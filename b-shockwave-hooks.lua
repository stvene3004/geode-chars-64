 
function shockwave_general_kill(o)
    local s = obj_get_nearest_object_with_behavior_id(o,id_bhvMilneShockwave)
    if s ~= nil 
    and math.abs(o.oPosY - s.oPosY) <= 200
    and dist_between_objects(o, s) < s.oShockwaveThreshold then 
        if (o.oInteractStatus & INT_STATUS_INTERACTED) == 0 
        and o.oAction ~= OBJ_ACT_VERTICAL_KNOCKBACK and o.oAction ~= OBJ_ACT_HORIZONTAL_KNOCKBACK and o.oAction ~= OBJ_ACT_SQUISHED then
            o.oInteractStatus = ATTACK_PUNCH | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        end
    end
end
 
function shockwave_bobomb_kill(o)
    local s = obj_get_nearest_object_with_behavior_id(o,id_bhvMilneShockwave)
    if s ~= nil 
    and math.abs(o.oPosY - s.oPosY) <= 200
    and dist_between_objects(o, s) < s.oShockwaveThreshold then 
        if (o.oAction ~= BOBOMB_ACT_EXPLODE) and (o.oAction ~= BOBOMB_ACT_LAUNCHED) then
            if (o.oVelY <= 0) then
                o.oMoveAngleYaw = obj_angle_to_object(o, s)
                o.oForwardVel = -20.0
                o.oVelY = 30.0
                o.oAction = BOBOMB_ACT_LAUNCHED
            end
        end
    end
end
 
function shockwave_piranha_kill(o)
    local s = obj_get_nearest_object_with_behavior_id(o,id_bhvMilneShockwave)
    if s ~= nil 
    and math.abs(o.oPosY - s.oPosY) <= 200
    and dist_between_objects(o, s) < s.oShockwaveThreshold then 
        stop_secondary_music(50)
        if o.oAction ~= PIRANHA_PLANT_ACT_SHRINK_AND_DIE 
        and o.oAction ~= PIRANHA_PLANT_ACT_ATTACKED and o.oAction ~= PIRANHA_PLANT_ACT_WAIT_TO_RESPAWN then
            o.oAction = PIRANHA_PLANT_ACT_ATTACKED
            return true
        end
    end
end
 
function shockwave_chuckya_kill(o)
    local s = obj_get_nearest_object_with_behavior_id(o,id_bhvMilneShockwave)
    if s ~= nil 
    and math.abs(o.oPosY - s.oPosY) <= 200
    and dist_between_objects(o, s) < s.oShockwaveThreshold then 
            o.oMoveAngleYaw = obj_angle_to_object(o, s)
            o.oForwardVel = -20.0
            o.oVelY = 30.0
            o.oAction = 2
    end
end


hook_behavior(id_bhvGoomba, OBJ_LIST_PUSHABLE, false, nil, shockwave_general_kill)
hook_behavior(id_bhvKoopa, OBJ_LIST_PUSHABLE, false, nil, shockwave_general_kill)
hook_behavior(id_bhvSpindrift, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvPokey, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvPokeyBodyPart, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvFlyGuy, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvScuttlebug, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvMoneybag, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvMontyMole, OBJ_LIST_GENACTOR, false, nil, shockwave_general_kill)
hook_behavior(id_bhvSpiny, OBJ_LIST_PUSHABLE, false, nil, shockwave_general_kill)

hook_behavior(id_bhvBobomb, OBJ_LIST_DESTRUCTIVE, false, nil, shockwave_bobomb_kill)

hook_behavior(id_bhvPiranhaPlant, OBJ_LIST_GENACTOR, false, nil, shockwave_piranha_kill)

hook_behavior(id_bhvChuckya, OBJ_LIST_GENACTOR, false, nil, shockwave_chuckya_kill)