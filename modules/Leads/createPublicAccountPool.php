<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$languageType;
$smarty=new lingdangCRM_Smarty();
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicAccounts = new cls_PublicLeads('Leads');
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
//公海参数设置帮助
$labels = array('PublicPoolParam');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel($module,1,'HelpUrl_'.$label);
}
if (!empty($helpHtmlArr['PublicPoolParam'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['PublicPoolParam'].'</div>';
}
//设置修改公海池
if(!empty($_REQUEST['getlist']) && $_REQUEST['getlist'] == 'yes'){
	$account_pool = [];
	if(!empty($public_account['public_account_pool'])){
		foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
			$administrators_arr = explode(',',$pool_info['administrators']);
			if($pool_info['allowget'] == 'yes' && !in_array($current_user->id,$administrators_arr)){
				$accounttype = 'PUBLICALLOCATE';
			}else{
				$accounttype = 'NOALLOCATE';
			}
			$account_pool[$pool_id] = array(
				'pool_name' => $pool_info['pool_name'],
				'accounttype' => $accounttype,
				'default_pool'=> $pool_info['default_pool'],
			);
		}
	}
	$smarty->assign('DATA',$account_pool);
    $smarty->assign('IS_ADMIN',is_admin($current_user));
	$_REQUEST['diony']='diony';
	$content=$smarty->fetch("modules/Leads/viewPublicLeadsPool.tpl");
	$arr['title']=getFixedLabel("Edittheunassignedpool");
	$arr['oktext']=getFixedLabel("CONFIRME");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$arr['content']=$content;
	ConvertTojsonString(1,$arr,"success");
}
//设置默认公海池
if(!empty($_REQUEST["setdefaultpool"]) && $_REQUEST["setdefaultpool"]== "yes"){
	$emptydefault_sql = "UPDATE ld_leads_public_pool SET default_pool = ?";
	$adb->pquery($emptydefault_sql,array(''));
	if($_REQUEST['cheakstatus'] == 'true'){
		$updatedefault_sql = "UPDATE ld_leads_public_pool SET default_pool = ? where id = ?";
		$adb->pquery($updatedefault_sql,array('yes',$_REQUEST['pool_id']));
	}
	unsetCache('public_leads_pool');//清除公海缓存
	ConvertTojsonString(1,$arr,"success");
}
//公海池排序
if(!empty($_REQUEST["sortpublicpool"]) && $_REQUEST["sortpublicpool"]== "yes"){
	$pool_ids_arr = explode(";",$_REQUEST["pool_ids_str"]);
	$updateseq_sql = "UPDATE ld_leads_public_pool SET `sequence` = ? where id = ?";
	for($i=0 ;$i<count($pool_ids_arr);$i++){
        if(!empty($pool_ids_arr[$i])){
            $adb->pquery($updateseq_sql, array(($i+1),$pool_ids_arr[$i]));
        }
    }
	unsetCache('public_leads_pool');//清除公海缓存
	ConvertTojsonString(1,$arr,"success");
}
$pool_id = 0;
if(!empty($_REQUEST['pool_id'])){
	$pool_id = $_REQUEST['pool_id'];	//公海池id
	$query = "select id,zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,
	userid_after_transfer,userid_after_release,create_buttons,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid,modifiedtime,modifiedby,recycleselect,allow_users,transfer_users,
    poolmember_show_noallocate from ld_leads_public_pool where id = ? and deleted = 0";
	$result = $adb->pquery($query,array($pool_id));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$pool_id = $adb->query_result($result,$i,'id');
			$limit_type = $adb->query_result($result,$i,'limit_type');
			$administrators = $adb->query_result($result,$i,'administrators');	//公海管理员
			$administrators_lastname = array();
			if(!empty($administrators)){
				$administrators_array = explode(',',$administrators);
				foreach($administrators_array as $userid){
						$administrators_lastname[$userid] = getUserFullName($userid);
				}
			}
			$allow_users = $adb->query_result($result,$i,'allow_users');	//允许“公海分配”的成员
			$allow_users_lastname = array();
			if(!empty($allow_users)){
				$allow_users_array = explode(',',$allow_users);
				foreach($allow_users_array as $userid){
						$allow_users_lastname[$userid] = getUserFullName($userid);
				}
			}
			$transfer_users = $adb->query_result($result,$i,'transfer_users');	//允许“转换公海”的成员
			$transfer_users_lastname = array();
			if(!empty($transfer_users)){
				$transfer_users_array = explode(',',$transfer_users);
				foreach($transfer_users_array as $userid){
						$transfer_users_lastname[$userid] = getUserFullName($userid);
				}
			}
			$userid_after_transfer = $adb->query_result($result,$i,'userid_after_transfer');
			$userid_after_release = $adb->query_result($result,$i,'userid_after_release');
			$create_buttons = $adb->query_result($result,$i,'create_buttons');
			$pool_data= array(
				'zh_name' => $adb->query_result($result,$i,'zh_name'),	//公海名称中文
				'en_name' => $adb->query_result($result,$i,'en_name'),	//公海名称英文
				'limit_count' => $adb->query_result($result,$i,'limit_count'),	//公海已分配客户上线
				'limit_type' => $limit_type,	//公海已分配上线 1按成员 2按角色
				'administrators' => $administrators,	//公海管理员
				'administrators_lastname' => $administrators_lastname,	//公海管理员
				'userids' => $adb->query_result($result,$i,'userids'),	//公海成员
				'usertype' => $adb->query_result($result,$i,'usertype'),	//公海成员类型 all所有 group 部门 user 用户
				'dataprofile' => $adb->query_result($result,$i,'dataprofile'),	//公海未分配客户不允许领取（只能由公海管理员分配） 
				'allowget' => $adb->query_result($result,$i,'allowget'),	//公海未分配客户不控制数据权限（可查询所有公海未分配客户） 
				'allow_unallocated_showinall' => $adb->query_result($result,$i,'allow_unallocated_showinall'),	//允许公海未分配客户显示在“全部（含指定公海）”列表 
				'allow_allocated_showinall' => $adb->query_result($result,$i,'allow_allocated_showinall'),	// 允许公海已分配客户显示在“全部（含指定公海）”列表 
				'allow_trasnfer_others' => $adb->query_result($result,$i,'allow_trasnfer_others'),	//允许公海成员将已分配或领取的公海客户转移到其他公海 
				'userid_after_transfer' => $userid_after_transfer,	//客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
				'userid_after_transfer_lastname' => getUserFullName($userid_after_transfer),
				'userid_after_release' => $userid_after_release,	//公海已分配客户释放后，更改客户负责人为（为空表示不更改）
				'userid_after_release_lastname' => getUserFullName($userid_after_release),
				'create_buttons' => explode(',',$create_buttons),	//公海成员客户序时簿“新建”功能下拉选项
				'beforereminddays' => $adb->query_result($result,$i,'beforereminddays'),	//客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） 
				'objtainaccountcontroldays' => $adb->query_result($result,$i,'objtainaccountcontroldays'),	//客户被自动回收后天内不允许被当前销售负责人再次领取（为0或空表示不控制） 
				'recycleselect' => $adb->query_result($result,$i,'recycleselect'),	//公海回收条件sql
				'createdtime' => $adb->query_result($result,$i,'createdtime'),
				'smcreatorid' => $adb->query_result($result,$i,'smcreatorid'),
				'modifiedtime' => $adb->query_result($result,$i,'modifiedtime'),
				'modifiedby' => $adb->query_result($result,$i,'modifiedby'),
				'allow_users' => $allow_users,	//允许“公海分配”的成员
				'allow_users_lastname' => $allow_users_lastname,	//允许“公海分配”的成员
				'transfer_users' => $transfer_users,	//允许“转换公海”的成员
				'transfer_users_lastname' => $transfer_users_lastname,	//允许“转换公海”的成员
                'poolmember_show_noallocate' => $adb->query_result($result,$i,'poolmember_show_noallocate'),	//允许公海成员查看“公海未分配”列表
			);
		}
	}
}else{
	//公海池新建默认值
    $pool_data['dataprofile']='yes';//edit:can 20210826 046733: （新建账套）销售线索和客户模块，公海参数设置中“ 不控制公海未分配客户的数据权限，允许查询所有公海未分配客户”参数默认勾选
	$pool_data['administrators'] = 1;
	$pool_data['administrators_lastname'] = getUserFullName(1);
	$pool_data['limit_count'] = 100;
	$pool_data['limit_type'] = 'user';
	$pool_data['create_buttons'] = array('NOALLOCATE');
	$pool_data['objtainaccountcontroldays'] = 7;
	$pool_data['beforereminddays'] = 3;
}

$smarty->assign('POOLDATA',$pool_data);
//公海已分配客户数量上限 - 按角色控制
$account_role_limitaccount = $cls_PublicAccounts->getAccountRoleLimitCount($pool_id);
$smarty->assign('ACCOUNBT_ROLE_LIMITCOUNT',$account_role_limitaccount);
$buttonarray['NOALLOCATE'] = getFixedLabel('LBL_NOALLOCATE');	//公海未分配
$buttonarray['PUBLICALLOCATE'] = getFixedLabel('LBL_PUBLICALLOCATE');	//公海已分配
$smarty->assign('buttonarray',$buttonarray);
$smarty->assign('buttontype',explode(',',$buttontype));

//自动回收规则设置
$sql="select ld_leads_set_rule.* from ld_leads_set_rule
inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (ld_tab.presence in(0,2) or tabname='Singin') and pool_id = ? and type='complete' ORDER BY type,sequence ";
if(empty($pool_id))
	$result=$adb->pquery($sql,array(1));
else
	$result=$adb->pquery($sql,array($pool_id));
$nocompletechk='yes';
$normalcompletechk='no';
$completecondition = 'and';
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
    if($type=='complete'){
		$seqno=sizeof($arr_complete_condition)+1;
		$completecondition=$condition;
		//自动回收规则设置区块：公海客户参与回收，默认值修改
		if(empty($pool_id)){
			$day = '';$status = 'inactive';$iscycle = 'no';$completecondition = 'or';
			switch($modulename){
				case 'ContactRecords':
				   $status = 'active';
				   $day = 10;
				   $iscycle = 'yes';
				break;
				case 'Singin':
				    $day = 20;	
				
			}
		}
        $arr_complete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
            ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
            ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]
            ,'iscycle'=>$iscycle);
        
    }
}
$smarty->assign("ARRRECOVERYMODULES",json_encode($arr_recovery_modules));//参与回收的模块
$smarty->assign("COMPLETECONDITION",$completecondition);
$smarty->assign("ARRCOMPLETECONDITION",$arr_complete_condition);

$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('POOL_ID',$pool_id);
//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
$module='Leads';
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);
$advfilterlist = getAdvFilter($pool_id);
$arr['columns_block'] = getByModule_ColumnsHTML($module,$modulecollist,$pool_id);//高级查询select option

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
$content=$smarty->fetch("modules/Leads/createPublicLeadsPool.tpl");
//chj 2020/12/25 43956: 编辑旧公海：弹出层窗口显示为“新建公海”
if(!empty($_REQUEST['pool_id'])){
	$arr['title']=getFixedLabel("ModifyParameters");
}else{
	$arr['title']=getFixedLabel("createpublicaccountpool");
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");


/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilter($pool_id) {

	global $adb,  $default_charset;
	if(empty($pool_id))return '';
	$advft_criteria = array();

	$sql = 'SELECT * FROM ld_leads_set_advfilter_grouping where pool_id = ?  ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array($pool_id));
    $i = 1;
	$j = 0;
	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select ld_leads_set_advfilter.* from ld_leads_set_advfilter';
		$ssql.= " where groupid=? and pool_id = ? order by ld_leads_set_advfilter.columnindex";

		$result = $adb->pquery($ssql, array($groupId,$pool_id));
        
        
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

function getByModule_ColumnsHTML($module,$columnslist,$pool_id) {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,"");
	$columnsList[getTranstab('Contacts')] = CustomView_Special::getAccountContact('Contacts',getCvadfilter($pool_id)); 
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

function getCvadfilter($pool_id)
{
    global $adb;
    $sql = "select columnname from ld_leads_set_advfilter where pool_id = ?";
    $result = $adb->pquery($sql,array($pool_id));
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