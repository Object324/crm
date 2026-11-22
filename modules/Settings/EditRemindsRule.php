<?php
include(globalStatic::$root_directory.'modules/Settings/CommonAutoReminds.php');

if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
{
    $blockid=$_REQUEST['blockid'];
}   
if(isset($_REQUEST['record']) && $_REQUEST['record'])
{
    $record=$_REQUEST['record'];
}    
    
if(isset($_REQUEST['mode']))
{
    $mode=$_REQUEST['mode'];
}
$smarty=new lingdangCRM_Smarty;

if($mode == 'edit' && $record!= '')
{
    //提醒方式内容
    $remindmethod_array=getRemindmethod_select_array();
    $smarty->assign('REMINDEMETHOD_ARRAY',json_encode($remindmethod_array));
    $reminder_user_array=getReminder_User_select_array(getTabname($blockid));
    $smarty->assign('REMINDER_USER_ARRAY',$reminder_user_array);
    $smarty->assign('REMINDER_USER_ARRAY_JSON',json_encode($reminder_user_array));
    $remindday3=getFixedLabel("AHEAD")."&nbsp;<input type='text' class='ld-input-inner width50' name='advanceannulremind' value=''>&nbsp;".getFixedLabel("Days");
    $sql="SELECT *  from ld_automaticreminds where id=? and tabid=?";
    $params=array($record,$blockid);
    $result=$adb->pquery($sql,$params);
    $num_rows=$adb->num_rows($result);
    if($num_rows>0)
    {
        $annualremind=$adb->query_result($result,0,'annualremind');//每年提醒
        $remindRuleName=$adb->query_result($result,0,'name');
        $columnname=$adb->query_result($result,0,'columnname'); 
        $startdate=$adb->query_result($result,0,'startdate');
        $remindnum=$adb->query_result($result,0,'remindnum');
        $remindway=$adb->query_result($result,0,'remindway');//提醒重复方式
       
        $remindday=$adb->query_result($result,0,'remindday');
        $reminder=$adb->query_result($result,0,'reminder');//提醒人
        $remindervalue=$adb->query_result($result,0,'remindervalue');//提醒人对应设置值（不包括指定成员）
        
        $remindcontent=$adb->query_result($result,0,'remindcontent');
        $remindmethod=$adb->query_result($result,0,'remindmethod');//提醒方式
        //提醒方式为“对话框/移动端”或“短信”时，清除HTML标签（历史数据）
        if($remindmethod == '0' || $remindmethod == '2')
        {
            //$remindcontent = html_entity_decode($remindcontent);
            //$remindcontent = str_replace("<br/>","\r\n",$remindcontent);
            $remindcontent = strip_tags($remindcontent);
        }
        
        $specifyuserids=$adb->query_result($result,0,'specifyuserids');//指定用户ID
        $smarty->assign('SPECIFYUSERIDS',$specifyuserids);
  
        
        if($reminder=='specifyuser'&&!empty($specifyuserids))
        {
            $sql='select last_name,wx_userid  from ld_users where  find_in_set(id,\''.$specifyuserids.'\' )';
            $tmp_result=$adb->pquery($sql,array());
			$n_rows = $adb->num_rows($tmp_result);
			$usernames = array();
			if($n_rows>= 1){
				$userobj=new Users();
				for($k = 0; $k < $n_rows; $k++){
					$last_name = $adb->query_result($tmp_result,$k,'last_name');
					$wx_userid = $adb->query_result($tmp_result,$k,'wx_userid');
					$userobj->wx_userid=$wx_userid;
					$userobj->last_name=$last_name;
					$usernames[] =getUserlastName($userobj);
					
				}
			}
            $SPECIFYUSERNAMES = implode(',',$usernames);
            $smarty->assign('SPECIFYUSERNAMES',$adb->query_result($tmp_result,0,0));
        }
        else if($reminder == 3){//指定角色
            $profile = new Profile();
            $profileids=explode(',',trim($remindervalue));
             foreach($profileids as $profileid)
             {
                 $profileinfo = $profile->getProfileinfo($profileid);
                 $profilename.=$profileinfo['profilename'].',';
             }
            $profilename = trim($profilename,',');
            $smarty->assign('role_id',$remindervalue);
            $smarty->assign('role_name',$profilename);
        }
        else if($reminder == 6){//指定部门成员的职位级别
            require_once( 'modules/Users/Group.class.php');
    		$group_focus = new Group();
            $remindervaluearray = explode('::', $remindervalue);
            $groupList = $group_focus->getGroupInfoByid($remindervaluearray[0]);
            $remindervalue = getFixedLabel('Sector').':'.$groupList['groupname'];
            $remindervalue .= '<br>'.getFixedLabel('POSITIONLEVEL').':'.$remindervaluearray[1];
            
        }
        
        if($remindway == 2)
        {
            $sqls="SELECT * from ld_remindway where wayid=?";
            $results=$adb->pquery($sqls,array($record));
            $num_row=$adb->num_rows($results);
            $remindday1="";
            if($num_row == $remindnum){
                for($i=1;$i<=$remindnum;$i++)
                {   
                    $remindsday=$adb->query_result($results,$i-1,'remindsday');
                    $remindday1.= '第'.$i.'次&nbsp;<input type="text" value="'.$remindsday.'" size="12" id="remindnums2'.$i.'" name="remindnums2'.$i.'" class="detailedViewTextBox width50">&nbsp;天后&nbsp;&nbsp;&nbsp;';
                    if($i%4 == 0)
                    {
                        $remindday1.="<br>";
                    }
                }
            }
        }
        else if($remindway=='3')
        {
            //每年提醒
             $remindday3=getFixedLabel("AHEAD")."<input type='text' name='advanceannulremind' class='ld-input-inner width50' value='$remindday'>".getFixedLabel("Days");
        }
        else{
            $remindday1='';
        }
 
        
        $smarty->assign("annualremind",$annualremind);
        $smarty->assign("remindRuleName",$remindRuleName);
        $smarty->assign("columnname",$columnname);
        $smarty->assign("startdate",$startdate);
        $smarty->assign("remindnum",$remindnum);   
        $smarty->assign("remindway",$remindway);
        $smarty->assign("remindday",$remindday);
        $smarty->assign("remindday1",$remindday1);
        $smarty->assign("remindday3",$remindday3);
        $smarty->assign("reminder",$reminder);
        $smarty->assign("remindcontent",$remindcontent);
        $smarty->assign('remindmethod',$remindmethod);
        $smarty->assign('REMINDERVALUE',$remindervalue);
        $smarty->assign('REMINDERVALUEARRAY',$remindervaluearray);
    }
    
}

crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
//职位级别
$userlevelarr = getPicklistValesForNORole('userlevel',$adb,array(),"");
$smarty->assign('USERLEVELARR',$userlevelarr);
//部门
require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
$group_focus = new Group();
$groupInfo = $group_focus->getGrouplist();
$group_arr=array();
foreach($groupInfo as $tmpgroupinfo)
{
    $tmpgroupid=$tmpgroupinfo['groupid'];
    $depth=$tmpgroupinfo['depth'];
    $tmpgroupname=$tmpgroupinfo['groupname'];
    if($depth>0)
    {
        for($i=0;$i<$depth;$i++)
        {
            $tmpgroupname="&nbsp;".$tmpgroupname;
        }
    }
    
    $group_arr[$tmpgroupname]=$tmpgroupid;
}
$smarty->assign('GROUPINFO',$group_arr);
$arr['groupinfo']=$group_arr;

//时间字段*/
$smarty->assign("DATAFIELDS",$fields);

$smarty->assign("TABID",$blockid);
$smarty->assign("mokuai_name",getTranstab(getTabname($blockid)));
$smarty->assign("RelatedModuleName",getTabname($blockid));//相关模块名称


//aliyun短信模板
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$smarty->assign("PlatForm",$platform);
$smsrelated_arr = [];
if ($platform == 'aliyun') {
    $smstemplatelist = $cls_Send_MassSms->getSmsTemplatePresenceInform($platform);
    $smarty->assign("SmsTemplateList",$smstemplatelist);//启用的短信模板列表
    $smarty->assign("PRINTTABS",getPresenceModuleList());
    //获取设置的短信类型的参数信息
    $smsrelated_arr = $cls_Send_MassSms->getSmsRelated('ld_automaticreminds',$record);
//    $smarty->assign("SmsRelatedArr",$smsrelated_arr);
}

/*基本查询开始
$sql="SELECT * from ld_remindcvstdfilter where cvid=? ";
$result=$adb->pquery($sql,array($record));
$general=array();
if($adb->num_rows($result)>0){
    $general['columnname']=$adb->query_result($result,0,'columnname');
    $general['stdfilter']=$adb->query_result($result,0,'stdfilter');
    $general['startdate']=$adb->query_result($result,0,'startdate');
    $general['enddate']=$adb->query_result($result,0,'enddate');
}*/

$smarty->assign('general',$general);
//print_r($general);
$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);
$smarty->assign('MODE',$mode);
$smarty->assign('RECORD',$record);
//数据分类开始
$oCustomView = new CustomView();
$modulecollist = $oCustomView->getModuleColumnsList(getTabname($blockid));
$stdfiltercolhtml = getStdFilterHTML(getTabname($blockid)); //选择字段
$stdfilterhtml = $oCustomView->getStdFilterCriteria();//选择时间段
$stdfilterjs = $oCustomView->getCriteriaJS();//获取时间段js

$advfilterlist = getAdvFilterByCvidRemind($record);


Crm_load_class_file('CommonView',"modules/CustomView");
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$advfilterhtml = CommonView::getAdvCriteriaHTML($fLabels);

$modulecolumnshtml = getByModule_ColumnsHTML(getTabname($blockid),$modulecollist);//高级查询select option

$smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
$smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
$smarty->assign("DATEFORMAT",$current_user->date_format);
$smarty->assign("IMAGE_PATH", $image_path);//图片路径
$smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);//时间段js
$smarty->assign("JS_DATEFORMAT",parse_calendardate('YYYY-mm-ddd'));//自定义时间段

$smarty->assign("FOPTION",$advfilterhtml);//高级查询select option 2
$smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);//高级查询select option 1


$smarty->assign("CRITERIA_GROUPS",$advfilterlist);	
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//zxm 2021-0909 阳光创信 语音提醒
$version = getVersionTradeInfo();
$smarty->assign("versionAccount",$version['account']);
//语音提醒模板
$SMSVoicearray = tencentcloud_sms_voice();
$SMSVoicearray = Zend_Json::decode($SMSVoicearray['para_content']);
$smarty->assign("SMSVoicearray",$SMSVoicearray);

/**********/
$oCustomView = new CustomView($cv_module);
$now_action = vtlib_purify($_REQUEST['action']);
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
$arr['foption']=$advfilterhtml;
$arr['columns_block']=$modulecolumnshtml;
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance(getTabname($blockid));
$arr['advanceFields'] = $controller->getAdvanceFields();
 $_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('EDIT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['flabels']=$fLabels;    
$arr['approvereminds']=$global_approvereminds;
$arr['remindusertext']=$approveremindlabels['reminduserlabel'];
$arr['tipsetreminder']=getFixedLabel('PLEASESETREMINDER');
$arr['modulelabel']=getTranstab($tabname);
$arr['specifyuserids'] = $specifyuserids;
$arr['specifyusernames'] = $SPECIFYUSERNAMES;
$arr['remindertype'] = $remindmethod;
$arr['reminder_user_array'] = json_encode($reminder_user_array);
$arr['remindmethod_array'] = json_encode($remindmethod_array);
$arr['platform'] = $platform;
$arr['smsrelated_arr']=$smsrelated_arr;
$str=$smarty->fetch("AutomaticReminds/EditMultiRemindsRule.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();


function getStdFilterHTML($module,$selected="")
{
	global $app_list_strings, $current_language,$app_strings,$current_user;

	global $oCustomView;
	$stdfilter = array();
	$result = $oCustomView->getStdCriteriaByModule($module);
   


	if(isset($result))
	{
		foreach($result as $key=>$value)
		{
			if($value == 'Start Date & Time')
			{
				$value = 'Start Date';
			}
		//	$use_module_label =  getTranslatedString($module, $module);
            $use_module_label=getTranstab($module);
		
		
				if($key == $selected)
				{
					$filter['value'] = $key;
					
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] = 'selected';
				}else
				{
					$filter['value'] = $key;
					$filter['text'] = $use_module_label." - ".$value;
					$filter['selected'] ='';
				}
			
			$stdfilter[]=$filter;
			//added to fix ticket #5117. If a user doesn't have permission for a field and it has been used to fileter a custom view, it should be get displayed to him as Not Accessible.
			if(!$is_admin && $selected != '' && $filter['selected'] == '')
			{
				$keys = explode(":",$selected);
				if(getFieldVisibilityPermission($module,$current_user->id,$keys[2]) != '0')
				{
					$filter['value'] = "not_accessible";
					$filter['text'] = getFixedLabel('NOTACCESS');
					$filter['selected'] = "selected";
					$stdfilter[]=$filter;
				}
			}

		}

	}
	//系统设置->自动提醒设置，“提醒时间参考字段”增加单据分录中的“日期”和“日期时间”字段
	if(((get_file_address($module,'ProductDetails'))&&$module!='ServiceCharge') || get_file_address($module,$module.'DetailFieldsHtml')){
		if(get_file_address($module,$module.'DetailFieldsHtml')){
			crm_load_class_file('TabDetailFields','include/TabDetailFields');
			$TabDetailFields = new TabDetailFields(getTabid($module));
			$productFields=$TabDetailFields->getTabDetailFields();
		}else{
			crm_load_class_file('ProductDetails','include/ProductDetails');
			$productDetails=ProductDetails::getInstance($module);
			$productFields = $productDetails->getModuleFields();
		}
		foreach($productFields as $fieldname => $field){
			$bigtype = $field->getBigType();
			$fielddatetype = $field->getFieldDataType();
			if(in_array($bigtype,array('date','datetime')) || in_array($fielddatetype,array('date','datetime'))){
				$tablename = $field->getTableName();
				$col_info = $tablename.':'.$fieldname.':'.$fieldname.':products_fieldlabel';
				$filter['value'] = $col_info;
				$filter['text'] = $use_module_label .getFixedLabel('DETAIL')." - ".$field->fieldLableKey;
				$filter['selected'] = '';
				if($col_info == $selected){
					$filter['selected'] = 'selected';
				}
				$stdfilter[] = $filter;
			}
		}
	}
	return $stdfilter;
}
function getByModule_ColumnsHTML($module,$columnslist,$selected="") {
    global $mod_strings;
	$columnsList = getByModule_ColumnsList($module,$columnslist,$selected);
  
    /**
    * edit:chj
    * date:2014-1-12
    * reason: 模块，产品明细 查询条件显示产品明细内容
    **/
    if(get_file_address($module,'ProductDetails'))
    {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        $columnsList[getTranstab('Products').getFixedLabel('INFORMATION')] = CustomView_Special::getProductSearchCustom($module,getCvadfilter($_REQUEST['record']));   
    }
    else if($module=='Accounts')
    {
        //35893:设置-系统设置-参数设置-自动提醒设置,选择模块“客户”新建，数据范围，高级查询，筛选字段里面没有联系人模块的字段，可以参考客户模块高级查找是有的
        $columnsList[getTranstab('Contacts')] = CustomView_Special::getAccountContact('Contacts',getCvadfilter($_REQUEST['record'])); 
    }
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
    $sql = "select columnname from ld_remindcvadvfilter where cvid = ?";
    $result = $adb->pquery($sql,array($cvid));
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

/** to get the Advanced filter for the given customview Id
 * @param $cvid :: Type Integer
 * @returns  $advfilterlist Array
 */
function getAdvFilterByCvidRemind($cvid) {

	global $adb,  $default_charset;

	$advft_criteria = array();

	$sql = 'SELECT * FROM ld_remindcvadvfilter_grouping WHERE cvid = ? ORDER BY groupid';
	$groupsresult = $adb->pquery($sql, array($cvid));
    $i = 1;
	$j = 0;
	while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
		$groupId = $relcriteriagroup["groupid"];
		$groupCondition = $relcriteriagroup["group_condition"];

		$ssql = 'select ld_remindcvadvfilter.* from ld_remindcvadvfilter
					left join ld_remindcvadvfilter_grouping on ld_remindcvadvfilter.cvid = ld_remindcvadvfilter_grouping.cvid
							';
		$ssql.= " where ld_remindcvadvfilter.cvid = ? AND ld_remindcvadvfilter.groupid = ? order by ld_remindcvadvfilter.columnindex";

		$result = $adb->pquery($ssql, array($cvid, $groupId));
        
        
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0)
			continue;

		while ($relcriteriarow = $adb->fetch_array($result)) {
			$columnIndex = $relcriteriarow["columnindex"];
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $relcriteriarow["comparator"];
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


?>