class CfgPatches
{
	class WBK_Zombies_Corrupted
	{
		author="WebKnight";
		units[]=
		{
			"WBK_SpecialZombie_Corrupted_1",
			"WBK_SpecialZombie_Corrupted_2",
			"WBK_SpecialZombie_Corrupted_3"
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
class CfgSounds
{
	sounds[]={};
	class corrupted_head_attack_1
	{
		name="corrupted_head_attack_1";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\attack_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_attack_2
	{
		name="corrupted_head_attack_2";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\attack_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_attack_3
	{
		name="corrupted_head_attack_3";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\attack_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_attack_4
	{
		name="corrupted_head_attack_4";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\attack_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_attack_5
	{
		name="corrupted_head_attack_5";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\attack_5.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_idle_1
	{
		name="corrupted_head_idle_1";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\idle_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_head_idle_2
	{
		name="corrupted_head_idle_2";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\idle_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_dead_1
	{
		name="corrupted_dead_1";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_dead_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_dead_2
	{
		name="corrupted_dead_2";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_dead_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_dead_3
	{
		name="corrupted_dead_3";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_dead_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_idle_1
	{
		name="corrupted_idle_1";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_idle_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_idle_2
	{
		name="corrupted_idle_2";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_idle_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_idle_3
	{
		name="corrupted_idle_3";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_idle_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_idle_4
	{
		name="corrupted_idle_4";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_idle_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class corrupted_transformed
	{
		name="corrupted_transformed";
		sound[]=
		{
			"\WBK_Zombies_Corrupted\Sounds\corrupted_transformed.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
};
class CfgGesturesMale;
class CfgGesturesZombieCorrupted: CfgGesturesMale
{
	skeletonName="WBK_ZombieCreatureCorrupted_Skeleton";
	class ManActions
	{
	};
	class Actions;
	class Default;
	class BlendAnims
	{
		Corrupted_FullBody[]={};
	};
	class States
	{
		class Disable_Gesture: Default
		{
			speed=1;
			file="\WBK_Zombies_Corrupted\animations\Corrupted_idle.rtm";
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
class CfgMovesBasic
{
	class Default;
	class StandBase;
	class BlendAnims;
	class Actions
	{
		class Default;
		class NoActions;
		class WBK_Zombie_CORRUPTED_Moveset: NoActions
		{
			LimpF="Corrupted_Walk";
			LimpLF="Corrupted_Walk";
			LimpRF="Corrupted_Walk";
			LimpL="Corrupted_Walk";
			LimpR="Corrupted_Walk";
			LimpB="Corrupted_Walk";
			LimpLB="Corrupted_Walk";
			LimpRB="Corrupted_Walk";
			stop="Corrupted_idle";
			default="Corrupted_idle";
			stopRelaxed="Corrupted_idle";
			TurnL="Corrupted_Turn_L";
			TurnR="Corrupted_Turn_R";
			TurnLRelaxed="Corrupted_Turn_L";
			TurnRRelaxed="Corrupted_Turn_R";
			WalkF="Corrupted_Walk";
			PlayerWalkF="Corrupted_Walk";
			WalkLF="Corrupted_Walk";
			PlayerWalkLF="Corrupted_Walk";
			WalkRF="Corrupted_Walk";
			PlayerWalkRF="Corrupted_Walk";
			WalkL="Corrupted_Walk";
			PlayerWalkL="Corrupted_Walk";
			WalkR="Corrupted_Walk";
			PlayerWalkR="Corrupted_Walk";
			WalkB="Corrupted_Walk";
			PlayerWalkB="Corrupted_Walk";
			WalkLB="Corrupted_Walk";
			PlayerWalkLB="Corrupted_Walk";
			WalkRB="Corrupted_Walk";
			PlayerWalkRB="Corrupted_Walk";
			SlowF="Corrupted_Run";
			PlayerSlowF="Corrupted_Run";
			SlowB="Corrupted_Run";
			PlayerSlowB="Corrupted_Run";
			FastF="Corrupted_Run";
			PlayerFastF="Corrupted_Run";
			combat="Corrupted_Walk";
			up="Corrupted_Walk";
			down="Corrupted_Walk";
			gear="Corrupted_Walk";
			upDegree="ManPosNoWeapon";
			PlayerSlowLF="Corrupted_Run";
			PlayerSlowRF="Corrupted_Run";
			PlayerSlowL="Corrupted_Run";
			PlayerSlowR="Corrupted_Run";
			PlayerSlowLB="Corrupted_Run";
			PlayerSlowRB="Corrupted_Run";
			FastLF="Corrupted_Run";
			FastRF="Corrupted_Run";
			FastL="Corrupted_Run";
			FastR="Corrupted_Run";
			FastLB="Corrupted_Run";
			FastRB="Corrupted_Run";
			TactF="Corrupted_Run";
			TactLF="Corrupted_Run";
			TactRF="Corrupted_Run";
			TactL="Corrupted_Run";
			TactR="Corrupted_Run";
			TactLB="Corrupted_Run";
			TactRB="Corrupted_Run";
			TactB="Corrupted_Run";
			PlayerTactF="Corrupted_Run";
			PlayerTactLF="Corrupted_Run";
			PlayerTactRF="Corrupted_Run";
			PlayerTactL="Corrupted_Run";
			PlayerTactR="Corrupted_Run";
			PlayerTactLB="Corrupted_Run";
			PlayerTactRB="Corrupted_Run";
			PlayerTactB="Corrupted_Run";
			Die="Corrupted_die";
			StartFreefall="Corrupted_in_AIR";
		};
		class WBK_Zombie_CORRUPTED_Moveset_inAir: WBK_Zombie_CORRUPTED_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="Corrupted_in_AIR";
			Up="Corrupted_in_AIR";
			Crouch="Corrupted_in_AIR";
			AdjustB="";
			Stand="Corrupted_in_AIR";
		};
	};
};
class cfgMovesWbkZombieCorrupted: CfgMovesBasic
{
	gestures="CfgGesturesZombieCorrupted";
	skeletonName="WBK_ZombieCreatureCorrupted_Skeleton";
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
		actions="WBK_Zombie_CORRUPTED_Moveset";
		file="\WBK_Zombies_Corrupted\animations\Corrupted_idle.rtm";
	};
	class StandBase: StandBase
	{
		actions="WBK_Zombie_CORRUPTED_Moveset";
		file="\WBK_Zombies_Corrupted\animations\Corrupted_idle.rtm";
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
		class Corrupted_idle: StandBase
		{
			ignoreMinPlayTime[]=
			{
				"Corrupted_die"
			};
			collisionShape="A3\anims_f\Data\Geom\Sdr\Ppne.p3d";
			boundingSphere=0.5;
			interpolationSpeed=2;
			file="\WBK_Zombies_Corrupted\animations\Corrupted_idle.rtm";
			duty=0.69999999;
			minPlayTime=1;
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			actions="WBK_Zombie_CORRUPTED_Moveset";
			speed=-3;
			canPullTrigger=0;
			canReload=0;
			limitGunMovement=1;
			headBobStrength=-1;
			soundEnabled=0;
			headBobMode=1;
			disableWeapons=0;
			disableWeaponsLong=0;
			enableMissile=1;
			enableOptics=1;
			aiming="aimingNo";
			head="noHead";
			legs="legsNo";
			variantsAI[]={};
			variantsPlayer[]={};
			ConnectTo[]={};
			ConnectFrom[]={};
			InterpolateTo[]=
			{
				"Corrupted_idle",
				0.0099999998,
				"Corrupted_Walk",
				0.0099999998,
				"Corrupted_Run",
				0.0099999998,
				"Corrupted_Turn_L",
				0.0099999998,
				"Corrupted_Turn_R",
				0.0099999998,
				"Corrupted_in_AIR",
				0.0099999998,
				"Corrupted_die",
				0.30000001,
				"Corrupted_attack_success_dying",
				0.30000001,
				"Corrupted_Attack",
				0.89999998,
				"Corrupted_Attack_Far",
				0.89999998,
				"Corrupted_attack_success_front",
				0.89999998,
				"Corrupted_attack_success_back",
				0.89999998
			};
			InterpolateFrom[]=
			{
				"Corrupted_idle",
				0.0099999998,
				"Corrupted_Walk",
				0.0099999998,
				"Corrupted_Run",
				0.0099999998,
				"Corrupted_Turn_L",
				0.0099999998,
				"Corrupted_Turn_R",
				0.0099999998,
				"Corrupted_in_AIR",
				0.0099999998,
				"Corrupted_die",
				0.30000001,
				"Corrupted_attack_success_dying",
				0.30000001,
				"Corrupted_Attack",
				0.89999998,
				"Corrupted_Attack_Far",
				0.89999998,
				"Corrupted_attack_success_front",
				0.89999998,
				"Corrupted_attack_success_back",
				0.89999998
			};
			preload=1;
		};
		class Corrupted_Walk: Corrupted_idle
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Walk.rtm";
			speed=-0.88;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class Corrupted_Run: Corrupted_Walk
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Walk.rtm";
			speed=-0.55000001;
		};
		class Corrupted_Turn_L: Corrupted_idle
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Turn_L.rtm";
			speed=-0.77999997;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class Corrupted_Turn_R: Corrupted_idle
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Turn_R.rtm";
			speed=-0.77999997;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class Corrupted_in_AIR: Corrupted_idle
		{
			actions="WBK_Zombie_CORRUPTED_Moveset_inAir";
			file="\WBK_Zombies_Corrupted\animations\Corrupted_in_AIR.rtm";
			speed=-2.5;
			soundEnabled=0;
		};
		class Corrupted_die: Corrupted_idle
		{
			interpolationSpeed=6;
			interpolationRestart=1;
			ignoreMinPlayTime[]={};
			soundEnabled=0;
			minPlayTime=0.99000001;
			speed=-1.35;
			file="\WBK_Zombies_Corrupted\animations\Corrupted_die.rtm";
			InterpolateTo[]={};
			InterpolateFrom[]={};
			variantsAI[]={};
			variantsPlayer[]={};
			looped="false";
		};
		class Corrupted_Attack: Corrupted_idle
		{
			variantsAI[]={};
			variantsPlayer[]={};
			interpolationSpeed=4;
			interpolationRestart=1;
			looped="false";
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Attack.rtm";
			speed=-2.5999999;
			minPlayTime=0.99000001;
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.16,0.52999997,0.91000003};
		};
		class Corrupted_Attack_Far: Corrupted_Attack
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_Attack_Far.rtm";
			speed=-2;
			soundEnabled=0;
		};
		class Corrupted_attack_success_front: Corrupted_Attack
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_attack_success_front.rtm";
			speed=-8;
			soundEnabled=0;
		};
		class Corrupted_attack_success_back: Corrupted_Attack
		{
			file="\WBK_Zombies_Corrupted\animations\Corrupted_attack_success_back.rtm";
			speed=-8;
			soundEnabled=0;
		};
		class Corrupted_attack_success_failed: Corrupted_Attack
		{
			minPlayTime=0.80000001;
			ignoreMinPlayTime[]={};
			file="\WBK_Zombies_Corrupted\animations\Corrupted_attack_success_failed.rtm";
			speed=-1;
			soundEnabled=0;
		};
	};
};
class cfgVehicles
{
	class I_Survivor_F;
	class WBK_C_ExportClass: I_Survivor_F
	{
		identityTypes[]=
		{
			"empty_Face"
		};
	};
	class WBK_SpecialZombie_Corrupted_1: WBK_C_ExportClass
	{
		side=2;
		editorSubcategory="WBK_Zombies_SpecialInfected";
		gestures="CfgGesturesZombieCorrupted";
		class SoundEnvironExt
		{
			generic[]=
			{
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_01.wav",
						1,
						1,
						30
					}
				},
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_02.wav",
						1,
						1,
						30
					}
				},
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_03.wav",
						1,
						1,
						30
					}
				}
			};
		};
		class SoundEquipment
		{
			soldier[]=
			{
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_01.wav",
						1,
						1,
						30
					}
				},
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_02.wav",
						1,
						1,
						30
					}
				},
				
				{
					"run",
					
					{
						"\WBK_Zombies_Corrupted\sounds\step_03.wav",
						1,
						1,
						30
					}
				}
			};
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
		uniformClass="Corrupted_uniform";
		nakedUniform="Corrupted_uniform";
		faction="WBK_AI_ZHAMBIES";
		_generalMacro="WBK_AI_ZHAMBIES";
		vehicleclass="Men";
		displayName="Corrupted";
		moves="cfgMovesWbkZombieCorrupted";
		model="WBK_Zombies_Corrupted\cryingHead.p3d";
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
			"\WBK_Zombies_Corrupted\textures\skull_v2_CO.paa"
		};
		hiddenSelectionsMaterials[]=
		{
			"\WBK_Zombies_Corrupted\textures\CryingHead.rvmat"
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
	class WBK_SpecialZombie_Corrupted_2: WBK_SpecialZombie_Corrupted_1
	{
		side=1;
	};
	class WBK_SpecialZombie_Corrupted_3: WBK_SpecialZombie_Corrupted_1
	{
		side=0;
	};
};
class cfgWeapons
{
	class Uniform_Base;
	class UniformItem;
	class Corrupted_uniform: Uniform_Base
	{
		displayname="Corrupted";
		model="WBK_Zombies_Corrupted\cryingHead.p3d";
		scope=1;
		picture="";
		hiddenSelections[]={};
		hiddenSelectionsTextures[]={};
		class ItemInfo: UniformItem
		{
			containerclass="Supply200";
			mass=30;
			uniformclass="Corrupted_uniform";
			uniformmodel="-";
		};
	};
};
class Extended_Killed_Eventhandlers
{
	class WBK_SpecialZombie_Corrupted_1
	{
		class WBK_SpecialZombie_Corrupted_1_Death
		{
			killed="_target = _this select 0;if (local _target) then {removeUniform _target; detach _target;};";
		};
	};
};
class Extended_InitPost_EventHandlers
{
	class WBK_SpecialZombie_Corrupted_1
	{
		class Zombie_Corrupted_Init
		{
			init="_unit = _this select 0; if (local _unit) then {_unit execVM '\WBK_Zombies_Corrupted\AI\WBK_AI_CorruptedHead.sqf';};";
		};
	};
};
class Extended_PreInit_EventHandlers
{
	class WBK_Zombies_Corrupted_PreInit
	{
		init="call compile preprocessFileLineNumbers '\WBK_Zombies_Corrupted\XEH_preInit.sqf'";
	};
};
class cfgMods
{
	author="WebKnight";
	timepacked="1734896560";
};
