#include <Inet.au3>
#include <FTP.au3>
#include <array.au3>
#include '_Startup.au3'

$sName = "RemoteControl"
_StartupRegistry_Install($sName)

$server = "host"
$username = "username"
$pass = "password"
$screen = "/";Directory from root for PHP and screen shot
$php = "http://" & $server & $screen;PHP Directory Location On The Server
$TimeInt = 3000 ;refresh time
$phpurl = $php & "remote.php"
;SETTINGS  ^^^^^^^^^^
AutoItSetOption("WinTitleMatchMode", 2)
AutoItSetOption("RunErrorsFatal", 0)
While 1
	$text = _INetGetSource ( $php & "com.con" )
	;_INetGetSource ( $phpurl & "?clear=1") <=CLEARS FILE, NOT NEEDED BECAUSE TEXTIN CLEARS FIRST
	If $text <> "" Then
		$text = StringMid ( $text, 1, StringInStr($text, "<!" )-1)
		ConsoleWrite($text & @CR); PUTS OUT CURRENT COMMON FILE TEXT
		$func = funcfind()
		If $func <> "" Then _INetGetSource ( $phpurl & "?textin=" & $func & " at " & @HOUR & ":" & @MIN & ":" & @SEC)
		$text = ""
	EndIf
	Sleep($TimeInt)
WEnd

Func funcfind()
	$gettext = StringSplit($text, "*")
	$ubound = UBound($gettext)-1
	If $ubound > 0 Then
		;ConsoleWrite($ubound)
		Select
			Case $gettext[1] = "quit"
				Exit
			Case $gettext[1] = "dir"
				Dim $dir
				_ArrayDelete($gettext, 0)
				$directory = _ArrayToString ( $gettext, "*" )
				$directory = StringReplace($directory, "dir*", "")
				$directory = StringReplace($directory, "\\", "\")
				$search = FileFindFirstFile($directory)
				$dir = _ArrayCreate("")
				If $search = -1 Then
					Return "No files/directories matched the search pattern"
				EndIf
				While 1
					$file = FileFindNextFile($search)
					If @error Then ExitLoop
					_ArrayAdd ( $dir, $file )
				WEnd
				FileClose($search)
				$dirout = _ArrayToString ( $dir, "&" )
				$dirout = StringReplace( $dirout, "&", "<br>" )
				Return "Files in folder: " & $directory & "<br>" & $dirout & "<BR><BR>Directory listed "
			Case $gettext[1] = "screen"
				DllCall("captdll.dll", "int", "CaptureScreen", "str", @TempDir & "\screen.jpg", "int", 40)
				$data = "screenput=" & FileRead( @TempDir & "\screen.jpg" )
				$Open = _FTPOpen('MyFTP Control')
				$Conn = _FTPConnect($Open, $server, $username, $pass)
				_FTPDelFile($Conn, $screen & "screen.jpg")
				$Ftpp = _FtpPutFile($Conn, @TempDir & '\screen.jpg', $screen & "screen.jpg")
				Return "Screen Captured - <a href=" & "screen.jpg" & ">IMAGE</a>"
			Case $gettext[1] = "timeint" And $ubound=2
				$TimeInt = $gettext[2]
				Return "Time set"
			Case $gettext[1] = "say" And $ubound=2
				_TalkOBJ($gettext[2], 3)
				Return "Said: " & $gettext[2]
			Case $gettext[1] = "close" And $ubound=2
				$return = WinClose($gettext[2])
				If $return = 1 Then
					Return "Closed: " & $gettext[2]
				Else
					Return "Could not close: " & $gettext[2]
				EndIf
			Case $gettext[1] = "kill" And $ubound=2
				$return = WinClose($gettext[2])
				If $return = 1 Then
					Return "Killed: " & $gettext[2]
				Else
					Return "Could not kill: " & $gettext[2]
				EndIf
			Case $gettext[1] = "processclose" And $ubound=2
				ProcessClose($gettext[2])
				Return "Process Closed: " & $gettext[2]
			Case $gettext[1] = "filedel" And $ubound=2
				$gettext[2] = StringReplace($gettext[2], "\\", "\")
				FileDelete($gettext[2])
				Return "File deleted: " & $gettext
			Case $gettext[1] = "filerun" And $ubound=2
				$gettext[2] = StringReplace($gettext[2], "\\", "\")
				AutoItSetOption("RunErrorsFatal", 0)
				Run($gettext[2])
				If @error = 1 then $return = "Error running program: " & $gettext[2]
				AutoItSetOption("RunErrorsFatal", 1)
				Return "File ran: " & $gettext[2]
			Case $gettext[1] = "filemove" And $ubound=3
				$gettext[2] = StringReplace($gettext[2], "\\", "\")
				$gettext[3] = StringReplace($gettext[3], "\\", "\")
				FileMove($gettext[2], $gettext[3], 9)
				Return "File moved from: " & $gettext[2] & " to " & $gettext[3]
			Case $gettext[1] = "filecopy" And $ubound=3
				$gettext[2] = StringReplace($gettext[2], "\\", "\")
				$gettext[3] = StringReplace($gettext[3], "\\", "\")
				FileCopy($gettext[2], $gettext[3], 9)
				Return "File Copied from: " & $gettext[2] & " to " & $gettext[3]
			Case $gettext[1] = "beep" And $ubound=3
				Beep($gettext[2], $gettext[3])
				Return "Beeped on freqency: " & $gettext[2] & " for " & $gettext[3] & " milliseconds"
			Case $gettext[1] = "media" And $ubound=2
				Select
					Case $gettext[2] = "open"
						Run('C:\Program Files\Windows Media Player\wmplayer.exe')
						If @error = 1 then $return = "Error opening Windows Media Player"
					Case $gettext[2] = "next"
						send("{MEDIA_NEXT}")
					Case $gettext[2] = "back"
						send("{MEDIA_PREV}")
					Case $gettext[2] = "play"
						Send("{MEDIA_PLAY_PAUSE}")
					Case $gettext[2] = "stop"
						send("{MEDIA_STOP}")
					Case $gettext[2] = "up"
						send("{VOLUME_UP}")
					Case $gettext[2] = "down"
						send("{VOLUME_DOWN}")
					Case $gettext[2] = "mute"
						send("{VOLUME_MUTE}")
					Case $gettext[2] = "fullscreen"
						WinActivate( "Windows Media Player" )
						Send("{Alt}{Enter}")
				EndSelect
				Return "Ran media command: " & $gettext[2]
			Case $gettext[1] = "au3"
				$gettext[2] = StringReplace($gettext[2], '@crlf', @CRLF)
				$gettext[2] = StringReplace($gettext[2], '\"', '"')
				$gettext[2] = StringReplace($gettext[2], "\'", "'")
				$au3file = FileOpen ( @TempDir & "\temp.au3", 2 )
				FileWrite( $au3file, $gettext[2] )				
				FileClose( $au3file )
				ConsoleWrite( $gettext[2] )
				Run(@AutoItExe & ' /AutoIt3ExecuteScript ' & '"' & @TempDir & "\temp.au3" & '"')
				If @error then Return "Error running interpreter: " & $gettext[2];INCORRECT, MUST FIX
				Return "Ran command: " & $gettext[2]
			Case $gettext[1] = "logoff"
				Shutdown (0)
			Case $gettext[1] = "shutdown"
				Shutdown (1)
			Case $gettext[1] = "reboot"
				Shutdown (2)
			Case $gettext[1] = "sleep"
				Shutdown (32)
			Case $gettext[1] = "hybernate"
				Shutdown (64)
				;case Else
				;Return "Error or at Idle"
		EndSelect
	EndIf
EndFunc

Func _TalkOBJ($s_text, $s_voice = 3)
	Local $quite = 0
	Local $o_speech = ObjCreate ("SAPI.SpVoice")
	Select
		Case $s_voice == 0
			Return
		Case $s_voice == 1
			$o_speech.Voice = $o_speech.GetVoices("Name=Microsoft Mary", "Language=409").Item(0);female
		Case $s_voice == 2
			$o_speech.Voice = $o_speech.GetVoices("Name=Microsoft Mike", "Language=409").Item(0);male
		Case $s_voice == 3
			$o_speech.Voice = $o_speech.GetVoices("Name=Microsoft Sam", "Language=409").Item(0);sam
	EndSelect
	$o_speech.Speak ($s_text)
	$o_speech = ""
	Sleep(1000)
	TrayTip("","",1)
EndFunc ;==>_TalkOBJ