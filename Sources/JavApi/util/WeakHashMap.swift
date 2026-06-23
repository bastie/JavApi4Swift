/*
 * SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
 * SPDX-License-Identifier: MIT
 */

extension java.util {

  /// A hash-table-based implementation of `java.util.Map` with **weakly referenced keys**.
  ///
  /// An entry is automatically removed when its key is no longer strongly referenced from
  /// outside the map.  This mirrors the behaviour of Java's `WeakHashMap`.
  ///
  /// ### Swift / Java differences
  ///
  /// | Java | Swift (this class) |
  /// |------|--------------------|
  /// | All `Object` keys are reference types → any key works | Only class instances (`AnyObject`) can be weak → `Key: AnyObject` |
  /// | GC collects unreachable keys lazily | ARC deallocates immediately when strong-ref count hits zero |
  /// | Entry removal happens at indeterminate GC time | Entry is logically gone the instant the last external `strong` ref disappears; stale storage is purged on next access |
  ///
  /// Because Swift uses ARC instead of a garbage collector, dead entries are *purged lazily*
  /// on every mutating or querying access.  Call ``purge()`` explicitly if you need
  /// deterministic cleanup without a read or write.
  ///
  /// ### Value-type keys are not supported
  ///
  /// `String`, `Int`, `struct`, and other Swift value types cannot be held weakly.
  /// Use ``HashMap`` for those key types.  See *DevelopmentNotes.md → WeakHashMap* for
  /// the full rationale.
  ///
  /// - Since: Java 1.2
  public final class WeakHashMap<Key: AnyObject & Hashable, Value>: java.util.AbstractMap<Key, Value> {

    // MARK: - Internal storage

    /// Wraps a key as a weak reference, using `ObjectIdentifier` for equality / hashing
    /// so that the dictionary does not itself hold a strong reference to the key.
    private final class WeakBox {
      weak var key: Key?
      let id: ObjectIdentifier

      init(_ key: Key) {
        self.key = key
        self.id = ObjectIdentifier(key)
      }
    }

    private struct Entry {
      let box: WeakBox
      var value: Value
    }

    /// Keyed by `ObjectIdentifier` so the dictionary never holds a strong ref to `Key`.
    private var storage: [ObjectIdentifier: Entry] = [:]

    // MARK: - Init

    /// Creates an empty `WeakHashMap`.
    public override init() {}

    /// Creates an empty `WeakHashMap` with a capacity hint.
    public init(initialCapacity: Int) {
      storage = Dictionary(minimumCapacity: initialCapacity)
    }

    // MARK: - Purge

    /// Removes all entries whose key has been deallocated.
    ///
    /// Called automatically before every access; you can also call it directly if you
    /// want to reclaim storage without performing any map operation.
    public func purge() {
      storage = storage.filter { $0.value.box.key != nil }
    }

    // MARK: - AbstractMap — required override

    /// Returns a live snapshot of all entries whose keys are still alive.
    ///
    /// Dead entries are purged before the snapshot is taken.
    public override func entrySet() -> [(key: Key, value: Value)] {
      purge()
      return storage.values.compactMap { entry in
        guard let k = entry.box.key else { return nil }
        return (key: k, value: entry.value)
      }
    }

    // MARK: - java.util.Map — Mutation

    /// Associates `value` with `key`.
    ///
    /// The key is held **weakly**; the value is held strongly.
    /// Returns the previously associated value, or `nil` if none.
    @discardableResult
    public override func put(_ key: Key, _ value: Value) -> Value? {
      purge()
      let id = ObjectIdentifier(key)
      let old = storage[id]?.value
      storage[id] = Entry(box: WeakBox(key), value: value)
      return old
    }

    /// Removes the entry for `key` and returns its former value, or `nil` if absent.
    @discardableResult
    public override func remove(_ key: Key) -> Value? {
      purge()
      return storage.removeValue(forKey: ObjectIdentifier(key))?.value
    }

    // MARK: - java.util.Map — Query (O(1) overrides)

    public override func size() -> Int {
      purge()
      return storage.count
    }

    public override func isEmpty() -> Bool {
      purge()
      return storage.isEmpty
    }

    public override func containsKey(_ key: Key) -> Bool {
      purge()
      guard let entry = storage[ObjectIdentifier(key)] else { return false }
      return entry.box.key != nil
    }

    public override func get(_ key: Key) -> Value? {
      purge()
      guard let entry = storage[ObjectIdentifier(key)],
            entry.box.key != nil else { return nil }
      return entry.value
    }

    public override func clear() {
      storage.removeAll()
    }

    // MARK: - Subscript (Swift-style)

    /// Swift dictionary-style subscript access.
    ///
    /// Writing `nil` removes the entry.
    public subscript(key: Key) -> Value? {
      get { get(key) }
      set {
        if let v = newValue {
          put(key, v)
        } else {
          remove(key)
        }
      }
    }
  }
}
