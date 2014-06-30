<html><head>
<title>Remote PC Control</title>
</head>
<body bgcolor ="black">
<center>
<font color="red">
<?
$fp = fopen("com.con", "r");
$read = fread($fp,1000);
fclose($fp);
echo $read;
?>
<form method="POST">
<input name="textout" type="hidden" value="1">
<input type="submit" value="Update Output">
<BR>
<form method="POST">
Other Command<BR>
<textarea name="textin" cols="100" rows="10"></textarea>
<BR>
<input type="submit" value="Send Command">
<BR><BR><BR><BR>
</center>
</form>
</html>Written by:<BR>Beqa Gozalishvili</font></blink>
<BR><BR><BR>
</center>
</form>
</html>
<?php
if($_REQUEST["clear"]==1){
$fp = fopen("com.con", "w");
fwrite($fp, "");
fclose($fp);
};
if($_REQUEST["testout"]==1){
$fp = fopen("com.con", "r");
$read = fread($fp,1000);
fclose($fp);
echo $read;
};
if ($_REQUEST["textin"]!=""){
$textin = $_REQUEST["textin"];
$fp = fopen("com.con", "w");
fwrite($fp, $textin);
fclose($fp);
};
php?>