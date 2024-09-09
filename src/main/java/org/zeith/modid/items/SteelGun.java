package org.zeith.modid.items;

import net.minecraft.world.InteractionHand;
import net.minecraft.world.InteractionResultHolder;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import org.zeith.modid.entity.EntityLightningBall;

public class SteelGun extends Item
{
    public SteelGun(Properties properties)
    {
        super(properties);
    }

    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand)
    {
        ItemStack itemstack = player.getItemInHand(hand);
        if (player.isCrouching())
        {
            player.heal(4.0F);
            return InteractionResultHolder.success(itemstack);
        }

        if (player.isSprinting())
        {
            player.getFoodData().eat(4, 1.0F);
            return InteractionResultHolder.success(itemstack);
        }

        if (!level.isClientSide)
        {
            EntityLightningBall arrow = new EntityLightningBall(level, player);
            arrow.shootFromRotation(player, player.getXRot(), player.getYRot(), 0.0F, 1.5F, 1.0F);
            level.addFreshEntity(arrow);
        }
        return InteractionResultHolder.success(itemstack);
    }
}
