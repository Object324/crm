<?php
$type =$_REQUEST['type'];
if($type=='smswork')
{
    include ('modules/CommunicationLog/smswork.php');
}
else
{
    include ('modules/CommunicationLog/smslist.php');
}

?>