<?php

echo "Disabled\n";
exit();

function dirpath($dir, $create = false) {
    $dir = str_replace("/", DIRECTORY_SEPARATOR, $dir);
    if ($create) {
        if (!is_dir($dir)) {
			mkdir($dir, 0777, true);
		}
    }
    return $dir;
}

$srcDir = dirpath(__DIR__ . '/cache/_old');
$destDir = dirpath(__DIR__ . '/cache');

$files = scandir($srcDir, 0);
for($i = 2; $i < count($files); $i++) {
    $filename = $files[$i];

    if (preg_match("/^players_squads_(.*?).json/", $filename, $matches)) {
        list($filename, $id) = $matches;
        
        $moveToDir = dirpath("$destDir/players/squads/team_$id", true);

        $from = dirpath("$srcDir/$filename");
        $to = dirpath("$moveToDir/$filename");

        rename($from, $to);

        echo "$filename\n";
    } elseif (preg_match("/^players_(\d*?)_.*\.json/", $filename, $matches)) {
        list($filename, $id) = $matches;
        // var_dump($matches);

        $from = dirpath("$srcDir/$filename");

        $response = json_decode(file_get_contents($from), 1);

        if (isset($response["parameters"]["team"])) {
            $toDir = dirpath("$destDir/players/team_$id", true);
        } else {
            $toDir = dirpath("$destDir/players/$id", true);
        }
        
        // $moveToDir = dirpath("$destDir/players/squads/team_$id", true);

        // $from = dirpath("$srcDir/$filename");
        $to = dirpath("$toDir/$filename");

        rename($from, $to);

        echo "$filename\n";
    }
}
    