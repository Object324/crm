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
global $current_user,$languageType;
$smarty=new lingdangCRM_Smarty();
$module = $_REQUEST['frommodule'];
$tabid = getTabid($module);

if($module == 'Accounts'){
    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
    $cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
    $public_account = $cls_PublicAccounts->getPublicAccountConfig();

    $public_pool_table = 'ld_account_public_pool';
}else{
    crm_load_class_file('cls_PublicLeads', 'modules/Leads');
    $cls_PublicAccounts = new cls_PublicLeads($module);

    $public_account = $cls_PublicAccounts->getPublicAccountConfig();

    $public_pool_table = 'ld_leads_public_pool';
}

$pool_id = 0;
if(!empty($_REQUEST['pool_id'])){
	$pool_id = $_REQUEST['pool_id'];	//公海池id
	$query = "select id,zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,
	userid_after_transfer,userid_after_release,create_buttons,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid,modifiedtime,modifiedby,recycleselect,allow_users,transfer_users,poolmember_show_noallocate,default_pool from ".$public_pool_table." where id = ? and deleted = 0";
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
                    $administrators_lastname[] = ['userid'=>$userid,'last_name'=>getUserFullName($userid)];
				}
			}
			$allow_users = $adb->query_result($result,$i,'allow_users');	//允许“公海分配”的成员

			if(!empty($allow_users)){
                $allow_users_lastname = array();
				$allow_users_array = explode(',',$allow_users);
				foreach($allow_users_array as $userid){
				    $allow_users_lastname[$userid] = getUserFullName($userid);
				}
			}else{
                $allow_users_lastname = '';
            }
			$transfer_users = $adb->query_result($result,$i,'transfer_users');	//允许“转换公海”的成员

			if(!empty($transfer_users)){
                $transfer_users_lastname = array();
				$transfer_users_array = explode(',',$transfer_users);
				foreach($transfer_users_array as $userid){
				    $transfer_users_lastname[$userid] = getUserFullName($userid);
				}
			}else{
                $transfer_users_lastname = '';
            }
			$userid_after_transfer = $adb->query_result($result,$i,'userid_after_transfer');
			$userid_after_release = $adb->query_result($result,$i,'userid_after_release');
			$create_buttons = (string)$adb->query_result($result,$i,'create_buttons');
			$pool_data= array(
			    'id' => $pool_id,
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
				//'recycleselect' => $adb->query_result($result,$i,'recycleselect'),	//公海回收条件sql
				'createdtime' => $adb->query_result($result,$i,'createdtime'),
				'smcreatorid' => $adb->query_result($result,$i,'smcreatorid'),
				'modifiedtime' => $adb->query_result($result,$i,'modifiedtime'),
				'modifiedby' => $adb->query_result($result,$i,'modifiedby'),
				'allow_users' => $allow_users,	//允许“公海分配”的成员
				'allow_users_lastname' => $allow_users_lastname,	//允许“公海分配”的成员
				'transfer_users' => $transfer_users,	//允许“转换公海”的成员
				'transfer_users_lastname' => $transfer_users_lastname,	//允许“转换公海”的成员
                'poolmember_show_noallocate' => $adb->query_result($result,$i,'poolmember_show_noallocate'),	//允许公海成员查看“公海未分配”列表
                'default_pool' =>$adb->query_result($result,$i,'default_pool'),
			);
			foreach ($pool_data as &$pooldata_value){
			    if($pooldata_value===null)$pooldata_value='';
            }
		}
	}
}else{
	//公海池新建默认值
    $pool_data['dataprofile']='yes';//edit:can 20210826 046733: （新建账套）销售线索和客户模块，公海参数设置中“ 不控制公海未分配客户的数据权限，允许查询所有公海未分配客户”参数默认勾选
	$pool_data['administrators'] = '1';
	$pool_data['administrators_lastname'] = [['userid'=>1,'last_name'=>getUserFullName(1)]];
	$pool_data['limit_count'] = 100;
	$pool_data['limit_type'] = 'user';
	$pool_data['create_buttons'] = array('NOALLOCATE');
	$pool_data['objtainaccountcontroldays'] = 7;
	$pool_data['beforereminddays'] = 3;
	$pool_data['usertype'] = 'all';
    $pool_data['id'] = -1;
    $pool_data['zh_name'] = '';
    $pool_data['en_name'] = '';
    $pool_data['active'] = 'yes';
    $pool_data['userid_after_transfer_lastname'] = '';
    $pool_data['userid_after_release_lastname'] = '';

}
$arr['pool_data'] = $pool_data;

//公海已分配客户数量上限 - 按角色控制
$public_role_limitaccount = $cls_PublicAccounts->getAccountRoleLimitCount($pool_id);
$arr['public_role_limitaccount'] = $public_role_limitaccount;

$buttonarray['NOALLOCATE'] = getFixedLabel('LBL_NOALLOCATE');	//公海未分配
$buttonarray['PUBLICALLOCATE'] = getFixedLabel('LBL_PUBLICALLOCATE');	//公海已分配

$arr['buttonarray'] = $buttonarray;


crm_load_class_file('cls_AdvftOperate','include');
$AdvftOperateobj = cls_AdvftOperate::getInstance($module);
//公海回收方案
$public_recovey_rule = array();

if($pool_id > 0){
    $query = "select * from ld_module_recovery_programme where from_pool_id = ? and modulename=? order by sequence";
    $result = $adb->pquery($query,array($pool_id,$module));
    $num_rows = $adb->num_rows($result);
}else{
    $num_rows = 0;
}

if($num_rows >= 1){
    for($i = 0; $i < $num_rows; $i++){
        $id = $adb->query_result($result,$i,'programmeid');
        $all_advft_arr = getAdvFilter($module,$pool_id,$id);

        $advfilter = $all_advft_arr['advft_criteria'];
        $advfilter_grouping = $all_advft_arr['advft_criteria_groups'];

        $advf_label = $AdvftOperateobj->TransAdvftTostring($advfilter,$advfilter_grouping);
        //$advf_label = str_replace('<br>','',$advf_label);
        $transfer_users = $adb->query_result($result,$i,'transfer_users');
        $transfer_users_label = getUserFullName($transfer_users);

        $public_recovey_rule[] = array(
            'programme_name' => $adb->query_result($result,$i,'programme_name'),
            'programmeid' => $id,
            'active' => $adb->query_result($result,$i,'active'),
            'from_pool_id' => $adb->query_result($result,$i,'from_pool_id'),
            'pool_id' => $adb->query_result($result,$i,'pool_id'),
            'advfilter' => ldcrm_json_encode($advfilter),
            'advfilter_grouping' => ldcrm_json_encode($advfilter_grouping),
            'advf_label' => $advf_label,
            'description' => $adb->query_result($result,$i,'description'),
            'rule_arr' => getAccountPublicRule($module,$id),
            'beforereminddays' => $adb->query_result($result,$i,'beforereminddays'),
            'transfer_users' => $transfer_users,
            'transfer_users_label' => $transfer_users_label,
            'objtainaccountcontroldays' => $adb->query_result($result,$i,'objtainaccountcontroldays')
        );
    }
    $arr['public_recovey_rule'] = $public_recovey_rule;
}else{
    $arr['public_recovey_rule'] = '';
}



$labelbol_arr = ['Name(ZH)','Name(EN)','BASICINFO','Pleasesettheadministrators','Mangers','MEMBERNAME','SUPERADMINISTRATORHASALLPERMISSIONS','ALLTHEUSERS','SETBYDEPARTMENT','SETBYUSERS',
    'SEASMEMBERSSCOPEOFRELEASE','Members','RELEASESELF','NOTALLOWEDRELEASE','UNALLOCATECUSTOMERADMIN','ISSHOWUNALLOCATEDHIGHSEAS','Allowuserstotransfertheallocatedcustomerstootherseas',
    'NOLIMITS','ACCORDINGTOTHEUSEREACH','Accordingtotherolcontrol','recoveryconditions','recyclingrules','createecyclingscheme','SCHEMEDESCRIPTION','WHETHERTOENABLE','OPERATING',
    'recyclingscheme','CYCLENOCREATEDDAYS','SINGLENOCREATEDDAYS','maximumnumberofhighseascustomers','PROFILES','Themaximumnumberofhighseascustomers','addrulecomments','Businessrules',
    'CUSTOMERCONTROLPUBLIC','Allowtheunallocatedcustomerstobedisplayedinalllist','Allowtheallocatedcustomerstobedisplayedinalllist','AFTERCONVERTINGMODIFYTHEOWNER','AFTERCONVERTINGMODIFYTHEOWNERDES','AFTERRELEASINGTHEALLOCATEDHIGNSEASDES',
    'NEWBUTTONDROP-DOWNOPTIONS','AFTERRELEASINGTHEALLOCATEDHIGNSEAS','ADMIN','LBL_PROFILES','DistributionRules','Pleaseentername'];
$fieldlabel_arr = [];
foreach ($labelbol_arr as $tmp_label){
    $fieldlabel_arr[$tmp_label] = getFixedLabel($tmp_label);
}
if($module == 'Leads'){
    $transfer_label = [
        'UNALLOCATECUSTOMERADMIN'=>'UnallocateLeadsAdmin',
        'Allowuserstotransfertheallocatedcustomerstootherseas'=>'AllowUsersToTransferTheAllocatedLeadsToOtherSeas',
        'maximumnumberofhighseascustomers'=>'MaximumNumberOfAssignedLeadsInHighSeas',
        'Allowtheunallocatedcustomerstobedisplayedinalllist'=>'AllowTheUnallocatedLeadsToBeDisplayList',
        'Allowtheallocatedcustomerstobedisplayedinalllist'=>'AllowTheAllocatedLeadsToBeDisplayList',
        'AFTERCONVERTINGMODIFYTHEOWNER'=>'AfterConvertingModfyTheLeadsOwner',
        'NEWBUTTONDROP-DOWNOPTIONS'=>'NewButtonDropDownOptionsOfLeads',
        'AFTERCONVERTINGMODIFYTHEOWNERDES'=>'AfterConvertingModfyTheLeadsOwnerDES',
        'AFTERRELEASINGTHEALLOCATEDHIGNSEASDES'=>'AfterReleasignTheAllocatedHighSeasOfLeadsDES',
        'AFTERRELEASINGTHEALLOCATEDHIGNSEAS'=>'AfterReleasignTheAllocatedHighSeasOfLeads','ADMIN','LBL_PROFILES'];
    foreach ($transfer_label as $old_labelbol => $new_labelbol){
        $fieldlabel_arr[$old_labelbol] = getFixedLabel($new_labelbol);
    }
}

$arr['fieldlabel_arr'] = $fieldlabel_arr;
//所有的权限设置
$sql = 'SELECT actionid,actionname,actionlabel from ld_actionmapping where actionname in ("turnhighseas","transfercustomer","allocate","delay","release","displayeunallocated") 
        order by field(actionname,"turnhighseas","transfercustomer","Allocate","delay","release","displayeunallocated")';
$result = $adb->query($sql);
$all_actionid_arr = [];
if($adb->num_rows($result)>0){
    $btn_profile_arr = $adb->query_result_all($result);
    foreach ($btn_profile_arr as &$tmp_info){
        $tmp_info['label'] = getFixedLabel($tmp_info['actionlabel']);
        $all_actionid_arr[] = $tmp_info['actionid'];
    }
}
$arr['btn_profile'] = $btn_profile_arr;
//公海管理员员对应的权限
$sql = 'SELECT userid,GROUP_CONCAT(actionid) as tmp_str from ld_publicpool_opreation_permission where tabid = ? and pool_id = ? GROUP BY userid';
$result = $adb->pquery($sql,[$tabid,$pool_id]);
$num_rows = $adb->num_rows($result);
$user_profile_info = ['a'=>[33]];
if($pool_data['id'] == -1){
    $user_profile_info[$pool_data['administrators']]=$all_actionid_arr;
}
if($num_rows>0){
    for ($i=0;$i<$num_rows;$i++){
        $userid = $adb->query_result($result,$i,'userid');
        $tmp_str = $adb->query_result($result,$i,'tmp_str');
        $actionid_arr = explode(',',$tmp_str);
        $user_profile_info[$userid] = $actionid_arr;
    }
}
$admin_arr = explode(',',$pool_data['administrators']);
foreach ($admin_arr as $tmp_userid){
    if(!isset($user_profile_info[$tmp_userid])){
        $user_profile_info[$tmp_userid] = [];
    }
}

$arr['user_profile_info'] = $user_profile_info;
//公海成员释放权限权限
$releasetype_arr = [];
$releasetype_arr[] = ['key'=>'unlimit','labelbol'=>'NOLIMITS'];
$releasetype_arr[] = ['key'=>'self','labelbol'=>'RELEASESELF'];
$releasetype_arr[] = ['key'=>'no','labelbol'=>'NOTALLOWEDRELEASE'];
$arr['releasetype_arr'] = $releasetype_arr;

//公海池信息
$arr['public_pool'] = $cls_PublicAccounts->getAllActivePool();

$_REQUEST['diony']='diony';
//chj 2020/12/25 43956: 编辑旧公海：弹出层窗口显示为“新建公海”
if(!empty($_REQUEST['pool_id'])){
	$arr['title']=getFixedLabel("ModifyParameters");
}else{
	$arr['title']=getFixedLabel("createpublicaccountpool");
}
$arr['language_type'] = $languageType;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
//$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");

function getAdvFilter($module,$pool_id,$programmeid) {

	global $adb,  $default_charset;
	if(empty($pool_id))return '';
	if($module == 'Accounts'){
	    $advft_group_table = 'ld_account_set_advfilter_grouping';
        $advft_table = 'ld_account_set_advfilter';
    }else{
        $advft_group_table = 'ld_leads_set_advfilter_grouping';
        $advft_table = 'ld_leads_set_advfilter';
    }


	$advft_criteria = array();
    $all_advft_arr = [];
    $all_advft_arr['advft_criteria'] = [];
    $all_advft_arr['advft_criteria_groups'] = [];

	$sql = 'SELECT * FROM '.$advft_group_table.' where pool_id = ? and programmeid = ?  ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array($pool_id,$programmeid));
	if($adb->num_rows($groupsresult) == 0){
	    return $all_advft_arr;
    }


    $i = 1;
	$j = 0;
    $all_advft_arr['advft_criteria_groups'] = [null];

	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select '.$advft_table.'.* from '.$advft_table.'';
		$ssql.= ' where groupid=? and pool_id = ? and programmeid = ? order by '.$advft_table.'.columnindex';

		$result = $adb->pquery($ssql, array($groupId,$pool_id,$programmeid));
        
        
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0)
			return ;

		while ($relcriteriarow = $adb->fetch_array($result)) {
			$columnIndex = $relcriteriarow["columnindex"];
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $relcriteriarow["comparator"];
            $criteria['groupid'] = $relcriteriarow["groupid"];
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
			if(!empty($relcriteriarow["columncondition"])){
                $criteria['columncondition'] = $relcriteriarow["columncondition"];
            }else{
                $criteria['columncondition'] = $relcriteriarow["column_condition"];
            }
			if(empty($criteria['columncondition'])){
                $criteria['columncondition'] = 'and';
            }

            $all_advft_arr['advft_criteria'][] = $criteria;
			$j++;
		}

        $advft_criteria[$i]['condition'] = $groupCondition;
		$all_advft_arr['advft_criteria_groups'][$groupId]['groupcondition'] = $groupCondition;
		$i++;
	}
	return $all_advft_arr;
}

function getAccountPublicRule($module,$programid){
    global $adb;
    $all_rule = [];
    if($module == 'Accounts'){
        $tablename = 'ld_account_set_rule';
    }else{
        $tablename = 'ld_leads_set_rule';
    }

    $query = "SELECT a.programmeid,a.`status`,a.iscycle,a.days,a.`condition`,a.tabname FROM
        $tablename a INNER JOIN ld_tab ON ld_tab.`name` = a.tabname
        WHERE a.programmeid = ? and  a.`type` = 'complete' AND ld_tab.presence IN (0, 2) ORDER BY a.sequence;";
    $result = $adb->pquery($query,array($programid));

    $num_rows = $adb->num_rows($result);
    $tmp_id = 1;
    if($num_rows >= 1){
        $all_rule = $adb->query_result_all($result);
        foreach ($all_rule as &$tmp_info){
            $tmp_info['id'] = $tmp_id;
            $tmp_info['tablabel'] = getTranstab($tmp_info['tabname']);
            $tmp_id ++;
        }
    }
    return $all_rule;
}

?>