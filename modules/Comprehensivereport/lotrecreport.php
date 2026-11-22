<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings,$current_user, $currentModule;
$smarty=new lingdangCRM_Smarty();

$user_id = $current_user->id;
$user_array=Array();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
require('user_privileges/user_language_'.$current_user->id.'.php');

$SearchScope = "";
$MergeSmowner=getCurSmOwnerSearchScope('SalesOrder');
$UserArr = $MergeSmowner['UserCombo'];
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

if(!isset($_REQUEST['Report_form_query']) && $_REQUEST['Report_form_query']=="") 
{
    $scope= 'SmOwner_Search_All';
}else{
    $scope = $_REQUEST['SmOwnerSearchScope'];
}
$query = " ";
if($scope){
switch($scope)
    {
        case 'SmOwner_Search_All':
            $Smownerids= getCurSmOwnerSearchScope('Potentials');
            $SearchScope="";
            foreach($Smownerids['UserCombo']as $userid=>$userinfo)
            {
                 if($SearchScope == "")
                {
                    $SearchScope .=$userid; 
                }
                else
                {
                    $SearchScope .=",".$userid; 
                }	
                
            }
            $query .= " and  %s.SmOwnerid in ( ".$SearchScope.")";
        break;
        case 'SmOwner_Search_Me':
           $query .=" and %s.SmOwnerID=".$current_user->id;
           $user_id=0;
        break;
        case 'SmOwner_Search_Create':
            $query .=" and %s.SmCreatorID=".$current_user->id;
            $user_id=0;
        break;
        case 'smowner_search_senior':
            $query .=" and %s.SmOwnerID in ( ".$_REQUEST['selectuserid'].")";
            $user_id=0;
            break;
        default:
          $query .= " and %s.SmOwnerID=".$scope;
          $user_id=0;
    }
}
$smarty->assign("selectuserid",$_REQUEST['selectuserid']);
$smarty->assign("SmOwnerSearchScope",$_REQUEST['SmOwnerSearchScope']);
$smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

if(isset($_REQUEST['year']))
{
    if(is_int(intval($_REQUEST['year']))==false)
    {
        echo '报表年份错误！';
        exit();
    }
        if($_REQUEST['year']!=''){
        $year = $_REQUEST['year'];
    }else{
        $year = date('Y',time());
    }
}
//print_r($_REQUEST);
$Report_form_query=$_REQUEST['Report_form_query'];
$year=$_REQUEST['year'];
$month=$_REQUEST['month'];
$searchtype=$_REQUEST['searchtype'];
if($Report_form_query == 'true')
{
    $begin_end_date_arr=explode(' ',$_REQUEST['begin_date']);            
    $begin_date=trim($begin_end_date_arr[0]);
    $begin_dates=explode('-',$_REQUEST['begin_date']);
    $begin_month=$begin_dates[1];
    $end_date=trim($begin_end_date_arr[2]);
    $end_dates=explode('-',$end_date);
    $end_month=$end_dates[1];
    $_REQUEST['month']=$end_month;
    $_REQUEST['year']=$end_dates[0];
}
else
{  
    if($month==0){
        $begin_month=1;$end_month=12;
    }else{
        $begin_month=$month;$end_month=$month;
    }

    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01"; 
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("searchtype",$searchtype);

$AccountNamevalue = $_REQUEST['AccountName'];
$smarty->assign("AccountNamevalue",$AccountNamevalue);
if($AccountNamevalue!=''){
   $AccountNameSQL = " and ld_account.accountname like '%$AccountNamevalue%'"; 
}

$AssignedTovalue = $_REQUEST['AssignedTo'];
$smarty->assign("AssignedTovalue",$AssignedTovalue);
if($AssignedTovalue!=''){
   $AssignedToSQL = " and ld_users.last_name like '%$AssignedTovalue%'"; 
}

$ORDERNOvalue = $_REQUEST['ORDERNO'];
$smarty->assign("ORDERNOvalue",$ORDERNOvalue);
if($ORDERNOvalue!=''){
   $ORDERNOSQL = " and ld_salesorder.salesorder_no like '%$ORDERNOvalue%'"; 
}

$Packingvalue = $_REQUEST['Packing'];
$smarty->assign("Packingvalue",$Packingvalue);
if($Packingvalue!=''){
   $PackingSQL = " and ld_inventoryproductrelscf.sf4 like '%$Packingvalue%'"; 
}

$productcategory=getproductcategory();
$productcategoryvalue = $_REQUEST['productcategoryvalue'];
$smarty->assign("productcategoryvalue",$productcategoryvalue);
$smarty->assign("productcategory",$productcategory);
if($productcategoryvalue!=''){
   $productcategorySQL = " and ld_products.productcategory = '$productcategoryvalue'"; 
}

$cf_1602=getcf_1602();
$cf_1602value = $_REQUEST['cf_1602'];
$smarty->assign("cf_1602",$cf_1602);
$smarty->assign("cf_1602value",$cf_1602value);
if($cf_1602value!=''){
   $cf_1602SQL = " and ld_salesordercf.cf_1602 = '$cf_1602value'"; 
}
//Liver 2016-11-30 综合报表-乐瑞固总帐款销售表报错
crm_load_function_file("getPicklistDependencyDatasource",'modules/PickList','lingdang_DependencyPicklist');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource('Accounts');
$billstate=$picklistDependencyDatasource['bill_country']['__DEFAULT__']['bill_state']; 

$picklistDependencyDatasourcevalue = $_REQUEST['picklistDependencyDatasource'];
$smarty->assign("billstate",$billstate);
$smarty->assign("picklistDependencyDatasourcevalue",$picklistDependencyDatasourcevalue);
if($picklistDependencyDatasourcevalue!=''){
   $bill_stateSQL = " and ld_account.bill_state = '$picklistDependencyDatasourcevalue'"; 
}


$listValue=getlotrec($begin_date,$end_date,$searchtype,$AccountNameSQL,$AssignedToSQL,$ORDERNOSQL,$PackingSQL,$productcategorySQL,$cf_1602SQL,$bill_stateSQL,$query);

function getlotrec($begin_date,$end_date,$searchtype,$AccountNameSQL,$AssignedToSQL,$ORDERNOSQL,$PackingSQL,$productcategorySQL,$cf_1602SQL,$bill_stateSQL,$query){
    global $adb; 
    //echo $useridSQL;
    //echo $begin_date."<br>".$end_date;
    if($searchtype==1||$searchtype==''){
        $timeSQL='and ld_salesorder.signed_data BETWEEN \''.$begin_date.'\' AND \''.$end_date.'\' ';
    }else{
        $timeSQL='and ld_salesorder.duedate BETWEEN \''.$begin_date.'\' AND \''.$end_date.'\' ';
    }
    $SQL = "CREATE TEMPORARY TABLE
                IF NOT EXISTS TEMPTABLE IGNORE (
            SELECT 	ld_salesorder.salesorderid,
            salesorder_no,MONTH(signed_data) AS signed_data,duedate,ld_account.bill_state,ld_account.bill_city,
            accountname,cf_1602,cf_1495,taxprice AS hansuidanjia,quantity*listprice AS buhansuijine,
            ld_products.productcategory,cf_1464,productname,cf_1494,ld_users.last_name,ld_usersHelpDesk.last_name AS HDlast_name,
            quantity,ld_salesorder.total,sf4
            FROM ld_salesorder 
            LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
            LEFT JOIN ld_account ON ld_salesorder.accountid=ld_account.accountid
            INNER JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id 
            INNER JOIN ld_salesorderdetailscf ON ld_salesorderdetailscf.lineitem_id=ld_salesorderdetail.lineitem_id
            LEFT JOIN ld_products ON ld_salesorderdetail.productid=ld_products.productid
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            LEFT JOIN ld_potential ON ld_salesorder.potentialid=ld_potential.potentialid
            LEFT JOIN ld_potentialscf ON ld_potential.potentialid=ld_potentialscf.potentialid
            LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smownerid
            LEFT JOIN (
            SELECT * FROM (SELECT smownerid,createdtime,salesorderid FROM ld_troubletickets WHERE ld_troubletickets.deleted=0 
            ORDER BY createdtime DESC) AS F1 GROUP BY  F1.salesorderid
            ) AS F2 ON F2.salesorderid=ld_salesorder.salesorderid 
            LEFT JOIN ld_users AS ld_usersHelpDesk ON F2.smownerid=ld_usersHelpDesk.id 
						WHERE ld_salesorder.deleted=0 AND ld_salesorder.sostatus <> '已作废' 
                        $timeSQL $AccountNameSQL $AssignedToSQL $ORDERNOSQL $PackingSQL $productcategorySQL $cf_1602SQL $bill_stateSQL
						 ".sprintf($query,'ld_salesorder')."
                        ORDER BY ld_salesorder.createdtime DESC)
            ;";
           //echo $SQL."<br>";
           $adb->pquery($SQL,array());
        $SQL="SELECT SUM(total) AS total FROM (SELECT total FROM TEMPTABLE GROUP BY salesorderid) AS F1";
            //echo $SQL."<br>";
            $result2=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result2);
            for ($i = 0; $i < $rowCount; $i++) {  
            $total=$adb->query_result($result2, $i, 'total');
            }
         $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS TempTable2 IGNORE (
                SELECT 
            	''salesorderid,
            	'".getFixedLabel('TOTAL')."' salesorder_no,
            	'' signed_data,
            	'' duedate,
            	'' bill_state,
            	'' bill_city,
            	'' accountname,
            	'' cf_1602,
            	'' cf_1495,
            	SUM(hansuidanjia) as hansuidanjia,
            	SUM(buhansuijine) as buhansuijine,
            	'' productcategory,
            	'' cf_1464,
            	'' productname,
            	'' cf_1494,
            	'' last_name,
            	''  HDlast_name,
            	SUM(quantity) as quantity,
            	'$total' as total,
            	sf4
             from TEMPTABLE);";   
              //echo $SQL."<br>";
             $adb->pquery($SQL,array());
           $SQL="SELECT * FROM TEMPTABLE UNION SELECT * FROM TempTable2";  
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['salesorder_no'] = $adb->query_result($result, $i, 'salesorder_no');
        $productList[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $productList[$i]['duedate'] = $adb->query_result($result, $i, 'duedate');
        $productList[$i]['bill_state'] = $adb->query_result($result, $i, 'bill_state');
        $productList[$i]['bill_city'] = $adb->query_result($result, $i, 'bill_city');
        $productList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList[$i]['cf_1602'] = $adb->query_result($result, $i, 'cf_1602');
        $productList[$i]['cf_1495'] = $adb->query_result($result, $i, 'cf_1495');
        $productList[$i]['taxprice'] = $adb->query_result($result, $i, 'hansuidanjia');
        $productList[$i]['buhansuijine'] = number_format($adb->query_result($result, $i, 'buhansuijine'),2);
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $productList[$i]['cf_1464'] = $adb->query_result($result, $i, 'cf_1464');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['cf_1494'] = $adb->query_result($result, $i, 'cf_1494');
        $productList[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $productList[$i]['HDlast_name'] = $adb->query_result($result, $i, 'hdlast_name');
        $productList[$i]['quantity'] = number_format($adb->query_result($result, $i, 'quantity'),2);
        $productList[$i]['total'] = number_format($adb->query_result($result, $i, 'total'),2);
        $productList[$i]['sf4'] = $adb->query_result($result, $i, 'sf4');
    }
    
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
      //print_r($productList);  
    return $productList;
}
function getcf_1602(){
        global $adb; 
    $SQL = 'select cf_1602 from ld_cf_1602 group by cf_1602';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productList[$i]= $adb->query_result($result, $i, 'cf_1602');
        }
    return $productList;
}

function getproductcategory(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 9:41
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $productcategory = array_values($result_pick);
            /*global $adb;
    $SQL='SELECT productcategory FROM ld_productcategory group by productcategoryid';
        $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {    
            $productcategory[$i]= $adb->query_result($result, $i, 'productcategory');
        }*/
    return $productcategory;
}

function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}

function getthemonth($date)
{
    $firstday = date('Y-m-01', strtotime($date));
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
    return $lastday;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$listValue);
$smarty->display('Comprehensivereport/lotrecreport.tpl');
exit();
?>