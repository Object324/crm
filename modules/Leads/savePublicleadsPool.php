<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/
global $adb,$current_user;
$zh_name = $_REQUEST['zh_name'];	//公海名称（中）
$en_name = $_REQUEST['en_name'];	// 公海名称（英） 
$administrators = $_REQUEST['select_administrators_id'];	//公海管理员
$usertype = $_REQUEST['usertype'];	//公海成员类型
$userids = $_REQUEST['userids'];	//公海成员id
$limit_type = $_REQUEST['limit_type'];	//公海已分配客户数量上限 类型
$limit_count = $_REQUEST['limit_count'];	// 公海已分配客户数量上限：按成员控制，每成员  
$txtbox_role_count = $_REQUEST['txtbox_role_count'];	//公海已分配客户数量上限：按角色控制 
$txtbox_roleid = $_REQUEST['txtbox_roleid'];
// 公海未分配客户不允许领取（只能由公海管理员分配） 
$allowget = 'no';
if(!empty($_REQUEST['allowget']))$allowget = 'yes';
// 公海未分配客户不控制数据权限（可查询所有公海未分配客户） 
$dataprofile = 'no';
if(!empty($_REQUEST['dataprofile']))$dataprofile = 'yes';
// 允许公海未分配客户显示在“全部（含指定公海）”列表 
$allow_unallocated_showinall = 'no';
if(!empty($_REQUEST['allow_unallocated_showinall']))$allow_unallocated_showinall = 'yes';
// 允许公海已分配客户显示在“全部（含指定公海）”列表 
$allow_allocated_showinall = 'no';
if(!empty($_REQUEST['allow_allocated_showinall']))$allow_allocated_showinall = 'yes';
//允许公海成员将已分配或领取的公海客户转移到其他公海
$allow_trasnfer_others = 'no';
if(!empty($_REQUEST['allow_trasnfer_others']))$allow_trasnfer_others = 'yes';
//允许公海成员查看“公海未分配”列表
$poolmember_show_noallocate = 'no';
if(!empty($_REQUEST['poolmember_show_noallocate']))$poolmember_show_noallocate = 'yes';
$create_buttons = implode(',', $_REQUEST['m_create_buttons']);	//公海成员客户序时簿“新建”功能下拉选项
$userid_after_transfer = $_REQUEST['userid_after_transfer'];	// 客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
$userid_after_release = $_REQUEST['userid_after_release'];	// 公海已分配客户释放后，更改客户负责人为（为空表示不更改）
$objtainaccountcontroldays = $_REQUEST['objtainaccountcontroldays'];	//客户被自动回收后    天内不允许被当前销售负责人再次领取（为0或空表示不控制） 
$beforereminddays = $_REQUEST['beforereminddays'];	// 客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） 
$advft_criteria = $_REQUEST['advft_criteria'];	//自动回收规则数据分类设置
$advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
$allow_user_id = $_REQUEST['allow_user_id'];	//允许“公海分配”的成员
$transfer_user_id = $_REQUEST['transfer_user_id'];	//允许“转换公海”的成员
//$_REQUEST['pool_id'] = 1;
//公海池
if(empty($_REQUEST['select_pool_id'])){
	$query = "insert into ld_leads_public_pool(zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,userid_after_transfer,userid_after_release,create_buttons,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid,allow_users,transfer_users,poolmember_show_noallocate) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	$adb->pquery($query,array($zh_name,$en_name,$limit_count,$limit_type,$administrators,$userids,$usertype,$dataprofile,$allowget,$allow_unallocated_showinall,$allow_allocated_showinall,$allow_trasnfer_others,$userid_after_transfer,$userid_after_release,$create_buttons,$beforereminddays,$objtainaccountcontroldays,date('Y-m-d H:i:s'),$current_user->id,$allow_user_id,$transfer_user_id,$poolmember_show_noallocate));
	$_REQUEST['select_pool_id']=$adb->getLastInsertID();
	//新增加得公海池，默认追加：自动回收规则设置
	if($_REQUEST['select_pool_id'] != 1){
		$query = "insert into ld_leads_set_rule(tabname,type,`condition`,labelbol,sequence,days,`status`,columnname,otherwhere,iscycle,singlelabelbol,pool_id)
		select tabname,type,`condition`,labelbol,sequence,0,'inactive',columnname,otherwhere,'no',singlelabelbol,".$_REQUEST['select_pool_id']." from ld_leads_set_rule where pool_id = 1 and type= 'complete'";
		$adb->pquery($query,array());
	}
	//新增公海，更新sequence
	$updateseq_sql = 'UPDATE ld_leads_public_pool SET `sequence` = ? WHERE id = ?';
	$adb->pquery($updateseq_sql,array($_REQUEST['select_pool_id'],$_REQUEST['select_pool_id']));
	//新增公海的时候，需要为该公海自动生成一个默认的数据分类
	insertPublicAccountCustomView($_REQUEST['select_pool_id']);
}else{
	$query = "update ld_leads_public_pool set zh_name = ?,en_name = ?,limit_count = ?,limit_type = ?,administrators = ?,userids = ?,usertype = ?,dataprofile = ?,allowget = ?,allow_unallocated_showinall = ?,allow_allocated_showinall = ?,allow_trasnfer_others = ?,userid_after_transfer = ?,userid_after_release = ?,create_buttons = ?,beforereminddays = ?,objtainaccountcontroldays = ?,modifiedtime = ?,modifiedby = ?,allow_users=?,transfer_users=?,poolmember_show_noallocate=? where id = ?";
	$adb->pquery($query,array($zh_name,$en_name,$limit_count,$limit_type,$administrators,$userids,$usertype,$dataprofile,$allowget,$allow_unallocated_showinall,$allow_allocated_showinall,$allow_trasnfer_others,$userid_after_transfer,$userid_after_release,$create_buttons,$beforereminddays,$objtainaccountcontroldays,date('Y-m-d H:i:s'),$current_user->id,$allow_user_id,$transfer_user_id,$poolmember_show_noallocate,$_REQUEST['select_pool_id']));

}

if(!empty($_REQUEST['select_pool_id'])){
	//公海已分配客户数量上限：按角色控制 
	if($limit_type == 'role'){
		if(!empty($txtbox_roleid) && !empty($txtbox_role_count)){
			$query = 'delete from ld_leads_role_limitcount where pool_id = ?';
			$adb->pquery($query,array($_REQUEST['select_pool_id']));
			foreach($txtbox_roleid as $key => $roleid){
				$query = 'insert into ld_leads_role_limitcount(pool_id,roleid,limit_count) values (?,?,?)';
				$adb->pquery($query,array($_REQUEST['select_pool_id'],$roleid,$txtbox_role_count[$key]));
			}
		}
	}

	//自动回收规则设置
	$query="select tabname,type from ld_leads_set_rule where type = 'complete' and pool_id = ? order by type desc ";
	$result=$adb->pquery($query,array($_REQUEST['select_pool_id']));
	$rows=$adb->num_rows($result);
	if($rows >= 1){
		for($i=0;$i<$rows;$i++){
			$tabname=$adb->query_result($result,$i,'tabname');
			$type=$adb->query_result($result,$i,'type');
			$condition=$_REQUEST[$type.'opt'];
			$days=$_REQUEST[$tabname."_".$type."days"];
			$status=$_REQUEST[$tabname."_".$type."chk"];
			if( $status == 'on'){
				$status='active';
			}else{
				$status='inactive';
			}
			$iscycle=$_REQUEST['changerule_'.$type.'_'.$tabname];
			if($iscycle=='no')
			{
				$days=$_REQUEST[$tabname."_single_".$type."days"];
			}
			$query="update ld_leads_set_rule set status=?,days=?,`condition`=?,iscycle=?  where type=? and tabname=? and pool_id = ?";
			$adb->pquery($query,array($status,$days,$condition,$iscycle,$type,$tabname,$_REQUEST['select_pool_id']));
		}
	}

	//提醒高级条件设置保存
	$sql="delete from ld_leads_set_advfilter where pool_id = ?"; 
	$adb->pquery($sql,array($_REQUEST['select_pool_id']));
	$sql="delete from ld_leads_set_advfilter_grouping where pool_id = ?"; 
	$adb->pquery($sql,array($_REQUEST['select_pool_id']));
	if(!empty($advft_criteria)){
		$advfilterlist = ldcrm_json_decode($advft_criteria);
		$advfiltergroup=ldcrm_json_decode($advft_criteria_groups);
		$index=1;
        for($i=0;$i<count($advfilterlist);$i++){
			$query="INSERT INTO ld_leads_set_advfilter (groupid,columnindex,columnname,comparator,value,column_condition,pool_id) VALUES(?,?,?,?,?,?,?)"; 
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
				$_REQUEST['select_pool_id']
			);
			$adb->pquery($query,$params);
        }

		foreach($advfiltergroup as $groupid=>$groupinfo){
			
			if(empty($groupinfo)) continue;
			//if(empty($groupinfo["conditionexpression"])) continue;
			$sql='insert into ld_leads_set_advfilter_grouping(groupid,group_condition,condition_expression,pool_id)value(?,?,?,?)';
			$adb->pquery($sql,array($groupid,$groupinfo['groupcondition'],$groupid-1,$_REQUEST['select_pool_id']));
		}
	}
	//回收公海的时候有用
	$sql="update ld_sys_event set eventdate=? where type='publicleads'";
	$adb->pquery($sql,array('1600-01-01'));

	//公海回收条件sql
	crm_load_class_file("LeadsSetCustomView",'modules/Leads/LeadsSet');
	
	$AccountSetCustomView=new LeadsSetCustomView($_REQUEST['select_pool_id']);
	
	crm_load_class_file("LeadsSetQueryGenerator",'modules/Leads/LeadsSet');
    
	if(count($advft_criteria)>0&&$advft_criteria!='[]')
	{
		$queryGenerator =new LeadsSetQueryGenerator('Leads', $current_user,$AccountSetCustomView);
		$queryGenerator->initForDefaultCustomView();
		$query= $queryGenerator->getQuery();

		$queryGenerator->getWhereClause();
		$queryGenerator->getFromClause();
	}
	else
	{
		$query='';
	}
	$sql=' update ld_leads_public_pool set recycleselect=? where id = ?';
	$adb->pquery($sql,array($query,$_REQUEST['select_pool_id']));
}
unsetCache('public_leads_pool');
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array('pool_id'=>$_REQUEST['select_pool_id']),"success");

//负责全部普通客户的数据分类
function insertPublicAccountCustomView($pool_id){
	global $adb;
	$query = "select id from ld_customview_seq";
	$result = $adb->pquery($query,array());
	$max_customview_cvid = $adb->query_result($result,0,0);
	$focus = CRMEntity::getInstance('Leads');
	//数据分类 - 公海未分配
	$noallocate_cvid = $max_customview_cvid + 1;
	//数据分类 - 公海已分配
	$publicallocate_cvid = $max_customview_cvid + 2;
	$query = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id) 
	select $noallocate_cvid,viewname,setdefault,0,entitytype,`status`,userid,sequence,pagewidthpercent,'NOALLOCATE',description,$pool_id from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT'";
	$adb->pquery($query,array());
	$query = "insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id) 
	select $publicallocate_cvid,viewname,setdefault,0,entitytype,`status`,userid,sequence,pagewidthpercent,'PUBLICALLOCATE',description,$pool_id from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT'";
	$adb->pquery($query,array());
	$query = "select cvid,columnname from ld_cvcolumnlist where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
	$result = $adb->pquery($query,array());
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
			if(in_array(strtolower($columnname_array[0]),array('ld_leads','ld_leadscf'))){
				if(in_array($columnname_array[1],$public_account_columns)){
					unset($public_account_columns);
				}
				$adb->pquery($insert_customview,array($noallocate_cvid,$columnindex,$columnname));
				$adb->pquery($insert_customview,array($publicallocate_cvid,$columnindex,$columnname));
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
					$columnname_string = $tablename.':'.$columnname.':'.$fieldname.':'.'Leads_fieldlabel:'.$typeofdatas[0];
					$adb->pquery($insert_customview,array($publicallocate_cvid,$columnindex,$columnname_string));
					$columnindex++;
				}
			}
		}
		//数据分类排序
		$query = "select columnname,sorttype from ld_cvcolumnlistsort where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$query = "insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select $noallocate_cvid,columnname,sorttype from ld_cvcolumnlistsort where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
			$query = "insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select $publicallocate_cvid,columnname,sorttype from ld_cvcolumnlistsort where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
		}
		//数据分类 - 刷选条件
		$query = "select columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$query = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			select $noallocate_cvid,columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
			$query = "insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
			select $publicallocate_cvid,columnindex,columnname,comparator,`value`,groupid,column_condition from ld_cvadvfilter where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
		}
		$query = "select groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1));";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$query = "insert into ld_cvadvfilter_grouping(cvid,groupid,group_condition,condition_expression)
			select $noallocate_cvid,groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
			$query = "insert into ld_cvadvfilter_grouping(cvid,groupid,group_condition,condition_expression)
			select $publicallocate_cvid,groupid,group_condition,condition_expression from ld_cvadvfilter_grouping where cvid = (select cvid from ld_customview where entitytype = 'Leads' and viewname = 'all' and customcategory = 'ALLACCOUNT' and pool_id in (0,1))";
			$adb->pquery($query,array());
		}
	}
	$query = "update ld_customview_seq set id = (select max(cvid) from ld_customview)";
	$adb->pquery($query,array());
	unsetCacheDirectory('customview');
}
?>