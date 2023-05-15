//
//  UserDefaults+.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/15.
//

import Foundation

extension UserDefaults {

    // MARK: 예시코드 - UserDefaults.standard.set(codable: interview, forKey: "interview")
    func set<T: Encodable>(codable: T, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codable)
            let jsonString = String(data: data, encoding: .utf8)!
            print("Saving \"\(key)\": \(jsonString)")
            self.set(jsonString, forKey: key)
        } catch {
            print("Saving \"\(key)\" failed: \(error)")
        }
    }

    // MARK: 예시코드 - UserDefaults.standard.codable(Interview.self, forKey: "interview")
    func codable<T: Decodable>(_ codable: T.Type, forKey key: String) -> T? {
        guard let jsonString = self.string(forKey: key) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        print("Loading \"\(key)\": \(jsonString)")
        return try? decoder.decode(codable, from: data)
    }
}
