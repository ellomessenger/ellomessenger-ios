import Postbox

public extension ElloAppMediaWebFile {
    var dimensions: PixelDimensions? {
        return dimensionsForFileAttributes(self.attributes)
    }
    
    var duration: Int32? {
        return durationForFileAttributes(self.attributes)
    }
}
