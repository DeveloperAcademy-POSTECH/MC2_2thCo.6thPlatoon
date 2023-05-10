//
//  RecordBubble.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI
import UniformTypeIdentifiers

/**
 인터뷰의 내용과 음성 컨트롤러를 담는 레코드 버블 입니다.
 해당 뷰는 반드시 "스크롤뷰 내부"에서 호출합니다.
 
 - Author: Celan
 */
struct RecordBubble: View {
    @ObservedObject var voiceViewModel: VoiceViewModel
    @State var record: Record
    @State var interview: Interview
    @State private var text: String = ""
    @Binding var isEditing: Bool

    var body: some View {
        HStack(spacing: 10) {
            if record.type == Recorder.interviewer.rawValue {
                playButtonBuilder()
                
                recordBubbleBuilder()
                    .contextMenu {
                        contextMenuButtonBuilder()
                    }
            } else {
                recordBubbleBuilder()
                    .contextMenu {
                        contextMenuButtonBuilder()
                    }
                
                playButtonBuilder()
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 8)
        .sheet(isPresented: $isEditing) {
            InterviewDetailChatEditModalView(isInterviewDetailChatEditModalViewDisplayed: $isEditing)
        }
    }
    
    // MARK: - Builders
    private func playButtonBuilder() -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 44, height: 44)
            .overlay(alignment: .center) {
                Button {
                    // TODO: - Play or Stop
                } label: {
                    Image(systemName: "play.fill")
                }
                .frame(width: 34, height: 34)
                .background(Color.yellow)
                .clipShape(Circle())
            }
            .padding(.leading, 45)
    }
    
    private func recordBubbleBuilder() -> some View {
        VStack {
            if isEditing {
                TextField("", text: $text)
                    .font(.system(size: 14))
                    .frame(
                        maxWidth: 278 - 39,
                        minHeight: 44 - 22,
                        alignment: .trailing
                    )
                    .padding(.vertical, 11)
                    .padding(.horizontal, 19.5)
            } else {
                Text("\(interview.recordSTT[record.transcriptIndex])")
                Text("temp")
                    .font(.system(size: 14))
                    .frame(
                        maxWidth: 278 - 39,
                        minHeight: 44 - 22,
                        alignment: .trailing
                    )
                    .padding(.vertical, 11)
                    .padding(.horizontal, 19.5)
            }
            
        }
        .background(Color.orange)
        .clipShape(Bubble(record: record))
        .frame(
            maxWidth: .infinity,
            alignment: .trailing
        )
    }
    
    @ViewBuilder
    private func contextMenuButtonBuilder() -> some View {
        Button {
            self.pasteToClipboard(with: interview.recordSTT[record.transcriptIndex])
        } label: {
            Label("복사", systemImage: "doc.on.doc")
        }
        
        Button {
            withAnimation {
                isEditing.toggle()
            }
        } label: {
            Label("편집", systemImage: "square.and.pencil")
        }
    }
    
    // MARK: - METHODS
    /**
     Clipboard로 복사하는 메소드입니다.
     완료되는 시점에 뷰에 복사 완료를 알리는 알람을 띄웁니다. <- Todo
     */
    private func pasteToClipboard(with str: String) {
        UIPasteboard.general.setValue(
            str,
            forPasteboardType: UTType.plainText.identifier
        )
    }
}

struct Bubble: Shape {
    var record: Record
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners:
                record.type == Recorder.interviewer.rawValue
                ? [.topLeft, .bottomLeft, .bottomRight]
                : [.topRight, .bottomRight, .bottomLeft]
            ,
            cornerRadii: CGSize(
                width: 20,
                height: 20
            )
        )
        
        return Path(path.cgPath)
    }
}

struct RecordBubble_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
//            RecordBubble(record: .init(recordDescription: "하이하이"), index: 0, isInterviewer: true)
//            RecordBubble(record: .init(recordDescription: "안녕안녕"), index: 1, isInterviewer: false)
//            RecordBubble(record: .init(recordDescription: "바이바이"), index: 0, isInterviewer: true)
//            RecordBubble(record: .init(recordDescription: "그래그래"), index: 2, isInterviewer: false)
        }
    }
}
