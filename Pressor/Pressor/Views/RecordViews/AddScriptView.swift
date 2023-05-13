//
//  AddScriptView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/12.
//

import SwiftUI

struct AddScriptView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var interviewViewModel: InterviewViewModel
    @Binding var scriptAdded: Bool
    @State var title: String = ""
    @State var description: String = ""
    
    // 초기화 메서드
    init(interviewViewModel: InterviewViewModel, scriptAdded: Binding<Bool>) {
        self.interviewViewModel = interviewViewModel
        _scriptAdded = scriptAdded
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    inputSection
                }.scrollContentBackground(.hidden)
                    .background(Color.white)
            }
            .navigationTitle(Text("대본 추가"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
        }
    }
    
    // 입력 섹션
    private var inputSection: some View {
        Section {
            titleTextField
            bodyTextEditor
        }.listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    // 제목 입력 필드
    private var titleTextField: some View {
        ZStack(alignment: .leading) {
            if title.isEmpty {
                Text("제목")
                    .foregroundColor(.gray)
            }
            TextField("", text: $title)
        }
    }
    
    // 본문 입력 에디터
    private var bodyTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if description.isEmpty {
                Text("본문")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.leading, -2)
            }
            TextEditor(text: $description)
                .frame(height: 270)
                .padding(.leading, -4)
        }
    }
    
    // 취소 버튼
    private var cancelButton: some View {
        Button("취소") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.red)
    }
    
    // 완료 버튼
    private var doneButton: some View {
        Button("완료") {
            if isInputValid() {
                interviewViewModel.setScript(title: title, description: description)
            }
            // 제목과 본문을 입력한 경우, scriptAdded를 true로 설정하고 현재 창 종료
            scriptAdded = true
            presentationMode.wrappedValue.dismiss()
        }
        // 제목과 본문을 입력하지 않은 경우, "완료" 버튼 비활성화
        .foregroundColor(isInputValid() ? .red : .gray)
        .disabled(!isInputValid())
    }
}

private extension AddScriptView {
    // 제목과 본문을 입력했는지 확인하는 함수
    func isInputValid() -> Bool {
        return !title.isEmpty && !description.isEmpty
    }
}
