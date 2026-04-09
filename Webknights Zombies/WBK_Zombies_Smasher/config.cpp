class CfgPatches
{
	class WBK_Zombies_Smasher
	{
		author="WebKnight";
		units[]=
		{
			"WBK_SpecialZombie_Smasher_Hellbeast_3",
			"WBK_SpecialZombie_Smasher_Hellbeast_2",
			"WBK_SpecialZombie_Smasher_Hellbeast_1",
			"WBK_SpecialZombie_Smasher_Acid_3",
			"WBK_SpecialZombie_Smasher_Acid_2",
			"WBK_SpecialZombie_Smasher_Acid_1",
			"WBK_SpecialZombie_Smasher_1",
			"WBK_SpecialZombie_Smasher_2",
			"WBK_SpecialZombie_Smasher_3"
		};
		weapons[]={};
		requiredVersion=0.1;
		requiredAddons[]=
		{
			"A3_Characters_F",
			"a3_anims_f"
		};
	};
};
class CfgMovesBasic
{
	class Default;
	class StandBase;
	class BlendAnims;
	class Actions
	{
		class Default;
		class NoActions;
		class WBK_Zombie_SMASHER_Moveset: NoActions
		{
			Disable_Gesture[]=
			{
				"Disable_Gesture",
				"Gesture"
			};
			LimpF="WBK_Smasher_Run";
			LimpLF="WBK_Smasher_Run";
			LimpRF="WBK_Smasher_Run";
			LimpL="WBK_Smasher_Run";
			LimpR="WBK_Smasher_Run";
			LimpB="WBK_Smasher_Run";
			LimpLB="WBK_Smasher_Run";
			LimpRB="WBK_Smasher_Run";
			stop="WBK_Smasher_Idle";
			default="WBK_Smasher_Idle";
			stopRelaxed="WBK_Smasher_Idle";
			TurnL="WBK_Smasher_TurnL";
			TurnR="WBK_Smasher_TurnR";
			TurnLRelaxed="WBK_Smasher_TurnL";
			TurnRRelaxed="WBK_Smasher_TurnR";
			WalkF="WBK_Smasher_Run";
			PlayerWalkF="WBK_Smasher_Run";
			WalkLF="WBK_Smasher_Run";
			PlayerWalkLF="WBK_Smasher_Run";
			WalkRF="WBK_Smasher_Run";
			PlayerWalkRF="WBK_Smasher_Run";
			WalkL="WBK_Smasher_Run";
			PlayerWalkL="WBK_Smasher_Run";
			WalkR="WBK_Smasher_Run";
			PlayerWalkR="WBK_Smasher_Run";
			WalkB="WBK_Smasher_Run";
			PlayerWalkB="WBK_Smasher_Run";
			WalkLB="WBK_Smasher_Run";
			PlayerWalkLB="WBK_Smasher_Run";
			WalkRB="WBK_Smasher_Run";
			PlayerWalkRB="WBK_Smasher_Run";
			SlowF="WBK_Smasher_Run";
			PlayerSlowF="WBK_Smasher_Run";
			SlowB="WBK_Smasher_Run";
			PlayerSlowB="WBK_Smasher_Run";
			FastF="WBK_Smasher_Run";
			PlayerFastF="WBK_Smasher_Run";
			combat="WBK_Smasher_Run";
			up="WBK_Smasher_Run";
			down="WBK_Smasher_Run";
			gear="WBK_Smasher_Run";
			upDegree="ManPosNoWeapon";
			PlayerSlowLF="WBK_Smasher_Run";
			PlayerSlowRF="WBK_Smasher_Run";
			PlayerSlowL="WBK_Smasher_Run";
			PlayerSlowR="WBK_Smasher_Run";
			PlayerSlowLB="WBK_Smasher_Run";
			PlayerSlowRB="WBK_Smasher_Run";
			FastLF="WBK_Smasher_Run";
			FastRF="WBK_Smasher_Run";
			FastL="WBK_Smasher_Run";
			FastR="WBK_Smasher_Run";
			FastLB="WBK_Smasher_Run";
			FastRB="WBK_Smasher_Run";
			TactF="WBK_Smasher_Run";
			TactLF="WBK_Smasher_Run";
			TactRF="WBK_Smasher_Run";
			TactL="WBK_Smasher_Run";
			TactR="WBK_Smasher_Run";
			TactLB="WBK_Smasher_Run";
			TactRB="WBK_Smasher_Run";
			TactB="WBK_Smasher_Run";
			PlayerTactF="WBK_Smasher_Run";
			PlayerTactLF="WBK_Smasher_Run";
			PlayerTactRF="WBK_Smasher_Run";
			PlayerTactL="WBK_Smasher_Run";
			PlayerTactR="WBK_Smasher_Run";
			PlayerTactLB="WBK_Smasher_Run";
			PlayerTactRB="WBK_Smasher_Run";
			PlayerTactB="WBK_Smasher_Run";
			StartFreefall="WBK_Smasher_inAir";
			Die="WBK_Smasher_Die";
			Unconscious="WBK_Smasher_Run";
		};
		class WBK_Zombie_SMASHER_Moveset_Run: WBK_Zombie_SMASHER_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="WBK_Smasher_Run";
			Up="WBK_Smasher_Run";
			Crouch="WBK_Smasher_Run";
			AdjustB="";
			Stand="WBK_Smasher_Run";
		};
		class WBK_Zombie_SMASHER_Moveset_TurnL: WBK_Zombie_SMASHER_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="WBK_Smasher_TurnL";
			Up="WBK_Smasher_TurnL";
			Crouch="WBK_Smasher_TurnL";
			AdjustB="";
			Stand="WBK_Smasher_TurnL";
		};
		class WBK_Zombie_SMASHER_Moveset_TurnR: WBK_Zombie_SMASHER_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="WBK_Smasher_TurnR";
			Up="WBK_Smasher_TurnR";
			Crouch="WBK_Smasher_TurnR";
			AdjustB="";
			Stand="WBK_Smasher_TurnR";
		};
		class WBK_Zombie_SMASHER_Moveset_InAir: WBK_Zombie_SMASHER_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="WBK_Smasher_inAir";
			Up="WBK_Smasher_inAir";
			Crouch="WBK_Smasher_inAir";
			AdjustB="";
			Stand="WBK_Smasher_inAir";
		};
		class WBK_Zombie_SMASHER_Moveset_InAir_Start: WBK_Zombie_SMASHER_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="WBK_Smasher_inAir_start_onRun";
			Up="WBK_Smasher_inAir_start_onRun";
			Crouch="WBK_Smasher_inAir_start_onRun";
			AdjustB="";
			Stand="WBK_Smasher_inAir_start_onRun";
		};
		class Acts_CarFixingWheel_actions;
		class WBK_Smasher_Sync_Human: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_1";
		};
	};
};
class CfgMovesMaleSdr: CfgMovesBasic
{
	skeletonName="OFP2_ManSkeleton";
	gestures="CfgGesturesMale";
	class States
	{
		class HubShootingRangeKneel_move1;
		class WBK_Smasher_Execution: HubShootingRangeKneel_move1
		{
			boundingSphere=5;
			minPlayTime=0.88999999;
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			interpolationspeed=6;
			interpolationrestart=1;
			looped=0;
			aimPrecision=3;
			ignoreMinPlayTime[]={};
			duty=-0.5;
			actions="WBK_Smasher_Sync_Human";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_EXECUTION_VICTIM.rtm";
			stamina=-0.1;
			speed=-8;
			showHandGun=0;
			mask="BodyFull";
			leftHandIKBeg=0;
			leftHandIKCurve[]={0};
			leftHandIKEnd=0;
			rightHandIKBeg=0;
			rightHandIKCurve[]={0};
			rightHandIKEnd=0;
			weaponIK=0;
			enableOptics=0;
			showWeaponAim=0;
			disableWeapons=1;
			disableWeaponsLong=1;
			leaning="empty";
			aimingBody="empty";
			aiming="empty";
			limitGunMovement=9.1000004;
			headBobMode=1;
			headBobStrength=-1;
			forceAim=1;
			head="headDefault";
			canPullTrigger=0;
			enableDirectControl=0;
			weaponLowered=0;
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};
			connectFrom[]={};
			interpolateFrom[]={};
			InterpolateTo[]=
			{
				"Unconscious",
				0.0099999998
			};
			ragdoll=0;
		};
		class acid_death_human_1: WBK_Smasher_Execution
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_HumanMelt_1.rtm";
			speed=-2;
			InterpolateTo[]={};
		};
		class acid_death_human_2: acid_death_human_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_HumanMelt_2.rtm";
			speed=-1.5;
		};
		class acid_death_human_3: acid_death_human_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_HumanMelt_3.rtm";
			speed=-1.5;
		};
	};
};
class CfgGesturesMale;
class CfgGesturesZombieSmasher: CfgGesturesMale
{
	skeletonName="WBK_Smasher_Skeleton";
	class ManActions
	{
	};
	class Actions;
	class Default;
	class BlendAnims
	{
		Smasher_FullBody[]={};
	};
	class States
	{
		class Disable_Gesture: Default
		{
			speed=1;
			file="\WBK_Zombies_Smasher\Smasher\WBK_Smasher_Idle.rtm";
			disableWeapons=0;
			interpolationRestart=2;
			enableOptics=1;
			weaponIK=1;
			looped=0;
			leftHandIKBeg=1;
			leftHandIKCurve[]={1};
			leftHandIKEnd=1;
			rightHandIKBeg=1;
			rightHandIKCurve[]={1};
			rightHandIKEnd=1;
		};
	};
};
class cfgMovesWbkZombieSmasher: CfgMovesBasic
{
	gestures="CfgGesturesZombieSmasher";
	skeletonName="WBK_Smasher_Skeleton";
	collisionVertexPattern[]=
	{
		"1a",
		"2a",
		"3a",
		"4a",
		"5a",
		"6a",
		"7a",
		"8a",
		"9a",
		"10a",
		"11a",
		"12a",
		"13a",
		"14a",
		"15a",
		"16a",
		"17a",
		"18a",
		"19a",
		"20a",
		"21a",
		"22a",
		"23a",
		"24a",
		"25a",
		"26a",
		"27a",
		"28a",
		"29a",
		"30a",
		"31a",
		"32a",
		"33a",
		"34a"
	};
	collisionGeomCompPattern[]={1};
	class Default: Default
	{
		actions="WBK_Zombie_SMASHER_Moveset";
		file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Idle.rtm";
	};
	class StandBase: StandBase
	{
		actions="WBK_Zombie_SMASHER_Moveset";
		file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Idle.rtm";
	};
	class DefaultDie: Default
	{
		aiming="aimingNo";
		legs="legsNo";
		head="headNo";
		disableWeapons=1;
		interpolationRestart=1;
		soundOverride="fallbody";
		soundEdge[]={0.44999999};
		soundEnabled=0;
	};
	class States
	{
		class WBK_Smasher_Idle: StandBase
		{
			ignoreMinPlayTime[]=
			{
				"WBK_Smasher_Die"
			};
			boundingSphere=5;
			interpolationSpeed=2;
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Idle.rtm";
			duty=0.69999999;
			minPlayTime=1;
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			actions="WBK_Zombie_SMASHER_Moveset";
			variantsAI[]={};
			speed=-4;
			canPullTrigger=0;
			canReload=0;
			limitGunMovement=1;
			headBobStrength=-1;
			headBobMode=1;
			disableWeapons=0;
			disableWeaponsLong=0;
			enableMissile=1;
			enableOptics=1;
			aiming="aimingNo";
			head="noHead";
			legs="legsNo";
			ConnectTo[]={};
			ConnectFrom[]={};
			InterpolateTo[]=
			{
				"WBK_Smasher_Idle",
				0.0099999998,
				"WBK_Smasher_Run",
				0.0099999998,
				"WBK_Smasher_TurnL",
				0.0099999998,
				"WBK_Smasher_TurnR",
				0.0099999998,
				"WBK_Smasher_inAir_start_onRun",
				0.0099999998,
				"WBK_Smasher_Die",
				0.5,
				"WBK_Smasher_inAir_end",
				0.69999999,
				"WBK_Smasher_Attack_1",
				0.89999998,
				"WBK_Smasher_Attack_2",
				0.89999998,
				"WBK_Smasher_Attack_3",
				0.89999998,
				"WBK_Smasher_Attack_Air",
				0.89999998,
				"WBK_Smasher_Attack_VEHICLE",
				0.89999998,
				"WBK_Smasher_Execution",
				0.89999998,
				"WBK_Smasher_Roar",
				0.89999998,
				"WBK_Smasher_Throw",
				0.89999998,
				"WBK_Smasher_HitHard",
				0.89999998
			};
			InterpolateFrom[]=
			{
				"WBK_Smasher_Idle",
				0.0099999998,
				"WBK_Smasher_Run",
				0.0099999998,
				"WBK_Smasher_TurnL",
				0.0099999998,
				"WBK_Smasher_TurnR",
				0.0099999998,
				"WBK_Smasher_inAir_start_onRun",
				0.0099999998,
				"WBK_Smasher_Die",
				0.5,
				"WBK_Smasher_inAir_end",
				0.69999999,
				"WBK_Smasher_Attack_1",
				0.89999998,
				"WBK_Smasher_Attack_2",
				0.89999998,
				"WBK_Smasher_Attack_3",
				0.89999998,
				"WBK_Smasher_Attack_Air",
				0.89999998,
				"WBK_Smasher_Attack_VEHICLE",
				0.89999998,
				"WBK_Smasher_Execution",
				0.89999998,
				"WBK_Smasher_Roar",
				0.89999998,
				"WBK_Smasher_Throw",
				0.89999998,
				"WBK_Smasher_HitHard",
				0.89999998
			};
			preload=1;
		};
		class WBK_Smasher_Run: WBK_Smasher_Idle
		{
			actions="WBK_Zombie_SMASHER_Moveset_Run";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Run.rtm";
			speed=-0.68000001;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class WBK_Smasher_TurnL: WBK_Smasher_Idle
		{
			actions="WBK_Zombie_SMASHER_Moveset_TurnL";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_TurnL.rtm";
			speed=-0.75;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class WBK_Smasher_TurnR: WBK_Smasher_Idle
		{
			actions="WBK_Zombie_SMASHER_Moveset_TurnR";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_TurnR.rtm";
			speed=-0.75;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class WBK_Smasher_inAir: WBK_Smasher_Idle
		{
			actions="WBK_Zombie_SMASHER_Moveset_inAir";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_inAir.rtm";
			speed=-5;
			InterpolateTo[]=
			{
				"WBK_Smasher_inAir_end",
				0.0099999998
			};
		};
		class WBK_Smasher_Die: WBK_Smasher_Idle
		{
			interpolationRestart=1;
			soundEnabled=0;
			minPlayTime=0.99000001;
			speed=-1.5;
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Die.rtm";
			actions="WBK_Zombie_SMASHER_Moveset";
			InterpolateTo[]={};
			InterpolateFrom[]={};
			variantsAI[]={};
			variantsPlayer[]={};
			looped="false";
		};
		class WBK_Smasher_Attack_1: WBK_Smasher_Idle
		{
			variantsAI[]={};
			variantsPlayer[]={};
			interpolationSpeed=3.5;
			interpolationRestart=1;
			looped="false";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_1.rtm";
			speed=-4.75;
			minPlayTime=0.99000001;
			ignoreMinPlayTime[]=
			{
				"WBK_Smasher_Die"
			};
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.40000001,0.64999998};
		};
		class WBK_Smasher_Attack_2: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_2.rtm";
			speed=-3;
			soundEdge[]={0.15000001,0.5,0.75};
		};
		class WBK_Smasher_Attack_3: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_3.rtm";
			speed=-3;
			soundEdge[]={0.079999998,0.60000002,0.63999999,0.94};
		};
		class WBK_Smasher_Attack_Air: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_Air.rtm";
			speed=-2.4000001;
			soundEnabled=0;
		};
		class WBK_Smasher_Attack_VEHICLE: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_VEHICLE.rtm";
			speed=-4.5;
			soundEdge[]={0.1,0.40000001,0.44999999};
		};
		class WBK_Smasher_Execution: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_EXECUTION_MAIN.rtm";
			speed=-8;
			soundEnabled=0;
		};
		class WBK_Smasher_Roar: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Roar.rtm";
			speed=-2.5;
			soundEnabled=0;
		};
		class WBK_Smasher_Throw: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Throw.rtm";
			speed=-3.5;
			soundEnabled=0;
		};
		class WBK_Smasher_HitHard: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_HitHard.rtm";
			speed=-2.8;
			soundEnabled=0;
		};
		class WBK_Smasher_inAir_start_onRun: WBK_Smasher_Attack_1
		{
			actions="WBK_Zombie_SMASHER_Moveset_InAir_Start";
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_inAir_start_onRun.rtm";
			soundEnabled=0;
			speed=-0.75;
			InterpolateTo[]=
			{
				"WBK_Smasher_inAir",
				0.0099999998
			};
		};
		class WBK_Smasher_inAir_end: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_inAir_end.rtm";
			speed=-1.5;
			soundEnabled=0;
		};
		class WBK_Smasher_Attack_Acid: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_Acid.rtm";
			speed=-2.5;
			soundEnabled=0;
		};
		class WBK_Smasher_Attack_Fire: WBK_Smasher_Attack_1
		{
			file="\WBK_Zombies_Smasher\animations\WBK_Smasher_Attack_Fire.rtm";
			speed=-2.8;
			soundEnabled=0;
		};
	};
};
class cfgAmmo
{
	class Grenade;
	class Smasher_RockGrenade: Grenade
	{
		hit=9000;
		indirectHit=9000;
		indirectHitRange=1.5;
		model="WBK_Zombies_Smasher\Smasher_Stone.p3d";
		explosionTime=0;
		fusedistance=1;
		deflectionSlowDown=0.001;
		caliber=60;
		typicalSpeed=1;
		explosionEffects="ExploAmmoExplosion";
		SoundSetExplosion[]=
		{
			"Explosion_Debris_SoundSet"
		};
	};
	class SmokeShell;
	class Smasher_AcidGrenade: SmokeShell
	{
		explosionSoundEffect="DefaultExplosion";
		timeToLive=900;
		grenadeFireSound[]={};
		grenadeBurningSound[]={};
		model="\A3\Weapons_F_EPB\Ammo\B_IRstrobe_F.p3d";
		simulation="shotGrenade";
		hit=9;
		indirectHit=4;
		indirectHitRange=5;
		deflecting=0;
		airFriction=-0.001;
		whistleDist=16;
		typicalSpeed=26;
		explosionTime=0;
		fuseDistance=1;
		directionalExplosion=0;
		deflectionSlowDown=0;
		simulationStep=0.050000001;
		SoundSetExplosion[]=
		{
			"Explosion_Debris_SoundSet"
		};
	};
};
class CfgVehicles
{
	class I_Survivor_F;
	class WBK_C_ExportClass: I_Survivor_F
	{
		identityTypes[]=
		{
			"empty_Face"
		};
	};
	class WBK_SpecialZombie_Smasher_1: WBK_C_ExportClass
	{
		side=2;
		editorSubcategory="WBK_Zombies_SpecialInfected";
		gestures="CfgGesturesZombieSmasher";
		class SoundEnvironExt
		{
			tarmac[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			generic[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			water_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			water[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			metal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_metal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			wavymetal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			gridmetal_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_metalplate_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			metalplatepressed_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			metalplate_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			steel_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			wavymetal_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			steel[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			softwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_softwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_wood[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			wood[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_solidwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			sand[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			sand_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			gravel2[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			gravel[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			gravel_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			dirt[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			dirt_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			rock[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			mud[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			mud_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			forest[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			forest_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			tiling[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			grass[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			drygrass[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			grass_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			grasstall_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			pavement_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			stony[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			concrete[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			road[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			concrete_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			asphalt_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_concrete_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			stones_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			hallway[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			concrete_Ext[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			normalExt[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_tiles[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
			int_concrete[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Smasher_Footsteps_SoundSet"
					}
				}
			};
		};
		class SoundEquipment
		{
			soldier[]={};
		};
		class SoundBreath
		{
			breath[]={};
		};
		class SoundDrown
		{
			breath[]={};
		};
		class SoundInjured
		{
			breath[]={};
		};
		class SoundBleeding
		{
			breath[]={};
		};
		class SoundBurning
		{
			breath[]={};
		};
		class SoundChoke
		{
			breath[]={};
		};
		class SoundRecovered
		{
			breath[]={};
		};
		class SoundBreathAiming
		{
			breath[]={};
		};
		class SoundBreathAutomatic
		{
			breath[]={};
		};
		class SoundBreathInjured
		{
			Person1[]={};
		};
		class SoundBreathSwimming
		{
			breathSwimming1[]={};
		};
		class SoundHitScream
		{
			Person1[]={};
		};
		items[]={};
		uniformClass="Smasher_uniform";
		nakedUniform="Smasher_uniform";
		faction="WBK_AI_ZHAMBIES";
		_generalMacro="WBK_AI_ZHAMBIES";
		vehicleclass="Men";
		displayName="Smasher";
		moves="cfgMovesWbkZombieSmasher";
		model="WBK_Zombies_Smasher\Smasher.p3d";
		armor=7;
		scope=2;
		canCarryBackPack=1;
		canDeactivateMines=0;
		engineer=0;
		hiddenSelections[]=
		{
			"Camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies_Smasher\textures\Smasher_Texture.paa"
		};
		hiddenSelectionsMaterials[]=
		{
			"\WBK_Zombies_Smasher\textures\Smasher.rvmat"
		};
		attendant=1;
		class Character
		{
			radius=200;
			detectionRadius=500;
			chaseDistance=51;
			coverRadius=50;
			escapeRadius=200;
			damage=0.40000001;
			damageHitPoints[]=
			{
				
				{
					"HitLeftLeg",
					0.40000001
				},
				
				{
					"HitRightLeg",
					0.40000001
				},
				
				{
					"HitBody",
					0.69999999
				}
			};
			armor=7;
			attackDistances[]={2,3};
			allowWalk=1;
			aggressive=1;
			secrecy=0.40000001;
			curious=1;
			cowardice=0;
			societal=0;
			tactful=1;
			courage=1;
			friendly[]={};
			class Sounds
			{
				idle[]={};
				attack[]={};
				hit[]={};
				other[]={};
			};
			class Animations
			{
				attack_1[]={};
				attack_2[]={};
				attack_3[]={};
				agry[]={};
				eat[]=
				{
					""
				};
			};
			class HitPoints
			{
				class HitFace
				{
					armor=1;
					material=-1;
					name="bip01_head";
					passThrough=0.1;
					radius=0.079999998;
					explosionShielding=0.1;
					minimalHit=0.0099999998;
				};
				class HitNeck: HitFace
				{
					armor=1;
					material=-1;
					name="bip01_neck";
					passThrough=0.1;
					radius=0.1;
					explosionShielding=0.5;
					minimalHit=0.0099999998;
				};
				class HitHead: HitNeck
				{
					armor=1;
					material=-1;
					name="bip01_head";
					passThrough=0.1;
					radius=0.2;
					explosionShielding=0.5;
					minimalHit=0.0099999998;
					depends="HitFace max HitNeck";
				};
				class HitPelvis
				{
					armor=1;
					material=-1;
					name="bip01_pelvis";
					passThrough=0.1;
					radius=0.2;
					explosionShielding=1;
					visual="injury_body";
					minimalHit=0.0099999998;
				};
				class HitAbdomen: HitPelvis
				{
					armor=1;
					material=-1;
					name="bip01_spine1";
					passThrough=0.1;
					radius=0.15000001;
					explosionShielding=1;
					visual="injury_body";
					minimalHit=0.0099999998;
				};
				class HitDiaphragm: HitAbdomen
				{
					armor=1;
					material=-1;
					name="bip01_spine2";
					passThrough=0.1;
					radius=0.15000001;
					explosionShielding=6;
					visual="injury_body";
					minimalHit=0.0099999998;
				};
				class HitChest: HitDiaphragm
				{
					armor=1;
					material=-1;
					name="bip01_spine3";
					passThrough=0.1;
					radius=0.15000001;
					explosionShielding=6;
					visual="injury_body";
					minimalHit=0.0099999998;
				};
				class HitBody: HitChest
				{
					armor=6500;
					material=-1;
					name="Body";
					passThrough=0.1;
					radius=0.16;
					explosionShielding=6;
					visual="injury_body";
					minimalHit=0.0099999998;
					depends="HitPelvis max HitAbdomen max HitDiaphragm max HitChest";
				};
				class HitArms
				{
					armor=1;
					material=-1;
					name="arms";
					passThrough=1;
					radius=0.1;
					explosionShielding=1;
					visual="injury_hands";
					minimalHit=0.0099999998;
				};
				class HitHands: HitArms
				{
					armor=1;
					material=-1;
					name="hands";
					passThrough=1;
					radius=0.1;
					explosionShielding=1;
					visual="injury_hands";
					minimalHit=0.0099999998;
					depends="HitArms";
				};
				class HitLegs
				{
					armor=1;
					material=-1;
					name="legs";
					passThrough=1;
					radius=0.12;
					explosionShielding=1;
					visual="injury_legs";
					minimalHit=0.0099999998;
				};
			};
			armorStructural=0.40000001;
			explosionShielding=0.039999999;
			minTotalDamageThreshold=0.001;
			impactDamageMultiplier=0.5;
		};
		weapons[]=
		{
			"Throw",
			"Put"
		};
		magazines[]={};
		linkedItems[]={};
	};
	class WBK_SpecialZombie_Smasher_2: WBK_SpecialZombie_Smasher_1
	{
		side=1;
	};
	class WBK_SpecialZombie_Smasher_3: WBK_SpecialZombie_Smasher_1
	{
		side=0;
	};
	class WBK_SpecialZombie_Smasher_Acid_1: WBK_SpecialZombie_Smasher_1
	{
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies_Smasher\textures\Smasher_Acid_CO.paa"
		};
		displayName="Smasher (Spewer)";
	};
	class WBK_SpecialZombie_Smasher_Acid_2: WBK_SpecialZombie_Smasher_Acid_1
	{
		side=1;
		displayName="Smasher (Spewer)";
	};
	class WBK_SpecialZombie_Smasher_Acid_3: WBK_SpecialZombie_Smasher_Acid_1
	{
		side=0;
		displayName="Smasher (Spewer)";
	};
	class WBK_SpecialZombie_Smasher_Hellbeast_1: WBK_SpecialZombie_Smasher_1
	{
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies_Smasher\textures\Hell_Spawn_Smasher_CO.paa"
		};
		displayName="Smasher (Hellspawn)";
	};
	class WBK_SpecialZombie_Smasher_Hellbeast_2: WBK_SpecialZombie_Smasher_Hellbeast_1
	{
		side=1;
		displayName="Smasher (Hellspawn)";
	};
	class WBK_SpecialZombie_Smasher_Hellbeast_3: WBK_SpecialZombie_Smasher_Hellbeast_1
	{
		side=0;
		displayName="Smasher (Hellspawn)";
	};
};
class CfgSounds
{
	sounds[]={};
	class hellspawn_fireball_hit
	{
		name="hellspawn_fireball_hit";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hellspawn_fireball_hit.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class hellspawn_fireball_idle
	{
		name="hellspawn_fireball_idle";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hellspawn_fireball_idle.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class hellspawn_fireball_loop
	{
		name="hellspawn_fireball_loop";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hellspawn_fireball_loop.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class hellspawn_fireball_start_1
	{
		name="hellspawn_fireball_start_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hellspawn_fireball_start_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class hellspawn_fireball_start_2
	{
		name="hellspawn_fireball_start_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hellspawn_fireball_start_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_death_human_1
	{
		name="acid_death_human_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_death_human_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_death_human_2
	{
		name="acid_death_human_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_death_human_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_death_human_3
	{
		name="acid_death_human_3";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_death_human_3.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_attack_start
	{
		name="acid_attack_start";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_attack_start.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class smasher_idle_acid
	{
		name="smasher_idle_acid";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\smasher_idle_acid.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_hit
	{
		name="acid_hit";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_hit.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_idle
	{
		name="acid_idle";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_idle.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class acid_loop
	{
		name="acid_loop";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\acid_loop.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Smash_rockHit
	{
		name="Smash_rockHit";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\smash_rockHit.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_hit
	{
		name="Smasher_hit";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\hit.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_human_scream_1
	{
		name="Smasher_human_scream_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\human_scream_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_human_scream_2
	{
		name="Smasher_human_scream_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\human_scream_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_human_scream_3
	{
		name="Smasher_human_scream_3";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\human_scream_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_swoosh_1
	{
		name="Smasher_swoosh_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\swoosh_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_swoosh_2
	{
		name="Smasher_swoosh_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\swoosh_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_hit_vehicle
	{
		name="Smasher_hit_vehicle";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\nano_veh_impac_3.wav",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_1
	{
		name="Smasher_attack_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_2
	{
		name="Smasher_attack_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_3
	{
		name="Smasher_attack_3";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_4
	{
		name="Smasher_attack_4";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_5
	{
		name="Smasher_attack_5";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_5.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_6
	{
		name="Smasher_attack_6";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_6.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_7
	{
		name="Smasher_attack_7";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_7.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_8
	{
		name="Smasher_attack_8";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_8.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_attack_9
	{
		name="Smasher_attack_9";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_attack_9.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_die_1
	{
		name="Smasher_die_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_die_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_die_2
	{
		name="Smasher_die_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_die_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_die_3
	{
		name="Smasher_die_3";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_die_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_die_4
	{
		name="Smasher_die_4";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_die_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_Eat
	{
		name="Smasher_Eat";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_Eat.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_eat_voice
	{
		name="Smasher_eat_voice";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_eat_voice.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_execution_end
	{
		name="Smasher_execution_end";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_execution_end.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_idle_1
	{
		name="Smasher_idle_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_idle_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_idle_2
	{
		name="Smasher_idle_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_idle_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_idle_3
	{
		name="Smasher_idle_3";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_idle_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_idle_4
	{
		name="Smasher_idle_4";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_idle_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_idle_5
	{
		name="Smasher_idle_5";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_idle_5.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_Roar
	{
		name="Smasher_Roar";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_Roar.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_scream_1
	{
		name="Smasher_scream_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_scream_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_scream_2
	{
		name="Smasher_scream_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_scream_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_scream_1_dist
	{
		name="Smasher_scream_1_dist";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_scream_dist_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_scream_2_dist
	{
		name="Smasher_scream_2_dist";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\Smasher_scream_dist_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_hit_human_1
	{
		name="Smasher_hit_human_1";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\human_hit_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Smasher_hit_human_2
	{
		name="Smasher_hit_human_2";
		sound[]=
		{
			"\WBK_Zombies_Smasher\sounds\human_hit_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
};
class CfgSoundSets
{
	class footsteps_roofTiles_sprint_Exp_SoundSet;
	class WBK_Smasher_Footsteps_SoundSet: footsteps_roofTiles_sprint_Exp_SoundSet
	{
		soundShaders[]=
		{
			"WBK_Smasher_FootStep_Close",
			"WBK_Smasher_FootStep_Far"
		};
		volumeFactor=1;
	};
};
class CfgSoundShaders
{
	class WBK_Smasher_FootStep_Close
	{
		frequency=1;
		samples[]=
		{
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_1",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_2",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_3",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_4",
				1
			}
		};
		volume=0.60000002;
		range=85;
	};
	class WBK_Smasher_FootStep_Far
	{
		frequency=1;
		samples[]=
		{
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_1",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_2",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_3",
				1
			},
			
			{
				"\WBK_Zombies_Smasher\sounds\smasher_footstep_4",
				1
			}
		};
		volume=0.2;
		range=600;
	};
};
class cfgWeapons
{
	class Uniform_Base;
	class UniformItem;
	class Smasher_uniform: Uniform_Base
	{
		displayname="Smasher";
		model="WBK_Zombies_Smasher\Smasher.p3d";
		scope=1;
		picture="";
		hiddenSelections[]={};
		hiddenSelectionsTextures[]={};
		class ItemInfo: UniformItem
		{
			containerclass="Supply200";
			mass=30;
			uniformclass="Smasher_uniform";
			uniformmodel="-";
		};
	};
};
class Extended_Killed_Eventhandlers
{
	class WBK_SpecialZombie_Smasher_1
	{
		class WBK_SpecialZombie_Smasher_1_Death
		{
			killed="_target = _this select 0;if (local _target) then {removeUniform _target;};";
		};
	};
};
class Extended_InitPost_EventHandlers
{
	class WBK_SpecialZombie_Smasher_1
	{
		class Zombie_Smasher_Init
		{
			init="_unit = _this select 0; if (local _unit) then {_unit execVM '\WBK_Zombies_Smasher\AI\WBK_AI_Smasher.sqf';};";
		};
	};
};
class Extended_PreInit_EventHandlers
{
	class WBK_Zombies_Smasher_PreInit
	{
		init="call compile preprocessFileLineNumbers '\WBK_Zombies_Smasher\XEH_preInit.sqf'";
	};
};
class cfgMods
{
	author="WebKnight";
	timepacked="1734896593";
};
