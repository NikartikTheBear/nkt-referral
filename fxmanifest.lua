fx_version "cerulean"
game "gta5"
lua54 "yes"

author "nikartik"
version "1.0.0"

shared_scripts {"@ox_lib/init.lua"}
client_scripts {"client/**.*"}
server_scripts {"@oxmysql/lib/MySQL.lua", "server/**.*"}
