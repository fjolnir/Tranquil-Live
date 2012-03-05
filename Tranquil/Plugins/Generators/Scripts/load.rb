class Numeric
    def clamp(min, max)
        [max, [self, min].max].min
    end
end

require "oscillators"
require "randomness"