class CfgPatches
{
	class WBK_Zombies_Goliaph
	{
		author="WebKnight";
		units[]=
		{
			"WBK_Goliaph_1",
			"WBK_Goliaph_2",
			"WBK_Goliaph_3"
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
class CfgMovesBasicSpaceMarine
{
	class Actions
	{
		class Acts_CarFixingWheel_actions;
		class WBK_Goliaph_Sync_Human: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_1";
		};
		class WBK_Goliaph_Sync_Human2: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_2";
		};
		class WBK_Goliaph_Sync_Human3: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledThrust";
		};
		class WBK_Goliaph_Sync_Human4: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_1";
		};
		class WBK_Goliaph_Sync_Human5: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_2";
		};
		class WBK_Goliaph_Sync_Human6: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_3";
		};
		class WBK_Goliaph_Sync_Human7: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_4";
		};
	};
};
class CfgMovesMaleSpaceMarine: CfgMovesBasicSpaceMarine
{
	gestures="CfgGesturesSpaceMarine";
	skeletonName="SpaceMarine_ManSkeleton";
	class States
	{
		class HubShootingRangeKneel_move1;
		class Goliaph_Sync_1: HubShootingRangeKneel_move1
		{
			boundingSphere=5;
			minPlayTime=0.55000001;
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			interpolationspeed=6;
			interpolationrestart=1;
			looped=0;
			aimPrecision=3;
			ignoreMinPlayTime[]={};
			duty=-0.5;
			actions="WBK_Goliaph_Sync_Human";
			file="\WBK_Zombies_Goliath\animations\Sync_1_SpaceMarine.rtm";
			stamina=-0.1;
			speed=-1.3;
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
		class Goliaph_Sync_2: Goliaph_Sync_1
		{
			minPlayTime=0.85000002;
			file="\WBK_Zombies_Goliath\animations\Sync_2_SpaceMarine.rtm";
			speed=-2.75;
			actions="WBK_Goliaph_Sync_Human2";
		};
		class Goliaph_Sync_ImpaledThrust: Goliaph_Sync_1
		{
			minPlayTime=0.99000001;
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledThrust_SM.rtm";
			speed=-2.5;
			actions="WBK_Goliaph_Sync_Human3";
			InterpolateTo[]={};
		};
		class Goliaph_Sync_ImpaledGround_1: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_1_SM.rtm";
			actions="WBK_Goliaph_Sync_Human4";
		};
		class Goliaph_Sync_ImpaledGround_2: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_2_SM.rtm";
			actions="WBK_Goliaph_Sync_Human5";
		};
		class Goliaph_Sync_ImpaledGround_3: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_3_SM.rtm";
			actions="WBK_Goliaph_Sync_Human6";
		};
		class Goliaph_Sync_ImpaledGround_4: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_4_SM.rtm";
			actions="WBK_Goliaph_Sync_Human7";
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
		class WBK_Goliaph_Moveset: NoActions
		{
			Disable_Gesture[]=
			{
				"Disable_Gesture",
				"Gesture"
			};
			stance="ManStanceUndefined";
			useFastMove=1;
			turnSpeed=2;
			LimpF="Goliaph_Walk";
			LimpLF="Goliaph_Walk";
			LimpRF="Goliaph_Walk";
			LimpL="Goliaph_Walk";
			LimpR="Goliaph_Walk";
			LimpB="Goliaph_Walk";
			LimpLB="Goliaph_Walk";
			LimpRB="Goliaph_Walk";
			stop="Goliaph_Idle_1";
			default="Goliaph_Idle_1";
			stopRelaxed="Goliaph_Idle_1";
			TurnL="Goliaph_Walk";
			TurnR="Goliaph_Walk";
			TurnLRelaxed="Goliaph_Walk";
			TurnRRelaxed="Goliaph_Walk";
			WalkF="Goliaph_Walk";
			PlayerWalkF="Goliaph_Walk";
			WalkLF="Goliaph_Walk";
			PlayerWalkLF="Goliaph_Walk";
			WalkRF="Goliaph_Walk";
			PlayerWalkRF="Goliaph_Walk";
			WalkL="Goliaph_Walk";
			PlayerWalkL="Goliaph_Walk";
			WalkR="Goliaph_Walk";
			PlayerWalkR="Goliaph_Walk";
			WalkB="Goliaph_Run_B";
			PlayerWalkB="Goliaph_Run_B";
			WalkLB="Goliaph_Run_B";
			PlayerWalkLB="Goliaph_Run_B";
			WalkRB="Goliaph_Run_B";
			PlayerWalkRB="Goliaph_Run_B";
			SlowF="Goliaph_Run";
			PlayerSlowF="Goliaph_Run";
			SlowB="Goliaph_Run_B";
			PlayerSlowB="Goliaph_Run_B";
			PlayerFastF="Goliaph_Run";
			combat="Goliaph_Idle_1";
			up="Goliaph_Run";
			down="Goliaph_Run";
			gear="Goliaph_Idle_1";
			upDegree="ManPosNoWeapon";
			PlayerSlowLF="Goliaph_Run";
			PlayerSlowRF="Goliaph_Run";
			PlayerSlowL="Goliaph_Run";
			PlayerSlowR="Goliaph_Run";
			PlayerSlowLB="Goliaph_Run_B";
			PlayerSlowRB="Goliaph_Run_B";
			FastF="Goliaph_Run";
			FastLF="Goliaph_Run";
			FastRF="Goliaph_Run";
			FastL="Goliaph_Run";
			FastR="Goliaph_Run";
			FastLB="Goliaph_Run";
			FastRB="Goliaph_Run";
			TactF="Goliaph_Run";
			TactLF="Goliaph_Run";
			TactRF="Goliaph_Run";
			TactL="Goliaph_Run";
			TactR="Goliaph_Run";
			TactLB="Goliaph_Run_B";
			TactRB="Goliaph_Run_B";
			TactB="Goliaph_Run_B";
			PlayerTactF="Goliaph_Run";
			PlayerTactLF="Goliaph_Run";
			PlayerTactRF="Goliaph_Run";
			PlayerTactL="Goliaph_Run";
			PlayerTactR="Goliaph_Run";
			PlayerTactLB="Goliaph_Run_B";
			PlayerTactRB="Goliaph_Run_B";
			PlayerTactB="Goliaph_Run_B";
			Die="Goliaph_Death";
			StartFreefall="Goliaph_Walk";
			Unconscious="Goliaph_Walk";
		};
		class WBK_Goliaph_Moveset_MOVEB: WBK_Goliaph_Moveset
		{
			turnSpeed=4.5;
			PlayerCrouch="Goliaph_Run_B";
			Up="Goliaph_Run_B";
			Crouch="Goliaph_Run_B";
			AdjustB="";
			Stand="Goliaph_Idle_1";
		};
		class Acts_CarFixingWheel_actions;
		class WBK_Goliaph_Sync_Human: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_1";
		};
		class WBK_Goliaph_Sync_Human2: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_2";
		};
		class WBK_Goliaph_Sync_Human3: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledThrust";
		};
		class WBK_Goliaph_Sync_Human4: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_1";
		};
		class WBK_Goliaph_Sync_Human5: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_2";
		};
		class WBK_Goliaph_Sync_Human6: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_3";
		};
		class WBK_Goliaph_Sync_Human7: Acts_CarFixingWheel_actions
		{
			Default="Goliaph_Sync_ImpaledGround_4";
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
		class Goliaph_Sync_1: HubShootingRangeKneel_move1
		{
			boundingSphere=5;
			minPlayTime=0.55000001;
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			interpolationspeed=6;
			interpolationrestart=1;
			looped=0;
			aimPrecision=3;
			ignoreMinPlayTime[]={};
			duty=-0.5;
			actions="WBK_Goliaph_Sync_Human";
			file="\WBK_Zombies_Goliath\animations\Sync_1_Human.rtm";
			stamina=-0.1;
			speed=-1.3;
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
		class Goliaph_Sync_2: Goliaph_Sync_1
		{
			minPlayTime=0.85000002;
			file="\WBK_Zombies_Goliath\animations\Sync_2_Human.rtm";
			speed=-2.75;
			actions="WBK_Goliaph_Sync_Human2";
		};
		class Goliaph_Sync_ImpaledThrust: Goliaph_Sync_1
		{
			minPlayTime=0.99000001;
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledThrust.rtm";
			speed=-2.5;
			actions="WBK_Goliaph_Sync_Human3";
			InterpolateTo[]={};
		};
		class Goliaph_Sync_ImpaledGround_1: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_1.rtm";
			actions="WBK_Goliaph_Sync_Human4";
		};
		class Goliaph_Sync_ImpaledGround_2: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_2.rtm";
			actions="WBK_Goliaph_Sync_Human5";
		};
		class Goliaph_Sync_ImpaledGround_3: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_3.rtm";
			actions="WBK_Goliaph_Sync_Human6";
		};
		class Goliaph_Sync_ImpaledGround_4: Goliaph_Sync_ImpaledThrust
		{
			file="\WBK_Zombies_Goliath\animations\Sync_Human_ImpaledGround_4.rtm";
			actions="WBK_Goliaph_Sync_Human7";
		};
	};
};
class CfgGesturesMale;
class CfgGestures_WBK_Goliaph: CfgGesturesMale
{
	skeletonName="WBK_Goliaph_Skeleton";
	class ManActions
	{
	};
	class Actions;
	class Default;
	class BlendAnims;
	class States
	{
		class Disable_Gesture: Default
		{
			speed=1;
			file="\WBK_Zombies_Goliath\animations\Idle.rtm";
			disableWeapons=0;
			interpolationRestart=2;
			enableOptics=1;
			weaponIK=0;
			looped=0;
			leftHandIKBeg=0;
			leftHandIKCurve[]={0};
			leftHandIKEnd=0;
			rightHandIKBeg=0;
			rightHandIKCurve[]={0};
			rightHandIKEnd=0;
		};
	};
};
class CfgMoves_WBK_Goliaph: CfgMovesMaleSdr
{
	gestures="CfgGestures_WBK_Goliaph";
	skeletonName="WBK_Goliaph_Skeleton";
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
		actions="WBK_Securitron_Moveset";
		file="\WBK_Zombies_Goliath\animations\Idle.rtm";
	};
	class StandBase: StandBase
	{
		actions="WBK_Securitron_Moveset";
		file="\WBK_Zombies_Goliath\animations\Idle.rtm";
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
		class Goliaph_Idle_1: StandBase
		{
			relSpeedMin=0.60000002;
			relSpeedMax=1;
			minPlayTime=0.80000001;
			ignoreMinPlayTime[]=
			{
				"Goliaph_Walk",
				"Goliaph_Run",
				"Goliaph_Run_B",
				"Goliaph_Death",
				"Goliaph_Melee_1",
				"Goliaph_Melee_2",
				"Goliaph_Melee_3",
				"Goliaph_Melee_Run_1",
				"Goliaph_Taunt",
				"Goliaph_Throw"
			};
			boundingSphere=6;
			interpolationSpeed=2;
			interpolationRestart=1;
			file="\WBK_Zombies_Goliath\animations\Idle.rtm";
			duty=0.1;
			actions="WBK_Goliaph_Moveset";
			variantAfter[]={4,5,7};
			variantsAI[]=
			{
				"Goliaph_Idle_1",
				0.5,
				"Goliaph_Idle_2",
				0.5
			};
			variantsPlayer[]=
			{
				"Goliaph_Idle_1",
				0.5,
				"Goliaph_Idle_2",
				0.5
			};
			speed=-8;
			canPullTrigger=1;
			canReload=1;
			limitGunMovement=0.5;
			headBobStrength=0;
			headBobMode=0;
			disableWeapons=0;
			disableWeaponsLong=0;
			enableMissile=1;
			enableOptics=1;
			leaning="empty";
			aiming="empty";
			aimingBody="empty";
			head="empty";
			legs="legsDefault_WBK_Goliaph";
			InterpolateTo[]=
			{
				"Goliaph_Idle_1",
				0.0099999998,
				"Goliaph_Idle_2",
				0.0099999998,
				"Goliaph_Walk",
				0.0099999998,
				"Goliaph_Run",
				0.0099999998,
				"Goliaph_Run_B",
				0.0099999998,
				"Goliaph_Death",
				0.0099999998,
				"Goliaph_Melee_1",
				0.0099999998,
				"Goliaph_Melee_2",
				0.0099999998,
				"Goliaph_Melee_3",
				0.0099999998,
				"Goliaph_Taunt",
				0.0099999998,
				"Goliaph_Melee_Run_1",
				0.0099999998,
				"Goliaph_Throw",
				0.0099999998
			};
			InterpolateFrom[]={};
			preload=1;
		};
		class Goliaph_Idle_2: Goliaph_Idle_1
		{
			file="\WBK_Zombies_Goliath\animations\Idle1.rtm";
		};
		class Goliaph_Walk: Goliaph_Idle_1
		{
			interpolationRestart=1;
			minPlayTime=0;
			speed=-1.9;
			file="\WBK_Zombies_Goliath\animations\walk.rtm";
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.5,0.94999999};
			variantsAI[]={};
			variantsPlayer[]={};
		};
		class Goliaph_Run: Goliaph_Walk
		{
			speed=-0.94999999;
			file="\WBK_Zombies_Goliath\animations\run.rtm";
			soundEdge[]={0.44999999,0.89999998};
		};
		class Goliaph_Run_B: Goliaph_Walk
		{
			speed=-1;
			file="\WBK_Zombies_Goliath\animations\run_B.rtm";
			soundEdge[]={0.44999999,0.89999998};
			actions="WBK_Goliaph_Moveset_MOVEB";
		};
		class Goliaph_Death: Goliaph_Walk
		{
			soundEnabled=0;
			minPlayTime=0.99000001;
			speed=-2.5;
			file="\WBK_Zombies_Goliath\animations\death.rtm";
			actions="WBK_Goliaph_Moveset";
			InterpolateTo[]={};
			InterpolateFrom[]={};
			variantsAI[]={};
			variantsPlayer[]={};
			looped="false";
		};
		class Goliaph_Melee_1: Goliaph_Idle_1
		{
			variantsAI[]={};
			variantsPlayer[]={};
			interpolationSpeed=3.5;
			interpolationRestart=1;
			looped="false";
			file="\WBK_Zombies_Goliath\animations\attack_1.rtm";
			speed=-3.4000001;
			minPlayTime=0.99000001;
			ignoreMinPlayTime[]=
			{
				"Goliaph_Death"
			};
			soundOverride="run";
			soundEnabled=1;
			soundEdge[]={0.16,0.52999997,0.91000003};
		};
		class Goliaph_Melee_Run_1: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_Run_1.rtm";
			speed=-1;
			soundEdge[]={0.44999999,0.89999998};
		};
		class Goliaph_Melee_2: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_2.rtm";
			speed=-2.2;
			soundEnabled=0;
		};
		class Goliaph_Melee_3: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_3.rtm";
			speed=-3.4000001;
			soundEdge[]={0.1,0.25,0.83999997};
		};
		class Goliaph_Taunt: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\taunt.rtm";
			speed=-2.8;
			soundEnabled=0;
		};
		class Goliaph_Throw: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\throw.rtm";
			speed=-3;
			soundEdge[]={0.1,0.25,0.83999997};
		};
		class Goliaph_Sync_1: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\Sync_1.rtm";
			speed=-1.8;
			soundEnabled=0;
		};
		class Goliaph_Sync_2: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\Sync_2.rtm";
			speed=-3.4000001;
			soundEnabled=0;
		};
		class Goliaph_Spikes: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_Spikes.rtm";
			speed=-4.3000002;
			soundEnabled=0;
		};
		class Goliaph_RockThrow: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_RockThrow.rtm";
			speed=-4.1999998;
			soundEnabled=0;
		};
		class Goliaph_Staggered: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\stagger.rtm";
			speed=-2.3;
			soundEnabled=0;
		};
		class Goliaph_VehicleGrab: Goliaph_Melee_1
		{
			file="\WBK_Zombies_Goliath\animations\attack_VehicleGrab.rtm";
			speed=-4.3000002;
			soundEnabled=0;
		};
	};
	class BlendAnims: BlendAnims
	{
		legsDefault_WBK_Goliaph[]=
		{
			"G_Leg_1_R",
			0.19999997,
			"G_Leg_1_L",
			0.19999997,
			"G_Leg_2_R",
			0.34999999,
			"G_Leg_2_L",
			0.34999999,
			"G_Leg_3_R",
			0.64999998,
			"G_Leg_3_L",
			0.64999998,
			"G_Leg_4_R",
			1,
			"G_Leg_4_L",
			1
		};
	};
};
class CfgSounds
{
	sounds[]={};
	class Goliath_Swing_1
	{
		name="Goliath_Swing_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\swing_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_Swing_2
	{
		name="Goliath_Swing_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\swing_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_Swing_3
	{
		name="Goliath_Swing_3";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\swing_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_rangeAttack
	{
		name="Goliath_rangeAttack";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\rangeAttack.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Goliath_GroundHit
	{
		name="Goliath_GroundHit";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\groundHit.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Goliath_Taunt_1
	{
		name="Goliath_Taunt_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\taunt_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_Taunt_2
	{
		name="Goliath_Taunt_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\taunt_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_human_hit_1
	{
		name="Goliath_human_hit_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\human_hit_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_human_hit_2
	{
		name="Goliath_human_hit_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\human_hit_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_human_hit_3
	{
		name="Goliath_human_hit_3";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\human_hit_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_1
	{
		name="Goliath_V_idle_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_2
	{
		name="Goliath_V_idle_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_3
	{
		name="Goliath_V_idle_3";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_3.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_4
	{
		name="Goliath_V_idle_4";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_4.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_5
	{
		name="Goliath_V_idle_5";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_5.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_idle_6
	{
		name="Goliath_V_idle_6";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Idle_6.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_Death
	{
		name="Goliath_V_Death";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Death.ogg",
			4.466836,
			1
		};
		titles[]={};
	};
	class Goliath_V_Roar_1
	{
		name="Goliath_V_Roar_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Roar_1.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_Roar_2
	{
		name="Goliath_V_Roar_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Roar_2.ogg",
			3.1622777,
			1
		};
		titles[]={};
	};
	class Goliath_V_Roar_Dist_1
	{
		name="Goliath_V_Roar_Dist_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Roar_Far_1.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Goliath_V_Roar_Dist_2
	{
		name="Goliath_V_Roar_Dist_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Roar_Far_2.ogg",
			5.6234136,
			1
		};
		titles[]={};
	};
	class Goliath_V_Attack_1
	{
		name="Goliath_V_Attack_1";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Attack_1.ogg",
			3.9810717,
			1
		};
		titles[]={};
	};
	class Goliath_V_Attack_2
	{
		name="Goliath_V_Attack_2";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Attack_2.ogg",
			3.9810717,
			1
		};
		titles[]={};
	};
	class Goliath_V_Attack_3
	{
		name="Goliath_V_Attack_3";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Attack_3.ogg",
			3.9810717,
			1
		};
		titles[]={};
	};
	class Goliath_V_Attack_4
	{
		name="Goliath_V_Attack_4";
		sound[]=
		{
			"\WBK_Zombies_Goliath\sounds\G_Attack_4.ogg",
			3.9810717,
			1
		};
		titles[]={};
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
	class WBK_Goliaph_1: WBK_C_ExportClass
	{
		side=1;
		faction="WBK_AI_ZHAMBIES";
		_generalMacro="WBK_Goliaph_1";
		editorSubcategory="WBK_Zombies_SpecialInfected";
		gestures="CfgGestures_WBK_Goliaph";
		hiddenSelections[]={};
		hiddenSelectionsTextures[]={};
		class SoundEnvironExt
		{
			tarmac[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			generic[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			water_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			water[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			metal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_metal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			wavymetal[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			gridmetal_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_metalplate_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			metalplatepressed_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			metalplate_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			steel_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			wavymetal_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			steel[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			softwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_softwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_wood[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			wood[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_solidwood_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			sand[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			sand_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			gravel2[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			gravel[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			gravel_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			dirt[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			dirt_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			rock[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			mud[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			mud_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			forest[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			forest_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			tiling[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			grass[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			drygrass[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			grass_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			grasstall_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			pavement_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			stony[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			concrete[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			road[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			concrete_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			asphalt_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_concrete_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			stones_exp[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			hallway[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			concrete_Ext[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			normalExt[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_tiles[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				}
			};
			int_concrete[]=
			{
				
				{
					"run",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
					}
				},
				
				{
					"walk",
					
					{
						"soundset",
						"WBK_Goliath_Footsteps_SoundSet"
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
			breath1[]={};
			breath2[]={};
			breath3[]={};
			breath4[]={};
			breath5[]={};
			breath6[]={};
			breath7[]={};
			breath8[]={};
			breath9[]={};
			breath10[]={};
			breath11[]={};
			breath12[]={};
			breath13[]={};
			breath14[]={};
			breath15[]={};
			breath16[]={};
			breath17[]={};
			breath18[]={};
		};
		class SoundBreathAiming
		{
			breath[]={};
			breath1[]={};
			breath2[]={};
			breath3[]={};
			breath4[]={};
			breath5[]={};
			breath6[]={};
			breath7[]={};
			breath8[]={};
			breath9[]={};
			breath10[]={};
			breath11[]={};
			breath12[]={};
			breath13[]={};
			breath14[]={};
			breath15[]={};
			breath16[]={};
			breath17[]={};
			breath18[]={};
		};
		class SoundDrown
		{
			breath[]={};
			breath1[]={};
			breath2[]={};
			breath3[]={};
			breath4[]={};
			breath5[]={};
			breath6[]={};
			breath7[]={};
			breath8[]={};
			breath9[]={};
			breath10[]={};
			breath11[]={};
			breath12[]={};
			breath13[]={};
			breath14[]={};
			breath15[]={};
			breath16[]={};
			breath17[]={};
			breath18[]={};
		};
		class SoundInjured
		{
			person_moan1[]={};
			person_moan2[]={};
			person_moan3[]={};
			person_moan4[]={};
			person_moan5[]={};
			person_moan6[]={};
			person_moan7[]={};
			person_moan8[]={};
			person_moan9[]={};
			person_moan10[]={};
			person_moan11[]={};
			person_moan12[]={};
			person_moan13[]={};
			person_moan14[]={};
			person_moan15[]={};
			person_moan16[]={};
			person_moan17[]={};
			person_moan18[]={};
		};
		class SoundBleeding
		{
			breath[]={};
		};
		class SoundChoke
		{
			breath[]={};
			breath1[]={};
			breath2[]={};
			breath3[]={};
			breath4[]={};
			breath5[]={};
			breath6[]={};
			breath7[]={};
			breath8[]={};
			breath9[]={};
			breath10[]={};
			breath11[]={};
			breath12[]={};
			breath13[]={};
			breath14[]={};
			breath15[]={};
			breath16[]={};
			breath17[]={};
			breath18[]={};
		};
		class SoundRecovered
		{
			Person1[]={};
			Person2[]={};
			Person3[]={};
			Person4[]={};
			Person5[]={};
			Person6[]={};
			Person7[]={};
			Person8[]={};
			Person9[]={};
			Person10[]={};
			Person11[]={};
			Person12[]={};
			Person13[]={};
			Person14[]={};
			Person15[]={};
			Person16[]={};
			Person17[]={};
			Person18[]={};
		};
		class SoundBreathAutomatic
		{
			breath[]={};
			breath0[]={};
		};
		class SoundBreathInjured
		{
			Person1[]={};
			Person2[]={};
			Person3[]={};
			Person4[]={};
			Person5[]={};
			Person6[]={};
			Person7[]={};
			Person8[]={};
			Person9[]={};
			Person10[]={};
			Person11[]={};
			Person12[]={};
			Person13[]={};
			Person14[]={};
			Person15[]={};
			Person16[]={};
			Person17[]={};
			Person18[]={};
		};
		class SoundBurning
		{
			Person1[]={};
			Person2[]={};
			Person3[]={};
			Person4[]={};
			Person5[]={};
			Person6[]={};
			Person7[]={};
			Person8[]={};
			Person9[]={};
			Person10[]={};
			Person11[]={};
			Person12[]={};
			Person13[]={};
			Person14[]={};
			Person15[]={};
			Person16[]={};
			Person17[]={};
			Person18[]={};
		};
		class SoundBreathSwimming
		{
			breathSwimming1[]={};
		};
		class SoundHitScream
		{
			Person1[]={};
			Person2[]={};
			Person3[]={};
			Person4[]={};
			Person5[]={};
			Person6[]={};
			Person7[]={};
			Person8[]={};
			Person9[]={};
			Person10[]={};
			Person11[]={};
			Person12[]={};
			Person13[]={};
			Person14[]={};
			Person15[]={};
			Person16[]={};
			Person17[]={};
			Person18[]={};
		};
		items[]={};
		uniformClass="Goliaph_Uniform";
		nakedUniform="Goliaph_Uniform";
		vehicleclass="Men";
		displayName="Goliath";
		moves="CfgMoves_WBK_Goliaph";
		model="WBK_Zombies_Goliath\WBK_Zombies_Goliath.p3d";
		armor=7;
		scope=2;
		canCarryBackPack=1;
		canDeactivateMines=0;
		engineer=0;
		attendant=1;
		threat[]={1,1,1};
		type=1;
		cost=10000000;
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
		respawnweapons[]=
		{
			"Throw",
			"Put"
		};
		respawnMagazines[]={};
		linkedItems[]=
		{
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		RespawnlinkedItems[]=
		{
			"ItemGPS",
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
	};
	class WBK_Goliaph_2: WBK_Goliaph_1
	{
		side=2;
	};
	class WBK_Goliaph_3: WBK_Goliaph_1
	{
		side=0;
	};
	class Land_DragonsTeeth_01_1x1_new_F;
	class Goliath_Shard_1: Land_DragonsTeeth_01_1x1_new_F
	{
		scope=2;
		scopeCurator=2;
		model="WBK_Zombies_Goliath\Goliath_Shard_90.p3d";
		displayName="Goliath Shard";
		mapSize=20.27;
		destrType="DestructNo";
		accuracy=0.2;
		animated=0;
		armor=20000;
		cost=0;
	};
	class Goliath_HitBox: Goliath_Shard_1
	{
		model="WBK_Zombies_Goliath\WBK_Zombies_HitBox.p3d";
		displayName="Goliath body";
	};
};
class Extended_Killed_Eventhandlers
{
	class WBK_Goliaph_1
	{
		class WBK_Goliaph_1_Death
		{
			killed="_target = _this select 0;if (local _target) then {removeUniform _target; [_target,'Goliaph_Death'] remoteExec ['switchMove',0];};";
		};
	};
	class CAManBase
	{
		class WBK_Goliaph_KillAGuy_Death
		{
			killed="_target = _this select 0; _killer = _this select 1; if ((local _target) && (_killer isKindOf 'WBK_Goliaph_1')) then {_target spawn WBK_Goliath_ShardKill;};";
		};
	};
};
class Extended_PreInit_EventHandlers
{
	class WBK_Zombies_Goliath_PreInit
	{
		init="call compile preprocessFileLineNumbers '\WBK_Zombies_Goliath\XEH_preInit.sqf'";
	};
};
class Extended_InitPost_EventHandlers
{
	class WBK_Goliaph_1
	{
		class Zombie_Goliath_Init
		{
			init="_unit = _this select 0; if (local _unit) then {_unit execVM '\WBK_Zombies_Goliath\AI\WBK_Goliath_AI.sqf';};";
		};
	};
};
class WeaponFireGun;
class WeaponCloudsGun;
class WeaponFireMGun;
class WeaponCloudsMGun;
class Mode_SemiAuto;
class Mode_Burst;
class Mode_FullAuto;
class SlotInfo;
class MuzzleSlot;
class CowsSlot;
class PointerSlot;
class UnderBarrelSlot;
class cfgWeapons
{
	class ItemCore;
	class UniformItem;
	class Uniform_Base;
	class HeadgearItem;
	class Vest_Camo_Base;
	class VestItem;
	class Goliaph_Uniform: Uniform_Base
	{
		displayname="Goliaph";
		model="WBK_Zombies_Goliath\WBK_Zombies_Goliath.p3d";
		scope=1;
		picture="";
		hiddenSelections[]={};
		hiddenSelectionsTextures[]={};
		class ItemInfo: UniformItem
		{
			containerclass="Supply200";
			mass=30;
			uniformclass="Goliaph_Uniform";
			uniformmodel="-";
		};
	};
};
class CfgSoundSets
{
	class Rifle_Shot_Base_SoundSet;
	class WBK_GShard_Exp_SoundSet: Rifle_Shot_Base_SoundSet
	{
		soundShaders[]=
		{
			"WBK_GShard_Exp_Close",
			"WBK_GShard_Exp_Far"
		};
		volumeFactor=1;
		volumeCurve="InverseSquare2Curve";
		sound3DProcessingType="WeaponMediumShot3DProcessingType";
		distanceFilter="weaponShotDistanceFreqAttenuationFilter";
		spatial=1;
		doppler=0;
		loop=0;
	};
	class footsteps_roofTiles_sprint_Exp_SoundSet;
	class WBK_Goliath_Footsteps_SoundSet: footsteps_roofTiles_sprint_Exp_SoundSet
	{
		soundShaders[]=
		{
			"WBK_Goliath_FootStep_Close",
			"WBK_Goliath_FootStep_Far"
		};
		volumeFactor=1;
	};
};
class CfgSoundShaders
{
	class WBK_GShard_Exp_Close
	{
		samples[]=
		{
			
			{
				"\WBK_Zombies_Goliath\sounds\Goliath_Shard_Close",
				1
			}
		};
		volume=1;
		range=250;
		rangeCurve[]=
		{
			{0,1},
			{220,1},
			{250,1},
			{2800,0}
		};
	};
	class WBK_GShard_Exp_Far
	{
		samples[]=
		{
			
			{
				"\WBK_Zombies_Goliath\sounds\Goliath_Shard_Far",
				1
			}
		};
		volume=1.1;
		range=2800;
		rangeCurve[]=
		{
			{0,0},
			{220,0.5},
			{250,1},
			{2800,1}
		};
	};
	class WBK_Goliath_FootStep_Close
	{
		frequency=1;
		samples[]=
		{
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_footstep_1",
				1
			},
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_footstep_2",
				1
			},
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_footstep_3",
				1
			}
		};
		volume=1.7;
		range=85;
	};
	class WBK_Goliath_FootStep_Far
	{
		frequency=1;
		samples[]=
		{
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_farfootstep_1",
				1
			},
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_farfootstep_2",
				1
			},
			
			{
				"\WBK_Zombies_Goliath\sounds\goliaph_farfootstep_3",
				1
			}
		};
		volume=1.7;
		range=600;
	};
};
class cfgAmmo
{
	class Missile_AA_03_F;
	class Goliath_Projectile: Missile_AA_03_F
	{
		CraterEffects="";
		craterShape="";
		explosionSoundEffect="";
		craterWaterEffects="ImpactEffectsWater";
		effectsMissileInit="";
		effectsFire="CannonFire";
		explosionEffects="EffectMOPMS";
		effectsMissile="missile3";
		fuseDistance=1;
		hit=1500;
		explosive=0;
		indirectHit=250;
		thrustTime=500;
		indirectHitRange=0.1;
		model="WBK_Zombies_Goliath\Goliath_Projectile.p3d";
		SoundSetExplosion[]=
		{
			"WBK_GShard_Exp_SoundSet"
		};
		soundFly[]=
		{
			"\WBK_Zombies_Goliath\sounds\goliath_projectile_loop",
			2,
			1,
			400
		};
	};
};
class cfgMods
{
	author="WebKnight";
	timepacked="1734896578";
};
