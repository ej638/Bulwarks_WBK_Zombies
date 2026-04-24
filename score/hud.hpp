#define killPoints_idc 99999

class KillPointsHud {
	idd = -1;
    fadeout=0;
    fadein=0;
	duration = 10000000000;
	name= "KillPointsHud";
	onLoad = "uiNamespace setVariable ['KillPointsHud', _this select 0]";

	class controlsBackground {
		// Full-screen red overlay — alpha driven by fn_playerDamageTint.
		// Defined first so it renders behind the score text box.
		class DamageTintOverlay: RscStructuredText
		{
			idc = 99998;
			type = CT_STRUCTURED_TEXT;
			x = SafeZoneX;
			y = SafeZoneY;
			w = SafeZoneW;
			h = SafeZoneH;
			colorText[] = {0, 0, 0, 0};
			colorBackground[] = {1, 0, 0, 0};
			text = "";
		};
		class KillPointsHud_1:RscStructuredText
		{
			idc = killPoints_idc;
			type = CT_STRUCTURED_TEXT;
			size = 0.040;
			x = (SafeZoneX + 0);
			y = (SafeZoneY + 0.015);
			w = 0.2; h = 0.18;
			colorText[] = {1,1,1,1};
			lineSpacing = 3;
			colorBackground[] = {0,0,0,0.3};
			text = "Text";
			font = "PuristaLight";
			shadow = 2;
			class Attributes {
				align = "left";
			};
		};

	};
};
