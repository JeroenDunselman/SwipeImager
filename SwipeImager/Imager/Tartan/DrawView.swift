//
//  DrawView.swift
//  SwipeImager
//
//  Created by Jeroen Dunselman on 01/02/2020.
//  Copyright © 2020 Jeroen Dunselman. All rights reserved.
//

import UIKit

class DrawTartanView: UIView {
    @IBInspectable var ovalColor: UIColor = UIColor.blue
    @IBInspectable var coords:[[Int]] = []
    @IBInspectable var cells:[[Int]] = []
//    @IBInspectable var client: ViewController = ViewController()  //UIViewController() as! ViewController
    
    override func draw(_ rect: CGRect) {
        ovalColor.setFill()
//        let path = UIBezierPath(ovalIn: rect) //path.fill()
//        _ = (0...9).map {i in coords = coords + [[i, i]]}
//        _ = coords.map {c in fillShape(Coordinate(c[0], c[1]))}
        _ = cells.map {c in
            
            p.clrs[c[2]].setFill()
            fillShape(Coordinate(c[0], c[1]))
            
        }
    }
    
    let p = Palet.shared
    var pCurrentColorIndex:Int = 999
    func setOvalColor(_ color: UIColor) {
        self.ovalColor = color
        pCurrentColorIndex = p.indexOfColor(color: self.ovalColor) ?? 999
//        print("OvalColor set to \(pCurrentColorIndex)")
        
    }
    func addCell(_ c:[Int]) {
        if c.count > 3 {print("raar")} //        print("c: \(c)")
        if cells.count < 22500 {cells = cells + [[c[0], c[1], c[2]]] }
//        print("coords.count \(cells.count)")
    }

    func fillShape(_ current: Coordinate) {
        //Draw 1 layout cell in four quadrants
//        print("current: Coordinate \(current)")
        let one:CGFloat = 1
        let half:CGFloat = CGFloat(one / 2)
        let defaultSize = CGSize(width: one, height: one)
        
        let viewSize = self.frame.size
        
        var rect = CGRect(origin: CGPoint(x:current.x, y:current.y), size: defaultSize)
        UIRectFill(rect)
        
        let newX:Int = (current.x + Int(viewSize.width * half))
        rect = CGRect(origin: CGPoint(x:newX, y:current.y), size: defaultSize)
        UIRectFill(rect)
        
        let newY:Int = (current.y + Int(viewSize.width * half))
        rect = CGRect(origin: CGPoint(x:current.x, y:newY), size: defaultSize)
        UIRectFill(rect)
        
        rect = CGRect(origin: CGPoint(x:newX, y:newY), size: defaultSize)
        UIRectFill(rect)
        
    }

}
