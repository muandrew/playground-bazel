package com.example.cmp.libb

import com.example.cmp.libc.CmpDefaults
import com.example.cmp.libc.SheetDisplayState
import com.example.cmp.libc.Track

/**
 * Service and UI coordinator provided by Library B.
 * Depends on Library C domain models and provides logic for App A.
 */
class SheetManager(
    val track: Track = CmpDefaults.sampleTrack,
    initialState: SheetDisplayState = CmpDefaults.initialSheetState,
) {
    var state: SheetDisplayState = initialState
        private set

    var isPlaying: Boolean = false
        private set

    fun togglePlayback(): Boolean {
        isPlaying = !isPlaying
        return isPlaying
    }

    fun transitionTo(anchor: String): SheetDisplayState {
        val (prog, expanded) = when (anchor) {
            "Hidden" -> Pair(0.0f, false)
            "Peek" -> Pair(0.25f, false)
            "Compact" -> Pair(0.5f, false)
            "Full" -> Pair(1.0f, true)
            else -> Pair(state.progress, state.isExpanded)
        }
        state = SheetDisplayState(
            anchorName = anchor,
            progress = prog,
            isExpanded = expanded,
        )
        return state
    }

    fun formatSummary(): String {
        val status = if (isPlaying) "Playing" else "Paused"
        return "[$status] ${track.title} by ${track.artist} | Anchor: ${state.anchorName} (${(state.progress * 100).toInt()}%)"
    }
}
