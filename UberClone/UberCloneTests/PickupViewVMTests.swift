//
//  UberCloneTests.swift
//  UberCloneTests
//
//  Created by Vinh Phan on 2/12/25.
//

import XCTest
@testable import UberClone

@MainActor
final class PickupViewVMTests: XCTestCase {

  func testInitialization_SetsUpPropertiesCorrectly() {
    // Arrange
//    let sampleTrip = Trip.mock(state: .requested)
//    let pickupCoordinates = sampleTrip.pickupCoordinates!
//
//    let sut = makeSUT(trip: sampleTrip, driverService: MockDriverService())
//
//    // Assert
//    XCTAssertEqual(sut.trip.passengerUid, sampleTrip.passengerUid)
//    XCTAssertEqual(sut.pickupCoordinates.latitude, pickupCoordinates.latitude)
//    XCTAssertEqual(sut.pickupCoordinates.longitude, pickupCoordinates.longitude)
//    XCTAssertEqual(sut.countdown, 10)
//    XCTAssertNil(sut.error)
//
//    let region = sut.cameraPosition.region
//    XCTAssertNotNil(region)
//    XCTAssertEqual(region?.center.latitude, pickupCoordinates.latitude)
//    XCTAssertEqual(region?.center.longitude, pickupCoordinates.longitude)
//    XCTAssertEqual(region?.span.latitudeDelta, 0.01)
//    XCTAssertEqual(region?.span.longitudeDelta, 0.01)

    XCTFail("Test CI")
  }

  func testAcceptTrip_Success_UpdatesTripAndCallsCompletion() {
    // Arrange
    let sampleTrip = Trip.mock(state: .requested)
    let mockDriverService = MockDriverService()
    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)
    let expectation = XCTestExpectation(description: "Expect completion handler to be called when trip is accepted")

    // Act
    sut.acceptTrip {
      expectation.fulfill()
    }

    // Assert
    wait(for: [expectation], timeout: 1.0)

    let message = mockDriverService.receivedMessages.first
    if case let .acceptTrip(trip) = message {
      XCTAssertEqual(mockDriverService.receivedMessages.count, 1, "Expect driver service receive only 1 message to accept trip")
      XCTAssertEqual(trip.passengerUid, sampleTrip.passengerUid, "Expect driver service receive the same trip info from sut")
    } else {
      XCTFail("Expect acceptTrip is called")
    }

    XCTAssertEqual(sut.trip.state, .accepted, "Expect trip state change to accepted")
    XCTAssertNil(sut.error, "Expect no error on success")
  }

  func testAcceptTrip_ErrorThrown_ShouldSetErrorAndDoesNotUpdateTripOrCallCompletion() async {
    // Arrange
    let sampleTrip = Trip.mock(state: .requested)
    let initialTripState = sampleTrip.state
    let mockDriverService = MockDriverService()
    mockDriverService.errorToThrow = NSError(domain: "", code: 1)

    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)

    let expectation = XCTestExpectation(description: "sut should handle the error.")

    // Act
    sut.acceptTrip {
      XCTFail("Expect completion handler should not be called on failure case")
    }

    let _ = await XCTWaiter.fulfillment(of: [expectation], timeout: 1.0)

    // Assert
    let message = mockDriverService.receivedMessages.first
    if case let .acceptTrip(trip) = message {
      XCTAssertEqual(mockDriverService.receivedMessages.count, 1, "Expect driver service receive only 1 message to accept trip")
      XCTAssertEqual(trip.passengerUid, sampleTrip.passengerUid, "Expect driver service receive the same trip info from sut")
    } else {
      XCTFail("Expect acceptTrip is called")
    }

    XCTAssertEqual(sut.trip.state, initialTripState, "Expect trip state not change")
    XCTAssertNotNil(sut.error, "Expect error exist")
  }

  func testDenyTrip_Success_UpdateTripAndCallsCompletion() {
    // Arrange
    let sampleTrip = Trip.mock(state: .requested)
    let mockDriverService = MockDriverService()

    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)

    let expectation = expectation(description: "Expect completion handler to be called when trip is deined")

    // Act
    sut.denyTrip {
      expectation.fulfill()
    }

    // Assert
    wait(for: [expectation], timeout: 1.0)

    let message = mockDriverService.receivedMessages.first
    if case let .updateTripState(trip, state) = message {
      XCTAssertEqual(mockDriverService.receivedMessages.count, 1, "Expect driver service receive only 1 message to update trip")
      XCTAssertEqual(trip.passengerUid, sampleTrip.passengerUid, "Expect driver service receive the same trip info from sut")
      XCTAssertEqual(state, TripState.denied, "Expect trip state updated to denied")
    } else {
      XCTFail("Expect updateTripState is called")
    }
  }

  func testDenyTrip_ErrorThrow_ShouldSetErrorAndDoesNotUpdateTripOrCallCompletion() async {
    // Arrange
    let sampleTrip = Trip.mock(state: .requested)
    let initialState = sampleTrip.state
    let mockDriverService = MockDriverService()
    mockDriverService.errorToThrow = NSError(domain: "", code: 1)

    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)

    let expectation = XCTestExpectation(description: "sut should handle the error.")

    // Act
    sut.denyTrip {
      XCTFail("Expected completion is not called")
    }

    let _ = await XCTWaiter.fulfillment(of: [expectation], timeout: 1.0)

    let message = mockDriverService.receivedMessages.first
    if case let .updateTripState(trip, _) = message {
      XCTAssertEqual(mockDriverService.receivedMessages.count, 1, "Expect driver service receive only 1 message to update trip")
      XCTAssertEqual(trip.passengerUid, sampleTrip.passengerUid, "Expect driver service receive the same trip info from sut")
      XCTAssertEqual(sut.trip.state, initialState, "Expect trip state not change")
    } else {
      XCTFail("Expect updateTripState is called")
    }
    XCTAssertNotNil(sut.error, "Expect error exist")
  }

  func makeSUT(trip: Trip, driverService: DriverService) -> PickupViewVM {
    let sut = PickupViewVM(trip: trip, driverService: driverService)
    return sut
  }

}
