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
    @State private var showingEditView = false
    @State private var navigateToEditScriptView = false
    @State private var showingDeleteConfirmationAlert = false
    @Binding var scriptAdded: Bool
    @State var title: String = ""
    @State var description: String = ""
    
    // 초기화 메서드
    init(interviewViewModel: InterviewViewModel, scriptAdded: Binding<Bool>) {
        self.interviewViewModel = interviewViewModel
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
            .onAppear {
                title = interviewViewModel.script.title
            }
    }
    
    // 본문 필드
    private var bodyText: some View {
        Text(description)
            .onAppear {
                description = interviewViewModel.script.description
            }
    }
    
    // 취소 버튼
    private var cancelButton: some View {
        Button("취소") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.accentColor)
    }
    
    // 수정 버튼
    private var editButton: some View {
        HStack {
            NavigationLink(destination: EditScriptView(interviewViewModel: interviewViewModel, showingEditView: $showingEditView, title: title, description: description), isActive: $navigateToEditScriptView) {
                EmptyView()
            }
            Menu {
                Button(action: {
                    navigateToEditScriptView = true
                }) {
                    Label("편집", systemImage: "pencil")
                }
                Button(role: .destructive, action: {
                    showingDeleteConfirmationAlert = true
                }) {
                    Label("삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle").foregroundColor(.accentColor)
            }
        }
        .alert(isPresented: $showingDeleteConfirmationAlert) {
            Alert(title: Text("대본 삭제"), message: Text("정말로 대본을 삭제하시겠습니까?"),
                  primaryButton: .destructive(Text("삭제")) {
                scriptAdded = false
                interviewViewModel.setScript(title: "", description: "")
                presentationMode.wrappedValue.dismiss()
            },
                  secondaryButton: .cancel(Text("취소"))
            )
        }
    }
}
