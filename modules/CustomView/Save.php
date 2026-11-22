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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/Stock/CommonStock.php');
global $adb;
global  $current_user;
$_REQUEST['diony']='diony';
$cvid = (int) vtlib_purify($_REQUEST["record"]);

$cvmodule = vtlib_purify($_REQUEST["cvmodule"]);
if($cvmodule=='Calendar')
$cvmodule='Events';
$parenttab = getParentTab();
$return_action = vtlib_purify($_REQUEST["return_action"]);

$is_admin=is_admin($current_user);
if($cvmodule != "") {
	$cv_tabid = getTabid($cvmodule);
	$viewname = vtlib_purify($_REQUEST["viewName"]);
	if(strtolower($default_charset) != 'utf-8')
		$viewname = htmlentities($viewname);

    if(isset($_REQUEST['repeat'])&&$_REQUEST['repeat']==1)
    {
       	$ssql = "select ld_customview.cvid,ld_customview.viewname,ld_customview.status, ld_users.first_name,ld_users.last_name from ld_customview inner join ld_tab on ld_tab.name = ld_customview.entitytype
					left join ld_users on ld_customview.userid = ld_users.id ";
    	$ssql .= " where ld_tab.tabid=?";
    	$sparams = array($cv_tabid);
		
		//or ld_customview.userid in(select ld_user2role.userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '" . $current_user_parent_role_seq . "::%')
        if ($is_admin == false) {
    			$ssql .= " and (ld_customview.status=0 or ld_customview.userid = ? or ld_customview.status = 3)";
    			array_push($sparams, $current_user->id);
    		}
        $ssql.=' and viewname=? and cvid!=? and entitytype =?';
        //客户模块 分类编辑全部。
        if($cvmodule == 'Accounts')
        {
            if(isset($_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']) && $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] != '')
            {
                $ssql .= " and customcategory = '".$_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']."'";
            }
            else
            {
                $ssql .= " and customcategory = 'ALLACCOUNT'";
            }
            //$ssql .=' and customcategory';
        }
        array_push($sparams,$viewname);
        array_push($sparams,$cvid);
        array_push($sparams,$cvmodule);
     
        $result=$adb->pquery($ssql,$sparams);
        if($adb->num_rows($result)>0)
        {
            ConvertTojsonString(-1,array(),'error');
        }


    }
	if(isset($_REQUEST['setStatus']) && $_REQUEST['setStatus'] != '' && $_REQUEST['setStatus'] != '1')
		$status = $_REQUEST['setStatus'];
	elseif(isset($_REQUEST['setStatus']) && $_REQUEST['setStatus'] != '' && $_REQUEST['setStatus'] == '1')
    //edti by ld tifa 20130306 
	    //$status = CV_STATUS_PENDING;
        $status =CV_STATUS_PUBLIC;
	else
		$status = CV_STATUS_PRIVATE;

	$userid = $current_user->id;

	if(isset($_REQUEST["setDefault"])) {
	   
	  $setdefault = 1;
	} else {
	  $setdefault = 0;
	}

	if(isset($_REQUEST["setMetrics"])) {
		$setmetrics = 1;
	} else {
		$setmetrics = 0;
	}

 	//$allKeys = array_keys($HTTP_POST_VARS);
	//this is  will cause only the chosen fields to be added to the ld_cvcolumnlist table
	$allKeys = array_keys($_REQUEST);
    if($cvmodule == 'InventoryAccount' || $cvmodule == 'InventoryQuery')
    {
        switch($cvmodule)
        {
            case 'InventoryAccount':
                $columnslist = selCustomInfo(1);
                break;
            case 'InventoryQuery':
                $columnslist = selCustomInfo(2);
                break;
        }
    }
    else
    {
        //<<<<<<<columns>>>>>>>>>>
    	for ($i=0;$i<count($allKeys);$i++) {
    	   $string = substr($allKeys[$i], 0, 6);
    	   if($string == "column") {
    		   //the contusion, will cause only the chosen fields to be added to the ld_cvcolumnlist table
    		   if($_REQUEST[$allKeys[$i]] != "")
            	   $columnslist[] = $_REQUEST[$allKeys[$i]];
       	   }
    	}  
    }
	//<<<<<<<columns>>>>>>>>>

	//<<<<<<<standardfilters>>>>>>>>>
	$std_filter_list = array();
	$stdfiltercolumn = $_REQUEST["stdDateFilterField"];
	$std_filter_list["columnname"] = $stdfiltercolumn;
	$stdcriteria = $_REQUEST["stdDateFilter"];
	$std_filter_list["stdfilter"] = $stdcriteria;
	$startdate = $_REQUEST["startdate"];
	$enddate = $_REQUEST["enddate"];
	if(empty($startdate) && empty($enddate)) {
		unset($std_filter_list);
	} else {
	    crm_load_function_file('DateTimeField','include/fields','DateTimeField');
		$dbCurrentDateTime = new DateTimeField(date('Y-m-d H:i:s'));
		$startDateTime = new DateTimeField($startdate.' '. $dbCurrentDateTime->getDisplayTime());
		$endDateTime = new DateTimeField($enddate.' '. $dbCurrentDateTime->getDisplayTime());
		$std_filter_list["startdate"] = $startDateTime->getDBInsertDateValue();
		$std_filter_list["enddate"] = $endDateTime->getDBInsertDateValue();
	}
	//<<<<<<<standardfilters>>>>>>>>>

	//<<<<<<<advancedfilter>>>>>>>>>
	$json = new Zend_Json();

	$advft_criteria = $_REQUEST['advft_criteria'];

	$advft_criteria = $json->decode($advft_criteria);
    
	$advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
	$advft_criteria_groups = $json->decode($advft_criteria_groups);
	//<<<<<<<advancedfilter>>>>>>>>
	//$moduleHandler = vtws_getModuleHandlerFromName($cvmodule,$current_user);
    $tmp_field_obj=Field::getInstance($cvmodule,$adb);
    if($cvmodule == 'Emails'){
        $tmp_field_obj=Field::getInstance($_REQUEST['cvmodule_field'],$adb);
    }

	$moduleFields = $tmp_field_obj->getModuleFields();
	if(!$cvid) {
		$genCVid = $adb->getUniqueID("ld_customview");
     
		if($genCVid != "") {
		    // add by tifa 20130311 for view order
            if($cvmodule=='Calendar')
            $cvmodule='Events';
		    $seq_sql='select max(sequence) from ld_customview where entitytype=?';
            if(isset($_REQUEST['group'])&&$_REQUEST['group']!='')
            $seq_result = $adb->pquery($seq_sql, array($_REQUEST['group']));
            else
            $seq_result = $adb->pquery($seq_sql, array($cvmodule));
            $seq_no=$adb->query_result($seq_result,0);
            $seq_no+=1;
            //echo $_REQUEST['PageWidthPercent'] . "==";
            //exit;
			$customviewsql = "INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, status, userid,sequence)
				VALUES (?,?,?,?,?,?,?,?)";
            
           if(isset($_REQUEST['group'])&&$_REQUEST['group']!='')
           {
                $customviewparams = array($genCVid, $viewname, $setdefault, $setmetrics, $_REQUEST['group'], $status, $userid,$seq_no);
           }
           else
           {
                $customviewparams = array($genCVid, $viewname, $setdefault, $setmetrics, $cvmodule, $status, $userid,$seq_no);
           }
             
			$customviewresult = $adb->pquery($customviewsql, $customviewparams);
//设置默认
			if($setdefault == 1) {
				$sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? and tabid = ?",array($current_user->id, $cv_tabid));
				if($adb->num_rows($sql_result) > 0) {
					$updatedefaultsql = "UPDATE ld_user_module_preferences SET default_cvid = ? WHERE userid = ? and tabid = ?";
					$updatedefaultresult = $adb->pquery($updatedefaultsql, array($genCVid, $current_user->id, $cv_tabid));
				} else {
					$insertdefaultsql = "INSERT INTO ld_user_module_preferences(userid, tabid, default_cvid) values (?,?,?)";
					$insertdefaultresult = $adb->pquery($insertdefaultsql, array($userid, $cv_tabid, $genCVid));
				}
			} else {
			  /*
             edit:Can
             date:20130605
             reason:4100: 视图方案问题，设置默认视图时产生的问题
             */
				$sql_result = $adb->pquery("SELECT 1 FROM ld_user_module_preferences WHERE userid = ? and tabid = ? and default_cvid=?",array($current_user->id, $cv_tabid,$genCVid));
                //echo "1dd$genCVid";
                //exit();
				if($adb->num_rows($sql_result) > 0) {
					$deletedefaultsql = "DELETE FROM ld_user_module_preferences WHERE userid = ? and tabid = ? and default_cvid=?";
					$deletedefaultresult = $adb->pquery($deletedefaultsql, array($current_user->id, $cv_tabid,$genCVid));
				}
			}

			if($customviewresult) {
			     /**
                 * edit:chj
                 * date:2014-1-16
                 * reason: 模块 序时薄有产品信息，则分类默认选项跟全部类型一样
                 **/
                if(get_file_address($cvmodule,'ProductDetails'))
                {
                    $columnslist = getColumnAllList($genCVid);
                }
				if(isset($columnslist)||(isset($_REQUEST['group'])&&$_REQUEST['group']!='')) {
				    if(isset($_REQUEST['group'])&&$_REQUEST['group']!='');
                    else{
                        for($i=0;$i<count($columnslist);$i++) {
						$columnsql = "INSERT INTO ld_cvcolumnlist (cvid, columnindex, columnname) VALUES (?,?,?)";
						$columnparams = array($genCVid, $i, $columnslist[$i]);
						$columnresult = $adb->pquery($columnsql, $columnparams);
					    }
                    }
					
					if($std_filter_list["columnname"] !="") {
						$stdfiltersql = "INSERT INTO ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) VALUES (?,?,?,?,?)";
						$stdfilterparams = array($genCVid, $std_filter_list["columnname"], $std_filter_list["stdfilter"], $adb->formatDate($std_filter_list["startdate"], true), $adb->formatDate($std_filter_list["enddate"], true));
						$stdfilterresult = $adb->pquery($stdfiltersql, $stdfilterparams);
					
					}

					foreach($advft_criteria as $column_index => $column_condition) {

						if(empty($column_condition)) continue;

						$adv_filter_column = $column_condition["columnname"];
						$adv_filter_comparator = $column_condition["comparator"];
						$adv_filter_value = $column_condition["value"];
						$adv_filter_column_condition = $column_condition["columncondition"];
						$adv_filter_groupid = $column_condition["groupid"];

						$column_info = explode(":",$adv_filter_column);

						$fieldName = $column_info[2];
						$fieldObj = $moduleFields[$fieldName];
						$fieldType = $fieldObj->getFieldDataType();

						if($fieldType == 'currency') {
							if($fieldObj->getUIType() == '71') {
								$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value, null, true);
							} else {
								$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value);
							}
						}

						$temp_val = explode(",",$adv_filter_value);
						if(($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '' )) {
							$val = Array();
							for($x=0;$x<count($temp_val);$x++) {
								//if date and time given then we have to convert the date and
								//leave the time as it is, if date only given then temp_time
								//value will be empty
								if(trim($temp_val[$x]) != '') {
									$date = new DateTimeField(trim($temp_val[$x]));
									if($fieldType == 'date') {
										$val[$x] = DateTimeField::convertToDBFormat(
												trim($temp_val[$x]));
									} elseif($fieldType == 'datetime') {
										$val[$x] = $date->getDBInsertDateTimeValue();
									} else {
										$val[$x] = $date->getDBInsertTimeValue();
									}
								}
							}
							$adv_filter_value = implode(",",$val);
						}

						$irelcriteriasql = "INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) values (?,?,?,?,?,?,?)";
						$irelcriteriaresult = $adb->pquery($irelcriteriasql, array($genCVid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));
						// Update the condition expression for the group to which the condition column belongs
						$groupConditionExpression = '';
						if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
							$groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
						}
						$groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
						$advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
					}

					foreach($advft_criteria_groups as $group_index => $group_condition_info) {

						if(empty($group_condition_info)) continue;
						if(empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

						$irelcriteriagroupsql = "insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) values (?,?,?,?)";
						$irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
					}
					
				}
			}
			$cvid = $genCVid;
		}
	} else {
		if($is_admin == true || $current_user->id) {
			$updatecvsql = "UPDATE ld_customview
					SET viewname = ?, setmetrics = ?, status = ?, setdefault=? WHERE cvid = ?";
			$updatecvparams = array($viewname, $setmetrics, $status, $setdefault, $cvid);
			$updatecvresult = $adb->pquery($updatecvsql, $updatecvparams);
			
			if($setdefault == 1) {
				$sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? and tabid = ?",array($current_user->id, $cv_tabid));
				if($adb->num_rows($sql_result) > 0) {
					$updatedefaultsql = "UPDATE ld_user_module_preferences SET default_cvid = ? WHERE userid = ? and tabid = ?";
					$updatedefaultresult = $adb->pquery($updatedefaultsql, array($cvid, $current_user->id, $cv_tabid));
				} else {
					$insertdefaultsql = "INSERT INTO ld_user_module_preferences(userid, tabid, default_cvid) values (?,?,?)";
					$insertdefaultresult = $adb->pquery($insertdefaultsql, array($userid, $cv_tabid, $cvid));
				}
			} else {
			 /*
             edit:Can
             date:20130605
             reason:4100: 视图方案问题，设置默认视图时产生的问题
             */
				$sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? and tabid = ? and default_cvid= ?",array($current_user->id, $cv_tabid,$cvid));
				//echo "2dd$cvid";
                //exit();
                if($adb->num_rows($sql_result) > 0) {
					$deletedefaultsql = "DELETE FROM ld_user_module_preferences WHERE userid = ? and tabid = ? and default_cvid=?";
					$deletedefaultresult = $adb->pquery($deletedefaultsql, array($current_user->id, $cv_tabid,$cvid));
				}
			}
			$deletesql = "DELETE FROM ld_cvcolumnlist WHERE cvid = ?";
			$deleteresult = $adb->pquery($deletesql, array($cvid));

			$deletesql = "DELETE FROM ld_cvstdfilter WHERE cvid = ?";
			$deleteresult = $adb->pquery($deletesql, array($cvid));

			$deletesql = "DELETE FROM ld_cvadvfilter WHERE cvid = ?";
			$deleteresult = $adb->pquery($deletesql, array($cvid));

			$deletesql = "DELETE FROM ld_cvadvfilter_grouping WHERE cvid = ?";
			$deleteresult = $adb->pquery($deletesql, array($cvid));

			$genCVid = $cvid;
			if($updatecvresult) {
				if(isset($columnslist)||(isset($_REQUEST['group'])&&$_REQUEST['group']!='')) {
				    if(($_REQUEST['group'])&&$_REQUEST['group']!='');
                    else{
                         for($i=0;$i<count($columnslist);$i++) {
						$columnsql = "INSERT INTO ld_cvcolumnlist (cvid, columnindex, columnname) VALUES (?,?,?)";
						$columnparams = array($genCVid, $i, $columnslist[$i]);
						$columnresult = $adb->pquery($columnsql, $columnparams);
					  }
                    }
					
					if($std_filter_list["columnname"] !="") {
						$stdfiltersql = "INSERT INTO ld_cvstdfilter (cvid,columnname,stdfilter,startdate,enddate) VALUES (?,?,?,?,?)";
						$stdfilterparams = array($genCVid, $std_filter_list["columnname"], $std_filter_list["stdfilter"], $adb->formatDate($std_filter_list["startdate"], true), $adb->formatDate($std_filter_list["enddate"], true));
						$stdfilterresult = $adb->pquery($stdfiltersql, $stdfilterparams);
						
					}

					foreach($advft_criteria as $column_index => $column_condition) {

						if(empty($column_condition)) continue;

						$adv_filter_column = $column_condition["columnname"];
						$adv_filter_comparator = $column_condition["comparator"];
						$adv_filter_value = $column_condition["value"];
						$adv_filter_column_condition = $column_condition["columncondition"];
						$adv_filter_groupid = $column_condition["groupid"];

						$column_info = explode(":",$adv_filter_column);

						$fieldName = $column_info[2];
						$fieldObj = $moduleFields[$fieldName];
                        
						$fieldType = $fieldObj->getFieldDataType();

						if($fieldType == 'currency') {
							// Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
							if($fieldObj->getUIType() == '72') {
								$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value, null, true);
							} else {
								$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value);
							}
						}

						$temp_val = explode(",",$adv_filter_value);
						if(($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '' )) {
							$val = Array();
							for($x=0;$x<count($temp_val);$x++) {
								//if date and time given then we have to convert the date and
								//leave the time as it is, if date only given then temp_time
								//value will be empty
								if(trim($temp_val[$x]) != '') {
									$date = new DateTimeField(trim($temp_val[$x]));
									if($fieldType == 'date') {
										$val[$x] = DateTimeField::convertToDBFormat(
												trim($temp_val[$x]));
									} elseif($fieldType == 'datetime') {
										$val[$x] = $date->getDBInsertDateTimeValue();
									} else {
										$val[$x] = $date->getDBInsertTimeValue();
									}
								}
							}
							$adv_filter_value = implode(",",$val);
						}

						$irelcriteriasql = "INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) values (?,?,?,?,?,?,?)";
						$irelcriteriaresult = $adb->pquery($irelcriteriasql, array($genCVid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));

						// Update the condition expression for the group to which the condition column belongs
						$groupConditionExpression = '';
						if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
							$groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
						}
						$groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
						$advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
					}

					foreach($advft_criteria_groups as $group_index => $group_condition_info) {

						if(empty($group_condition_info)) continue;
						if(empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

						$irelcriteriagroupsql = "insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) values (?,?,?,?)";
						$irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
					}
				
				}
			}
		}
	}
}
$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
if($cvmodule=='Events')
$cvmodule='Calendar';
unsetCacheDirectory('customview');
/**
 * this function returns the entity information for a given module; for e.g. for Contacts module
 * it returns the information of tablename, modulename, fieldsname and id gets from ld_entityname
 * @param string $module - the module name
 * @return array $data - the entity information for the module
 */
function getColumnAllList($cvid)
{
    global $adb;
    $sql = "select cvid from ld_customview where viewname = 'All' and entitytype = (select entitytype from ld_customview where cvid = ?)";
    $result = $adb->pquery($sql, array($cvid));
    $allcvid = $adb->query_result($result, 0, 'cvid');
    $colsql = "select sequence,columns from ld_tabwithproductview where cvid = ?";
    $colresult = $adb->pquery($colsql, array($allcvid));
    for ($i = 0; $i < $adb->num_rows($colresult); $i++){
        $array[$adb->query_result($colresult, $i, 'sequence')] =    $adb->query_result($colresult, $i, 'columns');
    }
    return $array;
}

// @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块(创建)
if($_REQUEST['refreshpage']=='no') {
//    $customview=$customView = new CustomView($_REQUEST['cvmodule']);
    $customView = CustomView::getInstance($_REQUEST['cvmodule']);//Emails
    $viewid = $customView->getViewId($_REQUEST['cvmodule']);
    if($_REQUEST['cvmodule'] == 'Emails' || $_REQUEST['cvmodule'] == 'MassSMS')
        $module = $_REQUEST['cvmodule'];//群发邮件模块
    $customview_html = $customView->getCustomViewCombo2($viewid,$module,$category);

    $smarty=new lingdangCRM_Smarty();
    $smarty->assign('CUSTOMVIEW_HTML',$customview_html);

//    $smarty->assign("MODULE",$_REQUEST['cvmodule']); //暂时还没用到
//    $smarty->assign("VIEWID",$viewid);

    $content=$smarty->fetch("SelectEmailFenzuName.tpl");
    $arr['datafenzucontent'] = $content;

    ConvertTojsonString(1,$arr,'success');
}else{
    header("Location: index.php?action=$return_action&module=$cvmodule&viewname=$cvid&switchview=$cvid&SearchScope=$SearchScope");
}
/*if(isset($_REQUEST['group'])&&$_REQUEST['group']!='')
header("Location: index.php?action=$return_action&module=".$_REQUEST['group']."&viewname=$cvid&switchview=$cvid&SearchScope=$SearchScope");
else
header("Location: index.php?action=$return_action&module=$cvmodule&viewname=$cvid&switchview=$cvid&SearchScope=$SearchScope");*/
?>