<?php
global $adb,$currentModule;
$viewid=vtlib_purify($_REQUEST['cvid']);

$queryGenerator = new QueryGenerator('Accounts', $current_user);
$queryGenerator->initForCustomViewById($viewid);
$list_query = $queryGenerator->getQuery();//分组查询条件

$result=$adb->pquery($list_query,array());
$accountid= "";

for($i=0;$i<$adb->num_rows($result);$i++)
{
       $accountid .= "'".$adb->query_result($result,$i,'accountid')."',"; 
}
echo "####$$$$".$accountid."####$$$$";

?>