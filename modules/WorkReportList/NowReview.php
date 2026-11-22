<?php
header("Content-type: text/html; charset=utf-8");
global $current_user,$currentModule,$adb,$theme;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance($currentModule);

if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($_REQUEST['record'],'WorkReportList');
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());

}else{
    throw new Exception('record error');
}

$method = $_REQUEST['method'];
if ($method == 'savereader') {//保存点评内容
    require 'modules/Home/WorkReportController.php';
    $workreport_focus = new WorkReportController();

    $workreportid = $_REQUEST['workreportid'];
    //未点评的单据才保存评论
    if ($focus->column_fields['approved'] != '1') {
        $workreport_focus->savereader();
    }
    ConvertTojsonString(1,array(),'success');
    exit();
}



$detail_query = $focus->getDetailQuery();
$result = $adb->pquery($detail_query, array());
$num_rows=$adb->num_rows($result);
$detailData = [];//单据字段信息  //dump($focus->column_fields);
if ($num_rows > 0) {
    $detailData = $adb->query_result_all($result)[0];

    //不同类型下要显示的字段(即汇报内容部分)
    $showspecialcolumns = $focus->getShowSpecialColumn();
    foreach ($showspecialcolumns as &$columninfo) {
        $columnname = $columninfo['columnname'];
        $columninfo['value'] = $detailData[$columnname];
    }
    $smarty->assign("ShowSpecialColumnInfo", $showspecialcolumns);

    //点评人
    $reuserid=$detailData['reuser'];
    $reuser_lastname = '';
    if (!empty($reuserid)) {
        $query = "select wx_userid,last_name from ld_users where id = ? limit 1";
        $tmp_result = $adb->pquery($query, array($reuserid));
        if ($adb->num_rows($tmp_result) >= 1) {
            $userobj = new Users();
            $userobj->wx_userid = $adb->query_result($tmp_result,0,'wx_userid');
            $userobj->last_name = $adb->query_result($tmp_result, 0, 'last_name');
            $reuser_lastname = getUserlastName($userobj);
        }
    }
    $detailData['readername'] = $reuser_lastname;

    $type=$detailData['type'];
    $sendlog_workdate=$detailData['sendlog_workdate'];
    if ($type == 1) {
        $timestr = date('Y年m月d日', strtotime($sendlog_workdate));
        $StayCommentInfo .= $timestr." ".getFixedLabel('JOURNAL');
        $detailData['typelabel'] = getFixedLabel('JOURNAL');
    } elseif ($type == 2) {
        $timestr1Arr = explode(" ~ ", $sendlog_workdate);
        $timestr1_1 = date('Y年m月d日', strtotime($timestr1Arr[0]));
        $timestr1_2 = date('Y年m月d日', strtotime($timestr1Arr[1]));
        $StayCommentInfo .= $timestr1_1."-".$timestr1_2." "." ".getFixedLabel('WEEKPLAN');
        $detailData['typelabel'] = getFixedLabel('WEEKPLAN');
    } elseif ($type == 3) {
        $timestr2Arr = explode(" ~ ", $sendlog_workdate);
        $timestr2 = date('Y年m月', strtotime($timestr2Arr[0]));
        $StayCommentInfo .= $timestr2." ".getFixedLabel('MONTHPLAN');
        $detailData['typelabel'] = getFixedLabel('MONTHPLAN');
    }

    $creatorInfo = $focus->getUserImage($detailData['smcreatorid']);
    $detailData['userimage'] = $creatorInfo['userimage'];//创建人头像

}
//dump($detailData);
$smarty->assign("detailData", $detailData);

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);

$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("RECORD", $_REQUEST['record']);

//Security check for related list
$category = getParentTab();
$smarty->assign("CATEGORY",$category);

$smarty->assign("MODULE",$currentModule);

$smarty->assign("HAVEMODCOMMENTS",'no');
setGLobalURLSmarty($smarty);


global $global_pick_list_depencyfield;
global $global_pick_list_values;
global $global_picklist_colors,$global_picklist_colors_byvalue;
global $detail_column_fields_value,$current_user;
$_REQUEST['diony']='yes';
$fields=$focus->fieldobj->getFieldListArray();
$arr['fields']=$fields['fields'];

$smarty->assign('ISADMIN',$current_user->is_admin);


$arr['column_fields_value']=$detail_column_fields_value;
$arr['isadmin']=$current_user->is_admin;

$languageType= getLanguageType($current_user);
if($languageType=='zh'){
    $colon = '：';
} else {
    $colon = ':';
}

$arr['title'] = "点评".$focus->workreport_logtype[$focus->column_fields['type']];
$arr['oktext'] = "点评";
$arr['canceltext'] = getFixedLabel('CANCEL');


$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;

$arr['list_link_field']=$focus->list_link_field;

$content=$smarty->fetch("modules/WorkReportList/ReviewPop.tpl");
$arr['content']=$content;
ConvertTojsonString(1,$arr,'success');

?>