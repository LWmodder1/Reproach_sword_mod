this.parry <- this.inherit("scripts/skills/skill", {
	m = {
		IsSpent = false,
		IsForceEnabled = false,
		DefenseBonus = 0
	},
	function create()
	{
		this.m.ID = "actives.parry";
		this.m.Name = "Parry";
		this.m.Description = "Prepare to immediately counter-attack any opponent that attempts to attack in melee and misses with enhanced defensive posture. A character under the parry condition receives bonus in melee defense that is proportinal to melee attack. The amount ";
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
			return 5;
		}

        else if (adjacentEnemies == 5)
		{
		    return 6
		}

		else if (adjacentEnemies == 4)
		{
			bonus = 8;
		}
		
		else if (adjacentEnemies == 3)
		{
			bonus = 11;
		}

		else if (adjacentEnemies == 2)
		{
			bonus = 15;
		}
		
		else if (adjacentEnemies == 1)
		{
			bonus = 20;
		}

		
		return this.Math.round(0.01 * bonus * actor.getCurrentProperties().getMeleeSkill());
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
		];

		if (!this.getContainer().getActor().getCurrentProperties().IsSpecializedInSwords)
		{
			ret.push({
				id = 4,
				type = "text",
				icon = "ui/icons/hitchance.png",
				text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-10%[/color] chance to hit"
			}
			{
				id = 5,
				type = "text",
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.m.DefenseBonus + "[/color] Melee Defense"
			}
			);
		}

		return ret;
	}

	function isEnabled()
	{
		if (this.m.IsForceEnabled)
		{
			return true;
		}
		
		// local items = this.getContainer().getActor().getItems();
		// local off = items.getItemAtSlot(this.Const.ItemSlot.Offhand);
        // 
		// if (off == null && !items.hasBlockedSlot(this.Const.ItemSlot.Offhand) || off != null && off.isItemType(this.Const.Items.ItemType.Tool))
		// {
		//	   return true;
		// }
		//
		// return false;
	}	

	function isUsable()
	{
		return !this.m.IsSpent && this.skill.isUsable();
	}

	function onAfterUpdate( _properties )
	{
		this.m.FatigueCostMult = _properties.IsSpecializedInSwords ? this.Const.Combat.WeaponSpecFatigueMult : 1.0;
		
		this.m.DefenseBonus = 0;
		
		if (this.isEnabled())
		{
			this.m.DefenseBonus = this.getDefenseBonus(_properties);
			_properties.MeleeDefense += this.m.DefenseBonus;
		}
	}
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		return true;
	}

	function onUse( _user, _targetTile )
	{
		if (!this.m.IsSpent)
		{
			this.m.Container.add(this.new("scripts/skills/effects/riposte_effect"));
			this.m.IsSpent = true;

			if (!_user.isHiddenToPlayer())
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " uses Riposte");
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
		this.m.Container.removeByID("effects.riposte");
	}

});

