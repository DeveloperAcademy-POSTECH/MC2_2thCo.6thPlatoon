//
//  RecordBubble.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI
import UniformTypeIdentifiers

struct RecordBubble: View {
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @StateObject var bubbleManager: InterviewBubbleManager
    @State var record: Record
    @State private var text: String = ""
    @State private var isReadyToPlay: Bool = true
    @State private var isEditing: Bool = false

    let idx: Int

    var isInterviewerSpeaking: Bool {
        record.type == Recorder.interviewer.rawValue
    }
    
    // MARK: - body
    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            if
                let interview = interviewListViewModel.interviewList[safe: idx] {
                if isInterviewerSpeaking {
                    recordBubbleBuilder(with: interview)
                        .padding(.leading, 32)
                    
                    playButtonBuilder(with: interview)
                        .offset(y: -8)
                    
                } else {
                    playButtonBuilder(with: interview)
                        .offset(y: 16)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(interview.details.userName)
                            .fontWeight(.semibold)
                            .font(.subheadline)
                        
                        recordBubbleBuilder(with: interview)
                            .padding(.trailing, 32)
                    }
                    
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
                isInterviewDetailChatEditModalViewDisplayed: $isEditing,
                transcriptIndex: record.transcriptIndex,
                interviewIdx: idx
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
                            isReadyToPlay: $isReadyToPlay
                        )
                    } else {
                        bubbleManager.stopPlayingRecordVoice()
                    }
                } label: {
                    Image(systemName: isReadyToPlay ? "play.fill" : "stop.fill")
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
                .onChange(of: bubbleManager.isReadyToPlay) { newValue in
                    if bubbleManager.isReadyToPlay {
                        self.isReadyToPlay = true
                    }
                }
            }
    }
    
    private func recordBubbleBuilder(with interview: Interview) -> some View {
        VStack {
            Text("\(interview.recordSTT[safe: record.transcriptIndex] ?? "")")
                .font(.system(size: 14))
                .frame(
                    maxWidth: .infinity,
                    minHeight: 44 - 22,
                    alignment: isInterviewerSpeaking
                        ? .trailing
                        : .leading
                )
                .padding(.vertical, 11)
                .padding(.horizontal, 19.5)
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
