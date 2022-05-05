<?php

require_once 'vendor/autoload.php';

function transliterateString($txt) {
    $transliterationTable = array('á' => 'a', 'Á' => 'A', 'à' => 'a', 'À' => 'A', 'ă' => 'a', 'Ă' => 'A', 'â' => 'a', 'Â' => 'A', 'å' => 'a', 'Å' => 'A', 'ã' => 'a', 'Ã' => 'A', 'ą' => 'a', 'Ą' => 'A', 'ā' => 'a', 'Ā' => 'A', 'ä' => 'ae', 'Ä' => 'AE', 'æ' => 'ae', 'Æ' => 'AE', 'ḃ' => 'b', 'Ḃ' => 'B', 'ć' => 'c', 'Ć' => 'C', 'ĉ' => 'c', 'Ĉ' => 'C', 'č' => 'c', 'Č' => 'C', 'ċ' => 'c', 'Ċ' => 'C', 'ç' => 'c', 'Ç' => 'C', 'ď' => 'd', 'Ď' => 'D', 'ḋ' => 'd', 'Ḋ' => 'D', 'đ' => 'd', 'Đ' => 'D', 'ð' => 'dh', 'Ð' => 'Dh', 'é' => 'e', 'É' => 'E', 'è' => 'e', 'È' => 'E', 'ĕ' => 'e', 'Ĕ' => 'E', 'ê' => 'e', 'Ê' => 'E', 'ě' => 'e', 'Ě' => 'E', 'ë' => 'e', 'Ë' => 'E', 'ė' => 'e', 'Ė' => 'E', 'ę' => 'e', 'Ę' => 'E', 'ē' => 'e', 'Ē' => 'E', 'ḟ' => 'f', 'Ḟ' => 'F', 'ƒ' => 'f', 'Ƒ' => 'F', 'ğ' => 'g', 'Ğ' => 'G', 'ĝ' => 'g', 'Ĝ' => 'G', 'ġ' => 'g', 'Ġ' => 'G', 'ģ' => 'g', 'Ģ' => 'G', 'ĥ' => 'h', 'Ĥ' => 'H', 'ħ' => 'h', 'Ħ' => 'H', 'í' => 'i', 'Í' => 'I', 'ì' => 'i', 'Ì' => 'I', 'î' => 'i', 'Î' => 'I', 'ï' => 'i', 'Ï' => 'I', 'ĩ' => 'i', 'Ĩ' => 'I', 'į' => 'i', 'Į' => 'I', 'ī' => 'i', 'Ī' => 'I', 'ĵ' => 'j', 'Ĵ' => 'J', 'ķ' => 'k', 'Ķ' => 'K', 'ĺ' => 'l', 'Ĺ' => 'L', 'ľ' => 'l', 'Ľ' => 'L', 'ļ' => 'l', 'Ļ' => 'L', 'ł' => 'l', 'Ł' => 'L', 'ṁ' => 'm', 'Ṁ' => 'M', 'ń' => 'n', 'Ń' => 'N', 'ň' => 'n', 'Ň' => 'N', 'ñ' => 'n', 'Ñ' => 'N', 'ņ' => 'n', 'Ņ' => 'N', 'ó' => 'o', 'Ó' => 'O', 'ò' => 'o', 'Ò' => 'O', 'ô' => 'o', 'Ô' => 'O', 'ő' => 'o', 'Ő' => 'O', 'õ' => 'o', 'Õ' => 'O', 'ø' => 'oe', 'Ø' => 'OE', 'ō' => 'o', 'Ō' => 'O', 'ơ' => 'o', 'Ơ' => 'O', 'ö' => 'oe', 'Ö' => 'OE', 'ṗ' => 'p', 'Ṗ' => 'P', 'ŕ' => 'r', 'Ŕ' => 'R', 'ř' => 'r', 'Ř' => 'R', 'ŗ' => 'r', 'Ŗ' => 'R', 'ś' => 's', 'Ś' => 'S', 'ŝ' => 's', 'Ŝ' => 'S', 'š' => 's', 'Š' => 'S', 'ṡ' => 's', 'Ṡ' => 'S', 'ş' => 's', 'Ş' => 'S', 'ș' => 's', 'Ș' => 'S', 'ß' => 'SS', 'ť' => 't', 'Ť' => 'T', 'ṫ' => 't', 'Ṫ' => 'T', 'ţ' => 't', 'Ţ' => 'T', 'ț' => 't', 'Ț' => 'T', 'ŧ' => 't', 'Ŧ' => 'T', 'ú' => 'u', 'Ú' => 'U', 'ù' => 'u', 'Ù' => 'U', 'ŭ' => 'u', 'Ŭ' => 'U', 'û' => 'u', 'Û' => 'U', 'ů' => 'u', 'Ů' => 'U', 'ű' => 'u', 'Ű' => 'U', 'ũ' => 'u', 'Ũ' => 'U', 'ų' => 'u', 'Ų' => 'U', 'ū' => 'u', 'Ū' => 'U', 'ư' => 'u', 'Ư' => 'U', 'ü' => 'ue', 'Ü' => 'UE', 'ẃ' => 'w', 'Ẃ' => 'W', 'ẁ' => 'w', 'Ẁ' => 'W', 'ŵ' => 'w', 'Ŵ' => 'W', 'ẅ' => 'w', 'Ẅ' => 'W', 'ý' => 'y', 'Ý' => 'Y', 'ỳ' => 'y', 'Ỳ' => 'Y', 'ŷ' => 'y', 'Ŷ' => 'Y', 'ÿ' => 'y', 'Ÿ' => 'Y', 'ź' => 'z', 'Ź' => 'Z', 'ž' => 'z', 'Ž' => 'Z', 'ż' => 'z', 'Ż' => 'Z', 'þ' => 'th', 'Þ' => 'Th', 'µ' => 'u', 'а' => 'a', 'А' => 'a', 'б' => 'b', 'Б' => 'b', 'в' => 'v', 'В' => 'v', 'г' => 'g', 'Г' => 'g', 'д' => 'd', 'Д' => 'd', 'е' => 'e', 'Е' => 'E', 'ё' => 'e', 'Ё' => 'E', 'ж' => 'zh', 'Ж' => 'zh', 'з' => 'z', 'З' => 'z', 'и' => 'i', 'И' => 'i', 'й' => 'j', 'Й' => 'j', 'к' => 'k', 'К' => 'k', 'л' => 'l', 'Л' => 'l', 'м' => 'm', 'М' => 'm', 'н' => 'n', 'Н' => 'n', 'о' => 'o', 'О' => 'o', 'п' => 'p', 'П' => 'p', 'р' => 'r', 'Р' => 'r', 'с' => 's', 'С' => 's', 'т' => 't', 'Т' => 't', 'у' => 'u', 'У' => 'u', 'ф' => 'f', 'Ф' => 'f', 'х' => 'h', 'Х' => 'h', 'ц' => 'c', 'Ц' => 'c', 'ч' => 'ch', 'Ч' => 'ch', 'ш' => 'sh', 'Ш' => 'sh', 'щ' => 'sch', 'Щ' => 'sch', 'ъ' => '', 'Ъ' => '', 'ы' => 'y', 'Ы' => 'y', 'ь' => '', 'Ь' => '', 'э' => 'e', 'Э' => 'e', 'ю' => 'ju', 'Ю' => 'ju', 'я' => 'ja', 'Я' => 'ja');
    return str_replace(array_keys($transliterationTable), array_values($transliterationTable), $txt);
}

function getRandomDecimalVariation() {
	return (rand(0, 2) / 10) - 0.1; // e.g. -0.99 - 0.1
}

function getRandomWholeVariation() {
	return rand(0, 10) - 3; // e.g. -5 - 5
}

class ApiManager {

	private $pdo;

	private $apiKey = "";

	// when changing this, be careful to test the `if ($playerTeamRow)` part with a known player transfer 
	private $season = 2022;
	
	// we we know we can't use the api or testing
	private $useCache = true;

	// how many api request have been done since our last sleep
	private $httpRequestCount = 0;

	// how much the api throttles us by per minute
	private $httpRequestLimit = 10;

	// overrides before we do an insert/update
	private $playerTableColumnOverrides = [];

	const TEAM_TYPE_CLUB_ID = 1;
	const TEAM_TYPE_NATION_ID = 2;

	const METHOD_TEAM = "teams";
	const METHOD_TEAM_NAMES_FAKE = "teams:names:fake";
	const METHOD_TEAM_NAMES_RESTORE = "teams:names:restore";
	const METHOD_PLAYERS = "players";
	const METHOD_PLAYERS_ALL = "players:all";
	const METHOD_PLAYERS_REBASE = "players:rebase";
	const METHOD_PLAYERS_POSITIONBYSKILL = "players:positionbyskill";
	const METHOD_PLAYERS_POSITIONBYSKILL_ALL = "players:positionbyskill:all";
	const METHOD_PLAYERS_IMPORT_CSV = "players:importcsv";
	const METHOD_PLAYERS_GENERATE_CSV = "players:csv:generate";
	const METHOD_PLAYERS_NAMES_FAKE = "players:names:fake";
	const METHOD_PLAYERS_NAMES_RESTORE = "players:names:restore";
	const METHOD_TEAM_SEARCH_NAME = "teams:search:name";
	const METHOD_TEAM_SEARCH_LEAGUE = "teams:search:league";

	const LAST_REQUEST_FILEPATH = __DIR__ . DIRECTORY_SEPARATOR . "last_request.json";

	/**
	 * We use this to determine position_number
	 * @var $formationLimit 
	 */
	private $formationLimits = [
		"442" => [
			'Goalkeeper' => 1,
			'Defender' => 4,
			'Midfielder' => 4,
			'Attacker' => 2,
		],
		"433" => [
			'Goalkeeper' => 1,
			'Defender' => 4,
			'Midfielder' => 3,
			'Attacker' => 3,
		],
		"532" => [
			'Goalkeeper' => 1,
			'Defender' => 5,
			'Midfielder' => 3,
			'Attacker' => 2,
		],
		"352" => [
			'Goalkeeper' => 1,
			'Defender' => 3,
			'Midfielder' => 5,
			'Attacker' => 2,
		],
	];

	/**
	 * We'll increment this when we loop the players 
	 * @var $formationLimit 
	 */
	private $positionNumber = 1;
	private $subPositionNumber = 12;

	private $settings = [];

	/**
	 * Return db path 
	 * @return {string}
	 */
	function __construct($settings = []) {
		$path = realpath(__DIR__ . '/../data/data.db');
		$this->pdo = new \PDO("sqlite:".$path);
		$this->httpRequestCount = 0;

		$this->settings = $settings;

		$env = require_once("env.php");

		// set up api env 
		$this->apiKey = $env["api_key"];

		// get info from last execution e.g. request count
		if (file_exists(self::LAST_REQUEST_FILEPATH)) {
			$lastRequest = json_decode(file_get_contents(self::LAST_REQUEST_FILEPATH), 1);
			$secondsSinceLastRequest = time() - $lastRequest["timestamp"];
			if ($secondsSinceLastRequest <= 60) {
				$this->httpRequestCount = $lastRequest["http_request_count"];
			}
		}
		
		// // load overrides
		// $playerTableColumnOverridesFile = realpath(__DIR__ . "/overrides/players.json");
		// if ($playerTableColumnOverridesFile) {
		// 	$this->playerTableColumnOverrides = json_decode(file_get_contents($playerTableColumnOverridesFile), 1);
		// }

		// warn that cache is off
		if (!$this->useCache) {
			echo "\Warning #: use cache option is turned off\n\n continue (1), turn cache on and continue (2) or exit (3)?\n\n";

			$stdin = fopen('php://stdin', 'r');
			$input = trim(fgets($stdin));
			switch ($input) {
				case "1":
					break;
				case "2":
					$this->useCache = true;
					break;
				default:
					exit();
			}
		}
	}

	/**
	 * Close connection 
	 */
	function __destruct() {
        $this->pdo = null;

		// log the last request
		file_put_contents(self::LAST_REQUEST_FILEPATH, json_encode([
			"timestamp" => time(),
			"http_request_count" => $this->httpRequestCount,
		]));
    }

	/**
	 * Set team names to fake e.g. Celtic -> Glasgow Green
	 */
	public function setPlayersNamesToFake() {

		$sql = "SELECT * FROM players LEFT JOIN countries ON countries.country_id = players.country_id";
		
		// loop through club teams only
		$stmt = $this->pdo->prepare($sql);

		// apply start and limit 
		if (!is_null($limit) and is_numeric($limit)) {
			$sql .= " LIMIT $start, $limit";
		} elseif (is_numeric($start) and $start > 0) {
			$sql .= " LIMIT $limit";
		}

		// 
		$stmt->execute();
		while ($playerRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
			$playerId = (int) $playerRow["player_id"];
			$displayName = $playerRow["display_name"];

			// replace vowels
			// $fakeDisplayName = str_replace(["ee", "a", "i", "o", "e", "u", "ss", "y", "sc"], ["i", "e", "y", "e", "u", "e", "sh", "i", "sk"], $displayName);
			$fakeDisplayName = str_replace([
				"ee", // 1
				"a", // 2
				"i", // 3
				"u", // 4
				"e", // 5
				"o", // 6
				"ss", // 7
				"y", // 8
				"sc" // 9
			], [
				"i", // 1
				"o", // 2
				"a", // 3
				"i", // 4
				"u", // 5
				"e", // 6
				"sh", // 7
				"ay", // 8
				"sk" // 9
			], $displayName);

			// remove first intial
			$fakeDisplayName = preg_replace("/^[A-Z]+\.\s(.*?)/", "$1", $fakeDisplayName);

			echo "Changing '$displayName' ($playerId) to: '$fakeDisplayName'\n";

			$values = [
				"display_name" => $fakeDisplayName,
			];

			$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
			
			$values = array_values($values);
			array_push($values, $playerId);

			$sql = "UPDATE players SET $updateSetColumnsString WHERE player_id = ?";
			$stmtUpdate = $this->pdo->prepare($sql);
			$success = $stmtUpdate->execute($values);
			
			var_dump($success);
		}
	}

	// /**
	//  * Set team names to fake e.g. Celtic -> Glasgow Green
	//  */
	// public function setPlayersNamesToReal($start = 0, $limit = null) {

	// 	$sql = "SELECT * FROM players";

	// 	// apply start and limit 
	// 	if (!is_null($limit) and is_numeric($limit)) {
	// 		$sql .= " LIMIT $start, $limit";
	// 	} elseif (is_numeric($start) and $start > 0) {
	// 		$sql .= " LIMIT $limit";
	// 	}

	// 	// loop through club teams only
	// 	$stmt = $this->pdo->prepare($sql);
	// 	$stmt->execute();
	// 	while ($playerRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
	// 		$playerId = (int) $playerRow["player_id"];
	// 		$apiPlayerId = (int) $playerRow["api_player_id"];

	// 		// get cache team file
	// 		$data = $this->httpRequest("players", [
	// 			"id" => $apiPlayerId,
	// 			"season" => $this->season,
	// 		]);

	// 		$playerData = @$data["response"][0]["player"];

	// 		$fullName = transliterateString($playerData["name"]);

	// 		echo "Restoring: '$fullName'\n";

	// 		$values = [
	// 			"display_name" => $fullName,
	// 		];

	// 		$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
			
	// 		$values = array_values($values);
	// 		array_push($values, $playerId);

	// 		$sql = "UPDATE players SET $updateSetColumnsString WHERE player_id = ?";
	// 		$stmtUpdate = $this->pdo->prepare($sql);
	// 		$success = $stmtUpdate->execute($values);
			
	// 		var_dump($success);
	// 	}
	// }

	/**
	 * Set team names to fake e.g. Celtic -> Glasgow Green
	 */
	public function setTeamsNamesToFake() {

		// get fake team name map
		$fakeTeamNames = json_decode(file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . "overrides/teams_fake_names.json"), 1);
		
		// loop through club teams only
		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id WHERE team_type = 'Club'");
		$stmt->execute();
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
			$teamId = (int) $teamRow["team_id"];
			$apiTeamId = (int) $teamRow["api_team_id"];
			$teamName = $teamRow["team_name"];

			@$values = $fakeTeamNames["$apiTeamId"];
			if ($values) {
				echo "Overriding '$teamName': " . json_encode($values) . "\n";

				$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
				
				$values = array_values($values);
				array_push($values, $teamId);

				$sql = "UPDATE teams SET $updateSetColumnsString WHERE team_id = ?";
				$stmtUpdate = $this->pdo->prepare($sql);
				$success = $stmtUpdate->execute($values);
				
				var_dump($success);
			} else {
				echo "Fake name not found for: '$teamName' ($apiTeamId)\n";
			}
		}
	}

	/**
	 * Set team names to fake e.g. Celtic -> Glasgow Green
	 */
	public function setTeamsNamesToReal() {

		// get the real name overrides 
		$teamRealNameOverrides = json_decode(file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . "overrides/teams.json"), 1);
		
		// first, loop through club teams only and restore from json cache
		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id WHERE team_type = 'Club'");
		$stmt->execute();
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
			$teamId = (int) $teamRow["team_id"];
			$apiTeamId = (int) $teamRow["api_team_id"];
			$teamName = $teamRow["team_name"];

			// get cache team file
			$data = $this->httpRequest("teams", [
				"id" => $apiTeamId,
			]);

			if ($teamData = @$data["response"][0]["team"]) {

				$values = [
					"team_name" => $teamData["name"],
					"short_name" => $teamData["name"],
					"hud_name" => strtoupper(substr($teamData["name"], 0, 3)),
				];

				// apply overrides e.g. hud
				if (@$overrides = $teamRealNameOverrides["$apiTeamId"]) {
					$intersectValues = array_intersect_key($overrides, $values);
					$values = array_merge($values, $intersectValues);
				}

				echo "Changing '$teamName' to: '{$teamData["name"]}'\n";
	
				$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
				
				$values = array_values($values);
				array_push($values, $teamId);
	
				$sql = "UPDATE teams SET $updateSetColumnsString WHERE team_id = ?";
				$stmtUpdate = $this->pdo->prepare($sql);
				$success = $stmtUpdate->execute($values);
				
				var_dump($success);
			}
		}

		// next use map to set , an as these are often manually updated 
	}

	/**
	 * Search teams by name 
	 * @param {string} $teamName e.g. Celtic
	 */
	public function searchTeamsByLeague($leagueId, $season = null) {
		
		if (is_null($season)) {
			$season = $this->season;
		}
		
		return $this->searchTeams([
			"league" => $leagueId,
			"season" => $season,
		]);
	}

	/**
	 * Search teams by name 
	 * @param {string} $teamName e.g. Celtic
	 */
	public function searchTeamsByName($teamName) {
		return $this->searchTeams([
			"name" => $teamName,
		]);
	}

	/**
	 * Search teams by name 
	 * @param {string} $teamName e.g. Celtic
	 */
	public function searchTeams($params) {
		$data = $this->httpRequest("teams", $params);
	
		echo "\nFOUND " . count($data["response"]) . " RESULTS (teamName: apiTeamId):\n";

		foreach ($data["response"] as $responseItem) {
			$teamData = $responseItem["team"];

			$apiTeamId = (int) $teamData["id"];		
			$teamName = transliterateString($teamData["name"]);
			
			echo "- $teamName: $apiTeamId\n";
		}
	}

	/**
	 * 
	 */
	public function loadTeam($apiTeamId) {
		$data = $this->httpRequest("teams", [
			"id" => $apiTeamId,
		]);

		// var_dump($data);
	
		foreach ($data["response"] as $responseItem) {
			$teamData = $responseItem["team"];
			$this->handleTeamDataFromApi($teamData);
		}
	}

	/**
	 * Set skill level based on team skill level, etc
	 */
	public function rebasePlayers() {

		// order is important - first rebase players based on national team, then overwrite those for club teams
		$teamTypes = ["Nation", "Club"];

		foreach ($teamTypes as $teamType) {
		
			// loop through teams
			$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id WHERE team_type = ?");
			$stmt->execute([$teamType]);
			while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
				
				// 
				$teamId = (int) $teamRow['team_id'];
				$teamName = $teamRow['team_name'];
				$teamSkillLevel = $teamRow['skill_level'];

				echo "Rebasing players in $teamName ($teamSkillLevel)\n";

				// 
				$stmt2 = $this->pdo->prepare("SELECT * FROM player_team 
					LEFT JOIN players ON players.player_id = player_team.player_id 
					WHERE team_id = ?
					ORDER BY position_number ASC");
	
				// 
				$stmt2->execute([$teamId]);
				while ($playerRow = $stmt2->fetch(PDO::FETCH_ASSOC)) {
				
					// from api 
					$apiPlayerId = (int) $playerRow["player_id"];
					$playerName = $playerRow["display_name"];
					$position = $playerRow["position"];
	
					// 
					$this->updatePlayerSkillLevelByPosition($playerRow, $teamSkillLevel, $position);
				}
			}
		}
	}

	/**
	 * Import player data from csv file e.g. hair skin color, rating etc
	 */
	public function importPlayersCSV() {
		$h = fopen(__DIR__ . DIRECTORY_SEPARATOR . "overrides/players.csv", "r");

		$isheader = true;
		while (($data = fgetcsv($h, 1000, ",")) !== FALSE) {
			if ($isheader) {
				$isheader = false;
				continue;
			}
			list($apiPlayerId, $name, $hairSkinColorId, $rating, $starRated) = $data;

			$playerRow = $this->getPlayerRowByApiId($apiPlayerId);
			$starRated = (int) $starRated;

			$this->updatePlayerSkillLevelByPosition($playerRow, $rating, $playerRow["position"], $starRated);

			echo "Importing players data: '$name'\n";

			$values = [
				"hair_skin_color_id" => (int) $hairSkinColorId,
			];

			$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
			
			$values = array_values($values);
			array_push($values, (int) $apiPlayerId);

			$sql = "UPDATE players SET $updateSetColumnsString WHERE api_player_id = ?";
			$stmtUpdate = $this->pdo->prepare($sql);
			$success = $stmtUpdate->execute($values);	
		}
	}

	/**
	 * 
	 */
	private function updatePlayerSkillLevelByPosition($playerRow, $rating, $position, $starRated = null) {

		$playerId = (int) $playerRow["player_id"];
		$apiPlayerId = (int) $playerRow["api_player_id"];

		$speed = $rating + getRandomWholeVariation();
		$acceleration = $rating + getRandomWholeVariation();
		$dribbling = $rating + getRandomWholeVariation();
		$goalkeeping = $rating + getRandomWholeVariation();
		$tackling = $rating + getRandomWholeVariation();
		$passing = $rating + getRandomWholeVariation();
		$heading = $rating + getRandomWholeVariation();
		$shooting = $rating + getRandomWholeVariation();
		
		// e.g. 70 -> 0.7
		$ratingDecimal = $rating / 120;

		$positionRating = $rating;

		// overrides - lower some e.g. shooting for goalkeepers
		switch ($position) {
			case "Goalkeeper":
				$heading *= ($ratingDecimal + getRandomDecimalVariation());
				$shooting *= ($ratingDecimal + getRandomDecimalVariation());

				$positionRating = round((($goalkeeping * 2) + $tackling) / 3);
				break;

			case "Defender":
				$goalkeeping *= ($ratingDecimal + getRandomDecimalVariation());
				$heading *= ($ratingDecimal + getRandomDecimalVariation());
				$shooting *= ($ratingDecimal + getRandomDecimalVariation());

				$positionRating = round(($tackling + $passing) / 2);
				break;
				
			case "Midfielder":
				$goalkeeping *= ($ratingDecimal + getRandomDecimalVariation());
				$heading *= ($ratingDecimal + getRandomDecimalVariation());
				// $shooting *= ($ratingDecimal + getRandomDecimalVariation());

				$positionRating = round(($tackling + $passing + $shooting) / 3);
				break;
			
			case "Attacker":
				$goalkeeping *= ($ratingDecimal + getRandomDecimalVariation());
				$tackling *= ($ratingDecimal + getRandomDecimalVariation());

				$positionRating = round(($shooting + $heading) / 2);
				break;						
		}
		
		// in some exceptional cases, we'll apply overrides
		$values = [
			"position" => $position,
			"goalkeeping" => round($goalkeeping),
			"tackling" => round($tackling),
			"passing" => round($passing),
			"heading" => round($heading),
			"shooting" => round($shooting),
			
			"speed" => round($speed),
			"acceleration" => round($acceleration),
			"dribbling" => round($dribbling),

			"rating" => $positionRating,
			"star_rated" => $starRated,
		];

		echo "-- UPDATING player skill levels: {$playerRow['display_name']} ($position) (".json_encode($values).") \n";

		$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
		
		$values = array_values($values);
		array_push($values, $playerId);

		$sql = "UPDATE players SET $updateSetColumnsString WHERE player_id = ?";
		$stmt = $this->pdo->prepare($sql);
		$success = $stmt->execute($values);
		
		var_dump($success);
	}

	/**
	 * 
	 */
	public function loadAllPlayers($season = null) {
		
		if (is_null($season)) {
			$season = $this->season;
		}

		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id");
		$stmt->execute();
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$this->loadPlayers($teamRow["api_team_id"], $season);
		}
	}

	// /**
	//  * 
	//  */
	// public function generatePlayersCSV() {
		
	// 	$stmt = $this->pdo->prepare("SELECT * FROM player_team 
	// 		LEFT JOIN players ON players.player_id = player_team.player_id 
	// 		GROUP BY player_id
	// 		ORDER BY position_number ASC");

	// 	$stmt->execute();

	// 	$columns = [
	// 		"player_id",
	// 		"display_name",
	// 		"speed",
	// 		"acceleration",
	// 		"dribbling",
	// 		"tackling",
	// 		"heading",
	// 		"goalkeeping",
	// 		"passing",
	// 		"shooting",
	// 		"hair_skin_color_id",
	// 		"country_id",
	// 		"api_player_id",
	// 		"position",
	// 		"position_number",
	// 		"shirt_number",
	// 		"player_id",
	// 	];

	// 	$csvRows = [implode(",", $columns)];
	// 	while ($playerRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
	// 		$row = [];
	// 		foreach($columns as $column) {
	// 			array_push($row, $playerRow[$column]);
	// 		}
	// 		array_push($csvRows, implode(",", $row));
	// 	}

	// 	$filepath = __DIR__ . DIRECTORY_SEPARATOR . "overrides" . DIRECTORY_SEPARATOR . "players.csv";
	// 	if (file_exists($filepath)) {
	// 		echo "ERROR: file already exists, please remove then run again";
	// 	} else {
	// 		file_put_contents($filepath, implode("\n", $csvRows));
	// 	}
	// }

	/**
	 * 
	 */
	public function loadPlayers($apiTeamId, $season = null) {
		
		if (is_null($season)) {
			$season = $this->season;
		}

		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id WHERE api_team_id = ?");
		$stmt->execute([$apiTeamId]);
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			echo "\n\n### Loading players for team: {$teamRow["team_name"]} ###\n\n";
			$this->loadPlayersFromApi($teamRow, $season);
			$this->loadPlayerSquadsFromApi($teamRow);
		}
	}

	/**
	 * To maximise use of the cached date, we'll replicate the process for adding players 
	 * so that we can hopefully depend on all the cache files being present. So first, it'll 
	 * query players by teamId, then query missing players individually
	 */
	public function loadPlayersRealNames($season = null) {
		
		if (is_null($season)) {
			$season = $this->season;
		}

		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id");
		$stmt->execute();
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
			$apiTeamId = $teamRow['api_team_id'];
			$teamId = (int) $teamRow['team_id'];
			$teamName = $teamRow['team_name'];
		
			$data = $this->httpRequest("players", [
				"team" => $apiTeamId,
				"season" => $season,
			]);
		
			$response = $data["response"];
		
			foreach ($response as $responseItem) {
				$playerData = $responseItem["player"];
				
				$apiPlayerId = $playerData['id'];
				$fullName = transliterateString($playerData["name"]);

				// remove first intial
				$fullName = preg_replace("/^[A-Z]+\.\s(.*?)/", "$1", $fullName);

				echo "Restoring: '$fullName'\n";

				$values = [
					"display_name" => $fullName,
				];

				$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
				
				$values = array_values($values);
				array_push($values, $apiPlayerId);

				$sql = "UPDATE players SET $updateSetColumnsString WHERE api_player_id = ?";
				$stmtUpdate = $this->pdo->prepare($sql);
				$success = $stmtUpdate->execute($values);
				
				var_dump($success);
			}


			// now query players/squads for any missing players...
			
			// get data from api 
			$data = $this->httpRequest("players/squads", [
				"team" => $apiTeamId,
			]);
			$response = $data["response"];

			foreach ($response[0]["players"] as $playerSquadData) {
		
				// from api 
				$apiPlayerId = (int) $playerSquadData["id"];
				$fullName = transliterateString($playerSquadData["name"]);

				echo "Restoring: '$fullName'\n";

				$values = [
					"display_name" => $fullName,
				];

				$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
				
				$values = array_values($values);
				array_push($values, $apiPlayerId);

				$sql = "UPDATE players SET $updateSetColumnsString WHERE api_player_id = ?";
				$stmtUpdate = $this->pdo->prepare($sql);
				$success = $stmtUpdate->execute($values);
				
				var_dump($success);

			}
		}
	}

	
	
	/**
	 * Load players from the api and write to players and player_team
	 */
	private function loadPlayersFromApi($teamRow, $season) {
	
		$teamId = $teamRow['team_id'];
		$apiTeamId = $teamRow['api_team_id'];
		$teamSkillLevel = $teamRow['skill_level'];
		$teamName = $teamRow['team_name'];
	
		echo "LOADING team data: {$teamRow["team_name"]}\n";
	
		$data = $this->httpRequest("players", [
			"team" => $apiTeamId,
			"season" => $season,
		]);
	
		$response = $data["response"];
	
		foreach ($response as $responseItem) {
			$playerData = $responseItem["player"];
			$this->handlePlayerDataFromApi($playerData, $teamRow);
		}
	}



	/**
	 * 
	 */
	private function loadPlayerSquadsFromApi($teamRow) {

		// 
		$teamId = (int) $teamRow['team_id'];
		$teamName = $teamRow['team_name'];
		$teamType = $teamRow['team_type'];
		$teamSkillLevel = $teamRow['skill_level'];
		$apiTeamId = $teamRow['api_team_id'];

		$formationLimit = $this->formationLimits["442"];

		// get data from api 
		$data = $this->httpRequest("players/squads", [
			"team" => $apiTeamId,
		], false); // remove false if want to use cache
		$response = $data["response"];

		// oragnise players into ordered positions e.g. Goalkeeper, Denfender, MF, Att
		$playerDataSortedByPosition = $this->sortPlayersByPosition($response[0]["players"]);

		// loop through each json item and insert/update
		$currentPosition = null;
		$positionLimitCount = 1;
		$outfieldPositionNumber = 1;
		$subPositionNumber = 12;

		// we'll store any matches from the overrides file here so they can be processed at the end
		$matchingPlayersSquadsOverrides = [];

		// $playersSquadsOverridesFile = realpath(__DIR__ . "/overrides/players_squads.json");
		// if ($playersSquadsOverridesFile) {
		// 	$playersSquadsOverrides = json_decode(file_get_contents($playersSquadsOverridesFile), 1);
		// }

		// we'll create an array of valid player IDs as we add/edit them, any not in the array at the 
		// end will be removed as they may have moved on to another club
		$validPlayerIds = [];

		foreach ($playerDataSortedByPosition as $playerSquadData) {
	
			// from api 
			$apiPlayerId = (int) $playerSquadData["id"];
			$shirtNumber = (int) $playerSquadData["number"];
			$playerName = $playerSquadData["name"];
			$position = $playerSquadData["position"];

			// get the player row, should be in there by now 
			// we don't have nationality possibly, but if the player doesn't exist in players
			// we need to create an entry there. load the player from the api, then insert
			$playerRow = $this->getPlayerRowByApiId($apiPlayerId);
			if (!$playerRow) {
				
				$data = $this->httpRequest("players", [
					"id" => $apiPlayerId,
					"season" => $this->season,
				]);

				// if no players found even still, put into db with squad data only?
				if (empty($data["response"]) > 0) {
					$playerData = [
						"id" => $apiPlayerId,
						"name" => $playerName,
						"nationality" => null, // what can we do??
					];
				} else {
					$playerData = $data["response"][0]["player"];
				}

				$this->handlePlayerDataFromApi($playerData, $teamRow);

				// try again 
				$playerRow = $this->getPlayerRowByApiId($apiPlayerId);

			}

			$playerId = (int) $playerRow["player_id"];

			// append to valid player ids 
			array_push($validPlayerIds, $playerId);

			// If player position is empty then we can assume that skill levels haven't been set, update now
			// Club is a more accurate indicator of the player skill level so use that to override
			if (!$playerRow["position"]) { // or $teamType == "Club") {
				$this->updatePlayerSkillLevelByPosition($playerRow, $teamSkillLevel, $position);
			}
	
			// delete any player team rows that are same team_type but different team_id e.g. player transfers
			$stmt = $this->pdo->prepare("DELETE FROM player_team WHERE player_team_id IN (SELECT player_team_id FROM player_team LEFT join teams ON teams.team_id = player_team.team_id LEFT join team_types ON teams.team_type_id = team_types.team_type_id where player_team.player_id = ? and teams.team_id != ? and team_type = ?)");
			$stmt->execute([$playerId, $teamId, $teamType]);
			
			// now connect team and player
			$stmt = $this->pdo->prepare("SELECT * FROM player_team where player_id = ? and team_id = ?");
			$stmt->execute([$playerId, $teamId]);
			if ($playerTeamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			
				echo "-- ROW FOUND, SKIPPING player_team: $playerName -> $teamName\n";

			} else {

				echo "-- INSERTING INTO player_team: $currentPosition $positionNumber. {$playerName} -> {$teamRow["team_name"]}\n";

				// we'll take care of this in the next step
				$positionNumber = 999;
	
				$stmt = $this->pdo->prepare('INSERT INTO "player_team" ("player_id", "team_id", "position_number", "shirt_number") VALUES (?,?,?,?)');
				$values = [$playerId, $teamId, $positionNumber, $shirtNumber];
				$success = $stmt->execute($values);
				var_dump($success);

			}

		}

		// print "DELETE FROM player_team WHERE player_team_id IN (select player_team_id from player_team where team_id = 36 and player_id not in (".implode(",", $validPlayerIds)."))";

		// now that we have a full squad of playerIds, we should unlink the players linked to that team 
		// with player ids not in this array 
		$stmt = $this->pdo->prepare("DELETE FROM player_team WHERE player_team_id IN (select player_team_id from player_team where team_id = ? and player_id not in (".implode(",", $validPlayerIds)."))");
		$stmt->execute([$teamId]);
		// var_dump(implode(",", $validPlayerIds));

		// Ensure that player positions are correct with no gaps
		$this->updatePlayerTeamPositionNumbersByFormation($teamId, "442");

		// lastly, just tidy up any names with &apos; etc
		$stmt = $this->pdo->prepare("UPDATE players SET display_name = REPLACE(display_name, \"&apos;\", \"'\")");
		$stmt->execute([]);
	}

	/**
	 * Will order players in a team based on a formation
	 */
	public function updatePlayerTeamPositionNumbersByFormationAllTeams() {
		
		// loop through national teams
		$stmt = $this->pdo->prepare("SELECT * FROM teams LEFT JOIN team_types ON teams.team_type_id = team_types.team_type_id"); #  WHERE team_type = 'Nation'
		$stmt->execute();
		while ($teamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			echo "Setting squad positions for: {$teamRow['team_name']} {$teamRow['formation']}\n";
			$this->updatePlayerTeamPositionNumbersByFormation($teamRow['team_id'], $teamRow['formation']);
		}
	}

	/**
	 * Will order players in a team based on a formation
	 */
	public function updatePlayerTeamPositionNumbersByFormation($teamId, $formationKey = "442") {

		if (is_null($formationKey)) {
			$formationKey = "442";
		} elseif (!array_key_exists($formationKey, $this->formationLimits)) {
			echo "Formation '$formationKey' not found\n";
			return;
		}

		// use team preferred formation, "442" for all case for now
		$formationLimit = $this->formationLimits[$formationKey];

		// in the end, we'll have a list of ordered players
		$players = [];

		// put all players into sub pool
		$stmt = $this->pdo->prepare("SELECT * FROM player_team LEFT JOIN players ON players.player_id = player_team.player_id WHERE team_id = ? ORDER BY position_number ASC");
		$stmt->execute([$teamId]);
		while ($playerTeamRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			array_push($players, $playerTeamRow);
		}

		// sort players based on skill level so that it brings the best players to the top
		usort($players, function ($a, $b) {

			// TODO take position e.g. gk into consideration
			$playersArray = [$a, $b];
			$skillsArray = [];

			foreach($playersArray as $i => $pd) {
				switch ($pd['position']) {
					case 'Goalkeeper':
						$skillsArray[$i] = $pd['goalkeeping'];
						continue;
					case 'Defender':
						$skillsArray[$i] = round(($pd['tackling'] + $pd['speed'] + $pd['acceleration']) / 3);
						continue;
					case 'Midfielder':
						$skillsArray[$i] = round(($pd['passing'] + $pd['speed'] + $pd['acceleration']) / 3);
						continue;
					case 'Attacker':
						$skillsArray[$i] = round(($pd['shooting'] + $pd['speed'] + $pd['acceleration']) / 3);
						continue;
				}
			}
			
			// // compare both players skill levels
			// $aSumOfSkills = $a['speed'] + $a['acceleration'] + $a['dribbling'] + $a['tackling'] + $a['goalkeeping'] + $a['passing'] + $a['shooting'];
			// $bSumOfSkills = $a['speed'] + $a['acceleration'] + $a['dribbling'] + $a['tackling'] + $a['goalkeeping'] + $a['passing'] + $a['shooting'];
			
			if ($skillsArray[0] == $skillsArray[1]) {
				return 0;
			}
			return ($skillsArray[0] > $skillsArray[1]) ? -1 : 1;
		});

		// // DEBUG
		// foreach ($players as $key => $player) {
		// 	echo "$key: {$player['display_name']}\n";
		// }
		
		// get outfield players 
		$positionedPlayers = [];

		// outfield players 
		$this->setPlayerPositionsByFormation($positionedPlayers, $players, $formationLimit, true);
		
		// subs
		$this->setPlayerPositionsByFormation($positionedPlayers, $players, [
			'Goalkeeper' => 1,
			'Defender' => 1,
			'Midfielder' => 2,
			'Attacker' => 1
		], true);

		$positionedPlayers = array_merge($positionedPlayers, $players);

		// // DEBUG
		// var_dump(array_column($positionedPlayers, "display_name"));
		
		$positionNumber = 1;
		foreach ($positionedPlayers as $player) {

			$playerTeamId = $player["player_team_id"];

			// echo "Setting player_position for: $positionNumber. {$player['display_name']} ({$player['position']})\n";

			$values = [
				"position_number" => $positionNumber,
			];
	
			$updateSetColumnsString = $this->getUpdateSetColumnsString($values);
			
			$values = array_values($values);
			array_push($values, $playerTeamId);
	
			$sql = "UPDATE player_team SET $updateSetColumnsString WHERE player_team_id = ?";
			$stmtUpdate = $this->pdo->prepare($sql);
			$success = $stmtUpdate->execute($values);
			
			// var_dump($success);

			$positionNumber++;
		}

		// lastly, set formation key to teams
		$sql = "UPDATE teams SET formation = ? WHERE team_id = ?";
		$stmtUpdate = $this->pdo->prepare($sql);
		$success = $stmtUpdate->execute([$formationKey, $teamId]);
		
	}

	/**
	 * 
	 */
	private function setPlayerPositionsByFormation(&$positionedPlayers, &$players, $formationLimit, $deductFromPool = false) {

		// create keys reset to zero based on formationLimit
		$formationLimitCount = [];
		foreach (array_keys($formationLimit) as $key) $formationLimitCount[$key] = 0;

		$currentPosition = null;
		$currentPositionCount = 0;

		$currentPositionNumber = 1;

		$positions = array_keys($formationLimit);

		// first build up an array of outfield players, then we'll build subs array of players not in that array 
		$playerDataSortedByPosition = $this->sortPlayersByPosition($players);
		while ($desiredPosition = array_shift($positions)) {
			foreach ($playerDataSortedByPosition as $player) {

				// is this player the position we need?
				if ($player["position"] == $desiredPosition) {
					array_push($positionedPlayers, $player);
					$formationLimitCount[$desiredPosition]++;
				}
				
				// if we have enough players for this position, break out
				if ($formationLimitCount[$desiredPosition] >= $formationLimit[$desiredPosition]) {
					// echo "Break out\n";
					break;
				}
			}
		}

		if ($deductFromPool) {
			$playersIds = array_column($positionedPlayers, "player_id");
			foreach($players as $i => $player) {
				if (in_array($player["player_id"], $playersIds)) {
					unset($players[$i]);
				}
			}
		}

		return $positionedPlayers;
	}

	/**
	 * Will look up manual overrides for standout players e.g. Ronaldo
	 * Only keys in $values will be set
	 * @param {id|string} $apiPlayerId
	 * @param {array} $values
	 * @param {enum} $mode This will tell us if we are in real or fake mode
	 */
	private function applyPlayerOverrides($apiPlayerId, $values, $mode = null) {
		if (isset($this->playerTableColumnOverrides["$apiPlayerId"])) {
			$overrides = $this->playerTableColumnOverrides["$apiPlayerId"];
			$intersectValues = array_intersect_key($overrides, $values);
			$values = array_merge($values, $intersectValues);
		}
		return $values;
	}

	private function handleTeamDataFromApi($teamData) {

		// from api 
		$apiTeamId = (int) $teamData["id"];		
		$teamName = transliterateString($teamData["name"]);

		if ($teamRow = $this->getTeamRowByApiId($apiTeamId)) {
			
			echo "-- ROW FOUND, SKIPPING teams: $teamName\n";

			// $stmt = $this->pdo->prepare('UPDATE "teams" SET shirt_number = ? WHERE player_id = ? and team_id = ?');
			// $values = [$shirtNumber, $playerId, $teamId];
			// $success = $stmt->execute($values);
			
			// var_dump($success);
			
		} else {

			$shortName = $teamName;
			$hudName = strtoupper(substr($teamName, 0, 3));
			$countryName = transliterateString($teamData["country"]);
			$teamTypeId = ($teamData["national"]) ? self::TEAM_TYPE_NATION_ID : self::TEAM_TYPE_CLUB_ID;
			
			// get country row 
			$countryId = $this->getCountryRowByName($countryName);
			if (!$countryId) {
				echo "!! WARNING: Country not found: $countryName";
			}

			$stmt = $this->pdo->prepare('INSERT INTO "teams" ("team_name", "short_name", "hud_name", "team_type_id", "country_id", "api_team_id") VALUES (?,?,?,?,?,?)');
			$values = [$teamName, $shortName, $hudName, $teamTypeId, $countryId, $apiTeamId];
			
			echo "-- INSERTING INTO teams: ".implode(", ", $values)."\n";

			$success = $stmt->execute($values);

			var_dump($success);
			
		}
	}

	/**
	 * Will opt to INSERT of UPDATE
	 * @param {array} $playerData Data for player from API
	 * @param {array} $teamRow Row from db
	 */
	private function handlePlayerDataFromApi($playerData, $teamRow) {

		// from api 
		$apiPlayerId = (int) $playerData["id"];

		// insert if needed
		if ($playerRow = $this->getPlayerRowByApiId($apiPlayerId)) {
			// echo "-- UPDATING players: {$playerData["name"]}\n";
			echo "-- ROW FOUND, SKIPPING players: {$playerData["name"]}\n";

			// $stmt = $this->pdo->prepare('UPDATE "players" SET full_name = ?, first_name = ?, last_name = ?, speed = ?, acceleration = ?, dribbling = ?, tackling = ?, heading = ?, goalkeeping = ?, passing = ?, shooting = ?, country_id = ? WHERE api_player_id = ?');
			// $success = $stmt->execute([$fullName, $firstName, $lastName, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $teamSkillLevel, $countryId, $apiPlayerId]);
			// var_dump($success);

		} else {
			
			$fullName = transliterateString($playerData["name"]);
			// $firstName = transliterateString($playerData["firstname"]);
			// $lastName = transliterateString($playerData["lastname"]);
			$nationality = $playerData["nationality"];
	
			// team 
			$teamSkillLevel = $teamRow['skill_level'];
	
			$countryId = $this->getCountryRowByName($nationality);

			// we don;t know what position each player is to just use team skill_level
			$values = [
				"display_name" => $fullName,
				"speed" => $teamSkillLevel,
				"acceleration" => $teamSkillLevel,
				"dribbling" => $teamSkillLevel,
				"tackling" => $teamSkillLevel,
				"heading" => $teamSkillLevel,
				"goalkeeping" => $teamSkillLevel,
				"passing" => $teamSkillLevel,
				"shooting" => $teamSkillLevel,
				"country_id" => $countryId,
				"api_player_id" => $apiPlayerId,
				// "full_name" => $fullName,
				// "first_name" => $firstName,
				// "last_name" => $lastName,
			];

			$insertColumnNamesString = $this->getInsertColumnNamesString($values);
			$insertColumnValuesString = $this->getInsertColumnValuesString($values);

			$sql = "INSERT INTO players (\"$insertColumnNamesString\") VALUES ($insertColumnValuesString)";

			// display_name gets written on insert, but not update 
			$stmt = $this->pdo->prepare($sql);
			$values = array_values($values);
			
			echo "-- INSERTING INTO players: {$playerData["name"]}\n";
			
			$success = $stmt->execute($values);

			var_dump($success);
		}
	}

	private function getInsertColumnNamesString($values) {
		return implode('", "', array_keys($values));
	}

	private function getInsertColumnValuesString($values) {
		return implode(',', array_fill(0, count(array_keys($values)), '?'));
	}

	private function getUpdateSetColumnsString($values) {
		$setsArray = [];
		foreach ($values as $name => $value) {
			array_push($setsArray, "$name = ?");
		}
		return implode(", ", $setsArray);
	}

	/**
	 * 
	 */
	private function getCountryRowByName($countryName) {

		// get country
		$countryId = null; // default
		$stmt = $this->pdo->prepare("SELECT * FROM countries where country = ?");
		$stmt->execute([$countryName]);
		if ($countryRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
			$countryId = $countryRow["country_id"];
		}

		return $countryId;
	}

	private function sortPlayersByPosition($data) {
		
		$pg = [
			'Goalkeeper' => [],
			'Defender' => [],
			'Midfielder' => [],
			'Attacker' => []
		];
		foreach ($data as $playerData) {
			$position = $playerData["position"];
			array_push($pg[$position], $playerData);
		}

		return array_merge($pg["Goalkeeper"], $pg["Defender"], $pg["Midfielder"], $pg["Attacker"]);
		
	}

	private function getTeamRowByApiId($apiTeamId) {
		$stmt = $this->pdo->prepare("SELECT * FROM teams where api_team_id = ?");
		$stmt->execute([$apiTeamId]);
		return $stmt->fetch(PDO::FETCH_ASSOC);
	}

	private function getPlayerRowByApiId($apiPlayerId) {
		$stmt = $this->pdo->prepare("SELECT * FROM players where api_player_id = ?");
		$stmt->execute([$apiPlayerId]);
		return $stmt->fetch(PDO::FETCH_ASSOC);
	}

	private function getHttpRequestCacheFilepath($endpoint, $params = null) {
		
		// get / mkdir 
		$dir = $this->getHttpRequestCacheDir($endpoint, $params);
		
		// filename 
		$filename = str_replace("/", "_", $endpoint);
		if ($params) {
			$filename .= "_" . implode("_", $params);
		}
		$cacheFilePath = realpath($dir) . DIRECTORY_SEPARATOR . "$filename.json";

		return $cacheFilePath;
	}

	/**
	 * 
	 */
	private function getHttpRequestCacheDir($endpoint, $params = null) {

		// for the sake of endpoint, we'll replace colons with underscores
		$endpoint = str_replace(":", "_", $endpoint);

		// 
		$teamDir = "";
		if (isset($params["id"])) {
			$teamDir = $params["id"];
		} elseif (isset($params["team"])) {
			$teamDir = "team_" . $params["team"];
		} elseif (isset($params["name"])) {
			$teamDir = "name_" . $params["name"];
		} elseif (isset($params["league"])) {
			$teamDir = "league_" . $params["league"];
		}

		$cacheDir = realpath(__DIR__ . DIRECTORY_SEPARATOR . "cache") . DIRECTORY_SEPARATOR . $endpoint . DIRECTORY_SEPARATOR . $teamDir;
		
		// dir doesn't exist, make it
		if (!is_dir($cacheDir)) {
			mkdir($cacheDir, 0777, true);
		}
		
		return $cacheDir;
	}
	
	/**
	 * Make http request to api for data 
	 */
	private function httpRequest($endpoint, $params = [], $useCache = null) {

		if (is_null($useCache)) {
			$useCache = $this->useCache;
		}
	
		// use local files to test?
		$cacheFilePath = realpath($this->getHttpRequestCacheFilepath($endpoint, $params));
		if ($useCache && $cacheFilePath) {
			$json = file_get_contents($cacheFilePath);
			$data = json_decode($json, 1);
			echo "LOADING FROM CACHE $cacheFilePath\n";
		} else {

			// do http request to api...

			// we may need to sleep for a minute
			if ($this->httpRequestCount >= $this->httpRequestLimit) {
				echo "SLEEPING...\n";
				sleep(60);
				$this->httpRequestCount = 0;
			}

			echo "LOADING FROM API $endpoint\n";
		
			$curl = curl_init();
		
			$url = "https://v3.football.api-sports.io/$endpoint?" . http_build_query($params);
			
			echo $url . "\n";
			
			curl_setopt_array($curl, [
				CURLOPT_URL => $url,
				CURLOPT_RETURNTRANSFER => true,
				CURLOPT_FOLLOWLOCATION => true,
				CURLOPT_ENCODING => "",
				CURLOPT_MAXREDIRS => 10,
				CURLOPT_TIMEOUT => 30,
				CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
				CURLOPT_CUSTOMREQUEST => "GET",
				CURLOPT_HTTPHEADER => [
					"x-rapidapi-host: v3.football.api-sports.io",
					"x-rapidapi-key: " . $this->apiKey
				],
			]);
			
			$response = curl_exec($curl);
			$err = curl_error($curl);

			$this->httpRequestCount++;
			
			curl_close($curl);
			
			if ($err) {
				echo "cURL Error #:" . $err;
				exit;
			} else {
				$data = json_decode($response, 1);
			}

		}

		$errors = array_keys($data["errors"]);

		// check errors key 
		if (count($errors)) {
			echo "\nError #:" . json_encode($data["errors"]) . "\n\n exit y or n?\n\n";

			$stdin = fopen('php://stdin', 'r');
			$input = trim(fgets($stdin));
			if ($input == 'y') {
				exit();
			}
			
		} else {
				
			// debug/log
			$cacheFilePath = $this->getHttpRequestCacheFilepath($endpoint, $params);
			file_put_contents($cacheFilePath, json_encode($data));
		}

		return $data;

	}
}

list($script, $method) = $argv;
if (!$method) {
	echo "- Method missing\n";
	exit();
}

$apiManager = new ApiManager();

switch (strtolower($method)) {
	case ApiManager::METHOD_TEAM:
		list($script, $method, $apiTeamId) = $argv;
		$apiManager->loadTeam($apiTeamId);
		break;
		
	case ApiManager::METHOD_TEAM_NAMES_FAKE:
		$apiManager->setTeamsNamesToFake();
		break;
	
	case ApiManager::METHOD_TEAM_NAMES_RESTORE:
		$apiManager->setTeamsNamesToReal();
		break;
	
	case ApiManager::METHOD_PLAYERS_NAMES_FAKE:
		@list($script, $method, $season) = $argv;
		$apiManager->setPlayersNamesToFake();
		break;
	
	case ApiManager::METHOD_PLAYERS_NAMES_RESTORE:
		@list($script, $method) = $argv;
		$apiManager->loadPlayersRealNames();
		break;
	
	case ApiManager::METHOD_TEAM_SEARCH_NAME:
		list($script, $method, $query) = $argv;

		if (!$query) {
			echo "- Query missing\n";
			exit();
		}
		
		$apiManager->searchTeamsByName($query);
		break;
	
	case ApiManager::METHOD_TEAM_SEARCH_LEAGUE:
		@list($script, $method, $leagueId, $season) = $argv;

		if (!$leagueId) {
			echo "- League ID missing\n";
			exit();
		}
		
		$apiManager->searchTeamsByLeague($leagueId, $season);
		break;

	case ApiManager::METHOD_PLAYERS_REBASE:
		@list($script, $method) = $argv;

		$apiManager->rebasePlayers();
		break;

	case ApiManager::METHOD_PLAYERS_POSITIONBYSKILL:
		@list($script, $method, $teamId, $formation) = $argv;

		$apiManager->updatePlayerTeamPositionNumbersByFormation($teamId, $formation);
		break;

	case ApiManager::METHOD_PLAYERS_POSITIONBYSKILL_ALL:
		@list($script, $method, $teamId, $formation) = $argv;

		$apiManager->updatePlayerTeamPositionNumbersByFormationAllTeams();
		break;

	case ApiManager::METHOD_PLAYERS_IMPORT_CSV:
		@list($script, $method, $season) = $argv;

		$apiManager->importPlayersCSV($season);
		break;

	case ApiManager::METHOD_PLAYERS_ALL:
		@list($script, $method, $season) = $argv;

		$apiManager->loadAllPlayers($season);
		break;

	case ApiManager::METHOD_PLAYERS: // playly
		@list($script, $method, $apiTeamId, $season) = $argv;

		if (!$apiTeamId) {
			echo "- API team missing\n";
			exit();
		}

		$apiManager->loadPlayers($apiTeamId, $season);
		break;

	case ApiManager::METHOD_PLAYERS_GENERATE_CSV:
		@list($script, $method) = $argv;

		$apiManager->generatePlayersCSV();
		
	default:
		echo "- Invalid method\n";
		exit();
}
