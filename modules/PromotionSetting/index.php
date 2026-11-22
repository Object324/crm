<?php
global $adb;
//http://www.51mis.com/mob/images/parter_banner.jpg" style="width: 320px;height: 220px;
$smarty=new lingdangCRM_Smarty();
$focus=CRMEntity::getInstance("Leads");
$fieldinfos=$focus->fieldobj->getModuleFields();
$tmp_field=new fieldInfo();
$tmp_field->setfieldLabel("--无--");

$arrfield[]=$tmp_field;
foreach($fieldinfos as $fieldname=>$fieldobj)
{
    
    $arrfield[]=$fieldobj;
}
$tmp['fields']=$arrfield;
$smarty->assign("LEADFIELD",$arrfield);
$sql='select * from ld_marketset ';
$result=$adb->pquery($sql,array());
$smarty->assign("TEMPLATEPATH",'http://www.51mis.com/mob/images/parter_banner.jpg');
if($adb->num_rows($result)>0)
{
    $smarty->assign("STATUS",$adb->query_result($result,0,'status'));
     $smarty->assign("BUSSINESS_ALLOCATE",$adb->query_result($result,0,'bussiness_allocate'));
     $smarty->assign("BUSSINESSDEAL_CONDITION",$adb->query_result($result,0,'bussinessdeal_condition'));
     $smarty->assign("MARKETADMINUSER",$adb->query_result($result,0,'marketadminuser'));
     $smarty->assign("TEMPLATEPATH",$adb->query_result($result,0,'templatepath'));
}
crm_load_class_file("MarketFieldInfo",'marketplateform/ObjInfo');
crm_load_class_file('cls_market_field','marketplateform/GetClass');
$marketfieldobj=new cls_market_field('_bussinesssave');
$marketfields=$marketfieldobj->getAllFieldliketype();


$smarty->assign('MARKETFIELDS',$marketfields);

$MergeSmowner=getCurSmOwnerSearchScope('Leads');

unset($MergeSmowner['OtherInfo']);
$smarty->assign('USERS',$MergeSmowner['UserCombo']);
$sql="select * from ld_marketset_commission where formulatype=?  order by level asc ";
$result=$adb->pquery($sql,array('level'));
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $level=$adb->query_result($result ,$i,'level');
    
    if($level==1)
    {
        $smarty->assign("first_COMMISSIONMETHOD",$adb->query_result($result,$i,'type'));
        $smarty->assign("first_COMMISSIONMONEY",$adb->query_result($result,$i,'money'));
    }
    else 
    {
         $smarty->assign("second_COMMISSIONMETHOD",$adb->query_result($result,$i,'type'));
        $smarty->assign("second_COMMISSIONMONEY",$adb->query_result($result,$i,'money'));
    }
}

$smarty->display("PromotionSetting.tpl");

?>