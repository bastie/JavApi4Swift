/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

// MARK: - Helpers

/// Minimal concrete PublicKey for testing (no real cryptography).
private struct MockPublicKey: java.security.PublicKey {
  func getAlgorithm() -> String { "MOCK" }
  func getFormat() -> String? { nil }
  func getEncoded() -> [UInt8]? { nil }
}

/// Minimal concrete PrivateKey for testing (no real cryptography).
private struct MockPrivateKey: java.security.PrivateKey {
  func getAlgorithm() -> String { "MOCK" }
  func getFormat() -> String? { nil }
  func getEncoded() -> [UInt8]? { nil }
}

/// Minimal concrete Provider for testing.
private final class MockProvider: java.security.Provider {
  override func getName() -> String { "MockProvider" }
  override func getVersion() -> Double { 1.0 }
  override func getInfo() -> String { "Test provider" }
}

// MARK: - DigestInputStream

@Suite("java.security.DigestInputStream")
struct JavApi_security_DigestInputStream_Tests {

  @Test("Lesen durch DigestInputStream erzeugt denselben Hash wie direktes update()")
  func testDigestMatchesDirect() throws {
    let data: [UInt8] = Array("hello".utf8)

    // Direct digest
    let mdDirect = try java.security.MessageDigest.getInstance("SHA-256")
    let expected = mdDirect.digest(data)

    // Via DigestInputStream
    let mdStream = try java.security.MessageDigest.getInstance("SHA-256")
    let bais = java.io.ByteArrayInputStream(data)
    let dis  = java.security.DigestInputStream(bais, mdStream)
    var buf = [UInt8](repeating: 0, count: data.count + 1)
    let n = try dis.read(&buf, 0, buf.count)
    #expect(n == data.count)
    let actual = mdStream.digest()
    #expect(actual == expected)
  }

  @Test("getMessageDigest gibt das assoziierte Digest zurück")
  func testGetMessageDigest() throws {
    let md  = try java.security.MessageDigest.getInstance("MD5")
    let dis = java.security.DigestInputStream(java.io.ByteArrayInputStream([]), md)
    // Pointer equality not available for classes without Identifiable, compare by type
    #expect(dis.getMessageDigest() === md)
  }

  @Test("on(false) deaktiviert Digest-Berechnung")
  func testDigestOff() throws {
    let data: [UInt8] = [1, 2, 3]

    let md  = try java.security.MessageDigest.getInstance("SHA-256")
    let dis = java.security.DigestInputStream(java.io.ByteArrayInputStream(data), md)
    dis.on(false)
    var buf = [UInt8](repeating: 0, count: data.count)
    _ = try dis.read(&buf, 0, buf.count)
    // Digest of empty input (no data fed)
    let actual   = md.digest()
    let empty    = (try java.security.MessageDigest.getInstance("SHA-256")).digest([])
    #expect(actual == empty)
  }

  @Test("read() gibt -1 am Ende zurück")
  func testEOF() throws {
    let md  = try java.security.MessageDigest.getInstance("MD5")
    let dis = java.security.DigestInputStream(java.io.ByteArrayInputStream([]), md)
    #expect(try dis.read() == -1)
  }
}

// MARK: - DigestOutputStream

@Suite("java.security.DigestOutputStream")
struct JavApi_security_DigestOutputStream_Tests {

  @Test("Schreiben durch DigestOutputStream erzeugt denselben Hash wie direktes update()")
  func testDigestMatchesDirect() throws {
    let data: [UInt8] = Array("hello".utf8)

    let mdDirect = try java.security.MessageDigest.getInstance("SHA-256")
    let expected = mdDirect.digest(data)

    let mdStream = try java.security.MessageDigest.getInstance("SHA-256")
    let baos = java.io.ByteArrayOutputStream()
    let dos  = java.security.DigestOutputStream(baos, mdStream)
    try dos.write(data, 0, data.count)
    let actual = mdStream.digest()
    #expect(actual == expected)
  }

  @Test("write(Int) aktualisiert Digest korrekt")
  func testWriteSingleByte() throws {
    let mdDirect = try java.security.MessageDigest.getInstance("MD5")
    _ = mdDirect.digest([0x42])

    let mdStream = try java.security.MessageDigest.getInstance("MD5")
    let dos = java.security.DigestOutputStream(java.io.ByteArrayOutputStream(), mdStream)
    try dos.write(0x42)
    let actual = mdStream.digest()
    let expected = (try java.security.MessageDigest.getInstance("MD5")).digest([0x42])
    #expect(actual == expected)
  }

  @Test("on(false) deaktiviert Digest-Berechnung")
  func testDigestOff() throws {
    let data: [UInt8] = [1, 2, 3]
    let md  = try java.security.MessageDigest.getInstance("SHA-256")
    let dos = java.security.DigestOutputStream(java.io.ByteArrayOutputStream(), md)
    dos.on(false)
    try dos.write(data, 0, data.count)
    let actual = md.digest()
    let empty  = (try java.security.MessageDigest.getInstance("SHA-256")).digest([])
    #expect(actual == empty)
  }
}

// MARK: - KeyPair

@Suite("java.security.KeyPair")
struct JavApi_security_KeyPair_Tests {

  @Test("getPublic gibt den übergebenen PublicKey zurück")
  func testGetPublic() {
    let pub  = MockPublicKey()
    let priv = MockPrivateKey()
    let kp   = java.security.KeyPair(pub, priv)
    #expect(kp.getPublic().getAlgorithm() == "MOCK")
  }

  @Test("getPrivate gibt den übergebenen PrivateKey zurück")
  func testGetPrivate() {
    let pub  = MockPublicKey()
    let priv = MockPrivateKey()
    let kp   = java.security.KeyPair(pub, priv)
    #expect(kp.getPrivate().getAlgorithm() == "MOCK")
  }
}

// MARK: - KeyPairGenerator

@Suite("java.security.KeyPairGenerator")
struct JavApi_security_KeyPairGenerator_Tests {

  @Test("getInstance wirft NoSuchAlgorithmException für unbekannten Algorithmus")
  func testUnknownAlgorithmThrows() {
    #expect(throws: (any Error).self) {
      try java.security.KeyPairGenerator.getInstance("UNKNOWN_KPG")
    }
  }

  @Test("getAlgorithm gibt den im Konstruktor gesetzten Namen zurück")
  func testGetAlgorithm() {
    // Subclass just to instantiate
    class DummyKPG: java.security.KeyPairGenerator, @unchecked Sendable {
      init() { super.init("DummyAlgo") }
    }
    #expect(DummyKPG().getAlgorithm() == "DummyAlgo")
  }
}

// MARK: - Signature

@Suite("java.security.Signature")
struct JavApi_security_Signature_Tests {

  @Test("getInstance wirft NoSuchAlgorithmException für unbekannten Algorithmus")
  func testUnknownAlgorithmThrows() {
    #expect(throws: (any Error).self) {
      try java.security.Signature.getInstance("UNKNOWN_SIG")
    }
  }

  @Test("initSign setzt Status auf SIGN")
  func testInitSignSetsState() throws {
    class DummySig: java.security.Signature, @unchecked Sendable {
      init() { super.init("DummySig") }
    }
    let sig  = DummySig()
    let priv = MockPrivateKey()
    #expect(sig.state == java.security.Signature.UNINITIALIZED)
    try sig.initSign(priv)
    #expect(sig.state == java.security.Signature.SIGN)
  }

  @Test("initVerify setzt Status auf VERIFY")
  func testInitVerifySetsState() throws {
    class DummySig: java.security.Signature, @unchecked Sendable {
      init() { super.init("DummySig") }
    }
    let sig = DummySig()
    let pub = MockPublicKey()
    try sig.initVerify(pub)
    #expect(sig.state == java.security.Signature.VERIFY)
  }

  @Test("Konstanten haben korrekte Werte")
  func testConstants() {
    #expect(java.security.Signature.UNINITIALIZED == 0)
    #expect(java.security.Signature.SIGN          == 2)
    #expect(java.security.Signature.VERIFY        == 3)
  }
}

// MARK: - Security

@Suite("java.security.Security")
struct JavApi_security_Security_Tests {

  @Test("getProviders enthält mindestens einen Provider")
  func testGetProvidersNotEmpty() {
    #expect(!java.security.Security.getProviders().isEmpty)
  }

  @Test("getAlgorithms(MessageDigest) enthält MD5 und SHA-256")
  func testGetAlgorithmsMessageDigest() {
    let algs = java.security.Security.getAlgorithms("MessageDigest")
    #expect(algs.contains("MD5"))
    #expect(algs.contains("SHA-256"))
  }

  @Test("addProvider fügt Provider hinzu; removeProvider entfernt ihn")
  func testAddAndRemoveProvider() {
    let before = java.security.Security.getProviders().count
    let mock   = MockProvider()
    let pos    = java.security.Security.addProvider(mock)
    #expect(pos > 0)
    #expect(java.security.Security.getProviders().count == before + 1)

    java.security.Security.removeProvider("MockProvider")
    #expect(java.security.Security.getProviders().count == before)
  }

  @Test("addProvider gibt -1 zurück wenn Provider bereits registriert")
  func testAddDuplicateProvider() {
    let mock = MockProvider()
    java.security.Security.addProvider(mock)
    let result = java.security.Security.addProvider(MockProvider())
    #expect(result == -1)
    // cleanup
    java.security.Security.removeProvider("MockProvider")
  }

  @Test("toString gibt '<name> version <version>' zurück")
  func testProviderToString() {
    let p = MockProvider()
    #expect(p.toString() == "MockProvider version 1.0")
    #expect(p.description == p.toString())
  }
}
