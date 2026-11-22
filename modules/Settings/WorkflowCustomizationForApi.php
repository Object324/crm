<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
if(!empty($_REQUEST['getModuleField']) && $_REQUEST['getModuleField'] == 'yes' && !empty($_REQUEST['sel_tabid'])){
	$moduelfield = getModuleField($_REQUEST['sel_tabid']);
	$_REQUEST['diony']='yes';
	ConvertTojsonString(1,$moduelfield,"success");
}else{
	$moduelfield = getModuleField($_REQUEST['tabid']);
}
$moduelmainfield = getModuleMainField($_REQUEST['tabid']);//调用API只取主表字段

//所有相关模块
$sql='select  name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=? and `name` in (\'SalesOrder\',\'ServiceContracts\',\'Accounts\',\'Products\',\'Expense\') and presence in(0,2) order by tabsequence ';
$result=$adb->pquery($sql,array($languageType,'ld_tab'));
$workflow_module=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $tablabel=$adb->query_result($result,$i,'tablabel');
    $name=$adb->query_result($result,$i,'name');
    $tabid=$adb->query_result($result,$i,'tabid');
    if($tabid==9)
    {
        $tabid=16;
    }
    $workflow_module[$tabid]=$adb->query_result($result,$i,'fieldlabel');
}
$smarty->assign('WORKFLOW_MODULE',$workflow_module);
$smarty->assign('FIELDSEL',$moduelfield);
$smarty->assign('MAINFIELDSEL',$moduelmainfield);
$smarty->assign('MODULE_TABID',$_REQUEST['tabid']);
$workflow_api_parameter = [];

$workflow_actionid = (int)$_REQUEST['workflow_actionid'];
if(!empty($workflow_actionid)){
	$query = "select workflow_id,action_title,api_url,api_jsondata,body_query_type,api_receive_msg from ld_workflow_actions where id = ? limit 1";
	$result=  $adb->pquery($query,array($workflow_actionid));
	$workflow_id = $adb->query_result($result,0,'workflow_id');
	$action_data = array(
		'workflow_id' => $workflow_id,
		'action_title' => $adb->query_result($result,0,'action_title'),
		'api_url' => $adb->query_result($result,0,'api_url'),
		'api_jsondata' => $adb->query_result($result,0,'api_jsondata'),
		'workflow_actionid' => $workflow_actionid,
		'body_query_type' => $adb->query_result($result,0,'body_query_type'),
		'api_receive_msg' => $adb->query_result($result,0,'api_receive_msg'),
	);

    $query = "select workflow_id,workflow_action_id,parameter_name,parameter_type,parameter_value,parameter_description,sequence,workflow_api_type from ld_workflow_api_parameter where workflow_id = ? and workflow_action_id = ?";
    $result=  $adb->pquery($query,array($workflow_id,$workflow_actionid));
    if($adb->num_rows($result) >= 1){
        for($i = 0; $i < $adb->num_rows($result); $i++){
            $workflow_api_type = $adb->query_result($result,$i,'workflow_api_type');
            $sequence = $adb->query_result($result,$i,'sequence');
            $workflow_api_parameter[$workflow_api_type][$sequence] = array(
                'parameter_name' => $adb->query_result($result,$i,'parameter_name'),
                'parameter_type' => $adb->query_result($result,$i,'parameter_type'),
                'parameter_value' => $adb->query_result($result,$i,'parameter_value'),
                'parameter_description' => $adb->query_result($result,$i,'parameter_description'),
            );

        }
    }

}else{
//	$module = getTabname($_REQUEST['tabid']);
//	$action_data = getDefaultJson($module);//BUG0070781 新增API的时候，API URL 应该默认为空，且需要控制必填
	$workflow_id = (int)$_REQUEST['workflow_id'];
}



$smarty->assign('TABID',$_REQUEST['tabid']);
$smarty->assign('ACTION_DATA',$action_data);
$smarty->assign('WORDFLOW_ID',$workflow_id);
//$smarty->assign('JDYISV',$_REQUEST['jdyisv']);
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('ADDITION').getFixedLabel('WorkflowActions').'  ->  '.getFixedLabel('CallAPI');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['work_api_parameter']=$workflow_api_parameter;
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForApi.tpl');
ConvertTojsonString(1,$arr,"success");

function getDefaultJson($module){
	if($module == 'Accounts'){
		$action_data['api_url'] = 'https://api.kingdee.com/jdy/basedata/customer_save';
		$action_data['api_jsondata'] = '{
       "id":"[var.ld_account_kis_id_Accounts]",
      "number":"[var.ld_account_account_no_Accounts]",
      "name":"[var.ld_account_accountname_Accounts]",
      "group_id":"",
      "clevel_id":"",
      "saledeptid_id":"",
      "salerid_id":"[var.ld_account_smownerid_Accounts]",
      "rate":"40",
      "bankaccount":"",
      "bank":"",
      "accountopenaddr":"",
      "countryid_id":"[var.ld_account_bill_country_Accounts]",
      "provinceid_id":"[var.ld_account_bill_state_Accounts]",
      "cityid_id":"[var.ld_account_bill_city_Accounts]",
      "districtid_id":"[var.ld_account_bill_area_Accounts]",
      "addr":"[var.ld_account_bill_street_Accounts]",
      "remark": "[var.ld_account_description_Accounts]",
	  "ignorewarn":true,
       "contactpersons": [
          {
              "contactperson":"[var.ld_contactdetails_lastname_Accounts]",
              "mobile":"[var.ld_contactdetails_mobile_Accounts]",
              "phone":"[var.ld_contactdetails_pphone_Accounts]",
              "gender":"1",
              "birthday":"[var.ld_contactdetails_birthday_Accounts]",
              "qq": "[var.ld_contactscf_qq_Accounts]",
              "email":"[var.ld_contactdetails_email_Accounts]",
              "wechat":"[var.ld_contactscf_wx_Accounts]",
              "isdefault_linkman": true,
              "contact_address":"[var.ld_contactdetails_mailingstreet_Accounts]",
              "contact_countryid_id":"[var.ld_contactdetails_mailingcountry_Accounts]",
              "contact_provinceid_id":"[var.ld_contactdetails_mailingstate_Accounts]",
              "contact_cityid_id":"[var.ld_contactdetails_mailingcity_Accounts]",
              "contact_districtid_id":"[var.ld_contactdetails_mailingarea_Accounts]"
          }
     ]
}';
	}else if($module == 'Products'){
		$action_data['api_url'] = 'http://api.kingdee.com/jdy/basedata/material_save';
		$action_data['api_jsondata'] = '{
"id":"[var.ld_products_kis_id_Accounts]",
"name":"[var.ld_products_productname_Products]",
"number":"[var.ld_products_product_no_Products]",
"checktype":1,
"baseunitid_id":"[var.ld_products_usageunit_Products]",
"purchaseunitid_id":"[var.ld_products_usageunit_Products]",
"saleunitid_id":"[var.ld_products_usageunit_Products]",
"storeunitid_id":"[var.ld_products_usageunit_Products]",
"model":"[var.ld_products_productsheet_Products]",
"helpcode":"[var.ld_products_productcode_Products]",
"auxunitid_id":"[var.ld_products_usageunit_Products]"
}';
	}else if($module == 'SalesOrder'){
		$action_data['api_url'] = 'https://api.kingdee.com/jdy/sal/sal_order_save';
		$action_data['api_jsondata'] = '{
 "id": "[var.ld_salesorder_kis_id_SalesOrder]",
  "billdate": "[var.ld_salesorder_signed_data_SalesOrder]",
  "billno": "[var.ld_salesorder_salesorder_no_SalesOrder]",
  "customerid_id": "[var.ld_account_account_no_SalesOrder]",
  "empid_id": "[var.ld_salesorder_smownerid_SalesOrder]",
  "remark": "[var.ld_salesorder_description_SalesOrder]",
  "contact_phone": "[var.ld_contactdetails_mobile_Accounts]",
  "totalamount": "[var.ld_salesorder_total_SalesOrder]",
  "contact_address": "[var.ld_contactdetails_mailingstreet_Accounts]",
  "contact_linkman": "[var.ld_contactdetails_lastname_Accounts]",
  "currencyid_id": "[var.ld_salesorder_currency_id_SalesOrder]",
  "billsource": "APP",
  "ignorewarn":true,
  "material_entity": [{
                "unit_id":  "[var.ld_products_usageunit_products]",
                "taxprice": "[var.productdetails_taxprice_products]",
                "qty": "[var.productdetails_quantity_products]",
                "materialid_id": "[var.ld_products_product_no_products]",
                "auxpropid": null,
                "deliverydate": "",
                "stockid_id":"",
                "comment":"[var.productdetails_comment_products]",
				"allamount":"[var.productdetails_tax_amount_products]",
                "cess":"[var.productdetails_tax2_products]",
                "deliverydate":""
  }]
}';
	}else if($module == 'ServiceContracts'){
		$action_data['api_url'] = 'https://api.kingdee.com/jdy/sal/sal_order_save';
		$action_data['api_jsondata'] = '{
 "id": "[var.ld_servicecontracts_kis_id_SalesOrder]",
  "billdate": "[var.ld_servicecontracts_due_date_ServiceContracts]",
  "billno": "[var.ld_servicecontracts_contract_no_ServiceContracts]",
  "customerid_id": "[var.ld_account_account_no_SalesOrder]",
  "empid_id": "[var.ld_servicecontracts_smownerid_ServiceContracts]",
  "remark": "[var.ld_servicecontracts_description_ServiceContracts]",
  "contact_phone": "[var.ld_contactdetails_mobile_Accounts]",
  "totalamount": "[var.ld_servicecontracts_total_ServiceContracts]",
  "contact_address": "[var.ld_contactdetails_mailingstreet_Accounts]",
  "contact_linkman": "[var.ld_contactdetails_lastname_Accounts]",
  "currencyid_id": "[var.ld_servicecontracts_currency_id_ServiceContracts]",
  "billsource": "APP",
  "ignorewarn":true,
  "material_entity": [{
                "unit_id":  "[var.ld_products_usageunit_products]",
                "price": "[var.productdetails_taxprice_products]",
                "qty": "[var.productdetails_quantity_products]",
                "materialid_id": "[var.ld_products_product_no_products]",
                "auxpropid": null,
                "deliverydate": "",
                "stockid_id":"",
                "comment":"[var.productdetails_comment_products]",
                "cess":"[var.productdetails_tax2_products]",
                "taxamount":"[var.productdetails_tax_total_products]",
                "discount":"[var.productdetails_discount_percent_products]",
                "disamount":"[var.productdetails_discount_amount_products]",
                "deliverydate":""
  }]
}';
	}else if($module == 'Expense'){
		$action_data['api_url'] = 'http://api.kingdee.com/jdy/arap/ap_other_credit_save';
		$action_data['api_jsondata'] = '{
"id": "[var.ld_expense_kis_id_Expense]",
"billdate":"[var.ld_expense_expensedate_Expense]",
"billno": "[var.ld_expense_expense_no_Expense]",
"emp_id": "[var.ld_expense_smownerid_Expense]",
"billsource":"crm",
"biztype": "1",
"remark":"",
"payfromtoentry": [
            {
               "id":"[var.expensedetails_kis_id2_expense]",
                "amount": "[var.expensedetails_money_expense]",
                "paccttype_id": "",
                "comment": "[var.expensedetails_expenseuse_expense]"
            }
    ],  
    "instantpayfromtoentry": [
            {
                "id":"[var.expensedetails_kis_id_expense]",
                "instantcomment": "[var.expensedetails_description_expense]",
                "instantpaytypeid_id": "",
                "instantsettleaccountid_id": "交行",
                "instantamount": "[var.expensedetails_money_expense]",
            }
        ]
}';
	}
	return $action_data;
}
//获取所有模块字段
function getModuleField($tabid){
	$tabname=getTabname($tabid);
	$blocks = getBlockLabels($tabid);
	$module_type = '';
	if(get_file_address($tabname,'ProductDetails')){
	   $module_type = 'moduel_productdetails';
	}
	if(get_file_address($tabname,$tabname.'DetailFieldsHtml')){
	   $module_type = 'moduel_tabdetails';
	}
	$focus = CRMEntity::getInstance($tabname);
	$modulefields = $focus->fieldobj->getModuleFields();
	if(!empty($modulefields)){
		foreach($modulefields as $fieldname => $field){
			$blockid = $field->getBlockId();
			$uitype = $field->getUIType();
			$savedatabase = $field->getSaveDataBase();
			$uitype = $field->getUIType();
			$tablename = $field->getTableName();
			$fieldlabel = $field->getFieldLabelKey();
			$columnname = $field->getColumnName();
			if($savedatabase == 'no'){
				continue;
			}
			if(in_array($uitype,array('1109','1108','28','69'))){
				continue;
			}
			if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
				continue;
			}
			$fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname);
		}
	}
	$fieldsel = ' <option>'.getFixedLabel('PLEASESELECTFIELD').'</option>';
	if(!empty($fields)){
		foreach($fields as $blockid => $fieldinfo){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
			foreach($fieldinfo as $columnname => $arr){
				$fieldsel .='<option value="[var.'.$arr[0].'_'.$columnname.'_'.$arr[2].']">'.$arr[1].'</option>';
			}
			$fieldsel .= '</optgroup>';
			
		}
	}
	$detail_fields = [];
	if($module_type == 'moduel_productdetails'){
		crm_load_class_file("ProductDetails",'include/ProductDetails');
    	$productDetails=ProductDetails::getInstance($tabname);
    	$productmoduleFields=$productDetails->getModuleFields();
		if(!empty($productmoduleFields)){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.getTranstab('Products').'">';
			foreach($productmoduleFields as $colname => $field){
				$fieldlabel = $field->getFieldLabelKey();
				$tablename = $field->getTableName();
				if($focus->Detail_table_scf == $tablename){
					$fieldsel .='<option value="[var.productdetails_'.$colname.'_products]">'.$fieldlabel.'</option>';
				}else{
					$fieldsel .='<option value="[var.productdetailscf_'.$colname.'_products]">'.$fieldlabel.'</option>';
				}
				
			}
			$fieldsel .= '</optgroup>';
		}
	}
	if($module_type == 'moduel_tabdetails'){
		crm_load_class_file("TabDetailFields",'include/TabDetailFields');
    	$TabDetailFields = new TabDetailFields($tabid);
		$tabDetailFields = $TabDetailFields->getTabDetailFields();
		if(!empty($tabDetailFields)){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.getTranstab($tabname).getFixedLabel('DETAIL').'">';
			foreach($tabDetailFields as $colname => $field){
				$fieldlabel = $field->getFieldLabelKey();
				$fieldsel .='<option value="[var.'.strtolower($tabname).'details_'.$colname.'_'.strtolower($tabname).']">'.$fieldlabel.'</option>';
			}
			$fieldsel .= '</optgroup>';
		}
	}
	return $fieldsel;
}
//获取模块单据头字段(不包括分录)
function getModuleMainField($tabid){
    global $adb;
    $tabname=getTabname($tabid);
    $blocks = getBlockLabels($tabid);
    $focus = CRMEntity::getInstance($tabname);
    $modulefields = $focus->fieldobj->getModuleFields();
    if(!empty($modulefields)){
        foreach($modulefields as $fieldname => $field){
            $blockid = $field->getBlockId();
            $uitype = $field->getUIType();
            $savedatabase = $field->getSaveDataBase();
            $uitype = $field->getUIType();
            $tablename = $field->getTableName();
            $fieldlabel = $field->getFieldLabelKey();
            $columnname = $field->getColumnName();
            if($savedatabase == 'no'){
                continue;
            }
            if(in_array($uitype,array('1109','1108','28','69'))){
                continue;
            }
            /*if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
                continue;
            }*/

            if ($field->getBigType() == 'reference') {
                $tmp_module = cls_module_uitype::getUitypeModule($uitype);
                $entityarray = getEntitynameInfo(getTabid($tmp_module));
//                $entity_field_info = getEntityFieldNames('Accounts');
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel.'(fldid)',"2"=>$tabname);
                $fields[$blockid][$entityarray['fieldname']]=array("0"=>$entityarray['tablename'],"1"=>$fieldlabel.'(fldname)',"2"=>$entityarray['modulename']);
            }
            elseif ($field->getBigType() == 'selectsource') {
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel.'(fldname)',"2"=>$tabname);
                $fields[$blockid][$columnname.'_id']=array("0"=>$tablename,"1"=>$fieldlabel.'(fldid)',"2"=>$tabname);
            }
            else{
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname);
            }
        }
    }

    $fieldsel = ' <option>'.getFixedLabel('PLEASESELECTFIELD').'</option>';
    if(!empty($fields)){
        foreach($fields as $blockid => $fieldinfo){
            $fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
            foreach($fieldinfo as $columnname => $arr){
                $fieldsel .='<option value="[var.'.$arr[0].'_'.$columnname.'_'.$arr[2].']">'.$arr[1].'</option>';
            }
            $fieldsel .= '</optgroup>';

        }
    }

    return $fieldsel;
}
function getBlockLabels($tabid){
	global $adb,$current_language,$current_user;
	$blocks = [];
	$languageType= getLanguageType($current_user);
	$query = "select ld_tranlabel.fieldlabel,ld_blocks.blockid from ld_blocks 
	LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_blocks.tabid and ld_tranlabel.Relateid = ld_blocks.blockid 
	where ld_blocks.tabid= ? and languagetype = ? and ld_tranlabel.trantable = 'ld_blocks'";
	$result = $adb->pquery($query,array($tabid,$languageType));
	for($i=0;$i<$adb->num_rows($result);$i++)
	{
		$blockid = $adb->query_result($result,$i,'blockid');
		$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
		$blocks[$blockid] = $fieldlabel;
	}
	return $blocks;
}
?>