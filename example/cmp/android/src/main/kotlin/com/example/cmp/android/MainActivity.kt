package com.example.cmp.android

import android.app.Activity
import android.os.Bundle
import android.widget.LinearLayout
import android.widget.TextView
import com.example.cmp.libb.SheetManager

class MainActivity : Activity() {
    private val manager = SheetManager()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 48, 48, 48)
        }

        val titleView = TextView(this).apply {
            text = "Compose Multiplatform Android - App A"
            textSize = 20f
        }

        val infoView = TextView(this).apply {
            text = "Targeting Kotlin 2.3.21 & Compose 1.9.5\n" + manager.formatSummary()
            textSize = 14f
            setPadding(0, 24, 0, 0)
        }

        layout.addView(titleView)
        layout.addView(infoView)
        setContentView(layout)
    }
}
