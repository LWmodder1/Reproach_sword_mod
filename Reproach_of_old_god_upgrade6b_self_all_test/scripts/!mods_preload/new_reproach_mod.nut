::mods_registerMod("mod_Reproach_sword_upgrade", 1.0, "Reproach of old gods upgrade");
::mods_queue("mod_Reproach_sword_upgrade", null, function()
{
	::mods_hookNewObject("items/weapons/legendary/lightbringer_sword", function(o)
	{
		o.m.Condition = 135.0;
		o.m.ConditionMax = 135.0;

		o.onEquip = function()
		{
		this.weapon.onEquip();
		this.addSkill(this.new("scripts/skills/actives/slash_lightning"));
		this.addSkill(this.new("scripts/skills/actives/parry_lightning"));
		this.addSkill(this.new("scripts/skills/actives/chain_lightning"));
		this.addSkill(this.new("scripts/skills/actives/lunge_lightning"));
		}
	})

})
	


