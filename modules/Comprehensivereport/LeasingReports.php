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
//本日，昨日，本周，本月，时间获取
$todayselect=  date('Y-m-d',time());
$yesterdayselect=  date("Y-m-d",time()-24*60*60); 
$week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
$week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));     
$month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));    
$month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
//本年
$begin_this_year=date('Y-01-01');
$end_this_year=date('Y-12-31');

$basicfilterHtml .="<a class='changeday' id='today1' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
<a id='yesterday1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
<a id='week1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
<a id='month1' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
<a id='year1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
<a id='all1' class='changeday' href=\"javascript:void(0);\" onclick=\"changedaytime(this,'all','2000-01-01','$end_this_year')\">".getFixedLabel('ALL')."</a>"; 
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
    $begin_date = "";
    $begin_date = $month_begin;
    $end_date = "";
    $end_date = $month_end;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("basicfilterHtml",$basicfilterHtml);


$cf_1471=getcf_1471();
$cf_1471value = $_REQUEST['cf_1471value'];
$smarty->assign("cf_1471value",$cf_1471value);
$smarty->assign("cf_1471",$cf_1471);
if($cf_1471value!=''){
   $cf_1471SQL = " and f1.cf_1471 = '$cf_1471value'"; 
}

$cf_1472=getcf_1472();
$cf_1472value = $_REQUEST['cf_1472value'];
$smarty->assign("cf_1472value",$cf_1472value);
$smarty->assign("cf_1472",$cf_1472);
if($cf_1472value!=''){
   $cf_1472SQL = " and f1.cf_1472 like '%$cf_1472value%'"; 
}

$productcategory=getproductcategory();
$productcategoryvalue = $_REQUEST['productcategoryvalue'];
$smarty->assign("productcategoryvalue",$productcategoryvalue);
$smarty->assign("productcategory",$productcategory);
if($productcategoryvalue!=''){
   $productcategorySQL = " and f1.productcategory = '$productcategoryvalue'"; 
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
            $query .= " and  smownerid in ( ".$SearchScope.")";
        break;
        case 'SmOwner_Search_Me':
           $query .=" and smownerid=".$current_user->id;
           $user_id=0;
        break;
        case 'SmOwner_Search_Create':
            $query .=" and smcreatorid=".$current_user->id;
            $user_id=0;
        break;
        case 'smowner_search_senior':
            $query .=" and smownerid in ( ".$_REQUEST['selectuserid'].")";
            $user_id=0;
            break;
        default:
          $query .= " and smownerid=".$scope;
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

$contract_no = $_REQUEST['contract_no'];
$smarty->assign("contract_no",$contract_no);
if($_REQUEST['contract_no']!=''){
   $contract_nosql = " and contract_no like '%$contract_no%'"; 
}
$cf_1545 = $_REQUEST['cf_1545'];
$smarty->assign("cf_1545",$cf_1545);
if($_REQUEST['cf_1545']!=''){
   $cf_1545sql = " and cf_1545 like '%$cf_1545%'"; 
}
$listValue=getValuelist($begin_date,$end_date,$cf_1471SQL,$cf_1472SQL,$productcategorySQL,$query,$contract_nosql,$cf_1545sql);
$listValueAll=$listValue['all'];
unset($listValue['all']);
$smarty->assign("listValueAll",$listValueAll);
if($_REQUEST['type']=='export'){

    include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array('城市','项目名称','资产类型','租赁合同编号','权利人','客户名称',
'房地坐落','建筑面积/平米','服务开始日期','服务到期日','计划回款日期','计划回款金额/元','已收金额/元','收款状态','应收款余额/元');
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
function getValuelist($begin_date,$end_date,$cf_1471SQL,$cf_1472SQL,$productcategorySQL,$query,$contract_nosql,$cf_1545sql){
    global $adb; 
    //echo $useridSQL;
            $SQL = "SELECT
        	servicecontractsid,
        	ld_paymentplan.paymentplanid,
        	cf_1471,
        	cf_1472,
        	productcategory,
        	contract_no,
        	cf_1545,
        	accountname,
        	productname,
        	cf_1470,
        	servicecontracts_start_date,
        	servicecontracts_end_date,
        	ld_paymentplan.plandate,
        	ld_paymentplan.amount,
        	IFNULL(total,0) AS total,
        	cf_1569,
        	cashbilldate,
        	paymentstatus,smcreatorid,smownerid,
        	IFNULL(ld_paymentplan.amount,0)-IFNULL(grouptotal,0) AS yskye
        FROM
        	(
        		SELECT
        			ld_servicecontracts.servicecontractsid,
        			ld_servicecontractsdetail.productid,
        			cf_1471,
        			cf_1472,
        			productcategory,
        			contract_no,
        			cf_1545,
        			accountname,
        			productname,
        			cf_1470,
        			servicecontracts_start_date,
        			servicecontracts_end_date,
        			quantity,
        			taxprice,ld_servicecontracts.smownerid,ld_servicecontracts.smcreatorid
        		FROM
        			ld_servicecontracts
        		LEFT JOIN ld_servicecontractscf ON ld_servicecontractscf.servicecontractsid = ld_servicecontracts.servicecontractsid
        		INNER JOIN ld_servicecontractsdetail ON ld_servicecontractsdetail.id = ld_servicecontracts.servicecontractsid
        		LEFT JOIN ld_account ON ld_account.accountid = ld_servicecontracts.accountid
        		LEFT JOIN ld_products ON ld_servicecontractsdetail.productid = ld_products.productid
        		LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid 
        		WHERE
        			ld_servicecontracts.deleted = 0 GROUP BY ld_servicecontracts.servicecontractsid
        	) AS f1
        LEFT JOIN (
        	SELECT
        		paymentplanid,
        		entitytypeid,
        		plandate,
        		amount,
        		paymentstatus
        	FROM
        		ld_paymentplan
        	WHERE
        		ld_paymentplan.deleted = 0
        ) AS ld_paymentplan ON f1.servicecontractsid = ld_paymentplan.entitytypeid
        LEFT JOIN (
        	SELECT
        		ld_cashbill2paymentplan.entitytypeid AS salesorderid,
        		ld_cashbill2paymentplan.amount AS total,
        		cf_1569,
        		cashbilldate,
        		paymentplanid
        	FROM
        		ld_cashbill
        	LEFT JOIN ld_cashbillscf ON ld_cashbill.cashbillid = ld_cashbillscf.cashbillid
        	LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
        	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
        	WHERE
        		ld_cashbill.deleted = 0
        	AND ld_cashbill2paymentplan.amount > 0
        	AND ld_cashbill.cashbillid > 0
        ) AS f2 ON f2.paymentplanid = ld_paymentplan.paymentplanid
        LEFT JOIN(
        	SELECT
        		SUM(IFNULL(ld_cashbill2paymentplan.amount,0)) AS grouptotal,
        		paymentplanid
        	FROM
        		ld_cashbill
        	LEFT JOIN ld_cashbillscf ON ld_cashbill.cashbillid = ld_cashbillscf.cashbillid
        	LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
        	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
        	WHERE
        		ld_cashbill.deleted = 0
        	AND ld_cashbill2paymentplan.amount > 0
        	AND ld_cashbill.cashbillid > 0
        	GROUP BY paymentplanid
        ) AS f3 ON f3.paymentplanid=ld_paymentplan.paymentplanid
        where 1=1 and ld_paymentplan.plandate BETWEEN '$begin_date' AND '$end_date' 
        $cf_1471SQL $cf_1472SQL $productcategorySQL $query $contract_nosql $cf_1545sql
        ORDER BY
         CONVERT (cf_1471 USING gbk) COLLATE gbk_chinese_ci ,
        	CONVERT (cf_1472 USING gbk) COLLATE gbk_chinese_ci ,
            CONVERT (productcategory USING gbk) COLLATE gbk_chinese_ci ,
            CONVERT (plandate USING gbk) COLLATE gbk_chinese_ci ;";
   //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {
        $List[$i]['servicecontractsid'] = $adb->query_result($result, $i, 'servicecontractsid');
        $List[$i]['paymentplanid'] = $adb->query_result($result, $i, 'paymentplanid');
        $List[$i]['cf_1471'] = $adb->query_result($result, $i, 'cf_1471');
        $List[$i]['cf_1472'] = $adb->query_result($result, $i, 'cf_1472');
        $List[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $List[$i]['contract_no'] = $adb->query_result($result, $i, 'contract_no');
        $List[$i]['cf_1545'] = $adb->query_result($result, $i, 'cf_1545');
        $List[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $List[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $List[$i]['cf_1470'] = $adb->query_result($result, $i, 'cf_1470');
        $List[$i]['servicecontracts_start_date'] = $adb->query_result($result, $i, 'servicecontracts_start_date');
        $List[$i]['servicecontracts_end_date'] = $adb->query_result($result, $i, 'servicecontracts_end_date');
        $List[$i]['plandate'] = $adb->query_result($result, $i, 'plandate');
        $List[$i]['amount'] = $adb->query_result($result, $i, 'amount');
        $List[$i]['total'] = $adb->query_result($result, $i, 'total');
        $List[$i]['paymentstatus'] = $adb->query_result($result, $i, 'paymentstatus');
        $List[$i]['yskye'] = $adb->query_result($result, $i, 'yskye');
    }
    foreach($List as $key=>$arr){
        if($paymentplanid != $arr['paymentplanid'] && $arr['paymentplanid'] > 0){
            $List['all']['amount']+=$arr['amount'];
            $List['all']['yskye']+=$arr['yskye'];
        }
        
        $List['all']['cf_1470']+=$arr['cf_1470'];
        $List['all']['total']+=$arr['total'];
        
        
         unset($List[$key]['servicecontractsid']);
         unset($List[$key]['paymentplanid']);
        $paymentplanid = $arr['paymentplanid'];
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
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 9:43
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $productList = array_values($result_pick);
      /*  global $adb;
    $SQL = 'select productcategory from ld_productcategory';
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
        for ($i = 0; $i < $rowCount; $i++) {
            $productList[$i]= $adb->query_result($result, $i, 'productcategory');
        }*/
    return $productList;
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

if($Report_form_query == 'true'){
    $smarty->display('Comprehensivereport/LeasingReportscontent.tpl');
}else{
    $smarty->display('Comprehensivereport/LeasingReports.tpl');
}
exit();
?>