<?php
/**
* edit: chj
* reason: 东贸特殊控制：适用范围
* date: 2021/9/22
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new,$currentModule;
$smarty=new lingdangCRM_Smarty();
$smarty->assign('FIELDNAME',$_REQUEST['fieldname']);
$smarty->assign('RECORD',$_REQUEST['record']);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
//适用范围 - 保存
if(!empty($_REQUEST['savemodulescope']) && $_REQUEST['savemodulescope'] == 'yes'){
	$focus = CRMEntity::getInstance($currentModule);
	$query = "update $focus->table_name set advft_criteria = ?,advft_criteria_groups = ? where $focus->table_index = ?";
	$adb->pquery($query,array($_REQUEST['advft_criteria'],$_REQUEST['advft_criteria_groups'],$_REQUEST['record']));
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,$arr,"success");
}
//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
$module=$currentModule;
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);
$advfilterlist = getAdvFilter();
$arr['columns_block'] = getByModule_ColumnsHTML($module,$modulecollist);//高级查询select option
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$advfilterhtml = CommonView::getAdvCriteriaHTML($fLabels);
$arr['flabels']=$fLabels;
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['arr_recovery_modules'] = $arr_recovery_modules;	//回收模块
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();
$arr['foption']=$advfilterhtml;
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("ModuleScope.tpl");
$arr['title']=getFixedLabel("LBL_ACCOUNT_SET");
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");


/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilter() {

	global $adb,  $default_charset;
	$advft_criteria = array();
	$advfiltergroup=ldcrm_json_decode($_REQUEST['advft_criteria_groups']);
	$advfilterlist = ldcrm_json_decode($_REQUEST['advft_criteria']);
    $i = 1;
	$j = 0;
	foreach($advfiltergroup as $key => $relcriteriagroup){
		if(empty($relcriteriagroup)){
			continue;
		}
		$groupId = $key;
		$groupCondition = $relcriteriagroup["groupcondition"];
		
		foreach($advfilterlist as $k => $relcriteriarow){
			if($relcriteriarow['groupid'] == $key){
				$columnIndex = $relcriteriarow["columnindex"];
				$criteria = array();
				$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
				$criteria['comparator'] = $relcriteriarow["comparator"];
				$criteria['search_comparator']= $relcriteriarow["comparator"];
				$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
				$col = explode(":", $relcriteriarow["columnname"]);
				$temp_val = explode(",", $relcriteriarow["value"]);
				if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
					 crm_load_class_file("DateTimeField","include/fields");
					$val = Array();
					for ($x = 0; $x < count($temp_val); $x++) {
						if ($col[4] == 'D') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDate();
						} elseif ($col[4] == 'DT') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDateTimeValue();
						} else {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayTime();
						}
					}
					$advfilterval = implode(",", $val);
				}
				$criteria['value'] = $advfilterval;
				$criteria['column_condition'] = $relcriteriarow["columncondition"];

				$advft_criteria[$i]['columns'][$j] = $criteria;
				$advft_criteria[$i]['condition'] = $groupCondition;
			   
				$j++;
			}
		}
		if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
			$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
		}
		$i++;
	}
	// Clear the condition (and/or) for last group, if any.
	if (!empty($advft_criteria[$i - 1]['condition']))
		$advft_criteria[$i - 1]['condition'] = '';

  
	return $advft_criteria;
}

function getByModule_ColumnsHTML($module,$columnslist) {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,"");
	$columnsList[getTranstab('Contacts')] = CustomView_Special::getAccountContact('Contacts',getCvadfilter()); 
	return generateSelectColumnsHTML($columnsList,$module);
}

function getByModule_ColumnsList($module,$columnslist,$selected="") {
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

	foreach($oCustomView->module_list[$module] as $key=>$value)
	{
		$advfilter = array();			
		$label = $key;
		if(isset($columnslist[$module][$key]))
		{
			foreach($columnslist[$module][$key] as $field=>$fieldlabel)
			{
				if(!in_array($fieldlabel,$check_dup))
				{
					if(isset($mod_strings[$fieldlabel]))
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
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
					}else
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
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
					}
					$advfilter[] = $advfilter_option;
					$check_dup [] = $fieldlabel;
				}
			}
			$advfilter_out[$label]= $advfilter;
		}
	}
	
	return $advfilter_out;
}

function getCvadfilter()
{
    global $adb;
	$array = [];
    /*$sql = "select columnname from ld_account_set_advfilter where pool_id = -1";
    $result = $adb->pquery($sql,array());
    for ($i=0;$i<$adb->num_rows($result);$i++) {
        $array[$i] = $adb->query_result($result, $i, "columnname");
    }*/
    return $array;
}

function generateSelectColumnsHTML($columnsList, $module) {
	$shtml = '';
	foreach($columnsList as $blocklabel=>$blockcolumns) {
    	$shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
    	foreach($blockcolumns as $columninfo) {
      		$shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
    	}
  	}
  	return $shtml;	
}
?>