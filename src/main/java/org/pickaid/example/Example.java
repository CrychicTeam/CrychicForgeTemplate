package org.pickaid.example;

import net.minecraft.resources.ResourceLocation;
import net.neoforged.fml.common.Mod;

@Mod(Example.MOD_ID)
public final class Example {
    public static final String MOD_ID = "example";

    public Example() {
    }

    public static ResourceLocation id(String path) {
        return ResourceLocation.fromNamespaceAndPath(MOD_ID, path);
    }
}
