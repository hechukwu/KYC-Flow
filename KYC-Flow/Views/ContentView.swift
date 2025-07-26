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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Country")) {
                    Picker("Country", selection: $viewModel.selectedCountryCode) {
                        ForEach(viewModel.supportedCountries, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: viewModel.selectedCountryCode) { _ in
                        viewModel.loadConfig()
                    }
                }
                if viewModel.isLoadingUserProfile {
                    Section {
                        Text("Loading user profile...")
                    }
                } else if let config = viewModel.config {
                    Section(header: Text("\(config.country) KYC Form")) {
                        ForEach(config.fields) { field in
                            DynamicFieldView(
                                field: field,
                                value: Binding(
                                    get: { viewModel.formData[field.id, default: ""] },
                                    set: { viewModel.formData[field.id] = $0 }
                                ),
                                error: viewModel.validationErrors[field.id],
                                isReadOnly: viewModel.isReadOnly(field: field)
                            )
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
                    .disabled(viewModel.isLoadingUserProfile)
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
            .onAppear { viewModel.loadConfig() }
        }
    }
}

#Preview {
    ContentView()
}
