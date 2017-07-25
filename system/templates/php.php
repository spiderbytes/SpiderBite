<?php

// header("Access-Control-Allow-Origin: *");
// header("Access-Control-Allow-Methods: GET,PUT,POST,DELETE,PATCH,OPTIONS");
// header('Content-Type: text/plain');


// processing PostData:

$PostData = file_get_contents("php://input");
parse_str($PostData, $PostParams);
$params = array_values($PostParams);

// processing Get-Request (if any)

$request = $_GET["request"];

if (!$request) {
	$request = array_shift($params);
}

if (!function_exists($request)) die("invalid request: '" . $request . "'");

echo call_user_func_array($request, $params);

die();

// -------------------------
//
// ### ServerCode ###
//
// -------------------------

?>