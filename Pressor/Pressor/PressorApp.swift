//
//  PressorApp.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

@main
struct PressorApp: App {
    @StateObject var routeManager: RoutingManager = .init()
    @StateObject var voiceViewModel: VoiceViewModel = .init(interview: .getInitInterview())
    @StateObject var interviewListViewModel: InterviewListViewModel = .init()
    @ObservedObject var permissionManager: PermissionManager = .init()
    
    var body: some Scene {
        WindowGroup {
            MainRecordView()
                .environmentObject(routeManager)
                .environmentObject(interviewListViewModel)
                .environmentObject(voiceViewModel)
                .onAppear {
                    permissionManager.requestAudioPermission()
                    permissionManager.requestRecordingPermission()
                    permissionManager.requestSpeechRecognizerPermission()
                    voiceViewModel.initInterview()
                }
                .onChange(of: voiceViewModel.isSTTCompleted) { newValue in
                    if newValue {
                        let completedArray = voiceViewModel.getTranscribeArray()
                        interviewListViewModel.completedInterview.recordSTT = completedArray
                        if
                            let index = interviewListViewModel.interviewList.firstIndex(of: interviewListViewModel.completedInterview) {
                            interviewListViewModel.interviewList[index] = interviewListViewModel.completedInterview
                            voiceViewModel.isSTTCompleted = false
                        }
                    }
                }
                .onChange(of: interviewListViewModel.isUpdatingDetails) { newValue in
                    if newValue {
                        interviewListViewModel.updateInterviewDetails()
                    }
                }
        }
    }
}
