<?php
require_once('Smarty_setup.php');
global $adb,$theme,$app_strings,$mod_strings,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty=new lingdangCRM_Smarty;
$info = '';

if(isset($_REQUEST['thisvalue']))
{
    $sql = "select productname from ld_products limit 0,20";
    $query = $adb->pquery($sql,array());
    $num_row = $adb->num_rows($query);
    for($i = 0; $i<$num_row; $i++)
    {
        $array[$i]['productname'] = $adb->query_result($query,$i,'productname');
    }            
    echo '{"total":28,"rows":' . json_encode($array) . '}';
    exit;
    $sql = "select productname from ld_products where productname like '%".$_REQUEST['thisvalue']."%'";
    $query = $adb->pquery($sql,array());
    $num_row = $adb->num_rows($query);
    if($num_row > 0)
    {
        for($i = 0; $i<$num_row; $i++)
        {
            $productname = $adb->query_result($query,$i,'productname');
            $info .='<li onClick="fill(\''.$productname.'\');" class="active-result">'.$productname.'</li>';
        }
    }
    else
    {
        $info = '<li id="li_chzn_sostatus" class="active-result" style="">'.getFixedLabel('NOMATCHINGITEMS').'</li>';
    }echo $info;exit;
}

$smarty->assign('pro',$_REQUEST['thisvalue']);
$smarty->assign('INFO',$info);
//echo '###SUCCESS###';
$smarty->display('getProduct.tpl');

?>