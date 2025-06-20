package org.pickaid.modid;

import net.minecraft.resources.ResourceLocation;
import net.minecraftforge.fml.common.Mod;

@Mod(Example.MOD_ID)
public class Example {
	public static final String MOD_ID = "example";

	public static ResourceLocation source(String path) {
		return new ResourceLocation(MOD_ID, path);
	}
}
