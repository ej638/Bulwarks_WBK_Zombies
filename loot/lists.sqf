/**
*  loot/lists
*
*  Hardcoded loot whitelist — only these items will spawn as loot.
*  No config scanning or blacklist; edit arrays directly to change loot pool.
*
*  Weapon magazines are auto-resolved from CfgWeapons config at spawn time
*  (spawnLoot.sqf uses getArray >> "magazines"), so they don't need separate entries.
*
*  Domain: Server
**/

// --- Hats (CfgWeapons, ItemInfo type 605) ---
List_Hats = [
    "H_Cap_blk_ION",
    "H_Bandanna_gry",
    "H_Bandanna_khk",
    "H_Bandanna_camo",
    "H_Beret_blk",
    "H_Beret_Colonel",
    "H_Booniehat_oli",
    "H_Booniehat_tan",
    "H_Cap_grn_BI",
    "H_Cap_surfer",
    "H_Hat_brown",
    "H_MilCap_mcamo",
    "H_Cap_headphones",
    "H_Shemag_olive",
    "H_StrawHat",
    "H_HelmetLeaderO_oucamo",
    "H_HelmetSpecO_ocamo",
    "H_HelmetB_snakeskin",
    "H_HelmetCrew_B",
    "H_HelmetB_light_grass",
    "H_HelmetB_desert"
];

// --- Uniforms (CfgWeapons, ItemInfo type 801) ---
List_Uniforms = [
    "U_BG_leader",
    "U_B_CombatUniform_mcam",
    "U_B_CombatUniform_mcam_tshirt",
    "U_I_OfficerUniform",
    "U_I_CombatUniform_shortsleeve",
    "U_C_Poloshirt_redwhite",
    "U_C_Poloshirt_tricolour",
    "U_B_CTRG_1",
    "U_O_CombatUniform_ocamo",
    "U_B_GhillieSuit",
    "U_BG_Guerrilla_6_1",
    "U_OrestesBody",
    "U_O_OfficerUniform_ocamo",
    "U_B_CombatUniform_mcam_vest",
    "U_I_G_Story_Protagonist_F"
];

// --- Vests (CfgWeapons, ItemInfo type 701) ---
List_Vests = [
    "V_PlateCarrier2_blk",
    "V_Chestrig_khk",
    "V_PlateCarrierIA2_dgtl",
    "V_HarnessOGL_brn",
    "V_BandollierB_khk",
    "V_TacVest_camo",
    "V_PlateCarrier1_rgr"
];

// --- Backpacks (CfgVehicles, vehicleClass "Backpacks") ---
List_Backpacks = [
    "B_AssaultPack_ocamo",
    "B_Carryall_cbr",
    "B_FieldPack_cbr",
    "B_Kitbag_mcamo",
    "B_TacticalPack_oli",
    "B_AssaultPack_Kerry"
];

// --- Primary Weapons (CfgWeapons, type 1) ---
List_Primaries = [
    "arifle_CTAR_ghex_F",        // CAR-95       → 30Rnd_580x42_Mag_F
    "arifle_AK12_F",             // AK-12        → 30Rnd_762x39_Mag_F
    "srifle_GM6_camo_F",         // GM6 Lynx     → 5Rnd_127x108_Mag
    "LMG_03_F",                  // LIM-85       → 200Rnd_556x45_Box_F
    "srifle_LRR_camo_F",         // M320 LRR     → 7Rnd_408_Mag
    "srifle_EBR_F",              // Mk18 ABR     → 20Rnd_762x51_Mag
    "arifle_Mk20_F",             // Mk20         → 30Rnd_556x45_Stanag
    "LMG_Mk200_F",              // Mk200        → 200Rnd_65x39_cased_Box
    "arifle_MX_SW_F",           // MX SW        → 100Rnd_65x39_caseless_mag
    "arifle_MXC_khk_F",         // MXC          → 30Rnd_65x39_caseless_mag
    "arifle_MXM_F",             // MXM          → 30Rnd_65x39_caseless_mag
    "hgun_PDW2000_F",           // PDW2000      → 30Rnd_9x21_Mag
    "srifle_DMR_01_F",          // Rahim        → 10Rnd_762x51_Mag
    "arifle_SDAR_F",            // SDAR         → 30Rnd_556x45_Stanag, 20Rnd_556x45_UW_mag
    "SMG_02_F",                  // Sting        → 30Rnd_9x21_Mag
    "arifle_TRG21_F",           // TRG-21       → 30Rnd_556x45_Stanag
    "arifle_ARX_hex_F",         // Type 115     → 30Rnd_65x39_caseless_green, 10Rnd_50BW_Mag_F
    "SMG_01_F",                  // Vermin       → 30Rnd_45ACP_Mag_SMG_01
    "LMG_Zafir_F",              // Zafir        → 150Rnd_762x51_Box
    "SMG_03_black",              // ADR-97       → 50Rnd_570x28_SMG_03
    "arifle_AKS_F",             // AKS-74U      → 30Rnd_545x39_Mag_F
    "arifle_CTARS_ghex_F",      // CAR-95 GL    → 30Rnd_580x42_Mag_F
    "arifle_Katiba_F",          // Katiba       → 30Rnd_65x39_caseless_green
    "arifle_MX_GL_F"            // MX 3GL       → 30Rnd_65x39_caseless_mag, 3Rnd_HE_Grenade_shell
];

// --- Secondary Weapons (CfgWeapons, type 3) ---
List_Secondaries = [
    "hgun_Rook40_F",             // Rook-40      → 16Rnd_9x21_Mag
    "hgun_Pistol_heavy_01_F",    // 4-five       → 11Rnd_45ACP_Mag
    "hgun_ACPC2_F",              // ACP-C2       → 9Rnd_45ACP_Mag
    "hgun_P07_F",                // P07          → 16Rnd_9x21_Mag
    "hgun_Pistol_heavy_02_F"     // Zubr .45     → 6Rnd_45ACP_Cylinder
];

// --- Launchers (CfgWeapons, type 4) ---
List_Launchers = [
    "launch_RPG7_F",             // RPG-7        → RPG7_F
    "launch_RPG32_F",            // RPG-42       → RPG32_F, RPG32_HE_F
    "launch_NLAW_F"              // PCML         → NLAW_F
];

// --- Optics & Attachments (CfgWeapons, ItemInfo type 201/301) ---
List_Optics = [
    "optic_MRCO",
    "optic_DMS",
    "optic_LRPS",
    "optic_SOS",
    "optic_Nightstalker",
    "optic_NVS",
    "optic_Hamr",
    "optic_tws",
    "optic_Arco"
];

// --- Items (CfgWeapons misc: FAK, Medikit, GPS, etc.) ---
List_Items = [
    "FirstAidKit",
    "Medikit",
    "ItemGPS",
    "ItemCompass",
    "ItemMap",
    "ItemWatch",
    "ItemRadio"
];

// --- Glasses (CfgGlasses) ---
List_Glasses = [
    "G_Aviator",
    "G_Bandanna_aviator",
    "G_Spectacles",
    "G_Tactical_Black"
];

// --- Grenades (CfgMagazines — thrown explosives) ---
List_Grenades = [
    "HandGrenade",
    "MiniGrenade"
];

// --- Mines (CfgMagazines — not used, kept empty for pool compatibility) ---
List_Mines = [];

// --- Charges (CfgMagazines — placed explosives) ---
List_Charges = [
    "DemoCharge_Remote_Mag",
    "ClaymoreDirectionalMine_Remote_Mag",
    "SatchelCharge_Remote_Mag"
];

// --- Composite Lists (consumed by editMe.sqf LOOT pools and spin box) ---
List_AllWeapons = List_Primaries + List_Secondaries + List_Launchers;
List_AllClothes = List_Hats + List_Uniforms + List_Glasses;
