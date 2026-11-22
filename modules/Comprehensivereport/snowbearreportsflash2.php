<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('include/FusionCharts/class/FusionCharts_Gen.php');
require_once("include/FusionCharts/class/FusionCharts.php");
require_once('Smarty_setup.php');
global $current_user;
$smarty=new lingdangCRM_Smarty;
if($_REQUEST['year2']!=''&&$_REQUEST['year']==''){
    $_REQUEST['year']=$_REQUEST['year2']+1;
}

if($_REQUEST['year']!=''&&$_REQUEST['year2']==''){
    $_REQUEST['year2']=$_REQUEST['year']-1;
}
if($_REQUEST['year2']==''&&$_REQUEST['year']==''){
    $_REQUEST['year']=date("Y",strtotime($date));
    $_REQUEST['year2']=date("Y",strtotime($date))-1;
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

$cf_1475list = getcf_1475();

$admissibilitytype=$_REQUEST['admissibilitytype'];
$smarty->assign('admissibilitytype',$admissibilitytype);
$smarty->assign('cf_1475list',$cf_1475list);
if($admissibilitytype!=''){
    $whereSQL=" and ld_projectcf.cf_1475 = '$admissibilitytype'";
}
$WinRate_Potentials_values = getSnowBearSbpccs($_REQUEST['year'],'',$whereSQL);
$WinRate_values = getSnowBearSbpccs($_REQUEST['year2'],'',$whereSQL);
foreach($WinRate_values as $key=>$arr){
    $values[$key] = setNumberFormat(($WinRate_Potentials_values[$key]-$arr)/$arr*100).'%';
}
$img = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart($MonthName,$WinRate_Potentials_values,$WinRate_values,$_REQUEST['year'],$_REQUEST['year2']);
//print_r(getSnowBearSbpccs($_REQUEST['year'],1,$whereSQL));
$smarty->assign('year2',$_REQUEST['year2']);
$smarty->assign('year',$_REQUEST['year']);
$smarty->assign('values',$values);
$smarty->assign('WinRate_Potentials_values',$WinRate_Potentials_values);
$smarty->assign('WinRate_values',$WinRate_values);
$smarty->assign('total',getSnowBearSbpccs($_REQUEST['year'],1,$whereSQL));
$smarty->assign('total2',getSnowBearSbpccs($_REQUEST['year2'],1,$whereSQL));
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
$smarty->assign("reportname",'Productcustomerservicenumberfailurestatistics2');
$smarty->display('Comprehensivereport/snowbearreport.tpl');

function getcf_1475(){
    global $adb;
    $SQL = "SELECT cf_1475 FROM ld_cf_1475";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'cf_1475');
    }
    
    return $proList;
}

//Edit by luyx 2016-09-06
//产品售后故障汇总表（售后故障次数统计）：次数按单据“处理数量”统计
function getSnowBearSbpccs($year,$ctype='',$whereSQL=''){
    global $adb;
    $SQL = "SELECT
                	ifnull(SUM(T1),0) AS T1,
                	ifnull(SUM(T2),0) AS T2,
                	ifnull(SUM(T3),0) AS T3,
                	ifnull(SUM(T4),0) AS T4,
                	ifnull(SUM(T5),0) AS T5,
                	ifnull(SUM(T6),0) AS T6,
                	ifnull(SUM(T7),0) AS T7,
                	ifnull(SUM(T8),0) AS T8,
                	ifnull(SUM(T9),0) AS T9,
                	ifnull(SUM(T10),0) AS T10,
                	ifnull(SUM(T11),0) AS T11,
                	ifnull(SUM(T12),0) AS T12
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
           				CASE WHEN MONTH(ld_project.startdate) = 12 THEN ld_projectcf.cf_1478 END AS T12
                    FROM ld_project 
                    LEFT JOIN ld_projectcf ON ld_projectcf.projectid = ld_project.projectid 
                    WHERE YEAR(ld_project.startdate) = $year
                        AND ld_project.deleted = 0 
                        $whereSQL) AS F1";
    //echo $SQL."<br><br>";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        for($c = 1; $c < 13; $c++){
           $productList[$c] = $adb->query_result($result, $i, 't'.$c); 
           $total += $adb->query_result($result, $i, 't'.$c);
        }
    }
    //print_r($productList);
    if($rowCount==0){
         for($c = 1; $c < 13; $c++){
           $productList[$c] = 0; 
        }
    }
    if($ctype!=''){
        return $total==''?'0.0':$total;
    }else{
        return $productList;
    }

}


/*
andrew
20140514
HitRate报表拼接XML
*/
function chart($Months,$values,$lastvalue,$year,$year2){
    $strXML ="<chart palette='2' caption='小白熊报表' xaxisname='月份' shownames='1'  showvalues='0'   sYAxisValuesDecimals='2' connectNullData='0' PYAxisName=''   numDivLines='4' formatNumberScale='0'>";
    $strXML .="<categories font='Arial' fontSize='12' fontColor='000000'>";
    foreach($Months as $arr){
           $strXML .="<category label='".$arr."' />";
    }
    $strXML .="</categories>";
    $strXML .="<dataset seriesName='$year2' color='1476BF' showValues='0'>";
    foreach($lastvalue as $key2=>$arr2){
           $strXML .="<set value ='".$arr2."' />";
    }
    $strXML .="</dataset>";
    $strXML .="<dataset seriesName='$year' color='C00000' showValues='0'>";
    foreach($values as $key2=>$arr2){
           $strXML .="<set value ='".$arr2."' />";
    }
    $strXML .="</dataset>";
    $strXML .="</chart>";
    return renderChartHTML("include/FusionCharts/MSColumn3DLineDY.swf","",$strXML, "WinRate", 1000, 450);
}

?>