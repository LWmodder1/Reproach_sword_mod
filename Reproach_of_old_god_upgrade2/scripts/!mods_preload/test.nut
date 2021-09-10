::mods_hookNewObject("items/weapons/legendary/lightbringer_sword", function(newsword)
{
    newsword.m.ID = "weapon.lightbringer_sword2"
	newsword.m.StaminaModifier = -6;
	newsword.m.RegularDamage = 59;
	newsword.m.RegularDamageMax = 65;
	newsword.m.DirectDamageMult = 0.36;

    newsword.onEquip = function()
    {
    this.weapon.onEquip();
    this.addSkill(this.new("scripts/skills/actives/slash_lightning2"));
    this.addSkill(this.new("scripts/skills/actives/riposte2"));
    }
})