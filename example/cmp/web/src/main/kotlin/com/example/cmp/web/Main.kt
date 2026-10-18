package com.example.cmp.web

import com.example.cmp.libb.SheetManager

fun main() {
    println("==========================================================")
    println(" Compose Multiplatform Web (JS/Wasm) App A")
    println(" Powered by Kotlin 2.3.21 and Compose 1.9.5 Bzlmod Rules")
    println("==========================================================")

    val manager = SheetManager()
    println("Initial:    " + manager.formatSummary())

    manager.togglePlayback()
    println("After Play: " + manager.formatSummary())

    manager.transitionTo("Compact")
    println("To Compact: " + manager.formatSummary())

    manager.transitionTo("Full")
    println("To Full:    " + manager.formatSummary())

    println("Web application initialized successfully.")
}
