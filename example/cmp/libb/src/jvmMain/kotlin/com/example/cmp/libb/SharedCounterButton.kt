package com.example.cmp.libb

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Shared Compose UI Counter Button for JVM targets (Desktop and Android).
 * Renders an interactive Material 3 Button with reactive count display.
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
