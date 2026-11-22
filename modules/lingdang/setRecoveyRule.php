<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();

$module=$_REQUEST['frommodule'];
$circletype = $_REQUEST['circletype'];
if($_REQUEST['mode'] == 'save'){
    $ruleinfo = $_REQUEST['ruleinfo'];

    crm_load_class_file('cls_AdvftOperate','include');
    $AdvftOperateobj = cls_AdvftOperate::getInstance($module);

    $ruleid = $_REQUEST['ruleid'];

    $advfilter = $ruleinfo['advfilter'];
    $advfilter_grouping = $ruleinfo['advfilter_grouping'];

    if(!empty($advfilter) && !empty($advfilter_grouping)){
        crm_load_class_file("AccountNormalSetCustomView",'modules/Accounts/AccountSet');
        crm_load_class_file("AccountNormalSetProductDetails",'modules/Accounts/AccountSet');
        $AccountSetCustomView=new AccountNormalSetCustomView($module,$advfilter,$advfilter_grouping);
        $AccountSetProductDetails=new AccountNormalSetProductDetails($module,$advfilter,$advfilter_grouping);
        $advfilter_arr = ldcrm_json_decode($advfilter);
        if($module == 'Accounts'){
            crm_load_class_file("AccountsQueryGenerator",'include/QueryGenerator');
            crm_load_class_file("AccountsSetQueryGenerator",'modules/Accounts/AccountSet');
            if(count($advfilter_arr)>0 && $advfilter_arr[0]['columnname'] != '')
            {
                $queryGenerator =new AccountsSetQueryGenerator($module, $current_user,$AccountSetCustomView,$AccountSetProductDetails);
                $queryGenerator->initForDefaultCustomView();
                $recycleselect= $queryGenerator->getQuery();
                $query = $recycleselect;
            }else{
                $query = '';
            }
        }else{
            crm_load_class_file("LeadsSetQueryGenerator",'modules/Leads/LeadsSet');
            if(count($advfilter_arr)>0 && $advfilter_arr[0]['columnname'] != '')
            {
                $queryGenerator =new LeadsSetQueryGenerator($module, $current_user,$AccountSetCustomView);
                $queryGenerator->initForDefaultCustomView();
                $query= $queryGenerator->getQuery();
            }
            else
            {
                $query='';
            }

        }
        $ruleinfo['recycleselect'] = $query;

        $advf_label = $AdvftOperateobj->TransAdvftTostring(json_decode(html_entity_decode($advfilter),true),json_decode(html_entity_decode($advfilter_grouping),true));
        $ruleinfo['advf_label'] = $advf_label;
    }else{
        $ruleinfo['recycleselect'] = '';
        $ruleinfo['advf_label'] = '';
    }
    //普通客户的回收规则
    if($circletype == 'normal'){
        $program_table = 'ld_account_normal';
        $program_table_index = 'id';
        $program_rule_table = 'ld_account_set_rule_normal';
        $program_rule_table_index = 'normal_id';
        $update_column_arr = ['active','description','recycleselect','pool_id','advfilter','advfilter_grouping','beforereminddays','transfer_users','objtainaccountcontroldays','programme_name','sequence'];

        $rule_update_column_arr = ['normal_id','tabname','condition','sequence','days','status','columnname','otherwhere','iscycle'];
        $rule_sql_update_column = ['normal_id','tabname','`condition`','sequence','days','`status`','columnname','otherwhere','iscycle'];

        if($module == 'Leads'){
            $program_table = 'ld_leads_normal';
            $program_rule_table = 'ld_leads_set_rule';
            $program_rule_table_index = 'programmeid';
            $rule_update_column_arr = ['programmeid','type','tabname','condition','sequence','days','status','columnname','otherwhere','iscycle'];
            $rule_sql_update_column = ['programmeid','type','tabname','`condition`','sequence','days','`status`','columnname','otherwhere','iscycle'];
        }

    }else{
        //公海客户的回收规则
        $program_table = 'ld_module_recovery_programme';
        $program_table_index = 'programmeid';
        $program_rule_table = 'ld_account_set_rule';
        $update_column_arr = ['active','modulename','description','recycleselect','pool_id','from_pool_id','beforereminddays','transfer_users','objtainaccountcontroldays','programme_name','sequence'];
        $program_rule_table_index = 'programmeid';
        $advft_table = 'ld_account_set_advfilter';
        $advft_group_table = 'ld_account_set_advfilter_grouping';

        $rule_update_column_arr = ['programmeid','type','tabname','condition','sequence','days','status','columnname','otherwhere','iscycle','pool_id'];
        $rule_sql_update_column = ['programmeid','type','tabname','`condition`','sequence','days','`status`','columnname','otherwhere','iscycle','pool_id'];
        $ruleinfo['modulename'] = $module;
        if($module == 'Leads'){
            $program_rule_table = 'ld_leads_set_rule';
            $advft_table = 'ld_leads_set_advfilter';
            $advft_group_table = 'ld_leads_set_advfilter_grouping';
        }
    }


    //保存方案基本信息
    if($ruleid > 0){
        $update_column = [];
        foreach ($update_column_arr as $tmp_column){
            $column_value[] = $ruleinfo[$tmp_column];
            $update_column[] = $tmp_column.' = ? ';
        }
        $column_value[] = $ruleid;

        $rule_sql = 'update '.$program_table.' set '.implode(',',$update_column).' where '.$program_table_index.' = ? ';
        $adb->pquery($rule_sql,$column_value);
        $new_ruleid = $ruleid;
    }else{
        $sql = 'SELECT count(1)+1 as new_seq from '.$program_table;
        $result = $adb->pquery($sql);
        if($adb->num_rows($result)>0){
            $ruleinfo['sequence'] = $adb->query_result($result,0,'new_seq');
        }
        $rule_sql = 'insert into '.$program_table.'('.implode(',',$update_column_arr).') value('.generateQuestionMarks($update_column_arr).')';
        $column_value = [];
        foreach ($update_column_arr as $tmp_column){
            $column_value[] = $ruleinfo[$tmp_column];
        }
        $adb->pquery($rule_sql,$column_value);

        $new_ruleid = $adb->getLastInsertID();

    }

    if($circletype == 'normal'){
        $ruleinfo['normal_id'] = $new_ruleid;
        $ruleinfo['programmeid'] = $new_ruleid;
    }else{
        $ruleinfo['programmeid'] = $new_ruleid;
    }
    //删除原有的规则信息
    $delete_sql = 'DELETE from '.$program_rule_table.' where '.$program_rule_table_index.' = ?';
    $adb->pquery($delete_sql,[$new_ruleid]);
    //保存规则信息

    $insert_sql = 'insert into '.$program_rule_table.'('.implode(',',$rule_sql_update_column).') values ('.generateQuestionMarks($rule_sql_update_column).')';
    $rule_arr = $ruleinfo['rule_arr'];
    foreach ($rule_arr as $tmp_info){
        if($tmp_info['show'] == 'no')continue;
        $column_value = [];
        if($circletype == 'normal'){
            $tmp_info['normal_id'] = $new_ruleid;
            $tmp_info['programmeid'] = $new_ruleid;
            $tmp_info['type'] = 'normal';
        }else{
            $tmp_info['programmeid'] = $new_ruleid;
            $tmp_info['pool_id'] = $ruleinfo['from_pool_id'];
            $tmp_info['type'] = 'complete';
        }
        if($tmp_info['tabname'] == '' || $tmp_info['tabname'] == 'null' || $tmp_info['tabname'] == 'undefined'){
            continue;
        }

        $tmp_info['columnname'] = 'createdtime';
        if($tmp_info['tabname'] == 'SalesOrder'){
            $tmp_info['otherwhere'] = ' and ifnull(ld_salesorder.sostatus,"")<>"已作废" ';
        }else if($tmp_info['tabname'] == 'ServiceContracts'){
            $tmp_info['otherwhere'] = ' and ifnull(ld_servicecontracts.contract_status,"")<>"已作废" ';
        }else{
            $tmp_info['otherwhere'] = '';
        }

        foreach ($rule_update_column_arr as $tmp_column){
            $column_value[] = $tmp_info[$tmp_column];
        }
        $adb->pquery($insert_sql,$column_value);
    }

    if($circletype == 'public'){
        $sql="delete from ".$advft_table." where programmeid = ? ";
        $adb->pquery($sql,array($new_ruleid));
        $sql="delete from ".$advft_group_table." where programmeid = ?";
        $adb->pquery($sql,array($new_ruleid));

        if(!empty($advfilter)){
            $advfilterlist = ldcrm_json_decode($advfilter);
            $advfiltergroup=ldcrm_json_decode($advfilter_grouping);
            $index=1;
            for($i=0;$i<count($advfilterlist);$i++){
                $query="INSERT INTO ".$advft_table." (groupid,columnindex,columnname,comparator,value,column_condition,pool_id,programmeid) VALUES(?,?,?,?,?,?,?,?)";
                $groupid= $advfilterlist[$i]['groupid'];
                if($advfilterlist[$i]['columnname']==''){
                    continue;
                }
                $params=array(
                    $advfilterlist[$i]['groupid'],
                    $index++,
                    $advfilterlist[$i]['columnname'],
                    $advfilterlist[$i]['comparator'],
                    $advfilterlist[$i]['value'],
                    $advfilterlist[$i]['columncondition'],
                    $ruleinfo['from_pool_id'],
                    $new_ruleid
                );
                $adb->pquery($query,$params);

            }

            foreach($advfiltergroup as $groupid=>$groupinfo){

                if(empty($groupinfo)) continue;
                //if(empty($groupinfo["conditionexpression"])) continue;
                $sql='insert into '.$advft_group_table.'(groupid,group_condition,condition_expression,pool_id,programmeid)value(?,?,?,?,?)';
                $adb->pquery($sql,array($groupid,$groupinfo['groupcondition'],$groupid-1,$ruleinfo['from_pool_id'],$new_ruleid));
            }
        }
    }

    unset($ruleinfo['recycleselect']);
    $arr['ruleid'] = $new_ruleid;
    $arr['ruleinfo'] = $ruleinfo;

    ConvertTojsonString(1,$arr,"success");
}

//数据分类开始
crm_load_class_file('CommonView',"modules/CustomView");
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
//$content=$smarty->fetch("Accounts/setNormalAccountBasicSearch.tpl");
//BUG0054926 wyt 公海参数设置，启用公海回收规则，点击“回收条件”，弹出层标签显示“回收方案”，点击“回收规则”，弹出层标签显示“回收条件”。预期结果：标签应该对应显示，避免造成歧义
$arr['title']=getFixedLabel("recoveryconditions");

$labelbol_arr = ['ENABLERECYCLINGSCHEME','SEACUSTOMERSRECYCLINGSCHEME','REGULARCUSTOMERSRECYCLINGSCHEME','BASICINFO','recoveryconditions','recyclingrules','Businessrules',
    'recyclingtothehighseas','SCHEMEDESCRIPTION','SCHEMENAME','ADDRECYCLINGRULES','RULETYPE','INTERVALDAYS','BillType','NORMALCUSTOMRECYCLE','RECYCLERULE','SINGLERULE',
    'SINGLERULELABEL','CIRCLERULELABEL','LOGICALRELATION','OR','SEARCHAND','WHETHERTOENABLE','OPERATING','oneoftherulesmustbedone','alltherulesmustbedone','ObjtainAccountControlDays',
    'BEFOREREMINDDAYSCUSTOMER','AUTOMATICRECOVERYMODIFYOWNER','SETTINGS','CONDITION','RECYCLINGSCOPE'];
$fieldlabel_arr = [];
foreach ($labelbol_arr as $tmp_label){
    $fieldlabel_arr[$tmp_label] = getFixedLabel($tmp_label);
}
//根据模块和回收方案类型修改文本描述
$transfer_label = [];
if($module == 'Leads'){
    $transfer_label = [
        'NORMALCUSTOMRECYCLE'=>'CommonLeadsParticipateInRecycling',
        'BEFOREREMINDDAYSCUSTOMER'=>'HowManyDaysBeforeLeadRecoveryToRemindOfLeads',
        'ObjtainAccountControlDays'=>'OBJTAINLEADCONTROLDAYS',
        ];
    if($circletype == 'public'){
        $transfer_label = ['NORMALCUSTOMRECYCLE'=>'HighSeasSalesLeadsParticipateInRecycling'];
    }
}else{
    if($circletype == 'public'){
        $transfer_label = ['NORMALCUSTOMRECYCLE'=>'COMPLETEAUTOMATICRECOVERYRULE'];
    }
}
foreach ($transfer_label as $old_labelbol => $new_labelbol){
    $fieldlabel_arr[$old_labelbol] = getFixedLabel($new_labelbol);
}


$arr['fieldlabel_arr'] = $fieldlabel_arr;
$arr['arrJsPopupLabel'] = array('and'=>getFixedLabel('SEARCHAND'),'or'=>getFixedLabel('OR'),
    'none'=>getFixedLabel('NONE'),
);

//获取可用的相关信息列表
if($module == 'Accounts'){
    $columnname = 'accountid';
}else if($module == 'Leads'){
    $columnname = 'leads_id';
}
$sql = "SELECT ld_tab.`name` as `key`,ld_tranlabel.fieldlabel as `label` from ld_field 
INNER JOIN ld_tab on ld_field.tabid = ld_tab.tabid
INNER JOIN ld_tranlabel on ld_tab.tabid = ld_tranlabel.tabid and ld_tranlabel.Relateid = ld_tab.tabid and ld_tranlabel.trantable = 'ld_tab'
where (ld_field.columnname = ? or (ld_tab.`name`='Singin' and ld_field.columnname = 'source_list' ))  and ld_tranlabel.languagetype = 'zh' 
and ld_field.presence in (0,2) and ld_tab.presence in (0,2) and ld_tab.`name` not in ('ServiceCharge') ORDER BY ld_tab.tabsequence";
$result = $adb->pquery($sql,[$columnname]);

$all_result = [];
if($adb->num_rows($result)>0){
    $all_result = $adb->query_result_all($result);
}
$arr['all_relation'] = $all_result;

$arr['language_type'] = getLanguageType($current_user);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
//$arr['content']=$content;
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