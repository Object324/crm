<?php
/**
 * 更新操作
 * Edit:andrew
 * date:20140110
 * reason:年度统计表（龙威）
 * */
global $adb,$mod_strings;
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$smarty=new lingdangCRM_Smarty();

$tdtotalhtml='<td class="listTableRow small" style="background-color:#EEEEEE;">';
$tdhtml='<td class="listTableRow">';
$tdtotalright='<td class="listTableRow small" style="background-color:#EEEEEE;" align="right">';
$tdright='<td class="listTableRowRight">';

if(isset($_REQUEST['year']))
{
    if((is_int(intval($_REQUEST['year']))==false)&&intval($_REQUEST['year'])>date('Y'))
    {
        echo '报表年份错误！';
        exit();
    }
    //销售额
    $year = $_REQUEST['year'];
    $SaleLists = get_year_sale($year,'','');
    //上一年销售额
    $oyear = $year-1;
    $OldSaleLists = get_year_sale($oyear,'','');
    
    //同比增长
    $saletotal = $SaleLists['total'];
    $addtotal = $SaleLists['total']-$OldSaleLists['total'];
    unset($SaleLists['total']);
    foreach($SaleLists as $key1=>$arr){
        foreach($OldSaleLists as $key2=>$oldarr){
            if($key1==$key2){
                //$SaleAddList[$key2] = $arr-$oldarr;
                $SaleAddList[$key2] = round(($arr-$oldarr)/$oldarr*100,2)."%";
            }
        }
    }
    
    //金额格式化
    foreach($SaleLists as $key=>$arr){
        $SaleLists[$key] = getDecimalTwoVal($arr);
    }
    /*
    foreach($SaleAddList as $key=>$arr){
        $SaleAddList[$key] = getDecimalTwoVal($arr);
    }
    */

//新单
    for($i=1;$i<=12;$i++){
        $time = $year."-".$i."-00 00:00:00";
        $sql="select SUM(ifnull(s.total,0)) as total,MONTH(s.signed_data) AS s_month from ld_salesorder as s 
        where s.sostatus<>'已作废' and s.deleted=0 and s.stockpresence='全部出库' 
        and YEAR(s.signed_data)=".$year." AND MONTH(s.signed_data)=".$i." 
        AND  accountid not in(
            SELECT accountid FROM ld_salesorder as s 
            WHERE s.stockpresence='全部出库' and s.signed_data<='".$time."'
            ) 
        GROUP BY s_month ORDER BY s_month ASC";
        $result=$adb->pquery($sql,array());
        $tos = $adb->query_result($result, 0, 'total');
        $NewSale[$i]=getDecimalTwoVal($tos);
        $NewSale[total]+=$tos;
    }
    
    $newsaletotal = $NewSale[total];
    unset($NewSale[total]);
    
//返单
    for($i=1;$i<=12;$i++){
        $time = $year."-".$i."-00 00:00:00";
        $sql="select SUM(ifnull(s.total,0)) as total,MONTH(s.signed_data) AS s_month 
        from ld_salesorder as s 
        where s.sostatus<>'已作废' and s.deleted=0 
        and s.stockpresence='全部出库' and YEAR(s.signed_data)=".$year." 
        AND MONTH(s.signed_data)=".$i." AND  accountid in(
            SELECT accountid FROM ld_salesorder as s  
            WHERE s.stockpresence='全部出库' and s.signed_data<='".$time."'
            ) 
        GROUP BY s_month ORDER BY s_month ASC";
        $result=$adb->pquery($sql,array());
        $tos = $adb->query_result($result, 0, 'total');
        $backSale[$i]=getDecimalTwoVal($tos);
        $backSale[total]+=$tos;
    }
    
    $backsaletotal = $backSale[total];
    unset($backSale[total]);
    $newpercent = round($newsaletotal/$saletotal*100,2)."%";
    $oldpercent = round($backsaletotal/$saletotal*100,2)."%";
    
    //客户类型
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 10:55
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $arr_accounttype = $objpinklist->getPickListValues('accounttype',"ld_field",array(),"");
    foreach($arr_accounttype as $value){
        $a_type = $value;
        $atypes[] = $value;
        $a_type_sale[] = get_year_sale($year,$a_type,'');
    }
    /*$asql = "SELECT accounttype FROM ld_accounttype";
    $result=$adb->pquery($asql,array());
    $rowCount = $adb->num_rows($result);
    for($i=0;$i<$rowCount;$i++){
        $a_type = $adb->query_result($result, $i, 'accounttype');
        $atypes[] = $adb->query_result($result, $i, 'accounttype');
        $a_type_sale[] = get_year_sale($year,$a_type,'');
    }*/
    
    foreach($a_type_sale as $key1=>$arr1){
        if(!empty($arr1[total])){
            $a_type_sale[$key1][13] = $arr1[total];
        }else{
            $a_type_sale[$key1][13] = '0.00';
        }
            $atotal+=$a_type_sale[$key1][total];
            unset($a_type_sale[$key1][total]);
    }
    
    foreach($a_type_sale as $key1=>$arr1){
        $a_type_sale[$key1][14] = round(($arr1[13]/$atotal*100),2)."%";
    }
    
    foreach($a_type_sale as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            if($key2!=14){
            $a_type_sale[$key][$key2] = getDecimalTwoVal($arr2);
            }
        }
    }
    
    $atypes[0]='其中：'.$atypes[0];
    
    foreach($atypes as $key=>$arr){
        foreach($a_type_sale as $key2=>$arr2){
            if($key==$key2){
                array_unshift($a_type_sale[$key2],$atypes[$key]);
            }
        }
    }
    
//区域
    //Liver 2016-11-30 综合报表-销售统计表——总表 报错
    crm_load_function_file("getPickListDependency",'modules/PickList','lingdang_DependencyPicklist');
    $dependentPicklists = lingdang_DependencyPicklist::getPickListDependency('Accounts','bill_country','bill_state');
    
    foreach($dependentPicklists[valuemapping] as $key=>$arr){
    /*if($key!=0){
        unset($arr[targetvalues][0]);
    }*/
    $addresssale = implode("','",$arr[targetvalues]);
    $sourcevalue[] = $arr[sourcevalue];
    $addresssale = "'".$addresssale."'";
    $Chinaarea[] = get_year_sale($year,'',$arr['sourcevalue']);
    $Chinaarea[$key][13] = $Chinaarea[$key][total];
    unset($Chinaarea[$key][total]);
    $areatotal += $Chinaarea[$key][13];
    }

    foreach($Chinaarea as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            if($key2==13){
                $Chinaarea[$key][14] = round($arr[13]/$areatotal*100)."%";
            }
            if($key2!=14){
                $Chinaarea[$key][$key2] = getDecimalTwoVal($arr2);
            }
        }
    }
    
    foreach($sourcevalue as $key=>$arr){
        foreach($Chinaarea as $key2=>$arr2){
            if($key==$key2){
                array_unshift($Chinaarea[$key],$arr);
            }
        }
    }
    
    $Chinaarea[0][0]='其中：'.$Chinaarea[0][0];

    //资金回笼
    $cashbilllist = get_cashbill($year);
    
    $cashbilltotal = $cashbilllist[total];
    unset($cashbilllist[total]);

    $cashbilltotalp = round(($cashbilltotal/$saletotal*100),2)."%";
    
    foreach($SaleLists as $key1=>$arr1){
        foreach($cashbilllist as $key2=>$arr2){
            if($key1==$key2){
                $cashbilllist[$key2] = getDecimalTwoVal($arr2);
                $arr1a=str_replace(",", "",$arr1); 
                $arr2a=str_replace(",", "",$arr2); 
                $cashp[$key1] = round(($arr2a/$arr1a*100),2)."%";
            }
        }
    }
   
    //应收账款余额(元)
    foreach($SaleLists as $key1=>$arr1){
        foreach($cashbilllist as $key2=>$arr2){
            if($key1==$key2){
            $arr1=str_replace(",", "",$arr1); 
            $arr2=str_replace(",", "",$arr2); 
            $Balance[$key1] = (float)$arr1-(float)($arr2);
            $btotal += ((float)$arr1-(float)($arr2));
            }
        }
    }
    for($c=1;$c<=12;$c++){
        for($i=1;$i<=$c;$i++){
        $Balances[$c]+=$Balance[$i];
        }
    }
    foreach($Balances as $key=>$val)
    {
        $Balances[$key]=getDecimalTwoVal($val);
    }
    //print_r($Balances);
    //资金回笼区域
    foreach($dependentPicklists[valuemapping] as $key=>$arr){
        /*if($key!=0){
            unset($arr[targetvalues][0]);
        }*/
        $addresssalecashbill = implode("','",$arr[targetvalues]);
        $sourcevaluecashbill[] = $arr[sourcevalue];
        $addresssalecashbill = "'".$addresssalecashbill."'";
        $Chinaareacashbill[] = get_cashbill($year,$arr['sourcevalue']);
        $Chinaareacashbill[$key][13] = $Chinaareacashbill[$key][total];
        unset($Chinaareacashbill[$key][total]);
        $areatotalcashbill += $Chinaareacashbill[$key][13];
    }

    foreach($Chinaareacashbill as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            if($key2==13){
                $Chinaareacashbill[$key][14] = round($arr[13]/$areatotalcashbill*100,2)."%";
            }
            if($key2!=14){
                $Chinaareacashbill[$key][$key2] = getDecimalTwoVal($arr2);
            }
        }
    }
    
    foreach($sourcevaluecashbill as $key=>$arr){
        foreach($Chinaareacashbill as $key2=>$arr2){
            if($key==$key2){
                array_unshift($Chinaareacashbill[$key],$arr);
            }
        }
    }
    $Chinaareacashbill[0][0]='其中：'.$Chinaareacashbill[0][0];
}

//获取收款单总额
//value：年份
function get_cashbill($year,$area=''){
    global $adb;
    if(!empty($area)){
         $addresssql=" and accountid in (SELECT accountid 
         from ld_account where bill_country in ('".$area."'))";
    }else{
        $addresssql=" and accountid in(SELECT accountid from ld_account)";
    }
    $sql="select SUM(ifnull(s.Total,0)) as total,MONTH(s.cashbilldate) AS s_month 
    from ld_cashbill as s where deleted=0 AND IFNULL(approvestatus,'')<>'已拒绝' AND YEAR(s.cashbilldate)=".$year.$addresssql." GROUP BY s_month ORDER BY s_month ASC";
    //echo $sql."<br>";
    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $total = $adb->query_result($result, $i, 'total');
        $month = $adb->query_result($result, $i, 's_month');
        $SaleList[$i][mtotal] = $total;
        $SaleList[$i][month] = $month;
    }
    //空月份加上0.00
    for($i = 1; $i < 13; $i++){
        $SaleLists[$i]='0.00';
        foreach($SaleList as $arr){
            if($i==$arr[month]){
                $SaleLists[$arr[month]] = $arr[mtotal];
                $SaleLists[total]+=$arr[mtotal];
            }
        }
        if(empty($SaleLists[total])){
            $SaleLists[total]="0.00";
        }
    }
    return $SaleLists;
}

//获取合同订单销售额
//value：年份,用户类型，区域
function get_year_sale($year,$atype='',$addresssale=''){
    global $adb;
    if(!empty($atype)){
        $atypesql=" and accountid in (SELECT accountid FROM ld_account WHERE account_type='".$atype."')";
    }
    
    if(!empty($addresssale)){
        $addresssql=" and accountid in(SELECT accountid 
        from ld_account where bill_country in ('".$addresssale."'))";
    }
    $sql="select SUM(ifnull(s.total,0)) as total,MONTH(s.signed_data) AS s_month 
    from ld_salesorder as s 
    where s.sostatus<>'已作废' and s.deleted=0 and IFNULL(s.approvestatus,'')<>'已拒绝' and s.stockpresence='全部出库' 
    and YEAR(s.signed_data)=".$year.$atypesql.$addresssql." 
    GROUP BY s_month ORDER BY s_month ASC";

    $result=$adb->pquery($sql,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $total = $adb->query_result($result, $i, 'total');
        $month = $adb->query_result($result, $i, 's_month');
        $SaleList[$i][mtotal] = $total;
        $SaleList[$i][month] = $month;
    }
    //空月份加上0.00
    for($i = 1; $i < 13; $i++){
        $SaleLists[$i]='0.00';
        foreach($SaleList as $arr){
            if($i==$arr[month]){
                $SaleLists[$arr[month]] = $arr[mtotal];
                $SaleLists[total]+=$arr[mtotal];
            }
        }
        if(empty($SaleLists[total])){
            $SaleLists[total]="0.00";
        }
    }
    return $SaleLists;
}

//页面赋值
$smarty->assign("YEAR",$year);//年
$smarty->assign("MONTH",$month);//月
$smarty->assign("TDTOTALHTML",$tdtotalhtml);
$smarty->assign("TDHTML",$tdhtml);
$smarty->assign("TDTOTALRIGHT",$tdtotalright);
$smarty->assign("TDRIGHT",$tdright);
$smarty->assign("SALETOTAL",getDecimalTwoVal($saletotal));//销售额合计
$smarty->assign("SALELIST",$SaleLists);//销售额
$smarty->assign("SALEADDLIST",$SaleAddList);//同比增长
$smarty->assign("ADDTOTAL",getDecimalTwoVal($addtotal));//同比增长合计
$smarty->assign("NEWSALE",$NewSale);//新单
$smarty->assign("NEWSALETOTAL",getDecimalTwoVal($newsaletotal));//新单合计
$smarty->assign("BACKSALE",$backSale);//返单
$smarty->assign("BACKSALETOTAL",getDecimalTwoVal($backsaletotal));//返单合计
$smarty->assign("NEWPERCENT",$newpercent);//新单占比累计
$smarty->assign("OLDPERCENT",$oldpercent);//返单占比累计
$smarty->assign("ATYPESALE",$a_type_sale);//用户类型
$smarty->assign("CASHBILLLIST",$cashbilllist);//资金回笼
$smarty->assign("CASHBILLTOTAL",getDecimalTwoVal($cashbilltotal));//资金回笼
$smarty->assign("CASHP",$cashp);//资金回笼占比
$smarty->assign("CASHBILLTOTALP",$cashbilltotalp);//资金回笼占比合计
$smarty->assign("CASHBILLTOTALCB",getDecimalTwoVal($cashbilltotalcb));//西北区占比累计
$smarty->assign("BALANCE",$Balances);//应收账款余额
$smarty->assign("BTOTAL",getDecimalTwoVal($btotal));//应收账款余额合计
$smarty->assign("CHINAAREA",$Chinaarea);//
$smarty->assign("CHINAAREACASHBILL",$Chinaareacashbill);//cashbill
$smarty->display('Comprehensivereport/RwCrmDetail.tpl');
exit();
?>