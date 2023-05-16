//
//  InterviewListViewModel.swift
//  Pressor
//
//  Created by Celan on 2023/05/15.
//

import SwiftUI

final class InterviewListViewModel: ObservableObject {
    @AppStorage(Constants.USERDEFAULTS_INTERVIEWS_KEY) var interviewList: [Interview] = []
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
}
