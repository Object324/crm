<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
error_reporting(E_ALL^E_NOTICE^E_WARNING);
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('RecycleBinUtils.php');
require_once('modules/Accounts/Accounts.php');

//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$correct = 0;
$error = 0;
$idlist=vtlib_purify($_REQUEST['idlist']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
$selected_module = vtlib_purify($_REQUEST['selectmodule']);
$idlists = getSelectedRecordIds($_REQUEST,$selected_module,$idlist,$excludedRecords);
require_once('data/CRMEntity.php');
$focus = CRMEntity::getInstance($selected_module);
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
$batchtype = getFixedLabel('REDUCTION');
$batreachmax_restore = getFixedLabel('ALLOCATERREACHMAXCUSTOMERRestore');//单据【分配测试11】还原失败！原因：单据负责人【张三】公海已分配客户数量已达上限！
$entityarray = getEntitynameInfo(getTabid($selected_module));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
foreach($idlists as $key => $id){
    if(!empty($id)){
        $idArr[] = $id;
    }
}
$query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.implode(',',$idArr).')';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
    $crmid = $adb->query_result($result,$i,$tabindex);
    $subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
}
for($i=0;$i<count($idlists);$i++)
{
    if($btach_num <= $i)break;
    if(empty($idlists[$i]))continue;
    if(!empty($idlists[$i]) && $selected_module == 'Accounts') {
        /**
         * edit:kevin
         * date:2013-04-24
         * reason:还原单据时,更新公海客户信息
         */
        $account=new Accounts();
        $account->updateAccountInfo($selected_module,'',3,$idlists[$i]);
        if(empty($mod_name)){
            $mod_name=$selected_module;
        }

        //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = cls_PublicAccounts::getInstance($selected_module);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        $focus->retrieve_entity_info($idlists[$i], $selected_module);
        $publicaccount = $focus->column_fields['publicaccount'];

        if ($public_account['status'] == 'yes' && $publicaccount > 1) {//公海已分配
            $pool_id = $focus->column_fields['pool_id'];
            $limit_count = $focus->getPublicAccountLimitCount($focus->column_fields['assigned_user_id'],$pool_id);
            if($limit_count<9999999999)
            {
                $haved_count = $focus->getSmowerNumForPublicAccount($focus->column_fields['assigned_user_id'],$pool_id);
                $batreachmax_common = getFixedLabel('ALLOCATERREACHMAXPUBLICCUSTOMERError');//单据【分配测试11】还原失败！原因：单据负责人【张三】公海已分配客户数量已达上限！
                if ($limit_count <= $haved_count) {
                    $edit_err .= sprintf($batreachmax_common,'<a referencemodule="'.$selected_module.'" referencerecord="'.$idlists[$i].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$idlists[$i]]['subject'].'</a>',$batchtype,getUserFullName($focus->column_fields['assigned_user_id'])).'<br>';
                    $error++;
                    continue;
                }
            }
        }
        elseif ($publicaccount == 0) {//普通客户还原时，判断是否超出上限
            $batreachmax_common = $public_account['status'] == 'yes'?getFixedLabel('ALLOCATERREACHMAXCUSTOMERError1'):getFixedLabel('ALLOCATERREACHMAXCUSTOMERError');//单据【分配测试11】还原失败！原因：单据负责人【张三】普通客户数量已达上限！
            $limit_count = $focus->getCommonAccountLimitCount($focus->column_fields['assigned_user_id']);
            if($limit_count<9999999999)
            {
                $haved_count = $focus->getSmowerNumForCommonAccount($focus->column_fields['assigned_user_id']);
                if ($limit_count <= $haved_count) {
                    $edit_err .= sprintf($batreachmax_common,'<a referencemodule="'.$selected_module.'" referencerecord="'.$idlists[$i].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$idlists[$i]]['subject'].'</a>',$batchtype,getUserFullName($focus->column_fields['assigned_user_id'])).'<br>';
                    $error++;
                    continue;
                }
            }
        }

    }
    elseif(!empty($idlists[$i]) && $selected_module == 'Leads') {
        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicAccounts = new cls_PublicLeads($selected_module);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        $focus->retrieve_entity_info($idlists[$i], $selected_module);
        $publicaccount = $focus->column_fields['publicaccount'];

        if ($public_account['status'] == 'yes' && $publicaccount > 1) {//公海已分配
            $pool_id = $focus->column_fields['pool_id'];
            $limit_count = $focus->getPublicAccountLimitCount($focus->column_fields['assigned_user_id'],$pool_id);
            if($limit_count<9999999999)
            {
                $haved_count = $focus->getSmowerNumForPublicAccount($focus->column_fields['assigned_user_id'],$pool_id);
                $batreachmax_common = getFixedLabel('ALLOCATERREACHMAXPUBLICLeadsError');
                if ($limit_count <= $haved_count) {
                    $edit_err .= sprintf($batreachmax_common,'<a referencemodule="'.$selected_module.'" referencerecord="'.$idlists[$i].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$idlists[$i]]['subject'].'</a>',$batchtype,getUserFullName($focus->column_fields['assigned_user_id'])).'<br>';
                    $error++;
                    continue;
                }
            }
        }
        elseif ($publicaccount == 0) {//普通
            $batreachmax_common = $public_account['status'] == 'yes'?getFixedLabel('ALLOCATERREACHMAXLeadsError1'):getFixedLabel('ALLOCATERREACHMAXLeadsError');
            $limit_count = $focus->getCommonAccountLimitCount($focus->column_fields['assigned_user_id']);
            if($limit_count<9999999999)
            {
                $haved_count = $focus->getSmowerNumForCommonAccount($focus->column_fields['assigned_user_id']);
                if ($limit_count <= $haved_count) {
                    $edit_err .= sprintf($batreachmax_common,'<a referencemodule="'.$selected_module.'" referencerecord="'.$idlists[$i].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$idlists[$i]]['subject'].'</a>',$batchtype,getUserFullName($focus->column_fields['assigned_user_id'])).'<br>';
                    $error++;
                    continue;
                }
            }
        }
    }
    if($selected_module=='CashBack'){
        /*$cashback_query = "select * from ld_cashback where cashbackid =?";
        $cashback_result = $adb->pquery($cashback_query, array($idlists[$i]));
        $result_total = $adb->query_result($cashback_result,0,'total');
        $bankaccountsetid = $adb->query_result($cashback_result,0,'bankaccountsetid');
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$result_total WHERE bankaccountsetid=$bankaccountsetid";
        $adb->pquery($usql,array());*/
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(回收站还原反算已退款)
        $focus->inverseAmount($idlists[$i]);
        $focus->minusBankMoney($idlists[$i]);
    }
    elseif($selected_module=='PurchaseCashBack'){
        $focus->inverseAmount($idlists[$i]);
        $focus->addBankMoney($idlists[$i]);
    }
    elseif($selected_module=='ProjectTask'){
        $SQL = "SELECT trade FROM ld_version;";
        $result = $adb->pquery($SQL, array());
        $trade = $adb->query_result($result, 0, 'trade');
        if($trade=='qiaiju'){
            $SQL = "SELECT totalcost,projectid FROM ld_projecttask WHERE projecttaskid=?";
            $result=$adb->pquery($SQL,array($idlists[$i]));
            $totalcost = $adb->query_result($result, 0, 'totalcost');
            $projectid = $adb->query_result($result, 0, 'projectid');
            $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost+$totalcost WHERE projectid=$projectid;";
            $adb->pquery($SQL,array());
        }
    }
    elseif($selected_module == 'HelpDesk'){
        $query = 'select servicecontractsid from ld_troubletickets where ticketid = ?';
        $result = $adb->pquery($query,array($idlists[$i]));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $servicecontractsid = $adb->query_result($result,0,0);
            if($servicecontractsid > 0){
                $adb->pquery('update ld_servicecontracts set service_units=service_units+1 where servicecontractsid=?',array($servicecontractsid));
            }
        }
    }
    $focus->restore($selected_module, $idlists[$i]);

    $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$selected_module.'" referencerecord="'.$idlists[$i].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$idlists[$i]]['subject'].'</a>',$batchtype).'<br>';
    $correct++;
}
if($error == 0){
    $error = count($idArr) - $correct;
}
/**
 * 金融行业合同订单删除生成产品交易历史记录
 * ------------------------begin-----------------------------
 **/
$record = array_filter($idlists);//去除数组当中的空元素。
$trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
$tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。
if(!empty($tradename)&&file_exists('include/trade/'.$tradename.'/'.$tradename."_$selected_module.php"))
{
    require_once('include/trade/'.$tradename.'/'.$tradename.'_SalesOrder.php');
    $trade_class_name=$tradename.'_SalesOrder';
    if(class_exists($trade_class_name))
    {
        $trade_focus=new $trade_class_name($focus);
        if(method_exists($trade_focus,"restore"))
            $trade_focus->restore($record);//金融行业（或者基金行业）时，回收站还原合同订单单据时。
    }
}
/**
 * --------------------end----------------------------------
 **/

$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
$submitlog = sprintf($submitlog,count($idArr),$correct,$error);
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
$submitlog = '<div id="pop_remind_content" class="pop_remind_content"><div class="qui_dialog_body " style="background-color: #fff;max-height: 400px;overflow-y: auto;"><div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog."</div></div>".$edit_err."</div></div>";

$entity['log']['value'] = $submitlog;//批量处理信息
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$entity['title']['value'] = getFixedLabel('REDUCTION');// 还原
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
$parenttab = getParentTab();

header("Location: index.php?module=RecycleBin&action=RecycleBinAjax&file=index&parenttab=$parenttab&mode=ajax&selected_module=$selected_module");
?>