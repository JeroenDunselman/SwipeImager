public struct ZPattern {
    //  XXX000
    //  XX000X
    //  X000XX
    //  000XXX
    //  00XXX0
    //  0XXX00
    
    public var length:Int = 3
    private var z:[[Bool]] = [[]]
    
    public init (length: Int) {
        self.length = 3 //length not supported by imager
        z = getRowCol()
    }
    
    func getRow(length: Int) -> [Bool] {
        
        return Array(repeating: true, count: length)
             + Array(repeating: false, count: length)
    }
    
    func getRowCol() -> [[Bool]] {
        var y: [[Bool]] = []
        //row
        var x: [Bool] = getRow(length: self.length);
        
        //remove first rowelement and append, add row to 2D result
        _ = (0..<x.count).map( { _ in
            var temp: [Bool] = [x.removeLast()]
            temp += x
            x = temp
            y += [x]
        })
        
        return y
    }
    
    public func z(x: Int, y: Int) -> Bool {
        return z[x % z[0].count][y % z[0].count]
    }
}
