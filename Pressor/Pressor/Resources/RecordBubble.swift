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
    @ObservedObject var bubbleManager: InterviewBubbleManager
    @State var record: Record
    @State private var text: String = ""
    @State private var isReadyToPlay: Bool = false
    @Binding var isEditing: Bool

    var isInterviewerSpeaking: Bool {
        record.type == Recorder.interviewer.rawValue
    }
    
    // MARK: - body
    var body: some View {
        HStack(spacing: 10) {
            if
                let interview = bubbleManager.currentInterview {
                if isInterviewerSpeaking {
                    playButtonBuilder(with: interview)
                    
                    recordBubbleBuilder(with: interview)
                } else {
                    recordBubbleBuilder(with: interview)
                       
                    playButtonBuilder(with: interview)
                }
            }
        }
        .padding(
            isInterviewerSpeaking
            ? .trailing
            : .leading,
            16
        )
        .padding(.bottom, 8)
        .sheet(isPresented: $isEditing) {
            InterviewDetailChatEditModalView(
                interviewBubbleManager: bubbleManager,
                record: record,
                isInterviewDetailChatEditModalViewDisplayed: $isEditing
            )
        }
    }
    
    // MARK: - Builders
    private func playButtonBuilder(with interview: Interview) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 44, height: 44)
            .overlay(alignment: .center) {
                Button {
                    // TODO: - Play or Stop
                    if isReadyToPlay {
                        bubbleManager.startPlayingRecordVoice(
                            url: record.fileURL,
                            isPlaying: $isReadyToPlay
                        )
                    } else {
                        bubbleManager.stopPlayingRecordVoice(isPlaying: $isReadyToPlay)
                    }
                } label: {
                    Image(systemName: isReadyToPlay ? "stop.fill" : "play.fill")
                        .foregroundColor(
                            isInterviewerSpeaking
                            ? .pressorButtonOrangePrimary
                            : .pressorButtonBluePrimary
                        )
                }
                .frame(width: 34, height: 34)
                .background(
                    isInterviewerSpeaking
                    ? Color.pressorButtonOrangeBackground
                    : Color.pressorButtonBlueBackground
                )
                .clipShape(Circle())
            }
            .padding(
                isInterviewerSpeaking
                ? .leading
                : .trailing,
                45
            )
    }
    
    private func recordBubbleBuilder(with interview: Interview) -> some View {
        VStack {
            if isEditing {
                TextField("", text: $text)
                    .font(.system(size: 14))
                    .frame(
                        maxWidth: 278 - 39,
                        minHeight: 44 - 22,
                        alignment: isInterviewerSpeaking
                            ? .trailing
                            : .leading
                    )
                    .padding(.vertical, 11)
                    .padding(.horizontal, 19.5)
            } else {
                Text("\(interview.recordSTT[safe: record.transcriptIndex] ?? "")")
                    .font(.system(size: 14))
                    .frame(
                        maxWidth: 278 - 39,
                        minHeight: 44 - 22,
                        alignment: isInterviewerSpeaking
                            ? .trailing
                            : .leading
                    )
                    .padding(.vertical, 11)
                    .padding(.horizontal, 19.5)
            }
        }
        .background(
            isInterviewerSpeaking
            ? Color.PressorOrange_Light
            : Color.PressorBlue_Light
        )
        .frame(
            maxWidth: .infinity,
            alignment: isInterviewerSpeaking ? .trailing : .leading
        )
        .clipShape(Bubble(isInterviewerSpeaking: isInterviewerSpeaking))
        .contextMenu {
            contextMenuButtonBuilder(with: interview)
        }
    }
    
    @ViewBuilder
    private func contextMenuButtonBuilder(with interview: Interview) -> some View {
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
    let isInterviewerSpeaking: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners:
                isInterviewerSpeaking
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
