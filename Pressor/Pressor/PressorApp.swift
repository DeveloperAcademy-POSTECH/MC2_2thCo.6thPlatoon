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
    @StateObject var voiceViewModel: VoiceViewModel = .init(interview: .getDummyInterview())
    @StateObject var interviewListViewModel: InterviewListViewModel = .init()
    @ObservedObject var permissionManager: PermissionManager = .init()
    
    var body: some Scene {
        WindowGroup {
            MainRecordView(vm: voiceViewModel)
                .environmentObject(routeManager)
                .environmentObject(interviewListViewModel)
                .onAppear {
                    permissionManager.requestAudioPermission()
                    permissionManager.requestRecordingPermission()
                    permissionManager.requestSpeechRecognizerPermission()
                }
        }
    }
}
