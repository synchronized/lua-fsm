package.path = "..//?.lua;"..package.path

local fsm_machine = require "luafsm" --引入fsm模块

local states = {
	IDLE = "idlestate",
	MOVE = "movestate",
}

-- 定义idle状态
local idlestate = {
	name = states.IDLE,
}

-- 当进入状态时被调用
function idlestate.on_enter(player)
	print(string.format("%s: idlestate.init", player.name))
end

-- 当执行fsm_machine.update()时调用当前状态的update()函数
function idlestate.on_update(player)
	print(string.format("%s: idlestate.update", player.name))
	if player.move_target_pos ~= nil then
		player:change_state(states.MOVE)
	end
end

-- 当切换到其他状态时被调用
function idlestate.on_exit(player)
	print(string.format("%s: idlestate.exit", player.name))
end

-----------------------------------------
-- 定义move状态
local movestate = {
	name = states.MOVE,
}

-- 当进入状态时被调用
function movestate.on_enter(player)
	print(string.format("%s: movestate.enter", player.name))
end

-- 当执行fsm_machine.update()时调用当前状态的update()函数
function movestate.on_update(player)
	local target_pos = player.move_target_pos
	local current_pos = player.current_pos
	if math.abs(target_pos.x - current_pos.x) < 1 and math.abs(target_pos.y - current_pos.y) < 1 then
		player.move_target_pos = nil
		player:change_state(states.IDLE)
	end

	current_pos.x = current_pos.x + (target_pos.x - current_pos.x) / 10
	current_pos.y = current_pos.y + (target_pos.y - current_pos.y) / 10
	print(string.format("%s: movestate.update pos{x: %0.3f, y: %0.3f}", player.name, current_pos.x, current_pos.y))
end

-- 当切换到其他状态时被调用
function movestate.on_exit(player)
	print(string.format("%s: movestate.exit", player.name))
end

local player = {}

function player.new(name)
	local player_fsm = fsm_machine.new()
	local obj = setmetatable({
		fsm = player_fsm,
		name = name,
		current_pos = {x = 0, y = 0},
		move_target_pos = nil,
	}, player)
	player.__index = player

	player_fsm:add_state(idlestate, obj)
	player_fsm:add_state(movestate, obj)
	return obj
end

function player:change_state(to_state_name)
	self.fsm:change_state(to_state_name)
end

function player:update(deltamill)
	self.fsm:update(deltamill)
end

function player:set_target_pos(pos)
	self.move_target_pos = pos
	local cpos = self.current_pos
	print(string.format("command move player from pos{x: %0.3f, y: %0.3f} to pos{x: %0.3f, y: %0.3f}",
						cpos.x, cpos.y, pos.x, pos.y))
end

local player001 = player.new("player001")

player001:change_state(idlestate.name)
for i = 1, 500 do
	player001:update()

	if i % 15 == 0 then
		-- 模拟用户输入
		if player001.fsm:get_current_state_name() == idlestate.name then
			local pos = {x = math.random(-50, 50), y = math.random(-50, 50)}
			player001:set_target_pos(pos)
		end
	end
end
