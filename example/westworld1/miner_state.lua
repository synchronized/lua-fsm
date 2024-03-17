
local fsm_machine = require "luafsm"
local config = require "config"
local location = require "location"

local states = {
	DIG_FOR_NUGGET = "DigForNugget(挖矿)",
	DEPOSIT_GOLD = "DepositGold(存钱)",
	GO_HOME_RESTED = "GoHomeRested(回家睡觉)",
	QUENCH_THIRST = "QuenchThirst(解渴)",
}

-- 挖矿状态
local dig_for_nugget_state = {
	name = states.DIG_FOR_NUGGET,
}
function dig_for_nugget_state.on_enter(obj)
	if obj.m_location ~= location.goldmine then
		print(obj:logp()..": 步行来到金矿，准备开始挖矿了")
		obj.m_location = location.goldmine
	end
end
function dig_for_nugget_state.on_update(obj, _ --[[deltamillis]])
	obj:add_goldcarried(1) -- 挖到一块金矿
	obj:inc_fatigue() --增加疲劳值
	print(obj:logp()..": 捡起一块金块")

	if obj:is_pockets_full() then
		-- 如果背包已满则去银行存钱
		obj:change_state(states.DEPOSIT_GOLD)
	elseif obj:is_thirsty() then
		-- 者达到饥渴度阈值则去酒吧
		obj:change_state(states.QUENCH_THIRST)
	end
end
function dig_for_nugget_state.on_exit(obj)
	print(obj:logp()..": 啊，我要离开金矿了，口袋里装满了可爱的金子")
end

-- 存钱状态
local deposit_gold_state = {
	name = states.DEPOSIT_GOLD,
}
function deposit_gold_state.on_enter(obj)
	if obj.m_location ~= location.bank then
		print(obj:logp()..": 要去银行了吗. 是的，阁下")
		obj.m_location = location.bank
	end
end
function deposit_gold_state.on_update(obj, _ --[[deltamillis]])
	obj:add_wealth(obj.m_goldcarried)
	obj.m_goldcarried = 0
	print(obj:logp()..": 存放黄金。 现在总财富值: "..tostring(obj.m_moneyinbank))

	if obj:is_enough_money() then
		print(obj:logp()..": 哈哈！ 目前已经足够富有了。 回到家咯!!!")
		obj:change_state(states.GO_HOME_RESTED)
	else
		obj:change_state(states.DIG_FOR_NUGGET)
	end
end
function deposit_gold_state.on_exit(obj)
	print(obj:logp()..": 行走在离开银行的路上")
end

-- 矿工回家休息
local go_home_rested_state = {
	name = states.GO_HOME_RESTED,
}
function go_home_rested_state.on_enter(obj)
	if obj.m_location ~= location.shack then
		print(obj:logp()..": 步行回家")
		obj.m_location = location.shack
	end
end
function go_home_rested_state.on_update(obj, _ --[[deltamillis]])
	if not obj:is_fatigued() then
		print(obj:logp()..": 这次睡真香甜！ 是时候寻找更多黄金了")
		obj:change_state(states.DIG_FOR_NUGGET)
	else
		obj:dec_fatigue() --减少疲劳值
		print(obj:logp()..": ZZZZ... ")
	end
end
function go_home_rested_state.on_exit(obj, _ --[[deltamillis]])
	print(obj:logp()..": 离开了家")
end

-- 解渴
local quench_thirst_state = {
	name = states.QUENCH_THIRST
}
function quench_thirst_state.on_enter(obj)
	if obj.m_location ~= location.saloon then
		print(obj:logp()..": 太棒了！ 步行前往沙龙!")
		obj.m_location = location.saloon
	end
end
function quench_thirst_state.on_update(obj, _ --[[deltamillis]])
	assert(obj:is_thirsty(), "in quench_thirst_state but not thirsty")

	obj.m_thirst = 0
	obj.m_moneyinbank = obj.m_moneyinbank - 2
	print(obj:logp()..": 这酒喝起来真不错")
	obj:change_state(states.DIG_FOR_NUGGET)
end
function quench_thirst_state.on_exit(obj, _ --[[deltamillis]])
	print(obj:logp()..": 离开酒吧，感觉很好")
end

return {go_home_rested_state, dig_for_nugget_state, deposit_gold_state, quench_thirst_state}
