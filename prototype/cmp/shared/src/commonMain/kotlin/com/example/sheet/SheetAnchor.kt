package com.example.sheet

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Anchor states for the iOS-style multi-anchor bottom sheet.
 *
 * Mimics Apple's iOS sheet detents (see https://developer.apple.com/design/human-interface-guidelines/sheets):
 * - [Hidden]: The sheet is fully dismissed below the screen viewport. Nothing is rendered.
 * - [Peek]: Small detent showing the title and drag indicator (~80dp).
 * - [Compact]: Medium detent displaying title, header info, and an optional preview of full content (~45% screen).
 * - [Full]: Expanded detent displaying the full scrollable content (~92% screen).
 */
enum class SheetAnchor {
    /** Sheet is completely hidden off-screen and dismissed. Nothing rendered. */
    Hidden,

    /** Peek height detent (~80dp), showing title and drag indicator. */
    Peek,

    /** Compact detent (~45% screen height), showing header and optional content preview. */
    Compact,

    /** Full detent (~92% screen height), showing full scrollable content. */
    Full,
}

/**
 * Configuration parameters for the multi-anchor bottom sheet detents.
 *
 * @property peekHeight Height of the sheet in [SheetAnchor.Peek] state. Defaults to 80.dp.
 * @property compactFraction Fractional height of the screen covered in [SheetAnchor.Compact] state. Defaults to 0.45f (45%).
 * @property fullFraction Fractional height of the screen covered in [SheetAnchor.Full] state. Defaults to 0.92f (92%).
 * @property previewOverflow How much of the [SheetAnchor.Full] content peeks out in [SheetAnchor.Compact] state. Defaults to 40.dp.
 * @property previewOverflowPercentage Optional percentage/fraction (0.0f..1.0f) to preview in [SheetAnchor.Compact] state. If set, takes precedence over [previewOverflow].
 */
data class SheetAnchorConfig(
    val peekHeight: Dp = 80.dp,
    val compactFraction: Float = 0.45f,
    val fullFraction: Float = 0.92f,
    val previewOverflow: Dp = 40.dp,
    val previewOverflowPercentage: Float? = null,
) {
    init {
        require(peekHeight >= 0.dp) { "peekHeight must be non-negative, but was $peekHeight" }
        require(compactFraction in 0f..1f) { "compactFraction must be in range [0.0, 1.0], but was $compactFraction" }
        require(fullFraction in 0f..1f) { "fullFraction must be in range [0.0, 1.0], but was $fullFraction" }
        require(compactFraction <= fullFraction) {
            "compactFraction ($compactFraction) must be less than or equal to fullFraction ($fullFraction)"
        }
        require(previewOverflow >= 0.dp) { "previewOverflow must be non-negative, but was $previewOverflow" }
        previewOverflowPercentage?.let {
            require(it in 0f..1f) { "previewOverflowPercentage must be in range [0.0, 1.0], but was $it" }
        }
    }

    /**
     * Resolves the actual overflow height in [Dp], either calculated from [previewOverflowPercentage]
     * relative to [containerHeight] or falling back to the fixed [previewOverflow] value.
     */
    fun resolvePreviewOverflow(containerHeight: Dp): Dp {
        return previewOverflowPercentage?.let { containerHeight * it } ?: previewOverflow
    }
}
