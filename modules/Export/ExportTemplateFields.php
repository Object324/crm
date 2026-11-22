<?php
/**
 * 更新操作
 * edit:can
 * date:20140115
 * reason:导出模板界面
 * */
global $adb,$current_user;
global $currentModule;
require('user_privileges/user_language_'.$current_user->id.'.php');
$tabid=getTabid($currentModule);
//if($tabid==16){$tabid=9;}
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.fieldname,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?)
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?)
 and presence in(0,2)  and ld_blocks.visible=0  and  ld_field.uitype <> 1109
order by ld_blocks.sequence asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));


$modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
                        ,'start_hour','title','reports_to_id','phone_other'
                        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
                        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
                        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
                        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
                        ,'viewothers','editothers','imagename'
                        ,'delothers','viewselfbills','edit_other_mobile','edit_me_mobile','is_mobile_style'
                        ,'select_servicedetail','select_due_date','trackpostion','login_sms','telephone_view'
                        ,'push_work_reminds','push_news_reminds','push_wx_reminds','scopeauthority'
                        ,'accountallview','groupid','profileid','approvestatus','approveby');
if($currentModule=='Users')
{
    $deployarray=getSys_deploy(55);//呼叫中心类型
    $deploy_value=$deployarray['deploy_value']??'';
    if($deploy_value=='汉天EC2')
    {
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
        $modulenoshowfields['Users'][]='jw_user';
                    
    }
    else  if($deploy_value=='苏州思孚')
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='jw_user';
    }
    else if($deploy_value=='苏州九维')
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
    }
    else 
    {
        $modulenoshowfields['Users'][]='hantian_exten';
        $modulenoshowfields['Users'][]='sopho_exten';
        $modulenoshowfields['Users'][]='sopho_queue';
        $modulenoshowfields['Users'][]='jw_user';
    }
}
        
$exportarr=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=$adb->query_result($result,$i,'fieldlabel');
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
    $blockLabel=($adb->query_result($result,$i,'blocklabel'));
    $columnname=$adb->query_result($result,$i,'columnname');
    $fieldname=$adb->query_result($result,$i,'fieldname');
    if(in_array($fieldname,$modulenoshowfields[$currentModule]))
    {
        continue;
    }
    $typedata=explode('~',$typeofdata);
 
    /*if($adb->query_result($result,$i,'uitype')==4)
    {   
        $exportarr[$columnname]=array($blockLabel,'M',$fieldLabel,'field','M');
    }
    else
    {*/
        $exportarr[$columnname]=array($blockLabel,$typedata[1],$fieldLabel,'field',$typedata[1]);
    //}
    
}


$smarty=new lingdangCRM_Smarty();
$smarty->assign('MODULE',$currentModule);
$smarty->assign('EXPORTS',$exportarr);

$smarty->display('ExportTemplate.tpl');

?>