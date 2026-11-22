<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');

class cls_Products_SaveWX extends cls_SaveWX{
    //对冲提醒
    public function before_save(){
        //@edit:zkt @date:2024/12/20 @reason: XUQIU20240821-02   --- 系统参数，设置计算预收单金额时是否统计未审批通过的预收单
        $allowsave_arr = $this->focus->IsAllowSaveBeforeSave();
        if($allowsave_arr['allowsave'] == 'no'){
            $msg = $this->focus->getsaveerrormsg();
            ConvertTojsonString("-1",array(),$msg);
        }
        parent::before_save();
    }
}
foreach($_REQUEST['wx_productFieldInfo'] as $key=>$val){
    $_REQUEST[$key] = $val;
}

$mobj = new cls_Products_SaveWX('CashBill');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
    $_REQUEST['deleterow'.$i] = $_REQUEST['hidden_rowid_'.$i];
    //unset($_REQUEST['hidden_rowid_'.$i]);
}
//41217: （61mis.com/kfbtest）手机端>企业微信>灵当CRM>收款单模块>新建单据界面：“选择源单”合同订单，带出分录信息，录入“本次收款金额”“1000”，点击保存，查看单据明细界面“实际收款金额”显示为“0”（微信小程序也有此问题）
if(!isset($_REQUEST['currency_id']) || empty($_REQUEST['currency_id'])){
    $_REQUEST['currency_id'] = 1;
}
$_REQUEST['subtotal']=$_REQUEST['p_total']['total']['value']; 
$_REQUEST['selectsource'] = getSalesEntityType($_REQUEST['salesorder_id']);
$translatedbvalue_arr=  getTranslateDbValueNew($currentModule,'cashtype');
//$translatedbvalue_arr=$translatedbvalue_arr[$currentModule]['cashtype'];
foreach($translatedbvalue_arr as $column_dbvalue=>$tmp_arr)
{
    $db_label = $tmp_arr['labelbol'];
     if(getFixedLabel($db_label)==$_REQUEST['cashtype'])
     {
        $_REQUEST['cashtype']=$column_dbvalue;
        break;
     }
}
if($_REQUEST['cashtype']=='')
{
$_REQUEST['cashtype']='cashbill';

}
// dump($_REQUEST);
crm_load_class_file("cls_CheckDebuctionInfo",'modules/CashBill');
$checkobj = new cls_CheckDebuctionInfo($_REQUEST['record'],'');
$checkNegativeValues = $checkobj->checkNegativeValues($_REQUEST['cashbill_total'],$_REQUEST['save_debuctioninfo'],$_REQUEST['cashbilltype']);
if($checkNegativeValues == 'no'){
    ConvertTojsonString(-1,array(),$checkobj->errorinfo);
}

$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>

