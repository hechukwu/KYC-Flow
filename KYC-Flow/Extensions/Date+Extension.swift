//
//  Date+Extension.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//


import Foundation

extension Date {
    static let kycDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.calendar = Calendar(identifier: .iso8601)
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
}
