package org.zeith.modid.client.renderer;

import net.minecraft.client.renderer.entity.ArrowRenderer;
import net.minecraft.client.renderer.entity.EntityRendererProvider;
import net.minecraft.resources.ResourceLocation;
import org.zeith.modid.SteelRiptide;
import org.zeith.modid.entity.EntityLightningBall;


public class SimpleArrowRenderer extends ArrowRenderer<EntityLightningBall>
{
    public static final ResourceLocation TEXTURE = new ResourceLocation(SteelRiptide.MOD_ID, "textures/entity/simple_arrow.png");

    public SimpleArrowRenderer(EntityRendererProvider.Context context)
    {
        super(context);
    }

    @Override
    public ResourceLocation getTextureLocation(EntityLightningBall entity)
    {
        return TEXTURE;
    }
}
