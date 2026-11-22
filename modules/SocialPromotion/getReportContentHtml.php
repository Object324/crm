<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/7/16 18:06
 * Description: 获取当前查询条件的表单推广的统计报表的html
 */

global $currentModule,$adb;
$record = intval($_REQUEST['record']);
$startmonth = $_REQUEST['startmonth'];
$scope = strval($_REQUEST['SmOwnerSearchScope']);
$selectuserid = explode(',',strval($_REQUEST['selectuserid']));
$userid=array();
if($scope =='SmOwner_Search_All'){
    $userid='';
}elseif ($scope =='smowner_search_senior'){
    $userid = $selectuserid;
}elseif($scope =='SmOwner_Search_Group'){
    //获取所有的所选部门的人员
    require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
    $group = new Group();
    $groupids = $selectuserid;
    foreach ($groupids as $groupid){
        $tmpArr =array_keys($group->getGroupOfusers($groupid));
        if($tmpArr != ''){
            $userid = array_merge($tmpArr,$userid);
        }
    }
}else{
    $userid = array($scope);
}


crm_load_class_file('SocialPromotionForm','modules/SocialPromotion');
$focus = CRMEntity::getInstance($currentModule);
$focus->id =$record;
$focus->retrieve_entity_info($focus->id, $currentModule);
$form = new SocialPromotionForm('');
$smarty = new lingdangCRM_Smarty();
$betweenTime = explode(' - ',$startmonth);
//获取当前单据的所有人。
$allUsers = $form ->getRecordAllUsers($focus,$record);
$resultUsers = array();
//筛选人 如果本人没有查看权限，去除本人  尤其是选择部门的时候
foreach ($userid as $key=>$user){
    if(!in_array($user,$allUsers)){
        unset($userid[$key]);
    }
}

$mappingmodule = $focus->column_fields['mappingmodule'];
$allUsers = $form->getRecordAllUsers($focus,$record);
//表头
$colTitle =  $form->makeColTitle($mappingmodule);
$smarty->assign('colTitle',$colTitle);
$reportArr = $form->getReportFormListHtml($userid,$record,$mappingmodule,$allUsers,$betweenTime[0],$betweenTime[1]);

$smarty->assign('reportArr',$reportArr);
$content = $smarty->fetch('modules/SocialPromotion/SocialReportHtml.tpl');
$_REQUEST['diony'] = 'yes';
ConvertTojsonString(1,array('content'=>$content),'success');