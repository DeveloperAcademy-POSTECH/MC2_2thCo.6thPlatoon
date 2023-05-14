//
//  InterviewDetailView.swift
//  Pressor
//
//  Created by Celan on 2023/05/09.
//

import SwiftUI
import CoreTransferable
import AVFoundation

struct InterviewDetailView: View {
    @StateObject var interviewBubbleManager: InterviewBubbleManager
    
    @State private var isEditing: Bool = false
    @State private var isInterviewInfoEditing: Bool = false
    @State private var isWholeRecordPlaying: Bool = false
    @State private var isRemovingInterview: Bool = false
    @State private var transferableScripts: String = ""
    
    @State private var wholeRecordPlayTime: CGFloat = 0
    @State private var currentTime: CGFloat = 0
    @State private var currentRecordIndex: Int = 0
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            ScrollView {
                if
                    let interview = interviewBubbleManager.currentInterview {
                    LazyVStack {
                        Section {
                            ForEach(interview.records, id: \.id) { eachRecord in
                                // TODO: DI ViewModel, Record
                                RecordBubble(
                                    bubbleManager: interviewBubbleManager,
                                    record: eachRecord,
                                    isEditing: $isEditing
                                )
                            }
                        } header: {
                            InterviewInfoHeader(with: interview)
                                .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, UIScreen.main.bounds.height * 0.2)
                }
            }
        }
        .overlay(alignment: .bottom) {
            // TODO: Not Completed
//                AudioPlayerBuilder(with: interview)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            // MARK: SET SLIDER THUMB IMAGE
            UISlider.appearance().setThumbImage(
                .init(systemName: "circlebadge.fill"),
                for: .normal
            )
            
            // TODO: GET Record List Here
            makeTransferableScripts()
        }
        .navigationTitle("\(interviewBubbleManager.currentInterview.details.interviewTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // TODO: CRASH ERROR, ASK TO MENTOR
                    if
                        let interview = interviewBubbleManager.currentInterview {
                        ShareLink(
                            item: transferableScripts,
                            subject: Text("\(interview.details.interviewTitle) 인터뷰 스크립트 보내기"),
                            message: Text("'\(interview.details.interviewTitle)' 인터뷰의 스크립트")
                        ) {
                            Label(
                                "공유하기",
                                systemImage: "square.and.arrow.up"
                            )
                        }
                        
                        Button(role: .destructive) {
                            isRemovingInterview.toggle()
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(isPresented: $isRemovingInterview) {
            Alert(
                title: Text("\(interviewBubbleManager.currentInterview.details.interviewTitle)을 삭제하시겠습니까?"),
                message: Text("이 동작은 취소되지 않습니다."),
                primaryButton: .default(
                    Text("취소하기")
                ),
                secondaryButton: .destructive(
                    Text("삭제하기")
                ) {
                    // TODO: REMOVE INTERVIEW CRUD HERE
                    print("\(#filePath) L: \(#line) REMOVE INTERVIEW CRUD HERE")
                }
            )
        }
    }
    
    
    // MARK: METHODS
    private func InterviewInfoHeader(with interview: Interview) -> some View {
        VStack {
            VStack {
                VStack(spacing: 12) {
                    HStack {
                        Text(interview.details.interviewTitle)
                            .bold()
                        Spacer()
                        NavigationLink {
                            InterviewDetailEditModalView(
                                interviewBubbleManager: interviewBubbleManager,
                                isDetailChanging: .constant(true)
                            )
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .tint(Color.pressorRed)
                    }
                    
                    HStack {
                        Text(interview.details.date.toString(dateFormat: "yyyy-MM-dd HH:MM"))
                        Spacer()
                        Text(interview.details.playTime.description)
                    }
                    .bold()
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray2))
                }
                
                Divider()
                    .padding(.vertical, 7.5)
                
                // MARK: Interview Infos
                HStack(spacing: 28) {
                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {
                        HStack {
                            Text("Name")
                        }
                        
                        if
                            let interview = interviewBubbleManager.currentInterview {
                            if !interview.details.userEmail.isEmpty {
                                HStack {
                                    Text("Email")
                                }
                            }
                            
                            if !interview.details.userPhoneNumber.isEmpty {
                                HStack {
                                    Text("Phone")
                                }
                            }
                        }
                    }
                    .bold()
                    .foregroundColor(Color(.systemGray2))
                    
                    VStack(
                        alignment: .leading,
                        spacing: 5
                    ) {
                        HStack {
                            Text(interview.details.userName)
                                .bold()
                        }
                        
                        if
                            let interview = interviewBubbleManager.currentInterview {
                            if !interview.details.userEmail.isEmpty {
                                HStack {
                                    Text(interview.details.userEmail)
                                }
                            }
                            
                            if !interview.details.userPhoneNumber.isEmpty {
                                HStack {
                                    Text(interview.details.userPhoneNumber)
                                }
                            }
                        }
                    }
                }
                .font(.callout)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
        .padding()
        // MARK: Sketch는 한 줄 이상을 받아오는 시나리오가 없기에 각 정보는 한 줄로 보여지도록 제한합니다.
        .lineLimit(1)
        .frame(
            width: UIScreen.main.bounds.width * 0.925
        )
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.pressorSystemGray)
        }
    }
    
    private func makeTransferableScripts() {
        for idx in 0 ..< interviewBubbleManager.currentInterview.recordSTT.count {
            let num = idx + 1
            if idx % 2 == 0 {
                // 먼저 질문하는 사람이 인터뷰어가 된다.
                self.transferableScripts += (num.description + "." + "인터뷰어: " + interviewBubbleManager.currentInterview.recordSTT[idx] + "\n")
            } else {
                self.transferableScripts += (num.description + "." + "\(interviewBubbleManager.currentInterview.details.userName) 님: " + interviewBubbleManager.currentInterview.recordSTT[idx] + "\n")
            }
        }
    }
    
    @ViewBuilder
    private func AudioPlayerBuilder(with interview: Interview) -> some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .background {
                    BlurBackground()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: UIScreen.main.bounds.height * 0.2
                )
            
            VStack {
                // MARK: PLAY PROGRESS
                // SLIDER....
                VStack(spacing: 0) {
                    Slider(
                        value: $interviewBubbleManager.progress,
                        in: 0 ... CGFloat(interviewBubbleManager.progress)
                    )
                    
                    HStack {
                        Text("\(currentTime.description)")
                        Spacer()
                        Text(interview.details.playTime)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // MARK: PLAY BUTTONS
                HStack(spacing: 40) {
                    Button {
                        isWholeRecordPlaying.toggle()
                        
                        // MARK: Start PLAY and Get Each Record's TimeInterval
                        interviewBubbleManager.startPlayingRecordVoice(
                            url: interview.records[currentRecordIndex].fileURL,
                            isPlaying: $isWholeRecordPlaying
                        )
                    } label: {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.clear)
                            .overlay {
                                Image(systemName: isWholeRecordPlaying ? "stop.fill" : "play.fill")
                                    .font(.title3)
                            }
                    }
                    
                    Button {
                        print("\(#file) L: \(#line) Play Next")
                    } label: {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.clear)
                            .overlay {
                                Image(systemName: "forward.end.alt.fill")
                                    .font(.title3)
                            }
                        
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 24)
            }
            .tint(.pressorRed)
        }
    }
}

struct InterviewDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InterviewDetailView(
                interviewBubbleManager: .init(
                    currentInterview: .getDummyInterview()
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
