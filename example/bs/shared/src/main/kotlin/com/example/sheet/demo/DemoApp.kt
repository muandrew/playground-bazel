package com.example.sheet.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.sheet.MultiAnchorBottomSheet
import com.example.sheet.SheetAnchor
import com.example.sheet.rememberMultiAnchorSheetState
import kotlinx.coroutines.launch

private val MusicDarkColorScheme = darkColorScheme(
    primary = Color(0xFF1DB954),
    onPrimary = Color(0xFF000000),
    primaryContainer = Color(0xFF137333),
    onPrimaryContainer = Color(0xFFE8F5E9),
    secondary = Color(0xFF1ED760),
    onSecondary = Color(0xFF000000),
    secondaryContainer = Color(0xFF282828),
    onSecondaryContainer = Color(0xFFB3B3B3),
    background = Color(0xFF121212),
    onBackground = Color(0xFFFFFFFF),
    surface = Color(0xFF1E1E1E),
    onSurface = Color(0xFFFFFFFF),
    surfaceVariant = Color(0xFF282828),
    onSurfaceVariant = Color(0xFFB3B3B3),
    outline = Color(0xFF3E3E3E),
    outlineVariant = Color(0xFF2A2A2A)
)

private data class TrackItem(
    val number: Int,
    val title: String,
    val artist: String = "Queen",
    val duration: String
)

private val BackgroundTracks = listOf(
    TrackItem(1, "Bohemian Rhapsody", "Queen • A Night at the Opera", "5:55"),
    TrackItem(2, "Hotel California", "Eagles • Hotel California", "6:30"),
    TrackItem(3, "Stairway to Heaven", "Led Zeppelin • Led Zeppelin IV", "8:02"),
    TrackItem(4, "Sweet Child O' Mine", "Guns N' Roses • Appetite for Destruction", "5:56"),
    TrackItem(5, "Comfortably Numb", "Pink Floyd • The Wall", "6:23"),
    TrackItem(6, "Smells Like Teen Spirit", "Nirvana • Nevermind", "5:01"),
    TrackItem(7, "Dream On", "Aerosmith • Aerosmith", "4:28"),
    TrackItem(8, "Back in Black", "AC/DC • Back in Black", "4:15"),
    TrackItem(9, "Like a Rolling Stone", "Bob Dylan • Highway 61 Revisited", "6:13"),
    TrackItem(10, "Heroes", "David Bowie • \"Heroes\"", "6:07"),
    TrackItem(11, "Under Pressure", "Queen & David Bowie • Hot Space", "4:08"),
    TrackItem(12, "Don't Stop Me Now", "Queen • Jazz", "3:29")
)

private val FullAlbumTracks = listOf(
    TrackItem(1, "Death on Two Legs (Dedicated to...)", duration = "3:43"),
    TrackItem(2, "Lazing on a Sunday Afternoon", duration = "1:07"),
    TrackItem(3, "I'm in Love with My Car", duration = "3:05"),
    TrackItem(4, "You're My Best Friend", duration = "2:52"),
    TrackItem(5, "'39", duration = "3:31"),
    TrackItem(6, "Sweet Lady", duration = "4:04"),
    TrackItem(7, "Seaside Rendezvous", duration = "2:16"),
    TrackItem(8, "The Prophet's Song", duration = "8:21"),
    TrackItem(9, "Love of My Life", duration = "3:39"),
    TrackItem(10, "Good Company", duration = "3:23"),
    TrackItem(11, "Bohemian Rhapsody", duration = "5:55"),
    TrackItem(12, "God Save the Queen", duration = "1:15")
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DemoApp() {
    MaterialTheme(colorScheme = MusicDarkColorScheme) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            val sheetState = rememberMultiAnchorSheetState(initialAnchor = SheetAnchor.Peek)
            val scope = rememberCoroutineScope()
            var isPlaying by remember { mutableStateOf(false) }

            Box(modifier = Modifier.fillMaxSize()) {
                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = {
                                Text(
                                    text = "Sheet Demo",
                                    fontWeight = FontWeight.Bold
                                )
                            },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = MaterialTheme.colorScheme.surface,
                                titleContentColor = MaterialTheme.colorScheme.onSurface
                            )
                        )
                    }
                ) { paddingValues ->
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(paddingValues),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        item {
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                colors = CardDefaults.cardColors(
                                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                                ),
                                shape = RoundedCornerShape(12.dp)
                            ) {
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(16.dp),
                                    verticalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Text(
                                        text = "Anchor Controls",
                                        style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                    Text(
                                        text = "Current anchor: ${sheetState.currentAnchor.name}",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.primary,
                                        fontWeight = FontWeight.Medium
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))

                                    Button(
                                        onClick = {
                                            scope.launch { sheetState.hide() }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = if (sheetState.currentAnchor == SheetAnchor.Hidden) {
                                            ButtonDefaults.buttonColors()
                                        } else {
                                            ButtonDefaults.filledTonalButtonColors()
                                        }
                                    ) {
                                        Text("Hidden")
                                    }

                                    Button(
                                        onClick = {
                                            scope.launch { sheetState.show(SheetAnchor.Peek) }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = if (sheetState.currentAnchor == SheetAnchor.Peek) {
                                            ButtonDefaults.buttonColors()
                                        } else {
                                            ButtonDefaults.filledTonalButtonColors()
                                        }
                                    ) {
                                        Text("Peek")
                                    }

                                    Button(
                                        onClick = {
                                            scope.launch { sheetState.show(SheetAnchor.Compact) }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = if (sheetState.currentAnchor == SheetAnchor.Compact) {
                                            ButtonDefaults.buttonColors()
                                        } else {
                                            ButtonDefaults.filledTonalButtonColors()
                                        }
                                    ) {
                                        Text("Compact")
                                    }

                                    Button(
                                        onClick = {
                                            scope.launch { sheetState.show(SheetAnchor.Full) }
                                        },
                                        modifier = Modifier.fillMaxWidth(),
                                        colors = if (sheetState.currentAnchor == SheetAnchor.Full) {
                                            ButtonDefaults.buttonColors()
                                        } else {
                                            ButtonDefaults.filledTonalButtonColors()
                                        }
                                    ) {
                                        Text("Full")
                                    }
                                }
                            }
                        }

                        item {
                            Text(
                                text = "Library",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onBackground,
                                modifier = Modifier.padding(top = 8.dp)
                            )
                        }

                        itemsIndexed(BackgroundTracks) { _, track ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(MaterialTheme.colorScheme.surface)
                                    .clickable {
                                        scope.launch { sheetState.show(SheetAnchor.Compact) }
                                    }
                                    .padding(horizontal = 12.dp, vertical = 10.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(RoundedCornerShape(6.dp))
                                        .background(MaterialTheme.colorScheme.surfaceVariant),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text("🎵", fontSize = 16.sp)
                                }
                                Spacer(modifier = Modifier.width(12.dp))
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = track.title,
                                        style = MaterialTheme.typography.bodyMedium,
                                        fontWeight = FontWeight.Medium,
                                        color = MaterialTheme.colorScheme.onSurface,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    Text(
                                        text = track.artist,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                                Text(
                                    text = track.duration,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }

                        item {
                            Spacer(modifier = Modifier.height(100.dp))
                        }
                    }
                }

                MultiAnchorBottomSheet(
                    state = sheetState,
                    onDismiss = {},
                    peekContent = {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "♪",
                                fontSize = 20.sp,
                                color = MaterialTheme.colorScheme.primary,
                                modifier = Modifier.padding(end = 12.dp)
                            )
                            Text(
                                text = "Now Playing — Bohemian Rhapsody",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurface,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    },
                    compactContent = {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 24.dp, vertical = 12.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                text = "Bohemian Rhapsody",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface,
                                textAlign = TextAlign.Center
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Queen • A Night at the Opera",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.secondary,
                                textAlign = TextAlign.Center
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(24.dp, Alignment.CenterHorizontally),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                IconButton(onClick = { /* skip previous */ }) {
                                    Text("⏮", fontSize = 24.sp, color = MaterialTheme.colorScheme.onSurface)
                                }
                                IconButton(
                                    onClick = { isPlaying = !isPlaying },
                                    modifier = Modifier
                                        .size(48.dp)
                                        .clip(CircleShape)
                                        .background(MaterialTheme.colorScheme.primary)
                                ) {
                                    Text(
                                        if (isPlaying) "⏸" else "▶",
                                        fontSize = 22.sp,
                                        color = MaterialTheme.colorScheme.onPrimary
                                    )
                                }
                                IconButton(onClick = { /* skip next */ }) {
                                    Text("⏭", fontSize = 24.sp, color = MaterialTheme.colorScheme.onSurface)
                                }
                            }
                            Spacer(modifier = Modifier.height(12.dp))
                            LinearProgressIndicator(
                                progress = { 0.35f },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(4.dp)
                                    .clip(RoundedCornerShape(2.dp)),
                                color = MaterialTheme.colorScheme.primary,
                                trackColor = MaterialTheme.colorScheme.surfaceVariant
                            )
                        }
                    },
                    fullContent = {
                        LazyColumn(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 20.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            item {
                                Spacer(modifier = Modifier.height(16.dp))
                                Box(
                                    modifier = Modifier
                                        .size(200.dp)
                                        .clip(RoundedCornerShape(16.dp))
                                        .background(MaterialTheme.colorScheme.surfaceVariant),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = "Album Art",
                                        style = MaterialTheme.typography.titleMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                        fontWeight = FontWeight.SemiBold
                                    )
                                }
                                Spacer(modifier = Modifier.height(24.dp))
                            }

                            item {
                                Text(
                                    text = "Track List",
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 4.dp)
                                )
                            }

                            itemsIndexed(FullAlbumTracks) { _, track ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(
                                            if (track.number == 11) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)
                                            else Color.Transparent
                                        )
                                        .padding(horizontal = 8.dp, vertical = 8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "${track.number}",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = if (track.number == 11) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant,
                                        modifier = Modifier.width(32.dp)
                                    )
                                    Text(
                                        text = track.title,
                                        style = MaterialTheme.typography.bodyMedium,
                                        fontWeight = if (track.number == 11) FontWeight.Bold else FontWeight.Normal,
                                        color = if (track.number == 11) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
                                        modifier = Modifier.weight(1f),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        text = track.duration,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }

                            item {
                                Spacer(modifier = Modifier.height(24.dp))
                                Text(
                                    text = "Lyrics",
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 8.dp)
                                )
                                Text(
                                    text = """
                                        Is this the real life?
                                        Is this just fantasy?
                                        Caught in a landslide,
                                        No escape from reality.

                                        Open your eyes,
                                        Look up to the skies and see,
                                        I'm just a poor boy, I need no sympathy,
                                        Because I'm easy come, easy go,
                                        Little high, little low,
                                        Any way the wind blows doesn't really matter to me, to me.

                                        Mama, just killed a man,
                                        Put a gun against his head, pulled my trigger, now he's dead.
                                        Mama, life had just begun,
                                        But now I've gone and thrown it all away.

                                        Mama, ooh,
                                        Didn't mean to make you cry,
                                        If I'm not back again this time tomorrow,
                                        Carry on, carry on as if nothing really matters.
                                    """.trimIndent(),
                                    style = MaterialTheme.typography.bodyMedium,
                                    lineHeight = 24.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Spacer(modifier = Modifier.height(48.dp))
                            }
                        }
                    }
                )
            }
        }
    }
}
