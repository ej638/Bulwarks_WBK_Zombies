class CfgPatches
{
	class WBK_Zombies_AdvancedEditorSettings
	{
		units[]={};
		weapons[]={};
		requiredVersion=1;
		requiredAddons[]=
		{
			"3DEN"
		};
		is3DENmod=1;
	};
};
class Cfg3DEN
{
	class Object
	{
		class AttributeCategories
		{
			class WBK_ZombiesEditorLoadd
			{
				displayName="WebKnight's Zombies";
				collapsed=1;
				class Attributes
				{
					class WBK_e3den_loadZombieAI
					{
						displayName="Load Zombie AI";
						tooltip="Load zombie AI on this unit.";
						property="WBK_e3den_loadZombieAI";
						control="Combo";
						expression="_this setVariable ['WBK_ZombieEden_LoadingNum', _value]; systemChat 'Zombie AI loaded on this unit';";
						defaultValue=0;
						class Values
						{
							class doNotLoadAnything
							{
								name="Not Load Anything";
								tooltip="Zombie Ai will not be loaded";
								value=0;
							};
							class Crawler
							{
								name="Crawler";
								value=1;
							};
							class Walker
							{
								name="Walker";
								value=2;
							};
							class Shambler
							{
								name="Shambler";
								value=3;
							};
							class Sprint_A
							{
								name="Sprinter (Angry)";
								value=4;
							};
							class Sprint_C
							{
								name="Sprinter (Calm)";
								value=5;
							};
							class Shooter
							{
								name="Triggerman";
								value=6;
							};
							class Corrupted
							{
								name="Corrupted body";
								value=7;
							};
							class MeleeShambler
							{
								name="Zombie with melee";
								value=8;
							};
						};
						unique=0;
						validate="none";
						condition="objectControllable";
						typeName="NUMBER";
					};
				};
			};
		};
	};
};
class cfgMods
{
	author="WebKnight";
	timepacked="1734896517";
};
