<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
$normal_id= 1;
if(!empty($_REQUEST['normal_id'])){
	$normal_id = $_REQUEST['normal_id'];
}
$smarty->assign('NORMALID',$normal_id);
//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
$module='Accounts';
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);
//编辑修改时候进入
if(!empty($_REQUEST['advft_criteria_groups']) && !empty($_REQUEST['advft_criteria'])){
	$advft_criteria = ldcrm_json_decode($_REQUEST['advft_criteria']);
	$advft_criteria_groups = ldcrm_json_decode($_REQUEST['advft_criteria_groups']);
	foreach($advft_criteria_groups as $key => $groups){
		if(isset($groups['groupcondition'])){
			foreach($advft_criteria as $advfrs){
				if($advfrs['groupid'] == $key){
					$advfilterlist[$key]['columns'][] = array(
						'columnname' => $advfrs['columnname'],
						'comparator' => $advfrs['comparator'],
						'search_comparator' => $advfrs['comparator'],
						'value' => $advfrs['value'],
						'column_condition' => $advfrs['columncondition']
					);
				}
			}
			$advfilterlist[$key]['condition'] = $groups['groupcondition'];
		}
	}
}else{
	$advfilterlist = getAdvFilter($normal_id);
}
getCvadfilter(1);
$arr['columns_block'] = getByModule_ColumnsHTML($module,$modulecollist,$normal_id);//高级查询select option
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$advfilterhtml = CommonView::getAdvCriteriaHTML($fLabels);
//chj 2022/3/24 0050466: （https://81mis.com [^]）客户管理>客户>公海参数设置，回收方案的回收条件中，首次点进选择条件，下拉框为空。修改请参考公海池设置条件时，选择条件样式
$arr['flabels']=$fLabels;
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
$arr['foption']=$advfilterhtml;
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
$_REQUEST['diony']='diony';
$content=$smarty->fetch("Accounts/setNormalAccountBasicSearch.tpl");
//BUG0054926 wyt 公海参数设置，启用公海回收规则，点击“回收条件”，弹出层标签显示“回收方案”，点击“回收规则”，弹出层标签显示“回收条件”。预期结果：标签应该对应显示，避免造成歧义
$arr['title']=getFixedLabel("recoveryconditions");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");


/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilter($normal_id) {

	global $adb,  $default_charset;
	$advft_criteria = array();
	$i = 1;
	$j = 0;
	$query = 'select advfilter,advfilter_grouping from ld_account_normal where id = ?';
	$result = $adb->pquery($query,array($normal_id));
	$advfilter = json_decode($adb->query_result($result,0,'advfilter'));
	$advfilter_grouping = json_decode($adb->query_result($result,0,'advfilter_grouping'));
	foreach($advfilter_grouping as $groupid => $groupobj){
		if(!empty($groupid)){
			$groupCondition = $groupobj->groupcondition;
			if(empty($advfilter)){
				return ;
			}
			foreach($advfilter as $advafilter_obj){
				if($i == $advafilter_obj->groupid){
					$criteria = array();
					$criteria['columnname'] = html_entity_decode($advafilter_obj->columnname, ENT_QUOTES, $default_charset);
					$criteria['comparator'] = $advafilter_obj->comparator;
					$advfilterval = html_entity_decode($advafilter_obj->value, ENT_QUOTES, $default_charset);
					$col = explode(":", $advafilter_obj->columnname);
					if(array_key_exists($advafilter_obj->comparator,$datetimestr))
					{ 
						//如果是本年明年，n天后等
						$temp_val[0]=$datetimestr[$advafilter_obj->comparator][0];
						$temp_val[1]=$datetimestr[$advafilter_obj->comparator][1];
					}else{
						$temp_val = explode(",", $advafilter_obj->value);
					}
					if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
						$val = Array();
						$advfilterval = implode("#", $temp_val);
					}
					$criteria['value'] = $advfilterval;
					$criteria['column_condition'] = $advafilter_obj->columncondition;
	
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
	}
	if (!empty($advft_criteria[$i - 1]['condition']))
		$advft_criteria[$i - 1]['condition'] = '';
	return $advft_criteria;
}

function getByModule_ColumnsHTML($module,$columnslist,$normal_id) {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,"");
	//$columnsList[getTranstab('Contacts')] = CustomView_Special::getAccountContact('Contacts',getCvadfilter($normal_id));
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

function getCvadfilter($normal_id)
{
    global $adb;
	$query = 'select advfilter,advfilter_grouping from ld_account_normal where id = ?';
	$result = $adb->pquery($query,array($normal_id));
	$advfilter = json_decode($adb->query_result($result,0,'advfilter'));
	foreach($advfilter as $obj){
		$array[] = $obj->columnname;
	}
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