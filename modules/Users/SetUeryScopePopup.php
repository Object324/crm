<?php
/**
 * edit:andrew
 * date:2015-6-17
 * reason:显示授权范围模块选择层
 **/
 
 $permit=isPermitted("Users","DataScope");
 if($permit=='no')
 {
    exit("没有权限");
 }
global $current_user,$adb;
$allModule = array();
$uid = $_REQUEST['uid'];//用户ID
$uid=trim($uid,";");

$uids=explode(";",$uid);
$uids_len = sizeOf($uids);
$uid=$uids[0];

$type = $_REQUEST['type'];//UserSelect：授权范围选择高级用户和高级部门  UserModuleSet：获取用户所有模块授权范围
$selectmodule = $_REQUEST['selectmodule'];	//选择的授权范围模块
$selectmod = $_REQUEST['selectmod'];	// 授权范围类型
if(!empty($uid)){
    if($type=='UserSelect'){
		$userViewIdArray = getUserModuleScopeHigher($selectmod,$uid,$selectmodule);
		foreach($userViewIdArray as $userid){
			$viewid[] = $userid;
		}
		echo implode(',',$viewid);
        exit();
    }elseif($type=='UserModuleSet'){//获取用户
        $modulescolist = getAllModuleScope();//获取所有授权范围的模块
        
		$usermodulescope = getUserAllModuleScope($uid);//获取所有用户的模块授权范围
        
        $tmpusermodulescope=$usermodulescope;
        foreach($tmpusermodulescope as $tmpmodulename=>$info )
        {
            //删除，用户模块，银行账户模块
            $tmpyes='no';
            foreach($modulescolist as $index=>$tmp_moduleinfo)
            {
                //@edit:liushuai,2021-07-16,reason:0046947: （https://81mis.com/kfbcrm/ [^]）成员管理->数据范围，去掉“邮件管理”
                if ($tmp_moduleinfo['modulename'] == 'Emails') {
                    unset($modulescolist[$index]);
                    break;
                }
                //zkt 0048170: （https://81mis.com/kfbcrm [^]）成员管理中设置数据范围，找到‘签到’，点击按部门，选择部门的界面出现错误
                /*if ($tmp_moduleinfo['modulename'] == 'Singin') {
                    unset($modulescolist[$index]);
                    break;
                }*/
                if($tmp_moduleinfo['modulename']==$tmpmodulename)
                {
                    $tmpyes='yes';
                    break;
                }
            }
            if($tmpyes=='no')
            {
                unset($usermodulescope[$tmpmodulename]);
            }
        }
		$userViewIdArray = getUserModuleScopeHigher($uid);//获取用户授权范围内的用户、部门信息
		$is_admin = getUserAdmin($uid);
		foreach($modulescolist as $index => $module_info){
			$scopeviewid = '';
			$scopeauthority = 0;
            $operation='';
            $viewothers=0;
            $delothers=0;
            $viewselfbills=0;
            $editothers=0;
            $module=$module_info['modulename'];
            
           if($module=='PromotionSetting'||$module=='MarketSpread')
                continue;
           // zkt 20221229 BUG0060258去除报表分析数据范围中的其他复选框
           //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块（去除其他复选框）//BUG20240508-13 ls 240511 目标管理，数据范围去掉“查看其他成员的单据详情”等数据权限
           if($module=='ReportAnalysis' || $module=='VisualAnalysis'|| $module=='SalesGoal'){
                $module_info['operation'] = '';
           }
			if(isset($usermodulescope[$module])){
				$scopeauthority = $usermodulescope[$module]['scopeauthority'];
                $viewothers= $usermodulescope[$module]['viewothers'];
                $editothers= $usermodulescope[$module]['editothers'];
                $delothers= $usermodulescope[$module]['delothers'];
                $viewselfbills= $usermodulescope[$module]['viewselfbills'];
                $editcreateme=$usermodulescope[$module]['editcreateme'];
                $viewcreateme=$usermodulescope[$module]['viewcreateme'];
                
			}
            
			if(!empty($userViewIdArray[$module])){
				$scopeviewid = implode(',', $userViewIdArray[$module]);
			}
			//管理员 默认为全部
			if($is_admin == 'on' && $scopeauthority == ''){
				$scopeauthority = 1;
                if($is_admin == 'on')
                {
                    $viewothers=1;
                    $delothers=1;
                    $viewselfbills=1;
                    $editothers=1;
                    $viewcreateme=1;
                    $editcreateme=1;
                }
			}
			$usermodulescope[$module]['scopeauthority'] = $scopeauthority;
			$usermodulescope[$module]['scopeviewid'] = $scopeviewid;
            $usermodulescope[$module]['delothers'] = $delothers;
            $usermodulescope[$module]['editothers']=$editothers;
            $usermodulescope[$module]['viewothers']=$viewothers;
            $usermodulescope[$module]['viewcreateme']=$viewcreateme;
            $usermodulescope[$module]['viewselfbills']=$viewselfbills;
            $usermodulescope[$module]['editcreateme']=$editcreateme;
            $usermodulescope[$module]['tabname']=$module_info['tabname'];
            
            $usermodulescope[$module]['operation']=$module_info['operation'];
		}
    }

}

//var_dump(array_keys($modulescolist));
//var_dump($usermodulescope);

$smarty = new lingdangCRM_Smarty;
if($uids_len > 1){
    $tmp_uid = '';
	$smarty->assign("UID",'');	
}else{
    $tmp_uid = $uid;
	$smarty->assign("UID",$uid);
}
//所有
$query = "select GROUP_CONCAT(viewid),scopeauthority from ld_scoperhigher where userid = ? and modulename = 'All'";
$result = $adb->pquery($query,array($uid));
if($adb->num_rows($result) >= 1){
	$scopeid = $adb->query_result($result,0,0);
	$scope = $adb->query_result($result,0,1);
}
$smarty->assign('SCOPE',$scope);
$smarty->assign('SCOPEID',$scopeid);
$smarty->assign("MODULESCOPE",$usermodulescope);
$allModule = array_keys($usermodulescope);
$smarty->assign("MODULELISTVAR",implode(',',$allModule));

$_REQUEST['diony']='yes';

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//数据范围帮助
$labels = array('ScopeAuthority');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Users',1,'HelpUrl_'.$label);
}
//$smarty->assign("HelpHtml", $helpHtmlArr['ScopeAuthority']);
$title = getFixedLabel('Thequeryscope');
if (!empty($helpHtmlArr['ScopeAuthority'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['ScopeAuthority'].'</div>';
}

$arr['content']=$smarty->fetch("SetUeryScopePopup.tpl");
$arr['UID']=$tmp_uid;
$arr['title']=$title;
$arr['oktext']=getFixedLabel('CONFIRMED');
$arr['canceltext']=getFixedLabel('CANCEL');
ConvertTojsonString(1,$arr,'success');

//$smarty->display("SetUeryScopePopup.tpl");
//exit();
/**
 * 获取所有有授权范围的模块
 * @return 回传所有模块的授权方式信息
 * @project 6.1 业务单据授权范围改进
 * @author Chj 2015/6/29
 */
function getAllModuleScope(){
	global $adb,$current_user;
	require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
	$query = 'select ld_tab.tabid,ld_tranlabel.fieldlabel as tabname,ld_tab.name,ld_profileallpermission.operation
				from ld_tab 
			inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid 
            LEFT JOIN ld_profileallpermission on ld_tab.tabid=ld_profileallpermission.tabid and ld_profileallpermission.operation=1
				where languagetype=? and trantable=? and ld_tab.`name` not in ("MassEmails","MassSMS","SmsPhrases","EmailListtmp","CommunicationLog","Navigation","InventoryLedger","InventoryAccount",
                            "InventoryQuery","Prdtnums","BankCash","Reports","Cache","Users","Tooltip",
                            "ModTracker","lingdangBackup","FieldFormulas","Events","Dashboard","Events","Rss",
                            "Portal","ConfigEditor","Import","Integration","Mbile","PBXManager","Services",
                            "lingdangBackup","WSAPP","Assets","CronTasks","SMSNotifier","Webforms","Announcements",
                            "MassFaxs","MassVoices","mobileAccounts","mobileContacts","mobileContactRecords",
                            "mobileSalesOrder","GraphicalReports","mobileProducts","mobilePublicAnnouncement",
                            "mobileHelpDesk","RecycleBin","CustomerPortal","Customreport",
                            "Reminds","MailManager","ChinaMap","CustomEcharts","ShopSettings","Shopping") AND (ld_tab.presence IN (0,2,5) or ld_tab.tabid=-2)
		
	GROUP BY ld_tab.tabid,languagetype,tabid 
			ORDER BY ld_tab.tabsequence;';
	$result = $adb->pquery($query,array($languageType,'ld_tab'));
	$num_rows = $adb->num_rows($result);
    //公海未分配客户不控制数据权限（可查询所有公海未分配客户）)0：不控制，1：控制
    //$status=getAccount_Set('status');
   // $dataprofile=getAccount_Set('dataprofile');
	if($num_rows > 0){
		for($i = 0; $i<$num_rows; $i++){
			$modulename = $adb->query_result($result,$i,'name');
			if($modulename=='PromotionSetting'||$modulename=='MarketSpread')
			    continue;
            //@edit:liushuai,2020-09-17,reason:0042188/模块管理中关闭模块后，成员管理数据范围中对应模块没有关闭
            //移动端报表比较特殊，需要开启(PC端设置数据范围时显示，并且设置范围是全部时，移动端销售简报查看范围需要可选成员)
            if (!vtlib_isModuleActive($modulename) && $modulename != 'MobileReport')
                continue;
            
			$modulescolist[]=array('tabname'=>$adb->query_result($result,$i,'tabname'),'modulename'=>$adb->query_result($result,$i,'name'),
            'tabid'=>$adb->query_result($result,$i,'tabid'),'operation'=>$adb->query_result($result,$i,'operation'));
            /*if($modulename=='Accounts'&&$status==0&&$dataprofile==1)
            {
                	$modulescolist[]=array('tabname'=>getFixedLabel('LBL_NOALLOCATE'),'modulename'=>NOALLOCATEACCOUNTS,
                'tabid'=>10000000,'operation'=>$adb->query_result($result,$i,'operation'));
            }*/
            
		}
	}
    
	return $modulescolist;
}

/**
 * 获取用户所有模块的授权类型
 * @return 回传用户所有模块的授权方式信息
 * @project 6.1 业务单据授权范围改进
 * @author Chj 2015/7/6
 */
function getUserAllModuleScope($uid){
	global $adb,$current_user;
    //公海未分配客户不控制数据权限（可查询所有公海未分配客户）)0：不控制，1：控制
    //$status=getAccount_Set('status');
    //$dataprofile=getAccount_Set('dataprofile');
    
	$query = 'select ld_tab.name as modulename,scopeauthority,viewothers,delothers,editothers,viewselfbills,editcreateme,viewcreateme from ld_tab left join (
        select scopeauthority,modulename,viewothers,delothers,editothers,viewselfbills,editcreateme,viewcreateme from
              
            ld_setscoperhigher   where userid = ?
        ) as tmp on tmp.modulename=ld_tab.name
            order by ld_tab.tabsequence asc 
         ';
   
	$result = $adb->pquery($query,array($uid));
	$num_rows = $adb->num_rows($result);
	if(!empty($num_rows)){
		for($i = 0; $i<$num_rows; $i++){
    		 
			$modulename = $adb->query_result($result,$i,'modulename');
             /*if($modulename==NOALLOCATEACCOUNTS&&($status==1||$dataprofile==0))
              {
                continue;
                
              }*/
			$modulescolist[$modulename]['scopeauthority'] = $adb->query_result($result,$i,'scopeauthority');
            $modulescolist[$modulename]['editcreateme'] = $adb->query_result($result,$i,'editcreateme');
            $modulescolist[$modulename]['viewothers'] = $adb->query_result($result,$i,'viewothers');
            $modulescolist[$modulename]['viewcreateme'] = $adb->query_result($result,$i,'viewcreateme');
            $modulescolist[$modulename]['editothers'] = $adb->query_result($result,$i,'editothers');
            $modulescolist[$modulename]['delothers'] = $adb->query_result($result,$i,'delothers');
            $modulescolist[$modulename]['viewselfbills'] = $adb->query_result($result,$i,'viewselfbills');
            /*if($modulename=='Accounts'&&$status==0&&$dataprofile==1)
            {
                 if($i<$num_rows-1)
                 {
                    $tmpsql='select * from ld_setscoperhigher where userid=? and modulename=?';
                    $tmpresult=$adb->pquery($tmpsql,array($uid,NOALLOCATEACCOUNTS));
                    if($adb->num_rows($tmpresult)>0)
                    {
                          $modulescolist[NOALLOCATEACCOUNTS]['scopeauthority'] = $adb->query_result($tmpresult,0,'scopeauthority');
                          $modulescolist[NOALLOCATEACCOUNTS]['viewothers'] = $adb->query_result($tmpresult,0,'viewothers');
                          $modulescolist[NOALLOCATEACCOUNTS]['viewcreateme'] = $adb->query_result($tmpresult,0,'viewcreateme');
                          $modulescolist[NOALLOCATEACCOUNTS]['editothers'] = $adb->query_result($tmpresult,0,'editothers');
                          $modulescolist[NOALLOCATEACCOUNTS]['delothers'] = $adb->query_result($tmpresult,0,'delothers');
                          $modulescolist[NOALLOCATEACCOUNTS]['viewselfbills'] = $adb->query_result($tmpresult,0,'viewselfbills');
                          $modulescolist[NOALLOCATEACCOUNTS]['editcreateme'] = $adb->query_result($tmpresult,0,'editcreateme');
                    }
                    else
                    {
                        
                            $modulescolist[NOALLOCATEACCOUNTS]['scopeauthority'] = $adb->query_result($result,$i,'scopeauthority');
                            $modulescolist[NOALLOCATEACCOUNTS]['viewothers'] = $adb->query_result($result,$i,'viewothers');
                            $modulescolist[NOALLOCATEACCOUNTS]['viewcreateme'] = $adb->query_result($result,$i,'viewcreateme');
                            $modulescolist[NOALLOCATEACCOUNTS]['editothers'] = $adb->query_result($result,$i,'editothers');
                            $modulescolist[NOALLOCATEACCOUNTS]['delothers'] = $adb->query_result($result,$i,'delothers');
                            $modulescolist[NOALLOCATEACCOUNTS]['viewselfbills'] = $adb->query_result($result,$i,'viewselfbills');
                            $modulescolist[NOALLOCATEACCOUNTS]['editcreateme'] = $adb->query_result($result,$i,'editcreateme');
                        
                    }
                 }
                
            }*/
            
		}
	}
   
	return $modulescolist;
}
/**
 * 获取用户单个模块的高级用户、高级部门的授权范围
 * @param 
 * @return 回传模块的高级授权范围信息
 * @project 6.1 业务单据授权范围改进
 * @author Chj 2015/6/29
 */
function getUserModuleScopeHigher($userid){
	global $adb,$current_user;
	if(!empty($userid)){

		$query = 'SELECT DISTINCT viewid,modulename FROM ld_scoperhigher WHERE userid = ?';
		$result = $adb->pquery($query,array($userid));
		$num_rows = $adb->num_rows($result);
		if($num_rows>0){
			for($i = 0; $i<$num_rows; $i++){
				$modulename = $adb->query_result($result,$i,'modulename');
				$scopViewId[$modulename][] = $adb->query_result($result,$i,'viewid');
			}
		}
		return $scopViewId;
	}
}

function getUserAdmin($userid){
	global $adb;
	if(!empty($userid)){
		$query = 'select is_admin from ld_users where id = ? limit 1';
		$result = $adb->pquery($query,array($userid));
		$is_admin = $adb->query_result($result,0,0);
		return $is_admin;
	}
}
?>