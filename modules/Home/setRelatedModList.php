<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author andrew 2015-05-27
 */
global $adb,$mod_strings;
global $current_user;
global $relationId;
global $related_left_type;
global $related_func_type;
global $related_left_id;
global $related_left_record;
global $related_left_tabid;
global $related_left_mod;
global $related_left_customView;
global $related_left_viewid;
global $related_left_listmodule;
global $related_header;
$relationId =  vtlib_purify($_REQUEST['relatedid']);
$roleID =  vtlib_purify($_REQUEST['record']);
if(!empty($relationId) && ((int)$relationId) > 0) {
	$header = vtlib_purify($_REQUEST['header']);//module;
     $related_header = $header;
	$related_left_type = vtlib_purify($_REQUEST['related_left_type']);//;
	if(empty($header)) return '';

    $smarty = new lingdangCRM_Smarty;
    crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
    $workreportshowobj=new cls_workreportshow();
    $allshowtype=$workreportshowobj->getWorkReportShow();
    $smarty->assign("WORKREPORTSHOW",$allshowtype);
	//查看范围选择下拉框
	$workrangearr = array(
		'all'=>'全部',
        'weibo'=>getFixedLabel('BLOG'),
		'logday'=>getFixedLabel('JOURNAL'),
		'logweek'=>getFixedLabel('WEEKPLAN'),
		'logmonth'=>getFixedLabel('MONTHPLAN'),
        'cocmd'=>getFixedLabel('TASK')
	);
	$cur_releasetext = getFixedLabel('RELEASENEW');	
	if($languageType == 'en'){
	  $cur_releasetext .= ' ';
	}
	if($allshowtype[0]['type']=="weibo"){
	  $cur_panel_tag = 'weibo';
	  $cur_releasetext .= getFixedLabel('BLOG');
	}
	else if($allshowtype[0]['type']=="dayreport"){
	  $cur_panel_tag = 'day';
	  $cur_releasetext .= getFixedLabel('JOURNAL');
	}
	else if($allshowtype[0]['type']=="weekreport"){
	  $cur_panel_tag = 'week';
	  $cur_releasetext .= getFixedLabel('WEEKPLAN');
	}
	else if($allshowtype[0]['type']=="monthreport"){
	  $cur_panel_tag = 'month';
	  $cur_releasetext .= getFixedLabel('MONTHPLAN');
	}
	else if($allshowtype[0]['type']=="cocmd"){
	  $cur_panel_tag = 'cocmd';
	  $cur_releasetext .= getFixedLabel('TASK');
	}
	$cur_releasetext .= '...';
	$smarty->assign("cur_panel_tag",$cur_panel_tag);
	$smarty->assign("cur_releasetext",$cur_releasetext);
	$smarty->assign("WORKRANGEARR", $workrangearr);
	$smarty->assign("LANGEUAGETYPE", $languageType);
	$smarty->assign('HOMECONTROL',1);
	$smarty->assign('HEADER',$related_header);

	//工作协同，当前登陆用户头像，edit:can 
	$Sql='select last_name,ld_attachments.name,ld_attachments.path,ld_attachments.attachmentsid,reader from ld_users    
			 left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
		   left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
		   where ld_users.id=?';
	$result=$adb->pquery($Sql,array($current_user->id));

	$userid = $current_user->id;
	$lastname = $adb->query_result($result,0,'last_name');
	$userimgpath = $adb->query_result($result,0,'path');
	$userimgname = $adb->query_result($result,0,'name');
	$attachmentsid = $adb->query_result($result,0,'attachmentsid');
	$reader=$adb->query_result($result,0,'reader');
	if(empty($reader))
	{
		$reader=1;
	}
	if(file_exists('user_privileges/user_privileges_'.$reader.'.php'))
	{
		require('user_privileges/user_privileges_'.$reader.'.php');
		$readername=$user_info['last_name'];
	}
	else
	{
			$sql='select last_name from ld_users where id=?';
			$readerresult=$adb->pquery($sql,array($reader));
			if($adb->num_rows($readerresult)>0)
			{
					$readername=$adb->query_result($readerresult,0,0);
			}
	}
				
	if(!empty($userimgpath) && !empty($userimgname))
	{
		$userimgnamearr = explode('.',$userimgname);
		$userimgpath .= $attachmentsid.'_1.'.$userimgnamearr[1];
	}
	if(empty($userimgpath) || !file_exists($userimgpath)){
        // ljj 20231201 XUQIU1000927 更换默认头像
        $userimgpath=getDefaultAvatar($userid);
    }
	$userInfo['image']=  $userimgpath;
	$userInfo['name']=$lastname;
	$userInfo['id']=$current_user->id;
	$userInfo['readerid']=$reader;
	$userInfo['readername']=$readername;
	$smarty->assign('USERINFO',$userInfo);
	$smarty->assign('CURRENT_USERID',$current_user->id);
    
    $Sql = "select organizationname from ld_organizationdetails";
    $organiresult = $adb->pquery($Sql,array());
	require_once 'modules/Home/ExpressionList.php';//获取表情列表
    $smarty->assign('FILESNAMELIST',$filesnamelist);
	require 'modules/Home/WorkReportController.php';
	$work_focus = new WorkReportController();
	$entitytype = 'workreport';
	$workfieldarray = $work_focus->getWorkFieldInfo($entitytype);
	$smarty->assign('WORKFIELDARRAY',$workfieldarray);
  $smarty->assign('WORKREPORTTYPE','RELATE');
  $smarty->assign('ROLEID',$roleID);
    //duan 20221216 获取当前用户的头像
    $userimageinfo = getUser_imageInfo($current_user->id);
    $imageinfo = $userimageinfo['imagename'][0];
    if(empty($imageinfo)){
        // ljj 20231201 XUQIU1000927 更换默认头像
        $userimage=getDefaultAvatar($current_user->id);
        $smarty->assign('userimage',$userimage);
    }else{
        if($imageinfo['storage_location'] == 'cos'){
            $userimage = $imageinfo['cloud_path'];
        }else{
            $userimage = $imageinfo['file_path'].$imageinfo['newfile_name'];
        }
        $smarty->assign('userimage',$userimage);
    }
  setGLobalURLSmarty($smarty);//设置js,css等访问路径
  $smarty->display("Home/Coordination.tpl");
    
}

?>