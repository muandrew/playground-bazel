package com.example.cmp.libb

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue

/**
 * Shared Compose Multiplatform Counter state and presentation model.
 * Shared across Android, Desktop, and Web applications.
 */
class CounterButtonState(initialCount: Int = 0) {
    var count by mutableStateOf(initialCount)
        private set

    fun onClick(): Int {
        count++
        return count
    }

    val label: String
        get() = "Count: $count"

    val statusText: String
        get() = "Button clicked $count ${if (count == 1) "time" else "times"}"
}

/**
 * Creates and remembers a CounterButtonState within a Composable tree.
 */
@Composable
fun rememberCounterButtonState(initialCount: Int = 0): CounterButtonState {
    return remember { CounterButtonState(initialCount) }
}
