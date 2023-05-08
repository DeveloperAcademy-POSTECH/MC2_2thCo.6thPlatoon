//
//  InterviewRecordingEndTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/05.
//

import SwiftUI

struct InterviewRecordingEndTestView: View {
    @ObservedObject var vm: VoiceViewModel
    @State private var showingList = false
    @State var infoModel: InterviewDetail = InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: "")

    @State var isValid: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("새로운 인터뷰", text: $infoModel.interviewTitle)
                } header: {
                    Text("인터뷰 제목")
                }
                .listRowBackground(Color(uiColor: UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)))
                Section {
                    HStack(spacing: 0){
                        TextField("이름", text: $infoModel.userName)
                            .onChange(of: self.infoModel.userName) { text in
                                isValid = text.count != 0 ? true : false
                            }
                        Spacer()
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                    }
                    
                    TextField("이메일", text: $infoModel.userEmail)
                    TextField("전화번호", text: $infoModel.userPhoneNumber)
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
                        showingList.toggle()
                        //infoModel 전달해주기
                        infoModel.date = vm.date
                        infoModel.playTime = vm.playTime
                        print(infoModel)
                        // Date -> String 예시
                        print(infoModel.date.toString(dateFormat: "YYYY. M. d. a h:mm"))
                    }
                    // 모달에서 새화면으로 바꿔야함
                    .sheet(isPresented: $showingList, content: {

                        InterviewDetailTestView(vm: vm)
                    })
                    .foregroundColor(isValid ? .accentColor : .gray)
                }
            }// toolbar
            
        }//NavigationView
    }
}

struct InterviewRecordingEndModalTestView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingEndTestView(vm: VoiceViewModel())
    }
}
