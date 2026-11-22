<?php
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();

$cf_1471=getcf_1471();
$cf_1471value = $_REQUEST['cf_1471value'];
$smarty->assign("cf_1471value",$cf_1471value);
$smarty->assign("cf_1471",$cf_1471);
if($cf_1471value!=''){
   $cf_1471SQL = " and ld_productcf.cf_1471 = '$cf_1471value'"; 
}

$cf_1472=getcf_1472();
$cf_1472value = $_REQUEST['cf_1472value'];
$smarty->assign("cf_1472value",$cf_1472value);
$smarty->assign("cf_1472",$cf_1472);
if($cf_1472value!=''){
   $cf_1472SQL = " and ld_productcf.cf_1472 like '%$cf_1472value%'"; 
}

$productcategory=getproductcategory();
$productcategoryvalue = $_REQUEST['productcategoryvalue'];
$smarty->assign("productcategoryvalue",$productcategoryvalue);
$smarty->assign("productcategory",$productcategory);
if($productcategoryvalue!=''){
   $productcategorySQL = " and ld_products.productcategory = '$productcategoryvalue'"; 
}

$user_id = $current_user->id;
$user_array=Array();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
require('user_privileges/user_language_'.$current_user->id.'.php');

$SearchScope = "";
$MergeSmowner=getCurSmOwnerSearchScope('Comprehensivereport');
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
            $query .= " and  ld_products.smownerid in ( ".$SearchScope.")";
        break;
        case 'SmOwner_Search_Me':
           $query .=" and ld_products.smownerid=".$current_user->id;
           $user_id=0;
        break;
        case 'SmOwner_Search_Create':
            $query .=" and ld_products.smcreatorid=".$current_user->id;
            $user_id=0;
        break;
        case 'smowner_search_senior':
            $query .=" and ld_products.smownerid in ( ".$_REQUEST['selectuserid'].")";
            $user_id=0;
            break;
        default:
          $query .= " and ld_products.smownerid=".$scope;
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
$cf_1484=$_REQUEST['cf_1484'];
$smarty->assign('cf_1484',$cf_1484);
$s2="'".implode("','",$cf_1484)."'";

if($s2!=''){
    $query.=" and cf_1484 in ($s2) ";
}
$listValue=getsnowbearCsnostofa($cf_1471SQL,$cf_1472SQL,$productcategorySQL,$query);
$allValue = $listValue['ALL'];
unset($listValue['ALL']);
$smarty->assign("allValue",$allValue);
if($_REQUEST['export']=='yes'){

    include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array('城市','项目名称','资产类型','资产总数量','资产总原值(万元)','资产总市值（万元）','建筑总面积/平米');
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
foreach($listValue as $key=>$arr){
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($v).($key+2),$arr2); 
       $v++;
    }
}

$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk','Report'));
$objPHPExcel->getActiveSheet()->setTitle('Report');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

$objWriter->save('storage/Report.xls');   

 //下载文件

 $file_name="Report.xls";
 $file_dir="storage/";

$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
}
function getsnowbearCsnostofa($cf_1471SQL,$cf_1472SQL,$productcategorySQL,$query){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT cf_1471,cf_1472,productcategory,COUNT(1) AS zccount,SUM(cf_1482) AS cf_1482,
            SUM(cf_1483) AS cf_1483,SUM(cf_1470) AS cf_1470
            FROM ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid
            where 1=1 $cf_1471SQL $cf_1472SQL $productcategorySQL $query
             and ld_products.deleted = 0  and cf_1484 not in ('无','','异常')
            GROUP BY cf_1471,cf_1472,productcategory 
            ORDER BY  
            CONVERT (cf_1471 USING gbk) COLLATE gbk_chinese_ci ,
            CONVERT (cf_1472 USING gbk) COLLATE gbk_chinese_ci ,
            CONVERT (productcategory USING gbk) COLLATE gbk_chinese_ci ;";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['cf_1472'] = $adb->query_result($result, $i, 'cf_1472');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['zccount'] = $adb->query_result($result, $i, 'zccount');
        $List[$i]['cf_1482'] = setNumberFormat($adb->query_result($result, $i, 'cf_1482'),4);
        $List[$i]['cf_1483'] = setNumberFormat($adb->query_result($result, $i, 'cf_1483'),4);
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
        $List['ALL']['zccount'] += $adb->query_result($result, $i, 'zccount');
        $List['ALL']['cf_1482'] += $adb->query_result($result, $i, 'cf_1482');
        $List['ALL']['cf_1483'] += $adb->query_result($result, $i, 'cf_1483');
        $List['ALL']['cf_1470'] += $adb->query_result($result, $i, 'cf_1470');
    }
  //print_r($List);
    return $List;
}

function getcf_1471(){
        global $adb;
    $SQL = 'select cf_1471 from ld_cf_1471';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $productList[$i]= $adb->query_result($result, $i, 'cf_1471');
        }

    return $productList;
}

function getcf_1472(){
        global $adb;
    $SQL = 'select cf_1472 from ld_cf_1472';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $productList[$i]= $adb->query_result($result, $i, 'cf_1472');
        }

    return $productList;
}

function getproductcategory(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 10:23
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $productList = array_values($result_pick);
    return $productList;
        /*global $adb;
    $SQL = 'select productcategory from ld_productcategory';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $productList[$i]= $adb->query_result($result, $i, 'productcategory');
        }
    return $productList;*/
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
$smarty->display('Comprehensivereport/StockAssetSummaryReports.tpl');
exit();
?>