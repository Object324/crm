<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/FusionCharts/class/FusionCharts_Gen.php');
require_once("include/FusionCharts/class/FusionCharts.php");
require_once('Smarty_setup.php');
global $current_user;
$smarty=new lingdangCRM_Smarty;

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

$Report_form_query=$_REQUEST['Report_form_query'];
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
    $begin_month=1;$end_month=12;
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
$smarty->assign("YEAR",$year);

$productcategory = getproductcategory();
$cf_1471 = getcf_1471();
$cf_1472 = getcf_1472();


$productcategory2 = getproductcategory2();
$productcategoryvalue = $_REQUEST['productcategoryvalue'];
$smarty->assign("productcategoryvalue",$productcategoryvalue);
$smarty->assign("productcategory2",$productcategory2);
if($productcategoryvalue!=''){
   $productcategorySQL = " and productcategory = '$productcategoryvalue'"; 
}
$WinRate_values = getreportlist($productcategory,$cf_1471,$begin_date,$end_date);
$Wincash_values = getreportlist2($productcategory,$cf_1471,$begin_date,$end_date);
$Cityarea = getCityarea($begin_date,$end_date);
$AssetSize = getAssetSize($begin_date,$end_date);
$Cityarea2 = getCityarea2($begin_date,$end_date);
$AssetSize2 = getAssetSize2($begin_date,$end_date);
$qucunhua = getquhualv($cf_1471,$begin_date,$end_date);
$zupinbili = getzupinbili($cf_1471,$begin_date,$end_date);
$xiangmuquhua = getxiangmuquhua($cf_1472,$begin_date,$end_date,$productcategorySQL);

$colour = array('429EAD','4249AD','AD42A2','D4AC31','008900','E95D0F','1160B8','F2AC0C',
    'BF0000','A53838','7D8892','C3CACA','B2D2DD','507D9E','268926','2675B4','C91D1D','C2780D','0080C0'
    ,'008040','808080','800080','FF8040','FFFF00','FF0080');
$img = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart($colour,'全国存量资产各城市面积分布（单位：平米）',$Cityarea);
$img2 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart2($colour,'全国存量资产各城市面积分布（单位：平米）',$Cityarea);
$img3 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart3($colour,'全国存量资产各类面积分布（单位：平米）',$AssetSize);
$img4 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart4($colour,'全国存量资产各类面积分布（单位：平米）',$AssetSize);
$img5 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart($colour,'全国存量资产货值分布（单位：万元）',$Cityarea2);
$img6 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart2($colour,'全国存量资产货值分布（单位：万元）',$Cityarea2);
$img7 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart3($colour,'全国存量资产各类型货值分布（单位：万元）',$AssetSize2);
$img8 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart4($colour,'全国存量资产各类型货值分布（单位：万元）',$AssetSize2);
$img9 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart5('全国各城市存量年去化率(按所有可售资产计算）',$qucunhua);
$img10 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart5('各城市存量租赁比例表（按租赁）',$zupinbili);
$img11 = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart5('项目去化率表',$xiangmuquhua);

$smarty->assign('RETURN_MODULE',$_REQUEST['return_mypage']);
$smarty->assign('WinRate_values',$WinRate_values);
$smarty->assign('productcategory',$productcategory);
$smarty->assign('cf_1471',$cf_1471);
$smarty->assign('Wincash_values',$Wincash_values);
$smarty->assign('qucunhua',$qucunhua);
$smarty->assign('zupinbili',$zupinbili);
$smarty->assign('xiangmuquhua',$xiangmuquhua);

$smarty->assign("IMG",$img);
$smarty->assign("IMG2",$img2);
$smarty->assign("IMG3",$img3);
$smarty->assign("IMG4",$img4);
$smarty->assign("IMG5",$img5);
$smarty->assign("IMG6",$img6);
$smarty->assign("IMG7",$img7);
$smarty->assign("IMG8",$img8);
$smarty->assign("IMG9",$img9);
$smarty->assign("IMG10",$img10);
$smarty->assign("IMG11",$img11);
$smarty->assign("reportname",'全国资产面积汇总表（单位：平米）');

$smarty->display('Comprehensivereport/SummaryNationalAssetsAreaReports.tpl');
if(!empty($_REQUEST['return_mypage']) && $_REQUEST['return_mypage'] == 'home'){
	exit();
}


function getcf_1471(){
    global $adb;
   $SQL = 'SELECT cf_1471 FROM ld_cf_1471';
   $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        //$List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $cf_1471 = $adb->query_result($result, $i, 'cf_1471');
        $List[$cf_1471] = '';
    }
    
    return $List;
}
function getcf_1472(){
    global $adb;
   $SQL = 'SELECT cf_1472 FROM ld_productcf 
            INNER JOIN ld_products on ld_products.productid=ld_productcf.productid
            WHERE deleted=0 GROUP BY cf_1472;';
   $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
       $cf_1472 = $adb->query_result($result, $i, 'cf_1472');
        $List[$cf_1472] = '';
    }
    return $List;
}
function getproductcategory(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 10:52
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $List = array();
    foreach($result_pick as $key=>$value){
        $List[$value] = '';
    }
    return $List;

    /*global $adb;
   $SQL = 'SELECT productcategory FROM ld_productcategory';
   $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
       $productcategory = $adb->query_result($result, $i, 'productcategory');
        $List[$productcategory] = '';
    }
    return $List;*/
}
function getproductcategory2(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 10:54
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $proList = array_values($result_pick);
    return $proList;
       /* global $adb;
    $SQL = 'select productcategory from ld_productcategory';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $productList[$i]= $adb->query_result($result, $i, 'productcategory');
        }
    return $productList;*/
}
function getreportlist($productcategory,$cf_1471,$begin_date,$end_date){
    global $adb;
    $SQL = "SELECT cf_1471,productcategory,SUM(cf_1470) AS cf_1470 FROM ld_products 
            INNER JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and cf_1484 not in ('无','','异常') 
            and  createdtime GROUP BY cf_1471,productcategory";
	//BETWEEN '$begin_date' AND '$end_date'
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    }

    foreach($productcategory as $key=>$arr){
        $productcategory[$key]=$cf_1471;
    }

    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            foreach($List as $key3=>$arr3){
               // echo $arr3['cf_1471'].'-'.$key2.'|'.$arr3['cf_1473'].'-'.$key."<br>";
                if($arr3['cf_1471']==$key2&&$arr3['productcategory']==$key){
                    $productcategory[$key][$key2]=$arr3['cf_1470'];
                }
            }
        }
    }
    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            $productcategory['公司合计'][$key2]+=$productcategory[$key][$key2];
        }
    }
    
    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            $productcategory[$key]['总计']+=$arr2;
        }
    }

    return $productcategory;
}
function getreportlist2($productcategory,$cf_1471,$begin_date,$end_date){
    global $adb;
    $SQL = "SELECT cf_1471,productcategory,SUM(cf_1483) AS cf_1470 FROM ld_products 
            LEFT JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and cf_1484 not in ('无','','异常') 
            and  createdtime GROUP BY cf_1471,productcategory";
	//BETWEEN '$begin_date' AND '$end_date' 
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    } 

    foreach($productcategory as $key=>$arr){
        $productcategory[$key]=$cf_1471;
    }

    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            foreach($List as $key3=>$arr3){
               // echo $arr3['cf_1471'].'-'.$key2.'|'.$arr3['cf_1473'].'-'.$key."<br>";
                if($arr3['cf_1471']==$key2&&$arr3['productcategory']==$key){
                    $productcategory[$key][$key2]=$arr3['cf_1470'];
                }
            }
        }
    }
    
    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            
            $productcategory['公司合计'][$key2]+=$productcategory[$key][$key2];
        }
    }
    
    foreach($productcategory as $key=>$arr){
        foreach($arr as $key2=>$arr2){
            $productcategory[$key]['总计']+=$arr2;
        }
    }
    /*echo "<pre>";
    print_r($cf_1473);*/
    return $productcategory;
}
function getCityarea($begin_date,$end_date){
    global $adb;
    $SQL = "SELECT cf_1471,SUM(cf_1470) AS cf_1470 FROM ld_products 
            LEFT JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and cf_1471<>'' and cf_1484 not in ('无','','异常') 
            and  createdtime GROUP BY cf_1471";
			//BETWEEN '$begin_date' AND '$end_date' 
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    }

    return $List;
}
function getAssetSize($begin_date,$end_date){
    global $adb;
    $SQL = "SELECT productcategory,SUM(cf_1470) AS cf_1470 FROM ld_products 
            LEFT JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and productcategory<>'' and cf_1484 not in ('无','','异常') 
            and  createdtime 
            GROUP BY productcategory";
			//BETWEEN '$begin_date' AND '$end_date' 
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    }
    
    return $List;
}
function getCityarea2($begin_date,$end_date){
    global $adb;
    $SQL = "SELECT cf_1471,SUM(cf_1483) AS cf_1470 FROM ld_products 
            LEFT JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and cf_1471<>'' and cf_1484 not in ('无','','异常') 
            and  createdtime 
            GROUP BY cf_1471";//BETWEEN '$begin_date' AND '$end_date' 
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    }

    return $List;
}
function getAssetSize2($begin_date,$end_date){
    global $adb;
    $SQL = "SELECT productcategory,SUM(cf_1483) AS cf_1470 FROM ld_products 
            LEFT JOIN ld_productcf ON ld_productcf.productid=ld_products.productid 
            WHERE deleted=0 and cf_1484<>'已售' and productcategory<>'' and cf_1484 not in ('无','','异常') 
            and  createdtime 
            GROUP BY productcategory";//BETWEEN '$begin_date' AND '$end_date' 
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
    }
    
    return $List;
}

function getquhualv($cf_1471,$begin_date,$end_date){
       global $adb;
    $SQL = "select cf_1471,sum(count) as count from (SELECT
        	cf_1471,
        	sum(cf_1470) AS count
            FROM
        	ld_products
            LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
            WHERE
        	deleted = 0
            AND createdtime BETWEEN '$begin_date 00:00:00'
            AND '$end_date 23:59:59'
            AND cf_1471 <> ''
            GROUP BY
        	cf_1471
            UNION
            SELECT
        	cf_1471,
        	sum(cf_1470) AS count
            FROM
        	ld_products
            LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
            WHERE
        	deleted = 0
            AND createdtime < '$begin_date 00:00:00'
            AND cf_1471 <> ''
            GROUP BY
        	cf_1471) as tmp group by cf_1471
            ;";
    
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['count'] = $adb->query_result($result, $i, 'count');
    }
   
    foreach($cf_1471 as $key=>$arr){
        foreach($List as $key2=>$arr2){
            if($key==$arr2['cf_1471']){
                $cf_1471[$key]['cunliang']=$arr2['count'];
            }
        }
    }
	//当年去化
    $SQL = "SELECT ld_productcf.cf_1471,sum(ld_productcf.cf_1470) AS count from ld_salesorderdetail 
            LEFT JOIN ld_salesordercf on  ld_salesordercf.salesorderid  = ld_salesorderdetail.id
            LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id
            LEFT JOIN ld_products on ld_products.productid = ld_salesorderdetail.productid
            LEFT JOIN ld_productcf on ld_productcf.productid = ld_salesorderdetail.productid
            where ld_productcf.cf_1484 IN ('已售') AND ld_salesordercf.cf_1496 BETWEEN '$begin_date' AND '$end_date'
            AND ld_salesorder.deleted=0 AND ld_products.deleted=0 GROUP BY ld_productcf.cf_1471;";
          //  echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List2[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List2[$i]['count2'] = $adb->query_result($result, $i, 'count');
    }
    
    foreach($cf_1471 as $key=>$arr){
        foreach($List2 as $key2=>$arr2){
            if($key==$arr2['cf_1471']){
                $cf_1471[$key]['quhua']=$arr2['count2'];
            }
        }
    }
	//开始时间截止之前的去化值
    $SQL = "SELECT ld_productcf.cf_1471,sum(ld_productcf.cf_1470) AS count from ld_salesorderdetail 
            LEFT JOIN ld_salesordercf on  ld_salesordercf.salesorderid  = ld_salesorderdetail.id
            LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id
            LEFT JOIN ld_products on ld_products.productid = ld_salesorderdetail.productid
            LEFT JOIN ld_productcf on ld_productcf.productid = ld_salesorderdetail.productid
            where ld_salesordercf.cf_1496 < '$begin_date 00:00:00'
            AND ld_salesorder.deleted=0 AND ld_products.deleted=0 GROUP BY ld_productcf.cf_1471;";
	$result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
	for ($i = 0; $i < $rowCount; $i++) {
        $List3[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List3[$i]['count3'] = $adb->query_result($result, $i, 'count');
    }
	//当年产量+当年去化
	foreach($cf_1471 as $key=>$arr){
        foreach($List3 as $key2=>$arr2){
            if($key==$arr2['cf_1471']){
                $cf_1471[$key]['cunliang'] -= $arr2['count3'];
            }
        }
    }
    foreach($cf_1471 as $key=>$arr){
        if($arr['quhua']==''){
          $arr['quhua']=0;  
          $cf_1471[$key]['quhua']=0; 
        }
        if($arr['cunliang']==''){
            $arr['cunliang']=0;
            $cf_1471[$key]['cunliang']=0; 
        }
        
        $cf_1471[$key]['quhuabili']=round($arr['quhua']/$arr['cunliang'],2);
        if($cf_1471[$key]['quhuabili']=='')$cf_1471[$key]['quhuabili']=0;
    }

    return $cf_1471; 
}
function getzupinbili($cf_1471,$begin_date,$end_date){
       global $adb;
    $SQL = "SELECT cf_1471,sum(cf_1470) AS count FROM ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE deleted=0 and cf_1484 IN ('待售租','已租','保留') GROUP BY cf_1471;";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['count'] = $adb->query_result($result, $i, 'count');
    }
   
    foreach($cf_1471 as $key=>$arr){
        foreach($List as $key2=>$arr2){
            if($key==$arr2['cf_1471']){
                $cf_1471[$key]['cunliang']=$arr2['count'];
            }
        }
    }
    $SQL = "SELECT cf_1471,sum(cf_1470) AS count FROM ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE deleted=0 and cf_1484 IN ('已租') GROUP BY cf_1471;";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List2[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List2[$i]['count2'] = $adb->query_result($result, $i, 'count');
    }
    
    foreach($cf_1471 as $key=>$arr){
        foreach($List2 as $key2=>$arr2){
            if($key==$arr2['cf_1471']){
                $cf_1471[$key]['quhua']=$arr2['count2'];
            }
        }
    }
    foreach($cf_1471 as $key=>$arr){
        if($arr['quhua']==''){
          $arr['quhua']=0;  
          $cf_1471[$key]['quhua']=0; 
        }
        if($arr['cunliang']==''){
            $arr['cunliang']=0;
            $cf_1471[$key]['cunliang']=0; 
        }
        
        $cf_1471[$key]['quhuabili']=round($arr['quhua']/$arr['cunliang'],2);
        if($cf_1471[$key]['quhuabili']=='')$cf_1471[$key]['quhuabili']=0;
    }

    return $cf_1471; 
}

function getxiangmuquhua($cf_1472,$begin_date,$end_date,$productcategorySQL){
           global $adb;
    $SQL = "SELECT cf_1472,sum(cf_1470) AS count FROM ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE deleted=0 $productcategorySQL and cf_1484 IN ('待租','已租','待售','待售租','已售') GROUP BY cf_1472;";
	//echo $SQL . '<br>';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1472'] = $adb->query_result($result, $i, 'cf_1472');
        $List[$i]['count'] = $adb->query_result($result, $i, 'count');
    }
   
    foreach($cf_1472 as $key=>$arr){
        foreach($List as $key2=>$arr2){
            if($key==$arr2['cf_1472']){
                $cf_1472[$key]['cunliang']=$arr2['count'];
            }
        }
    }
    $SQL = "SELECT cf_1472,sum(cf_1470) AS count FROM ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE deleted=0 $productcategorySQL and cf_1484 IN ('已售') GROUP BY cf_1472;";
		//echo $SQL . '<br>';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $List2[$i]['cf_1472'] = $adb->query_result($result, $i, 'cf_1472');
        $List2[$i]['count2'] = $adb->query_result($result, $i, 'count');
    }
    
    foreach($cf_1472 as $key=>$arr){
        foreach($List2 as $key2=>$arr2){
            if($key==$arr2['cf_1472']){
                $cf_1472[$key]['quhua']=$arr2['count2'];
            }
        }
    }
    foreach($cf_1472 as $key=>$arr){
        if($arr['quhua']==''){
          $arr['quhua']=0;  
          $cf_1472[$key]['quhua']=0; 
        }
        if($arr['cunliang']==''){
            $arr['cunliang']=0;
            $cf_1472[$key]['cunliang']=0; 
        }
        
        $cf_1472[$key]['quhuabili']=round($arr['quhua']/$arr['cunliang'],2);
        if($cf_1472[$key]['quhuabili']=='')$cf_1472[$key]['quhuabili']=0;
    }
    foreach($cf_1472 as $key=>$arr){
        if($arr['quhua']==0)unset($cf_1472[$key]);
    }

    return $cf_1472; 
}
/*
andrew
20140514
HitRate报表拼接XML
*/
function chart($colour,$reportname,$values){
    $strXML ="<chart caption='".$reportname."' showPercentageInLabel='1' showValues='1' showLabels='0' showLegend='1' showPercentValues='1'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['cf_1470']."' label='".$arr['cf_1471']."' color='".$colour[$key]."'/>";
    }
    $strXML .="</chart>";
    //echo $strXML;die;
    return renderChartHTML("include/FusionCharts/Pie2D.swf","",$strXML, "WinRate", 450, 450);
}

function chart2($colour,$reportname,$values){
    $strXML ="<chart caption='".$reportname."' 
     bgColor='F1F1F1' showValues='1' canvasBorderThickness='1' canvasBorderColor='999999' 
     plotFillAngle='330' plotBorderColor='999999' showAlternateVGridColor='1' divLineAlpha='0'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['cf_1470']."' label='".$arr['cf_1471']."' color='".$colour[$key]."'/>";
    }
    $strXML .="</chart>";
    //echo $strXML;die;
    return renderChartHTML("include/FusionCharts/Bar2D.swf","",$strXML, "WinRate", 450, 450);
}

function chart3($colour,$reportname,$values){
    $strXML ="<chart caption='".$reportname."' showPercentageInLabel='1' showValues='1' showLabels='0' showLegend='1' showPercentValues='1'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['cf_1470']."' label='".$arr['productcategory']."' color='".$colour[$key]."'/>";
    }
    $strXML .="</chart>";
    //echo $strXML;die;
    return renderChartHTML("include/FusionCharts/Pie2D.swf","",$strXML, "WinRate", 450, 450);
}

function chart4($colour,$reportname,$values){
    $strXML ="<chart caption='".$reportname."' 
     bgColor='F1F1F1' showValues='1' canvasBorderThickness='1' canvasBorderColor='999999' 
     plotFillAngle='330' plotBorderColor='999999' showAlternateVGridColor='1' divLineAlpha='0'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['cf_1470']."' label='".$arr['productcategory']."' color='".$colour[$key]."'/>";
    }
    $strXML .="</chart>";
    //echo $strXML;die;
    return renderChartHTML("include/FusionCharts/Bar2D.swf","",$strXML, "WinRate", 450, 450);
}

function chart5($reportname,$values){
    $strXML ="<chart palette='1' caption='".$reportname."' showLabels='1' showvalues='1'  sYAxisValuesDecimals='2' connectNullData='0'   numDivLines='4' formatNumberScale='0'>";
    $strXML .='<categories>';
    foreach($values as $key=>$arr){
           $strXML .="<category label='".$key."' />";
    }
    $strXML .='</categories>';
    $strXML .="<dataset seriesName='当年存量' color='AFD8F8' showValues='0'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['cunliang']."' />";
    }
    $strXML .='</dataset>';
    $strXML .="<dataset seriesName='当年去化' color='F6BD0F' showValues='0'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['quhua']."' />";
    }
    $strXML .='</dataset>';
    $strXML .="<dataset seriesName='去化比例' color='8BBA00' showValues='1' parentYAxis='S'>";
    foreach($values as $key=>$arr){
           $strXML .="<set value='".$arr['quhuabili']."' />";
    }
    $strXML .='</dataset>';
    $strXML .="</chart>";
    //echo $strXML;die;
    return renderChartHTML("include/FusionCharts/MSColumn3DLineDY.swf","",$strXML, "WinRate", '100%', 450);
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
?>