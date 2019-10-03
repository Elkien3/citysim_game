local function fl(x)
	if x < 0 then
		return math.ceil(x) + 0 -- make -0 go away
	else
		return math.floor(x)
	end
end

local function cmod(a, b)
	local x = a % b
	if a < 0 and x > 0 then
		x = x - b
	end
	return x
end


local radix = 2^24 -- maybe up to 2^26 is safe?
local radix_sqrt = fl(math.sqrt(radix))

local bigintmt -- forward decl

local function alloc()
	local bi = {}
	setmetatable(bi, bigintmt)
	bi.comps = {}
	bi.sign = 1;
	return bi
end

local function clone(a)
	local bi = alloc()
	bi.sign = a.sign
	local c = bi.comps
	local ac = a.comps
	for i = 1, #ac do
		c[i] = ac[i]
	end
	return bi
end

local function normalize(bi, notrunc)
	local c = bi.comps
	local v
	-- borrow for negative components
	for i = 1, #c - 1 do
		v = c[i]
		if v < 0 then
			c[i+1] = c[i+1] + fl(v / radix) - 1
			v = cmod(v, radix)
			if v ~= 0 then
				c[i] = v + radix
			else
				c[i] = v
				c[i+1] = c[i+1] + 1
			end
		end
	end
	-- is top component negative?
	if c[#c] < 0 then
		-- switch the sign and fix components
		bi.sign = -bi.sign
		for i = 1, #c - 1 do
			v = c[i]
			c[i] = radix - v
			c[i+1] = c[i+1] + 1
		end
		c[#c] = -c[#c]
	end
	-- carry for components larger than radix
	for i = 1, #c do
		v = c[i]
		if v > radix then
			c[i+1] = (c[i+1] or 0) + fl(v / radix)
			c[i] = cmod(v, radix)
		end
	end
	-- trim off leading zeros
	if not notrunc then
		for i = #c, 2, -1 do
			if c[i] == 0 then
				c[i] = nil
			else
				break
			end
		end
	end
	-- check for -0
	if #c == 1 and c[1] == 0 and bi.sign == -1 then
		bi.sign = 1
	end
end

local function negate(a)
	local bi = clone(a)
	bi.sign = -bi.sign
	return bi
end

local function compare(a, b)
	local ac, bc = a.comps, b.comps
	local as, bs = a.sign, b.sign
	if ac == bc then
		return 0
	elseif as > bs then
		return 1
	elseif as < bs then
		return -1
	elseif #ac > #bc then
		return as
	elseif #ac < #bc then
		return -as
	end
	for i = #ac, 1, -1 do
		if ac[i] > bc[i] then
			return as
		elseif ac[i] < bc[i] then
			return -as
		end
	end
	return 0
end

local function lt(a, b)
	return compare(a, b) < 0
end

local function eq(a, b)
	return compare(a, b) == 0
end

local function le(a, b)
	return compare(a, b) <= 0
end

local function addint(a, n)
	local bi = clone(a)
	if bi.sign == 1 then
		bi.comps[1] = bi.comps[1] + n
	else
		bi.comps[1] = bi.comps[1] - n
	end
	normalize(bi)
	return bi
end

local function add(a, b)
	if type(a) == "number" then
		return addint(b, a)
	elseif type(b) == "number" then
		return addint(a, b)
	end
	local bi = clone(a)
	local sign = bi.sign == b.sign
	local c = bi.comps
	for i = #c + 1, #b.comps do
		c[i] = 0
	end
	local bc = b.comps
	for i = 1, #bc do
		local v = bc[i]
		if sign then
			c[i] = c[i] + v
		else
			c[i] = c[i] - v
		end
	end
	normalize(bi)
	return bi
end

local function sub(a, b)
	if type(b) == "number" then
		return addint(a, -b)
	elseif type(a) == "number" then
		a = bigint(a)
	end
	return add(a, negate(b))
end

local function mulint(a, b)
	local bi = clone(a)
	if b < 0 then
		b = -b
		bi.sign = -bi.sign
	end
	local bc = bi.comps
	for i = 1, #bc do
		bc[i] = bc[i] * b
	end
	normalize(bi)
	return bi
end

local function multiply(a, b)
	local bi = alloc()
	local c = bi.comps
	local ac, bc = a.comps, b.comps
	for i = 1, #ac + #bc do
		c[i] = 0
	end
	for i = 1, #ac do
		for j = 1, #bc do
			c[i+j-1] = c[i+j-1] + ac[i] * bc[j]
		end
		-- keep the zeroes
		normalize(bi, true)
	end
	normalize(bi)
	if bi ~= bigint(0) then
		bi.sign = a.sign * b.sign
	end
	return bi
end

local function kmul(a, b)
	local ac, bc = a.comps, b.comps
	local an, bn = #a.comps, #b.comps
	local bi, bj, bk, bl = alloc(), alloc(), alloc(), alloc()
	local ic, jc, kc, lc = bi.comps, bj.comps, bk.comps, bl.comps

	local n = fl((math.max(an, bn) + 1) / 2)
	for i = 1, n do
		ic[i] = (i + n <= an) and ac[i+n] or 0
		jc[i] = (i <= an) and ac[i] or 0
		kc[i] = (i + n <= bn) and bc[i+n] or 0
		lc[i] = (i <= bn) and bc[i] or 0
	end
	normalize(bi)
	normalize(bj)
	normalize(bk)
	normalize(bl)
	local ik = bi * bk
	local jl = bj * bl
	local mid = (bi + bj) * (bk + bl) - ik - jl
	local mc = mid.comps
	local ikc = ik.comps
	local jlc = jl.comps
	for i = 1, #ikc + n*2 do -- fill it up
		jlc[i] = jlc[i] or 0
	end
	for i = 1, #mc do
		jlc[i+n] = jlc[i+n] + mc[i]
	end
	for i = 1, #ikc do
		jlc[i+n*2] = jlc[i+n*2] + ikc[i]
	end
	jl.sign = a.sign * b.sign
	normalize(jl)
	return jl
end

local kthresh = 12

local function mul(a, b)
	if type(a) == "number" then
		return mulint(b, a)
	elseif type(b) == "number" then
		return mulint(a, b)
	end
	if #a.comps < kthresh or #b.comps < kthresh then
		return multiply(a, b)
	end
	return kmul(a, b)
end

local function divint(numer, denom)
	local bi = clone(numer)
	if denom < 0 then
		denom = -denom
		bi.sign = -bi.sign
	end
	local r = 0
	local c = bi.comps
	for i = #c, 1, -1 do
		r = r * radix + c[i]
		c[i] = fl(r / denom)
		r = cmod(r, denom)
	end
	normalize(bi)
	return bi
end

local function multi_divide(numer, denom)
	local n = #denom.comps
	local approx = divint(numer, denom.comps[n])
	for i = n, #approx.comps do
		approx.comps[i - n + 1] = approx.comps[i]
	end
	for i = #approx.comps, #approx.comps - n + 2, -1 do
		approx.comps[i] = nil
	end
	local rem = approx * denom - numer
	if rem < denom then
		quotient = approx
	else
		quotient = approx - multi_divide(rem, denom)
	end
	return quotient
end

local function multi_divide_wrap(numer, denom)
	-- we use a successive approximation method, but it doesn't work
	-- if the high order component is too small.  adjust if needed.
	if denom.comps[#denom.comps] < radix_sqrt then
		numer = mulint(numer, radix_sqrt)
		denom = mulint(denom, radix_sqrt)
	end
	return multi_divide(numer, denom)
end

local function div(numer, denom)
	if type(denom) == "number" then
		if denom == 0 then
			error("divide by 0", 2)
		end
		return divint(numer, denom)
	elseif type(numer) == "number" then
		numer = bigint(numer)
	end
	-- check signs and trivial cases
	local sign = 1
	local cmp = compare(denom, bigint(0))
	if cmp == 0 then
		error("divide by 0", 2)
	elseif cmp == -1 then
		sign = -sign
		denom = negate(denom)
	end
	cmp = compare(numer, bigint(0))
	if cmp == 0 then
		return bigint(0)
	elseif cmp == -1 then
		sign = -sign
		numer = negate(numer)
	end
	cmp = compare(numer, denom)
	if cmp == -1 then
		return bigint(0)
	elseif cmp == 0 then
		return bigint(sign)
	end
	local bi
	-- if small enough, do it the easy way
	if #denom.comps == 1 then
		bi = divint(numer, denom.comps[1])
	else
		bi = multi_divide_wrap(numer, denom)
	end
	if sign == -1 then
		bi = negate(bi)
	end
	return bi
end

local counter = 0

local function activityDot()
	counter = counter + 1

	if counter >= 1000 then
		counter = 0
		write(".")
		sleep(0.01)
	end
end

local function intrem(bi, m)
	if m < 0 then
		m = -m
	end
	local rad_r = 1
	local r = 0
	local bc = bi.comps
	for i = 1, #bc do
		activityDot()
		local v = bc[i]
		r = cmod(r + v * rad_r, m)
		rad_r = cmod(rad_r * radix, m)
	end
	if bi.sign < 1 then
		r = -r
	end
	return r
end

local function intmod(bi, m)
	local r = intrem(bi, m)
	if r < 0 then
		r = r + m
	end
	return r
end

local function rem(bi, m)
	if type(m) == "number" then
		return bigint(intrem(bi, m))
	elseif type(bi) == "number" then
		bi = bigint(bi)
	end

	return bi - ((bi / m) * m)
end

local function mod(a, m)
	local bi = rem(a, m)
	if bi.sign == -1 then
		bi = bi + m
	end
	return bi
end

local printscale = 10000000
local printscalefmt = string.format("%%.%dd", math.log10(printscale))
local function makestr(bi, s)
	if bi >= bigint(printscale) then
		makestr(divint(bi, printscale), s)
	end
	table.insert(s, string.format(printscalefmt, intmod(bi, printscale)))
end

local function biginttostring(bi)
	local s = {}
	if bi < bigint(0) then
		bi = negate(bi)
		table.insert(s, "-")
	end
	makestr(bi, s)
	s = table.concat(s):gsub("^0*", "")
	if s == "" then s = "0" end
	return s
end

local function biginttonumber(bi)
	return tonumber(biginttostring(bi))
end

bigintmt = {
	__add = add,
	__sub = sub,
	__mul = mul,
	__div = div,
	__mod = mod,
	__unm = negate,
	__eq = eq,
	__lt = lt,
	__le = le,
	__tostring = biginttostring,
}

local cache = {}
local ncache = 0

function bigint(n)
	if cache[n] then
		return cache[n]
	end
	local bi
	if type(n) == "string" then
		local digits = { n:byte(1, -1) }
		for i = 1, #digits do
			digits[i] = string.char(digits[i])
		end
		local start = 1
		local sign = 1
		if digits[i] == '-' then
			sign = -1
			start = 2
		end
		bi = bigint(0)
		for i = start, #digits do
			bi = addint(mulint(bi, 10), tonumber(digits[i]))
		end
		bi = mulint(bi, sign)
	else
		bi = alloc()
		bi.comps[1] = n
		normalize(bi)
	end
	if ncache > 100 then
		cache = {}
		ncache = 0
	end
	cache[n] = bi
	ncache = ncache + 1
	return bi
end

--
-- Start of my code
--

local bigZero = bigint(0)
local bigOne = bigint(1)

local function gcd(a, b)
	if b ~= bigZero then
		return gcd(b, a % b)
	else
		return a
	end
end

local function modexp(base, exponent, modulus)
	local r = 1

	while true do
		if exponent % 2 == bigOne then
			r = r * base % modulus
		end
		exponent = exponent / 2

		if exponent == bigZero then
			break
		end
		base = base * base % modulus
	end

	return r
end

local function bigRandomWithLength(length, cap)
	if not cap then
		cap = 999999999
	end

	local randomString = tostring(math.random(100000000, cap))

	while true do
		randomString = randomString ..
			tostring(math.random(100000000, cap))
		if #randomString >= length then
			local finalRandom = randomString:sub(1, length)
			if finalRandom:sub(-1, -1) == "2" then
				return bigint(finalRandom:sub(1, -2) .. "3")
			elseif finalRandom:sub(-1, -1) == "4" then
				return bigint(finalRandom:sub(1, -2) .. "5")
			elseif finalRandom:sub(-1, -1) == "6" then
				return bigint(finalRandom:sub(1, -2) .. "7")
			elseif finalRandom:sub(-1, -1) == "8" then
				return bigint(finalRandom:sub(1, -2) .. "9")
			elseif finalRandom:sub(-1, -1) == "0" then
				return bigint(finalRandom:sub(1, -2) .. "1")
			else
				return bigint(finalRandom)
			end
		end
	end
end

local function bigRandom(minNum, maxNum)
	if maxNum < bigint(1000000000) then
		return bigint(math.random(biginttonumber(minNum),
			biginttonumber(maxNum)))
	end

	local maxString = tostring(maxNum)
	local cap = tonumber(tostring(maxNum):sub(1, 9))
	local range = #maxString - #tostring(minNum)

	if range == 0 then
		return bigRandomWithLength(#maxString, cap)
	end

	if #maxString > 30 then
		return bigRandomWithLength(#maxString - 1)
	end

	local randomLength = math.random(1, 2^(#maxString - 1))
	for i = 1, #maxString - 1 do
		if randomLength <= (2^i) then
			return bigRandomWithLength(i)
		end
	end
end

local function isPrime(n)
	if type(n) == "number" then
		n = bigint(n)
	end

	if n % 2 == bigZero then
		return false
	end

	local s, d = 0, n - bigOne
	while d % 2 == bigZero do
		s, d = s + 1, d / 2
	end

	for i = 1, 3 do
		local a = bigRandom(bigint(2), n - 2)
		local x = modexp(a, d, n)
		if x ~= bigOne and x + 1 ~= n then
			for j = 1, s do
				x = modexp(x, bigint(2), n)
				if x == bigOne then
					return false
				elseif x == n - 1 then
					a = bigZero
					break
				end
			end
			if a ~= bigZero then
				return false
			end
		end
	end

	return true
end

local function generateLargePrime()
	local i = 0
	while true do
		local randomNumber = bigRandomWithLength(39)

		if isPrime(randomNumber) then
			return randomNumber
		end
	end
end

local function generatePQ(e)
	local randomPrime
	while true do
		randomPrime = generateLargePrime()
		if gcd(e, randomPrime - 1) == bigOne then
			return randomPrime
		end
	end
end

local function euclidean(a, b)
	local x, y, u, v = bigZero, bigOne, bigOne, bigZero
	while a ~= bigZero do
		local q, r = b / a, b % a
		local m, n = x - u * q, y - v * q
		b, a, x, y, u, v = a, r, u, v, m, n
	end
	return b, x, y
end

local function modinv(a, m)
	local gcdnum, x, y = euclidean(a, m)
	if gcdnum ~= bigOne then
		return nil
	else
		return x % m
	end
end

local function generateKeyPair()
	while true do
		local e = generateLargePrime()
		write("-")
		sleep(0.1)
		local p = generatePQ(e)
		write("-")
		sleep(0.1)
		local q = generatePQ(e)
		write("-")
		sleep(0.1)

		local n = p * q
		local phi = (p - 1) * (q - 1)
		local d = modinv(e, phi)

		-- 104328 is just a magic number (can be any semi-unique number)
		local encrypted = modexp(bigint(104328), e, n)
		local decrypted = modexp(encrypted, d, n)

		write("+")
		sleep(0.1)
		counter = 0

		if decrypted == bigint(104328) then
			counter = 0
			return {
				shared = tostring(n),
				public = tostring(e),
			}, {
				shared = tostring(n),
				private = tostring(d),
			}
		end
	end
end

minetest.register_node("digistuff:rsa", {
	description = "Digilines RSA generator",
	groups = {cracky=3},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec","field[channel;Channel;${channel}")
	end,
	tiles = {
		"digistuff_nic_top.png",
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
	},
	inventory_image = "digistuff_nic_top.png",
	drawtype = "nodebox",
	selection_box = {
		--From luacontroller
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -5/16, 8/16 },
	},
	node_box = {
		--From Luacontroller
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}, -- Bottom slab
			{-5/16, -7/16, -5/16, 5/16, -6/16, 5/16}, -- Circuit board
			{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16}, -- IC
		}
	},
	paramtype = "light",
	sunlight_propagates = true,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if minetest.is_protected(pos,name) and not minetest.check_player_privs(name,{protection_bypass=true}) then
			minetest.record_protection_violation(pos,name)
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.channel then meta:set_string("channel",fields.channel) end
	end,
	digiline = 
	{
		receptor = {},
		effector = {
			action = function(pos,node,channel,msg)
					local meta = minetest.get_meta(pos)
					if meta:get_string("channel") ~= channel then return end
					if type(msg) ~= str then return end
          if msg ~= "generate" then return end
					local publicKey, privateKey = generateKeyPair()
							digiline:receptor_send(pos, digiline.rules.default, channel, (publicKey, privateKey)
						end)
				end
		},
	},
})
minetest.register_craft({
	output = "digistuff:rsa",
	recipe = {
		{"","default:mese",""},
		{"digilines:wire_std_00000000","mesecons_luacontroller:luacontroller0000","mesecons:wire_00000000_off"}
	}
})
