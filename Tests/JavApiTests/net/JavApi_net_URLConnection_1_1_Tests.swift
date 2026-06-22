/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */
import Testing
@testable import JavApi

@Suite("java.net.URLConnection — Java 1.1 FileNameMap additions")
struct JavApi_net_URLConnection_1_1_Tests {

  // MARK: - getFileNameMap / default map

  @Test("getFileNameMap() returns non-nil default map")
  func getFileNameMap_returnsDefault() {
    let map = java.net.URLConnection.getFileNameMap()
    // Just verify we get something back; the default map is non-nil by design
    #expect(map.getContentTypeFor("test.html") != nil)
  }

  @Test("Default map: .html → text/html")
  func defaultMap_html() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("index.html") == "text/html")
    #expect(map.getContentTypeFor("page.htm")   == "text/html")
  }

  @Test("Default map: .txt → text/plain")
  func defaultMap_txt() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("readme.txt") == "text/plain")
  }

  @Test("Default map: .json → application/json")
  func defaultMap_json() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("data.json") == "application/json")
  }

  @Test("Default map: .png → image/png")
  func defaultMap_png() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("photo.png") == "image/png")
  }

  @Test("Default map: .jpg and .jpeg → image/jpeg")
  func defaultMap_jpeg() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("photo.jpg")  == "image/jpeg")
    #expect(map.getContentTypeFor("photo.jpeg") == "image/jpeg")
  }

  @Test("Default map: .pdf → application/pdf")
  func defaultMap_pdf() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("doc.pdf") == "application/pdf")
  }

  @Test("Default map: unknown extension → nil")
  func defaultMap_unknown() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("file.xyz123") == nil)
  }

  @Test("Default map: no extension → nil")
  func defaultMap_noExtension() {
    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("Makefile") == nil)
  }

  // MARK: - setFileNameMap

  @Test("setFileNameMap replaces the global map")
  func setFileNameMap_replacesMap() {
    // Save original
    let original = java.net.URLConnection.getFileNameMap()
    defer { java.net.URLConnection.setFileNameMap(original) }

    // Install a custom map
    final class CustomMap: java.net.FileNameMap, @unchecked Sendable {
      func getContentTypeFor(_ fileName: String) -> String? {
        return fileName.hasSuffix(".custom") ? "application/x-custom" : nil
      }
    }
    java.net.URLConnection.setFileNameMap(CustomMap())

    let map = java.net.URLConnection.getFileNameMap()
    #expect(map.getContentTypeFor("file.custom") == "application/x-custom")
    // Standard extension no longer recognized by custom map
    #expect(map.getContentTypeFor("index.html") == nil)
  }
}
