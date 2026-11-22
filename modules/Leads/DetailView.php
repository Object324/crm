<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule, $singlepane_view,$adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $static_publicleads;
if(!isset($static_publicleads)){
    $sql_leadsid='select publicaccount from ld_leads  where leadsid=? limit 1;';
    $sql_result=$adb->pquery($sql_leadsid,array($_REQUEST['record']));
    $static_publicleads=$adb->query_result($sql_result,0,'publicaccount');
}
$focus = CRMEntity::getInstance($currentModule);

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
    $focus->id = $_REQUEST['record'];
	$focus->name=$focus->column_fields[$focus->list_link_field];
}
$smarty = new lingdangCRM_Smarty;
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicLeads = new cls_PublicLeads($currentModule);
$public_account = $cls_PublicLeads->getPublicAccountConfig();
if($public_account['status'] == 'yes'){
    $focus->setpublicaccountpool($public_account['public_account_pool']);
}
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
        $focus->id = "";
}

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

global $global_pick_list_values;
$smarty->assign("BLOCKS", getBlocks($currentModule,"detail_view",'',$focus->column_fields));
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", $currentModule);
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
$tabid = getTabid($currentModule);
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid)); //打印工具
$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);


$smarty->assign("MODULE",$currentModule);

$is_rel_list=isPresentRelatedLists($currentModule);
//ls 2022-01-22 0049657: （http://hnkdmd.gnddns.com:8000/crm/ [^]）（客户问题-苏锦文）销售线索》单据详情，相关信息设置，没显示公海日志选项
if(!empty($is_rel_list) && f_array_search('publicaccount_log',$is_rel_list)> 0 && $public_account['status'] != 'yes'){
    unset($is_rel_list[f_array_search('publicaccount_log',$is_rel_list)]);
}
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);

if(get_callLinkDisplay() == 'no'){
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}

$smarty->assign("IS_REL_LIST",$is_rel_list);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));//小编辑
$smarty->assign("SinglePane_View", $singlepane_view);

/* 关联创建 begin */
$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);

//@edit:liushuai,2020-09-04,reason:0042593: 销售线索启用审批流程，单据查看详情界面，右上角没有显示审批状态标签
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片

global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//chj 2021/1/5 44027: （https://61mis.com/kfbtest/ [^]）测试部账号，客户管理>客户1>全部（含指定公海）>批量领取123；该客户的公海状态：公海未分配 ，详情页面没有显示未分配的图标
$smarty->assign("PUBLICACCOUNT",$static_publicleads);

if($public_account['status'] == 'yes'){
    $transfer_permit = 'no';
    $public_account_pool = [];
    if(!empty($public_account['public_account_pool'])){
        $sql_leadsid='select pool_id,publicaccount from ld_leads  where leadsid=? limit 1;';
        $sql_result=$adb->pquery($sql_leadsid,array($_REQUEST['record']));
        $acc_pool_id=$adb->query_result($sql_result,0,'pool_id');
        $publicaccount=$adb->query_result($sql_result,0,'publicaccount');
        foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
            if($acc_pool_id != $pool_id && $focus->column_fields['publicaccount'] >= 1)continue;
            $admins = explode(',',(string)$pool_info['administrators']);
            $transfer_users_array = explode(',',(string)$pool_info['transfer_users']);	//允许“转换公海”的成员

            $userids = explode(',',(string)$pool_info['userids']);
            
            if($focus->column_fields['publicaccount'] == 0 && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array) || in_array($current_user->id,$userids))){	//如果该客户是“普通客户”，则仅当用户是“公海管理员”时显示按钮
                $transfer_permit = 'yes';
                break;
            }else if($focus->column_fields['publicaccount'] == 1 && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array))){	//如果该客户是“公海未分配客户”，则仅当用户是“公海管理员”时显示按钮
                $transfer_permit = 'yes';
                break;
            }else if(($focus->column_fields['publicaccount'] == 2 || $focus->column_fields['publicaccount'] == 3) && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array) || (in_array($current_user->id,$userids) && $pool_info['allow_trasnfer_others'] == 'yes'))){	//如果该客户是“公海已分配客户”，并且当前用户是“公海管理员”时显示按钮
                //当前用户只是“公海用户”且该客户“所属公海”的参数设置勾选了“允许公海成员将已分配或领取的公海客户移客户到其他公海”时，也显示“转换公海”按钮
                $transfer_permit = 'yes';
                break;
            }
        }


        //获取当前用户有权限看到的公海池
        foreach($public_account['public_account_pool'] as $temp_pool_id => $pool_info){
            if(!empty($pool_info['administrators'])){
                $admins = explode(',',(string)$pool_info['administrators']);
                if(in_array($current_user->id,$admins)){
                    $public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
                }
                //公海客户“公海已分配”页签：可选公海仅显示当前用户是“公海管理员”或“公海成员”的公海池
                $userids = explode(',',(string)$pool_info['userids']);
                if(in_array($current_user->id,$userids)){
                    $public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
                }
            }
        }
        //公海未分配、公海已分配 。 过滤当前公海池
        if($publicaccount >= 1 && !empty($acc_pool_id)){
            unset($public_account_pool[$acc_pool_id]);
        }
    }
    if($transfer_permit == 'yes' && !empty($public_account_pool) && isPermitted($currentModule,"EditView",$_REQUEST['record']) == 'yes'){
        $publicbutton['turnhighseas'] = getFixedLabel('Transfer');
    }

    $smarty->assign('POOL_ID',$focus->column_fields['pool_id']);

    //ls 2022-02-23 公海状态字段未开启时，需查询优化
    if(!isset($focus->column_fields['publicaccount'])){
        $result = $adb->pquery("select publicaccount from ld_account where accountid = ?",array($focus->id));
        $focus->column_fields['publicaccount'] = $adb->query_result($result,0,0);
    }
    if(isset($focus->column_fields['publicaccount'])){
        if($focus->column_fields['publicaccount'] == 1){
            $smarty->assign('PUBLICACCOUNTTYPE','NOALLOCATE');
        }else if($focus->column_fields['publicaccount'] == 2 || $focus->column_fields['publicaccount'] == 3){
            $smarty->assign('PUBLICACCOUNTTYPE','PUBLICALLOCATE');
        }else{
            $smarty->assign('PUBLICACCOUNTTYPE','COMMONACCOUNT');
        }
    }

}
$focus->logic->setPublicDetailBtn($publicbutton);
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);

//判断是否启用公海客户
//$status=getAccount_Set('status');
$smarty->assign('PUBLICACCOUNTSTATUS',$public_account['status']);
//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);
//布局规则
/*
$_REQUEST['diony']='yes';
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();////获取所有的触发字段
//$arr['datetimestr']=CommonView::stdFilterDateTimeStr();
$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;
$arr['column_fields_value']=$detail_column_fields_value;
$arr['fields']=$fields['fields'];
$arr['title']=getTranstab($currentModule);
$arr['list_link_field']=$focus->list_link_field;
//$arr['oktext']=getFixedLabel("SAVE");
//$arr['canceltext']=getFixedLabel("CANCEL");
$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
$arr['content']=$content;
ConvertTojsonString(1,$arr,'success');*/
?>