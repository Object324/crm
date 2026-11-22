<?php
/**
 * 获取提醒人内容名称
 * $remindervalue:提醒人对应设置内容（提醒人为specifyuser时,remindervalue数据库取specifyuserids的值）
 * */
function getReminderText($module,$remindmethod,$reminder,$remindervalue)
{
    $reminder_user_array=getReminder_User_select_array($module);
    
   global $adb;
   if($reminder=='specifyuser')
   {
        $specifyuserids = $remindervalue;
		$query = 'select last_name,wx_userid from ld_users where id in ('.$specifyuserids.')';
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
   }else if($reminder==3){//指定角色
        include_once('modules/Users/Profile.class.php');
        $profile = new Profile();
        $profileids=explode(',',trim($remindervalue,','));
        $data='';
        foreach($profileids as $profileid)
        {
            $profileinfo = $profile->getProfileinfo($profileid);
            $data.=$profileinfo['profilename'].',';
        }
        return trim($data,',');
   }
   else if($reminder==4 || $reminder == 5)
   {//单据负责人部门成员的职位级别,单据负责人直属上级部门成员的职位级别
		return $remindervalue;
   }
   else if($reminder==6)
   {//指定部门成员的职位级别
        require_once( 'modules/Users/Group.class.php');
		$group_focus = new Group();
        $remindervaluearray = explode('::', $remindervalue);
        $groupList = $group_focus->getGroupInfoByid($remindervaluearray[0]);
        $remindervalue = getFixedLabel('Sector').':'.$groupList['groupname'];
        $remindervalue .= '<br>'.getFixedLabel('POSITIONLEVEL').':'.$remindervaluearray[1];
		return $remindervalue;
   }
    if($remindmethod==0)
    {
         foreach($reminder_user_array['dialog'] as $index=>$content)
         {
             if($content['value']==$reminder)
             {
                 return  $content['text'];
                 
             }
         }
    }
    else  if($remindmethod==1)
    {
         foreach($reminder_user_array['email'] as $index=>$content)
         {
             if($content['value']==$reminder)
             {
                 return  $content['text'];
                 
             }
         }
    }
    else  if($remindmethod==2)
    {
         foreach($reminder_user_array['sms'] as $index=>$content)
         {
             if($content['value']==$reminder)
             {
                 return  $content['text'];
                 
             }
         }
    }

}
function getReminder_User_select_array($module)
{
    $focus=CRMEntity::getInstance($module);
    $fieldobj=$focus->fieldobj;
    $smownercolumnname=$focus->getSmownerColumName();
    $smownerfieldlabel=$fieldobj->getFieldInfoBykeyValue('columnname',$smownercolumnname,'fieldlabel');
    $creatorcolumnname=$focus->getCreateColumnName();
    $creatorfieldlabel=$fieldobj->getFieldInfoBykeyValue('columnname',$creatorcolumnname,'fieldlabel');
    if($module=='Users')
    {
        $reminder_user_arr['dialog'][]=array('value'=>'curuser','text'=>getFixedLabel('CURMEMBER'));
    }
    else
    {
        if($smownerfieldlabel!='')
            $reminder_user_arr['dialog'][]=array('value'=>1,'text'=>$smownerfieldlabel);
    }
    //zkt 2022.02.25 客户/服务收费管理增加“服务代表”功能
	//服务代表
    if($module=='Accounts'||$module=='ServiceCharge')
    {
        $service_representativefieldlabel=$fieldobj->getFieldInfoBykeyValue('columnname','service_representative','fieldlabel');
        if($service_representativefieldlabel!='')
        {
            $reminder_user_arr['dialog'][]=array('value'=>'service_representative','text'=>$service_representativefieldlabel);
        }
    }
    if($creatorfieldlabel!='')
        $reminder_user_arr['dialog'][]=array("value"=>2,'text'=>$creatorfieldlabel);
     $reminder_user_arr['dialog'][]=array('value'=>'specifyuser','text'=>getFixedLabel('SPECIFYUSER'));//指定用户
     $reminder_user_arr['email'][]=array('value'=>1,'text'=>$smownerfieldlabel);
     if($creatorfieldlabel!='')
             $reminder_user_arr['email'][]=array("value"=>2,'text'=>$creatorfieldlabel);
     $reminder_user_arr['email'][]=array('value'=>'specifyuser','text'=>getFixedLabel('SPECIFYUSER'));//指定用户
     
     $reminder_user_arr['sms'][]=array('value'=>1,'text'=>$smownerfieldlabel);
      if($creatorfieldlabel!='')
        $reminder_user_arr['sms'][]=array("value"=>2,'text'=>$creatorfieldlabel);
     $reminder_user_arr['sms'][]=array('value'=>'specifyuser','text'=>getFixedLabel('SPECIFYUSER'));//指定用户
    //if($remindmethod=='1'||$remindmethod=='2')
    //{
      if(true)
        {
            //zkt 20220915 XUQIU1000406  自动提醒设置，提醒人增加【单选用户】、【多选用户】、【团队成员】、【指定角色】和【单据负责人部门成员的职位级别】等选项（参考审批人类型）
            $tmp_reminder_user_arr[]=array('value'=>3,'text'=>getFixedLabel('SPECIFYROLE'));//指定角色
            $tmp_reminder_user_arr[]=array('value'=>4,'text'=>getFixedLabel('SPECIFYPROMOTERDEP'));//单据负责人部门成员的职位级别
            $tmp_reminder_user_arr[]=array('value'=>5,'text'=>getFixedLabel('LBL_POSITIONLEVEL'));//单据负责人直属上级部门的职位级别
            $tmp_reminder_user_arr[]=array('value'=>6,'text'=>getFixedLabel('LBL_POSITIONDEPARTMENT'));//指定部门成员的职位级别
            
            $modulefields = $focus->fieldobj->getModuleFields();
            $fieldarr = [];
            foreach($modulefields as $tmp_fieldname=>$tmpfieldinfo){
                $tmpbigtype = $tmpfieldinfo->getBigType();
                $tmpuitype = $tmpfieldinfo->getUIType();
                $tmptablename = $tmpfieldinfo->getTableName();
                $tmpcolumnname = $tmpfieldinfo->getColumnName();
                $tmpfieldlabel = $tmpfieldinfo->getFieldLabel();
                if($tmpuitype == 153||$tmpuitype == 154){
                    //单选用户、多选用户、团队成员
                    $tmp_reminder_user_arr[]=array('value'=>'UserField##'.$tmptablename.'##'.$tmpcolumnname,'text'=>$tmpfieldlabel);
                }
            }
            
        }  
        
        if($module=='Accounts'||$module=='ServiceCharge')
        {
            $tmp_reminder_user_arr[]=array('value'=>'Accounts','text'=>getFixedLabel('Customer'));//客户
            
            $tmp_reminder_user_arr[]=array('value'=>'Accounts##Primary##Contacts','text'=>getFixedLabel('CUSTOMERPRIMARYCONTACT'));//客户首要联系人
            $tmp_reminder_user_arr[]=array('value'=>'Accounts##All##Contacts','text'=>getFixedLabel('CUSTOMERANDRELATEDCONTACT'));//客户和关联联系人
            
        }
        else if($module=='Contacts')
        {
            $tmp_reminder_user_arr[]=array('value'=>'Contacts','text'=>getFixedLabel('CONTACTS'));//联系人
        }
        else if($module=='Vendors')
        {
            $tmp_reminder_user_arr[]=array('value'=>'Vendors','text'=>getFixedLabel('VENDORS'));//供应商
            $tmp_reminder_user_arr[]=array('value'=>'Vendors##All##VendorContact','text'=>getFixedLabel('VENDORANDRELATEDCONTACT'));//供应商和关联联系人
            //zkt 	0047361: （https://81mis.com/kfbcrm [^]）自动提醒设置，供应商模块，提醒方式选择“邮件”和“短信”时，提醒人中隐藏“供应商联系人”选项
            //$tmp_reminder_user_arr[]=array('value'=>'VendorContact','text'=>getFixedLabel('VENDORCONTACT'));//供应商联系人

        }
        else if($module=='VendorContact')
        {
            $tmp_reminder_user_arr[]=array('value'=>'VendorContact','text'=>getFixedLabel('VENDORCONTACT'));//供应商联系人
        }
        else
        {
            $accountfield=$focus->fieldobj->getFieldInfoBykeyValue('uitype',73,'columnname');
            $contactfield=$focus->fieldobj->getFieldInfoBykeyValue('uitype',57,'columnname');
            
            if(!empty($accountfield))
            {
                $tmp_reminder_user_arr[]=array('value'=>'Accounts','text'=>getFixedLabel('Customer'));//客户
            }
            if(!empty($contactfield))
            {
                $tmp_reminder_user_arr[]=array('value'=>'Contacts','text'=>getFixedLabel('CONTACTS'));//联系人
            }
            if(!empty($accountfield))
            {
                $tmp_reminder_user_arr[]=array('value'=>'Accounts##Primary##Contacts','text'=>getFixedLabel('CUSTOMERPRIMARYCONTACT'));//客户首要联系人
                $tmp_reminder_user_arr[]=array('value'=>'Accounts##All##Contacts','text'=>getFixedLabel('CUSTOMERANDRELATEDCONTACT'));//客户和关联联系人
            }
            
            /************供应商**********************************/
            $vendorfield=$focus->fieldobj->getFieldInfoBykeyValue('uitype',75,'columnname');
            if(empty($vendorfield))
            {
                $vendorfield=$focus->fieldobj->getFieldInfoBykeyValue('uitype',81,'columnname');
            }
            $vendorcontactfield=$focus->fieldobj->getFieldInfoBykeyValue('uitype',97,'columnname');
            if(!empty($vendorfield))
            {
                $tmp_reminder_user_arr[]=array('value'=>'Vendors','text'=>getFixedLabel('VENDORS'));//供应商
                
                
            }
            if($vendorcontactfield)
            {
                 $tmp_reminder_user_arr[]=array('value'=>'VendorContact','text'=>getFixedLabel('VENDORCONTACT'));//供应商联系人
            }
            if(!empty($vendorfield))
            {
                $tmp_reminder_user_arr[]=array('value'=>'Vendors##All##VendorContact','text'=>getFixedLabel('VENDORANDRELATEDCONTACT'));//供应商和关联联系人
            }
            
            
        }
        foreach($tmp_reminder_user_arr as $index=>$content)
        {
            $reminder_user_arr['dialog'][]=$content;
            $reminder_user_arr['sms'][]=$content;
            $reminder_user_arr['voice'][]=$content;
            $reminder_user_arr['email'][]=$content;
                
        }
    //}

    
    return $reminder_user_arr;
}

//提醒方式内容
function getRemindmethod_select_array()
{
    $version = getVersionTradeInfo();
    //提醒方式内容
    $remindmethod_array=array();
    $remindmethod_array['nodialog'][]=array('value'=>1,'text'=>getFixedLabel('EMAIL'));
    $remindmethod_array['nodialog'][]=array('value'=>2,'text'=>getFixedLabel('SMS'));
    $remindmethod_array['dialog'][]=array('value'=>0,'text'=>getFixedLabel('DIALOG').'/'.getFixedLabel('MobileTerminal'));
    $remindmethod_array['dialog'][]=array('value'=>1,'text'=>getFixedLabel('EMAIL'));
    $remindmethod_array['dialog'][]=array('value'=>2,'text'=>getFixedLabel('SMS'));
    
    if($version['account']=="ygchuangxin"&&getTabname($blockid)=="Accounts"){
        $remindmethod_array['nodialog'][]= array('value'=>201,'text'=>getFixedLabel('VOICE'));
        $remindmethod_array['dialog'][]= array('value'=>201,'text'=>getFixedLabel('VOICE'));
    }
    return $remindmethod_array;
}


?>