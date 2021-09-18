this.chain_lightning <- this.inherit("scripts/skills/skill", {
	m = {
		SoundOnLightning = [
			"sounds/combat/dlc2/legendary_lightning_01.wav",
			"sounds/combat/dlc2/legendary_lightning_02.wav",		
		]
	},
	function create()
	{
		this.m.ID = "actives.chain_lightning";
		this.m.Name = "Chain Lightning";
		this.m.Description = "Within 5 tile radius, the owner of the sword can summon a powerful linear electric discharge that can reach up to 5 nearby targets.";
		this.m.KilledString = "Electrocuted";
		this.m.Icon = "skills/active_216.png";
		this.m.IconDisabled = "skills/active_216.png";
		this.m.Overlay = "active_216";
		this.m.SoundOnUse = [
			"sounds/enemies/dlc6/cast_lightning_01.wav",
			"sounds/enemies/dlc6/cast_lightning_02.wav",
			"sounds/enemies/dlc6/cast_lightning_03.wav",
			"sounds/enemies/dlc6/cast_lightning_04.wav"
		];
		this.m.SoundOnHitDelay = 0;
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.Delay = 500;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = false;
		this.m.IsWeaponSkill = false;
		this.m.IsUsingHitchance = false;
		this.m.IsDoingForwardMove = false;
		this.m.IsTargetingActor = false;
		this.m.IsAOE = true;
		this.m.InjuriesOnBody = this.Const.Injury.BurningBody;
		this.m.InjuriesOnHead = this.Const.Injury.BurningHead;
		this.m.DirectDamageMult = 1.0;
		this.m.ActionPointCost = 9;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 5;
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
			},
			{
				id = 4,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Inflicts an [color=" + this.Const.UI.Color.DamageValue + "]20[/color] - [color=" + this.Const.UI.Color.DamageValue + "]30[/color] damage that ignores armor up to five targets."
			},
			{
				id = 5,
				type = "text",
				icon = "ui/icons/special.png",
				text = "The chance of successful chain lightning is defined based on the 40% of the Fatigue and 60% of the Resolve, and maximum 95% chance."  
			},
			
		];
		
		return ret;
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
			hitInfo.DamageRegular = this.Math.rand(20, 30);
			hitInfo.DamageDirect = 1.0;
			hitInfo.BodyPart = this.Const.BodyPart.Body;
			hitInfo.BodyDamageMult = 1.0;
			hitInfo.FatalityChanceMult = 0.0;
			_data.Target.onDamageReceived(_data.User, _data.Skill, hitInfo);
		}, _data);
	}

	function SpellHitChance()
	{
		local actor = this.getContainer().getActor();
		local ratio1 = 40;
		local ratio2 = 60;
		return this.Math.round(0.01 * ratio1 * actor.getCurrentProperties().getBravery() + 0.01 * ratio2 * actor.getCurrentProperties().getFatigue());
	}
	
	function onUse( _user, _targetTile )
	{
		local myTile = _user.getTile();

		if ( _user.isAlive() && _targetEntity.getMoraleState() != 0 && this.Math.rand(1, 100) <= this.Math.min(95, this.SpellHitChance); )
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
			potentialTargets = [];
			potentialTiles = [];

			for( local i = 0; i < 6; i = ++i )
			{
				if (!targetTile.hasNextTile(i))
				{
				}
				else
				{
					local tile = targetTile.getNextTile(i);

					if (tile.ID != myTile.ID)
					{
						potentialTiles.push(tile);
					}

					if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
					{
					}
					else
					{
						potentialTargets.push(tile);
					}
				}
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[this.Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[this.Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 300);
			potentialTargets = [];
			potentialTiles = [];	
	
			for( local i = 0; i < 6; i = ++i )
			{
				if (!targetTile.hasNextTile(i))
				{
				}
				else
				{
					local tile = targetTile.getNextTile(i);

					if (tile.ID != myTile.ID)
					{
						potentialTiles.push(tile);
					}

					if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
					{
					}
					else
					{
						potentialTargets.push(tile);
					}
				}
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[this.Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[this.Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 500);
			potentialTargets = [];
			potentialTiles = [];	
			
			for( local i = 0; i < 6; i = ++i )
			{
				if (!targetTile.hasNextTile(i))
				{
				}
				else
				{
					local tile = targetTile.getNextTile(i);

					if (tile.ID != myTile.ID)
					{
						potentialTiles.push(tile);
					}

					if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
					{
					}
					else
					{
						potentialTargets.push(tile);
					}
				}
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[this.Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[this.Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 700);
			potentialTargets = [];
			potentialTiles = [];

			for( local i = 0; i < 6; i = ++i )
			{
				if (!targetTile.hasNextTile(i))
				{
				}
				else
				{
					local tile = targetTile.getNextTile(i);

					if (tile.ID != myTile.ID)
					{
						potentialTiles.push(tile);
					}

					if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
					{
					}
					else
					{
						potentialTargets.push(tile);
					}
				}
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[this.Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[this.Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 900);
			potentialTargets = [];
			potentialTiles = [];				
		}
		return success;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedAttackBlockedChanceMult *= 0;
			_properties.RangedDefense = 0;
	}

});

