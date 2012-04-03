oop = require("oop")
ffi.cdef[[
uint64_t mach_absolute_time(void);
uint64_t AbsoluteToNanoseconds(uint64_t absoluteTime);
]]

function time()
	return tonumber(C.AbsoluteToNanoseconds(C.mach_absolute_time()))/1000000000
end

Osc = class()
function Osc:new(period)
	self = self:create()
	self.period = period or 1
	self.startTime = time()
	return self
end

function Osc:val()
	return ((time() - self.startTime) % self.period) / self.period
end

SinOsc = class(Osc)
function SinOsc:val()
	return sin(self:super().val(self) * 2 * Pi)
end


CosOsc = class(Osc)
function CosOsc:val()
	return cos(self:super().val(self) * 2 * Pi)
end

SawtoothOsc = class(Osc)
function SawtoothOsc:val()
	return self:super().val(self)
end

TriangleOsc = class(Osc)
function TriangleOsc:val()
	return abs((self:super().val(self) - 0.5) * 2)
end
