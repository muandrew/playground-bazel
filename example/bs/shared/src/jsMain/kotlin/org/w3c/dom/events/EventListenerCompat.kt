/*
 * Compose Foundation 1.12.0 was compiled against the legacy DOM API, whose
 * EventListener(handler) factory is not included by kotlinx-browser 0.5.0.
 * Keep this compatibility factory in jsMain so JVM and Android stay DOM-free.
 */
package org.w3c.dom.events

/** Adapts a Kotlin callback to the browser's EventListener interface. */
public fun EventListener(handler: (Event) -> Unit): EventListener = EventListenerHandler(handler)

private class EventListenerHandler(private val handler: (Event) -> Unit) : EventListener {
    override fun handleEvent(event: Event) {
        handler(event)
    }

    override fun toString(): String = "EventListenerHandler($handler)"
}
