<?php
/**
 * edit:kevin
 * date:2013-07-15
 * reason:公海客户设置
 */ 
global $theme,$theme,$current_user;
 global $current_user;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='AccountSet';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$smarty=new lingdangCRM_Smarty;
require_once('include/utils/UserInfoUtil.php');
require('user_privileges/user_privileges_'.$current_user->id.'.php');
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//$l=0;
//$userDetails=getAllUserName();
//$useridarr = array_keys($userDetails);
//$usersql = join(',',$useridarr);
/**
 *@edit:andy 
 *@date:
 *@reason:左右结构改进，sql改进
 *@version:
 */
//OLD:$query = 'SELECT id,last_name FROM ld_users WHERE "on" != is_admin AND 0 = deleted ORDER BY id;';
//公海管理员开始sqsl：
$query = 'SELECT id,last_name FROM ld_users WHERE "on" != is_admin AND 0 = deleted and `status` = \'Active\' 
            and id not in (select id from ld_users where
             FIND_IN_SET(id,(SELECT adminaccount from ld_account_set))) ORDER BY CONVERT (last_name USING gbk) COLLATE gbk_chinese_ci ASC';
$result = $adb->query($query);
$rows = $adb->num_rows($result);
if($rows > 0){
	for($i=0;$i<$rows;++ $i){
		$userid = $adb->query_result($result,$i,'id');
		$username = $adb->query_result($result,$i,'last_name');
		$userIdStr .= '"'.$userid.'",';
		$userNameStr .= '"'.$username.'",';
	}
}
$userIdStr = trim($userIdStr,',');
$userNameStr = trim($userNameStr,',');
$smarty->assign("USERIDSTR",$userIdStr);
$smarty->assign("USERNAMESTR",$userNameStr);

$days=10;
$count=20;
$bills='SalesOrder';
$iset=1;
$query='select * from ld_account_set';
$dataProfile=1;
$getProfile=1;
$wheathershow=1;
$userid='';
$user_name='';
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    $iset=$adb->query_result($result,0,'status');

    $count=$adb->query_result($result,0,'count');
	$days=$adb->query_result($result,0,'days');
    $adminaccount=$adb->query_result($result,0,'adminaccount');
    $usersaccount=$adb->query_result($result,0,'usersaccount'); 
	$usersaccount_type=$adb->query_result($result,0,'usersaccount_type');
	if($usersaccount_type == '')$usersaccount_type = 'all';
    $dataProfile=$adb->query_result($result,0,'dataprofile');
    $getProfile=$adb->query_result($result,0,'getprofile');
    $wheathershow=$adb->query_result($result,0,'wheathershow');
    $userid=$adb->query_result($result,0,'userid'); 
	$bills = $adb->query_result($result,0,'bills'); 
    $astricttype=$adb->query_result($result,0,'astricttype'); 
	$allotuserid = $adb->query_result($result,0,'allotaccount');
    $buttontype = $adb->query_result($result,0,'buttontype'); //yyx 2015-4-21 获取公海参数值
	$publicaccount = $adb->query_result($result,0,'publicaccount');
    $containnormalaccount=$adb->query_result($result,0,'containnormalaccount');
    $normalconvertbuttonprofile=$adb->query_result($result,0,'normalconvertbuttonprofile');//增加公海已分配客户转普通权限
    
      $objtainaccountcontroldays=$adb->query_result($result,0,'objtainaccountcontroldays');
    $smarty->assign("NormalConvertButtonProfile",$normalconvertbuttonprofile);
 
    $beforereminddays=$adb->query_result($result,0,'beforereminddays');//客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒）
    $smarty->assign("beforereminddays",$beforereminddays);
    
    $smarty->assign("ADMINACCOUNT",$adminaccount);
    
    $adminarr=explode(',',$adminaccount);   
    $member=array();
    crm_load_function_file('getFirstCharter','modules/Settings','getFirstCharter');
    foreach($adminarr as $account){
        if($account !=''){
            if(getUserFullName($account)!=''){
                //$member[]=$account;            
                //$member[]=getFixedLabel("LBL_USERS")."::".getUserFullName($account);
                //$member[]=getUserFullName($account);
                $userNameFirstCharter=getFirstCharter(getUserFullName($account));
                $member[$userNameFirstCharter][$account]=getUserFullName($account);       
            }
            
        }
        
    }
    ksort($member);
    //$smarty->assign('ADMINACCOUNT',$member);
}


$sql="select ld_account_set_rule.* from ld_account_set_rule
inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (ld_tab.presence in(0,2) or tabname='Singin') ORDER BY type,sequence ";
$result=$adb->pquery($sql,array());
$nocompletechk='yes';
$completechk='no';
$normalcompletechk='no';
$arr_nocomplete_condition=array();
$arr_complete_condition=array();
$arr_normal_condition=array();
$arr_recovery_modules=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $modulename=$adb->query_result($result,$i,'tabname');
    $day=$adb->query_result($result,$i,'days');
    $type=$adb->query_result($result,$i,'type');
    $recyclelabelbols=explode("/",$adb->query_result($result,$i,'labelbol'));
    $singlelablebols=explode("/",$adb->query_result($result,$i,'singlelabelbol'));
    $status=$adb->query_result($result,$i,'status');
    $iscycle=$adb->query_result($result,$i,'iscycle');
    $condition=$adb->query_result($result,$i,'condition');
  
    
    //$sequence=$adb->query_result($result,$i,'sequence')
    
    if(empty($day))
    {
        $day="";
    }
    if(!in_array($modulename,$arr_recovery_modules))
    {
         $arr_recovery_modules[]=$modulename;
    }
    if($type=='nocomplete')
    {
        $seqno=sizeof($arr_nocomplete_condition)+1;
        
        $arr_nocomplete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
            ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
            ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]);
        $nocompletecondition=$condition;
        
    }
    else if($type=='complete')
    {
       
        $seqno=sizeof($arr_complete_condition)+1;
        $arr_complete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
            ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
            ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]
            ,'iscycle'=>$iscycle);
        $completecondition=$condition;
        if($status=='active')
        {
            $completechk='yes';
        }
    }
    else if($type=='singlenormal')
    {
        $arr_recovery_modules[]=$modulename;
        $seqno=sizeof($arr_single_normal_condition)+1;
        $arr_single_normal_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
            ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
            ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]);
        $singlenormalcondition=$condition;
        if($status=='active')
        {
            $singlenormalchk='yes';
        }
    }
    else if($type=='normal')
    {
        $seqno=sizeof($arr_normal_condition)+1;
        $arr_normal_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
                    ,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
                    ,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]
                    ,'iscycle'=>$iscycle);
        $normalcondition=$condition;
        if($status=='active')
        {
            $normalchk='yes';
        }
    }
        
} 
$smarty->assign("ARRRECOVERYMODULES",json_encode($arr_recovery_modules));//参与回收的模块
$smarty->assign("NOCOMPLETECONDITION",$nocompletecondition);
$smarty->assign("COMPLETECONDITION",$completecondition);
$smarty->assign("NORMALCONDITION",$normalcondition);
$smarty->assign("COMPLETECHK",$completechk);
$smarty->assign("NORMALCHK",$normalchk);
$smarty->assign("SINGLENORMALCHECK",$singlenormalchk);
$smarty->assign("ARRNOCOMPLETECONDITION",$arr_nocomplete_condition);



$smarty->assign("ARRCOMPLETECONDITION",$arr_complete_condition);
$smarty->assign("ARRNORMALCONDITION",$arr_normal_condition);
$smarty->assign("ARRSINGLENORMALCONDITION",$arr_single_normal_condition);
$smarty->assign('publicaccount',$publicaccount);
//<!---公海未分配，公海已分配 zyh 20150518--->
$buttonarray = array(
	'1' => getFixedLabel('COMMONACCOUNT'),
	'2' =>getFixedLabel('LBL_NOALLOCATE'),
	'3' => getFixedLabel('LBL_PUBLICALLOCATE')
); //yyx 2015-4-21 创建数组，获取‘全部、仅普通、仅公海’这三种参数
$publicaccountarray = array(getFixedLabel('COMMONACCOUNT'),getFixedLabel('LBL_NOALLOCATE'),getFixedLabel('LBL_PUBLICALLOCATE'));//快速创建客户默认的客户公海状态
$smarty->assign('publicaccountarray',$publicaccountarray);
$smarty->assign('buttonarray',$buttonarray);//yyx 2015-4-21 提交公海参数值数组内容
$smarty->assign('buttontype',explode(',',$buttontype));
//	客户序时簿列表页签显示为
$listbtn_label = array(
	'1' => getFixedLabel('allexcludinghignseas'),	//全部（不含公海）
	'0' =>getFixedLabel('allubcludingallpublicaccount'),	//全部（含所有公海）
	'2' => getFixedLabel('allincludingthepublicaccount'),	//全部（含公海已分配）
	'3' => getFixedLabel('allexcludinghignseas1')	//全部（含公海未分配）
);
$smarty->assign('LISTBTNLABEL',$listbtn_label);
$profile_focus = new Profile();
$role_det = $profile_focus->getProfileArray();
$roleout ='';
$roleout .="<table class='ControlTable1 listEntries' border=0 cellspacing=1 cellpadding=5 width=100%><tr>
                    <th title='".getFixedLabel('ROLES')."'>".getFixedLabel('ROLES')."
                    </th>
                    <th width='300' title='".getFIxedlabel('Themaximumnumberofhighseascustomers')."'>".getFIxedlabel('Themaximumnumberofhighseascustomers')."
                    </th>
                    <th width='50'>".getFIxedlabel('OPERATING')."
                    </th>
               </tr>";
$roleout .= astrictindent($roleout,$role_det);
$roleout .="</table>";
//print_r($roleout);


$smarty->assign("ASTRICTTYPE", $astricttype);
$smarty->assign("ROLETREE", $roleout);
$smarty->assign('ISET',$iset);
$smarty->assign('DAYS',$days);
$smarty->assign('COUNT',$count);
$smarty->assign('BILLS',$bills);
$smarty->assign('DATA',$data);
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
$smarty->assign("DATAPROFILE",$dataProfile);
$smarty->assign("GETPROFILE",$getProfile);
$smarty->assign("wheathershow",$wheathershow);
$smarty->assign('USERSACCOUNT',$usersaccount);
$smarty->assign('USERSACCOUNT_TYPE',$usersaccount_type);
$smarty->assign("containnormalaccount",$containnormalaccount);
 getAccount_Set('aa');//重新生成缓存文件
$smarty->assign("userid",$userid);
if($userid != ''){
    $user_name=getOwnerName($userid);
    $smarty->assign("user_name",getOwnerName($userid));
}
if($allotuserid != ''){
    $smarty->assign("allotuser_name",getOwnerName($allotuserid));
	$smarty->assign("allotuser_id",$allotuserid);
}
$smarty->assign("THEME", $theme);
// require_once('SetmenuControl.php');
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('LANGUAGETYPE',$languageType);


//数据分类开始
$tabid=6;
$module='Accounts';
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList($module);
//$stdfiltercolhtml = getStdFilterHTML($module); //选择字段
$stdfilterhtml = $oCustomView->getStdFilterCriteria();//选择时间段
$stdfilterjs = $oCustomView->getCriteriaJS();//获取时间段js

$advfilterlist = getAdvFilter($record);


		
$advfilterhtml = getAdvCriteriaHTML();

$modulecolumnshtml = getByModule_ColumnsHTML($module,$modulecollist);//高级查询select option

$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
$smarty->assign("DATEFORMAT",$current_user->date_format);
$smarty->assign("IMAGE_PATH", $image_path);//图片路径
$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);//时间段js
$smarty->assign("JS_DATEFORMAT",parse_calendardate('YYYY-mm-ddd'));//自定义时间段

$smarty->assign("FOPTION",$advfilterhtml);//高级查询select option 2
$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);//高级查询select option 1


$smarty->assign("CRITERIA_GROUPS",$advfilterlist);	
Crm_load_class_file('CommonView',"modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

/**********/
$oCustomView = new CustomView($cv_module);
$now_action = vtlib_purify($_REQUEST['action']);
//客户被自动回收后     天内不允许被当前负责人再次领取（为0或空表示不控制）
$strlabel=getFixedLabel('ObjtainAccountControlDays');
$objtainaccountcontroldayshtml="<input type='text' value='$objtainaccountcontroldays' name='objtainaccountcontroldays' class='btn-radius-system input-btn-align' style='width: 50px;text-align: center;' />";
$strlabel=str_replace("__",$objtainaccountcontroldayshtml,$strlabel);

$smarty->assign('objtainaccountcontroldayshtml',$strlabel);
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('newAccountSet.tpl');
ConvertTojsonString(1,$arr,"success");
function getAdvCriteriaHTML($selected="")
{
	 global $adv_filter_options;
   
	 foreach($adv_filter_options as $key=>$value)
	 {
		if($selected == $key)
		{
			$shtml .= "<option selected value=\"".$key."\">".$value."</option>";
		}else
		{
			$shtml .= "<option value=\"".$key."\">".$value."</option>";
		}
	 }
    return $shtml;
    
}

/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilter() {

	global $adb,  $default_charset;

	$advft_criteria = array();

	$sql = 'SELECT * FROM ld_account_set_advfilter_grouping  ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array());
    $i = 1;
	$j = 0;
	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select ld_account_set_advfilter.* from ld_account_set_advfilter';
		$ssql.= " where groupid=? order by ld_account_set_advfilter.columnindex";

		$result = $adb->pquery($ssql, array($groupId));
        
        
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0)
			return ;

		while ($relcriteriarow = $adb->fetch_array($result)) {
			$columnIndex = $relcriteriarow["columnindex"];
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $relcriteriarow["comparator"];
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
			$criteria['column_condition'] = $relcriteriarow["column_condition"];

			$advft_criteria[$i]['columns'][$j] = $criteria;
			$advft_criteria[$i]['condition'] = $groupCondition;
           
			$j++;
		}
		if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
			$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
		}
		$i++;
	}
	// Clear the condition (and/or) for last group, if any.
	if (!empty($advft_criteria[$i - 1]['condition']))
		$advft_criteria[$i - 1]['condition'] = '';

  
	return $advft_criteria;
}
function getByModule_ColumnsHTML($module,$columnslist,$selected="") {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,$selected);
  
    /**
    * edit:chj
    * date:2014-1-12
    * reason: 模块，产品明细 查询条件显示产品明细内容
    **/
    
        //35893:设置-系统设置-参数设置-自动提醒设置,选择模块“客户”新建，数据范围，高级查询，筛选字段里面没有联系人模块的字段，可以参考客户模块高级查找是有的
        $columnsList[getTranstab('Contacts')] = CustomView_Special::getAccountContact('Contacts',getCvadfilter($_REQUEST['record'])); 
    
	return generateSelectColumnsHTML($columnsList,$module);
}
function getByModule_ColumnsList($module,$columnslist,$selected="") {
	global $oCustomView, $current_language,$theme;
	global $app_list_strings;
    global $adb;
	$advfilter = array();
	//$mod_strings = return_specified_module_language($current_language,$module);

    /*
    edit by LD Can
    date:2013026
    reasion:3268: 页面布局修改字段名称之后，导致已创建的视图中“选择字段”显示异常
    
    */
	$check_dup = Array();

	foreach($oCustomView->module_list[$module] as $key=>$value)
	{
		$advfilter = array();			
		$label = $key;
		if(isset($columnslist[$module][$key]))
		{
			foreach($columnslist[$module][$key] as $field=>$fieldlabel)
			{
				if(!in_array($fieldlabel,$check_dup))
				{
					if(isset($mod_strings[$fieldlabel]))
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
					//if($selected == $field)
                   if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
                   {
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "selected";
						}else
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "";
						}
					}else
					{
					   $arrselected=explode(":",$selected);
                      $arrfield=explode(":",$field);
                       
						//if($selected == $field)
                    if($arrselected[0]==$arrfield[0] && $arrfield[1]==$arrselected[1])
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "selected";
						}else
						{
							$advfilter_option['value'] = $field;
							$advfilter_option['text'] = $fieldlabel;
							$advfilter_option['selected'] = "";
						}
					}
					$advfilter[] = $advfilter_option;
					$check_dup [] = $fieldlabel;
				}
			}
			$advfilter_out[$label]= $advfilter;
		}
	}
	
	return $advfilter_out;
}
function getCvadfilter($cvid)
{
    global $adb;
    $sql = "select columnname from ld_account_set_advfilter ";
    $result = $adb->pquery($sql,array());
    for ($i=0;$i<$adb->num_rows($result);$i++) {
        $array[$i] = $adb->query_result($result, $i, "columnname");
    }
    return $array;
}
function generateSelectColumnsHTML($columnsList, $module) {
	$shtml = '';
	foreach($columnsList as $blocklabel=>$blockcolumns) {
    	$shtml .= "<optgroup label='".$blocklabel."' class='select' style='border:none'>";
    	foreach($blockcolumns as $columninfo) {
      		$shtml .= "<option ".$columninfo['selected']." value='".$columninfo['value']."'>".$columninfo['text']."</option>";
    	}
  	}
  	return $shtml;	
}

function astrictindent($roleout,$role_det)
{
	global $theme,$mod_strings,$app_strings,$adb;
	$theme_path="themes/".$theme."/";
	$image_path=$theme_path."images/";
    //获取角色限制数量
    $squlastrict = 'SELECT roleid,astrictcount FROM ld_role_astrictcount;';
    $astrict_res = $adb->pquery($squlastrict, array());
    $astrict_num_rows = $adb->num_rows($astrict_res);
    for($r=0; $r<$astrict_num_rows; $r++)
    {
    	$roleid = $adb->query_result($astrict_res,$r,'roleid');
        $astrict[$roleid] = $adb->query_result($astrict_res,$r,'astrictcount');
    }
    foreach($role_det as $roleid => $rolename)
    {

  //       $role_det_arr=$role_det[$roleid];
		// $roleid_arr=$role_det_arr[2];
		// $rolename = $role_det_arr[0];
        
		// $roledepth = $role_det_arr[1];  
        // if($roleid != 'H1')
        // {

        //  // $parent=getParentRole($roleid);
        //  //$countasrict角色限制数量
        if($astrict[$roleid]==''){ 
            $countasrict=0;
        }else{
            $countasrict=$astrict[$roleid];
        };   
        
        $croleid = "'".$roleid."'";        
        $roleoutL .="<tr bgcolor='white'><td nowrap>";
        $roleoutL .="<span title='".$rolename."'>".$rolename."</span>";//角色名字
        $roleoutL .="</td>";
        $roleoutL .="<td>";               
        $roleoutL .="<div id='seetxtbox_$roleid' style=\"display:block;\"><span title='".$countasrict."'>".$countasrict."</span></div>";
        $roleoutL .="<div id=\"editarea_$roleid\" style=\"display:none;\" class=\"modulecontrolldiv\">
                	    <input id=\"txtbox_".$roleid."\" class=\"detailedViewTextBox\" style=\"width:150px;float:left;\" type=\"text\" value=\"$countasrict\" maxlength=\"100\" name=\"modulename\" onblur=\"this.className='detailedViewTextBox'\" onfocus=\"this.className='commonDetailedTextBox gwidth70 bgcolordh'\">
                        <span>
                            <a class=\"Anu3_a\" style=\"margin-left:3px;margin-top: 3px;\" href=\"javascript:void(0);\" onclick=\"vtlib_savecount($countasrict,$croleid)\">".getFixedLabel('SAVE')."</a>
                            <a class=\"Anu3_a\" style=\"margin-top: 3px;\" href=\"javascript:void(0);\" onclick=\"vtlib_showeditinput_account(2,$croleid,$countasrict);\" >".getFixedLabel('CANCEL')."</a>
                        </span>
                    </div>";
        $roleoutL .="</td>"; 
        $roleoutL .="<td>";               
        $roleoutL .="<a  class='Anu3_a' href='javascript:void(0);' onclick=\"vtlib_showeditinput_account(1,$croleid,$countasrict);\" >".getFixedLabel('EDIT')."</a>";
        $roleoutL .="</td>"; 
        $roleoutL .="</tr>";
        
        //}
      if(sizeof($value) > 0 )
		{
			$roleoutL .= astrictindent($value,$roleout,$role_det);
		}
         
    }
         
   
    return $roleoutL;
}

/**
* 角色前空格
**/
function spaceCharacter($depth){
    if($depth>1){
        for($i=0;$i<$depth;$i++){
            $str .='&nbsp;&nbsp;&nbsp;';            
        }
    }
    return $str;
}
?>