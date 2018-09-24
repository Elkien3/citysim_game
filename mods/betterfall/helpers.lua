function betterfall.register_ghostnode(nodename) 
    table.insert(betterfall.ghost_nodes, nodename)
end

function betterfall.set_falling_time(time) 
    betterfall.falling_time = time
end