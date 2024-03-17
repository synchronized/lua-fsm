# lua-fsm

# Introduction
lua版本的有限状态机(Finite-state machine 以下简称fsm), fsm所有组件都在 luafsm.lua 文件中
还有两个示例:
test.lua
westworld1

## 类型
### fsm_state 状态
动作： 对应fsm中状态需要执行的动作, 它由一个字符串类型的<u>state_name</u> ，三个回调函数，一个userdata组成
userdata 会在回调的时候传递回对应的回调函数的第一个参数
使用:<u>fsm_state.new({name, on_enter, on_update, on_exit}, user_data)</u>函数创建状态

### fsm_machine 状态机
主要控制状态更新
```fsm_machine.new()``` 创建状态机
```fsm_machine.has_state(self, state_name)``` 查询是否存在状态
```fsm_machine.get_current_state_name(self)``` 获取当前状态名称
```fsm_machine.change_state(self, state_name)``` 改变当前状态
```fsm_machine.add_state(self, tblstate, userdata)``` 添加状态到状态机
```fsm_machine.update(self, deltamill)``` 更新状态机

```lua
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
```

执行结果如下
```
┌(~/workspace/lua-fsm/example)-[git://main ✗]-
└> lua test2.lua
player001: idlestate.init
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 0.000, y: 0.000} to pos{x: -18.000, y: -10.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: -1.800, y: -1.000}
player001: movestate.update pos{x: -3.420, y: -1.900}
player001: movestate.update pos{x: -4.878, y: -2.710}
player001: movestate.update pos{x: -6.190, y: -3.439}
player001: movestate.update pos{x: -7.371, y: -4.095}
player001: movestate.update pos{x: -8.434, y: -4.686}
player001: movestate.update pos{x: -9.391, y: -5.217}
player001: movestate.update pos{x: -10.252, y: -5.695}
player001: movestate.update pos{x: -11.026, y: -6.126}
player001: movestate.update pos{x: -11.724, y: -6.513}
player001: movestate.update pos{x: -12.351, y: -6.862}
player001: movestate.update pos{x: -12.916, y: -7.176}
player001: movestate.update pos{x: -13.425, y: -7.458}
player001: movestate.update pos{x: -13.882, y: -7.712}
player001: movestate.update pos{x: -14.294, y: -7.941}
player001: movestate.update pos{x: -14.665, y: -8.147}
player001: movestate.update pos{x: -14.998, y: -8.332}
player001: movestate.update pos{x: -15.298, y: -8.499}
player001: movestate.update pos{x: -15.568, y: -8.649}
player001: movestate.update pos{x: -15.812, y: -8.784}
player001: movestate.update pos{x: -16.030, y: -8.906}
player001: movestate.update pos{x: -16.227, y: -9.015}
player001: movestate.update pos{x: -16.405, y: -9.114}
player001: movestate.update pos{x: -16.564, y: -9.202}
player001: movestate.update pos{x: -16.708, y: -9.282}
player001: movestate.update pos{x: -16.837, y: -9.354}
player001: movestate.update pos{x: -16.953, y: -9.419}
player001: movestate.update pos{x: -17.058, y: -9.477}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: -17.152, y: -9.529}
command move player from pos{x: -17.152, y: -9.529} to pos{x: 4.000, y: 30.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: -15.037, y: -5.576}
player001: movestate.update pos{x: -13.133, y: -2.018}
player001: movestate.update pos{x: -11.420, y: 1.183}
player001: movestate.update pos{x: -9.878, y: 4.065}
player001: movestate.update pos{x: -8.490, y: 6.659}
player001: movestate.update pos{x: -7.241, y: 8.993}
player001: movestate.update pos{x: -6.117, y: 11.093}
player001: movestate.update pos{x: -5.105, y: 12.984}
player001: movestate.update pos{x: -4.195, y: 14.686}
player001: movestate.update pos{x: -3.375, y: 16.217}
player001: movestate.update pos{x: -2.638, y: 17.595}
player001: movestate.update pos{x: -1.974, y: 18.836}
player001: movestate.update pos{x: -1.377, y: 19.952}
player001: movestate.update pos{x: -0.839, y: 20.957}
player001: movestate.update pos{x: -0.355, y: 21.861}
player001: movestate.update pos{x: 0.080, y: 22.675}
player001: movestate.update pos{x: 0.472, y: 23.408}
player001: movestate.update pos{x: 0.825, y: 24.067}
player001: movestate.update pos{x: 1.143, y: 24.660}
player001: movestate.update pos{x: 1.428, y: 25.194}
player001: movestate.update pos{x: 1.686, y: 25.675}
player001: movestate.update pos{x: 1.917, y: 26.107}
player001: movestate.update pos{x: 2.125, y: 26.497}
player001: movestate.update pos{x: 2.313, y: 26.847}
player001: movestate.update pos{x: 2.481, y: 27.162}
player001: movestate.update pos{x: 2.633, y: 27.446}
player001: movestate.update pos{x: 2.770, y: 27.701}
player001: movestate.update pos{x: 2.893, y: 27.931}
player001: movestate.update pos{x: 3.004, y: 28.138}
player001: movestate.update pos{x: 3.103, y: 28.324}
player001: movestate.update pos{x: 3.193, y: 28.492}
player001: movestate.update pos{x: 3.274, y: 28.643}
player001: movestate.update pos{x: 3.346, y: 28.778}
player001: movestate.update pos{x: 3.412, y: 28.901}
player001: movestate.update pos{x: 3.471, y: 29.011}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 3.523, y: 29.109}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 3.523, y: 29.109} to pos{x: -31.000, y: 6.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 0.071, y: 26.799}
player001: movestate.update pos{x: -3.036, y: 24.719}
player001: movestate.update pos{x: -5.832, y: 22.847}
player001: movestate.update pos{x: -8.349, y: 21.162}
player001: movestate.update pos{x: -10.614, y: 19.646}
player001: movestate.update pos{x: -12.653, y: 18.281}
player001: movestate.update pos{x: -14.488, y: 17.053}
player001: movestate.update pos{x: -16.139, y: 15.948}
player001: movestate.update pos{x: -17.625, y: 14.953}
player001: movestate.update pos{x: -18.962, y: 14.058}
player001: movestate.update pos{x: -20.166, y: 13.252}
player001: movestate.update pos{x: -21.250, y: 12.527}
player001: movestate.update pos{x: -22.225, y: 11.874}
player001: movestate.update pos{x: -23.102, y: 11.287}
player001: movestate.update pos{x: -23.892, y: 10.758}
player001: movestate.update pos{x: -24.603, y: 10.282}
player001: movestate.update pos{x: -25.242, y: 9.854}
player001: movestate.update pos{x: -25.818, y: 9.469}
player001: movestate.update pos{x: -26.336, y: 9.122}
player001: movestate.update pos{x: -26.803, y: 8.810}
player001: movestate.update pos{x: -27.222, y: 8.529}
player001: movestate.update pos{x: -27.600, y: 8.276}
player001: movestate.update pos{x: -27.940, y: 8.048}
player001: movestate.update pos{x: -28.246, y: 7.843}
player001: movestate.update pos{x: -28.522, y: 7.659}
player001: movestate.update pos{x: -28.769, y: 7.493}
player001: movestate.update pos{x: -28.992, y: 7.344}
player001: movestate.update pos{x: -29.193, y: 7.209}
player001: movestate.update pos{x: -29.374, y: 7.088}
player001: movestate.update pos{x: -29.537, y: 6.980}
player001: movestate.update pos{x: -29.683, y: 6.882}
player001: movestate.update pos{x: -29.815, y: 6.794}
player001: movestate.update pos{x: -29.933, y: 6.714}
player001: movestate.update pos{x: -30.040, y: 6.643}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: -30.136, y: 6.578}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: -30.136, y: 6.578} to pos{x: 5.000, y: 28.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: -26.622, y: 8.721}
player001: movestate.update pos{x: -23.460, y: 10.649}
player001: movestate.update pos{x: -20.614, y: 12.384}
player001: movestate.update pos{x: -18.053, y: 13.945}
player001: movestate.update pos{x: -15.747, y: 15.351}
player001: movestate.update pos{x: -13.673, y: 16.616}
player001: movestate.update pos{x: -11.805, y: 17.754}
player001: movestate.update pos{x: -10.125, y: 18.779}
player001: movestate.update pos{x: -8.612, y: 19.701}
player001: movestate.update pos{x: -7.251, y: 20.531}
player001: movestate.update pos{x: -6.026, y: 21.278}
player001: movestate.update pos{x: -4.923, y: 21.950}
player001: movestate.update pos{x: -3.931, y: 22.555}
player001: movestate.update pos{x: -3.038, y: 23.099}
player001: movestate.update pos{x: -2.234, y: 23.589}
player001: movestate.update pos{x: -1.511, y: 24.031}
player001: movestate.update pos{x: -0.860, y: 24.427}
player001: movestate.update pos{x: -0.274, y: 24.785}
player001: movestate.update pos{x: 0.254, y: 25.106}
player001: movestate.update pos{x: 0.728, y: 25.396}
player001: movestate.update pos{x: 1.155, y: 25.656}
player001: movestate.update pos{x: 1.540, y: 25.890}
player001: movestate.update pos{x: 1.886, y: 26.101}
player001: movestate.update pos{x: 2.197, y: 26.291}
player001: movestate.update pos{x: 2.478, y: 26.462}
player001: movestate.update pos{x: 2.730, y: 26.616}
player001: movestate.update pos{x: 2.957, y: 26.754}
player001: movestate.update pos{x: 3.161, y: 26.879}
player001: movestate.update pos{x: 3.345, y: 26.991}
player001: movestate.update pos{x: 3.511, y: 27.092}
player001: movestate.update pos{x: 3.659, y: 27.183}
player001: movestate.update pos{x: 3.794, y: 27.264}
player001: movestate.update pos{x: 3.914, y: 27.338}
player001: movestate.update pos{x: 4.023, y: 27.404}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 4.120, y: 27.464}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 4.120, y: 27.464} to pos{x: 16.000, y: -41.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 5.308, y: 20.617}
player001: movestate.update pos{x: 6.378, y: 14.456}
player001: movestate.update pos{x: 7.340, y: 8.910}
player001: movestate.update pos{x: 8.206, y: 3.919}
player001: movestate.update pos{x: 8.985, y: -0.573}
player001: movestate.update pos{x: 9.687, y: -4.616}
player001: movestate.update pos{x: 10.318, y: -8.254}
player001: movestate.update pos{x: 10.886, y: -11.529}
player001: movestate.update pos{x: 11.398, y: -14.476}
player001: movestate.update pos{x: 11.858, y: -17.128}
player001: movestate.update pos{x: 12.272, y: -19.515}
player001: movestate.update pos{x: 12.645, y: -21.664}
player001: movestate.update pos{x: 12.980, y: -23.597}
player001: movestate.update pos{x: 13.282, y: -25.338}
player001: movestate.update pos{x: 13.554, y: -26.904}
player001: movestate.update pos{x: 13.799, y: -28.314}
player001: movestate.update pos{x: 14.019, y: -29.582}
player001: movestate.update pos{x: 14.217, y: -30.724}
player001: movestate.update pos{x: 14.395, y: -31.752}
player001: movestate.update pos{x: 14.556, y: -32.676}
player001: movestate.update pos{x: 14.700, y: -33.509}
player001: movestate.update pos{x: 14.830, y: -34.258}
player001: movestate.update pos{x: 14.947, y: -34.932}
player001: movestate.update pos{x: 15.052, y: -35.539}
player001: movestate.update pos{x: 15.147, y: -36.085}
player001: movestate.update pos{x: 15.232, y: -36.576}
player001: movestate.update pos{x: 15.309, y: -37.019}
player001: movestate.update pos{x: 15.378, y: -37.417}
player001: movestate.update pos{x: 15.440, y: -37.775}
player001: movestate.update pos{x: 15.496, y: -38.098}
player001: movestate.update pos{x: 15.547, y: -38.388}
player001: movestate.update pos{x: 15.592, y: -38.649}
player001: movestate.update pos{x: 15.633, y: -38.884}
player001: movestate.update pos{x: 15.670, y: -39.096}
player001: movestate.update pos{x: 15.703, y: -39.286}
player001: movestate.update pos{x: 15.732, y: -39.458}
player001: movestate.update pos{x: 15.759, y: -39.612}
player001: movestate.update pos{x: 15.783, y: -39.751}
player001: movestate.update pos{x: 15.805, y: -39.876}
player001: movestate.update pos{x: 15.824, y: -39.988}
player001: movestate.update pos{x: 15.842, y: -40.089}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 15.858, y: -40.180}
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 15.858, y: -40.180} to pos{x: 32.000, y: -47.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 17.472, y: -40.862}
player001: movestate.update pos{x: 18.925, y: -41.476}
player001: movestate.update pos{x: 20.232, y: -42.028}
player001: movestate.update pos{x: 21.409, y: -42.526}
player001: movestate.update pos{x: 22.468, y: -42.973}
player001: movestate.update pos{x: 23.421, y: -43.376}
player001: movestate.update pos{x: 24.279, y: -43.738}
player001: movestate.update pos{x: 25.051, y: -44.064}
player001: movestate.update pos{x: 25.746, y: -44.358}
player001: movestate.update pos{x: 26.372, y: -44.622}
player001: movestate.update pos{x: 26.934, y: -44.860}
player001: movestate.update pos{x: 27.441, y: -45.074}
player001: movestate.update pos{x: 27.897, y: -45.267}
player001: movestate.update pos{x: 28.307, y: -45.440}
player001: movestate.update pos{x: 28.676, y: -45.596}
player001: movestate.update pos{x: 29.009, y: -45.736}
player001: movestate.update pos{x: 29.308, y: -45.863}
player001: movestate.update pos{x: 29.577, y: -45.976}
player001: movestate.update pos{x: 29.819, y: -46.079}
player001: movestate.update pos{x: 30.037, y: -46.171}
player001: movestate.update pos{x: 30.234, y: -46.254}
player001: movestate.update pos{x: 30.410, y: -46.328}
player001: movestate.update pos{x: 30.569, y: -46.396}
player001: movestate.update pos{x: 30.712, y: -46.456}
player001: movestate.update pos{x: 30.841, y: -46.510}
player001: movestate.update pos{x: 30.957, y: -46.559}
player001: movestate.update pos{x: 31.061, y: -46.603}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 31.155, y: -46.643}
player001: idlestate.update
command move player from pos{x: 31.155, y: -46.643} to pos{x: -13.000, y: 18.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 26.740, y: -40.179}
player001: movestate.update pos{x: 22.766, y: -34.361}
player001: movestate.update pos{x: 19.189, y: -29.125}
player001: movestate.update pos{x: 15.970, y: -24.412}
player001: movestate.update pos{x: 13.073, y: -20.171}
player001: movestate.update pos{x: 10.466, y: -16.354}
player001: movestate.update pos{x: 8.119, y: -12.919}
player001: movestate.update pos{x: 6.007, y: -9.827}
player001: movestate.update pos{x: 4.107, y: -7.044}
player001: movestate.update pos{x: 2.396, y: -4.540}
player001: movestate.update pos{x: 0.856, y: -2.286}
player001: movestate.update pos{x: -0.529, y: -0.257}
player001: movestate.update pos{x: -1.776, y: 1.569}
player001: movestate.update pos{x: -2.899, y: 3.212}
player001: movestate.update pos{x: -3.909, y: 4.691}
player001: movestate.update pos{x: -4.818, y: 6.022}
player001: movestate.update pos{x: -5.636, y: 7.219}
player001: movestate.update pos{x: -6.373, y: 8.297}
player001: movestate.update pos{x: -7.035, y: 9.268}
player001: movestate.update pos{x: -7.632, y: 10.141}
player001: movestate.update pos{x: -8.169, y: 10.927}
player001: movestate.update pos{x: -8.652, y: 11.634}
player001: movestate.update pos{x: -9.087, y: 12.271}
player001: movestate.update pos{x: -9.478, y: 12.844}
player001: movestate.update pos{x: -9.830, y: 13.359}
player001: movestate.update pos{x: -10.147, y: 13.823}
player001: movestate.update pos{x: -10.432, y: 14.241}
player001: movestate.update pos{x: -10.689, y: 14.617}
player001: movestate.update pos{x: -10.920, y: 14.955}
player001: movestate.update pos{x: -11.128, y: 15.260}
player001: movestate.update pos{x: -11.315, y: 15.534}
player001: movestate.update pos{x: -11.484, y: 15.780}
player001: movestate.update pos{x: -11.635, y: 16.002}
player001: movestate.update pos{x: -11.772, y: 16.202}
player001: movestate.update pos{x: -11.895, y: 16.382}
player001: movestate.update pos{x: -12.005, y: 16.544}
player001: movestate.update pos{x: -12.105, y: 16.689}
player001: movestate.update pos{x: -12.194, y: 16.820}
player001: movestate.update pos{x: -12.275, y: 16.938}
player001: movestate.update pos{x: -12.347, y: 17.045}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: -12.413, y: 17.140}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: -12.413, y: 17.140} to pos{x: 47.000, y: 1.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: -6.471, y: 15.526}
player001: movestate.update pos{x: -1.124, y: 14.073}
player001: movestate.update pos{x: 3.688, y: 12.766}
player001: movestate.update pos{x: 8.019, y: 11.589}
player001: movestate.update pos{x: 11.917, y: 10.531}
player001: movestate.update pos{x: 15.426, y: 9.577}
player001: movestate.update pos{x: 18.583, y: 8.720}
player001: movestate.update pos{x: 21.425, y: 7.948}
player001: movestate.update pos{x: 23.982, y: 7.253}
player001: movestate.update pos{x: 26.284, y: 6.628}
player001: movestate.update pos{x: 28.356, y: 6.065}
player001: movestate.update pos{x: 30.220, y: 5.558}
player001: movestate.update pos{x: 31.898, y: 5.103}
player001: movestate.update pos{x: 33.408, y: 4.692}
player001: movestate.update pos{x: 34.767, y: 4.323}
player001: movestate.update pos{x: 35.991, y: 3.991}
player001: movestate.update pos{x: 37.092, y: 3.692}
player001: movestate.update pos{x: 38.082, y: 3.423}
player001: movestate.update pos{x: 38.974, y: 3.180}
player001: movestate.update pos{x: 39.777, y: 2.962}
player001: movestate.update pos{x: 40.499, y: 2.766}
player001: movestate.update pos{x: 41.149, y: 2.589}
player001: movestate.update pos{x: 41.734, y: 2.430}
player001: movestate.update pos{x: 42.261, y: 2.287}
player001: movestate.update pos{x: 42.735, y: 2.159}
player001: movestate.update pos{x: 43.161, y: 2.043}
player001: movestate.update pos{x: 43.545, y: 1.939}
player001: movestate.update pos{x: 43.891, y: 1.845}
player001: movestate.update pos{x: 44.202, y: 1.760}
player001: movestate.update pos{x: 44.481, y: 1.684}
player001: movestate.update pos{x: 44.733, y: 1.616}
player001: movestate.update pos{x: 44.960, y: 1.554}
player001: movestate.update pos{x: 45.164, y: 1.499}
player001: movestate.update pos{x: 45.348, y: 1.449}
player001: movestate.update pos{x: 45.513, y: 1.404}
player001: movestate.update pos{x: 45.662, y: 1.364}
player001: movestate.update pos{x: 45.795, y: 1.327}
player001: movestate.update pos{x: 45.916, y: 1.295}
player001: movestate.update pos{x: 46.024, y: 1.265}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 46.122, y: 1.239}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 46.122, y: 1.239} to pos{x: 32.000, y: -35.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 44.710, y: -2.385}
player001: movestate.update pos{x: 43.439, y: -5.647}
player001: movestate.update pos{x: 42.295, y: -8.582}
player001: movestate.update pos{x: 41.265, y: -11.224}
player001: movestate.update pos{x: 40.339, y: -13.601}
player001: movestate.update pos{x: 39.505, y: -15.741}
player001: movestate.update pos{x: 38.754, y: -17.667}
player001: movestate.update pos{x: 38.079, y: -19.400}
player001: movestate.update pos{x: 37.471, y: -20.960}
player001: movestate.update pos{x: 36.924, y: -22.364}
player001: movestate.update pos{x: 36.432, y: -23.628}
player001: movestate.update pos{x: 35.988, y: -24.765}
player001: movestate.update pos{x: 35.590, y: -25.789}
player001: movestate.update pos{x: 35.231, y: -26.710}
player001: movestate.update pos{x: 34.908, y: -27.539}
player001: movestate.update pos{x: 34.617, y: -28.285}
player001: movestate.update pos{x: 34.355, y: -28.956}
player001: movestate.update pos{x: 34.120, y: -29.561}
player001: movestate.update pos{x: 33.908, y: -30.105}
player001: movestate.update pos{x: 33.717, y: -30.594}
player001: movestate.update pos{x: 33.545, y: -31.035}
player001: movestate.update pos{x: 33.391, y: -31.431}
player001: movestate.update pos{x: 33.252, y: -31.788}
player001: movestate.update pos{x: 33.126, y: -32.109}
player001: movestate.update pos{x: 33.014, y: -32.398}
player001: movestate.update pos{x: 32.912, y: -32.659}
player001: movestate.update pos{x: 32.821, y: -32.893}
player001: movestate.update pos{x: 32.739, y: -33.103}
player001: movestate.update pos{x: 32.665, y: -33.293}
player001: movestate.update pos{x: 32.599, y: -33.464}
player001: movestate.update pos{x: 32.539, y: -33.617}
player001: movestate.update pos{x: 32.485, y: -33.756}
player001: movestate.update pos{x: 32.436, y: -33.880}
player001: movestate.update pos{x: 32.393, y: -33.992}
player001: movestate.update pos{x: 32.353, y: -34.093}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 32.318, y: -34.184}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 32.318, y: -34.184} to pos{x: 14.000, y: 28.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 30.486, y: -27.965}
player001: movestate.update pos{x: 28.838, y: -22.369}
player001: movestate.update pos{x: 27.354, y: -17.332}
player001: movestate.update pos{x: 26.019, y: -12.799}
player001: movestate.update pos{x: 24.817, y: -8.719}
player001: movestate.update pos{x: 23.735, y: -5.047}
player001: movestate.update pos{x: 22.762, y: -1.742}
player001: movestate.update pos{x: 21.885, y: 1.232}
player001: movestate.update pos{x: 21.097, y: 3.909}
player001: movestate.update pos{x: 20.387, y: 6.318}
player001: movestate.update pos{x: 19.748, y: 8.486}
player001: movestate.update pos{x: 19.174, y: 10.438}
player001: movestate.update pos{x: 18.656, y: 12.194}
player001: movestate.update pos{x: 18.191, y: 13.774}
player001: movestate.update pos{x: 17.772, y: 15.197}
player001: movestate.update pos{x: 17.394, y: 16.477}
player001: movestate.update pos{x: 17.055, y: 17.630}
player001: movestate.update pos{x: 16.749, y: 18.667}
player001: movestate.update pos{x: 16.475, y: 19.600}
player001: movestate.update pos{x: 16.227, y: 20.440}
player001: movestate.update pos{x: 16.004, y: 21.196}
player001: movestate.update pos{x: 15.804, y: 21.876}
player001: movestate.update pos{x: 15.624, y: 22.489}
player001: movestate.update pos{x: 15.461, y: 23.040}
player001: movestate.update pos{x: 15.315, y: 23.536}
player001: movestate.update pos{x: 15.184, y: 23.982}
player001: movestate.update pos{x: 15.065, y: 24.384}
player001: movestate.update pos{x: 14.959, y: 24.746}
player001: movestate.update pos{x: 14.863, y: 25.071}
player001: movestate.update pos{x: 14.777, y: 25.364}
player001: movestate.update pos{x: 14.699, y: 25.628}
player001: movestate.update pos{x: 14.629, y: 25.865}
player001: movestate.update pos{x: 14.566, y: 26.078}
player001: movestate.update pos{x: 14.509, y: 26.270}
player001: movestate.update pos{x: 14.459, y: 26.443}
player001: movestate.update pos{x: 14.413, y: 26.599}
player001: movestate.update pos{x: 14.371, y: 26.739}
player001: movestate.update pos{x: 14.334, y: 26.865}
player001: movestate.update pos{x: 14.301, y: 26.979}
player001: movestate.update pos{x: 14.271, y: 27.081}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: 14.244, y: 27.173}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: 14.244, y: 27.173} to pos{x: -22.000, y: 22.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: 10.619, y: 26.656}
player001: movestate.update pos{x: 7.357, y: 26.190}
player001: movestate.update pos{x: 4.422, y: 25.771}
player001: movestate.update pos{x: 1.779, y: 25.394}
player001: movestate.update pos{x: -0.598, y: 25.054}
player001: movestate.update pos{x: -2.739, y: 24.749}
player001: movestate.update pos{x: -4.665, y: 24.474}
player001: movestate.update pos{x: -6.398, y: 24.227}
player001: movestate.update pos{x: -7.958, y: 24.004}
player001: movestate.update pos{x: -9.363, y: 23.804}
player001: movestate.update pos{x: -10.626, y: 23.623}
player001: movestate.update pos{x: -11.764, y: 23.461}
player001: movestate.update pos{x: -12.787, y: 23.315}
player001: movestate.update pos{x: -13.709, y: 23.183}
player001: movestate.update pos{x: -14.538, y: 23.065}
player001: movestate.update pos{x: -15.284, y: 22.959}
player001: movestate.update pos{x: -15.956, y: 22.863}
player001: movestate.update pos{x: -16.560, y: 22.776}
player001: movestate.update pos{x: -17.104, y: 22.699}
player001: movestate.update pos{x: -17.594, y: 22.629}
player001: movestate.update pos{x: -18.034, y: 22.566}
player001: movestate.update pos{x: -18.431, y: 22.509}
player001: movestate.update pos{x: -18.788, y: 22.458}
player001: movestate.update pos{x: -19.109, y: 22.413}
player001: movestate.update pos{x: -19.398, y: 22.371}
player001: movestate.update pos{x: -19.658, y: 22.334}
player001: movestate.update pos{x: -19.892, y: 22.301}
player001: movestate.update pos{x: -20.103, y: 22.271}
player001: movestate.update pos{x: -20.293, y: 22.244}
player001: movestate.update pos{x: -20.464, y: 22.219}
player001: movestate.update pos{x: -20.617, y: 22.197}
player001: movestate.update pos{x: -20.756, y: 22.178}
player001: movestate.update pos{x: -20.880, y: 22.160}
player001: movestate.update pos{x: -20.992, y: 22.144}
player001: movestate.update pos{x: -21.093, y: 22.129}
player001: movestate.exit
player001: idlestate.init
player001: movestate.update pos{x: -21.183, y: 22.117}
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
player001: idlestate.update
command move player from pos{x: -21.183, y: 22.117} to pos{x: 46.000, y: -30.000}
player001: idlestate.update
player001: idlestate.exit
player001: movestate.enter
player001: movestate.update pos{x: -14.465, y: 16.905}
player001: movestate.update pos{x: -8.419, y: 12.214}
player001: movestate.update pos{x: -2.977, y: 7.993}
player001: movestate.update pos{x: 1.921, y: 4.194}
player001: movestate.update pos{x: 6.329, y: 0.774}
player001: movestate.update pos{x: 10.296, y: -2.303}
player001: movestate.update pos{x: 13.866, y: -5.073}
player001: movestate.update pos{x: 17.080, y: -7.566}
player001: movestate.update pos{x: 19.972, y: -9.809}
player001: movestate.update pos{x: 22.575, y: -11.828}
player001: movestate.update pos{x: 24.917, y: -13.645}
player001: movestate.update pos{x: 27.025, y: -15.281}
player001: movestate.update pos{x: 28.923, y: -16.753}
player001: movestate.update pos{x: 30.631, y: -18.077}
player001: movestate.update pos{x: 32.168, y: -19.270}
player001: movestate.update pos{x: 33.551, y: -20.343}
player001: movestate.update pos{x: 34.796, y: -21.308}
player001: movestate.update pos{x: 35.916, y: -22.178}
player001: movestate.update pos{x: 36.925, y: -22.960}
```
