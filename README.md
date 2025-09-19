// WalmartAssessment

A simple iOS app that fetches and displays a list of countries. It demonstrates a lightweight MVVM architecture with UIKit, a small networking layer, and unit tests.

## Features

- Fetch countries from a remote JSON endpoint
- Display country name, capital, region, and code in a table view
- Search by country name or capital (case-insensitive)
- Error handling with retry
- Unit tests for view model and integration paths
- UI tests for launch

## Project Structure

- Country.swift: Decodable model for a country
- CountriesViewModel.swift: View model handling loading, state, and filtering
- CountryListViewController.swift: UIKit list UI, search, and binding to the view model
- MockNetworkManager.swift (Tests target): Test-only networking mock for deterministic tests
- WalmartAssessmentTests.swift: Unit and integration tests for the view model
- WalmartAssessmentUITests.swift / WalmartAssessmentUITestsLaunchTests.swift: Basic UI tests

## Requirements

- Xcode 15 or later
- iOS 16.0+ deployment target (adjust if your project differs)

## Getting Started

1. Open WalmartAssessment.xcodeproj (or the .xcworkspace if you are using a workspace) in Xcode.
2. Select the WalmartAssessment scheme.
3. Choose a simulator (e.g., iPhone 15) or a connected device.
4. Press Cmd+R to build and run.

The app should launch to a list of countries and begin loading automatically.

## Running Tests

- Unit/Integration Tests:

  - Select the WalmartAssessment scheme.
  - Press Cmd+U to run all tests, or use the Test navigator in Xcode.
  - Tests include success and error paths for loading countries and search filtering behavior.

- UI Tests:
  - With the WalmartAssessment scheme selected, press Cmd+U or run the UI test classes in the Test navigator.
  - The included UI test checks basic app launch.

## Notes on Networking

- The production build uses a concrete Networking implementation (not shown here) to perform HTTP GET requests.
- Tests use MockNetworkManager to provide deterministic responses (success from bundled JSON, raw data, or various error modes).

## Troubleshooting

- If the list appears empty, ensure the remote JSON endpoint is reachable or run tests that use the bundled mock JSON.
- Clean the build folder (Shift+Cmd+K) if you encounter stale build artifacts.

## License

This project is provided for assessment/demo purposes.
