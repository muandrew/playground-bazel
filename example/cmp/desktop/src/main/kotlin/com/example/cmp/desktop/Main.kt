package com.example.cmp.desktop

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
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import com.example.cmp.libb.CounterButtonState
import com.example.cmp.libb.SharedCounterButton
import com.example.cmp.libb.rememberCounterButtonState

@Composable
fun CounterApp(state: CounterButtonState = rememberCounterButtonState()) {
    MaterialTheme(colorScheme = darkColorScheme()) {
        Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            Column(
                modifier = Modifier.fillMaxSize().padding(32.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = "Compose Multiplatform Desktop",
                    fontSize = 24.sp,
                    color = MaterialTheme.colorScheme.primary,
                )
                Text(
                    text = "Kotlin 2.3.21 • Compose 1.9.5 • Bzlmod",
                    fontSize = 13.sp,
                    color = Color.Gray,
                )
                Spacer(modifier = Modifier.height(28.dp))

                // Shared Compose UI Button whose UI is rendered by Compose
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

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "Compose Multiplatform Desktop - Shared Counter Button",
    ) {
        CounterApp()
    }
}
