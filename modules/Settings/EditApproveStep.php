<?php
/****************************************************************
**edit:kevin
**date:2013-08-16
**reason:编辑流程步骤
****************************************************************/
crm_load_class_file("CommonView","modules/CustomView");
global $theme;
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid']!='')
$stepid=$_REQUEST['stepid'];
$smarty=new lingdangCRM_Smarty;
$smarty->assign("ISUSED",'no');
$arr['isused']='no';
$approve=new Approve();
$approveresult=$approve->approveUsed($record,$blockid);
if($approveresult==1 || $approveresult==5){
//	 $_REQUEST['diony']='diony';
  //  ConvertTojsonString(2,array(),"error");
//	exit();  
//32413: 系统设置 > 审批流程管理
  $arr['isused']='yes';
    $smarty->assign("ISUSED",'yes');

}
//duan 2022-4-12 使用中的审批步骤允许编辑，不删除原有的逻辑，给固定值no
$smarty->assign("ISUSED",'no');

$tabname=getTabname($blockid);
$focus=CRMEntity::getInstance($tabname);
global $global_approvereminds,$approveremindlabels,$approveremind_email_user,$approveremind_sms_user;
include(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");

/*
 * editor:gyq_05
 * reason:给CreateSendInformContent方法参数赋值
 * date  : 2016 2 25
 * */
$smarty->assign('FROMMODULE',$tabname);
$smarty->assign('TABID',$blockid);
$smarty->assign("OUT_ID",$record);


$smarty->assign('BLOCKNAME',$tabname);
$query="select * from ld_approvestep where approveid=$record and id=$stepid";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$ended=1;
$step=1;
$approvetype=0;
$profile = new Profile();
//获取模块的所有可编辑字段
$fieldobj=Field::getInstance($tabname,$adb);
$moduleFields=$fieldobj->getModuleFields();
foreach($moduleFields as $fieldname=>$fieldinfo) {
	$displaytype = $fieldinfo->getDisplaytype();
	$presence = $fieldinfo->getPresence();
	$allowedit = $fieldinfo->get_allowedit();
	$columnname=$fieldinfo->getColumnName();
	$fieldlabel=$fieldinfo->getfieldLabel();
    $bigtype = $fieldinfo->getBigType();
    //zkt 20220407 50857: （https://kh.xiaoshou360.com/haiyeyiliao/ [^]）海业医疗-复选框字段在被设置为审批必填字段时，不勾选无法保存
    //复选框字段不设置必填
    if($bigtype == 'boolean'){
        continue;
    }
	if($displaytype == 1 && $presence != 1 && $allowedit == 'yes'){
		$module_fields[] = array(
			'fieldname' => $fieldname,
			'fieldlabel' => $fieldlabel
		);
	}
}
if(!empty($module_fields)){
	$kk = 0;
	foreach($module_fields as $key => $fieldarr){
		$key = $key + 1;
		$all_module_fields[$kk][] = $fieldarr;
		if($key%4==0){
			$kk++;
		}
	}
}//新增并发步骤
$smarty->assign("concurrentstepid",$_REQUEST['concurrentstepid']);
if($num_rows){
    
    /*
     * editor:gyq_05
     * reasom:編輯步驟新增審批通知
     * date  :2016 2 24
     * */
    $sql="select * from ld_approvereminds where stepid=$stepid";

    $remindresult=$adb->query($sql);
    $remind_num_rows=$adb->num_rows($remindresult);
    for($i=0;$i<$remind_num_rows;$i++){

        $remindtype=$adb->query_result($remindresult,$i,'type');
        $remindmethod=$adb->query_result($remindresult,$i,'remindmethod');
        $reminduser=$adb->query_result($remindresult,$i,'reminduser');
        $remindcontent=$adb->query_result($remindresult,$i,'remindcontent');
		$reminduserid=$adb->query_result($remindresult,$i,'reminduserid');
        $remindcolumnname=$adb->query_result($remindresult,$i,'remindcolumnname');
        //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
        //添加提醒标题，用于移动端显示
        $remindtitle=$adb->query_result($remindresult,$i,'remindtitle');
        
        $groupname=$global_approvereminds['groups'][$remindtype];
        $reminddatas[$groupname]['method'][]=$remindmethod;
        $reminddatas[$groupname][$remindmethod]["reminduser"][]=$reminduser;
        $reminddatas[$groupname][$remindmethod][$reminduser]["remindcontent"]=$remindcontent;
        $reminddatas[$groupname][$remindmethod][$reminduser]["remindtitle"] = $remindtitle;
        if($reminduser=='selectuser')
        {
            $reminddatas[$groupname][$remindmethod][$reminduser]['hidden']=$reminduserid;
        }
        else if(in_array($reminduser,$global_approvereminds['reminduser']['chkselect']))//发送邮件，短信提醒
        { 
             $reminddatas[$groupname][$remindmethod][$reminduser]['hidden']=$remindcolumnname;
        }
        
    }
  
    $smarty->assign("REMINDHTML",getRemindsHtml($reminddatas,$tabname));
    
    $id=$adb->query_result($result,0,'approvetype');//审批人类型，参考编辑和新增界面的下拉框
    $value=$adb->query_result($result,0,'approvevalue');//审批人值（指定审批人）
    $concurrentid=$adb->query_result($result,0,'concurrentid');
 
    
    
    $smarty->assign("ApproveValuelength",0);
    $smarty->assign('APPROVEBY',$value);
    if($id==0){
        $ids=explode(',',$value);
        //$smarty->assign('sel_value',$ids);
        foreach($ids as $value){
            $approveby .=getUserFullName($value).",";
        }
        $smarty->assign("ApproveValuelength",sizeof($ids));
    }elseif($id==1){
         $profileids=explode(',',trim($value));
         
         foreach($profileids as $profileid)
         {
             $profileinfo = $profile->getProfileinfo($profileid);
             $approveby.=$profileinfo['profilename'].',';
         }
		
        $approveby = trim($approveby,',');
    }else if($id == 4){
		$approvearray = explode('::', $value);
		$approveby = '';
	}else{
        $approveby=$value;
    }


    $stepid=$adb->query_result($result,0,'id');
    if($concurrentid>0)
    {
        
        $smarty->assign("concurrentstepid",$stepid);//说明有并发步骤
    }
    $approveid=$adb->query_result($result,0,'approveid');
    $name=$adb->query_result($result,0,'name');
    $description=$adb->query_result($result,0,'description');
    $alloweditbill=$adb->query_result($result,0,'alloweditbill');//当前步骤审批人是否允许编辑(yes:允许编辑，no:不允许)
    $countersigner=$adb->query_result($result,0,'countersigner');//是否会签（yes：是）
	$augmentsinger=$adb->query_result($result,0,'augmentsinger');//本步骤审批时是否允许加签（NO：或签 YES：与签）
    $approveremarkrequire=$adb->query_result($result,0,'approveremarkrequire');//当前步骤审批意见是否必填
	$module_field=$adb->query_result($result,0,'module_field');
    $approvetype=$id;
    //如果审批人类型为1、2、3、4，>6,即存在审批人为空的情况,则显示'审批人为空时'设置栏
    if(in_array($approvetype,array(1,2,3,4))||$approvetype>6){
        $smarty->assign('SHOWEMPTYSET','yes');
    }
    $emptyapproverdeal = $adb->query_result($result,0,'emptyapproverdeal');//审批人为空时控制
    
    if(empty($emptyapproverdeal)){//选项为空
        $smarty->assign('EMPTYAPPROVERDEAL','');
    }else if($emptyapproverdeal == 'autopass'||$emptyapproverdeal == 'transfertomanager'){//自动通过，自动转交管理员
        $smarty->assign('EMPTYAPPROVERDEAL',$emptyapproverdeal);
    }else{//指定审批人
        $transfer_userids = $emptyapproverdeal;
        $transfer_userid_arr = explode(',',trim($emptyapproverdeal,','));
        
        $transfer_userinfo = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $transfer_userid_arr);
        $transfer_userids = implode(',',$transfer_userid_arr);
        $transfer_uservalues = implode(',',array_map("getUserFullName",$transfer_userid_arr));
        $smarty->assign('TRANSFERUSERIDS',$transfer_userids);
        $smarty->assign('TRANSFERUSERVALUES',$transfer_uservalues);
        $smarty->assign('TRANSFERUSERINFO',$transfer_userinfo);
        $smarty->assign('EMPTYAPPROVERDEAL','transfertouser');
    }
    $approvevalue=rtrim($approveby,',');
    $ended=$adb->query_result($result,0,'ended');
    $specifyapproverid=$adb->query_result($result,0,'specifyapproverid');
    $step=$adb->query_result($result,0,'step');
    $smarty->assign("ALLOWEDITBILL",$alloweditbill);
    $smarty->assign('MODULE_FIELDS',explode(',',$module_field));
    $smarty->assign('STEPID',$stepid);
    $smarty->assign('APPROVEID',$approveid);
    $smarty->assign('NAME',$name);
    $smarty->assign('DESCRIPTION',$description);  
   // dump($countersigner);
    $smarty->assign("countersigner",$countersigner); 
	$smarty->assign('augmentsinger',$augmentsinger);
    $smarty->assign('approveremarkrequire',$approveremarkrequire);

    //duan 20230714 读取审批步骤的必填字段信息
    crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
    $mandatoryfield_str = cls_ApproveMandatoryField::getMandatoryField($stepid);
    $arr['mandatoryfield'] = $mandatoryfield_str;
}
else
{
    $reminddatas=array();
    //35452: 审批流程管理>>审批通知界面：审批处理前默认勾选提醒方式为“对话框”和“微信”的“审批人”，审批通过和审批不通过都默认勾选提醒方式为“对话框”和“微信”的“负责人
    //35452: 审批流程管理>>审批通知界面：审批处理前默认勾选提醒方式为“对话框”的“审批人”，审批通过和审批不通过都默认勾选提醒方式为“对话框”和“负责人”
     $reminddatas['before_approve']['method'][]='dialog';
    // $reminddatas['before_approve']['method'][]='weixin';
     $reminddatas['before_approve']['dialog']["reminduser"][]='approver';
     //$reminddatas['before_approve']['weixin']["reminduser"][]='approver';
     $reminddatas['after_approve']['method'][]='dialog';
    // $reminddatas['after_approve']['method'][]='weixin';
     $reminddatas['after_approve']['dialog']["reminduser"][]='smowner';
   //  $reminddatas['after_approve']['weixin']["reminduser"][]='smowner';
     
     $reminddatas['refuse_approve']['method'][]='dialog';
    // $reminddatas['refuse_approve']['method'][]='weixin';
     $reminddatas['refuse_approve']['dialog']["reminduser"][]='smowner';
    // $reminddatas['refuse_approve']['weixin']["reminduser"][]='smowner';
     $smarty->assign("REMINDHTML",getRemindsHtml($reminddatas,$tabname));
     
     $smarty->assign("countersigner",'no'); 
}
/*
 * editor:gyq_05
 * reason:预填充审批提醒内容
 * date  :2016 2 25
 * */


$smarty->assign('ALL_MODULE_FIELDS',$all_module_fields);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('APPROVETYPE',$approvetype);
$smarty->assign('APPROVEVALUE',$approvevalue);
$smarty->assign('APPROVEARRAY',$approvearray);
$smarty->assign('ENDED',$ended);
$smarty->assign('SPECIFYAPPROVERID',$specifyapproverid);
$smarty->assign('STEP',$step);
$query="select * from ld_approvestepdetails where stepid=$stepid order by pass asc ";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$pass=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $pass[]=array('pass'=>$adb->query_result($result,$i,'pass'),
        'modulestatus'=>$adb->query_result($result,$i,'modulestatus'),
        'pickcolumnname'=>$adb->query_result($result,$i,'pickcolumnname')
        );
    }
}

$assigned_user_id = $current_user->id; 
$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $assigned_user_id), $ids);

//print_r($users_combo);
$smarty->assign("users_combo",$users_combo);
/*
edit:cdw
date:20130828
reason:user的隐藏框
*/
if(isset($_REQUEST['uservalue']))
{
    $uservalue = $_REQUEST['uservalue'];
    $uservalue = str_replace("\r\n","",$uservalue);
    $uservalue = rtrim($uservalue,',');

    $smarty->assign('uservalue',$uservalue);
}
//end
$smarty->assign('PASS',$pass);
$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);
$smarty->assign('RECORD',$record);

//echo $results->sql;exit;
//require_once 'modules/PickList/PickListUtils.php';
crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
//if($adb->num_rows($results) > 0){

 //$rows=$adb->num_rows($result);
 $fieldobjs=$focus->fieldobj->getModuleFields();
 $select_approve_type = array();
$all_fieldlabel_arr = [];
 foreach($fieldobjs as $fieldname=>$fieldinfo)
 {
	$columnname=$fieldinfo->getColumnName();
	$fieldlabel=$fieldinfo->getFieldLabel();
	$fieldid = $fieldinfo->getFieldid();
    $bigtype=$fieldinfo->getBigType();
    $uitype = $fieldinfo->getUIType();

    $all_fieldlabel_arr[$fieldname] = $fieldlabel;
    if($fieldinfo->getSaveDataBase()=='no'||$fieldinfo->isRelatedModuleField())
        continue;
	//edit: chj date: 2020/9/24 reason:单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
	if($uitype == 153 || $uitype == 154){
		$select_approve_type[$fieldid] = $fieldlabel;
        $select_uitype[$fieldid] = $uitype;
	}
    if($uitype!=15)
        continue;
    $picklist[$columnname]=$fieldlabel;
 }
$smarty->assign('SELECT_APPRIVE_TYPE',$select_approve_type);
$smarty->assign('SELECT_UITYPE',$select_uitype);
$smarty->assign('PICKLIST',$picklist);
crm_load_class_file('staticProfile.class','modules/Users');
$editprofile = staticProfile::isModuleExistsProfile($tabname,'EditView');
$smarty->assign('editprofile',$editprofile);
$arr['all_fieldlabel_arr'] = $all_fieldlabel_arr;
//}


/**
 * 获取用户职位级别信息
 * @project PROT195 审批管理改进
 * @author Tujt 2015-04-15
 */
$userlevelarr = getPicklistValesForNORole('userlevel',$adb,array(),"");
$smarty->assign('USERLEVELARR',$userlevelarr);
$arr['userlevelarr'] = $userlevelarr;
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
    if(isset($group_arr[$tmpgroupname])){
        $group_arr[$tmpgroupname."&nbsp;"]=$tmpgroupid;
    }else{
        $group_arr[$tmpgroupname]=$tmpgroupid;
    }

}
$smarty->assign('GROUPINFO',$group_arr);
//include(globalStatic::$root_directory."include/QueryGenerator/ApproveStepQuery/ApproveStepView.php");
crm_load_class_file('ApproveStepView','include/QueryGenerator/ApproveStepQuery');
crm_load_class_file("CustomView_Columnlist",'modules/CustomView');
$oCustomView = new ApproveStepView($tabname);
$modulecollist = $oCustomView->getModuleColumnsList($tabname);
$modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($tabname,$modulecollist);//高级查询模块字段
$advfilterhtml = CustomView_Columnlist::getAdvCriteriaHTML();

$advfilterlist = $oCustomView->getAdvFilterByCvid($stepid);

if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
        
$arr['foption']=$advfilterhtml;
$arr['columns_block']=$modulecolumnshtml;
$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($tabname);
$arr['advanceFields'] = $controller->getAdvanceFields();
 $_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("APPROVALSTEP");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['flabels']=$fLabels;    
$arr['approvereminds']=$global_approvereminds;
$arr['remindusertext']=$approveremindlabels['reminduserlabel'];
$arr['tipsetreminder']=getFixedLabel('PLEASESETREMINDER');
$arr['modulelabel']=getTranstab($tabname);
$arr['modulename']=$tabname;

$arr['groupinfo']=$group_arr;
$str=$smarty->fetch("Approve/EditApproveStep.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
function getRemindsHtml($reminddatas,$frommodule)
{
    global $global_approvereminds,$approveremindlabels,$approveremind_email_user,$approveremind_sms_user;
    $approvereminds=$global_approvereminds;
   
    
    foreach($approvereminds['groups'] as $groupindex=> $groupname)
    {
        $html.='<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="220%">';
        $html.='<tr>';
        $html.='<th>'.$approveremindlabels['grouplabel'][$groupname].'</th>';
        $html.='</tr>';
        $html.='</table>';
        $html.='<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">';
        $html.='<tr>
					<td>'.getFixedLabel('REMINDMETHOD').'</td>
					<td>'.getFixedLabel('REMINDERPEOPLE').'</td>
					<td width="150" nowrap="nowrap">'.getFixedLabel('REMINDSCONTENT').'</td>
				</tr>';
      foreach($approvereminds[$groupname]['method'] as $method)
      {
        //提醒方式
        $methodcheck='';
        if(isset($reminddatas[$groupname]['method']) && is_array($reminddatas[$groupname]['method']) && in_array($method,$reminddatas[$groupname]['method']))
        {
            $methodcheck="checked";
            
        }
        $html.='<tr><td>
					<input '.$methodcheck.' type="checkbox" methodtaggroup="'.$groupname.'_'.$method.'" name="'.$groupname.'_'.$method.'_method"  value="0" id="'.$groupname.'_'.$method.'_method"><label for="'.$groupname.'_'.$method.'_method">'
                        .$approveremindlabels['methodlabel'][$method].'</label>
			         </td>';
          //提醒人
            $html.='<td>';              
         foreach($approvereminds[$groupname][$method]['reminduser'] as $usertag)
         {
            $remindusercheck="";
         
            if(is_array($reminddatas[$groupname]['method']) && in_array($method,$reminddatas[$groupname]['method'])
                 &&in_array($usertag,$reminddatas[$groupname][$method]['reminduser']))
                 {
                    $remindusercheck="checked";
                 
                    $selectuserhiddevalue=$reminddatas[$groupname][$method][$usertag]['hidden'];
                    
                 }
            if(!in_array($usertag,$approvereminds['reminduser']['chkselect']))
				  $html.='<input type="checkbox" '.$remindusercheck.' methodtaggroup="'.$groupname.'_'.$method.'" name="'.$groupname.'_'.$method.'_'.$usertag.'" id="'.$groupname.'_'.$method.'_'.$usertag.'" chkselect="no"  onclick="approveremindchkbox(\''.$groupname.'_'.$method.'_'.$usertag.'\')"  /><label for="'.$groupname.'_'.$method.'_'.$usertag.'"> '.$approveremindlabels['reminduserlabel'][$usertag].'</label>&nbsp;&nbsp;&nbsp;';
                            
			else
            {
                
                if(in_array($usertag,['selectuser','selectrole','departmentposition','topposition','departmentuser']))
                {
                    
                    
                    $html.=' <input type="checkbox" '.$remindusercheck.' methodtaggroup="'.$groupname.'_'.$method.'" name="'.$groupname.'_'.$method.'_'.$usertag.'" chkselect="yes"  id="'.$groupname.'_'.$method.'_'.$usertag.'" /><label for="'.$groupname.'_'.$method.'_'.$usertag.'">'.$approveremindlabels['reminduserlabel'][$usertag].'</label>';
                    
                    $html.=' <input  type="hidden"  value="'.$selectuserhiddevalue.'" name="'.$groupname.'_'.$method.'_'.$usertag.'_hidden" id="'.$groupname.'_'.$method.'_'.$usertag.'_hidden" />
							<a class="icon-little icon-pepole"  href="javascript:;" onclick="approveSelectUserByType(\''.$frommodule.'\',\''.$groupname.'_'.$method.'\',\''.$usertag.'\');"></a>&nbsp;&nbsp;&nbsp;';
                            
                }
                else 
                {
                    $html.='<input type="checkbox" '.$remindusercheck.' methodtaggroup="'.$groupname.'_'.$method.'" name="'.$groupname.'_'.$method.'_'.$usertag.'" chkselect="yes"  id="'.$groupname.'_'.$method.'_'.$usertag.'" /><label for="'.$groupname.'_'.$method.'_'.$usertag.'">'.$approveremindlabels['reminduserlabel'][$usertag].'</label>';
                    $html.='<input  type="hidden" value="'.$selectuserhiddevalue.'" name="'.$groupname.'_'.$method.'_'.$usertag.'_hidden" id="'.$groupname.'_'.$method.'_'.$usertag.'_hidden"/>';
                    $fieldmodules=explode("_",$usertag);
                    
                   if(in_array($usertag,$approveremind_email_user))
                        $html.='<a class="icon-little icon-email"  href="javascript:;" onclick="approveSelectModuleField(\''.$frommodule.'\',\''.$fieldmodules[0].'\',\''.$groupname.'_'.$method.'\')"></a>&nbsp;&nbsp;&nbsp;';
                        
					else
                       $html.='<a class="icon-little icon-mob"  href="javascript:;" onclick="approveSelectModuleField(\''.$frommodule.'\',\''.$fieldmodules[0].'\',\''.$groupname.'_'.$method.'\')"></a>&nbsp;&nbsp;&nbsp;';     		
                }
                            
            }			
		
                        
         }
         
 	      $html.='</td>';
          //提醒内容
          $html.='<td>';
           foreach($approvereminds[$groupname][$method]['reminduser'] as $usertag)
           {
            $remindcontent="";
            $remindtitle = "";
            
            
            if(is_array($reminddatas[$groupname]['method']) && in_array($method,$reminddatas[$groupname]['method'])
                 && is_array($reminddatas[$groupname][$method]['reminduser']) && in_array($usertag,$reminddatas[$groupname][$method]['reminduser'])
                 &&$reminddatas[$groupname][$method][$usertag]['remindcontent']!="")
                 {
                  
                    $remindcontent=$reminddatas[$groupname][$method][$usertag]['remindcontent'];
                    $remindtitle=$reminddatas[$groupname][$method][$usertag]['remindtitle'];
                    
                 }
                 else if(!isset($_REQUEST['record'])|| $_REQUEST['record']<=0){
                    
                    $remindcontent=$global_approvereminds[$groupname]['defaultremind'][$usertag];
                    //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                    //第一版先使用占位符，后面增加通配符时再修改
                    $remindtitle=str_replace('{$MODULE$}',getTranstab($frommodule),$global_approvereminds[$groupname]['defaultremindtitle'][$usertag]);
                    
                 }
              $html.=' <input  type="hidden" value="'.$remindcontent.'" name="'.$groupname.'_'.$method.'_'.$usertag.'_remindcontent" id="'.$groupname.'_'.$method.'_'.$usertag.'_remindcontent"/>';
              $html.=' <input  type="hidden" value="'.$remindtitle.'" name="'.$groupname.'_'.$method.'_'.$usertag.'_remindtitle" id="'.$groupname.'_'.$method.'_'.$usertag.'_remindtitle"/>';
		      
              
           }
           $html.='<a href="javascript:void(0);" onclick="SetApproveRemindContent(\''.$frommodule.'\',\''.$groupname.'\',\''.$method.'\')">'.getFixedLabel('SETREMINDSCONTENT').'</a>';
           $html.='</td>';
           $html.="</tr>";
      }
      $html.="</table>";
   }
    
    
	return $html;			
                
}
?>