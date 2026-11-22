<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'modules/lingdang/EditView.php';

/*
*edit:diony
*time:20140909
*reason:呼叫弹屏
**/
if (isset($_REQUEST['vendorscallid']) && $_REQUEST['vendorscallid'] != '') {
    $vendorsid = $_REQUEST['vendorscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select vendorid,vendorname from ld_vendor where vendorid=?", array($vendorsid));
	$vendorname = $adb->query_result($result, 0, 'vendorname');
    $smarty->assign("VENDORID", $vendorsid);
    $smarty->assign("VENDORNAME", $vendorname);
}

if (isset($_REQUEST['vendorcontactcallid']) && $_REQUEST['vendorcontactcallid'] != '') {
    $vendorcontactid = $_REQUEST['vendorcontactcallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select T1.vendorid,vendorname,vendorcontactsid,lastname from ld_vendorcontacts as T1 
    left join ld_vendor as T2 on T1.Vendorid = T2.vendorid
    where vendorcontactsid = ?", array($vendorcontactid));
    $vendorid = $adb->query_result($result, 0, 'vendorid');
    $vendorname = $adb->query_result($result, 0, 'vendorname');
    $lastname = $adb->query_result($result, 0, 'lastname');
    $smarty->assign("VENDORID", $vendorid);
    $smarty->assign("VENDORNAME", $vendorname);
    $smarty->assign("VENDORCONTACTID", $vendorcontactid);
    $smarty->assign("LASTNAME", $lastname);
}

/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));

//diony 2014-10-15 弹屏新增时自动传值
if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['callfilename']) && $_REQUEST['callfilename'] != '')
{
      $one_callfiles=explode('\\',$_REQUEST['callfilename']);
     $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
     $callfilenames=explode('_',$two_callfilename);
     $callphone=$callfilenames[0];
     $xinghao_phone= fieldValueUitype::setReportMobileStyle($callphone);
     for($i=0;$i<sizeof($one_callfiles)-1;$i++)
     {
        $filenames.=$one_callfiles[$i].'\\';
     }
    $one_filenames=$filenames.$xinghao_phone.'_'.$callfilenames[1];
    crm_load_class_file('cls_PhoneEncrypt','include');
    $obj=new cls_PhoneEncrypt();
 
    $two_filenames=$filenames.$obj->createToken_Phone($callphone).'_'.$callfilenames[1] ;

    $smarty->assign('CALLFILENAME',$one_filenames);
    $smarty->assign('ENCRYPT_FILENAME',$two_filenames);
	$smarty->assign('CALLTYPE',$_REQUEST['calltype']);
    $smarty->assign('CALLDISPLAY','yes');
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

/* editor:gyq_11 reason:九维呼叫通话记录id date:20160603*/
if(!empty($_REQUEST['jiuweiid'])){
    $smarty->assign('JiuWeiAccount',$_REQUEST['jiuweiid']);
    $smarty->assign('CALLCENTERSWITCH',$_REQUEST['callcenter_switch']);
}
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
setGLobalURLSmarty($smarty);//设置js,css等访问路径
if($_REQUEST['callfilename11111']||$_REQUEST['callphone1111'])
{
    $smarty->display("DetailView/EditRelated.tpl");
    

}
else
{
    
    $str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
    $_REQUEST['diony']='diony';
    if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
    } else {
        $arr['title'] = getTranstab($currentModule);
    }
    $arr['approve_arr']=$approve_arr;
    $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');

    //zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
    $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
    $is_page_setting = "no";
    if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
        $is_page_setting = "yes";
    }
    $arr['is_page_setting'] = $is_page_setting;

    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$quickcreatestr;
    $arr['allcontent']=$str;
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['isadmin']=$current_user->is_admin;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
    $arr['picklistcontent']=$global_pick_list_values;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
    $arr["validatasaverule"]=getAllRule($currentModule);
    //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
      
    ConvertTojsonString(1,$arr,"success");
}
?>