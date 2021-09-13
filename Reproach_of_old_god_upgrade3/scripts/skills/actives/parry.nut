this.parry <- this.inherit("scripts/skills/skill", {
	m = {
		IsSpent = false,
		DefenseBonus = 0
	},
	function create()
	{
		this.m.ID = "actives.parry";
		this.m.Name = "Parry";
		this.m.Description = "Prepare to immediately counter-attack any opponent that attempts to attack in melee and misses with enhanced defensive posture. A character under the parry condition receives a ranged and melee defense bonus based on the melee attack and the number of adjacent surrounding enemies. ";
		this.m.Icon = "skills/active_33.png";
		this.m.IconDisabled = "skills/active_33_sw.png";
		this.m.Overlay = "active_33";
		this.m.SoundOnUse = [
			"sounds/combat/riposte_01.wav",
			"sounds/combat/riposte_02.wav",
			"sounds/combat/riposte_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsWeaponSkill = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 25;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}
	
	function getDefenseBonus(_properties)
	{		
		local actor = this.getContainer().getActor();

		if (actor == null || !actor.isPlacedOnMap())
		{
			return 0;
		}

		local myTile = actor.getTile();
		local alliedFactions = actor.getAlliedFactions();
		local adjacentEnemies = 0;

		if (myTile == null)
		{
			return 0;
		}

		if (!("Entities" in this.Tactical))
		{
			return 0;
		}

		if (this.Tactical.Entities == null)
		{
			return 0;
		}

		if (this.Tactical.State.isAutoRetreat())
		{
			return 0;
		}

		if (!this.Tactical.isActive())
		{
			return 0;
		}

		local actors = this.Tactical.Entities.getAllInstancesAsArray();		
		local bonus = 0;

		foreach( a in actors )
		{
			if (a == null)
			{
				continue;
			}

			if (!a.isPlacedOnMap())
			{
				continue;
			}
			
			if (a.isAlliedWith(actor))
			{
				continue;
			}

			if (a.getTile() == null)
			{
				continue;
			}

			if (a.getTile().getDistanceTo(myTile) != 1)
			{
				continue;
			}

			adjacentEnemies += 1;
		}
		
		if (adjacentEnemies == 6)
		{
			bonus = 6;
		}

        else if (adjacentEnemies == 5)
		{
		    bonus = 9;
		}

		else if (adjacentEnemies == 4)
		{
			bonus = 11;
		}
		
		else if (adjacentEnemies == 3)
		{
			bonus = 13;
		}

		else if (adjacentEnemies == 2)
		{
			bonus = 14;
		}
		
		else if (adjacentEnemies == 1)
		{
			bonus = 15;
		}
		
		return this.Math.round(0.01 * bonus * actor.getCurrentProperties().getMeleeSkill());
	}

	function isUsable()
	{
		return !this.m.IsSpent && this.skill.isUsable();
	}

	function onAfterUpdate( _properties )
	{
		this.m.FatigueCostMult = _properties.IsSpecializedInSwords ? this.Const.Combat.WeaponSpecFatigueMult : 1.0;
		this.m.DefenseBonus = 0;
		if (this.m.IsSpent)
		{
			this.m.DefenseBonus = this.getDefenseBonus(_properties);
			_properties.MeleeDefense += this.m.DefenseBonus;
			_properties.RangedDefense += this.m.DefenseBonus;
		}
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 3,
				type = "text",
				text = this.getCostString()
			}
			{
				id = 4,
				type = "text",
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.m.DefenseBonus + "[/color] Melee Defense"
			}
		];

		if (!this.getContainer().getActor().getCurrentProperties().IsSpecializedInSwords)
		{
			ret.push({
				id = 5,
				type = "text",
				icon = "ui/icons/hitchance.png",
				text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-5%[/color] chance to hit"
			});
		}

		return ret;
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		return true;
	}

	function onUse( _user, _targetTile )
	{
		if (!this.m.IsSpent)
		{
			this.m.Container.add(this.new("scripts/skills/effects/parry_effect"));
			this.m.IsSpent = true;

			if (!_user.isHiddenToPlayer())
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " uses Parry");
			}

			return true;
		}

		return false;
	}

	function onTurnStart()
	{
		this.m.IsSpent = false;
	}

	function onRemoved()
	{
		this.m.Container.removeByID("effects.parry");
	}

});

