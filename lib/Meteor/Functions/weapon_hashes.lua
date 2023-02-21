local weapon_hashes = {}

weapon_hashes.all_weapon_hashes = {
}

temp_weapons = util.get_weapons()
-- create a table with just weapon hashes, labels
for a,b in pairs(temp_weapons) do
    weapon_hashes.all_weapon_hashes[#weapon_hashes.all_weapon_hashes + 1] = {hash = b['hash'], label_key = b['label_key']}
end

return weapon_hashes