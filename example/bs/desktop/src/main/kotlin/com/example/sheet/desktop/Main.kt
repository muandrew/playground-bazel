package com.example.sheet.desktop

import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.example.sheet.demo.DemoApp

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "Bottom Sheet Demo",
        state = rememberWindowState(width = 400.dp, height = 800.dp),
    ) {
        DemoApp()
    }
}
