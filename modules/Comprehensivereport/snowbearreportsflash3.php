<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/FusionCharts/class/FusionCharts_Gen.php');
require_once("include/FusionCharts/class/FusionCharts.php");
require_once('Smarty_setup.php');
global $current_user;
$smarty=new lingdangCRM_Smarty;

if($_REQUEST['year']==''){
    $_REQUEST['year']=date("Y",strtotime($date));
}
//查看范围
$MonthName = array(
                    1  => '1',
                    2  => '2',
                    3  => '3',
                    4  => '4',
                    5  => '5',
                    6  => '6',
                    7  => '7',
                    8  => '8',
                    9  => '9',
                    10 =>'10',
                    11 => '11',
                    12 => '12'
                    );
$Customercategory=$_REQUEST['Customercategory'];
if($Customercategory!=''){
$whereproductSQL = " AND ld_products.productid = '$Customercategory' ";
///echo $Customercategory;
$smarty->assign("proname",$Customercategory);
}
$proList=getproductsheet();
$WinRate_Potentials_values = getSnowBearSbpccs($_REQUEST['year'],$whereproductSQL);
$WinRate_Potentials__salesorder_values = getSnowBearSbpccssalesorder($_REQUEST['year'],$whereproductSQL);

    foreach($WinRate_Potentials_values['month'] as $key2=>$arr2){
              $WinRate_Potentials_values['month'][$key2] = $WinRate_Potentials__salesorder_values['month'][$key2]!=0?$arr2/$WinRate_Potentials__salesorder_values['month'][$key2]:0;
    }
$img = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart($MonthName,$WinRate_Potentials_values);

$smarty->assign('year',$_REQUEST['year']);
$smarty->assign('proList',$proList);
$smarty->assign('WinRate_Potentials_values',$WinRate_Potentials_values);
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
$smarty->assign("IMG",$img);
$smarty->assign("NOW",$now);
$smarty->assign("reportname",'Productcustomerservicenumberfailurestatistics3');
$smarty->display('Comprehensivereport/snowbearreport.tpl');

function getSnowBearSbpccssalesorder($year,$whereproductSQL){
    global $adb;
    $SQL = "SELECT
	SUM(IFNULL(F2.T1, 0)) AS T1,
	SUM(IFNULL(F2.T2, 0)) AS T2,
	SUM(IFNULL(F2.T3, 0)) AS T3,
	SUM(IFNULL(F2.T4, 0)) AS T4,
	SUM(IFNULL(F2.T5, 0)) AS T5,
	SUM(IFNULL(F2.T6, 0)) AS T6,
	SUM(IFNULL(F2.T7, 0)) AS T7,
	SUM(IFNULL(F2.T8, 0)) AS T8,
	SUM(IFNULL(F2.T9, 0)) AS T9,
	SUM(IFNULL(F2.T10, 0)) AS T10,
	SUM(IFNULL(F2.T11, 0)) AS T11,
	SUM(IFNULL(F2.T12, 0)) AS T12,
	cf_1482,
	cf_1483,
	cf_1484
FROM
	(SELECT 
            case WHEN MONTH(ld_salesorder.signed_data)=1 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T1,
            case WHEN MONTH(ld_salesorder.signed_data)=2 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T2,
            case WHEN MONTH(ld_salesorder.signed_data)=3 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T3,
            case WHEN MONTH(ld_salesorder.signed_data)=4 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T4,
            case WHEN MONTH(ld_salesorder.signed_data)=5 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T5,
            case WHEN MONTH(ld_salesorder.signed_data)=6 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T6,
            case WHEN MONTH(ld_salesorder.signed_data)=7 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T7,
            case WHEN MONTH(ld_salesorder.signed_data)=8 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T8,
            case WHEN MONTH(ld_salesorder.signed_data)=9 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T9,
            case WHEN MONTH(ld_salesorder.signed_data)=10 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T10,
            case WHEN MONTH(ld_salesorder.signed_data)=11 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T11,
            case WHEN MONTH(ld_salesorder.signed_data)=12 THEN IFNULL(SUM(ld_salesorderdetail.quantity),0) ELSE 0 END as T12,
            cf_1482,cf_1483,cf_1484
            FROM ld_salesorder 
            LEFT JOIN ld_salesorderdetail ON ld_salesorder.salesorderid=ld_salesorderdetail.id
            LEFT JOIN ld_products ON ld_products.productid=ld_salesorderdetail.productid 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid            
            WHERE ld_products.deleted=0
            AND YEAR(ld_salesorder.signed_data)=$year AND ld_salesorder.deleted=0 $whereproductSQL
            GROUP BY MONTH(ld_salesorder.signed_data)) AS F2";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        for($c = 1; $c < 13; $c++){
           $productList['month'][$c] = $adb->query_result($result, $i, 't'.$c); 
        }
        $productList['line']['cf_1482'] = $adb->query_result($result, $i, 'cf_1482'); 
        $productList['line']['cf_1483'] = $adb->query_result($result, $i, 'cf_1483'); 
        $productList['line']['cf_1484'] = $adb->query_result($result, $i, 'cf_1484'); 
    }
    if($rowCount==0){
        for($c = 1; $c < 13; $c++){
           $productList['month'][$c] = 0; 
        }
        $SQL = "select cf_1482,cf_1483,cf_1484 from ld_products LEFT JOIN ld_productcf 
        ON ld_products.productid=ld_productcf.productid where 1=1 $whereproductSQL";        
        //echo $SQL;
        $result2=$adb->pquery($SQL,array());
        $productList['line']['cf_1482'] =  $adb->query_result($result2, 0, 'cf_1482'); 
        $productList['line']['cf_1483'] = $adb->query_result($result2, 0, 'cf_1483'); 
        $productList['line']['cf_1484'] = $adb->query_result($result2, 0, 'cf_1484'); 
    }
    return $productList;
}
function getSnowBearSbpccs($year,$whereproductSQL){
    global $adb;
    $SQL = "SELECT    
                ifnull(SUM(T1),0)*100 AS T1,
               	ifnull(SUM(T2),0)*100 AS T2,
               	ifnull(SUM(T3),0)*100 AS T3,
               	ifnull(SUM(T4),0)*100 AS T4,
               	ifnull(SUM(T5),0)*100 AS T5,
               	ifnull(SUM(T6),0)*100 AS T6,
               	ifnull(SUM(T7),0)*100 AS T7,
               	ifnull(SUM(T8),0)*100 AS T8,
               	ifnull(SUM(T9),0)*100 AS T9,
               	ifnull(SUM(T10),0)*100 AS T10,
               	ifnull(SUM(T11),0)*100 AS T11,
               	ifnull(SUM(T12),0)*100 AS T12,
                cf_1482,
                cf_1483,
                cf_1484
            FROM (
                SELECT 
				    CASE WHEN MONTH(ld_project.startdate) = 1 THEN ld_projectcf.cf_1478 END AS T1,
    				CASE WHEN MONTH(ld_project.startdate) = 2 THEN ld_projectcf.cf_1478 END AS T2,
    				CASE WHEN MONTH(ld_project.startdate) = 3 THEN ld_projectcf.cf_1478 END AS T3,
     			    CASE WHEN MONTH(ld_project.startdate) = 4 THEN ld_projectcf.cf_1478 END AS T4,
    				CASE WHEN MONTH(ld_project.startdate) = 5 THEN ld_projectcf.cf_1478 END AS T5,
    				CASE WHEN MONTH(ld_project.startdate) = 6 THEN ld_projectcf.cf_1478 END AS T6,
    				CASE WHEN MONTH(ld_project.startdate) = 7 THEN ld_projectcf.cf_1478 END AS T7,
    				CASE WHEN MONTH(ld_project.startdate) = 8 THEN ld_projectcf.cf_1478 END AS T8,
    				CASE WHEN MONTH(ld_project.startdate) = 9 THEN ld_projectcf.cf_1478 END AS T9,
    				CASE WHEN MONTH(ld_project.startdate) = 10 THEN ld_projectcf.cf_1478 END AS T10,
    				CASE WHEN MONTH(ld_project.startdate) = 11 THEN ld_projectcf.cf_1478 END AS T11,
    				CASE WHEN MONTH(ld_project.startdate) = 12 THEN ld_projectcf.cf_1478 END AS T12,
                    cf_1482,
                    cf_1483,
                    cf_1484
                FROM ld_project
                LEFT JOIN ld_projectcf ON ld_projectcf.projectid = ld_project.projectid
                LEFT JOIN ld_products ON ld_products.productid=ld_project.product_id 
                LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
                WHERE ld_project.deleted=0
                    AND YEAR(ld_project.startdate)=$year 
                    $whereproductSQL) as F1";
    //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        for($c = 1; $c < 13; $c++){
           $productList['month'][$c] = $adb->query_result($result, $i, 't'.$c); 
        }
        $productList['line']['cf_1482'] = $adb->query_result($result, $i, 'cf_1482'); 
        $productList['line']['cf_1483'] = $adb->query_result($result, $i, 'cf_1483'); 
        $productList['line']['cf_1484'] = $adb->query_result($result, $i, 'cf_1484'); 
    }
    if($rowCount==0){
        for($c = 1; $c < 13; $c++){
           $productList['month'][$c] = 0; 
        }
        $SQL = "select cf_1482,cf_1483,cf_1484 from ld_products LEFT JOIN ld_productcf 
        ON ld_products.productid=ld_productcf.productid where 1=1 $whereproductSQL";        
        //echo $SQL;
        $result2=$adb->pquery($SQL,array());
        $productList['line']['cf_1482'] =  $adb->query_result($result2, 0, 'cf_1482'); 
        $productList['line']['cf_1483'] = $adb->query_result($result2, 0, 'cf_1483'); 
        $productList['line']['cf_1484'] = $adb->query_result($result2, 0, 'cf_1484'); 
    }
    return $productList;
}
function getproductsheet(){
    global $adb;
    $SQL = "SELECT productid,productname FROM ld_products GROUP BY productid order by productname";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $productid=$adb->query_result($result, $i, 'productid');
        $proList[$productid] = $adb->query_result($result, $i, 'productname');
    }
    
    return $proList;
}

/*
andrew
20140514
HitRate报表拼接XML
*/
function chart($Months,$values){
    //print_r($values);
    $strXML ="<chart caption='故障占比图' numdivlines='4' showValues='0' numVDivLines='22' anchorRadius='2' labelDisplay='rotate' slantLabels='1' lineThickness='2' palette='4' xtLabelManagement='0'>";
    $strXML .="<categories font='Arial' fontSize='12' fontColor='000000'>";
    foreach($Months as $arr){
           $strXML .="<category label='".$arr."' />";
    }
    $strXML .="</categories>";
    $strXML .="<dataset seriesname='故障比'>";


    foreach($values['month'] as $key2=>$arr2){
                $strXML .="<set value ='".$arr2."'/>";
    }

    $strXML .="</dataset>";
    $strXML .="<dataset seriesname='高'>";
    
    foreach($Months as $arr){
                $strXML .="<set value ='".$values['line']['cf_1482']."'/>";
    }

    $strXML .="</dataset>";
    $strXML .="<dataset seriesname='中'>";

    foreach($Months as $arr){
                $strXML .="<set value ='".$values['line']['cf_1483']."'/>";
    }
 
    $strXML .="</dataset>";
    $strXML .="<dataset seriesname='低'>";

    foreach($Months as $arr){
                $strXML .="<set value ='".$values['line']['cf_1484']."'/>";
    }
    
    $strXML .="</dataset>"; 
    $strXML .="</chart>";

    return renderChartHTML("include/FusionCharts/FCF_MSLine.swf","",$strXML, "HitRate", 1000, 450);
}

?>