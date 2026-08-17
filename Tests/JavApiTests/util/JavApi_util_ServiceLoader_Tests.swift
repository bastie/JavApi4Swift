/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
import Foundation
@testable import JavApi

/// Dummy vtable type used in tests — no real dynamic library involved.
private struct DummyVTable {
  let version: Int
}

struct JavApi_util_ServiceLoader_Tests {

  @Test("ServiceLoader init does not crash")
  func testInit() {
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Dummy")
    _ = loader  // just verify construction succeeds
    #expect(true)
  }

  @Test("ServiceLoader.load() static factory returns a loader")
  func testStaticLoad() {
    let loader = java.util.ServiceLoader<DummyVTable>.load(serviceName: "com.example.Dummy")
    _ = loader
    #expect(true)
  }

  @Test("ServiceLoader yields no providers when service file is absent")
  func testNoProvidersWhenAbsent() {
    // Point the loader at an empty temp directory — no .properties file present.
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([FileManager.default.temporaryDirectory.path])
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.NonExistentService")
    let providers = Array(loader)
    // Restore to avoid side-effects between tests.
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([])
    #expect(providers.isEmpty)
  }

  @Test("ServiceLoader.reload() clears cache without crashing")
  func testReload() {
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Dummy")
    loader.reload()
    // After reload the iterator still works (empty in test environment).
    let providers = Array(loader)
    #expect(providers.isEmpty)
  }

  @Test("ServiceLoader.setSearchPaths accepts empty list")
  func testSetSearchPathsEmpty() {
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([])
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Dummy")
    let providers = Array(loader)
    #expect(providers.isEmpty)
  }

  @Test("Two ServiceLoaders for same service name are independent objects")
  func testIndependentLoaders() {
    let a = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Svc")
    let b = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Svc")
    #expect(a !== b)
  }

  // MARK: - Java 9

  @Test("findFirst() returns empty Optional when no provider available")
  func testFindFirstEmpty() {
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([FileManager.default.temporaryDirectory.path])
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.NoSuch")
    let opt = loader.findFirst()
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([])
    #expect(opt.isEmpty())
  }

  @Test("stream() returns empty Stream when no provider available")
  func testStreamEmpty() {
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([FileManager.default.temporaryDirectory.path])
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.NoSuch")
    let count = loader.stream().count()
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([])
    #expect(count == 0)
  }

  @Test("stream() count matches iterator count")
  func testStreamCountMatchesIterator() {
    java.util.ServiceLoader<DummyVTable>.setSearchPaths([])
    let loader = java.util.ServiceLoader<DummyVTable>(serviceName: "com.example.Svc")
    let iterCount = Array(loader).count
    loader.reload()
    let streamCount = Int(loader.stream().count())
    #expect(iterCount == streamCount)
  }
}
