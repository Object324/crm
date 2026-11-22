<?php
/**
 * 审批流程分配功能
 * @project PROT195 审批管理改进
 * @author Tujt 2015-04-15
 */
 
 global $current_user;

//$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='MultiApproveList';
//$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';=
if($_REQUEST['type'] == 'saveApprovalProcessSort') {
    $type = $_REQUEST['type'];
    global $adb;
//保存审批流程排序 weiyannan 20231121 XUQIU1002038 后台设置列表界面可以做排序 后台设置--系统定制-审批流程定制
    if ($type == 'saveApprovalProcessSort') {
        if (!empty($_REQUEST['tagids'])&&!empty($_REQUEST['tabid'])) {
            $tabid = $_REQUEST['tabid'];
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_approve set sequence = ? where id = ? and tabid = ?', array($sequence, $id, $tabid));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
}
 $record=$_REQUEST['record'];
if(isset($_REQUEST['mode']) && 'approve' == $_REQUEST['mode']){
    global $adb;
    $approveid = $_REQUEST['approveid'];
    /**
     * 审批流程分配用户
     */
    if(isset($_REQUEST['allocate']) && $_REQUEST['allocate'] == 1){
        $userid = $_REQUEST['userid'];
        $userarr = explode(',', $userid);
        $query = 'delete from ld_approve2user where approveid = '.$approveid.' ';
        $adb->pquery($query,array());
        if(!empty($userarr)){
            foreach ($userarr as $user) {
                $query = 'insert into ld_approve2user(approveid,userid) values('.$approveid.','.$user.') ';
                $adb->pquery($query,array());
            }
        }
    }else{//通过传递的审批流程ID，获取对应的用户信息
        $query = 'select GROUP_CONCAT(userid) AS userid from ld_approve2user 
                    where approveid = '.$approveid.' ';
        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $userid = '';
        if($rows > 0){
            $userid = $adb->query_result($result,0,'userid');
        }
        echo $userid;die;
    }
    die;
}

/**************************************************************************
**edit:kevin
**date:2013-08-15
**reason:审批流程管理序时簿
**************************************************************************/

global $theme,$mod_strings,$app_strings,$default_charset;

$approve=new Approve();
$startapprove=$approve->startBlocksApprove();
$modulename = getTabModuleName($tabid);

$query="SELECT tablename,ld_field.tabid,T1. NAME,T1.tablabel FROM ld_field INNER JOIN (
	SELECT * FROM ld_tab WHERE presence IN (0, 2) ORDER BY tabsequence ) AS T1 ON ld_field.tabid = T1.tabid
    WHERE ld_field.columnname = 'approveby' AND ld_field.tabid <> 29 AND ld_field.tabid IN (
	SELECT ld_tab.tabid FROM ld_systems_deploy INNER JOIN ld_tab ON ld_tab.`name` = ld_systems_deploy.setype
	WHERE setype IS NOT NULL AND setype <> ''  AND ld_systems_deploy.id > 0 ORDER BY  ld_systems_deploy.id)";


$result=$adb->query($query);

$num_rows=$adb->num_rows($result);
$tab=array();
if($num_rows){
    $count=0;
    for($i=0;$i<$num_rows;$i++){
        $tabid=$adb->query_result($result,$i,'tabid');
        $module=$adb->query_result($result,$i,'name');
        if($tabid==22){
            
            $blockid=$tabid;
            
            $count++;
        }
        
        $tab[]=array('tabid'=>$tabid,
        'tabname'=>getTranstab($module)
        );
        
    }

    if(!$count)
    $blockid=$adb->query_result($result,0,'tabid');
}

if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
    $blockid=$_REQUEST['blockid'];

if(isset($_REQUEST['formodule']) && $_REQUEST['formodule']!='undefined'){
    $blockid=getTabid($_REQUEST['formodule']);
    if($blockid==16)$blockid=9;
}
if(is_array($startapprove) && in_array($blockid,$startapprove)){
    $module_approve = 0;
}else{
    $module_approve = 1;
}
$blockmodulename = getTabname($blockid);
if($approve->Blocksquicksubmit($blockmodulename)){
    $quick_submit = 0;
}else{
    $quick_submit = 1;
}
if($approve->recordAgainSubmit($blockmodulename)){
    $again_submit = 0;
}else{
    $again_submit = 1;
}
if($approve->ShowDisabledApprove($blockmodulename)){
    $showdisabledapprove = 0;
    $presence_sql = '';
}else{
    $showdisabledapprove = 1;
    $presence_sql = ' and status = 0 ';//不显示停用的审批流程
}
$noapprovalshowempty = getUsersettingByLabel($blockmodulename,1,'NoApprovalShowEmpty');//xxy 2023-12-14 无默认审批流时显示为空 参数

$smarty=new lingdangCRM_Smarty;
$smarty->assign('MODULE_APPROVE',$module_approve);
$smarty->assign('QUICK_SUBMIT',$quick_submit);
$smarty->assign('AGAIN_SUBMIT',$again_submit);
$smarty->assign('SHOWDISABLEDAPPROVE',$showdisabledapprove);
$smarty->assign('NOAPPROVALSHOWEMPTY',$noapprovalshowempty);

$smarty->assign('TAB',$tab);
$query="select * from ld_approve where tabid=? $presence_sql ORDER BY sequence ,createdtime asc";
$result=$adb->pquery($query,array($blockid));
$num_rows=$adb->num_rows($result);
$approve=array();
//editor:gyq_132 reason:审批流程默认值改进，增加default_on_new,default_on_submit  2019/7/22 15:26 ID1000479
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $approveallocatetype=$adb->query_result($result,$i,'approveallocatetype');
        $allocatetypeInfo=getApproceUser($adb->query_result($result,$i,'id'),$approveallocatetype);
        $approve[]=array('id'=>$adb->query_result($result,$i,'id'),
        'tabid'=>$adb->query_result($result,$i,'tabid'),
        'name'=>$adb->query_result($result,$i,'name'),
        'status'=>$adb->query_result($result,$i,'status'),
        'description'=>$adb->query_result($result,$i,'description'),
        'allocatetypeidLink' =>$allocatetypeInfo[0]['allocatetypeidLink'],
        'allocatetypenameLink' =>$allocatetypeInfo[0]['allocatetypenameLink'],
        'approveallocatetype'=>$adb->query_result($result,$i,'approveallocatetype'),
        'default_on_new'=>$adb->query_result($result,$i,'default_on_new'),
        'default_on_submit'=>$adb->query_result($result,$i,'default_on_submit'),
        'allowagainsubmit'=>$adb->query_result($result,$i,'allowagainsubmit'),
        'isnewapprove'=>$adb->query_result($result,$i,'isnewapprove')

        );
    }
}
$smarty->assign('MODULENAME',$modulename);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
$smarty->assign('APPROVE',$approve);

$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);
$smarty->assign('COUNT',$num_rows);
$smarty->assign('LANGUAGETYPE',$languageType);
// require_once('SetmenuControl.php');

/**
 *parameter:approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配. 
 **/
function getApproceUser($approceid,$approveallocatetype)
{
        global $adb; 
        if($approveallocatetype==0)
        {
            
            $allocatename = getFixedLabel('ALLTHEUSERS');  
             $allocatetypeInfo[]=array
            (
              'allocatetypeidLink'=>'-1',
              'allocatetypenameLink'=>$allocatename
            );
            return $allocatetypeInfo;
        }
        if($approveallocatetype==1)//部门
        {
             $query1 = "SELECT allocateid,allocatename,approveid FROM(
                      
                    	SELECT	
                    		 ld_groups.groupid    as allocateid,
                             '' as wx_userid,
                    		 ld_groups.groupname AS allocatename,
                    		 approveid
                    	FROM
                    		ld_approve2user
                    	INNER JOIN ld_approve ON ld_approve.`id`=ld_approve2user.approveid
                    	INNER JOIN ld_groups  ON ld_groups.groupid = ld_approve2user.`userid`
                    	WHERE ld_approve.approveallocatetype=1 
                    	
                    )AS alldata
                    WHERE alldata.approveid=? order by approveid desc;";
        }
        else if($approveallocatetype==2)
        {
            $query1 = "SELECT allocateid,allocatename,approveid FROM (
                      
                    	SELECT	
                    		 ld_users.id as allocateid,
                             ld_users.wx_userid,
                    		 ld_users.`last_name` AS allocatename ,
                    		 ld_approve2user.approveid
                    	FROM
                    		ld_approve2user
                    	INNER JOIN ld_approve ON ld_approve.`id`=ld_approve2user.approveid
                    	INNER JOIN ld_users ON ld_users.`id` = ld_approve2user.`userid`
                    	WHERE ld_approve.approveallocatetype=2 
                    )AS alldata
                    WHERE alldata.approveid=? order by approveid desc;";
        }
        else if($approveallocatetype==3)//按角色
        {
            $query1 = "SELECT allocateid,allocatename,approveid FROM(
                      
                    	SELECT	
                    		 ld_profile.profileid    as allocateid,
                             '' as wx_userid,
                    		 ld_profile.profilename AS allocatename,
                    		 approveid
                    	FROM
                    		ld_approve2user
                    	INNER JOIN ld_approve ON ld_approve.`id`=ld_approve2user.approveid
                         inner join ld_profile on ld_profile.profileid=ld_approve2user.userid
                    	WHERE ld_approve.approveallocatetype=3 
                    	
                    )AS alldata
                    WHERE alldata.approveid=? order by approveid desc;";
                   
                  
        }
       
        $result1=$adb->pquery($query1,array($approceid));
        $num_rows1=$adb->num_rows($result1);
         if($num_rows1 > 0){
            $userLink = '';
            for($i=0;$i<$num_rows1;$i++){
                $allocateid = $adb->query_result($result1,$i,'allocateid');
                $allocatename = $adb->query_result($result1,$i,'allocatename');
                if($allocatename=='AllUser')//所有用户。
                {
                  $allocatename = getFixedLabel('ALLTHEUSERS');  
                }
                else if($approveallocatetype==1){//部门
                    $groupobj=new Users();
                    $groupobj->groupid=$allocateid;
                    $groupobj->groupname=$allocatename;
                    $allocatename=getWx_GroupName($groupobj);
                }
                else if($approveallocatetype==2){//用户
                    $userobj=new Users();
                    $userobj->id=$allocateid;
                    $userobj->last_name=$allocatename;
                    $userobj->wx_userid=$adb->query_result($result1,$i,'wx_userid');
                    $allocatename=getUserlastName($userobj);
                    
                }
                else if($approveallocatetype==3)
                {
                    //按角色
                    
                }
                $allocatetypeidLink .= $allocateid.',';
                $allocatetypenameLink .= $allocatename.'、';
            }
         
            $allocatetypeidLink = trim($allocatetypeidLink,',');
            //$allocatetypenameLink = trim($allocatetypenameLink,'、');
            // mb_internal_encoding("UTF-8");
			// $encoding = mb_internal_encoding();
			
			  
            $allocatetypenameLink = mb_rtrim($allocatetypenameLink,'、','UTF-8');
            $allocatetypeInfo[]=array
            (
              'allocatetypeidLink'=>$allocatetypeidLink,
              'allocatetypenameLink'=>$allocatetypenameLink
            );
         }
         return  $allocatetypeInfo;
}
setGLobalURLSmarty($smarty);//js,css加载的url
$_REQUEST['diony']='yes';


//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//审批流定制帮助
$labels = array('MultiApproveList');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);


if(isset($_REQUEST['directmode']) && $_REQUEST['directmode']=='ajax')
{
    //选择模块：仅更新下方表格，显示对应表格内容
    $arr['content']= $smarty->fetch('Approve/MultiApproveLists.tpl');
    //选择模块：增加更新单选框的状态
    $arr['module_approve'] = $module_approve;
    $arr['quick_submit'] = $quick_submit;
    $arr['again_submit'] = $again_submit;
    $arr['showdisabledapprove'] = $showdisabledapprove;
    $arr['noapprovalshowempty'] = $noapprovalshowempty;
    ConvertTojsonString(1,$arr,"success");
}
else
{
    if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
        $smarty->display('Approve/MultiApproveEntries.tpl');
        exit();    
    }
    else {
        $arr['content']= $smarty->fetch('Approve/MultiApproveList.tpl');
        ConvertTojsonString(1,$arr,"success");
    }
}
?>