<?php
if (isset($_POST['template_data']))
{
	shell_exec('echo OK > /tmp/yamashita.txt');
}else{
	shell_exec('echo NG > /tmp/yamashita.txt');
}
?>
