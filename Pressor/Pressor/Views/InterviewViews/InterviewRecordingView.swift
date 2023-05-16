//
//  InterviewRecordingView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/03.
//

import SwiftUI

struct InterviewRecordingView: View {
    @EnvironmentObject var routingManager: RoutingManager
    @ObservedObject var vm: VoiceViewModel
    
    @State private var isDetailChanging: Bool = false
    @State private var isShowingList = false
    @State var transcriptIndex: Int = 0
    @StateObject private var audioInputManager = AudioInputViewModel()
    @State private var isRecording = false
    @State private var isPaused = true
    @State private var duration: TimeInterval = 0.0
    @State private var speakerSwitch: Color = SpeakerSwitch.speakerOne
    @State private var timer: Timer? = nil
    @State private var visualColor: Color = Color.PressorOrange
    @State private var isChevronAnimating = false
    @State private var isShowingBottomImage = true
    @State private var initChevronOffsetYValue = CGFloat.zero
    @State private var isShowingTopImage = true
    @State var isShowingCancelAlert = false
    
    // 타이머 시간 포맷
    func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "00:00"
    }
    
    // 화자 구분 색상
    private struct SpeakerSwitch {
        static let speakerOne = Color.PressorOrange
        static let speakerTwo = Color.PressorBlue
    }
    
    // 타이머 시작 함수
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            duration += 1
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
        NavigationView{
            ZStack {
                VStack {
                    HStack { // 컨트롤 영역 (일시정지 및 재생 + 완료)
                        Button {
                            self.isShowingCancelAlert.toggle()
                        } label: {
                            Text("취소")
                                .foregroundColor(Color.red)
                                .font(.headline)
                        }
                        .alert(isPresented: $isShowingCancelAlert) {
                            Alert(
                                title: Text("녹음 취소"),
                                message: Text("진행중인 녹음이 삭제됩니다."),
                                primaryButton: .destructive(Text("녹음 취소")) {
                                    routingManager.isRecordViewDisplayed.toggle()
                                    // 취소하면 인터뷰 초기화
                                    vm.initInterview()
                                },
                                secondaryButton: .cancel(Text("되돌아가기"))
                            )
                        }
                        .position(
                            x: UIScreen.main.bounds.width / 6.5,
                            y: UIScreen.main.bounds.height * 0.03
                        )
                        
                        // 일시정지 및 재생 버튼 로직
                        Button(action: {
                            isRecording.toggle()
                            if isRecording {
                                // 녹음 중일때 -> 녹음 시작 및 타이머 시작
                                isPaused = false
                                audioInputManager.startRecording { buffer in
                                    DispatchQueue.main.async { }
                                }
                                startTimer()
                                // 녹음 중일때 or 일시정지일 떄 오디오 비주얼라이저 색상 변경
                                if speakerSwitch == SpeakerSwitch.speakerOne {
                                    visualColor = Color.PressorOrange
                                } else {
                                    visualColor = Color.PressorBlue
                                }
                                vm.startRecording()
                            } else {
                                // 일시정지일때 -> 타이머 정지 및 오디오 비주얼라이저 끔
                                audioInputManager.stopRecording()
                                isPaused = true
                                stopTimer()
                                // 오디오 비주얼라이저 회색으로 비활성화 표시
                                visualColor = Color.gray
                                
                                // 일단 먼저 녹음중지하고 기록함
                                vm.stopRecording(
                                    index: self.transcriptIndex,
                                    recoder: vm.recoderType
                                )
                                self.transcriptIndex += 1
                            }
                        }) {
                            // 일시정지 및 재생 버튼 UI
                            RoundedRectangle(cornerRadius: 35)
                            // 버튼 겉 stroke
                                .stroke(!isPaused ? Color.white : Color.red, lineWidth: 3)
                                .frame(width: 131, height: 44)
                            // 버튼 속 fill
                                .overlay(RoundedRectangle(cornerRadius: 35)
                                    .frame(width: 119, height: 32)
                                         // 녹음 중일때 -> 검정색, 녹음 일시정지일때 -> 빨간색
                                    .foregroundColor(!isPaused ? Color.black : Color.PressorRed_Dark)
                                    .overlay(
                                        HStack {
                                            // 녹음 중일때 -> 일시정지 심볼, 녹음 일시정지일때 -> 재생 심볼
                                            Image(systemName: !isPaused ? "pause.fill" : "play.fill")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .foregroundColor(Color.red)
                                            // 타이머 텍스트
                                            Text(formattedDuration(duration))
                                                .font(.title2)
                                                .fontDesign(.rounded)
                                                .fontWeight(.bold)
                                                .foregroundColor(!isPaused ? Color.white : Color.red)
                                                .frame(minWidth: 50)
                                                .monospacedDigit()
                                        }
                                    )
                                )
                        }
                        .position(
                            x: UIScreen.main.bounds.width / 6.15,
                            y: UIScreen.main.bounds.height * 0.03
                        )
                        .onAppear {
                            vm.recoderType = Recorder.interviewer
                            vm.startRecording()
                            
                            isRecording = true
                            // 녹음 중일때 -> 녹음 시작 및 타이머 시작
                            isPaused = false
                            audioInputManager.startRecording { buffer in
                                DispatchQueue.main.async {}
                            }
                            startTimer()
                            // 녹음 중일때 or 일시정지일 떄 오디오 비주얼라이저 색상 변경
                            if speakerSwitch == SpeakerSwitch.speakerOne {
                                visualColor = Color.PressorOrange
                            } else {
                                visualColor = Color.PressorBlue
                            }
                        }

                        // 완료 버튼 로직
                        NavigationLink(
                            destination: InterviewDetailEditModalView(
                                isDetailChanging: .constant(false),
                                interview: vm.interview
                            )
                            .onAppear {
                                vm.isSTTCompleted = false
                            },
                            label: {
                                Text(vm.isSTTCompleted ? "완료" : "음성 변환중")
                                    .font(.headline)
                                // 녹음 중일때 -> 회색, 녹음 일시정지일때 -> 빨간색
                                    .foregroundColor(!isPaused ? Color.BackgroundGray_Dark : Color.red)
                                // 녹음 중일 때 완료 버튼 비활성화
                                    .position(
                                        x: UIScreen.main.bounds.width / 6,
                                        y: UIScreen.main.bounds.height * 0.03
                                    )
                            } //label
                        ) // NavigationLink
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    vm.interview.records = vm.recordings
                                    vm.interview.details.playTime = formattedDuration(duration)
                                }
                        )
                        .navigationTitle("뒤로")
                        .navigationBarHidden(true)
                        .disabled(isRecording || !vm.isSTTCompleted)
                    } // HStack
                    // 화자 전환 기능
                    RoundedRectangle(cornerRadius: 44)
                        // 화자전환 영역
                        .fill(Color.BackgroundGray_Dark)
                        .frame(
                            width: UIScreen.main.bounds.width * 0.93,
                            height: UIScreen.main.bounds.height * 0.74
                        )
                        // 화자전환 제스처
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let isDraggingDownward = (value.translation.height > 50 && speakerSwitch == SpeakerSwitch.speakerTwo) || (value.translation.height < -50 && speakerSwitch == SpeakerSwitch.speakerOne)
                                    withAnimation(.spring()) {
                                        if isDraggingDownward {
                                            // 오디오 비주얼라이저 색상
                                            if speakerSwitch == SpeakerSwitch.speakerOne {
                                                speakerSwitch = SpeakerSwitch.speakerTwo
                                                visualColor = Color.PressorBlue
                                                self.isChevronAnimating = true
                                            } else {
                                                speakerSwitch = SpeakerSwitch.speakerOne
                                                visualColor = Color.PressorOrange
                                                self.isChevronAnimating = false
                                            }
                                            
                                            if vm.isRecording {
                                                // 화자바꾸지 않고 기록함
                                                vm.stopRecording(
                                                    index: self.transcriptIndex,
                                                    recoder: vm.recoderType
                                                )
                                                self.transcriptIndex += 1
                                                // 화자를 바꾸기
                                                if vm.recoderType == Recorder.interviewer { // 인터뷰어일때
                                                    vm.recoderType = Recorder.interviewee // 화자 바꾸고
                                                } else { // 인터뷰이일때
                                                    vm.recoderType = Recorder.interviewer
                                                }
                                                vm.startRecording()
                                            } else {
                                                // 화자를 바꾸기
                                                if vm.recoderType == Recorder.interviewer { // 인터뷰어일때
                                                    vm.recoderType = Recorder.interviewee // 화자 바꾸고
                                                } else { // 인터뷰이일때
                                                    vm.recoderType = Recorder.interviewer
                                                }
                                            }
                                        }
                                    }
                                }
                        )
                        // 화자전환 제스처 가이드
                        .overlay {
                            Group {
                                if speakerSwitch == SpeakerSwitch.speakerOne {
                                    // 내가 화자일때
                                    if isShowingBottomImage {
                                        VStack(spacing: 20) {
                                            Image(systemName: "chevron.compact.up")
                                                .resizable()
                                                .frame(width: 34, height: 10)
                                                .foregroundColor(Color.PressorOrange)
                                                .offset(x: 0, y: isChevronAnimating ? initChevronOffsetYValue - 15 : initChevronOffsetYValue)
                                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isChevronAnimating)
                                                .onAppear {
                                                    self.isChevronAnimating = true
                                                }
                                            Text("쓸어올려 상대로 전환")
                                                .foregroundColor(Color.PressorOrange)
                                        }
                                        .padding(.top, UIScreen.main.bounds.height / 2)
                                        .onAppear {
                                        }
                                    }
                                } else {
                                    // 상대가 화자일때
                                    if isShowingBottomImage {
                                        VStack(spacing: 20) {
                                            Text("쓸어내려 나로 전환")
                                                .foregroundColor(Color.PressorBlue)
                                            Image(systemName: "chevron.compact.down")
                                                .resizable()
                                                .frame(width: 34, height: 10)
                                                .foregroundColor(Color.PressorBlue)
                                                .offset(x: 0, y: !isChevronAnimating ? 15 + initChevronOffsetYValue : initChevronOffsetYValue)
                                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: !isChevronAnimating)
                                                .onAppear {
                                                    self.isChevronAnimating = false
                                                }
                                        }
                                        .padding(.bottom, UIScreen.main.bounds.height / 2)
                                        .onAppear {
                                        }
                                    }
                                }
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                        }
                        .position(
                            x: UIScreen.main.bounds.width / 2,
                            y: UIScreen.main.bounds.height * 0.006
                        )
                } // VStack
                // 오디오 비쥬얼라이저 뷰
                AudioVisualizerView(audioInputManager: audioInputManager, isRecording: $isRecording, isPaused: $isPaused, audioVisualizerColor: $visualColor)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.875)
            } // ZStack
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )// 컨트롤영역 + 화자전환영역 + 오디오 비주얼라이저 VStack 닫기
            .background (
                Color.black
            )
            .onAppear {
                audioInputManager.prepare()
            }
            .onDisappear {
                audioInputManager.stopRecording()
                stopTimer()
            }
        } // NavigationView
        .accentColor(Color.orange)
        .navigationViewStyle(.stack)
    } // body
} // struct

struct InterviewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingView(
            vm: VoiceViewModel(
                interview: Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [], script: Script(title: "", description: "")))
        )
    }
}
