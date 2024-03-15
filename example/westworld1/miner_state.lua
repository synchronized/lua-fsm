
local fsm_machine = require "luafsm"
local config = require "config"
local location = require "location"

local states = {
	DIG_FOR_NUGGET = "DigForNugget(挖矿)",
	DEPOSIT_GOLD = "DepositGold(存钱)",
	GO_HOME_RESTED = "GoHomeRested(回家睡觉)",
	QUENCH_THIRST = "QuenchThirst(解渴)",
}

local miner_state = {}

miner_state.states = states

-- 挖矿状态
function miner_state.new_action_digfornugget(self)
	local digfornugget = {}
	function digfornugget.init(obj)
		if obj.m_location ~= location.goldmine then
			print(obj:logp()..": 步行来到金矿，准备开始挖矿了")
			obj.m_location = location.goldmine
		end
	end
	function digfornugget.update(obj, _ --[[deltamillis]])
		obj:add_goldcarried(1) -- 挖到一块金矿
		obj:inc_fatigue() --增加疲劳值
		print(obj:logp()..": 捡起一块金块")

		if obj:is_pockets_full() then
			-- 如果背包已满则去银行存钱
			return fsm_machine.status.TERMINATED
		end
		if obj:is_thirsty() then
			-- 者达到饥渴度阈值则回家
			return fsm_machine.status.TERMINATED
		end

		return fsm_machine.status.RUNNING
	end
	function digfornugget.cleanup(obj)
		print(obj:logp()..": 啊，我要离开金矿了，口袋里装满了可爱的金子")
	end
	return fsm_machine.new_action("DigForNugget(挖矿)",
								  digfornugget.init,
								  digfornugget.update,
								  digfornugget.cleanup, self)
end

-- 存钱状态
function miner_state.new_action_depositgold(self)
	local depositgold = {}
	function depositgold.init(obj)
		if obj.m_location ~= location.bank then
			print(obj:logp()..": 要去银行了吗. 是的，阁下")
			obj.m_location = location.bank
		end
	end
	function depositgold.update(obj, _ --[[deltamillis]])
		obj:add_wealth(obj.m_goldcarried)
		obj.m_goldcarried = 0
		print(obj:logp()..": 存放黄金。 现在总财富值: "..tostring(obj.m_moneyinbank))

		if obj.m_moneyinbank >= config.comfort_level then
			print(obj:logp()..": 哈哈！ 目前已经足够富有了。 回到家咯!!!")
		end
		return fsm_machine.status.TERMINATED
	end
	function depositgold.cleanup(obj)
		print(obj:logp()..": 行走在离开银行的路上")
	end
	return fsm_machine.new_action("DepositGold(存钱)",
								  depositgold.init,
								  depositgold.update,
								  depositgold.cleanup, self)
end

-- 矿工回家休息
function miner_state.new_action_go_home_rested(self)
	local go_home_rested = {}
	function go_home_rested.init(obj)
		if obj.m_location ~= location.shack then
			print(obj:logp()..": 步行回家")
			obj.m_location = location.shack
		end
	end
	function go_home_rested.update(obj, _ --[[deltamillis]])
		if not obj:is_fatigued() then
			print(obj:logp()..": 这次睡真香甜！ 是时候寻找更多黄金了")
			return fsm_machine.status.TERMINATED
		end
		obj:dec_fatigue() --减少疲劳值
		print(obj:logp()..": ZZZZ... ")
		return fsm_machine.status.RUNNING
	end
	function go_home_rested.cleanup(obj, _ --[[deltamillis]])
		print(obj:logp()..": 离开了家")
	end
	return fsm_machine.new_action("GoHomeRested(回家睡觉)",
								  go_home_rested.init,
								  go_home_rested.update,
								  go_home_rested.cleanup, self)
end

-- 解渴
function miner_state.new_action_quench_thirst(self)
	local quench_thirst_state = {}
	function quench_thirst_state.init(obj)
		if obj.m_location ~= location.saloon then
			print(obj:logp()..": 太棒了！ 步行前往沙龙!")
			obj.m_location = location.saloon
		end
	end
	function quench_thirst_state.update(obj, _ --[[deltamillis]])
		assert(obj:is_thirsty(), "in quench_thirst_state but not thirsty")

		obj.m_thirst = 0
		obj.m_moneyinbank = obj.m_moneyinbank - 2
		print(obj:logp()..": 这酒喝起来真不错")
		return fsm_machine.status.TERMINATED
	end
	function quench_thirst_state.cleanup(obj, _ --[[deltamillis]])
		print(obj:logp()..": 离开酒吧，感觉很好")
	end
	return fsm_machine.new_action("QuenchThirst(解渴)",
								  quench_thirst_state.init,
								  quench_thirst_state.update,
								  quench_thirst_state.cleanup, self)
end

return miner_state
