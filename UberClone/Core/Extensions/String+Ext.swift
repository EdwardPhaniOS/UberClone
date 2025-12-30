//
//  StringExt.swift
//  UberClone
//
//  Created by Vinh Phan on 13/11/25.
//

import Foundation

extension String {
  static var empty: String {
    return ""
  }
  
  var isValidEmail: Bool {
    let predicate = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
    return predicate.evaluate(with: self)
  }
  
  var isValidPassword: Bool {
    let predicate = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9]{6,}$")
    return predicate.evaluate(with: self)
  }
  
  var isValidUserName: Bool {
    let predicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9\\-.' ]{2,25}$")
    return predicate.evaluate(with: self)
  }
}
