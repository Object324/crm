<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

$deployarray=getSys_deploy(1);
$deployvalue = $deployarray['deploy_value'];//在合同订单模块创建回款计划时是否控制回款计划总额必须等于订单金额。1:是，0:否
if($_REQUEST['fromid']>0&&$_REQUEST['frommodule']=="SalesOrder"&&$deployvalue==1)
{
    
    //038260: （51mis.com/kfbcrm）合同订单模块>选择单据编号为【SO77】合同订单明细界面>相关>点击回款计划：点击截图红框中的新增按钮，没有弹出提示【该订单已创建回款计划】
    $sqlsalesorder='SELECT ld_salesorder.approvestatus, ld_account.accountname,salesorder_no,total,subtotal,ld_account.accountid,
                        ld_salesorder.currency_id,ld_salesorder.conversion_rate,ld_salesorder.smownerid
                from ld_salesorder left join ld_account on ld_salesorder.accountid=ld_account.accountid where ld_salesorder.salesorderid = ?';
                    
    $saleorderresult=$adb->pquery($sqlsalesorder,array($_REQUEST['fromid']));
    $currency_id=$adb->query_result($saleorderresult,0,"currency_id");
    $conversion_rate=$adb->query_result($saleorderresult,0,"conversion_rate");
    $total=$adb->query_result($saleorderresult,0,"total");
    $sql="select ifnull(amount,0),salesorderid,periodtime,currency_id,conversion_rate from ld_paymentplan 
    where ld_paymentplan.deleted=0 and entitytypeid= ".$_REQUEST['fromid'].' order by paymentplanid asc ';
    //echo $sql;
    $paymentresult=$adb->pquery($sql,array());
    if($adb->num_rows($paymentresult)>0)//如果有回款计划
    {
       //echo "have";
        for($i=0;$i<$adb->num_rows($paymentresult);$i++)
        {
            $amount = $adb->query_result($paymentresult,$i,0);//获取回款计划的金额
            $is_currency_id = $adb->query_result($paymentresult,$i,'currency_id');//获取回款计划的币种
            $is_conversion_rate = $adb->query_result($paymentresult,$i,'conversion_rate');//获取回款计划的汇率
            //判断回款计划的币种是否等于回款计划的币种
            if($currency_id != $is_currency_id)
            {
                if($currency_id == 1){
    				
                    $amount = $amount*(1/$is_conversion_rate);
                }else
                    $amount = $amount*$is_conversion_rate/$conversion_rate;
            }
            $paymentamount+=$amount;
           //获取该合同订单最大期次
            //（因为查询排序时按照期次升序排序)
            $periodtime=$adb->query_result($paymentresult,$i,2);
        }
        $nopaymentamount=0.00;
        $nopaymentamount=floatval ($total)-floatval($paymentamount);
      
        if($nopaymentamount < 0)
        {
            $nopaymentamount = 0;
        }    
 
        if($nopaymentamount<=0)
            {
                $_REQUEST['diony']='yes';
                ConvertTojsonString("-1",array(),getFixedLabel('ORDERCREATED'));
                
                
            }   
        

    }
}
require_once globalStatic::$root_directory.'modules/lingdang/EditView.php';
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

if(empty($qcreate_array)){
    $qcreate_array = [];
}
if(empty($qcreate_array['form']) || !is_array($qcreate_array['form'])){
    $qcreate_array['form'] = [];
}
$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
    /*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
                $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
            if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
                $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}

$_REQUEST['diony']='diony';

//zkt 20221025 BUG0057797收/付款计划，编辑界面，右上角没有显示页面设置操作按钮
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);

$arr['picklistcontent']=$global_pick_list_values;
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
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
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//$arr['columnfields_value']=$focus->column_fields;
$arr['isduplicate'] = getTabDuplicate($currentModule);
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>