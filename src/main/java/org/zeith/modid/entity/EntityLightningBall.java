package org.zeith.modid.entity;

import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.LightningBolt;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.projectile.AbstractArrow;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.phys.EntityHitResult;
import org.zeith.modid.init.ModEntities;

public class EntityLightningBall extends AbstractArrow {
    public EntityLightningBall(EntityType<? extends AbstractArrow> type, Level level) {
        super(type, level);
    }

    public EntityLightningBall(Level level, double x, double y, double z) {
        super(ModEntities.LIGHTNING_PROJECTILE, x, y, z, level);
    }

    public EntityLightningBall(Level level, LivingEntity shooter) {
        super(ModEntities.LIGHTNING_PROJECTILE, shooter, level);
    }

    @Override
    protected ItemStack getPickupItem() {
        return ItemStack.EMPTY;
    }

    @Override
    protected void onHitEntity(EntityHitResult result) {
        super.onHitEntity(result);
        spawnLightning(result.getLocation().x(), result.getLocation().y(), result.getLocation().z());
        this.discard();
    }

    @Override
    protected void onHitBlock(BlockHitResult result) {
        super.onHitBlock(result);
        spawnLightning(result.getLocation().x(), result.getLocation().y(), result.getLocation().z());
        this.discard();
    }

    private void spawnLightning(double x, double y, double z) {
        if (!this.level().isClientSide) {
            LightningBolt lightning = EntityType.LIGHTNING_BOLT.create(this.level());
            if (lightning != null) {
                lightning.moveTo(x, y, z);
                this.level().addFreshEntity(lightning);
            }
        }
    }
}