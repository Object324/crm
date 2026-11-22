<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();


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
if($year==''){
    $year = date("Y");
}
$where='where 1=1 ';
$user_id = $current_user->id;
$user_array=Array();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
require('user_privileges/user_language_'.$current_user->id.'.php');

$SearchScope = "";
$MergeSmowner=getCurSmOwnerSearchScope('Comprehensivereport');
$UserArr = $MergeSmowner['UserCombo'];
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']);
unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
unset($MergeSmowner["OtherInfo"]['smowner_search_senior']);
if(!isset($_REQUEST['Report_form_query']) && $_REQUEST['Report_form_query']=="") 
{
    $scope= 'SmOwner_Search_All';
}else{
    $scope = $_REQUEST['smownerid'];
}

$query = " ";
if($scope){
            $Smownerids= getCurSmOwnerSearchScope('Comprehensivereport');
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

switch($scope)
    {
        case 'SmOwner_Search_All':
            $query .= " and  ld_salesorder.smownerid in ( ".$SearchScope.")";
        break;
        case 'SmOwner_Search_Me':
           $query .=" and ld_salesorder.smownerid=".$current_user->id;
        break;
        case 'SmOwner_Search_Create':
            $query .=" and ld_salesorder.smcreatorid=".$current_user->id;
        break;
        case 'smowner_search_senior':
            $query .=" and ld_salesorder.smownerid in ( ".$_REQUEST['selectuserid'].")";
        break;
        default:
          $query .= " and  ld_salesorder.smownerid =  ".$scope."";
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
$cf_1486 = $_REQUEST['cf_1486'];
if($cf_1486!=''){
    $where .=' and cf_1486 like "%'.$cf_1486.'%"';
}

$List = getDividend($where,$year,$query);
/*echo '<pre>';
print_r($List);*/

function getDividend($where,$year,$query){
    global $adb; 

            $SQL = "SELECT ld_salesorder.salesorderid,signed_data,cf_1487,salesorder_no,cf_1486,
                    accountname,ld_users.last_name,cf_1488,cf_1489,cf_1490,
                    if(ld_salesorder.currency_id > 1,total/ld_salesorder.conversion_rate,total) as total,
                    users.last_name as smowner,
                    if(ld_salesorder.currency_id > 1,cf_1483/ld_salesorder.conversion_rate,cf_1483) as cf_1483,
                    if(ld_salesorder.currency_id > 1,cf_1484/ld_salesorder.conversion_rate,cf_1484) as cf_1484,
                    if(ld_salesorder.currency_id > 1,cf_1492/ld_salesorder.conversion_rate,cf_1492) as cf_1492,
                    if(ld_salesorder.currency_id > 1,cf_1493/ld_salesorder.conversion_rate,cf_1493) as cf_1493,
                    if(ld_salesorder.currency_id > 1,cf_1494/ld_salesorder.conversion_rate,cf_1494) as cf_1494,
                    if(ld_salesorder.currency_id > 1,total/ld_salesorder.conversion_rate,total)-
                    if(ld_salesorder.currency_id > 1,cf_1492/ld_salesorder.conversion_rate,cf_1492)-
                    if(ld_salesorder.currency_id > 1,cf_1493/ld_salesorder.conversion_rate,cf_1493)-
                    if(ld_salesorder.currency_id > 1,cf_1494/ld_salesorder.conversion_rate,cf_1494)
                     AS youxiaojine
                    FROM ld_salesorder
                    LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid=ld_salesordercf.salesorderid
                    LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid
                    LEFT JOIN ld_users ON ld_users.id=ld_salesorder.smcreatorid
                    LEFT JOIN ld_users AS users ON users.id=ld_salesorder.smownerid
                    $where and ld_salesorder.deleted=0 and YEAR(signed_data)=$year  $query
                    AND sostatus<>'已作废' AND ld_salesorder.approvestatus='已批准'
                     order by ld_salesorder.smownerid;";
                    //echo $SQL."<br>";
                    //
            $result1=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result1);
        for ($i = 0; $i < $rowCount; $i++) {  
            $List[$i]['salesorderid'] = $adb->query_result($result1, $i, 'salesorderid');
            $List[$i]['signed_data'] = $adb->query_result($result1, $i, 'signed_data');
            $List[$i]['cf_1487'] = $adb->query_result($result1, $i, 'cf_1487');
            $List[$i]['salesorder_no'] = $adb->query_result($result1, $i, 'salesorder_no');
            $List[$i]['cf_1486'] = $adb->query_result($result1, $i, 'cf_1486');
            $List[$i]['accountname'] = $adb->query_result($result1, $i, 'accountname');
            $List[$i]['last_name'] = $adb->query_result($result1, $i, 'last_name');
            $List[$i]['cf_1488'] = $adb->query_result($result1, $i, 'cf_1488');
            $List[$i]['cf_1489'] = $adb->query_result($result1, $i, 'cf_1489');
            $List[$i]['cf_1490'] = $adb->query_result($result1, $i, 'cf_1490');
            $List[$i]['total'] = $adb->query_result($result1, $i, 'total');
            $List[$i]['smowner'] = $adb->query_result($result1, $i, 'smowner');
            $List[$i]['cf_1483'] = $adb->query_result($result1, $i, 'cf_1483');
            $List[$i]['cf_1484'] = $adb->query_result($result1, $i, 'cf_1484');
            $List[$i]['cf_1492'] = $adb->query_result($result1, $i, 'cf_1492');
            $List[$i]['cf_1493'] = $adb->query_result($result1, $i, 'cf_1493');
            $List[$i]['cf_1494'] = $adb->query_result($result1, $i, 'cf_1494');
            $List[$i]['youxiaojine'] = $adb->query_result($result1, $i, 'youxiaojine');  
    }

            $SQL="SELECT MONTH(plandate) AS plandate,SUM(
            if(ld_paymentplan.currency_id > 1,amount/ld_paymentplan.conversion_rate,amount)
            ) AS amount,entitytypeid  
                    FROM  ld_paymentplan 
                    where ld_paymentplan.deleted=0
                    GROUP BY entitytypeid,MONTH(plandate)";
                    //echo $SQL."<br>";
            $result2=$adb->pquery($SQL,array());
            $rowCount2 = $adb->num_rows($result2);
            //echo $rowCount2;
            for ($i = 0; $i < $rowCount2; $i++) {  
                $List2[$i]['entitytypeid'] = $adb->query_result($result2, $i, 'entitytypeid');
                $List2[$i]['plandate'] = $adb->query_result($result2, $i, 'plandate');
                $List2[$i]['amount'] = $adb->query_result($result2, $i, 'amount');
             }
             foreach($List as $key=>$arr){
                foreach($List2 AS $key2=>$arr2){
                    if($arr['salesorderid']==$arr2['entitytypeid']){
                        $List[$key][$arr2['plandate'].'_huikuan']=$arr2['amount'];
                    }                    
                }

             }
            $SQL="SELECT quarter(plandate) AS plandate,SUM(
            if(ld_paymentplan.currency_id > 1,amount/ld_paymentplan.conversion_rate,amount)
            ) AS amount,entitytypeid  
                    FROM  ld_paymentplan 
                    where ld_paymentplan.deleted=0
                    GROUP BY entitytypeid,quarter(plandate)";
                    //echo $SQL."<br>";
            $result4=$adb->pquery($SQL,array());
            $rowCount4 = $adb->num_rows($result2);
            //echo $rowCount2;
            for ($i = 0; $i < $rowCount4; $i++) {  
                $List4[$i]['entitytypeid'] = $adb->query_result($result4, $i, 'entitytypeid');
                $List4[$i]['plandate'] = $adb->query_result($result4, $i, 'plandate');
                $List4[$i]['amount'] = $adb->query_result($result4, $i, 'amount');
             }
             foreach($List as $key=>$arr){
                foreach($List4 AS $key2=>$arr2){
                    if($arr['salesorderid']==$arr2['entitytypeid']){
                        $List[$key][$arr2['plandate'].'_huikuan_j']=$arr2['amount'];
                    }                    
                }

             }
            $SQL="SELECT MONTH(cashbilldate) AS cashbilldatemonth,SUM(
            if(ld_cashbill.currency_id > 1,amount/ld_cashbill.conversion_rate,amount)
            ) AS amount,cashbilldate,entitytypeid 
                    FROM  ld_cashbill 
                    left join ld_cashbill2paymentplan 
                    on ld_cashbill2paymentplan.cashbillid=ld_cashbill.cashbillid 
                    WHERE ld_cashbill.deleted=0 AND ld_cashbill.checkoutstatus='已审核'
                    GROUP BY entitytypeid,MONTH(cashbilldate);";
                //echo $SQL2."<br>";
           
           $result3=$adb->pquery($SQL,array());
        
            //echo $SQL.'<br>';
            $rowCount3 = $adb->num_rows($result3);
            for ($i = 0; $i < $rowCount3; $i++) {  
                $List3[$i]['entitytypeid'] = $adb->query_result($result3, $i, 'entitytypeid');
                $List3[$i]['cashbilldatemonth'] = $adb->query_result($result3, $i, 'cashbilldatemonth');
                $List3[$i]['cashbilldate'] = $adb->query_result($result3, $i, 'cashbilldate');
                $List3[$i]['amount'] = $adb->query_result($result3, $i, 'amount');
             }
             foreach($List as $key=>$arr){
                foreach($List3 AS $key2=>$arr2){
                    if($arr['salesorderid']==$arr2['entitytypeid']){
                        $List[$key][$arr2['cashbilldatemonth'].'_shoukuan']=$arr2['amount'];
                        $List[$key][$arr2['cashbilldatemonth'].'_cashbilldate']=$arr2['cashbilldate'];
                    }                    
                }
             }
             
             
            $SQL="SELECT quarter(cashbilldate) AS cashbilldatemonth,SUM(
            if(ld_cashbill.currency_id > 1,amount/ld_cashbill.conversion_rate,amount)
            ) AS amount,cashbilldate,entitytypeid 
                    FROM  ld_cashbill 
                    left join ld_cashbill2paymentplan 
                    on ld_cashbill2paymentplan.cashbillid=ld_cashbill.cashbillid 
                    WHERE ld_cashbill.deleted=0 AND ld_cashbill.checkoutstatus='已审核'
                    GROUP BY entitytypeid,quarter(cashbilldate);";
                //echo $SQL2."<br>";
           
           $result5=$adb->pquery($SQL,array());
        
            //echo $SQL.'<br>';
            $rowCount5 = $adb->num_rows($result5);
            for ($i = 0; $i < $rowCount5; $i++) {  
                $List5[$i]['entitytypeid'] = $adb->query_result($result5, $i, 'entitytypeid');
                $List5[$i]['cashbilldatemonth'] = $adb->query_result($result5, $i, 'cashbilldatemonth');
                $List5[$i]['amount'] = $adb->query_result($result5, $i, 'amount');
             }
             foreach($List as $key=>$arr){
                foreach($List5 AS $key2=>$arr2){
                    if($arr['salesorderid']==$arr2['entitytypeid']){
                        $List[$key][$arr2['cashbilldatemonth'].'_shoukuan_j']=$arr2['amount'];
                    }                    
                }
             }
            /* echo '<pre>';
             print_r($List);*/
             
        foreach($List as $key=>$arr){
            for($i=1;$i<=12;$i++){
                $List[$key][$i.'_youxiaohuikuan']=$arr['youxiaojine']/$arr['total']*$arr[$i.'_shoukuan'];
           }      
        }

        foreach($List as $key=>$arr){
                $List['合计']['salesorderid'] = '';
                $List['合计']['signed_data'] = '合计';
                $List['合计']['cf_1487'] = '';
                $List['合计']['salesorder_no'] = '';
                $List['合计']['cf_1486'] = '';
                $List['合计']['accountname'] = '';
                $List['合计']['last_name'] = '';
                $List['合计']['cf_1488'] = '';
                $List['合计']['cf_1489'] = '';
                $List['合计']['cf_1490'] = '';
                $List['合计']['total'] += $List[$key]['total'];
                $List['合计']['smowner'] = '';
                $List['合计']['cf_1483'] = '';
                $List['合计']['cf_1484'] = '';
                $List['合计']['cf_1492'] += $List[$key]['cf_1492'];
                $List['合计']['cf_1493'] += $List[$key]['cf_1493'];
                $List['合计']['cf_1494'] += $List[$key]['cf_1494'];
                $List['合计']['youxiaojine'] += $List[$key]['youxiaojine']; 
                for($i=1;$i<=12;$i++){
                    if($List[$key][$i.'_huikuan']>0){
                        $List['合计'][$i.'_huikuan']+=$List[$key][$i.'_huikuan'];
                    }
                    if($List[$key][$i.'_shoukuan']>0){
                        $List['合计'][$i.'_shoukuan']=$List[$key][$i.'_shoukuan'];
                    }
                    if($List[$key][$i.'_youxiaohuikuan']>0){
                        $List['合计'][$i.'_youxiaohuikuan']=$List[$key][$i.'_youxiaohuikuan'];
                    }
                }
                for($i=1;$i<=4;$i++){
                    if($List[$key][$i.'_huikuan_j']>0){
                        $List['合计'][$i.'_huikuan_j']+=$List[$key][$i.'_huikuan_j'];  
                    }
                    if($List[$key][$i.'_shoukuan_j']>0){
                        $List['合计'][$i.'_shoukuan_j']=$List[$key][$i.'_shoukuan_j'];
                    }
                }
        }
    return $List;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$List);
if($_REQUEST['Report_form_query'] == 'true')
    $smarty->display('Comprehensivereport/amountpaymentsummarycontent.tpl');
else
    $smarty->display('Comprehensivereport/amountpaymentsummary.tpl');

exit();
?>