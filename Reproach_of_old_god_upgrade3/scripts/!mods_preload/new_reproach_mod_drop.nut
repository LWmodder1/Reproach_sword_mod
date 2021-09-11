::mods_registerMod("mod_Reproach_sword_upgrade", 1.0, "Reproach of old gods upgrade");
::mods_queue("mod_Reproach_sword_upgrade", null, function()
{
    ::mods_hookExactClass("entity/tactical/enemies/ghost_knight", function(obj)
    {
        local onDeath = ::mods_getMember(obj, "onDeath");
        obj.onDeath = function( _killer, _skill, _tile, _fatalityType )
        {
            this.m.Items.unequip(this.m.Items.getItemAtSlot(this.Const.ItemSlot.Mainhand));

            if (_tile != null)
            {
                local loot = this.new('items/weapons/legendary/lightbringer_sword2.nut');
                loot.drop(_tile);
            }

            onDeath(_killer, _skill, _tile, _fatalityType);
        }
    });
})
	
