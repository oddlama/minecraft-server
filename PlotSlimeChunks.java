import java.util.*;
import java.lang.*;
import java.io.*;

class PlotSlimeChunks {
	static long world_seed = 6018062811117054619l;
	static long slime_seed = 987214909;
	static int radius = 16;

	public static boolean is_slime_chunk(int x, int z) {
		return new Random(
				world_seed +
				(int)(x * x * 0x4c1906) +
				(int)(x * 0x5ac0db) +
				(int)(z * z) * 0x4307a7L +
				(int)(z * 0x5f24f) ^ slime_seed
				).nextInt(10) == 0;
	}

	public static void main(String args[]) {
		if (args.length != 3) {
			System.out.println("usage: " + args[0] + " <x> <z>");
		}
		int x = Integer.parseInt(args[1]);
		int z = Integer.parseInt(args[2]);
		if (x < 0) { x = x / 16 - 1; } else { x = x / 16; }
		if (z < 0) { z = z / 16 - 1; } else { z = z / 16; }

		for (int cz = z - radius; cz <= z + radius; ++cz) {
			for (int cx = x - radius; cx <= x + radius; ++cx) {
				String str = "";
				boolean is_slime = is_slime_chunk(cx, cz);
				if (cx == x && cz == z) {
					str += is_slime ? "[1;31m" : "[31m";
				} else if (is_slime) {
					str += "[32m";
				}
				str += is_slime ? "▓▓" : pattern(cx, cz, x, z);
				str += "[m";
				System.out.print(str);
			}
			System.out.println();
		}
	}

	public static String pattern(int cx, int cz, int x, int z) {
		if ((cx - x + cz - z) % 2 == 0) {
			return "░░";
		} else {
			return "  ";
		}
	}
}
