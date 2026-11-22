<?php
global $currentModule,$current_user,$adb;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$focus = CRMEntity::getInstance($currentModule);
$focus->getModuleLogic($currentModule);//->getListViewButtons();
$moduleFields=$focus->fieldobj->getModuleFields();

$customView = CustomView::getInstance($currentModule);
$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView);
$viewid = $customView->getViewId($currentModule);
$tabid= getTabid($currentModule);
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
}
//$page_list_query=$queryGenerator->getQuery('','groupby');
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$all_prev_advance_fieldname_value = array();
$cur_advance_columnname = $cls_module_advance->moduleadvance['module_field'];

//zxm 20230523 kfbcrm BUG0066412   服务收费管理---进度漏斗---点击打开速度很慢
$depency_sql = "select sourcefield from ld_picklist_dependency where tabid=? and targetfield=? ";
$depency_res = $adb->pquery($depency_sql,array($tabid,$cur_advance_columnname));
$depency_nums = $adb->num_rows($depency_res);
$sourcefield = "";
//是级联字段 且有上级字段
if ($depency_nums>0) {
    crm_load_function_file("getAllPickListValues",'modules/PickList','PickListUtils');
    $sourcefield = $adb->query_result($depency_res,0,'sourcefield');
    //上级字段的所有下拉框值
    $all_prev_advance_fieldname_value = getAllPickListValues($sourcefield);
}
//索引数组
$all_prev_advance_fieldname_value_index = array_values($all_prev_advance_fieldname_value);
$prev_advance_fieldlabel = '';
if($cls_module_advance->moduleadvance['method'] == 'field') {
    //BUG20240906-49 需要修改成：需要默认选一个选项，例如潜在客户，显示漏斗界面和数据；下拉框可选
    $select_stage_value = empty($_REQUEST['select_stage_value'])?$all_prev_advance_fieldname_value_index[0]:$_REQUEST['select_stage_value'];
    //根据当前字段名 和 上级字段值 获取当前字段下拉框值
    $advance_stage_values = $cls_module_advance->getAdvanceStageValuesBysourcevalue($cls_module_advance->moduleadvance['module_field'],$select_stage_value);
    if($sourcefield&&!empty($select_stage_value)) {
        $fieldobj = $focus->fieldobj->getFieldInfoobjBykey("fieldname", $sourcefield);
        //zxm 20231019 直接把上级字段拼接到高级查找条件中  且的关系
        $temparr_advance['searchtype'] = 'advance';
        $temparr_advance['advft_criteria'] = '[{"groupid":"1","columnname":"'.$focus
            ->table_name.':'.$fieldobj->getColumnName().':'.$fieldobj->getFieldName().':'.$focus->module_name.'_fieldlabel:V","comparator":"e","value":"'.$select_stage_value.'","columncondition":""}]';
        $temparr_advance['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
        $queryGenerator->addUserSearchConditions($temparr_advance);
    }
}else{
	$fieldname = 'advance_stage';
	$startdate = date('Y').'-01-01';
	$enddate = date('Y').'-12-31';
	$s = strtotime($startdate);
	$e = strtotime($enddate);
	for($i=0; $i<12; $i++){    
		$d = mktime(0,0,0,date('m',$s)+$i,date('d',$s),date('Y',$s));
		$advance_stage_values[] = date('Y-m',$d);
	}
}
$page_list_query=$queryGenerator->getQuery('','groupby');
$arr['list'] = $all_prev_advance_fieldname_value;//级联字段  当前级联字段的父联字段所有的值   为空不显示
$arr['prev_advance_fieldlabel'] = $prev_advance_fieldlabel;

$tablename = $focus->table_name;
$table_index = $focus->table_index;
$customFieldTable = $focus->customFieldTable;
//edit: xll 2023/07/26 BUG0070110 kfbcrm-财务管理-收款计划-统计报表显示数据错误
//$state_fieldname = 'advance_stage';
//edit: xll 2023/08/04 进度漏斗的统计字段取决于推进设置的字段---你取出来的是fieldname,实际去表里用的是columnname
$state_fieldname = $cls_module_advance->moduleadvance['module_field'];//zxm 20231024 这个得到的是fieldname,字段名字是columnname
$fieldinfo = $moduleFields[$state_fieldname];
$columnname = $fieldinfo->getColumnName();

$query = "select $columnname,count(1) as cnt from $tablename left join $customFieldTable[0] on $customFieldTable[0].$customFieldTable[1] = $tablename.$table_index where $tablename.$table_index in($page_list_query) 
		and deleted = 0 group by $columnname";

$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
$other_num = 0;
$totalcount=0;
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$label = $adb->query_result($result,$i,strtolower($columnname)); //结果的键值为小写
		$cnt = $adb->query_result($result,$i,'cnt');
        //if(!empty($label)){
        //指定日期  - 其他
			if(in_array($label,$advance_stage_values)){
				$stage_cnt[$label] = $cnt;
                $totalcount +=$adb->query_result($result,$i,'cnt');
            }else{
				$other_num += $cnt;
            }

        //}
	}
}
//$smarty=new lingdangCRM_Smarty();
if($cls_module_advance->moduleadvance['method'] == 'period'){
	$advance_stage_values[] = getFixedLabel('othercc');
	$stage_cnt[getFixedLabel('othercc')] = $other_num;
}
$data['title'] = $advance_stage_values;
//wyt_220706_XUQIU1000477_销售机会漏斗表 旁边显示各阶段的百分占比
foreach($advance_stage_values as $key => $stage){

    if(!empty($stage_cnt[$stage])){
        $data['count'][$key] = $stage_cnt[$stage];
    }else{
		$data['count'][$key] = 0;
    }
    if($totalcount==0){
        $percentage[]=0 ."%";
    }
    else{
        $percentage[]=round(($data['count'][$key]/$totalcount)*100,2) ."%";
    }
    $data['clickvalue'][$key] = 0;
}
$data['totalcount']=$percentage;
$arr['stage_values']=$data;
$arr['title']=getFixedLabel("PropelledFunnel");
$_REQUEST['diony']='diony';
//$content=$smarty->fetch('ListViewReport.tpl');
//$arr['content'] = $content;
ConvertTojsonString(1,$arr,"success");
?>