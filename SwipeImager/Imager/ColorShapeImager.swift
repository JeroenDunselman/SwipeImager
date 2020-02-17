//
//  ImageBuilder.swift

//  Created by Jeroen Dunselman on 03/01/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public extension UIImage {
    internal convenience init?( size: CGSize = CGSize(width: 1, height: 1),
                                dictShapes: [Int:[Coordinate]] = [:]) {
        
        let palet = Palet.shared, imgRect = CGRect(origin: .zero, size: size)

        func runShapeFor(key: Int, shape: [Coordinate]) {
            let index:Int = key % palet.clrs.count
            let shapeColor:UIColor = palet.clrs[index]
            shapeColor.setFill()
            print("\(palet.keyOfColor(color: palet.clrs[index]) ?? "color n.f.")")
            _ = shape.map{cell in fillShape(current: cell) }
        }
        
        func fillShape(current: Coordinate) {
            //Draw 1 layout cell in four quadrants
            let one:CGFloat = 1
            let half:CGFloat = CGFloat(one / 2)
            let rSize = CGSize(width: one, height: one)
            
            var rect = CGRect(origin: CGPoint(x:current.x, y:current.y), size: rSize)
            UIRectFill(rect)
            
            let newX:Int = (current.x + Int(size.width * half))
            rect = CGRect(origin: CGPoint(x:newX, y:current.y), size: rSize)
            UIRectFill(rect)
            
            let newY:Int = (current.y + Int(size.width * half))
            rect = CGRect(origin: CGPoint(x:current.x, y:newY), size: rSize)
            UIRectFill(rect)

            rect = CGRect(origin: CGPoint(x:newX, y:newY), size: rSize)
            UIRectFill(rect)
            
        }
        
        UIGraphicsBeginImageContextWithOptions(imgRect.size, false, 0.0)
        print("imaging colorShape for..")
        _ = dictShapes.map { colorShape in
//              DispatchQueue.global(qos: .default).async { //screamer
                runShapeFor(key: colorShape.key, shape: colorShape.value)
//            }
            
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

public extension UIImage {
    
    func filter(_ filter: String) -> UIImage? {
        
        let filterName = filter
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: filterName) else { return nil}
        
        if currentFilter.inputKeys.contains(kCIInputImageKey) {
            currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            
            if let output = currentFilter.outputImage,
                let cgImage = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
            }
        }
        return nil
    }
    
    var noir: UIImage? {
        
        let filterName = "CIGlassLozenge" //CIComicEffect"// "CIPhotoEffectNoir" CIGlassLozenge"
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: filterName) else { return nil}
        
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        
        
        return nil
    }
    
    var sepia: UIImage? {
        let context = CIContext(options: nil)
        
        guard let currentFilter = CIFilter(name: "CISepiaTone") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}

class RGBFilter: CIFilter {
    var inputImage: CIImage?
    
    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage as AnyObject]
//                return createCustomKernel().apply(extent: inputImage.extent, arguments: args)
                return createKernel().apply(extent: inputImage.extent, arguments: args)
            } else {
                return nil
            }
        }
    }

    
    enum RGB: Int {case red = 0, green, blue}
    
//    func rgbParam(paramIndex: RGB, value: Float)  {
    init(paramIndex: Int, value: Float)  {
        super.init()
        self.kernelString = "kernel vec4 chromaKey( __sample s) { \n" +
            "  vec4 newPixel = s.rgba;" +
            "  newPixel[\(paramIndex)] = \(value);" +
            "  return newPixel;\n" +
        "}"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createKernel() -> CIColorKernel {
        return CIColorKernel(source: kernelString)!
    }
    
    //Suppose we wanted to write a custom kernel that removed the red color channel and divided the blue channel by two.
    var kernelString =
        "kernel vec4 chromaKey( __sample s) { \n" +
            "  vec4 newPixel = s.rgba;" +
            "  newPixel[0] = 0.0;" +
            "  newPixel[2] = newPixel[2] / 2.0;" +
            "  return newPixel;\n" +
    "}"
}
/* niu
func createCustomKernel() -> CIColorKernel {
    
    let paramIndex: String = String(2.asMaxRandom())
    let paramValue: String = "newPixel[2] + (newPixel[2] / 0.5)" //"0.0"
    let kernelString =
        "kernel vec4 chromaKey( __sample s) { \n" +
            "  vec4 newPixel = s.rgba;" +
            "  newPixel[\(paramIndex)] = \(paramValue);" +
            "  return newPixel;\n" +
    "}"
    
    return CIColorKernel(source: kernelString)!
}
struct EFUIntPixel {
    var red: UInt8 = 0
    var green: UInt8 = 0
    var blue: UInt8 = 0
    var alpha: UInt8 = 0
}
 
 public extension UIImage {
 var replaceRedWithPink: UIImage? {
 let img = CIImage(image: self)
 let pxlRed = EFUIntPixel(red: 255, green: 0, blue: 0, alpha: 0)
 let pxlBlue = EFUIntPixel(red: 0 , green: 0, blue: 255, alpha: 0)
 if let output = img?.replace(colorOld: pxlRed, colorNew: pxlBlue) {
 return UIImage(ciImage: output)
 }
 return nil
 }
 var customFilter: UIImage? {
 
 //        let filter = CustomFilter()
 //        filter.inputImage = CIImage(image: self)
 //
 //        if let output = filter.outputImage {
 //            return UIImage(ciImage: output)
 //        }
 return nil
 }}
 
extension CIImage {
    
    // Replace color with another one
    // https://github.com/dstarsboy/TMReplaceColorHue/blob/master/TMReplaceColorHue/ViewController.swift
    func replace(colorOld: EFUIntPixel, colorNew: EFUIntPixel) -> CIImage? {
        let cubeSize = 64
        let cubeData = { () -> [Float] in
            let selectColor = (Float(colorOld.red) / 255.0, Float(colorOld.green) / 255.0, Float(colorOld.blue) / 255.0, Float(colorOld.alpha) / 255.0)
            let raplaceColor = (Float(colorNew.red) / 255.0, Float(colorNew.green) / 255.0, Float(colorNew.blue) / 255.0, Float(colorNew.alpha) / 255.0)
            
            var data = [Float](repeating: 0, count: cubeSize * cubeSize * cubeSize * 4)
            var tempRGB: [Float] = [0, 0, 0]
            var newRGB: (r : Float, g : Float, b : Float, a: Float)
            var offset = 0
            for z in 0 ..< cubeSize {
                tempRGB[2] = Float(z) / Float(cubeSize) // blue value
                for y in 0 ..< cubeSize {
                    tempRGB[1] = Float(y) / Float(cubeSize) // green value
                    for x in 0 ..< cubeSize {
                        tempRGB[0] = Float(x) / Float(cubeSize) // red value
                        // Select colorOld
                        if tempRGB[0] == selectColor.0 && tempRGB[1] == selectColor.1 && tempRGB[2] == selectColor.2 {
                            //                            print("replacing")
                            newRGB = (raplaceColor.0, raplaceColor.1, raplaceColor.2, raplaceColor.3)
                        } else {
                            newRGB = (tempRGB[0], tempRGB[1], tempRGB[2], 1)
                        }
                        data[offset] = newRGB.r
                        data[offset + 1] = newRGB.g
                        data[offset + 2] = newRGB.b
                        data[offset + 3] = 1.0
                        offset += 4
                    }
                }
            }
            return data
        }()
        
        let data = cubeData.withUnsafeBufferPointer { Data(buffer: $0) } as NSData
        let colorCube = CIFilter(name: "CIColorCube")!
        colorCube.setValue(cubeSize, forKey: "inputCubeDimension")
        colorCube.setValue(data, forKey: "inputCubeData")
        colorCube.setValue(self, forKey: kCIInputImageKey)
        return colorCube.outputImage
    }
}
*/


