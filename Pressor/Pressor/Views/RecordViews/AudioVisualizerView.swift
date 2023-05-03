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
    @State private var barHeights: [CGFloat] = Array(repeating: 0, count: 50)

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                // 각 막대를 반복하여 표시
                ForEach(0..<barHeights.count) { index in
                    BarView(height: barHeights[index])
                }
            }

//            Button(action: toggleRecording) {
//                Text("Toggle Recording")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
        }
        .onAppear {
            // 뷰가 나타날 때 녹음 시작
            audioInputManager.startRecording { buffer in
                DispatchQueue.main.async {
                    self.updateBarHeights(with: buffer)
                }
            }
        }
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

    // 막대 높이 업데이트(에니베이션)
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
            .fill(Color.black)
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
