<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $currentModule;
global $adb;
$focus = CRMEntity::getInstance($currentModule);

$record = vtlib_purify($_REQUEST['record']);
$module = vtlib_purify($_REQUEST['module']);
$return_module = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$return_id = vtlib_purify($_REQUEST['return_id']);
//$parenttab = getParentTab();
//Added to fix 4600
$url = getBasic_Advance_SearchURL();
//echo $return_module;
/**
 * edit:kevin
 * date:2013-07-23
 * reason:删除单据时,更新公海客户
 * updatePotentialInfo
 */
/*
$account=new Accounts();               
$account->updateAccountInfo($module,'',2,$record);*/

    /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select contactrecordID from ld_contactrecords where contactrecordID in($record) and deleted=0";

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
//审批流程begin
//判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
   
	$approve = Approve::getInstance($currentModule);
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}
/*
 * editor : gyq_02
 * explian : 删除前给当前对象赋值
 * date   : 2016  1  22
 * */
if(!empty($record))
    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);

//审批流程end
$arr = DeleteEntity($currentModule, $return_module, $focus, $record, $return_id,"yes");

/*
 * editor : gyq_02
 * reason : 新增，删除联系记录更新对应客户最新进度和最新联系日期，销售机会最新联系日期
 * date   : 2016  1  22
 * */

if($focus->column_fields['account_id']>0)
{
    $focus->updateRelatedTableInfo('ld_account',array($focus->column_fields['account_id']));

}
if($focus->column_fields['potential_id']>0){

    $focus->updateRelatedTableInfo('ld_potential',array($focus->column_fields['potential_id']));
}

if($focus->column_fields['leads_id']>0){

    $focus->updateRelatedTableInfo('ld_leads',array($focus->column_fields['leads_id']));
}
ConvertTojsonString('1',$arr,'');
echo "##YES##";
exit();

?>