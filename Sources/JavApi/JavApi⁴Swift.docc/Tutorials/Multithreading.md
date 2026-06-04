# Multithreading

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Running code concurrently using threads, thread groups, and Swift's modern async/await.

## Overview

Java and Swift take fundamentally different approaches to concurrency. Java's threading model (introduced in Java 1.0) is built around mutable shared state protected by locks. Swift's model (introduced in Swift 5.5) is built around *structured concurrency* — tasks have clear lifetimes, and data safety is enforced by the compiler through `Sendable` and actors.

JavApi⁴Swift bridges these two worlds. You can write Java-style threading code and it works — but for new code written in Swift, structured concurrency is the better path.

> **Key difference:** Java threads run until they finish or are interrupted. Swift Tasks are *structured* — they live within a scope and are automatically cancelled when that scope ends.

## Thread — the Java 1.0 Way

### Subclassing Thread

In Java, you run code on a new thread by subclassing `Thread` and overriding `run()`.

**Java:**
```java
class MyThread extends Thread {
    public void run() {
        System.out.println("Running in thread: " + getName());
    }
}

MyThread t = new MyThread();
t.setName("worker");
t.start();
```

**JavApi⁴Swift:**
```swift
import JavApi

class MyThread: Thread {
    override func run() {
        print("Running in thread: \(getName())")
    }
}

let t = MyThread()
t.setName("worker")
t.start()
```

### Using a Runnable

The second Java pattern passes work as a `Runnable`. This avoids subclassing.

**Java:**
```java
Runnable task = () -> System.out.println("Hello from Runnable");
Thread t = new Thread(task, "myThread");
t.start();
```

**JavApi⁴Swift:**

`Runnable` is a protocol with a single `run()` method. Closures cannot conform to protocols directly in Swift, so define a small helper or use an anonymous class pattern:

```swift
import JavApi

class PrintTask: Runnable {
    private let message: String
    init(_ message: String) { self.message = message }
    func run() { print(message) }
}

let t = Thread(PrintTask("Hello from Runnable"), "myThread")
t.start()
```

### Thread.sleep

**Java:**
```java
Thread.sleep(500); // milliseconds, throws InterruptedException
```

**JavApi⁴Swift — legacy (blocking):**
```swift
Thread.sleep(500)   // blocks the current thread
```

**JavApi⁴Swift — preferred (async):**
```swift
await Thread.sleep(milliseconds: 500)
```

> **Important difference:** The legacy `Thread.sleep(_:)` blocks the underlying OS thread — the same behaviour as Java. The async variant uses `Task.sleep` and yields the thread back to the scheduler, which is more efficient and the right choice in `async` contexts.

## ThreadGroup — Organising Threads

`ThreadGroup` lets you manage a set of threads together — for example, to interrupt them all at once.

**Java:**
```java
ThreadGroup group = new ThreadGroup("workers");
Thread t1 = new Thread(group, task1, "worker-1");
Thread t2 = new Thread(group, task2, "worker-2");
t1.start();
t2.start();

// Later — cancel everything
group.interrupt();

System.out.println("Active threads: " + group.activeCount());
```

**JavApi⁴Swift:**
```swift
import JavApi

let group = ThreadGroup("workers")

let t1 = Thread(group, PrintTask("Task 1"), "worker-1")
let t2 = Thread(group, PrintTask("Task 2"), "worker-2")
t1.start()
t2.start()

// Later — cancel everything
await group.interrupt()

let count = await group.activeCount()
print("Active threads: \(count)")
```

> **Important difference:** In JavApi⁴Swift, `ThreadGroup` is a Swift `actor`. Any call that reads or modifies the group's state must use `await`. This is different from Java, where `ThreadGroup` methods are `synchronized` and callable without `await`. The `actor` model gives you the same thread safety with a cleaner Swift API.

### interrupt() maps to Task cancellation

When you call `group.interrupt()` in JavApi⁴Swift, each thread's underlying Swift `Task` is cancelled via `task.cancel()`. The thread's `run()` method is not forcibly stopped — it must cooperate by checking `Task.isCancelled` (or `isInterrupted()`) and returning early if cancelled.

```swift
class CancellableTask: Thread {
    override func run() {
        for i in 0..<100 {
            guard !isInterrupted() else {
                print("Cancelled at step \(i)")
                return
            }
            // ... do work ...
        }
    }
}
```

### suspend() and resume() are no-ops

`ThreadGroup.suspend()` and `resume()` were deprecated in Java 1.2 because they caused deadlocks. In JavApi⁴Swift they are no-ops and marked `@available(*, deprecated)`. Do not use them.

## The Swift Way — async/await and TaskGroup

For new Swift code, use structured concurrency instead of `Thread` and `ThreadGroup`. The concepts map cleanly:

| Java | Swift |
|------|-------|
| `Thread` | `Task { }` |
| `ThreadGroup` | `withTaskGroup(of:)` |
| `thread.interrupt()` | `task.cancel()` |
| `ThreadGroup.interrupt()` | `group.cancelAll()` |
| `Thread.sleep(ms)` | `try await Task.sleep(for: .milliseconds(ms))` |

```swift
// Run two tasks in parallel and wait for both
await withTaskGroup(of: String.self) { group in
    group.addTask { "Result from task 1" }
    group.addTask { "Result from task 2" }

    for await result in group {
        print(result)
    }
}
```

Structured concurrency guarantees that all child tasks finish (or are cancelled) before `withTaskGroup` returns. There is no equivalent guarantee in Java's `ThreadGroup`.

## Priority

Java thread priorities range from `Thread.MIN_PRIORITY` (1) to `Thread.MAX_PRIORITY` (10), with `NORM_PRIORITY` (5) as the default.

```swift
let t = Thread()
t.setPriority(Thread.MAX_PRIORITY)   // 10
t.start()
```

> **Important difference:** Java's priority values influence the OS scheduler. In JavApi⁴Swift the priority is stored and readable but has **no effect on scheduling** — Swift Tasks use a separate priority system (`TaskPriority`: `.background`, `.utility`, `.default`, `.userInitiated`, `.high`). If scheduling priority matters, use `Task(priority: .high) { }` directly.

## Summary

| Concept | Java 1.0 | JavApi⁴Swift | Native Swift |
|---------|----------|--------------|--------------|
| New thread | `extends Thread` | `class MyThread: Thread` | `Task { }` |
| Run work | `new Thread(runnable)` | `Thread(runnable, name)` | `Task { closure }` |
| Sleep | `Thread.sleep(ms)` | `Thread.sleep(ms)` | `Task.sleep(for:)` |
| Group | `new ThreadGroup(name)` | `ThreadGroup(name)` | `withTaskGroup` |
| Interrupt all | `group.interrupt()` | `await group.interrupt()` | `group.cancelAll()` |
| Thread safety | `synchronized` | `actor`, `NSLock` | `actor` |

For porting existing Java code, `Thread` and `ThreadGroup` give you a familiar starting point. For new Swift code, prefer `async`/`await` and `TaskGroup` — the compiler will help you avoid data races at compile time.
