/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.io {
  // 1. Das Protokoll analog zu Java definieren
  /// - Since: Java 1.7
  public protocol AutoCloseable : java.io.Closeable {
  }
}

extension java.io.AutoCloseable {
  // 2. Eine Erweiterung schreiben, die JEDEM AutoCloseable-Typ die Logik schenkt
  // Führt einen Block aus und schließt die Ressource danach garantiert.
  func `try`<Result>(_ block: (Self) throws -> Result) rethrows -> Result {
    // Dank rethrows müssen wir hier kein try-catch nutzen.
    // Falls der Block einen Fehler wirft, wird er nach oben durchgereicht.
    defer {
      do {
        try self.close()
      } catch _ {
        // ignored
      }
    }
    return try block(self)
  }
  
  
  // better readable in swift
  // Führt einen Block aus und schließt die Ressource danach garantiert.
  
  /// You do not have to give up your beloved try-with-resources pattern. With our custom Swift extension, it feels almost exactly the same.
  ///
  /// **Java**
  ///
  ///     try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
  ///       System.out.println(reader.readLine());
  ///     } catch (IOException e) {
  ///       System.out.println("Error: " + e.getMessage());
  ///     }
  ///     // reader is safely closed at this point
  ///
  /// **Swift**
  ///
  ///     do {
  ///       try BufferedReader(FileReader("file.txt")).tryWith { reader in
  ///         print(try reader.readLine())
  ///       }
  ///     } catch {
  ///       print("Error: \(error)")
  ///     }
  ///     // reader is safely closed at this point
  ///
  /// **Key Differences You Need to Know**
  /// While the syntax looks very familiar, Swift handles a few architectural concepts differently under the hood:
  ///
  /// 1. Where to put the try? (Error Precision)
  ///
  /// *Java:* You place the try keyword at the very beginning of the statement before the parentheses. Java just knows that something inside that block might throw an error.
  /// *Swift:* Swift enforces absolute precision. You must place the try keyword exactly in front of the specific line or method that can actually fail (meaning right before tryWith and right before reader.readLine()). This makes your code highly transparent, as any developer can immediately spot the dangerous lines.
  ///
  /// 2. The Power of rethrowsIn Java, methods are rigidly declared with throws IOException. In Swift, our tryWith extension utilizes a feature called rethrows.This means:
  ///
  /// If the code inside your { reader in ... } block does not throw any errors (for example, if you are just reading hardcoded values), you can completely omit the try before tryWith and you don't even need the surrounding do-catch block! The Swift compiler dynamically adapts based on what your closure does.
  ///
  /// 3. Nesting Multiple ResourcesIn Java, you separate multiple resources inside the parentheses using a semicolon: try (Res A; Res B).
  ///
  /// In Swift, you simply nest the closures inside one another:
  ///
  ///     try ResA().tryWith { a in
  ///       try ResB().tryWith { b in
  ///         // Use both 'a' and 'b' here
  ///       }
  ///     }
  
  /// The Swift advantage: You get a clear visual hierarchy of your scopes. The resources are safely closed in reverse order (LIFO — Last In, First Out) as soon as their respective closing braces are reached.
  ///
  /// 4. The try? Shortcut (The "I don't care about the error" inline mode)
  ///
  /// If you want to open a resource in Java but don't care about handling the exact exception (you just want to return null if it fails), you still have to write a tedious, empty catch block.
  ///
  /// In Swift, you can use try?:swift// If the file does not exist, 'line' simply becomes nil.
  ///
  ///     // The resource is STILL guaranteed to be safely closed!
  ///     let line = try? BufferedReader(FileReader("file.txt")).tryWith { r in
  ///       try r.readLine()
  ///     }
  func tryWith<Result>(_ block: (java.io.AutoCloseable) throws -> Result) rethrows -> Result {
    // Dank rethrows müssen wir hier kein try-catch nutzen.
    // Falls der Block einen Fehler wirft, wird er nach oben durchgereicht.
    defer {
      do {
        try self.close()
      }
      catch _ {
        // ignored
      }
    }
    return try block(self)
  }
}
