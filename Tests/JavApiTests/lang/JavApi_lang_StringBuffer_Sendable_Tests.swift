/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - StringBuilder / StringBuffer Sendable conformance
//
// See Text-Implementierung.md, "Swift-6.3-Concurrency-Hinweis": StringBuffer
// is now `@unchecked Sendable` (backed by a consistently-held NSLock),
// StringBuilder is deliberately left non-Sendable, matching Java's own
// documented "StringBuilder is not thread-safe, StringBuffer is" contract.
//
// Note on what is (and isn't) tested here: Swift Testing has no way to
// assert that code *fails* to compile, so there is no test proving
// "StringBuilder is not Sendable" — that guarantee is enforced by the
// compiler itself the moment anyone tries to capture a StringBuilder in a
// `@Sendable` closure, which simply won't build. What *is* tested below is
// the positive side: StringBuffer actually satisfies Sendable, and is
// genuinely safe to mutate from multiple concurrent tasks — not merely
// declared `@unchecked Sendable` on faith.

/// Requires its argument to conform to `Sendable`; calling this with a
/// `StringBuffer` only compiles because `StringBuffer` is `Sendable`.
private func requireSendable<T: Sendable>(_ value: T) {}

struct JavApi_lang_StringBuffer_Sendable_Tests {

  @Test("StringBuffer conforms to Sendable (compile-time check)")
  func stringBufferIsSendable() {
    requireSendable(StringBuffer("compile-time proof"))
  }

  @Test("StringBuffer survives concurrent appends from many tasks without data loss")
  func concurrentAppendsAreSafe() async {
    let buffer = StringBuffer()
    let taskCount = 50
    let charsPerTask = 20

    // This closure captures `buffer` (a class instance) across task
    // boundaries — it only compiles because StringBuffer is Sendable.
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<taskCount {
        group.addTask {
          for _ in 0..<charsPerTask {
            buffer.append("x")
          }
        }
      }
    }

    // If any append were lost to a race, this would be short.
    #expect(buffer.length() == taskCount * charsPerTask)
    #expect(buffer.toString().count == taskCount * charsPerTask)
  }

  @Test("StringBuffer allows concurrent reads and writes without crashing")
  func concurrentReadsAndWritesAreSafe() async {
    let buffer = StringBuffer("start")
    let writers = 30

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<writers {
        group.addTask { buffer.append("a") }
        group.addTask { _ = buffer.length() }
        group.addTask { _ = buffer.toString() }
        group.addTask { _ = try? buffer.charAt(0) }
      }
    }

    // No crash, and every successful append is accounted for.
    #expect(buffer.length() == "start".count + writers)
  }
}
