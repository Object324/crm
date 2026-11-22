<?php

if($_REQUEST['type'] == 'saveprintModulesSort') {
    $type = $_REQUEST['type'];
    global $adb;
//保存审批流程排序 weiyannan 20231121 XUQIU1002038 后台设置列表界面可以做排序
    if ($type == 'saveprintModulesSort') {
        if (!empty($_REQUEST['tagids'])) {
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_templateprint set sequence = ? where templateprintid = ?', array($sequence, $id));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
}

/**
 * 打印模板分配功能
 * @project PROT195 审批管理改进
 * @author Tujt 2015-04-16
 */
 global $current_user;
 $_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='TemlateprintList';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
if(isset($_REQUEST['mode']) && 'tpltouser' == $_REQUEST['mode']){
    global $adb;
    $tplprintid = $_REQUEST['tplprintid'];
    /**
     * 审批流程分配用户
     */
    if(isset($_REQUEST['allocate']) && $_REQUEST['allocate'] == 1){
        $userid = $_REQUEST['userid'];
        $userarr = explode(',', $userid);
        $query = 'delete from ld_templateprint2user where templateprintid = '.$tplprintid.' ';
        $adb->pquery($query,array());
        if(!empty($userarr)){
            foreach ($userarr as $user) {
                $query = 'insert into ld_templateprint2user(templateprintid,userid) values('.$tplprintid.','.$user.') ';
                $adb->pquery($query,array());
            }
        }
    }else{//通过传递的审批流程ID，获取对应的用户信息
        $query = 'select GROUP_CONCAT(userid) AS userid from ld_templateprint2user 
                    where templateprintid = '.$tplprintid.' ';
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
require('user_privileges/user_language_'.$current_user->id.'.php');
//获取所有的打印模块
$sql='select  name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=? and  printtab=1 and presence in(0,2) order by tabsequence ';
$result=$adb->pquery($sql,array($languageType,'ld_tab'));
$printtabs=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $tablabel=$adb->query_result($result,$i,'tablabel');
    $name=$adb->query_result($result,$i,'name');
    if($name=='ChannelCode') continue;
    if($name=='CustomEcharts') continue;
    if($name=='SocialPromotion') continue;
    $printtabid=$adb->query_result($result,$i,'tabid');
    if($printtabid==9)
    {
        $printtabid=16;
    }
    $printtabs[$printtabid]=$adb->query_result($result,$i,'fieldlabel');
}
require_once('Smarty_setup.php');
global $adb,$app_strings,$mod_strings,$current_user;
if($_REQUEST['printtab']){
    $tabid=$_REQUEST['printtab'];
    if($tabid==9){
        $tabid=16;
    }
}
else{
    if(vtlib_isModuleActive('SalesOrder')){
        $tabid=22;//默认合同订单
    }else{
        $tabid=key($printtabs);
    }
}


$smarty=new lingdangCRM_Smarty;
$smarty->assign("PRINTTABID",$tabid);
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
//$list_header = array($mod_strings['LBL_LIST_TOOLS'],$mod_strings['LBL_TEMPLATEPRINT_NAME'],$mod_strings['LBL_ISDEFAULT'],$mod_strings['LBL_DESCRIPTION']);
$list_header = array(
    getFixedLabel('TEMPLATENAME'),getFixedLabel('APPLICABLESCOPE'),getFixedLabel('SourceFileFormat'),
    getFixedLabel('WHETHERDEFAULT'),getFixedLabel('ApprovedAllowPrint'),
    getFixedLabel('LatestModifiedby'),getFixedLabel('TIMEOFLASTMOD'),
);
$list_header_style = array(
    'width="200px" align="left"','align="left"','width="10%"',
    'width="10%"','width="15%"',
    'width="8%"','width="12%"',
);
$smarty->assign("LIST_HEADER",$list_header);
$smarty->assign("LIST_HEADER_STYLE",$list_header_style);
//获取列表显示界面数据。
/**
 *parameter:allocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配. 
 **/
$query='
        SELECT distinct allocateids,templateprintid,allocatepname,templateprintname,allocatetype,isdefault,approvedallowprint,
            printfilename,modifiedby,modifiedtime
        FROM
        (
          select 
            -1 AS allocateids,ld_templateprint.templateprintid,
            "AllUser" AS allocatepname,
            ld_templateprint.tabid,ld_templateprint.templateprintname ,
            ld_templateprint.allocatetype ,ld_templateprint.isdefault,ld_templateprint.approvedallowprint,ld_templateprint.sequence,
            ld_templateprint.printfilename,ld_templateprint.modifiedby,ld_templateprint.modifiedtime
       	  from ld_templateprint where allocatetype=0
      	  UNION
          select  
              GROUP_CONCAT(ld_users.id) as allocateids,			
              ld_templateprint2user.templateprintid,
              GROUP_CONCAT(ld_users.last_name  SEPARATOR "、") as allocatepname,
              ld_templateprint.tabid,
              ld_templateprint.templateprintname ,ld_templateprint.allocatetype,
              ld_templateprint.isdefault,ld_templateprint.approvedallowprint,ld_templateprint.sequence,
              ld_templateprint.printfilename,ld_templateprint.modifiedby,ld_templateprint.modifiedtime
       		  from ld_templateprint2user 
       		  inner JOIN ld_users on ld_users.id=ld_templateprint2user.userid 
              inner JOIN ld_templateprint 
       		  on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
           where allocatetype=2 GROUP BY  ld_templateprint2user.templateprintid
       	   UNION
           select  
                GROUP_CONCAT(ld_groups.groupid) as allocateids,						
                ld_templateprint2user.templateprintid,
                GROUP_CONCAT(ld_groups.groupname  SEPARATOR "、") as allocatepname,
                ld_templateprint.tabid,
                ld_templateprint.templateprintname,ld_templateprint.allocatetype ,
                ld_templateprint.isdefault,ld_templateprint.approvedallowprint ,ld_templateprint.sequence,
                ld_templateprint.printfilename,ld_templateprint.modifiedby,ld_templateprint.modifiedtime
        		from ld_templateprint2user 
        		inner JOIN ld_groups on ld_groups.groupid=ld_templateprint2user.userid inner JOIN ld_templateprint 
        		on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
                where allocatetype=1 GROUP BY  ld_templateprint2user.templateprintid
			UNION
			select  
				GROUP_CONCAT(ld_profile.profileid) as allocateids,						
				ld_templateprint2user.templateprintid,
				GROUP_CONCAT(ld_profile.profilename  SEPARATOR "、") as allocatepname,
				ld_templateprint.tabid,
				ld_templateprint.templateprintname,ld_templateprint.allocatetype ,
				ld_templateprint.isdefault,ld_templateprint.approvedallowprint ,ld_templateprint.sequence,
                ld_templateprint.printfilename,ld_templateprint.modifiedby,ld_templateprint.modifiedtime
				from ld_templateprint2user 
				inner JOIN ld_profile on ld_profile.profileid=ld_templateprint2user.userid inner JOIN ld_templateprint 
				on ld_templateprint.templateprintid=ld_templateprint2user.templateprintid  
				where allocatetype=3 GROUP BY  ld_templateprint2user.templateprintid
        ) AS alldata
        WHERE alldata.tabid=?  order by sequence,templateprintid desc ';
$result=$adb->pquery($query,array($tabid));
$num_rows = $adb->num_rows($result);
$templateList = [];
for($i = 0; $i<$num_rows; $i++){
    $lastname = $adb->query_result($result,$i,'allocatepname'); 
    if($lastname=='AllUser')//所有用户。
    {
      $lastname = getFixedLabel('ALLTHEUSERS');  
    }
	$allocatetype = $adb->query_result($result,$i,'allocatetype');
	$allocateids = $adb->query_result($result,$i,'allocateids');
	if($allocatetype == 2){
		$lastname = getUserName($allocateids);
	}
	if($allocatetype == 1){
		$lastname = getGroupNamePrint($allocateids);
	}
    $templateList[$i]['printid'] = $adb->query_result($result,$i,'templateprintid');
    $templateList[$i]['printname'] = $adb->query_result($result,$i,'templateprintname');
    $templateList[$i]['lastname'] = $lastname;
    $templateList[$i]['isdefault'] = $adb->query_result($result,$i,'isdefault');
    $templateList[$i]['approvedallowprint'] = $adb->query_result($result,$i,'approvedallowprint');
    $templateList[$i]['allocateids'] = $adb->query_result($result,$i,'allocateids');
    $templateList[$i]['allocatetype'] = $adb->query_result($result,$i,'allocatetype');

    // 源文件格式
    $printfilename = $adb->query_result($result,$i,'printfilename');
    $extension = pathinfo($printfilename, PATHINFO_EXTENSION);// 文件后缀
    if($extension == 'doc' || $extension == 'docx'){
        $templatetype = 'Word';
    }else if($extension == 'xls' || $extension == 'xlsx'){
        $templatetype = 'Excel';
    }else{
        $templatetype = 'HTML';
    }
    $templateList[$i]['templatetype'] = $templatetype;
    $templateList[$i]['modifiedby'] = getUserFullName($adb->query_result($result,$i,'modifiedby'));
    $templateList[$i]['modifiedtime'] = $adb->query_result($result,$i,'modifiedtime');
}
$smarty->assign("LIST_ENTRIES",$templateList);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign('PRINTCNT', count($templateList));
$smarty->assign("PRINTTABID",$tabid);
$smarty->assign("LANGUAGETYPE",$languageType);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);


//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//打印模板帮助
$labels = array('TemplatePrintList');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if(isset($_REQUEST['directmode']) && $_REQUEST['directmode']=='ajax')
{
    //选择模块：仅更新下方表格，显示对应表格内容
    $arr['content']= $smarty->fetch('TemplatePrintLists.tpl');
    ConvertTojsonString(1,$arr,"success");
}
else
{
    $arr['content']= $smarty->fetch('TemplatePrintList.tpl');
    ConvertTojsonString(1,$arr,"success");
}

function getUserName($ids){
	global $adb;
	$query = 'select last_name,wx_userid from ld_users where id in ('.$ids.')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		$userobj=new Users();
		$data = array();
		for($i = 0; $i < $num_rows; $i++){
			$last_name = $adb->query_result($result,$i,'last_name');
			$wx_userid = $adb->query_result($result,$i,'wx_userid');
			$userobj->wx_userid=$wx_userid;
			$userobj->last_name=$last_name;
			$data[] = getUserlastName($userobj);
		}
		return implode('、',$data);
	}
	return '';
}

function getGroupNamePrint($ids){
	global $adb;
	$query = 'select groupid,groupname from ld_groups where groupid in ('.$ids.')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		require_once( 'modules/Users/Group.class.php');
		$groupobj=new Group();
		$data = array();
		for($i = 0; $i < $num_rows; $i++){
			$groupid = $adb->query_result($result,$i,'groupid');
			$groupname = $adb->query_result($result,$i,'groupname');
			$groupobj->groupid=$groupid;
			$groupobj->groupname=$groupname;
			$data[] = getWx_GroupName($groupobj);
		}
		return implode('、',$data);
	}
	return '';
}
?>