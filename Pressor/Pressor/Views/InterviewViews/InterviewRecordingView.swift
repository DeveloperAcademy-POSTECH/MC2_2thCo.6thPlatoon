//
//  InterviewRecordingView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/03.
//

import SwiftUI

struct InterviewRecordingView: View {
    @StateObject private var audioInputManager = AudioInputViewModel()
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var duration: TimeInterval = 0.0
    @State private var backgroundColor: Color = SpeakerColor.speakerOne
    @State private var timer: Timer? = nil
    @State private var rotationAngle: Double = 0
    
    // 화자 구분 색상
    private struct SpeakerColor {
           static let speakerOne = Color(red: 1, green: 234 / 255, blue: 132 / 255)
           static let speakerTwo = Color(red: 177 / 255, green: 232 / 255, blue: 1)
       }
    
    // 타이머 시작 함수
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            duration += 0.1
        }
    }
    
    // 타이머 중지 함수
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 타이머 초기화 함수
    private func resetDuration() {
        duration = 0
    }
    
    // 타이머 일시정지 함수
    private func pauseResumeTimer() {
        if timer == nil {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    // 화면 플립 기능
                    withAnimation(.easeInOut(duration: 0.6)) {
                        rotationAngle += 180
                    }
                }) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                // 화자 전환 기능
                backgroundColor = backgroundColor == SpeakerColor.speakerOne ? SpeakerColor.speakerTwo : SpeakerColor.speakerOne
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 100, height: 300)
            }
            
            Spacer()
            // 오디오 비쥬얼라이저 뷰
            AudioVisualizerView(audioInputManager: audioInputManager, isRecording: $isRecording, isPaused: $isPaused)
            HStack {
                // 타이머 표시
                Text(String(format: "%.1fs", duration))
                    .font(.title2)
                    .frame(minWidth: 50)
                    .padding(.leading)
                
                // 녹음 버튼
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        audioInputManager.startRecording { buffer in
                            DispatchQueue.main.async {
                                // UI 관련 로직
                            }
                        }
                        startTimer()
                    } else {
                        audioInputManager.stopRecording()
                        isPaused = false
                        stopTimer()
                        resetDuration()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle" : "record.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    isPaused.toggle()
                    pauseResumeTimer()
                    if isPaused {
                        // 녹음 일시정지
                    } else {
                        // 녹음 재개
                    }
                }) {
                    Image(systemName: isPaused ? "play.circle" : "pause.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                .disabled(!isRecording)
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .rotation3DEffect(.degrees(rotationAngle), axis: (x: 1.0, y: 0.0, z: 0.0))
        .background(backgroundColor)
        .onAppear {
            audioInputManager.prepare()
        }
        .onDisappear {
            audioInputManager.stopRecording()
        }
    }
}


struct InterviewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingView()
    }
}

