<?php
	// SIMPLE SYSTEM coded by Vinh Pham (opdo.vn)
	// Login file
	// v1.0
	include 'ss_func.php';
	if (isset($_POST["login"],$_POST["acc"],$_POST["pass"],$_POST["id"])) {
		if ($_POST["login"] == 'login') {
			$acc = $_POST["acc"]; // account
			$pass = $_POST["pass"]; // password
			$id = $_POST["id"]; // id may
			$login = _Login($acc, $pass, $id, 1);
			if ($GLOBALS['SS_COUNT_BY_DATE'] == false) { // kiểm tra nếu system tính là số lần dùng
				$new_Vaild = (float)_Account_Get_Vaild($acc, $pass)-1; // trừ lần dùng
				_Account_Set_Vaild($acc, $pass, $new_Vaild);
			} else die('ok');
			echo $login;
		}
	} else {
		die("ERROR[opdo:]Khong nhan duoc thong tin");
	}
?>