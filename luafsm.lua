--[[
	状态动作,组成状态的一部分
]]

local fsm_action = {}

fsm_action.type = "action"
fsm_action.status = {
	RUNNING = "RUNNING", --运行中
	TERMINATED = "TERMINATED", --结束
	UNINIIALIZED = "UNINIIALIZED" --还未初始化
}

--创建一个状态动作
--@param name 状态动作名称
--@param finit 状态动作初始化方法
--@param fupdate 状态动作更新方法
--@param fcleanup 状态动作清理方法
--@param userdata 用户数据,会作为参数传递给上面的三个方法
--@return 返回创建的状态动作对象
function fsm_action.new(name, finit, fupdate, fcleanup, userdata)
	local action_obj = {
		finit_ = finit,
		fupdate_  = fupdate,
		fcleanup_ = fcleanup,
		name_ = name or "",
		status_ = fsm_action.status.UNINIIALIZED,
		type_ = fsm_action.type,
		user_data_ = userdata,

		init = fsm_action.init,
		update = fsm_action.update,
		cleanup = fsm_action.cleanup,
	}
	return action_obj
end

--状态动作初始化
--@param self fsm_action.new创建的对象
function fsm_action.init(self)
	if self.status_ == fsm_action.status.UNINIIALIZED then
		if self.finit_ then
			self.finit_(self.user_data_)
		end
	end

	self.status_ = fsm_action.status.RUNNING
end

--状态动作更新
--@param self fsm_action.new创建的对象
function fsm_action.update(self, deltamillis)
	if self.status_ == fsm_action.status.TERMINATED then
		return fsm_action.status.TERMINATED
	elseif self.status_ == fsm_action.status.RUNNING then
		if self.fupdate_ then
			self.status_ = self.fupdate_(self.user_data_, deltamillis)

			assert(self.status_)
		else
			self.status_ = fsm_action.status.TERMINATED
		end
	end

	return self.status_
end

--状态动作清理
--@param self fsm_action.new创建的对象
function fsm_action.cleanup(self)
	if self.status_ == fsm_action.status.TERMINATED then
		if self.fcleanup_ then
			self.fcleanup_(self.user_data_)
		end
	end

	self.status_ = fsm_action.status.UNINIIALIZED
end

--[[
	状态
]]

local fsm_state = {}

--创建一个状态
--@param name 状态名称
--@param action fsm_action.new创建的动作
--@return 返回创建的状态对象
function fsm_state.new(name, action)
	local state = {
		name_ = name,
		action_ = action,
	}
	return state
end

--[[
	状态转换对象
]]

local fsm_transition = {}

--创建一个状态转换对象
--@param to_state_name 要转换到的状态名称
--@param fevaluator 一个函数用来判断条件是否达成
--@return 返回创建的状态对象
function fsm_transition.new(to_state_name, fevaluato)
	local transition = {
		evaluator_ = fevaluato,
		to_state_name_ = to_state_name,
	}
	return transition
end

--[[
	状态机
]]

local fsm_machine = {}
fsm_machine.new_action = fsm_action.new
fsm_machine.status = fsm_action.status

--创建一个状态机对象
--@param userdata 用户数据,会作为参数传递给上面的三个方法
--@return 返回创建的状态机对象
function fsm_machine.new(userdata)
	local fsm = {
		current_state_ = nil,
		states_ = {},
		transition_ = {},
		user_data_ = userdata,

		new_action = fsm_action.new,
		add_state = fsm_machine.add_state,
		add_transition = fsm_machine.add_transition,
		has_state = fsm_machine.has_state,
		has_transition = fsm_machine.has_transition,
		get_current_state_name = fsm_machine.get_current_state_name,
		get_current_state_status = fsm_machine.get_current_state_status,
		set_state = fsm_machine.set_state,
		update = fsm_machine.update,
	}
	return fsm
end

--是否存在指定名称的状态
--@param state_name 状态名称
--@return 返回是否存在状态对象
function fsm_machine.has_state(self, state_name)
	return self.states_[state_name] ~= nil
end

--是否存在指定名称状态转化状态
--@param self fsm_machine.new创建的状态机对象
--@param from_state_name 原始状态名称
--@param to_state_name 目标状态名称
--@return 返回是否存在状态转换对象
function fsm_machine.has_transition(self, from_state_name, to_state_name)
	return self.transition_[from_state_name] ~= nil and
		self.transition_[from_state_name][to_state_name] ~= nil
end

--返回当前状态名称
--@param self fsm_machine.new创建的状态机对象
--@return 返回当前状态名称
function fsm_machine.get_current_state_name(self)
	if self.current_state_ then
		return self.current_state_.name_
	end
end

--返回当前状态status
--@param self fsm_machine.new创建的状态机对象
--@return 返回当前状态status
function fsm_machine.get_current_state_status(self)
	if self.current_state_ then
		return self.current_state_.action_.status_
	end
end

--设置当前状态
--@param self fsm_machine.new创建的状态机对象
--@param state_name 状态名称
function fsm_machine.set_state(self, state_name)
	if self:has_state(state_name) then
		if self.current_state_ then
			self.current_state_.action_:cleanup()
		end

		self.current_state_ = self.states_[state_name]
		self.current_state_.action_:init()
	end
end

--添加状态
--@param self fsm_machine.new创建的状态机对象
--@param state_name 状态名称
--@param action 动作,fsm_action.new创建的对象
function fsm_machine.add_state(self, state_name, action)
	assert(action, string.format("invalid action in state_name: %s", tostring(state_name)))
	self.states_[state_name] = fsm_state.new(state_name, action)
end

--添加状态转化对象
--@param self fsm_machine.new创建的状态机对象
--@param from_state_name 原始状态名称
--@param to_state_name 目标状态名称
--@param fevaluator 一个函数用来判断条件是否达成
function fsm_machine.add_transition(self, from_state, to_state, fevaluator)
	if self:has_state(from_state) and
		self:has_state(to_state) then

		if self.transition_[from_state] == nil then
			self.transition_[from_state] = {}
		end

		table.insert(
			self.transition_[from_state],
			fsm_transition.new(to_state, fevaluator)
		)
	end
end

local function evaluateTransitions(self, transitions)
	for index = 1 , #transitions do
		if transitions[index].evaluator_(self.user_data_) then
			return transitions[index].to_state_name_;
		end
	end
end

--添加状态转化对象
--@param self fsm_machine.new创建的状态机对象
--@param deltamill 经过的毫秒数
function fsm_machine.update(self, deltamill)
	if self.current_state_ then
		local status = self:get_current_state_status()

		if status == fsm_action.status.RUNNING then
			self.current_state_.action_:update(deltamill)
		elseif status == fsm_action.status.TERMINATED then
			local to_state_name = evaluateTransitions(self,self.transition_[self.current_state_.name_])

			if self.states_[to_state_name] ~= nil then
				self.current_state_.action_:cleanup()
				self.current_state_ = self.states_[to_state_name]
				self.current_state_.action_:init()
			end
		end
	end
end

return fsm_machine
