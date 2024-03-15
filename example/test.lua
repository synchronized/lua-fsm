------------
-- 下面是测试代码
------------
package.path = "..//?.lua;"..package.path

local fsm_machine = require "luafsm"

-- SoldierActions

local soldier = {
	timer = 0,
}

function soldier.new(name)
	return {
		name = name,
		timer = 0,
	}
end

function soldier.new_idle_action(obj)
	local finit = function(userdata)
		print("SoldierActions.Idle.Initialize data is "..userdata.name)
		userdata.timer = 0
	end

	local fupdate = function(userdata, deltaTimeInMillis)
		print("SoldierActions.Idle.Update data is "..userdata.name)
		userdata.timer = (userdata.timer + 1)
		if userdata.timer > 3 then
			return fsm_machine.status.TERMINATED
		end

		return fsm_machine.status.RUNNING
	end

	local fcleanup = function(userdata)
		print("SoldierActions.Idle.CleanUp data is "..userdata.name)
		userdata.timer = 0
	end

	return fsm_machine.new_action("idle", finit, fupdate, fcleanup, obj)
end

function soldier.new_die_actions(obj)
	local finit = function(userdata)
		print("SoldierActions.Die.Initialize data is "..userdata.name)
		userdata.timer = 0
	end

	local fupdate = function(userdata, deltaTimeInMillis)
		print("SoldierActions.Die.Update data is "..userdata.name)
		userdata.timer = (userdata.timer + 1)
		if userdata.timer > 2 then
			return fsm_machine.status.TERMINATED
		end

		return fsm_machine.status.RUNNING
	end

	local fcleanup = function(userdata)
		print("SoldierActions.Die.CleanUp data is "..userdata.name)
		userdata.timer = 0
	end

	return fsm_machine.new_action("die", finit, fupdate, fcleanup, obj)
end

-- SoldierEvaluators
function soldier.evaluators_true(userdata)
	print("SoldierEvaluators_True data is "..userdata.name)
	return true
end

function soldier.evaluators_false(userdata)
	print("SoldierEvaluators_True data is "..userdata.name)
	return false
end

function soldier.new_fsm(obj)
	local fsm = fsm_machine.new(obj)
	fsm:add_state("idle", soldier.new_idle_action(obj))
	fsm:add_state("die", soldier.new_die_actions(obj))

	fsm:add_transition("idle", "die", soldier.evaluators_true)
	fsm:add_transition("die", "idle", soldier.evaluators_true)

	fsm:set_state('idle')

	return fsm
end

local obj = soldier.new("Soldier001")
local fsm = soldier.new_fsm(obj)
for _ = 1, 100 do
	fsm:update()
end
