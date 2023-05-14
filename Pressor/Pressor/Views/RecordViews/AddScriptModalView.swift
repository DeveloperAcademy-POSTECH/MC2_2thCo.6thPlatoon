//
// AddScriptModalView.swift
// Pressor
//
// Created by Ha Jong Myeong on 2023/05/09.
//

import SwiftUI

// 스크립트 추가 및 수정 모드 전환을 위한 열거형
enum ScriptMode {
    case add
    case edit
}

struct AddScriptModalView: View {
    // 화면 전환을 관리하는 presentationMode를 사용하여 모달 창을 닫을 수 있도록 하는 변수
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var interviewViewModel: InterviewViewModel
    // 외부에서 전달된 scriptAdded를 바인딩하여 완료 버튼을 눌렀을 때 업데이트
    @Binding var scriptAdded: Bool
    
    @State private var title: String
    @State private var description: String
    
    // 뷰의 모드를 결정하는 변수
    let mode: ScriptMode
    
    // 초기화 메서드
    init(interviewViewModel: InterviewViewModel, scriptAdded: Binding<Bool>, title: String, description: String, mode: ScriptMode) {
        self.interviewViewModel = interviewViewModel
        _scriptAdded = scriptAdded
        _title = State(initialValue: title)
        _description = State(initialValue: description)
        self.mode = mode
    }
    
    // 메인 뷰
    var body: some View {
        NavigationView {
            Form {
                inputSection
            }
            .navigationBarTitle(mode == .add ? "대본 추가" : "대본 수정", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
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
                .frame(height: 270)
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
        Button(mode == .add ? "완료" : "수정") {
            if isInputValid() {
                switch mode {
                case .add:
                    interviewViewModel.setScript(title: title, description: description)
                case .edit:
                    interviewViewModel.setScript(title: title, description: description)
                }
                // 제목과 본문을 입력한 경우, scriptAdded를 true로 설정하고 모달 창 종료
                scriptAdded = true
                presentationMode.wrappedValue.dismiss()
            }
        }
        // 제목과 본문을 입력하지 않은 경우, "완료" 버튼 비활성화
        .foregroundColor(isInputValid() ? .red : .gray)
        .disabled(!isInputValid())
    }
}

private extension AddScriptModalView {
    // 제목과 본문을 입력했는지 확인하는 함수
    func isInputValid() -> Bool {
        return !title.isEmpty && !description.isEmpty
    }
}
