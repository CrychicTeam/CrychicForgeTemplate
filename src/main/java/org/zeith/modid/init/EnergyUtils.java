package org.zeith.modid.init;

import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraftforge.common.capabilities.ForgeCapabilities;
import net.minecraftforge.common.util.LazyOptional;
import net.minecraftforge.energy.IEnergyStorage;

public class EnergyUtils {

    public static int transferEnergyToNeighbors(Level level, BlockPos pos, int energy) {
        for (Direction e : Direction.values()) {
            BlockPos neighbor = pos.relative(e);
            if (!level.hasChunkAt(neighbor)) {
                continue;
            }

            BlockEntity be = level.getBlockEntity(neighbor);
            if (be == null) {
                continue;
            }
            LazyOptional<IEnergyStorage> storage = be.getCapability(ForgeCapabilities.ENERGY, e.getOpposite());
            if (!storage.isPresent()) {
                storage = be.getCapability(ForgeCapabilities.ENERGY, null);
            }

            if (storage.isPresent()) {
                energy -= storage.orElseThrow(NullPointerException::new).receiveEnergy(energy, false);

                if (energy <= 0) {
                    return 0;
                }
            }
        }
        return energy;
    }
}