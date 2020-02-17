//
//  Conductor.swift
//  Recorder
//
//  Created by Jeroen Dunselman on 29/01/2020.
//  Copyright © 2020 Jeroen Dunselman. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
class Conductor {
    var sequenceIndex = 0
    var clientView:UIView?
    
    var delegate:ConductableDelegate? //weak
    let orchestra = AudioService()
    let chords = NoteNumberService()

    //Record phrase
    var recorder = Recorder()
    
    var triggerEnabled: Bool = true
    var timerNoteOff: Timer?
    let releaseTime: Double = 1.5
    
    var currentVelocity: CGPoint = CGPoint(x: 0, y: 0)
    
    private var fingerCount = 0, runFingercount = 0
    var currentFingerCount:Int {
        get { return fingerCount}
        set(newCurrent) {
            print("\(newCurrent);\(runFingercount)")
            fingerCount = newCurrent
            runFingercount += 1
            
        }
    }
    
    init() {  }
    
    func setDelegate(_ swipeVC: UIViewController){
        self.delegate = swipeVC as? ConductableDelegate
        clientView = swipeVC.view
        //        orchestra.conductor = self
        //        initializeFingerCountTranspositions()
        //        playRecursive()
    }
    @objc func gestureAction(_ sender:UIPanGestureRecognizer) {
        let data = SenderData(
            velocity: sender.velocity(in: clientView),
            position: sender.location(in: clientView),
            fingerCount: sender.numberOfTouches)
        
        handleEventWith(SenderData(
            velocity: sender.velocity(in: clientView),
            position: sender.location(in: clientView),
            fingerCount: sender.numberOfTouches))
        
        visualizeEventWith(data)
    }
    func visualizeEventWith(_ data: SenderData) {
        //animate
        let limiter = 16
        
        //        let velocity: CGFloat = currentVelocity.y / CGFloat(limiter)
        let velocity: CGFloat = data.velocity.y / CGFloat(limiter)
        
        delegate?.visualizePlaying(position: data.position, velocity: velocity)
    }
    
    func handleEventWith(_ data: SenderData) {
        handleNumberOfTouches(data.fingerCount)
        //        handlePan(data.position) //test for changes in zone
        handlePrePhrase()
        handleDirectionChange(data)
        currentVelocity.y = data.velocity.y //currently only 1 directionchange supported
        handlePostPhrase()
    }
}
extension Conductor {
    
    func handleNumberOfTouches(_ fingerCount: Int) {//
        if currentFingerCount != fingerCount {
            delegate?.fingerCountChanged()
            currentFingerCount = fingerCount}
        
        
        if fingerCount == 0 {
            handlePostPhrase()
            print("fingerCount == 0 triggered handlePostPhrase")}
//        print("fingerCount:\(fingerCount)")
    }
    
    func handlePrePhrase() {
        //next phrase
        if triggerEnabled {
            if recorder.recording { recorder.recordStarted = Date()}
            //            playNote(data)
            triggerEnabled = false
            //            client.chordChanged()
        }
    }
    
    func handlePostPhrase() {
        //accomplish continuous postponement of NoteOff event while still panning
        if let _ = timerNoteOff {
            //cancel previous noteOff
            timerNoteOff?.invalidate()
            timerNoteOff = nil
        }
        //accomplish continuous reset of timer to invoke noteOff after pan ends (and after postponement for releaseTime)
        if timerNoteOff == nil {
            self.timerNoteOff = Timer.scheduledTimer(timeInterval: releaseTime, target:self,selector:#selector(self.triggerNoteOffEvent), userInfo: nil, repeats: false)
        }
    }
    
    func handleDirectionChange(_ data: SenderData) {
        let velocity = data.velocity
        
        let directionChanged = (velocity.y > 0 && currentVelocity.y < 0) || (velocity.y < 0 && currentVelocity.y > 0)
        
        if (directionChanged) {
            //transport sequence to next note and play it
            self.sequenceIndex += 1
            self.playNote(data)
        }
    }
  
        
    
    
}

extension Conductor {
    
    @objc func triggerNoteOffEvent() {
        timerNoteOff?.invalidate()
        timerNoteOff = nil
        
        sequenceIndex = 0
        triggerEnabled = true
        //        client.phraseEnded()
        orchestra.allNotesOff()
        //
        //        print("recordedEvents.count: \(recorder.recordedEvents.count)")
        recorder.recordStarted = nil
        recorder.recording = false
        print("postponed event from triggerNoteOffEvent")
        //        if replayEnabled {
        //            //            replaySequenceIndex = 0
        print("recorder.clockedEvents.count:        \(recorder.clockedEvents.count)")
        delegate?.phraseEnded()
        recorder.replayEvents()
        
        //        }
        //        if !autoPlayCancelled {autoPlayCancelled = true}
    }
    
    func playNote(_ data: SenderData) {
//        handlePostPhrase()
        //        print("\((data.position, data.velocity))")
        print("noteOn fingerCount: \(data.fingerCount)")
        noteOn(note: MIDINoteNumber(determineCurrentNote() + 24))
        
        //record it
        if recorder.recording, let start = recorder.recordStarted {
            let clock = Date().toInt64 - start.toInt64
            recorder.clockedEvents.append(SwipeEvent(
                at: clock,
                data: data))
        }
    }
    
    func determineCurrentNote() -> Int {
        var result = 0
        result += chords.scales[0][0][self.fingerCount]
        return result
    }
    //        let defaultTransposition = 40
    //        result = defaultTransposition
    //        result += currentOctave.rawValue
    //        result += chords.scales[self.currentChordVariant % chords.scales.count][self.currentChordIndex % ChordRole.allCases.count][sequence[sequenceIndex % sequence.count]]
    //        result += current4FingerTranspose
    func noteOn(note: MIDINoteNumber) {
        orchestra.play(noteNumber: note)
    }
}

extension Date {
    var toInt64:Int64 {return Int64((self.timeIntervalSince1970 * 1000.0).rounded())}
    init(milliseconds:Int) {self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))}
}
