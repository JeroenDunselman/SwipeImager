//
//  Checkerboard.swift

//  Created by Jeroen Dunselman on 03/01/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reservedvar/

/*    init(entry: Entry) {
        self.tartan = entry.definition?.tartan // .1.tartan
        self.colorZones = (self.tartan?.colors)!
        self.entry = entry
    }
    init(tartan: Tartan, colorSet: [Int]) {
        self.tartan = tartan
        self.colorZones = colorSet
        self.tartan?.colorSet = colorSet.valuedAsSet
    }
    var colorSet: Set<Int> { return colorZones.valuedAsSet } //duplicate in tartan?
    var entry: Entry?
, sizesContrast: Int = 5 */

import Foundation
import UIKit
typealias Coordinate = (x: Int, y: Int)

public class LayOut {
    var images: [String:Any] = [:]
    var liveView:DrawTartanView = DrawTartanView()
    
    var tartan: Tartan?
    var cells: [[Int]] = [], colorShapes: [Int:[Coordinate]] = [:], colorZones: [Int]
    var rowStore:[Int:Any] = [:], shapeStore:[Int:[Coordinate]] = [:]
    var zFactor = 3
    let p = Palet.shared.clrs
    
    init(tartan: Tartan) {
        self.tartan = tartan
        self.colorZones = tartan.colors
    }

    public func build() -> UIImage {
        
        self.tartan?.sett = self.tartan?.createStructure() ?? []
        return visualizeTartan()
    }

}

extension LayOut {
    
    func visualizeTartan() -> UIImage {
        layoutTartan()
        self.images["initial"] = self.createImage()
        //self.createVariant()
        return self.images["initial"] as! UIImage
    }
    
    func layoutTartan() {
        guard let sett = self.tartan?.sett, sett.count > 0,
            let colors = self.tartan?.colorSet else { return }
        
        
        //todo prevent unequally defined imgs,  if zFactor == 1 {img.collage(3*3)};ffact = zPat? zPat/2
        if (sett.count) % (self.tartan?.zPattern.length)! != 0 { self.zFactor = 3 }
    
        create2D(sett)
        createColorShapes(colors)
    }

    func create2D(_ sett:[Int]) {
        //turn colorstructure 2d
        self.createSquareFromDefinition(sett)
        while rowStore.count < sett.count {
            sleep(1)
            print("bg thread not finished rowStore")
        }
        _ = (0..<rowStore.count).map { index in
            guard let row:[Int] = rowStore[index] as? [Int] else {
                print("error")
                return
            }
            self.cells.append( row )
        }
    }
    func createSquareFromDefinition(_ definition: [Int?]){
        //determine color for coord according zPattern and store
        guard let pattern = self.tartan?.zPattern else { return }
        //todo: issue high def loosing columns
        let size = definition.count*zFactor
        
        _ = (0..<size).map { x in var column:[Int] = []
            //Larger size  exceeds maximum number of these available?
            DispatchQueue.global(qos: .default).async {
            
                _ = (0..<size).map { y in
                    let c:Coordinate = Coordinate(x:x, y:y)
                    //alternate colorsource orientation using zPat
                    let orientation:Bool = pattern.z(x: c.x, y: c.y)
                    let source:Int = orientation ? x : y
                    if let resultColor:Int = definition[source % definition.count] {
                        column.append(resultColor)
//                        self.liveView.addCell([c.x, c.y, resultColor])
//                        DispatchQueue.main.async() { () -> Void in self.liveView.setNeedsDisplay()}
                    }
                }
                DispatchQueue.main.async() { () -> Void in
                    self.rowStore[x] = column
//                    print("row \(x) finished as \(self.store.count) in \(size)")
                }
            }
        }
    }
    
    func updateLiveView(_ i:Int) {
        if i == self.liveView.pCurrentColorIndex { return }
        self.liveView.setOvalColor(self.p[i])
        self.liveView.setNeedsDisplay() //DispatchQueue.main.async() { () -> Void in
    }
    
    func createColorShapes(_ colorSet:Set<Int>) {
        //group cells by color into clrShapes
        self.createColorShapesForSet(colorSet ) //trtn!.colorSetNumeric!)
        while shapeStore.count < colorSet.count {
            sleep(1)
            print("bg thread not finished shapeStore")
        }
        colorShapes = shapeStore
    }
    
    func createColorShapesForSet(_ colorSet: Set<Int>) {
        let colors:[Int] = colorSet.reduce([]) {ar, el  in return ar + [el]}
        print("colors: \(colors)")
        //create shapes by gathering coordinates for each color
        _ = colors.map { current in
//            DispatchQueue.global(qos: .default).async {
                var shape: [Coordinate] = []
                _ = self.cells.enumerated().map { (x, row) in
                    _ = row.enumerated().map  { (y, cell) in
                        if (cell == current) {
                            //cellValue represents a paletPos
                            let coordinate = Coordinate(x: x, y: y)
                            shape.append(coordinate)
//                            updateLiveView(cell)
//                            self.liveView.fillShape(current: coordinate)
                        }
                    }
                    
            }
//       DispatchQueue.main.async() { () -> Void in
            self.shapeStore[current] = shape
//                }
//            updateLiveView(current)
        }
    }
    
    func createImage() -> UIImage {
        //        //turn colorstructure 2d
        //        createSquareFromDefinition(self.tartan?.sett ?? [])
        
        //group cells by color into clrShapes
        //        createShapesfromCells(colorSet: (tartan?.colorSet)! )
        
        //set imgsize to repeats of defsize
        let repeatSize = 4 * zFactor
        let definitionSize = self.tartan?.sumSizes
        let imageSize = repeatSize*definitionSize!
        
        //Draw colorShapes into image
        if let imageTartan:UIImage = UIImage(
            size: CGSize(width: imageSize, height: imageSize),
            dictShapes: colorShapes) { return imageTartan }
        
        return UIImage(color: UIColor.darkGray)!
    }
}

extension LayOut {
    func createVariant() {
        //        images["noir"] = (images["initial"] as! UIImage).noir
        //        images["sepia"] = (images["initial"] as! UIImage).sepia
        
        //images["freaky"] = (images["initial"] as! UIImage).customFilter
        let filter = RGBFilter(paramIndex: 2.asMaxRandom(), value: 0.9)
        let img:UIImage = self.images["initial"] as! UIImage
        filter.inputImage = CIImage(image: img)
        if let output = filter.outputImage {
            images["freaky"] = UIImage(ciImage: output)
        }
    }
}

