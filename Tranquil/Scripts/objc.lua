-- TLC - The Tiny Lua Cocoa bridge
-- Note: Only tested with LuaJit 2 Beta 9 on x86_64 with OS X >=10.7.3 & iPhone 4 with iOS 5

-- Copyright (c) 2012, Fjölnir Ásgeirsson

-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.

-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-- Usage:
-- Accessing a class: MyClass = objc.MyClass
-- Loading a framework: objc.loadFramework("AppKit")
   -- Foundation is loaded by default.
   -- The table objc.frameworkSearchPaths, contains a list of paths to search (formatted like /System/Library/Frameworks/%s.framework/%s)
-- Creating objects: MyClass.new() or MyClass.alloc().init()
   -- Retaining&Releasing objects is handled by the lua garbage collector so you should never need to call retain/release
-- Calling methods: myInstance.doThis_withThis_andThat(this, this, that)
   -- Colons in selectors are converted to underscores (last one being optional)
-- Creating blocks: objc.createBlock(myFunction, returnType, argTypes)
   -- returnType: An encoded type specifying what the block should return (Consult https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html for reference)
   -- argTypes: An array of encoded types specifying the argument types the block expects
   -- Both return and argument types default to void if none are passed

-- Demo:
-- objc = require("objc")
-- objc.loadFramework("AppKit")
-- pool = objc.NSAutoreleasePool.new()
-- objc.NSSpeechSynthesizer.new().startSpeakingString(objc.strToObj("Hello From Lua!"))
-- pool.drain()

local ffi = require("ffi")

local objc = {
	debug = false,
	frameworkSearchPaths = {
		"/System/Library/Frameworks/%s.framework/%s",
		"/Library/Frameworks/%s.framework/%s",
		"~/Library/Frameworks/%s.framework/%s"
	}
}
-- Automatically load classes when requested (On subsequent accesses they will not be reloaded)
setmetatable(objc, {
	__index = function(t, key)
		return objc.loadClass(key)
	end
})

local function _log(...)
	if objc.debug == true then
		local output
		for i,arg in pairs({...}) do
			if i == 1 then
				output = tostring(arg)
			else
				output = output .. ",   " .. tostring(arg)
			end
		end
		io.stderr:write(output .. "\n")
	end
end

if ffi.abi("64bit") then
	ffi.cdef([[
	typedef double CGFloat;
	typedef long NSInteger;
	typedef unsigned long NSUInteger;
	]])
else
	ffi.cdef([[
	typedef float CGFloat;
	typedef int NSInteger;
	typedef unsigned int NSUInteger;
	]])
end

ffi.cdef([[
typedef struct objc_class *Class;
struct objc_class { Class isa; };
typedef struct objc_object { Class isa; } *id;

typedef struct objc_selector *SEL;
typedef id (*IMP)(id, SEL, ...);
typedef signed char BOOL;
typedef struct objc_method *Method;

id objc_msgSend(id theReceiver, SEL theSelector, ...);

Class objc_getClass(const char *name);
const char *class_getName(Class cls);
Method class_getClassMethod(Class aClass, SEL aSelector);
IMP class_getMethodImplementation(Class cls, SEL name);
Method *class_copyMethodList(Class cls, unsigned int *outCount);

SEL method_getName(Method method);
unsigned method_getNumberOfArguments(Method method);
void method_getReturnType(Method method, char *dst, size_t dst_len);
const char * method_getTypeEncoding(Method method);
void method_getArgumentType(Method method, unsigned int index, char *dst, size_t dst_len);
IMP method_getImplementation(Method method);
Class object_getClass(id object);

Method class_getInstanceMethod(Class aClass, SEL aSelector);
Method class_getClassMethod(Class aClass, SEL aSelector);

SEL sel_registerName(const char *str);
const char* sel_getName(SEL aSelector);

const char *object_getClassName(id obj);

id objc_getMetaClass(const char *name);
BOOL class_isMetaClass(Class cls);
id class_getSuperclass(Class cls);

void free(void *ptr);
void CFRelease(id obj);

// http://clang.llvm.org/docs/Block-ABI-Apple.txt
struct __block_descriptor_1 {
	unsigned long int reserved; // NULL
	unsigned long int size; // sizeof(struct __block_literal_1)
}

struct __block_literal_1 {
	struct __block_literal_1 *isa;
	int flags;
	int reserved;
	void *invoke;
	struct __block_descriptor_1 *descriptor;
}
struct __block_literal_1 *_NSConcreteGlobalBlock;

// NSObject dependencies
typedef struct CGPoint { CGFloat x; CGFloat y; } CGPoint;
typedef struct CGSize { CGFloat width; CGFloat height; } CGSize;
typedef struct CGRect { CGPoint origin; CGSize size; } CGRect;
typedef struct CGAffineTransform { CGFloat a; CGFloat b; CGFloat c; CGFloat d; CGFloat tx; CGFloat ty; } CGAffineTransform;
typedef struct _NSRange { NSUInteger location; NSUInteger length; } NSRange;
typedef struct _NSZone NSZone;

// Opaque dependencies
struct _NSStringBuffer;
struct __CFCharacterSet;
struct __GSFont;
struct __CFString;
struct __CFDictionary;
struct __CFArray;
struct __CFAllocator;
struct _NSModalSession;

int access(const char *path, int amode);
]])

local C = ffi.C

ffi.load("/usr/lib/libobjc.A.dylib", true)

function objc.loadFramework(name)
	for i,path in pairs(objc.frameworkSearchPaths) do
		path = path:format(name,name)
		if C.access(path, bit.lshift(1,2)) == 0 then
			return ffi.load(path, true)
		end
	end
	error("Error! Framework '"..name.."' not found.")
end

objc.loadFramework("Foundation")
objc.loadFramework("CoreFoundation")

CGPoint = ffi.metatype("CGPoint", {})
CGSize = ffi.metatype("CGSize", {})
CGRect = ffi.metatype("CGRect", {})
CGAffineTransform = ffi.metatype("CGAffineTransform", {})
NSRange = ffi.metatype("NSRange", {})

local function _selToStr(sel)
	return ffi.string(ffi.C.sel_getName(sel))
end
local function _strToSel(str)
	return ffi.C.sel_registerName(str)
end
local SEL=_strToSel

-- Stores references to method implementations
local _objc_classMethodRegistry = {}
local _objc_instanceMethodRegistry = {}


-- Takes a single ObjC type encoded, and converts it to a C type specifier
local function _typeEncodingToCType(aEncoding)
	local i = 1
	local ret = ""
	local isPtr = false

	if aEncoding:sub(i,i) == "^" then
		isPtr = true
		i = i+1
	end

	-- First check type qualifiers
	if aEncoding:sub(i,i) == "r" then
		ret = ret .. "const "
		i = i+1
	end

	-- Unused qualifiers
	if     aEncoding:sub(i,i)  == "n" then i = i+1
	elseif aEncoding:sub(i,i)  == "o" then i = i+1
	elseif aEncoding:sub(i,i)  == "N" then i = i+1
	end
	if aEncoding:sub(i,i) == "R" then i = i+1; end
	if aEncoding:sub(i,i) == "V" then i = i+1; end

	-- Then type encodings
	local c = aEncoding:sub(i,i)

	if c == "@" then
		ret = ret .. "id"
	elseif c == "#" then
		ret = ret .. "Class"
	elseif c == "c" then
		ret = ret .. "char"
	elseif c == "C" then
		ret = ret .. "unsigned char"
	elseif c == "s" then
		ret = ret .. "short"
	elseif c == "S" then
		ret = ret .. "unsigned short"
	elseif c == "i" then
		ret = ret .. "int"
	elseif c == "I" then
		ret = ret .. "unsigned int"
	elseif c == "l" then
		ret = ret .. "long"
	elseif c == "L" then
		ret = ret .. "unsigned long"
	elseif c == "q" then
		ret = ret .. "long long"
	elseif c == "Q" then
		ret = ret .. "unsigned long long"
	elseif c == "f" then
		ret = ret .. "float"
	elseif c == "d" then
		ret = ret .. "double"
	elseif c == "B" then
		ret = ret .. "BOOL"
	elseif c == "v" then
		ret = ret .. "void"
	elseif c == "^" then
		ret = ret .. "void *"
	elseif c == "*" then
		ret = ret .. "char *"
	elseif c == ":" then
		ret = ret .. "SEL"
	elseif c == "?" then
		ret = ret .. "void"
	elseif c == "(" then
		local name = aEncoding:sub(aEncoding:find("[^=^(]+"))
		if name == "?" then
			_log("Anonymous unions not supported: "..aEncoding)
			return nil
		end
		ret = ret .. "union "..name
	elseif c == "{" then
		local name = aEncoding:sub(aEncoding:find("[^=^{]+"))
		if name == "?" then
			_log("Anonymous structs not supported "..aEncoding)
			return nil
		end
		ret = ret .. "struct "..name
	else
		_log("Error! type encoding '"..aEncoding.."' is not supported")
		return nil
	end

	if isPtr == true then
		ret = ret.."*"
	end
	return ret
end

local function _readMethod(method)
	local imp = C.method_getImplementation(method);
	-- Typecast the IMP
	local typePtr = ffi.new("char[512]")

	C.method_getReturnType(method, typePtr, 512)
	local retTypeStr = _typeEncodingToCType(ffi.string(typePtr))
	if retTypeStr == nil then
		return nil
	end
	local impTypeStr = ""..retTypeStr.." (*)("

	local argCount = C.method_getNumberOfArguments(method)
	for j=0, argCount-1 do
		C.method_getArgumentType(method, j, typePtr, 512);
		local typeStr = ffi.string(typePtr)
		typeStr =  _typeEncodingToCType(typeStr)
		-- If we encounter an unsupported type, we skip loading this method
		if typeStr == nil then
			return nil
		end
		if j < argCount-1 then
			typeStr = typeStr..","
		end
		impTypeStr = impTypeStr..typeStr
	end

	impTypeStr = impTypeStr..")"
	_log("Loading method:",_selToStr(ffi.C.method_getName(method)), impTypeStr)

	return ffi.cast(impTypeStr, imp)
end

local function _readMethods(obj, cache)
	local count = ffi.new("unsigned int[1]")
	local list = C.class_copyMethodList(obj, count)
	for i=0, count[0]-1 do
		local method = list[i]
		local selector = C.method_getName(method)
		local selStr = _selToStr(selector)

		cache[selStr] = _readMethod(method)
	end
    C.free(list)
end

ffi.metatype("struct objc_class", {
	__index = function(self,selStr)
		selStr = selStr:gsub("_", ":")
		return function(...)
			local argCount = #{...}
			if argCount > 0 and selStr:sub(-1,-1) ~= ":" then
				for i=1, argCount do selStr = selStr..":" end
			end

			local className = ffi.string(C.class_getName(ffi.cast("Class", self)))
			_log("Calling +["..className.." "..selStr.."]")
			local methods = _objc_classMethodRegistry[className]
			local method = methods[selStr]
			if method == nil then
				-- Try loading it (in case it was implemented in a superclass)
				local methodDesc = C.class_getClassMethod(self, SEL(selStr))
		
				if ffi.cast("void*", methodDesc) > nil then
					method = _readMethod(methodDesc)
					methods[selStr] = method
				else
					method = C.objc_msgSend
				end
			end

			local success, ret = pcall(method, ffi.cast("id", self), SEL(selStr), ...)
			if success == false then
				error(ret.."\n"..debug.traceback())
			end

			if ffi.istype("struct objc_object*", ret) then
				if not (selStr:sub(1,5) == "alloc" or selStr == "new")  then
					ret.retain()
				end
				ret = ffi.gc(ret, C.CFRelease)
			end
			return ret
		end
	end,
	-- Grafts a lua function onto the class as an instance method, it will only be callable from lua though
	__newindex = function(self,selStr,lambda)
		selStr = selStr:gsub("_", ":")
		local className = C.class_getName(ffi.cast("Class", self))
		local methods = _objc_instanceMethodRegistry[className]
		if not (methods == nil) then
			methods[selStr] = lambda
		end
	end
})

ffi.metatype("struct objc_object", {
	__index = function(self,selStr)
		selStr = selStr:gsub("_", ":")
		return function(...)
			local argCount = #{...}
			if argCount > 0 and selStr:sub(-1,-1) ~= ":" then
				for i=1, argCount do selStr = selStr..":" end
			end

			local className = ffi.string(C.object_getClassName(ffi.cast("id", self)))
			_log("Calling -["..className.." "..selStr.."]")
			local methods = _objc_instanceMethodRegistry[className]
			-- If the class hasn't been loaded already, load it
			if methods == nil then
				objc.loadClass(className)
				methods = _objc_instanceMethodRegistry[className]
				if methods == nil then
					error("Could not find class "..className.."\n"..debug.traceback())
				end
			end

			local method = methods[selStr]
			if method == nil then
				-- Try loading it (in case it was implemented in a superclass)
				local methodDesc = C.class_getInstanceMethod(C.object_getClass(self), SEL(selStr))

				if ffi.cast("void*", methodDesc) > nil then
					method = _readMethod(methodDesc)
					methods[selStr] = method
				else
					method = C.objc_msgSend
				end
			end

			local success, ret = pcall(method, ffi.cast("id", self), SEL(selStr), ...)
			if success == false then
				error(ret.."\n"..debug.traceback())
			end

			if ffi.istype("struct objc_object*", ret) and not (selStr == "retain" or selStr == "release") then
				-- Retain objects that need to be retained
				if not (selStr:sub(1,4) == "init" or selStr:sub(1,4) == "copy" or selStr:sub(1,11) == "mutableCopy") then
					ret.retain()
				end
				ret = ffi.gc(ret, C.CFRelease)
			end
			return ret
		end
	end
})


-- Loads the class for a given name (Only caches the methods defined in the class itself, other methods are cached on first usage)
function objc.loadClass(aClassName)
	local class = C.objc_getClass(aClassName)
	if(_objc_classMethodRegistry[aClassName]) then
		return class
	end
	local metaClass = C.objc_getMetaClass(aClassName)

	_objc_classMethodRegistry[aClassName] = _objc_classMethodRegistry[aClassName] or { }
	_objc_instanceMethodRegistry[aClassName] = _objc_instanceMethodRegistry[aClassName] or { }

	_readMethods(ffi.cast("Class", metaClass), _objc_classMethodRegistry[aClassName])
	_readMethods(class, _objc_instanceMethodRegistry[aClassName])

	objc[aClassName] = class
	return class
end

-- Convenience functions

function objc.strToObj(aStr)
	return objc.NSString.stringWithUTF8String_(aStr)
end
function objc.objToStr(aObj)
	local str = aObj.description().UTF8String()
	return ffi.string(str)
end


-- Blocks

local _sharedBlockDescriptor = ffi.new("struct __block_descriptor_1")
_sharedBlockDescriptor.reserved = 0;
_sharedBlockDescriptor.size = ffi.sizeof("struct __block_literal_1")

-- Wraps a function to be used with a block
local function _createBlockWrapper(lambda, retType, argTypes)
	-- Build a function definition string to cast to
	retType = retType or "v"
	argTypes = argTypes or {"v"}

	retType = _typeEncodingToCType(retType)
	if retType == nil then
		return nil
	end
	local funTypeStr = ""..retType.." (*)(void *,"

	for i,typeStr in pairs(argTypes) do
		typeStr = _typeEncodingToCType(typeStr)
		-- If we encounter an unsupported type, we skip loading this method
		if typeStr == nil then
			return nil
		end
		if i < #argTypes then
			typeStr = typeStr..","
		end
		funTypeStr = funTypeStr..typeStr
	end

	funTypeStr = funTypeStr..")"
	_log("Created block with signature:", funTypeStr)
	
	ret = function(theBlock, ...)
		return lambda(...)
	end
	return ffi.cast(funTypeStr, ret)
end

-- Creates a block and returns it typecast to 'id'
function objc.createBlock(lambda, retType, argTypes)
	if not lambda then
		return nil
	end
	local block = ffi.new("struct __block_literal_1")
	block.isa = C._NSConcreteGlobalBlock
	block.flags = bit.lshift(1, 29)
	block.reserved = 0
	block.invoke = ffi.cast("void*", _createBlockWrapper(lambda, retType, argTypes))
	block.descriptor = _sharedBlockDescriptor

	return ffi.cast("id", block)
end

return objc
