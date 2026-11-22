<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/
global $adb,$current_user;
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$pool_data = $_REQUEST['pool_data'];

$zh_name = $pool_data['zh_name'];	//公海名称（中）
$en_name = $pool_data['en_name'];	// 公海名称（英）
$administrators = $pool_data['administrators'];	//公海管理员
$usertype = $pool_data['usertype'];	//公海成员类型
$userids = $pool_data['userids'];	//公海成员id
$limit_type = $pool_data['limit_type'];	//公海已分配客户数量上限 类型
$limit_count = $pool_data['limit_count'];	// 公海已分配客户数量上限：按成员控制，每成员
// 公海未分配客户不允许领取（只能由公海管理员分配）
$allowget = $pool_data['allowget'];
// 公海未分配客户不控制数据权限（可查询所有公海未分配客户）
$dataprofile = $pool_data['dataprofile'];
// 允许公海未分配客户显示在“全部（含指定公海）”列表
$allow_unallocated_showinall = $pool_data['allow_unallocated_showinall'];
// 允许公海已分配客户显示在“全部（含指定公海）”列表
$allow_allocated_showinall = $pool_data['allow_allocated_showinall'];
//允许公海成员将已分配或领取的公海客户转移到其他公海
$allow_trasnfer_others = $pool_data['allow_trasnfer_others'];
//允许公海成员查看“公海未分配”列表
$poolmember_show_noallocate = $pool_data['poolmember_show_noallocate'];
//公海成员客户序时簿“新建”功能下拉选项
$create_buttons = '';
if(isset($pool_data['m_create_buttons']) && !empty($pool_data['m_create_buttons'])){
    $create_buttons = implode(',', $pool_data['m_create_buttons']);
}
$userid_after_transfer = $pool_data['userid_after_transfer'];	// 客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
$userid_after_release = $pool_data['userid_after_release'];	// 公海已分配客户释放后，更改客户负责人为（为空表示不更改）
$objtainaccountcontroldays = $pool_data['objtainaccountcontroldays'];	//客户被自动回收后    天内不允许被当前销售负责人再次领取（为0或空表示不控制）
$beforereminddays = $pool_data['beforereminddays'];	// 客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒）
$advft_criteria = $pool_data['advft_criteria'];	//自动回收规则数据分类设置
$advft_criteria_groups = $pool_data['advft_criteria_groups'];
$allow_user_id = $pool_data['allow_user_id'];	//允许“公海分配”的成员
$transfer_user_id = $pool_data['transfer_user_id'];	//允许“转换公海”的成员
$releasetype = $pool_data['releasetype'];
//$_REQUEST['pool_id'] = 1;

$new_pool_id = $_REQUEST['select_pool_id'];
//公海池
$create_pool = 'no';
$module = $_REQUEST['frommodule'];
$tabid = getTabid($module);
$active = 'yes';
$pool_data['active'] = $active;

if($module == 'Accounts'){
    $public_table = 'ld_account_public';
    $normal_table = 'ld_account_normal';
    $normal_rule_table = 'ld_account_set_rule_normal';
    $public_rule_table = 'ld_account_set_rule';
    $role_limit_table = 'ld_account_role_limitcount';
    $role_limit_common_table = 'ld_account_role_limitcount_common';
    $public_pool_table = 'ld_account_public_pool';
}else{
    $public_table = 'ld_leads_public';
    $normal_table = 'ld_leads_normal';
    $normal_rule_table = 'ld_leads_set_rule';
    $public_rule_table = 'ld_leads_set_rule';
    $role_limit_table = 'ld_leads_role_limitcount';
    $role_limit_common_table = 'ld_leads_role_limitcount_common';
    $public_pool_table = 'ld_leads_public_pool';
}

//hzx 公海名称不能重复
$selectsql  = 'select 1 from '.$public_pool_table.' where deleted = 0 and ( zh_name = ? or en_name = ? );';
$result = $adb->pquery($selectsql,array($zh_name,$en_name));

if($new_pool_id <= 0){
    if($adb->num_rows($result) > 0){
        ConvertTojsonString(-1,array(),"");
    }
	$query = "insert into ".$public_pool_table."(zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,userid_after_transfer,userid_after_release,create_buttons,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid,allow_users,transfer_users,poolmember_show_noallocate,releasetype,active) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	$adb->pquery($query,array($zh_name,$en_name,$limit_count,$limit_type,$administrators,$userids,$usertype,$dataprofile,$allowget,$allow_unallocated_showinall,$allow_allocated_showinall,$allow_trasnfer_others,$userid_after_transfer,$userid_after_release,$create_buttons,$beforereminddays,$objtainaccountcontroldays,date('Y-m-d H:i:s'),$current_user->id,$allow_user_id,$transfer_user_id,$poolmember_show_noallocate,$releasetype,$active));
	$new_pool_id=$adb->getLastInsertID();

	$create_pool = 'yes';
	//新增公海，更新sequence
	$updateseq_sql = 'UPDATE '.$public_pool_table.' SET `sequence` = ? WHERE id = ?';
	$adb->pquery($updateseq_sql,array($new_pool_id,$new_pool_id));
	//新增公海的时候，需要为该公海自动生成一个默认的数据分类
	insertPublicAccountCustomView($module,$new_pool_id);
    $pool_data['id'] = $new_pool_id;
}else{
    if($adb->num_rows($result) > 1){
        ConvertTojsonString(-1,array(),"");
    }
	$query = "update ".$public_pool_table." set zh_name = ?,en_name = ?,limit_count = ?,limit_type = ?,administrators = ?,userids = ?,usertype = ?,dataprofile = ?,allowget = ?,allow_unallocated_showinall = ?,allow_allocated_showinall = ?,allow_trasnfer_others = ?,userid_after_transfer = ?,userid_after_release = ?,create_buttons = ?,beforereminddays = ?,objtainaccountcontroldays = ?,modifiedtime = ?,modifiedby = ?,allow_users=?,transfer_users=?,poolmember_show_noallocate=?,releasetype=?,active=? where id = ?";
	$adb->pquery($query,array($zh_name,$en_name,$limit_count,$limit_type,$administrators,$userids,$usertype,$dataprofile,$allowget,$allow_unallocated_showinall,$allow_allocated_showinall,$allow_trasnfer_others,$userid_after_transfer,$userid_after_release,$create_buttons,$beforereminddays,$objtainaccountcontroldays,date('Y-m-d H:i:s'),$current_user->id,$allow_user_id,$transfer_user_id,$poolmember_show_noallocate,$releasetype,$active,$new_pool_id));

}

if(!empty($new_pool_id)){
    //公海回收方案
    $public_recovey_rule = $_REQUEST['public_recovey_rule'];

    $update_sql = 'UPDATE ld_module_recovery_programme set active = ?,sequence = ?,from_pool_id=?,pool_id=? where programmeid=?';
    $saveid_arr = [];
    foreach ($public_recovey_rule as $key => $tmp_info){
        $saveid_arr[] = $tmp_info['programmeid'];
        if($tmp_info['pool_id'] == -1)$tmp_info['pool_id'] = $new_pool_id;
        if($tmp_info['from_pool_id'] == -1)$tmp_info['from_pool_id'] = $new_pool_id;

        $adb->pquery($update_sql,[$tmp_info['active'],($key+1),$tmp_info['from_pool_id'],$tmp_info['pool_id'],$tmp_info['programmeid']]);
    }
    if(count($saveid_arr)>0){
        $saveid_str = implode(',',$saveid_arr);
    }else{
        $saveid_str = -1;
    }
    $delete_sql = 'delete from '.$public_rule_table.' where pool_id = ? and programmeid not in ('.$saveid_str.')';
    $adb->pquery($delete_sql,[$new_pool_id]);
    $delete_sql = 'delete from ld_module_recovery_programme where pool_id = ? and modulename = ? and programmeid not in ('.$saveid_str.')';
    $adb->pquery($delete_sql,[$new_pool_id,$module]);

	//公海已分配客户数量上限：按角色控制 
    if ($limit_type == 'role') {
        $role_limit_count_info = $_REQUEST['role_limit_count_info'];
        $query = 'delete from '.$role_limit_table.' where pool_id = ?';
        $adb->pquery($query,array($new_pool_id));
        foreach($role_limit_count_info as $key => $tmp_info){
            $query = 'insert into '.$role_limit_table.'(pool_id,roleid,limit_count) values (?,?,?)';
            $adb->pquery($query,array($new_pool_id,$tmp_info['profileid'],$tmp_info['limit_count']));
        }
    }
    //公海管理员角色权限保存
    $user_profile_info = $_REQUEST['user_profile_info'];
    $query = 'delete from ld_publicpool_opreation_permission where pool_id = ? and tabid = ? ';
    $adb->pquery($query,array($new_pool_id,$tabid));
    $administrators_arr =explode(',',$administrators);
    foreach ($user_profile_info as $tmp_userid => $actionid_arr){
        if(!in_array($tmp_userid,$administrators_arr))continue;
        foreach ($actionid_arr as $tmp_actionid){
            $query = 'INSERT into ld_publicpool_opreation_permission(userid,pool_id,actionid,tabid) value(?,?,?,?)';
            $adb->pquery($query,array($tmp_userid,$new_pool_id,$tmp_actionid,$tabid));
        }
    }

    if($module == 'Accounts'){
        //回收公海的时候有用
        $sql="update ld_sys_event set eventdate=? where type='publicaccount'";
        $adb->pquery($sql,array('1600-01-01'));
    }else{
        //回收公海的时候有用
        $sql="update ld_sys_event set eventdate=? where type='publicleads'";
        $adb->pquery($sql,array('1600-01-01'));
    }
}
if($module == 'Accounts'){
    unsetCache('public_account_pool');
}else{
    unsetCache('public_leads_pool');
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('pool_id'=>$new_pool_id,'pool_data'=>$pool_data),"success");

//复制全部普通客户的数据分类
function insertPublicAccountCustomView($module,$pool_id){
    global $adb;
    $query = "select id from ld_customview_seq";
    $result = $adb->pquery($query,array());
    $max_customview_cvid = $adb->query_result($result,0,0);

    $tmp_sql = "select cvid from ld_customview where entitytype = '".$module."' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1)";
    $tmp_result = $adb->pquery($tmp_sql,[]);
    if($adb->num_rows($tmp_result)>0){
        $from_cvid = $adb->query_result($tmp_result,0,'cvid');
    }else{
        return '';
    }

    $focus = CRMEntity::getInstance($module);
    //数据分类 - 公海未分配
    $noallocate_cvid = $max_customview_cvid + 1;
    //数据分类 - 公海已分配
    $publicallocate_cvid = $max_customview_cvid + 2;
    //数据分录 - 全部公海客户
    $allpublic_cvid = $max_customview_cvid + 3;

    $query = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id) 
	select $noallocate_cvid,viewname,setdefault,0,entitytype,`status`,userid,sequence,pagewidthpercent,'NOALLOCATE',description,$pool_id from ld_customview where cvid = ?";
    $adb->pquery($query,array($from_cvid));

    $query = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id) 
	select $publicallocate_cvid,viewname,setdefault,0,entitytype,`status`,userid,sequence,pagewidthpercent,'PUBLICALLOCATE',description,$pool_id from ld_customview where cvid = ?";
    $adb->pquery($query,array($from_cvid));

    $query = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id) 
	select $allpublic_cvid,viewname,setdefault,0,entitytype,`status`,userid,sequence,pagewidthpercent,'ALLPUBLICACCOUNT',description,$pool_id from ld_customview where cvid = ?";
    $adb->pquery($query,array($from_cvid));

    $query = "select cvid,columnname from ld_cvcolumnlist where cvid = ?";
    $result = $adb->pquery($query,array($from_cvid));
    $num_rows = $adb->num_rows($result);
    if($num_rows > 0){
        $columns = [];
        $columnindex = 0;
        $public_account_columns = array('allocatedate'=>'allocatedate','protectdate'=>'protectdate','completed'=>'completed');
        $insert_customview = "insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (?,?,?)";
        for($i = 0; $i < $num_rows; $i++){
            $cvid = $adb->query_result($result,$i,'cvid');
            $columnname = $adb->query_result($result,$i,'columnname');
            $columnname_array = explode(':',$columnname);
            if(in_array(strtolower($columnname_array[0]),$focus->tab_name)){
                if(in_array($columnname_array[1],$public_account_columns)){
                    unset($public_account_columns);
                }
                $adb->pquery($insert_customview,array($noallocate_cvid,$columnindex,$columnname));
                $adb->pquery($insert_customview,array($publicallocate_cvid,$columnindex,$columnname));
                $adb->pquery($insert_customview,array($allpublic_cvid,$columnindex,$columnname));
                $columnindex++;
            }
        }
        //公海已分配：显示的列：复制普通客户“全部”数据分类中除联系人字段的列+领取日期、保护截止日期+公海目标
        if(!empty($public_account_columns)){
            foreach($public_account_columns as $columnanme){
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname', $columnanme);
                if(!empty($fieldinfo)){
                    $tablename=$fieldinfo->getTableName();
                    $columnname=$fieldinfo->getColumnName();
                    $fieldname=$fieldinfo->getFieldName();
                    $fieldlabel=$fieldinfo->getFieldLabelKey();
                    $typeofdata=$fieldinfo->getTypeOfData();
                    $typeofdatas=explode('~',$typeofdata);
                    $columnname_string = $tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofdatas[0];
                    $adb->pquery($insert_customview,array($publicallocate_cvid,$columnindex,$columnname_string));
                    $columnindex++;
                }
            }
        }
        //数据分类排序
        $query = "select columnname,sorttype from ld_cvcolumnlistsort where cvid = ?";
        $result = $adb->pquery($query,array($from_cvid));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $query = "insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select $noallocate_cvid,columnname,sorttype from ld_cvcolumnlistsort where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select $publicallocate_cvid,columnname,sorttype from ld_cvcolumnlistsort where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select $allpublic_cvid,columnname,sorttype from ld_cvcolumnlistsort where cvid = ?";
            $adb->pquery($query,array($from_cvid));
        }
        //数据分类 - 刷选条件
        $query = "select columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = ?";
        $result = $adb->pquery($query,array($from_cvid));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $query = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			select $noallocate_cvid,columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			select $publicallocate_cvid,columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			select $allpublic_cvid,columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = ?";
            $adb->pquery($query,array($from_cvid));
        }
        $query = "select groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = ?;";
        $result = $adb->pquery($query,array($from_cvid));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $query = "insert into ld_cvadvfilter_grouping(cvid,groupid,group_condition,condition_expression)
			select $noallocate_cvid,groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvadvfilter_grouping(cvid,groupid,group_condition,condition_expression)
			select $publicallocate_cvid,groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = ?";
            $adb->pquery($query,array($from_cvid));
            $query = "insert into ld_cvadvfilter_grouping(cvid,groupid,group_condition,condition_expression)
			select $allpublic_cvid,groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = ?";
            $adb->pquery($query,array($from_cvid));
        }
    }
    $query = "update ld_customview_seq set id = (select max(cvid) from ld_customview)";
    $adb->pquery($query,array());
    unsetCacheDirectory('customview');
}
?>