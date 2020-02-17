//
//  Recorder.swift
//  Recorder
//
//  Created by Jeroen Dunselman on 29/01/2020.
//  Copyright © 2020 Jeroen Dunselman. All rights reserved.
//

import Foundation
import UIKit

typealias SwipeEvent = (at: Int64, data: SenderData)
typealias SenderData = (velocity: CGPoint, position: CGPoint, fingerCount: Int)

class Recorder {
    var recording: Bool = false
    var recordStarted: Date?
    var clockedEvents: [SwipeEvent] = []
    
    func replayEvents() {
//        let report = {
//            let f: (_ :String) -> Void = {d in print("replaying \(d)")}
//            _ = f("clockedEvents.count: \(self.clockedEvents.count)")
//            _ = self.clockedEvents.map {e in f("\(e.data.fingerCount)")}
//        }
//        _ = report()
        print("replay ends, initializing next phrase")
        clockedEvents = []
        recording = true
    }
}
protocol ConductableDelegate {
    func phraseEnded()
//    func chordChanged()
//    func chordVariantChanged()
    func visualizePlaying(position: CGPoint, velocity: CGFloat) //, chordVariant: Int)
    func fingerCountChanged()
}



