package com.example.sheet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
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
 * - When at or below [SheetAnchor.Hidden]: alpha is 0.0
 * - When at [SheetAnchor.Peek]: alpha is [alphaPeek] (0.32)
 * - When between [SheetAnchor.Peek] and [SheetAnchor.Full]: alpha linearly interpolates to [alphaFull] (0.50)
 */
fun calculateScrimAlpha(
    currentOffset: Float,
    containerHeight: Float,
    peekHeightPx: Float,
    fullFraction: Float,
    alphaPeek: Float = SheetDefaults.ScrimAlphaPeek,
    alphaFull: Float = SheetDefaults.ScrimAlphaFull,
): Float {
    if (containerHeight <= 0f || currentOffset.isNaN()) return 0f

    val hiddenOffset = containerHeight
    val peekOffset = (containerHeight - peekHeightPx).coerceAtLeast(0f)
    val fullOffset = (containerHeight * (1f - fullFraction)).coerceAtLeast(0f)

    return when {
        currentOffset >= hiddenOffset -> 0f
        currentOffset in peekOffset..hiddenOffset -> {
            val range = hiddenOffset - peekOffset
            if (range <= 0f) 0f
            else {
                val fraction = (hiddenOffset - currentOffset) / range
                fraction * alphaPeek
            }
        }
        currentOffset in fullOffset..peekOffset -> {
            val range = peekOffset - fullOffset
            if (range <= 0f) alphaPeek
            else {
                val fraction = (peekOffset - currentOffset) / range
                alphaPeek + fraction * (alphaFull - alphaPeek)
            }
        }
        else -> alphaFull // offset < fullOffset (overscrolled past Full)
    }.coerceIn(0f, alphaFull)
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
