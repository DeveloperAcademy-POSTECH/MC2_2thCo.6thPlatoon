//
//  InterviewBubbleManager.swift
//  Pressor
//
//  Created by Celan on 2023/05/12.
//

import SwiftUI
import AVFoundation

final class InterviewBubbleManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentInterview: Interview = .getDummyInterview()
    @Published var duration: Double = 0.0
    @Published var formattedDuration: String = ""
    @Published var progress: CGFloat = 0.0
    @Published var formattedProgress: String = "00:00"
    
    private var formatter = DateComponentsFormatter()
    private var audioPlayer: AVAudioPlayer = .init()
    
    // MARK: LIFECYCLE
    init(
        currentInterview: Interview? = nil
    ) {
        self.currentInterview = currentInterview ?? .getDummyInterview()
    }
    
    private func prepareAudioPlayer(with audioPlayer: AVAudioPlayer) {
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        
        formattedDuration = formatter.string(from: TimeInterval(audioPlayer.duration))!
        duration = audioPlayer.duration
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
            self?.formattedProgress = self?.formatter.string(from: TimeInterval(audioPlayer.currentTime))! ?? ""
        }
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
//            prepareAudioPlayer(with: self.audioPlayer)
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
}
