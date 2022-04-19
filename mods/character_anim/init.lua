local mod = modlib.mod
local namespace = mod.create_namespace()
namespace.quaternion = modlib.quaternion
namespace.conf = mod.configuration()
namespace.insecure_environment = minetest.request_insecure_environment() or _G
mod.extend"importer"
mod.extend"main"