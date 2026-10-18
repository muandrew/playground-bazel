package com.example.cmp.web

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.ComposeViewport
import com.example.cmp.libb.CounterButtonState
import com.example.cmp.libb.SharedCounterButton
import com.example.cmp.libb.rememberCounterButtonState
import kotlinx.browser.document

/**
 * Compose Multiplatform Web Application UI.
 * Renders the exact same Compose Material 3 UI and button onto HTML5 Canvas via Skiko.
 */
@Composable
fun WebCounterApp(state: CounterButtonState = rememberCounterButtonState()) {
    MaterialTheme(colorScheme = darkColorScheme()) {
        Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            Column(
                modifier = Modifier.fillMaxSize().padding(32.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = "Compose Multiplatform Web (Canvas)",
                    fontSize = 24.sp,
                    color = MaterialTheme.colorScheme.primary,
                )
                Text(
                    text = "Kotlin 2.3.21 • Compose 1.9.5 (Skiko) • Bzlmod",
                    fontSize = 13.sp,
                    color = Color.Gray,
                )
                Spacer(modifier = Modifier.height(28.dp))

                // Unified Compose Material 3 Button from commonMain
                SharedCounterButton(state = state, modifier = Modifier.padding(8.dp))

                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    text = state.statusText,
                    fontSize = 14.sp,
                    color = Color.LightGray,
                )
            }
        }
    }
}

@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    println("==========================================================")
    println(" Compose Multiplatform Web (Canvas/Skiko) App A")
    println(" Shared Material 3 Button")
    println("==========================================================")

    val isBrowser: Boolean = js("typeof window !== 'undefined' && typeof document !== 'undefined'") as Boolean
    if (isBrowser) {
        val root = document.getElementById("root")
        if (root != null) {
            println("Attaching Skiko ComposeViewport to #root element...")
            ComposeViewport(root) {
                WebCounterApp()
            }
            println("ComposeViewport mounted successfully.")
        } else {
            println("Warning: #root element not found in DOM.")
        }
    } else {
        // Headless execution under Node.js: verify counter model and state
        println("Running headless verification under Node.js...")
        val state = CounterButtonState(initialCount = 0)
        println("Initial button label: ${state.label}")
        check(state.count == 0) { "Expected count 0 but was ${state.count}" }

        val c1 = state.onClick()
        println("Click 1 -> ${state.label} (${state.statusText})")
        check(c1 == 1) { "Expected count 1 but was $c1" }

        val c2 = state.onClick()
        println("Click 2 -> ${state.label} (${state.statusText})")
        check(c2 == 2) { "Expected count 2 but was $c2" }

        val c3 = state.onClick()
        println("Click 3 -> ${state.label} (${state.statusText})")
        check(c3 == 3) { "Expected count 3 but was $c3" }

        println("Headless verification passed successfully!")
    }
}
