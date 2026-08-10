/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

// MARK: - Java 8 functional-interface default methods for Map

extension java.util.Map {

  /// Performs the given action for each entry in this map.
  ///
  /// Mirrors `java.util.Map.forEach(BiConsumer<? super K, ? super V>)` (Java 8).
  ///
  /// The default implementation iterates over ``keySet()`` and calls
  /// `action.accept(key, value)` for every key-value pair.
  ///
  /// - Parameter action: The action to be performed for each entry.
  /// - Since: Java 8
  public func forEach(_ action: some java.util.function.BiConsumer<K, V>) {
    for key in keySet().toArray().compactMap({ $0 }) {
      if let value = get(key) {
        action.accept(key, value)
      }
    }
  }

  /// Replaces each entry's value with the result of invoking the given function
  /// on that entry until all entries have been processed or the function throws.
  ///
  /// Mirrors `java.util.Map.replaceAll(BiFunction<? super K, ? super V, ? extends V>)` (Java 8).
  ///
  /// - Parameter function: The function to apply to each entry.
  /// - Since: Java 8
  public func replaceAll(_ function: some java.util.function.BiFunction<K, V, V>) {
    for key in keySet().toArray().compactMap({ $0 }) {
      if let value = get(key) {
        let newValue = function.apply(key, value)
        _ = put(key, newValue)
      }
    }
  }

  /// If the specified key is not already associated with a value (or is mapped
  /// to `nil`), attempts to compute its value using the given mapping function
  /// and enters it into this map.
  ///
  /// Mirrors `java.util.Map.computeIfAbsent(K, Function<? super K, ? extends V>)` (Java 8).
  ///
  /// - Parameters:
  ///   - key: The key with which the specified value is to be associated.
  ///   - mappingFunction: The function to compute a value.
  /// - Returns: The current (existing or computed) value associated with the
  ///   specified key, or `nil` if the computed value is `nil`.
  /// - Since: Java 8
  @discardableResult
  public func computeIfAbsent(
    _ key: K,
    _ mappingFunction: some java.util.function.Function<K, V>
  ) -> V? {
    if let existing = get(key) { return existing }
    let newValue = mappingFunction.apply(key)
    _ = put(key, newValue)
    return newValue
  }
}
