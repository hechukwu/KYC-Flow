//
//  DynamicFieldView.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//


import SwiftUI

struct DynamicFieldView: View {
    let field: KYCField
    @Binding var value: String
    let error: String?
    let isReadOnly: Bool

    var body: some View {
        VStack(alignment: .leading) {
            switch field.type {
            case .text:
                TextField(field.label, text: $value)
                    .disabled(isReadOnly)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            case .number:
                TextField(field.label, text: $value)
                    .keyboardType(.numberPad)
                    .disabled(isReadOnly)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            case .date:
                DatePicker(field.label, selection: Binding<Date>(
                    get: {
                        Date.kycDateFormatter.date(from: value) ?? Date()
                    },
                    set: {
                        value = Date.kycDateFormatter.string(from: $0)
                    }
                ), displayedComponents: .date)
                .disabled(isReadOnly)
            }
            if let errorMsg = error {
                Text(errorMsg).foregroundColor(.red).font(.caption)
            }
        }
        .padding(.vertical, 5)
    }
}
