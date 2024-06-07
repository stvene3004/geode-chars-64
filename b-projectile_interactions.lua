
-------------------
--GENERAL ENEMIES--
-------------------

function shockwave_chuckya(o, shot_dir)
    o.usingObj = nil
    obj_mark_for_deletion(o)
    obj_spawn_loot_yellow_coins(o, 5, 20.0)
    spawn_mist_particles_with_sound(SOUND_OBJ_CHUCKYA_DEATH)
    return true
end

function crystal_bullet_enemygeneral(o, shot_dir)
    if (o.oInteractStatus & INT_STATUS_INTERACTED) == 0 
    and o.oAction ~= OBJ_ACT_VERTICAL_KNOCKBACK and o.oAction ~= OBJ_ACT_HORIZONTAL_KNOCKBACK and o.oAction ~= OBJ_ACT_SQUISHED then
        o.oInteractStatus = ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        return true
    else
        return false
    end
end

function crystal_bullet_goomba(o, shot_dir)
    if (o.oInteractStatus & INT_STATUS_INTERACTED) == 0 
    and o.oAction ~= OBJ_ACT_VERTICAL_KNOCKBACK and o.oAction ~= OBJ_ACT_HORIZONTAL_KNOCKBACK and o.oAction ~= OBJ_ACT_SQUISHED then
        if o.oGoombaSize == GOOMBA_SIZE_HUGE then
            o.oInteractStatus = ATTACK_GROUND_POUND_OR_TWIRL | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        else
            o.oInteractStatus = ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        end
        return true
    else
        return false
    end
end

function crystal_bullet_enemygeneral(o, shot_dir)
    if (o.oInteractStatus & INT_STATUS_INTERACTED) == 0 
    and o.oAction ~= OBJ_ACT_VERTICAL_KNOCKBACK and o.oAction ~= OBJ_ACT_HORIZONTAL_KNOCKBACK and o.oAction ~= OBJ_ACT_SQUISHED then
        o.oInteractStatus = ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        return true
    else
        return false
    end
end

function crystal_bullet_bigenemygeneral(o, shot_dir)
    if (o.oInteractStatus & INT_STATUS_INTERACTED) == 0 then
        o.oInteractStatus = ATTACK_FAST_ATTACK | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        return true
    else
        return false
    end
end

-----------------------
--BOB-OMB BATTLEFIELD--
-----------------------

function crystal_bullet_bobomb(o, shot_dir)
    if (o.oAction ~= BOBOMB_ACT_EXPLODE) then
        if (o.oVelY <= 0) then
            o.oMoveAngleYaw = shot_dir
            o.oForwardVel = 30.0
            o.oVelY = 40.0
            o.oAction = BOBOMB_ACT_LAUNCHED
        end
        return true
    else
        return false
    end
end

function shockwave_bobomb(o, shot_dir)
    if (o.oAction ~= BOBOMB_ACT_EXPLODE) then
            o.oAction = BOBOMB_ACT_EXPLODE
        return true
    else
        return false
    end
end

function crystal_bullet_chainchomp(o, shot_level, shot_dir)
    if shot_level == 3  then
        o.oSubAction = CHAIN_CHOMP_SUB_ACT_LUNGE
        o.oChainChompMaxDistFromPivotPerChainPart = 900.0 / 5
        o.oForwardVel = 0.0
        o.oVelY = 300.0
        o.oGravity = -4.0
        o.oChainChompTargetPitch = -0x3000
    end
    return true
end

function crystal_bullet_waterbomb(o, shot_dir)
    o.oAction = WATER_BOMB_ACT_EXPLODE
    return true
end

function crystal_bullet_kingbobomb(o, shot_level, shot_dir)
    if shot_level == 3 and (o.oFlags & OBJ_FLAG_HOLDABLE) ~= 0 and o.oAction ~= 8 then
        o.oVelY = 30
        o.oForwardVel = 30
        o.oMoveAngleYaw = shot_dir
        o.oMoveFlags = 0
        o.oAction = 4
    end
    return true
end

function crystal_bullet_breakablebox(o, shot_dir)
    o.oInteractStatus =  ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
    return true
end

function crystal_bullet_breakableboxsmall(o, shot_dir)
    o.oInteractStatus = ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED | INT_STATUS_STOP_RIDING
    return true
end

function crystal_bullet_exclamationbox(o, shot_dir)
    if o.oAction ~= 5 and o.oAction ~= 6 then
        o.oInteractStatus = ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        return true
    else
        return false
    end
end

--------------------
--WHOMP'S FORTRESS--
--------------------

function crystal_bullet_bridge(o, shot_level, shot_dir)
    if shot_level == 3 and (o.oFaceAnglePitch > -0x4000) then
        o.oAction = 2
    end
    return true
end

function crystal_bullet_whomp(o, shot_level, shot_dir)
    if o.oAction ~= 8 and shot_level == 3 then
        o.oNumLootCoins = 5
        obj_spawn_loot_yellow_coins(o, 5, 20.0)
        o.oAction = 8
    end
    return true
end

function crystal_bullet_whompking(o, shot_level, shot_dir)
    if o.oAction ~= 8 and o.oAction ~= 0 and shot_level == 3 then
        o.oHealth = o.oHealth - 1
        play_sound(SOUND_OBJ2_WHOMP_SOUND_SHORT, o.header.gfx.cameraToObject)
        play_sound(SOUND_OBJ_KING_WHOMP_DEATH, o.header.gfx.cameraToObject)
        if (o.oHealth == 0) then
            o.oAction = 8
        end
    end
    return true
end

function crystal_bullet_piranhaplant(o, shot_dir)
    stop_secondary_music(50)
    if o.oAction ~= PIRANHA_PLANT_ACT_SHRINK_AND_DIE 
    and o.oAction ~= PIRANHA_PLANT_ACT_ATTACKED and o.oAction ~= PIRANHA_PLANT_ACT_WAIT_TO_RESPAWN then
        o.oAction = PIRANHA_PLANT_ACT_ATTACKED
        return true
    end
    return false
end

function crystal_bullet_bulletbill(o, shot_level, shot_dir)
    if shot_level == 2 then
        o.oAction = 4
    elseif shot_level == 3 then
        o.oAction = 3
        spawn_non_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, o.oPosX, o.oPosY, o.oPosZ, nil)
    end
    return true
end

----------------------
--COOL COOL MOUNTAIN--
----------------------

function crystal_bullet_mrblizzard(o, shot_dir)
    if o.oAction ~= MR_BLIZZARD_ACT_DEATH then
        o.oAction = MR_BLIZZARD_ACT_DEATH
        return true
    end
    return false
end

----------------------
--SHIFTING SAND LAND--
----------------------
function crystal_bullet_klepto(o, shot_dir)
    o.oInteractStatus = ATTACK_FROM_ABOVE | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED | INT_STATUS_STOP_RIDING
    return true
end

--------------------
--LETHAL LAVA LAND--
--------------------
function crystal_bullet_mri(o, shot_dir)
    if (o.oAction ~= 3) then
        o.oAction = 3
        o.oTimer = 104
        return true
    end
    return false
end

function crystal_bullet_bully(o, shot_dir)
    o.oMoveAngleYaw = shot_dir
    o.oInteractStatus = INT_STATUS_INTERACTED
    o.oForwardVel = 15
    return true
end

---------------------
---TINY HUGE ISLAND--
---------------------

function crystal_bullet_spiny(o, shot_dir)
    o.oInteractStatus =  ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
    return true
end

function crystal_bullet_firepiranhaplant(o, shot_dir)
    if o.oAction ~= FIRE_PIRANHA_PLANT_ACT_HIDE then
        o.oInteractStatus = ATTACK_FAST_ATTACK | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        return true
    end
    return false
end

crystalbullettargets = {
    -- BOB
    [id_bhvGoomba] = crystal_bullet_goomba, 
    [id_bhvKoopa] = crystal_bullet_enemygeneral,
    [id_bhvBobomb] = crystal_bullet_bobomb,
    --[id_bhvChainChomp] = crystal_bullet_chainchomp,
    [id_bhvWaterBomb] = crystal_bullet_waterbomb,
    --[id_bhvKingBobomb] = crystal_bullet_kingbobomb,
    --[id_bhvBreakableBox] = crystal_bullet_breakablebox,
    --[id_bhvBreakableBoxSmall] = crystal_bullet_breakableboxsmall,
    [id_bhvExclamationBox] = crystal_bullet_exclamationbox,
    -- WF
    --[id_bhvKickableBoard] = crystal_bullet_bridge,
    [id_bhvWfBreakableWallLeft] = crystal_bullet_breakablebox,
    [id_bhvWfBreakableWallRight] = crystal_bullet_breakablebox,
    --[id_bhvSmallWhomp] = crystal_bullet_whomp,
    --[id_bhvWhompKingBoss] = crystal_bullet_whompking,
    [id_bhvPiranhaPlant] = crystal_bullet_piranhaplant,
    --[id_bhvBulletBill] = crystal_bullet_bulletbill,
    -- CM
    [id_bhvSpindrift] = crystal_bullet_enemygeneral,
    --[id_bhvMrBlizzard] = crystal_bullet_mrblizzard,
    -- BBH
    [id_bhvBoo] = crystal_bullet_enemygeneral,
    [id_bhvGhostHuntBoo] = crystal_bullet_enemygeneral,
    [id_bhvFlyingBookend] = crystal_bullet_enemygeneral,
    [id_bhvHauntedChair] = crystal_bullet_enemygeneral,
    [id_bhvBooInCastle] = crystal_bullet_enemygeneral,
    [id_bhvBooWithCage] = crystal_bullet_enemygeneral,
    [id_bhvMerryGoRoundBoo] = crystal_bullet_bigenemygeneral,
    [id_bhvBalconyBigBoo] = crystal_bullet_bigenemygeneral,
    [id_bhvGhostHuntBigBoo] = crystal_bullet_bigenemygeneral,
    [id_bhvMerryGoRoundBigBoo] = crystal_bullet_bigenemygeneral,
    -- LLL
    [id_bhvMrI] = crystal_bullet_mri,
    [id_bhvSmallBully] = crystal_bullet_bully,
    [id_bhvBigBully] = crystal_bullet_bully,
    [id_bhvBigBullyWithMinions] = crystal_bullet_bully,
    -- SSL
    [id_bhvPokey] = crystal_bullet_enemygeneral,
    [id_bhvPokeyBodyPart] = crystal_bullet_enemygeneral,
    [id_bhvKlepto] = crystal_bullet_klepto,
    [id_bhvFlyGuy] = crystal_bullet_enemygeneral,
    [id_bhvEyerokHand] = crystal_bullet_bigenemygeneral,
    -- HMZ
    [id_bhvScuttlebug] = crystal_bullet_enemygeneral,
    [id_bhvSnufit] = crystal_bullet_enemygeneral,
    [id_bhvSwoop] = crystal_bullet_enemygeneral,
    -- THI
    [id_bhvFirePiranhaPlant] = crystal_bullet_firepiranhaplant,
    --[id_bhvChuckya] = crystal_bullet_chuckya,
    [id_bhvEnemyLakitu] = crystal_bullet_enemygeneral,
    [id_bhvSpiny] = crystal_bullet_spiny,
    [id_bhvWigglerBody] = crystal_bullet_klepto,
    [id_bhvWigglerHead] = crystal_bullet_klepto,
    -- TTM
    [id_bhvMontyMole] = crystal_bullet_enemygeneral,
    -- WDW
    [id_bhvSkeeter] = crystal_bullet_enemygeneral,
    -- SL
    [id_bhvSmallChillBully] = crystal_bullet_bully,
    [id_bhvBigChillBully] = crystal_bullet_bully,
    [id_bhvMoneybag] = crystal_bullet_enemygeneral,
}

function projectileattack(obj, shot_dir)
    local hurtenemy = false
    local enemyobj
    
    for key,value in pairs(crystalbullettargets) do --projectilehurtableenemy is a table of enemies that can be hurt by projectiles with each enemy stored by behaviorid
        enemyobj = obj_get_nearest_object_with_behavior_id(obj,key) --get nearest hitable obj
        if enemyobj ~= nil and obj_check_hitbox_overlap(obj, enemyobj) then --check if obj is touching enemy obj
            if crystalbullettargets[key] then
                hurtenemy = crystalbullettargets[key](enemyobj, shot_dir)
            end
        end
    end
    return hurtenemy
end