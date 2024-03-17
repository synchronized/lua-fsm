--[[
	状态
]]

local fsm_state = {}

--创建一个状态
--@param name 状态名称
--@param tblstate 状态原生定义，必须要有name属性，可选的on_enter,on_update,on_exit方法
--@param userdata 用户数据,会作为参数传递给on_enter,on_update,on_exit上面的三个方法
--@return 返回创建的状态对象
function fsm_state.new(tblstate, userdata)
	local state_name = tblstate.name or error(string.format("invalid state name"))
	local action_obj = {
		name_ = state_name,
		on_enter_ = tblstate.on_enter,
		on_update_ = tblstate.on_update,
		on_exit_ = tblstate.on_exit,
		user_data_ = userdata,

		enter = fsm_state.enter,
		update = fsm_state.update,
		exit = fsm_state.exit,
	}
	return action_obj
end

--状态初始化
--@param self fsm_state.new创建的对象
function fsm_state.enter(self)
	if self.on_enter_ then
		self.on_enter_(self.user_data_)
	end
end

--状态更新
--@param self fsm_state.new创建的对象
function fsm_state.update(self, deltamillis)
	if self.on_update_ then
		self.on_update_(self.user_data_, deltamillis)
	end
end

--状态退出
--@param self fsm_state.new创建的对象
function fsm_state.exit(self)
	if self.on_exit_ then
		self.on_exit_(self.user_data_)
	end
end

--[[
	状态机
]]

local fsm_machine = {}

--创建一个状态机对象
--@param userdata 用户数据,会作为参数传递给上面的三个方法
--@return 返回创建的状态机对象
function fsm_machine.new()
	local fsm = {
		current_state_ = nil,
		states_ = {},

		add_state = fsm_machine.add_state,
		has_state = fsm_machine.has_state,
		get_current_state_name = fsm_machine.get_current_state_name,
		change_state = fsm_machine.change_state,
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

--返回当前状态名称
--@param self fsm_machine.new创建的状态机对象
--@return 返回当前状态名称
function fsm_machine.get_current_state_name(self)
	if self.current_state_ then
		return self.current_state_.name_
	end
end

--设置当前状态
--@param self fsm_machine.new创建的状态机对象
--@param state_name 状态名称
function fsm_machine.change_state(self, state_name)
	if not self.current_state_ and not self.states_[state_name] then
		return
	end
	if self.current_state_ == self.states_[state_name] then
		return
	end
	if self.current_state_ then
		self.current_state_:exit()
	end

	self.current_state_ = self.states_[state_name]
	if self.current_state_ then
		self.current_state_:enter()
	end
end

--添加状态
--@param self fsm_machine.new创建的状态机对象
--@param state_name 状态名称
--@param tblstate 状态原生定义，必须要有name属性，可选的on_enter,on_update,on_exit方法
--@param userdata 用户数据,会作为参数传递给on_enter,on_update,on_exit上面的三个方法
function fsm_machine.add_state(self, tblstate, userdata)
	local state_name = tblstate.name or error(string.format("invalid state name"))
	self.states_[state_name] = fsm_state.new(tblstate, userdata)
end

--添加状态转化对象
--@param self fsm_machine.new创建的状态机对象
--@param deltamill 经过的毫秒数
function fsm_machine.update(self, deltamill)
	if self.current_state_ then
		self.current_state_:update(deltamill)
	end
end

return fsm_machine
