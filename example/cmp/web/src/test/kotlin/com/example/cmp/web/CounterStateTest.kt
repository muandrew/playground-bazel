package com.example.cmp.web

import com.example.cmp.libb.CounterButtonState

/** Checks shared counter behavior without starting a browser or Compose viewport. */
fun main() {
    val state = CounterButtonState()
    check(state.count == 0)
    check(state.label == "Count: 0")
    check(state.statusText == "Button clicked 0 times")

    check(state.onClick() == 1)
    check(state.label == "Count: 1")
    check(state.statusText == "Button clicked 1 time")

    check(state.onClick() == 2)
    check(state.label == "Count: 2")
    check(state.statusText == "Button clicked 2 times")

    val restoredState = CounterButtonState(initialCount = 7)
    check(restoredState.onClick() == 8)
    check(restoredState.label == "Count: 8")
    println("Shared counter state checks passed (Node.js; browser rendering not exercised).")
}
