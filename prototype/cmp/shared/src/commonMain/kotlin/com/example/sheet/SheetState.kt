package com.example.sheet

import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.exponentialDecay
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.gestures.AnchoredDraggableState
import androidx.compose.foundation.gestures.DraggableAnchors
import androidx.compose.foundation.gestures.animateTo
import androidx.compose.foundation.gestures.snapTo
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Stable
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp

/**
 * State holder for [MultiAnchorBottomSheet], managing anchor snapping gestures, animated transitions,
 * and current position offsets.
 *
 * Offset model:
 * - 0 = top of container (Full is positioned at `containerHeight * (1 - fullFraction)`)
 * - maxOffset = [SheetAnchor.Hidden] (`containerHeight`, sheet fully below viewport)
 *
 * Anchors are calculated as:
 * - [SheetAnchor.Hidden]: `containerHeight`
 * - [SheetAnchor.Peek]: `containerHeight - peekHeight`
 * - [SheetAnchor.Compact]: `containerHeight * (1 - compactFraction)`
 * - [SheetAnchor.Full]: `containerHeight * (1 - fullFraction)`
 *
 * @param initialAnchor Initial anchor of the sheet. Defaults to [SheetAnchor.Hidden].
 * @param density Screen density for converting Dp to Px.
 * @param animationSpec Physics animation spec for anchor transitions (defaults to [SheetDefaults.AnimationSpec]).
 * @param confirmValueChange Callback invoked before transitioning to a new anchor. Return false to veto.
 */
@OptIn(ExperimentalFoundationApi::class)
@Stable
class MultiAnchorSheetState(
    val initialAnchor: SheetAnchor = SheetAnchor.Hidden,
    val density: Density? = null,
    val animationSpec: AnimationSpec<Float> = SheetDefaults.AnimationSpec,
    val confirmValueChange: (SheetAnchor) -> Boolean = { true },
    val positionalThreshold: (totalDistance: Float) -> Float = { distance -> distance * 0.5f },
    val velocityThreshold: () -> Float = {
        if (density != null) {
            with(density) { 125.dp.toPx() }
        } else {
            400f
        }
    },
) {
    /**
     * Secondary constructor supporting `initialValue` naming convention.
     */
    constructor(
        initialValue: SheetAnchor,
        density: Density? = null,
        animationSpec: AnimationSpec<Float> = SheetDefaults.AnimationSpec,
        confirmValueChange: (SheetAnchor) -> Boolean = { true },
    ) : this(
        initialAnchor = initialValue,
        density = density,
        animationSpec = animationSpec,
        confirmValueChange = confirmValueChange,
    )

    /**
     * Underlying foundation [AnchoredDraggableState] managing anchors, offsets, and gesture snapping.
     */
    val anchoredDraggableState: AnchoredDraggableState<SheetAnchor> = AnchoredDraggableState(
        initialValue = initialAnchor,
        positionalThreshold = positionalThreshold,
        velocityThreshold = velocityThreshold,
        snapAnimationSpec = animationSpec,
        decayAnimationSpec = exponentialDecay(),
        confirmValueChange = confirmValueChange,
    )

    /**
     * The current anchor where the sheet is settled or settling.
     */
    val currentAnchor: SheetAnchor
        get() = anchoredDraggableState.currentValue

    /**
     * Alias for [currentAnchor] matching Compose conventions.
     */
    val currentValue: SheetAnchor
        get() = currentAnchor

    /**
     * The target anchor that the sheet is moving toward during a gesture or animation.
     */
    val targetAnchor: SheetAnchor
        get() = anchoredDraggableState.targetValue

    /**
     * Alias for [targetAnchor] matching Compose conventions.
     */
    val targetValue: SheetAnchor
        get() = targetAnchor

    /**
     * Current pixel offset of the sheet's top edge from the top of the container.
     * Evaluates to [Float.NaN] until anchors have been initialized.
     */
    val offset: Float
        get() = anchoredDraggableState.offset

    /**
     * Safe current pixel offset of the sheet, returning 0f if [offset] is [Float.NaN].
     */
    val currentOffset: Float
        get() = if (anchoredDraggableState.offset.isNaN()) 0f else anchoredDraggableState.offset

    /**
     * True if the sheet is visible (not fully dismissed at [SheetAnchor.Hidden]).
     */
    val isVisible: Boolean
        get() = currentAnchor != SheetAnchor.Hidden || targetAnchor != SheetAnchor.Hidden

    /**
     * True if the sheet is at the [SheetAnchor.Full] detent.
     */
    val isExpanded: Boolean
        get() = currentAnchor == SheetAnchor.Full

    /**
     * Fractional progress between the current anchor and target anchor (0f..1f).
     * Returns 1f when the sheet is settled at [currentAnchor] == [targetAnchor].
     */
    val progress: Float
        get() {
            val from = currentAnchor
            val to = targetAnchor
            if (from == to) return 1f
            return progress(from = from, to = to)
        }

    /**
     * Calculates the fractional progress (0f..1f) between [from] anchor and [to] anchor.
     */
    fun progress(from: SheetAnchor, to: SheetAnchor): Float {
        val anchors = anchoredDraggableState.anchors
        val fromOffset = anchors.positionOf(from)
        val toOffset = anchors.positionOf(to)
        if (fromOffset.isNaN() || toOffset.isNaN() || fromOffset == toOffset) return 0f
        val current = offset
        if (current.isNaN()) return 0f
        val fraction = (current - fromOffset) / (toOffset - fromOffset)
        return fraction.coerceIn(0f, 1f)
    }

    /**
     * Updates the draggable anchors using raw pixel values and fractions.
     *
     * Offset mapping:
     * - [SheetAnchor.Hidden] = containerHeight
     * - [SheetAnchor.Peek] = containerHeight - peekHeightPx
     * - [SheetAnchor.Compact] = containerHeight * (1 - compactFraction)
     * - [SheetAnchor.Full] = containerHeight * (1 - fullFraction)
     */
    fun updateAnchors(
        containerHeight: Float,
        peekHeightPx: Float,
        compactFraction: Float,
        fullFraction: Float,
    ) {
        if (containerHeight <= 0f) return
        val newAnchors = DraggableAnchors {
            SheetAnchor.Hidden at containerHeight
            SheetAnchor.Peek at (containerHeight - peekHeightPx).coerceAtLeast(0f)
            SheetAnchor.Compact at (containerHeight * (1f - compactFraction)).coerceAtLeast(0f)
            SheetAnchor.Full at (containerHeight * (1f - fullFraction)).coerceAtLeast(0f)
        }
        anchoredDraggableState.updateAnchors(newAnchors)
    }

    /**
     * Updates the draggable anchors using container height, density, and [SheetAnchorConfig].
     */
    fun updateAnchors(
        containerHeight: Float,
        density: Density,
        config: SheetAnchorConfig,
    ) {
        val peekHeightPx = with(density) { config.peekHeight.toPx() }
        updateAnchors(
            containerHeight = containerHeight,
            peekHeightPx = peekHeightPx,
            compactFraction = config.compactFraction,
            fullFraction = config.fullFraction,
        )
    }

    /**
     * Directly updates the underlying [DraggableAnchors].
     */
    fun updateAnchors(newAnchors: DraggableAnchors<SheetAnchor>) {
        anchoredDraggableState.updateAnchors(newAnchors)
    }

    /**
     * Animates the sheet to the specified [anchor] using spring physics.
     */
    suspend fun animateTo(anchor: SheetAnchor) {
        anchoredDraggableState.animateTo(anchor)
    }

    /**
     * Snaps the sheet immediately to the specified [anchor] without animation.
     */
    suspend fun snapTo(anchor: SheetAnchor) {
        anchoredDraggableState.snapTo(anchor)
    }

    /**
     * Shows the sheet by animating to the specified [anchor] (defaults to [SheetAnchor.Compact]).
     */
    suspend fun show(anchor: SheetAnchor = SheetAnchor.Compact) {
        require(anchor != SheetAnchor.Hidden) { "The target anchor cannot be Hidden when calling show()" }
        animateTo(anchor)
    }

    /**
     * Hides the sheet by animating to [SheetAnchor.Hidden].
     */
    suspend fun hide() {
        animateTo(SheetAnchor.Hidden)
    }

    /**
     * Expands the sheet to the specified [anchor], typically [SheetAnchor.Full].
     */
    suspend fun expandTo(anchor: SheetAnchor = SheetAnchor.Full) {
        animateTo(anchor)
    }

    /**
     * Settles the sheet at the target anchor based on fling velocity or proximity.
     */
    suspend fun settle(velocity: Float = 0f) {
        val current = offset
        if (current.isNaN()) return
        val anchors = anchoredDraggableState.anchors
        val sortedAnchors = listOf(SheetAnchor.Full, SheetAnchor.Compact, SheetAnchor.Peek, SheetAnchor.Hidden)
            .filter { !anchors.positionOf(it).isNaN() }
            .sortedBy { anchors.positionOf(it) }

        val velThreshold = 500f
        val target = when {
            velocity > velThreshold -> {
                sortedAnchors.firstOrNull { anchors.positionOf(it) > current } ?: sortedAnchors.last()
            }
            velocity < -velThreshold -> {
                sortedAnchors.lastOrNull { anchors.positionOf(it) < current } ?: sortedAnchors.first()
            }
            else -> {
                anchors.closestAnchor(current) ?: currentAnchor
            }
        }
        animateTo(target)
    }

    companion object {
        fun Saver(
            animationSpec: AnimationSpec<Float> = SheetDefaults.AnimationSpec,
            confirmValueChange: (SheetAnchor) -> Boolean = { true },
            density: Density,
        ): Saver<MultiAnchorSheetState, SheetAnchor> = Saver(
            save = { it.currentAnchor },
            restore = { savedAnchor ->
                MultiAnchorSheetState(
                    initialAnchor = savedAnchor,
                    density = density,
                    animationSpec = animationSpec,
                    confirmValueChange = confirmValueChange,
                )
            },
        )
    }
}

/**
 * Creates and remembers a [MultiAnchorSheetState] across recompositions.
 *
 * @param initialAnchor Initial anchor of the sheet (defaults to [SheetAnchor.Hidden]).
 * @param animationSpec Animation spec for anchor transitions (defaults to [SheetDefaults.AnimationSpec]).
 * @param confirmValueChange Callback to veto state changes.
 */
@Composable
fun rememberMultiAnchorSheetState(
    initialAnchor: SheetAnchor = SheetAnchor.Hidden,
    animationSpec: AnimationSpec<Float> = SheetDefaults.AnimationSpec,
    confirmValueChange: (SheetAnchor) -> Boolean = { true },
): MultiAnchorSheetState {
    val density = LocalDensity.current
    return rememberSaveable(
        saver = MultiAnchorSheetState.Saver(
            animationSpec = animationSpec,
            confirmValueChange = confirmValueChange,
            density = density,
        ),
    ) {
        MultiAnchorSheetState(
            initialAnchor = initialAnchor,
            density = density,
            animationSpec = animationSpec,
            confirmValueChange = confirmValueChange,
        )
    }
}
