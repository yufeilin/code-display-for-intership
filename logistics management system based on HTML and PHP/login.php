<html>
<body>
<?php 
	session_start();

	$account=$_POST['account'];
	$pwd=$_POST['pwd'];
	if (!$account || !$pwd) {
		echo 'You have not entered all the required details.<br />Please go back and try again.';
		exit;
	}
	if (!get_magic_quotes_gpc()) {
		$account=addslashes($account);
		$pwd=addslashes($pwd);
	}
	@ $db=new mysqli('localhost','root','gdhygjzx7','db_class');
	if (mysqli_connect_errno()) {
		echo 'Error:Could not connect to database.Please try again later.';
		exit;
	}
	$query="select account_name from account where account_name='".$account."';";
	$result=$db->query($query);
	$row=mysqli_fetch_assoc($result);
	if (!$row['account_name']) {
		echo 'no this account!<br>';
	}
	$query="select passwd from account where account_name='".$account."';";
	$result=$db->query($query);
	$row=mysqli_fetch_assoc($result);
	if ($row['passwd']==$pwd) {
		echo 'login succeed.';
		echo '<br>';
		$_SESSION['valid_user']=$account;
		echo "<script>location.href='database.php';</script>";
	}
	else {
		echo 'error password!<br>';
	}
	//echo $row['account'];
	
	//echo $result;                    1
	//echo gettype($result);           boolean
	$db->close();	

?>
</body>
</html>
