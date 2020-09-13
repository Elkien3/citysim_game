
#### Advtrains - Lua Automation features

This mod offers components that run LUA code and interface with each other through a global environment. It makes complex automated railway systems possible.

### atlatc
The mod is sometimes abbreviated as 'atlatc'. This stands for AdvTrainsLuaATC. This short name has been chosen for user convenience, since the name of this mod ('advtrains_luaautomation') is very long.

### Privilege
To perform any operations using this mod (except executing operation panels), players need the "atlatc" privilege.
This privilege should never be granted to anyone except trusted administrators. Even though the LUA environment is sandboxed, it is still possible to DoS the server by coding infinite loops or requesting expotentially growing interrupts. 

### Active and passive
Active components are these who have LUA code running in them. They are triggered on specific events. Passive components are dumb, they only have a state and can be set to another state, they can't perform actions themselves.

### Environments

Each active component is assigned to an environment. This is where all data are held. Components in different environments can't inferface with each other.
This system allows multiple independent automation systems to run simultaneously without polluting each other's environment.

/env_create <env_name>
Create environment with the given name. To be able to do anything, you first need to create an environment. Choose the name wisely, you can't change it afterwards.

/env_setup <env_name>
Invoke the form to edit the environment's initialization code. For more information, see the section on active components. You can also delete an environment from here.

### Active components

The code of every active component is run on specific events which are explained soon. When run, every variable written that is not local and is no function or userdata is saved over code re-runs and over server restarts. Additionally, the following global variables are defined:

# event
The variable 'event' contains a table with information on the current event. How this table can look is explained below.

# S
The variable 'S' contains a table which is shared between all components of the environment. Its contents are persistent over server restarts. May not contain functions, every other value is allowed.
Example:
Component 1: S.stuff="foo"
Component 2: print(S.stuff)
-> foo

# F
The variable 'F' also contains a table which is shared between all components of the environment. Its contents are discarded on server shutdown or when the init code gets re-run. Every data type is allowed, even functions.
The purpose of this table is not to save data, but to provide static value and function definitions. The table should be populated by the init code.

# Standard Lua functions
The following standard Lua libraries are available:
string, math, table, os
The following standard Lua functions are available:
assert, error, ipairs, pairs, next, select, tonumber, tostring, type, unpack

Every attempt to overwrite any of the predefined values results in an error.

# LuaAutomation-specific global functions

POS(x,y,z)
Shorthand function to create a position vector {x=?, y=?, z=?} with less characters

In the following functions, all parameters named 'pos' designate a position. You can use either:
- a default Minetest position vector (like {x=34, y=2, z=-18})
- the POS(34,2,-18) shorthand
- A string, the passive component name. See 'passive component naming'.

getstate(pos)
Get the state of the passive component at position 'pos'. See section on passive components for more info.
pos can be either a position vector (created by POS()) or a string, the name of this passive component.

setstate(pos, newstate)
Set the state of the passive component at position 'pos'.

is_passive(pos)
Checks whether there is a passive component at the position pos (and/or whether a passive component with this name exists)

interrupt(time, message)
Cause LuaAutomation to trigger an 'int' event on this component after the given time in seconds with the specified 'message' field. 'message' can be of any Lua data type.
Not available in init code!

interrupt_pos(pos, message)
Immediately trigger an 'ext_int' event on the active component at position pos. 'message' is like in interrupt().
USE WITH CARE, or better don't use! Incorrect use can result in expotential growth of interrupts.

digiline_send(channel, message)
Make this active component send a digiline message on the specified channel.
Not available in init code!

-- The next 4 functions are available when advtrains_interlocking is enabled: --

can_set_route(pos, route_name)
Returns whether it is possible to set the route designated by route_name from the signal at pos.

set_route(pos, route_name)
Requests the given route from the signal at pos. Has the same effect as clicking "Set Route" in the signalling dialog.

cancel_route(pos)
Cancels the route that is set from the signal at pos. Has the same effect as clicking "Cancel Route" in the signalling dialog.

get_aspect(pos)
Returns the signal aspect of the signal at pos. A signal aspect has the following format:
aspect = {
	main = { -- the next track section in line. Shows blocked for shunt routes
		free = <boolean>,
		speed = <int km/h>,
	},
	shunt = { -- whether a "shunting allowed" aspect should be shown
		free = <boolean>,
	}
	dst = { -- the aspect of the next main signal on (at end of) route
		free = <boolean>,
		speed = <int km/h>,
	}
	info = {
		call_on = <boolean>, -- Call-on route, expect train in track ahead
		dead_end = <boolean>, -- Route ends on a dead end (e.g. bumper)
	}
}
As of August 2018, only the aspect.main.free field is ever used by the interlocking system.

# Lines

The advtrains_line_automation component adds a few contraptions that should make creating timeable systems easier.
Part of its functionality is also available in LuaATC:

- rwt.* - all Railway Time functions are included as documented in https://advtrains.de/wiki/doku.php?id=dev:lines:rwt

- schedule(rw_time, msg)
- schedule_in(rw_dtime, msg)
Schedules an event of type {type="schedule", schedule=true, msg=msg} at (resp. after) the specified railway time.
(which can be in any format). You can only schedule one event this way. (uses the new lines-internal scheduler)

## Components and events

The event table is a table of the following format:
{
	type = "<type>",
	<type> = true,
	... additional content ...
}
You can check for the event type by either using
if event.type == "wanted" then ...do stuff... end
or
if event.wanted then ...do stuff... end
(if 'wanted' is the event type to check for)

# Init code
The initialization code is not a component as such, but rather a part of the whole environment. It can (and should) be used to make definitions that other components can refer to.
Examples:
A function to define behavior for trains in subway stations:
function F.station()
	if event.train then atc_send("B0WOL") end
	if event.int and event.message="depart" then atc_send("OCD1SM") end
end

The init code is run whenever the F table needs to be refilled with data. This is the case on server startup and whenever the init code is changed and you choose to run it.
Functions are run in the environment of the currently active node, regardless of where they were defined. So, the 'event' table always reflects the state of the calling node.

The 'event' table of the init code is always {type="init", init=true}.

# ATC rails
The Lua-controlled ATC rails are the only components that can actually interface with trains. The following event types are generated:

{type="train", train=true, id="<train_id>"}
This event is fired when a train enters the rail. The field 'id' is the unique train ID, which is 6-digit random numerical string.
If the world contains trains from an older advtrains version, this string may be longer and contain a dot (.)

{type="int", int=true, msg=<message>}
Fired when an interrupt set by the 'interrupt' function runs out. 'message' is the message passed to the interrupt function.
For backwards compatiblity reasons, <message> is also contained in an event.message field.
{type="ext_int", ext_int=true, message=<message>}
Fired when another node called 'interrupt_pos' on this position. 'message' is the message passed to the interrupt_pos function.

{type="digiline", digiline=true, channel=<channel>, msg=<message>}
Fired when the controller receives a digiline message.

In addition to the default environment functions, the following functions are available:

atc_send(<atc_command>)
	Sends the specified ATC command to the train and returns true. If there is no train, returns false and does nothing.
atc_reset()
	Resets the train's current ATC command. If there is no train, returns false and does nothing.
atc_arrow
	Boolean, true when the train is driving in the direction of the arrows of the ATC rail. Nil if there is no train.
atc_id
	Train ID of the train currently passing the controller. Nil if there's no train.
atc_speed
	Speed of the train, or nil if there is no train.
atc_set_text_outside(text)
	Set text shown on the outside of the train. Pass nil to show no text.
atc_set_text_inside(text)
	Set text shown to train passengers. Pass nil to show no text.
get_line()
	Returns the "Line" property of the train (a string).
	This can be used to distinguish between trains of different lines and route them appropriately.
	The interlocking system also uses this property for Automatic Routesetting.
set_line(line)
	Sets the "Line" property of the train (a string).
	If the first digit of this string is a number (0-9), any subway wagons on the train will have this one displayed as line number
	(where "0" is actually shown as Line 10 on the train)
get_rc()
	Returns the "Routingcode" property of the train (a string).
	The interlocking system uses this property for Automatic Routesetting.
set_rc(routingcode)
	Sets the "Routingcode" property of the train (a string).
	The interlocking system uses this property for Automatic Routesetting.
split_at_index(index, command)
	Splits the train at the specified index, into a train with index-1 wagons and a second train starting with the index-th wagon.
	command specifies an atc command to be sent to the second train after decoupling. 
set_autocouple()
	Sets the train into autocouple mode 
unset_autocouple()
	Unsets autocouple mode
set_shunt(), unset_shunt()
	deprecated aliases for set_autocouple() and unset_autocouple(), will be removed from a later release.

# Operator panel
This simple node executes its actions when punched. It can be used to change a switch and update the corresponding signals or similar applications.

The event fired is {type="punch", punch=true} by default. In case of an interrupt or a digiline message, the events are similar to the ones of the ATC rail.

### Passive components

All passive components can be interfaced with the setstate and getstate functions(see above).
Below, each apperance is mapped to the "state" of that node.

## Signals
The light signals are interfaceable, the analog signals are not.
"green" - Signal shows green light
"red" - Signal shows red light

## Switches
All default rail switches are interfaceable, independent of orientation.
"cr" - The switch is set in the direction that is not straight.
"st" - The switch is set in the direction that is straight.

## Mesecon Switch
The Mesecon switch can be switched using LuaAutomation. Note that this is not possible on levers, only the full-node 'Switch' block.
"on" - the switch is switched on
"off" - the switch is switched off

##Andrew's Cross
"on" - it blinks
"off" - it does not blink

### Passive component naming
You can assign names to passive components using the Passive Component Naming tool.
Once you set a name for any component, you can reference it by that name in the getstate() and setstate() functions, like this:
(Imagine a signal that you have named "Stn_P1_out" at position (1,2,3) )
setstate("Stn_P1_out", "green") instead of setstate(POS(1,2,3), "green")
This way, you don't need to memorize positions.

PC-Naming can also be used to name interlocking signals for route setting via the set_route() functions. IMPORTANT: The "Signal Name" set in the
signalling formspec is completely independent and can NOT be used to look up the position, you need to explicitly use the PCNaming tool.

--TODO: Ein paar mehr Codebeispiele wären schön, insbesondere mit os.date und so...
