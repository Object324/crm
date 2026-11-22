<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
$before_status = 'no';
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicLeads = new cls_PublicLeads($_REQUEST['frommodule']);
$data = $cls_PublicLeads->getPublicAccount();
if(!empty($data['status'])){
	$before_status = $data['status'];
}
$users = [];
if(!empty($data['administrators'])){
	$query = 'select id,last_name,wx_userid from ld_users where id in (' . $data['administrators'] . ')';
	$result = $adb->pquery($query, array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$userid = $adb->query_result($result,$i,'id');
			$last_name = $adb->query_result($result,$i,'last_name');
			$wx_userid = $adb->query_result($result,$i,'wx_userid');
			$userobj=new Users();
			$userobj->wx_userid=$wx_userid;
			$userobj->last_name=$last_name;
			$users[$userid] = getUserlastName($userobj);;
		}
	}
}else{
	//新建公海超级管理员默认值
	$users[1] = getUserFullName(1);
	$data['administrators'] = 1;
}
$public_account = $cls_PublicLeads->getPublicAccountConfig();
$account_pool = [];
if(!empty($public_account['public_account_pool'])){
	foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
		$account_pool[$pool_id] = $pool_info['pool_name'];
	}
}

//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(按角色控制 数量上限)
//普通客户数量上限 - 按角色控制
$commonaccount_role_limitaccount = $cls_PublicLeads->getCommonAccountRoleLimitCount();
$smarty->assign('COMMONACCOUNBT_ROLE_LIMITCOUNT',$commonaccount_role_limitaccount);

//自动回收规则设置
$sql="select ld_leads_set_rule.* from ld_leads_set_rule
inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (ld_tab.presence in(0,2) or tabname='Singin') and type='normal' ORDER BY type,sequence ";
$result=$adb->pquery($sql,array());
$nocompletechk='yes';
$normalcompletechk='no';
$completecondition = 'or';
$arr_complete_condition=array();
$arr_recovery_modules=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $modulename=$adb->query_result($result,$i,'tabname');
    $day=$adb->query_result($result,$i,'days');
    $type=$adb->query_result($result,$i,'type');
    $recyclelabelbols=explode("/",$adb->query_result($result,$i,'labelbol'));
    $singlelablebols=explode("/",$adb->query_result($result,$i,'singlelabelbol'));
    $status=$adb->query_result($result,$i,'status');
    $iscycle=$adb->query_result($result,$i,'iscycle');
    $condition=$adb->query_result($result,$i,'condition');
    if(empty($day)){
        $day="";
    }
    if(!in_array($modulename,$arr_recovery_modules)){
         $arr_recovery_modules[]=$modulename;
    }
    if($type=='normal'){
		$seqno=sizeof($arr_complete_condition)+1;
		$completecondition=$condition;
		//自动回收规则设置区块：普通客户参与回收，默认值修改
		if($data['show_account_rule'] != 'yes'){
			$day = '';$status = 'inactive';$iscycle = 'no';$completecondition = 'or';
			switch($modulename){
				case 'ContactRecords':
				   $status = 'active';
				   $day = 10;
				   $iscycle = 'yes';
				break;
				case 'Singin':
				    $day = 20;	
				break;
			
			}
			
		}
        $arr_complete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
            ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
            ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]
            ,'iscycle'=>$iscycle);
        
    }
}
if($data['account_rule_pool_id'] == ''){
	$data['account_rule_pool_id'] = $cls_PublicLeads->getDefaultPublicPool('pool_id');
}
$smarty->assign("ARRRECOVERYMODULES",json_encode($arr_recovery_modules));//参与回收的模块
$smarty->assign("COMPLETECONDITION",$completecondition);
$smarty->assign("ARRCOMPLETECONDITION",$arr_complete_condition);

$smarty->assign('ALL_POOL',$account_pool);
//ls 2021-09-06 【ID1001938】销售线索和客户模块，多公海“全部”页签增加默认值显示
$smarty->assign('ALL_ACCOUNT_TYPE',array(
    'ALLACCOUNT' =>getFixedLabel('theallincludeunassignedpool'),	//全部（含所有公海）
    'DEFAULTALLACCOUNT' =>getFixedLabel('thedefaultallincludeunassigned'),	//全部（含指定公海）
    'COMMONACCOUNT' => getFixedLabel('allexcludinghignseas'),	//全部（不含公海）
    'PUBLICALLOCATE' => getFixedLabel('LBL_PUBLICALLOCATE'),	//全部（含公海已分配）
    'NOALLOCATE' => getFixedLabel('LBL_NOALLOCATE')	//全部（含公海未分配）
));
$smarty->assign('USERS',$users);
$smarty->assign('BEFORE_STATUS',$before_status);
//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
$module='Leads';
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
$arr['foption']=$advfilterhtml;
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//线索公海参数设置帮助
$labels = array('PublicPoolParam');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Leads',1,'HelpUrl_'.$label);
}
//$arr['helpHtml'] = $helpHtmlArr;
if (!empty($helpHtmlArr['PublicPoolParam'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['PublicPoolParam'].'</div>';
}

$content=$smarty->fetch("modules/Leads/LeadsPublic.tpl");
$arr['title']=getFixedLabel("LBL_ACCOUNT_SET");
$arr['oktext']=getFixedLabel("SAVE");
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

	$sql = 'SELECT * FROM ld_leads_set_advfilter_grouping where pool_id = -1  ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array());
    $i = 1;
	$j = 0;
	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select ld_leads_set_advfilter.* from ld_leads_set_advfilter';
		$ssql.= " where groupid=? and pool_id = -1 order by ld_leads_set_advfilter.columnindex";

		$result = $adb->pquery($ssql, array($groupId,));
        
        
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0)
			return ;

		while ($relcriteriarow = $adb->fetch_array($result)) {
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
			$criteria['column_condition'] = $relcriteriarow["column_condition"];

			$advft_criteria[$i]['columns'][$j] = $criteria;
			$advft_criteria[$i]['condition'] = $groupCondition;
           
			$j++;
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
    $sql = "select columnname from ld_leads_set_advfilter where pool_id = -1";
    $result = $adb->pquery($sql,array());
    for ($i=0;$i<$adb->num_rows($result);$i++) {
        $array[$i] = $adb->query_result($result, $i, "columnname");
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