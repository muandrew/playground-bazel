package com.example.cmp.desktop

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import com.example.cmp.libb.SheetManager

@Composable
fun AppContent(manager: SheetManager) {
    var summary by remember { mutableStateOf(manager.formatSummary()) }

    MaterialTheme(colorScheme = darkColorScheme()) {
        Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            Column(
                modifier = Modifier.fillMaxSize().padding(24.dp),
                verticalArrangement = Arrangement.SpaceBetween,
            ) {
                Column {
                    Text(
                        text = "Compose Multiplatform Desktop",
                        fontSize = 22.sp,
                        color = MaterialTheme.colorScheme.primary,
                    )
                    Text(
                        text = "Kotlin 2.3.21 • Compose 1.9.5 • Bzlmod",
                        fontSize = 13.sp,
                        color = Color.Gray,
                    )
                    Spacer(modifier = Modifier.height(16.dp))

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color(0xFF242424), RoundedCornerShape(12.dp))
                            .padding(16.dp),
                    ) {
                        Text(text = summary, color = Color.White)
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Button(onClick = {
                        manager.togglePlayback()
                        summary = manager.formatSummary()
                    }) {
                        Text(if (manager.isPlaying) "Pause" else "Play")
                    }
                    Button(onClick = {
                        manager.transitionTo("Peek")
                        summary = manager.formatSummary()
                    }) {
                        Text("Peek")
                    }
                    Button(onClick = {
                        manager.transitionTo("Compact")
                        summary = manager.formatSummary()
                    }) {
                        Text("Compact")
                    }
                    Button(onClick = {
                        manager.transitionTo("Full")
                        summary = manager.formatSummary()
                    }) {
                        Text("Full")
                    }
                }
            }
        }
    }
}

fun main() = application {
    val manager = remember { SheetManager() }
    Window(
        onCloseRequest = ::exitApplication,
        title = "CMP Desktop Demo - App A",
    ) {
        AppContent(manager)
    }
}
