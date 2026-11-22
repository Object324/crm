<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
* 入库单  审核、反审核操作
 ********************************************************************************/
 if(!empty($_REQUEST['record']) && !empty($_REQUEST['persence'])){
	//presence 1:审核  2:未审核
     
	global $adb,$PlatformMC;
	//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
	$deployarray=getSys_deploy(48);
	if($deployarray['deploy_value']== 1){
		if($_REQUEST['stype'] == 'check'){
			require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
			updateStockPresence($_REQUEST['record']);
		}
        if(empty($PlatformMC)){
            echo 'success';die;
        }else{
            ConvertTojsonString(1,array(),'');
        }
	}
	$presence = $_REQUEST['persence'];
	$record = $_REQUEST['record'];
    //edit:can 20230103 60367 新建入库单时，提示入库单的数量不允许超过源单（在页面设置中已经取消了控制“数量”不允许超出源单） 
     if(empty($PlatformMC)){
            echo 'success';die;
    }else{
        ConvertTojsonString(1,array(),'');
    }
	if($presence == 1){
		$query = 'select parent_lineitem_id,entitytype,entitytypeid,productid,quantity from ld_stockdetail where id = ?';
		$result = $adb->pquery($query,array($record));
		for($i = 0; $i<$adb->num_rows($result); $i++){
			$parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
			$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
			$productid = $adb->query_result($result,$i,'productid');
			$quantity = $adb->query_result($result,$i,'quantity');
            $entitytype= $adb->query_result($result,$i,'entitytype');
			if($productid > 0 && $entitytypeid > 0 && $parent_lineitem_id > 0&&!empty($entitytype)){
			     $focus=CRMEntity::getInstance($entitytype);
                 $detailtable=$focus->Detail_table;
				$query = " SELECT
					havepurchasecount,balancepurchasecount,ld_products.productname,ld_products.product_no 
				FROM
					$detailtable
				LEFT JOIN ld_products on ld_products.productid = $detailtable.productid
				WHERE
					$detailtable.id = ?
				AND $detailtable.productid = ?
				AND $detailtable.lineitem_id = ? ";
				$sresult = $adb->pquery($query,array($entitytypeid,$productid,$parent_lineitem_id));
				$num_rows = $adb->num_rows($sresult);
				if($num_rows >= 1){
					$productname = $adb->query_result($sresult,0,'productname');
					$product_no = $adb->query_result($sresult,0,'product_no');
					$balancepurchasecount = $adb->query_result($sresult,0,'balancepurchasecount');
					$havepurchasecount = $adb->query_result($sresult,0,'havepurchasecount');
					if($quantity > $balancepurchasecount){
						$error[$parent_lineitem_id] = array(
							'productname' => $productname,
							'product_no' => $product_no,
							'havepurchasecount' =>  sprintf('%.2f',$havepurchasecount),
							'balancepurchasecount' => sprintf('%.2f',$balancepurchasecount)
						);
					}
				}
			}
		}
	}
	if(!empty($error)){
	    if(empty($PlatformMC)){
	        require_once('./include/Zend/Json.php');
    		$json = new Zend_Json();
    		$jsonentity = $json->encode($error);
    		echo $jsonentity;die;
	    }else{
            $k = 1;
            $err_info = '';
            foreach($error as $val){
                $productname = '<span style="color: #0070ba;">' . $val['productname'] . '</span>（'.$val['product_no'].'）';
	            $err_info .= $k .'、'.$productname . '　累计入库数量: '. setNumberFormat($val['havepurchasecount']) .'　可入库数量: '.setNumberFormat($val['balancepurchasecount']) . '<br>';
                $k++;
            }
	        $err_subject = '产品累计入库数量超过可入库数量,审核失败!';
	        $wx_err = '<div style="text-align: left;">'.$err_subject.'<br>'.$err_info.'</div>';
	        ConvertTojsonString(-1,null,$wx_err);
	    }
	}else{
		if($_REQUEST['stype'] == 'check'){
			require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
			updateStockPresence($_REQUEST['record']);
		}
        if(empty($PlatformMC)){
            echo 'success';die;
        }else{
            ConvertTojsonString(1,array(),'');
        }
		
	}
 }

?>