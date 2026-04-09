disableSerialization;
221919 cutRsc ["WBK_ZombieDesc_First","PLAIN"];
waitUntil {!isNull (uiNameSpace getVariable "WBK_ZombieDesc_First")};
_display = uiNameSpace getVariable "WBK_ZombieDesc_First";
_setText = _display displayCtrl 1001;
_setText ctrlSetStructuredText (parseText format ["<t size='4.9' align='center' valign='middle' font='EtelkaMonospacePro'>Select zombie type. The Ai will be loaded on a WHOLE GROUP! So do not forget about that. Special Infected can be found in every single side in WBK Zombies faction.</t>", player]);
_setText ctrlSetBackgroundColor [0,0,0,0.5];
waitUntil {!(dialog)};
221919 cutRsc ["default","PLAIN"];