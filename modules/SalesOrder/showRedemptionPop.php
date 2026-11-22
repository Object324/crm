<?php
global $theme,$adb;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("IMAGE_PATH",$image_path);
$salesorderid=$_REQUEST['recordid'];
$relationId=$_REQUEST['relationId'];
$smarty->assign('RELATIONID',$relationId);
$smarty->assign('SALESORDERID',$salesorderid);
$redemptionid=empty($_REQUEST['redemptionid'])?0:$_REQUEST['redemptionid'];
$smarty->assign('REDEMPTIONID',$redemptionid);
if(!empty($redemptionid)){//编辑
    $query='
            SELECT
            	redemption_time,
            	redemption_quantity,
            	redemption_isfree,
            	redemption_cost
            FROM
            	ld_fund_redemption
            WHERE
            	redemption_id =?';
    $result=$adb->pquery($query,array($redemptionid));
    $nums=$adb->num_rows($result);
    $sysdeploy = getSys_deploy(49);//系统参数，控制小数位；
    $lengthdecimaldigits = $sysdeploy['deploy_value'];
    $redemption_time=$adb->query_result($result,0,'redemption_time');
    $redemption_quantity=$adb->query_result($result,0,'redemption_quantity');
    $redemption_quantity=sprintf('%.'.$lengthdecimaldigits.'f',abs($redemption_quantity));
    $redemption_isfree=$adb->query_result($result,0,'redemption_isfree');   
    $redemption_cost=$adb->query_result($result,0,'redemption_cost');
    $redemption_cost=sprintf('%.'.$lengthdecimaldigits.'f',$redemption_cost);
    $smarty->assign('REDEMPTIONTIME',$redemption_time);
    $smarty->assign('REDEMPTIONQUANTITY',$redemption_quantity);
    $smarty->assign('REDEMPTIONISFREE',$redemption_isfree);
    $smarty->assign('REDEMPTIONCOST',$redemption_cost);
}
 $_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("REDEMPTION");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("showRedemptionPop.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>