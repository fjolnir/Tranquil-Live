-- I just don't like typing
rand = random

-- A random number between -1&1 centered on 0
function cRand()
	return (rand() - 0.5) * 2.0
end

-- A random vector with each component between 0&1
-- Visualized: A positive unit cube
function randVec()
	return vec3(rand(), rand(), rand())
end

-- A random vector with each component between -1&1
-- Visualized: A 2x2x2 cube centered on the origin,
function cRandVec()
	return vec3(cRand(), cRand(), cRand())
end

-- A random vector of length equal to or less than 1
-- Visualized: a unit sphere centered on the origin
function sphereRandVec()
	ret = cRandVec()
	while ret.magnitudeSquared > 1.0 do
		ret = cRandVec()
	end
	return ret
end

-- A Gaussian random number centered on zero with a variance of 1
function gaussRand()
    local w = 1
	local x = 0
    local y = 0
    while not ((w < 1) and (w > 0)) do
        x = cRand()
        y = cRand()
        w = x^2 + y^2
    end
    w = sqrt((-2.0 * log(w)) / w)
    return w*x
end
    
function gaussVec()
    return vec3(gaussRand(), gaussRand(), gaussRand())
end
    
    
