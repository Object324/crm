<?php
/***************************************************
**更新操作
**edit:chj
**date:2014-9-18
**reason:客户和联系人关联字段
***************************************************/

global $adb,$theme,$mod_strings,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='AccountsContactsField';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$languageType= getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty;
$tabnames = array('Accounts','Contacts');
//保存已存字段
if(isset($_REQUEST['edittype']) && $_REQUEST['edittype'] == 'Add')
{
	if(isset($_REQUEST['enname']) && isset($_REQUEST['zhname']))
	{
		/*if($_REQUEST['isdisplay'] == '')
			$is_display = 1;//不显示
		else
			$is_display = 0;//显示*/
		$is_display = $_REQUEST['isdisplay'];
		if(getBlockDisplayInfo('AccountContacts') == '')//新增
		{
			$adb->pquery('insert into ld_blockdisplay(zh_blockname,en_blockname,display_position,is_display,block_type) values (?,?,?,?,?)',array($_REQUEST['zhname'],$_REQUEST['enname'],$_REQUEST['display_type'],$is_display,'AccountContacts'));	
		}
		else
		{
			$adb->pquery('update ld_blockdisplay set zh_blockname = ?,en_blockname=?,display_position=?,is_display=? where block_type = ?',array($_REQUEST['zhname'],$_REQUEST['enname'],$_REQUEST['display_type'],$is_display,'AccountContacts'));
		}
	}
	
    //撤销、去除之前所有的已选字段和顺序
    $adb->pquery("update ld_field set associatedfields = 1,associatedsequence=0 where associatedfields = 0");
    $selectedfields = explode(';',rtrim($_REQUEST['selectedfields'],';'));
    for($i = 0; $i<count($selectedfields); $i++)
    {
        $sequence = $i+1;
        $adb->pquery("update ld_field set associatedfields = 0,associatedsequence=? where fieldid = ?", array($sequence,$selectedfields[$i]));
    }
    unsetCacheDirectory('fields');
	$_REQUEST['diony']='yes';
	ConvertTojsonString(1,array(),"success");
}

//获取当前模块已选字段
$selected_fields = getAllFields(1);
for($i = 0; $i<count($tabnames); $i++)
{
    //zkt 20230810 可选字段应不包括标签 BUG0070932 kfbcrm-后台设置-其他设置-显示客户和联系人关联字段- 相关联的模块 单据详情界面显示错位 
    $query = 'select ld_field.fieldid,ld_tranlabel.fieldlabel from ld_field 
        inner join ld_tranlabel on ld_tranlabel.relateid = ld_field.fieldid 
        where ld_field.presence in (0,2) and ld_tranlabel.languagetype = ?  
        and ld_tranlabel.trantable=? and ld_field.uitype != 301 and ld_tranlabel.tabid = ? and ld_field.tablename != \'ld_attachments\'';
    //去除已选字段
    if(!empty($selected_fields))
    {
        $query .= " and ld_field.fieldid not in ($selected_fields)";   
    }
    //如果是客户 则不显示客户的首要联系人
    if($tabnames[$i] == 'Accounts')
    {
        $query .= " and ld_field.tablename not in ('ld_contactdetails','ld_contactscf') ";
    }
    $query .=" order by ld_field.block,ld_field.sequence asc ";//排序

        
    $result = $adb->pquery($query,array($languageType,'ld_field',getTabid($tabnames[$i])));
    $num_row = $adb->num_rows($result);
    for($j = 0; $j<$num_row; $j++)
    {
        $fieldid = $adb->query_result($result,$j,'fieldid');
        $fieldlabel = $adb->query_result($result,$j,'fieldlabel');
        $fields[$fieldid] = getTranstab($tabnames[$i]) . '_' . $fieldlabel;
    }
}
//区块信息
$blockinfo = getBlockDisplayInfo('AccountContacts');
if(isset($_REQUEST['edittype']) && $_REQUEST['edittype'] == 'Add')
{
	$blockinfo['zh_blockname'] = $_REQUEST['zhname'];
	$blockinfo['en_blockname'] = $_REQUEST['enname'];
	$blockinfo['display_position'] = $_REQUEST['display_type'];
	$blockinfo['is_display'] = $is_display;
	
}

$smarty->assign('BLOCKINFO',$blockinfo);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('ALLFIELDS',$fields);
$smarty->assign('CHILDFIELDS',getAllFields(0));
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('APP',$app_strings);
$smarty->assign('ALLMODULENAME',getAllModuleName());
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/AccountsContactsField.tpl');
ConvertTojsonString(1,$arr,"success");
/**
 * @edit:chj
 * @date:2014-9-18
 * @reason:获取已选字段
 * @description:
 */
function getAllFields($type)
{
    global $adb,$current_user;
    $languageType= getLanguageType($current_user);
    $query = "select ld_field.tabid,ld_field.fieldid,ld_tranlabel.fieldlabel from ld_field 
    inner join ld_tranlabel on ld_tranlabel.relateid = ld_field.fieldid 
    where ld_field.presence in (0,2) and ld_tranlabel.languagetype = ? 
    and ld_tranlabel.trantable=? and associatedfields = 0  and ld_field.tabid in(6,4) order by associatedsequence asc ";
    $result = $adb->pquery($query,array($languageType,'ld_field'));
    $num_row = $adb->num_rows($result);
    for($j = 0; $j<$num_row; $j++)
    {
        $fieldid = $adb->query_result($result,$j,'fieldid');
        $fieldlabel = $adb->query_result($result,$j,'fieldlabel');
        $tabid = $adb->query_result($result,$j,'tabid');
        $fieldids[$j] = $fieldid;
        $fieldlabels[$fieldid] = getTranstab(getTabModuleName($tabid)) . '_' . $fieldlabel;
    }
    if($type == 1)
        return implode(',',$fieldids);
    else
        return $fieldlabels;
}

/**
 * @edit:liver
 * @date:2018-3-14
 * @reason:获取显示客户及联系人关联字段区块的模块,bug0033245
 * @description:
 */
function getAllModuleName(){
    global $adb,$current_user;
    $languageType= getLanguageType($current_user);
    //所有显示客户及联系人关联字段区块的模块(只显示启用模块)
    $query = "select name from ld_tab where presence =0 and name  in ('ContactRecords','Quotes','SalesOrder','SalesBack','ServiceContracts',
             'HelpDesk','ServiceReturn','Project','ProjectTask','Invoice','CashBill','PaymentPlan','OutboundOrder','Commission','Expense','Potentials')";
    $result = $adb->pquery($query,array());
    $num_row = $adb->num_rows($result);
                 
    for($i = 0; $i < $num_row; $i++){
        $name = $adb->query_result($result,$i,'name');
        $moduleLabels[$i] = getTranstab($name);
    }
    
    if($languageType == 'zh')
        return   implode('、',$moduleLabels);
    else
        return   implode(',&nbsp;&nbsp;',$moduleLabels);                      
}
?>