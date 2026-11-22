<?php
global  $currentModule, $theme,$current_user,$adb;
if(isset($_REQUEST['sourcemodule'])&&isset($_REQUEST['idstring'])&&$_REQUEST['Ajax']=='yes')
{
    
    $_REQUEST['rowid'] = $_REQUEST['before_row']+1;
	$_REQUEST['cashbill_currency_id'] = $_REQUEST['currency_id'];
    
    $_REQUEST['listval'] = $_REQUEST['idstring'];
    $sourceModule = $_REQUEST['sourcemodule'];
    $lineitem_ids = rtrim($_REQUEST['listval'],",");
	$lineitem_ids_arr = explode(',',$lineitem_ids);//lineitem_id
	$entitytypeid = 0;
	if(!empty($sourceModule)){
		if(get_file_address($sourceModule,'ProductDetails')){
		  $source_focus=CRMEntity::getInstance($sourceModule);
          $detailtable=$source_focus->Detail_table;
			$query = "select id,lineitem_id from $detailtable where lineitem_id in ($lineitem_ids) order by field(lineitem_id,$lineitem_ids)";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				$id = $adb->query_result($result,$i,'id');//源单id
				if($i == 0)$entitytypeid = $id;
				$entitytype_recordid[] = $id;
				$entitytype_no[] = getModuleHref($sourceModule,$id);//获取单据的超链接字段
			}
		}else{
			for($i = 0; $i<count($lineitem_ids_arr); $i++){
				if($i == 0)$entitytypeid = $lineitem_ids_arr[$i];
				$entitytype_recordid[] = $lineitem_ids_arr[$i];
				$entitytype_no[] = getModuleHref($selectSourceModuleName,$lineitem_ids_arr[$i]);
			}
		}
	}
	$entitytype_no = array_unique($entitytype_no);
	$entitytype_no = set_array_unique($entitytype_no); 
    
    
    $entitytypeids = implode(',',$entitytype_recordid);
    crm_load_class_file('cls_CashBill_EntityHtml','modules/CashBill/EntityData');
    $obj_entity=new cls_CashBill_EntityHtml('0',$entitytypeids,$sourceModule);
    $obj_entity->Detailobj->frommdouleFocus = $productdetail_fromFocus;
    $obj_entity->Detailobj->productdetail_mode = $productdetail_mode;
    $obj_entity->Detailobj->entitytypeids = $entitytypeids;
	$entitytype_recordid=array_unique($entitytype_recordid);
    
    
    $tabDetailFieldObj = $obj_entity->Detailobj->DetailsHtmlobj->tabDetailFieldData;
    $TabDetailFieldsHtmlTdObj = $obj_entity->Detailobj->DetailsHtmlobj->TabDetailFieldsHtmlTd;
	
    $selectSourcedata = $tabDetailFieldObj->getTabDetailHtmlContentDataSelectSource($entitytypeids,$sourceModule);
    $source_arr = array();
    //对获取到的数据进行处理
    $tabPresenceDetailFields = $tabDetailFieldObj->tabPresenceDetailFields;
    foreach($selectSourcedata as $index => $column_value_arr){
        $tmp = array();
        foreach($column_value_arr as $columnname=>$columnvalue){
            
            $detailfieldobj = $tabDetailFieldObj->TabDetailFields->getFieldInfoobjBykey('columnname',$columnname);
            
            if(empty($detailfieldobj)){
                continue;
            }
            $typeofdata=$detailfieldobj->getTypeOfData();
            //zkt 20221109 XUQIU1000804 单据头和单据分录“金额货币”类型的字段允许自定义小数位数
            $typeofdata_decimal=2;//获取typeofdata中的小数位数
            $typeofdata_decimal=$detailfieldobj->gettypeofdata_decmail();
            //单据头和单据分录“金额货币”类型字段根据typeofdata取值，其他的仍默认为2
            if(!$detailfieldobj->isAmountorCurrencyField()||$typeofdata_decimal == ''){
                $typeofdata_decimal = 2;
            }
            
            $values = $TabDetailFieldsHtmlTdObj->getColumnValue($detailfieldobj,$columnname,$columnvalue,SHOW_EDITVIEW);
            $value = $values['value'];
			$rawValue = $values['rawvalue'];
            if($columnname == 'amount'){
				if($column_value_arr['currency_id'] != $_REQUEST['currency_id']){
					if($_REQUEST['currency_id'] == 1){
						$value = $rawValue = sprintf('%.'.$typeofdata_decimal.'f', $value/$column_value_arr['conversion_rate']);
					}else{
						$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
						$conversion_rate = $currencyobj->getCurrencyRate();
						$value = $rawValue = sprintf('%.'.$typeofdata_decimal.'f', $value/$column_value_arr['conversion_rate']*$conversion_rate);
					}
				}
			}
			
            $tmp[$columnname] = $rawValue;
            if($detailfieldobj->getEdit_Permission()==1||$detailfieldobj->getEdit_Permission()==3){
            //不可编辑字段
                $spancolumnvalue = $columnvalue;
                if($detailfieldobj->getBigType() == 'entitytype'||$detailfieldobj->getParentBigType() == 'entitytype'){
    		  	      if(!empty($rawValue))
             	      {
             	           $value = getTranstab($rawValue);
             	      }
                }
                //zkt 20230711 BUG0069379  创建收款单，选择源单为收款计划时，收款计划所关联的合同信息带不出来
                else if($detailfieldobj->getFieldType() == 'Reference'){
                    $tmp[$columnname.'_name'] = $value;
                }
            	$tmp['span_'.$columnname] = $value;
            }
            else{
            //可编辑字段
                if($detailfieldobj->getFieldType() == 'Reference'){
                   $tmp['name_'.$columnname] = $value;
                }
                else if($detailfieldobj->isAmountorCurrencyField()){
                    $tmp[$columnname] = $value;
                }
            }
        }
        $source_arr[] = $tmp;
    }
    @ob_clean();
    @ob_flush();
	$jsonentity = Zend_Json::encode($source_arr);
    
    
    echo implode(',', $entitytype_no)."$$$$###$$$$".implode(',',$entitytype_recordid).'$$$$###$$$$'.$jsonentity;
	exit();
}


?>