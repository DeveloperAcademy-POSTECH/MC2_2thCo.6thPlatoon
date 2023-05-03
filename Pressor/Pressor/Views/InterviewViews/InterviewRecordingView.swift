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

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    // 화면 플립 기능
                }) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                // 화자 전환 기능
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 100, height: 300)
            }
            
            Spacer()
            AudioVisualizerView(audioInputManager: audioInputManager, isRecording: $isRecording)
            HStack {
                Text(String(format: "%.1fs", duration))
                    .font(.title2)
                    .padding(.leading)
                
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        audioInputManager.startRecording { buffer in
                            DispatchQueue.main.async {
                                // UI 관련 로직
                            }
                        }
                    } else {
                        audioInputManager.stopRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle" : "record.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    isPaused.toggle()
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
                .padding(.trailing)
            }
            .padding(.bottom)
        }
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

