//
//  PermissionManager.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/12.
//

import AVFoundation
import Speech

class PermissionManager : ObservableObject {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    /**
     * 음성녹음 권한을 요청합니다.
     */
    func requestRecordingPermission() {
        // Singleton 인스턴스를 얻어온다.
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            // 오디오 세션의 카테고리와 모드를 설정한다.
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            // 음성 녹음 권한을 요청한다.
            recordingSession.requestRecordPermission() { allowed in
                if allowed {
                    print("Record: 권한 허용")
                } else {
                    print("Record: 권한 거부")
                }
            }
        } catch {
            print("음성 녹음 실패")
        }
    }
    
    /**
     * 음성인식 권한을 요청합니다.
     */
    func requestSpeechRecognizerPermission() {
        // Initialize the speech recogniter with your preffered language
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR")) else {
            print("Speech recognizer is not available for this locale!")
            return
        }
        
        // Check the availability. It currently only works on the device
        if (speechRecognizer.isAvailable == false) {
            print("Speech recognizer is not available for this device!")
            return
        }
        
        // Make the authorization request
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // The authorization status results in changes to the
            // app’s interface, so process the results on the app’s
            // main queue.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Speech Recognizer: 권한 허용")

                case .denied:
                    print("Speech Recognizer: 권한 거부")
                    
                case .restricted:
                    print("Speech Recognizer: restricted")
                    
                case .notDetermined:
                    print("Speech Recognizer: notDetermined")
                
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    
    
    /**
     * 오디오 권한을  요청합니다.
     */
    func requestAudioPermission(){
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
            if granted {
                print("Audio: 권한 허용")
            } else {
                print("Audio: 권한 거부")
            }
        })
    }
    
}
