-- SMS Alfredo's voice system.
-- Define what triggers the custom voice
local function use_custom_voice(m)
    return gPlayerSyncTable[m.playerIndex].modelId == E_MODEL_MILNE or gPlayerSyncTable[m.playerIndex].modelId == E_MODEL_MILNE_RECOLORABLE --Put your condition here!
end

--How many snores the sleep-talk has, or rather, how long the sleep-talk lasts
--If you omit the sleep-talk you can ignore this
local SLEEP_TALK_SNORES = 8

--Define what actions play what voice clips
--If an action has more than one voice clip, put those clips inside a table
--CHAR_SOUND_SNORING3 requires two or three voice clips to work properly...
--but you can omit it if your character does not sleep-talk
MILNE_VOICETABLE = {
    [CHAR_SOUND_ATTACKED] = {'milne-ugh-hurt.mp3', 'milne-hurt.mp3'},
    [CHAR_SOUND_COUGHING1] = 'milne-cough.mp3',
    [CHAR_SOUND_COUGHING2] = {'milne-cough-2.mp3', 'milne-cough-2-2.mp3'},
    [CHAR_SOUND_COUGHING3] = 'milne-cough-3.mp3',
    [CHAR_SOUND_DOH] = {'milne-doh.mp3', 'milne-doh-2.mp3'},
    --[CHAR_SOUND_DROWNING] = 'Blurp_Blurp_Blurp_Drowning',
    [CHAR_SOUND_DYING] = 'milne-death.mp3',
    [CHAR_SOUND_EEUH] = 'milne-hrnng.mp3',
    --[CHAR_SOUND_GAME_OVER] = 'Game_Over.ogg',
    [CHAR_SOUND_GROUND_POUND_WAH] = 'milne-hah-2.mp3',
    [CHAR_SOUND_HAHA] = 'milne-chuckle.mp3',
    [CHAR_SOUND_HAHA_2] = 'milne-chuckle.mp3',
    [CHAR_SOUND_HELLO] = 'milne-sup.mp3',
    --[CHAR_SOUND_HERE_WE_GO] = 'Here_we_GO_Mario_Kart_64.ogg',
    [CHAR_SOUND_HOOHOO] = {'milne-ha.mp3', 'milne-hup.mp3'},
    [CHAR_SOUND_HRMM] = 'milne-grunt.mp3',
    --[CHAR_SOUND_IMA_TIRED] = 'Ughtired.ogg',
    --[CHAR_SOUND_LETS_A_GO] = 'Okay.ogg',
    [CHAR_SOUND_MAMA_MIA] = 'milne-o-em-gee-guys-she-said-the-bad-word.mp3',
    --[CHAR_SOUND_OKEY_DOKEY] = 'Okie_Dokie.ogg',
    [CHAR_SOUND_ON_FIRE] = 'milne-lava.mp3',
    [CHAR_SOUND_OOOF] = 'milne-ugh-hurt.mp3',
    [CHAR_SOUND_OOOF2] = 'milne-ugh-hurt.mp3',
    [CHAR_SOUND_PANTING] = {'milne-panting-2.mp3', 'milne-panting.mp3'},
    --[CHAR_SOUND_PANTING_COLD] = 'Panting_Low_Energy.ogg',
    --[CHAR_SOUND_PRESS_START_TO_PLAY] = 'Press_Start_to_Play.ogg',
    [CHAR_SOUND_PUNCH_HOO] = 'milne-hah.mp3',
    [CHAR_SOUND_PUNCH_WAH] = 'milne-ha.mp3',
    [CHAR_SOUND_PUNCH_YAH] = 'milne-ha-2.mp3',
    --[CHAR_SOUND_SNORING1] = 'Snoring1.ogg',
    --[CHAR_SOUND_SNORING2] = 'Snoring2.ogg',
    --[CHAR_SOUND_SNORING3] = {'Snoring3.ogg', 'Snoring2.ogg', 'Must_Plant_Flowers_Talking_in_Sleep.ogg'},
    [CHAR_SOUND_SO_LONGA_BOWSER] = 'milne-take-out-the-trash.mp3',
    [CHAR_SOUND_TWIRL_BOUNCE] = 'milne-woohoo.mp3',
    [CHAR_SOUND_UH] = 'milne-uhng.mp3',
    [CHAR_SOUND_UH2] = 'milne-uhng.mp3',
    [CHAR_SOUND_UH2_2] = 'milne-uhng.mp3',
    [CHAR_SOUND_WAAAOOOW] = 'milne-falling.mp3',
    [CHAR_SOUND_WAH2] = 'milne-ha-2.mp3',
    [CHAR_SOUND_WHOA] = 'milne-woah.mp3',
    [CHAR_SOUND_YAHOO] = 'milne-yeah.mp3',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = {'milne-yeah.mp3', 'milne-yes.mp3', 'milne-woohoo.mp3'},
    [CHAR_SOUND_YAH_WAH_HOO] = {'milne-ha-2.mp3', 'milne-hay.mp3'},
    [CHAR_SOUND_YAWNING] = 'milne-yawn.mp3',
}

--Define the table of samples that will be used for each player
--Global so if multiple mods use this they won't create unneeded samples
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
gCustomVoiceSamples = {}
gCustomVoiceStream = nil

--Get the player's sample, stop whatever sound
--it's playing if it doesn't match the provided sound
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
--- @param m MarioState
function stop_custom_character_sound(m, sound)
    local voice_sample = gCustomVoiceSamples[m.playerIndex]
    if voice_sample == nil or not voice_sample.loaded then
        return
    end

    audio_sample_stop(voice_sample)
    if voice_sample.file.relativePath:match('^.+/(.+)$') == sound then
        return voice_sample
    end
    audio_sample_destroy(voice_sample)
end

--Play a custom character's sound
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
--- @param m MarioState
function play_custom_character_sound(m, voice)
    --Get sound, if it's a table, get a random entry from it
    local sound
    if type(voice) == "table" then
        sound = voice[math.random(#voice)]
    else
        sound = voice
    end
    if sound == nil then return 0 end

    --Get current sample and stop it
    local voice_sample = stop_custom_character_sound(m, sound)

    --If the new sound isn't a string, let's assume it's
    --a number to return to the character sound hook
    if type(sound) ~= "string" then
        return sound
    end

    --Load a new sample and play it! Don't make a new one if we don't need to
    if (m.area == nil or m.area.camera == nil) and m.playerIndex == 0 then
        if gCustomVoiceStream ~= nil then
            audio_stream_stop(gCustomVoiceStream)
            audio_stream_destroy(gCustomVoiceStream)
        end
        gCustomVoiceStream = audio_stream_load(sound)
        audio_stream_play(gCustomVoiceStream, true, 1)
    else
        if voice_sample == nil then
            voice_sample = audio_sample_load(sound)
        end
        audio_sample_play(voice_sample, m.pos, 1)

        gCustomVoiceSamples[m.playerIndex] = voice_sample
    end
    return 0
end

--Main character sound hook
--This hook is freely modifiable in case you want to make any specific exceptions
--- @param m MarioState
local function custom_character_sound(m, characterSound)
    if not use_custom_voice(m) then return end
    if characterSound == CHAR_SOUND_SNORING3 then return 0 end
    if characterSound == CHAR_SOUND_HAHA and m.hurtCounter > 0 then return 0 end

    local voice = MILNE_VOICETABLE[characterSound]
    if voice ~= nil then
        return play_custom_character_sound(m, voice)
    end
    return 0
end

--Snoring logic for CHAR_SOUND_SNORING3 since we have to loop it manually
--This code won't activate on the Japanese version, due to MARIO_MARIO_SOUND_PLAYED not being set
local SNORE3_TABLE = MILNE_VOICETABLE[CHAR_SOUND_SNORING3]
local STARTING_SNORE = 46
local SLEEP_TALK_START = STARTING_SNORE + 49
local SLEEP_TALK_END = SLEEP_TALK_START + SLEEP_TALK_SNORES

--Main hook for snoring
--- @param m MarioState
function custom_character_snore(m)
    if not use_custom_voice(m) then return end

    --Stop the snoring!
    if m.action ~= ACT_SLEEPING then
        if m.isSnoring > 0 then
            stop_custom_character_sound(m)
        end
        return

    --You're not in deep snoring
    elseif not (m.actionState == 2 and (m.flags & MARIO_MARIO_SOUND_PLAYED) ~= 0) then
        return
    end

    local animFrame = m.marioObj.header.gfx.animInfo.animFrame

    --Behavior for CHAR_SOUND_SNORING3
    if SNORE3_TABLE ~= nil and #SNORE3_TABLE >= 2 then
        --Exhale sound
        if animFrame == 2 and m.actionTimer < SLEEP_TALK_START then
            play_custom_character_sound(m, SNORE3_TABLE[2])

        --Inhale sound
        elseif animFrame == 25 then
            
            --Count up snores
            if #SNORE3_TABLE >= 3 then
                m.actionTimer = m.actionTimer + 1

                --End sleep-talk
                if m.actionTimer >= SLEEP_TALK_END then
                    m.actionTimer = STARTING_SNORE
                end
    
                --Enough snores? Start sleep-talk
                if m.actionTimer == SLEEP_TALK_START then
                    play_custom_character_sound(m, SNORE3_TABLE[3])
                
                --Regular snoring
                elseif m.actionTimer < SLEEP_TALK_START then
                    play_custom_character_sound(m, SNORE3_TABLE[1])
                end
            
            --Definitely regular snoring
            else
                play_custom_character_sound(m, SNORE3_TABLE[1])
            end
        end

    --No CHAR_SOUND_SNORING3, just use regular snoring
    elseif animFrame == 2 then
        play_character_sound(m, CHAR_SOUND_SNORING2)

    elseif animFrame == 25 then
        play_character_sound(m, CHAR_SOUND_SNORING1)
    end
end

hook_event(HOOK_CHARACTER_SOUND, custom_character_sound)