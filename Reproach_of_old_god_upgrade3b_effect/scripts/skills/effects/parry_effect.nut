this.parry_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "effects.parry";
		this.m.Name = "Parry";
		this.m.Description = "This character is prepared to immediately counter-attack on any failed attempt to attack him in melee with enhanced defensive posture. A character under the parry condition receives a bonus to ranged and melee defense based on the melee attack and the number of adjacent surrounding enemies.";
		this.m.Icon = "skills/status_effect_33.png";
		this.m.IconMini = "status_effect_33_mini";
		this.m.Overlay = "status_effect_33";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsRemovedAfterBattle = true;
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
			bonus = 5;
		}

		if (adjacentEnemies == 5)
		{
			bonus = 8;
		}

		if (adjacentEnemies == 4)
		{
			bonus = 11;
		}

		if (adjacentEnemies == 3)
		{
			bonus = 13;
		}

		if (adjacentEnemies == 2)
		{
			bonus = 14;
		}

		if (adjacentEnemies == 1)
		{
			bonus = 15;
		}

		if (adjacentEnemies == 0)
		{
			bonus = 15;
		}

		return this.Math.round(0.01 * bonus * actor.getCurrentProperties().getMeleeSkill());
	}

	function onUpdate( _properties )
	{
		_properties.IsRiposting = true;		
		_properties.MeleeDefense += this.getDefenseBonus(_properties);
		_properties.RangedDefense += this.getDefenseBonus(_properties);
	}

	function getTooltip()
	{
		local bonus = this.getContainer().getActor().getCurrentProperties();
		return [
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
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.getDefenseBonus(bonus) + "[/color] Melee Defense"
			},
			{
				id = 4,
				type = "text",
				icon = "ui/icons/ranged_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.getDefenseBonus(bonus) + "[/color] Ranged Defense"
			}
		];
	}

	function onTurnStart()
	{
		this.removeSelf();
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (this.Tactical.TurnSequenceBar.getActiveEntity() == null || this.Tactical.TurnSequenceBar.getActiveEntity().getID() != this.getContainer().getActor().getID())
		{
			if (!this.getContainer().getActor().getCurrentProperties().IsSpecializedInSwords)
			{
				_properties.MeleeSkill -= 5;
			}
		}
	}

});

