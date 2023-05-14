//
//  InterviewRecordingView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/03.
//

import SwiftUI

struct InterviewRecordingView: View {
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
    @State private var visualColor: Color = Color(red: 1.0, green: 166/255, blue: 0.0)
    
    @Binding var isShownInterviewRecordingView: Bool
    
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
        static let speakerOne = Color(red: 0.0, green: 234/255, blue: 223/255)
        static let speakerTwo = Color(red: 1.0, green: 166/255, blue: 0.0)
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
        NavigationView{
            VStack { // 컨트롤 영역 + 화자전환 영역 + 오디오 비주얼라이저 영역
                HStack { // 컨트롤 영역 (일시정지 및 재생 + 완료)
                    Button {
                        self.isShownInterviewRecordingView.toggle()
                    } label: {
                        Text("취소")
                            .foregroundColor(Color.red)
                            .font(.headline)
                    }
                    .position(
                        x: UIScreen.main.bounds.width / 6.5,
                        y: UIScreen.main.bounds.height * 0.02
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
                                visualColor = Color(red: 1.0, green: 166/255, blue: 0.0)
                            } else {
                                visualColor = Color(red: 0.0, green: 234/255, blue: 223/255)
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
                                .foregroundColor(!isPaused ? Color.black : Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 30/100))
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
                                    }
                                )
                            )
                    }
                    .position(
                        x: UIScreen.main.bounds.width / 6.15,
                        y: UIScreen.main.bounds.height * 0.02
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
                            visualColor = Color(red: 1.0, green: 166/255, blue: 0.0)
                        } else {
                            visualColor = Color(red: 0.0, green: 234/255, blue: 223/255)
                        }
                    }
                    
                    // 완료 버튼 로직
                    NavigationLink(
                        destination: InterviewDetailEditModalView(
                            interviewBubbleManager: InterviewBubbleManager(currentInterview: vm.interview),
                            isDetailChanging: $isDetailChanging
                        ),
                        label: {
                            Text("완료")
                                .font(.headline)
                            // 녹음 중일때 -> 회색, 녹음 일시정지일때 -> 빨간색
                                .foregroundColor(!isPaused ? Color(red: 117/255, green: 117/255, blue: 117/255) : Color.red)
                            // 녹음 중일 때 완료 버튼 비활성화
                                .position(
                                    x: UIScreen.main.bounds.width / 6,
                                    y: UIScreen.main.bounds.height * 0.02
                                )
                        } //label
                    ) // NavigationLink
                    .navigationTitle("뒤로")
                    .navigationBarHidden(true)
                    .disabled(isRecording)
                } // HStack
                
                // 화자 전환 기능
                RoundedRectangle(cornerRadius: 44)
                // 화자전환 영역
                    .fill(Color(red: 28/255, green: 28/255, blue: 30/255))
                    .frame(
                        width: UIScreen.main.bounds.width * 0.95,
                        height: UIScreen.main.bounds.height * 0.7
                    )
                // 화자전환 제스처
                    .gesture(
                        DragGesture(minimumDistance: 100, coordinateSpace: .local)
                            
                            .onEnded { value in
                                let isDraggingDownward = (value.translation.height > 100 && speakerSwitch == SpeakerSwitch.speakerTwo) || (value.translation.height < -100 && speakerSwitch == SpeakerSwitch.speakerOne)
                                withAnimation() {
                                    if isDraggingDownward {
                                        // 오디오 비주얼라이저 색상
                                        if speakerSwitch == SpeakerSwitch.speakerOne {
                                            speakerSwitch = SpeakerSwitch.speakerTwo
                                            visualColor = Color(red: 0.0, green: 234/255, blue: 223/255)
                                        } else {
                                            speakerSwitch = SpeakerSwitch.speakerOne
                                            visualColor = Color(red: 1.0, green: 166/255, blue: 0.0)
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
                // 화자전환 가이드
                    .overlay(alignment: .bottom) {
                        Group {
                            if speakerSwitch == SpeakerSwitch.speakerOne {
                                // 내가 화자일때
                                VStack {
                                    Image(systemName: "chevron.compact.up")
                                        .resizable()
                                        .frame(width: 34, height: 10)
                                        .foregroundColor(Color(red: 1.0, green: 166/255, blue: 0.0))
                                        .padding(.bottom, 10)
                                    Text("쓸어올려 상대로 전환")
                                        .foregroundColor(Color(red: 1.0, green: 166/255, blue: 0.0))
                                }
                            } else {
                                // 상대가 화자일때
                                VStack{
                                    Spacer()
                                        .frame(height: 480)
                                    Image(systemName: "chevron.compact.down")
                                        .resizable()
                                        .frame(width: 34, height: 10)
                                        .foregroundColor(Color(red: 0.0, green: 234/255, blue: 223/255))
                                        .padding(.bottom, 10)
                                    Text("쓸어내려 나로 전환")
                                        .foregroundColor(Color(red: 0.0, green: 234/255, blue: 223/255))
                                }
                            }
                        }
                        .padding(.bottom, 80)
                        .font(.headline)
                        .fontWeight(.bold)
                    }
                
                // 오디오 비쥬얼라이저 뷰
                AudioVisualizerView(audioInputManager: audioInputManager, isRecording: $isRecording, isPaused: $isPaused, audioVisualizerColor: $visualColor)
            } // VStack
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
                // 마지막 STT Text가 시점 변경되는 시점을 무시하고 '일시정지 -> 완료'할 경우 오작동하는 경우가 있어서
                // .onDisappear로 인스턴스 업데이트 시점 조절
                vm.interview.recordSTT = vm.transcripts
                vm.interview.records = vm.recordings
                vm.interview.details.playTime = formattedDuration(duration)
            }
        } // NavigationView
        .navigationViewStyle(.stack)
        .accentColor(Color.red)
    } // body
} // struct

struct InterviewRecordingView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingView(
            vm: VoiceViewModel(
                interview: Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [], script: Script(scriptTitle: "", scriptContent: "")))
            , isShownInterviewRecordingView: .constant(false)
        )
    }
}
