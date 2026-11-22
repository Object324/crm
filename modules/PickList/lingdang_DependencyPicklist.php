<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/


//require_once globalStatic::$root_directory. 'modules/PickList/PickListUtils.php';

crm_load_function_file("getAllPickListValues",'modules/PickList','PickListUtils');
class lingdang_DependencyPicklist {

	static function getDependentPicklistFields($module='') {
		global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
		if(empty($module)) {
			$result = $adb->pquery('SELECT DISTINCT sourcefield, targetfield, ld_picklist_dependency.tabid FROM ld_picklist_dependency LEFT JOIN ld_tab on ld_tab.tabid = ld_picklist_dependency.tabid where ld_tab.presence in(0,2) ', array());
		} else {
			$tabId = getTabid($module);
			$result = $adb->pquery('SELECT DISTINCT sourcefield, targetfield, ld_picklist_dependency.tabid FROM ld_picklist_dependency LEFT JOIN ld_tab on ld_tab.tabid = ld_picklist_dependency.tabid WHERE ld_picklist_dependency.tabid=? and ld_tab.presence in(0,2) ', array($tabId));
		}
		$noofrows = $adb->num_rows($result);

		$dependentPicklists = array();
		if($noofrows > 0) {
			$fieldlist = array();
			for($i=0; $i<$noofrows; ++$i) {
				$fieldTabId = $adb->query_result($result,$i,'tabid');
				$sourceField = $adb->query_result($result,$i,'sourcefield');
				$targetField = $adb->query_result($result,$i,'targetfield');
                 $fieldobj=Field::getInstance(getTabname($fieldTabId),$adb);
                 $sourceid=$fieldobj->getFieldInfoBykeyValue('fieldname',$sourceField,'fieldid');
                 $targetid=$fieldobj->getFieldInfoBykeyValue('fieldname',$targetField,'fieldid');
                 
				if(empty($sourceid) || empty($targetid)) {
					continue;
				}

				$fieldResult = $adb->pquery('SELECT ld_tranlabel.fieldlabel FROM ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                 WHERE fieldname = ? and languagetype=? and trantable=? and ld_field.tabid=?', array($sourceField,$languageType,'ld_field',$fieldTabId));
				$sourceFieldLabel = $adb->query_result($fieldResult,0,'fieldlabel');
        
				$fieldResult = $adb->pquery('Select ld_tranlabel.fieldlabel FROM ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                 WHERE fieldname = ? and languagetype=? and trantable=? and ld_field.tabid=?', array($targetField,$languageType,'ld_field',$fieldTabId));
				$targetFieldLabel = $adb->query_result($fieldResult,0,'fieldlabel');

				$dependentPicklists[] = array('sourcefield'=>$sourceField, 'sourcefieldlabel'=>$sourceFieldLabel,
						'targetfield'=>$targetField, 'targetfieldlabel'=>$targetFieldLabel,
						'module'=>getTabModuleName($fieldTabId));
			}
		}
		return $dependentPicklists;
	}

	static function getAvailablePicklists($module) {
		global $adb, $current_user;
		$tabId = getTabid($module);
        //中英文包
        require("user_privileges/user_language_".$current_user->id.'.php');
        if(empty($languageType))
        {
            $languageType = 'zh';
        }

		$query="select ld_tranlabel.fieldlabel,ld_field.fieldname" .
				" FROM ld_tranlabel inner join ld_field on ld_field.fieldid = ld_tranlabel.relateid AND ld_tranlabel.trantable='ld_field'" .
				" where displaytype=1 and ld_field.tabid=? and ld_field.uitype in ('15','16') " .
				" and ld_field.presence in (0,2) and ld_tranlabel.languagetype =? and 
                        ld_tranlabel.tabid =? ORDER BY ld_field.block ASC,sequence asc ";

        $result = $adb->pquery($query, array($tabId,$languageType,$tabId));
		$noofrows = $adb->num_rows($result);
        
        $fieldlist = array();
		if($noofrows > 0) {
			for($i=0; $i<$noofrows; ++$i) {
				$fieldlist[$adb->query_result($result,$i,"fieldname")] = $adb->query_result($result,$i,"fieldlabel");
			}
		}
		return $fieldlist;
	}
 

	static function deletePickListDependencies($module, $sourceField, $targetField) {
		global $adb;

		$tabId = getTabid($module);

		$adb->pquery("DELETE FROM ld_picklist_dependency WHERE tabid=? AND sourcefield=? AND targetfield=?",
				array($tabId, $sourceField, $targetField));
        //0048201: （https://81mis.com/kfbcrm [^]）销售线索级联字段设置中删除字段级联关系后，线索新建界面选择“意向产品”时仍提示级联
        unset($global_pick_list_depencyfield[$targetField]);
	}

	static function getPickListDependency($module, $sourceField, $targetField) {
		global $adb;

		$tabId = getTabid($module);
		$dependencyMap = array();
		$dependencyMap['sourcefield'] = $sourceField;
		$dependencyMap['targetfield'] = $targetField;

		$result = $adb->pquery('SELECT * FROM ld_picklist_dependency WHERE tabid=? AND sourcefield=? AND targetfield=?',
				array($tabId,$sourceField,$targetField));
		$noOfMapping = $adb->num_rows($result);

		$valueMapping = array();
		$mappedSourceValues = array();
		for($i=0; $i<$noOfMapping; ++$i) {
			$sourceValue = $adb->query_result($result, $i, 'sourcevalue');
			$targetValues = $adb->query_result($result, $i, 'targetvalues');
			$unserializedTargetValues = json_decode(html_entity_decode($targetValues));

			$mapping = array();
			$mapping['sourcevalue'] = $sourceValue;
			$mapping['targetvalues'] = $unserializedTargetValues;

			$valueMapping[$i] = $mapping ;
		}
		$dependencyMap['valuemapping'] = $valueMapping;

		return $dependencyMap;
	}
   static function getPickListDepencyFields($module)
   {
    	global $adb,$global_pick_list_depencyfield;

		$tabId = getTabid($module);

		$result = $adb->pquery('SELECT * FROM ld_picklist_dependency WHERE tabid=? GROUP BY sourcefield', array($tabId));
		$noofrows = $adb->num_rows($result);
        $spacearray[]='';
		$picklistDependencyDatasource = array();
		for($i=0; $i<$noofrows; ++$i) {
			$sourceField = $adb->query_result($result, $i, 'sourcefield');
			$targetField = $adb->query_result($result, $i, 'targetfield');
            $global_pick_list_depencyfield[$targetField]=$sourceField;
			
		}
		return $global_pick_list_depencyfield;
   }
   static function getPicklistDependencyDatasourceByParentFieldvalue($module,$sourcefield,$targetfield,$parentvalue) {
	       	global $adb;
            $tabId=getTabid($module);
            
        	$result = $adb->pquery('SELECT * FROM ld_picklist_dependency
                 WHERE tabid=? and sourcefield=? and targetfield=? and sourcevalue=?  ', array($tabId,$sourcefield,$targetfield,$parentvalue));
                 
               
		      $noofrows = $adb->num_rows($result);
              if($noofrows>0)
                     return json_decode($adb->query_result($result,0,'targetvalues'));
              else
                  return array();
             
        
        
        }
   static function getPicklistDependencyDatasourceByParentFieldname($module,$sourcefield,$targetfield,$parentvalue) {
		global $adb;

		$tabId = getTabid($module);
        $focus=CRMEntity::getInstance($module);
		$result = $adb->pquery('SELECT * FROM ld_picklist_dependency WHERE tabid=? and sourcefield=?  ', array($tabId,$sourcefield));
		$noofrows = $adb->num_rows($result);
       
        $spacearray[]='';
		$picklistDependencyDatasource = array();
		for($i=0; $i<$noofrows; ++$i) {
			$sourceField = $adb->query_result($result, $i, 'sourcefield');
			$targetField = $adb->query_result($result, $i, 'targetfield');
            if(!array_key_exists($targetfield,$focus->column_fields))
            {
                continue;
            }
			$sourceValue = decode_html($adb->query_result($result, $i, 'sourcevalue'));
			$targetValues = decode_html($adb->query_result($result, $i, 'targetvalues'));
            
			$unserializedTargetValues = json_decode(html_entity_decode($targetValues));
            /**
             * edit:zyh
             * reason:vb6.1,下拉框加空格
             * 20150521
             * */
            $unserializedTargetValues=array_merge($spacearray,$unserializedTargetValues);
			$criteria = decode_html($adb->query_result($result, $i, 'criteria'));
			$unserializedCriteria = json_decode(html_entity_decode($criteria));

			if(!empty($unserializedCriteria) && $unserializedCriteria['fieldname'] != null) {
				$conditionValue = array(
						"condition" => array($unserializedCriteria['fieldname'] => $unserializedCriteria['fieldvalues']),
						"values" => $unserializedTargetValues
				);
				$picklistDependencyDatasource[$sourceField][$sourceValue][$targetField][] = $conditionValue;
			} else {
				$picklistDependencyDatasource[$sourceField][$sourceValue][$targetField] = $unserializedTargetValues;
			}
            $pickArray[]='';
			if(empty($picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField])) {
				foreach(getAllPicklistValues($targetField) as $picklistValue) {
					$pickArray[] = decode_html($picklistValue);
				}
               
				$picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField] = $pickArray;
			}
		}
       
        $tmparr=$picklistDependencyDatasource[$sourceField];
      
		return $tmparr;
	}
    
	static function getPicklistDependencyDatasource($module) {
		global $adb,$global_pick_list_depencyfield;
        static $static_picklistDependencyDatasource;
        if(is_array($static_picklistDependencyDatasource)&&array_key_exists($module,$static_picklistDependencyDatasource))
        {
            return $static_picklistDependencyDatasource[$module];
        }
        if(!is_array($static_picklistDependencyDatasource))
        {
            $static_picklistDependencyDatasource=[];
        }
        if(!file_exists(globalStatic::$root_directory.'dataCache/picklist'))
        {
             mkdir(globalStatic::$root_directory.'dataCache/picklist',0777);
        }
        $focus=CRMEntity::getInstance($module);
        
        if(file_exists(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module."_pickdepencylist.php"))
         {
            require_once(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module."_pickdepencylist.php");
            // @edit:dong @date:2022/08/29 @reason: 应该格式为数组 否则261行赋值报错
            $global_pick_list_depencyfield=json_decode($global_pick_list_depencyfield,true);
            //edit:can 44134: (61mis.com/kfbcrm)进度跟踪；OA表单-加班单；单据编号JB31， 加班单中设置了进度跟踪，跟踪的字段为级联字段；没有按照设置的级联字段显示
           $hideparentfield_arr=[];
           $hidechildfield_arr=[];
          
           foreach($global_pick_list_depencyfield as $childfield=>$parentfield)
           {
                $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$parentfield);
                 if(!$tmpfieldinfo||empty($tmpfieldinfo->getFieldName()))
                 {
                    $hideparentfield_arr[]=$parentfield;
                    $hidechildfield_arr[]=$childfield;
                 }
           }
            $picklistDependencyDatasource=json_decode($picklistDependencyDatasource,true);
            if(sizeof($hideparentfield_arr)>0){
                foreach($hideparentfield_arr as $tmpindex=>$tmpfield){
                    
                    unset($picklistDependencyDatasource[$tmpfield]);
                    unset($global_pick_list_depencyfield[$hidechildfield_arr[$tmpindex]]);
                }
            }
           
            if(sizeof($picklistDependencyDatasource)>0)
            {
                $static_picklistDependencyDatasource[$module]=$picklistDependencyDatasource;
                return $picklistDependencyDatasource;
                
            }
         
         
         }
		$tabId = getTabid($module);

		$result = $adb->pquery('SELECT ld_picklist_dependency.* FROM ld_picklist_dependency
                        INNER JOIN ld_field on ld_field.fieldname=ld_picklist_dependency.sourcefield
                where ld_field.presence in(0,2) and ld_picklist_dependency.tabid=?', array($tabId));
		$noofrows = $adb->num_rows($result);
        $spacearray[]='';
		$picklistDependencyDatasource = array();
		for($i=0; $i<$noofrows; ++$i) {
			$sourceField = $adb->query_result($result, $i, 'sourcefield');

			$targetField = $adb->query_result($result, $i, 'targetfield');
            $global_pick_list_depencyfield[$targetField]=$sourceField;
			$sourceValue = decode_html($adb->query_result($result, $i, 'sourcevalue'));
			$targetValues = decode_html($adb->query_result($result, $i, 'targetvalues'));
            
			$unserializedTargetValues = json_decode(html_entity_decode($targetValues));
            /**
             * edit:zyh
             * reason:vb6.1,下拉框加空格
             * 20150521
             * */
            //$unserializedTargetValues=array_merge($spacearray,$unserializedTargetValues);
			//	$criteria = decode_html($adb->query_result($result, $i, 'criteria'));
			//	$unserializedCriteria = json_decode(html_entity_decode($criteria));

		
				$picklistDependencyDatasource[$sourceField][$sourceValue][$targetField] = $unserializedTargetValues;
			
            $pickArray[]='';
            if($targetField!='bill_area'&&$targetField!='bill_city'&&$targetField!='bill_state')
		if(empty($picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField])) {
				foreach(getAllPicklistValues($targetField) as $picklistValue) {
					$pickArray[] = decode_html($picklistValue);
				}
               
		     	$picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField] = $pickArray;
			} 
		}
		if($module == 'Accounts' && vtlib_isModuleActive('Contacts')){// 客户模块首要联系人-国省市区级联字段
			$result = $adb->pquery("SELECT ld_picklist_dependency.* FROM ld_picklist_dependency
						INNER JOIN ld_field on ld_field.fieldname=ld_picklist_dependency.sourcefield
				where ld_field.presence in(0,2) and (ld_field.fieldname='bill_country' or ld_field.fieldname='bill_state' or ld_field.fieldname='bill_city' or ld_field.fieldname='bill_area')
					and ld_picklist_dependency.tabid=?", array(getTabid('Contacts')));
			$noofrows = $adb->num_rows($result);
			for($i=0; $i<$noofrows; ++$i) {
				$sourceField = $adb->query_result($result, $i, 'sourcefield');


				$targetField = $adb->query_result($result, $i, 'targetfield');
				$global_pick_list_depencyfield[$targetField.'_mapping']=$sourceField.'_mapping';
				$sourceValue = decode_html($adb->query_result($result, $i, 'sourcevalue'));
				$targetValues = decode_html($adb->query_result($result, $i, 'targetvalues'));
				
				$unserializedTargetValues = json_decode(html_entity_decode($targetValues));

				$picklistDependencyDatasource[$sourceField.'_mapping'][$sourceValue][$targetField.'_mapping'] = $unserializedTargetValues;
			}
		}
        if(!file_exists(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module."_pickdepencylist.php"))
         {
            $content="<?php \n";
            $content.='$global_pick_list_depencyfield=\''.ldcrm_json_encode($global_pick_list_depencyfield).'\''.";\n";
             $content.='$picklistDependencyDatasource=\''.ldcrm_json_encode($picklistDependencyDatasource).'\''.";\n";
             $content.="?>";
             
            file_put_contents(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module."_pickdepencylist.php",$content);
            
         }
        //duan 20240705 缓存文件中不应该有权限判断，将逻辑移到缓存外
        foreach ($picklistDependencyDatasource as $tmp_fieldname => $tmp_arr){
            $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$tmp_fieldname);
            if(!$tmpfieldinfo||empty($tmpfieldinfo->getFieldName())){
                unset($picklistDependencyDatasource[$tmp_fieldname]);
            }
        }

        $static_picklistDependencyDatasource[$module]=$picklistDependencyDatasource;
		return $picklistDependencyDatasource;
	}

	static function getJSPicklistDependencyDatasource($module) {
		$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
		return Zend_Json::encode($picklistDependencyDatasource);
	}

	static function checkCyclicDependency($module, $sourceField, $targetField) {
		$adb = PearDatabase::getInstance();

		// If another parent field exists for the same target field - 2 parent fields should not be allowed for a target field
		$result = $adb->pquery('SELECT COUNT(id) AS checkcount FROM ld_picklist_dependency WHERE tabid = ?
						AND (targetfield = ? AND sourcefield != ?) 
						OR (sourcefield = ? AND targetfield = ?) 
						ORDER BY id;',
				array(getTabid($module), $targetField, $sourceField,$targetField,$sourceField));
		//OR (sourcefield = ? AND targetfield != ?) $sourceField,$targetField,
		$checkcount = $adb->query_result($result,0,'checkcount');
		if($checkcount > 0) return true;
		//TODO - Add required check for cyclic dependency
		return false;
	}
	static function getTargetFields($tabid,$sourcefield){
		$adb = PearDatabase::getInstance();
		$result = $adb->pquery('select targetfield from ld_picklist_dependency where tabid = ? and sourcefield = ? GROUP BY targetfield ',array($tabid,$sourcefield));
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			for($i = 0; $i<$num_rows; $i++){
				$targetFieldArray[] = $adb->query_result($result,$i,'targetfield');
			}
			return $targetFieldArray;
		}
		return '';
	}
    static function getSourceFields($tabid,$targetfield){
		$adb = PearDatabase::getInstance();
		$result = $adb->pquery('select sourcefield from ld_picklist_dependency where tabid = ? and targetfield = ? GROUP BY sourcefield ',array($tabid,$targetfield));
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			for($i = 0; $i<$num_rows; $i++){
				$sourceFieldArray[] = $adb->query_result($result,$i,'sourcefield');
			}
			return $sourceFieldArray;
		}
		return '';
	}
	static function getDependentPickListModules() {
		$adb = PearDatabase::getInstance();
        /*
        *AUTHOR:BY LD KEVIN
        *DATE:20130130
        *DESCRIPTION:修改bug3225
        *and ld_tab.tabid<>7
        *edit by LD Can
        *reason:0003284: 控制面板 级联字段和（下拉框编辑）里面的选择模块中：常见问题、服务单、项目、项目任务、采购订单、服务合同、服务、供应商等信息的不需要，应该去掉的
        *date:20130308
        */
        /*edit:andrew
        *20140123
        *添加排序
        */
		$query = "SELECT distinct ld_field.tabid, ld_tab.tablabel, ld_tab.name as tabname FROM ld_field
						INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid
						INNER JOIN ld_picklist_set ON ld_picklist_set.listname = ld_field.fieldname
					WHERE uitype IN (15,16)
						and ld_picklist_set.relatetable='ld_field'
						AND ld_field.displaytype = 1
						AND ld_field.presence in (0,2) and ld_tab.tabid<>7 and ld_tab.presence in(0,2)
					GROUP BY ld_field.tabid HAVING count(*) > 1 and tablabel not in ('Events') order by tabsequence";
		// END
		$result = $adb->pquery($query, array());
		while($row = $adb->fetch_array($result)) {
			$modules[$row['tablabel']] = $row['tabname'];
		}
		//ksort($modules);
		return $modules;
	}

}
?>