//
//  EditInterviewScriptTestView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/10.
//

import SwiftUI

struct EditInterviewScriptTestView: View {
    @ObservedObject var viewModel: InterviewViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var content: String
    let index: Int
    
    init(viewModel: InterviewViewModel, index: Int, updatedTitle: String, updatedContent: String) {
        self.viewModel = viewModel
        self._title = State(wrappedValue: updatedTitle)
        self._content = State(wrappedValue: updatedContent)
        self.index = index
    }
    
    var body: some View {
        VStack {
            TextField("Enter title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter content", text: $content)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                viewModel.updateScript(title: title, content: content, atIndex: index)
                        presentationMode.wrappedValue.dismiss()
            }) {
                Text("Update Interview Script")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Interview Script")
    }
}
