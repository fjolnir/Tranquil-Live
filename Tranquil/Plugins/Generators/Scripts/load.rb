class Numeric
    def clamp(min, max)
        [max, [self, min].max].min
    end
end

class Osc
    def initialize(period)
        @period = period
        @startTime = Time.now.to_f
    end
    
    def val
        ((Time.now.to_f - @startTime) % @period) / @period
    end
end

class SinOsc < Osc
    def val
        sin(super*2*PI)
    end
end

class CosOsc < Osc
    def val
        cos(super*2*PI)
    end
end

class SawtoothOsc < Osc
    def val
        super
    end
end

class TriangleOsc < Osc
    def val
        ((super-0.5)*2.0).abs
    end
end