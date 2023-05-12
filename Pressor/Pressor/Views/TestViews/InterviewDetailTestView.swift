//
//  InterviewDetailTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/03.
//

import SwiftUI

struct InterviewDetailTestView: View {
    //@StateObject var speechRecognizer = SpeechRecognizer()
    @ObservedObject var vm: VoiceViewModel

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false){
                    ForEach(vm.interview.records, id: \.id) { recording in
                        VStack{
                            HStack{

                                VStack(alignment:.leading) {
                                    Text("\(recording.fileURL.lastPathComponent)")
                                    Text(recording.type)
                                    Spacer()
                                    
                                    Text(vm.transcripts[recording.transcriptIndex])
                                        .padding(10)
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                        .onAppear{
                                            print(vm.recordings.count)
                                            print(recording)
                                            print(">>>")
                                        }
                                }
                                .foregroundColor(.white)
                                Spacer()
                                VStack {
                                    Button(action: {
                                        vm.deleteRecording(url:recording.fileURL)
                                    }) {
                                        Image(systemName:"xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size:15))
                                    }
                                    Spacer()
                                    Button(action: {
                                        if recording.isPlaying == true {
                                            vm.stopPlaying(url: recording.fileURL)
                                        }else{
                                            vm.startPlaying(url: recording.fileURL)
                                        }
                                    }) {
                                        Image(systemName: recording.isPlaying ? "stop.fill" : "play.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size:30))
                                    }
                                    
                                }
                                
                            } // HStack
                            .padding()
                        } // VStack
                        .padding(.horizontal, 10)
                        .frame(width: 370, height: 200)
                        .background(Color.gray)
                        .cornerRadius(30)
                    } // ForEach
                } // ScrollView
                
                Button {
                    vm.transcripts.forEach {
                        print($0)
                    }
                    vm.testMain()
                    print(" >> transcripts count")
                    print(vm.transcripts.count)
                } label: {
                    Text("stt배열 내놔")
                }

                
            } // VStack
            .padding(.top,30)
            .navigationBarTitle("Recordings")
        } // NavigationView
    } // View
}

struct recordingListView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewDetailTestView(vm: VoiceViewModel(interview: Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [], script: .init(title: "", description: ""))))
    }
}
