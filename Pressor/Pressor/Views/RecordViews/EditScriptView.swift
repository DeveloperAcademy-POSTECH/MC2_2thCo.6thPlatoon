//
//  EditScriptView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/12.
//

import SwiftUI

struct EditScriptView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var interviewViewModel: InterviewViewModel
    @Binding var showingEditView: Bool
    @State var title: String
    @State var description: String

    // 초기화 메서드
    init(interviewViewModel: InterviewViewModel, showingEditView: Binding<Bool>, title: String, description: String) {
            self.interviewViewModel = interviewViewModel
            _showingEditView = showingEditView
            _title = State(initialValue: title)
            _description = State(initialValue: description)
        }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    inputSection
                }
            }
            .navigationTitle(Text("대본 편집"))
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
        .navigationBarBackButtonHidden(true)
    }

    // 입력 섹션
    private var inputSection: some View {
        Section {
            titleTextField
            bodyTextEditor
        }
    }

    // 제목 입력 필드
    private var titleTextField: some View {
        TextField("제목", text: $title)
    }

    // 본문 입력 에디터
    private var bodyTextEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $description)
                .padding(.leading, -4)
            
            if description.isEmpty {
                // 본문이 비어있을 때만 "본문" 텍스트 표시
                Text("본문")
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.leading, -2)
            }
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
                interviewViewModel.setScript(title: title, description: description)
            showingEditView = false
            presentationMode.wrappedValue.dismiss()
        }
        // 제목과 본문을 입력하지 않은 경우, "완료" 버튼 비활성화
        .foregroundColor(.red)
    }
}
