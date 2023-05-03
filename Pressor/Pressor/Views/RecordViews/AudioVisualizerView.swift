//
//  AudioVisualizerView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/02.
//

import SwiftUI
import AVFoundation

struct AudioVisualizerView: View {
    // 오디오 입력 관리자 관찰 객체
    @ObservedObject var audioInputManager: AudioInputViewModel
    // 녹음 여부 나타내는 바인딩 변수
    @Binding var isRecording: Bool
    // 각 막대의 높이를 저장하는 배열
    @State private var barHeights: [CGFloat] = Array(repeating: 0, count: 80)

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    HStack(spacing: 2) {
                        // 각 막대를 생성, 높이와 애니메이션 적용.
                        ForEach(0..<barHeights.count) { index in
                            BarView(height: barHeights[index] * weight(for: index))
                                .animation(.easeInOut(duration: 0.15), value: barHeights[index])
                        }
                    }
                }
            }
        }
        .frame(height: 80)
        .onAppear {
            // 녹음 중일 경우, 오디오 입력 관리자를 시작
            if isRecording {
                audioInputManager.startRecording { buffer in
                    DispatchQueue.main.async {
                        self.updateBarHeights(with: buffer)
                    }
                }
            }
        }
        .onChange(of: isRecording) { newIsRecording in
            // 녹음 상태가 변경되면, 오디오 입력 관리자를 시작하거나 중지.
            if newIsRecording {
                audioInputManager.startRecording { buffer in
                    DispatchQueue.main.async {
                        self.updateBarHeights(with: buffer)
                    }
                }
            } else {
                audioInputManager.stopRecording()
                barHeights = Array(repeating: 0, count: 80)
            }
        }
    }
}

extension AudioVisualizerView {
    
    // 막대의 높이를 조절하기 위한 가중치 함수
    private func weight(for index: Int) -> CGFloat {
        let halfCount = CGFloat(barHeights.count / 2)
        let relativeIndex = abs(CGFloat(index) - halfCount)
        let weight = 1 - (2 * relativeIndex / halfCount)
        return weight
    }
    
    // 주어진 버퍼를 사용하여 막대 높이를 업데이트하는 함수
    private func updateBarHeights(with buffer: AVAudioPCMBuffer) {
        let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
        let sampleCount = samples.count
        let blockSize = sampleCount / barHeights.count
        let maxHeight = UIScreen.main.bounds.height

        for i in 0..<barHeights.count {
            let start = i * blockSize
            let end = start + blockSize
            let slice = samples[start..<end]

            let rms = calculateRMS(for: Array(slice))
            let normalizedHeight = CGFloat(min(max(0, rms), 1)) * maxHeight / 3
            barHeights[i] = min(max(normalizedHeight, 0), maxHeight)
        }
    }
    
    // 주어진 샘플 배열에 대한 RMS(루트 평균 제곱) 값 계산 함수
    private func calculateRMS(for samples: [Float]) -> Float {
        let sumOfSquares = samples.reduce(0) { $0 + $1 * $1 }
        let rms = sqrt(sumOfSquares / Float(samples.count))
        return rms
    }
}

struct BarView: View {
    var height: CGFloat

    var body: some View {
        let safeHeight = max(min(height, CGFloat.greatestFiniteMagnitude), 0)
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.black)
            .frame(height: safeHeight)
    }
}
