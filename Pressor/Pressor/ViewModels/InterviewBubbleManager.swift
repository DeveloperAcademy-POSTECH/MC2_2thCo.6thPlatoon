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
    @Published var isReadyToPlay: Bool = true
    
    private var formatter = DateComponentsFormatter()
    private var audioPlayer: AVAudioPlayer = .init()
    
    // MARK: LIFECYCLE
    init(
        currentInterview: Interview
    ) {
        super.init()
    }
    
    private func prepareAudioPlayer(with audioPlayer: AVAudioPlayer) {
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        
        formattedDuration = formatter.string(from: TimeInterval(audioPlayer.duration))!
        duration = audioPlayer.duration
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.progress = CGFloat(audioPlayer.currentTime / audioPlayer.duration)
            self.formattedProgress = self.formatter.string(from: TimeInterval(audioPlayer.currentTime))!
        }
    }
    
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

// MARK: - Interview Edit & Update
extension InterviewBubbleManager {
    public func updateState(
        interviewTitle: inout String,
        userName: inout String,
        userEmail: inout String,
        userPhoneNumber: inout String
    ) {
        interviewTitle = currentInterview.details.interviewTitle
        userName = currentInterview.details.userName
        userEmail = currentInterview.details.userEmail
        userPhoneNumber = currentInterview.details.userPhoneNumber
    }
    
    public func updateInterviewDetails(
        interviewTitle: String,
        userName: String,
        userEmail: String,
        userPhoneNumber: String
    ) {
        currentInterview.details.interviewTitle = interviewTitle
        currentInterview.details.userName = userName
        currentInterview.details.userEmail = userEmail
        currentInterview.details.userPhoneNumber = userPhoneNumber
    }
}
