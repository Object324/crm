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

//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $ServiceContractsPreremind,$current_user;
require_once('include/Stock/CommonStock.php');
require_once('user_privileges/user_language_'.$current_user->id.'.php');

//$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='SystemSet';
//$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$date_var = date("Y-m-d");
$smarty = new lingdangCRM_Smarty;

/** gives the role info, role profile info and role user info details in an array  for the specified role id
  * @param $roleid -- role id:: Type integer
  * @returns $return_data -- array contains role info, role profile info and role user info. This array is used to construct the detail view for the specified role id :: Type varchar
 **/
if(empty($_REQUEST['postroot'])){

    $smarty->assign('TABLE',getAllSystemInfo(1));
}
/*
if(isset($_REQUEST['setparamsforapprove']) && $_REQUEST['setparamsforapprove'] == 1){//隐藏审批参数设置
    $smarty->assign('TABLE',getAllSystemInfo(3));
}*/

$smarty->assign('MAX_DEPLOYTYPE',getMaxSystemDeploy());
$smarty->assign('ALLSYSTEMROOT',getAllSystemRoot());

$smarty->assign('ALLSYSTEMROOTCOUNT',getAllSystemCount());
function getAllSystemInfo($theroot){
    $fourroot = '';

    for($i=1;$i<=8;$i++){
        if($theroot == $i){
            $dis = "";
        }elseif($i==3){//隐藏审批参数设置
            continue;
        }else{
            $dis = 'style="display:none;"';
        }
		$systemrootinfo = getSystemRootInfo($i);

		if($systemrootinfo!=''){
			$fourroot .= '<div class="rootinfo" '.$dis.'>';
			$fourroot .= getSystemTable($systemrootinfo);
			$fourroot .= '</div>';
		}
    }
    $fourroot .= '<input type="hidden" value="'.$theroot.'" name="postroot" >';
    return $fourroot;
}

function getAllSystemRoot(){
	global $adb;
	$query = 'select roottype from ld_systems_deploy where presence = 0 and roottype >= 1 GROUP BY  roottype ORDER BY roottype';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$data[] = $adb->query_result($result,$i,0);
		}
	}
	return $data;
}
//获取最大的deploy_type值
function getAllSystemCount(){
	global $adb;
	$query = 'select max(deploy_type) as a from ld_systems_deploy ';
	$result = $adb->pquery($query,array());
	return $adb->query_result($result,0,0);;
}
//处理表单提交的数据(保存数据)
if($_REQUEST['post'] == 'yes'){
	set_time_limit(0);
	$changebankaccountbol='no';//更改银行账户剩余金额
	//获取所有的审批模块
	$query = "select ld_systems_deploy.id,ld_systems_deploy.setype from ld_systems_deploy 
	LEFT JOIN ld_tab on ld_tab.`name` = ld_systems_deploy.setype
	where roottype = 3 and setype is not NULL and setype != ''";
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	$approve_module = [];	//所有的审批模块
	$system_approvemodule_id = [];
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
			$approve_module[$id] = $adb->query_result($result,$i,'setype');
			$system_approvemodule_id[] = $id;
		}
	}
	
     //已收金额计算时是否统计未审核的收款单
      //已付金额计算时是否统计未审核的付款单
     $sql='select * from ld_systems_deploy where (deploy_type=83 and deploy_value=?) or (deploy_type=84 and deploy_value=?)';
     $tmpresult=$adb->pquery($sql,array($_REQUEST['83'],$_REQUEST['84']));
     if($adb->num_rows($tmpresult)<2)
     {
                //表示参数改变
            $changebankaccountbol='yes';
     }

    $pre_deploy_value_205 = getSys_deploy(205);
    $pre_deploy_value_205 = $pre_deploy_value_205['deploy_value'];

    foreach($_REQUEST as $key=>$val){
      
		if(!is_numeric($key)){
			continue;
		}

        if($key == 18){//合同订单交付日期前Ｎ天提醒负责人（为0表示当天提醒，为空表示不提醒
			$deployarray = getSys_deploy(18);
            $old_deploy_value = $deployarray['deploy_value'];
            if(trim($val)!=''){
                $sql="update ld_reminds set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) where reltab=? and status_rmd='未读'  and  content like '%交付日期提醒%'";
                $adb->pquery($sql,array('SalesOrder'));
                $contentvalue = getFixedLabel('DELIVERYDATEREMINDER');
                $sql="update ld_reminds set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) where reltab=? and status_rmd='未读'  and  content like '%$contentvalue%'";
                $adb->pquery($sql,array('SalesOrder'));
                
                $sql="update ld_reminds_accepted set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) where reltab=? and status_rmd='未读'  and  content like '%交付日期提醒%'";
                $adb->pquery($sql,array('SalesOrder'));
                $contentvalue = getFixedLabel('DELIVERYDATEREMINDER');
                $sql="update ld_reminds_accepted set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) where reltab=? and status_rmd='未读'  and  content like '%$contentvalue%'";
                $adb->pquery($sql,array('SalesOrder'));
            }
        }
       
        if($key==196)
        {
           //是否启用批次管理
            if($val==0)
            {
                 $sql='update ld_field set presence=0 where tabid=14 and columnname="batchmanagement" ';
                 $query='update ld_producttoolfield set presence=0 where columnname="batchtext" ';
                 
            }
            else
            {
                $sql='update ld_field set presence=1 where tabid=14 and columnname="batchmanagement" ';
                $query='update ld_producttoolfield set presence=1 where columnname="batchtext" ';
                 
            }
            $adb->pquery($sql,array());
            $adb->pquery($query,array());
             unsetCacheDirectory('productfields');
             unsetCacheDirectory('fields');
        }
        if($key == 24){//服务合同截止日期前Ｎ天提醒负责人（为0表示当天提醒，为空表示不提醒）
			$deployarray = getSys_deploy(24);
            $old_deploy_value = $deployarray['deploy_value'];
            if(trim($val)!='')
            {
                $sql="update ld_reminds set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) 
                    where reltab=? and status_rmd='未读'  and  content like '%产品服务到期提醒%'";
                $adb->pquery($sql,array('ServiceContracts'));
                
                $sql="update ld_reminds_accepted set date_time=DATE_ADD(DATE_ADD(date_time,INTERVAL $old_deploy_value DAY),INTERVAL -$val DAY) 
                    where reltab=? and status_rmd='未读'  and  content like '%产品服务到期提醒%'";
                $adb->pquery($sql,array('ServiceContracts'));
            }
        }
        if($key == 40 ||$key == 41){//回款计划提前提醒天数、付款计划提前提醒天数
            if ($val == '') {
                $sql = 'update ld_automaticreminds set status =0 where defaultnum=?';
                $adb->pquery($sql, array($key));
            } else {
                $sql = 'update ld_automaticreminds set status =1 where defaultnum=?';
                $adb->pquery($sql, array($key));
    
                $sql_cvid = 'select id from ld_automaticreminds where defaultnum=?';
                $result_cvid = $adb->pquery($sql_cvid, array($key));
                $cvid = $adb->query_result($result_cvid, 0, 'id');
				
                if ($val != 0)
                    $remindsdays = '-' . $val;
				else
					$remindsdays = $val;
                $sql = 'update ld_remindway set remindsday=? where wayid=?';
                $adb->pquery($sql, array($remindsdays, $cvid));
            }
            @unlink('dataCache/execDays/autoremind.txt');
        }
        if($key == 53){//回款计划按照项目状态收款和提醒。1：是，2：否
            if ($val == 2) {
				$adb->pquery("update ld_field set presence=1 where tabid=(select tabid from ld_tab where name='PaymentPlan') and columnname='projectstatus'");
                //$adb->pquery("update ld_systems_deploy set presence=0 where deploy_type=40");
                //$adb->pquery("update ld_automaticreminds set status=0 where defaultnum = 40");
            } else {
				$adb->pquery("update ld_field set presence=0 where tabid=(select tabid from ld_tab where name='PaymentPlan') and columnname='projectstatus'");
               // $adb->pquery("update ld_systems_deploy set presence=1 where deploy_type=40");
               // $adb->pquery("update ld_automaticreminds set status=0 where defaultnum = 40");
            }
			unsetCacheDirectory('fields');
        }
		if($key == 124){
			unsetCacheDirectory('productfields');
		}

         
        if($key == 72){//客户首要联系人显示设置 只用来排序
			$tabid = getTabid('ServiceCharge');//服务收费管理
            $adb->pquery("update ld_blocks set visible = '" . $val . "' where tabid in(6,$tabid) and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' ");
        }
       // if($key == 73){//设置登录时是否启用验证码 只用来排序
          //  $adb->pquery("update ld_code set status = ".$val." ");            
      //  }
		if($key == 133 || $key == 134 || $key == 135 || $key == 136){	//收款单、付款单、出库单、入库单是否启用审批流程
			if($key == 133){
				$module = 'CashBill';
			}else if($key == 134){
				$module = 'SendCashBill';
			}else if($key == 135){
				$module = 'OutboundOrder';
			}else{
				$module = 'Stock';
			}
			if($val == 1){	//否
				if($key == 133 || $key == 134){
					$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 0 where columnname in ("checker","checkoutstatus") and ld_tab.`name` = ?',array($module));
				}else{
					$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 0 where columnname in ("subsmownerid") and ld_tab.`name` = ?',array($module));
				}
				$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 1 where columnname in ("approveby","approvestatus","currentapprover") and ld_tab.`name` = ?',array($module));
			}else{
				if($key == 133 || $key == 134){
					$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 1 where columnname in ("checker","checkoutstatus") and ld_tab.`name` = ?',array($module));
				}else{
					$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 1 where columnname in ("subsmownerid") and ld_tab.`name` = ?',array($module));
				}
				$adb->pquery('update ld_field LEFT JOIN ld_tab on ld_tab.tabid = ld_field.tabid set ld_field.presence = 0 where columnname in ("approveby","approvestatus","currentapprover") and ld_tab.`name` = ?',array($module));
			}
		}
		//更新系统参数值
        if($key==47)
        {
             $sql='select * from ld_systems_deploy where deploy_type=47 and deploy_value=?';
          $servicecontracts_approveresult=$adb->pquery($sql,array($_REQUEST['47']));
        }

        $deployarray_48 = getSys_deploy(48);
		$adb->pquery("update ld_systems_deploy set deploy_value = '" .$val. "' where deploy_type= $key");

        //ls 2021-12-9 0049064: （http://1.117.187.41:85/ [^] ）（客户问题）BOM清单管理》产品名称-柜门锁，总库存显示为-10，点开显示为0的(重算产品总库存数量的sql应该在系统参数保存之后执行)
        if($key == 48){	//出库单或入库单更新库存流水记录触发点 0：审核  1：保存
            if ($deployarray_48['deploy_value'] != $val) {
                $adb->pquery("DROP PROCEDURE IF EXISTS `ldcrm_resetoutinfo_bychangepara`;",array());
                $query_addproc = "
                    CREATE PROCEDURE `ldcrm_resetoutinfo_bychangepara`()
                    BEGIN
                    
                    	UPDATE ld_outboundorder SET presence='未出库' WHERE approvestatus='未提交' AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE  deploy_type=48 AND deploy_value=0);
                    	UPDATE ld_outboundorder SET approvestatus='已批准' WHERE presence='已出库' AND approvestatus='未提交' AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE  deploy_type=48 AND deploy_value=0);
                    
                    	IF EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE b.entitytype='SalesOrder' LIMIT 1) THEN
                    		-- 重算合同分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_salesorderdetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS out_qty
                    			FROM ld_outboundorder a
                    			LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.haveoutproductcount=IFNULL(b.out_qty,0),a.balanceoutproductcount=a.quantity-IFNULL(b.out_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算合同出库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_salesorder s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.salesorderid) THEN '未出库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_salesorderdetail WHERE id=s.salesorderid AND quantity>0 AND haveoutproductcount>0) THEN '生成出库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_salesorderdetail WHERE id=s.salesorderid AND quantity>0 AND balanceoutproductcount>0) THEN '全部出库'
                    				ELSE '部分出库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    	IF EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE b.entitytype='ServiceContracts' LIMIT 1) THEN
                    		-- 重算服务合同分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_servicecontractsdetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS out_qty
                    			FROM ld_outboundorder a
                    			LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.haveoutproductcount=IFNULL(b.out_qty,0),a.balanceoutproductcount=a.quantity-IFNULL(b.out_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算服务合同出库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_servicecontracts s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.servicecontractsid) THEN '未出库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_servicecontractsdetail WHERE id=s.servicecontractsid AND quantity>0 AND haveoutproductcount>0) THEN '生成出库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_servicecontractsdetail WHERE id=s.servicecontractsid AND quantity>0 AND balanceoutproductcount>0) THEN '全部出库'
                    				ELSE '部分出库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    
                    	IF EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE b.entitytype='Invoice' LIMIT 1) THEN
                    		-- 重算发票分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_invoicedetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS out_qty
                    			FROM ld_outboundorder a
                    			LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.haveoutproductcount=IFNULL(b.out_qty,0),a.balanceoutproductcount=a.quantity-IFNULL(b.out_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算发票出库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_invoice s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.invoiceid) THEN '未出库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_invoicedetail WHERE id=s.invoiceid AND quantity>0 AND haveoutproductcount>0) THEN '生成出库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_invoicedetail WHERE id=s.invoiceid AND quantity>0 AND balanceoutproductcount>0) THEN '全部出库'
                    				ELSE '部分出库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    	IF EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE b.entitytype='Stock' LIMIT 1) THEN
                    		-- 重算入库单分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_stockdetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS out_qty
                    			FROM ld_outboundorder a
                    			LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.haveoutproductcount=IFNULL(b.out_qty,0),a.balanceoutproductcount=a.quantity-IFNULL(b.out_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算入库单出库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_stock s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_outboundorder a LEFT JOIN ld_outboundorderdetail b ON b.id=a.out_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.stock_id) THEN '未出库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_stockdetail WHERE id=s.stock_id AND quantity>0 AND haveoutproductcount>0) THEN '生成出库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_stockdetail WHERE id=s.stock_id AND quantity>0 AND balanceoutproductcount>0) THEN '全部出库'
                    				ELSE '部分出库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    
                    
                    	UPDATE ld_stock SET presence='未入库' WHERE approvestatus='未提交' AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE  deploy_type=48 AND deploy_value=0);
                    	UPDATE ld_stock SET approvestatus='已批准' WHERE presence='已入库' AND approvestatus='未提交' AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE  deploy_type=48 AND deploy_value=0);
                    
                    	IF EXISTS (SELECT 1 FROM ld_stock a LEFT JOIN ld_stockdetail b ON b.id=a.stock_id WHERE b.entitytype='PurchaseOrder' LIMIT 1) THEN
                    		-- 重算采购订单分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_purchaseorderdetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS in_qty
                    			FROM ld_stock a
                    			LEFT JOIN ld_stockdetail b ON b.id=a.stock_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.havepurchasecount=IFNULL(b.in_qty,0),a.balancepurchasecount=a.quantity-IFNULL(b.in_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算采购订单入库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_purchaseorder s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_stock a LEFT JOIN ld_stockdetail b ON b.id=a.stock_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.purchaseorderid) THEN '未入库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_purchaseorderdetail WHERE id=s.purchaseorderid AND quantity>0 AND haveoutproductcount>0) THEN '生成入库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_purchaseorderdetail WHERE id=s.purchaseorderid AND quantity>0 AND balanceoutproductcount>0) THEN '全部入库'
                    				ELSE '部分入库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    	IF EXISTS (SELECT 1 FROM ld_stock a LEFT JOIN ld_stockdetail b ON b.id=a.stock_id WHERE b.entitytype='PurchaseInvoice' LIMIT 1) THEN
                    		-- 重算采购发票分录已出库数量
                    		SET @disable_triggers=1;
                    		UPDATE ld_purchaseinvoicedetail a
                    		LEFT JOIN (
                    			SELECT
                    				entitytypeid,
                    				parent_lineitem_id,
                    				SUM(quantity) AS in_qty
                    			FROM ld_stock a
                    			LEFT JOIN ld_stockdetail b ON b.id=a.stock_id
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND b.entitytypeid>0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=0) THEN a.approvestatus='已批准'
                    						ELSE 1=1
                    					END)
                    			GROUP BY parent_lineitem_id
                    		) b ON b.parent_lineitem_id=a.lineitem_id
                    		SET a.havepurchasecount=IFNULL(b.in_qty,0),a.balancepurchasecount=a.quantity-IFNULL(b.in_qty,0);
                    
                    		SET @disable_triggers=NULL;
                    
                    		-- 重算采购订单入库状态
                    		SET @disable_triggers=1;
                    		UPDATE ld_purchaseinvoice s
                    		SET s.stockpresence=(CASE
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_stock a LEFT JOIN ld_stockdetail b ON b.id=a.stock_id WHERE a.deleted=0 AND a.approvestatus<>'已拒绝' AND b.entitytypeid=s.purchaseorderid) THEN '未入库'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_purchaseinvoicedetail WHERE id=s.purchaseorderid AND quantity>0 AND haveoutproductcount>0) THEN '生成入库单'
                    				WHEN NOT EXISTS (SELECT 1 FROM ld_purchaseinvoicedetail WHERE id=s.purchaseorderid AND quantity>0 AND balanceoutproductcount>0) THEN '全部入库'
                    				ELSE '部分入库'
                    			END);
                    		SET @disable_triggers=NULL;
                    	END IF;
                    
                    	SET @disable_triggers=1;
                    	UPDATE ld_products p
                    	LEFT JOIN (
                    		SELECT
                    			a.wareid,
                    			a.productid,
                    			a.batchtext,
                    			SUM(a.inventory_qty) AS inventory_qty
                    		FROM (
                    			SELECT
                    				a.warehouseid AS wareid,
                    				a.productid,
                    				a.batchtext,
                    				a.lastqty AS inventory_qty
                    			FROM ld_warehousecondtions a
                    			LEFT JOIN ld_products c ON c.productid=a.productid
                    			WHERE a.modulename='库存初始化'
                    				AND a.type='确认初始库存'
                    			UNION ALL
                    			SELECT
                    				a.wareid,
                    				c.productid,
                    				c.batchtext,
                    				c.quantity
                    			FROM ld_stock a
                    			LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.approvestatus='已批准'
                    					END)
                    			UNION ALL
                    			SELECT
                    				a.wareid,
                    				c.productid,
                    				c.batchtext,
                    				c.quantity
                    			FROM ld_salesback a
                    			LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND a.salesbackstatus<>'中止'
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.approvestatus='已批准'
                    					END)
                    			UNION ALL
                    			SELECT
                    				c.wareid,
                    				c.productid,
                    				c.batchtext,
                    				0-c.quantity
                    			FROM ld_outboundorder a
                    			LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
                    			LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                    			LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND a.approvestatus<>'已拒绝'
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.approvestatus='已批准'
                    					END)
                    			UNION ALL
                    			SELECT
                    				a.wareid,
                    				c.productid,
                    				c.batchtext,
                    				0-c.quantity
                    			FROM ld_purchaseback a
                    			LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND a.purchasebackstatus<>'中止'
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.purchasebackstatus='已出库'
                    					END)
                    			UNION ALL
                    			SELECT
                    				a.inwarehouse,
                    				c.productid,
                    				c.batchtext,
                    				c.quantity
                    			FROM ld_warehousetransfer a
                    			LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.transferstatus='已审核'
                    					END)
                    			UNION ALL
                    			SELECT
                    				a.outwarehouse,
                    				c.productid,
                    				c.batchtext,
                    				0-c.quantity
                    			FROM ld_warehousetransfer a
                    			LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.transferstatus='已审核'
                    					END)
                    			UNION ALL
                    			SELECT
                    				a.wareid,
                    				c.productid,
                    				c.batchtext,
                    				c.profitloss
                    			FROM ld_checks a
                    			LEFT JOIN ld_checksdetail c ON c.id=a.id
                    			LEFT JOIN ld_products p ON p.productid=c.productid
                    			WHERE a.deleted=0
                    				AND (
                    					CASE
                    						WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
                    						ELSE a.presence='盘点结束'
                    					END)
                    		) a
                    		WHERE a.productid>0
                    		GROUP BY a.productid
                    	) a ON a.productid=p.productid
                    	SET p.qtyinstock=IFNULL(a.inventory_qty,0)
                    	WHERE p.deleted=0
                    		AND IFNULL(p.qtyinstock,0)<>IFNULL(a.inventory_qty,0);
                    
                    	SET @disable_triggers=NULL;
                        
                    end
    				";

                $adb->pquery($query_addproc,array());
                $adb->pquery("CALL ldcrm_resetoutinfo_bychangepara();",array());
                //$adb->pquery("DROP PROCEDURE IF EXISTS `ldcrm_resetoutinfo_bychangepara`;",array());

                /*	 crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
                     crm_load_class_file('cls_InPurchase_InverseCompute','include/OptionModule');
                     $sql="select * from (select ld_stockdetail.entitytype,ld_stockdetail.entitytypeid,'stock' as module from  ld_stock
                     inner join ld_stockdetail on ld_stockdetail.id=ld_stock.stock_id union
                     select  ld_outboundorderdetail.entitytype,ld_outboundorderdetail.entitytypeid,'out' as module from ld_outboundorder
                     inner join ld_outboundorderdetail on ld_outboundorderdetail.id=ld_outboundorder.out_id
                      where DELETEd=0) as tmp
                      where entitytypeid >0
                       group by entitytype,entitytypeid,module";
                     global $adb;

                     $result=$adb->pquery($sql,array());
                     $num_rows=$adb->num_rows($result);
                     for($i=0;$i<$num_rows;$i++)
                     {
                        $tmpmodule=$adb->query_result($result,$i,'module');
                        $entitytypeid=$adb->query_result($result,$i,'entitytypeid');
                        $entitytype=$adb->query_result($result,$i,'entitytype');
                        if($entitytype==''||empty($entitytypeid)){
                            continue;
                        }
                        if($entitytype=='SalesOrder'){
                            continue;
                        }
                        if($tmpmodule=='out'){
                             cls_Source_InverseCompute::updateoutboundEntityInfo($entitytypeid,$entitytype);//更新源单出库状态和已出库和未数量
                        }
                        else{
                            cls_InPurchase_InverseCompute::updateStockEntityInfo($entitytypeid,$entitytype);//更新源单入库状态和已入库和未入库数量
                        }

                     }*/
            }
        }
		//所有的审批模块
		//chj 2021/3/2 44765: Systemset.php 641 -675 行审批参数相关的功能代码优化
        if(!empty($system_approvemodule_id) && in_array($key,$system_approvemodule_id))
      {
          $tmpmodule=$approve_module[$key];
          if($val==1)
          {
            //33540: 单据关闭审批参数时，单据界面不应该显示“审批状态”、“上一步审批人”、“当前审批人”、“最新审批时间”
            $tabid=getTabid($tmpmodule);
            $sql="update ld_field set presence=1  where tabid=? and columnname in('approveby','approvestatus','currentapprover','approvetime')  ";
            $adb->pquery($sql,array($tabid));
           
            unsetCacheDirectory('fields');
          }
          //服务合同审批参数
        
          if($adb->num_rows($servicecontracts_approveresult)<=0&&$key==47){
            $sql='delete from ld_maxservicedate ';
            $adb->pquery($sql,array());
            
               clearCacheFiles();
                unsetCache('systems_deploy');
               
                getSys_deploy(47,'yes');//重新调用，清空静态变量



              //XUQIU1002017 liushuai 20231030 服务收费管理要按最终用户去显示产品服务到期日
              $focus=CRMEntity::getInstance('ServiceContracts');
              if($focus->end_accountid_enable() == "yes"){
                  $sql='select ld_servicecontracts.end_accountid as accountid from ld_servicecontracts
                      inner join ld_account on ld_account.accountid=ld_servicecontracts.end_accountid
                      where ld_servicecontracts.deleted=0 and ld_account.deleted=0  and ld_servicecontracts.end_accountid>0
                      group by ld_servicecontracts.end_accountid';
              }else{
                  $sql='select ld_servicecontracts.accountid from ld_servicecontracts
                      inner join ld_account on ld_account.accountid=ld_servicecontracts.accountid
                      where ld_servicecontracts.deleted=0 and ld_account.deleted=0  and ld_servicecontracts.accountid>0
                      group by ld_servicecontracts.accountid';
              }
              $tmp_result=$adb->pquery($sql,array());
              $num_rows=$adb->num_rows($tmp_result);

              for($tmp_i=0;$tmp_i<$num_rows;$tmp_i++){
                  $accountid=$adb->query_result($tmp_result,$tmp_i,'accountid');
                  $focus->getMaxServicDate($accountid);
              }



                
          }
          
          // 
      }
      
    }
    
    
    $sql='select * from ld_systems_deploy where deploy_type=205 ';
    
    $result=$adb->pquery($sql,array());
    chmod(globalStatic::$root_directory.'modules/Potentials',0777);
    if($adb->num_rows($result)>0)
    {
         $deploy_value=$adb->query_result($result,0,'deploy_value');
         if($deploy_value==0)
         {
            //显示明细
            chmod(globalStatic::$root_directory.'modules/Potentials',0777);
            $filehandler=fopen(globalStatic::$root_directory.'modules/Potentials/ProductDetails.php','w');
            fclose($filehandler);
            $sql='update ld_field set displaytype=3,presence=0 where tabid=2 and (columnname="amount" or columnname="currency_id") ';
            $adb->pquery($sql,array());
            $sql="update ld_field
            inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
            and ld_tranlabel.trantable='ld_field' and ld_tranlabel.tabid=ld_field.tabid
            set ld_tranlabel.fieldlabel='合计' ,ld_field.fieldlabel='合计'
            where ld_field.tabid=2 and ld_field.columnname='amount' and ld_tranlabel.languagetype='zh' ";

            $adb->pquery($sql,array());
            //显示明细
            //edit:can 2020-11-11 43175: （https://61mis.com/kfbtest [^]）系统设置-参数设置-系统参数设置-业务设置；在将“设置销售机会是否显示产品分录明细”这个参数选择为是之后；在销售机会模块的管理分类中复制数据分类，然后选择复制的数据分类，页面不能正常显示。
             if ($deploy_value != $pre_deploy_value_205) {//bug:业务参数205设置为是，不更改为否时再次保存，数据分类改变
                 $sql = 'delete from ld_tabwithproductview where cvid in( select ld_cvcolumnlist.cvid
                     from ld_cvcolumnlist
                    inner join ld_customview on ld_customview.cvid=ld_cvcolumnlist.cvid
                    where ld_customview.entitytype="Potentials"
                    group by ld_cvcolumnlist.cvid ) ';
                 $adb->pquery($sql, array());

                 //显示明细
                 $sql = 'insert into ld_tabwithproductview(tabid, `columns`,sequence,cvid) 
                    select 2,ld_cvcolumnlist.`columnname`,ld_cvcolumnlist.columnindex,ld_cvcolumnlist.cvid
                     from ld_cvcolumnlist
                    inner join ld_customview on ld_customview.cvid=ld_cvcolumnlist.cvid
                    where ld_customview.entitytype="Potentials" ';

                 $adb->pquery($sql, array());
             }

         }
         else
         {
             


           //edit:can 2020-11-11 43175: （https://61mis.com/kfbtest [^]）系统设置-参数设置-系统参数设置-业务设置；在将“设置销售机会是否显示产品分录明细”这个参数选择为是之后；在销售机会模块的管理分类中复制数据分类，然后选择复制的数据分类，页面不能正常显示。
            //不显示明细
             if ($deploy_value != $pre_deploy_value_205) {//bug:业务参数205设置为是，不更改为否时再次保存，数据分类改变
				 $sql='update ld_field set displaytype=1 ,presence=0 where tabid=2  and (columnname="amount" or columnname="currency_id") ';
				$adb->pquery($sql,array());
				$sql="update ld_field
				inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
				and ld_tranlabel.trantable='ld_field'
				set ld_tranlabel.fieldlabel='预计合同金额' ,ld_field.fieldlabel='预计合同金额'
				where ld_field.tabid=2 and ld_field.columnname='amount' and ld_tranlabel.languagetype='zh'
				";
				 $adb->pquery($sql,array());
				@unlink(globalStatic::$root_directory.'modules/Potentials/ProductDetails.php');
                 $sql = 'delete from ld_cvcolumnlist where cvid in( select ld_tabwithproductview.cvid
                     from ld_tabwithproductview
                    inner join ld_customview on ld_customview.cvid=ld_tabwithproductview.cvid
                    where ld_customview.entitytype="Potentials"
                    group by ld_tabwithproductview.cvid ) ';
                 $adb->pquery($sql, array());


                 $sql = 'insert into ld_cvcolumnlist( columnname,columnindex,cvid) select ld_tabwithproductview.`columns`,ld_tabwithproductview.sequence,ld_tabwithproductview.cvid
                     from ld_tabwithproductview
                    inner join ld_customview on ld_customview.cvid=ld_tabwithproductview.cvid
                    where ld_customview.entitytype="Potentials" ';
                 $adb->pquery($sql, array());
             }


         }
         unsetCache("fields");
         
    }
    else
    {
        @unlink(globalStatic::$root_directory.'modules/Potentials/ProductDetails.php');
    }
       clearCacheFiles();
    
    unsetCache('systems_deploy');
   $deployarray= getSys_deploy(49,'yes');//小数位数
   $lengthdecimal=$deployarray['deploy_value'];
   for($tmpi=0;$tmpi<=8;$tmpi++)
   {
     $sql='update ld_producttoolfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where bigtype="num" ';
    $adb->pquery($sql,array());
    $sql='update ld_tabdetailfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where bigtype="num" ';
    $adb->pquery($sql,array());
    
   }
   $deployarray= getSys_deploy(93,'yes');//单价小数位数
   $lengthdecimal=$deployarray['deploy_value'];
  for($tmpi=0;$tmpi<=8;$tmpi++)
   {
     $sql='update ld_producttoolfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where uitype="163" ';
    $adb->pquery($sql,array());
    $sql='update ld_tabdetailfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where fieldtype="price" ';
    $adb->pquery($sql,array());
    
   }
   //zkt 20221207 BUG0059669 此处应该不读缓存
   $deployarray= getSys_deploy(351,'yes');//设置单据分录明细金额字段和单据头货币字段小数位数
   $lengthdecimal=$deployarray['deploy_value'];
  for($tmpi=0;$tmpi<=8;$tmpi++)
   {
     $sql='update ld_producttoolfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where uitype>=25 and uitype<=50 ';
    $adb->pquery($sql,array());
    $sql='update ld_tabdetailfield set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where fieldtype="Amount" or fieldtype="RMB_Amount" or fieldtype="SourceAmount" ';
    $adb->pquery($sql,array());
    $sql='update ld_field set typeofdata=replace(typeofdata,",'.$tmpi.'",",'.$lengthdecimal.'")   where bigtype="currency" and (uitype = 71 or uitype=72) and columnname!="unit_price" and columnname!="costprice"';
    $adb->pquery($sql,array());
   }
   unsetCacheDirectory('tabdetailfields');
   unsetCacheDirectory('productfields');
   unsetCacheDirectory('fields');
   
    //返回到提交的页签
    $smarty->assign('TABLE',getAllSystemInfo($_REQUEST['postroot']));
    if($changebankaccountbol=='yes')
    {
		$adb->pquery("SET @disable_triggers=1",array());
        $sql="UPDATE ld_bankaccountset a
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.Total) AS Total
                        	FROM ld_cashbill a
                        	WHERE a.deleted=0
                        		AND a.approvestatus<>'已拒绝'
                        		AND (
                        			CASE
                        				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=83 AND deploy_value=0) THEN 1=1
                        				ELSE a.approvestatus='已批准'
                        			END)
                        	GROUP BY a.bankaccountsetid
                        ) s1 ON a.Bankaccountsetid=s1.bankaccountsetid
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.Total) AS Total
                        	FROM ld_sendcashbill a
                        	WHERE a.deleted=0
                        		AND a.approvestatus<>'已拒绝'
                        		AND (
                        			CASE
                        				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=84 AND deploy_value=0) THEN 1=1
                        				ELSE a.approvestatus='已批准'
                        			END)
                        	GROUP BY a.bankaccountsetid
                        ) z1 ON a.Bankaccountsetid=z1.bankaccountsetid
                        LEFT JOIN (
                        	SELECT
                        		a.inaccount,
                        		SUM(a.cashmoney) AS total
                        	FROM ld_cashdeposit a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.inaccount
                        ) s2 ON a.Bankaccountsetid=s2.inaccount
                        LEFT JOIN (
                        	SELECT
                        		a.Outaccount,
                        		SUM(a.cashmoney) AS total
                        	FROM ld_cashdeposit a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.Outaccount
                        ) z2 ON a.Bankaccountsetid=z2.Outaccount
                        LEFT JOIN (
                        	SELECT
                        		a.inaccount,
                        		SUM(a.cashmoney) AS total
                        	FROM ld_putcash a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.inaccount
                        ) s3 ON a.Bankaccountsetid=s3.inaccount
                        LEFT JOIN (
                        	SELECT
                        		a.Outaccount,
                        		SUM(a.cashmoney) AS total
                        	FROM ld_putcash a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.Outaccount
                        ) z3 ON a.Bankaccountsetid=z3.Outaccount
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.total) AS total
                        	FROM ld_purchasecashback a
                        	WHERE a.deleted=0
                        	GROUP BY a.bankaccountsetid
                        ) s4 ON a.Bankaccountsetid=s4.bankaccountsetid
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.total) AS total
                        	FROM ld_cashback a
                        	WHERE a.deleted=0
                        	GROUP BY a.bankaccountsetid
                        ) z4 ON a.Bankaccountsetid=z4.bankaccountsetid
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.total) AS total
                        	FROM ld_expense a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.bankaccountsetid
                        ) z5 ON a.Bankaccountsetid=z5.bankaccountsetid
                        LEFT JOIN (
                        	SELECT
                        		a.bankaccountsetid,
                        		SUM(a.total) AS total
                        	FROM ld_commission a
                        	WHERE a.deleted=0
                        		AND a.approvestatus='已批准'
                        	GROUP BY a.bankaccountsetid
                        ) z6 ON a.Bankaccountsetid=z6.bankaccountsetid
                        SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.Total,0)+IFNULL(s2.Total,0)+IFNULL(s3.Total,0)+IFNULL(s4.Total,0)-IFNULL(z1.Total,0)-IFNULL(z2.Total,0)-IFNULL(z3.Total,0)-IFNULL(z4.Total,0)-IFNULL(z5.Total,0)-IFNULL(z6.Total,0);
                        ";
        $adb->pquery($sql,array());
        $adb->pquery("SET @disable_triggers=NULL",array());
    }
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array(),'success');
}


//获取系统参数表格
function getSystemTable($info){
    $i=0;
    $table = '';
    $table .= '<input type="hidden" id="posttype" name="posttype" value="'.$info[0]['roottype'].'">';
    $table .= '<table border=0 cellspacing=0 cellpadding=0 width="100%" class="settingTable fir-center">';
    foreach($info as $item){
		$deployarray = array();
        if($item['deploy_type']=='103')
        {
            continue;
        }

		//设置服务合同新增保存后是否更新客户的客户状态字段为（为空表示不更新）
		if($item['deploy_type'] == 161){
			$focus_fieldobj=Field::getInstance('Accounts',$adb);
			$field=$focus_fieldobj->getFieldInfoobjBykey('columnname','rating');
			if(empty($field)){
				continue;
			}
		}
		//设置服务收费管理序时簿列表界面显示服务合同或联系人
		if($item['deploy_type'] == 325){
			if(!vtlib_isModuleActive('ServiceCharge')){
				continue;
			}
		}
		//客户最晚服务到期日到期后是否允许创建客户服务单
		if($item['deploy_type'] == 166){
			if(!vtlib_isModuleActive('Accounts') || !vtlib_isModuleActive('HelpDesk')){
				continue;
			}
			$focus = CRMEntity::getInstance('Accounts');
			if(!isset($focus->column_fields['lastservicedate'])){
				continue;
			}
		}
        //设置移动端客户管理、服务收费管理单据详情页签上方是否显示联系人区块务单
        if($item['deploy_type'] == 461){
            if((!vtlib_isModuleActive('Accounts') && !vtlib_isModuleActive('ServiceCharge')) || !vtlib_isModuleActive('Contacts')){
                continue;
            }
        }
		//设置销售发票，采购发票审批通过后计算已开票金额
		if($item['deploy_type'] == 463){
			if(!vtlib_isModuleActive('Invoice') && !vtlib_isModuleActive('PurchaseInvoice')){
				continue;
			}
		}elseif($item['deploy_type'] == 464){//若“产品”模块关闭，则此参数不显示
            if(!vtlib_isModuleActive('Products')){
                continue;
            }
        }
		if($item['deploy_type'] == 465){
			if(!vtlib_isModuleActive('CashBill')){
				continue;
			}
		}
		//页面设置/单据分录定制，增加“内容过多自动换行”字段属性，去掉了“设置序时簿列表界面文本区域字段类型的字段内容是否换行显示”
        if($item['deploy_type'] == 206){
			continue;
        }
        if($i % 2 == '0'){
            $table .='<tr class="lvtColData" id="setting_'.$item['deploy_type'].'" onmouseout="listOnMouseOut(ld(this),\'on\');" onmouseover="listOnMouseOver(ld(this));"';
        }
        else{
            $table .='<tr class="lvtColDataBj" id="setting_'.$item['deploy_type'].'" onmouseout="listOnMouseOut(ld(this),\'On\');" onmouseover="listOnMouseOver(ld(this));"';
        }
       
        //ls 20220808 BUG0054418 关闭“收款单”和“付款单”后，“设置计算已收金额时是否统计未审批通过的收款单”和“设置计算已付金额时是否统计未审批通过的付款单”参数仍然显示，预期结果：应该不显示
        //BUG0068070 txy 2023.06.13 后台设置--参数设置--为列表增加数字编号
        if(($item['deploy_type'] == 83 && !vtlib_isModuleActive('CashBill')) || ($item['deploy_type'] == 84 && !vtlib_isModuleActive('SendCashBill'))){
            $table .= ' style="display:none"';
            $table .= '>';
            $table .='<td class="wSpaceIn"  ></td>';
        }else{
            $i++;
            $table .= '>';
            $table .='<td class="wSpaceIn"  >' .($i).'</td>';
           
        }
        

       
        $table .='<td class="wSpaceIn" width="80%">';
        if($item['roottype'] == 3){
            if($item['setype'] == ''){
                $table .= getTransSystem($item['deploy_type']);
                
            }else{
                $table .= getTranstab($item['setype']).getFixedLabel('WHETHERENABLEAPPROVAL');
            }         
        }else{
            /*
            //翻译直接写到 ld_tranlabel 中，不用拼接。 
            //Edit by luyx at 2019-07-31
			if($item['deploy_type'] == 10 || $item['deploy_type'] == 48){
				$table .= getFixedLabel('SETTINGS');
			}*/

			foreach($item['inputvalue'] as $val){
				if(!empty($val['or_relatedmodule'])){
					$modulelabel_array = array();
					$module_all = explode(',',$val['or_relatedmodule']);
					foreach($module_all as $module){
						if(vtlib_isModuleActive($module) == 'yes'){
							$modulelabel_array[] = getTranstab($module);
						}
					}

					if(sizeOf($modulelabel_array) > 0){
						if($item['deploy_type'] == 463){
							//Edit by luyx at 2023-12-28 reason: 直接修改 ld_tranlabel 表翻译即可
							//$table .= getFixedLabel('SET');
							//$table .= implode('、',$modulelabel_array);
							//UPDATE ld_tranlabel SET fieldlabel='设置计算已开票金额时是否统计未审批的{$Invoice.Invoice}和{$PurchaseInvoice.PurchaseInvoice}' WHERE trantable='ld_systems_deploy' AND Relateid=463 AND languagetype='zh';
						}else{
							$table .= implode(getFixedLabel('OR'),$modulelabel_array);
						}
					}
				}
			}
			
			$table .=getTransSystem($item['deploy_type']);
			
        }
        $table .='</td>';
        $table .='<td class="dvtCellInfo" >';
        if($item['inputtype'] == 'text'){
            switch($item['deploy_type']){  
                case 13:
                case 14: 
                case 67:
                    //只允许录入数字
                    $table .= '<input type="text" class="ld-input-inner width120" id="'.$item['deploy_type'].'"  name="'.$item['deploy_type'].'" value="'.$item['deploy_value'].'" size="15" onkeyup="value=value.replace(/[^\d]/g,\'\')" onblur="systemSetBlur(this)">';
                    break;              
                case 18:
                case 24:
                case 40:
                case 41:
                    //只允许录入数字和空格
                    $table .= '<input type="text" class="ld-input-inner width120" id="'.$item['deploy_type'].'"  name="'.$item['deploy_type'].'" value="'.$item['deploy_value'].'" size="15" onkeyup="value=value.replace(/[^\d\s]/g,\'\')">';
                    break;
                case 105:
                case 106:
                    //@edit:zkt @date:2024/12/17 @reason:XUQIU20241104-08 【安全性优化】文件安全、数据暴露风险漏洞：CRMAPI 接口重新设计，KEY数据库中加密
                    $tmpdeploy_value = $item['deploy_value'];
                    if(is_string($tmpdeploy_value)&&$tmpdeploy_value != ''){
                        $cls_AESencryptionbykeyobj= cls_AESencryptionbykey::getInstance();
                        if(!empty($cls_AESencryptionbykeyobj->getLingdangdecryptionbykey($tmpdeploy_value,$item['deploy_type']))){
                            $tmpdeploy_value = $cls_AESencryptionbykeyobj->getLingdangdecryptionbykey($tmpdeploy_value,$item['deploy_type']);
                        }
                    }
                    //只允许录入数字和字母
                    $table .= '<input type="text" class="ld-input-inner width120" id="'.$item['deploy_type'].'"  name="'.$item['deploy_type'].'" value="'.$tmpdeploy_value.'" size="15" onkeyup="value=value.replace(/[^\d\w]/g,\'\')">';
                    unset($tmpdeploy_value);
                    break;
                default:
                     $table .= '<input type="text" class="ld-input-inner width120" id="'.$item['deploy_type'].'"  name="'.$item['deploy_type'].'" value="'.$item['deploy_value'].'" size="15">';
            }
        }
        if($item['inputtype'] == 'opetext'){
			$table .= '<div class="inputnumbox btn-radius-system width120" id="lengthdecimaldigitdiv_'.$item['deploy_type'].'">';
            $table .= '<a id="dwbtn" href="javascript:;">-</a>';
            $table .= '<input type="text" id="'.$item['deploy_type'].'" name="'.$item['deploy_type'].'"
					maxlength=1 value="'.$item['deploy_value'].'"/>';
            $table .= '<a id="upbtn" href="javascript:;">+</a>';
            $table .= '</div>';
        }
        if($item['inputtype'] == 'select'){
            
            if($item['deploy_type'] == 71){//调用产品时只能选择已审批的产品 1：否，0：是  (产品模块审批开启时才有该选项)
                $deploy_70 = getSys_deploy(70);//产品模块审批是否开启
                $table .='<input type="hidden" id=70 value="'.$deploy_70['deploy_value'].'" >';
                $table .='<select name="'.$item['deploy_type'].'" id="'.$item['deploy_type'].'" deploy_70='.$deploy_70['deploy_value'].' class="ld-select-inner width120">';
            }elseif($item['deploy_type'] == 53){ //回款计划按照项目状态收款和提醒 1:是，2：否
                $table .='<select name="'.$item['deploy_type'].'" id="'.$item['deploy_type'].'" onchange="SystemSet.showSelectPaymentPlanSet()" class="ld-select-inner width120">';
            }
            
            else{
                $table .='<select name="'.$item['deploy_type'].'" id="'.$item['deploy_type'].'" class="ld-select-inner width120">';
            }
            
			$isSelectValue = 'no';
			foreach($item['inputvalue'] as $key=>$val){
				if(!empty($val['isSelectValue']) ){
					$isSelectValue = 'yes';
					break;
				}
			}
            foreach($item['inputvalue'] as $key=>$val){
				$str = '';
                if($val['value'] == $item['deploy_value']){
                    $str = 'selected=""';
                }
                if($item['deploy_type']=='130')
                {

                    //8366: 控制面板>系统参数：“合同订单是否自动创建服务合同（服务期限为1年，金额为0元）”，不启用合同订单审批时，下拉选项应该不显示【审批通过创建】
                     $salesordersys_value= getSys_deploy(3);
                     if($salesordersys_value['deploy_value']==1&&$val['text']=='CREATEAFTERAPPROVE')
                     {
                        continue;
                     }
                }
                else if($item['deploy_type'] == 162)//合同订单保存后是否自动创建收款单
                {
                    //控制面板>系统参数：“合同订单保存后是否自动创建收款单”，不启用合同订单审批时，下拉选项应该不显示【审批通过创建】
                     $salesordersys_value= getSys_deploy(3);
                     if($salesordersys_value['deploy_value']==1&&($val['text']=='CREATEAFTERAPPROVE'||$val['text']=='CREATEAFTERAPPROVENOFREE'))
                     {
                        continue;
                     }
                }
                else if($item['deploy_type'] == 163)//服务合同保存后是否自动创建收款单
                {
                    //控制面板>系统参数：“服务订单保存后是否自动创建收款单”，不启用合同订单审批时，下拉选项应该不显示【审批通过创建】
                     $salesordersys_value= getSys_deploy(47);
                     if($salesordersys_value['deploy_value']==1&&($val['text']=='CREATEAFTERAPPROVE'||$val['text']=='CREATEAFTERAPPROVENOFREE'))
                     {
                        continue;
                     }
                }else if($item['deploy_type'] == 325){//设置服务收费管理序时簿列表界面显示服务合同或联系人
					$val['text'] = getTranstab($val['text']);
				}
				if(array_key_exists('value',$val)){
					if($isSelectValue == 'yes'){
						$table .='<option '.$str.' value="'.$val['value'].'" >'.$val['text'].'</option>';
					}else{
						//订货商城增加参数控制显示经销商折扣价
						if($item['deploy_type'] == 349 && $val['text'] == 'product_costprice'){
							$tmpfocus=CRMEntity::getInstance('Products');
                            $fieldinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",'unit_price');
							if(!empty($fieldinfo)){
								$table .='<option '.$str.' value="'.$val['value'].'" >'.getTranstab('Products').' - '.$fieldinfo->getFieldLabelKey().'</option>';
							}else{
								$table .='<option '.$str.' value="'.$val['value'].'" >'.getTranstab('Products').'</option>';
							}
						}else {
                            $table .='<option '.$str.' value="'.$val['value'].'" >'.getFixedLabel($val['text']).'</option>';
						}
					}
				}
            }
            $table .='</select>';
        }
		if($item['deploy_type'] == 48){
			$table .= '<input type="hidden" value="'.$item['deploy_value'].'" name="deploy_48_hidden" id="deploy_48_hidden" /><input type="hidden" value="0" name="deploy_48_hidden_type" id="deploy_48_hidden_type" />';
		}
        $table .='</td>';
        $table .='</tr>';
    
    }
    $table .='</table>';
    return $table;
}

//获取相应页签数据
function getSystemRootInfo($roottype){
    
    $SystemInfo = getSystemInfo();
    $SysRootInfo = array();
    foreach($SystemInfo as $key=>$info){
        if($info['roottype'] == $roottype){
            $SysRootInfo[] = $info;
        }
    }

    $SysRootInfo = getActive($SysRootInfo);
    getSqlInputValue($SysRootInfo);
    return $SysRootInfo;
}

//获取系统参数数据
function getSystemInfo(){
 
    global $adb; 
    $cachekey = 'getSystemInfo';
    $SystemInfo = CacheDirectory($cachekey,'Cache');
	require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
	$checkVersionIs001 = cls_StaticCommonFun::checkVersionIs001();
    if(!empty($SystemInfo)){
        return $SystemInfo;
    }else{
        //设置排序
        $query="SELECT deploy_value,setype,deploy_type,roottype,inputtype,inputvalue from ld_systems_deploy where presence= 0 order by sequence";
        $results=$adb->pquery($query);
        $num=$adb->num_rows($results);
        if($num>0){
            for($i=0;$i<$num;$i++){
				$deploy_type = $adb->query_result($results,$i,'deploy_type');
				if($checkVersionIs001 > 0 && $checkVersionIs001 == 55){	//客户001标准版
					if($deploy_type == '83' || $deploy_type == '84'){
						continue;
					}
				}
                $tmp_inputvalue = $adb->query_result($results,$i,'inputvalue');
                $array[] =array(
                    'setype' => $adb->query_result($results,$i,'setype'),                
                    'inputtype' => $adb->query_result($results,$i,'inputtype'),
                    'deploy_type' => $adb->query_result($results,$i,'deploy_type'),
                    'roottype' => $adb->query_result($results,$i,'roottype'),
                    'inputvalue' => !empty($tmp_inputvalue)?json_decode(htmlspecialchars_decode($tmp_inputvalue),TRUE):'',
                    'deploy_value' => $adb->query_result($results,$i,'deploy_value'),
                );
            }   
        }
        CacheDirectory($cachekey,'Cache',$array);
        return $array;
    }
}

//获取翻译
function getTransSystem($deploy_value){
    global $languageType;
    global $adb;
    $sql = "select fieldlabel from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='".$languageType."' and relateid=$deploy_value ";
      
    $results = $adb->pquery($sql);
    $fieldlabel = $adb->query_result($results,0,'fieldlabel');
    $arrlabels=explode('{$',$fieldlabel);    
    $label=$arrlabels[0];
    for($j=1;$j<sizeof($arrlabels);$j++){
        $arrrelateobj=explode('}',$arrlabels[$j]);
        $expdian=explode('.',$arrrelateobj[0]);
        $module=$expdian[0];//获取弹出框所在模块
        if(!vtlib_isModuleActive($module)){
            $label.=$arrrelateobj[1];
            continue;
        }
        $relateobj=$expdian[1];
        $tabid=getTabid($module);
        if($module == $relateobj){
            $sql='select fieldlabel from ld_tranlabel where languagetype=? and trantable=\'ld_tab\' and tabid=?';
            $resultt=$adb->pquery($sql,array($languageType,$tabid));
        }else{
            $sql='select fieldlabel from ld_tranlabel where languagetype=? and trantable=\'ld_field\' and relateid =(select fieldid from ld_field where  tabid=?  and fieldname=?) and tabid=?';
            $resultt=$adb->pquery($sql,array($languageType,$tabid,$relateobj,$tabid));
        }
        if($adb->num_rows($resultt)>0){
            $label.=$adb->query_result($resultt,0,0);
		}
         $label.=$arrrelateobj[1];
    }
     
    if(!empty($label))
        $fieldlabel=$label;
       
    return $fieldlabel;
}

//根据模块是否开启，筛选页签信息(json:relatedmodule)
function getActive($SysRootInfo){
    //获取当前系统账套
	$version=getVersionTradeInfo();
    $version=$version['trade'];
  
    foreach($SysRootInfo as $key=>$val){
		//审批参数
		if($val['setype'] != ''){
			if(!vtlib_isModuleActive($val['setype'])){
				unset($SysRootInfo[$key]);
			}
		}else{
            foreach($val['inputvalue'] as $rkey=>$rval){
				//relatedmodule:并且关系，只要不满足其一，就不显示
                if(array_key_exists('relatedmodule',$rval) && $rval['relatedmodule']!=''){
                    $module_arr = explode(',',$rval['relatedmodule']);
                    foreach($module_arr as $mval){
                        if(!vtlib_isModuleActive($mval)){
                             unset($SysRootInfo[$key]);
                             continue;
                        }
                    }
                    unset($SysRootInfo[$key]['inputvalue'][$rkey]);
                }
               
                 if(array_key_exists('relatedfield',$rval) && $rval['relatedfield']!=''){
                    $module_arr = explode(',',$rval['relatedfield']);
                    foreach($module_arr as $mval){
                          $moduleinfos=explode('.',$mval);
                          if(!vtlib_isModuleActive($moduleinfos[0])){
                             unset($SysRootInfo[$key]);
                             continue;
                           }
                           
                           
                          $tmpfocus=CRMEntity::getInstance($moduleinfos[0]);
                          $fieldinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",$moduleinfos[1]);
                          if(!$fieldinfo)
                          {
                             unset($SysRootInfo[$key]);
                             continue;
                          }
                          
                        
                    }
                    unset($SysRootInfo[$key]['inputvalue'][$rkey]);
                }
				//非金融账套，系统参数显示了：合同订单新增保存后是否立即创建派息单选项
				if(array_key_exists('version_trade',$rval) && $rval['version_trade']!=''){
					if($version != $rval['version_trade']){
						unset($SysRootInfo[$key]);
					}
				}
				//or_relatedmodule:或者关系，只要有一个模块开启，就显示
				if(array_key_exists('or_relatedmodule',$rval) && $rval['or_relatedmodule']!=''){
					$module_arr = explode(',',$rval['or_relatedmodule']);
					$isModule = 0;
					foreach($module_arr as $mval){
						if(vtlib_isModuleActive($mval)){
                             $isModule = 1;
                        }
					}
					if(empty($isModule)){
						unset($SysRootInfo[$key]);
					}
				}
            }
		}       
    }
	return $SysRootInfo;
}

function getMaxSystemDeploy(){
	global $adb;
	$query = 'select max(deploy_type) from ld_systems_deploy';
	$result = $adb->pquery($query,array());
	return $adb->query_result($result,0,0);
}
//获取sql对应的数据放入$info
function getSqlInputValue(&$SysRootInfo){
    global $adb;
    //Eidtor:gyq_64 Reason:下拉框改进  Date:2018/4/2 0002 下午 5:07
    //脚本示例，增加"type":"picklist","relatetable":"ld_field"
    // UPDATE ld_systems_deploy SET inputvalue='[{"value":"sales_stage","text":"sales_stage"},{"field":"sales_stage","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Potentials"},{"isSelectValue":"yes"}]' WHERE deploy_type=38;
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    foreach($SysRootInfo as $key=>$val){
        foreach($val['inputvalue'] as $ikey=>$ival){
            if(isset($ival['type']) && $ival['type']=='picklist'){
                $arrpicklist = $objpinklist->getPickListValues($ival['field'],array(),'',$ival['relatetable']);
                foreach($arrpicklist as $pickkey=>$pickvalue){
                    $SysRootInfo[$key]['inputvalue'][]=array(
                        'value' => $pickvalue,
                        'text' => $pickvalue,
                    );
                }
                $SysRootInfo[$key]['inputvalue'][0]['value'] = '';
                $SysRootInfo[$key]['inputvalue'][0]['text'] = '';
                unset($SysRootInfo[$key]['inputvalue'][$ikey]);
            }else{
                if($ival['sql'] != ''){
                    $result = $adb->pquery($ival['sql'],array());
                    for($i=0;$i<$adb->num_rows($result);$i++)
                    {
                        $SysRootInfo[$key]['inputvalue'][]=array(
                            'value' => $adb->query_result($result,$i,$val['inputvalue'][0]['value']),
                            'text' => $adb->query_result($result,$i,$val['inputvalue'][0]['text']),
                        );
                    }
                    $SysRootInfo[$key]['inputvalue'][0]['value'] = '';
                    $SysRootInfo[$key]['inputvalue'][0]['text'] = '';
                    unset($SysRootInfo[$key]['inputvalue'][$ikey]);
                }
            }

        }
    }
    
    return $SysRootInfo;
}

// require_once('SetmenuControl.php');


/*
reason:隐藏审批参数设置
if($_REQUEST['comefromapprove'] == 1){
    header("Location: index.php?module=Settings&action=MultiApproveList&parenttab=Settings&blockidsetting=3&fieldidsetting=47");
}else{*/
$_REQUEST['diony']='yes';
$regop=RegOp::getInstance();
$smarty->assign("VersionNo",$regop->GetVersionNo());
$smarty->assign("iskehu001",isKehu001ServerPc());
$arr['content']= $smarty->fetch('SystemSet.tpl');
ConvertTojsonString(1,$arr,"success");


?>