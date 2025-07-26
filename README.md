# KYC-Flow

This project demonstrates a dynamic, configuration-driven "Know Your Customer" (KYC) form system for a global investment app. The form adapts based on country-specific requirements defined in external configuration files. It features dynamic form rendering, robust input validation, and special-case handling for the Netherlands (NL), where certain fields are read-only and fetched from a mocked API.

## 🚀  Getting Started 
#### 1. Requirements
- Xcode 16+ (tested with Swift 5.5+)

- iOS 18+ or Swift Playground (with SwiftUI support)

#### 2. Running the App
- ##### Xcode Project:

  1. Clone the repository.

  2. Open .xcodeproj in Xcode.

  3. Build and run on Simulator or device.

- ##### Swift Playground:

  1. Copy content of ContentView, models, and view model into a Swift Playground.

  2. Run and interact in the live view.

## 🌍 Features
- Country selector (NL, DE; easily extensible to others)

- Loads KYC configuration per-country (fields, validation)

- Dynamically renders each form field (text, number, date)

- Handles field-level validation with inline error messages:

  - Required fields

  - Regex patterns and custom error messages

  - Minimum/maximum length (for text)

  - Minimum/maximum value (for numbers)

- Submission outputs form data as formatted JSON

- Special NL Handling: Certain fields (first_name, last_name, birth_date) are fetched from a simulated API and displayed as read-only

## 🏗 Architectural Overview
- Country Selection: Implemented via SwiftUI Picker, updating the form's configuration.

- Configuration Source: In this demo, configs are defined inline (could be loaded from JSON/YAML).

- Dynamic Rendering: Form fields generated dynamically using SwiftUI views, with field metadata from the config.

- Validation: Performed in ViewModel, adhering to rules set in config for the selected country. Errors are shown under each field.

- Submission: On successful validation, form data is serialized and displayed in a modal sheet.

#### 🇳🇱 Special Handling for Netherlands (NL)
For the Netherlands, first_name, last_name, and birth_date:

- Are loaded via a simulated asynchronous API call (/api/nl-user-profile)

- Are displayed as read-only when the form appears

- This simulates real-world integration where these fields are pre-filled from official sources and not editable by the user

##### Implementation Approach:

- When NL is selected, the ViewModel triggers the mocked API call (1 second delay, hardcoded response).

- The main form observes loading state; submit is disabled until data loads.

- The isNLReadOnlyField logic ensures those fields are non-editable only for NL.

## 🧪 Mocked API
The simulated endpoint /api/nl-user-profile is implemented as:

swift
```
func fetchNLUserProfile() {
    isLoadingNLData = true
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
```
No actual network dependencies are used; this is all local for easy evaluation.

## 🧩 Extending for More Countries & Flexible Configs
To add more countries, simply add new configs (inline, JSON, or YAML) with desired fields and validation rules.

#### Recommendation: Config Format Enhancement
Currently, configs lack the ability to specify that a field should be read-only or have its source indicated (“external API”), necessitating some hardcoded logic. To address this for future scalability:

#### Proposed Config Format
Add optional config keys:

readonly: true — Marks the field as read-only in the UI.

data_source: "nl-user-profile" — Indicates this field’s value comes from a particular API or source.

##### Example (YAML excerpt):

```
country: NL
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
With this, the UI and ViewModel logic become fully data-driven and easier to maintain.

## 📝 Design Decisions and Justification
- Why put NL logic in view model?
  Keeps config generic/minimal while supporting urgent business rules not (yet) reflected in external files. For production, move those rules to config as proposed.

- Why dynamic field views?
  Supports future customizability and easy maintenance—no per-country or per-field UI code needed.

- Why show JSON output?
  Makes form submission transparent for demonstration and debugging.

## Appendix: Assignment Coverage Checklist
| Requirement	                              |        Solution?                   |
| ------------------------------------------|------------------------------------|
| Country selector	                        |   ✔️ Picker in UI                  |
| Loads per-country KYC config	            |   ✔️ Inline, but easily extensible |
| Renders dynamic fields	                  |   ✔️ Driven by config              |
| Handles required, regex, min/max rules	  |   ✔️ All implemented               |
| Validation errors inline	                |   ✔️ Inline to each field          |
| Form data output on valid submit	        |   ✔️ JSON modal                    |
| NL: 3 fields fetched, shown read-only	    |   ✔️ Mocked API, read-only fields  |

Thank you for reviewing!
