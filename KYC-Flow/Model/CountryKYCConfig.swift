//
//  CountryKYCConfig.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//


import SwiftUI
import Combine

// MARK: - Models
struct CountryKYCConfig: Codable {
    let country: String
    let fields: [KYCField]
}

struct KYCField: Codable, Identifiable {
    let id: String
    let label: String
    let type: FieldType
    let required: Bool
    let readonly: Bool?
    let data_source: String?
    let validation: ValidationRule?
    
    enum FieldType: String, Codable {
        case text, number, date
    }
}

struct ValidationRule: Codable {
    let regex: String?
    let message: String?
    let minLength: Int?
    let maxLength: Int?
    let minValue: Double?
    let maxValue: Double?
}
