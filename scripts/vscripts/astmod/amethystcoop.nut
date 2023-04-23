//-----------------------------------------------------------------------------------------------------------------------------
// SETTINGS loaded at the start of the game
//-----------------------------------------------------------------------------------------------------------------------------
DirectorOptions <-
{
	ActiveChallenge 				= 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	ShouldAllowSpecialsWithTank 	= 1
	ShouldAllowMobsWithTank 		= 0
	cm_SpecialRespawnInterval 		= 3 //Time for an SI spawn slot to become available
	SpecialInitialSpawnDelayMin 	= 0 //Time between spawns in any particular SI class
	SpecialInitialSpawnDelayMax 	= 0
	cm_SpecialSlotCountdownTime 	= 0
	PreferredSpecialDirection 		= 4
	cm_HeadshotOnly 				= 0

	RelaxMaxInterval 				= 1 //Maximum time to spend in the RELAX tempo.
	RelaxMinInterval 				= 1 //Minimum time to spend in the RELAX tempo.


	DominatorLimit 			= 3
	cm_BaseSpecialLimit 	= 3
	cm_MaxSpecials 			= 3
	BoomerLimit 			= 1
	SpitterLimit 			= 0
	HunterLimit 			= 1
	JockeyLimit 			= 1
	ChargerLimit 			= 1
	SmokerLimit 			= 0
}

MapData <-{
	g_nSI 	= 3
	g_nTime = 3
}

function update_diff()
{
	local difficulty = Convars.GetStr("das_fakedifficulty");
	local timer = Convars.GetStr("ast_sitimer");
	switch (difficulty) {
		case "1":
			DirectorOptions.HunterLimit = 1
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 0
			DirectorOptions.SpitterLimit = 0
			DirectorOptions.JockeyLimit = 1
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 4
			//MapData.g_nSI = 3
			//MapData.g_nTime = 3
			switch (timer) {
				case "0":
					MapData.g_nTime = 6
					MapData.g_nSI = 1
					break;
				case "1":
					MapData.g_nTime = 3
					MapData.g_nSI = 3
					break;
				case "2":
					MapData.g_nTime = 2
					MapData.g_nSI = 3
					break;
				case "3":
					MapData.g_nTime = 0
					MapData.g_nSI = 3
					break;
				default:
					MapData.g_nTime = 3
					MapData.g_nSI = 3
					break;
			}
			break;
		case "2":
			DirectorOptions.HunterLimit = 2
			DirectorOptions.SmokerLimit = 0
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.SpitterLimit = 0
			DirectorOptions.JockeyLimit = 1
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 4
			//MapData.g_nSI = 4
			//MapData.g_nTime = 6
			switch (timer) {
				case "0":
					MapData.g_nTime = 10
					MapData.g_nSI = 3
					break;
				case "1":
					MapData.g_nTime = 8
					MapData.g_nSI = 4
					break;
				case "2":
					MapData.g_nTime = 6
					MapData.g_nSI = 4
					break;
				case "3":
					MapData.g_nTime = 0
					MapData.g_nSI = 4
					break;
				default:
					MapData.g_nTime = 8
					MapData.g_nSI = 4
					break;
			}
			break;
		case "3":
			DirectorOptions.HunterLimit = 3
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.SpitterLimit = 1
			DirectorOptions.JockeyLimit = 1
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 1
			MapData.g_nSI = 6
			//MapData.g_nTime = 22
			switch (timer) {
				case "0":
					MapData.g_nTime = 26
					break;
				case "1":
					MapData.g_nTime = 22
					break;
				case "2":
					MapData.g_nTime = 18
					break;
				case "3":
					MapData.g_nTime = 0
					break;
				default:
					MapData.g_nTime = 22
					break;
			}
			break;
		case "4":
			DirectorOptions.HunterLimit = 4
			DirectorOptions.SpitterLimit = 1
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.JockeyLimit = 1
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 1
			MapData.g_nSI = 6
			//MapData.g_nTime = 17
			switch (timer) {
				case "0":
					MapData.g_nTime = 22
					break;
				case "1":
					MapData.g_nTime = 17
					break;
				case "2":
					MapData.g_nTime = 14
					break;
				case "3":
					MapData.g_nTime = 0
					break;
				default:
					MapData.g_nTime = 17
					break;
			}
			break;
		default:
			DirectorOptions.HunterLimit = 1
			DirectorOptions.SmokerLimit = 0
			DirectorOptions.BoomerLimit = 0
			DirectorOptions.SpitterLimit = 0
			DirectorOptions.JockeyLimit = 1
			DirectorOptions.ChargerLimit = 1
			MapData.g_nSI = 3
			MapData.g_nTime = 3
			break;
	}
	DirectorOptions.cm_BaseSpecialLimit 					= MapData.g_nSI
	DirectorOptions.cm_MaxSpecials 							= MapData.g_nSI
	DirectorOptions.DominatorLimit 							= MapData.g_nSI
	DirectorOptions.cm_SpecialRespawnInterval 		= MapData.g_nTime
	DirectorOptions.cm_SpecialSlotCountdownTime 	= MapData.g_nTime
}
update_diff();
g_ModeScript.update_diff();
