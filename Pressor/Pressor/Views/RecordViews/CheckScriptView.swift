//
//  CheckScriptView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/13.
//

import SwiftUI

struct CheckScriptView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var interviewViewModel: InterviewViewModel
    @ObservedObject var voiceViewModel: VoiceViewModel
    @State private var showingEditView = false
    @State private var navigateToEditScriptView = false
    @Binding var scriptAdded: Bool
    let title: String
    let description: String
    
    // 초기화 메서드
    init(interviewViewModel: InterviewViewModel, voiceViewModel: VoiceViewModel, title: String, description: String, scriptAdded: Binding<Bool>) {
        self.interviewViewModel = interviewViewModel
        self.voiceViewModel = voiceViewModel
        self.title = interviewViewModel.script.title
        self.description = interviewViewModel.script.description
        self._scriptAdded = scriptAdded
    }
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    titleText
                    bodyText
                }.scrollContentBackground(.hidden)
                    .background(Color.white)
            }
            .navigationTitle(Text("대본"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    editButton
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // 제목 필드
    private var titleText: some View {
        Text(title)
            .font(.title)
    }
    
    // 본문 필드
    private var bodyText: some View {
        Text(description)
    }
    
    // 취소 버튼
    private var cancelButton: some View {
        Button("취소") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.red)
    }
    
    // 수정 버튼
    private var editButton: some View {
        Menu {
            Button(action: {
                navigateToEditScriptView = true
            }) {
                Label("편집", systemImage: "pencil")
            }
            Button(role: .destructive, action: {
                // 대본 삭제
                scriptAdded = false
                interviewViewModel.setScript(title: "", description: "")
                presentationMode.wrappedValue.dismiss()
            }) {
                Label("삭제", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
        // 네비게이션 링크 동작 버그로 .background 사용
        .background(NavigationLink("", destination: EditScriptView(interviewViewModel: interviewViewModel, showingEditView: $showingEditView, title: title, description: description), isActive: $navigateToEditScriptView))
    }
}
