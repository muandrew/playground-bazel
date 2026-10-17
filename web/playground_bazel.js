/**
 * Compose Multiplatform — iOS Multi-Anchor Bottom Sheet Demo
 * Web (Wasm / JS) Canvas & DOM Interactive Engine
 */

(function () {
    const root = document.getElementById('ComposeTarget');
    if (!root) return;

    // Track items matching DemoApp.kt
    const backgroundTracks = [
        { num: 1, title: "Bohemian Rhapsody", artist: "Queen • A Night at the Opera", duration: "5:55" },
        { num: 2, title: "Hotel California", artist: "Eagles • Hotel California", duration: "6:30" },
        { num: 3, title: "Stairway to Heaven", artist: "Led Zeppelin • Led Zeppelin IV", duration: "8:02" },
        { num: 4, title: "Sweet Child O' Mine", artist: "Guns N' Roses • Appetite for Destruction", duration: "5:56" },
        { num: 5, title: "Comfortably Numb", artist: "Pink Floyd • The Wall", duration: "6:23" },
        { num: 6, title: "Smells Like Teen Spirit", artist: "Nirvana • Nevermind", duration: "5:01" },
        { num: 7, title: "Dream On", artist: "Aerosmith • Aerosmith", duration: "4:28" },
        { num: 8, title: "Back in Black", artist: "AC/DC • Back in Black", duration: "4:15" },
        { num: 9, title: "Like a Rolling Stone", artist: "Bob Dylan • Highway 61 Revisited", duration: "6:13" },
        { num: 10, title: "Heroes", artist: "David Bowie • \"Heroes\"", duration: "6:07" },
        { num: 11, title: "Under Pressure", artist: "Queen & David Bowie • Hot Space", duration: "4:08" },
        { num: 12, title: "Don't Stop Me Now", artist: "Queen • Jazz", duration: "3:29" }
    ];

    const albumTracks = [
        { num: 1, title: "Death on Two Legs (Dedicated to...)", duration: "3:43" },
        { num: 2, title: "Lazing on a Sunday Afternoon", duration: "1:07" },
        { num: 3, title: "I'm in Love with My Car", duration: "3:05" },
        { num: 4, title: "You're My Best Friend", duration: "2:52" },
        { num: 5, title: "'39", duration: "3:31" },
        { num: 6, title: "Sweet Lady", duration: "4:04" },
        { num: 7, title: "Seaside Rendezvous", duration: "2:16" },
        { num: 8, title: "The Prophet's Song", duration: "8:21" },
        { num: 9, title: "Love of My Life", duration: "3:39" },
        { num: 10, title: "Good Company", duration: "3:23" },
        { num: 11, title: "Bohemian Rhapsody", duration: "5:55" },
        { num: 12, title: "God Save the Queen", duration: "1:15" }
    ];

    const lyricsText = `Is this the real life?
Is this just fantasy?
Caught in a landslide,
No escape from reality.
Open your eyes,
Look up to the skies and see...

I'm just a poor boy, I need no sympathy,
Because I'm easy come, easy go,
Little high, little low,
Any way the wind blows doesn't really matter to me, to me.

Mama, just killed a man,
Put a gun against his head,
Pulled my trigger, now he's dead...`;

    // Anchor states matching SheetAnchor.kt
    const Anchors = {
        Hidden: 'Hidden',
        Peek: 'Peek',
        Compact: 'Compact',
        Full: 'Full'
    };

    let currentAnchor = Anchors.Peek;
    let isPlaying = false;
    let isDragging = false;
    let dragStartY = 0;
    let sheetStartOffset = 0;
    let currentOffset = 0;
    let lastDragY = 0;
    let lastDragTime = 0;
    let dragVelocity = 0;

    // Config matching SheetAnchorConfig
    const config = {
        peekHeight: 80,
        compactFraction: 0.45,
        fullFraction: 0.92,
        previewOverflow: 44
    };

    // Build DOM structure
    root.innerHTML = `
        <style>
            .app-container {
                position: relative;
                width: 100%;
                height: 100%;
                background: #121212;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                user-select: none;
            }
            .top-bar {
                height: 56px;
                background: #1E1E1E;
                display: flex;
                align-items: center;
                padding: 0 16px;
                border-bottom: 1px solid #282828;
                flex-shrink: 0;
                z-index: 10;
            }
            .top-bar-title {
                font-size: 18px;
                font-weight: 700;
                color: #FFFFFF;
                letter-spacing: -0.3px;
            }
            .content-scroll {
                flex: 1;
                overflow-y: auto;
                padding: 16px;
                display: flex;
                flex-direction: column;
                gap: 12px;
                padding-bottom: 96px;
            }
            .card {
                background: #282828;
                border-radius: 14px;
                padding: 16px;
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            .card-title {
                font-size: 15px;
                font-weight: 700;
                color: #FFFFFF;
            }
            .card-subtitle {
                font-size: 12px;
                font-weight: 600;
                color: #1DB954;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .btn-group {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 6px;
            }
            .btn {
                background: #383838;
                border: none;
                border-radius: 8px;
                color: #FFFFFF;
                font-size: 12px;
                font-weight: 600;
                padding: 9px 0;
                cursor: pointer;
                transition: background 0.15s, transform 0.1s;
                text-align: center;
            }
            .btn:hover {
                background: #444444;
            }
            .btn:active {
                transform: scale(0.97);
            }
            .btn.active {
                background: #1DB954;
                color: #000000;
            }
            .section-title {
                font-size: 15px;
                font-weight: 700;
                color: #FFFFFF;
                margin-top: 6px;
            }
            .track-row {
                background: #1E1E1E;
                border-radius: 10px;
                padding: 12px 14px;
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .track-num {
                width: 22px;
                font-size: 13px;
                color: #888888;
                font-weight: 600;
                text-align: center;
            }
            .track-info {
                flex: 1;
                min-width: 0;
            }
            .track-title {
                font-size: 14px;
                font-weight: 600;
                color: #FFFFFF;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .track-artist {
                font-size: 12px;
                color: #B3B3B3;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                margin-top: 2px;
            }
            .track-dur {
                font-size: 12px;
                color: #888888;
                font-weight: 500;
            }

            /* Scrim overlay */
            .scrim {
                position: absolute;
                inset: 0;
                background: #000000;
                opacity: 0;
                pointer-events: none;
                transition: opacity 0.25s ease-out;
                z-index: 20;
            }
            .scrim.active {
                pointer-events: auto;
            }

            /* iOS Bottom Sheet Surface */
            .sheet-surface {
                position: absolute;
                left: 0;
                right: 0;
                top: 0;
                height: 100%;
                background: #1E1E1E;
                border-top-left-radius: 18px;
                border-top-right-radius: 18px;
                box-shadow: 0 -8px 32px rgba(0, 0, 0, 0.6);
                z-index: 30;
                display: flex;
                flex-direction: column;
                will-change: transform;
                touch-action: none;
            }
            .drag-handle-zone {
                width: 100%;
                padding: 10px 0 8px;
                display: flex;
                justify-content: center;
                cursor: grab;
                flex-shrink: 0;
            }
            .drag-pill {
                width: 36px;
                height: 5px;
                border-radius: 3px;
                background: rgba(255, 255, 255, 0.3);
            }

            /* Peek content */
            .peek-content {
                padding: 2px 20px 10px;
                display: flex;
                align-items: center;
                gap: 10px;
                flex-shrink: 0;
            }
            .peek-icon {
                font-size: 18px;
                color: #1DB954;
            }
            .peek-title {
                font-size: 14px;
                font-weight: 700;
                color: #FFFFFF;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            /* Compact content */
            .compact-content {
                padding: 4px 20px 12px;
                display: flex;
                flex-direction: column;
                gap: 12px;
                flex-shrink: 0;
                transition: opacity 0.2s, max-height 0.25s;
            }
            .compact-header {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }
            .song-title {
                font-size: 18px;
                font-weight: 700;
                color: #FFFFFF;
            }
            .song-artist {
                font-size: 13px;
                color: #B3B3B3;
            }
            .playback-controls {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 24px;
            }
            .control-btn {
                background: transparent;
                border: none;
                color: #FFFFFF;
                font-size: 20px;
                cursor: pointer;
                width: 36px;
                height: 36px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                transition: background 0.15s;
            }
            .control-btn:hover {
                background: rgba(255, 255, 255, 0.1);
            }
            .control-btn.play {
                background: #FFFFFF;
                color: #000000;
                width: 44px;
                height: 44px;
                font-size: 16px;
            }
            .control-btn.play:hover {
                background: #1DB954;
            }
            .progress-container {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            .progress-bar-bg {
                width: 100%;
                height: 4px;
                background: #333333;
                border-radius: 2px;
                overflow: hidden;
            }
            .progress-bar-fill {
                width: 35%;
                height: 100%;
                background: #1DB954;
            }
            .progress-times {
                display: flex;
                justify-content: space-between;
                font-size: 10px;
                color: #777777;
            }

            /* Preview overflow container in Compact mode */
            .preview-overflow {
                height: 44px;
                overflow: hidden;
                position: relative;
                mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 100%);
                -webkit-mask-image: linear-gradient(to bottom, rgba(0,0,0,1) 0%, rgba(0,0,0,0) 100%);
                padding: 0 20px;
                flex-shrink: 0;
            }

            /* Full content scrollable area */
            .full-content-scroll {
                flex: 1;
                overflow-y: auto;
                padding: 10px 20px 32px;
                display: flex;
                flex-direction: column;
                gap: 16px;
                touch-action: pan-y;
            }
            .album-art-box {
                width: 180px;
                height: 180px;
                margin: 0 auto;
                border-radius: 14px;
                background: linear-gradient(135deg, #2a2a2a, #1a1a1a);
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 8px;
                box-shadow: 0 10px 24px rgba(0, 0, 0, 0.4);
                border: 1px solid #333333;
            }
            .album-art-icon {
                font-size: 40px;
                color: #1DB954;
            }
            .album-art-label {
                font-size: 12px;
                font-weight: 600;
                color: #888888;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .lyrics-box {
                background: #252525;
                border-radius: 12px;
                padding: 16px;
                font-size: 13px;
                line-height: 1.6;
                color: #D1D1D1;
                white-space: pre-line;
                font-style: italic;
            }
        </style>

        <div class="app-container">
            <!-- Top bar -->
            <div class="top-bar">
                <span class="top-bar-title">Sheet Demo</span>
            </div>

            <!-- Main scrollable content behind sheet -->
            <div class="content-scroll" id="backgroundList">
                <div class="card">
                    <div class="card-title">Anchor Controls</div>
                    <div class="card-subtitle" id="currentAnchorLabel">Current anchor: Peek</div>
                    <div class="btn-group">
                        <button class="btn" id="btnHidden" data-anchor="Hidden">Hidden</button>
                        <button class="btn active" id="btnPeek" data-anchor="Peek">Peek</button>
                        <button class="btn" id="btnCompact" data-anchor="Compact">Compact</button>
                        <button class="btn" id="btnFull" data-anchor="Full">Full</button>
                    </div>
                </div>

                <div class="section-title">Music Library</div>
                <div id="libraryContainer"></div>
            </div>

            <!-- Scrim overlay -->
            <div class="scrim" id="sheetScrim"></div>

            <!-- Bottom Sheet Surface -->
            <div class="sheet-surface" id="bottomSheet">
                <div class="drag-handle-zone" id="dragZone">
                    <div class="drag-pill"></div>
                </div>

                <!-- 1. Peek Content -->
                <div class="peek-content" id="peekSection">
                    <span class="peek-icon">♪</span>
                    <span class="peek-title">Now Playing — Bohemian Rhapsody</span>
                </div>

                <!-- 2. Compact Content -->
                <div class="compact-content" id="compactSection">
                    <div class="compact-header">
                        <div class="song-title">Bohemian Rhapsody</div>
                        <div class="song-artist">Queen • A Night at the Opera</div>
                    </div>
                    <div class="playback-controls">
                        <button class="control-btn" id="btnPrev" title="Previous">⏮</button>
                        <button class="control-btn play" id="btnPlay" title="Play/Pause">▶</button>
                        <button class="control-btn" id="btnNext" title="Next">⏭</button>
                    </div>
                    <div class="progress-container">
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill"></div>
                        </div>
                        <div class="progress-times">
                            <span>2:04</span>
                            <span>5:55</span>
                        </div>
                    </div>
                </div>

                <!-- Preview overflow in Compact mode -->
                <div class="preview-overflow" id="previewOverflowSection">
                    <div style="font-size: 13px; font-weight: 700; color: #FFF; margin-bottom: 4px;">Track List</div>
                    <div style="font-size: 12px; color: #BBB;">1. Death on Two Legs • 3:43</div>
                </div>

                <!-- 3. Full Content -->
                <div class="full-content-scroll" id="fullScrollSection">
                    <div class="album-art-box">
                        <div class="album-art-icon">🎵</div>
                        <div class="album-art-label">Album Art</div>
                    </div>

                    <div class="section-title">Track List</div>
                    <div id="albumTracksContainer"></div>

                    <div class="section-title" style="margin-top: 8px;">Lyrics</div>
                    <div class="lyrics-box" id="lyricsContent"></div>
                </div>
            </div>
        </div>
    `;

    // Populate track lists
    const libraryContainer = document.getElementById('libraryContainer');
    libraryContainer.innerHTML = backgroundTracks.map(t => `
        <div class="track-row" style="margin-bottom: 8px;">
            <div class="track-num">${t.num}</div>
            <div class="track-info">
                <div class="track-title">${t.title}</div>
                <div class="track-artist">${t.artist}</div>
            </div>
            <div class="track-dur">${t.duration}</div>
        </div>
    `).join('');

    const albumTracksContainer = document.getElementById('albumTracksContainer');
    albumTracksContainer.innerHTML = albumTracks.map(t => `
        <div class="track-row" style="margin-bottom: 6px; background: #252525;">
            <div class="track-num">${t.num}</div>
            <div class="track-info">
                <div class="track-title">${t.title}</div>
            </div>
            <div class="track-dur">${t.duration}</div>
        </div>
    `).join('');

    document.getElementById('lyricsContent').textContent = lyricsText;

    // DOM Elements
    const sheet = document.getElementById('bottomSheet');
    const scrim = document.getElementById('sheetScrim');
    const dragZone = document.getElementById('dragZone');
    const peekSection = document.getElementById('peekSection');
    const compactSection = document.getElementById('compactSection');
    const previewOverflowSection = document.getElementById('previewOverflowSection');
    const fullScrollSection = document.getElementById('fullScrollSection');
    const currentAnchorLabel = document.getElementById('currentAnchorLabel');
    const btnPlay = document.getElementById('btnPlay');

    const buttons = {
        [Anchors.Hidden]: document.getElementById('btnHidden'),
        [Anchors.Peek]: document.getElementById('btnPeek'),
        [Anchors.Compact]: document.getElementById('btnCompact'),
        [Anchors.Full]: document.getElementById('btnFull')
    };

    // Calculate anchor offsets
    function getContainerHeight() {
        return root.clientHeight || 800;
    }

    function getAnchorOffset(anchor) {
        const H = getContainerHeight();
        switch (anchor) {
            case Anchors.Hidden:
                return H;
            case Anchors.Peek:
                return H - config.peekHeight;
            case Anchors.Compact:
                return H * (1 - config.compactFraction);
            case Anchors.Full:
                return H * (1 - config.fullFraction);
            default:
                return H - config.peekHeight;
        }
    }

    // Interpolate scrim alpha matching SheetLayout.kt calculateScrimAlpha()
    function updateScrim(offset) {
        const H = getContainerHeight();
        const peekOffset = H - config.peekHeight;
        const fullOffset = H * (1 - config.fullFraction);

        let alpha = 0;
        if (offset >= H) {
            alpha = 0;
        } else if (offset >= peekOffset) {
            const fraction = (H - offset) / (H - peekOffset);
            alpha = fraction * 0.32;
        } else if (offset >= fullOffset) {
            const fraction = (peekOffset - offset) / (peekOffset - fullOffset);
            alpha = 0.32 + fraction * (0.50 - 0.32);
        } else {
            alpha = 0.50;
        }

        scrim.style.opacity = Math.max(0, Math.min(0.50, alpha));
        if (alpha > 0.01) {
            scrim.classList.add('active');
        } else {
            scrim.classList.remove('active');
        }
    }

    // Update section visibility
    function updateContentVisibility(anchor) {
        currentAnchorLabel.textContent = `Current anchor: ${anchor}`;

        // Update button active state
        Object.entries(buttons).forEach(([a, btn]) => {
            if (btn) btn.classList.toggle('active', a === anchor);
        });

        if (anchor === Anchors.Hidden) {
            sheet.style.visibility = 'hidden';
            compactSection.style.display = 'none';
            previewOverflowSection.style.display = 'none';
            fullScrollSection.style.display = 'none';
        } else if (anchor === Anchors.Peek) {
            sheet.style.visibility = 'visible';
            compactSection.style.display = 'none';
            previewOverflowSection.style.display = 'none';
            fullScrollSection.style.display = 'none';
        } else if (anchor === Anchors.Compact) {
            sheet.style.visibility = 'visible';
            compactSection.style.display = 'flex';
            previewOverflowSection.style.display = 'block';
            fullScrollSection.style.display = 'none';
        } else if (anchor === Anchors.Full) {
            sheet.style.visibility = 'visible';
            compactSection.style.display = 'flex';
            previewOverflowSection.style.display = 'none';
            fullScrollSection.style.display = 'flex';
        }
    }

    // Spring animation transition to anchor
    function animateToAnchor(anchor, withSpring = true) {
        currentAnchor = anchor;
        const targetOffset = getAnchorOffset(anchor);
        currentOffset = targetOffset;

        if (withSpring) {
            sheet.style.transition = 'transform 0.42s cubic-bezier(0.18, 0.9, 0.28, 1.0)';
        } else {
            sheet.style.transition = 'none';
        }

        sheet.style.transform = `translate3d(0, ${Math.round(targetOffset)}px, 0)`;
        updateScrim(targetOffset);
        updateContentVisibility(anchor);
    }

    // Button click listeners
    Object.entries(buttons).forEach(([anchor, btn]) => {
        if (btn) {
            btn.addEventListener('click', () => {
                animateToAnchor(anchor, true);
            });
        }
    });

    // Scrim dismiss click
    scrim.addEventListener('click', () => {
        animateToAnchor(Anchors.Hidden, true);
    });

    // Play/Pause toggle
    btnPlay.addEventListener('click', (e) => {
        e.stopPropagation();
        isPlaying = !isPlaying;
        btnPlay.textContent = isPlaying ? '⏸' : '▶';
    });

    // Touch and Pointer Drag Handling with Cooperative Scrolling
    function onPointerDown(e) {
        // If clicking inside full scroll content and scrolled down, let internal scroll handle
        if (currentAnchor === Anchors.Full && fullScrollSection.contains(e.target) && fullScrollSection.scrollTop > 0) {
            return;
        }

        isDragging = true;
        sheet.style.transition = 'none';
        dragStartY = e.clientY || (e.touches && e.touches[0].clientY) || 0;
        sheetStartOffset = currentOffset;
        lastDragY = dragStartY;
        lastDragTime = Date.now();
        dragVelocity = 0;

        window.addEventListener('pointermove', onPointerMove, { passive: false });
        window.addEventListener('pointerup', onPointerUp);
        window.addEventListener('pointercancel', onPointerUp);
    }

    function onPointerMove(e) {
        if (!isDragging) return;

        const clientY = e.clientY || (e.touches && e.touches[0].clientY) || 0;
        const delta = clientY - dragStartY;
        const now = Date.now();
        const dt = now - lastDragTime;
        if (dt > 0) {
            dragVelocity = (clientY - lastDragY) / dt;
            lastDragY = clientY;
            lastDragTime = now;
        }

        // Cooperative scrolling check: if in Full mode and dragging up, allow normal scroll
        if (currentAnchor === Anchors.Full && delta < 0 && fullScrollSection.scrollTop < fullScrollSection.scrollHeight - fullScrollSection.clientHeight) {
            return;
        }

        const rawOffset = sheetStartOffset + delta;
        const minOffset = getAnchorOffset(Anchors.Full) - 20; // gentle overscroll resistance
        const maxOffset = getAnchorOffset(Anchors.Hidden);

        currentOffset = Math.max(minOffset, Math.min(maxOffset, rawOffset));
        sheet.style.transform = `translate3d(0, ${Math.round(currentOffset)}px, 0)`;
        updateScrim(currentOffset);

        // Dynamically adjust content while dragging
        const compactOffset = getAnchorOffset(Anchors.Compact);
        if (currentOffset <= compactOffset + 50 && compactSection.style.display === 'none') {
            compactSection.style.display = 'flex';
        }
        if (e.cancelable) e.preventDefault();
    }

    function onPointerUp() {
        if (!isDragging) return;
        isDragging = false;
        window.removeEventListener('pointermove', onPointerMove);
        window.removeEventListener('pointerup', onPointerUp);
        window.removeEventListener('pointercancel', onPointerUp);

        // Snap to best anchor based on position and fling velocity
        const H = getContainerHeight();
        const fullOff = getAnchorOffset(Anchors.Full);
        const compactOff = getAnchorOffset(Anchors.Compact);
        const peekOff = getAnchorOffset(Anchors.Peek);
        const hiddenOff = getAnchorOffset(Anchors.Hidden);

        let targetAnchor = currentAnchor;

        if (dragVelocity > 0.6) {
            // Fling downwards
            if (currentOffset < compactOff) targetAnchor = Anchors.Compact;
            else if (currentOffset < peekOff) targetAnchor = Anchors.Peek;
            else targetAnchor = Anchors.Hidden;
        } else if (dragVelocity < -0.6) {
            // Fling upwards
            if (currentOffset > peekOff) targetAnchor = Anchors.Peek;
            else if (currentOffset > compactOff) targetAnchor = Anchors.Compact;
            else targetAnchor = Anchors.Full;
        } else {
            // Distance threshold snapping
            const dists = [
                { anchor: Anchors.Full, dist: Math.abs(currentOffset - fullOff) },
                { anchor: Anchors.Compact, dist: Math.abs(currentOffset - compactOff) },
                { anchor: Anchors.Peek, dist: Math.abs(currentOffset - peekOff) },
                { anchor: Anchors.Hidden, dist: Math.abs(currentOffset - hiddenOff) }
            ];
            dists.sort((a, b) => a.dist - b.dist);
            targetAnchor = dists[0].anchor;
        }

        animateToAnchor(targetAnchor, true);
    }

    // Attach drag listener to handle and peek zone
    dragZone.addEventListener('pointerdown', onPointerDown);
    peekSection.addEventListener('pointerdown', onPointerDown);

    // Window resize handler
    window.addEventListener('resize', () => {
        animateToAnchor(currentAnchor, false);
    });

    // Initialize to Peek anchor
    setTimeout(() => {
        animateToAnchor(Anchors.Peek, false);
    }, 50);

    console.log("Compose Multiplatform Bottom Sheet Web Engine Initialized");
})();
