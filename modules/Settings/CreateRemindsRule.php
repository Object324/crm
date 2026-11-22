<?php
include(globalStatic::$root_directory.'modules/Settings/CommonAutoReminds.php');

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
{
    $blockid=$_REQUEST['blockid'];
}    
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module'])
{
    $blockname=$_REQUEST['fld_module'];
}    
if(isset($_REQUEST['record']) && $_REQUEST['record'])
{
    $record=$_REQUEST['record'];
}    
    
$mode='create';
if(isset($_REQUEST['mode']))
{
    $mode=$_REQUEST['mode'];
}
$smarty=new lingdangCRM_Smarty;


//时间字段
//$smarty->assign("DATAFIELDS",$fields);
//创建人
//创建人
if(getTabname($blockid)=='Attachment')
    $smarty->assign("CREATER",gettranslabelfields(getTabname($blockid),'creator'));
else

    $smarty->assign("CREATER",gettranslabelfields(getTabname($blockid),'smcreatorid'));
//负责人
$smarty->assign("SMOWNERID",gettranslabelfields(getTabname($blockid),'smownerid'));
$smarty->assign("mokuai_name",getTranstab(getTabname($blockid)));
$smarty->assign("RelatedModuleName",getTabname($blockid));//相关模块名称

//提醒方式内容
$remindmethod_array=getRemindmethod_select_array();
$smarty->assign('REMINDEMETHOD_ARRAY',json_encode($remindmethod_array));
$reminder_user_array=getReminder_User_select_array(getTabname($blockid));

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


$smarty->assign('REMINDER_USER_ARRAY',$reminder_user_array);
$smarty->assign('REMINDER_USER_ARRAY_JSON',json_encode($reminder_user_array));
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('APP',$app_strings);
$smarty->assign('BLOCKID',$blockid);
$smarty->assign('MODE',$mode);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('RECORD',$record);

Crm_load_class_file('CommonView',"modules/CustomView");
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);

//数据分类开始
if($record == '')
{   
   $oCustomView = new CustomView();
   $modulecollist = $oCustomView->getModuleColumnsList(getTabname($blockid));
   $stdfiltercolhtml = getStdFilterHTML(getTabname($blockid)); //选择字段
   $stdfilterhtml = $oCustomView->getStdFilterCriteria();//选择时间段
   $stdfilterjs = $oCustomView->getCriteriaJS();//获取时间段js
    $advfilterhtml = CommonView::getAdvCriteriaHTML($fLabels);

   $modulecolumnshtml = getByModule_ColumnsHTML(getTabname($blockid),$modulecollist);//高级查询select option
   
   $smarty->assign("STDFILTERCOLUMNS",$stdfiltercolhtml);
   $smarty->assign("STDFILTERCRITERIA",$stdfilterhtml);
   $smarty->assign("DATEFORMAT",$current_user->date_format);
   $smarty->assign("IMAGE_PATH", $image_path);//图片路径
   $smarty->assign("STDFILTER_JAVASCRIPT",$stdfilterjs);//时间段js
   $smarty->assign("JS_DATEFORMAT",parse_calendardate('YYYY-mm-ddd'));//自定义时间段
   $smarty->assign("COLUMNS_BLOCK",$modulecolumnshtml);//高级查询select option 1
   $smarty->assign("FOPTION",$advfilterhtml);//高级查询select option 2
}
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

$remindday3=getFixedLabel("AHEAD")."&nbsp;<input type='text' class='ld-input-inner width50' name='advanceannulremind' value=''>&nbsp;".getFixedLabel("Days");
$smarty->assign("remindday3",$remindday3);
//zxm 2021-0909 阳光创信 语音提醒
$version = getVersionTradeInfo();
$smarty->assign("versionAccount",$version['account']);

//语音提醒模板
$SMSVoicearray = tencentcloud_sms_voice();
$SMSVoicearray = Zend_Json::decode($SMSVoicearray['para_content']);
$smarty->assign("SMSVoicearray",$SMSVoicearray);

//aliyun短信模板
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$smarty->assign("PlatForm",$platform);
if ($platform == 'aliyun') {
    $smstemplatelist = $cls_Send_MassSms->getSmsTemplatePresenceInform($platform);
    $smarty->assign("SmsTemplateList",$smstemplatelist);//启用的短信模板列表
    $smarty->assign("PRINTTABS",getPresenceModuleList());
    $smarty->assign("TABID",$blockid);
}

$arr['foption']=$advfilterhtml;
$arr['columns_block']=$modulecolumnshtml;
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance(getTabname($blockid));
$arr['advanceFields'] = $controller->getAdvanceFields();
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('LBL_AUTOMATICREMINDS_SET');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['flabels']=$fLabels;    
$arr['approvereminds']=$global_approvereminds;
$arr['remindusertext']=$approveremindlabels['reminduserlabel'];
$arr['tipsetreminder']=getFixedLabel('PLEASESETREMINDER');
$arr['modulelabel']=getTranstab($tabname);
$arr['reminder_user_array'] = json_encode($reminder_user_array);
$arr['remindmethod_array'] = json_encode($remindmethod_array);
$arr['platform'] = $platform;
$str=$smarty->fetch("AutomaticReminds/CreateMultiRemindsRule.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
//获取模块字段
function getStdFilterHTML($module,$selected="")
{
	global $app_list_strings, $current_language,$app_strings,$current_user;

	global $oCustomView;
	$stdfilter = array();
	$result = $oCustomView->getStdCriteriaByModule($module);
   $is_admin=is_admin($current_user);

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
					if($selected == '')
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
				$filter['text'] = $use_module_label.getFixedLabel('DETAIL')." - ".$field->fieldLableKey;
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
    $sql = "select columnname from ld_cvadvfilter where cvid = ?";
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
?>