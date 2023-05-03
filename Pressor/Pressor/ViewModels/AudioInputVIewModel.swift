//
//  AudioInputVIewModel.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/03.
//

import Foundation
import AVFoundation

// 오디오 입력을 처리하기 위한 뷰 모델 클래스
class AudioInputViewModel: ObservableObject {
    // AVAudioEngine을 사용하여 오디오 데이터를 처리
    var audioEngine: AVAudioEngine
    // 처리된 오디오 버퍼를 처리하는 핸들러
    private var audioBufferHandler: ((AVAudioPCMBuffer) -> Void)?
    
    // AVAudioEngine 인스턴스 초기화
    init() {
        audioEngine = AVAudioEngine()
    }

    // 오디오 엔진을 준비하고 탭 설치
    func prepare() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.audioBufferHandler?(buffer)
        }
    }
    
    // 오디오 녹음을 시작하고 오디오 버퍼 핸들러 설정
    func startRecording(_ audioBufferHandler: @escaping (AVAudioPCMBuffer) -> Void) {
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
