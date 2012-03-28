-- TLC - The Tiny Lua Cocoa bridge
-- Note: Only tested on x86_64 & OS X >=10.7.3

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
-- Loading a class: objc_loadClass("MyClass")
-- Creating objects: MyClass:new() or MyClass:alloc():init()
   -- Objects returned by init* or new are automatically autoreleased
-- Calling methods: myInstance:doThis_withThis_andThat_(this, this, that)
   -- Colons in selectors are converted to underscores
-- Creating blocks: objc_createBlock(myFunction, returnType, argTypes)
   -- returnType: An encoded type specifying what the block should return (Consult https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html for reference)
   -- argTypes: An array of encoded types specifying the argument types the block expects

-- Note: Currently, in order to pass an object to a method, you must append '.id' to it, this is to
--      get the actual reference rather than the lua wrapper. This is not desirable and I will fix it asap
--      Example: Instead of myInstance:method_(anotherInstance) you'd do myInstance:method_(anotherInstance.id)

local objc_debug = false
local function objc_log(...)
	if objc_debug == true then
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

ffi.cdef([[
typedef struct objc_class *Class;
typedef struct objc_object {
	Class isa;
} *id;

typedef struct objc_selector *SEL;
typedef id (*IMP)(id, SEL, ...);
typedef signed char BOOL;
typedef struct objc_method *Method;

id objc_getClass(const char *name);
const char * class_getName(id cls);
Method class_getClassMethod(id aClass, SEL aSelector);
IMP class_getMethodImplementation(id cls, SEL name);
Method * class_copyMethodList(id cls, unsigned int *outCount);

SEL method_getName(Method method);
unsigned method_getNumberOfArguments(Method method);
void method_getReturnType(Method method, char *dst, size_t dst_len);
const char * method_getTypeEncoding(Method method);
void method_getArgumentType(Method method, unsigned int index, char *dst, size_t dst_len);
IMP method_getImplementation(Method method);
id object_getClass(id object);

Method class_getInstanceMethod(id aClass, SEL aSelector);
Method class_getClassMethod(id aClass, SEL aSelector);

SEL sel_registerName(const char *str);
const char* sel_getName(SEL aSelector);

const char *object_getClassName(id obj);

id objc_getMetaClass(const char *name);
BOOL class_isMetaClass(id cls);
id class_getSuperclass(id cls);

void free(void *ptr);

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
typedef double CGFloat;
typedef struct CGPoint { CGFloat x; CGFloat y; } CGPoint;
typedef struct CGSize { CGFloat width; CGFloat height; } CGSize;
typedef struct CGRect { CGPoint origin; CGSize size; } CGRect;
typedef struct CGAffineTransform { CGFloat a; CGFloat b; CGFloat c; CGFloat d; CGFloat tx; CGFloat ty; } CGAffineTransform;

typedef long NSInteger;
typedef unsigned long NSUInteger;
typedef struct _NSRange { NSUInteger location; NSUInteger length; } NSRange;
typedef struct _NSZone NSZone;
// NSString dependencies
struct _NSStringBuffer {};
]])


local objc_getClass = ffi.C.objc_getClass
local objc_getMetaClass = ffi.C.objc_getMetaClass

local class_getInstanceMethod = ffi.C.class_getInstanceMethod
local class_getClassMethod = ffi.C.class_getClassMethod
local class_isMetaClass = ffi.C.class_isMetaClass
local class_getSuperclass = ffi.C.class_getSuperclass
local class_copyMethodList = ffi.C.class_copyMethodList
class_getName = function(class)
	return ffi.string(ffi.C.class_getName(class))
end

local object_getClass = ffi.C.object_getClass
local object_getClassName = function(name)
	return ffi.string(ffi.C.object_getClassName(name))
end

local method_getNumberOfArguments = ffi.C.method_getNumberOfArguments
local method_getImplementation = ffi.C.method_getImplementation
local method_getReturnType = ffi.C.method_getReturnType
local method_getArgumentType = ffi.C.method_getArgumentType

local function objc_selToStr(sel)
	return ffi.string(ffi.C.sel_getName(sel))
end
local function objc_strToSel(str)
	return ffi.C.sel_registerName(str)
end
local SEL=objc_strToSel

local free = ffi.C.free


-- Stores references to method implementations
objc_classMethodRegistry = {}
objc_instanceMethodRegistry = {}


-- Takes a single ObjC type encoded, and converts it to a C type specifier
local function objc_typeEncodingToCType(aEncoding)
	i = 1
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
		name = aEncoding:sub(aEncoding:find("[^=^(]+"))
		if name == "?" then
			objc_log("Anonymous unions not supported: "..aEncoding)
			return nil
		end
		ret = ret .. "union "..name
	elseif c == "{" then
		name = aEncoding:sub(aEncoding:find("[^=^{]+"))
		if name == "?" then
			objc_log("Anonymous structs not supported "..aEncoding)
			return nil
		end
		ret = ret .. "struct "..name
	else
		objc_log("Error! type encoding '"..aEncoding.."' is not supported")
		return nil
	end

	if isPtr == true then
		ret = ret.."*"
	end
	return ret
end

local function _objc_readMethod(method)
	ret = {
		method = method,
		argCount = method_getNumberOfArguments(method),
	}

	local imp = method_getImplementation(method);
	-- Typecast the IMP
	local typePtr = ffi.new("char[512]")

	method_getReturnType(method, typePtr, 512)
	local retTypeStr = objc_typeEncodingToCType(ffi.string(typePtr))
	if retTypeStr == nil then
		return nil
	end
	local impTypeStr = ""..retTypeStr.." (*)("

	local argCount = ret.argCount
	local shouldCancel = false
	for j=0, argCount-1 do
		method_getArgumentType(method, j, typePtr, 512);
		local typeStr = ffi.string(typePtr)
		typeStr =  objc_typeEncodingToCType(typeStr)
		-- If we encounter an unsupported type, we skip loading this method
		if typeStr == nil then
			shouldCancel = true
			break
		end
		if j < argCount-1 then
			typeStr = typeStr..","
		end
		impTypeStr = impTypeStr..typeStr
	end

	if shouldCancel == true then
		return nil
	end

	impTypeStr = impTypeStr..")"
	objc_log("Loading method:",objc_selToStr(ffi.C.method_getName(method)), impTypeStr)
	objc_log(impTypeStr)
	ret.imp = ffi.cast(impTypeStr, imp)

	return ret
end

local function _objc_readMethods(obj, cache)
	local count = ffi.new("unsigned int[1]")
	local list = class_copyMethodList(obj, count)
	for i=0, count[0]-1 do
		local method = list[i]
		local selector = ffi.C.method_getName(method)
		local selStr = objc_selToStr(selector)

		cache[selStr] = _objc_readMethod(method)
	end
    free(list)
end

-- Wrapper for an objc class
objc_classWrapper = ffi.metatype("union { id id; }", {
	__index = function(proxy,selStr)
		selStr = selStr:gsub("_", ":")
		return function(self, ...)
			objc_log("Calling +"..selStr)
			local methods = objc_classMethodRegistry[class_getName(self.id)]
			local method = methods[selStr]
			if method == nil then
				-- Try loading it (in case it was defined in a superclass)
				local methodDesc = class_getClassMethod(self.id, SEL(selStr))
		
				if ffi.cast("void*", methodDesc) > nil then
					methodDesc = _objc_readMethod(methodDesc)
					methods[selStr] = methodDesc
					method = methodDesc
				else
					error("Unknown selector "..selStr)
				end
			end
			
			local ret = method.imp(self.id, SEL(selStr), ...)

			if ffi.istype("id", ret) then
				ret = objc_wrapper(ret)
			end
			return ret
		end
	end
})

-- Wrapper around an instance of an objc class
objc_wrapper = ffi.metatype("struct { id id; }", {
	__index = function(proxy,selStr)
		selStr = selStr:gsub("_", ":")
		return function(self, ...)
			local className = object_getClassName(ffi.cast("id", self.id))
			objc_log("Calling -["..className.." "..selStr.."]")
			local methods = objc_instanceMethodRegistry[className]
			-- If the class hasn't been loaded already, load it
			if methods == nil then
				objc_loadClass(className)
				methods = objc_instanceMethodRegistry[className]
				if methods == nil then
					error("Could not find class "..className)
				end
			end

			local method = methods[selStr]
			if method == nil then
				-- Try loading it (in case it was defined in a superclass)
				local methodDesc = class_getInstanceMethod(object_getClass(self.id), SEL(selStr))

				if ffi.cast("void*", methodDesc) > nil then
					methodDesc = _objc_readMethod(methodDesc)
					methods[selStr] = methodDesc
					method = methodDesc
				else
					error("Unknown selector "..selStr)
				end
			end

			local ret = method.imp(self.id, SEL(selStr), ...)

			if ffi.istype("id", ret) then
				ret = objc_wrapper(ret)
				-- Autorelease retained objects
				if selStr:sub(1,4) == "init" or selStr == "new" then
					ret:autorelease()
				end
			end
			return ret
		end
	end
})


-- Loads the class for a given name (Only caches the methods defined in the class itself, other methods are cached on first usage)
function objc_loadClass(aClassName)
	local class = objc_getClass(aClassName)
	if(objc_classMethodRegistry[aClassName]) then
		return objc_classWrapper(class)
	end
	local metaClass = objc_getMetaClass(aClassName)

	objc_classMethodRegistry[aClassName] = objc_classMethodRegistry[aClassName] or { }
	objc_instanceMethodRegistry[aClassName] = objc_instanceMethodRegistry[aClassName] or { }

	_objc_readMethods(metaClass, objc_classMethodRegistry[aClassName])
	_objc_readMethods(class, objc_instanceMethodRegistry[aClassName])
	
	ret = objc_classWrapper(class)
	_G[aClassName] = ret
	return ret
end

-- Convenience functions

objc_loadClass("NSString")
function objc_strToObj(aStr)
	return NSString:stringWithUTF8String_(aStr)
end
function objc_objToStr(aObj)
	local str = aObj:description():UTF8String()
	return ffi.string(str)
end


-- Blocks

local objc_sharedBlockDescriptor = ffi.new("struct __block_descriptor_1")
objc_sharedBlockDescriptor.reserved = 0;
objc_sharedBlockDescriptor.size = ffi.sizeof("struct __block_literal_1")

local _NSConcreteGlobalBlock = ffi.C._NSConcreteGlobalBlock

-- Wraps a function to be used with a block
local function _objc_createBlockWrapper(lambda, retType, argTypes)
	-- Build a function definition string to cast to
	retType = retType or "v"
	argTypes = argTypes or {"v"}

	retType = objc_typeEncodingToCType(retType)
	if retType == nil then
		return nil
	end
	local funTypeStr = ""..retType.." (*)(void *,"

	local shouldCancel = false
	for i,typeStr in pairs(argTypes) do
		typeStr = objc_typeEncodingToCType(typeStr)
		-- If we encounter an unsupported type, we skip loading this method
		if typeStr == nil then
			shouldCancel = true
			break
		end
		if i < #argTypes then
			typeStr = typeStr..","
		end
		funTypeStr = funTypeStr..typeStr
	end

	if shouldCancel == true then
		return nil
	end
	funTypeStr = funTypeStr..")"
	objc_log(funTypeStr)
	
	ret = function(theBlock, ...)
		return lambda(...)
	end
	return ffi.cast(funTypeStr, ret)
end

-- Creates a block and returns it typecast to 'id'
function objc_createBlock(lambda, retType, argTypes)
	if not lambda then
		return nil
	end
	local block = ffi.new("struct __block_literal_1")
	block.isa = _NSConcreteGlobalBlock
	block.flags = bit.lshift(1, 29)
	block.reserved = 0
	block.invoke = ffi.cast("void*", _objc_createBlockWrapper(lambda, retType, argTypes))
	block.descriptor = objc_sharedBlockDescriptor

	return ffi.cast("id", block)
end
