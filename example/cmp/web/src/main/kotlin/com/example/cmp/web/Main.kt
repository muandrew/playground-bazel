package com.example.cmp.web

import androidx.compose.runtime.Composable
import com.example.cmp.libb.CounterButtonState
import com.example.cmp.libb.DomElement
import com.example.cmp.libb.SharedCounterButton
import com.example.cmp.libb.rememberCounterButtonState
import com.example.cmp.libb.renderComposeWeb

/**
 * Compose Web App UI rendering the shared Compose Multiplatform Counter Button.
 */
@Composable
fun WebCounterApp(state: CounterButtonState = rememberCounterButtonState()) {
    DomElement(
        tagName = "div",
        className = "counter-card",
    ) {
        DomElement(
            tagName = "h2",
            className = "counter-title",
            text = "Compose Multiplatform Web",
        )
        DomElement(
            tagName = "p",
            className = "counter-subtitle",
            text = "Kotlin 2.3.21 • Compose 1.9.5 • Bzlmod",
        )
        // Shared Compose Button rendered directly by Compose Runtime
        SharedCounterButton(state = state)
        DomElement(
            tagName = "p",
            id = "shared-counter-status",
            className = "counter-status",
            text = state.statusText,
        )
    }
}

fun main() {
    println("==========================================================")
    println(" Compose Multiplatform Web (JS/Wasm) App A")
    println(" Compose-Rendered Shared Counter Button")
    println("==========================================================")

    val isBrowser: Boolean = js("typeof window !== 'undefined' && typeof document !== 'undefined'") as Boolean
    if (isBrowser) {
        val mount = {
            println("Mounting Compose Web Composition into #root element...")
            renderComposeWeb(containerId = "root") {
                WebCounterApp()
            }
            println("Compose Web Composition successfully mounted.")
        }

        val doc: dynamic = js("document")
        if (doc.readyState == "loading") {
            doc.addEventListener("DOMContentLoaded", { mount() })
        } else {
            mount()
        }
    } else {
        // Headless / Node execution: verify Compose Composition execution
        println("Running headless Compose Web Composition verification...")
        val counterState = CounterButtonState(initialCount = 0)
        val composition = renderComposeWeb(containerId = "headless-root") {
            WebCounterApp(state = counterState)
        }

        println("Initial button label: ${counterState.label}")
        check(counterState.count == 0) { "Expected count 0 but was ${counterState.count}" }

        val c1 = counterState.onClick()
        println("Click 1 -> ${counterState.label} (${counterState.statusText})")
        check(c1 == 1) { "Expected count 1 but was $c1" }

        val c2 = counterState.onClick()
        println("Click 2 -> ${counterState.label} (${counterState.statusText})")
        check(c2 == 2) { "Expected count 2 but was $c2" }

        val c3 = counterState.onClick()
        println("Click 3 -> ${counterState.label} (${counterState.statusText})")
        check(c3 == 3) { "Expected count 3 but was $c3" }

        composition.dispose()
        println("Headless Compose Web verification passed successfully!")
    }
}
