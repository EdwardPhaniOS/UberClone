//
//  MockDriverService.swift
//  UberCloneTests
//
//  Created by Vinh Phan on 2/12/25.
//

import Foundation
import Combine
import CoreLocation
@testable import UberClone

class MockDriverService: DriverService {

  var shouldThrowError = false
  var errorToThrow: Error = NSError(domain: "", code: 1)

  let tripPublisherSubject = PassthroughSubject<Trip, Error>()
  let tripCancelPublisherSubject = PassthroughSubject<Void, Error>()

  // -- For updateDriverLocation --
  var updateDriverLocationCallCount = 0
  var lastReceivedLocation: CLLocation?

  // -- For updateTripState --
  var updateTripStateCallCount = 0
  var lastReceivedTripForStateUpdate: Trip?
  var lastReceivedStateForUpdate: TripState?

  // -- For acceptTrip --
  var acceptTripCallCount = 0
  var lastReceivedTripForAcceptance: Trip?

  // -- For removeAllListener --
  var removeAllListenerCallCount = 0

  func tripPublisher() -> AnyPublisher<Trip, Error> {
    return tripPublisherSubject.eraseToAnyPublisher()
  }

  func tripCancelPublisher(trip: Trip) -> AnyPublisher<Void, Error> {
    return tripCancelPublisherSubject.eraseToAnyPublisher()
  }

  func updateDriverLocation(location: CLLocation) async throws {
    updateDriverLocationCallCount += 1
    lastReceivedLocation = location

    if shouldThrowError {
      throw errorToThrow
    }
  }

  func updateTripState(trip: Trip, state: TripState) async throws {
    updateTripStateCallCount += 1
    lastReceivedTripForStateUpdate = trip
    lastReceivedStateForUpdate = state

    if shouldThrowError {
      throw errorToThrow
    }
  }

  func acceptTrip(trip: Trip) async throws {
    acceptTripCallCount += 1
    lastReceivedTripForAcceptance = trip

    if shouldThrowError {
      throw errorToThrow
    }
  }

  func removeAllListener() {
    removeAllListenerCallCount += 1
  }
}
