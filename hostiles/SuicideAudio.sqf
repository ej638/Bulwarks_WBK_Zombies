_wave = attkWave;

while {_wave == attkWave} do {
  _allHCs = entities "HeadlessClient_F";
  _allHPs = allPlayers - _allHCs;
  {
    if (side _x == east) then {
      _thisAI = _x;
      {
        if (((_thisAI distance2D _x) < 70) && (alive _thisAI)) then {
            [_thisAI, "SuicideSound"] remoteExec ["sound_fnc_say3DGlobal", 0];
            sleep random 3;
        }
      } forEach _allHPs;
    };
  } foreach allUnits;
  sleep 5;
};
