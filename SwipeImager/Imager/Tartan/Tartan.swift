import UIKit

typealias TartanDefinition = (tartan:Tartan, info:[String:Any])
class Tartan {
    
    var zPattern: ZPattern = ZPattern(length:3)
    var sett:[Int] = []
    var sizes:[Int] = []
    public var sumSizes: Int = 0
    
    var colors:[Int] = []
    public var colorSet:Set<Int> = [] //[x, y, x, z], MacKinnon.x.x.x
    public var colorSetCompact:(layOut:[Int], sortString:String) = ([], "")//[0, 1, 0, 2], MacKinnon.x.x.x
    
    init() {}
    
    init(sett:[Int]) { //[intThreadColor]
        self.colorSet = sett.valuedAsSet
//        self.randomizeColorSet()
        
        self.sumSizes = sett.count
        self.sett = sett.mirror() as! [Int] //mirrorStructure(definition:sett)
    }
    
    init(colors:[Int], sizes:[Int]) {
        self.colors = colors
        self.createColorPattern()
        
        self.sizes = sizes
        self.sumSizes = self.sizes.map { $0 }.reduce(0, +)
    }
    
    convenience init(sizes:[Int]){
        var colors:[Int] = []
        
        //colors from palet enumeration with random offset
        let offSet = Palet.shared.clrs.count.asMaxRandom()
        _ = (0..<sizes.count).map({colors.append($0 + offSet)})
        
        self.init(colors: colors, sizes: sizes)
    }
    
    convenience init(randomSizesFor colors:[Int]) {
        let theColors = colors
        let sizes: [Int] = theColors.reduce([]) {(ar, el) in ar + [11.randomFib()]}
        self.init(colors: theColors, sizes: sizes)
    }
    
    var sizesContrast = 4//( x - y > 0 ) : () ?? 5
    func randomContrastFib() -> Int {
        return sizesContrast.randomFib()
    }
    
}

extension Tartan {
    
    func createStructure() -> [Int] {
        
        var definition: [Int] = []
        //get sett
        _ = (0..<self.sizes.count).map { i in
            definition += Array(repeatElement(self.colors[i], count: (self.sizes[i])))}
        return definition.mirror() as! [Int]
    }
    //please document this
    //definition += Array(repeatElement(self.colors[i], count: (self.sizes[i] / divider)))
    //
    //        var allEven = true
    //        _ = (0..<self.sizes.count).map({if ($0 % 2 != 0){ allEven = false } })
    //        let divider = allEven ? 2 : 1
    //        print("divider: \(divider)")
}

extension Tartan {
    
    func createColorPattern() {
        
        colorSet = colors.valuedAsSet
        
        let colorSetPattern = colors
            .reduce([]) {(ar, el) in ar + (!ar.contains(el) ? [el] : [] )}
        let layOut:[Int] = colors.reduce([]) {(ar, el) in ar + [colorSetPattern.index(of: el)!]}
        
        //make comparable by sortString
        colorSetCompact = ( layOut: layOut,
                        sortString: layOut.reduce("") { ar, el in "\(ar)\(el)"})
    }
}


