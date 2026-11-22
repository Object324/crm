<?php


class CustomView_Special
{
    
    //获取分类高级查询 - 明细字段信息
   static function getServiceChargeDetail($module,$columnname)
    {
        $module='ServiceCharge';
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
    	$tabid = getTabid($module);
    	$focus = CRMEntity::getInstance($module);
        crm_load_class_file('ProductDetails','include/ProductDetails');
        crm_load_class_file('ProductDetails_ServiceCharge','include/ProductDetails');
    	$productdetails = new ProductDetails_ServiceCharge($module,$languageType);
       
    	$productdetail_fields = $productdetails->setProductToolFields();
    	foreach($productdetail_fields as $fieldname => $field){
    		$selected = "";
    		if(!empty($field)){
    			$typeofdata = explode('~',$field->getTypeOfData());
    	
    				$column = $field->getTableName() . ':' . $field->getColumnName() . ':' . $field->getColumnName() . ':' . 'Products_fieldlabel' .':' . $typeofdata[0];
    			
    			if(!empty($columnname) && in_array($column,$columnname)){
    				$selected = "selected = selected";
    			}
    			$TabDetailsFieldsInfo[] = array(
    				'value'=> $column,
    				'text' => $field->getfieldLabel(),
    				'selected' => $selected,
    			);
    		}
    	}
        return $TabDetailsFieldsInfo;
    }
     static  function getAccountContact($module,$columnname)
    {
        global $adb,$current_user;
    
       //35893:设置-系统设置-参数设置-自动提醒设置,选择模块“客户”新建，数据范围，高级查询，筛选字段里面没有联系人模块的字段，可以参考客户模块高级查找是有的
	    $fieldobj=Field::getInstance($module,$adb);
        
		$modulefields=$fieldobj->getModuleFields();
		foreach($modulefields as $key => $productfield){
			if(!empty($productfield)){
				$fieldtablename = $productfield->getTableName();
				$fieldcolname = $productfield->getColumnName();
				$fieldname = $productfield->getColumnName();
				$fieldtype = $productfield->getTypeOfData();
				$fieldlabel = $productfield->getFieldLabel();
				$uitype = $productfield->getUIType();
                    if($productfield->getUIType()==69)
                    {
                        continue;
                    }
					$fieldtype = explode("~", $fieldtype);
					$column = $fieldtablename . ':' . $fieldcolname . ':' . $fieldname . ':' . 'contacts_fieldlabel' .':' . $fieldtype[0];
					if(!empty($columnname) && in_array($column,$columnname))
					{
						$selected = "selected = selected";
					}
					$ProductInfo[$key] = array(
						'value'=> $column,
						'text' => $fieldlabel,
						'selected' => $selected,
						'uitype' => $uitype,
					);
				
			}
		}
        return $ProductInfo;
    }
    //获取分类高级查询 - 产品字段信息
   static  function getProductSearchCustom($module,$columnname)
    {
        global $adb,$current_user;
        crm_load_class_file('ProductDetails','include/ProductDetails');
		$productDetails=ProductDetails::getInstance($module,$languageType);
        $focus=CRMEntity::getInstance($module);
        $detailtable=$focus->Detail_table;
        $detailtablescf=$focus->Detail_table_scf;
		$modulefields=$productDetails->getModuleFields();
		foreach($modulefields as $key => $productfield){
			if(!empty($productfield)){
				$fieldtablename = $productfield->getTableName();
				if(strtolower($fieldtablename) == 'ld_products' || strtolower($fieldtablename)=='ld_productcf' 
                || strtolower($fieldtablename) == $detailtable || 
                    strtolower($fieldtablename) == $detailtablescf){
					$fieldcolname = $productfield->getColumnName();
					//if($fieldcolname == 'entitytype' || $fieldcolname == 'entitytypeid')continue;//跳过源单类型及源单。
					$fieldname = $productfield->getColumnName();
					$fieldtype = $productfield->getTypeOfData();
					$fieldlabel = $productfield->getFieldLabel();
                    //edit:can 20210423 45628
                    if($productfield->getUIType()==69 || ($productfield->getSaveDataBase() == 'no'&&!isProductTable($productfield->getTableName(),$module)))
                    {
                        continue;
                    }
					$fieldtype = explode("~", $fieldtype);
					$column = $fieldtablename . ':' . $fieldcolname . ':' . $fieldname . ':' . 'Products_fieldlabel' .':' . $fieldtype[0];
					if(!empty($columnname) && in_array($column,$columnname))
					{
						$selected = "selected = selected";
					}
					$ProductInfo[$key] = array(
						'value'=> $column,
						'text' => $fieldlabel,
						'selected' => $selected,
					);
				}
			}
		}
        return $ProductInfo;
    }
    //获取分类高级查询 - 明细字段信息
   static function getFinacialSearchCustom($module,$columnname)
    {
        global $adb,$current_user;
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
    	$tabid = getTabid($module);
    	$focus = CRMEntity::getInstance($module);
    	$TabDetailFields = new TabDetailFields($tabid);
    	$tabDetailFields = $TabDetailFields->getTabPresenceDetailFields();
    	foreach($tabDetailFields as $fieldname => $field){
    		$selected = "";
    		if(!empty($field)){
    			$typeofdata = explode('~',$field->getTypeOfData());
				$savedatabase = $field->getSaveDataBase();
				if($savedatabase == 'no'){
					continue;
				}
    			if(strtolower($field->getTableName()) == strtolower($focus->Detail_table) || strtolower($field->getTableName()) == strtolower($focus->Detail_table_scf)){
    				$column = $field->getTableName() . ':' . $field->getColumnName() . ':' . $field->getColumnName() . ':' . 'Products_fieldlabel' .':' . $typeofdata[0];
    			}
                else
                {
                    continue;
                }
    			if(!empty($columnname) && in_array($column,$columnname)){
    				$selected = "selected = selected";
    			}
    			$TabDetailsFieldsInfo[] = array(
    				'value'=> $column,
    				'text' => $field->getfieldLabel(),
    				'selected' => $selected,
    			);
    		}
    	}
        return $TabDetailsFieldsInfo;
    }
    
    //获取模块的可视分类信息
    public static function getModuleSearchCustom($module,$columnname)
    {
        //todo:此处代码可以调用include/productdetails/productdetails.php,edit:can
        global $adb,$currentModule,$current_user;
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        $sqlField = "select tablename,columnname,ld_field.uitype,ld_field.fieldname,typeofdata,case when ifnull(ld_tranlabel.fieldlabel,'')='' then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
        from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
         where presence in (0,2) and ld_tranlabel.languagetype=? and ld_tranlabel.trantable=? and ld_tranlabel.tabid=? and ld_field.tabid = ?";

        if($currentModule == 'ServiceCharge' && $module == 'ServiceContracts')
        {
            $sqlField.= ' and ld_field.uitype not in(52,53,70,73,57)';
            $column = 'ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D';
            if(!empty($columnname) && in_array($column,$columnname))
            {
                $selected = "selected = selected";
            }
            //zkt 0047098: （https://81mis.com/kfbcrm [^]）服务收费管理，管理分类弹窗中，设置条件选择字段下拉选项“服务合同信息”区块多了一个“服务到期日”字段
            //服务合同信息->服务到期日显示
            /*$ProductInfo[0] = array(
                'value'=> $column,
                'text' => getFixedLabel('PERIODOFSERVICEEND'),
                'selected' => $selected,
				'uitype' => 5
            );*/
            $stdcriteria_list['ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D'] = getFixedLabel('PERIODOFSERVICEEND');
        }
        $resField = $adb->pquery($sqlField, array($languageType,'ld_field',getTabid($module),getTabid($module)));
        for($i = 1; $i<=$adb->num_rows($resField); $i++)
        {
            $selected = "";
            $fieldtablename = $adb->query_result($resField, $i - 1, "tablename");
            $fieldcolname = $adb->query_result($resField, $i -1, "columnname");
            $fieldname = $adb->query_result($resField, $i - 1, "fieldname");
            $fieldtype = $adb->query_result($resField, $i - 1, "typeofdata");
			$uitype = $adb->query_result($resField, $i - 1, "uitype");
            $fieldtype = explode("~", $fieldtype);
            switch($fieldtype[0])
            {
               // case DT:
                //    $fieldtypeofdata = 'D';
                 //   break;
                case "NN":
                    $fieldtypeofdata = 'N';
                    break;
                default:
                    $fieldtypeofdata = $fieldtype[0];
            }

            $fieldlabel = $adb->query_result($resField, $i - 1, "fieldlabel");
            $column = $fieldtablename . ':' . $fieldcolname . ':' . $fieldname . ':' . 'Products_' .
            'fieldlabel' . ':' . $fieldtypeofdata;
                $columncheck = $fieldtablename . ':' . $fieldcolname;
            

            if(!empty($columnname) && in_array($column,$columnname) )
            {
                $selected = "selected = selected";
            }
            $ProductInfo[$i] = array(
                'value'=> $column,
                'text' => $fieldlabel,
                'selected' => $selected,
				'uitype' => $uitype,
                'm_content' => '',
                'm_content_end' => ''
            );
        }
        return $ProductInfo;
    }

    static function getStdCriteriaByModule($module,$customviewobj) {
		global $adb,$currentModule;
      
       $fieldobj=Field::getInstance($module,$adb);
       $fieldModules=$fieldobj->getModuleFields();
        $module_info = $customviewobj->getCustomViewModuleInfo($module);
         
		foreach ($customviewobj->module_list[$module] as $key => $blockid) {
			$blockids[] = $blockid;
		}
       foreach($fieldModules as $fieldname=>$fieldinfo)
       {  
                $uitype=$fieldinfo->getUIType();
                $blockid=$fieldinfo->getBlockId();
                if(in_array($blockid,$blockids)&&(in_array($uitype,array(5,6,23,70,86,256))))
                {
                    	$fieldtablename = $fieldinfo->getTableName();
			          $fieldcolname = $fieldinfo->getColumnName();
                        $fieldlabel =$fieldinfo->getfieldLabel();
			
        			$fieldlabel1 = str_replace(" ", "_", $fieldlabel);
                    $optionvalue = $fieldtablename . ":" . $fieldcolname . ":" . $fieldname . ":" . $module . "_fieldlabel" ;
        			$stdcriteria_list[$optionvalue] = $fieldlabel;
                }
               
       }
	
		return $stdcriteria_list;
	}
  
    static 	function getCustomViewModuleInfo($module,$customviewobj) {
		global $adb,$current_user;
		global $current_language;
		//$current_mod_strings = return_specified_module_language($current_language, $module);
        require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.'.php');
		$block_info = Array();
		$modules_list = explode(",", $module);
             
		if ($module == "Calendar") {
			//$module = "Calendar','Events";
			//$modules_list = array('Calendar', 'Events');
            $module = "Events";
			$modules_list = array('Events');
		}

		// Tabid mapped to the list of block labels to be skipped for that tab.
		$skipBlocksList = array(
			getTabid('Contacts') => array('LBL_IMAGE_INFORMATION'),
			getTabid('HelpDesk') => array('LBL_COMMENTS'),
			getTabid('Products') => array('LBL_IMAGE_INFORMATION'),
			getTabid('Faq') => array('LBL_COMMENT_INFORMATION'),
			getTabid('Quotes') => array('LBL_RELATED_PRODUCTS'),
			getTabid('PurchaseOrder') => array('LBL_RELATED_PRODUCTS'),
			getTabid('SalesOrder') => array('LBL_RELATED_PRODUCTS'),
			getTabid('Invoice') => array('LBL_RELATED_PRODUCTS')
		);
       
        $cachekey = 'cache_modulelist_getCustomViewModuleInfo_'.$module.'getCustomViewModuleInfo' ;
        $cachemodulelistview = CacheDirectory($cachekey,'customview');
        if($cachemodulelistview)
        {
           
            $customviewobj->module_list=$cachemodulelistview;
            return $cachemodulelistview;
        }
            
          $tabid=getTabid($module);
            
		$Sql = "select distinct block,ld_field.tabid,name,case when ifnull(ld_tranlabel.fieldlabel,'')='' then ld_blocks.blocklabel else ld_tranlabel.fieldlabel end as blocklabel 
        from ld_field inner join ld_blocks on ld_blocks.blockid=ld_field.block 
        inner join ld_tab on ld_tab.tabid=ld_field.tabid 
        inner join ld_tranlabel on ld_tranlabel.relateid=ld_blocks.blockid
        where ld_tranlabel.trantable=? and languageType=? and  displaytype != 3  and ld_tab.name in (" . generateQuestionMarks($modules_list) . ") and ld_field.presence in (0,2) and uitype!=10 and uitype!=69";
	   
    	//客户高级查询 内 不显示客户的首要联系人字段信息
		if($module == 'Accounts')
			$Sql .= " and ld_blocks.blocklabel != 'LBL_ACCOUNT_PRIMARYCONTACT'";
		$Sql .= ' order by block';
		//LBL_ACCOUNT_PRIMARYCONTACT
        //print_r(array($modules_list,'ld_blocks',$languageType));
    	$result = $adb->pquery($Sql, array('ld_blocks',$languageType,$modules_list));
		if ($module == "Events")
			$module = "Calendar";

		$pre_block_label = '';
     
		while ($block_result = $adb->fetch_array($result)) {
		      
			$block_label = $block_result['blocklabel'];
			$tabid = $block_result['tabid'];
           
            
			// Skip certain blocks of certain modules
			if (array_key_exists($tabid, $skipBlocksList) && in_array($block_label, $skipBlocksList[$tabid]))
				continue;
            
			if (trim($block_label) == '') {
				$block_info[$pre_block_label] = $block_info[$pre_block_label] . "," . $block_result['block'];
			} else {
			        
                        $lan_block_label=$block_label;  
    
    				if (isset($block_info[$lan_block_label]) && $block_info[$lan_block_label] != '') {
    					$block_info[$lan_block_label] = $block_info[$lan_block_label] . "," . $block_result['block'];
    				} else {
    					$block_info[$lan_block_label] = $block_result['block'];
    				}
			}
			$pre_block_label = $lan_block_label;
		}
		$customviewobj->module_list[$module] = $block_info;
        CacheDirectory($cachekey,'customview',$customviewobj->module_list);
		return $customviewobj->module_list;
	}
    
  
    
   /**
     * edit:can
     * date:20140422
     * reason:视图手机开发
     * */
      static function jsongetCustomViewCombo2($viewid,$thismodulename,$customviewobj, $markselected = true, $popup='') {
		global $adb, $current_user;
		$tabid = getTabid($customviewobj->customviewmodule);

		require(globalStatic::$root_directory.'user_privileges/user_privileges_' . $current_user->id . '.php');

		$shtml_user = '';
		$shtml_pending = '';
		$shtml_public = '';
        $shtml_default=array();
        $shtml_others=array();
      
        $shtml_others[]=array('title'=>'我的'.getTranstab($thismodulename),'viewname'=>'SmOwner_Search_Me');
		$selected = 'selected';
		if ($markselected == false)
			$selected = '';

		$ssql = "select ld_customview.*, ld_users.first_name,ld_users.last_name from ld_customview inner join ld_tab on ld_tab.name = ld_customview.entitytype
					left join ld_users on ld_customview.userid = ld_users.id ";
		$ssql .= " where ld_tab.tabid=?";
        if($customviewobj->customviewmodule=='Accounts'||$customviewobj->customviewmodule=='Leads')
        {
             /*
             $status=getAccount_set('status');//是否启用公海客户
             if($status==1)//没有启用公海客户,数据分类只获取“全部"页签
             {
                $ssql.=" and customcategory='AllACCOUNT' ";   
             }*/
             //$ssql.=" and customcategory='AllACCOUNT' ";  
             $accounttype = $_REQUEST['accounttype'];
			 if(empty($accounttype) || $accounttype == 'DEFAULTALLACCOUNT' || $accounttype == 'COMMONACCOUNT'){
				$accounttype = 'ALLACCOUNT';
			 }
             $ssql.=" and customcategory='$accounttype'";
			crm_load_class_file('cls_Public'.$customviewobj->customviewmodule, 'modules/'.$customviewobj->customviewmodule);
			$className = 'cls_Public'.$customviewobj->customviewmodule;
			$cls_PublicAccounts = new $className($currentModule);
			$public_account = $cls_PublicAccounts->getPublicAccountConfig();
			if($public_account['status'] == 'yes' && $accounttype != 'ALLACCOUNT'){
				
				if(empty($_REQUEST['pool_id'])){
					$pool_all  = array_keys($public_account['public_account_pool']);
					if(!empty($pool_all[0]))
						$ssql .= " and ld_customview.pool_id = " . $pool_all[0];
				}else{
					$ssql .= " and ld_customview.pool_id = " . $_REQUEST['pool_id'];
				}
				
			}
        }
		$sparams = array($tabid);

		//zkt 20220930 BUG0057260（V8.4.6.6.10）移动端微信小程序：客户分类与PC端不一致。
        //if ($is_admin == false) {
			$ssql .= " and (ld_customview.status=0 or ld_customview.userid = ? or ld_customview.status = 3 ) ";
			array_push($sparams, $current_user->id);
		//}
		$ssql .= " ORDER BY sequence";

        $result = $adb->pquery($ssql, $sparams);
		while ($cvrow = $adb->fetch_array($result)) {
			if ($cvrow['viewname'] == 'All') {
				$cvrow['viewname'] = getFixedLabel('ALL');
			}
            if($cvrow['cvid']==$viewid)
            {
                 $customviewobj->pageWidthPercent=$cvrow['pagewidthpercent'];
            }
			$option = '';
			$viewname = $cvrow['viewname'];
			if ($cvrow['status'] == CV_STATUS_DEFAULT || $cvrow['userid'] == $current_user->id) {
				$disp_viewname = $viewname;
			} else {
				//$userName = getFullNameFromArray('Users', $cvrow);
              
                $disp_viewname = $viewname;
			}
			if ($cvrow['setdefault'] == 1 && $viewid == '') 
            {
    			
                 $customviewobj->setdefaultviewid = $cvrow['cvid'];
			} 
            elseif ($cvrow['cvid'] == $viewid) 
            {
    		
				$customviewobj->setdefaultviewid = $cvrow['cvid'];
			}
              
             $shtml_others[]=array('title'=>$disp_viewname,'viewname'=>$cvrow['cvid']);
            

		}
		$shtml = $shtml_default;
		if ($is_admin == true)
			$shtml .= $shtml_pending;
          
		$shtml = $shtml_others;
        
		return $shtml;
	}
    static function getAdvCompator($comparator, $value, $datatype,$customviewobj)
    {
        	global $adb, $default_charset;
		$value = html_entity_decode(trim($value), ENT_QUOTES, $default_charset);
		$value = $adb->sql_escape_string($value);

		if ($comparator == "e") {
			if (trim($value) == "NULL") {
				$rtvalue = " is NULL";
			} elseif (trim($value) != "") {
				$rtvalue = " = " . $adb->quote($value);
			} elseif (trim($value) == "" && ($datatype == "V" || $datatype == "E")) {
				$rtvalue = " = " . $adb->quote($value);
			} else {
				$rtvalue = " is NULL";
			}
		}
		if ($comparator == "n") {
			if (trim($value) == "NULL") {
				$rtvalue = " is NOT NULL";
			} elseif (trim($value) != "") {
				$rtvalue = " <> " . $adb->quote($value);
			} elseif (trim($value) == "" && $datatype == "V") {
				$rtvalue = " <> " . $adb->quote($value);
			} elseif (trim($value) == "" && $datatype == "E") {
				$rtvalue = " <> " . $adb->quote($value);
			} else {
				$rtvalue = " is NOT NULL";
			}
		}
		if ($comparator == "s") {
			if (trim($value) == "" && ($datatype == "V" || $datatype == "E")) {
				$rtvalue = " like '" . formatForSqlLike($value, 3) . "'";
			} else {
				$rtvalue = " like '" . formatForSqlLike($value, 2) . "'";
			}
		}
		if ($comparator == "ew") {
			if (trim($value) == "" && ($datatype == "V" || $datatype == "E")) {
				$rtvalue = " like '" . formatForSqlLike($value, 3) . "'";
			} else {
				$rtvalue = " like '" . formatForSqlLike($value, 1) . "'";
			}
		}
		if ($comparator == "c") {
			if (trim($value) == "" && ($datatype == "V" || $datatype == "E")) {
				$rtvalue = " like '" . formatForSqlLike($value, 3) . "'";
			} else {
				$rtvalue = " like '" . formatForSqlLike($value) . "'";
			}
		}
		if ($comparator == "k") {
			if (trim($value) == "" && ($datatype == "V" || $datatype == "E")) {
				$rtvalue = " not like ''";
			} else {
				$rtvalue = " not like '" . formatForSqlLike($value) . "'";
			}
		}
		if ($comparator == "l") {
			$rtvalue = " < " . $adb->quote($value);
		}
		if ($comparator == "g") {
			$rtvalue = " > " . $adb->quote($value);
		}
		if ($comparator == "m") {
			$rtvalue = " <= " . $adb->quote($value);
		}
		if ($comparator == "h") {
			$rtvalue = " >= " . $adb->quote($value);
		}
		if ($comparator == "b") {
			$rtvalue = " < " . $adb->quote($value);
		}
		if ($comparator == "a") {
			$rtvalue = " > " . $adb->quote($value);
		}

		return $rtvalue;
    }
    /**
     * 目前只用日程管理用到
     *
    static function getModifiedCvListQuery($listquery,$module,$viewid,$customviewobj)
    {
         global $current_user;
		if ($viewid != "" && $listquery != "") {

			$listviewquery = substr($listquery, strpos($listquery, 'FROM'), strlen($listquery));
			if ($module == "Calendar" || $module == "Emails") {
				$query = "select distinct " . $customviewobj->getCvColumnListSQL($viewid) . ", ld_activity.activityid, ld_activity.activitytype as type, ld_activity.priority, case when (ld_activity.status not like '') then ld_activity.status else ld_activity.eventstatus end as status, ld_activity.activityid as crmid,ld_contactdetails.contactid " . $listviewquery;
	
            	if ($module == "Calendar")
					$query = str_replace('ld_seactivityrel.crmid,', '', $query);
              
			}else if ($module == "Documents") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid,ld_notes.* " . $listviewquery;
			} else if ($module == "Products") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid,ld_products.* " . $listviewquery;
			} else if ($module == "Vendors") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid " . $listviewquery;
			} else if ($module == "PriceBooks") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid " . $listviewquery;
			} else if ($module == "Faq") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid " . $listviewquery;
			} else if ($module == "Potentials" || $module == "Contacts") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid,ld_account.accountid " . $listviewquery;
			} else if ($module == "Invoice" || $module == "SalesOrder" || $module == "Quotes") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid,ld_contactdetails.contactid,ld_account.accountid " . $listviewquery;
			} else if ($module == "PurchaseOrder") {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid,ld_contactdetails.contactid " . $listviewquery;
			}
            else if($module=="ContactRecords")
            {
                $query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid " . $listviewquery;
            }
             else {
				$query = "select " . $customviewobj->getCvColumnListSQL($viewid) . " ,ld_crmentity.crmid " . $listviewquery;
			}
			$stdfiltersql = $customviewobj->getCVStdFilterSQL($viewid);
             
			$advfiltersql = $customviewobj->getCVAdvFilterSQL($viewid);
			if (isset($stdfiltersql) && $stdfiltersql != '') {
				$query .= ' and ' . $stdfiltersql;
			}
			if (isset($advfiltersql) && $advfiltersql != '') {
				$query .= ' and ' . $advfiltersql;
			}
		}
		return $query;
    } */
}
?>