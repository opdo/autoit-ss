#include <_HttpRequest.au3> ; // tks to Huan Hoang
#include <Array.au3> ; // tks to Huan Hoang
#include-once
#cs INFO
Simple System v1.0
Coded by VinhPham (opdo.vn)
Tks to Huan Hoang (HttpRequest UDF)
#ce

#Region SETTING
Global Const $__SYSTEM__URL = 'http://localhost'
Global Const $__OUO_API = ''
#EndRegion

Global Const $__MY__ID = _GetUUID()
Global $USER_DETAILS, $USER_PASS, $USER_CHANGE = False

#Region User Func
; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_Login
; Description ...: Thực hiện đăng nhập một account
; Syntax ........: _SS_Login($acc, $pass)
; Parameters ....: $acc                 - account
;                  $pass                - password
; Return values .: return về mảng $USER_DETAILS chứa thông tin user, và $USER_PASS chứa password user. nếu thất bại set @error = 1
; Author ........: Vinh Pham
; ===============================================================================================================================
Func _SS_Login($acc, $pass)
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_login.php', 'login=login&acc=' & $acc & '&pass=' & $pass & '&id=' & $__MY__ID)
	$message = _Return_Message($request)
	If @error Then
		MsgBox(16, 'Thông báo', $message)
		Return SetError(1, 0, 0)
	EndIf
	Global $USER_DETAILS = StringSplit($message, '|')
	if $USER_DETAILS[0] < 2 then SetError(1, 0, 0)
	Global $USER_PASS = $pass
	AdlibRegister("_SS_KeepConnect", 10000)
	Return $USER_DETAILS
EndFunc   ;==>_SS_Login

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_RegAcc
; Description ...: Thực hiện đăng ký một account
; Syntax ........: _SS_RegAcc($acc, $pass, $id, $name, $email)
; Parameters ....: $acc                 - account
;                  $pass                - pass
;                  $id                  - id
;                  $name                - name
;                  $email               - email
; Return values .: 1 nếu đăng ký thành công, 0 và báo lỗi nếu đăng ký thất bại
; Author ........: Vinh Pham
; ===============================================================================================================================
Func _SS_RegAcc($acc, $pass, $id, $name, $email)
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_reg.php', 'reg=reg&acc=' & $acc & '&pass=' & $pass & '&id=' & $id & '&name=' & $name & '&email=' & $email)
	$message = _Return_Message($request)
	If @error Then
		MsgBox(16, 'Thông báo', $message)
		Return SetError(1, 0, 0)
	EndIf
	Return SetError(1, 0, 1)
EndFunc   ;==>_SS_RegAcc

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_AddCode
; Description ...: Thực hiện chức năng nạp key tăng hạn sử dụng cho user
; Syntax ........: _SS_AddCode()
; Parameters ....:
; Return values .: False nếu thất bại, True nếu thành công
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_AddCode()
	If Not IsArray($USER_DETAILS) Then Return 0
	$ib = InputBox('Nhập code', 'Nhập code sử dụng')
	If $ib = '' Or @error Then Return False
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=addcode', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID & '&code=' & $ib)
	$message = _Return_Message($request)
	If @error Then
		MsgBox(16, 'Thông báo', $message)
		Return False
	Else
		Global $USER_DETAILS = StringSplit($message, '|')
		If Number(_SS_GetInfo()[2]) = 1 Then
			MsgBox(64, 'Thành công', 'Sử dụng đến ' & StringRight($USER_DETAILS[5], 2) & '/' & StringMid($USER_DETAILS[5], 5, 2) & '/' & StringLeft($USER_DETAILS[5], 4))
		Else
			MsgBox(64, 'Thành công', 'Sử dụng được ' & $USER_DETAILS[5] & ' lần')
		EndIf
		Return True
	EndIf
EndFunc   ;==>_SS_AddCode

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_GetTrial
; Description ...: Cho user dùng thử với thiết lập của system_setting
; Syntax ........: _SS_GetTrial()
; Parameters ....:
; Return values .: None
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_GetTrial()
	If Not IsArray($USER_DETAILS) Then Return 0
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=gettrial', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID)
	$message = _Return_Message($request)
	If @error Then
		MsgBox(16, 'Thông báo', $message)
		Return False
	Else
		InputBox('Dùng thử','Vào link bên dưới bạn sẽ được xác nhận dùng thử',_SS_ShortLink($__SYSTEM__URL & '/ss_func.php?cmd=trial'&$message&$USER_DETAILS[1]))
	EndIf
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_ChangeInfo
; Description ...: Đổi info của user
; Syntax ........: _SS_ChangeInfo($info, $value)
; Parameters ....: $info                - column muốn đổi.
;                  $value               - đổi thành giá trị nào.
; Return values .: True nếu thành công và false nếu thất bại, sau đó nếu thành công các giá trị của $USER_DETAILS sẽ được thay đổi, $USER_CHANGE chuyển thành true
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_ChangeInfo($info, $value)
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=changeinfo', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID & '&info=' & $info & '&value=' & $value)
	If Number($request) = 1 Then
		$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=keep_connect', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID)
		$message = _Return_Message($request)
		$USER_CHANGE = True
		$USER_DETAILS = StringSplit($message, '|')
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_SS_ChangeInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_CheckVaild
; Description ...: Kiểm tra hạn sử dụng của tài khoản
; Syntax ........: _SS_CheckVaild()
; Parameters ....:
; Return values .: True nếu còn hạn, False nếu hết hạn
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_CheckVaild()
	If Not IsArray($USER_DETAILS) Then Return 0
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=checkvaild', 'acc=' & $USER_DETAILS[1])
	If Number($request) = 1 Then Return True
	Return False
EndFunc   ;==>_SS_CheckVaild

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_CFC
; Description ...: Gọi một function cmd trên php
; Syntax ........: _SS_CFC($cmd[, $post = ''])
; Parameters ....: $cmd                 - lệnh cmd muốn gửi lên.
;                  $post                - [optional] lệnh post muốn gửi kèm. Default is ''.
; Return values .: Trả về $request từ php
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_CFC($cmd, $post = '') ; call func cmd
	If IsArray($USER_DETAILS) Then
		If $post <> '' Then $post = '&' & $post
		$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=' & $cmd, 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID & $post)
		Return $request
	EndIf
EndFunc   ;==>_SS_CFC


; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_KeepConnect
; Description ...: Dùng để kiểm tra connect của user
; Syntax ........: _SS_KeepConnect()
; Parameters ....:
; Return values .: None
; Author ........: Vinh Pham
; ===============================================================================================================================
Func _SS_KeepConnect()
	If IsArray($USER_DETAILS) Then
		$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=keep_connect', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&id=' & $__MY__ID)
		if $request = '' or @error Then Return 0
		$message = _Return_Message($request)
		If $request == '0' or @error Then
			MsgBox(16, 'Thông báo', 'Tài khoản của bạn đã bị ngắt kết nối')
			Exit
		EndIf
		$USER_DETAILS_TEMP = StringSplit($message, '|')
		For $i = 1 to $USER_DETAILS_TEMP[0]
			if $USER_DETAILS_TEMP[$i] <> $USER_DETAILS[$i] Then
				Global $USER_DETAILS = StringSplit($message, '|')
				Global $USER_CHANGE = True
				Return True
			EndIf
		Next
	EndIf
EndFunc   ;==>_SS_KeepConnect


; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_GetInfo
; Description ...: Lấy thông tin simple system
; Syntax ........: _SS_GetInfo()
; Parameters ....:
; Return values .: Thông tin trả về dạng <phiên bản>|<count by date: 1 nếu có, 0 nếu count by times>
; Author ........: Vinh Phạm
; ===============================================================================================================================
Func _SS_GetInfo()
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_func.php?cmd=getinfo')
	Return StringSplit($request, '|')
EndFunc   ;==>_SS_GetInfo


Func _SS_ShortLink($link)
	Return __HttpRequest(2, $__OUO_API&$link)
EndFunc

Func _Return_Message($message)
	$ss = StringSplit($message, '[opdo:]', 1)
	If @error Then Return $message
	If $ss[0] < 2 Then Return $message
	If $ss[1] = 'ERROR' Then Return SetError(1, 0, $ss[2])
	If $ss[1] = 'SUCCESS' Then Return SetError(0, 0, $ss[2])
	Return SetError(1, 0, $ss[2])
EndFunc   ;==>_Return_Message

Func _GetUUID()
	Local $oWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\localhost\root\cimv2")
	If Not IsObj($oWMIService) Then
		Return SetError(1, 0, -1)
	EndIf
	Local $oSysProd = $oWMIService.ExecQuery("Select * From Win32_ComputerSystemProduct")
	For $oSysProp In $oSysProd
		Return SetError(0, 0, Binary($oSysProp.UUID))
	Next
	Return SetError(2, 0, -1)
EndFunc   ;==>_GetUUID
#EndRegion

#Region Admin func
; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_Admin_IsAdmin
; Description ...: Kiểm tra quyền admin của tài khoản
; Syntax ........: _SS_Admin_IsAdmin()
; Parameters ....:
; Return values .: True nếu có, False nếu không
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_Admin_IsAdmin()
	If Not IsArray($USER_DETAILS) Then Return False
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_admin.php?admin=isadmin', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS)
	if Number($request) = 1 Then Return True
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_Admin_GetListMember
; Description ...: Lấy danh sách member system
; Syntax ........: _SS_Admin_GetListMember()
; Parameters ....:
; Return values .: Trả về list bao gồm 1 mảng mà mỗi ngăn là thông tin được tách với nhau bằng dấu "|"
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_Admin_GetListMember()
	If Not IsArray($USER_DETAILS) Then Return 0
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_admin.php?admin=listmember', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS)
	$message = _Return_Message($request)
	If @error Then
		MsgBox(16, 'Thông báo', $message)
		Return -1
	Else
		Local $return[0]
		Local $ss = StringSplit($request,@CRLF)
		For $i = 1 To $ss[0]
			if $ss[$i] <> '' Then _ArrayAdd($return,$ss[$i],Default, Default, Default, 1)
		Next
		Return $return
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _SS_Admin_ChangeInfo
; Description ...: Thay đổi thông tin một user bất kỳ
; Syntax ........: _SS_Admin_ChangeInfo($acc, $info, $value)
; Parameters ....: $acc                 - account muốn đổi thông tin.
;                  $info                - column muốn đổi.
;                  $value               - giá trị muốn đổi.
; Return values .: True nếu thành công và false nếu thất bại
; Author ........: Vinh Pham
; Related .......: Phải gọi hàm _SS_Login() thành công để sử dụng hàm này
; ===============================================================================================================================
Func _SS_Admin_ChangeInfo($acc ,$info, $value)
	If Not IsArray($USER_DETAILS) Then Return 0
	$request = __HttpRequest(3, $__SYSTEM__URL & '/ss_admin.php?admin=changeinfo', 'acc=' & $USER_DETAILS[1] & '&pass=' & $USER_PASS & '&uacc=' & $acc & '&uinfo=' & $info & '&uvalue=' & $value)
	If Number($request) = 1 Then
		Return true
	Else
		Return False
	EndIf
EndFunc   ;==>_SS_ChangeInfo

Func __HttpRequest($a, $b, $c = '')
	Local $times = 0
	Do
	if $c = '' then
		$request =  _HttpRequest($a, $b)
	Else
		$request =  _HttpRequest($a, $b, $c)
	EndIf
	$times+= $times
	Until not @error or $request <> '' or $times >= 10
	if $times >= 10 Then
		MsgBox(16,'Thông báo','Lỗi kết nối với system')
		Exit
	EndIf
	Return $request
EndFunc
#EndRegion