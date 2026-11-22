<?php

//ÉèÖÃÔÊÐí±à¼­µÄ×Ö¶Î
global $adb,$current_user;
$_REQUEST['diony']='yes';

if(!is_admin($current_user))
{
    ConvertTojsonString("-1",array(),'no profile');
}
if($_REQUEST['save']=='yes')
{
    //±£´æ
    $selfieldids=trim(trim($_REQUEST['selfieldids']),',');
    $allfieldis=trim(trim($_REQUEST['allfieldids']),',');
    
  //  $arrfieldids=explode(',',$fieldids);
    $tabid=getTabid("Users");
    $sql='update ld_field set profileeditfield="no"  where fieldid in( '.$allfieldis.')';
    $adb->pquery($sql,array());
   
  
    if(strlen($selfieldids)>0)
     {
        $sql='update ld_field set profileeditfield="yes"  where fieldid in('.$selfieldids.')';
      
        $adb->pquery($sql,array());
     }
     unsetCacheDirectory("fields");
    ConvertTojsonString(1,array(),'success');
}
else
{
    $smarty = new lingdangCRM_Smarty;


    $smarty->assign("MODULE","Users");
    $setFieldList=setAllowEditFieldList();
    $smarty->assign("SETFIELDLIST",$setFieldList);
    $str=$smarty->fetch("setSearchField.tpl");
    $retarr['title']=getFixedLabel("SETFIELD");
    $retarr['oktext']=getFixedLabel("SAVE");
    $retarr['canceltext']=getFixedLabel("CANCEL");
    $retarr['content']=$str;
    
    ConvertTojsonString(1,$retarr,"success");
}
//$smarty->assign("Hreffieldname",$focus->list_link_field);
function setAllowEditFieldList(){
    global $adb,$current_user;
     $modulenoshowfields['Users'] = array('activity_view', 'lead_view', 'hour_format', 'end_hour','user_name'
        , 'is_admin','status','profileid','wx_userid','wx_openid','dingtalk_userid','jw_user','sopho_exten','sopho_queue'
        ,'start_hour', 'title', 'reports_to_id', 'phone_other','hantian_exten','userlevel','helpdesk_log','hire_date'
        , 'secondaryemail', 'signature', 'address_street', 'address_city', 'address_state', 'address_postalcode'
        , 'address_country', 'accesskey', 'time_zone', 'currency_id','campaignsview', 'currency_grouping_pattern', 'currency_decimal_separator'
        , 'currency_grouping_separator', 'currency_symbol_placement', 'internal_mailer', 'theme', 'language'
        , 'reminder_interval', 'asterisk_extension', 'use_asterisk', 'attachmentsid', 'date_format', 'email2'
        , 'confirm_password', 'user_password', 'viewothers', 'editothers','last_name','groupid'
        , 'delothers', 'viewselfbills', 'edit_other_mobile', 'edit_me_mobile', 'is_mobile_style'
        , 'select_servicedetail', 'select_due_date', 'trackpostion', 'login_sms', 'telephone_view'
        , 'push_work_reminds', 'push_news_reminds', 'push_wx_reminds', 'scopeauthority', 'accountallview');
    $languageType= getLanguageType($current_user);
    $fieldobj=$current_user->fieldobj;
    $modulefields=$fieldobj->getModuleFields();
   
    foreach($modulefields as $fieldname=>$fieldinfo)
    {
        if(in_array($fieldname,$modulenoshowfields['Users']))
        {
            continue;
        }
         if($fieldinfo->getSaveDataBase()=='no')
                continue;
         if($fieldinfo->getDisplaytype()!=1)
         {
            continue;
         }
        $tablename =$fieldinfo->getTableName();
       // if(in_array(strtolower($tablename),$tabarray)){
           
            $fieldid=$fieldinfo->getFieldid();
            $fieldlist[$fieldid]['fieldlabel']=$fieldinfo->getFieldLabelKey();
            $fieldlist[$fieldid]['columnname']=$fieldinfo->getColumnName();
            if($fieldinfo->getProfileEditField()=='yes')
                $fieldlist[$fieldid]['searchfieldtype']=0;
            else
                $fieldlist[$fieldid]['searchfieldtype']=1;
            $fieldlist[$fieldid]['tablename']=$tablename;
       // }
    }
    /*echo "<pre>";
    print_r($fieldlist);
    echo "<pre>";*/
    return $fieldlist;
    
}
?>