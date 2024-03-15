package.path = "../../?.lua;"..package.path

local miner = require "miner_fsm"

local minerobj = miner.create("Jick001")
for _ = 1, 100 do
	minerobj:update(0.1)
end
