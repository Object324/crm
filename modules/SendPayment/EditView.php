<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;

/**
 * @edit:chj
 * @date:2014-9-12
 * @reason: 采购订单创建付款计划 
 * @description:0011283：采购订单查看明细界面，点击更多->【创建付款计划】按钮，程序没有判断该采购订单的【付款计划】是否已经等于 采购订单的金额。
 */
if(isset($_REQUEST['purchaseorder_id']) && isset($_REQUEST['iscreatesendpayment']) && $_REQUEST['iscreatesendpayment'] == true)
{
    $deployarray=getSys_deploy(20); //在采购订单模块创建付款计划时是否控制付款计划总额必须等于订单
    $sql = "select total,sum(amount) as amount from ld_purchaseorder
            left join ld_sendpayment on ld_purchaseorder.purchaseorderid = ld_sendpayment.Purchaseorder_id 
            where purchaseorderid = ?";
    $query = $adb->pquery($sql,array($_REQUEST['purchaseorder_id']));
    if($adb->query_result($query,0,'total') > $adb->query_result($query,0,'amount') || $deployarray['deploy_value'] == 0)
    {
        echo '###SUCCESS###1';exit;
    }
    else
    {
        echo '###SUCCESS###2';exit;
    }
    
}
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);


if(isset($_REQUEST['record'])&&$_REQUEST['record']!='')
{ 
   
    $record=$_REQUEST['record'];
    if($isduplicate== 'true') {
    
    }
    else{
        $record=$_REQUEST['record'];
        $sql="select cpstatus from ld_sendpayment where sendpaymentid=$record";
        $result=$adb->pquery($sql,array());
       
        $cppaymentstatus=$adb->query_result($result,0,0);
        $strStatus = getFixedLabel('thecurrentdocumenthasbeenpaid');	//"当前单据已付款，不允许编辑！";
        if($cppaymentstatus=="部分已付")
        {
            $strStatus=	getFixedLabel('thecurrenrpartofthebillhasbeenpaid');//"当前单据部分已付款，不允许编辑";
        }
        if($cppaymentstatus=="已付" ||$cppaymentstatus=="部分已付")
        {
             $_REQUEST['diony']='diony';
            ConvertTojsonString("-1",array(),$strStatus);
            /*echo "<div id='warningTable' class='warningTable'>";
            echo "<div class='warningTableContent'>
                    <div class='wtc_img'><img src='themes/images/icon-prohibit.png'></div>
                    <div class='wtc_title'>".getFixedLabel('REMINDER')."</div>
                    <div class='wtc_content'>".$strStatus."</div>
                    <div class='wtc_btn'><input value=".getFixedLabel('RETURN')." title=".getFixedLabel('RETURN')." class='createauto' onclick='javascript:window.history.back();' type='button'></div>
                        </div>";
            echo "</div>";
            echo "<script type='text/javascript' language='JavaScript'>
                    var a = ld('.Header').outerHeight(),//头部高度
                        c_height = 0,
                        s_height = ld(window).height();
                    if(a==null) a=0;
                    c_height = s_height-a;
                    ld('#warningTable').css('height',c_height);
                    ld('.warningTableContent').css('margin-top',-a/2);
                  </script>";
            exit();*/
         }
         }
}
    
require_once 'modules/lingdang/EditView.php';
$qcreate_array=$focus->fieldobj->QuickCreate();
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

$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';

//zkt 20221025 BUG0057797收/付款计划，编辑界面，右上角没有显示页面设置操作按钮
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);

if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
$arr['approve_arr']=$approve_arr;
$arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
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
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate($currentModule);
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段

//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");

?>