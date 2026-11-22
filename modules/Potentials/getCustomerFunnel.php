<?php
//销售机会增加“老客户营销”字段
global $currentModule,$current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$select_arr = array();
$customView = CustomView::getInstance($currentModule);
$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView);
$viewid = $customView->getViewId($currentModule);
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
}
$page_list_query=$queryGenerator->getQuery('',1);
//销售阶段
$sales_satag_value = getSelectValueAndNum('sales_stage',$page_list_query);
$arr['sales_stage'] = array_keys($sales_satag_value);
foreach($sales_satag_value as $label => $cnt){
	$arr['sales_stage_count'][] = $cnt;
}
//老客户营销
$oldcustomer_marketing_value = getSelectValueAndNum('oldcustomer_marketing',$page_list_query);
$arr['oldcustomer_marketing'] = array_keys($oldcustomer_marketing_value);
foreach($oldcustomer_marketing_value as $label => $cnt){
	$arr['oldcustomer_marketing_count'][] = $cnt;
}

$smarty=new lingdangCRM_Smarty();
$arr['title']=getFixedLabel("Customerfunnel");
$_REQUEST['diony']='diony';
$content=$smarty->fetch('ListViewReport.tpl');
$arr['content'] = $content;
//dump($arr);
ConvertTojsonString(1,$arr,"success");


//获取下拉框内容和数量
function getSelectValueAndNum($columnname,$page_list_query){
	global $currentModule,$adb;
	$picklistvalues = array();
	$focus = CRMEntity::getInstance($currentModule);
	//$focus->getModuleLogic($currentModule);//->getListViewButtons();
	$moduleFields=$focus->fieldobj->getModuleFields();
	$field = $moduleFields[$columnname];
	if(!empty($field)){
		crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
		$picklistvalue=getAssignedPicklistValues($field->getColumnName(),'',$adb,array(),$field);
		foreach($picklistvalue as $val){
			if(!empty($val)){
				$data[$val] = '0(0%)';
				$picklistvalues[] = "'".$val."'";
			}
		}
	}
	if(!empty($picklistvalues)){
		$query = "select count(1) as cnt,$columnname from ld_potential
		INNER JOIN
		(
			$page_list_query
		) as tmp on tmp.potentialid = ld_potential.potentialid 
		where ld_potential.$columnname in (".implode(',',$picklistvalues).")
		GROUP BY $columnname order by FIELD($columnname,".implode(',',$picklistvalues).") ";
        //wyt_220706_XUQIU1000477_销售机会漏斗表 旁边显示各阶段的百分占比
        $result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		$other_num = 0;
        $totalcount=0;
        for($i = 0; $i < $num_rows; $i++){
            $cnt = $adb->query_result($result,$i,'cnt');
            $totalcount +=$cnt;
        }
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$label = $adb->query_result($result,$i,$columnname);
				$cnt = $adb->query_result($result,$i,'cnt');
                if($totalcount==0){
                    $percentage=0 ."%";
                }else{
                    $percentage=round(($cnt/$totalcount)*100,2) ."%";
                    $data[$label] = $cnt .'('.$percentage.')';
                }
            }
        }
    }
	return $data;
}
?>