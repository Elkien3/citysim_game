-- Trie implementation : A string search tree
trie = {}
local tr = trie

-- creates new trie : {}
function trie.new() return {} end

-- inserts word into trie
function trie.insert(trie, word, value, overwrite)
    for i = 1, word:len() do
        local char = word:sub(i, i)
        trie[char] = trie[char] or {}
        trie = trie[char]
    end
    local was_leaf = trie.is_leaf
    if (not was_leaf) or overwrite then trie.is_leaf = value or true end
    return was_leaf
end

-- removes word from trie if exists
function trie.remove(trie, word)
    local branch, character = trie, word:sub(1, 1)
    for i = 1, word:len() - 1 do
        local char = word:sub(i, i)
        if not trie[char] then return nil end
        if trie[char].is_leaf or next(trie, next(trie)) then
            branch = trie
            character = char
        end
        trie = trie[char]
    end
    local char = word:sub(word:len())
    if not trie[char] then return nil end
    trie = trie[char]
    local was_leaf = trie.is_leaf
    trie.is_leaf = nil
    if branch and not next(trie) then branch[character] = nil end
    return was_leaf
end

-- check whether trie contains word, returns value or false, subset of trie.search, higher performance when not found (searches no suggestion)
function trie.get(trie, word)
    for i = 1, word:len() do
        local char = word:sub(i, i)
        trie = trie[char]
        if not trie then return nil end
    end
    return trie.is_leaf
end

function trie.suggestion(trie, remainder)
    local until_now = {}
    local subtries = {[trie] = until_now}
    local suggestion, value
    while next(subtries) do
        local new_subtries = {}
        local leaves = {}
        for trie, word in pairs(subtries) do
            if trie.is_leaf then
                table.insert(leaves, {word = word, value = trie.is_leaf})
            end
        end
        if #leaves > 0 then
            if remainder then
                local best_leaves = {}
                local best_score = 0
                for _, leaf in pairs(leaves) do
                    local score = 0
                    for i = 1, math.min(#leaf.word, string.len(remainder)) do -- calculate intersection
                        if remainder:sub(i, i) == leaf.word[i] then
                            score = score + 1
                        end
                    end
                    if score == best_score then
                        table.insert(best_leaves, leaf)
                    elseif score > best_score then
                        best_leaves = {leaf}
                    end
                end
                leaves = best_leaves
            end
            local leaf = leaves[math.random(1, #leaves)] -- TODO select best instead of random (?)
            suggestion, value = table.concat(leaf.word), leaf.value
            break
        end
        for trie, word in pairs(subtries) do
            for char, subtrie in pairs(trie) do
                local word = {unpack(word)}
                table.insert(word, char)
                new_subtries[subtrie] = word
            end
        end
        subtries = new_subtries
    end
    return suggestion, value
end

-- searches word in trie, returns true if found, or (false, suggestion) when not
function trie.search(trie, word)
    for i = 1, word:len() do
        local char = word:sub(i, i)
        if not trie[char] then
            local until_now = word:sub(1, i - 1)
            local suggestion, value = tr.suggestion(trie, word:sub(i))
            return nil, until_now .. suggestion, value
        end
        trie = trie[char]
    end
    local is_leaf = trie.is_leaf
    if is_leaf then return is_leaf end
    local until_now = word
    local suggestion, value = tr.suggestion(trie)
    return nil, until_now .. suggestion, value
end

function trie.find_longest(trie, query, query_offset)
    local leaf_pos = query_offset
    local last_leaf
    for i = query_offset, query:len() do
        local char = query:sub(i, i)
        trie = trie[char]
        if not trie then
            break
        elseif trie.is_leaf then
            last_leaf = trie.is_leaf
            leaf_pos = i
        end
    end
    return last_leaf, leaf_pos
end