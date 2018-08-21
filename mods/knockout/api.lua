-- toolname is the name of the tool (ex "default:pick_wood")
-- chance is the chance that the target will be knocked out when hit with the tool
-- (A value betwen 1 and 0; 1 = will happen every time; 0 = will never happed. Note that a chance of 1 may fail to knock players out if the tool is not used wiht a full punch)
-- max_health is the maximum health the player will have to be knocked out with the tool
-- (If the player's health is greater then max_health, they won't be knocked out, regardless of chance)
-- max_time is the maximum time (in seconds) that the player will be knocked out for (note that this would happen if the player was hit when they had 0 hp, aka never)
-- the minimum time the player will be knocked out for is half of max_time
-- The actual time the player is knocked out for is calculated by the following equation:
-- time knocked out = max_time * (1 - current hp / (max_health * 2))
knockout.register_tool = function(toolname, chance, max_health, max_time)
	knockout.tools[toolname] = {chance = chance, max_health = max_health, max_time = max_time}
end
