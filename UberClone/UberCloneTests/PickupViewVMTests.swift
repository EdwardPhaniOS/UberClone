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
    let sampleTrip = Trip.mock()
    let pickupCoordinates = sampleTrip.pickupCoordinates!
    let sut = makeSUT(trip: sampleTrip)

    XCTAssertEqual(sut.trip.passengerUid, sampleTrip.passengerUid)
    XCTAssertEqual(sut.pickupCoordinates.latitude, pickupCoordinates.latitude)
    XCTAssertEqual(sut.pickupCoordinates.longitude, pickupCoordinates.longitude)
    XCTAssertEqual(sut.countdown, 10)
    XCTAssertNil(sut.error)

    let region = sut.cameraPosition.region
    XCTAssertNotNil(region)
    XCTAssertEqual(region?.center.latitude, pickupCoordinates.latitude)
    XCTAssertEqual(region?.center.longitude, pickupCoordinates.longitude)
    XCTAssertEqual(region?.span.latitudeDelta, 0.01)
    XCTAssertEqual(region?.span.longitudeDelta, 0.01)
  }

  func testAcceptTrip_WhenTripIsRequesting_ShouldCallServiceAndUpdateState() async {
    // Given
    let sampleTrip = Trip.mock()
    sampleTrip.state = .requested

    let mockDriverService = MockDriverService()
    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)
    let expectation = XCTestExpectation(description: "Expect completion handler to be called when trip is accepted")

    // When
    sut.acceptTrip {
      expectation.fulfill()
    }

    await fulfillment(of: [expectation], timeout: 2.0)

    // Then
    XCTAssertEqual(mockDriverService.acceptTripCallCount, 1, "Expect driver service receive message to accept trip 1 time")
    XCTAssertEqual(mockDriverService.lastReceivedTripForAcceptance?.passengerUid, sampleTrip.passengerUid, "Expect driver service receive the same trip info from sut")
    XCTAssertEqual(sut.trip.state, .accepted, "Expect trip state change to accepted")
    XCTAssertNil(sut.error, "Expect no error on success")
  }

  func testAcceptTrip_WhenServiceThrowsError_ShouldSetErrorAndNotChangeState() async {
    // Given
    let sampleTrip = Trip.mock()
    sampleTrip.state = .requested

    let initialTripState = sampleTrip.state

    let mockDriverService = MockDriverService()
    mockDriverService.shouldThrowError = true
    mockDriverService.errorToThrow = NSError(domain: "", code: 1)
    let sut = makeSUT(trip: sampleTrip, driverService: mockDriverService)

    let expectation = XCTestExpectation(description: "sut should handle the error.")

    // When
    sut.acceptTrip {
      XCTFail("Expect completion handler should not be called on failure case")
    }

    let _ = await XCTWaiter.fulfillment(of: [expectation], timeout: 1.0)

    // Then
    XCTAssertEqual(mockDriverService.acceptTripCallCount, 1, "Expected driver service receive message to accept trip 1 time")
    XCTAssertEqual(sut.trip.state, initialTripState, "Expect trip state not change")
    XCTAssertNotNil(sut.error, "Expect error exist")
  }

  func makeSUT(trip: Trip = .mock(), driverService: DriverService = MockDriverService()) -> PickupViewVM {
    let sut = PickupViewVM(trip: trip, driverService: driverService)
    return sut
  }

}
