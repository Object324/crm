<?php
/**************************************************************************
**edit:diony
**date:2014-05-07
**reason:自动提醒
**************************************************************************/
include(globalStatic::$root_directory.'modules/Settings/CommonAutoReminds.php');
global $current_user,$default_charset;
global $current_user;

if($_REQUEST['type'] == 'saveAutoRemindTableSort') {
    $type = $_REQUEST['type'];
    global $adb;
//保存审批流程排序 weiyannan 20231121 XUQIU1002038 后台设置列表界面可以做排序 后台设置--参数设置-自动提醒设置
    if ($type == 'saveAutoRemindTableSort') {
        if (!empty($_REQUEST['tagids'])&&!empty($_REQUEST['tabid'])) {
            $tabid = $_REQUEST['tabid'];
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_automaticreminds set sequence = ? where id = ? and tabid = ?', array($sequence, $id, $tabid));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
}

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='AutomaticReminds';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$languageType= getLanguageType($current_user);
/*$sql='select  name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=? and presence in(0,2) order by tabsequence ';*/
 
 $sql="select DISTINCT ld_tab.tabid,name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=?  and presence in(0,2) 
AND name NOT IN ('Home','MassSMS','MassEmails','SmsPhrases','MailManager','Emails','SalesGoal',
'EmailListtmp','CommunicationLog','Navigation','InventoryLedger','InventoryAccount',
'InventoryQuery','Prdtnums','BankCash','OftenUseReport','Dashboard','Comprehensivereport',
'Reports','Reminds','FieldFormulas','Cache','reportlog','recyclebin','Faq','Customreport','CooperativeWork','ChinaMap','CustomEcharts','Singin') GROUP BY tabid  order by tabsequence ";
$result=$adb->pquery($sql,array($languageType,'ld_tab'));

$num_rows=$adb->num_rows($result);

$tab=array();
if($num_rows){
    $count=0;
    for($i=0;$i<$num_rows;$i++){
        $tabid=$adb->query_result($result,$i,'tabid');
        $module=$adb->query_result($result,$i,'name');
        if($tabid==22){
            $blockid=$tabid;
            $count++;
        }        
        $tab[]=array('tabid'=>$tabid,
        'tabname'=>getTranstab($module)
        );
    }
    if(!$count)
    $blockid=$adb->query_result($result,0,'tabid');
}

if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
$blockid=$_REQUEST['blockid'];

$smarty=new lingdangCRM_Smarty;
$smarty->assign('TAB',$tab);
$query="select * from ld_automaticreminds where tabid=? and defaultnum is null ORDER BY sequence,createdtime";
$result=$adb->pquery($query,array($blockid));
$num_rows=$adb->num_rows($result);
$automaticreminds=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        
        $columnname=$adb->query_result($result,$i,'columnname');
        if($columnname == 'dothis')
        {
            $columnname=getFixedLabel('custom');
        }
        else
        {
            $arr=explode(':',$columnname);
            $columnname=gettranslabelfields(getTabname($blockid),$arr[1]);
			if(empty($columnname)){
				$module = getTabname($blockid);
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
					$field = $productFields[$arr[1]];
					if(!empty($field)){
						$columnname = $field->fieldLableKey;
					}
				}
			}
        }
        $remindervalue = $adb->query_result($result,$i,'remindervalue');//提醒人对应设置值（不包括指定成员）
        $reminder = $adb->query_result($result,$i,'reminder');
        if($reminder == 'specifyuser'){
            $remindervalue = $adb->query_result($result,$i,'specifyuserids');//指定用户ID
        }
        
        $automaticreminds[]=array('id'=>$adb->query_result($result,$i,'id'),
        'tabid'=>$adb->query_result($result,$i,'tabid'),
        'name'=>$adb->query_result($result,$i,'name'),
        'columnname'=>$columnname,
        'remindnum'=>$adb->query_result($result,$i,'remindnum'),
        'remindway'=>$adb->query_result($result,$i,'remindway'),
        'reminder'=>getReminderText(getTabname($blockid),$adb->query_result($result,$i,'remindmethod'),$adb->query_result($result,$i,'reminder'),$remindervalue),
        'reminderc'=>gettranslabelfields(getTabname($adb->query_result($result,$i,'tabid')),'smcreatorid'),
        'reminders'=>gettranslabelfields(getTabname($adb->query_result($result,$i,'tabid')),'smownerid'),
        'status'=>$adb->query_result($result,$i,'status'),
        'remindcontent'=>decode_html($adb->query_result($result,$i,'remindcontent'))
        );
    }
}
$smarty->assign('AUTOMATICREMINDS',$automaticreminds);
$smarty->assign('THEME',$theme);

$smarty->assign('BLOCKID',$blockid);
$smarty->assign('COUNT',$num_rows);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);

// require_once('SetmenuControl.php');
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//企业号设置帮助
$labels = array('AutomaticReminds');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
$_REQUEST['diony']='yes';
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    
    $smarty->display('AutomaticReminds/AutomaticRemindsEntries.tpl');
    exit();
}
else
{
    if(isset($_REQUEST['directmode']) && $_REQUEST['directmode']=='ajax')
    {
        $arr['content']= $smarty->fetch('AutomaticReminds/AutomaticRemindsLists.tpl');
        ConvertTojsonString(1,$arr,"success");
    }
    else
    {
        $arr['content']= $smarty->fetch('AutomaticReminds/AutomaticRemindsList.tpl');
        ConvertTojsonString(1,$arr,"success");
    }
}
?>