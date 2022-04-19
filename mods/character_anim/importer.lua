local BinaryStream
local previous_require = require
rawset(_G, "require", insecure_environment.require)
pcall(function()
    -- Lua 5.1 compatibility
    rawset(_G, "bit", rawget(_G, "bit") or require"bit")
    BinaryStream = require"binarystream"
end)
rawset(_G, "require", previous_require)
local io = insecure_environment.io
insecure_environment = nil
if not BinaryStream then return end

local data_uri_start = "data:application/octet-stream;base64,"
function read_bonedata(path)
    local gltf = minetest.parse_json(modlib.file.read(path))
    local buffers = {}
    for index, buffer in ipairs(gltf.buffers) do
        buffer = buffer.uri
        assert(modlib.text.starts_with(buffer, data_uri_start))
        -- Trim padding characters, see https://github.com/minetest/minetest/commit/f34abaedd2b9277c1862cd9b82ca3338747f104e
        buffers[index] = assert(minetest.decode_base64(modlib.text.trim_right(buffer:sub((data_uri_start):len()+1), "=")) or nil, "base64 decoding failed, upgrade to Minetest 5.4 or newer")
    end
    local accessors = gltf.accessors
    local function read_accessor(accessor)
        local buffer_view = gltf.bufferViews[accessor.bufferView + 1]
        local buffer = assert(buffers[buffer_view.buffer + 1])
        local binary_stream = BinaryStream(buffer, buffer:len())
        -- See https://github.com/KhronosGroup/glTF/tree/master/specification/2.0#animations
        local component_readers = {
            [5120] = function()
                return math.max(binary_stream:readS8() / 127, -1)
            end,
            [5121] = function()
                return binary_stream:readU8() / 255
            end,
            [5122] = function()
                return math.max(binary_stream:readS16() / 32767, -1)
            end,
            [5123] = function()
                return binary_stream:readU16() / 65535
            end,
            [5126] = function()
                return binary_stream:readF32()
            end
        }
        local accessor_type = accessor.type
        local component_reader = component_readers[accessor.componentType]
        binary_stream:skip(buffer_view.byteOffset)
        local values = {}
        for index = 1, accessor.count do
            if accessor_type == "SCALAR" then
                values[index] = component_reader()
            elseif accessor_type == "VEC3" then
                values[index] = {
                    x = component_reader(),
                    y = component_reader(),
                    z = component_reader()
                }
            elseif accessor_type == "VEC4" then
                values[index] = {
                    component_reader(),
                    component_reader(),
                    component_reader(),
                    component_reader()
                }
            end
        end
        return values
    end
    local nodes = gltf.nodes
    local animation = gltf.animations[1]
    local channels, samplers = animation.channels, animation.samplers
    local animations_by_nodename = {}
    for _, node in pairs(nodes) do
        animations_by_nodename[node.name] = {
            default_translation = node.translation,
            default_rotation = node.rotation
        }
    end
    for _, channel in ipairs(channels) do
        local path, node_index, sampler = channel.target.path, channel.target.node, samplers[channel.sampler + 1]
        assert(sampler.interpolation == "LINEAR")
        if path == "translation" or path == "rotation" then
            local time_accessor = accessors[sampler.input + 1]
            local time, transform = read_accessor(time_accessor), read_accessor(accessors[sampler.output + 1])
            local min_time, max_time = time_accessor.min and time_accessor.min[1] or modlib.table.min(time), time_accessor.max and time_accessor.max[1] or modlib.table.max(time)
            local nodename = nodes[node_index + 1].name
            assert(not animations_by_nodename[nodename][path])
            animations_by_nodename[nodename][path] = {
                start_time = min_time,
                end_time = max_time,
                keyframes = time,
                values = transform
            }
        end
    end
    -- HACK to remove unanimated bones (technically invalid, but only proper way to remove Armature / Player / Camera / Suns)
    for bone, animation in pairs(animations_by_nodename) do
        if not(animation.translation or animation.rotation) then
            animations_by_nodename[bone] = nil
        end
    end
    local is_root, is_child = {}, {}
    for index, node in pairs(nodes) do
        if animations_by_nodename[node.name] then
            local children = node.children
            if children and #children > 0 then
                is_root[index] = node
                for _, child_index in pairs(children) do
                    child_index = child_index + 1
                    assert(not is_child[child_index])
                    is_child[child_index] = true
                    is_root[child_index] = nil
                end
            end
        end
    end
    local order = {}
    local insert = modlib.func.curry(table.insert, order)
    for node_index in pairs(is_root) do
        local node = nodes[node_index]
        insert(node.name)
        local function insert_children(parent, children)
            for _, child_index in ipairs(children) do
                local child = nodes[child_index + 1]
                local name = child.name
                animations_by_nodename[name].parent = parent
                insert(name)
                if child.children then
                    insert_children(name, child.children)
                end
            end
        end
        insert_children(node.name, node.children)
    end
    for index, node in ipairs(nodes) do
        if animations_by_nodename[node.name] and not(is_root[index] or is_child[index]) then
            insert(node.name)
        end
    end
    return {order = order, animations_by_nodename = animations_by_nodename}
end

local basepath = modlib.mod.get_resource""

function import_model(filename)
    local path = basepath .. "models/".. filename .. ".gltf"
    if not modlib.file.exists(path) then
        return false
    end
    modeldata[filename] = read_bonedata(path)
    local file = io.open(basepath .. "modeldata.lua", "w")
    file:write(minetest.serialize(modeldata))
    file:close()
    return true
end

minetest.register_chatcommand("ca_import", {
    params = "<filename>",
    description = "Imports a model for use with character_anim",
    privs = {server = true},
    func = function(_, filename)
        local success = import_model(filename)
        return success, (success and "Model %s imported successfully" or "File %s does not exist"):format(filename)
    end
})