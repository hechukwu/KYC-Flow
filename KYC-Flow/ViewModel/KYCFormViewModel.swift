//
//  KYCFormViewModel.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//


import SwiftUI
import Combine

class KYCFormViewModel: ObservableObject {
    @Published var selectedCountryCode: String = "NL"
    @Published var formData: [String: String] = [:]
    @Published var validationErrors: [String: String] = [:]
    @Published var config: CountryKYCConfig?
    @Published var isLoadingNLData = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadConfig()
    }

    func loadConfig() {
        // Load config based on selectedCountryCode from local bundle YAML files
        // For brevity, we'll emulate loading with JSON strings inline here
        switch selectedCountryCode {
        case "NL":
            config = CountryKYCConfig(
                country: "NL",
                fields: [
                    .init(id: "first_name", label: "First Name", type: .text, required: true, validation: nil),
                    .init(id: "last_name", label: "Last Name", type: .text, required: true, validation: nil),
                    .init(id: "bsn", label: "BSN", type: .text, required: true,
                          validation: ValidationRule(regex: #"^\d{9}$"#, message: "BSN must be 9 digits", minLength: nil, maxLength: nil, minValue: nil, maxValue: nil)),
                    .init(id: "birth_date", label: "Birth Date", type: .date, required: true, validation: nil)
                ]
            )
            fetchNLUserProfile()
        case "DE":
            config = CountryKYCConfig(
                country: "DE",
                fields: [
                    .init(id: "first_name", label: "Vorname", type: .text, required: true, validation: nil),
                    .init(id: "last_name", label: "Nachname", type: .text, required: true, validation: nil),
                    .init(id: "steuer_id", label: "Steueridentifikationsnummer", type: .text, required: true,
                          validation: ValidationRule(regex: #"^\d{11}$"#, message: "Muss 11 Ziffern haben", minLength: nil, maxLength: nil, minValue: nil, maxValue: nil)),
                    .init(id: "birth_date", label: "Geburtsdatum", type: .date, required: true, validation: nil)
                ]
            )
            formData = [:]
        default:
            config = nil
            formData = [:]
        }

        // Clear previous errors
        validationErrors = [:]
    }

    func fetchNLUserProfile() {
        isLoadingNLData = true

        // Simulated async fetch with delay (mock API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = [
                "first_name": "Jan",
                "last_name": "Jansen",
                "birth_date": "1985-07-20"
            ]
            self.formData.merge(profile) { _, new in new }
            self.isLoadingNLData = false
        }
    }

    // Validate all fields according to config rules
    func validate() -> Bool {
        var errors: [String: String] = [:]

        guard let fields = config?.fields else {
            return false
        }

        for field in fields {
            let value = formData[field.id, default: ""].trimmingCharacters(in: .whitespaces)

            // Required check
            if field.required && value.isEmpty {
                errors[field.id] = "\(field.label) is required"
                continue
            }

            guard !value.isEmpty else { continue }

            // Regex validation
            if let regexPattern = field.validation?.regex,
               let regex = try? NSRegularExpression(pattern: regexPattern),
               regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) == nil {
                errors[field.id] = field.validation?.message ?? "\(field.label) format is invalid"
                continue
            }

            // Min/Max length (for text)
            if field.type == .text {
                if let minL = field.validation?.minLength, value.count < minL {
                    errors[field.id] = "\(field.label) must be at least \(minL) characters"
                    continue
                }
                if let maxL = field.validation?.maxLength, value.count > maxL {
                    errors[field.id] = "\(field.label) must be at most \(maxL) characters"
                    continue
                }
            }

            // Min/Max value (for numbers)
            if field.type == .number, let doubleVal = Double(value) {
                if let minV = field.validation?.minValue, doubleVal < minV {
                    errors[field.id] = "\(field.label) must be at least \(minV)"
                    continue
                }
                if let maxV = field.validation?.maxValue, doubleVal > maxV {
                    errors[field.id] = "\(field.label) must be at most \(maxV)"
                    continue
                }
            }
        }

        validationErrors = errors
        return errors.isEmpty
    }

    func submit() -> String? {
        guard validate() else { return nil }
        // Return JSON string of formData for summary display
        if let jsonData = try? JSONSerialization.data(withJSONObject: formData, options: .prettyPrinted) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
