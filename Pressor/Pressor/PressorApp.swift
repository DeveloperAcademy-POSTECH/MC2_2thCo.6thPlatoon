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
    var body: some Scene {
        WindowGroup {
            MainRecordView()
                .environmentObject(routeManager)
        }
    }
}
