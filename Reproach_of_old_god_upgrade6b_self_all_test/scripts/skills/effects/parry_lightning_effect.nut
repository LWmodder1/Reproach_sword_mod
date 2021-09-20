this.parry_lightning_effect <- this.inherit("scripts/skills/skill", {
	m = {
		SoundOnLightning = [
		"sounds/combat/dlc2/legendary_lightning_01.wav",
		"sounds/combat/dlc2/legendary_lightning_02.wav"	
		]
	},
	function create()
	{
		this.m.ID = "effects.parry_lightning";
		this.m.Name = "Lightning Parry";
		this.m.Description = "This character is prepared to immediately counter-attack on any failed attempt to attack him in melee with enhanced defensive posture. A character under the parry condition receives a bonus to ranged and melee defense based on the melee attack and the number of adjacent surrounding enemies. The counter-attack inflicts lightning damage to a single target.";
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
	
	function onTurnStart()
	{
		this.removeSelf();
	}

	function getTooltip()
	{
		local bonus = this.getContainer().getActor().getCurrentProperties();
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
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.getDefenseBonus(bonus) + "[/color] Melee Defense"
			},
			{
				id = 4,
				type = "text",
				icon = "ui/icons/ranged_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.getDefenseBonus(bonus) + "[/color] Ranged Defense"
			},
			{
				id = 5,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Inflicts an additional [color=" + this.Const.UI.Color.DamageValue + "]10[/color] - [color=" + this.Const.UI.Color.DamageValue + "]20[/color] damage that ignores armor to a single target."
			}
		];
		
		if (!this.getContainer().getActor().getCurrentProperties().IsSpecializedInSwords)
		{
			ret.push({
				id = 6,
				type = "text",
				icon = "ui/icons/hitchance.png",
				text = "Has [color=" + this.Const.UI.Color.NegativeValue + "]-5%[/color] chance to hit"
			});
		}
		return ret;
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
	
	function addResources()
	{
		foreach( r in this.m.SoundOnLightning )
		{
			this.Tactical.addResource(r);
		}
	}	

	function applyEffect( _data, _delay )
	{
		this.Time.scheduleEvent(this.TimeUnit.Virtual, _delay, function ( _data )
		{
			for( local i = 0; i < this.Const.Tactical.LightningParticles.len(); i = ++i )
			{
				this.Tactical.spawnParticleEffect(true, this.Const.Tactical.LightningParticles[i].Brushes, _data.TargetTile, this.Const.Tactical.LightningParticles[i].Delay, this.Const.Tactical.LightningParticles[i].Quantity, this.Const.Tactical.LightningParticles[i].LifeTimeQuantity, this.Const.Tactical.LightningParticles[i].SpawnRate, this.Const.Tactical.LightningParticles[i].Stages);
			}
		}, _data);

		if (_data.Target == null)
		{
			return;
		}

		this.Time.scheduleEvent(this.TimeUnit.Virtual, _delay + 200, function ( _data )
		{
			local hitInfo = clone this.Const.Tactical.HitInfo;
			hitInfo.DamageRegular = this.Math.rand(10, 20);
			hitInfo.DamageDirect = 1.0;
			hitInfo.BodyPart = this.Const.BodyPart.Body;
			hitInfo.BodyDamageMult = 1.0;
			hitInfo.FatalityChanceMult = 0.0;
			_data.Target.onDamageReceived(_data.User, _data.Skill, hitInfo);
		}, _data);
	}	
	
	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (this.Tactical.TurnSequenceBar.getActiveEntity() == null || this.Tactical.TurnSequenceBar.getActiveEntity().getID() != this.getContainer().getActor().getID())
		{		
		local myTile = this.getContainer().getActor().getTile();

		if ( _targetEntity.getMoraleState() != 0 && _targetEntity.isAlive() && this.Math.rand(1, 100) <= 100)
		{
			local selectedTargets = [];
			local potentialTargets = [];
			local potentialTiles = [];
			local target;
			local targetTile = _targetEntity.getTile();

			if (this.m.SoundOnLightning.len() != 0)
			{
				this.Sound.play(this.m.SoundOnLightning[this.Math.rand(0, this.m.SoundOnLightning.len() - 1)], this.Const.Sound.Volume.Skill * 2.0, this.getContainer().getActor().getPos());
			}

			if (!targetTile.IsEmpty && _targetEntity.isAlive())
			{
				target = _targetEntity;
				selectedTargets.push(target.getID());
			}

			local data = {
				Skill = this,
				User = this.getContainer().getActor(),
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 100);
		} 	
		}
	}

});

