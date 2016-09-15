<?php
	// SIMPLE SYSTEM coded by Vinh Pham (opdo.vn)
	// Setting file
	// v1.0
	// thong tin sql
	date_default_timezone_set("Asia/Ho_Chi_Minh");
	$sql_username = "root";
	$sql_password = "";
	$sql_host = "localhost";
	$sql_database = "dblogin";
	$conn = mysqli_connect($sql_host,$sql_username,$sql_password,$sql_database) or die("ERROR[opdo:]Khong ket noi duoc voi database");
	// setting simple system
	$SS_VERSION = '1.0'; // phien ban su dung
	$SS_ONLINE = true; // true: duoc phep su dung, false: ngung su dung
	$SS_LOGIN_1TIMES = true; // true: chi cho phep 1 tai khoan login tren 1 may cung luc, false: cho phep 1 tai khoan login tren nhieu may cung luc
	$SS_LOGIN_OVERWIRTE = true; // true: co the disconect cua nguoi login truoc do, false: khong the disconect nguoi login truoc do
	$SS_COUNT_BY_DATE = false; // true: tinh ngay su dung, false: tinh lan su dung
	$SS_GETTRIAL = true; // true: cho phep dung thu, false: khong cho phep dung thu
	$SS_TRIAL_1TIMES = true; // true: dung thu 1 lan duy nhat, false: duoc dung thu nhieu lan
?>