
local fsm_machine = require "luafsm"
local miner = require "miner"
local miner_state = require "miner_state"

function miner.create(name)
	local obj = miner.new(name)
	obj.m_fsm = obj:create_fsm()
	return obj
end

function miner.update(self, deltamillis)
	self.m_thirst = self.m_thirst + 1
	self.m_fsm:update(deltamillis)
end


function miner.create_fsm(self)
	local fsm = fsm_machine.new(self)
	--添加状态
	fsm:add_state(miner_state.states.DIG_FOR_NUGGET, miner_state.new_action_digfornugget(self))
	fsm:add_state(miner_state.states.DEPOSIT_GOLD, miner_state.new_action_depositgold(self))
	fsm:add_state(miner_state.states.GO_HOME_RESTED, miner_state.new_action_go_home_rested(self))
	fsm:add_state(miner_state.states.QUENCH_THIRST, miner_state.new_action_quench_thirst(self))

	--添加转化对象
	fsm:add_transition(miner_state.states.DIG_FOR_NUGGET, miner_state.states.QUENCH_THIRST, self.is_thirsty)
	fsm:add_transition(miner_state.states.DIG_FOR_NUGGET, miner_state.states.DEPOSIT_GOLD, self.is_pockets_full)
	fsm:add_transition(miner_state.states.DEPOSIT_GOLD, miner_state.states.GO_HOME_RESTED, self.is_enough_money)
	fsm:add_transition(miner_state.states.DEPOSIT_GOLD, miner_state.states.DIG_FOR_NUGGET, self.is_not_enough_money)
	fsm:add_transition(miner_state.states.GO_HOME_RESTED, miner_state.states.DIG_FOR_NUGGET, self.is_not_fatigued)
	fsm:add_transition(miner_state.states.QUENCH_THIRST, miner_state.states.DIG_FOR_NUGGET, self.is_not_thirsty)

	--设置当前状态
	fsm:set_state(miner_state.states.GO_HOME_RESTED)
	return fsm
end

return miner
