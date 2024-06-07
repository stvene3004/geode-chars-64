define_custom_obj_fields({
    oCrystalOwner = 'u32',
    oCrystalDestroyNextFrames = 'u32',
    oShockwaveThreshold = 'u32',
    oOrbScale = 'u32',
    oShockwaveScale = 'u32'
})

----------------
-- Shard Toss --
----------------
-- Main object behavior.
function crystal_bullet_init(o)
    local np = network_player_from_global_index(o.oCrystalOwner)
    local m = gMarioStates[np.localIndex]

    o.oFlags =
        (OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW |
        OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    o.activeFlags = o.activeFlags | ACTIVE_FLAG_UNK9

    if (m.playerIndex ~= 0) then
        o.oIntangibleTimer = 0
        if gServerSettings.playerInteractions == PLAYER_INTERACTIONS_PVP then
            o.oInteractType = INTERACT_DAMAGE
            o.oDamageOrCoinValue = 1
        end
    end
    
    cur_obj_scale(0.5)
    o.oFriction = 1
    o.oVelY = 0

    -- hitbox
    o.hitboxRadius = 80
    o.oWallHitboxRadius = 0
    o.hitboxHeight = 80
    o.hitboxDownOffset = 80
    o.oForwardVel = 120

    --network_init_object(o, true, { "oCrystalOwner" })

end

function crystal_bullet_loop(o)
    local collisionFlags = object_step()
    
    if (collisionFlags & OBJ_COL_FLAG_GROUNDED) ~= 0 
        or (collisionFlags & OBJ_COL_FLAG_HIT_WALL) ~= 0
        or o.oForwardVel < 10 then
            crystal_bullet_death(o)
    end
    
    if projectileattack(o, o.oMoveAngleYaw) then
        crystal_bullet_death(o)
    end
    
    spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
    o.oInteractStatus = o.oInteractStatus + ~(INT_STATUS_INTERACTED)
    o.oForwardVel = o.oForwardVel - 3
end

function toss_shards(m)
    for i = 0,3 -1,1 do
        spawn_non_sync_object(
            id_bhvCrystalBullet,
            E_MODEL_MILNE_CRYSTAL,
            m.pos.x, m.pos.y + 100, m.pos.z,
            function(o)
                o.oMoveAngleYaw = m.faceAngle.y
                o.oCrystalOwner = gNetworkPlayers[m.playerIndex].globalIndex
                if i == 1 then
                    o.oMoveAngleYaw = o.oMoveAngleYaw + 0x500
                elseif i == 2 then
                    o.oMoveAngleYaw = o.oMoveAngleYaw - 0x500
                end
            end
        )
    end
end

-- Interactions

function crystal_bullet_hit_other_players(o)
    local np = network_player_from_global_index(o.oCrystalOwner)
    local m = gMarioStates[np.localIndex]
    local player = nearest_mario_state_to_object(o)
    if player ~= nil and obj_check_hitbox_overlap(o, player.marioObj) and player.playerIndex ~= m.playerIndex then
        return true
    end
    return false
end

function crystal_bullet_death(o)
    local position = {x = o.oPosX, y = o.oPosY, z =o.oPosZ,}
    audio_sample_play(MILNE_OBJECT_CRYSTAL_SHATTER, position, 0.5)
    obj_mark_for_deletion(o)
    for i = 0,math.random(2, 5),1 do
        spawn_non_sync_object(
            id_bhvCrystalShatter,
            E_MODEL_MILNE_CRYSTAL,
            o.oPosX, o.oPosY, o.oPosZ,
            function(c)
                c.oMoveAngleYaw = math.random(0x0000, 0x10000)
            end
        )
    end
end

function milne_shockwave_init(o)
    local np = network_player_from_global_index(o.oCrystalOwner)
    local m = gMarioStates[np.localIndex]

    o.oFlags =
        (OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW |
        OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    o.activeFlags = o.activeFlags | ACTIVE_FLAG_UNK9
    
    o.oShockwaveScale = 1
    o.oFriction = 1
    o.oVelY = 0

    -- hitbox
    o.oIntangibleTimer = 0
    o.hitboxRadius = 80
    o.hitboxHeight = 80
    o.oOpacity = 255

end

function milne_shockwave_loop(o)
    cur_obj_scale(o.oShockwaveScale)
    cur_obj_align_gfx_with_floor()
    --shockwave_attack(o, o.oMoveAngleYaw)
    o.oShockwaveScale = approach_f32_symmetric(o.oShockwaveScale, o.oShockwaveThreshold, o.oShockwaveThreshold / 80)
    o.oOpacity = approach_f32_symmetric(o.oOpacity, 0, o.oShockwaveThreshold / 200)
    o.oInteractStatus = o.oInteractStatus + ~(INT_STATUS_INTERACTED)
    
    if o.oTimer > 120 then
        obj_mark_for_deletion(o)
    end
    
    o.oTimer = o.oTimer + 1
end

---------------------
-- Shatter pieces. --
---------------------

function crystal_shatter_init(o)
    o.oFlags =
        (OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW |
        OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    -- hitbox
    o.oIntangibleTimer = 0
    cur_obj_scale(0.2)
    o.hitboxRadius = o.header.gfx.scale.x * 100
    o.hitboxHeight = o.header.gfx.scale.y * 100
    o.oForwardVel = math.random(6, 10)
    o.oVelY = math.random(30, 50)

    -- physics
    o.oWallHitboxRadius = o.hitboxRadius
    o.oGravity          = -4.5
    o.oBounciness       = -0.65
    o.oFriction       = 0.8

end

function crystal_shatter_loop(o)
    
    -- perform physics
    cur_obj_update_floor_and_walls()
    cur_obj_move_standard(0)
    
    if (o.oMoveFlags & OBJ_MOVE_ON_GROUND) ~= 0 or (o.oMoveFlags & OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        o.oTimer = o.oTimer + 1
        if o.oTimer > 60 then
            obj_mark_for_deletion(o)
        end
    end
        
    if (o.oMoveFlags & OBJ_MOVE_BOUNCE) ~= 0
    or (o.oMoveFlags & OBJ_MOVE_ON_GROUND) ~= 0
    or (o.oMoveFlags & OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        o.oForwardVel = o.oForwardVel * o.oFriction
        o.oFaceAnglePitch = 0x000
    else
        o.oFaceAnglePitch = o.oFaceAnglePitch + 0x200 * o.oForwardVel
    end

    o.oInteractStatus = o.oInteractStatus + ~(INT_STATUS_INTERACTED)
end

-------------------
-- Lance pieces. --
-------------------

function lance_piece_init(o)
    o.oFlags =
        (OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW |
        OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    -- hitbox
    o.oIntangibleTimer = 0
    cur_obj_scale(1)

end

function lance_piece_loop(o)
    local np = network_player_from_global_index(o.oCrystalOwner)
    local m = gMarioStates[np.localIndex]
    
    if o.oAction == 1 then
        o.oHomeX = m.pos.x
        o.oHomeY = m.pos.y + 100
        o.oHomeZ = m.pos.z
    else
        o.oHomeX = get_hand_foot_pos_x(m, 0)
        o.oHomeY = get_hand_foot_pos_y(m, 0)
        o.oHomeZ = get_hand_foot_pos_z(m, 0)
    end
    
    local homePitch = obj_get_pitch_to_home(cur_obj_lateral_dist_to_home())
    local homeAngle = cur_obj_angle_to_home()

    o.oMoveAngleYaw = homeAngle
    o.oMoveAnglePitch = homePitch
    o.oFaceAnglePitch = o.oFaceAnglePitch + 0x3000
    o.oVelY = sins(o.oMoveAnglePitch) * -90
    o.oForwardVel = coss(o.oMoveAnglePitch) * 90

    -- perform physics
    obj_move_xyz_using_fvel_and_yaw(o)
    
    if o.oTimer > 10 then
        obj_mark_for_deletion(o)
    end
    
    o.oTimer = o.oTimer + 1
end

function spawn_lance_pieces(m, num, centered)
    for i = 0,num -1,1 do
        spawn_non_sync_object(
            id_bhvLancePiece,
            E_MODEL_MILNE_CRYSTAL,
            m.pos.x + math.random(-300, 300), m.pos.y + math.random(-300, 300), m.pos.z + math.random(-300, 300),
            function(o)
                if centered == true then o.oAction = 1 end
                o.oCrystalOwner = gNetworkPlayers[m.playerIndex].globalIndex
            end
        )
    end
end

--------------------------------
-- Crizlyn Orb Spirit Thingy. --
--------------------------------

function crizlyn_orb_init(o)
    o.oFlags =
        (OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_COMPUTE_DIST_TO_MARIO | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW |
        OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    -- hitbox
    o.oIntangibleTimer = 0
    o.oOrbScale = 10
    cur_obj_scale(o.oOrbScale/10)

end

local targetScale = 10
function crizlyn_orb_loop(o)
    
    if o.oOrbScale >= 10 then targetScale = 3
    elseif o.oOrbScale <= 3 then targetScale = 10 end
    
    o.oOrbScale = approach_s16_symmetric(o.oOrbScale, targetScale, 2)
    cur_obj_scale(o.oOrbScale/10)

    o.oVelY = 10
    obj_set_billboard(o)
    
    -- perform physics
    obj_move_xyz_using_fvel_and_yaw(o)
    
    if o.oTimer > 60 * 30 then
        obj_mark_for_deletion(o)
    end
    
    spawn_non_sync_object(
        id_bhvCelebrationStarSparkle,
        E_MODEL_SPARKLES,
        o.oPosX + math.random(-50, 50), o.oPosY + math.random(-50, 50), o.oPosZ + math.random(-50, 50),
        nil
    )

    o.oTimer = o.oTimer + 1
end

function crizlyn_orb_bubble_loop(o)
    local m = gMarioStates[o.heldByPlayerIndex]
    obj_copy_pos(o, m.marioObj)
    
    if o.oOrbScale >= 10 then targetScale = 3
    elseif o.oOrbScale <= 3 then targetScale = 10 end
    
    o.oOrbScale = approach_s16_symmetric(o.oOrbScale, targetScale, 2)
    cur_obj_scale(o.oOrbScale/10)

    obj_set_billboard(o)    
    
    spawn_non_sync_object(
        id_bhvCelebrationStarSparkle,
        E_MODEL_SPARKLES,
        o.oPosX + math.random(-50, 50), o.oPosY + math.random(-50, 50), o.oPosZ + math.random(-50, 50),
        nil
    )
    
    if m.action ~= ACT_BUBBLED or is_player_in_local_area(m) == 0 then
        spawn_lance_pieces(m, math.random(6, 12), true)
        audio_sample_play(CRIZLYN_SHATTER_REVERSE, m.pos, 1)
        obj_mark_for_deletion(o)
        m.bubbleObj = nil
    end

    o.oTimer = o.oTimer + 1
end

function milne_death(m)
    audio_sample_play(CRIZLYN_SHATTER, m.pos, 1)
    spawn_non_sync_object(
        id_bhvCrizlynOrb,
        E_MODEL_MILNE_ORB,
        m.pos.x, m.pos.y, m.pos.z,
        function(o)
            local position = {x = o.oPosX, y = o.oPosY, z =o.oPosZ,}
            audio_sample_play(CRIZLYN_CORE, position, 1)
        end
    )
    for i = 0,math.random(36, 48),1 do
        spawn_non_sync_object(
            id_bhvCrystalShatter,
            E_MODEL_MILNE_CRYSTAL,
            m.pos.x, m.pos.y, m.pos.z,
            function(c)
                c.oMoveAngleYaw = m.faceAngle.y + math.random(0x0000, 0x10000)
            end
        )
    end
end

id_bhvCrystalBullet = hook_behavior(nil, OBJ_LIST_GENACTOR, true, crystal_bullet_init, crystal_bullet_loop)
id_bhvMilneShockwave = hook_behavior(nil, OBJ_LIST_GENACTOR, true, milne_shockwave_init, milne_shockwave_loop)
id_bhvCrystalShatter = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crystal_shatter_init, crystal_shatter_loop)
id_bhvLancePiece = hook_behavior(nil, OBJ_LIST_DEFAULT, true, lance_piece_init, lance_piece_loop)
id_bhvCrizlynOrb = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crizlyn_orb_init, crizlyn_orb_loop)
id_bhvCrizlynOrbBubble = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, true, crizlyn_orb_init, crizlyn_orb_bubble_loop)