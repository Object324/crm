<?php


$sql='select  * from ld_users where ifnull(trackgroupid,0)>0 and trackgroupid in (SELECT ld_trackpostion.trackpostion_id from ld_trackpostion)';
$result=$adb->pquery($sql,array());

for($i=0;$i<$adb->num_rows($result);$i++)
{
    $wx_userid=$adb->query_result($result,$i,'wx_userid');
    $last_name=$adb->query_result($result,$i,'last_name');
    $tmpuserid=$adb->query_result($result,$i,'id');
    $userobj=new Users();
    $userobj->last_name=$last_name;
    $userobj->wx_userid=$wx_userid;
    $userobj->id=$tmpuserid;
    if($i==0&&!isset($_REQUEST['userid']))$_REQUEST['userid'] = $tmpuserid;
    $selected = false;
    if($i==0){
        $selected = true;
    }
//$MergeSmowner["UserCombo"][$tmpuserid]=[getUserlastName($userobj)=>''];
    $SmOwner_option_arr[]= array('label'=>getUserlastName($userobj),'value'=>$tmpuserid,'selected'=>$selected);
}

if(!isset($_REQUEST['searchdate']))$_REQUEST['searchdate'] = date('Y-m-d');

global $currentModule,$current_user;
crm_load_class_file("TrackLocationList","Register");
$_REQUEST['diony']='yes';
$obj=new TrackLocationList($_REQUEST['userid'],$_REQUEST['searchdate']);
$arr=$obj->getList();

if($_REQUEST['ajax']=='yes')
{
    ConvertTojsonString(1,['list'=>$arr],'success');
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign("trackpositionjsonstr",json_encode($arr));





//应该获取设置定位的用户
//$newCustomView = new ProductDetails($module);
$morelist = 1;

// Identify this module as custom module.
$smarty->assign('MORE_LIST',$morelist);
//print_r($newCustomView->getRowCount());
$smarty->assign("nowdate",date("Y-m-d"));


$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
if($_REQUEST['resetmap'] == 'yes'){
    $content= $smarty->fetch('TrackLocationMap.tpl');
    ConvertTojsonString(1,['list'=>$arr,'content'=>$content],'success');
}

$smarty->display("TrackLocationMap.tpl");


?>