//
//  InterviewRecordingEndTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/05.
//

import SwiftUI

struct InterviewRecordingEndTestView: View {
    @ObservedObject var vm: VoiceViewModel
    @State private var isShowingList = false
    @State private var isValid: Bool = false
    
    var body: some View {
//        NavigationView {
            Form {
                Section {
                    TextField("새로운 인터뷰", text: $vm.interview.details.interviewTitle)
                } header: {
                    Text("인터뷰 제목")
                }
                .listRowBackground(Color(uiColor: UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)))
                Section {
                    HStack(spacing: 0){
                        TextField("이름", text: $vm.interview.details.userName)
                            .onChange(of: vm.interview.details.userName) { text in
                                isValid = text.count != 0 ? true : false
                            }
                        Spacer()
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                    } // HStack
                    
                    TextField("이메일", text: $vm.interview.details.userEmail)
                    TextField("전화번호", text: $vm.interview.details.userPhoneNumber)
                } header: {
                    Text("대상자 정보")
                } footer: {
                    HStack(spacing: 0){
                        Image(systemName: "asterisk")
                        Text("는 필수 입력 정보입니다.")
                    }
                }
                .listRowBackground(Color(uiColor: UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)))
            }// Form
            .scrollContentBackground(.hidden)
            .background(.white) // Add your background color
            .navigationTitle("정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        isShowingList.toggle()
                        print(vm.interview)

                    }
                    // 모달에서 새화면으로 바꿔야함
                    .sheet(isPresented: $isShowingList, content: {

                        InterviewDetailTestView(vm: vm)
                    })
                    .foregroundColor(isValid ? .accentColor : .gray)
                }
            }// toolbar
//        }//NavigationView
    }
}

struct InterviewRecordingEndModalTestView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingEndTestView(vm: VoiceViewModel(interview: Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [])))
    }
}
