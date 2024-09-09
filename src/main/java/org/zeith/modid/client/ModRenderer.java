package org.zeith.modid.client;

import net.minecraft.client.renderer.entity.EntityRenderers;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.client.event.EntityRenderersEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import org.zeith.modid.SteelRiptide;
import org.zeith.modid.client.renderer.SimpleArrowRenderer;
import org.zeith.modid.init.ModEntities;

@Mod.EventBusSubscriber(modid = SteelRiptide.MOD_ID, bus = Mod.EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ModRenderer {
    @SubscribeEvent
    public static void onClientSetup(EntityRenderersEvent.RegisterRenderers event) {
        EntityRenderers.register(ModEntities.LIGHTNING_PROJECTILE, SimpleArrowRenderer::new);
    }
}
