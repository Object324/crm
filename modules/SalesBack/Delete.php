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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Accounts/Delete.php,v 1.5 2005/03/10 09:28:34 shaw Exp $
 * Description:  Deletes an Account record and then redirects the browser to the 
 * defined return URL.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

global $mod_strings;

require_once('include/logging.php');
$log = LoggerManager::getLogger('SalesBack');

//Added to fix 4600
$url = getBasic_Advance_SearchURL();
if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);
        /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
   $record = $_REQUEST['record'];
     $checkdeletesql="select salesbackid from ld_salesback where  salesbackid in($record) and deleted=0";
//echo $checkdeletesql;die();
    $dresult=$adb->query($checkdeletesql);
    $dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
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
    
$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,
            entitytypeid ,ld_salesbackdetail.entitytype,lineitem_id
                    from ld_salesbackdetail 
                    left join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id where id = ? ';
$result = $adb->pquery($query,array($_REQUEST['record']));
$num_rows = $adb->num_rows($result);
$arr = DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id'],"yes");
//反写合同订单已入库和未入库数量
crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
cls_Source_InverseCompute::Source_InveverseCompute("SalesBack",$record); //BUG0069176 xxy 2023-7-13 退货单删除后，销售订单已退货数量统计数量包含已删除单据,需要在删除后再反写一遍
for($i=0;$i<$num_rows;$i++)
{
    	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
	$productid = $adb->query_result($result,$i,'productid');
	$qty = $adb->query_result($result,$i,'quantity');
	$entitytype = $adb->query_result($result,$i,'entitytype');
	$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
	$lineitem_id = $adb->query_result($result,$i,'lineitem_id');

    	if($entitytypeid > 0){
	  
	       cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
        }
}
ConvertTojsonString('1',$arr,'');
echo '##YES##';

?>