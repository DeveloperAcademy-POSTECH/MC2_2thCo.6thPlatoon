//
//  PermissionManager.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/12.
//

import AVFoundation
import Speech
import UIKit

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
    
    func requestMicPermission() -> Bool {
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        switch AVAudioSession.sharedInstance().recordPermission {
            
        case AVAudioSession.RecordPermission.granted:
            return true
            
        case AVAudioSession.RecordPermission.denied:
            return false
            let NOTIalert: UIAlertController = UIAlertController(title: "마이크와 음성 인식 권한 설정", message: "서비스 이용을 위해 마이크와 음성 인식 권한을 허용해주세요.", preferredStyle: .alert)
            let NOTIaction: UIAlertAction = UIAlertAction(title: "설정 변경", style: .default, handler: { (ACTION) in
                //앱 강제 종료
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {exit(0)})
                //앱 설정 이동
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            NOTIalert.addAction(NOTIaction)
            DispatchQueue.main.async{
                if #available(iOS 15, *) {
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
                    }
                } else {
                    UIApplication.shared.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
                }
            }
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
                if granted {

                } else {
                    let NOTIalert: UIAlertController = UIAlertController(title: "마이크와 음성 인식 권한 설정", message: "서비스 이용을 위해 마이크와 음성 인식 권한을 허용해주세요.", preferredStyle: .alert)
                    let NOTIaction: UIAlertAction = UIAlertAction(title: "설정 변경", style: .default, handler: { (ACTION) in
                        //앱 강제 종료
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {exit(0)})
                        //앱 설정 이동
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    })
                    NOTIalert.addAction(NOTIaction)
                    DispatchQueue.main.async{
                        if #available(iOS 15, *) {
                            if let windowScene = scene as? UIWindowScene {
                                windowScene.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
                            }
                        } else {
                            UIApplication.shared.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
                        }
                    }
                }
            })
        default:
            break
        }
        
        return false
    }
    
    /**
     * 음성인식 권한을 요청합니다.
     */
    func requestSpeechRecognizerPermission() -> Bool {
        var authCheck = false
        
        // Initialize the speech recognizer with your preferred language
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR")) else {
            print("Speech recognizer is not available for this locale!")
            return false
        }
        
        // Check the availability. It currently only works on the device
        if speechRecognizer.isAvailable == false {
            print("Speech recognizer is not available for this device!")
            return false
        }
        
        // Request authorization synchronously
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        switch authStatus {
        case .authorized:
            print("Speech Recognizer: 권한 허용")
            authCheck = true
        case .denied:
            print("Speech Recognizer: 권한 거부")
            authCheck = false
        case .restricted:
            print("Speech Recognizer: restricted")
            authCheck = false
        case .notDetermined:
            print("Speech Recognizer: notDetermined")
            
            SFSpeechRecognizer.requestAuthorization { newAuthStatus in
                switch newAuthStatus {
                case .authorized:
                    print("Speech Recognizer: 권한 허용")
                    authCheck = true
                case .denied:
                    print("Speech Recognizer: 권한 거부")
                    authCheck = false
                case .restricted:
                    print("Speech Recognizer: restricted")
                    authCheck = false
                case .notDetermined:
                    print("Speech Recognizer: notDetermined")
                    authCheck = false
                @unknown default:
                    fatalError()
                }
            }
        @unknown default:
            fatalError()
        }
        
        print(authCheck)
        return authCheck
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
