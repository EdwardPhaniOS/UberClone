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

  enum Message {
    case acceptTrip(trip: Trip)
    case removeAllListener
    case updateTripState(trip: Trip, state: TripState)
    case updateDriverLocation(location: CLLocation)
  }

  var receivedMessages: [Message] = []

  var errorToThrow: Error?

  let tripPublisherSubject = PassthroughSubject<Trip, Error>()
  let tripCancelPublisherSubject = PassthroughSubject<Void, Error>()


  func tripPublisher() -> AnyPublisher<Trip, Error> {
    return tripPublisherSubject.eraseToAnyPublisher()
  }

  func tripCancelPublisher(trip: Trip) -> AnyPublisher<Void, Error> {
    return tripCancelPublisherSubject.eraseToAnyPublisher()
  }

  func updateDriverLocation(location: CLLocation) async throws {
    let message = Message.updateDriverLocation(location: location)
    receivedMessages.append(message)

    if let errorToThrow = errorToThrow {
      throw errorToThrow
    }
  }

  func updateTripState(trip: Trip, state: TripState) async throws {
    let message = Message.updateTripState(trip: trip, state: state)
    receivedMessages.append(message)

    if let errorToThrow = errorToThrow {
      throw errorToThrow
    }
  }

  func acceptTrip(trip: Trip) async throws {
    let message = Message.acceptTrip(trip: trip)
    receivedMessages.append(message)

    if let errorToThrow = errorToThrow {
      throw errorToThrow
    }
  }

  func removeAllListener() {
    let message = Message.removeAllListener
    receivedMessages.append(message)
  }
}
