
local entity = {
	entity_id = 0;
}

--获取实体id
function entity.get_nextid()
	entity.entity_id = entity.entity_id+1
	return entity.entity_id
end

return entity
