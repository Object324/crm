<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

require_once(globalStatic::$root_directory.'include/home.php');

include  globalStatic::$root_directory.'modules/Home/HomeUtils.php';
global $app_strings, $app_list_strings, $mod_strings;
global $adb, $current_user,$currentModule;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$regop=RegOp::getInstance();
$crmversion=$regop->GetVersionNo();
//$smarty = new lingdangCRM_Smarty;
$homeObj=new Homestuff;
$smarty=new lingdangCRM_Smarty;

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
if(!empty($_REQUEST['report_user_id'])&&$_REQUEST['report_user_id']!='all'){
     crm_load_class_file('RecordEncrypt','include');
	$userid = $_REQUEST['report_user_id'];
    
    $Obj=new RecordEncrypt("User",$userid);
    $userid=$Obj->decrypt();
  
     if(empty($userid))
     {
        exit("参数错误！");
     }
	$smarty->assign('REPORT_USER_ID',$userid);
}else{
	$userid = $current_user->id;
}
$user_name = $current_user->column_fields['user_name'];
if($current_user->is_admin=="on")
{
    $smarty->assign('ISADMIN',1);
}

//删除日志按钮是否显示
$isdelete = 'no';
if($current_user->user_name == 'admin' && empty($_REQUEST['massdelete'])){
	$isdelete = 'yes';
}
$smarty->assign('INFO',$_REQUEST['info']);
$smarty->assign('ISDELETE',$isdelete);
$smarty->assign("FIELDARRAY",$field_array);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("MODULE",'Home');
$smarty->assign("CATEGORY",getParenttab('Home'));
$smarty->assign("CURRENTUSER",$user_name);
$smarty->assign("HOMEFRAME",$homedetails);
$smarty->assign("REPORTTYPE", 'month');

$smarty->assign("LANGEUAGETYPE", $languageType);
setGLobalURLSmarty($smarty);

//echo $_REQUEST['selectuid'];
$smarty->assign("SENIORUSERIDSS",$_REQUEST['selectuid']);
crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
$workreportshowobj=new cls_workreportshow();
$allshowtype=$workreportshowobj->getWorkReportShow();
//微博 任务 默认高度和默认值
foreach ($allshowtype as $key => $typeinfo){
    if ($typeinfo['type'] == 'weibo' || $typeinfo['type'] == 'cocmd'){
        $workreporttype = $typeinfo['type'] == 'weibo'?4:5;
        $typeselect_sql = 'select defaultvalue,defaultheight from ld_workreport_field where name=? and type = ?';
        $type_result = $adb->pquery($typeselect_sql,array('workexperience',$workreporttype));
        $type_num_rows = $adb->num_rows($type_result);
        if ($type_num_rows > 0){
            $weibo_cocmd_info[$typeinfo['type']]['defaultvalue'] = $adb->query_result($type_result,0,'defaultvalue');
            $weibo_cocmd_info[$typeinfo['type']]['defaultheight'] = $adb->query_result($type_result,0,'defaultheight');
        }
    }
}
$smarty->assign('weibo_cocmd_info',$weibo_cocmd_info);

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
$smarty->assign("WORKREPORTSHOW",$allshowtype);
// 是否激活
$smarty->assign('HasCalendar','yes');
if(!vtlib_isModuleActive('Calendar')){
  $smarty->assign('HasCalendar','no');
}
// 是否有新增权限
$smarty->assign('HasCalendarCreate','no');
if(isPermitted('Calendar', 'Create', '') == 'yes'){
  $smarty->assign('HasCalendarCreate','yes');
}
foreach($allshowtype as $index=>$content){
  $showcontents[]=$content['type'];   
}

//设置工作汇报是否允许选择日期  0是  1否
//$sys = getSys_deploy(198);
//$smarty->assign('DEPLOY',$sys['deploy_value']);
if(2 != $versioninfo['versiontype']){//不是销售通
	$versiontrade = get_versiontrade();
	$homecontrol = 1;
	$smarty->assign('HOMECONTROL',$homecontrol);
	//查看范围选择下拉框
	$workrangearr = array(
    'weibo'=>getFixedLabel('BLOG'),
		'logday'=>getFixedLabel('JOURNAL'),
		'logweek'=>getFixedLabel('WEEKPLAN'),
		'logmonth'=>getFixedLabel('MONTHPLAN'),
    'cocmd'=>getFixedLabel('TASK')
	);
  if(!in_array('dayreport',$showcontents)){
    unset($workrangearr['logday']);
  }
  if(!in_array('weekreport',$showcontents)){
    unset($workrangearr['logweek']);
  }
  if(!in_array('monthreport',$showcontents)){
    unset($workrangearr['logmonth']);
  }
  if(!in_array('weibo',$showcontents)){
  	unset($workrangearr['weibo']);
  }
  if(!in_array('cocmd',$showcontents)){
    unset($workrangearr['cocmd']);
  }	
	
	if(!empty($_REQUEST['report_user_id'])){
		$workrangearr['workreply'] = '工作回复';
		$workrangearr['atmywork'] = '@我的工作';
		$workrangearr['atmyreply'] = '@我的回复';
	}
	$smarty->assign("WORKRANGEARR", $workrangearr);
	$dateselect = array(
		'all'=>getFixedLabel('ALL'),
		'today'=>getFixedLabel('checktoday'),
		'yesterday'=>getFixedLabel('checkyesterday'),
		'thisweek'=>getFixedLabel('thisweek'),
		'lastmonth'=>getFixedLabel('lastmonth'),
		'thismonth'=>getFixedLabel('thismonth'),
		'thisyear'=>getFixedLabel('THISYEAR'),
		'custom'=>getFixedLabel('custom'),
	);
	$smarty->assign('DATESELECT',$dateselect);
	//工作协同，当前登陆用户头像，edit:can 
	$Sql='select last_name,ld_attachments.newfile_name as name,ld_attachments.path,ld_attachments.attachmentsid,
				 ld_attachments.storage_location,ld_attachments.cloud_path,reader,wx_userid,ld_users.id from ld_users    
			 left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
		   left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
		   where ld_users.id=?';
	$result=$adb->pquery($Sql,array($userid));
	if($adb->num_rows($result)>0)
	{
		$userobj=new Users();
		$lastname = $adb->query_result($result,0,'last_name');
	    $wx_userid=$adb->query_result($result,0,'wx_userid');
	    $userid=$adb->query_result($result,0,'id');
	    $userobj->last_name=$lastname;
	    $userobj->wx_userid=$wx_userid;
	    $userobj->id=$userid;
	    
		$userimgpath = $adb->query_result($result,0,'path');
		$userimgname = $adb->query_result($result,0,'name');
		$storage_location = $adb->query_result($result,0,'storage_location');
		$cloud_path = $adb->query_result($result,0,'cloud_path');
		$attachmentsid = $adb->query_result($result,0,'attachmentsid');
		$reader=$adb->query_result($result,0,'reader');
		if(empty($reader))
		{
			$reader=1;
		}
	    
		if(file_exists('user_privileges/user_privileges_'.$reader.'.php'))
		{
	        $tmpuser=new Users();
	        $tmpuser->id=$reader;
	        $user_info=getuserInfoByPrivileges($tmpuser);
	        
			$readername=$user_info['last_name'];
	        $tmpuser->last_name=$readername;
	        
	        $reader_wx_userid=$user_info['wx_userid'];
	        $tmpuser->wx_userid=$reader_wx_userid;
		}
		else
		{
			$tmpuser=new Users();
			$sql='select last_name,wx_userid,id from ld_users where id=?';
			$readerresult=$adb->pquery($sql,array($reader));
			if($adb->num_rows($readerresult)>0)
			{
				$readername=$adb->query_result($readerresult,0,'last_name');
				$reader_wx_userid=$adb->query_result($readerresult,0,'wx_userid');
				$tmpuser->id=$adb->query_result($readerresult,0,'id');
				$tmpuser->wx_userid=$reader_wx_userid;
				$tmpuser->last_name=$readername;
			}
		}
        //zkt 0047605: （https://81mis.com/kfbcrm [^]）开发部测试演示账套-OA办公-工作汇报-用户系统头像更新后，工作汇报界面的左上方的大头像不会自动更新
		if(empty($userimgpath) || !@getimagesize($userimgpath.$userimgname) || !file_exists($userimgpath.$userimgname)){
            // ljj 20231201 XUQIU1000927 更换默认头像
            $image_str=getDefaultAvatar($userid);
            if (!empty($userimgname) && file_exists($userimgpath.iconv('utf-8','gb2312',$userimgname)) && @getimagesize($userimgpath.iconv('utf-8','gb2312',$userimgname))){
                $image_str = $userimgpath.iconv('utf-8','gb2312',$userimgname);
            }
        }
		else{
			$image_str = $userimgpath.$userimgname;
		}
		if($storage_location == 'cos'){
			$image_str = $cloud_path;
		}
	}
	else{
		$image_str = 'themes/images/defaultuser.png';
	}
	$userInfo['image']=  $image_str;
	$userInfo['name']=getUserlastName($userobj);
	$userInfo['id']=$userid;
	$userInfo['readerid']=$reader;
    //@edit:ljj,2023-08-03,reason: XUQIU1001648 工作汇报点评人被删除后，点评人应该被替换显示为删除成员时的指定成员
    if(!empty(getUserlastName($tmpuser))){
        $userInfo['readername']=getUserlastName($tmpuser);
    }
	$smarty->assign('USERINFO',$userInfo);
	$smarty->assign('CURRENT_USERID',$userid);
    
    $Sql = "select organizationname from ld_organizationdetails";
    $organiresult = $adb->pquery($Sql,array());
	include globalStatic::$root_directory.'modules/Home/ExpressionList.php';//获取表情列表
    $smarty->assign('FILESNAMELIST',$filesnamelist);
	/**
	 * 获取设置的字段
	 * @project 工作协同模板
	 * @author Tujt 2015-05-06
	 */
	require globalStatic::$root_directory.'modules/Home/WorkReportController.php';
	$work_focus = new WorkReportController();
	$entitytype = 'workreport';
	$workfieldarray = $work_focus->getWorkFieldInfo($entitytype);
	$smarty->assign('WORKFIELDARRAY',$workfieldarray);

    $smarty->assign('organizationname',$adb->query_result($organiresult,0,0));
}else{
	$smarty->assign('HOMECONTROL',0);
}


//获取已显示的简报组件的相关信息
$sql= "select name,sequence,presence,label_zh,label_en,count_module,count_type,count_columnname from ld_workreport_briefreport_detail  where `delete`=0 and presence = 'yes' order by sequence asc;";
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);

if($num_rows>0) {
    $component_arr=array();
    for($i = 0; $i < $num_rows; $i++){
        $count_module = $adb->query_result($result,$i,'count_module');
        if (!vtlib_isModuleActive($count_module) || isPermitted($count_module,'index') == 'no'){
            continue;
        }
        $name = $adb->query_result($result,$i,'name');
        $label_str = $languageType == 'zh'?'label_zh':'label_en';
        $label = $adb->query_result($result,$i,$label_str);
        $sequence = $adb->query_result($result,$i,'sequence');
        $array_bfcomponent=array();
        $array_bfcomponent['sequence']=$sequence;
        $array_bfcomponent['component_strtolower']=strtolower($name);
        $array_bfcomponent['component_name']=$name;
        //各个模块对应的组件名
        $array_bfcomponent['componentlabel']=$label;
        //收款金额、签到报表的计量单位不一样；
        $component_arr[$name]=$array_bfcomponent;
    }
}

$smarty->assign("BFCOMPONENT",$component_arr);
$smarty->assign('MASSDELETE',$_REQUEST['massdelete']);
$smarty->assign("ISADMIN",$current_user->is_admin);
$smarty->assign("SEARCHSCOPE",$_REQUEST['searchscope']);
$languageType=getLanguageType($current_user);
$smarty->assign('current_language',$languageType);

//duan 20221216 获取当前用户的头像
$userimageinfo = getUser_imageInfo($current_user->id);
$imageinfo = $userimageinfo['imagename'][0];
if(empty($imageinfo)){
    // ljj 20231201 XUQIU1000927 更换默认头像
    $userimage=getDefaultAvatar($current_user->id);
}else{
    if($imageinfo['storage_location'] == 'cos'){
        $userimage = $imageinfo['cloud_path'];
    }else{
        // ljj 20240411 BUG20240409-61 pc端-OA表单-工作汇报-现状：回复已提交的日报，用户头像不显示
        if ($imageinfo['isEncrypt'] == 'yes'){
            $cls_MyCRMcrypt = new cls_MyCRMcrypt();
            $imageinfo['file_path'] = $cls_MyCRMcrypt->decode($imageinfo['file_path']);
            $imageinfo['newfile_name'] = $cls_MyCRMcrypt->decode($imageinfo['newfile_name']);
        }
        $userimage = $imageinfo['file_path'].$imageinfo['newfile_name'];
    }
}
$smarty->assign('userimage',$userimage);

$smarty->assign('download_permit',isPermitted($currentModule,'DownLoad',''));
$smarty->assign('preview_permit',isPermitted($currentModule,'Preview',''));

$smarty->display("Home/Coordination.tpl");
?>