package com.example.cmp.libc

/**
 * Foundational domain models provided by Library C.
 * Used by Library B and App A across Android, Desktop, and Web.
 */
data class Track(
    val id: String,
    val title: String,
    val artist: String,
    val durationSec: Int,
)

data class SheetDisplayState(
    val anchorName: String,
    val progress: Float,
    val isExpanded: Boolean,
)

object CmpDefaults {
    val sampleTrack = Track(
        id = "cmp-001",
        title = "Compose Multiplatform on Bazel 8",
        artist = "Kotlin 2.3.21 & Compose 1.9.5",
        durationSec = 245,
    )
    val initialSheetState = SheetDisplayState(
        anchorName = "Peek",
        progress = 0.25f,
        isExpanded = false,
    )
}
