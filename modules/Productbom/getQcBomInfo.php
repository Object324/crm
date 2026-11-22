<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if(!isset($_REQUEST['setype'])) die;
global $currentModule;
global $adb;
$setype = $_REQUEST['setype'];
$entity = array();
$ScopOfAuthority = ScopOfAuthority::getInstance($adb,'Productbom');
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
switch($setype){
    case 'init'://初始化
		global $current_user;
		require('user_privileges/user_language_'.$current_user->id.'.php');
		require('user_privileges/user_privileges_'.$current_user->id.'.php');
		$tabid = getTabid('Productbom');
        $query = 'SELECT ld_field.columnname,ld_tranlabel.fieldlabel 
					FROM ld_field 
				INNER JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_field.`fieldid`
					WHERE ld_field.tabid = ? AND languagetype = ? 
					AND ld_field.columnname IN ("subject","smownerid");';
		$result = $adb->pquery($query,array($tabid,$languageType));
		$rows = $adb->num_rows($result);
		$fldlabel = array();
		if($rows > 0){//获得套餐名、负责人两个字段的翻译值(区分中英文)
			for($i=0;$i<$rows;++ $i){
			    $columnname = $adb->query_result($result,$i,'columnname');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				$fldlabel[$columnname] = $fieldlabel;
			}
		}
		$userid = $current_user->id;//获取负责人列表
		$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $userid), $userid);
		$fldlabel['nomatchingitems'] = getFixedLabel('NOMATCHINGITEMS');//没有匹配项目
		$entity['fldlabel'] = $fldlabel;
		$entity['user'] = $users_combo;
		$entity['userid'] = $userid;//当前用户ID
		$productcontent = 'productcategory,usageunit,unit_price';//产品套餐产品显示的字段
		$entity['product'] = $productcontent;
        break;
    case 'product'://选择产品套餐时，已经取到所有产品的ID，则直接通过产品ID获取选择产品需要的数据
        if(isset($_REQUEST['productid']) && !empty($_REQUEST['productid'])){
			$productid = trim($_REQUEST['productid'],',');
			$query = 'select productid,productname,unit_price,costprice from ld_products 
						where deleted = 0 and productid in ('.$productid.') ';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			if($rows > 0){
				$tmp_arr = array();
				$sysdeploy = getSys_deploy(49);
				if(isset($sysdeploy['deploy_value']))
					$lengthdecimaldigits = $sysdeploy['deploy_value'];
				else
					$lengthdecimaldigits  = 2;
				for($i=0;$i<$rows;++ $i){
					$pro_id = $adb->query_result($result,$i,'productid');
					$name = $adb->query_result($result,$i,'productname');
					$unitprice = $adb->query_result($result,$i,'unit_price');
					$costprice = $adb->query_result($result,$i,'costprice');
					/**
					 * 如果是RMB表体录入样式，则传递过去相关税率信息
					 * @project PROT99 奥特林：产品明细录入改进
					 * @author Tujt 2014-10-16
					 */
					$deployarray_52 = getSys_deploy(52);
					if(1 == $deployarray_52['deploy_value']){
						$sub_det = getRMBProductInfo();
						global $rmb_euro_id;
						if($rmb_euro_id > 0){
							$rmb_euro_price = getProductCurrency($pro_id,$rmb_euro_id);
							if($rmb_euro_price > 0) $unitprice = $rmb_euro_price;
							else $unitprice = 0;
						}
					}else{
						$sub_det = '::';
					}
					$tax_details = getTaxDetailsForProduct($pro_id);
					for ($tax_count = 0; $tax_count < count($tax_details); $tax_count++) {
						$tax_str .= $tax_details[$tax_count]['taxname'] . '=' . $tax_details[$tax_count]['percentage'] . ',';
						$tax_labelstr .= $tax_details[$tax_count]['taxlabel'] . ',';
					}
					for ($tax_count = 0; $tax_count < count($tax_details); $tax_count++) {
						$tax_str .= $tax_details[$tax_count]['taxname'] . '=' . $tax_details[$tax_count]['percentage'] . ',';
					}
					$tax_str = trim($tax_str, ',');
					$tax_labelstr= trim($tax_labelstr, ',');
				    $tmp_arr = array(
								"entityid" => $pro_id, 
								"prodname" => str_replace('+', '%20', urlencode(stripslashes(decode_html(nl2br($name))))),
								"unitprice" => $unitprice, 
								"qtyinstk" => 1,
								"costprice"=>$costprice, 
								"taxstring" => $tax_str, 
								"taxlabelstring"=>$tax_labelstr,
								"desc" => "", 
								"subprod_ids" => $sub_det,
								"span_var"=>"",
								"span_all"=>"".implode(',',setProductsInfo($pro_id))."",
								'format_num' => $lengthdecimaldigits,
							);
					$entity[]['vt_prod_arr'] = $tmp_arr;
				}
			}
		}
        break;
	case 'edit'://编辑产品套餐，获取产品套餐信息
	    $bomid = $_REQUEST['bomid'];
		$isbom = isPermitted('Productbom','EditView',$bomid);//判断是否有这个单子的编辑权限
		$entity['permitted']['value'] = $isbom;
		if($isbom == 'no'){
			echo '###error###' . getFixedLabel('NOPERMITTEDEXECUTE');
			die;
		}else{
			require('user_privileges/user_language_'.$current_user->id.'.php');
			require('user_privileges/user_privileges_'.$current_user->id.'.php');
			$tabid = getTabid('Productbom');

			$query = 'SELECT ld_field.columnname,ld_tranlabel.fieldlabel 
					FROM ld_field 
				INNER JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_field.`fieldid`
					WHERE ld_field.tabid = ? AND languagetype = ? and ld_tranlabel.tabid = ?
					AND ld_field.columnname IN ("subject","smownerid");';
			$result = $adb->pquery($query,array($tabid,$languageType,$tabid));
			$rows = $adb->num_rows($result);
			$fldlabel = array();
			if($rows > 0){//获得套餐名、负责人两个字段的翻译值(区分中英文)
				for($i=0;$i<$rows;++ $i){
					$columnname = $adb->query_result($result,$i,'columnname');
					$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
					$fldlabel[$columnname] = $fieldlabel;
				}
			}
			//获取负责人
			$userid = $current_user->id;
			$smarty->assign('SUBJECT',$fldlabel['subject']);
			$smarty->assign('SMOWNER',$fldlabel['smownerid']);
			$smarty->assign('MODE',$_REQUEST['mode']);
			$smarty->assign('CURR_ROW',$_REQUEST['curr_row']);
			$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
			$focus = CRMEntity::getInstance('Productbom');
			$focus->mode = $_REQUEST['mode'];
			if(!empty($bomid)){
				$focus->id = $bomid;
				$focus->retrieve_entity_info($bomid, "Productbom");
				$query = 'select ld_productbom.subject,ld_productbom.productbom_no,ld_productbom.smownerid,ld_productbom.subtotal,
							ld_productbom.total from ld_productbom where ld_productbom.deleted = 0 and ld_productbom.productbomid = ? ';
				$result = $adb->pquery($query,array($bomid));
				$rows = $adb->num_rows($result);
				if($rows > 0){
					$sysdeploy = getSys_deploy(49);
					if(isset($sysdeploy['deploy_value']))
						$lengthdecimaldigits = $sysdeploy['deploy_value'];
					else
						$lengthdecimaldigits  = 2;
					for($i=0;$i<$rows;++ $i){
						$subject = $adb->query_result($result,$i,'subject');
						$smownerid = $adb->query_result($result,$i,'smownerid');
						$productbom_no = $adb->query_result($result,$i,'productbom_no');
						$subtotal = $adb->query_result($result,$i,'subtotal');
						$total = $adb->query_result($result,$i,'total');
						$entity['subject'] = $subject;
						$entity['smownerid'] = $smownerid;
						if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'copy'){
							$entity['productbom_no'] = '';
						}else{
							$entity['productbom_no'] = $productbom_no;
						}
						$entity['subtotal'] = $subtotal;
						$entity['total'] = $total;
					}
					$userid = $smownerid;
					$smarty->assign('ENTITY',$entity);
				}
			}
            $focus->mode='edit';
            
			$entity['content']['value'] = $ProductDetailsHtml->getProductDetailsHtml($focus);
			$smarty->assign('ASSOCIATED_PRODUCTS',$entity['content']['value']);
			$productFields['fields']=$ProductDetailsHtml->moduleProductToolField;
			// editor:gyqX160722 Bug:0022129
			$productFields_new = preg_replace("|[".chr(1)."-".chr(31)."]+|",'', $productFields);

			$smarty->assign('PRODUCTFIELDSINFOJSON',json_encode($productFields_new));
			$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $userid), $userid);
			$smarty->assign('USERCOMBO',$users_combo);
			if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'copy'){
				$smarty->assign('BOMID','');
			}else{
				$smarty->assign('BOMID',$bomid);	
			}
		}
	    break;
	case 'bomname'://不同份数时，因为考虑到可能列头没有套餐名称字段，所以用ajax获取对应的套餐名称
	    $bomid = trim($_REQUEST['bomid'],',');
        $focus=CRMEntity::getInstance($currentModule);
        $columnname=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$focus->list_link_field,'columnname');
        
		$query = " SELECT productbomid,$columnname as subject FROM ld_productbom WHERE productbomid in ( ".$bomid.') ';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$productbomid = $adb->query_result($result,$i,'productbomid');
			    $subject = $adb->query_result($result,$i,'subject');
				$entity['bom'][$productbomid] = $subject;
			}
			$entity['row'] = $rows;
		}
	    break;
	case 'bomproduct':
	    if(isset($_REQUEST['bomid']) && !empty($_REQUEST['bomid'])){
			$bomid = trim($_REQUEST['bomid'],',');
		}else{
			return false;
		}
        // ljj 2024-11-4 XUQIU20241029-01 产品套餐字段需要能带到单据上（含移动端）选择产品套餐走选择原单业务,将明细数据带出
        $_REQUEST['selectmodule'] = $currentModule;
        $_REQUEST['popup_selectsource'] = 'true';
        $_REQUEST['withproductdetail'] = 'yes';
        $focus=CRMEntity::getInstance($currentModule);
        //简单点就认为套餐超链接字段是主表
        $columnname=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$focus->list_link_field,'columnname');
        
		$query = "SELECT ld_products.productid,ld_products.productname,
					ld_products.unit_price,ld_products.costprice,
					ld_productbomdetail.quantity,ld_productbomdetail.taxprice,
					ld_productbom.productbomid,ld_productbom.$columnname as subject,ld_productbom.total,ld_productbomdetail.lineitem_id  
						FROM ld_productbom 
					INNER JOIN ld_productbomdetail 
						ON ld_productbomdetail.id = ld_productbom.productbomid 
					INNER JOIN ld_products 
						ON ld_products.productid = ld_productbomdetail.productid 
					WHERE ld_productbom.deleted = 0 and ld_productbom.productbomid in ( ".$bomid.') order by ld_productbom.productbomid desc';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		if($rows > 0){
			$tmp_arr = array();
			$sysdeploy = getSys_deploy(49);
			if(isset($sysdeploy['deploy_value']))
				$lengthdecimaldigits = $sysdeploy['deploy_value'];
			else
				$lengthdecimaldigits  = 2;
            crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
			for($i=0;$i<$rows;++ $i){
				$pro_id = $adb->query_result($result,$i,'productid');
				$name = $adb->query_result($result,$i,'productname');
				$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
				$unitprice = sprintf('%.2f',$adb->query_result($result,$i,'unit_price'));
				$costprice = sprintf('%.2f',$adb->query_result($result,$i,'costprice'));
				$quantity = sprintf('%.'.$lengthdecimaldigits.'f',$adb->query_result($result,$i,'quantity'));
				$listprice = sprintf('%.2f',$adb->query_result($result,$i,'taxprice'));
				$bom_id = $adb->query_result($result,$i,'productbomid');
				$bom_name = $adb->query_result($result,$i,'subject');
				$bom_total = sprintf('%.2f',$adb->query_result($result,$i,'total'));
				/**
				 * 如果是RMB表体录入样式，则传递过去相关税率信息
				 * @project PROT99 奥特林：产品明细录入改进
				 * @author Tujt 2014-10-16
				 */
                 
				$tmp_arr=setProductsInfo($_REQUEST['returnmodule'],$lineitem_id,$_REQUEST['currencyid'],$_REQUEST['keywords'],$_REQUEST['curr_row'],'type');
                unset($tmp_arr['entitytype'],$tmp_arr['entitytype_module'],$tmp_arr['entitytype_transmodule'],$tmp_arr['selectSourceModuleid']);
                unset($tmp_arr['lineitem_id'],$tmp_arr['hidden_lineitem_id']);
                $tmp_arr['hdnProductId'] = $pro_id;
				$tmp_arr['quantity'] = $quantity;
				$tmp_arr['listprice'] = $listprice;
				$tmp_arr['taxprice'] = $listprice;
				$tmp_arr['bom_id'] = $bom_id;
				$tmp_arr['bom_name'] = $bom_name;
				$tmp_arr['bom_total'] = $bom_total;
				$tmp_arr['productcost'] = $costprice;
				$tmp_arr['product_desc'] = $bom_name . '=' . $bom_total . '*' . $quantity;
				$entity[]['vt_prod_arr'] = $tmp_arr;
			}
		}
	    break;
}
if($setype == 'product' || $setype == 'bomproduct' || $setype == 'bomname'){
	//require_once('./include/Zend/Json.php');
	//$json = new Zend_Json();
	$jsonentity = json_encode($entity);
	echo $jsonentity;
	die;
}else{
	if($_REQUEST['mode'] == 'edit' || $_REQUEST['mode'] == 'copy' || $_REQUEST['mode'] == 'update'){
		$_REQUEST['diony']='diony';
		if($_REQUEST['mode'] == 'edit'){
			$arr['title']=getTransTab('Productbom') . ' > ' . getTranstab('EDIT');
		}else if($_REQUEST['mode'] == 'copy'){
			$arr['title']=getTransTab('Productbom') . ' > ' . getTranstab('COPY');
		}else if($_REQUEST['mode'] == 'edit'){
			$arr['title']=getTransTab('Productbom') . ' > ' . getTranstab('Adjustment');
		}else{
			$arr['title']=getTransTab('Productbom') . ' > ' . getTranstab('Quickly_create');
		}
		$str=$smarty->fetch("QuickProductbom.tpl");
		$arr['content']=$str;
		ConvertTojsonString(1,$arr,"success");
		exit();
	}else{
		$smarty->display('QuickProductbom.tpl');
	}
}
?>