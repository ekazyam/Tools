<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">

	<link rel="stylesheet" href="css/style.css">
	<link rel="stylesheet" href="js/alert/themes/alertify.core.css">
	<link rel="stylesheet" href="js/alert/themes/alertify.default.css">
	
	<script type="text/javascript" src="js/jquery-1.10.2.js"></script
	<script type="text/javascript" src="js/alertify.js"></script>
	<script type="text/javascript" src="js/munin_change.js"></script>
	<script src="js/alert/lib/alertify.js"></script>
</head>
<body>
	<form name="form" method="POST" action="">
<?php 
	if (isset($_POST['munin_radio']))
	{
		$target = str_replace('static_' , '' , $_POST['munin_radio'] );
		$command = './changetemplate.sh ' . $target;
		exec($command);
	}
	include_once('./create_table.php');
	create_table();
?>
	<input type="submit" id="change" value="submit" >
	</form>
</body>
</html>
