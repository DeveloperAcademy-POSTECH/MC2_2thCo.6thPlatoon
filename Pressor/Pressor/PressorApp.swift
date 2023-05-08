//
//  PressorApp.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

@main
struct PressorApp: App {
    @ObservedObject var vm: VoiceViewModel = VoiceViewModel()
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            RecordTestView()
            MainTestView(vm: vm)
        }
    }
}
