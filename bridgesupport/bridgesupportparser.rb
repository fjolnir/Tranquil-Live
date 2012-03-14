require 'iconv'
require 'pathname'
require 'rexml/document'
require 'set'

require 'bridgesupportparser.so'

module Bridgesupportparser
    def self.add_blockattrs(hash)
	@blockattrs = @blockattrs0.nil? ? hash : @blockattrs0.merge(hash)
    end

    def self.blockattr?(k)
	@blockattrs ||= @blockattrs0 || {}
	@blockattrs.has_key?(k)
    end

    # This lambda (returned by Bridgesupportparser::custom_recursive_merge_64)
    # can be used to merge 64-bit attributes into 32-bit attributes, when
    # passed to Parser#set_custom_recursive_merge.
    @custom_recursive_merge_64 = lambda do |k, a0, a1|
	m = k.to_s.match(/^(.*)64$/)
	if m
	    k0 = m[1].to_sym
	    return if a0.include?(k0) && a0[k0].eql?(a1[k])
	end
	a0[k] = a1[k]
    end

    def self.custom_recursive_merge_64
	@custom_recursive_merge_64
    end

    def self.rename_attrs64
	{
	    :_ctype => :_ctype64,
	    :declared_type => :declared_type64,
	    :sel_of_type => :sel_of_type64,
	    :type => :type64,
	    :value => :value64,
	}
    end

    class MergingArray < Array
	attr_reader :name

	def initialize(name = 'MergingArray', *args)
	    super(*args)
	    @name = name
	end

	def []=(n, v)
	    if self[n].nil?
		super
	    else
		if self[n].respond_to?(:recursive_merge!)
		    self[n].recursive_merge!(v)
		else
		    if !self[n].eql?(v)
			warn "MergingArray:#{@name}[#{n}]: #{self[n]} => #{v}"
			super
		    end
		end
	    end
	    self[n]
	end

	def recursive_merge!(ary)
	    (self.length >= ary.length ? self : ary).each_index do |i|
		self[i] = ary[i] unless ary[i].nil?
	    end
	end
    end

    class MergingHash < Hash
	attr_reader :name

	def initialize(name = 'MergingHash', *args)
	    super(*args)
	    @name = name
	end

	def []=(k, v)
	    if self.include?(k)
		if self[k].respond_to?(:recursive_merge!)
		    #print "MergingHash: k=#{k} v=#{v.inspect} #{self[k].inspect}" #DEBUG
		    self[k].recursive_merge!(v)
		    #puts " => #{self[k].inspect}" #DEBUG
		else
		    if !self[k].eql?(v)
			warn "MergingHash:#{@name}[#{k}]: #{self[k]} => #{v}"
			super
		    end
		end
	    else
		super
	    end
	    self[k]
	end

	def recursive_merge!(m)
	    m.each { |k, v| self[k] = v }
	end
    end

    class MergingSequence < MergingArray
	attr_reader :name

	def initialize(name, *argv)
	    super
	    @index = 0
	end

	def <<(a)
	    a[:_index] = @index
	    super
	    @index += 1
	end
    end

    class MergingSet < Set
	alias_method :orig_add, :add
	attr_reader :name
	def initialize(name = 'MergingSet', *args)
	    super(*args)
	    @name = name
	end

	def add(x)
	    found = self.any? do |s|
		if s.eql?(x)
		    s.recursive_merge!(x) if s.respond_to?(:recursive_merge!)
		    true
		else
		    false
		end
	    end
	    self.orig_add(x) if !found
	end

	def recursive_merge!(enum)
	    enum.each { |e| add(e) }
	end
    end

    class Base # abstract
	attr_reader :attrs

	class << self
	    attr_reader :attr_transform, :element_name

	    def attrmap
		@attrmap ||= (@attrmap0 || {})
	    end

	    def blockattr?(k)
		@blockattrs ||= @blockattrs0 || {}
		return true if Bridgesupportparser.blockattr?(k)
		@blockattrs.has_key?(k)
	    end

	    # By default, attributes are blocked if their names begin with
	    # underscore, or if the blockattr? method returns true for that key.
	    # The set_attr_transform method provides a more general approach
	    # to determining what attributes will be displayed.  It is passed
	    # a Proc instance, and this Proc will be passed two argument.  The
	    # first argument is the attribute hash to process, while the second
	    # argument is lambda that given a key, will call the class-specific
	    # blockattr? method (which can be ignored if unneeded).  The Proc
	    # instance should return a new hash (or array of arrays of key/value
	    # pairs) that will substitute for the original attribute hash.  If
	    # the return is nil or an empty hash/array, no xml will be generate.
	    def set_attr_transform(t)
		@attr_transform = t
	    end
	end

	@@valmap = {
	    'false' => false,
	    'true' => true,
	}

	def self.add_blockattrs(hash)
	    @blockattrs = @blockattrs0.nil? ? hash : @blockattrs0.merge(hash)
	end

	def initialize(parser, name)
	    @parser = parser
	    @_name = "<#{self.class}>#{(name and !name.empty?) ? name : '<anonymous>'}"
	    @attrs = MergingHash.new(@_name)
	    @parser.add_attrs(@attrs)
	    self[:name] = name if name and !name.empty?
	end

	def initialize_copy(orig)
	    @attrs = orig.attrs.dup
	    @parser.add_attrs(@attrs)
	end

	# default accessors (mutators not supported)
	def method_missing(sym)
	    self[sym]
	end

	def [](k)
	    @attrs[k]
	end

	def []=(k, v)
	    if self.class.attrmap.include?(k)
		key, val = self.class.attrmap[k].call(k, v)
	    else
		key, val = k, v
	    end
	    val = @@valmap.fetch(val, val);
	    @attrs[key] = val unless val.nil?
	end

	def <=>(x)
	    self[:name] <=> x[:name]
	end

	def delete(k)
	    @attrs.delete(k)
	end

	def each(&block)
	    if block
		@attrs.each &block
	    end
	end

	def element
	    attr_transform = self.class.attr_transform
	    if attr_transform.nil?
		attrs = @attrs.select { |k, v| k.to_s[0] != ?_ && !self.class.blockattr?(k)}
	    else
		klass = self.class
		attrs = attr_transform.call(@attrs, lambda { |a| klass.blockattr?(a) })
	    end
	    #puts "Base: #{self.name} attrs=#{attrs.inspect}" #DEBUG
	    return nil if attrs.nil? || attrs.empty?
	    e = REXML::Element.new(self.class.element_name)
	    attrs.each { |k, v| e.attributes[k.to_s] = v }
	    e
	end

	def eql?(o)
	    self[:name] == o[:name]
	end

	def hash
	    self[:name].hash
	end

	def recursive_merge!(m)
	    custom_recursive_merge = @parser.custom_recursive_merge
	    #puts "Bridgesupportparser::Base.recursive_merge!: #{@attrs.inspect} #{m.attrs.inspect} custom_recursive_merge=#{custom_recursive_merge.inspect}" #DEBUG
	    if custom_recursive_merge.nil?
		@attrs.recursive_merge!(m.attrs)
	    else
		m.attrs.each_key { |k| custom_recursive_merge.call(k, @attrs, m.attrs) }
	    end
	end

	def type # avoid deprecation warning for Object#type
	    self[:type]
	end
    end

    class CFTypeInfo < Base
	@element_name = 'cftype'

	def initialize(parser, name, enc, attrs = nil, func = nil)
	    super(parser, name)
	    self[:type] = enc if enc and !enc.empty?
	    attrs.each { |k, v| self[k] = v } if attrs
	    self[:gettypeid_func] = func if func and !func.empty?
	end
    end

    class FunctionAliasInfo < Base
	@element_name = 'function_alias'

	def initialize(parser, name, orig)
	    super(parser, name)
	    self[:original] = orig
	end
    end

    class OpaqueInfo < Base
	@element_name = 'opaque'

	def initialize(parser, name, enc)
	    super(parser, name)
	    self[:type] = enc if enc and !enc.empty?
	end
    end

    class ValueInfo < Base # abstract
	@element_name = 'enum'

	def initialize(parser, name, value)
	    super(parser, name)
	    self[:value] = value unless value.nil?
	end
    end

    class EnumInfo < ValueInfo
	@element_name = 'enum'
    end

    class NumberInfo < ValueInfo
	@element_name = 'enum'
    end

    class NumberFuncCallInfo < ValueInfo
	@element_name = 'enum'

	def initialize(parser, name)
	    super(parser, name, nil)
	end
    end

    class StringInfo < ValueInfo
	@element_name = 'string_constant'
	@@iconv = Iconv.new('UTF-8', 'MACROMAN')

	def initialize(parser, name, value, nsstring = false)
	    # make sure the string is UTF-8.  If not, assume it is MacRoman
	    # and convert to UTF-8
	    begin
		value.unpack('U*') # throws exception if not UTF-8
	    rescue
		value = @@iconv.iconv(value)
	    end
	    super(parser, name, value)
	    self[:nsstring] = true if nsstring
	end
    end

    class VarInfoBase < Base #abstract
	def initialize(parser, name, type, enc, attrs = nil, funcptr = nil)
	    super(parser, name)
	    if type
		self[:_ctype] = type
		t = type.gsub( /\[[^\]]*\]/, '*' )
		re = /\b(__)?const\b/
		if t.match(re)
		    # don't set :const if the const is only part of the arguments
		    # to a function pointer
		    self[:const] = true if t.sub(/\(.*/, '').match(re)
		    t.gsub!(re, '')
		end
		t.gsub!(/<[^>]*>/, '')
		t.gsub!(/\b(in|out|inout|oneway|const)\b/, '')
		t.gsub!(/\b(__private_extern__|restrict)\b/, '')
		t.strip!
		t.squeeze!(' ')
		t.sub!(/\s+(\*+)$/, '\1')
		raise "empty type (was '#{type}')" if t.empty?
		self[:declared_type] = t
	    end
	    #self[:type] = enc if enc
	    if enc
		if enc =~ /^\^*\{\?=/
		    # An unnamed structure typedef.  Use the typedef name
		    # from declared_type.
		    td = self[:declared_type].gsub(/[^\w]/, '')
		    enc.sub!(/^(\^*)\{\?=/, "\\1{_#{td}=")
		    self[:_type_override] = true
		elsif t
		    case t
		    when /^(BOOL|Boolean)$/
			# the encoding should already be 'B' (custom header files)
			self[:_type_override] = true
		    when /^(BOOL|Boolean)\s*\*$/
			# the encoding should already be '^B' (custom header files)
			self[:_type_override] = true
		    end
		end
		self[:type] = enc
	    end
	    attrs.each { |k, v| self[k] = v } if attrs
	    if funcptr
		@funcptr = funcptr
		self[:function_pointer] = true
	    end
	end

	def element
	    e = super
	    return nil if e.nil?
	    if function_pointer?
		f = @funcptr.element
		#puts "VarInfo: #{self.name} funcptr=#{@funcptr} f=#{f.inspect}" #DEBUG
		f.each_element { |el| e.add_element(el) } if f
	    end
	    e
	end

	def function_pointer
	    @funcptr
	end

	def function_pointer?
	    self[:function_pointer]
	end

	def recursive_merge!(m)
	    super
	    if function_pointer?
		@funcptr.recursive_merge!(m.function_pointer) if m.function_pointer?
	    elsif m.function_pointer?
		@funcptr = m.function_pointer
	    end
	end

	def pointer_type?
	    self.type && self.type[0] == ?^
	end
    end

    class VarInfo < VarInfoBase
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'constant'

	def initialize(parser, name, type, enc, attrs = nil, funcptr = nil)
	    super
	    parser.all_varinfos << self
	end
    end

    class ArgInfo < VarInfo
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'arg'
    end

    class FieldInfo < VarInfoBase
	attr_accessor :resolved
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'field'
    end

    class RetvalInfo < VarInfo
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'retval'
    end

    class RetvalPtrInfo < VarInfo
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'retval'
    end

    class ObjCArgInfo < ArgInfo
	@attrmap0 = {
	    :in => lambda {|k, v| [:type_modifier, "n"]},
	    :_index => lambda {|k, v| [:index, v]},
	    :inout => lambda {|k, v| [:type_modifier, "N"]},
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	    :out => lambda {|k, v| [:type_modifier, "o"]},
	}
	@element_name = 'arg'

	def initialize(parser, name, type, enc, mod, attrs = nil, funcptr = nil)
	    super(parser, name, type, enc, attrs, funcptr)
	    if mod
		self[:type_modifier] = mod
		self[:_override] = true
	    end
	end
    end

    class ObjCRetvalInfo < VarInfo
	@attrmap0 = {
	    :nonnull => lambda {|k, v| [:null_accepted, !v]},
	}
	@element_name = 'retval'
    end

    class CallableInfo < Base # abstract
	attr_reader :argc, :args, :ret

	def initialize(parser, name, ret, args, attrs, variadic)
	    super(parser, name)
	    @ret = ret if ret
	    @args = args if args
	    @argc = @args.size if args
	    self[:variadic] = true if variadic
	    return unless attrs
	    attrs.each do |k, v|
		prefix, key = k.to_s.split(':', 2)
		if(!key.nil?)
		    case prefix
		    when 'return_value'
			@ret[key.intern] = v
		    end
		    next
		end
		case k
		when :format
		    which, str, first = v.split(',')
		    arg = @args[str.to_i - 1]
		    arg[:printf_format] = true unless arg.nil?
		when :nonnull
		    v.split(',').each do |n|
			arg = @args[n.to_i]
			arg[:null_accepted] = false unless arg.nil?
		    end
		else
		    self[k] = v
		end
	    end
	end

	def each_argument(&block)
	    if @args && block
		@args.each &block
	    end
	end

	def recursive_merge!(m)
	    super
	    @ret.recursive_merge!(m.ret) if m.ret
	    if @argc < m.argc
		warn "CallableInfo::recursive_merge!:#{@_name}:argc: #{@argc} => #{m.argc}"
		@argc = m.argc
	    end
	    @args.recursive_merge!(m.args) if m.args
	end

	def variadic?
	    self[:variadic] == true
	end
    end

    class FuncInfo < CallableInfo
	@element_name = 'function'

	def initialize(parser, name, ret, args, attrs, variadic, inline=false)
	    super(parser, name, ret, args, attrs, variadic)
	    self[:name] = name if name and !name.empty?
	    self[:inline] = true if inline
	end

	def <=>(x)
	    self[:name] <=> x[:name]
	end

	def dylib_wrapper(prefix = '_dw_')
	    lines = []
	    args = []
	    targs = []
	    i = 0
	    @args.each do |a|
		ai = "_a#{i}"
		args << ai
		targs << "#{a._ctype} #{ai}"
		i += 1
	    end
	    name = "#{prefix}#{self[:name]}"
	    proto = "#{@ret._ctype} #{name}(#{targs.join(', ')})"
	    lines << "#{proto} __asm(\"_#{self[:name]}\");"
	    lines << "#{proto} {"
	    cline = "    "
	    cline << "return " unless @ret.type == 'v'
	    cline << "#{self[:name]}(#{args.join(', ')});"
	    lines << cline
	    lines << "}\n"
	    lines.join("\n")
	end

	def element
	    # Function pointers may have no attributes at all, so could get
	    # optimized away.  Since the element is only use to hold the
	    # arguments to be passed to another element, we just create a
	    # dummy element, if needed
	    e = super || REXML::Element.new('DUMMY')
	    @args.each { |a| e.add_element(a.element) }
	    rete = @ret.element
	    e.add_element(rete) unless rete.nil?
	    e
	end

	def eql?(o)
	    self[:name] == o[:name]
	end

	def hash
	    self[:name].hash
	end

	def inline?
	    self[:inline] == true
	end
    end

    class MethodInfo < CallableInfo
	attr_reader :seltype

	@arg_select = nil
	@ret_select = nil
	class << self
	    attr_reader :arg_select, :ret_select

	    def set_arg_select(p)
		@arg_select = p
	    end

	    def set_ret_select(p)
		@ret_select = p
	    end
	end

	@attrmap0 = {
	    :name => lambda {|k, v| [:selector, v]},
	}
	@element_name = 'method'

	def initialize(parser, selector, menc, ret, args, attrs, is_class, variadic)
	    super(parser, selector, ret, args, attrs, variadic)
	    self[:class_method] = true if is_class
	    @seltype = menc
	end

	def <=>(o)
	    cmp = self[:selector] <=> o[:selector]
	    return cmp unless cmp == 0
	    return 0 if self[:class_method] == o[:class_method]
	    return -1 if self[:class_method]
	    return 1
	end

	def class_method?
	    self[:class_method] == true
	end

	def element
	    arg_select = self.class.arg_select
	    if arg_select.nil?
		args = @args
	    else
		args = @args.select { |a| arg_select.call(a) }
	    end
	    ret_select = self.class.ret_select
	    if ret_select.nil?
		ret = @ret
	    else
		ret = @ret if ret_select.call(@ret)
	    end
	    eargs = args.collect { |a| a.element }.compact
	    #puts "args.empty?=#{args.empty?} ret.nil?=#{ret.nil?}" #DEBUG
	    return nil if eargs.empty? && ret.nil? && self[:type].nil? && !self[:_override]
	    e = super
	    eargs.each { |a| e.add_element(a) }
	    if ret
		rete = ret.element
		e.add_element(rete) if rete
	    end
	    e
	end

	def eql?(o)
	    self[:selector] == o[:selector] && self[:class_method] == o[:class_method]
	end
	 
	def hash
	    self[:selector].hash
	end
    end

    class ObjCContainerInfo # abstract
	attr_reader :methods, :name, :protocols

	class << self
	    attr_reader :element_name
	end

	def initialize(parser, name, methods, protocols)
	    @parser = parser
	    @name = name
	    @methods = methods
	    @protocols = protocols
	end

	def concat(a)
	    @methods.recursive_merge!(a.methods)
	end

	def dup_methods
	    methods = Bridgesupportparser::MergingSet.new(@methods.name)
	    @methods.each { |m| methods << m.dup }
	    @methods = methods
	end

	def each_method(&block)
	    if @methods && block
		@methods.each &block
	    end
	end

	def each_protocol(&block)
	    if @protocols && block
		@protocols.each &block
	    end
	end

	def element
	    methods = @methods.sort.collect { |m| m.element } .compact
	    return nil if methods.empty?
	    e = REXML::Element.new(self.class.element_name)
	    e.attributes['name'] = @name
	    methods.each { |m| e.add_element(m) }
	    e
	end
	
	def recursive_merge!(m)
	    @methods.recursive_merge!(m.methods)
	    if @protocols
		@protocols.merge(m.protocols) if m.protocols
	    elsif m.protocols
		@protocols = m.protocols
	    end
	end
    end

    class ObjCCategoryInfo < ObjCContainerInfo
	attr_reader :klass
	@element_name = 'informal_protocol'

	def initialize(parser, name, klass, methods=Bridgesupportparser::MergingSet.new("category #{name} for #{klass}"), protocols=Set.new)
	    super(parser, name, methods, protocols)
	    @klass = klass
	end
    end

    class ObjCInterfaceInfo < ObjCContainerInfo
	@element_name = 'class'
    end

    class ObjCProtocolInfo < ObjCContainerInfo
    end

    class StructInfo < Base
	attr_accessor :resolved
	attr_reader :fields

	class << self
	    attr_accessor :block_fields
	end

	@block_fields = false
	@element_name = 'struct'

	def initialize(parser, name, encoding, fields)
	    super(parser, name)
	    self[:name] = name if name and !name.empty?
	    if encoding and !encoding.empty?
		if encoding =~ /^\{\?=/
		    enc = encoding.dup #DEBUG
		    # An unnamed structure typedef.  Use the StructInfo name
		    # for compatibility with previous gen_bridge_metadata.
		    encoding.sub!(/^\{\?=/, "{_#{name}=")
		    #puts "StructInfo: #{name} \"#{enc}\" => \"#{encoding}\"" #DEBUG
		end
		self[:type] = encoding
	    end
	    @fields = fields
	end

	def each_field(&block)
	    if @fields && block
		@fields.each &block
	    end
	end

	def element
	    e = super
	    return nil if e.nil?
	    if !self.class.block_fields
		@fields.each { |f| e.add_element(f.element) }
	    end
	    e
	end

	def recursive_merge!(m)
	    super
	    @fields.recursive_merge!(m.fields) if m.fields
	end

	def rename(n)
	    self.delete(:name) # to avoid recursive_merge! warnings
	    self[:name] = n
	end
    end

    class Parser
	attr_reader :all_attrs, :all_categories, :all_cftypes, :all_enums, :all_funcs, :all_func_aliases, :all_informal_protocols, :all_interfaces, :all_macronumbers, :all_macronumberfunccalls, :all_macrostrings, :all_opaques, :all_protocols, :all_structs, :all_varinfos, :all_vars, :custom_recursive_merge, :every_cftype, :special_method_encodings, :special_type_encodings

	# These values must match those in bridgesupport.cpp
	CONTENT = '__9_OxQk__4__c_0_n_T_3_n_t_'
	CONTENTEND = '__9_OxQk__4__3_0_F_'
	CONTENTMETHOD = CONTENT + '_m_3_T_h_0_d_'
	CONTENTTYPE = CONTENT + '_t_Y_p_3_'

	# There doesn't seem to be a foolproof way to determine if a typedef
	# whose name ends in "Ref" is a CFType or not.  So assuming that each
	# system framework is consistent, we create a list (stored in a hash)
	# for framework names where such typedefs are not CFTypes.
	DISABLE_CFTYPES = {
	    'CarbonCore' => true,
	    'JavaScriptCore' => true,
	}
	# This regexp extracts system framework names (including nested ones)
	FRAMEWORK_RE = Regexp.new('/System/Library/(?:Private)?Frameworks/(?:.*/)?([^/]*)\.framework/')

	def initialize(incs, paths, special_methods, special_types, defines = nil, incdirs = nil, sysroot = '/')
	    @all_attrs = []
	    @parsepaths = incs
	    puts "incs:\n#{incs.join("\n")}" if $DEBUG #DEBUG
	    puts "paths:\n#{paths.join("\n")}" if $DEBUG #DEBUG
	    if $DEBUG #DEBUG
		puts "incdirs:"
		incdirs.each { |i| puts "#{i[3..-1]} #{i[0,1]} #{i[1,1]} #{i[2,1]}" }
	    end #DEBUG
	    a = []
	    @special_methods = special_methods
	    @special_types = special_types
	    unless @special_methods.nil?
		@special_methods.each_index do |i|
		    t = @special_methods[i].sub(/^\s*[-+]/, '').sub(/;\s*$/, '').strip
		    a << "@interface #{CONTENTMETHOD}_#{i}\n" \
			+ "- #{t};\n" \
			+ "@end"
		end
		@special_method_encodings = []
	    end
	    unless @special_types.nil?
		@special_types.each_index { |i| a << "#{@special_types[i]} #{CONTENTTYPE}_#{i};\n" }
		@special_type_encodings = []
	    end
	    @parsecontent = a.join("\n") + "\n"
	    puts "parsecontent:\n#{@parsecontent}" if $DEBUG
	    #@parsedefines = ['__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__=1070']
	    #@parsedefines.concat(defines) unless defines.nil?
	    @parsedefines = defines;
	    @parseincdirs = incdirs
	    @parsesysroot = sysroot
	    # Allow header files in the directory hierarchies.  For framework
	    # directories, allow sub-framework headers.  The basename of the
	    # header must also match.
	    @parse_select = Set.new
	    @parse_select_basenames = {}
	    select = Set.new
	    paths.each do |p|
		select << Pathname.new(p).realpath.parent.to_s
		@parse_select_basenames[File.basename(p)] = true
	    end
	    select.each { |p| @parse_select << p.sub(/\.framework\/.*/, '.framework') }
	    #puts "@parse_select:\n#{@parse_select.to_a.join("\n")}" #DEBUG
	    #puts "@parse_select_basenames:\n#{@parse_select_basenames.keys.join("\n")}" #DEBUG
	    @parsepathcache = {CONTENT => [true, true]}
	    @all_categories = {}
	    @all_cftypes = Bridgesupportparser::MergingHash.new('all_cftypes')
	    @all_enums = Bridgesupportparser::MergingHash.new('all_enums')
	    @all_funcs = Bridgesupportparser::MergingHash.new('all_funcs')
	    @all_func_aliases = Bridgesupportparser::MergingHash.new('all_func_aliases')
	    @all_informal_protocols = Bridgesupportparser::MergingHash.new('all_informal_protocols')
	    @all_interfaces = Bridgesupportparser::MergingHash.new('all_interfaces')
	    @all_macronumbers = Bridgesupportparser::MergingHash.new('all_macronumbers')
	    @all_macrostrings = Bridgesupportparser::MergingHash.new('all_macrostrings')
	    @all_macronumberfunccalls = Bridgesupportparser::MergingHash.new('all_macronumberfunccalls')
	    @all_opaques = Bridgesupportparser::MergingHash.new('all_opaques')
	    @all_protocols = Bridgesupportparser::MergingHash.new('all_protocols')
	    @all_structs = Bridgesupportparser::MergingHash.new('all_structs')
	    @all_varinfos = []
	    @all_vars = Bridgesupportparser::MergingHash.new('all_vars')
	    @every_cftype = {}
	    @only_classes = {}
	end

	#######
	private
	#######

	def __xattr__(x)
	    "__attribute__((__annotate__(\"xattr:#{x}\")))"
	end

	# The difference between recursivefunc() and recursivefuncptr() is that
	# the first is called for functions (proper), and their return values
	# are instances of RetvalInfo.  recursivefunc() calls recursivefuncptr()
	# if an argument or return value is a function pointer, and its return
	# value will be an instance of RetvalPtrInfo.  recursivefuncptr() may
	# call itself recursively.
	def recursivefuncptr(f)
	    return nil if f.nil?
	    func, rettype, retenc, retattrs, retfunc, fattrs, variadic, inline = f.info
	    #puts "#{func} #{rettype} #{retenc} retattrs=#{retattrs.inspect} fattrs=#{fattrs.inspect} retfunc=#{!retfunc.nil?} variadic=#{variadic} inline=#{inline}" #DEBUG
	    ret = Bridgesupportparser::RetvalPtrInfo.new(self, nil, rettype, retenc, retattrs, recursivefuncptr(retfunc))
	    args = Bridgesupportparser::MergingSequence.new('recursivefuncptr')
	    f.each_argument do |name, type, enc, attrs, funcptr|
		# While we can generate recursive function pointers, some
		# BridgeSupport users (like MacRuby) can't deal with them.
		# So we avoid the recursion for now
		#args << Bridgesupportparser::ArgInfo.new(self, name, type, enc, attrs, recursivefuncptr(funcptr))
		args << Bridgesupportparser::ArgInfo.new(self, name, type, enc, attrs, nil)
	    end
	    Bridgesupportparser::FuncInfo.new(self, func, ret, args, fattrs, variadic, inline)
	end

	def recursivefunc(f)
	    return nil if f.nil?
	    func, rettype, retenc, retattrs, retfunc, fattrs, variadic, inline = f.info
	    #puts "#{func} #{rettype} #{retenc} retattrs=#{retattrs.inspect} fattrs=#{fattrs.inspect} retfunc=#{!retfunc.nil?} variadic=#{variadic} inline=#{inline}" #DEBUG
	    ret = Bridgesupportparser::RetvalInfo.new(self, nil, rettype, retenc, retattrs, recursivefuncptr(retfunc))
	    args = Bridgesupportparser::MergingSequence.new('recursivefunc')
	    f.each_argument do |name, type, enc, attrs, funcptr|
		args << Bridgesupportparser::ArgInfo.new(self, name, type, enc, attrs, recursivefuncptr(funcptr))
	    end
	    Bridgesupportparser::FuncInfo.new(self, func, ret, args, fattrs, variadic, inline)
	end

	def make_method(m)
	    sel, menc, rettype, retenc, retattrs, retfunc, mattrs, classmeth, variadic = m.info
	    ret = Bridgesupportparser::ObjCRetvalInfo.new(self, nil, rettype, retenc, retattrs, recursivefuncptr(retfunc))
	    args = Bridgesupportparser::MergingSequence.new("#{sel}.args")
	    m.each_argument do |name, type, enc, mod, attrs, funcptr|
		args << Bridgesupportparser::ObjCArgInfo.new(self, name, type, enc, mod, attrs, recursivefuncptr(funcptr))
	    end
	    Bridgesupportparser::MethodInfo.new(self, sel, menc, ret, args, mattrs, classmeth, variadic)
	end

	def make_opaque_or_struct(tname, name, decl)
	    if decl
		sname, senc = decl.info # "sname" is the same as "name"
		@all_structs[tname] = make_struct(tname, senc, decl)
	    else
		# promote forward reference to pointer to struct
		@all_opaques[tname] = Bridgesupportparser::OpaqueInfo.new(self, tname, "^{#{name}=}")
	    end
	end

	def make_struct(sname, senc, struct)
	    fields = Bridgesupportparser::MergingSequence.new(sname)
	    struct.each_field do |name, type, enc, attrs, funcptr|
		fields << Bridgesupportparser::FieldInfo.new(self, name, type, enc, attrs, recursivefuncptr(funcptr))
	    end
	    Bridgesupportparser::StructInfo.new(self, sname, senc, fields)
	end

	def recurse_append_protocol(a, b, seen)
	    b.each_protocol do |p|
		#puts ">p>#{p} seen=#{seen[p] ? 'yes' : 'no'}" #DEBUG
		if !seen[p]
		    seen[p] = 1
		    proto = @all_protocols[p]
		    #proto.methods.sort.each {|m| puts ">p>#{m.selector}"} #DEBUG
		    #puts '>p>----------' #DEBUG
		    if proto.nil?
			warn "Unknown protocol: #{p} for interface #{a.name}" if $DEBUG
		    else
			a.concat(proto)
			recurse_append_protocol(a, proto, seen)
		    end
		end
	    end
	end


	def inParseTree?(path)
	    x = @parsepathcache[path]
	    return x unless x.nil?
	    # allow header files in the directory hierarchies that match
	    # the basenames
	    p = Pathname.new(path).realpath.parent.to_s
	    len = p.length
	    i = @parse_select.any? do |d|
		dlen = d.length
		intree = case (dlen <=> len)
		when 1
		    false
		when 0
		    p == d
		else
		    p[dlen] == ?/ && p[0...dlen] == d
		end
		intree && @parse_select_basenames[File.basename(path)]
	    end
	    m = FRAMEWORK_RE.match(p)
	    c = (!m || DISABLE_CFTYPES[m[1]]) ? true : false
	    @parsepathcache[path] = [i, c]
	end

	def splitName(name)
	    idx = name.rindex('_')
	    return name if idx.nil?
	    [name[0,idx], name[(idx+1)..-1]]
	end

	def validName(name)
	    !name.nil? and !name.empty?
	end

	def _parse(triple)
	    #realp = Pathname.new(path).realpath
	    #dir = File.dirname(realpath(path))
	    #puts triple #DEBUG
	    Bridgesupportparser::BridgeSupportParser.parse(@parsepaths, @parsecontent, triple, @parsedefines, @parseincdirs, @parsesysroot, $DEBUG) do |top|
		next if @only_classes[top.class]
		intree, disableCFTypes = inParseTree?(top.path)
		case top
		when Bridgesupportparser::ATypedef
		    tname, ttype, tattrs = top.info
		    #puts "ATypedef: #{tname} #{ttype} intree=#{intree}" #DEBUG
		    next unless validName(tname)
		    i = 0
		    top.walk_types do |name, type, decl, attr|
			case i
			when 0
			    case type
			    when 'Struct'
				break unless intree
				make_opaque_or_struct(tname, name, decl)
				break # only direct structs, no pointers to structs
			    when 'Pointer'
				# do another loop
			    when 'Typedef'
				if name == 'CFTypeRef'
				    @every_cftype[tname] = 1
				    break
				end
				i = 10 # do case "else"
			    else
				break
			    end
			when 1
			    #puts "Typedef 1: name=#{tname} type=#{type} attrs=#{tattrs.inspect}" #DEBUG
			    break if type == 'Pointer'
			    if tname =~ /Ref$/ && !disableCFTypes
				# assume this is a CFType.
				@all_cftypes[tname] = Bridgesupportparser::CFTypeInfo.new(self, tname, top.encoding, tattrs) if intree
				@every_cftype[tname] = 1
			    elsif type == 'Struct'
				next unless intree
				make_opaque_or_struct(tname, name, decl)
			    end
			    break
			else
			    #puts "ATypedef:walk_types #{name} #{type}" #DEBUG
			    case type
			    when 'Struct'
				break unless intree
				make_opaque_or_struct(tname, name, decl)
				break # only direct structs, no pointers to structs
			    when 'Typedef'
				if name == 'CFTypeRef'
				    @every_cftype[tname] = 1
				    break
				end
			    else
				break
			    end
			end
			i += 1
		    end
		    next
		end
		next unless intree
		case top
		when Bridgesupportparser::AnEnum
		    # enum = top.info # don't need enum name
		    top.each_value { |name, val| @all_enums[name] = Bridgesupportparser::EnumInfo.new(self, name, val) if validName(name) }
		when Bridgesupportparser::AFunction
		    fname, rettype, retenc, retattrs, retfunc, fattrs, variadic, inline = top.info
		    @all_funcs[fname] = recursivefunc(top) if validName(fname)
		when Bridgesupportparser::AMacroFunctionAlias
		    faname, val = top.info
		    @all_func_aliases[faname] = Bridgesupportparser::FunctionAliasInfo.new(self, faname, val) if validName(faname)
		when Bridgesupportparser::AMacroNumber
		    nname, val = top.info
		    next unless validName(nname)
		    @all_macronumbers[nname] = Bridgesupportparser::NumberInfo.new(self, nname, val) if validName(nname)
		when Bridgesupportparser::AMacroNumberFuncCall
		    nname = top.info
		    next unless validName(nname)
		    @all_macronumberfunccalls[nname] = Bridgesupportparser::NumberFuncCallInfo.new(self, nname) if validName(nname)
		when Bridgesupportparser::AMacroString
		    sname, val, objcstr = top.info
		    next unless validName(sname)
		    val.sub!(/^"/, '')
		    val.sub!(/"$/, '')
		    @all_macrostrings[sname] = Bridgesupportparser::StringInfo.new(self, sname, val, objcstr)
		when Bridgesupportparser::AnObjCCategory
		    klass, cname = top.info
		    #next unless validName(cname) # allow any name, including extensions
		    #puts "*** adding category #{cname} for #{klass}" #DEBUG
		    methods = Bridgesupportparser::MergingSet.new("category #{cname} for #{klass}")
		    top.each_method { |m| methods << make_method(m) }
		    protocols = Set.new
		    top.each_protocol { |p| protocols.add(p) }
		    if klass == 'NSObject'
			@all_informal_protocols[cname] = Bridgesupportparser::ObjCCategoryInfo.new(self, cname, klass, methods, protocols)
		    else
			(@all_categories[klass] ||= Bridgesupportparser::MergingHash.new("category #{cname} for #{klass}"))[cname] = Bridgesupportparser::ObjCCategoryInfo.new(self, cname, klass, methods, protocols)
		    end
		when Bridgesupportparser::AnObjCInterface
		    iname = top.info
		    content, idx = splitName(iname)
		    if content == CONTENTMETHOD
			top.each_method do |m|
			    sel, menc, rettype, retenc, retattrs, retfunc, mattrs, classmeth, variadic = m.info
			    @special_method_encodings[idx.to_i] = menc
			    break
			end
			next
		    end
		    next unless validName(iname) && iname != CONTENTEND
		    #puts "*** adding interface #{iname}" #DEBUG
		    methods = Bridgesupportparser::MergingSet.new("interface #{iname}")
		    top.each_method { |m| methods << make_method(m) }
		    protocols = Set.new
		    top.each_protocol { |p| protocols.add(p) }
		    @all_interfaces[iname] = Bridgesupportparser::ObjCInterfaceInfo.new(self, iname, methods, protocols)
		when Bridgesupportparser::AnObjCProtocol
		    pname = top.info
		    next unless validName(pname)
		    #puts "*** adding protocol #{pname}" #DEBUG
		    methods = Bridgesupportparser::MergingSet.new("protocol #{pname}")
		    top.each_method { |m| methods << make_method(m) }
		    protocols = Set.new
		    top.each_protocol { |p| protocols.add(p) }
		    @all_protocols[pname] = Bridgesupportparser::ObjCProtocolInfo.new(self, pname, methods, protocols)
		when Bridgesupportparser::AStruct
		    sname, senc = top.info
		    @all_structs[sname] = make_struct(sname, senc, top) if validName(sname)
		when Bridgesupportparser::AVar
		    vname, vtype, venc, attrs, funcptr = top.info
		    content, idx = splitName(vname)
		    if content == CONTENTTYPE
			@special_type_encodings[idx.to_i] = venc
			next
		    end
		    # We currently can't deal with globals that are function
		    # pointers, so just ignore any
		    #@all_vars[vname] = Bridgesupportparser::VarInfo.new(self, vname, vtype, venc, attrs, recursivefuncptr(funcptr)) if validName(vname)
		    @all_vars[vname] = Bridgesupportparser::VarInfo.new(self, vname, vtype, venc, attrs) if validName(vname) && funcptr.nil?
		end
	    end
	end

	def matchingbrace(str, off)
	    while true
		off = str.index(/[{}]/, off + 1)
		if str[off] == ?{
		    off = matchingbrace(str, off)
		else
		    break
		end
	    end
	    off
	end

	######
	public
	######

	def add_attrs(a)
	    @all_attrs << a
	end

	def addXML(root)
	    @all_structs.sort.each do |k, struct|
		e = struct.element
		root.add_element(e) unless e.nil?
	    end
	    @all_cftypes.sort.each do |k, cftype|
		e = cftype.element
		root.add_element(e) unless e.nil?
	    end
	    @all_opaques.sort.each do |k, opaque|
		e = opaque.element
		root.add_element(e) unless e.nil?
	    end
	    @all_vars.sort.each do |k, var|
		e = var.element
		root.add_element(e) unless e.nil?
	    end
	    @all_macrostrings.sort.each do |k, str|
		e = str.element
		root.add_element(e) unless e.nil?
	    end
	    enums = @all_enums.merge(@all_macronumbers)
	    @all_macronumberfunccalls.each { |k, v| enums[k] = v unless v.value.nil? }
	    enums.sort.each do |k, enum|
		e = enum.element
		root.add_element(e) unless e.nil?
	    end
	    @all_funcs.sort.each do |k, func|
		e = func.element
		root.add_element(e) unless e.nil?
	    end
	    @all_func_aliases.sort.each do |k, a|
		e = a.element
		root.add_element(e) unless e.nil?
	    end
	    @all_interfaces.sort.each do |k, interface|
		e = interface.element
		root.add_element(e) unless e.nil?
	    end
		#$bsp_informal_protocols = true
		#@all_informal_protocols.sort.each do |k, ip|
		#e = ip.element
		#root.add_element(e) unless e.nil?
		#end
		#$bsp_informal_protocols = nil
	end

	def each_attrs
	    if block_given?
		@all_attrs.each { |a| yield a }
	    end
	end

	def mergeWith64!(p64)
	    p64.rename_attrs(Bridgesupportparser.rename_attrs64)
	    set_custom_recursive_merge(Bridgesupportparser::custom_recursive_merge_64)
	    recursive_merge!(p64)
	end

	def parse(triple)
	    menc, tenc = _parse(triple)

#	    # Merge all category and protocol methods (recursively)
#	    @all_interfaces.each do |name, interf|
#		#puts ">#{name}" #DEBUG
#		cseen = {}
#		pseen = {}
#		recurse_append_protocol(interf, interf, pseen);
#		categ = @all_categories[name]
#		if categ
#		    categ.each_value do |c|
#			#puts ">c>#{c.name} seen=#{cseen[c.name] ? 'yes' : 'no'}" #DEBUG
#			if !cseen[c.name]
#			    cseen[c.name] = 1
#			    #c.methods.sort.each {|m| puts ">c>#{m.selector}"} #DEBUG
#			    #puts '>c>----------' #DEBUG
#			    interf.concat(c)
#			    recurse_append_protocol(interf, c, pseen);
#			end
#		    end
#		end
#	    end
	    
	    # Merge categories into interfaces, creating as needed
	    @all_categories.each do |iname, h|
		interf = (@all_interfaces[iname] ||= Bridgesupportparser::ObjCInterfaceInfo.new(self, iname, Bridgesupportparser::MergingSet.new("interface #{iname}"), Set.new))
		h.each_value { |c| interf.concat(c) }
	    end

	    # Create a NSObject interface, if it doesn't already exist
	    nsobjcreated = false
	    nsobj = @all_interfaces['NSObject']
	    if nsobj.nil?
		nsobj = Bridgesupportparser::ObjCInterfaceInfo.new(self, 'NSObject', Bridgesupportparser::MergingSet.new("interface NSObject"), Set.new)
		nsobjcreated = true
	    end
	    # Merge all informal protocol methods into the NSObject interface.
	    @all_informal_protocols.each_value { |p| nsobj.concat(p) }
	    # For formal protocols, to emulate the previous gen_bridge_metadata
	    # behavior, protocol methods get merged into the NSObject interface.
	    # We also create a separate informal protocol with the methods of
	    # the formal protocol.
	    @all_protocols.each_value do |p|
		nsobj.concat(p)
		(@all_informal_protocols[p.name] ||= Bridgesupportparser::ObjCCategoryInfo.new(self, p.name, 'NSObject')).concat(p)
	    end
	    @all_interfaces['NSObject'] = nsobj if nsobjcreated && nsobj.methods.length > 0

	    # Go through the cftypes and for those without the gettypeid_func
	    # attribute, make up the standard name, and check against the
	    # known functions
	    @all_cftypes.each do |name, cftype|
		if !cftype.gettypeid_func
		    func = name.sub(/Ref$/, 'GetTypeID')
		    #puts "Trying #{func} for #{name}: #{@all_funcs[func]}" #DEBUG
		    if @all_funcs.has_key?(func)
			cftype[:gettypeid_func] = func
		    elsif func.sub!(/Mutable/, '')
			cftype[:gettypeid_func] = func if @all_funcs.has_key?(func)
		    end
		end
	    end

	    # For functions returning a cftype, with "Create" or "Copy" in
	    # the name, add the "already_retained" attribute to return value
	    @all_funcs.each do |name, func|
		ret = func.ret
		next unless ret.type != 'v'
		next if @every_cftype[ret.declared_type].nil?
		ret[:already_retained] = true if /(Create|Copy)/.match(name)
	    end

	    # Walk through all the type attributes and replace
	    # '^v' with '@' for cftypes
	    each_attrs do |a|
		dt = a[:declared_type]
		next if dt.nil? || @every_cftype[dt].nil?
		if a[:type] == '^v'
		    a.delete(:type) # delete to avoid recursive_merge! warning
		    a[:type] = '@'
		end
	    end

	    # For each method in each informal protocol, set the method "type"
	    # to the method encoding (we need to call dup_methods, so to
	    # avoid having "type" show up in NSObject methods, which are shared)
	    @all_informal_protocols.each do |name, ip|
		ip.dup_methods
		ip.each_method { |m| m[:type] = m.seltype }
	    end

	    # For each structure that has a nested anonymous-structure typedef,
	    # with structure name showing as '?', we replace the '?' with the
	    # type from the corresponding field.  We have to make multiple
	    # passes over the structures, until no more changes can be made.
	    anyunresolved = true
	    tagged_structs = {}
	    while anyunresolved
		anyunresolved = false
		@all_structs.each do |structname, struct|
		    next if struct.resolved
		    unless struct.type.match(/"\^*\{\?/)
			struct.resolved = true
			#puts "struct #{structname} already resolved" #DEBUG
			next
		    end
		    unresolved = false
		    struct.each_field do |f|
			next if f.resolved
			sname = f.declared_type.sub(/\s*\*$/, '')
			s = @all_structs[sname]
			if s
			    if s.resolved
				#resolvedtype = s.type.gsub(/"[^"]*"/, '')
				#puts "struct #{structname} field #{f.name} type=\"#{f.type}\" resolvedtype=\"#{resolvedtype}\"" #DEBUG
				#f.type[f.type.index(/\{/)..-1] = resolvedtype[resolvedtype.index(/\{/)..-1]
				f.type[f.type.index(/\{/)..-1] = s.type[s.type.index(/\{/)..-1]
				f.resolved = s.type.sub(/^\^*/, '')
				#puts "struct #{structname} field #{f.name} => #{f.type} (#{f.resolved})" #DEBUG
			    else
				unresolved = true
				#puts "struct #{structname} field #{f.name}: struct #{s.name} still unresolved" #DEBUG
			    end
			else
			    f.resolved = true
			end
		    end
		    if unresolved
			anyunresolved = true
			#puts "struct #{structname} remains unresolved" #DEBUG
		    else
			origtype = struct.type.dup
			struct.each_field do |f|
			    #puts "struct #{structname} field #{f.name} resolved=#{f.resolved}" #DEBUG
			    next if f.resolved == true
			    left = struct.type.index(/"#{f.name}"\^*\{/)
			    left = struct.type.index(/\{/, left.nil? ? 0 : left)
			    right = matchingbrace(struct.type, left)
			    #puts ">struct #{structname} field #{f.name} => #{f.resolved}" #DEBUG
			    #puts ">left=#{left} right=#{right} before=#{struct.type}" #DEBUG
			    struct.type[left..right] = f.resolved
			    #puts ">after=#{struct.type}" #DEBUG
			end
			if struct.type != origtype
			    tagged_structs[structname] = struct.type.sub(/^\^*/, '').gsub(/"[^"]*"/, '')
			    #puts ">>>Resolved: #{structname}" #DEBUG
			    #puts "\"#{origtype}\" =>" #DEBUG
			    #puts "\"#{struct.type}\"" #DEBUG
			end
			struct.resolved = true
			#puts "struct #{structname} is now resolved" #DEBUG
		    end
		end
	    end
	    #puts '=== tagged_structs ==='; tagged_structs.each {|k,v| puts "#{k}: #{v}"} #DEBUG
	    # Now walk through all the VarInfo instances, and replace with
	    # the new tagged structs
	    if tagged_structs.length > 0
		@all_varinfos.each do |v|
		    name = v.declared_type.sub(/\s*\*$/, '')
		    t = tagged_structs[name]
		    if t
			v.type[v.type.index(/\{/)..-1] = t
			v[:_type_override] = true
		    end
		end
	    end

	    if $DEBUG #DEBUG
		puts "@parsepathcache:" #DEBUG
		@parsepathcache.sort.each { |k, v| puts "#{k} => #{v.inspect}" } #DEBUG
	    end #DEBUG
	end

	def recursive_merge!(p)
	    # purge members that occur in 32-bit (self) and not in 64-bit (p)
	    # (@all_categories is a special case)

	    @all_categories.delete_if { |k, v| !p.all_categories.has_key?(k) }
	    @all_categories.each do |k, v|
		pp = p.all_categories[k]
		v.delete_if { |kk, vv| !pp.has_key?(kk) }
		v.recursive_merge!(pp)
	    end

	    @all_cftypes.delete_if { |k, v| !p.all_cftypes.has_key?(k) }
	    @all_cftypes.recursive_merge!(p.all_cftypes)
	    @all_enums.delete_if { |k, v| !p.all_enums.has_key?(k) }
	    @all_enums.recursive_merge!(p.all_enums)
	    @all_funcs.delete_if { |k, v| !p.all_funcs.has_key?(k) }
	    @all_funcs.recursive_merge!(p.all_funcs)
	    @all_func_aliases.delete_if { |k, v| !p.all_func_aliases.has_key?(k) }
	    @all_func_aliases.recursive_merge!(p.all_func_aliases)
	    @all_informal_protocols.delete_if { |k, v| !p.all_informal_protocols.has_key?(k) }
	    @all_informal_protocols.recursive_merge!(p.all_informal_protocols)
	    @all_interfaces.delete_if { |k, v| !p.all_interfaces.has_key?(k) }
	    @all_interfaces.recursive_merge!(p.all_interfaces)
	    @all_macronumbers.delete_if { |k, v| !p.all_macronumbers.has_key?(k) }
	    @all_macronumbers.recursive_merge!(p.all_macronumbers)
	    @all_macrostrings.delete_if { |k, v| !p.all_macrostrings.has_key?(k) }
	    @all_macrostrings.recursive_merge!(p.all_macrostrings)
	    @all_macronumberfunccalls.delete_if { |k, v| !p.all_macronumberfunccalls.has_key?(k) }
	    @all_macronumberfunccalls.recursive_merge!(p.all_macronumberfunccalls)
	    @all_opaques.delete_if { |k, v| !p.all_opaques.has_key?(k) }
	    @all_opaques.recursive_merge!(p.all_opaques)
	    @all_protocols.delete_if { |k, v| !p.all_protocols.has_key?(k) }
	    @all_protocols.recursive_merge!(p.all_protocols)
	    @all_structs.delete_if { |k, v| !p.all_structs.has_key?(k) }
	    @all_structs.recursive_merge!(p.all_structs)
	    @all_vars.delete_if { |k, v| !p.all_vars.has_key?(k) }
	    @all_vars.recursive_merge!(p.all_vars)
	end

	def rename_attrs(h)
	    @all_attrs.each do |attrs|
		h.each { |k, v| attrs[v] = attrs.delete(k) if attrs.include?(k) }
	    end
	end

	# By default, we rely on MergingHash's recursive_merge! method
	# to merge the attributes.  If set_custom_recursive_merge is passed
	# a lambda, that lambda will be responsible for merging each
	# attribute.  The arguments passed to the lambda are:
	#     key, self_attrs, other_attrs
	# where "key" is the current key symbol to merge, "self_attrs" is
	# the (MergingHash) attributes we are merging into, and
	# "other_attrs" is the (MergingHash) attributes we are merging.
	def set_custom_recursive_merge(m)
	    #puts "set_custom_recursive_merge=#{m.inspect}" #DEBUG
	    @custom_recursive_merge = m
	end
#####################################################
#################### DEBUGGING ######################
#####################################################

	def writeXML(file, version, doctype = false, indent = 4)
	    xml = REXML::Document.new
	    xml << REXML::XMLDecl.new
	    xml << REXML::DocType.new(['signatures', 'SYSTEM', '"file://localhost/System/Library/DTDs/BridgeSupport.dtd"']) if doctype
	    xml.add_element('signatures')
	    root = xml.root
	    root.attributes['version'] = version
	    addXML(root)
	    xml.write(file, indent)
	    file.print "\n"
	end

	#######
	private
	#######

	def dumpargs(func, indent = 0)
	    i = '  ' * indent
	    func.each_argument do |a|
		puts "#{i}#{a.name}: attrs=#{a.attrs.inspect}"
		dumpfunc(a.function_pointer, indent + 1) if a.function_pointer?
	    end
	end

	def dumpcateg(categ, indent = 0)
	    i = '  ' * indent
	    puts "---------\n" if indent == 0
	    protolist("#{i}#{categ.klass} (#{categ.name}): protocols=", categ)
	    dumpmeths(categ, indent + 1)
	end

	def dumpfields(struct, indent = 0)
	    i = '  ' * indent
	    struct.each_field do |f|
		puts "#{i}#{f.name}: attrs=#{f.attrs.inspect}"
		dumpfunc(f.function_pointer, indent + 1) if f.function_pointer?
	    end
	end

	def dumpfunc(func, indent = 0)
	    i = '  ' * indent
	    puts "---------\n" if indent == 0
	    puts "#{i}#{func.name}: retattrs=#{func.ret.attrs.inspect} attrs=#{func.attrs.inspect} variadic=#{func.variadic?} inline=#{func.inline?}"
	    dumpfunc(func.ret.function_pointer, indent + 1) if func.ret.function_pointer?
	    dumpargs(func, indent + 1)
	end

	def dumpmeths(container, indent = 0)
	    i = '  ' * indent
	    container.each_method do |meth|
		puts "#{i}#{meth.selector}: retattrs=#{meth.ret.attrs.inspect} attrs=#{meth.attrs.inspect} class_method=#{meth.class_method?} variadic=#{meth.variadic?}"
		dumpfunc(meth.ret.function_pointer, indent + 1) if meth.ret.function_pointer?
		dumpargs(meth, indent + 1)
	    end
	end

	def protolist(str, container)
	    print str
	    container.each_protocol { |p| print " #{p}" }
	    print "\n"
	end

	def dumpinterf(interf, indent = 0)
	    i = '  ' * indent
	    puts "---------\n" if indent == 0
	    protolist("#{i}#{interf.name}: protocols=", interf)
	    dumpmeths(interf, indent + 1)
	end

	def dumpproto(proto, indent = 0)
	    i = '  ' * indent
	    puts "---------\n" if indent == 0
	    protolist("#{i}#{proto.name}: protocols=", proto)
	    dumpmeths(proto, indent + 1)
	end

	def dumpstruct(struct, indent = 0)
	    i = '  ' * indent
	    puts "---------\n" if indent == 0
	    puts "#{i}#{struct.name}: attrs=#{struct.attrs.inspect}"
	    dumpfields(struct, indent + 1)
	end

	######
	public
	######

	def dump
	    puts "================ categories ==============="
	    @all_categories.sort.each { |k, v| v.sort.each { |c, categ| dumpcateg(categ) }}
	    puts "================ cftypes ==============="
	    @all_cftypes.sort.each { |k, t| puts "#{t.name} attrs=#{t.attrs.inspect}" }
	    puts "================ every cftype ==============="
	    @every_cftype.sort.each { |t, v| puts t }
	    puts "================ enum ==============="
	    @all_enums.sort.each { |name, e| puts "#{name}: \"#{e.value}\" attrs=#{e.attrs.inspect}" }
	    puts "================ funcs ==============="
	    @all_funcs.sort.each { |k, func| dumpfunc(func) }
	    puts "================ informal protocols ==============="
	    @all_informal_protocols.sort.each { |k, categ| dumpcateg(categ) }
	    puts "================ macrofunctionaliases ==============="
	    @all_func_aliases.sort.each { |n, v| puts "#{n}: #{v.original}" }
	    puts "================ macronumbers ==============="
	    @all_macronumbers.sort.each { |n, v| puts "#{n}: #{v.value} attrs=#{v.attrs.inspect}" }
	    puts "================ macronumberfunccalls ==============="
	    @all_macronumberfunccalls.sort.each { |n, v| puts "#{n}: attrs=#{v.attrs.inspect}" }
	    puts "================ macrostrings ==============="
	    @all_macrostrings.sort.each { |n, v| puts "#{n}: \"#{v.value}\" nsstring=#{v.nsstring} attrs=#{v.attrs.inspect}" }
	    puts "================ protocols ==============="
	    @all_protocols.sort.each { |k, proto| dumpproto(proto) }
	    puts "================ interfaces ==============="
	    @all_interfaces.sort.each { |k, interf| dumpinterf(interf) }
	    puts "================ structs ==============="
	    @all_structs.sort.each { |k, struct| dumpstruct(struct) }
	    @all_opaques.sort.each { |opaque, v| puts "opaque: #{opaque}" }
	    puts "================ special method_encodings ==============="
	    unless @special_method_encodings.nil?
		 @special_methods.each_index { |i| puts "#{@special_methods[i]} => #{@special_method_encodings[i]}" }
	    end
	    puts "================ special_type_encodings ==============="
	    unless @special_type_encodings.nil?
		 @special_types.each_index { |i| puts "#{@special_types[i]} => #{@special_type_encodings[i]}" }
	    end
	    puts "================ vars ==============="
	    @all_vars.sort.each do |k, v|
		puts "#{v.name}: attrs=#{v.attrs.inspect}"
		dumpfunc(v.function_pointer, 1) if v.function_pointer?
	    end
	end

	def only_parse_class(c)
	    @only_classes[c] = 1
	end
#####################################################
    end # class Parser
end # module Bridgesupportparser
