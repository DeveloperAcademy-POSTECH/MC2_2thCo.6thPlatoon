//
//  InterviewDetailChatEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailChatEditModalView: View {
//    @ObservedObject var recordViewModel: RecordViewModel
    @State private var interviewDescription: String = ""
    @Binding var isInterviewDetailChatEditModalViewDisplayed: Bool
    @FocusState var isTextEditorDisplayed: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextEditor(text: $interviewDescription)
                    .frame(
                        minHeight: UIScreen.main.bounds.height * 0.5,
                        maxHeight: .infinity
                    )
                    .focused($isTextEditorDisplayed)
                    .task {
                        isTextEditorDisplayed = true
                    }
            }
            .navigationTitle("편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        hideKeyboard()
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hideKeyboard()
                        dismiss()
                        // TODO: RECORD TEXT UPDATE HERE
                    } label: {
                        Text("완료")
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onDisappear {
            hideKeyboard()
        }
    }
}

//struct InterviewDetailChatEditModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        InterviewDetailChatEditModalView()
//    }
//}
