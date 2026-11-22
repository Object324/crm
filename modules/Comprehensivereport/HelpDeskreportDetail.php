<?php
/**
 * 更新操作
 * Edit:andrew
 * date:20140126
 * reason:内销报表（龙威）
 * */
global $adb,$mod_strings;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['year']) && isset($_REQUEST['month']))
{
     if(is_int(intval($_REQUEST['year']))==false)
    {
        
        echo '报表年份错误！';
        exit();
    }
    
    if(intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    if(intval($_REQUEST['month'])<0 ||intval($_REQUEST['month'])>12)
    {
        echo '报表月份错误！';
        exit();
    }
    
    $year = $_REQUEST['year'];
    $month = $_REQUEST['month'];
}
$ProId=0;
if($_REQUEST['proid']){
    $ProId=$_REQUEST['proid'];
}
$Pro_list = get_Pro_list();
$HelpDesklist = get_HelpDesk($month,$year,$ProId);
$HelpDesknum = get_HelpDesk_nums($month,$year,$ProId);
foreach($HelpDesklist as $key=>$arr){
    foreach($HelpDesknum as $key2=>$arr2){
        if($arr[4]==$arr2[2]){
                $HelpDesklist[$key][5] = $arr2[3];
        }
    }
    unset($HelpDesklist[$key][0]);
}
//print_r($HelpDesklist);
function get_Pro_list(){
    global $adb;
    $sql = "SELECT ld_troubletickets.product_id,ld_products.productname 
FROM ld_troubletickets 
LEFT JOIN ld_products on ld_products.productid=ld_troubletickets.product_id where productname<>''
";
//echo $sql;
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $k = $adb->query_result($result, $i, 'product_id');
        $Pro_list[$k] = $adb->query_result($result, $i, 'productname');
        }
        return $Pro_list;
}
//print_r($HelpDesklist);
/*edit:andrew
*20140126
*获取服务单信息
*/
function get_HelpDesk($month,$year,$proid){
    global $adb;
    $sql = "SELECT ld_troubletickets.product_id,ld_products.productname,ld_troubletickets.ticket_no,ld_ticketcf.cf_947,ld_ticketcf.cf_948 
    FROM ld_troubletickets inner join ld_ticketcf on ld_ticketcf.ticketid=ld_troubletickets.ticketid 
     LEFT JOIN ld_products on ld_products.productid=ld_troubletickets.product_id where productname<>'' 
    and ld_troubletickets.product_id=$proid ";
    if($month==0){
        $sql .=" and YEAR(ld_troubletickets.createdtime)=".$year;
    }else{
        $sql .=" and MONTH(ld_troubletickets.createdtime)=".$month." and YEAR(ld_troubletickets.createdtime)=".$year;
    }
    
   // $sql .= " and setype='HelpDesk'";
    
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $HelpDeskList[$i][0] = $adb->query_result($result, $i, 'product_id');
        $HelpDeskList[$i][1] = $i+1;
        $HelpDeskList[$i][2] = $adb->query_result($result, $i, 'productname');
        $HelpDeskList[$i][3] = $adb->query_result($result, $i, 'cf_947');
        $HelpDeskList[$i][4] = $adb->query_result($result, $i, 'cf_948');
    }    
    return $HelpDeskList;
}

/*edit:andrew
*20140126
*获取服务单信息数量
*/
function get_HelpDesk_nums($month,$year,$proid){
    global $adb;
    $sql = "SELECT ld_troubletickets.product_id,ld_ticketcf.cf_948,COUNT(1) as pnum 
FROM ld_troubletickets 
inner join ld_ticketcf on ld_ticketcf.ticketid=ld_troubletickets.ticketid 
LEFT JOIN ld_products on ld_products.productid=ld_troubletickets.product_id 
where productname<>'' and ld_troubletickets.product_id=$proid ";
    if($month==0){
        $sql .="and YEAR(ld_troubletickets.createdtime)=".$year;
    }else{
        $sql .="and MONTH(ld_troubletickets.createdtime)=".$month." and YEAR(ld_troubletickets.createdtime)=".$year;
    }
    $sql .= "  group by cf_948";
      
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
    $HelpDeskListnum[$i][1] = $adb->query_result($result, $i, 'product_id');
    $HelpDeskListnum[$i][2] = $adb->query_result($result, $i, 'cf_948');
    $HelpDeskListnum[$i][3] = $adb->query_result($result, $i, 'pnum');
    }
    return $HelpDeskListnum;
}

//页面赋值
$smarty->assign("PROID",$ProId);//产品列
$smarty->assign("PROLIST",$Pro_list);//产品列
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);//月
$smarty->assign("HelpDesklist",$HelpDesklist);
$smarty->display('Comprehensivereport/HelpDeskreportDetail.tpl');
exit();
?>