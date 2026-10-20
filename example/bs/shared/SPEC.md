# Shared bottom sheet

This is a Compose Multiplatform port of the reusable sheet behavior developed in
`prototype/cmp`. The source has no dependency on prototype target or package
labels; it is exposed as `com.example.sheet` for web, desktop, and Android.

The sheet has four anchors, ordered by visible height: Hidden, Peek (80 dp),
Compact (45% of the viewport), and Full (92%). Compact previews 40 dp of the
full content by default; callers may instead set a preview fraction. The sheet
uses a spring with damping ratio 0.85 and stiffness 400, 16 dp top corners, 8 dp
elevation, and a 36 by 5 dp drag handle.

The scrim fades in from Hidden through Peek and interpolates through the
Compact alpha before reaching Full. A downward drag/fling can settle at Hidden
and reports dismissal after the state becomes hidden. In Full, the surface is
measured to the configured visible height and gives the remaining space to the
scrollable content; upward scroll expands the sheet first, while downward
scroll at the top hands movement back to the sheet.

`src/test` checks detent offsets and resizing, preview configuration, scrim
interpolation, state transitions, transition vetoes, custom velocity thresholds,
and the JS event-listener adapter under Node.js. It does not exercise browser
rendering.
