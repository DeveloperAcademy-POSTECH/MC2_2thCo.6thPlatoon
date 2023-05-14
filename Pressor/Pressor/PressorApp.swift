//
//  PressorApp.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

@main
struct PressorApp: App {
    @ObservedObject var routeManager: RoutingManager = .init()
    @ObservedObject var voiceViewModel: VoiceViewModel = .init(interview: .getDummyInterview())
    
    var body: some Scene {
        WindowGroup {
            MainRecordView(vm: voiceViewModel)
                .environmentObject(routeManager)
        }
    }
}
