# A random number between -1&1 centered on 0
def cRand
	(rand - 0.5) * 2.0
end

# A random vector with each component between 0&1
# Visualized: A positive unit cube
def randVec
	vec4(rand, rand, rand)
end

# A random vector with each component between -1&1
# Visualized: A 2x2x2 cube centered on the origin,
def cRandVec
	vec4(cRand, cRand, cRand)
end

# A random vector of length equal to or less than 1
# Visualized: a unit sphere centered on the origin
def sphereRandVec
	ret = cRandVec
	while ret.magnitudeSquared > 1.0
		ret = cRandVec
	end
	ret
end

# A Gaussian random number centered on zero with a variance of 1
def gaussRand
    w = 1
	x = 0
    until w < 1.0 and w > 0 do
        x = cRand
        y = cRand
        w = x**2 + y**2
    end
    w = sqrt((-2.0 * log(w)) / w)
    w*x
end
    
def gaussVec
    vec4(gaussRand, gaussRand, gaussRand)
end
    
    
