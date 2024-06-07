-------------
-- Actions --
-------------
-- Normal.
ACT_MILNE_WATER_FALLING =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING |
        ACT_FLAG_CONTROL_JUMP_HEIGHT
)
ACT_MILNE_WATER_STANDING =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_IDLE | ACT_FLAG_SWIMMING
)
ACT_MILNE_WATER_WALKING =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING
)
ACT_WATER_TWISTER_THOK =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING
)
ACT_MILNE_WATER_GRAB =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING
)
ACT_MILNE_WATER_THROW =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_SWIMMING
)
ACT_WATER_CRYSTAL_LANCE_START =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_INVULNERABLE | ACT_FLAG_SWIMMING
)
ACT_WATER_CRYSTAL_LANCE_DASH =
    allocate_mario_action(
    ACT_GROUP_SUBMERGED | ACT_FLAG_MOVING | ACT_FLAG_INVULNERABLE | ACT_FLAG_SWIMMING
)

function milne_move_with_current(m)
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        return
    end
    local step = {
        x = 0,
        y = 0,
        z = 0
    }
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)

    apply_water_current(m, step)

    m.pos.x = m.pos.x + step.x
    m.pos.y = m.pos.y + step.y
    m.pos.z = m.pos.z + step.z
end

function milne_step_on_the_switch_you_stupid_bitch(m)
    local switch = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvFloorSwitchGrills)
    if switch ~= nil and m.marioObj.platform == switch then
        if (lateral_dist_between_objects(switch, m.marioObj) < 127.5) then
            if switch.oAction == 0 then
                switch.oAction = 1
            end
        end
    end
end

function milne_underwater_check_object_grab(m)
    if (m.marioObj.collidedObjInteractTypes & INTERACT_GRABBABLE) ~= 0 then
        local object = mario_get_collided_object(m, INTERACT_GRABBABLE)
        local dx = object.oPosX - m.pos.x
        local dz = object.oPosZ - m.pos.z
        local dAngleToObject = atan2s(dz, dx) - m.faceAngle.x
        if (dAngleToObject >= -0x2AAA and dAngleToObject <= 0x2AAA) then
            m.usedObj = object
            mario_grab_used_object(m)
            if (m.heldObj ~= nil) then
                m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
                if m.heldObj.behavior == get_behavior_from_id(id_bhvKoopaShellUnderwater) then
                    if (m.playerIndex == 0) then
                        play_shell_music()
                    end
                    set_mario_action(m, ACT_WATER_SHELL_SWIMMING, 0)
                else
                    set_mario_action(m, ACT_MILNE_WATER_FALLING, 1)
                end
                return true
            end
        end
    end
end

function act_milne_water_falling(m)
    local e = gStateExtras[m.playerIndex]
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        if m.forwardVel > 60 then
            mario_set_forward_vel(m, 60)
        end
        if m.forwardVel < -60 then
            mario_set_forward_vel(m, -60)
        end
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_GRAB, 0)
    end

    local animation = MARIO_ANIM_GENERAL_FALL
    if m.vel.y < 0 then
        m.vel.y = m.vel.y + 3
    end
    m.peakHeight = m.pos.y
    if m.actionArg == 0 then
        if m.heldObj ~= nil then
            animation = MARIO_ANIM_FALL_WITH_LIGHT_OBJ
        else
            animation = MARIO_ANIM_GENERAL_FALL
        end
    elseif m.actionArg == 1 then
        if m.heldObj ~= nil then
            animation = MARIO_ANIM_FALL_WITH_LIGHT_OBJ
        else
            animation = MARIO_ANIM_FALL_FROM_WATER
        end
    else
        if m.heldObj ~= nil then
            animation = MARIO_ANIM_JUMP_WITH_LIGHT_OBJ
        else
            animation = MARIO_ANIM_SINGLE_JUMP
        end
    end

    local stepResult = perform_air_step(m, 0)
    update_air_without_turn(m)
    set_mario_animation(m, animation)
    if stepResult == AIR_STEP_LANDED then --hit floor or cancelled
        set_mario_action(m, ACT_MILNE_WATER_STANDING, 0)
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 and m.actionTimer >= 1 and m.heldObj == nil then
        m.faceAngle.y = m.intendedYaw
        return set_mario_action(m, ACT_WATER_TWISTER_THOK, 0)
    end

    if (m.pos.y >= m.waterLevel - 80) and m.vel.y > 0 then
        m.pos.y = m.waterLevel
        set_mario_particle_flags(m, PARTICLE_WATER_SPLASH, false)
        if (m.playerIndex == 0) then set_camera_mode(m.area.camera, m.area.camera.defMode, 1) end
        if m.heldObj ~= nil then
            m.action = ACT_HOLD_JUMP
        else
            m.action = ACT_JUMP
        end
    end

    milne_move_with_current(m)

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_milne_water_standing(m)
    local e = gStateExtras[m.playerIndex]

    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end
    e.watercrystallanced = 0

    stationary_ground_step(m)
    milne_step_on_the_switch_you_stupid_bitch(m)

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 50
        mario_set_forward_vel(m, 0)
        return set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_GRAB, 0)
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        m.faceAngle.y = m.intendedYaw
        return set_mario_action(m, ACT_MILNE_WATER_WALKING, 0)
    end

    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_FALLING, 0)
    end

    if m.heldObj ~= nil then
        set_mario_animation(m, MARIO_ANIM_IDLE_WITH_LIGHT_OBJ)
    else
        if m.actionState == 0 then
            set_mario_animation(m, MARIO_ANIM_IDLE_HEAD_LEFT)
        elseif m.actionState == 1 then
            set_mario_animation(m, MARIO_ANIM_IDLE_HEAD_RIGHT)
        elseif m.actionState == 2 then
            set_mario_animation(m, MARIO_ANIM_IDLE_HEAD_CENTER)
        end
    end

    if is_anim_at_end(m) ~= 0 then
        if m.actionState >= 3 then
            m.actionState = 0
        else
            m.actionState = m.actionState + 1
        end
    end

    if (m.pos.y >= m.waterLevel - 150) then
        set_mario_particle_flags(m, PARTICLE_IDLE_WATER_WAVE, false)
    end

    milne_move_with_current(m)

    return 0
end

function act_milne_water_walking(m)
    local e = gStateExtras[m.playerIndex]

    e.watercrystallanced = 0

    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end

    if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_STANDING, 0)
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 50
        play_character_sound(m, CHAR_SOUND_HOOHOO)
        return set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_GRAB, 2)
    end

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_STANDING, 0)
    end

    update_walking_speed(m)
    local stepResult = perform_ground_step(m)
    milne_step_on_the_switch_you_stupid_bitch(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_MILNE_WATER_FALLING, 1)
    elseif stepResult == GROUND_STEP_NONE then
        if m.heldObj ~= nil then
            anim_and_audio_for_hold_walk(m)
        else
            anim_and_audio_for_walk(m)
        end
        if m.forwardVel < 20 then
            mario_set_forward_vel(m, 20)
        end
    elseif stepResult == GROUND_STEP_HIT_WALL then
        push_or_sidle_wall(m, m.pos)
        m.actionTimer = 0
    end

    milne_move_with_current(m)

    return 0
end

function act_water_twister_thok(m)
    local e = gStateExtras[m.playerIndex]
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end
    if m.actionTimer < 5 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    end
    if m.vel.y < -20 then
        m.vel.y = m.vel.y + 3
    end
    m.marioBodyState.handState = MARIO_HAND_OPEN
    smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_TWISTER_THOK")

    m.peakHeight = m.pos.y
    set_mario_animation(m, MARIO_ANIM_TWIRL)
    if m.actionArg == 0 then
        if m.actionTimer == 0 then
            m.actionState = m.actionArg
            play_character_sound(m, CHAR_SOUND_HOOHOO)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            audio_sample_play(MILNE_SOUND_ACTION_THOK, m.pos, 1)
        elseif m.actionTimer > 0 and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            m.faceAngle.y = m.intendedYaw
            m.actionTimer = 0
            return set_mario_action(m, ACT_WATER_TWISTER_THOK, 1)
        end
        e.rotAngle = e.rotAngle + 0x2000
    elseif m.actionArg == 1 then
        if m.actionTimer == 0 then
            m.actionState = m.actionArg
            play_character_sound(m, CHAR_SOUND_YAHOO)
            audio_sample_play(MILNE_SOUND_ACTION_THOK_DOWN, m.pos, 1)
        end
        e.rotAngle = e.rotAngle + 0x3053
    end

    if (m.pos.y >= m.waterLevel - 100) and m.vel.y > 0 then
        m.pos.y = m.waterLevel
        set_mario_particle_flags(m, PARTICLE_WATER_SPLASH, false)
        m.action = ACT_TWISTER_THOK
        if (m.playerIndex == 0) then set_camera_mode(m.area.camera, m.area.camera.defMode, 1) end
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_GRAB, 0)
    end

    local stepResult = perform_air_step(m, 0)
    update_air_without_turn(m)
    set_mario_animation(m, MARIO_ANIM_TWIRL)
    if stepResult == AIR_STEP_LANDED then
        m.faceAngle.y = m.intendedYaw
        set_mario_action(m, ACT_MILNE_WATER_STANDING, 0)
    end
    if e.rotAngle > 0x10000 then
        e.rotAngle = e.rotAngle - 0x10000
    end
    if e.rotAngle < -0x10000 then
        e.rotAngle = e.rotAngle + 0x10000
    end
    m.marioObj.header.gfx.angle.y = m.marioObj.header.gfx.angle.y + e.rotAngle

    milne_move_with_current(m)

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_milne_water_grab(m)
    set_mario_animation(m, MARIO_ANIM_A_POSE)

    milne_underwater_check_object_grab(m)
    milne_step_on_the_switch_you_stupid_bitch(m)

    local stepResult = 0
    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        stepResult = perform_air_step(m, 0)
    elseif (m.input & INPUT_OFF_FLOOR) == 0 then
        stepResult = perform_ground_step(m)
    end

    if stepResult == GROUND_STEP_NONE then
        apply_slope_decel(m, 1)
    end

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ACT_MILNE_WATER_THROW, 0)
    end

    m.actionTimer = m.actionTimer + 1

    if stepResult == GROUND_STEP_NONE then
        if (m.input & INPUT_A_PRESSED) ~= 0 then
            m.vel.y = 50
            play_character_sound(m, CHAR_SOUND_HOOHOO)
            return set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
        end
        apply_slope_decel(m, 1)
    end

    return 0
end

function act_milne_water_throw(m)
    local e = gStateExtras[m.playerIndex]
    mario_throw_held_object(m)

    if m.actionTimer == 0 then --and m.marioObj.collidedObjInteractTypes ~= INTERACT_GRABBABLE
        m.faceAngle.y = m.intendedYaw
        play_character_sound(m, CHAR_SOUND_YAH_WAH_HOO)
        m.marioObj.header.gfx.animInfo.animFrame = 0
    end

    set_mario_animation(m, MARIO_ANIM_THROW_LIGHT_OBJECT)

    local stepResult = 0
    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        stepResult = perform_air_step(m, 0)
    elseif (m.input & INPUT_OFF_FLOOR) == 0 then
        stepResult = perform_ground_step(m)
    end

    if stepResult == GROUND_STEP_NONE then
        if (m.input & INPUT_A_PRESSED) ~= 0 then
            m.vel.y = 50
            play_character_sound(m, CHAR_SOUND_HOOHOO)
            return set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
        end
        apply_slope_decel(m, 1)
    end

    
    if (m.input & INPUT_B_PRESSED) ~= 0 and 
    (m.actionTimer > 0 and m.actionTimer < 10) then
        if e.watercrystallanced <= 0 then
            m.faceAngle.y = m.intendedYaw
            set_mario_action(m, ACT_WATER_CRYSTAL_LANCE_START, 0)
        end
    end
    
    if (m.pos.y >= m.waterLevel - 80) and m.vel.y > 0 then
        m.pos.y = m.waterLevel
        set_mario_particle_flags(m, PARTICLE_WATER_SPLASH, false)
        if (m.playerIndex == 0) then set_camera_mode(m.area.camera, m.area.camera.defMode, 1) end
        m.action = ACT_SHARD_TOSS_AIR
    end

    if m.actionTimer > 15 then
        return set_mario_action(m, ACT_MILNE_WATER_FALLING, 0)
    end
    if m.vel.y < 0 then
        m.vel.y = m.vel.y + 3
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_water_crystal_lance_start(m)
    local e = gStateExtras[m.playerIndex]
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end
    if m.actionTimer > 10 then
        return set_mario_action(m, ACT_WATER_CRYSTAL_LANCE_DASH, 0)
    else
        set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRYSTAL_LANCE")
        set_anim_to_frame(m, 1)
        mario_set_forward_vel(m, -20)
        m.vel.y = 0
        m.actionTimer = m.actionTimer + 1
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
        stepResult = perform_air_step(m, 0)
    end

    milne_move_with_current(m)

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_water_crystal_lance_dash(m)
    local e = gStateExtras[m.playerIndex]
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        m.health = m.health + 0x100
    end
    e.watercrystallanced = 30

    if m.actionArg == 0 then
        if m.actionTimer == 0 then
            m.actionState = m.actionArg
            e.animFrame = 0
            play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
            audio_sample_play(MILNE_SOUND_ACTION_LANCE_DASH, m.pos, 1)
            if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                m.health = m.health - 0x100
            end
        end

        if m.actionTimer > 40 then
            return set_mario_action(m, ACT_MILNE_WATER_FALLING, 0)
        else
            set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
            smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRYSTAL_LANCE")
            set_anim_to_frame(m, e.animFrame)
            if e.animFrame >= 25 then
                e.animFrame = 25
            end
            if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                mario_set_forward_vel(m, 80)
            else
                mario_set_forward_vel(m, 70)
            end
            m.vel.y = 0
            m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100)
            m.actionTimer = m.actionTimer + 1
            m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
            e.animFrame = e.animFrame + 1
        end

        local stepResult = 0
        if (m.input & INPUT_OFF_FLOOR) ~= 0 then
            stepResult = perform_air_step(m, 0)
        elseif (m.input & INPUT_OFF_FLOOR) == 0 then
            stepResult = perform_ground_step(m)
        end

        if (stepResult == AIR_STEP_HIT_WALL or stepResult == GROUND_STEP_HIT_WALL) then
            m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
            audio_sample_play(MILNE_SOUND_ACTION_LANCE_WALL, m.pos, 1)
            return set_mario_action(m, ACT_WATER_CRYSTAL_LANCE_DASH, 1)
        end
        if stepResult == GROUND_STEP_NONE then
            if (m.input & INPUT_A_PRESSED) ~= 0 then
                m.vel.y = 50
                play_character_sound(m, CHAR_SOUND_HOOHOO)
                return set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
            end
            apply_slope_decel(m, 1)
        elseif stepResult == AIR_STEP_NONE then
            if (m.input & INPUT_A_PRESSED) ~= 0 then
                return set_mario_action(m, ACT_WATER_TWISTER_THOK, 0)
            end
        end
    end

    if m.actionArg == 1 then
        m.vel.y = 0
        mario_set_forward_vel(m, 0)
        if (m.input & INPUT_A_PRESSED) ~= 0 then
            m.vel.y = 65.0
            set_mario_action(m, ACT_MILNE_WATER_FALLING, 2)
            play_character_sound(m, CHAR_SOUND_HOOHOO)
        end
        if (m.input & INPUT_Z_PRESSED) ~= 0 then
            m.vel.y = -10
            set_mario_action(m, ACT_MILNE_WATER_FALLING, 0)
        end
    end
    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    m.actionTimer = m.actionTimer + 1
    return 0
end


hook_mario_action(ACT_MILNE_WATER_FALLING, act_milne_water_falling)
hook_mario_action(ACT_MILNE_WATER_STANDING, act_milne_water_standing)
hook_mario_action(ACT_MILNE_WATER_WALKING, act_milne_water_walking)
hook_mario_action(ACT_MILNE_WATER_GRAB, act_milne_water_grab)
hook_mario_action(ACT_MILNE_WATER_THROW, act_milne_water_throw)
hook_mario_action(ACT_WATER_TWISTER_THOK, act_water_twister_thok)
hook_mario_action(ACT_WATER_CRYSTAL_LANCE_DASH, act_water_crystal_lance_dash)
hook_mario_action(ACT_WATER_CRYSTAL_LANCE_START, act_water_crystal_lance_start)
