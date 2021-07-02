import XCTest
@testable import WooCommerce
import Yosemite

final class ShippingLabelAddressFormViewModelTests: XCTestCase {

    func test_handleAddressValueChanges_returns_updated_ShippingLabelAddress() {

        // Given
        let shippingAddress = MockShippingLabelAddress.sampleAddress()
        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10, type: .origin, address: shippingAddress, validationError: nil, countries: [])

        // When
        viewModel.handleAddressValueChanges(row: .name, newValue: "Skylar Ferry")
        viewModel.handleAddressValueChanges(row: .company, newValue: "Automattic Inc.")
        viewModel.handleAddressValueChanges(row: .phone, newValue: "12345")
        viewModel.handleAddressValueChanges(row: .country, newValue: "United States")
        viewModel.handleAddressValueChanges(row: .state, newValue: "CA")
        viewModel.handleAddressValueChanges(row: .address, newValue: "60 29th")
        viewModel.handleAddressValueChanges(row: .address2, newValue: "Street #343")
        viewModel.handleAddressValueChanges(row: .city, newValue: "San Francisco")
        viewModel.handleAddressValueChanges(row: .postcode, newValue: "94121-2303")

        // Then
        XCTAssertEqual(viewModel.address?.name, "Skylar Ferry")
        XCTAssertEqual(viewModel.address?.company, "Automattic Inc.")
        XCTAssertEqual(viewModel.address?.phone, "12345")
        XCTAssertEqual(viewModel.address?.country, "United States")
        XCTAssertEqual(viewModel.address?.state, "CA")
        XCTAssertEqual(viewModel.address?.address1, "60 29th")
        XCTAssertEqual(viewModel.address?.address2, "Street #343")
        XCTAssertEqual(viewModel.address?.city, "San Francisco")
        XCTAssertEqual(viewModel.address?.postcode, "94121-2303")
    }

    func test_sections_are_returned_correctly_if_there_are_no_errors() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                   name: "Skylar Ferry",
                                                   phone: "12345",
                                                   country: "United States",
                                                   state: "CA",
                                                   address1: "60 29th",
                                                   address2: "Street #343",
                                                   city: "San Francisco",
                                                   postcode: "94121-2303")

        // When
        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10, type: .origin, address: shippingAddress, validationError: nil, countries: [])

        // Then
        let expectedRows: [ShippingLabelAddressFormViewModel.Row] = [.name, .company, .phone, .address, .address2, .city, .postcode, .state, .country]
        XCTAssertEqual(viewModel.sections, [ShippingLabelAddressFormViewModel.Section(rows: expectedRows)])
    }

    func test_sections_are_returned_correctly_if_an_address_validation_error_occurs() {
        // Given
        let shippingAddress = MockShippingLabelAddress.sampleAddress()
        let stores = MockStoresManager(sessionManager: .testingInstance)
        let validationError = ShippingLabelAddressValidationError(addressError: "Error", generalError: nil)

        // When
        stores.whenReceivingAction(ofType: ShippingLabelAction.self) { action in
            switch action {
            case let .validateAddress(_, _, onCompletion):
                onCompletion(.failure(validationError))
            default:
                break
            }
        }

        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: [])
        viewModel.validateAddress(onlyLocally: false) { (result) in
        }

        // Then
        let expectedRows: [ShippingLabelAddressFormViewModel.Row] = [.name,
                                                                     .fieldError(.name),
                                                                     .company,
                                                                     .phone,
                                                                     .address,
                                                                     .fieldError(.address),
                                                                     .address2,
                                                                     .city,
                                                                     .fieldError(.city),
                                                                     .postcode,
                                                                     .fieldError(.postcode),
                                                                     .state,
                                                                     .fieldError(.state),
                                                                     .country,
                                                                     .fieldError(.country)]
        XCTAssertEqual(viewModel.sections, [ShippingLabelAddressFormViewModel.Section(rows: expectedRows)])
    }

    func test_address_validation_returns_correct_values_if_succeeded() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                   name: "Skylar Ferry",
                                                   phone: "12345",
                                                   country: "United States",
                                                   state: "CA",
                                                   address1: "60 29th",
                                                   address2: "Street #343",
                                                   city: "San Francisco",
                                                   postcode: "94121-2303")
        let stores = MockStoresManager(sessionManager: .testingInstance)
        let expectedValidationSuccess = ShippingLabelAddressValidationSuccess(address: shippingAddress,
                                                                                isTrivialNormalization: true)

        // When
        stores.whenReceivingAction(ofType: ShippingLabelAction.self) { action in
            switch action {
            case let .validateAddress(_, _, onCompletion):
                onCompletion(.success(expectedValidationSuccess))
            default:
                break
            }
        }

        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: [])
        viewModel.validateAddress(onlyLocally: false) { (result) in
        }

        // Then
        XCTAssertEqual(viewModel.addressValidated, .remote)
        XCTAssertEqual(viewModel.addressValidationError, nil)
    }

    func test_address_validation_returns_correct_values_if_the_validation_fails() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                                         name: "Skylar Ferry",
                                                                         phone: "12345",
                                                                         country: "United States",
                                                                         state: "CA",
                                                                         address1: "60 29th",
                                                                         address2: "Street #343",
                                                                         city: "San Francisco",
                                                                         postcode: "94121-2303")
        let stores = MockStoresManager(sessionManager: .testingInstance)
        let validationError = ShippingLabelAddressValidationError(addressError: "Error", generalError: nil)

        // When
        stores.whenReceivingAction(ofType: ShippingLabelAction.self) { action in
            switch action {
            case let .validateAddress(_, _, onCompletion):
                onCompletion(.failure(validationError))
            default:
                break
            }
        }

        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: [])
        viewModel.validateAddress(onlyLocally: false) { (result) in
        }

        // Then
        XCTAssertEqual(viewModel.addressValidated, .none)
        XCTAssertEqual(viewModel.addressValidationError, validationError)
    }

    func test_address_validation_returns_correct_values_if_the_validation_returns_an_error() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                   name: "Skylar Ferry",
                                                   phone: "12345",
                                                   country: "United States",
                                                   state: "CA",
                                                   address1: "60 29th",
                                                   address2: "Street #343",
                                                   city: "San Francisco",
                                                   postcode: "94121-2303")
        let stores = MockStoresManager(sessionManager: .testingInstance)
        let error = SampleError.first

        // When
        stores.whenReceivingAction(ofType: ShippingLabelAction.self) { action in
            switch action {
            case let .validateAddress(_, _, onCompletion):
                onCompletion(.failure(error))
            default:
                break
            }
        }

        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: [])
        viewModel.validateAddress(onlyLocally: false) { (result) in
        }

        // Then
        let validationError = ShippingLabelAddressValidationError(addressError: nil, generalError: error.localizedDescription)
        XCTAssertEqual(viewModel.addressValidated, .none)
        XCTAssertEqual(viewModel.addressValidationError, validationError)
    }

    func test_address_validation_toggle_shouldShowTopBannerView() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                   name: "Skylar Ferry",
                                                   phone: "12345",
                                                   country: "United States",
                                                   state: "CA",
                                                   address1: "60 29th",
                                                   address2: "Street #343",
                                                   city: "San Francisco",
                                                   postcode: "94121-2303")
        let stores = MockStoresManager(sessionManager: .testingInstance)
        let expectedValidationSuccess = ShippingLabelAddressValidationSuccess(address: shippingAddress,
                                                                                isTrivialNormalization: true)

        // When
        stores.whenReceivingAction(ofType: ShippingLabelAction.self) { action in
            switch action {
            case let .validateAddress(_, _, onCompletion):
                DispatchQueue.main.async {
                    onCompletion(.success(expectedValidationSuccess))
                }
            default:
                break
            }
        }

        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: [])
        viewModel.validateAddress(onlyLocally: false) { (result) in
        }

        // Then
        XCTAssertTrue(viewModel.showLoadingIndicator)
        waitUntil { () -> Bool in
            !viewModel.showLoadingIndicator
        }
    }

    func test_extended_country_and_state_name_return_the_correct_values() {
        // Given
        let shippingAddress = ShippingLabelAddress(company: "Automattic Inc.",
                                                   name: "Skylar Ferry",
                                                   phone: "12345",
                                                   country: "US",
                                                   state: "CA",
                                                   address1: "60 29th",
                                                   address2: "Street #343",
                                                   city: "San Francisco",
                                                   postcode: "94121-2303")
        let stores = MockStoresManager(sessionManager: .testingInstance)


        // When
        let viewModel = ShippingLabelAddressFormViewModel(siteID: 10,
                                                          type: .origin,
                                                          address: shippingAddress,
                                                          stores: stores,
                                                          validationError: nil,
                                                          countries: sampleCountries())


        // Then
        XCTAssertEqual(viewModel.extendedCountryName, "United States")
        XCTAssertEqual(viewModel.extendedStateName, "California")
    }
}

private extension ShippingLabelAddressFormViewModelTests {
    func sampleCountries() -> [Country] {
        let state1 = StateOfACountry(code: "CA", name: "California")
        let state2 = StateOfACountry(code: "DE", name: "Delaware")
        let state3 = StateOfACountry(code: "DC", name: "District Of Columbia")
        let country1 = Country(code: "US", name: "United States", states: [state1, state2, state3])

        let state4 = StateOfACountry(code: "AG", name: "Agrigento")
        let state5 = StateOfACountry(code: "RC", name: "Reggio Calabria")
        let state6 = StateOfACountry(code: "RM", name: "Roma")
        let country2 = Country(code: "IT", name: "Italy", states: [state4, state5, state6])

        return [country1, country2]
    }
}
