<?php
require_once('Smarty_setup.php');
//require_once('data/Tracker.php');
//require_once('include/CustomFieldUtil.php');
//require_once('include/utils/utils.php');
//require_once('user_privileges/default_module_view.php');
require_once ('include/Stock/CommonStock.php');
global $mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign('TYPE',$_REQUEST['type']);
$smarty->assign("ID",$_REQUEST['recordid']);
$smarty->assign("APP", $app_strings);
$smarty->assign("NATIONINFO",getDetailNation($_REQUEST['recordid'],$_REQUEST['type'],$_REQUEST['wareid']));
echo '###SUCCESS###';
$smarty->display("DetailNation.tpl");
exit();
function getDetailNation($id,$type,$wareid)
{
    global $adb;
    if($type == 1)
    {
        $sql="select b.ware_stock_no,quantity,b.presence,b.createdtime,b.smownerid,b.modifiedtime from ld_stock a,ld_stock b where a.id = b.stock_id 
        and a.productid = ? and b.presence = '未入库' and b.deleted = 0";
    }
    else
    {
        $sql="select b.out_no,quantity,b.presence,b.createdtime,b.smownerid,b.modifiedtime from ld_outboundorderdetail a,ld_outboundorder b where a.id = b.out_id and a.productid = ? and b.presence = '未出库' and b.deleted = 0";
    }
	if($wareid != 'all'){
		$sql .= " and b.wareid = $wareid ";
	}
    $result=$adb->pquery($sql,array($id));
    $nationarr=array();
	/**
	 * @project PROT75 数量小数位数
	 * @author Tujt 2014-08-14 CRMV5.6
	 */
	$sysdeploy = getSys_deploy(49);
	if(isset($sysdeploy['deploy_value']))
		$lengthdecimaldigits = $sysdeploy['deploy_value'];
	else
		$lengthdecimaldigits  = 2;
    for($i=0;$i<$adb->num_rows($result);$i++)
    {   
        if($type == 1)
        {
            $nationarr[$i]['ware_no'] = $adb->query_result($result,$i,'ware_stock_no');
        }else{
            $nationarr[$i]['ware_no'] = $adb->query_result($result,$i,'out_no');
        }
        $nationarr[$i]['id'] = $i+1;
        $nationarr[$i]['quantity'] = setNumberFormat($adb->query_result($result,$i,'quantity'),$lengthdecimaldigits);
        $nationarr[$i]['presence'] = $adb->query_result($result,$i,'presence');
        $nationarr[$i]['createdtime'] = $adb->query_result($result,$i,'createdtime');
        $nationarr[$i]['smownerid'] = getOwnerName($adb->query_result($result,$i,'smownerid'));
        $nationarr[$i]['modifiedtime'] = $adb->query_result($result,$i,'modifiedtime');
    }
    return $nationarr;
}
?>