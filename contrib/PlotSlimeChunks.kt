import java.util.Random
import kotlin.system.exitProcess

/**
 * Prints a map of slime chunks around a position in the terminal.
 *
 * Draws a (2 * [RADIUS] + 1)² grid of chunks centered on the chunk that holds the given block
 * coordinates. Each chunk is two characters wide:
 * - green `▓▓`: slime chunk
 * - red: the center chunk (bold `▓▓` if it is also a slime chunk)
 * - `░░` / blank: checkerboard background to make counting chunks easier
 *
 * Build and run (needs a Kotlin compiler and a JVM):
 * ```
 * kotlinc PlotSlimeChunks.kt -include-runtime -d PlotSlimeChunks.jar
 * java -jar PlotSlimeChunks.jar <x> <z>
 * ```
 * where `<x>` and `<z>` are block coordinates, e.g., from the F3 screen.
 */
internal object PlotSlimeChunks {
    /** Seed of the world to map. Change this to match your server's `/seed`. */
    const val WORLD_SEED: Long = 6018062811117054619L

    /** Constant salt Minecraft mixes into the slime chunk seed (`0x3ad8025f`). */
    const val SLIME_SEED: Long = 987214909

    /** Number of chunks drawn on each side of the center chunk. */
    const val RADIUS: Int = 16

    /**
     * Returns whether chunk ([x], [z]) is a slime chunk in Java Edition.
     *
     * Reproduces Minecraft's formula exactly, including the 32-bit overflow of the
     * `Int` products before they are added to the `Long` seed. It must use
     * [java.util.Random], whose algorithm the game relies on.
     */
    fun isSlimeChunk(x: Int, z: Int): Boolean {
        return Random(
            WORLD_SEED + (x * x * 0x4c1906) + (x * 0x5ac0db) + (z * z) * 0x4307a7L + (z * 0x5f24f) xor SLIME_SEED
        ).nextInt(10) == 0
    }

    /**
     * Entry point. Expects exactly two integer arguments, the block X and Z coordinates.
     * Prints usage to stderr and exits with status 1 otherwise.
     */
    @JvmStatic
    fun main(args: Array<String>) {
        val blockX = args.getOrNull(0)?.toIntOrNull()
        val blockZ = args.getOrNull(1)?.toIntOrNull()
        if (args.size != 2 || blockX == null || blockZ == null) {
            System.err.println("usage: java -jar PlotSlimeChunks.jar <x> <z>")
            exitProcess(1)
        }
        // Arithmetic shift floors toward negative infinity, matching Minecraft's block -> chunk mapping
        val x = blockX shr 4
        val z = blockZ shr 4

        for (cz in z - RADIUS..z + RADIUS) {
            for (cx in x - RADIUS..x + RADIUS) {
                var str = ""
                val isSlime = isSlimeChunk(cx, cz)
                if (cx == x && cz == z) {
                    str += if (isSlime) "\u001b[1;31m" else "\u001b[31m"
                } else if (isSlime) {
                    str += "\u001b[32m"
                }
                str += if (isSlime) "▓▓" else pattern(cx, cz, x, z)
                str += "\u001b[m"
                print(str)
            }
            println()
        }
    }

    /**
     * Background for a non-slime chunk ([cx], [cz]): alternates `░░` and blank in a
     * checkerboard anchored at the center chunk ([x], [z]).
     */
    fun pattern(cx: Int, cz: Int, x: Int, z: Int): String {
        return if ((cx - x + cz - z) % 2 == 0) {
            "░░"
        } else {
            "  "
        }
    }
}
