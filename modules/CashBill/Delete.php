<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Accounts/Accounts.php');

global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;

require_once('include/logging.php');
$log = LoggerManager::getLogger('cashBill');
    /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select cashbillid from ld_cashbill where cashbillid in($record) and deleted=0";

    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
        $hurl = 'index.php?module='.vtlib_purify($_REQUEST['return_module']).'&action='.vtlib_purify($_REQUEST['return_action']).'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;

        $srt = getFixedLabel('Thisrecordisdeleted');
         $entity['log']['value'] = $srt;
         $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
         $json = new Zend_Json();
         $jsonentity = $json->encode($entity);
	     echo $jsonentity;die;
    }

//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
$deploy_values=getSys_deploy("69");
if($deploy_values['deploy_value']==1&&Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    $entity['log']['value'] = $srt1;
    $entity['title']['value'] = getFixedLabel('DELETE');
    $json = new Zend_Json();
    $jsonentity = $json->encode($entity);
    echo $jsonentity;die;
}
//更新合同订单的最新收款日期
//在触发器中修改了
//$focus->UpdateSalesOrderCashBilldate($record,'del');
//Added to fix 4600
$url = getBasic_Advance_SearchURL();
if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);
/**
 * edit:kevin
 * date:2013-07-23
 * reason:删除单据时,更新公海客户
 */     
$account=new Accounts();               
$account->updateAccountInfo($_REQUEST['module'],'',2,$_REQUEST['record']);
DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);

echo '##YES##';
exit();
$parenttab = getParentTab();
if($_REQUEST['resetRelated'] !='ajax')
{
    header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
}
?>