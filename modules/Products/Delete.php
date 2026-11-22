<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);

$record = vtlib_purify($_REQUEST['record']);
$module = vtlib_purify($_REQUEST['module']);
$return_module = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$parenttab = getParentTab();
$return_id = vtlib_purify($_REQUEST['return_id']);
   /**
*@andrew
* @time:20140903
*0011046: 并发删除单据时，结果弹出提示“undefined”
*/
	$record = $_REQUEST['record'];
	$checkdeletesql="select productid from ld_products where productid in($record) and deleted=0";

	$dresult=$adb->query($checkdeletesql);
	$dnum_rows=$adb->num_rows($dresult);

    if($dnum_rows==0){
        $srt = getFixedLabel('Thisrecordisdeleted');
        $entity['log']['value'] = $srt;
        $entity['title']['value'] = getFixedLabel('DELETE');
        $json = new Zend_Json();
        $jsonentity = $json->encode($entity);
        echo $jsonentity;die;
    }
	if(!empty($_REQUEST['inven_product']) && $_REQUEST['inven_product'] == 'yes'){
	   $SQL='select ld_tab.name from ld_producttoolfield
       inner join ld_tab on ld_tab.tabid=ld_producttoolfield.tabid 
       where ld_tab.presence in(0,2) group by ld_tab.name';
    	 $hurl = 'index.php?module='.vtlib_purify($_REQUEST['return_module']).'&action='.vtlib_purify($_REQUEST['return_action']).'&record='.vtlib_purify($_REQUEST['return_id']).'&parenttab='.$parenttab.'&relmodule='.vtlib_purify($_REQUEST['module']).$url;
	 		   $entityarray = getEntitynameInfo(getTabid('Products'));
	   		 $tabfieldname = $entityarray['fieldname'];//模块链接字段
	   		 $query = "select $tabfieldname as subject from ld_products where productid = ?";
	   		 $result = $adb->pquery($query,array($record));
	   		 $subject = $adb->query_result($result,0,0);
                
       $productdetail_result=$adb->pquery($SQL,array());
       $bol='yes';
       	$entity['stype']['value'] = 'success';
       for($i=0;$i<$adb->num_rows($productdetail_result);$i++)
       {
            //判断该产品是否已经有关联的单据
            $tabname=$adb->query_result($productdetail_result,$i,'name');
            
    		$productforsource = $focus->getProductForSource($record,$tabname);
            if($productforsource['num_rows']>0)
            {
                $srt.= sprintf(getFixedLabel('FAILEDFORORDERISAPPROVINGFORINVEN'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$record.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',getFixedLabel('DELETETISHI')).getFixedLabel('associateddocuments').$productforsource['link'] . '<br>';
   			      $bol='no';
            }
            //$entity['stype']['value'] = 'error';
        
    	/*	}else{
    			$entity['stype']['value'] = 'success';
    		}*/
            
       }
      
		if($bol=='no')
        {
            $entity['stype']['value'] = 'error';
        }
		$entity['log']['value'] = $srt;//
		$entity['title']['value'] = getFixedLabel('DELETE');// 删除
		require_once('./include/Zend/Json.php');
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
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(!isset($record))
	die(getTranslatedString('ERR_DELETE_RECORD'));
if($return_module!="Products" || ($return_module=="Products" && empty($return_id)))
	DeleteEntity($currentModule, $return_module, $focus, $record, $return_id);
else
	$focus->deleteProduct2ProductRelation($record, $return_id, $_REQUEST['is_parent']);
 
 
 //edit:can 2021-03-05 44694: （https://61mis.com/kfbcrm [^]）产品管理模块中，在产品的明细界面删除产品之后，会跳转到首页。应该是删除之后停留在产品管理模块的序时簿界面
echo "##YES##";
/*
$parenttab = getParentTab();
echo "##YES##";
if(isset($_REQUEST['activity_mode']))
	$url .= '&activity_mode='.vtlib_purify($_REQUEST['activity_mode']);

header("Location: index.php?module=$return_module&action=$return_action&record=$return_id&relmodule=$module".$url);*/

?>