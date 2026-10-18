package com.example.cmp.libb

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

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

/**
 * Unified Compose Multiplatform Material 3 Counter Button.
 * The EXACT same Composable function and UI are shared and rendered directly by Compose
 * across Android, Desktop, and Web (Canvas/Skiko).
 */
@Composable
fun SharedCounterButton(
    state: CounterButtonState = rememberCounterButtonState(),
    modifier: Modifier = Modifier,
    onClick: () -> Unit = { state.onClick() },
) {
    Button(
        onClick = onClick,
        modifier = modifier,
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary,
        ),
    ) {
        Text(
            text = state.label,
            fontSize = 18.sp,
            color = Color.Black,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        )
    }
}
