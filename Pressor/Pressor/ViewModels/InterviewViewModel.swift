
//
//  InterviewViewModel.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/05.
//

import Foundation

class InterviewViewModel: ObservableObject {
    // Current script
    @Published var script: Script
    
    // VoiceViewModel
    @Published var voiceViewModel: VoiceViewModel

    // Default initializer
    init(voiceViewModel: VoiceViewModel) {
        self.voiceViewModel = voiceViewModel
        self.script = Script(title: "", description: "")
    }
    
    // 대본 수정(추가, 삭제 - 공백으로 바꿀 경우)
    func setScript(title: String, description: String) {
        self.script = Script(title: title, description: description)
        voiceViewModel.interview.script = script
    }
    
    // 대본 가져오기
    func getScript() -> Script {
        return self.script
    }
}
