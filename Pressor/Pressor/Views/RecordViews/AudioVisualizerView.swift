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
    // 일시정지 여부를 나타내는 바인딩 변수
    @Binding var isPaused: Bool
    // 색을 나타내는 바인딩 변수
    @Binding var audioVisualizerColor: Color
    // 각 막대의 높이를 저장하는 배열
    @State private var barHeights: [CGFloat] = Array(repeating: 0, count: 40)
    
    var body: some View {
        HStack(spacing: 3) {
            // 각 막대를 생성, 높이와 애니메이션 적용.
            ForEach(0..<barHeights.count, id: \.self) { index in
                BarView(
                    height: barHeights[index] * weight(for: index),
                    isRecording: isRecording,
                    audioVisualColor: audioVisualizerColor
                )
                .animation(.easeInOut(duration: 0.15), value: barHeights[index])
            }
        }
        .frame(width: 280, height: 50)
        .onAppear {
            // 뷰가 나타날 때 현재 녹음 중이고 일시정지 상태가 아니면, 오디오 입력 관리자 시작
            if isRecording && !isPaused {
                audioInputManager.startRecording { buffer in
                    DispatchQueue.main.async {
                        self.updateBarHeights(with: buffer)
                    }
                }
            }
        }
        .onChange(of: isRecording) { newIsRecording in
            // 녹음 상태가 변경되면, 새로운 녹음 상태에 따라 오디오 입력 관리자를 시작하거나 중지
            if newIsRecording && !isPaused {
                audioInputManager.startRecording { buffer in
                    DispatchQueue.main.async {
                        self.updateBarHeights(with: buffer)
                    }
                }
            } else {
                audioInputManager.stopRecording()
                barHeights = Array(repeating: 0, count: 50)
            }
        }
        .onChange(of: isPaused) { newIsPaused in
            // 일시정지 상태가 변경되면, 현재 녹음 중인 경우 일시정지 상태에 따라 오디오 입력 관리자를 시작하거나 중지
            if isRecording {
                if newIsPaused {
                    audioInputManager.stopRecording()
                } else {
                    audioInputManager.startRecording { buffer in
                        DispatchQueue.main.async {
                            self.updateBarHeights(with: buffer)
                        }
                    }
                }
            }
        }
    }
}

extension AudioVisualizerView {
    
    // 막대의 높이를 조절하기 위한 가중치 함수
    private func weight(for index: Int) -> CGFloat {
        let halfCount = CGFloat(barHeights.count / 2)
        let relativeIndex = abs(CGFloat(index) - halfCount)
        let weight = 1 - (1 * relativeIndex / halfCount)
        return weight
    }
    
    // 주어진 버퍼를 사용하여 막대 높이를 업데이트하는 함수
    private func updateBarHeights(with buffer: AVAudioPCMBuffer) {
        let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
        let sampleCount = samples.count
        let blockSize = sampleCount / barHeights.count
        let maxHeight = UIScreen.main.bounds.height / 2
        for i in 0..<barHeights.count {
            let start = i * blockSize
            let end = start + blockSize
            let slice = samples[start..<end]
            
            let rms = calculateRMS(for: Array(slice))
            let normalizedHeight = CGFloat(min(max(0, rms), 1)) * maxHeight
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
    var isRecording: Bool
    var audioVisualColor: Color
    
    var body: some View {
        let safeHeight = max(min(height, CGFloat.greatestFiniteMagnitude), 4)
        RoundedRectangle(cornerRadius: 4)
            .fill(audioVisualColor)
            .frame(maxHeight: safeHeight)
    }
}
