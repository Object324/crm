<?php
/**
 * 更新操作
 * Edit:andrew
 * date:20140110
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

$province = get_province();
if($month==1){
    $lastyear = $year-1;
    $lastmonth = 12;
}else{
    $lastyear = $year;
    $lastmonth = $month-1;
}

$lastmonthlist = get_date_data($province,$lastmonth,$lastyear,'');
$thismonthlist = get_date_data($province,$month,$year,'');
//月同比增长
//echo '<pre>';
//print_r($thismonthlist);
foreach($lastmonthlist as $key=>$arr){
    foreach($thismonthlist as $key2=>$arr2){
        if($key==$key2){
            //echo $arr2[2].'==='.$arr[2].'==='.round($arr2[2]/$arr[2]*100,2)."%".'=='.'<br>';//round($arr/$thismonthlist[$key2][2]*100,2)."%";
            //$thismonthlist[$key2][3] = round($arr2[2]/$arr[2]*100,2)."%";
            $thismonthlist[$key2][3] = round(($arr2[2]-$arr[2])/$arr[2]*100,2)."%";
        }
    }
}

//本年累计
$yearlist = get_date_data($province,$month,$year,'addups');
foreach($yearlist as $key=>$arr){
    foreach($thismonthlist as $key2=>$arr2){
        if($key==$key2){
            $thismonthlist[$key2][4] = $arr[2];
        }
    }
}

//年同比增长
$lastyearlist = get_date_data($province,$month,$year-1,'addup');
foreach($lastyearlist as $key=>$arr){
    foreach($thismonthlist as $key2=>$arr2){
        if($key==$key2){
            //$thismonthlist[$key2][5] = round($arr2[4]/$arr[2]*100,2)."%";
            $thismonthlist[$key2][5] = round(($arr2[4]-$arr[2])/$arr[2]*100,2)."%";
        }
    }
}
//echo '<pre>';
//print_r($thismonthlist);
$accidcont = get_date_data($province,$month,$year,'backsingle');
foreach($accidcont as $key=>$arr){
    foreach($thismonthlist as $key2=>$arr2){
        if($key==$key2){
            $thismonthlist[$key2][8] = $accidcont[$key2][8];
        }
    }
}
//资金回笼
//echo '<pre>';
//print_r($thismonthlist);
$cashbill = get_date_data($province,$month,$year,'cashbill');
foreach($cashbill[cashbill] as $key=>$arr){
    foreach($thismonthlist as $key2=>$arr2){
        if($key==$key2){
            if($arr){
                $thismonthlist[$key2][9] = $arr;
                $thismonthlist[$key2][10] = round($arr/$thismonthlist[$key2][2]*100,2)."%";
                $thismonthlist[$key2][11] = $thismonthlist[$key2][2]-$arr;
            }else{
                $thismonthlist[$key2][9] = 0;
                $thismonthlist[$key2][10] = "0%";
                $thismonthlist[$key2][11] = $thismonthlist[$key2][2]-0;
            }
            
        }
    }
}
foreach($thismonthlist as $key=>$arr){
    foreach($arr as $key2=>$arr2){
        if($key2!=1 && $key2 != 4 && $key2!=6 && $key2!=8 && $key2!=10 && $key2!=3 && $key2!=5){
            $thismonthlist[$key][$key2] = getDecimalTwoVal($arr2);
        }
    }
    ksort($thismonthlist[$key]);
}
/*edit:andrew
*20140114
*获取本月或上个月数据或年累计
*/
function get_date_data($province,$month,$year,$type=''){
    global $adb;
    foreach($province as $key=>$arr){
        $salelist[$key] = get_province_sale($arr,$month,$year,$type);
        if($type=='cashbill'){
            $cashbill[$key] = get_cashbill($arr,$month,$year);
        }
        
        $salelist[$key][province] = $arr;
        if($type=='backsingle'){
            $cc = getBacksingle($arr,$month,$year);
            $csa = implode(",",$cc);
            $sql = "SELECT accountid as c FROM ld_salesorder ";
            $sql .= " WHERE accountid in (".$csa.") and MONTH(signed_data)=".$month." and YEAR(signed_data)=".$year;
            $sql .= " and accountid in (SELECT accountid FROM ld_account WHERE bill_state='".$arr."')";
            $sql .= "and stockpresence='全部出库' and sostatus<>'已作废' and deleted=0;";
//echo $sql;die();
            $result=$adb->pquery($sql,array());
            $accrowCount[$key] = $adb->num_rows($result);
        } 

    }

    foreach($salelist as $key=>$arr){
        $salelists[$key][1] = $arr[province];
        $salelists[$key][6] = $arr[rowCount];
        //网点数量
        if(empty($arr[rowCount])){
            $salelists[$key][6] = 0; 
        }    
        //本月销售
        foreach($arr as $key2=>$arr2){
            $salelists[$key][2] += $arr2[total];                
        }
        foreach($accrowCount as $key3=>$arr3){
            if($key==$key3){
                if($arr3){ 
                    $salelists[$key][8] = $arr3; 
                }else{
                    $salelists[$key][8] = 0;
                }
            }
        }
        //网点平均销售
        $salelists[$key][7] = $salelists[$key][2]/$arr[rowCount];
        if($salelists[$key][7]==""){
            $salelists[$key][7] = 0;
        }
    }

    if($type=='cashbill'){
        $salelists[cashbill] = $cashbill;
        return $salelists; 
    }else{
        return $salelists;
    }
    
}

/*edit:andrew
*20140114
*获取有数据的省份列表
*/
function get_province(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 11:44
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $arr_bill_state = $objpinklist->getPickListValues('bill_state');
    $bill_state = array_values($arr_bill_state);
    /*global $adb;
    $sql = "SELECT bill_state FROM ld_bill_state";
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $bill_state[] = $adb->query_result($result, $i, 'bill_state');
    }*/
    return $bill_state;
}
//获取收款单
function get_cashbill($province,$month,$year){
    global $adb;
    $addresssql=" and accountid in(SELECT accountid from ld_account where bill_state ='".$province."')";
    $sql="select SUM(ifnull(s.Total,0)) as total from ld_cashbill as s where MONTH(s.cashbilldate)=".$month." and YEAR(s.cashbilldate)=".$year.$addresssql;
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    $total = $adb->query_result($result, 0, 'total');
    return $total;
}
/*edit:andrew
*20140114
*获取以前下单客户id
*变量：$province-省份,$month-月,$year-年
*/
function getBacksingle($province,$month,$year){
    global $adb;
    $time = $year."-".$month."-00 00:00:00";
    $sql = "SELECT accountid FROM ld_salesorder ";
    $sql .= "WHERE MONTH(signed_data)=".$month." and YEAR(signed_data)=".$year;
    $sql .= " and accountid in (SELECT accountid FROM ld_account WHERE bill_state='".$province."')";
    $sql .= "and stockpresence='全部出库' and sostatus<>'已作废' and deleted=0";
    //echo $sql."<br>";
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $account[$i] = $adb->query_result($result, $i, 'accountid');
    }
    return $account;
}
/*edit:andrew
*20140114
*按省份，月，年获取客户id,合同订单id
*变量：$province-省份,$month-月,$year-年
*/
function get_province_sale($province,$month,$year,$type=''){
    global $adb;
    $sql = "SELECT total,accountid,salesorderid FROM ld_salesorder  ";
    $sql .= "WHERE ";
    if($type=='addup'||$type=='addups'){
        $sql .= "MONTH(signed_data)<=".$month." and YEAR(signed_data)=".$year; 
    }else{
        $sql .= "MONTH(signed_data)=".$month." and YEAR(signed_data)=".$year; 
    }
    
    $sql .= " and accountid in (SELECT accountid FROM ld_account WHERE bill_state='".$province."')";
    $sql .= "and stockpresence='全部出库' and sostatus<>'已作废' and deleted=0;";
//echo $sql."<br>";
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        //$provincesale[province] = $province;
        $provincesale[rowCount] = $rowCount;
        $provincesale[$i][accountid] = $adb->query_result($result, $i, 'accountid');
        $provincesale[$i][salesorderid] = $adb->query_result($result, $i, 'salesorderid');
        $provincesale[$i][total] = $adb->query_result($result, $i, 'total');
    }
    return $provincesale;
}
//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);//月
foreach($thismonthlist as $key => $infos){
	$thismonteh_bill_state[$infos[1]] = $infos[4];
}
arsort($thismonteh_bill_state);
foreach($thismonteh_bill_state as $bill_state => $thismonthtotal){
	foreach($thismonthlist as $key => $infos){
		if($infos[1] == $bill_state){
			$infos[4] = getDecimalTwoVal($infos[4]);
			$data[] = $infos;
			//$thismonthlist[$key][2] = getDecimalTwoVal($infos[2]);
		}
	}
}
$smarty->assign("THISMONTHLIST",$data);
$smarty->display('Comprehensivereport/InsourcingreportDetail.tpl');
exit();
?>