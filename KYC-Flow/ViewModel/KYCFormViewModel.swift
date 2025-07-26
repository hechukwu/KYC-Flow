//
//  KYCFormViewModel.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//

import SwiftUI
import Combine
import Yams

class KYCFormViewModel: ObservableObject {
    @Published var selectedCountryCode: String = "NL"
    @Published var formData: [String: String] = [:]
    @Published var validationErrors: [String: String] = [:]
    @Published var config: CountryKYCConfig?
    @Published var isLoadingUserProfile = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let supportedCountries = [("NL", "Netherlands"), ("DE", "Germany"), ("US", "United States")]
    
    init() {
        loadConfig()
    }
    
    func loadConfig() {
        guard let url = Bundle.main.url(forResource: selectedCountryCode, withExtension: "yaml", subdirectory: nil),
              let yamlString = try? String(contentsOf: url, encoding: .utf8),
              let config = try? YAMLDecoder().decode(CountryKYCConfig.self, from: yamlString) else {
            print("Config URL for \(selectedCountryCode) not found!")
            self.config = nil
            self.formData = [:]
            return
        }
        print("Loaded YAML file at: \(url)")

        self.config = config
        self.validationErrors = [:]
        self.formData = [:]
        
        if selectedCountryCode == "NL" && config.fields.contains(where: { $0.data_source == "nl-user-profile" }) {
            fetchNLUserProfile()
        }
    }
    
    func fetchNLUserProfile() {
        isLoadingUserProfile = true
        // Simulate async fetch with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let profile = [
                "first_name": "Jan",
                "last_name": "Jansen",
                "birth_date": "1985-07-20"
            ]
            self.formData.merge(profile) { _, new in new }
            self.isLoadingUserProfile = false
        }
    }
    
    func isReadOnly(field: KYCField) -> Bool {
        return field.readonly ?? false
    }
    
    func validate() -> Bool {
        var errors: [String: String] = [:]
        guard let fields = config?.fields else { return false }
        for field in fields {
            let value = formData[field.id, default: ""].trimmingCharacters(in: .whitespaces)
            // Required
            if field.required && value.isEmpty {
                errors[field.id] = "\(field.label) is required"
                continue
            }
            guard !value.isEmpty else { continue }
            // Regex
            if let pattern = field.validation?.regex,
               let regex = try? NSRegularExpression(pattern: pattern),
               regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) == nil {
                errors[field.id] = field.validation?.message ?? "\(field.label) is invalid"
                continue
            }
            // Text length
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
            // Number range
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
        if let jsonData = try? JSONSerialization.data(withJSONObject: formData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
