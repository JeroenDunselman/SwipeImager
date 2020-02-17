//
//  ViewController.swift
//  Recorder
//
//  Created by Jeroen Dunselman on 29/01/2020.
//  Copyright © 2020 Jeroen Dunselman. All rights reserved.
//
//        let tartanDefinition:TartanDefinition = (tartan: tartan, info: ["info_htseflutsch": "randomSizesFor"])
//        let e: Entry = (title: "htseflutsch", definition: tartanDefinition)

import UIKit

extension ViewController: ConductableDelegate {
    func visualizePlaying(position: CGPoint, velocity: CGFloat) {
        emitterLayer.emitterPosition = position
        emitterLayer.birthRate = 100
    }
    
    func fingerCountChanged() {
        print(self.conductor?.currentFingerCount ?? 999)
        let color = Palet.shared.clrs[(self.conductor?.currentFingerCount ?? 0) % Palet.shared.clrs.count]
        self.fire.cell.color = color.cgColor
    }
    
    func phraseEnded() {
    
        emitterLayer.birthRate = 0
        
        let fingerCount:[Int] = self.conductor?.recorder.clockedEvents.reduce([],  {ar, el in return ar + [el.data.fingerCount] } ) ?? []
        print("finger counts registered: \(fingerCount.valuedAsSet)")
        
        let tartan = Tartan(sett: fingerCount)
        //Tartan(randomSizesFor: sequence) // Tartan(colors: vals, sizes: vals)
        let request = ImageRequest(LayOut(tartan: tartan)) //, colorSet: vals))
        //        let asset: Asset = (entry: e, request: request)

        if let showLayOutView = self.view as? DrawTartanView {
            request.layOut.liveView = showLayOutView
            request.layOut.liveView.coords = []
        }
        request.imageView = self.imgOutlet //self?.clientMenuVC!.resultVC!.imageView

//        let p:[UIColor] = Palet.shared.clrs
//        let color = p[p.count.asMaxRandom()]
//        self.triggerDraw(color)
        request.downloadImage() //return asset
    }
    
    func triggerDraw(_ color:UIColor) {
        if let v = self.view as? DrawTartanView {
            v.ovalColor = color //(v.ovalColor == UIColor.red) ? UIColor.purple : UIColor.red
            self.view.setNeedsDisplay()
        }
    }
}

class ViewController: GestureTracerViewController   {
  
    
//    public var panGesture = UIPanGestureRecognizer()
    var conductor: Conductor?
    //    let imgVw:UIImageView
    
    @IBOutlet var imgOutlet: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view = DrawTartanView()
        
        conductor = Conductor()
        conductor?.setDelegate(self)
        
        if let conductor = conductor {
            self.panGesture = UIPanGestureRecognizer(target: conductor, action: #selector(conductor.gestureAction(_:)))
        }
        self.view.addGestureRecognizer(panGesture)
        
        prepareEmitterLayer()
        self.view.addGestureRecognizer(panGesture)
    }
    
    let fire = Fire() //CAEmitterCell()
    func prepareEmitterLayer() {
        fire.cell.color = UIColor.green.cgColor
        self.emitterLayer.emitterCells = [fire.cell]
        self.emitterLayer.emitterMode = CAEmitterLayerEmitterMode.outline
        self.emitterLayer.emitterShape = CAEmitterLayerEmitterShape.circle
        self.emitterLayer.emitterSize = CGSize(width: 10, height: 10)
        
        self.view.layer.addSublayer(self.emitterLayer)
    }

}

class GestureTracerViewController: UIViewController {
    public var panGesture = UIPanGestureRecognizer()
    //visual response to swipe
    let emitterLayer = CAEmitterLayer()
    let colors = [UIColor.blue, UIColor.red, UIColor.green, UIColor.yellow]
    var guides: [UIView] = []
    override func viewDidLoad() {   }
}
