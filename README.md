# KYC-Flow
This project demonstrates a dynamic, configuration-driven "Know Your Customer" (KYC) form system for a global investment app. The form adapts based on country-specific requirements defined in external YAML configuration files. It features dynamic form rendering, robust input validation, and special-case handling for the Netherlands (NL), where certain fields are read-only and fetched from a mocked API.

## 🚀  Getting Started 
#### 1. Requirements
- Xcode 16+ (tested with Swift 5.5+)
- iOS 18+ or Swift Playground (with SwiftUI support)
- Yams (YAML parsing library) added via Swift Package Manager (see below)

#### 2. Running the App
- ##### Xcode Project:
  1. Clone the repository.
  2. Open .xcodeproj in Xcode.
  3. Build and run on Simulator or device.

#### 3. YAML Config Files
- Country KYC forms are defined in YAML files found in configs/.
- To add or change country requirements, simply edit or add the corresponding YAML file.

## 🌍 Features
- Country selector (NL, DE, US; easily extensible to others)
- Loads KYC configuration from per-country YAML file
- Dynamically renders each form field (text, number, date)
- Handles field-level validation with inline error messages:
  - Required fields
  - Regex patterns and custom error messages
  - Minimum/maximum length (for text)
  - Minimum/maximum value (for numbers)
- Submission outputs form data as formatted JSON
- Special NL Handling: Certain fields (first_name, last_name, birth_date) are fetched from a simulated API and displayed as read-only

## 📝 Example Config Files (YAML)
##### 🇳🇱 configs/NL.yaml
```country: NL
fields:
  - id: first_name
    label: First Name
    type: text
    required: true
    readonly: true
    data_source: nl-user-profile
  - id: last_name
    label: Last Name
    type: text
    required: true
    readonly: true
    data_source: nl-user-profile
  - id: bsn
    label: BSN
    type: text
    required: true
    validation:
      regex: '^\d{9}$'
      message: 'BSN must be 9 digits'
  - id: birth_date
    label: Birth Date
    type: date
    required: true
    readonly: true
    data_source: nl-user-profile
```

## 🏗 Architectural Overview
- Country Selection: Implemented via SwiftUI Picker, updating the form's configuration.
- Configuration Source: All configs loaded at runtime from Resources/Config/[COUNTRY].yaml using Yams.
- Dynamic Rendering: Fields rendered based on config; form and validation rules fully data-driven.
- Validation: Performed in the ViewModel, errors are shown inline.
- SSubmission: On valid submit, data shown as JSON.
- Special Sources/Readonly: Uses config’s readonly and data_source keys.

#### 🇳🇱 NL: Mocked API/Readonly Fields
- When a field in the config specifies data_source: nl-user-profile, the app simulates loading its value asynchronously, and shows that field as read-only (via readonly: true in config).
- For other countries, the fields are user-editable.

## 🧪 Mocked API
swift
```
func fetchNLUserProfile() {
    isLoadingUserProfile = true
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
```
No network is used; this fetch is simulated.

## 🧩 Extending for More Countries & Flexible Configs
To add a country:
- Copy an existing config YAML as a template,
- Change country: and the fields/validations as needed,
- Save as [NEW_CODE].yaml under configs/,
- No code change required.

#### Recommendation: Config Format Enhancement
Currently, configs lack the ability to specify that a field should be read-only or have its source indicated (“external API”), This has been addressed for fututre scalability see *Proposed Config Format* below:

#### Proposed Config Format
Added optional config keys:
readonly: true — Marks the field as read-only in the UI.
data_source: "nl-user-profile" — Indicates this field’s value comes from a particular API or source.

## 📝 Design Decisions and Justification
- Why put NL logic in view model?
  Keeps config generic/minimal while supporting urgent business rules reflected in external files.
- Why dynamic field views?
  Supports future customizability and easy maintenance—no per-country or per-field UI code needed.
- Why show JSON output?
  Makes form submission transparent for demonstration and debugging.

## Appendix: Assignment Coverage Checklist
| Requirement	                              |        Solution?                   |
| ------------------------------------------|------------------------------------|
| Country selector	                        |   ✔️ Picker in UI                  |
| Loads per-country KYC config (from YAML)  |   ✔️ External YAML file, runtime   |
| Renders dynamic fields	                  |   ✔️ Driven by config              |
| Handles required, regex, min/max rules	  |   ✔️ All implemented               |
| Validation errors inline	                |   ✔️ Inline to each field          |
| Form data output on valid submit	        |   ✔️ JSON modal                    |
| NL: fields fetched, shown read-only       |   ✔️ Mocked API, read-only fields  |

Thank you for reviewing!
