//
//  VoiceViewModel.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/02.
//

import Foundation
import AVFoundation
import Speech

enum Recorder: String {
    case interviewee
    case interviewer
}

class VoiceViewModel : NSObject, ObservableObject , AVAudioPlayerDelegate{
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    @Published var interviewPath: URL = URL(fileURLWithPath: "")
    private var currentPath: URL = URL(fileURLWithPath: "")
    @Published var isRecording : Bool = false
    @Published var recoderType: Recorder = Recorder.interviewer
    @Published var recordings = [Record]()
    @Published var transcripts: [String] = []
    @Published var recordsURL = [URL]()
    var playTime: String = ""
    var date: Date = Date()
    
    @Published var countSec = 0
    @Published var timerCount : Timer?
    @Published var timer : String = "0:00"
    @Published var toggleColor : Bool = false
    
    var playingURL : URL?
    
    override init(){
        super.init()
//        fetchAllRecording()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        for i in 0..<recordings.count {
            if recordings[i].fileURL == playingURL {
                recordings[i].isPlaying = false
            }
        }
    }
    
    func startRecording() {
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
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
    
    
    func stopRecording(index: Int){
        // 녹음 중지
        audioRecorder.stop()
        isRecording = false
        
        recordings.append(
            Record(
                fileURL: currentPath,
                createdAt:getFileDate(for: currentPath),
                type:
                    recordings.count % 2 == 0
                ? Recorder.interviewer.rawValue
                : Recorder.interviewee.rawValue,
                isPlaying: false,
                transcriptIndex: index
            )
        )
        // timer init
        self.countSec = 0
        timerCount!.invalidate()
        transcribe(url: currentPath)
    }
    
    func transcribe(url: URL) {
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
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            print(">> transcripts Waits")
            if (authStatus == .authorized) {
                // Grab a local audio sample to parse
                //                let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "one_more_thing", ofType: "mp3")!)
                let fileURL = url
                // Get the party started and watch for results in the completion block.
                // It gets fired every time a new word (aka transcription) gets detected.
                let request = SFSpeechURLRecognitionRequest(url: fileURL)
                print(">>>### URL: \(fileURL)")
                
                speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
                    if result == nil {
                        self.transcripts.append("(대화 없음)")
                    } else if (result?.isFinal)! {
                        if let res = result?.bestTranscription.formattedString {
                            self.transcripts.append(res)
                            print(res)
                        }
                    }
                })
            } else {
                print("Error: Speech-API not authorized!");
            }
        }
    }
    
    
    func startPlaying(url : URL) {
        
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
    
    func stopPlaying(url : URL) {
        
        audioPlayer.stop()
        
        for i in 0..<recordings.count {
            if recordings[i].fileURL == url {
                recordings[i].isPlaying = false
            }
        }
    }
    
    
    func deleteRecording(url : URL) {
        
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
    
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
    
    // MARK: - [테스트 메인 함수 정의 실시]
    func testMain(){
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
    
}
extension VoiceViewModel {
    func covertSecToMinAndHour(seconds : Int) -> String{
        
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
        
    }
}


