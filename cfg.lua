aph = {}
cfg = {}
cfg.framework = 'qb' --esx, qb, custom(If you choose custom, you need to edit the client and server files according to your framework.)
cfg.sqlwrapper = 'oxmysql' --ghmattimysql, mysql-async, oxmysql

cfg.discordLogColors = {
    ['default'] = 16711680,
    ['blue'] = 25087,
    ['green'] = 762640,
    ['white'] = 16777215,
    ['black'] = 0,
    ['orange'] = 16743168,
    ['lightgreen'] = 65309,
    ['yellow'] = 15335168,
    ['pink'] = 16711900,
    ['red'] = 16711680,
    ['cyan'] = 65535,
}

aph.shared = {}
aph.shared.functions = {}

dt = function(table, nb)
    if nb == nil then
		nb = 0
	end

    if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s.."    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s.."    "
			end
			s = s..'['..k..'] = '..dt(v, nb + 1)..',\n'
		end

		for i = 1, nb, 1 do
			s = s.."    "
		end

		return s..'}'
	else
		return tostring(table)
    end
end

aph.shared.functions.dt = function(table, nb)
    -- print(json.encode(table, {indent=true}))
    print(dt(table, nb))
end