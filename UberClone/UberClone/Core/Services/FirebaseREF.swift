//
//  FirebaseReferences.swift
//  UberClone
//
//  Created by Vinh Phan on 6/11/25.
//
import Firebase
import Foundation

struct FirebaseREF {
    static let dbURL = "https://uberclone-c3f5e-default-rtdb.asia-southeast1.firebasedatabase.app/"
    static let dbRef = Database.database(url: dbURL).reference()
    static let users = dbRef.child("users")
    static let driverLocations = dbRef.child("driver-locations")
    static let trips = dbRef.child("trips")
}
