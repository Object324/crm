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


require_once globalStatic::$root_directory. 'modules/PickList/PickListUtils.php';

class lingdang_DependencyPicklist {
        static  function savePickListDependencies($module,$sourceField,$targetField,$sourceValue,$mapping) {
    	global $adb;
    	$tabid = getTabid($module);
        if($mapping=="")
        {
            //
            $sql='delete from ld_picklist_dependency  wehre tabid=? and sourcefield=? AND targetfield=? AND sourcevalue=?';
            $adb->pquery($query,array($tabid,$sourceField,$targetField,$sourceValue));
            return ;
        }
    	$mapping = ldcrm_json_encode($mapping);
    	$query = 'SELECT id FROM ld_picklist_dependency WHERE tabid=? 
    				AND sourcefield=? AND targetfield=? AND sourcevalue=?;';
    	$result = $adb->pquery($query,array($tabid,$sourceField,$targetField,$sourceValue));
    	$rows = $adb->num_rows($result);
    	if($rows > 0){//编辑
    		$id = $adb->query_result($result,0, 'id');
    		$adb->pquery("UPDATE ld_picklist_dependency SET targetvalues=? WHERE id=?",
    						array($mapping, $id));
    	}else{//新增
    		$adb->pquery("INSERT INTO ld_picklist_dependency(id, tabid, sourcefield, targetfield, sourcevalue, targetvalues, criteria)
    								VALUES (?,?,?,?,?,?,?)",
    						array($adb->getUniqueID('ld_picklist_dependency'), $tabid, $sourceField, $targetField, $sourceValue,
    						$mapping,''));
    	}
        
      
        
    }
	static function getDependentPicklistFields($module='') {
		global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
		if(empty($module)) {
			$result = $adb->pquery('SELECT DISTINCT sourcefield, targetfield, ld_picklist_dependency.tabid FROM ld_picklist_dependency inner JOIN ld_tab on ld_tab.tabid = ld_picklist_dependency.tabid where ld_tab.presence in(0,2) ', array());
		} else {
			$tabId = getTabid($module);
			//Eidtor:gyq_64M Reason:下拉框改进,去除（0,2）的限制 Date:2018/3/20 0020 下午 6:09
			$result = $adb->pquery('SELECT DISTINCT sourcefield, targetfield, ld_picklist_dependency.tabid FROM ld_picklist_dependency inner JOIN ld_tab on ld_tab.tabid = ld_picklist_dependency.tabid WHERE ld_picklist_dependency.tabid=?', array($tabId));
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
        $tmparr=array();
        if($module=='Users')
        {
            $tmparr=array('approvestatus','lead_view','activity_view','currency_grouping_pattern'
                    ,'currency_decimal_separator','currency_grouping_separator','currency_symbol_placement'
                    ,'reminder_interval');
        }
        $fieldlist = array();
		if($noofrows > 0) {
			for($i=0; $i<$noofrows; ++$i) {
			 $fieldname=$adb->query_result($result,$i,"fieldname");
             if(in_array($fieldname,$tmparr))
             {
                continue;
             }
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
			$unserializedTargetValues = Zend_Json::decode(html_entity_decode($targetValues));

			$mapping = array();
			$mapping['sourcevalue'] = $sourceValue;
			$mapping['targetvalues'] = $unserializedTargetValues;

			$valueMapping[$i] = $mapping ;
		}
		$dependencyMap['valuemapping'] = $valueMapping;

		return $dependencyMap;
	}

	static function getPicklistDependencyDatasource($module) {
		global $adb;

		$tabId = getTabid($module);

		$result = $adb->pquery('SELECT * FROM ld_picklist_dependency WHERE tabid=?', array($tabId));
		$noofrows = $adb->num_rows($result);
        $spacearray[]='';
		$picklistDependencyDatasource = array();
		for($i=0; $i<$noofrows; ++$i) {
			$sourceField = $adb->query_result($result, $i, 'sourcefield');
			$targetField = $adb->query_result($result, $i, 'targetfield');
			$sourceValue = decode_html($adb->query_result($result, $i, 'sourcevalue'));
			$targetValues = decode_html($adb->query_result($result, $i, 'targetvalues'));
            
			$unserializedTargetValues = Zend_Json::decode(html_entity_decode($targetValues));
            /**
             * edit:zyh
             * reason:vb6.1,下拉框加空格
             * 20150521
             * */
            $unserializedTargetValues=array_merge($spacearray,$unserializedTargetValues);
			$criteria = decode_html($adb->query_result($result, $i, 'criteria'));
			$unserializedCriteria = Zend_Json::decode(html_entity_decode($criteria));

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
		/*	if(empty($picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField])) {
				foreach(getAllPicklistValues($targetField) as $picklistValue) {
					$pickArray[] = decode_html($picklistValue);
				}
               
				$picklistDependencyDatasource[$sourceField]['__DEFAULT__'][$targetField] = $pickArray;
			}*/
		}
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
						AND ((targetfield = ? AND sourcefield = ?) 
						OR (sourcefield = ? AND targetfield = ?) )
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
		//Eidtor:gyq_64 Reason:下拉框改进转为ld_picklist_set Date:2018/3/14 0014 下午 3:27
		$query = "SELECT distinct ld_field.tabid, ld_tab.tablabel, ld_tab.name as tabname FROM ld_field
						INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid
						INNER JOIN ld_picklist_set ON ld_picklist_set.listname = ld_field.fieldname
					WHERE uitype IN (15,16)
					
						AND ld_field.displaytype = 1
						AND ld_field.presence in (0,2) and ld_tab.tabid<>7 and ld_tab.presence in(0,2)
					GROUP BY ld_field.tabid HAVING count(*) > 1 and tablabel not in ('Events') order by tabsequence";
		$result = $adb->pquery($query, array());
		while($row = $adb->fetch_array($result)) {
			$modules[$row['tablabel']] = $row['tabname'];
		}
		return $modules;
	}

}
?>