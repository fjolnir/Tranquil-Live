class Texture
    def self.load(aPath)
        initWithContentsOfFile(aPath, minFilter:GL_NEAREST, maxFilter:GL_LINEAR, buildMipMaps:false)
    end
end

def loadTex(aPath)
    Texture.load(aPath)
end