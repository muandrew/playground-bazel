package com.example.sheet

import androidx.compose.animation.core.SpringSpec
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.CornerBasedShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Default styling and behavioral constants for [MultiAnchorBottomSheet], inspired by iOS Human Interface Guidelines.
 */
object SheetDefaults {
    /**
     * Top corner radius for the sheet container (16.dp).
     */
    val CornerRadius: Dp = 16.dp

    /**
     * Default shape of the sheet container with rounded top corners (16.dp).
     */
    val Shape: CornerBasedShape = RoundedCornerShape(
        topStart = CornerRadius,
        topEnd = CornerRadius,
        bottomStart = 0.dp,
        bottomEnd = 0.dp,
    )

    /**
     * Default surface elevation / shadow depth (8.dp).
     */
    val Elevation: Dp = 8.dp

    /**
     * Default width of the drag indicator pill (36.dp).
     */
    val DragIndicatorWidth: Dp = 36.dp

    /**
     * Default height of the drag indicator pill (5.dp).
     */
    val DragIndicatorHeight: Dp = 5.dp

    /**
     * Top padding above the drag indicator pill (8.dp).
     */
    val DragIndicatorTopPadding: Dp = 8.dp

    /**
     * Bottom padding below the drag indicator pill (8.dp).
     */
    val DragIndicatorBottomPadding: Dp = 8.dp

    /**
     * Default color of the drag indicator pill: [Color.Gray] with 40% opacity.
     */
    val DragIndicatorColor: Color = Color.Gray.copy(alpha = 0.4f)

    /**
     * Default shape of the drag indicator pill.
     */
    val DragIndicatorShape: Shape = CircleShape

    /**
     * Default base scrim color.
     */
    val ScrimColor: Color = Color.Black.copy(alpha = 0.32f)

    /**
     * Scrim alpha when the sheet is in [SheetAnchor.Peek] state (0.32f).
     */
    const val ScrimAlphaPeek: Float = 0.32f

    /**
     * Scrim alpha when the sheet is in [SheetAnchor.Compact] state (0.42f).
     */
    const val ScrimAlphaCompact: Float = 0.42f

    /**
     * Scrim alpha when the sheet is in [SheetAnchor.Full] state (0.50f).
     */
    const val ScrimAlphaFull: Float = 0.50f

    /**
     * Default spring animation specification for anchor snapping gestures:
     * dampingRatio = 0.85f, stiffness = 400f.
     */
    val AnimationSpec: SpringSpec<Float> = spring(
        dampingRatio = 0.85f,
        stiffness = 400f,
    )

    /**
     * Default sheet surface color derived from [MaterialTheme.colorScheme.surface].
     */
    val containerColor: Color
        @Composable
        get() = MaterialTheme.colorScheme.surface

    /**
     * Standard drag handle indicator composable matching iOS sheet design.
     *
     * @param modifier Modifier applied to the drag handle.
     * @param width Width of the pill indicator.
     * @param height Height of the pill indicator.
     * @param color Color of the pill indicator.
     * @param shape Shape of the pill indicator.
     */
    @Composable
    fun DragHandle(
        modifier: Modifier = Modifier,
        width: Dp = DragIndicatorWidth,
        height: Dp = DragIndicatorHeight,
        color: Color = DragIndicatorColor,
        shape: Shape = DragIndicatorShape,
    ) {
        Box(
            modifier = modifier
                .padding(top = DragIndicatorTopPadding, bottom = DragIndicatorBottomPadding)
                .size(width = width, height = height)
                .clip(shape)
                .background(color),
        )
    }
}
