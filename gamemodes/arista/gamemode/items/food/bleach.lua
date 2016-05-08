
ITEM.name					= "Bleach"
ITEM.size					= 1
ITEM.cost					= 5
ITEM.model				= "models/props_junk/garbage_plasticbottle001a.mdl"
ITEM.batch				= 5
ITEM.store				= true
ITEM.plural				= "Bottles of Bleach"
ITEM.description	= "Household cleaning product that certainly is not for drinking. Keep out of reach of children."
ITEM.equippable		= true
ITEM.equipword		= "drink bleach"
ITEM.base					= "item"

function ITEM:onUse(player)
	player:ChatPrint("chugs a whole bottle of bleach and falls to the ground.")
	player:Kill()
end
