//
//  Record.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import Foundation

struct Record: Codable {
    var id: String = UUID().uuidString
    var fileURL : URL
    var createdAt : Date
    var type: String
    var isPlaying : Bool
    var transcriptIndex: Int
}
