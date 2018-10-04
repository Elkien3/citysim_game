function betterfall.register_ghostnode(nodename) 
    table.insert(betterfall.ghost_nodes, nodename)
end

function betterfall.set_falling_timer(timer) 
    betterfall.falling_timer = timer
end
