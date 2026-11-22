<?php

//edit:can 应该不用改文件
require_once('./modules/Users/Group.class.php');
global $theme;
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
$blockid=$_REQUEST['blockid'];
//if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module'])
$blockname=getTabname($_REQUEST['blockid']);
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
$mode='create';
if(isset($_REQUEST['mode']))
$mode=$_REQUEST['mode'];

$focus=CRMEntity::getInstance($blockname);

$smarty=new lingdangCRM_Smarty;

$profile = Profile::getInstance();
//角色

$approvenum_rows=0;
$query="select * from ld_approve where id=$record";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$approvenum_rows=$num_rows;
$approve=array();

$approveobj=new Approve();
if($approveobj->recordAgainSubmit(getTabname($blockid))){
    $again_submit = 'yes';
}else{
    $again_submit = 'no';
}
$approve=['finishedfield_allocatetype'=>'all','finishedfield_allocateid'=>'-1'];
$smarty->assign('AGAIN_SUBMIT',$again_submit);//模块 已批准/拒绝的单据允许再次提交审批
//editor:gyq_132 reason:审批流程默认值改进，增加default_on_new,default_on_submit  2019/7/22 15:26 ID1000479
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $approve[]=array('id'=>$adb->query_result($result,$i,'id'),
            'tabid'=>$adb->query_result($result,$i,'tabid'),
            'name'=>$adb->query_result($result,$i,'name'),
            'status'=>$adb->query_result($result,$i,'status'),
            'description'=>$adb->query_result($result,$i,'description'),
            'approveallocatetype'=>$adb->query_result($result,$i,'approveallocatetype'),
            'allowediting'=>$adb->query_result($result,$i,'allowediting'),
            'allowantiapproval'=>$adb->query_result($result,$i,'allowantiapproval'),
            'finishedallowedit'=>$adb->query_result($result,$i,'finishedallowedit'),
            'allowagainsubmit'=>$adb->query_result($result,$i,'allowagainsubmit'),//again_submit为yes，finishedallowedit为yes时，才显示该参数选项
            'default_on_new'=>$adb->query_result($result,$i,'default_on_new'),
            'default_on_submit'=>$adb->query_result($result,$i,'default_on_submit'),
            'showsubmitremark'=>$adb->query_result($result,$i,'showsubmitremark'),
            'submitremarkrequire'=>$adb->query_result($result,$i,'submitremarkrequire'),
            'showurgent'=>$adb->query_result($result,$i,'showurgent'),
            'enableexpediting'=>$adb->query_result($result,$i,'enableexpediting'),
            'finishedfield_allocatetype'=>$adb->query_result($result,$i,'finishedfield_allocatetype'),//审批结束字段可以编辑的适用范围
            'finishedfield_allocateid'=>$adb->query_result($result,$i,'finishedfield_allocateid'),
            'editresetapprove'=>$adb->query_result($result,$i,'editresetapprove')
        );
    }
}else if($_REQUEST['record']>0)
{
    ////说明是新增审批流程界面，新增审批流程，如果是先保存审批步骤则程序会自动生成审批流程id
    $approve[]=array('id'=>$_REQUEST['record'],
            'tabid'=>$_REQUEST['blockid'],
            'name'=>$_REQUEST['name'],
            'status'=>1,
            'description'=>$_REQUEST['description'],
            'approveallocatetype'=>$_REQUEST['approveallocatetype'],
            'allowediting'=>$_REQUEST['allowediting'],
            'allowantiapproval'=>$_REQUEST['allowantiapproval'],
            'finishedallowedit'=>$_REQUEST['finishedallowedit'],
            'default_on_new'=>$adb->query_result($result,$i,'default_on_new'),
            'default_on_submit'=>$adb->query_result($result,$i,'default_on_submit'),
            'finishedfield_allocatetype'=>$adb->query_result($result,$i,'finishedfield_allocatetype'),//审批结束字段可以编辑的适用范围
            'finishedfield_allocateid'=>$adb->query_result($result,$i,'finishedfield_allocateid'),
            'editresetapprove'=>$adb->query_result($result,$i,'editresetapprove')
        );
}


$havechoosefield_arr=[];
$tmp_arrchoosed=[];
$fininsedselectfieldtype='all';

if($_REQUEST['record']>0)
{
    //已选择的审批结束后允许编辑的字段
    
    $sql='select * from ld_approve_finishededitfield where approveid=?';
    $result=$adb->pquery($sql,array($_REQUEST['record']));
    $rows=$adb->num_rows($result);
    
    for($i=0;$i<$rows;$i++)
    {
        $columns=$adb->query_result($result,$i,'columns');
        $col_arr=explode(":",$columns);
        $tablename=$col_arr[0];
        $columnname=$col_arr[1];
       
        if(in_array($tablename,$focus->tab_name)||$tablename=='ld_attachments')
        {
            //edit:can 20220411 （http://crm.airmaster.com.cn/crm）审批流程定制》项目信息表 “项目报备“流程，编辑流程，启用反审批 保存，再编辑打开界面， 显示反审批没保存成功 
            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
            
            
        }
        else {
            if(empty($focus->detailfieldobj))
            {
                continue;
            }
             $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
        }
        if(!$fieldinfo)
            continue;
        $havechoosefield_arr[$columns]=$fieldinfo->getFieldLabel();
        $fininsedselectfieldtype='part';
        
        
    }
    
    
}
$smarty->assign("fininsedselectfieldtype",$fininsedselectfieldtype);
$arrfield=[];
$main_allFields=$focus->fieldobj->getModuleFields();
$modulelabel=getTranstab($blockname);

foreach($main_allFields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getSaveDataBase()=='no')
        continue;
     if($fieldinfo->get_allowedit()=='no')
        continue;
    
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
    $columns="$tablename:$columnname:$blockname";
    
    if(array_key_exists($columns,$havechoosefield_arr))
        continue;
    
    $arrfield[$columns]=$modulelabel.'_'.$fieldinfo->getFieldLabel();
    
     
}
if(get_file_address($blockname,'ProductDetails'))
{
    $detail_allFields=$focus->detailfieldobj->getModuleFields();
    $label= getTranstab("Products");
    
    foreach($detail_allFields as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getSaveDataBase()=='no')
            continue;
         if($fieldinfo->getedit_permission()=='1')
            continue;
        $fieldid=$fieldinfo->getFieldid();
        if($fieldname=='productname')
            $fieldid=0;
        if($fieldid>0)
            continue;
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $columns="$tablename:$columnname:$blockname";
        if(array_key_exists($columns,$havechoosefield_arr))
            continue;
        $arrfield[$columns]=$label.'_'.$fieldinfo->getFieldLabel();
        
         
    }
}
else if(get_file_address($blockname,$blockname.'DetailFieldsHtml'))
{
    $detail_allFields=$focus->detailfieldobj->getModuleFields();
    foreach($detail_allFields as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getSaveDataBase()=='no')
            continue;
        if($fieldinfo->getedit_permission()=='1')
            continue;
        
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $columns="$tablename:$columnname:$blockname";
       if(array_key_exists($columns,$havechoosefield_arr))
            continue;
        $arrfield[$columns]=$label.'_'.$fieldinfo->getFieldLabel();
        
         
    }
}

$smarty->assign("finisedallfield_arr",$arrfield);
$smarty->assign("havechoosefield_arr",$havechoosefield_arr);
/*
 * editor:gyq_05
 * reason:审批页新增适用范围
 * date  :2016 2 25
 * */
$query="select * from ld_approve2user where approveid=$record";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$userlist='';
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $userId=$adb->query_result($result,$i,'userid');
        $userlist .= $userId.',';
    }
    $userlist = rtrim($userlist,',');
}else{
    /*reason:新建审批流程，初始化值,-5仅表示新建时各值为空*/
    $approve[0]['tabid'] = '-5';
    $approve[0]['id'] = '-5';
    $approve[0]['approveallocatetype'] = '0';
    $userlist = '-1';
}
if(!$approvenum_rows&&$_REQUEST['record']>0)
{//说明是新增审批流程界面，新增审批流程，如果是先保存审批步骤则程序会自动生成审批流程id
    $approve[0]['approveallocatetype'] = $_REQUEST['radiotype'];
    $userlist=$_REQUEST['selectallocateid'];
    
}
$smarty->assign("APPROVEALLOCATEID",$userlist);

$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);

$smarty->assign('APPROVE',$approve);
$smarty->assign('MODE',$mode);
$smarty->assign('RECORD',$record);

$group_focus = new Group();

/**
 *parameter:approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配. 
 **/
$query = 'SELECT
  alldata3.allocateid	,alldata3.allocatename
FROM
	(
		SELECT
			- 1 AS allocateid,
			"AllUser" AS allocatename
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.`id` = ld_approve2user.approveid

		WHERE
			ld_approve.approveallocatetype = 0
	    AND  approveid = ?
		UNION
		SELECT
			ld_users.id AS allocateid,
			ld_users.`last_name` AS allocatename
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
		INNER JOIN ld_users ON ld_users.`id` = ld_approve2user.`userid`
		WHERE
			ld_approve.approveallocatetype = 2
	    AND  approveid = ?
		UNION
		SELECT
			ld_groups.groupid AS allocateid,
			ld_groups.groupname AS allocatename
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
		INNER JOIN ld_groups ON ld_groups.groupid = ld_approve2user.`userid`
		WHERE
			ld_approve.approveallocatetype = 1
		AND approveid = ?
        UNION
		SELECT
			ld_profile.profileid AS allocateid,
			ld_profile.profilename AS allocatename
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
		INNER JOIN ld_profile ON ld_profile.profileid = ld_approve2user.`userid`
		WHERE
			ld_approve.approveallocatetype = 3
		AND approveid = ?
	) AS alldata3;';
$result=$adb->pquery($query,array($record,$record,$record,$record));
$num_rows=$adb->num_rows($result);
$userLink='';
if($num_rows > 0){   
    for($i=0;$i<$num_rows;$i++){
        $userid = $adb->query_result($result,$i,'allocateid');
        $allocatename = $adb->query_result($result,$i,'allocatename');
        if($allocatename=='AllUser')//所有用户。
        {
            $allocatename = getFixedLabel('ALLTHEUSERS'); 
            $userLink .= $allocatename.'、' ;
        }
        else{
            $userLink.= $allocatename.'、';
        }        
    }
    $userLink = trim($userLink,'、');
    $approve[] = $userLink;
}
else if($_REQUEST['record']>0)
{
    //说明是新增审批流程界面，新增审批流程，如果是先保存审批步骤则程序会自动生成审批流程id
    $userLink=$_REQUEST['radiontype'].'、'.$_REQUEST['selectallocateid'];
}

$smarty->assign('APPROVE',$approve);
$select_approve_type = array();
$focus=CRMEntity::getInstance($blockname);
$fieldobjs=$focus->fieldobj->getModuleFields();
 foreach($fieldobjs as $fieldname=>$fieldinfo)
 {
	$columnname=$fieldinfo->getColumnName();
	$fieldlabel=$fieldinfo->getFieldLabel();
	$fieldid = $fieldinfo->getFieldid();
	//edit: chj date: 2020/9/24 reason:单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
	if($fieldinfo->getUIType() == 153 || $fieldinfo->getUIType() == 154){
		$select_approve_type[$fieldid] = getFixedLabel('BIll') . $fieldlabel;
	}
 }

$smarty->assign('SELECT_APPRIVE_TYPE',$select_approve_type);
crm_load_class_file('cls_ApproveStep','modules/Approve');
$approvestepobj=new cls_ApproveStep($blockname,$record,"");
//获取审批步骤
$smarty->assign('STEP',$approvestepobj->getApproveStepList());
$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);
$smarty->assign('RECORD',$record);
$smarty->assign("mokuai_name",getTranstab(getTabname($blockid)));
$smarty->assign('LANGUAGETYPE',$languageType);
crm_load_class_file('staticProfile.class','modules/Users');
$editprofile = staticProfile::isModuleExistsProfile($blockname,'EditView');
$smarty->assign('editprofile',$editprofile);

$approveobj=new Approve();
 $approveresult=$approveobj->approveUsed($record,$blockid); 

if($approveresult==1 || $approveresult==5){
        //edit:duan 使用中的审批步骤允许编辑
        //$smarty->assign("ISUSED",'yes');       
    }

 $_REQUEST['diony']='diony';
 if(!empty($parenttabid)){
	$arr['title'] = getFixedLabel('EDIT').'"'.$parenttablelabel.'"&nbsp;&nbsp;('.getFixedLabel('LBL_TABLIST_DESCRIPTION').')';
 }else{
	$arr['title'] = getFixedLabel('LBL_APPROVE');
 }
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Approve/EditMultiApprove.tpl");
$arr['content']=$str;
$arr['approve'] = $approve;
$arr['userlist'] = $userlist;
ConvertTojsonString(1,$arr,"success");
exit();
//$smarty->display('Approve/EditMultiApprove.tpl');
?>