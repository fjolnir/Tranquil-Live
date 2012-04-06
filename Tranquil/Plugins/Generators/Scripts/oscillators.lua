oop = require("oop")

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
