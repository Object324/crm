<?php
/**
 * 更新操作
 * edit:can
 * date:20140115
 * reason:导出模板界面
 * */
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');

$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=22) 
and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=22) 
 and presence in(0,2) and displaytype=1 
order by ld_blocks.sequence, ld_field.sequence asc ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$languageType,'ld_blocks'));

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
$exportarr['discount_percent']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'O',getFixedlabel('WHOLEDISCOUNTPERCENT'),'CustomForm19');
$exportarr['discount_amount']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'O',getFixedLabel('WHOLEDIRECTPRICE'),'CustomForm19');
$exportarr['adjustment']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'O',getFixedLabel('Adjustment'),'CustomForm19');
$sql='select ld_tranlabel.fieldlabel from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid
where languagetype=? and trantable=? and ld_tranlabel.tabid=14 and columnname=?';
$proresult=$adb->pquery($sql,array($languageType,'ld_field','productname'));
$exportarr[$adb->query_result($proresult,0,0)]=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'M','productid','products');
$exportarr['quantity']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'M',getFixedLabel('QUANTITY'),'inventoryproductrel');
$exportarr['listprice']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'M',getFixedLabel('LISTPRICE'),'inventoryproductrel');
$exportarr['discount_percent']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'O',getFixedLabel('DISCOUNTRATE'),'inventoryproductrel');
$exportarr['discount_amount']=array(getTranstab('Products').' ' . getFixedLabel('InformationTools'),'O',getFixedLabel('DIRECTPRICE'),'inventoryproductrel');

$sql="select ld_tranlabel.fieldlabel,typeofdata,uitype,columnname 
from ld_producttoolfield
inner join ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
  where ld_tranlabel.languagetype=? and trantable=? and presence=0 and ld_producttoolfield.tabid=? and ld_producttoolfield.tablename=?  ORDER BY sequence  asc ";
$result=$adb->pquery($sql,array($languageType,'ld_producttoolfield',getTabid('SaleeOrder'),'ld_inventoryproductrelscf'));
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $fieldLabel=$adb->query_result($result,$i,'fieldlabel');
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
    $blockLabel=getTranstab('Products').' '.getFixedLabel('InformationTools');
    $columnname=$adb->query_result($result,$i,'columnname');
    $typedata=explode('~',$typeofdata);
    if($adb->query_result($result,$i,'uitype')==4)
    {
        $exportarr[$columnname]=array($blockLabel,'M',$fieldLabel,'producttoolfield','M');
    }
    else
    {
        $exportarr[$columnname]=array($blockLabel,$typedata[1],$fieldLabel,'producttoolfield',$typedata[1]);
    }
    
}
$smarty=new lingdangCRM_Smarty();
$smarty->assign('MODULE','CustomForm19');
$smarty->assign('EXPORTS',$exportarr);

$smarty->display('ExportTemplate.tpl');

?>