class CfgPatches
{
	class WBK_Zombies_SpecialInfected
	{
		name="WBK Special Infected";
		author="Big Red & Webknight";
		requiredVersion=1.6;
		requiredAddons[]=
		{
			"A3_Air_F",
			"A3_Air_F_Beta",
			"A3_Weapons_F",
			"A3_Data_F",
			"A3_Soft_F"
		};
		units[]=
		{
			"WBK_IK_SacristianSuitCfgVeh"
		};
		weapons[]=
		{
			""
		};
		magazines[]=
		{
			""
		};
		ammo[]=
		{
			""
		};
	};
};
class CfgVehicles
{
	class I_Survivor_F;
	class WBK_SpecialInfected_Bloater_Cfg: I_Survivor_F
	{
		author="Red";
		scope=1;
		scopeCurator=1;
		scopeArsenal=1;
		displayName="Zombie Bloater";
		identityTypes[]=
		{
			"LanguageENG_F",
			"Head_NATO",
			"G_NATO_default"
		};
		model="\WBK_Zombies\special_Infected\Smog.p3d";
		uniformclass="WBK_SpecialInfected_Bloater";
		hiddenSelections[]=
		{
			"camo",
			"camob"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\Bloater_Body_CO.paa",
			"\WBK_Zombies\special_Infected\textures\Bloater_Lungs_CO.paa"
		};
		backpack="";
		linkedItems[]=
		{
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		RespawnLinkedItems[]=
		{
			"ItemMap",
			"ItemCompass",
			"ItemWatch",
			"ItemRadio"
		};
		weapons[]={};
		respawnWeapons[]={};
		magazines[]={};
		respawnMagazines[]={};
	};
	class WBK_SpecialInfected_Screamer_Cfg: WBK_SpecialInfected_Bloater_Cfg
	{
		displayName="Screamer";
		model="\WBK_Zombies\special_Infected\Screamer.p3d";
		uniformclass="WBK_SpecialInfected_Screamer";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\screamer_CO.paa"
		};
	};
	class WBK_SpecialInfected_Leaper_1_Cfg: WBK_SpecialInfected_Bloater_Cfg
	{
		displayName="Leaper";
		model="\WBK_Zombies\special_Infected\Leaper_1.p3d";
		uniformclass="WBK_SpecialInfected_Leaper_1";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\leaper_1_CO.paa"
		};
	};
	class WBK_SpecialInfected_Leaper_2_Cfg: WBK_SpecialInfected_Bloater_Cfg
	{
		displayName="Leaper";
		model="\WBK_Zombies\special_Infected\Leaper_2.p3d";
		uniformclass="WBK_SpecialInfected_Leaper_2";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\leaper_2_CO.paa"
		};
	};
};
class ItemInfo;
class CfgWeapons
{
	class Uniform_Base;
	class WBK_SpecialInfected_Bloater: Uniform_Base
	{
		scope=1;
		scopeCurator=1;
		scopeArsenal=1;
		displayName="Zombie Bloater";
		model="\WBK_Zombies\special_Infected\Smog.p3d";
		hiddenSelections[]=
		{
			"camo",
			"camob"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\Bloater_Body_CO.paa",
			"\WBK_Zombies\special_Infected\textures\Bloater_Lungs_CO.paa"
		};
		class ItemInfo: ItemInfo
		{
			scope=1;
			uniformClass="WBK_SpecialInfected_Bloater_Cfg";
			model="\WBK_Zombies\special_Infected\Smog.p3d";
			hiddenSelections[]=
			{
				"camo",
				"camob"
			};
			hiddenSelectionsTextures[]=
			{
				"\WBK_Zombies\special_Infected\textures\Bloater_Body_CO.paa",
				"\WBK_Zombies\special_Infected\textures\Bloater_Lungs_CO.paa"
			};
		};
	};
	class WBK_SpecialInfected_Screamer: Uniform_Base
	{
		scope=1;
		scopeCurator=1;
		scopeArsenal=1;
		displayName="Zombie Screamer";
		model="\WBK_Zombies\special_Infected\Screamer.p3d";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\screamer_CO.paa"
		};
		class ItemInfo: ItemInfo
		{
			scope=1;
			uniformClass="WBK_SpecialInfected_Screamer_Cfg";
			model="\WBK_Zombies\special_Infected\Screamer.p3d";
			hiddenSelections[]=
			{
				"camo"
			};
			hiddenSelectionsTextures[]=
			{
				"\WBK_Zombies\special_Infected\textures\screamer_CO.paa"
			};
		};
	};
	class WBK_SpecialInfected_Leaper_1: Uniform_Base
	{
		scope=1;
		scopeCurator=1;
		scopeArsenal=1;
		displayName="Zombie Leaper";
		model="\WBK_Zombies\special_Infected\Leaper_1.p3d";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\leaper_1_CO.paa"
		};
		class ItemInfo: ItemInfo
		{
			scope=1;
			uniformClass="WBK_SpecialInfected_Leaper_1_Cfg";
			model="\WBK_Zombies\special_Infected\Leaper_1.p3d";
			hiddenSelections[]=
			{
				"camo"
			};
			hiddenSelectionsTextures[]=
			{
				"\WBK_Zombies\special_Infected\textures\leaper_1_CO.paa"
			};
		};
	};
	class WBK_SpecialInfected_Leaper_2: Uniform_Base
	{
		scope=1;
		scopeCurator=1;
		scopeArsenal=1;
		displayName="Zombie Leaper";
		model="\WBK_Zombies\special_Infected\Leaper_2.p3d";
		hiddenSelections[]=
		{
			"camo"
		};
		hiddenSelectionsTextures[]=
		{
			"\WBK_Zombies\special_Infected\textures\leaper_2_CO.paa"
		};
		class ItemInfo: ItemInfo
		{
			scope=1;
			uniformClass="WBK_SpecialInfected_Leaper_2_Cfg";
			model="\WBK_Zombies\special_Infected\Leaper_2.p3d";
			hiddenSelections[]=
			{
				"camo"
			};
			hiddenSelectionsTextures[]=
			{
				"\WBK_Zombies\special_Infected\textures\leaper_2_CO.paa"
			};
		};
	};
};
class cfgMods
{
	author="WebKnight";
	timepacked="1734896517";
};
