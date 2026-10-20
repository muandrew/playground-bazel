package com.example.sheet.web

import androidx.compose.runtime.SideEffect
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.ComposeViewport
import com.example.sheet.demo.DemoApp
import kotlinx.browser.document

@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    ComposeViewport(viewportContainerId = "root") {
        DemoApp()
        SideEffect {
            document.getElementById("loading")?.setAttribute("hidden", "")
            document.getElementById("root")?.setAttribute("data-compose-state", "ready")
        }
    }
}
