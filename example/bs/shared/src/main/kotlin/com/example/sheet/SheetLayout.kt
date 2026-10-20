package com.example.sheet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.BoxWithConstraintsScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

/**
 * Calculates the interpolated scrim opacity based on current sheet offset and detents.
 *
 * The alpha interpolates through Hidden, Peek, Compact, and Full anchor values.
 */
fun calculateScrimAlpha(
    currentOffset: Float,
    containerHeight: Float,
    peekHeightPx: Float,
    fullFraction: Float,
    alphaPeek: Float = SheetDefaults.ScrimAlphaPeek,
    compactFraction: Float = 0.45f,
    alphaCompact: Float = SheetDefaults.ScrimAlphaCompact,
    alphaFull: Float = SheetDefaults.ScrimAlphaFull,
): Float {
    if (containerHeight <= 0f || currentOffset.isNaN()) return 0f

    // Pair each detent's top offset with its scrim alpha, then interpolate between
    // neighboring detents. Sorting also keeps unusual container/peek combinations safe.
    val detents = listOf(
        containerHeight to 0f,
        (containerHeight - peekHeightPx).coerceAtLeast(0f) to alphaPeek,
        (containerHeight * (1f - compactFraction)).coerceAtLeast(0f) to alphaCompact,
        (containerHeight * (1f - fullFraction)).coerceAtLeast(0f) to alphaFull,
    ).sortedBy { it.first }
    if (currentOffset <= detents.first().first) return detents.first().second.coerceIn(0f, alphaFull)
    if (currentOffset >= detents.last().first) return detents.last().second.coerceIn(0f, alphaFull)

    for (index in 0 until detents.lastIndex) {
        val (lowerOffset, lowerAlpha) = detents[index]
        val (upperOffset, upperAlpha) = detents[index + 1]
        if (currentOffset <= upperOffset) {
            val range = upperOffset - lowerOffset
            if (range <= 0f) return upperAlpha.coerceIn(0f, alphaFull)
            val fraction = (currentOffset - lowerOffset) / range
            return (lowerAlpha + fraction * (upperAlpha - lowerAlpha)).coerceIn(0f, alphaFull)
        }
    }
    return 0f
}

/**
 * Layout and measurement container for bottom sheets.
 *
 * Measures container bounds using [BoxWithConstraints], dynamically updates anchor positions in [MultiAnchorSheetState],
 * renders an interactive interpolated scrim overlay, and positions the sheet surface using the state offset.
 *
 * @param state State controlling the multi-anchor bottom sheet.
 * @param onDismissRequest Invoked when the scrim overlay is tapped.
 * @param modifier Modifier applied to the outer layout container.
 * @param config Detent height and fraction configurations.
 * @param scrimColor Color of the background scrim.
 * @param content Optional background content rendered behind the sheet.
 * @param sheetContent Composable lambda rendering the sheet inside the layout scope.
 */
@Composable
fun SheetLayout(
    state: MultiAnchorSheetState,
    onDismissRequest: () -> Unit = {},
    modifier: Modifier = Modifier,
    config: SheetAnchorConfig = SheetAnchorConfig(),
    scrimColor: Color = SheetDefaults.ScrimColor,
    content: (@Composable () -> Unit)? = null,
    sheetContent: @Composable (BoxWithConstraintsScope) -> Unit,
) {
    val density = LocalDensity.current
    val coroutineScope = rememberCoroutineScope()

    BoxWithConstraints(modifier = modifier.fillMaxSize()) {
        val containerHeightPx = constraints.maxHeight.toFloat()
        val peekHeightPx = with(density) { config.peekHeight.toPx() }

        // Update anchors as container height changes
        SideEffect {
            state.updateAnchors(
                containerHeight = containerHeightPx,
                density = density,
                config = config,
            )
        }

        // 1. Optional background content behind the sheet
        content?.invoke()

        // 2. Scrim overlay with interpolated alpha
        val currentOffset = state.offset
        val scrimAlpha = calculateScrimAlpha(
            currentOffset = currentOffset,
            containerHeight = containerHeightPx,
            peekHeightPx = peekHeightPx,
            fullFraction = config.fullFraction,
            alphaPeek = SheetDefaults.ScrimAlphaPeek,
            compactFraction = config.compactFraction,
            alphaCompact = SheetDefaults.ScrimAlphaCompact,
            alphaFull = SheetDefaults.ScrimAlphaFull,
        )

        val isDismissible = state.isVisible && scrimAlpha > 0.001f
        if (isDismissible) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .graphicsLayer { alpha = scrimAlpha }
                    .background(scrimColor.copy(alpha = 1f))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                    ) {
                        coroutineScope.launch {
                            state.hide()
                            onDismissRequest()
                        }
                    },
            )
        }

        // 3. Sheet content container
        sheetContent(this)
    }
}

/**
 * Convenience layout that positions the sheet surface automatically using the offset from [MultiAnchorSheetState].
 */
@Composable
fun AnchoredSheetLayout(
    state: MultiAnchorSheetState,
    modifier: Modifier = Modifier,
    config: SheetAnchorConfig = SheetAnchorConfig(),
    scrimColor: Color = SheetDefaults.ScrimColor,
    onDismissRequest: () -> Unit = {},
    sheetContent: @Composable () -> Unit,
) {
    SheetLayout(
        state = state,
        onDismissRequest = onDismissRequest,
        modifier = modifier,
        config = config,
        scrimColor = scrimColor,
        content = null,
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .offset {
                    val y = if (state.anchoredDraggableState.offset.isNaN()) {
                        0
                    } else {
                        state.anchoredDraggableState.offset.roundToInt()
                    }
                    IntOffset(0, y)
                },
        ) {
            sheetContent()
        }
    }
}
