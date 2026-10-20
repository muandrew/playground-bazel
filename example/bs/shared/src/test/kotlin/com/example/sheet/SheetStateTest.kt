package com.example.sheet

import androidx.compose.animation.core.snap
import androidx.compose.runtime.MonotonicFrameClock
import androidx.compose.ui.unit.Density
import kotlin.js.unsafeCast
import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.startCoroutine
import org.w3c.dom.events.Event
import org.w3c.dom.events.EventListener

private class ImmediateFrameClock : MonotonicFrameClock {
    override val key: CoroutineContext.Key<*> get() = MonotonicFrameClock
    private var frameTimeNanos = 0L

    override suspend fun <R> withFrameNanos(onFrame: (Long) -> R): R {
        frameTimeNanos += 16_000_000L
        return onFrame(frameTimeNanos)
    }
}

/** Node-friendly checks for detent math, scrim interpolation, and state transitions. */
fun main() {
    fun near(actual: Float, expected: Float) = kotlin.math.abs(actual - expected) < 0.001f

    // Exercise the legacy factory required by Compose Foundation's clipboard
    // event handler when linked against kotlinx-browser 0.5.0.
    var handledEvent: Event? = null
    val event = js("({ type: 'compat-test' })").unsafeCast<Event>()
    val listener = EventListener { handledEvent = it }
    listener.handleEvent(event)
    check(handledEvent === event)

    val config = SheetAnchorConfig()
    check(config.peekHeight.value == 80f)
    check(config.compactFraction == 0.45f)
    check(config.fullFraction == 0.92f)
    check(config.resolvePreviewOverflow(androidx.compose.ui.unit.Dp(800f)).value == 40f)
    check(
        SheetAnchorConfig(previewOverflowPercentage = 0.1f)
            .resolvePreviewOverflow(androidx.compose.ui.unit.Dp(800f)).value == 80f,
    )
    check(runCatching { SheetAnchorConfig(compactFraction = 0.6f, fullFraction = 0.5f) }.isFailure)
    check(runCatching { SheetAnchorConfig(previewOverflowPercentage = 1.1f) }.isFailure)

    // A 1000 px viewport at density 1 has anchors at 1000, 920, 550, and 80 px.
    val state = MultiAnchorSheetState(density = Density(1f))
    state.updateAnchors(
        containerHeight = 1000f,
        density = Density(1f),
        config = config,
    )
    val anchors = state.anchoredDraggableState.anchors
    check(near(anchors.positionOf(SheetAnchor.Hidden), 1000f))
    check(near(anchors.positionOf(SheetAnchor.Peek), 920f))
    check(near(anchors.positionOf(SheetAnchor.Compact), 550f))
    check(near(anchors.positionOf(SheetAnchor.Full), 80f))
    state.updateAnchors(
        containerHeight = 800f,
        density = Density(1f),
        config = config,
    )
    check(near(state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Hidden), 800f))
    check(near(state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Peek), 720f))
    check(near(state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Compact), 440f))
    check(near(state.anchoredDraggableState.anchors.positionOf(SheetAnchor.Full), 64f))
    state.updateAnchors(1000f, Density(1f), config)

    check(calculateScrimAlpha(1000f, 1000f, 80f, 0.92f) == 0f)
    check(near(calculateScrimAlpha(920f, 1000f, 80f, 0.92f), 0.32f))
    check(near(calculateScrimAlpha(550f, 1000f, 80f, 0.92f), 0.42f))
    check(near(calculateScrimAlpha(80f, 1000f, 80f, 0.92f), 0.50f))
    check(near(calculateScrimAlpha(735f, 1000f, 80f, 0.92f), 0.37f))
    check(calculateScrimAlpha(Float.NaN, 1000f, 80f, 0.92f) == 0f)
    check(near(calculateScrimAlpha(-20f, 1000f, 80f, 0.92f), 0.50f))
    check(calculateScrimAlpha(100f, 0f, 80f, 0.92f) == 0f)

    var finished = false
    val checkTransitions: suspend () -> Unit = {
        state.snapTo(SheetAnchor.Peek)
        check(state.currentAnchor == SheetAnchor.Peek)
        check(state.isVisible)
        state.snapTo(SheetAnchor.Compact)
        check(state.currentAnchor == SheetAnchor.Compact)
        state.snapTo(SheetAnchor.Full)
        check(state.isExpanded)
        state.snapTo(SheetAnchor.Hidden)
        check(!state.isVisible)

        // A custom 100 px/s threshold controls low-velocity settle decisions.
        val thresholdState = MultiAnchorSheetState(
            initialAnchor = SheetAnchor.Hidden,
            density = Density(1f),
            animationSpec = snap(),
            velocityThreshold = { 100f },
        )
        thresholdState.updateAnchors(1000f, Density(1f), config)
        thresholdState.snapTo(SheetAnchor.Peek)
        thresholdState.settle(90f)
        check(thresholdState.currentAnchor == SheetAnchor.Peek)
        thresholdState.settle(-150f)
        check(thresholdState.currentAnchor == SheetAnchor.Compact)

        // Vetoed programmatic transitions leave the sheet at its current detent.
        val guardedState = MultiAnchorSheetState(
            initialAnchor = SheetAnchor.Hidden,
            density = Density(1f),
            animationSpec = snap(),
            confirmValueChange = { it != SheetAnchor.Full },
        )
        guardedState.updateAnchors(1000f, Density(1f), config)
        guardedState.snapTo(SheetAnchor.Peek)
        guardedState.animateTo(SheetAnchor.Full)
        check(guardedState.currentAnchor == SheetAnchor.Peek)
        finished = true
    }
    checkTransitions.startCoroutine(object : Continuation<Unit> {
        override val context = EmptyCoroutineContext + ImmediateFrameClock()
        override fun resumeWith(result: Result<Unit>) {
            result.getOrThrow()
        }
    })
    check(finished) { "snapTo should complete synchronously when no competing mutation is active" }
    println("Bottom sheet state checks passed (Node.js; browser rendering not exercised).")
}
