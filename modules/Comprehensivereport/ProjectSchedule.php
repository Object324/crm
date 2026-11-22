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
//print_r($_REQUEST);
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
$where='where 1=1 ';
$subject = $_REQUEST['subject'];
if($subject!=''){
    $where .=' and subject like "%'.$subject.'%"';
}


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
if(!isset($_REQUEST['Report_form_query']) && $_REQUEST['Report_form_query']=="") 
{
    $scope= 'SmOwner_Search_All';
}else{
    $scope = $_REQUEST['SmOwnerSearchScope'];
}


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
            $where .= " and  ld_salesorder.smownerid in ( ".$SearchScope.")";
        break;
        case 'SmOwner_Search_Me':
           $where .=" and ld_salesorder.smownerid=".$current_user->id;
        break;
        case 'SmOwner_Search_Create':
            $where .=" and ld_salesorder.smcreatorid=".$current_user->id;
        break;
        case 'smowner_search_senior':
            $where .=" and ld_salesorder.smownerid in ( ".$_REQUEST['selectuserid'].")";
            break;
        default:
           $where .= " and  ld_salesorder.smownerid in ( ".$scope.")";
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



$listValue=getlistvalue($where,$begin_date,$end_date);
if($_REQUEST['type']=='export'){

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'合同名称','材料成本明细金额','','','','','','','',
'人工费申请明细金额','','费用报销明细金额','','其他费用单明细金额','',
);
$listValue_header2=array(
'','产品名称','产品编号','产品类别','规格型号','出库数量','出库单价','出库金额','计量单位',
'施工说明','人工费金额','人工费用未付金额','报销人','报销金额合计','其他费用类别','金额',
);
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
foreach($listValue_header2 as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'2',$arr);
}
$activesheet->mergeCells('A1:A2');
$activesheet->mergeCells('B1:I1');
$activesheet->mergeCells('J1:L1');
$activesheet->mergeCells('M1:N1');
$activesheet->mergeCells('O1:P1');
/*echo '<pre>';
print_r($listValue);die;*/
foreach($listValue as $key=>$arr){  
    if($key==='合计'){
        $key=count($listValue)-1;
    }
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($v).($key+3),$arr2,PHPExcel_Cell_DataType::TYPE_STRING); 
       //$activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+($i*$page_count)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
       
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
function getlistvalue($where,$begin_date,$end_date){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT DISTINCT
            	ld_salesorder.salesorderid,
            	SUBJECT,
            	productname,
            	product_no,
            	ld_products.productcategory,
            	productsheet,
            	IFNULL(
            		ld_outboundorder.quantity,
            		0
            	) AS quantity,
            	IFNULL(
            		ld_outboundorder2.taxprice,
            		0
            	) AS outboundorder_taxprice,
            	IFNULL(
            		ld_outboundorder.quantity * ld_outboundorder.taxprice,
            		0
            	) AS taxprice,
            	usageunit,
            	solution,
            	IFNULL(fees, 0) AS fees,
            	last_name,
            	IFNULL(ld_expense.total, 0) AS expense_total,
            	commissiontype,
            	IFNULL(ld_commission.taxprice, 0) AS commisson_taxprice,
            	IFNULL(ld_potential.amount,0)-IFNULL(fees, 0) AS rengongweifu
            FROM
            	ld_salesorder
            LEFT JOIN ld_potential ON ld_salesorder.potentialid=ld_potential.potentialid
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
            LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
            LEFT JOIN (
            	SELECT
            			IFNULL(quantity, 0) * IFNULL(ld_stock.taxprice, 0)
            		 AS taxprice,
            		ld_outboundorderdetail.entitytypeid,ld_outboundorderdetail.productid
            	FROM
            		ld_outboundorder
            	LEFT JOIN ld_outboundorderdetail ON ld_outboundorderdetail.id = ld_outboundorder.out_id
            	LEFT JOIN (
            		SELECT
            			productid,
            			SUM(taxprice * quantity) / SUM(quantity) AS taxprice
            		FROM
            			ld_stock
            		LEFT JOIN ld_stockdetail ON ld_stockdetail.id = ld_stock.stock_id
            		WHERE
            			ld_stock.deleted = 0
            		AND ld_stock.presence = '已入库'
            		GROUP BY
            			productid
            	) AS ld_stock ON ld_stock.productid = ld_outboundorderdetail.productid
            	WHERE
            		ld_outboundorder.presence = '已出库'
            	AND ld_outboundorder.deleted = 0
            	AND ld_outboundorderdetail.entitytypeid <> 0
            	GROUP BY
            		ld_outboundorderdetail.entitytypeid,ld_outboundorderdetail.productid
            ) AS ld_outboundorder2 ON ld_salesorder.salesorderid = ld_outboundorder2.entitytypeid and 
            ld_salesorderdetail.productid=ld_outboundorder2.productid            
            LEFT JOIN (
            	SELECT
            		entitytypeid,
            		sum(quantity) as quantity,
            		sum(taxprice) as taxprice,productid
            	FROM
            		ld_outboundorder
            	LEFT JOIN ld_outboundorderdetail ON ld_outboundorderdetail.id = ld_outboundorder.out_id
            	WHERE
            		ld_outboundorder.deleted = 0 
            	AND ld_outboundorder.presence = '已出库' GROUP BY entitytypeid,productid
            ) AS ld_outboundorder ON ld_salesorder.salesorderid = ld_outboundorder.entitytypeid
            and ld_salesorderdetail.productid = ld_outboundorder.productid
            LEFT JOIN (
            	SELECT
            		salesorderid,
            		SUM(fees) AS fees,
            		solution
            	FROM
            		ld_troubletickets
            	WHERE
            		deleted = 0 and approvestatus='已批准'
            	GROUP BY
            		salesorderid
            ) AS ld_troubletickets ON ld_troubletickets.salesorderid = ld_salesorder.salesorderid
            LEFT JOIN (
            	SELECT
            		Salesorderid,
            		total,
            		last_name,
                    ld_approvelog.createdtime
            	FROM
            		ld_expense
                LEFT JOIN ld_approvelog ON ld_expense.expenseid=ld_approvelog.crmid 
            	LEFT JOIN ld_users ON ld_expense.smownerid = ld_users.id
            	WHERE
            		ld_expense.deleted = 0 and ld_expense.approvestatus='已批准'
            ) AS ld_expense ON ld_expense.Salesorderid = ld_salesorder.salesorderid
            LEFT JOIN (
            	SELECT
            		SUM(amount) AS taxprice,
            		entitytypeid,
            		commissiontype
            	FROM
            		ld_commission
            	LEFT JOIN ld_commission2payment ON ld_commission2payment.commission_id = ld_commission.commission_id
            	WHERE
            		deleted = 0 and approvestatus='已批准'
            	GROUP BY
            		entitytypeid
            ) AS ld_commission ON ld_commission.entitytypeid = ld_salesorder.salesorderid
            $where and signed_data BETWEEN '$begin_date' AND '$end_date'
            and	ld_salesorder.deleted = 0  and ld_salesorder.approvestatus='已批准'
            ORDER BY
            	salesorderid DESC,ld_expense.createdtime;";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');
        $list[$i]['SUBJECT'] = $adb->query_result($result, $i, 'subject');
        $list[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $list[$i]['product_no'] = $adb->query_result($result, $i, 'product_no');
        $list[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $list[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $list[$i]['quantity'] = $adb->query_result($result, $i, 'quantity');
        $list[$i]['outboundorder_taxprice'] = $adb->query_result($result, $i, 'outboundorder_taxprice');
        $list[$i]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
        $list[$i]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $list[$i]['solution'] = $adb->query_result($result, $i, 'solution');
        $list[$i]['fees'] = $adb->query_result($result, $i, 'fees');
        $list[$i]['rengongweifu'] = $adb->query_result($result, $i, 'rengongweifu');
        $list[$i]['last_name'] = $adb->query_result($result, $i, 'last_name');
        $list[$i]['expense_total'] = $adb->query_result($result, $i, 'expense_total');
        $list[$i]['commissiontype'] = $adb->query_result($result, $i, 'commissiontype');
        $list[$i]['commisson_taxprice'] = $adb->query_result($result, $i, 'commisson_taxprice');
        
    }
    foreach($list as $key=>$arr){
        if($list[$key]['salesorderid']==$list[$key+1]['salesorderid']){
            /*$list[$key+1]['SUBJECT']='';
            //$list[$key+1]['quantity']='';
            //$list[$key+1]['outboundorder_taxprice']='';
            //$list[$key+1]['taxprice']='';
            $list[$key+1]['solution']='';
            $list[$key+1]['fees']='';
            $list[$key+1]['last_name']='';
            $list[$key+1]['expense_total']='';
            $list[$key+1]['commissiontype']='';
            $list[$key+1]['commisson_taxprice']='';*/
        }
    }
    for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['SUBJECT'] = '合计金额';
        $list['合计']['productname'] = '';
        $list['合计']['product_no'] = '';
        $list['合计']['productcategory'] = '';
        $list['合计']['productsheet'] = '';
        if($list[$i]['salesorderid']!=$list[$i-1]['salesorderid']){
            $list['合计']['quantity'] += $list[$i]['quantity'];
            
            $list['合计']['taxprice'] += $list[$i]['taxprice'];  
        }
        //$list['合计']['outboundorder_taxprice'] += $list[$i]['outboundorder_taxprice'];
        $list['合计']['outboundorder_taxprice'] = '';
        $list['合计']['usageunit'] = '';
        $list['合计']['solution'] = '';
        $list['合计']['fees'] += $list[$i]['fees'];
        $list['合计']['rengongweifu'] += $list[$i]['rengongweifu'];
        $list['合计']['last_name'] = '';
        $list['合计']['expense_total'] += $list[$i]['expense_total'];
        $list['合计']['commissiontype'] = '';
        $list['合计']['commisson_taxprice'] += $list[$i]['commisson_taxprice'];
    }
    foreach($list as $key=>$arr){
        $list[$key]['quantity'] = $arr['quantity']!=''?setNumberFormat($arr['quantity']):'';
        $list[$key]['outboundorder_taxprice'] = $arr['outboundorder_taxprice']!=''?setNumberFormat($arr['outboundorder_taxprice']):'';
        $list[$key]['taxprice'] = $arr['taxprice']!=''?setNumberFormat($arr['taxprice']):'';
        $list[$key]['fees'] = $arr['fees']!=''?setNumberFormat($arr['fees']):'';
        $list[$key]['rengongweifu'] = $arr['rengongweifu']!=''?setNumberFormat($arr['rengongweifu']):'';
        $list[$key]['expense_total'] = $arr['expense_total']!=''?setNumberFormat($arr['expense_total']):'';
        $list[$key]['commisson_taxprice'] = $arr['commisson_taxprice']!=''?setNumberFormat($arr['commisson_taxprice']):'';
        unset($list[$key]['salesorderid']);
    }
      //print_r($productList);  
    return $list;
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

if($Report_form_query == 'true')
    $smarty->display('Comprehensivereport/ProjectSchedulecontent.tpl');
else
    $smarty->display('Comprehensivereport/ProjectSchedule.tpl');
exit();
?>