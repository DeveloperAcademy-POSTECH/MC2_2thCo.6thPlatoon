//
//  AudioInputVIewModel.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/03.
//

import Foundation
import CoreAudio
import AVFoundation

// 오디오 입력을 처리하기 위한 뷰 모델 클래스(AudioInputManager)
final class AudioInputViewModel: ObservableObject {
    // AVAudioEngine을 사용하여 오디오 데이터를 처리
    var audioEngine: AVAudioEngine = AVAudioEngine()
    // 처리된 오디오 버퍼를 처리하는 핸들러
    private var audioBufferHandler: ((AVAudioPCMBuffer) -> Void)?
    
    private func setPrefferredInputDevice(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
          // 사용 가능한 모든 입력 장치 가져오기
          let availableInputs = audioSession.availableInputs
          // 외부 마이크 찾기
          let externalMic = availableInputs?.first(where: { $0.portType != .builtInMic })

          if let extMic = externalMic {
              // 선호하는 입력 장치를 외부 마이크로 설정
              try audioSession.setPreferredInput(extMic)
              print("External microphone set as preferred input device.")
          } else {
              print("No external microphone found.")
          }
      } catch {
          print("Error setting preferred input device: \(error.localizedDescription)")
      }
    }
        
    // 오디오 녹음을 시작하고 오디오 버퍼 핸들러 설정
    func startRecording(_ audioBufferHandler: @escaping (AVAudioPCMBuffer) -> Void) {
      setPrefferredInputDevice()
        // 오디오 버퍼 핸들러 설정
        self.audioBufferHandler = audioBufferHandler
        // 기존 탭 제거
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        // 새 탭 설치
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            audioBufferHandler(buffer)
        }
        
        // 오디오 엔진 준비
        audioEngine.prepare()
        
        // 오디오 엔진 시작
        do {
            try audioEngine.start()
        } catch {
            print("Error starting the audio engine: \(error.localizedDescription)")
        }
    }
    
    // 오디오 녹음 중지 및 탭 제거
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
