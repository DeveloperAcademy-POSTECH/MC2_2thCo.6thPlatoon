//  InterviewRecordingEndView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/04.
//

import SwiftUI

struct InterviewRecordingEndView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: InterviewRecordViewModel
    
    var body: some View {
        NavigationView {
            Form {
                // 인터뷰 제목 섹션
                Section(header: Text("인터뷰 제목")) {
                    TextField("새로운 인터뷰", text: $viewModel.interviewTitle)
                }
                // 대상자 정보 섹션
                Section(header: Text("대상자 정보")) {
                    TextField("이름", text: $viewModel.intervieweeName)
                    
                    TextField("이메일", text: $viewModel.email)
                    
                    TextField("전화번호", text: $viewModel.phoneNum)
                }
            }
            .navigationBarTitle("정보", displayMode: .inline)
            .navigationBarItems(leading:
                                    // 취소 버튼
                                Button("취소") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red),
                                trailing:
                                    // 완료 버튼
                                Button("완료") {
                viewModel.saveInterviewRecord()
                presentationMode.wrappedValue.dismiss()
            }.disabled(viewModel.isDoneButtonDisabled)
            )
        }
    }
}

struct InterviewRecordingEndView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewRecordingEndView(viewModel: InterviewRecordViewModel())
    }
}
