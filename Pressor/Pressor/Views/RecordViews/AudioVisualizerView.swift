//
//  AudioVisualizerView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/02.
//

import SwiftUI
import AVFoundation
import Charts

struct AudioVisualizerView: View {
    @StateObject private var audioInputManager = AudioInputManager()
    @State private var barHeights: [CGFloat] = Array(repeating: 0, count: 80)

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    // 왼쪽 막대 그룹
                    HStack(spacing: 2) {
                        ForEach(0..<barHeights.count) { index in
                            BarView(height: barHeights[index] * weight(for: index))
                                .animation(.easeInOut(duration: 0.15), value: barHeights[index])
                        }
                    }
                }
            }}
        .frame(height: 80)
        .background(.black)
        .onAppear {
            // 뷰가 나타날 때 녹음 시작
            audioInputManager.startRecording { buffer in
                DispatchQueue.main.async {
                    self.updateBarHeights(with: buffer)
                }
            }
        }
    }

    // 인덱스에 따른 가중치 계산
    private func weight(for index: Int) -> CGFloat {
        let halfCount = CGFloat(barHeights.count / 2)
        let relativeIndex = abs(CGFloat(index) - halfCount)
        let weight = 1 - (2 * relativeIndex / halfCount)
        return weight
    }
    
    //    private func toggleRecording() {
    //        if audioInputManager.audioEngine.isRunning {
    //            audioInputManager.stopRecording()
    //        } else {
    //            audioInputManager.startRecording { buffer in
    //                DispatchQueue.main.async {
    //                    self.updateBarHeights(with: buffer)
    //                }
    //            }
    //        }
    //    }
    
    // 막대 높이 업데이트(에니메이션)
    private func updateBarHeights(with buffer: AVAudioPCMBuffer) {
        let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
        let sampleCount = samples.count
        let blockSize = sampleCount / barHeights.count
        
        for i in 0..<barHeights.count {
            let start = i * blockSize
            let end = start + blockSize
            let slice = samples[start..<end]
            
            let rms = calculateRMS(for: Array(slice))
            let normalizedHeight = CGFloat(min(max(0, rms), 1)) * UIScreen.main.bounds.height / 3
            barHeights[i] = normalizedHeight
        }
    }
    
    // RMS 계산
    private func calculateRMS(for samples: [Float]) -> Float {
        let sumOfSquares = samples.reduce(0) { $0 + $1 * $1 }
        let rms = sqrt(sumOfSquares / Float(samples.count))
        return rms
    }
    
}


struct BarView: View {
    var height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white)
            .frame(height: height)
    }
}

class AudioInputManager: ObservableObject {
    var audioEngine: AVAudioEngine
    private var audioBufferHandler: ((AVAudioPCMBuffer) -> Void)?
    
    init() {
        audioEngine = AVAudioEngine()
    }
    
    // 녹음 시작
    func startRecording(_ audioBufferHandler: @escaping (AVAudioPCMBuffer) -> Void) {
        self.audioBufferHandler = audioBufferHandler
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.audioBufferHandler?(buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
