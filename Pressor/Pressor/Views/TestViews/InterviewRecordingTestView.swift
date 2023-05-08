//
//  InterviewRecordingTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/02.
//

import SwiftUI

struct InterviewRecordingTestView: View {
    @ObservedObject var vm: VoiceViewModel
    
    @State private var showingList = false
    @State private var showingAlert = false
    @State private var isRecording = false
    @State var transcriptIndex: Int = 0
    
    var body: some View {
        
        VStack{
            Spacer()
            
            Image(systemName: vm.recoderType == Recorder.interviewer ? "mic.circle" : "mic.circle.fill")
                .font(.system(size: 45))
                .onTapGesture {
                    
                    // 일단 먼저 녹음중지하고 기록함
                    vm.stopRecording(index: self.transcriptIndex)
                    self.transcriptIndex += 1
                    // 화자를 바꾸기
                    if vm.recoderType == Recorder.interviewer { // 인터뷰어일때
                        vm.recoderType = Recorder.interviewee // 화자 바꾸고
                    } else { // 인터뷰이일때
                        vm.recoderType = Recorder.interviewer
                    }
                    vm.startRecording()
                    // 화자 바꾼 후 다른 화자로 녹음
                    
                }
                .onAppear{
                    vm.recoderType = Recorder.interviewer
                    vm.startRecording()
                }
            Text(vm.recoderType == Recorder.interviewer ? "나" : "상대")
            Spacer()
            HStack{
                Spacer()
                Button(action: {
                    if vm.isRecording == true {
                        // 녹음 중지
                        vm.stopRecording(index: transcriptIndex)
                        // 여태까지 녹음한 오디오파일들 패치
                        // TODO: 해당 인터뷰모델에
                        // TODO: 녹음한 [Record] 배열 넣기

                        showingList.toggle()
                        
                        // TODO: STT 어디서 하지?-?
                        // TODO: 위 vm.recordings에서 재생시키지 않고 stt 시도하기
                       
                        // TODO: 인터뷰대상자 정보입력
                        
                    }
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 45))
                }.sheet(isPresented: $showingList, content: {
                    InterviewRecordingEndTestView(vm: vm)
//                    InterviewDetailTestView(vm: vm)
                })
                Spacer()
                Button {
                    // 일시정지 중에만 활성화됨
                    if vm.isRecording == false {
                        showingList.toggle()
                    }
                } label: {
                    Text("완료")
                        .font(.system(size: 45))
                        .foregroundColor(vm.isRecording ? .gray : .red)
                }
                Spacer()
                Button {
                    if vm.isRecording == true {
                        vm.stopRecording(index: transcriptIndex)
                    } else {

                    }
                } label: {
                    Image(systemName: vm.isRecording ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 45))
                }
                Spacer()

            }
            Spacer()
        }

    }
}

struct InterviewRecordingTestView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingTestView(vm: VoiceViewModel())
    }
}
