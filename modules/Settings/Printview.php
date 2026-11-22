<?php

require_once ('include/Stock/CommonStock.php');
global $mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$tabid = getTabid($_REQUEST['returnModule']);
$smarty->assign("MODULE",$_REQUEST['returnModule']);
$smarty->assign("ID",$_REQUEST['recordid']);
$smarty->assign("APP", $app_strings);
$focus=CRMEntity::getInstance($_REQUEST['returnModule']);


$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$smarty->fetch("Printview.tpl");
ConvertTojsonString(1,$arr,'success');

function getPrintTemplate($tabid)
{
    global $adb;
    $sql="select * from ld_templateprint where tabid=?";
    $result=$adb->pquery($sql,array($tabid));
    $templatearr=array();
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $templateprintID=$adb->query_result($result,$i,'templateprintid');
        $templatename=$adb->query_result($result,$i,'templateprintname');
        $isDefault=$adb->query_result($result,$i,'isdefault');
        $templatearr[$templateprintID]=array($templatename,$isDefault);
    }
    return $templatearr;
}
?>