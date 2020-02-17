//
//  Fire.swift
//  Swipe-O-Phone
//
//  Created by Jeroen Dunselman on 21/03/2019.
//  Copyright © 2019 Jeroen Dunselman. All rights reserved.
//

import Foundation
import UIKit

class Fire {
    let cell = CAEmitterCell()
    init() {
        cell.birthRate = 1
        cell.lifetime = 3.0
        cell.lifetimeRange = 3.0
        
        cell.color = UIColor.red.cgColor
        cell.redRange = 0.46
        cell.greenRange = 0.49
        cell.blueRange = 0.67
        cell.alphaRange = 0.55
        
        cell.redSpeed = 0.11
        cell.greenSpeed = 0.07
        cell.blueSpeed = -2.25
        cell.alphaSpeed = -1.5
        //    345px-Chladini.Diagrams
        cell.contents = #imageLiteral(resourceName: "345px-Chladini2").cgImage
        cell.velocity = 10.0
        cell.velocityRange = 20.0
        cell.emissionRange = .pi * 2
        
        cell.scaleSpeed = -0.25
        cell.spin = 0.3
        cell.spinRange = 8.0
        cell.scale = 1.0
        cell.name = "fire"
    }
    
}
