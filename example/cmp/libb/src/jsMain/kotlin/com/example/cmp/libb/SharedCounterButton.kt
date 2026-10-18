package com.example.cmp.libb

import androidx.compose.runtime.AbstractApplier
import androidx.compose.runtime.Composable
import androidx.compose.runtime.ComposeNode
import androidx.compose.runtime.Composition
import androidx.compose.runtime.Recomposer
import kotlin.coroutines.EmptyCoroutineContext

/**
 * A Compose UI DOM Node for Web targets.
 * Managed and rendered directly by Compose Runtime.
 */
class DomNode(val tagName: String) {
    var text: String = ""
    var className: String = ""
    var id: String = ""
    var onClick: (() -> Unit)? = null
    val children = mutableListOf<DomNode>()

    // In a browser environment, this holds the real DOM Element
    var domElement: dynamic = null

    fun render(parent: dynamic = null): dynamic {
        val isBrowser: Boolean = js("typeof document !== 'undefined'") as Boolean
        if (!isBrowser) return null

        val doc: dynamic = js("document")
        val el = doc.createElement(tagName)
        domElement = el
        if (id.isNotEmpty()) el.id = id
        if (text.isNotEmpty()) el.textContent = text
        if (className.isNotEmpty()) el.className = className
        if (onClick != null) {
            el.onclick = { onClick?.invoke() }
        }
        for (child in children) {
            val childEl = child.render(el)
            if (childEl != null) el.appendChild(childEl)
        }
        if (parent != null) {
            parent.appendChild(el)
        }
        return el
    }

    fun updateDom() {
        if (domElement != null) {
            if (id.isNotEmpty()) domElement.id = id
            if (text.isNotEmpty()) domElement.textContent = text
            if (className.isNotEmpty()) domElement.className = className
        }
    }
}

/**
 * Compose Applier for DOM trees.
 */
class DomApplier(root: DomNode) : AbstractApplier<DomNode>(root) {
    override fun insertTopDown(index: Int, instance: DomNode) {
        // No-op
    }

    override fun insertBottomUp(index: Int, instance: DomNode) {
        current.children.add(index, instance)
        val isBrowser: Boolean = js("typeof document !== 'undefined'") as Boolean
        if (isBrowser && current.domElement != null) {
            instance.render(current.domElement)
        }
    }

    override fun remove(index: Int, count: Int) {
        for (i in 0 until count) {
            if (index < current.children.size) {
                val removed = current.children.removeAt(index)
                if (removed.domElement != null && current.domElement != null) {
                    current.domElement.removeChild(removed.domElement)
                }
            }
        }
    }

    override fun move(from: Int, to: Int, count: Int) {
        val items = (0 until count).map { current.children.removeAt(from) }
        current.children.addAll(to, items)
    }

    override fun onClear() {
        current.children.clear()
        if (current.domElement != null) {
            current.domElement.innerHTML = ""
        }
    }
}

/**
 * Emits a DOM element into the Compose composition hierarchy.
 */
@Composable
fun DomElement(
    tagName: String,
    className: String = "",
    id: String = "",
    text: String = "",
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit = {},
) {
    ComposeNode<DomNode, DomApplier>(
        factory = {
            val node = DomNode(tagName)
            node.className = className
            node.id = id
            node.text = text
            node.onClick = onClick
            node
        },
        update = {
            set(className) {
                this.className = it
                updateDom()
            }
            set(id) {
                this.id = it
                updateDom()
            }
            set(text) {
                this.text = it
                updateDom()
            }
            set(onClick) {
                this.onClick = it
            }
        },
        content = content,
    )
}

/**
 * Shared Compose UI Counter Button for Web (JS) targets.
 * The UI is rendered and recomposed entirely by Compose Runtime.
 */
@Composable
fun SharedCounterButton(
    state: CounterButtonState = rememberCounterButtonState(),
    onClick: () -> Unit = { state.onClick() },
) {
    DomElement(
        tagName = "button",
        id = "shared-counter-btn",
        className = "shared-counter-btn",
        text = state.label,
        onClick = onClick,
    )
}

/**
 * Mounts a Compose hierarchy into a root DOM element or virtual container.
 */
fun renderComposeWeb(
    containerId: String = "root",
    content: @Composable () -> Unit,
): Composition {
    val rootNode = DomNode("div")
    rootNode.id = containerId

    val isBrowser: Boolean = js("typeof document !== 'undefined'") as Boolean
    if (isBrowser) {
        val doc: dynamic = js("document")
        val container = doc.getElementById(containerId)
        if (container != null) {
            rootNode.domElement = container
        }
    }

    val applier = DomApplier(rootNode)
    val recomposer = Recomposer(EmptyCoroutineContext)
    val composition = Composition(applier, recomposer)
    composition.setContent(content)
    return composition
}
