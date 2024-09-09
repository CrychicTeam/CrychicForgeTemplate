package org.zeith.modid.mixins;

import net.minecraft.world.entity.LightningBolt;
import net.minecraft.world.level.Level;
import net.minecraft.core.BlockPos;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(LightningBolt.class)
public class LightningBoltMixin {

    @Shadow
    private int life;

    /*
    @Inject(method = "tick", at = @At("TAIL"))
    public void onTick(CallbackInfo info) {
        LightningBolt lightning = (LightningBolt) (Object) this;
        if (this.life < 0) {
            Level level = lightning.level();
            BlockPos pos = lightning.blockPosition();
            int radius = PowerGeneratorBlockEntity.RANGE;
            for (int x = -radius; x <= radius; x++) {
                for (int y = -radius; y <= radius; y++) {
                    for (int z = -radius; z <= radius; z++) {
                        BlockPos checkPos = pos.offset(x, y, z);
                        double distance = Math.sqrt(checkPos.distSqr(pos)) - 1;

                        distance = Math.max(0, distance);

                        if (distance <= radius) {
                            if (level.getBlockEntity(checkPos) instanceof PowerGeneratorBlockEntity) {
                                PowerGeneratorBlockEntity tile = (PowerGeneratorBlockEntity) level.getBlockEntity(checkPos);
                                int energyToAdd = (int) ((1 - (distance / radius)) * 16000);
                                tile.setEnergy(tile.getEnergy() + energyToAdd);
                                tile.transferTo();
                            }
                        }
                    }
                }
            }
        }
    }
    */
}