import Foundation
import UIKit
typealias MapInfo = (Int, UIColor)

class Palet {
    
    // MARK: - Properties
    
    static let shared = Palet()
    
    let tartanLibraryColorIdentifiers: [String : (Int, UIColor)]
    let clrs: [UIColor]
    
    // Initialization
//    let t = colorSet.enumerated().map { (index,element) in
//        return "\(index):\(element)"
//    }
    private init() {
        var colorMap: [String : (Int, UIColor)] = [:]
        
        colorMap["Y"] = (0, UIColor.magenta)
        colorMap["A"] = (1, UIColor.yellow)
        colorMap["DB"] = (2, UIColor.orange)
        colorMap["K"] = (3, UIColor.black)
        colorMap["B"] = (4, UIColor.blue)
        colorMap["R"] = (5, UIColor.red)
        colorMap["G"] = (6, UIColor.green)
//        tartanLibraryColorIdentifiers["N"] = (7, UIColor.gray)
        colorMap["P"] = (8, UIColor.purple)
        colorMap["T"] = (9, UIColor.brown)
        colorMap["W"] = (10, UIColor.white)
//        tartanLibraryColorIdentifiers["C"] = (11, UIColor.lightGray)
        colorMap["S"] = (12, UIColor.cyan)
//        tartanLibraryColorIdentifiers["DR"] = (13, #colorLiteral(red: 0, green: 0.3323789835, blue: 0.4204791784, alpha: 1))
//        tartanLibraryColorIdentifiers["LB"] = (14, #colorLiteral(red: 0.409163326, green: 0.6865409017, blue: 0.5725018382, alpha: 1))
//        tartanLibraryColorIdentifiers["DBG"] = (15, #colorLiteral(red: 0.8582422137, green: 0.3938060999, blue: 0.02006006613, alpha: 1))
//        tartanLibraryColorIdentifiers["RB"] = (16, UIColor.black)
//        tartanLibraryColorIdentifiers["DG"] = (17, UIColor.blue)
//        tartanLibraryColorIdentifiers["LR"] = (18, UIColor.red)
//        tartanLibraryColorIdentifiers["LN"] = (19, UIColor.green)
//        tartanLibraryColorIdentifiers["DN"] = (20, UIColor.gray)
//        tartanLibraryColorIdentifiers["XL"] = (21, UIColor.purple)
//        tartanLibraryColorIdentifiers["CLR"] = (22, UIColor.clear)
        
        tartanLibraryColorIdentifiers = colorMap
        clrs = tartanLibraryColorIdentifiers.map {$0.1}.sorted(by: {$0.0 < $1.0})
            .map {$0.1 }
    }

    public func indexOfColor(color: UIColor) -> Int? {
        return tartanLibraryColorIdentifiers.first(where: {$0.value.1 == color})?.value.0
    }
    public func keyOfColor(color: UIColor) -> String? {
        return tartanLibraryColorIdentifiers.first(where: {$0.value.1 == color})?.key
    }
    
}

public extension UIImage {
    
    public convenience init?(zones: [(Int, Int)]) {
        let p = Palet.shared
        let rect = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        _ = zones.map( { _ in
            p.clrs[zones[0].1].setFill()
            UIRectFill(rect)
        })
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
