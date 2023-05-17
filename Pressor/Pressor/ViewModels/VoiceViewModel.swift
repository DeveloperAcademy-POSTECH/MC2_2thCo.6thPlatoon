//
//  VoiceViewModel.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/02.
//

import SwiftUI
import AVFoundation
import Speech
import UIKit
import Combine

enum Recorder: String {
    case interviewee
    case interviewer
}

class VoiceViewModel : NSObject, ObservableObject , AVAudioPlayerDelegate{
    typealias STTCompeletion = () -> ()
    
    private var audioRecorder : AVAudioRecorder!
    private var audioPlayer : AVAudioPlayer!
    
    @Published var interview: Interview
    @Published var isRecording : Bool = false
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var timer : String = "0:00"
    @Published var isSTTCompleted: Bool = false
    
    public var interviewPath: URL = URL(fileURLWithPath: "")
    private var currentPath: URL = URL(fileURLWithPath: "")
    public var recoderType: Recorder = Recorder.interviewer
    public var recordings = [Record]()
    public var transcripts: [String] = []
    public var playTime: String = ""
    public var date: Date = Date()
    private var playingURL : URL?
    private var sfSpeech = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR"))
    
    init(interview: Interview){
        self.interview = interview
        super.init()
    }
    
    public func getTranscribeArray() -> [String] {
        return self.transcripts
    }
    
    public func initInterview() {
        //메인뷰에서 마이크를 탭하는 시점에서 Interview 인스턴스를 생성하도록 변경
        // MARK: 메인뷰 onAppear 시점에 initInterview를 실행하고, interviewViewModel에 의존성 부여하도록 설정
        let fileManager = FileManager.default
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // TODO: 인터뷰 저장하지 않을 시 해당 경로의 모든 정보 삭제해야함
        var interview: Interview = Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [], script: .init(title: "", description: ""))
        
        let directoryPath = documentUrl.appendingPathComponent("\(interview.id)")
        
        do {
            try fileManager.removeItem(atPath: directoryPath.path)
        } catch {
            print("Can't delete")
        }
        do {
            if !fileManager.fileExists(atPath: directoryPath.path) {
                try fileManager.createDirectory(
                    atPath: directoryPath.path,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }
        } catch {
            print("create folder error. do something")
        }
        
        self.interview = interview
        self.interviewPath = directoryPath
        
        // vm의 recording과 STT배열 초기화
        self.recordings.removeAll()
        self.transcripts.removeAll()
        self.isSTTCompleted = false
    }
    
    public func setInterviewDetail(interviewDetail: InterviewDetail) {
        self.interview.details = interviewDetail
        print(">>Set InterviewDatail")
        print(self.interview.details)
    }
    
    public func startRecording() {
        // 녹음이 시잘될 때 슬립모드 방지 시작
        UIApplication.shared.isIdleTimerDisabled = true
        
        // > 녹음 권한 요청 (싱글톤 객체)
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording")
        }
        
        // > 오디오 녹음 저장하기
        // > AVAudioRecoder 사용하여 인스턴스를 만들어 사용
        
        // > FileManager 인스턴스 생성 -> GET -> Documents의 directory URL
        let path = interviewPath
        
        // > init FileName
        let fileName = path.appendingPathComponent("\(Date().toString(dateFormat: "YYYY-MM-dd 'at' HH:mm:ss")).m4a")
        currentPath = fileName
        // recoder 세팅 (내부 녹음 품질을 정함)
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // url을 통해서 기록
            audioRecorder = try AVAudioRecorder(url: fileName, settings: recorderSettings)
            // 오디오 파일 생성 및 준비
            audioRecorder.prepareToRecord()
            // 해당 오디오파일에 녹음시작
            audioRecorder.record()
            isRecording = true
            
            // 타이머 on
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timer = self.covertSecToMinAndHour(seconds: self.countSec)
            })
            
            // TODO: 여기에 오디오 비주얼라이저 넣으면 될 것 같음
            
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    public func stopRecording(index: Int, recoder: Recorder){
        // 녹음이 끝날 때 슬립모드 방지 해제
        UIApplication.shared.isIdleTimerDisabled = false
        // 녹음 중지
        audioRecorder.stop()
        isRecording = false
        
        recordings.append(
            Record(
                fileURL: currentPath,
                createdAt:getFileDate(for: currentPath),
                type: recoder.rawValue,
                isPlaying: false,
                transcriptIndex: index
            )
        )
        // timer init
        self.countSec = 0
        timerCount!.invalidate()
    }
    
    public func startPlaying(url : URL) {
        
        playingURL = url
        
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
            
            for i in 0..<recordings.count {
                if recordings[i].fileURL == url {
                    recordings[i].isPlaying = true
                }
            }
            
        } catch {
            print("Playing Failed")
        }
    }
    
    public func stopPlaying(url : URL) {
        
        audioPlayer.stop()
        
        for i in 0..<recordings.count {
            if recordings[i].fileURL == url {
                recordings[i].isPlaying = false
            }
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        for i in 0..<recordings.count {
            if recordings[i].fileURL == playingURL {
                recordings[i].isPlaying = false
            }
        }
    }
    
    public func deleteRecording(url : URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Can't delete")
        }
        
        for i in 0..<recordings.count {
            
            if recordings[i].fileURL == url {
                if recordings[i].isPlaying == true{
                    stopPlaying(url: recordings[i].fileURL)
                }
                recordings.remove(at: i)
                
                break
            }
        }
    }
    
    private func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    // MARK: - [테스트 메인 함수 정의 실시]
    public func testMain(){
        /*
         ------------------------------------
         [요약 설명]
         ------------------------------------
         1. NSFileManager : 아이폰 [내파일] >> [애플리케이션 폴더] 에 있는 [파일] 을 읽기, 쓰기를 할 수 있습니다
         ------------------------------------
         2. 필요 info plist 설정 :
         
         아이폰 파일 접근 설정 : Supports opening documents in place : YES
         아이튠즈 공유 설정 : Application supports iTunes file sharing : YES
         ------------------------------------
         */
        
        
        // [파일이 저장되어 있는 경로 확인]
        let fileManager = FileManager.default // 파일 매니저 선언
        //let fileSavePath =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! // 애플리케이션 저장 폴더
        let fileSavePath = interviewPath
        
        // [애플리케이션 폴더에 저장되어 있는 파일 리스트 확인]
        var fileList : Array<Any>? = nil
        do {
            fileList = try FileManager.default.contentsOfDirectory(atPath: fileSavePath.path)
        }
        catch {
            print("[Error] : \(error.localizedDescription)")
        }
        
        
        // [로그 출력 실시]
        print("")
        print("====================================")
        print("[fileSavePath :: \(fileSavePath)]")
        print("[fileList :: \(String(describing: fileList))]")
        print("====================================")
        print("")
    }
    
    private func covertSecToMinAndHour(seconds : Int) -> String{
        
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
        
    }
}

extension VoiceViewModel {
    // MARK: - STT
    public func transURLs(urls: [URL]) {
        var idx = 0
        var numberOfURLs = urls.count
        
        loopTransURL(urls: urls, idx: idx, numberOfURLs: numberOfURLs)
    }
    
    private func loopTransURL(urls: [URL], idx: Int, numberOfURLs: Int) {
        self.transcribe(url: urls[idx]) { success in
            if success,
               idx < numberOfURLs - 1 {
                self.loopTransURL(urls: urls, idx: idx+1, numberOfURLs: numberOfURLs)
            } else {
                print("Transcribing failed for \(urls[idx])")
                
                self.isSTTCompleted = true
                // STT Completed.
            }
        }
    }
    
    private func transcribe(url: URL, completion: @escaping (Bool) -> Void) {
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko_KR")) else {
            print("Speech recognizer is not available for this locale!")
            completion(false)
            return
        }

        if !speechRecognizer.isAvailable {
            print("Speech recognizer is not available for this device!")
            completion(false)
            return
        }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            print(">> transcripts Waits")
            if (authStatus == .authorized) {
                let fileURL = url
                let request = SFSpeechURLRecognitionRequest(url: fileURL)
                print(">>>### URL: \(fileURL)")
                
                let task = speechRecognizer.recognitionTask(
                    with: request,
                    resultHandler: { (result, error) in
                        // MARK: 음성을 차례대로 정확하게 변환하기 위해
                        if result == nil {
                            self.transcripts.append("(대화 없음)")
                            completion(true)
                        } else if (result?.isFinal)! {
                            if let res = result?.bestTranscription.formattedString {
                                self.transcripts.append(res)
                                print(res)
                                completion(true)
                            }
                        }
                    })
            } else {
                print("Error: Speech-API not authorized!");
            }
        }
    }
}
