//
//  CountryKYCConfig.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//


import SwiftUI
import Combine

// MARK: - Models
struct CountryKYCConfig: Decodable {
    let country: String
    let fields: [KYCField]
}

struct KYCField: Decodable, Identifiable {
    let id: String
    let label: String
    let type: FieldType
    let required: Bool
    let validation: ValidationRule?

    enum FieldType: String, Decodable {
        case text, number, date
    }
}

struct ValidationRule: Decodable {
    let regex: String?
    let message: String?
    let minLength: Int?
    let maxLength: Int?
    let minValue: Double?
    let maxValue: Double?
}
