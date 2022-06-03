//
//  File.swift
//  
//
//  Created by Alex Shipin on 03.04.2022.
//

import Foundation

extension String {
    func safe() throws -> String {
        guard let data = try? JSONEncoder().encode(self), var text = String(data: data, encoding: .utf8) else {
            throw Errors.sqlError.description("Ошибка экаранирования символов", error: nil)
        }
        text = text.replacingOccurrences(of: "'", with: "\\'")
        text.removeFirst()
        text.removeLast()
        return text
    }
}
