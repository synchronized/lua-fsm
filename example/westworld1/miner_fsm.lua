
local fsm_machine = require "luafsm"
local miner = require "miner"
local miner_states = require "miner_state"

function miner.create(name)
	local obj = miner.new(name)
	obj.m_fsm = obj:create_fsm()
	return obj
end

function miner.change_state(self, state_name)
	self.m_fsm:change_state(state_name)
end

function miner.update(self, deltamillis)
	self.m_thirst = self.m_thirst + 1
	self.m_fsm:update(deltamillis)
end


function miner.create_fsm(self)
	local fsm = fsm_machine.new(self)
	--添加状态
	for _, v in ipairs(miner_states) do
		fsm:add_state(v, self)
	end

	--设置当前状态
	fsm:change_state(miner_states[1].name)
	return fsm
end

return miner
