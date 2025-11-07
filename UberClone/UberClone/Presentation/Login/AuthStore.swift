// Created on 10/24/25.
// Copyright (c) 2025 ABC Virtual Communications, Inc. All rights reserved.

import Foundation

@MainActor
class AuthStore: ObservableObject {
  @Published var isLoggedIn: Bool = true
}
