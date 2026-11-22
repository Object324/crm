<?php
/* creator:gyq_13 explain:EditView.php分离出方法 date:2016.7.4 */
class CustomView_Columnlist{

    public static $sti_module;

    public static function getByModule_ColumnsHTML($module,$columnslist,$selected="") {
		global $mod_strings;

		$columnsList = self::getByModule_ColumnsList($module,$columnslist,$selected);
        
        /* 日程模板条件判断 */
        if(self::$sti_module == 'Calendar'){
            $adf_column = null;
        }else{
            $adf_column = self::getCvadfilter($_REQUEST['record']);
        }
		$deployarray=getSys_deploy(325);	//服务收费列表显示联系人还是合同明细 
		$servicecharge_list_show = strtolower($deployarray['deploy_value']);
		/**
		 * edit:chj
		 * date:2014-1-12
		 * reason: 模块，产品明细 查询条件显示产品明细内容
		 **/
		if(get_file_address($module,'ProductDetails'))
		{
			crm_load_class_file('CustomView_Special','modules/CustomView');
            if($module=='ServiceCharge')
            {
				if($servicecharge_list_show == 'servicecontracts'){
					if(is_array($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]))
					{
						$columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]
						,CustomView_Special::getServiceChargeDetail($module,$adf_column));
						
					}
					else
					$columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getServiceChargeDetail($module,$adf_column);
				}
            }
            else
			{
			 
                if(is_array($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]))
                {
                    $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('Products').getFixedLabel('INFORMATION')]
                    ,CustomView_Special::getServiceChargeDetail($module,$adf_column));
                    
                }
                else
			     $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getProductSearchCustom($module,$adf_column);
            }
		}
		//除产品明细模块意外的名字模块
		if(get_file_address($module,$module.'DetailFieldsHtml'))
		{
			crm_load_class_file('CustomView_Special','modules/CustomView');
			$columnsList[getTranstab($module).getFixedLabel('INFORMATION')] = CustomView_Special::getFinacialSearchCustom($module,$adf_column);
		}
		if(get_file_address($module,'ProductDetails') && $module == 'ServiceCharge')
		{
			if($servicecharge_list_show == 'servicecontracts'){
				crm_load_class_file('CustomView_Special','modules/CustomView');
				$columnsList[getTranstab('ServiceContracts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('ServiceContracts',$adf_column);
			}else{
				crm_load_class_file('CustomView_Special','modules/CustomView');
				$columnsList[getTranstab('Contacts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('Contacts',$adf_column);
			}
		}
		/**
		 * edit:chj
		 * date:2014-12-31
		 * reason: 客户模块  高级查询里显示联系人信息，去除首要联系人信息
		 **/
		//duan 20230710 BUG0067317:联系人模块不启用时，客户模块的高级查询不应该显示联系人的字段
		if(get_file_address($module,'ContactsDetails')&& vtlib_isModuleActive('Contacts'))
		{
			crm_load_class_file('CustomView_Special','modules/CustomView');
			$columnsList[getTranstab('Contacts').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('Contacts',$adf_column);
		}
		/**
		 * edit:chj
		 * date:2014-12-31
		 * reason: 供应商模块  高级查询里显示供应商联系人信息
		 **/
        //duan 20230710 BUG0067317:供应商联系人模块不启用时，供应商模块的高级查询不应该显示供应商联系人的字段
		if(get_file_address($module,'VendorsDetails')&& vtlib_isModuleActive('VendorContact'))
		{
			crm_load_class_file('CustomView_Special','modules/CustomView');
            if(is_array($columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]))
            {
                $columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]=array_merge($columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')]
                            ,CustomView_Special::getModuleSearchCustom('VendorContact',$adf_column));
                            
            }
            else
			     $columnsList[getTranstab('VendorContact').getFixedLabel('INFORMATION')] = CustomView_Special::getModuleSearchCustom('VendorContact',$adf_column);
		}
		return self::generateSelectColumnsHTML($columnsList,$module);
	}

	protected static function generateSelectColumnsHTML($columnsList, $module) {
		$shtml = '';

		foreach($columnsList as $blocklabel=>$blockcolumns) {
			$shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
			foreach($blockcolumns as $columninfo) {
				$shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
			}
		}
		return $shtml;
	}

    protected static function getByModule_ColumnsList($module,$columnslist,$selected="") {
        global $oCustomView, $current_language,$theme;
        global $app_list_strings;
        global $adb;
        $advfilter = array();
        //$mod_strings = return_specified_module_language($current_language,$module);

        /*
        edit by LD Can
        date:2013026
        reasion:3268: 页面布局修改字段名称之后，导致已创建的视图中“选择字段”显示异常

        */
        $check_dup = Array();

        $focus=CRMEntity::getInstance($module);
        foreach($oCustomView->module_list[$module] as $key=>$value)
        {
            $advfilter = array();
            $label = $key;
            if(isset($columnslist[$module][$key]))
            {
                foreach($columnslist[$module][$key] as $field=>$fieldlabel)
                {
                    if(!in_array($field,$check_dup))
                    {
                            
                            $fields=explode(':',$field);
							$arrselected=explode(":",$selected);
                         
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$fields[1]);
                            if(!$fieldinfo||$fieldinfo->getFieldName()=='')
                            {
                                continue;
                            }
                            if($fieldinfo->getSaveDataBase()=='no')
                            {
                                continue;
                            }
                            if($fieldinfo&&($fieldinfo->getUIType()==1109||$fieldinfo->getUIType()==10||$fieldinfo->getUIType()==69))
                            {
                                //032281: 公告>数据分类：添加附件字段查找，结果报错了。
                                continue;
                            }
							if($module == 'ServiceCharge' && $fieldinfo->getTableName() == 'ld_contactdetails')continue;
							$arrfield=explode(":",$field);
							if($arrfield[0] == '' && $arrfield[1] == ''){
								continue;
							}
                            //if($selected == $field)
							if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "selected";
                            }else
                            {
                                $advfilter_option['value'] = $field;
                                $advfilter_option['text'] = $fieldlabel;
                                $advfilter_option['selected'] = "";
                            }
                        
                        $advfilter[] = $advfilter_option;
                        $check_dup [] = $field;
                    }
                }
                if(!empty($advfilter))
                    $advfilter_out[$label]= $advfilter;
            }
        }
	return $advfilter_out;
}
 public static function getStdFilterHTML($module,$selected="")
{
    global $adb,$app_list_strings, $current_language,$app_strings,$current_user,$currentModule;
    global $oCustomView;
	$stdfilter = array();
	require_once(globalStatic::$root_directory.'include/ProductDetails/ProductDetails.php');
    for($i = 0; $i<count($module); $i++)
    {
		$result = $oCustomView->getStdCriteriaByModule($module[$i]);
		if($currentModule == 'ServiceCharge' && $module[$i] == 'ServiceContracts'){
			$fieldobj = new ProductDetails($module[$i]);
			$fieldModules=$fieldobj->getModuleFields();
			$fields_servicecontracts_end_date = $fieldModules['servicecontracts_end_date'];
			$fields_servicecontracts_start_date = $fieldModules['servicecontracts_start_date'];
			$result['ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D'] = $fields_servicecontracts_end_date->fieldLableKey;
			$result['ld_servicecontractsdetail:servicecontracts_start_date:servicecontracts_start_date:Products_fieldlabel:D'] = $fields_servicecontracts_start_date->fieldLableKey;
		}
        
        if(isset($result))
    	{
    		foreach($result as $key=>$value)
    		{
    			/**
    			 * 服务合同，创建时间和修改时间不显示在基本查询时间字段中
    			 * @reason 0015053: 服务收费管理>列表：新建数据分类，页面显示空白
    			 * @author Tujt 2015-05-19
    			 */
    			if('ServiceContracts' == $module[$i]){
    				if(stripos($key, 'ld_servicecontracts:createdtime') > -1 || stripos($key, 'ld_servicecontracts:modifiedtime') > -1){
    					continue;
    				}
    			}
    			if($value == 'Start Date & Time')
    			{
    				$value = 'Start Date';
    			}
               
				$use_module_label=getTranstab($module[$i]);

				if($key == $selected)
				{
					$filter['value'] = $key;
					
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] = 'selected';
				}else
				{
					$filter['value'] = $key;
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] ='';
				}
    			
    			$stdfilter[]=$filter;

    		}
    
    	}
    }
    return $stdfilter;
}
	public static function getAdvCriteriaHTML($selected="")
	{
		global $adv_filter_options;
        //wym 240516 XUQIU1002181 新增查询条件，属于/不属于 条件可以输入多个字段，用“，”或“,”分辨注：中英文的“，”都可以做划分
        $adv_filter_options=array_merge($adv_filter_options,array('belong'=>'','notbelong'=>''));
		foreach($adv_filter_options as $key=>$value)
		{
			if($selected == $key)
			{
				$shtml .= "<option selected value=\"".$key."\">".$value."</option>";
			}else
			{
				$shtml .= "<option value=\"".$key."\">".$value."</option>";
			}
		}

		return $shtml;
	}
	private static function getCvadfilter($cvid)
	{
		global $adb;
		$sql = "select columnname from ld_cvadvfilter where cvid = ?";
		$result = $adb->pquery($sql,array($cvid));
		for ($i=0;$i<$adb->num_rows($result);$i++) {
			$array[$i] = $adb->query_result($result, $i, "columnname");
		}
		return $array;
	}
    
}

?>