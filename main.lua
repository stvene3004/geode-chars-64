-- name: \\#de04fa\\Milne the Crystal Fox
-- incompatible:
-- description: Type "milne \\#00C7FF\\on\\#ffffff\\|\\#A02200\\off\\#ffffff\\" in chat to play as Milne, a character from an SRB2 mod.\n\ \n\OC and original moveset by \\#de04fa\\CystallineGazer\\#ffffff\\ and the team behind the original SRB2 mod. Go support her by playin' their mod: \\#de04fa\\https://mb.srb2.org/addons/horizonchars.555/\\#ffffff\\\n\ \n\Moveset recreation by \\#00FFFF\\steven.\\#FFFFFF\\\n\ \n\Voice Actors Sampled:\n\  AJ Michalka (She-Ra and the Princesses of Power)\n\  Erica Lindbeck (Helluva Boss, Mortal Kombat 11)\n\  Ashly Burch(Mortal Kombat X)

-----------------------
-- Variables 'n shit --
-----------------------

E_MODEL_MILNE = smlua_model_util_get_id("milne_geo")
E_MODEL_MILNE_RECOLORABLE = smlua_model_util_get_id("milne_recolorable_geo")
E_MODEL_MILNE_CRYSTAL = smlua_model_util_get_id("milne_crystal_geo")
E_MODEL_MILNE_ORB = smlua_model_util_get_id("milne_orb_geo")

TEX_HUD_MILNE = get_texture_info("Milne_HUD")
TEX_HUD_KAZOTSKY = get_texture_info("kazotskyicon")
SOD = audio_stream_load("Soldier of Dance (SM64 Mix).ogg")
audio_stream_set_looping(SOD, true)

MILNE_SOUND_ACTION_THOK = audio_sample_load("milne-action-thok.mp3")
MILNE_SOUND_ACTION_THOK_DOWN = audio_sample_load("milne-action-thok-down.mp3")
MILNE_SOUND_ACTION_SHARD_TOSS = audio_sample_load("milne-action-shard-toss.mp3")

MILNE_SOUND_ACTION_LANCE_START = audio_sample_load("milne-action-lance-start.mp3")
MILNE_SOUND_ACTION_LANCE_DASH = audio_sample_load("milne-action-lance-dash.mp3")
MILNE_SOUND_ACTION_LANCE_WALL = audio_sample_load("milne-action-lance-wall.mp3")

MILNE_OBJECT_CRYSTAL_SHATTER = audio_sample_load("milne-object-crystal-shatter.mp3")

CRIZLYN_SHATTER = audio_sample_load("crizlyn-shatter.ogg")
CRIZLYN_SHATTER_REVERSE = audio_sample_load("crizlyn-shatter-reverse.ogg")
CRIZLYN_CORE = audio_sample_load("crizlyn-core.ogg")

milne = 0
showIcon = 0

local recolorable = 0

gStateExtras = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]
    e.animFrame = 0
    e.milnePeakHeight = 0
    e.rotAngle = 0
    e.crystallanced = 0
    e.watercrystallanced = 0
    e.impactLanded = 0
    e.firstJump = 0
    e.clspeed = 0
    e.dieded = 0
end

ACT_TWISTER_THOK =
    allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_CRYSTAL_LANCE_START =
    allocate_mario_action(
    ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION
)
ACT_CRYSTAL_LANCE_START_GROUND =
    allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_CRYSTAL_LANCE_DASH =
    allocate_mario_action(ACT_GROUP_MOVING| ACT_FLAG_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_CRYSTAL_LANCE_DASH_AIR =
    allocate_mario_action(
    ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION
)
ACT_CRYSTAL_LANCE_WALL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_STATIONARY)
ACT_KAZOTSKY_KICK = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_MILNE_MELEE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_MILNE_MELEE_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_SHARD_TOSS = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_SHARD_TOSS_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_MILNE_BOWSER_THROW = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_MILNE_BOWSER_THROW_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)

-- Character Select support.

function milne_command(msg)
    if msg == "on" then
        djui_chat_message_create("\\#de04fa\\Milne\\#ffffff\\ is \\#00C7FF\\on\\#ffffff\\!")
        gPlayerSyncTable[0].overwriteCharToMario = true
        gPlayerSyncTable[0].geodeChar = 1
        return true
    elseif msg == "off" then
        djui_chat_message_create("\\#de04fa\\Milne\\#ffffff\\ is \\#A02200\\off\\#ffffff\\!")
        gPlayerSyncTable[0].overwriteCharToMario = false
        gPlayerSyncTable[0].geodeChar = 0
        return true
    end
end

function milnecolor(msg)
    if msg == "on" then
        djui_chat_message_create("\\#de04fa\\Milne\\#ffffff\\ is \\#00C7FF\\recolorable\\#ffffff\\!")
        recolorable = 1
        return true
    elseif msg == "off" then
        djui_chat_message_create("\\#de04fa\\Milne\\#ffffff\\ is \\#A02200\\not recolorable\\#ffffff\\!")
        recolorable = 0
        return true
    end
end

local charSelectMilne = 0
local charSelectMilneRecolorable = 0
if _G.charSelectExists then
    charSelectMilne = _G.charSelect.character_add(
        "Milne the Crystal Fox",
        {
            "Milne uses crystal powers and",
            "raw strength to take out her foes!",
            "",
            "Sonic OC owned by CrystallineGazer."
        },
        "steven.",
        {r = 255, g = 0, b = 255},
        E_MODEL_MILNE,
        CT_MARIO,
        TEX_HUD_MILNE
    )

    charSelectMilneRecolorable = _G.charSelect.character_add(
        "Milne (Recolorable)",
        {
            "A separate recolorable model",
            "for Milne, since her normal",
            "color palette can't be replicated",
            "in the palette editor."
        },
        "steven.",
        {r = 255, g = 0, b = 255},
        E_MODEL_MILNE_RECOLORABLE,
        CT_MARIO,
        TEX_HUD_MILNE
    )

    -- Handle Voicelines via Character Select
    _G.charSelect.character_add_voice(E_MODEL_MILNE, MILNE_VOICETABLE)
    _G.charSelect.character_add_voice(E_MODEL_MILNE_RECOLORABLE, MILNE_VOICETABLE)

    hook_event(
        HOOK_CHARACTER_SOUND,
        function(m, sound)
            if _G.charSelect.character_get_voice(m) == MILNE_VOICETABLE then
                return _G.charSelect.voice.sound(m, sound)
            end
        end
    )
    hook_event(
        HOOK_MARIO_UPDATE,
        function(m)
            if _G.charSelect.character_get_voice(m) == MILNE_VOICETABLE then
                return _G.charSelect.voice.snore(m)
            end
        end
    )
else
    hook_chat_command(
        "milne",
        "[\\#00C7FF\\on\\#ffffff\\|\\#A02200\\off\\#ffffff\\] turn \\#de04fa\\Milne \\#00C7FF\\on \\#ffffff\\or \\#A02200\\off",
        milne_command
    )
    hook_chat_command(
        "milnecolor",
        "[\\#00C7FF\\on\\#ffffff\\|\\#A02200\\off\\#ffffff\\] Toggle \\#de04fa\\Milne's \\#ffffff\\recolorability.",
        milnecolor
    )
end

---------------
--- Actions ---
---------------

function act_twister_thok(m)
    local e = gStateExtras[m.playerIndex]
    if m.actionTimer < 5 then
        m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    end

    set_mario_animation(m, MARIO_ANIM_TWIRL)
    smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_TWISTER_THOK")
    m.marioBodyState.handState = MARIO_HAND_OPEN
    m.marioBodyState.eyeState = 4

    if m.actionArg == 0 then
        e.firstJump = 1
        if m.actionTimer == 0 then
            audio_sample_play(MILNE_SOUND_ACTION_THOK, m.pos, 1)
            m.actionState = m.actionArg
            play_character_sound(m, CHAR_SOUND_HOOHOO)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
            if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                m.health = m.health - 0x100
            end
        end

        e.rotAngle = e.rotAngle + 0x3000
        
        if m.actionTimer > 0 and (m.input & INPUT_A_PRESSED) ~= 0 then
            return set_mario_action(m, ACT_TWISTER_THOK, 1)
        end

    elseif m.actionArg == 1 then
        if m.actionTimer == 0 then
            audio_sample_play(MILNE_SOUND_ACTION_THOK_DOWN, m.pos, 1)
            m.actionState = m.actionArg
            play_character_sound(m, CHAR_SOUND_YAHOO)
            if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                m.health = m.health - 0x100
            end
        end
        e.rotAngle = e.rotAngle + 0x4000

    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_SHARD_TOSS_AIR, 0)
    end

    local stepResult = common_air_action_step(m, ACT_DOUBLE_JUMP_LAND, MARIO_ANIM_TWIRL, AIR_STEP_CHECK_HANG)
    if stepResult == AIR_STEP_LANDED then
        --m.faceAngle.y = atan2s(m.vel.z, m.vel.x)
        if should_get_stuck_in_ground(m) ~= 0 then
            queue_rumble_data_mario(m, 5, 80)
            play_character_sound(m, CHAR_SOUND_OOOF2)
            set_mario_action(m, ACT_FEET_STUCK_IN_GROUND, 0)
        end
    end

    if e.rotAngle > 0x10000 then
        e.rotAngle = e.rotAngle - 0x10000
    elseif e.rotAngle < -0x10000 then
        e.rotAngle = e.rotAngle + 0x10000
    end

    m.marioObj.header.gfx.angle.y = m.marioObj.header.gfx.angle.y + e.rotAngle

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_crystal_lance_start(m)
    local e = gStateExtras[m.playerIndex]

    if m.actionTimer > 5 then
        return set_mario_action(m, ACT_CRYSTAL_LANCE_DASH_AIR, 0)
    end

    set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
    smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRYSTAL_LANCE")
    set_anim_to_frame(m, 1)
    mario_set_forward_vel(m, -20)
    m.vel.y = 0
    m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

    stepResult = perform_air_step(m, 0)

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_crystal_lance_start_ground(m)
    local e = gStateExtras[m.playerIndex]

    if m.actionTimer > 5 then
        return set_mario_action(m, ACT_CRYSTAL_LANCE_DASH, 0)
    end

    set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
    smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRYSTAL_LANCE")
    set_anim_to_frame(m, 1)
    mario_set_forward_vel(m, -20)
    m.particleFlags = m.particleFlags | PARTICLE_SPARKLES

    stepResult = perform_ground_step(m)

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_crystal_lance_dash(m)
    local e = gStateExtras[m.playerIndex]
    local endAction = ACT_WALKING

    if m.actionTimer == 0 then
        m.actionState = m.actionArg
        e.animFrame = 0
        play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
        audio_sample_play(MILNE_SOUND_ACTION_LANCE_DASH, m.pos, 1)
        if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
            m.health = m.health - 0x100
        end
    end
    set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
    smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRYSTAL_LANCE")
    set_anim_to_frame(m, e.animFrame)
    if e.animFrame >= 25 then
        e.animFrame = 25
    end

    if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
        mario_set_forward_vel(m, 130)
    else
        mario_set_forward_vel(m, 90)
    end

    if m.actionTimer > 0 and (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_JUMP, 1)
    end

    m.vel.y = 0
    m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100)
    set_mario_particle_flags(m, (PARTICLE_DUST | PARTICLE_SPARKLES), false)
    play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    e.animFrame = e.animFrame + 1

    local stepResult = perform_ground_step(m)

    if m.actionTimer > 20 then
        return set_mario_action(m, ACT_WALKING, 0)
    end

    if stepResult == GROUND_STEP_HIT_WALL and m.wall ~= nil then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        audio_sample_play(MILNE_SOUND_ACTION_LANCE_WALL, m.pos, 1)
        set_mario_action(m, ACT_CRYSTAL_LANCE_WALL, 0)
    elseif stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_CRYSTAL_LANCE_DASH_AIR
    end

    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_crystal_lance_dash_air(m)
    local e = gStateExtras[m.playerIndex]

    if m.actionTimer == 0 then
        m.actionState = m.actionArg
        e.animFrame = 0
        play_character_sound(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE)
        audio_sample_play(MILNE_SOUND_ACTION_LANCE_DASH, m.pos, 1)
        if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
            m.health = m.health - 0x100
        end
    end
    set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
    set_anim_to_frame(m, e.animFrame)
    if e.animFrame >= 25 then
        e.animFrame = 25
    end

    if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
        mario_set_forward_vel(m, 130)
    else
        mario_set_forward_vel(m, 90)
    end

    if m.actionTimer > 0 and (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_TWISTER_THOK, 0)
    end

    m.vel.y = 0
    m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x100, 0x100)
    m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    e.animFrame = e.animFrame + 1

    local stepResult = perform_air_step(m, 0)

    if m.actionTimer > 20 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if stepResult == AIR_STEP_HIT_WALL and m.wall ~= nil then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        audio_sample_play(MILNE_SOUND_ACTION_LANCE_WALL, m.pos, 1)
        set_mario_action(m, ACT_CRYSTAL_LANCE_WALL, 0)
    elseif stepResult == AIR_STEP_LANDED then
        m.action = ACT_CRYSTAL_LANCE_DASH
    end

    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_crystal_lance_wall(m)
    local e = gStateExtras[m.playerIndex]
    m.vel.y = 0
    e.firstJump = 0
    mario_set_forward_vel(m, 0)
    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    if (m.input & INPUT_A_PRESSED) ~= 0 then
        set_jumping_action(m, ACT_DOUBLE_JUMP, 0)
        play_character_sound(m, CHAR_SOUND_HOOHOO)
        m.vel.y = 65.0
    end
    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        m.vel.y = -10
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if (m.input & INPUT_B_PRESSED) ~= 0 then
        set_mario_action(m, ACT_JUMP_KICK, 0)
    end
end

function act_kazotsky_kick(m)

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        m.vel.y = 30
        return set_mario_action(m, ACT_JUMP, 0)
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_PUNCHING, 0)
    end

    if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
        return set_mario_action(m, ACT_DOUBLE_JUMP_LAND, 0)
    end

    if (m.marioObj.header.gfx.animInfo.animFrame == 1 or m.marioObj.header.gfx.animInfo.animFrame == 11) then
        play_sound(SOUND_ACTION_TERRAIN_STEP, m.marioObj.header.gfx.cameraToObject)
    end

    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        mario_set_forward_vel(m, 10)
        m.faceAngle.y = m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
    else
        mario_set_forward_vel(m, 0)
    end

    local stepResult = perform_ground_step(m)

    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    set_mario_animation(m, MARIO_ANIM_RUNNING_UNUSED)
    return 0
end

function act_milne_melee(m)
    set_mario_animation(m, MARIO_ANIM_A_POSE)

    if mario_check_object_grab(m) ~= 0 and (m.input & INPUT_A_DOWN) == 0 then
        mario_grab_used_object(m)
        set_mario_action(m, ACT_HOLD_WALKING, 0)
        m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
        return 1
    end

    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_MILNE_MELEE_AIR
    end
    apply_slope_decel(m, 1)

    if is_anim_at_end(m) ~= 0 then
        if (m.input & INPUT_A_DOWN) ~= 0 then
            return set_mario_action(m, ACT_JUMP_KICK, 0)
        else
            return set_mario_action(m, ACT_SHARD_TOSS, 0)
        end
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_milne_melee_air(m)
    if mario_check_object_grab(m) ~= 0 and (m.input & INPUT_A_DOWN) == 0 then
        mario_grab_used_object(m)
        set_mario_action(m, ACT_HOLD_WALKING, 0)
        m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
        return 1
    end

    local stepResult = common_air_action_step(m, ACT_MILNE_MELEE, MARIO_ANIM_A_POSE, 0)
    if stepResult == AIR_STEP_LANDED then
        m.action = ACT_MILNE_MELEE
    end

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ACT_SHARD_TOSS_AIR, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_shard_toss(m)
    local e = gStateExtras[m.playerIndex]

    if m.actionTimer == 0 then --and m.marioObj.collidedObjInteractTypes ~= INTERACT_GRABBABLE
        m.faceAngle.y = m.intendedYaw
        if (m.playerIndex == 0) then
            toss_shards(m)
            network_send(true, { type = 'bullet',
                m = gNetworkPlayers[m.playerIndex].globalIndex
            })
        end

        audio_sample_play(MILNE_SOUND_ACTION_SHARD_TOSS, m.pos, 1)
        play_character_sound(m, CHAR_SOUND_YAH_WAH_HOO)
        m.marioObj.header.gfx.animInfo.animFrame = 0
    end

    set_mario_animation(m, MARIO_ANIM_THROW_LIGHT_OBJECT)

    local stepResult = perform_ground_step(m)
    if stepResult == GROUND_STEP_LEFT_GROUND then
        m.action = ACT_SHARD_TOSS_AIR
    end
    apply_slope_decel(m, 1)
    
    if math.abs(m.forwardVel) >= 10 then
        set_mario_particle_flags(m, PARTICLE_DUST, false)
        play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    end

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_JUMP, 0)
    end
    
    if (m.input & INPUT_B_PRESSED) ~= 0 and 
    (m.actionTimer > 0 and m.actionTimer < 10) then
        if e.crystallanced == 0 then
            m.faceAngle.y = m.intendedYaw
            e.crystallanced = 1
            set_mario_action(m, ACT_CRYSTAL_LANCE_START_GROUND, 0)
        end
    end
    
    if m.actionTimer > 15 then
        return set_mario_action(m, ACT_WALKING, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_shard_toss_air(m)
    local e = gStateExtras[m.playerIndex]

    if m.actionTimer == 0 then
        if (m.playerIndex == 0) then
            toss_shards(m)
            network_send(true, { type = 'bullet',
                m = gNetworkPlayers[m.playerIndex].globalIndex
            })
        end

        audio_sample_play(MILNE_SOUND_ACTION_SHARD_TOSS, m.pos, 1)
        play_character_sound(m, CHAR_SOUND_YAH_WAH_HOO)
        m.marioObj.header.gfx.animInfo.animFrame = 0
    end

    local stepResult = common_air_action_step(m, ACT_SHARD_TOSS, MARIO_ANIM_THROW_LIGHT_OBJECT, 0)
    if stepResult == AIR_STEP_LANDED then
        m.action = ACT_SHARD_TOSS
    end
    
    if (m.input & INPUT_B_PRESSED) ~= 0 and 
    (m.actionTimer > 0 and m.actionTimer < 10) then
        if e.crystallanced == 0 then
            m.faceAngle.y = m.intendedYaw
            e.crystallanced = 1
            set_mario_action(m, ACT_CRYSTAL_LANCE_START, 0)
        end
    end

    if m.actionTimer > 15 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end

    m.actionTimer = m.actionTimer + 1
    return 0
end

function act_milne_bowser_throw(m)

    if (m.input & INPUT_UNKNOWN_10) ~= 0 then
        return drop_and_set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if (m.input & INPUT_OFF_FLOOR) ~= 0 then
        return drop_and_set_mario_action(m, ACT_FREEFALL, 0)
    end

    if (m.actionTimer == 7) then
        mario_throw_held_object(m)
        m.usedObj.oBowserHeldAngleVelYaw = 0x1000
        m.usedObj.oBowserHeldAnglePitch = -0x1000
        play_character_sound_if_no_flag(m, CHAR_SOUND_SO_LONGA_BOWSER, MARIO_MARIO_SOUND_PLAYED)
        play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED)
        queue_rumble_data_mario(m, 3, 50)
    end

    animated_stationary_ground_step(m, CHAR_ANIM_GROUND_THROW, ACT_IDLE)
    
    m.actionTimer = m.actionTimer + 1
    return false
end

function act_milne_bowser_throw_air(m)
    if (m.actionTimer == 4) then
        mario_throw_held_object(m)
        m.usedObj.oBowserHeldAngleVelYaw = 0x1000
        m.usedObj.oBowserHeldAnglePitch = -0x1000
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_SO_LONGA_BOWSER, MARIO_MARIO_SOUND_PLAYED)
    set_character_animation(m, CHAR_ANIM_THROW_LIGHT_OBJECT)
    update_air_without_turn(m)

    local stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_LANDED then
        if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
            m.action = ACT_AIR_THROW_LAND
        end
    elseif stepResult == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, 0.0)
    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
    end
    
    m.actionTimer = m.actionTimer + 1
    return false
end

---------------
---- Hooks ----
---------------

function milne_anims(m)
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FALL_OVER_BACKWARDS then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_FALL_OVER_BACKWARDS")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLIDE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STOP_SLIDE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_STOP_SLIDE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DIVE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_DIVE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLOW_LAND_FROM_DIVE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLOW_LAND_FROM_DIVE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDE_DIVE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLIDE_DIVE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLOW_LEDGE_GRAB then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLOW_LEDGE_GRAB")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_CLIMB_DOWN_LEDGE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CLIMB_DOWN_LEDGE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_IDLE_ON_LEDGE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_IDLE_ON_LEDGE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FAST_LEDGE_GRAB then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_FAST_LEDGE_GRAB")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_GROUND_POUND then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_START_GROUND_POUND")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_GROUND_POUND")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_GROUND_POUND_LANDING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_GROUND_POUND_LANDING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_BACKWARD_KB then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_BACKWARD_KB")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FORWARD_KB then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_FORWARD_KB")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_SLEEP_SITTING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_START_SLEEP_SITTING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLEEP_IDLE then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLEEP_IDLE")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLEEP_START_LYING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLEEP_START_LYING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLEEP_LYING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLEEP_LYING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDE_KICK then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLIDE_KICK")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_CROUCH_FROM_SLIDE_KICK then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CROUCH_FROM_SLIDE_KICK")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLIDING_ON_BOTTOM_WITH_LIGHT_OBJ then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_SLIDING_ON_BOTTOM_WITH_LIGHT_OBJ")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAND_UP_FROM_SLIDING_WITH_LIGHT_OBJ then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_STAND_UP_FROM_SLIDING_WITH_LIGHT_OBJ")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_RUNNING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_RUNNING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DYING_ON_BACK then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_DYING_ON_BACK")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DYING_ON_STOMACH then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_DYING_ON_STOMACH")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WAKE_FROM_SLEEP then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_WAKE_FROM_SLEEP")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WAKE_FROM_LYING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_WAKE_FROM_LYING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_LAND_ON_STOMACH then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_LAND_ON_STOMACH")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_CRAWLING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_CRAWLING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_CRAWLING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_START_CRAWLING")
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STOP_CRAWLING then
        smlua_anim_util_set_animation(m.marioObj, "MILNE_ANIM_STOP_CRAWLING")
    end

end

function milne_expressions(m)
    local e = gStateExtras[m.playerIndex]

    -- yawn
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_START_SLEEP_YAWN then
        m.marioBodyState.eyeState = 9
    end

    -- snoring
    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLEEP_IDLE then
        if m.marioObj.header.gfx.animInfo.animFrame < 20 then
            m.marioBodyState.eyeState = 9
        else
            m.marioBodyState.eyeState = 10
        end
    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_SLEEP_LYING then
        if m.marioObj.header.gfx.animInfo.animFrame < 25 then
            m.marioBodyState.eyeState = 9
        else
            m.marioBodyState.eyeState = 10
        end
    end

    -- blushin' after Peach's kiss
    if m.action == ACT_END_PEACH_CUTSCENE then
        if (m.actionTimer >= 136 and m.actionArg == 8) or (m.actionArg == 9 and m.actionTimer <= 60) then
            m.marioBodyState.eyeState = 11
        end
    end

    -- death 'n hurt animations
    if m.action == ACT_ELECTROCUTION or m.action == ACT_WATER_DEATH then
        m.marioBodyState.eyeState = 13
    end

    if m.action == ACT_STANDING_DEATH then
        m.marioBodyState.eyeState = 13

        m.actionTimer = m.actionTimer + 1

        -- fox bitch dies
        if m.actionTimer >= 90 then
            m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
            if (m.playerIndex == 0) and e.dieded == 0 then
                e.dieded = 1
                milne_death(m)
            end
        else e.dieded = 0 end
    end

    if
        m.action == ACT_LAVA_BOOST or m.action == ACT_BURNING_FALL or m.action == ACT_BURNING_JUMP or
            m.action == ACT_QUICKSAND_DEATH or
            m.action == ACT_GRABBED or
            m.action == ACT_GETTING_BLOWN or
            m.action == ACT_HARD_BACKWARD_AIR_KB or
            m.action == ACT_BACKWARD_AIR_KB or
            m.action == ACT_SOFT_BACKWARD_GROUND_KB or
            m.action == ACT_HARD_FORWARD_AIR_KB or
            m.action == ACT_FORWARD_AIR_KB or
            m.action == ACT_SOFT_FORWARD_GROUND_KB or
            m.action == ACT_THROWN_FORWARD or
            m.action == ACT_THROWN_BACKWARD or
            m.action == ACT_DEATH_EXIT or
            m.action == ACT_BURNING_GROUND
     then
        m.marioBodyState.eyeState = 12
    end

    if
        m.action == ACT_HARD_BACKWARD_GROUND_KB or m.action == ACT_BACKWARD_GROUND_KB or
            m.action == ACT_HARD_FORWARD_GROUND_KB or
            m.action == ACT_FORWARD_GROUND_KB or
            m.action == ACT_DEATH_EXIT_LAND or
            m.action == ACT_FORWARD_WATER_KB or
            m.action == ACT_BACKWARD_WATER_KB or
            m.action == ACT_GROUND_BONK
     then
        m.marioBodyState.eyeState = 14
    end

    if m.action == ACT_DEATH_ON_BACK or m.action == ACT_DEATH_ON_STOMACH then
        m.actionTimer = m.actionTimer + 1
        if m.actionTimer >= 30 then
            m.marioBodyState.eyeState = 13
        end

        -- fox bitch dies
        if m.actionTimer >= 60 then
            m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
            if e.dieded == 0 then
                e.dieded = 1
                milne_death(m)
            end
        else e.dieded = 0 end

    end

    if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART1 then
        m.marioBodyState.eyeState = 12
    elseif m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_DROWNING_PART2 then
        m.marioBodyState.eyeState = 13
    end

    -- misc
    if
        m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_WATER_STAR_DANCE or
            m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_STAR_DANCE
     then
        m.marioBodyState.eyeState = 18
    end

    if m.action == ACT_EXIT_LAND_SAVE_DIALOG and m.actionState == 2 then
        if m.marioObj.header.gfx.animInfo.animFrame > 109 and m.marioObj.header.gfx.animInfo.animFrame < 154 then
            m.marioBodyState.eyeState = 15
        elseif m.marioObj.header.gfx.animInfo.animFrame > 0 and m.marioObj.header.gfx.animInfo.animFrame <= 109 then
            m.marioBodyState.eyeState = 12
        end
    end

    if m.action == ACT_FEET_STUCK_IN_GROUND then
        if m.marioObj.header.gfx.animInfo.animFrame < 100 then
            m.marioBodyState.eyeState = 12
        elseif m.marioObj.header.gfx.animInfo.animFrame >= 100 then
            m.marioBodyState.eyeState = 14
        end
    end

    if m.action == ACT_BUTT_STUCK_IN_GROUND then
        if m.marioObj.header.gfx.animInfo.animFrame < 100 then
            m.marioBodyState.eyeState = 12
        elseif m.marioObj.header.gfx.animInfo.animFrame >= 100 then
            m.marioBodyState.eyeState = 14
        end
    end
    if m.action == ACT_PANTING then
        m.marioBodyState.eyeState = 16
    end
    if m.action == ACT_SHIVERING then
        if m.actionState == 0 then
            if m.marioObj.header.gfx.animInfo.animFrame >= 30 then
                m.marioBodyState.eyeState = 16
            else
                m.marioBodyState.eyeState = 17
            end
        else
            m.marioBodyState.eyeState = 17
        end
    end
end

function milne_fall_impact(m)
    local e = gStateExtras[m.playerIndex]
    
    local fallHeight = e.milnePeakHeight - m.pos.y
    local damageHeight = 1000.0

    if (m.action ~= ACT_TWIRLING 
    and (m.action & ACT_GROUP_CUTSCENE) == 0
    and (m.action & ACT_GROUP_AIRBORNE) == 0
    and m.floor ~= nil
    and m.floor.type ~= SURFACE_BURNING) then
        if (m.vel.y < -55.0) and e.impactLanded == 0 then
            if (fallHeight > 4000.0) then
                spawn_non_sync_object(id_bhvMilneShockwave, 
                E_MODEL_BOWSER_WAVE, 
                m.pos.x, m.pos.y, m.pos.z, 
                function(obj)
                    obj.oShockwaveThreshold = 1500
                end)
                queue_rumble_data_mario(m, 5, 80)
                if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_FOV_LARGE) end
                
                play_sound(SOUND_OBJ_POUNDING_LOUD, m.marioObj.header.gfx.cameraToObject)

            elseif (fallHeight > 2000.0) then
                spawn_non_sync_object(id_bhvMilneShockwave, 
                E_MODEL_BOWSER_WAVE, 
                m.pos.x, m.pos.y, m.pos.z, 
                function(obj)
                    obj.oShockwaveThreshold = 800
                end)
                queue_rumble_data_mario(m, 5, 80)
                if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_FOV_MEDIUM) end

                play_sound(SOUND_OBJ_POUNDING1_HIGHPRIO, m.marioObj.header.gfx.cameraToObject)
                
            elseif (fallHeight > damageHeight) then
                queue_rumble_data_mario(m, 5, 80)
                if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_FOV_SMALL) end

                play_sound(SOUND_OBJ_POUNDING1_HIGHPRIO, m.marioObj.header.gfx.cameraToObject)

            end
            e.impactLanded = 1
        end
    end

    return false
end

function kazotsky_anims(m)
    if m.playerIndex ~= 0 then return end
    gPlayerSyncTable[m.playerIndex].customTaunt = _G.GeodeChars64.customTaunt
    if gPlayerSyncTable[m.playerIndex].geodeChar == 1 then 
        gPlayerSyncTable[m.playerIndex].kickAnim = "KAZOTSKY_KICK_MILNE"
    else
        if gPlayerSyncTable[m.playerIndex].customTaunt == false then
            if m.character.type == CT_LUIGI then
                gPlayerSyncTable[m.playerIndex].kickAnim = "KAZOTSKY_KICK_LUIGI"
            elseif m.character.type == CT_WARIO then
                gPlayerSyncTable[m.playerIndex].kickAnim = "KAZOTSKY_KICK_WARIO"
            elseif m.character.type == CT_WALUIGI then
                gPlayerSyncTable[m.playerIndex].kickAnim = "KAZOTSKY_KICK_WALUIGI"
            else
                gPlayerSyncTable[m.playerIndex].kickAnim = "KAZOTSKY_KICK_MARIO"
            end
        else
	        gPlayerSyncTable[m.playerIndex].kickAnim = _G.GeodeChars64.kickAnim
        end
    end
end

function mario_update_local(m)
    if _G.charSelectExists then
        if charSelectMilne == _G.charSelect.character_get_current_number()
        or charSelectMilneRecolorable == _G.charSelect.character_get_current_number() then
            gPlayerSyncTable[m.playerIndex].geodeChar = 1
        else
            gPlayerSyncTable[m.playerIndex].geodeChar = 0
        end
    else
        if recolorable == 0 then
            gPlayerSyncTable[0].modelId = E_MODEL_MILNE
        else
            gPlayerSyncTable[0].modelId = E_MODEL_MILNE_RECOLORABLE
        end
        if gMarioStates[0].character.type ~= 0 or gPlayerSyncTable[m.playerIndex].geodeChar == 0 or gPlayerSyncTable[m.playerIndex].geodeChar == nil then
            gPlayerSyncTable[0].modelId = nil
        end
    end
    
end

function mario_update(m)
    local s = gPlayerSyncTable[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    local e = gStateExtras[m.playerIndex]

    -- Taken from the Sonic mod.
    
    if s.overwriteCharToMario then
        np.overrideModelIndex = 0
    else
        np.overrideModelIndex = np.modelIndex
    end

    if m.playerIndex == 0 then
        mario_update_local(m)
    end

    if gPlayerSyncTable[m.playerIndex].geodeChar == 1 then
        milne_anims(m)
        milne_expressions(m)

        if m.marioBodyState.grabPos == GRAB_POS_HEAVY_OBJ then
            m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
        end

        if e.milnePeakHeight - m.pos.y < 2000 then m.peakHeight = m.pos.y end
        if m.vel.y >= 0 or m.pos.y == floorHeight then e.milnePeakHeight = m.pos.y end

        local thokkable =
            m.action == ACT_JUMP or m.action == ACT_DOUBLE_JUMP or m.action == ACT_LONG_JUMP or
            m.action == ACT_TRIPLE_JUMP or
            m.action == ACT_SIDE_FLIP or
            m.action == ACT_BACKFLIP or
            m.action == ACT_WALL_KICK_AIR or
            m.action == ACT_STEEP_JUMP or
            m.action == ACT_FREEFALL

        if thokkable and m.actionTimer > 0 and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            return set_mario_action(m, ACT_TWISTER_THOK, 0)
        end
        
        if m.action == ACT_IDLE and (m.controller.buttonPressed & X_BUTTON) ~= 0 then
            return set_mario_action(m, ACT_KAZOTSKY_KICK, 0)
        end

        if thokkable then
            m.actionTimer = m.actionTimer + 1
        end

        local waterActions =
            m.action == ACT_WATER_PLUNGE or m.action == ACT_WATER_IDLE or m.action == ACT_FLUTTER_KICK or
            m.action == ACT_SWIMMING_END or
            m.action == ACT_WATER_ACTION_END or
            m.action == ACT_HOLD_WATER_ACTION_END or
            m.action == ACT_HOLD_SWIMMING_END or
            m.action == ACT_HOLD_BREASTSTROKE or
            m.action == ACT_HOLD_WATER_IDLE or
            m.action == ACT_BREASTSTROKE
        if waterActions then
            return set_mario_action(m, ACT_MILNE_WATER_FALLING, 0)
        end

        if (m.action & ACT_FLAG_AIR) == 0 then
            e.crystallanced = 0
            e.firstJump = 0
        end

        if (m.action & ACT_FLAG_AIR) ~= 0 then
            e.impactLanded = 0
        end

        e.watercrystallanced = e.watercrystallanced - 1

        if (m.action == ACT_WALKING or m.action == ACT_HOLD_WALKING) and m.forwardVel > 0 then
            m.forwardVel = m.forwardVel * 1.05
        end

        custom_character_snore(m)
    else

        local milnesWaterActions =
            m.action == ACT_MILNE_WATER_FALLING or m.action == ACT_MILNE_WATER_STANDING or
            m.action == ACT_MILNE_WATER_WALKING or
            m.action == ACT_WATER_TWISTER_THOK or
            m.action == ACT_WATER_CRYSTAL_LANCE_DASH
        if milnesWaterActions then
            return set_mario_action(m, ACT_WATER_IDLE, 0)
        end
        if m.action == ACT_TWISTER_THOK then
            return set_mario_action(m, ACT_FREEFALL, 0)
        end

        do_kazotsky_kick(m, gPlayerSyncTable[m.playerIndex].startAction)
    end

    kazotsky_anims(m)
        
    if _G.GeodeChars64.customTaunt == false then 
        gPlayerSyncTable[0].startAction = ACT_IDLE
	else
	    gPlayerSyncTable[0].startAction = _G.GeodeChars64.tauntStartAction
	end

    if m.action == ACT_KAZOTSKY_KICK then
        smlua_anim_util_set_animation(m.marioObj, gPlayerSyncTable[m.playerIndex].kickAnim)
    end


    if m.action == ACT_BUBBLED then
        if gPlayerSyncTable[m.playerIndex].geodeChar == 1 then
            local bubble = obj_get_first_with_behavior_id(id_bhvBubblePlayer)
            if bubble ~= nil and bubble.heldByPlayerIndex == m.playerIndex then
                obj_mark_for_deletion(bubble)
                m.bubbleObj = spawn_non_sync_object(
                    id_bhvCrizlynOrbBubble,
                    E_MODEL_MILNE_ORB,
                    m.pos.x, m.pos.y, m.pos.z,
                    nil
                )
                m.bubbleObj.heldByPlayerIndex = m.playerIndex
            end
            m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        else
            local orb = obj_get_first_with_behavior_id(id_bhvCrizlynOrbBubble)
            if orb ~= nil and orb.heldByPlayerIndex == m.playerIndex then
                obj_mark_for_deletion(orb)
                m.bubbleObj = spawn_non_sync_object(
                    id_bhvBubblePlayer,
                    E_MODEL_BUBBLE_PLAYER,
                    m.pos.x, m.pos.y, m.pos.z,
                    nil
                )
                m.bubbleObj.heldByPlayerIndex = m.playerIndex
            end
            m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
        end
    end

    local np = gNetworkPlayers[0]
    if not np.connected then
        return false
    end

end

function mario_before_phys_step(m)
    local hScale = 1.0
    local e = gStateExtras[m.playerIndex]
    if gPlayerSyncTable[m.playerIndex].geodeChar == 1 then
        if ((m.action & ACT_FLAG_AIR) ~= 0 or m.action == ACT_METAL_WATER_JUMP) and m.vel.y < 0 then
            m.vel.y = m.vel.y - 2
        end
    end
end

function mario_on_set_action(m)
    local e = gStateExtras[m.playerIndex]
    
    -- Soldier of Dance

    if m.action == ACT_KAZOTSKY_KICK and m.playerIndex == 0 then
        seq_player_lower_volume(SEQ_PLAYER_LEVEL, 100, 40)
        audio_stream_play(SOD, true, 2)
        audio_stream_set_position(SOD, 1.443)
    end

    if (m.action ~= ACT_KAZOTSKY_KICK and m.playerIndex == 0) then
        seq_player_unlower_volume(SEQ_PLAYER_LEVEL, 100)
        audio_stream_stop(SOD)
    end

    if gPlayerSyncTable[m.playerIndex].geodeChar == 1 then
        if m.pos.y == m.floorHeight then
            milne_fall_impact(m)
        end
        
        if obj_has_behavior_id(m.usedObj, id_bhvBowser) ~= 0 and m.action == ACT_THROWING then
            return set_mario_action(m, ACT_MILNE_BOWSER_THROW, 0)
        end
        
        if obj_has_behavior_id(m.usedObj, id_bhvBowser) ~= 0 and m.action == ACT_AIR_THROW then
            return set_mario_action(m, ACT_MILNE_BOWSER_THROW_AIR, 0)
        end
        
        if m.action == ACT_METAL_WATER_JUMP then
            m.vel.y = m.vel.y + 4
        end

        if m.action == ACT_SLEEPING then
            e.animFrame = 0
        end

        if m.action == ACT_BUBBLED then
            audio_sample_play(CRIZLYN_SHATTER, m.pos, 1)
            audio_sample_play(CRIZLYN_CORE, m.pos, 1)
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
        
        if m.hurtCounter ~= 0 then
            for i = 0,math.random(2, 4),1 do
                spawn_sync_object(
                    id_bhvCrystalShatter,
                    E_MODEL_MILNE_CRYSTAL,
                    m.pos.x, m.pos.y, m.pos.z,
                    function(c)
                        c.oMoveAngleYaw = m.faceAngle.y + math.random(-0x2000, 0x2000)
                    end
                )
            end
        end
        
        if m.action == ACT_TWISTER_THOK or m.action == ACT_WATER_TWISTER_THOK then
            if e.firstJump == 1 then
                m.actionArg = 1
            end

            m.faceAngle.y = m.intendedYaw
            if m.actionArg == 0 then
                if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                    m.vel.y = 60
                else
                    m.vel.y = 50
                end

                if m.action == ACT_WATER_TWISTER_THOK then
                    m.vel.y = m.vel.y + 15
                end

            elseif m.actionArg == 1 then
                if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 then
                    m.vel.y = -60
                else
                    m.vel.y = -50
                end

            end
            
            if (m.input & INPUT_NONZERO_ANALOG) ~= 0 and m.wall == nil then
                if m.flags & (MARIO_NORMAL_CAP | MARIO_CAP_ON_HEAD) == 0 and m.forwardVel < 80 then
                    mario_set_forward_vel(m, 100)
                elseif m.forwardVel < 50 then
                    mario_set_forward_vel(m, 60)
                end
            end

        end
    
        if ((m.action == ACT_PUNCHING
        or m.action == ACT_MOVE_PUNCHING) and m.actionArg ~= 9)
        or (m.action == ACT_DIVE and (m.prevAction & ACT_FLAG_AIR) == 0) then
            return set_mario_action(m, ACT_MILNE_MELEE, 0)
        end

        if (m.action == ACT_DIVE or m.action == ACT_JUMP_KICK) and (m.prevAction & ACT_FLAG_AIR) ~= 0 then
            return set_mario_action(m, ACT_MILNE_MELEE_AIR, 0)
        end

        if m.action == ACT_CRYSTAL_LANCE_START
        or m.action == ACT_CRYSTAL_LANCE_START_GROUND
        or m.action == ACT_WATER_CRYSTAL_LANCE_START then
            audio_sample_play(MILNE_SOUND_ACTION_LANCE_START, m.pos, 1)
            if (m.playerIndex == 0) then
                spawn_lance_pieces(m, math.random(6, 12))
                network_send(true, { type = 'lance',
                    m = gNetworkPlayers[m.playerIndex].globalIndex
                })
            end
        end
    end
end

function on_hud_render()
    local m = gMarioStates[0]
    if
        obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil or is_game_paused() or
            (m.action == ACT_END_PEACH_CUTSCENE or m.action == ACT_CREDITS_CUTSCENE or
                m.action == ACT_END_WAVING_CUTSCENE)
     then
        return
    end
    djui_hud_set_resolution(RESOLUTION_DJUI)
    if gPlayerSyncTable[m.playerIndex].geodeChar == 1 and not _G.charSelectExists then
        local size = (djui_hud_get_screen_height() * 0.01) / (m.character.hudHeadTexture.height * 0.15)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(
            TEX_HUD_MILNE,
            djui_hud_get_screen_height() / 11,
            djui_hud_get_screen_height() / 16,
            size,
            size
        )
        if set_cam_angle(0) == CAM_ANGLE_MARIO then
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(
                TEX_HUD_MILNE,
                (djui_hud_get_screen_width()) - 192,
                djui_hud_get_screen_height() * 2 / 2.34,
                size,
                size
            )
        end
    end

    render_kazotsky_icon()
end

function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

for i = 0, (MAX_PLAYERS - 1) do
    local s = gPlayerSyncTable[i]
    s.overwriteCharToMario = false
end

function render_kazotsky_icon()
    local outPos = {x = 0, y = 0, z = 0}
    local scale

    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_color(0xFF, 0xFF, 0xFF, 0xFF)

    for i = 1, network_player_connected_count() do
        local m = gMarioStates[i]

        if gPlayerSyncTable[m.playerIndex].showIcon == 1 and m.playerIndex ~= 0 then
            local headPos = {
                x = m.marioBodyState.headPos.x,
                y = m.marioBodyState.headPos.y + 100,
                z = m.marioBodyState.headPos.z
            }
            djui_hud_world_pos_to_screen_pos(headPos, outPos)

            if gMarioStates[0].area.camera ~= nil then
                scale = 50 - (vec3f_dist(gLakituState.pos, headPos) / 100)
            else
                scale = 0
            end

            if scale < 0 then
                scale = 0
            elseif scale > 50 then
                scale = 50
            end

            djui_hud_render_texture(TEX_HUD_KAZOTSKY, outPos.x - 30, outPos.y - scale, scale / 180, scale / 180)
        end
    end
end

function set_mario_model(o)
    if obj_has_behavior_id(o, id_bhvMario) ~= 0 then
        local i = network_local_index_from_global(o.globalPlayerIndex)
        if gPlayerSyncTable[i].geodeChar == 1 then
            if gPlayerSyncTable[i].modelId ~= nil and obj_has_model_extended(o, gPlayerSyncTable[i].modelId) == 0 then
                obj_set_model_extended(o, gPlayerSyncTable[i].modelId)
            end
        end
    end
end

function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return true
    end
    if not np.connected then
        return false
    end
    if np.currCourseNum ~= gNetworkPlayers[0].currCourseNum then
        return false
    end
    if np.currActNum ~= gNetworkPlayers[0].currActNum then
        return false
    end
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum then
        return false
    end
    if np.currAreaIndex ~= gNetworkPlayers[0].currAreaIndex then
        return false
    end
    return is_player_active(m)
end

function on_receive_spawn_data(table)
    local np = network_player_from_global_index(table.m)
    local m = gMarioStates[np.localIndex]
    if (active_player(m)) then
        if (table.type == 'bullet') then
            toss_shards(m)
        end
        if (table.type == 'lance') then
            spawn_lance_pieces(m, math.random(6, 12))
        end
    end
end

function on_interact(m, o, intType, value)
    if obj_has_behavior_id(o, id_bhvCrystalBullet) ~= 0 then
        crystal_bullet_death(o)
    end

    if m.marioObj.platform == o and obj_has_behavior_id(o, id_bhvFloorSwitchGrills) ~= 0 then
        o.oAction = PURPLE_SWITCH_ACT_PRESSED
    end

    -- Properly grab stuff. (Bit taken from Sharen's Pasta Castle)
    local grabActions = {
        [ACT_MILNE_MELEE] = true,
        [ACT_MILNE_MELEE_AIR] = true
    }

    if m.action == ACT_MILNE_MELEE then
        if (intType & (INTERACT_GRABBABLE) ~= 0) and o.oInteractionSubtype & (INT_SUBTYPE_NOT_GRABBABLE) == 0 then
            m.interactObj = o
            m.input = m.input | INPUT_INTERACT_OBJ_GRABBABLE
            if o.oSyncID ~= 0 then
                network_send_object(o, true)
            end
        end
    end
end

hook_event(HOOK_BEFORE_PHYS_STEP, mario_before_phys_step)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_OBJECT_SET_MODEL, set_mario_model)
hook_event(HOOK_ON_PACKET_RECEIVE, on_receive_spawn_data)
hook_event(HOOK_ON_INTERACT, on_interact)

hook_mario_action(ACT_TWISTER_THOK, act_twister_thok, INT_HIT_FROM_ABOVE)
hook_mario_action(ACT_CRYSTAL_LANCE_START, act_crystal_lance_start, INTERACT_PLAYER)
hook_mario_action(ACT_CRYSTAL_LANCE_START_GROUND, act_crystal_lance_start_ground, INTERACT_PLAYER)
hook_mario_action(ACT_CRYSTAL_LANCE_DASH, act_crystal_lance_dash, INT_KICK)
hook_mario_action(ACT_CRYSTAL_LANCE_DASH_AIR, act_crystal_lance_dash_air, INT_KICK)
hook_mario_action(ACT_CRYSTAL_LANCE_WALL, act_crystal_lance_wall, INTERACT_PLAYER)
hook_mario_action(ACT_KAZOTSKY_KICK, act_kazotsky_kick, INTERACT_PLAYER)
hook_mario_action(ACT_MILNE_MELEE, act_milne_melee, INTERACT_PLAYER)
hook_mario_action(ACT_MILNE_MELEE_AIR, act_milne_melee_air, INTERACT_PLAYER)
hook_mario_action(ACT_SHARD_TOSS, act_shard_toss, INTERACT_PLAYER)
hook_mario_action(ACT_SHARD_TOSS_AIR, act_shard_toss_air, INT_HIT_FROM_ABOVE)
hook_mario_action(ACT_MILNE_BOWSER_THROW, act_milne_bowser_throw, INTERACT_PLAYER)
hook_mario_action(ACT_MILNE_BOWSER_THROW_AIR, act_milne_bowser_throw_air, INTERACT_PLAYER)