<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$currentModule,$adb,$theme;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$_REQUEST['diony']='yes';

$focus = CRMEntity::getInstance($currentModule);
if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($_REQUEST['record'],'WorkReportList');
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
}else{
    throw new Exception('record error');
}
$smarty = new lingdangCRM_Smarty;

$detail_query = $focus->getDetailQuery();
$result = $adb->pquery($detail_query, array());
$num_rows=$adb->num_rows($result);
$detailData = [];//单据字段信息  //dump($focus->column_fields);
if ($num_rows > 0) {
    $detailData = $adb->query_result_all($result)[0];

    //不同类型下要显示的字段(即日志部分)
    $showspecialcolumns = $focus->getShowSpecialColumn();
    foreach ($showspecialcolumns as &$columninfo) {
        $columnname = $columninfo['columnname'];
        $columninfo['value'] = $detailData[$columnname];
    }
    $smarty->assign("ShowSpecialColumnInfo", $showspecialcolumns);

    //关联客户
    $accountlist = $contactlist = $productlist = '';
    $query = '';
    if (!empty($detailData['relatedto_account'])) {
        $query = "select 'Accounts'  as relatedtab,accountid as record,accountname as name
					from  ld_account where accountid in(".$detailData['relatedto_account'].") and ld_account.deleted=0";
        $query_result = $adb->pquery($query, array());
        for ($i = 0; $i < $adb->num_rows($query_result); $i++) {
            $accountlist .= '<span><a href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record='.$adb->query_result($query_result,$i,'record').'" target="_blank">'.$adb->query_result($query_result,$i,'name').'</a></span><br>';
        }
    }
    $smarty->assign("AccountList", $accountlist);

    if (!empty($detailData['relatedto_contact'])) {
        $query = "select 'Contacts'  as relatedtab,contactid as record,lastname as name
					from  ld_contactdetails where contactid in(".$detailData['relatedto_contact'].") and ld_contactdetails.deleted=0";
        $query_result = $adb->pquery($query, array());
        for ($i = 0; $i < $adb->num_rows($query_result); $i++) {
            $contactlist .= '<span><a href="index.php?pageto_module=Contacts&pageto_action=index&pageto_record='.$adb->query_result($query_result,$i,'record').'" target="_blank">'.$adb->query_result($query_result,$i,'name').'</a></span><br>';
        }
    }
    $smarty->assign("ContactList", $contactlist);

    if (!empty($detailData['relatedto_product'])) {
        $query = "select 'Products'  as relatedtab,productid as record,productname as name
					from  ld_products where ld_products.productid in(".$detailData['relatedto_product'].") and ld_products.deleted=0";
        $query_result = $adb->pquery($query, array());
        for ($i = 0; $i < $adb->num_rows($query_result); $i++) {
            $productlist .= '<span><a href="index.php?pageto_module=Products&pageto_action=index&pageto_record='.$adb->query_result($query_result,$i,'record').'" target="_blank">'.$adb->query_result($query_result,$i,'name').'</a></span><br>';
        }
    }
    $smarty->assign("ProductList", $productlist);


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
    $detailData['readername'] = $reuser_lastname;//点评人

    $type=$detailData['type'];
    $sendlog_workdate=$detailData['sendlog_workdate'];

    if ($type == 1) {
        $timestr = date('Y年m月d日', strtotime($sendlog_workdate));
        $StayCommentInfo .= $timestr." ".getFixedLabel('JOURNAL');
    } elseif ($type == 2) {
        $timestr1Arr = explode(" ~ ", $sendlog_workdate);
        $timestr1_1 = date('Y年m月d日', strtotime($timestr1Arr[0]));
        $timestr1_2 = date('Y年m月d日', strtotime($timestr1Arr[1]));
        $StayCommentInfo .= $timestr1_1."-".$timestr1_2." "." ".getFixedLabel('WEEKPLAN');
    } elseif ($type == 3) {
        $timestr2Arr = explode(" ~ ", $sendlog_workdate);
        $timestr2 = date('Y年m月', strtotime($timestr2Arr[0]));
        $StayCommentInfo .= $timestr2." ".getFixedLabel('MONTHPLAN');
    }
    if (!empty($reuser_lastname)) {
        $StayCommentInfo .= " 由<span class=''>".$reuser_lastname."</span>点评";
    }
    $smarty->assign("StayCommentInfo", $StayCommentInfo);//待点评的展示信息

}

$smarty->assign("detailData", $detailData);
/* 详情页增加删除按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

global $global_pick_list_values;
//$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("BLOCKS", $blocks);
//$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));


$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("SINGLE_MOD", 'WorkReportList');
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
$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;
$arr['list_link_field']=$focus->list_link_field;

$content=$smarty->fetch("modules/WorkReportList/DetailView.tpl");
$arr['content']=$content;
//zxm 20221209 title新的样式
include(globalStatic::$root_directory.'include/utils/DetailViewUtils.php');
$arr['title'] = getDetailViewTitle($currentModule,$focus);
$arr['detailButtons'] = getDetailViewBtns($currentModule,$focus);
//dump($arr);
ConvertTojsonString(1,$arr,'success');

?>