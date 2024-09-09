package org.zeith.modid;

import net.minecraft.resources.ResourceLocation;
import net.minecraftforge.fml.common.Mod;

@Mod(SteelRiptide.MOD_ID)
public class SteelRiptide
{
	public static final String MOD_ID = "steelriptide";

	public static ResourceLocation id(String path)
	{
		return new ResourceLocation(MOD_ID, path);
	}
}
