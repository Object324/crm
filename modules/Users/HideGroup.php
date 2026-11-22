<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$smarty=new lingdangCRM_Smarty();
$record=$_REQUEST['record'];
$_REQUEST['diony']='diony';
global $current_user;
require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.".php");

$sql='select parentgroup from ld_groups where groupid=?';
$result=$adb->pquery($sql,array($record));
$parentgroup=$adb->query_result($result,0,'parentgroup');
$parentgroups=explode("::",$parentgroup);
if(sizeof($parentgroups)<=1||$parentgroups[1]<=0||$parentgroups[1]=='')
{
    if($languageType=='zh')
         ConvertTojsonString(-1,$arr,"不允许隐藏根部门");
    else
        ConvertTojsonString(-1,$arr,"The root department is not allowed to hide");
}
$allUser = [];
require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
$group_focus = new Group();
$groupuser=$group_focus->getGroupChild($record);
foreach($groupuser as $ky=>$content)
{
    $groupids[]=$content['groupid'];
}
 $sql="select distinct ld_users.id from ld_users INNER JOIN ld_users2group on ld_users2group.userid=ld_users.id ";
 $sql.=" and ld_users2group.groupid in (" .implode(',',$groupids)." ) and `status` = 'Active' ";
 // $sql.="where ld_users.id not in (select distinct userid from ld_users2group where groupid not in (".implode(',',$groupids)." ))";
$result=$adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
for($i=0;$i<$num_rows;$i++){
    $allUser[] = $adb->query_result($result,$i,'id');
}
if(empty($allUser)){
	ConvertTojsonString(1,array(),getFixedLabel("SUREWANTHIDE"));
}else{
	ConvertTojsonString("-2",array(),getFixedLabel("CANNOTHIDE"));
}
?>