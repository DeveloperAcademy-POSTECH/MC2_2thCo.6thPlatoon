//
//  InterviewBubbleManager.swift
//  Pressor
//
//  Created by Celan on 2023/05/12.
//

import SwiftUI
import AVFoundation

final class InterviewBubbleManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isReadyToPlay: Bool = true
    
    private var audioPlayer: AVAudioPlayer = .init()
    
    // MARK: - Bubble Audio Control
    public func startPlayingRecordVoice(
        url: URL,
        isReadyToPlay: Binding<Bool>
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
            
            // true -> False, PLAYING
            self.isReadyToPlay = false
            isReadyToPlay.wrappedValue.toggle()
        } catch {
            print("Playing Failed")
        }
    }
    
    public func stopPlayingRecordVoice() {
        audioPlayer.stop()
        isReadyToPlay = true
    }
    
    // MARK: AUDIO DELEGATE
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.isReadyToPlay = true
        } else {
            print("NOT SUCCESS: \(flag.description)")
        }
    }
}
