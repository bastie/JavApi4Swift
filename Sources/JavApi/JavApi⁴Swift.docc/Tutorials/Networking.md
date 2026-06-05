# Networking

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Resolving addresses, opening HTTP connections, and building a simple TCP server and client.

## Overview

JavApi⁴Swift covers the full `java.net` package from Java 1.0. This tutorial walks through the three common networking tasks in ascending order of complexity: resolving a hostname, making an HTTP request, and building a custom TCP server/client pair.

## InetAddress — resolving hostnames

`InetAddress.getByName` performs a DNS lookup and returns an object representing the IP address. This is usually the first step before opening a socket.

```swift
import JavApi

// Resolve a hostname
let addr = try java.net.InetAddress.getByName("example.com")
print(addr.getHostName())    // "example.com"
print(addr.getHostAddress()) // "93.184.216.34" (or similar)

// Resolve all addresses (some hosts return multiple IPs)
let all = try java.net.InetAddress.getAllByName("example.com")
for a in all {
    print(a.getHostAddress())
}

// Local host
let local = try java.net.InetAddress.getLocalHost()
print(local.getHostName())
```

> **Java vs. Swift:** The API is identical to Java. Both throw `UnknownHostException` if the host cannot be resolved.

## URL and URLConnection — HTTP client

For simple HTTP requests, use `URL` and `URLConnection`. This mirrors the Java 1.0 high-level networking API.

### Reading a URL directly

```swift
import JavApi

let url    = try java.net.URL("https://example.com")
let stream = try url.openStream()

var buf   = [byte](repeating: 0, count: 4096)
var count = try stream.read(&buf)
while count != -1 {
    let text = String(bytes: Array(buf.prefix(count)), encoding: .utf8) ?? ""
    print(text, terminator: "")
    count = try stream.read(&buf)
}
```

### URLConnection with headers

```swift
import JavApi

let url  = try java.net.URL("https://api.example.com/data")
let conn = url.openConnection()

// Configure before connecting
conn.setRequestProperty("Accept", "application/json")
conn.setConnectTimeout(5000)   // 5 seconds
conn.setDoInput(true)

// Connect and read
try conn.connect()

print("Status:       \(conn.getResponseCode())")
print("Content-Type: \(conn.getContentType() ?? "unknown")")
print("Length:       \(conn.getContentLength()) bytes")

let input = try conn.getInputStream()
var data  = [byte](repeating: 0, count: conn.getContentLength())
_ = try input.read(&data)
print(String(bytes: data, encoding: .utf8) ?? "")
```

> **Java vs. Swift:** `URLConnection` in JavApi⁴Swift uses `Foundation.URLSession` internally and is synchronous — matching Java's blocking semantics. For async networking in new Swift code, use `URLSession` directly with `async/await`.

## URLEncoder — encoding query parameters

When building URLs with query parameters, use `URLEncoder` to percent-encode values:

```swift
import JavApi

let name  = java.net.URLEncoder.encode("John & Jane")   // "John+%26+Jane"
let query = java.net.URLEncoder.encode("search term")   // "search+term"
let url   = try java.net.URL("https://example.com/search?\(query)=\(name)")
```

## ServerSocket and Socket — a minimal HTTP server and client

This example shows a complete request/response cycle using raw TCP sockets. The server runs in a Swift `Task`, the client connects from the main flow.

### The server

The server listens on port 8080, accepts one connection, reads the HTTP request line, and responds with a simple HTTP/1.0 response.

```swift
import JavApi

func runServer() async throws {
    let server = try java.net.ServerSocket(8080)
    defer { try? server.close() }

    print("Server listening on port \(server.getLocalPort())")

    // Accept one connection
    let client = try server.accept()
    defer { try? client.close() }

    // Read the request line
    let input  = try client.getInputStream()
    var lineBuf = [byte]()
    var b = try input.read()
    while b != -1 && b != Int(UInt8(ascii: "\n")) {
        lineBuf.append(byte(b))
        b = try input.read()
    }
    let requestLine = String(bytes: lineBuf, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    print("Server received: \(requestLine)")

    // Send HTTP/1.0 response
    let body     = "Hello from JavApi⁴Swift!\n"
    let bodyBytes = Array(body.utf8)
    let response = """
        HTTP/1.0 200 OK\r
        Content-Type: text/plain\r
        Content-Length: \(bodyBytes.count)\r
        Connection: close\r
        \r
        \(body)
        """
    let output = try client.getOutputStream()
    try output.write(Array(response.utf8))
}
```

### The client

The client uses the high-level `URLConnection` API to connect to the server started above:

```swift
import JavApi

func runClient() throws {
    let url  = try java.net.URL("http://127.0.0.1:8080/")
    let conn = url.openConnection()
    try conn.connect()

    print("Response code: \(conn.getResponseCode())")

    let input = try conn.getInputStream()
    var buf   = [byte](repeating: 0, count: 1024)
    var count = try input.read(&buf)
    while count != -1 {
        print(String(bytes: Array(buf.prefix(count)), encoding: .utf8) ?? "", terminator: "")
        count = try input.read(&buf)
    }
}
```

### Running server and client together

```swift
import JavApi

// Start server in background task
let serverTask = Task {
    try await runServer()
}

// Give the server a moment to start
await Thread.sleep(milliseconds: 100)

// Run client
try runClient()

// Clean up
serverTask.cancel()
```

> **Java vs. Swift:** In Java you would typically use `new Thread(runnable).start()` to run the server in the background. In Swift the idiomatic equivalent is `Task { }`. See <doc:Multithreading> for a detailed comparison.

## DatagramSocket — UDP

For UDP communication, use `DatagramSocket` and `DatagramPacket`:

```swift
import JavApi

// Sender
let sender  = try java.net.DatagramSocket()
let dest    = try java.net.InetAddress.getByName("127.0.0.1")
let message = Array("ping".utf8)
let packet  = java.net.DatagramPacket(message, message.count, dest, 9876)
try sender.send(packet)
sender.close()

// Receiver (typically in a separate task/thread)
let receiver = try java.net.DatagramSocket(9876)
var buf      = [byte](repeating: 0, count: 256)
let incoming = java.net.DatagramPacket(buf, buf.count)
try receiver.receive(incoming)   // blocks
let text = String(bytes: Array(incoming.getData().prefix(incoming.getLength())), encoding: .utf8) ?? ""
print("Received: \(text) from \(incoming.getAddress()?.getHostAddress() ?? "?")")
receiver.close()
```
