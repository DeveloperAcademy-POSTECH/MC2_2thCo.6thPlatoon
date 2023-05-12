//
//  InterviewBubbleManager.swift
//  Pressor
//
//  Created by Celan on 2023/05/12.
//

import SwiftUI
import AVFoundation

final class InterviewBubbleManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentInterview: Interview?
    private var audioPlayer: AVAudioPlayer = .init()
    
    // MARK: LIFECYCLE
    init(
        currentInterview: Interview? = nil
    ) {
        self.currentInterview = currentInterview
    }
    
    // MARK: - Bubble Audio Control
    public func startPlayingRecordVoice(
        url: URL,
        isPlaying: Binding<Bool>
    ) {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isPlaying.wrappedValue.toggle()
        } catch {
            print("Playing Failed")
        }
    }
    
    public func stopPlayingRecordVoice(isPlaying: Binding<Bool>) {
        audioPlayer.stop()
        isPlaying.wrappedValue.toggle()
    }
    
    // TODO: PLAY ALL RECORD WITH
    public func playAllRecord(isPlaying: Binding<Bool>, inList urls: [URL]) {
        let playSession = AVAudioSession.sharedInstance()
        var idx = 0
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: urls[idx])
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Playing Failed")
        }
    }
}
