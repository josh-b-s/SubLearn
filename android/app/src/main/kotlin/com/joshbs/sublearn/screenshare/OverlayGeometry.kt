package com.joshbs.sublearn.screenshare

data class Box(val x: Int, val y: Int, val width: Int, val height: Int)

/** Pure window maths, in pixels, kept apart from the WindowManager code. */
object OverlayGeometry {

    /** Moves the box, keeping at least [reach] px of it on screen so the title bar stays reachable. */
    fun moved(start: Box, dx: Int, dy: Int, screenWidth: Int, screenHeight: Int, reach: Int): Box = start.copy(
        x = (start.x + dx).coerceIn(reach - start.width, screenWidth - reach),
        y = (start.y + dy).coerceIn(0, screenHeight - reach),
    )

    /** The top-left corner follows the finger and the bottom-right corner stays where it is. */
    fun resized(start: Box, dx: Int, dy: Int, minWidth: Int, minHeight: Int): Box {
        val right = start.x + start.width
        val bottom = start.y + start.height
        val left = (start.x + dx).coerceAtMost(right - minWidth).coerceAtLeast(minOf(0, start.x))
        val top = (start.y + dy).coerceAtMost(bottom - minHeight).coerceAtLeast(0)
        return Box(left, top, right - left, bottom - top)
    }
}
