package org.pickaid.example;

import net.minecraft.resources.Identifier;
import net.neoforged.fml.common.Mod;

@Mod(Example.MOD_ID)
public final class Example {
    public static final String MOD_ID = "example";

    public Example() {
    }

    public static Identifier id(String path) {
        return Identifier.fromNamespaceAndPath(MOD_ID, path);
    }
}
