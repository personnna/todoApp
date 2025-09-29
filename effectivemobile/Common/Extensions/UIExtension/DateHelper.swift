//
//  DateHelper.swift
//  effectivemobile
//
//  Created by ellkaden on 29.09.2025.
//

import Foundation

extension DateFormatter {
    static let appDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        // ✅ ВАШ НУЖНЫЙ ФОРМАТ: "23 / 09 / 2025 15:30"
        formatter.dateFormat = "dd / MM / yyyy HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}
