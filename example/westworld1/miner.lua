
local entity = require "entity"
local config = require "config"
local location = require "location"

-- 矿工
local miner = {}
miner.__index = miner

function miner.new(name)
	local obj = {
		m_entityid    = entity.get_nextid(), --实体id
		m_name        = name, --名称
		m_location    = location.shack, --当前位置
		m_goldcarried = 0, --矿工口袋里有多少块金块
		m_moneyinbank = 0, --银行存款
		m_thirst      = 0, --饥渴度: 值越高，矿工越渴
		m_fatigue     = 0, --疲劳值: 值越高，矿工越累
	}
	setmetatable(obj, miner)
	return obj
end

function miner.logp(self)
	return string.format("%s(%d)", self.m_name, self.m_entityid)
end

-- 增加金矿
function miner.add_goldcarried(self, val)
	self.m_goldcarried = self.m_goldcarried + val
	if self.m_goldcarried < 0 then
		self.m_goldcarried = 0
	end
end

-- 增加金矿
function miner.is_pockets_full(self)
	return self.m_goldcarried >= config.max_nuggets
end


-- 增加财富
function miner.add_wealth(self, val)
	self.m_moneyinbank = self.m_moneyinbank + val
	if self.m_moneyinbank < 0 then
		self.m_moneyinbank = 0
	end
end

-- 矿工是否处于口渴状态
function miner.is_thirsty(self)
	return self.m_thirst >= config.thirst_level
end

-- 矿工是否处于非口渴状态
function miner.is_not_thirsty(self)
	return self.m_thirst < config.thirst_level
end

-- 矿工是否处于疲劳状态
function miner.is_fatigued(self)
	return self.m_fatigue >= config.tiredness_threshold
end

-- 矿工是否处于非疲劳状态
function miner.is_not_fatigued(self)
	return self.m_fatigue < config.tiredness_threshold
end

-- 有足够的钱了
function miner.is_enough_money(self)
	return self.m_moneyinbank >= config.comfort_level
end

-- 增加疲劳值
function miner.inc_fatigue(self)
	self.m_fatigue = self.m_fatigue + 1
end

-- 减少疲劳值
function miner.dec_fatigue(self)
	self.m_fatigue = self.m_fatigue - 1
end

return miner
