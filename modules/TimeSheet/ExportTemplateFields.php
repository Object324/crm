<?php
/**
 * 更新操作
 * edit:can
 * date:20140115
 * reason:导出模板界面
 * */
 //include(globalStatic::$root_directory.'modules/Export/ExportTemplateFields.php');
 
 /**
 * 更新操作
 * edit:Liver
 * date:20161012
 * reason:导出模板界面,增加明细
 * */
global $adb,$current_user;
global $currentModule;
require('user_privileges/user_language_'.$current_user->id.'.php');
$tabid=getTabid($currentModule);
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?)
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?)
 and presence in(0,2)  and ld_blocks.visible=0
order by ld_blocks.sequence, ld_field.sequence asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field',$tabid,$languageType,'ld_blocks',$tabid));

$exportarr=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=$adb->query_result($result,$i,'fieldlabel');
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
    $blockLabel=($adb->query_result($result,$i,'blocklabel'));
    $columnname=$adb->query_result($result,$i,'columnname');
    $typedata=explode('~',$typeofdata);
    if($adb->query_result($result,$i,'uitype')==4)
    {   
        $exportarr[$columnname]=array($blockLabel,'M',$fieldLabel,'field','M');
    }
    else
    {
        $exportarr[$columnname]=array($blockLabel,$typedata[1],$fieldLabel,'field',$typedata[1]);
    }
    
}

$_sql='select ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname ,input_type
    from ld_tabdetailfield tf
    inner join ld_tranlabel on ld_tranlabel.relateid=tf.tabdetailfieldid
    where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2) 
    and tf.tabid=? and (tf.tablename=? or tf.tablename=?) and tf.savedatabase = "yes" ORDER BY sequence  asc;';
$_result=$adb->pquery($_sql,array($languageType,'ld_tabdetailfield',$tabid,'ld_timesheetdetail','ld_timesheet'));
for($i=0;$i<$adb->num_rows($_result);$i++)
{
    $fieldLabel=$adb->query_result($_result,$i,'fieldlabel');
    $typeofdata=$adb->query_result($_result,$i,'typeofdata');
    $blockLabel=getTranstab('TimeSheet').getFixedLabel('Details');
    $columnname=$adb->query_result($_result,$i,'columnname');
    $typedata=explode('~',$typeofdata);
    if($adb->query_result($_result,$i,'uitype')==4)
    {   
        $exportarr[$columnname]=array($blockLabel,'M',$fieldLabel,'field','M');
    }
    else
    {
        $exportarr[$columnname]=array($blockLabel,$typedata[1],$fieldLabel,'tabdetailfield',$typedata[1]);
    }
    
}

$smarty=new lingdangCRM_Smarty();
$smarty->assign('MODULE',$currentModule);
$smarty->assign('EXPORTS',$exportarr);

$smarty->display('ExportTemplate.tpl');

?>