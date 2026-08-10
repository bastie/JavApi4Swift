# Scheduling: Timer and TimerTask

<!--
* SPDX-FileCopyrightText: 2026 - Sebastian Ritter <bastie@users.noreply.github.com>
* SPDX-License-Identifier: 0BSD
-->

Running code later, or repeatedly, using `java.util.Timer`, Swift Tasks, and Foundation.Timer.

## Overview

Almost every program eventually needs to run code *later*: check for new data every 30 seconds, show a loading indicator after half a second, retry a failed request with back-off. This kind of *scheduled execution* looks simple on the surface but hides real complexity: threads, cancellation, clock drift, and interaction with the UI thread.

Java solved this problem in version 1.3 with `java.util.Timer` and `java.util.TimerTask`. Swift offers three distinct mechanisms — `Foundation.Timer`, `DispatchQueue.asyncAfter`, and `Task.sleep` — each suited to a different context. JavApi⁴Swift maps the Java API onto Swift's structured concurrency model.

This article explains the Java scheduling model in depth, shows the equivalent Swift approaches, and guides you through choosing the right tool for each situation.

---

## The Java Model: Timer and TimerTask

### What is a Timer?

A `java.util.Timer` manages a single background thread and a queue of `TimerTask` objects. When you schedule a task, you describe *when* and *how often* it should run — the Timer handles the rest. Your code, in the form of a `TimerTask`, is called on the timer's background thread at the scheduled time.

```
┌─────────────────────────────────────────────┐
│               your application              │
│                                             │
│   timer.schedule(task, delay: 500)          │
│           │                                 │
│           ▼                                 │
│   ┌───────────────┐                         │
│   │  Timer queue  │  ← tasks waiting        │
│   └───────┬───────┘                         │
│           │  background thread              │
│           ▼                                 │
│      task.run()   ← called 500 ms later     │
└─────────────────────────────────────────────┘
```

### TimerTask: Defining the Work

`TimerTask` is an abstract class. You subclass it and override `run()` with whatever you want to do. In JavApi⁴Swift, it is a protocol:

**Java:**
```java
class PrintTask extends TimerTask {
    @Override
    public void run() {
        System.out.println("tick: " + System.currentTimeMillis());
    }
}
```

**JavApi⁴Swift:**
```swift
import JavApi

class PrintTask: java.util.TimerTask {
    func run() {
        print("tick: \(java.lang.System.currentTimeMillis())")
    }
}
```

Because `run()` is called on a background actor in JavApi⁴Swift, `TimerTask` conforms to `Sendable`. Any data the task touches must itself be safe to share across concurrency boundaries.

### Scheduling a One-Shot Task

The simplest use of `Timer` is running something once after a delay. The delay is always expressed in **milliseconds**.

**Java:**
```java
Timer timer = new Timer();
timer.schedule(new PrintTask(), 1000); // run once after 1 second
```

**JavApi⁴Swift:**
```swift
let timer = java.util.Timer()
timer.schedule(PrintTask(), delay: 1000)
```

After the task runs, the timer itself stays alive — you can schedule additional tasks on it. Call `timer.cancel()` when you no longer need it to release the underlying resource.

### Scheduling at an Absolute Time

Instead of a relative delay you can specify an absolute moment in time as milliseconds since the Unix epoch (1 January 1970 UTC). This is the value returned by `java.lang.System.currentTimeMillis()` and `java.util.Date.getTime()`.

**Java:**
```java
long midnight = /* compute next midnight */ ...;
timer.schedule(new PrintTask(), midnight);
```

**JavApi⁴Swift:**
```swift
let midnight: Int64 = /* compute next midnight */ ...
timer.schedule(PrintTask(), time: midnight)
```

If the specified time is in the past, the task runs immediately.

### Repeating Tasks: Fixed Delay vs. Fixed Rate

Java `Timer` offers two repeating strategies that are easy to confuse:

**`schedule(_:delay:period:)` — fixed delay**

The timer waits *period* milliseconds *after each execution finishes* before starting the next one. If a task takes 200 ms and the period is 1000 ms, the actual interval between starts is 1200 ms. This mode is appropriate when what matters is the *gap between executions* — for example, polling a server where you want to avoid hammering it while a slow response is in flight.

**`scheduleAtFixedRate(_:delay:period:)` — fixed rate**

The timer tries to fire the task at a constant *rate*, regardless of how long each execution takes. It tracks when each firing *should* have happened and, if the previous task was slow, fires the next one immediately to catch up. This mode is appropriate when you need a stable rhythm — for example, updating an animation at 60 frames per second.

```
Fixed delay (period = 1 s, task takes 0.3 s):
│←── 1 s ──→│←── 1 s ──→│←── 1 s ──→│
  [task 0.3s]   [task 0.3s]   [task 0.3s]
    ↑               ↑               ↑
    start        start+1.3s     start+2.6s

Fixed rate (period = 1 s, task takes 0.3 s):
│←── 1 s ──→│←── 1 s ──→│←── 1 s ──→│
  [task 0.3s]   [task 0.3s]   [task 0.3s]
    ↑               ↑               ↑
    start        start+1.0s     start+2.0s
```

**JavApi⁴Swift:**
```swift
let timer = java.util.Timer()

// Fixed delay — gaps between runs stay constant
timer.schedule(PrintTask(), delay: 0, period: 1000)

// Fixed rate — start times stay constant
timer.scheduleAtFixedRate(PrintTask(), delay: 0, period: 1000)
```

### Cancellation

`Timer.cancel()` stops the timer and cancels all pending tasks. `TimerTask.cancel()` cancels a single task without touching the timer itself.

**Java:**
```java
Timer timer = new Timer();
TimerTask task = new PrintTask();
timer.schedule(task, 0, 1000);

// Later...
task.cancel();   // stop this one task
timer.cancel();  // stop everything and release the thread
```

**JavApi⁴Swift:**
```swift
let timer = java.util.Timer()
timer.schedule(PrintTask(), delay: 0, period: 1000)

// Later...
timer.cancel()  // cancels all tasks and frees the underlying Swift Task
```

> **Important:** Always call `cancel()` on a `Timer` you no longer need. In JavApi⁴Swift, an uncancelled Timer with a repeating task holds a live Swift `Task` indefinitely.

---

## Swift Native Scheduling

When writing new Swift code rather than porting Java, you have three idiomatic options. Each has a different strength.

### Option 1: `Foundation.Timer` — RunLoop-based, for UI

`Foundation.Timer` fires on a `RunLoop`. On Apple platforms this integrates naturally with the UI: timer callbacks land on the main thread if you schedule them there, making it safe to update labels, buttons, and other views directly.

```swift
import Foundation

// One-shot, 1 second delay, on the main RunLoop
let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
    print("fired once")
}

// Repeating, every 0.5 seconds
let repeating = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
    print("tick")
    if someCondition { t.invalidate() }   // cancel from inside the callback
}
```

**When to use:** UI updates, animations triggered on a schedule, anything that must run on the main thread.

**Limitation:** A `Foundation.Timer` only fires while its `RunLoop` is running in the common mode. A timer scheduled on the main RunLoop pauses when the user scrolls (because UIKit switches the RunLoop to a tracking mode). Use `Timer(fire:interval:repeats:block:)` + `RunLoop.main.add(timer, forMode: .common)` to work around this.

### Option 2: `DispatchQueue.asyncAfter` — Simple One-Shot Delays

For a single, background-thread delayed execution without a Timer object, `asyncAfter` is the lightest option:

```swift
import Foundation

DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
    print("ran after 1 second on a background queue")
}

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    label.text = "updated"   // safe: runs on main queue
}
```

**When to use:** One-shot delays in code that already uses GCD. Avoid it for repeating tasks — you would have to call `asyncAfter` again inside the closure, which makes cancellation difficult and can leak closures.

### Option 3: `Task.sleep` — Structured Concurrency (Recommended for New Code)

Swift's structured concurrency model is the modern choice. `Task.sleep(for:)` suspends the current task without blocking a thread, and cancellation is cooperative and automatic.

**One-shot delay:**
```swift
Task {
    try await Task.sleep(for: .seconds(1))
    print("ran after 1 second")
}
```

**Repeating task with cancellation:**
```swift
let repeatingTask = Task {
    while !Task.isCancelled {
        print("tick")
        try await Task.sleep(for: .milliseconds(500))
    }
}

// Cancel from outside:
repeatingTask.cancel()
```

**Repeating task as an `AsyncStream`:**

When the consumer of a scheduled event is itself async, an `AsyncStream` is the cleanest interface:

```swift
func metronome(period: Duration) -> AsyncStream<Date> {
    AsyncStream { continuation in
        let task = Task {
            while !Task.isCancelled {
                continuation.yield(Date())
                try? await Task.sleep(for: period)
            }
            continuation.finish()
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

// Usage:
for await tick in metronome(period: .seconds(1)) {
    print("tick at \(tick)")
    if shouldStop { break }
}
```

**When to use:** Any new Swift code, server-side Swift, command-line tools, and anywhere you want cancellation to work automatically when the surrounding scope ends.

---

---

## Representing Deferred Results: `Callable` and `Future`

`Timer` and `TimerTask` answer the question *when* to run code. A related but distinct question is: *what do you do with the result once it's ready?* Java 5 introduced `java.util.concurrent.Callable` and `java.util.concurrent.Future` to give that answer a type.

### The conceptual link

A `Timer` fires and forgets — `run()` has no return value and the caller has no handle to the result. `Callable` and `Future` fill that gap:

```
┌─────────────────────────────────────────────────────────┐
│                      your application                   │
│                                                         │
│  val future = TaskFuture { expensiveComputation() }     │
│           │                           ▲                 │
│           │ submit                    │ result          │
│           ▼                           │                 │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │  Callable<V>     │─────▶│  Future<V>       │        │
│  │  (the work)      │      │  (the handle)    │        │
│  └──────────────────┘      └──────────────────┘        │
│                                                         │
│  val result = try future.get()  ← blocks until done    │
└─────────────────────────────────────────────────────────┘
```

Think of `Future<V>` as a *time-shifted container*: you ask for the value now, but the value itself arrives in the future.

### Callable — the throwable Supplier

`java.util.concurrent.Callable<V>` is identical to `java.util.function.Supplier<V>` except that `call()` may throw a checked exception. It represents a unit of work that produces a value.

**Java:**
```java
Callable<Integer> task = () -> {
    Thread.sleep(100);
    return 42;
};
```

**JavApi⁴Swift:**
```swift
import JavApi

let task = java.util.concurrent.AnyCallable<Int> {
    try await Task.sleep(for: .milliseconds(100))
    return 42
}
```

### Future — the result handle

`java.util.concurrent.Future<V>` is a handle to a computation that may not have finished yet. You can:

- poll its status with `isDone()` and `isCancelled()`
- cancel it with `cancel(_:)`
- retrieve its value by blocking with `get()`, which throws `ExecutionException` if the computation failed

**Java:**
```java
ExecutorService exec = Executors.newSingleThreadExecutor();
Future<Integer> future = exec.submit(() -> heavyWork());

// ... do other things ...

try {
    int result = future.get();   // blocks until done
} catch (ExecutionException e) {
    System.err.println("Task failed: " + e.getCause().getMessage());
}
exec.shutdown();
```

**JavApi⁴Swift:**
```swift
import JavApi

let future = java.util.concurrent.TaskFuture<Int> {
    try await heavyWork()
}

// ... do other things ...

do {
    let result = try future.get()   // blocks until done
    print("Result: \(result)")
} catch let e as java.util.concurrent.ExecutionException {
    print("Task failed: \(e.getCause()?.getMessage() ?? "unknown")")
}
```

`TaskFuture` wraps a Swift `Task` internally. On non-WASI platforms `get()` blocks the calling thread using a condition variable, exactly matching Java's semantics. On WASI (single-threaded) `get()` throws `ExecutionException` if the result is not yet available.

### Fixed-delay polling with a Future

`Future` and `Timer` can work together: a `Timer` fires periodically, and each firing submits a `Callable` and stores the `Future` for the next cycle to inspect:

```swift
class PollTask: java.util.TimerTask {
    nonisolated(unsafe) private var lastFuture: java.util.concurrent.TaskFuture<String>? = nil

    func run() {
        // Check previous result if available
        if let f = lastFuture, f.isDone() {
            print("Previous result: \(try? f.get() ?? "error")")
        }
        // Submit new work
        lastFuture = java.util.concurrent.TaskFuture<String> {
            try await fetchLatestData()
        }
    }
}

let timer = java.util.Timer()
timer.schedule(PollTask(), delay: 0, period: 5_000)
```

### Comparison: Timer + Future vs. structured concurrency

| Concern | Timer + Callable/Future | Swift structured concurrency |
|---------|------------------------|------------------------------|
| Schedule recurrence | `timer.schedule(task, delay:period:)` | `while !Task.isCancelled { … sleep … }` |
| Capture the result | `future.get()` (blocking) | `try await task.value` (suspending) |
| Handle failure | `catch ExecutionException` | `catch` in the async scope |
| Cancel | `future.cancel(true)` | `task.cancel()` |
| Block calling thread | Yes (`get()`) | No (suspends, not blocks) |

For new Swift code, prefer structured concurrency — `async`/`await` with `Task` gives you non-blocking suspension, automatic cancellation propagation, and compile-time data-race safety without the overhead of condition variables. Use `Callable`/`Future` when porting existing Java code that already uses `ExecutorService.submit`.

---

## Comparison at a Glance

| Requirement | Java | JavApi⁴Swift | Swift native |
|-------------|------|--------------|--------------|
| One-shot delay | `timer.schedule(task, delay)` | `timer.schedule(task, delay:)` | `Task { try await Task.sleep(for:) … }` |
| Repeating, fixed delay | `timer.schedule(task, delay, period)` | `timer.schedule(task, delay:period:)` | `Task { while … { … sleep … } }` |
| Repeating, fixed rate | `timer.scheduleAtFixedRate(task, delay, period)` | `timer.scheduleAtFixedRate(task, delay:period:)` | `AsyncStream` with tracked next-fire time |
| UI-safe repeating | `SwingUtilities.invokeLater` inside `run()` | `Task { @MainActor in … }` inside `run()` | `Foundation.Timer` on main RunLoop |
| Cancel one task | `task.cancel()` | *(cancel the timer or recreate)* | `task.cancel()` |
| Cancel all tasks | `timer.cancel()` | `timer.cancel()` | `task.cancel()` |
| Simple one-shot | — | — | `DispatchQueue.asyncAfter` |

---

## Pitfalls and Gotchas

### The UI-Thread Trap

Java `Timer` callbacks run on a private daemon thread — **never** on the Event Dispatch Thread. Updating Swing UI from `run()` directly causes races or crashes. The fix is `SwingUtilities.invokeLater`.

In JavApi⁴Swift, callbacks run on a background actor. The pattern is identical: dispatch explicitly to the main actor when you need to update the UI.

```swift
// ✅ correct — dispatch UI work to the main actor
class UpdateLabelTask: java.util.TimerTask {
    func run() {
        Task { @MainActor in
            label.text = "updated"
        }
    }
}

// ❌ wrong — direct UI access from a background actor
class UpdateLabelTask: java.util.TimerTask {
    func run() {
        label.text = "updated"   // data race / compiler error
    }
}
```

### Clock Drift with Fixed Delay

If you use `schedule(_:delay:period:)` and your task takes longer than the period, executions fall further and further behind. For time-sensitive repetition (audio, animation, network polling with a strict budget) use `scheduleAtFixedRate` or the Swift `AsyncStream` pattern with explicit next-fire tracking.

### Forgetting to Cancel

A `Timer` with a repeating task runs until the process exits unless you cancel it. In Java this is mitigated by using daemon threads (`new Timer(true)`). In JavApi⁴Swift, pass `isDaemon: true` to the constructor — but relying on this is a code smell. Cancel explicitly when the owning object is deallocated.

```swift
class Poller {
    private let timer = java.util.Timer()

    init() {
        timer.schedule(PollTask(), delay: 0, period: 5000)
    }

    deinit {
        timer.cancel()   // ← always cancel in deinit
    }
}
```

### Thread Safety of Task State

`TimerTask.run()` may be called from a background actor. Any mutable state your task reads or writes must be protected — use `nonisolated(unsafe)` with an explicit lock, an actor, or make it `@MainActor`-isolated.

---

## Full Example: A Self-Cancelling Countdown

```swift
import JavApi

/// Prints a countdown and cancels itself after reaching zero.
class CountdownTask: java.util.TimerTask {
    nonisolated(unsafe) private var count: Int
    private let timer: java.util.Timer

    init(from start: Int, timer: java.util.Timer) {
        self.count = start
        self.timer = timer
    }

    func run() {
        print(count > 0 ? "\(count)…" : "Go!")
        count -= 1
        if count < 0 { timer.cancel() }
    }
}

let timer = java.util.Timer()
let task  = CountdownTask(from: 3, timer: timer)
timer.schedule(task, delay: 0, period: 1000)

// Output (one line per second):
// 3…
// 2…
// 1…
// Go!
```

The equivalent in idiomatic Swift:

```swift
Task {
    for i in stride(from: 3, through: 0, by: -1) {
        print(i > 0 ? "\(i)…" : "Go!")
        try await Task.sleep(for: .seconds(1))
    }
}
```

Both are correct. Choose the Java-style version when porting existing code; choose the Swift-native version for new code.
