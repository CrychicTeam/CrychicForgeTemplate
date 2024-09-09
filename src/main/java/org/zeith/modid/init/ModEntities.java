package org.zeith.modid.init;

import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.MobCategory;
import org.zeith.modid.SteelRiptide;
import org.zeith.modid.entity.EntityLightningBall;

public interface ModEntities
{
    EntityType<EntityLightningBall> LIGHTNING_PROJECTILE = EntityType.Builder.<EntityLightningBall>of(EntityLightningBall::new, MobCategory.MISC)
            .sized(0.5F, 0.5F)
            .build(SteelRiptide.id("lightning_projectile").toString());
}
