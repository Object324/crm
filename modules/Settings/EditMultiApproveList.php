<?php

require_once('./modules/Users/Group.class.php');
global $theme,$default_charset;
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!='')
$blockname=$_REQUEST['fld_module'];
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
$smarty=new lingdangCRM_Smarty;
$query="select * from ld_approve where id=?";
$result=$adb->pquery($query,array($record));
$approve=array();
//editor:gyq_132 reason:审批流程默认值改进，增加default_on_new,default_on_submit  2019/7/22 15:19 ID1000479
if($adb->num_rows($result)){
    $approve[]=array('name'=>$adb->query_result($result,0,'name'),    
    'status'=>$adb->query_result($result,0,'status'),
    'description'=>$adb->query_result($result,0,'description'),
 //   'allowediting'=>$adb->query_result($result,0,'allowediting'),
    'allowantiapproval'=>$adb->query_result($result,0,'allowantiapproval'),
    'finishedallowedit'=>$adb->query_result($result,0,'finishedallowedit'),
    'allowagainsubmit'=>$adb->query_result($result,0,'allowagainsubmit'),
    'enableexpediting'=>$adb->query_result($result,0,'enableexpediting'),
    'default_on_new'=>$adb->query_result($result,0,'default_on_new'),
    'default_on_submit'=>$adb->query_result($result,0,'default_on_submit'),
    'showsubmitremark'=>$adb->query_result($result,$i,'showsubmitremark'),
    'submitremarkrequire'=>$adb->query_result($result,$i,'submitremarkrequire'),
    'showurgent'=>$adb->query_result($result,$i,'showurgent')
    );
}
$approveobj=new Approve();

$group_focus = new Group();

/**
 *parameter:approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配. 
 **/
$query = 'SELECT
  alldata3.allocateid,alldata3.allocatename,alldata3.allocatetype
FROM
	(
		SELECT
			- 1 AS allocateid,
			"AllUser" AS allocatename,
			0 as allocatetype
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.`id` = ld_approve2user.approveid

		WHERE
			ld_approve.approveallocatetype = 0
	    AND  approveid = ?
		UNION
		SELECT
			ld_users.wx_userid AS allocateid,
			ld_users.`last_name` AS allocatename,
			2 as allocatetype
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
			ld_groups.groupname AS allocatename,
			1 as allocatetype
		FROM
			ld_approve2user
		INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
		INNER JOIN ld_groups ON ld_groups.groupid = ld_approve2user.`userid`
		WHERE
			ld_approve.approveallocatetype = 1
		AND approveid = ?
        UNION
		SELECT
			ld_profile.profileid  AS allocateid,
			ld_profile.profilename AS allocatename,
			1 as allocatetype
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
        	$allocatetype = $adb->query_result($result,$i,'allocatetype');
        	if($allocatetype == 1){
        		$groupobj=new Group();
				$groupobj->groupid=$userid;
				$groupobj->groupname=$allocatename;
				$allocatename=getWx_GroupName($groupobj);
        	}
        	else if($allocatetype == 2){
        		$userobj=new Users();
				$userobj->wx_userid=$userid;
				$userobj->last_name=$allocatename;
				$allocatename=getUserlastName($userobj);
        	}
            $userLink.= $allocatename.'、';
        }        
    }
   // $userLink = trim($userLink,'、');
    $userLink = mb_rtrim($userLink,'、','UTF-8');//($userLink,'、');
    $approve[] = $userLink;
}
$smarty->assign('APPROVE',$approve);

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

if($approveobj->recordAgainSubmit(getTabname($blockid))){
    $smarty->assign('again_submit','yes');
}else{
    $smarty->assign('again_submit','no');
}

 $approveresult=$approveobj->approveUsed($record,$blockid); 

if($approveresult==1 || $approveresult==5){
        $smarty->assign("ISUSED",'yes');       
    }
    

 $_REQUEST['diony']='yes';
 $arr['title']=$approve[0]['name'];
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']=='true')
{
    
    
    $arr['content']=$smarty->fetch('Approve/EditMultiApproveEntries.tpl');
   
    
    
}
else
{
   // require_once('SetmenuControl.php');
    $arr['content']=$smarty->fetch('Approve/EditMultiApproveList.tpl');
}
ConvertTojsonString(1,$arr,'success');
?>