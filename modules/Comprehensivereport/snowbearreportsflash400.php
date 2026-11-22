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


$WinRate_Potentials_values = getSnowBearSbpccs($_REQUEST['year']);
$WinRate_values = getSnowBearSbpccs($_REQUEST['year2']);
foreach($WinRate_values as $key=>$arr){
    $values[$key] = setNumberFormat(($WinRate_Potentials_values[$key]-$arr)/$arr*100).'%';
}
$img = "<div id='WinRate' style='width:100%;height:100%;padding-left:-5px;'></div>".chart($MonthName,$WinRate_Potentials_values,$WinRate_values,$_REQUEST['year'],$_REQUEST['year2']);

$smarty->assign('year2',$_REQUEST['year2']);
$smarty->assign('year',$_REQUEST['year']);
$smarty->assign('values',$values);
$smarty->assign('WinRate_Potentials_values',$WinRate_Potentials_values);
$smarty->assign('WinRate_values',$WinRate_values);
$smarty->assign('total',getSnowBearSbpccs($_REQUEST['year'],1));
$smarty->assign('total2',getSnowBearSbpccs($_REQUEST['year2'],1));
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
$smarty->assign("reportname",'Summary400hotlinesinglestatistics');
$smarty->display('Comprehensivereport/snowbearreport.tpl');


function getSnowBearSbpccs($year,$ctype=''){
    global $adb;
    $SQL = "SELECT SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12
             FROM (SELECT 
            case WHEN MONTH(ld_contactrecords.createdtime)=1 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T1,
            case WHEN MONTH(ld_contactrecords.createdtime)=2 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T2,
            case WHEN MONTH(ld_contactrecords.createdtime)=3 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T3,
            case WHEN MONTH(ld_contactrecords.createdtime)=4 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T4,
            case WHEN MONTH(ld_contactrecords.createdtime)=5 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T5,
            case WHEN MONTH(ld_contactrecords.createdtime)=6 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T6,
            case WHEN MONTH(ld_contactrecords.createdtime)=7 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T7,
            case WHEN MONTH(ld_contactrecords.createdtime)=8 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T8,
            case WHEN MONTH(ld_contactrecords.createdtime)=9 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T9,
            case WHEN MONTH(ld_contactrecords.createdtime)=10 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T10,
            case WHEN MONTH(ld_contactrecords.createdtime)=11 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T11,
            case WHEN MONTH(ld_contactrecords.createdtime)=12 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T12
            FROM ld_contactrecords 
            WHERE YEAR(ld_contactrecords.createdtime)=$year AND ld_contactrecords.deleted=0
            GROUP BY MONTH(ld_contactrecords.createdtime)) AS F1";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        for($c = 1; $c < 13; $c++){
           $productList[$c] = $adb->query_result($result, $i, 't'.$c); 
           $total += $adb->query_result($result, $i, 't'.$c);
        }
    }
    
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