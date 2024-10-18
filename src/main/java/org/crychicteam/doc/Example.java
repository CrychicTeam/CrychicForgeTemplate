package org.crychicteam.doc;

import net.minecraft.resources.ResourceLocation;
import net.minecraftforge.fml.common.Mod;

@Mod(Example.MOD_ID)
public class Example
{
	public static final String MOD_ID = "doc";
	public static ResourceLocation id(String path)
	{
		return new ResourceLocation(MOD_ID, path);
	}
}
