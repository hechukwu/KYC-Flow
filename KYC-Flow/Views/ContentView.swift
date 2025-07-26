//
//  ContentView.swift
//  KYC-Flow
//
//  Created by Henry Chukwu on 26/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = KYCFormViewModel()
    @State private var showJSONSummary = false
    @State private var jsonOutput = ""

    // Supported countries for selection
    let countries = [("NL", "Netherlands"), ("DE", "Germany")]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Country")) {
                    Picker("Country", selection: $viewModel.selectedCountryCode) {
                        ForEach(countries, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.selectedCountryCode) {
                        viewModel.loadConfig()
                    }
                }

                if viewModel.isLoadingNLData {
                    Section {
                        Text("Loading NL user profile...")
                    }
                } else if let config = viewModel.config {
                    Section(header: Text("\(config.country) KYC Form")) {
                        ForEach(config.fields) { field in
                            DynamicFieldView(field: field,
                                             value: Binding(get: {
                                                 viewModel.formData[field.id, default: ""]
                                             }, set: {
                                                 viewModel.formData[field.id] = $0
                                             }),
                                             error: viewModel.validationErrors[field.id],
                                             isReadOnly: isNLReadOnlyField(field: field))
                        }
                    }
                }

                Section {
                    Button("Submit") {
                        if let json = viewModel.submit() {
                            jsonOutput = json
                            showJSONSummary = true
                        }
                    }
                    .disabled(viewModel.isLoadingNLData)
                }
            }
            .navigationTitle("KYC Form")
            .sheet(isPresented: $showJSONSummary) {
                VStack(alignment: .leading) {
                    Text("Form Data JSON")
                        .font(.headline)
                        .padding()
                    ScrollView {
                        Text(jsonOutput)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                    }
                    Button("Close") {
                        showJSONSummary = false
                    }.padding()
                }
            }
        }
    }

    func isNLReadOnlyField(field: KYCField) -> Bool {
        if viewModel.selectedCountryCode == "NL" {
            // NL-specific read-only fields
            return ["first_name", "last_name", "birth_date"].contains(field.id)
        }
        return false
    }
}

#Preview {
    ContentView()
}
