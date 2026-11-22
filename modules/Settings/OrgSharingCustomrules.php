<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty;

$data = [];
$advft_criteria = [];
$advft_criteria_groups = [];

if(!empty($_REQUEST['customrule_id'])){
    $query = "select tabid,permission,profileid,groupid,userid,share_demand,share_demand_groups from ld_org_share_customrules where customruleid=?";
    $result = $adb->pquery($query,array($_REQUEST['customrule_id']));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $tabid = $adb->query_result($result,0,'tabid');
        $_REQUEST['tabid']=$tabid;
        $permission = $adb->query_result($result,0,'permission');

        $profileid = $adb->query_result($result,0,'profileid');
        if(!empty($profileid)){
            $profileid_arr=explode(',',trim($profileid));//指定角色
            if(sizeof($profileid_arr)>0){
                $profile = new Profile();
                foreach($profileid_arr as $tmp_profileid)
                {
                    $profileinfo = $profile->getProfileinfo($tmp_profileid);
                    $profilename_arr[] .= $profileinfo['profilename'];
                }
                $profilename = implode(',',$profilename_arr);
            }
        }
        $groupid = $adb->query_result($result,0,'groupid');
        if(!empty($groupid)){
            $groupid_arr=explode(',',trim($groupid));//指定部门
            if(sizeof($groupid_arr)>0){
                foreach($groupid_arr as $tmp_groupid) {
                    $groupname_arr[] .= getGroupFullName($tmp_groupid);
                }
                $groupname = implode(',',$groupname_arr);
            }
        }
        $userid = $adb->query_result($result,0,'userid');
        if(!empty($userid)) {
            $userid_arr = explode(',', trim($userid));//指定用户
            if (sizeof($userid_arr) > 0) {
                foreach ($userid_arr as $tmp_userid) {
                    $username_arr[] .= getUserFullName($tmp_userid);
                }
                $username = implode(',', $username_arr);
            }
        }

        $module=getTabModuleName($tabid);
        $modulename=getTranstab($module);
        $advft_criteria = $adb->query_result($result,0,'share_demand');
        $advft_criteria_groups = $adb->query_result($result,0,'share_demand_groups');
        $data = array(
            'USERID' => $userid,
            'GROUPID' => $groupid,
            'PROFILEID' => $profileid,
            'permission' => $permission,
            'USERNAME' => $username,
            'GROUPNAME' => $groupname,
            'PROFILENAME' => $profilename
        );
    }
}else{
    $tabid = $_REQUEST['frommodule'];
    if($tabid>0) {
        $_REQUEST['tabid']=$tabid;
        $module = getTabname($tabid);
        $modulename=getTranstab($module);
    }
}
crm_load_class_file('CommonView',"modules/CustomView");
include(globalStatic::$root_directory.'modules/Settings/OrgshareCustomruleAdvSearch.php');
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$fLabels['has_changed']=getFixedLabel('haschanged');	//有改变
$fLabels['has_changed_to'] =getFixedLabel('haschangedto');	//有改变-变更后
$fLabels['has_changed_from']= getFixedLabel('haschangedfrom');	//有改变-变更前
$arr['flabels']=$fLabels;
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
$arr['foption']=$advfilterhtml;
if(!empty($module)) {
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    $controller = ListViewController::getInstance($module);
    $arr['advanceFields'] = $controller->getAdvanceFields();
}
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;
else
    $arr['criteria_groups']="";

$smarty->assign("tabid",$tabid);
$smarty->assign('CUSTOMRULE_ID',$_REQUEST['customrule_id']);
$smarty->assign('DATA',$data);

$arr['title'] = getFixedLabel(getFixedLabel('CUSTOMRULES'));
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('OrgSharingCustomrules.tpl');
ConvertTojsonString(1,$arr,"success");

?>

