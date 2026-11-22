<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$smarty=new lingdangCRM_Smarty();
$type=$_REQUEST['type'];
$_REQUEST['diony']='diony';
global $current_user;
require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.".php");


 if($_REQUEST['type']=='popup')
 {
 	$sql = 'select groupid from ld_groups where is_hidden="yes"';
 	$result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);

    for($i=0;$i<$rows;$i++)
    {
        $hiddengroup[]=$adb->query_result($result,$i,'groupid');
    }
    $arr['groupid'] = implode(',', $hiddengroup);
   ConvertTojsonString(1,$arr,"success");
    
    
 }
 else if($_REQUEST['type']=='save')
 {
    $_REQUEST['diony']='diony';
    // $userlist=explode(",",$_REQUEST['userlist']);
    $grouplist=explode(",",$_REQUEST['grouplist']);
    $sql='update ld_groups set is_hidden="no" where groupid in ('.implode(',',$grouplist).' )';
    $adb->pquery($sql,array());
    ConvertTojsonString(1,array(),"success");
    
 }
?>