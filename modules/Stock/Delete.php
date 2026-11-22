<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header$
 * Description:  Deletes an Account record and then redirects the browser to the 
 * defined return URL.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;


require_once ('include/Stock/CommonStock.php');
//$log = LoggerManager::getLogger('stock_delete');
/**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select stock_id,approvestatus from ld_stock where stock_id in($record) and deleted=0";

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
    else
    {
         if($adb->query_result($dresult,0,'approvestatus')==D_A_S_APPROVED)
         {
             $hurl = 'index.php?module='.vtlib_purify($_REQUEST['return_module']).'&action='.vtlib_purify($_REQUEST['return_action']).'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;
             echo "<script>
                 alert('该记录已审核，不可删除！');
                top.location='$hurl';
                </script>"; 
                //header("Location: index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&parenttab=".$parenttab."&relmodule=".vtlib_purify($_REQUEST['module']).$url);
                exit();
                $srt = "该记录已审核，不可删除！";
             $entity['log']['value'] = $srt;
             $entity['title']['value'] = getFixedLabel('DELETE');//当前页数
             $json = new Zend_Json();
             $jsonentity = $json->encode($entity);
    	     echo $jsonentity;die;
         }
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
//Added to fix 4600
$url = getBasic_Advance_SearchURL();
$focus->id=$_REQUEST['record'];
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
$deployarray=getSys_deploy(48);


if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    //require_once('modules/Approve/Approve.php');
	//$approve=new Approve();
	$approve = Approve::getInstance($currentModule);
	$focus->id=$_REQUEST['record'];
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    echo $approve->deleteBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}
/**
* edit:chj
* date:2014-7-28
* reason:灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
**/
$query = 'select ld_stockdetail.entitytype,quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,ld_stock.wareid,lineitem_id ,batchtext
from ld_stockdetail 
left join ld_stock on ld_stock.stock_id = ld_stockdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));
$num_rows = $adb->num_rows($result);
crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');

$arr = DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id'],"yes");

$exist_entitytypeids = [];
for($i = 0; $i<$num_rows; $i++){
	$productid = $adb->query_result($result,$i,'productid');
	$qty = $adb->query_result($result,$i,'quantity');
    $entitype=$adb->query_result($result,$i,'entitytype');
	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
	$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
	$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
	$wareid = $adb->query_result($result,$i,'wareid');
    $batchtext=$adb->query_result($result,$i,'batchtext');
	//更新采购订单的入库状态、未入库和入出库数量
    if($entitytypeid>0&&!in_array($entitytypeid,$exist_entitytypeids))
        cls_Source_InverseCompute::Source_InveverseCompute($entitype,$entitytypeid);
    $exist_entitytypeids[]=$entitytypeid;
	if($deployarray['deploy_value']== 1){
		insertCondtion($batchtext, $_REQUEST['record'],'删除入库单',$focus->column_fields['wareid'],$productid,$currentModule,$focus->column_fields['assigned_user_id'],0,$qty,$parent_lineitem_id,$lineitem_id);   
	}
}
ConvertTojsonString('1',$arr,'');
echo "##YES##";
?>