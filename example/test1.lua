package.path = "..//?.lua;"..package.path

local fsm_machine = require "luafsm" --引入fsm模块

-- 定义idle状态
local idlestate = {
	name = "idlestate",
}

-- 当进入状态时被调用
function idlestate.on_enter(player)
	print(string.format("%s: idlestate.init", player.name))
end

-- 当执行fsm_machine.update()时调用当前状态的update()函数
function idlestate.on_update(player)
	print(string.format("%s: idlestate.update", player.name))
end

-- 当切换到其他状态时被调用
function idlestate.on_exit(player)
	print(string.format("%s: idlestate.exit", player.name))
end


local player = {}

function player.new(name)
	local player_fsm = fsm_machine.new()
	local obj = setmetatable({
		name = name,
		fsm = player_fsm,
	}, player)
	player.__index = player

	player_fsm:add_state(idlestate, obj)
	return obj
end


function player:update(deltamill)
	self.fsm:update(deltamill)
end

local player001 = player.new("player001")

-- 调用对应传入的函数
player001.fsm:change_state(idlestate.name)
player001:update()
player001.fsm:change_state("run") -- 这个状态不存在
player001:update()
player001.fsm:change_state(idlestate.name)
player001:update()
