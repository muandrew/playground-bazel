package com.example.sheet

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.anchoredDraggable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

/**
 * Modifier that applies a vertical fade-out gradient mask using [graphicsLayer] and [BlendMode.DstIn].
 */
private fun Modifier.fadingEdge(): Modifier = this
    .graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)
    .drawWithContent {
        drawContent()
        drawRect(
            brush = Brush.verticalGradient(
                0.0f to Color.Black,
                1.0f to Color.Transparent,
            ),
            blendMode = BlendMode.DstIn,
        )
    }

/**
 * iOS-style multi-anchor bottom sheet component with detent behavior.
 *
 * Mimics Apple's iOS sheet design with 4 discrete anchor states:
 * - [SheetAnchor.Hidden]: Completely dismissed off-screen.
 * - [SheetAnchor.Peek]: Title and drag indicator (~80dp).
 * - [SheetAnchor.Compact]: Title, compact controls, and optional preview of full content (~45% screen).
 * - [SheetAnchor.Full]: Full scrollable content (~92% screen).
 *
 * @param state Controller for the sheet anchors, offsets, and animation.
 * @param onDismiss Invoked when the sheet is dismissed via scrim click or drag.
 * @param modifier Modifier applied to the bottom sheet layout.
 * @param config Height and fraction configuration for the 4 detents.
 * @param peekContent Content shown in Peek, Compact, and Full detents (e.g., title bar).
 * @param compactContent Content shown in Compact and Full detents (e.g., playback controls, summary).
 * @param fullContent Optional extensive scrollable content displayed in Full detent and previewed in Compact detent.
 * @param scrimColor Base color of the dimmer scrim.
 * @param containerColor Background color of the sheet surface.
 * @param shape Shape of the sheet surface with rounded top corners.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun MultiAnchorBottomSheet(
    state: MultiAnchorSheetState,
    onDismiss: () -> Unit = {},
    modifier: Modifier = Modifier,
    config: SheetAnchorConfig = SheetAnchorConfig(),
    peekContent: @Composable ColumnScope.() -> Unit,
    compactContent: @Composable ColumnScope.() -> Unit = {},
    fullContent: (@Composable ColumnScope.() -> Unit)? = null,
    scrimColor: Color = SheetDefaults.ScrimColor,
    containerColor: Color = MaterialTheme.colorScheme.surface,
    shape: Shape = SheetDefaults.Shape,
) {
    val coroutineScope = rememberCoroutineScope()

    // Nested scroll connection coordinating internal scroll with sheet dragging
    val nestedScrollConnection = remember(state) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                val delta = available.y
                val fullOffset = state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Full)
                val currentOffset = state.offset
                // When dragging up (delta < 0), if sheet is not yet at Full, let sheet expand first
                return if (delta < 0 && !currentOffset.isNaN() && !fullOffset.isNaN() && currentOffset > fullOffset) {
                    val consumed = state.anchoredDraggableState.dispatchRawDelta(delta)
                    Offset(0f, consumed)
                } else {
                    Offset.Zero
                }
            }

            override fun onPostScroll(
                consumed: Offset,
                available: Offset,
                source: NestedScrollSource,
            ): Offset {
                // When scrolling down (available.y > 0) and inner scroll didn't consume it (at top of list),
                // pull sheet down towards Compact/Peek/Hidden.
                return if (available.y > 0 && source == NestedScrollSource.Drag) {
                    val consumedDelta = state.anchoredDraggableState.dispatchRawDelta(available.y)
                    Offset(0f, consumedDelta)
                } else {
                    Offset.Zero
                }
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                val toFling = available.y
                val currentOffset = state.offset
                val fullOffset = state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Full)
                return if (toFling < 0 && !currentOffset.isNaN() && !fullOffset.isNaN() && currentOffset > fullOffset) {
                    state.settle(toFling)
                    available
                } else {
                    Velocity.Zero
                }
            }

            override suspend fun onPostFling(consumed: Velocity, available: Velocity): Velocity {
                state.settle(available.y)
                return available
            }
        }
    }

    SheetLayout(
        state = state,
        onDismissRequest = {
            coroutineScope.launch {
                state.hide()
                onDismiss()
            }
        },
        modifier = modifier,
        config = config,
        scrimColor = scrimColor,
    ) { layoutScope ->
        val currentAnchor = state.currentAnchor
        val targetAnchor = state.targetAnchor

        // If completely hidden and not currently animating, do not render surface
        if (currentAnchor != SheetAnchor.Hidden || targetAnchor != SheetAnchor.Hidden) {

        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .offset {
                    if (state.anchoredDraggableState.offset.isNaN()) {
                        IntOffset(0, 0)
                    } else {
                        IntOffset(0, state.anchoredDraggableState.offset.roundToInt())
                    }
                }
                .anchoredDraggable(
                    state = state.anchoredDraggableState,
                    orientation = Orientation.Vertical,
                )
                .nestedScroll(nestedScrollConnection),
            shape = shape,
            color = containerColor,
            shadowElevation = SheetDefaults.Elevation,
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                // Centered rounded rect drag indicator pill
                Box(
                    modifier = Modifier
                        .padding(
                            top = SheetDefaults.DragIndicatorTopPadding,
                            bottom = SheetDefaults.DragIndicatorBottomPadding,
                        )
                        .size(
                            width = SheetDefaults.DragIndicatorWidth,
                            height = SheetDefaults.DragIndicatorHeight,
                        )
                        .clip(RoundedCornerShape(SheetDefaults.DragIndicatorHeight / 2))
                        .background(SheetDefaults.DragIndicatorColor),
                )

                // 1. Peek content (always visible when non-hidden)
                peekContent()

                // 2. Compact content (visible when in Compact or Full)
                val isCompactOrFull = currentAnchor in listOf(SheetAnchor.Compact, SheetAnchor.Full) ||
                    targetAnchor in listOf(SheetAnchor.Compact, SheetAnchor.Full)

                AnimatedVisibility(
                    visible = isCompactOrFull,
                    enter = fadeIn() + expandVertically(),
                    exit = fadeOut() + shrinkVertically(),
                ) {
                    Column(modifier = Modifier.fillMaxWidth()) {
                        compactContent()
                    }
                }

                // 3. Full content or preview overflow
                if (fullContent != null) {
                    val isFullMode = currentAnchor == SheetAnchor.Full || targetAnchor == SheetAnchor.Full

                    if (isFullMode) {
                        // Full expanded content: scrollable area filling remaining sheet height
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f, fill = false),
                        ) {
                            Column(modifier = Modifier.fillMaxWidth()) {
                                fullContent()
                            }
                        }
                    } else if (isCompactOrFull) {
                        val overflowHeight = config.resolvePreviewOverflow(layoutScope.maxHeight)
                        if (overflowHeight > 0.dp) {
                            // Compact preview: clipped to overflowHeight with fading edge gradient
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(overflowHeight)
                                    .clipToBounds()
                                    .fadingEdge(),
                            ) {
                                Column(modifier = Modifier.fillMaxWidth()) {
                                    fullContent()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
}
