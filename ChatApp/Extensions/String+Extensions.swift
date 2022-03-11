//
//  String+Extensions.swift
//  ChatApp
//
//  Created by Tino on 2/2/2022.
//

import CryptoKit

extension String {
    func trim() -> Self {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var hashString: Self? {
        guard let stringData = self.data(using: .utf8) else { return nil }
        let hashData = SHA256.hash(data: stringData)
        let hashString = hashData.compactMap { letter in
            String(format: "%02x", letter)
        }
        .joined()
        return hashString
    }
}
