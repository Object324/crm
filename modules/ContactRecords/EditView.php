<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once 'modules/lingdang/EditView.php';

/*
*edit:diony
*time:20140909
*reason:呼叫弹屏
**/
if (isset($_REQUEST['accountscallid']) && $_REQUEST['accountscallid'] != '') {
    $accountid = $_REQUEST['accountscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select accountid,accountname from ld_account where accountid=?", array($accountid));
	$accountname = $adb->query_result($result, 0, 'accountname');
    $smarty->assign("ACCOUNTID", $accountid);
    $smarty->assign("ACCOUNTNAME", $accountname);
}
if(!empty($_REQUEST['account_id']) && !empty($_REQUEST['jiuweiid'])){
	$accountid = $_REQUEST['account_id'];
	//editor:gyq_20190513 0037052 reason:去除where中的and ld_contactdetails.reference = 1  2019/5/13 17:56
    //0037052: （http://120.92.173.99/kgc/ [^]）最新版本对接汉天，老客户弹屏出来后，创建工单（跟进记录），客户没有自动关联上工单。
    $result = $adb->pquery("select ld_account.accountid,accountname,contactid from ld_account
	LEFT JOIN ld_contactdetails on ld_contactdetails.accountid = ld_account.accountid 
	where ld_account.accountid=? ", array($accountid));
	$accountname = $adb->query_result($result, 0, 'accountname');
    $smarty->assign("ACCOUNTID", $accountid);
	$smarty->assign("CONTACTID", $adb->query_result($result, 0, 'contactid'));
    $smarty->assign("ACCOUNTNAME", $accountname);
}


//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
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
    
      global $adb;
    //不存在
    
     $callbutlerGetSql = "select id,description from ld_callbutler where soundrecordingfile like '%$two_callfilename%' ";    
    //file_put_contents(globalStatic::$root_directory.'modules/ContactRecords/aa.txt',$callbutlerGetSql);
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult)>0)
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
        $callDescription = $adb->query_result($callbutlerGetResult,0,'description');
       
       
        $sqlUpdate = "update ld_callbutler set description = ?,userid=? where id = ? ";
        $updateResult=$adb->pquery($sqlUpdate,array(0,$callButlerRemarks,$current_user->id,$callButlerID));
        
        
    }
    else
    {
         $sqlInsert = "insert into ld_callbutler 
            (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
             accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
            values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ";
           
            if($_REQUEST['calltype']==1)
            {
                $calltype='外拨';
            }
            else
            {
                $calltype='来电';
            } 
            
             $insertresult=$adb->pquery($sqlInsert,array($calltype,$callphone,'接通',null,null,'',$one_filenames,$current_user->id,
            0,0,0,0,0,0,0,$callButlerRemarks)); 
    }
}
//elseif(isset($_REQUEST['calltalkid']) && $_REQUEST['calltalkid'] != '')
//{
//    $smarty->assign('calltalkid',$_REQUEST['calltalkid']);
//}
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
 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
 
 
if($_REQUEST['callfilename111']||$_REQUEST['callphon11111e'])
{
    ///保存判断
    $smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

    $smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
    $smarty->display("DetailView/EditRelated.tpl");
    
}
else
{
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
    {
        $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
    }

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
  
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
	$arr["validatasaverule"]=getAllRule($currentModule);
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['isadmin']=$current_user->is_admin;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistcontent']=$global_pick_list_values;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
    //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
    crm_load_class_file('cls_fieldSensitiverule','include/fields');
    $fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
    $arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段
    //duan 20240923 在编辑页面结尾对返回值增加统一操作
    crm_load_class_file('CommonEditViewReturn','modules/lingdang');
    $CommonEditViewReturnObj = new CommonEditViewReturn();
    $arr = $CommonEditViewReturnObj->setReturnArr($arr);

    ConvertTojsonString(1,$arr,"success");
}

?>