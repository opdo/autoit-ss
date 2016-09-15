<?php
	// SIMPLE SYSTEM coded by Vinh Pham (opdo.vn)
	// Function file
	// v1.0
	include 'ss_setting.php';

	if ($SS_ONLINE == false) die("ERROR[opdo:]System dang bao tri"); // check thong tin bao tri system
	
	if (isset($_GET["cmd"])) {
		$cmd = $_GET["cmd"];
		if ($cmd=='getinfo') _Get_System_Info();
		if ($cmd=='checkvaild' && isset($_POST["acc"])) _Account_CheckVaild($_POST["acc"]);
		if ($cmd=='changeinfo' && isset($_POST["acc"],$_POST["pass"],$_POST["id"],$_POST["value"],$_POST["info"])) {
			if (_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 0)) _Account_Change_Info($_POST["acc"],$_POST["info"], $_POST["value"]);
		}
		if ($cmd=='keep_connect' && isset($_POST["acc"],$_POST["pass"],$_POST["id"])) {
			if (_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 0)) die(_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 1));
			else die('0');
		}
		if ($cmd=='addcode' && isset($_POST["acc"],$_POST["pass"],$_POST["id"],$_POST["code"])) {
			if (_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 0)) {
				if (_Account_Add_Code($_POST["acc"], $_POST["pass"], $_POST["code"])) die(_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 1));
				else  die('ERROR[opdo:]Nap code that bai');
			} else die('ERROR[opdo:]Nap code that bai');
		}
		if ($cmd=='gettrial' && isset($_POST["acc"],$_POST["pass"],$_POST["id"])) {
			if (_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 0)) _Account_Get_Trial($_POST["acc"]);
			else die('ERROR[opdo:]Dang nhap that bai');
		}
		if (substr($cmd,0,5)=='trial') {
			If (_Account_Set_Trial(substr($cmd,13),substr($cmd,5,8))) echo "Tai khoan cua ban da duoc kich hoat su dung thu";
			else echo "That bai";
			die();
		}

		// cách tạo 1 func command
		if ($cmd=='userfunc' && isset($_POST["acc"],$_POST["pass"],$_POST["id"])) { // tạo 1 command func
			if (_Login($_POST["acc"], $_POST["pass"], $_POST["id"], 0)) { // check thông tin user
				// thông tin hợp lệ
				_User_Func_Command($_POST["acc"]);
			}
			else die('0'); // thông tin không hợp lệ
		}
	}

	function _User_Func_Command($acc) { // user func để gọi
		if (_Account_CheckVaild($acc,0)) { // kiểm tra hạn dùng
			if ($acc == 'admin') die('Your are admin.'); 
			else  die('Hi member.'); 
		}
		else die('Tai khoan het han su dung');
	}

	function _Login($acc, $pass, $id, $return) {
		$pass = md5($pass);
		$conn = $GLOBALS['conn'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."' and pass = '". $pass ."'");
		if (!$query || mysqli_num_rows($query) == 0) {
			if ($return == 1) return "ERROR[opdo:]Tai khoan hoac mat khau khong chinh xac";
			return false;
		} else {
			$row = mysqli_fetch_array($query,MYSQL_ASSOC);
			if ($row['status'] == 'blocked' || $row['status'] == 'cancel') {
				if ($return == 1) return "ERROR[opdo:]Tai khoan da bi khoa";
				return false;
			}
			$SS_LOGIN_1TIMES = $GLOBALS['SS_LOGIN_1TIMES'];
			$SS_LOGIN_OVERWIRTE = $GLOBALS['SS_LOGIN_OVERWIRTE'];
			$now = (float)date("YmdHi");
			if ($SS_LOGIN_1TIMES) {
				$id_old = $row["id"];
				if ($id == $id_old || $id_old == "" || $id_old == "-1") {
					mysqli_query($conn,"UPDATE dblogin SET id='".(string)$id."',last_login='".$now."' WHERE acc='".$acc."'");
					if ($return == 1) return "SUCCESS[opdo:]".$row['acc']."|".$row['name']."|".$row['email']."|".$row['type']."|".$row['vaild'];
					return true;
				} else {
					if ($SS_LOGIN_OVERWIRTE) mysqli_query($conn,"UPDATE dblogin SET id='-1' WHERE acc='".$acc."'");
					else {
						$last_login = $row["last_login"];
						if ($now - (float)$last_login > 5) {
							mysqli_query($conn,"UPDATE dblogin SET id='".(string)$id."',last_login='".$now."' WHERE acc='".$acc."'");
							if ($return == 1) return "SUCCESS[opdo:]".$row['acc']."|".$row['name']."|".$row['email']."|".$row['type']."|".$row['vaild'];
							return true;
						}
					}
					if ($return == 1) return "ERROR[opdo:]Tai khoan da co nguoi dang nhap, hay dang nhap lai sau 5p nua";
					return false;
				}
			} else {
				mysqli_query($conn,"UPDATE dblogin SET id='".(string)$id."',last_login='".$now."' WHERE acc='".$acc."'");
				if ($return == 1) return "SUCCESS[opdo:]".$row['acc']."|".$row['name']."|".$row['email']."|".$row['type']."|".$row['vaild'];
				return true;
			}
		}
	}

	function _Reg($acc, $pass, $id, $name, $email) {
		$conn = $GLOBALS['conn'];
		if (_Account_Exist($acc) == false) {
			mysqli_query($conn,"INSERT INTO dblogin (acc,pass,id,name,email) VALUES ('".$acc."','".md5($pass)."','".$id."','".$name."','".$email."')");
			return true;
		} else return false;
	}

	function _Account_Get_Trial($acc) {
		if ($GLOBALS['SS_GETTRIAL'] == false) {
			return false;
			die();
		}
		$conn = $GLOBALS['conn'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		if ($row['get_trial'] == -1 || $row['get_trial'] == '-1' ) {
			if ($GLOBALS['SS_TRIAL_1TIMES']) {
				die('ERROR[opdo:]Tai khoan nay da Get Trial truoc do');
			} 
		}
		if (_Account_CheckVaild($acc, 0) == false) {
			$code = rand(10000000,99999999);
			mysqli_query($conn,"UPDATE dblogin SET get_trial='".$code."' WHERE acc='".$acc."'");
			die('SUCCESS[opdo:]'.$code);
		} else die('ERROR[opdo:]Tai khoan ban khong can Get Trial');
	}

	function _Account_Set_Trial($acc, $code) {
		if ($GLOBALS['SS_GETTRIAL'] == false) {
			return false;
			die();
		}
		$conn = $GLOBALS['conn'];
		if ($code == '' || $code == -1 || $code == '-1') return false;
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."' and get_trial='". $code ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		mysqli_query($conn,"UPDATE dblogin SET get_trial='-1' WHERE acc='".$acc."'");
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		if ($GLOBALS['SS_COUNT_BY_DATE'] == false) _Account_Set_Vaild($acc,$row['pass'], 1, 1);
		else _Account_Set_Vaild($acc, $row['pass'], (float)date("Ymd"), 1);
		return true;
	}

	function _Account_Add_Code($acc, $pass, $code) {
		$conn = $GLOBALS['conn'];
		$query2 = mysqli_query($conn,"SELECT * FROM dbcode WHERE code='". $code ."'");
		if (!$query2 || mysqli_num_rows($query2) == 0) return false;
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."' and pass='". md5($pass) ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		$row2 = mysqli_fetch_array($query2,MYSQL_ASSOC);
		$add = $row2['vaild'];
		if ($add == '-1' || $add == -1) return false;
		else {
			mysqli_query($conn,"UPDATE dbcode SET vaild='-1' WHERE code='".$code."'");
			$new_Vaild = '';
			if ($GLOBALS['SS_COUNT_BY_DATE']) {
				$date_txt = '';
				if ((float)$row2['vaild'] < (float)date("Ymd")) $date_txt = date("Ymd");
				else $date_txt = $row['vaild'];
				$date1 = substr($date_txt,-2);
				$date2 = substr($date_txt,4,2);
				$date3 = substr($date_txt,0,4);
				$date= date_create($date3."-".$date2."-".$date1);
				date_add($date,date_interval_create_from_date_string($add." days"));
				$new_Vaild = (float)date_format($date,"Ymd");
			} else $new_Vaild = (float)_Account_Get_Vaild($acc, $pass)+(float)$add;
			_Account_Set_Vaild($acc, $pass, $new_Vaild);
			return true;
		}
	}

	function _Account_Change_Info($acc, $column, $value) {
		if ($column=='name' || $column == 'email') { // chỉ cho phép đổi email và name
			$conn = $GLOBALS['conn'];
			mysqli_query($conn,"UPDATE dblogin SET ".$column."='".$value."' WHERE acc='".$acc."'");
			die('1');
		}
		die('0');
	}

	function _Account_Exist($acc) {
		$conn = $GLOBALS['conn'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		else return true;
	}

	function _Account_Set_Vaild($acc,$pass,$value, $md5pass = 0) {
		if ($md5pass==0) $pass = md5($pass);
		$conn = $GLOBALS['conn'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."' and pass='". $pass ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		mysqli_query($conn,"UPDATE dblogin SET vaild='".$value."' WHERE acc='".$acc."'");
		return true;
	}

	function _Account_Get_Vaild($acc,$pass, $md5pass = 0) {
		if ($md5pass==0) $pass = md5($pass);
		$conn = $GLOBALS['conn'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."' and pass='". $pass ."'");
		if (!$query || mysqli_num_rows($query) == 0) return false;
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		return (float)$row['vaild'];
	}

	function _Account_CheckVaild($acc, $return = 1) {
		$conn = $GLOBALS['conn'];
		$SS_COUNT_BY_DATE = $GLOBALS['SS_COUNT_BY_DATE'];
		$query = mysqli_query($conn,"SELECT * FROM dblogin WHERE acc='". $acc ."'");
		if (!$query || mysqli_num_rows($query) == 0) {
			if ($return == 1) die('0');
			return false;
		}
		$now = date("Ymd");
		$row = mysqli_fetch_array($query,MYSQL_ASSOC);
		if ($SS_COUNT_BY_DATE) {
			if ((float)$now <= (float)$row['vaild']) {
				if ($return == 1) die('1');
				return true;
			}
		} else {
			if ((float)$row['vaild'] > 0) {
				if ($return == 1) die('1');
				return true;
			}
		}
		if ($return == 1) die('0');
		return false;
	}

	function _Get_System_Info() {
		$count = 0;
		if ($GLOBALS['SS_COUNT_BY_DATE']) $count = 1;
		echo $GLOBALS['SS_VERSION'].'|'. $count;
	}
?>