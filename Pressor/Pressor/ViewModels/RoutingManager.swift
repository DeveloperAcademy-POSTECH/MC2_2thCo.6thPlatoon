//
//  RoutingManager.swift
//  Pressor
//
//  Created by Celan on 2023/05/11.
//

import SwiftUI

final class RoutingManager: ObservableObject {
    @Published var currentTab: String = Constants.RECORD_TAB_ID
    @Published var isRecordViewDisplayed: Bool = false
}
