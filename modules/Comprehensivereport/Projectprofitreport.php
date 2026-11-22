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
foreach($listValue as $key=>$arr){
        unset($listValue[$key]['salesorderid']);
    }
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$listValue_header=array(
'合同签约日期','合同名称','合同金额','已收款','未收款','材料成本汇总金额','人工费金额','人工费用未付金额','费用报销金额',
'其他费用单金额','费用合计金额','税金','毛利','毛利率%'
);
foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}

/*echo '<pre>';
print_r($listValue);die;*/
foreach($listValue as $key=>$arr){  
    if($key==='合计'){
        $key=count($listValue)-1;
    }
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($v).($key+2),$arr2,PHPExcel_Cell_DataType::TYPE_STRING); 
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
    $SQL = "SELECT
                ld_salesorder.salesorderid,    
            	signed_data,
            	SUBJECT,
            	IFNULL(ld_salesorder.total, 0) AS total,
            	IFNULL(ld_cashbill.total, 0) AS yishou,
            	IFNULL(ld_salesorder.total, 0) - IFNULL(ld_cashbill.total, 0) AS weishou,
            	IFNULL(
            		ld_outboundorder.taxprice,
            		0
            	) AS taxprice,
            	IFNULL(fees, 0) AS fees,
            	IFNULL(ld_expense.total, 0) AS expense_total,
            	IFNULL(ld_commission.taxprice, 0) AS commisson_taxprice,
            	IFNULL(
            		ld_outboundorder.taxprice,
            		0
            	) + IFNULL(fees, 0) + IFNULL(ld_expense.total, 0) + IFNULL(ld_commission.taxprice, 0) AS feiyongheji,
            	IFNULL(ld_salesorder.total, 0) * IFNULL(cf_1531, 0)/100 AS taxamount,
            	IFNULL(ld_salesorder.total, 0) - (
            		IFNULL(
            			ld_outboundorder.taxprice,
            			0
            		) + IFNULL(fees, 0) + IFNULL(ld_expense.total, 0) + IFNULL(ld_commission.taxprice, 0)
            	) - (
            		IFNULL(ld_salesorder.total, 0) * IFNULL(cf_1531, 0)/100
            	) AS maoli,
            	IFNULL(
            		(
            			IFNULL(ld_salesorder.total, 0) - (
            				IFNULL(
            					ld_outboundorder.taxprice,
            					0
            				) + IFNULL(fees, 0) + IFNULL(ld_expense.total, 0) + IFNULL(ld_commission.taxprice, 0)
            			) - (
            				IFNULL(ld_salesorder.total, 0) * IFNULL(cf_1531, 0)/100
            			)
            		) / IFNULL(ld_salesorder.total, 0) * 100,
            		0
            	) AS maolilv,
                IFNULL(ld_potentialscf.cf_1478*10000,0)-IFNULL(fees, 0) AS rengongweifu
            FROM
            	ld_salesorder
            INNER JOIN ld_salesordercf ON ld_salesordercf.salesorderid = ld_salesorder.salesorderid
            LEFT JOIN ld_potential ON ld_salesorder.potentialid=ld_potential.potentialid
            LEFT JOIN ld_potentialscf ON ld_potentialscf.potentialid=ld_potential.potentialid
            LEFT JOIN (
            	SELECT
            		ld_cashbill2paymentplan.entitytypeid AS salesorderid,
            		sum(
            
            			IF (
            				ld_cashbill.currency_id > 1,
            				ld_cashbill2paymentplan.amount / ld_cashbill.conversion_rate,
            				ld_cashbill2paymentplan.amount
            			)
            		) AS total
            	FROM
            		ld_cashbill
            	LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid
            	LEFT JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_cashbill2paymentplan.entitytypeid
            	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.servicecontractsid = ld_cashbill2paymentplan.entitytypeid
            	WHERE
            		ld_cashbill.deleted = 0
            	AND ld_cashbill2paymentplan.amount > 0
            	AND ld_cashbill.cashbillid > 0 and ld_cashbill.checkoutstatus='已审核'
            	GROUP BY
            		ld_cashbill2paymentplan.entitytypeid
            ) AS ld_cashbill ON ld_cashbill.salesorderid = ld_salesorder.salesorderid
            LEFT JOIN (
            	SELECT
            		SUM(
            			IFNULL(quantity, 0) * IFNULL(ld_stock.taxprice, 0)
            		) AS taxprice,
            		a.entitytypeid
            	FROM
            	   (SELECT DISTINCT
                		ld_outboundorder.out_id,
                		ld_outboundorder.presence,
                		ld_outboundorder.deleted,
                		ld_outboundorderdetail.entitytypeid
                		FROM
                			ld_outboundorder
                		LEFT JOIN ld_outboundorderdetail ON ld_outboundorderdetail.id = ld_outboundorder.out_id
                		where ld_outboundorderdetail.entitytypeid<>0) AS a 
                    LEFT JOIN ld_outboundorderdetail b ON a.out_id=b.id
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
            	) AS ld_stock ON ld_stock.productid = b.productid                                      
            WHERE
          		a.presence = '已出库'
            	AND a.deleted = 0
            	GROUP BY
           		   a.entitytypeid
            ) AS ld_outboundorder ON ld_salesorder.salesorderid=ld_outboundorder.entitytypeid
            LEFT JOIN (
            	SELECT
            		salesorderid,
            		SUM(fees) AS fees
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
            		sum(total) as total,
                    ld_approvelog.createdtime
            	FROM
            		ld_expense 
					LEFT JOIN (SELECT * FROM (SELECT crmid,createdtime from ld_approvelog  ORDER BY createdtime DESC) AS cc GROUP BY crmid) AS ld_approvelog                    
					ON ld_expense.expenseid=ld_approvelog.crmid 
            	WHERE
            		deleted = 0 and approvestatus='已批准'
                         	GROUP BY Salesorderid      
            ) AS ld_expense ON ld_expense.Salesorderid = ld_salesorder.salesorderid
            LEFT JOIN (
            	SELECT
            		SUM(amount) AS taxprice,
            		entitytypeid
            	FROM
            		ld_commission
            	LEFT JOIN ld_commission2payment ON ld_commission2payment.commission_id = ld_commission.commission_id
            	WHERE
            		deleted = 0 and approvestatus='已批准'
            	GROUP BY
            		entitytypeid
            ) AS ld_commission ON ld_commission.entitytypeid = ld_salesorder.salesorderid
             $where and signed_data BETWEEN '$begin_date' AND '$end_date'
            and	ld_salesorder.deleted = 0  ORDER BY signed_data DESC,ld_expense.createdtime;";
          //  echo $SQL."<br>"; and ld_salesorder.approvestatus='已批准'
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['salesorderid'] = $adb->query_result($result, $i, 'salesorderid');        
        $list[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $list[$i]['SUBJECT'] = $adb->query_result($result, $i, 'subject');
        $list[$i]['total'] = $adb->query_result($result, $i, 'total');
        $list[$i]['yishou'] = $adb->query_result($result, $i, 'yishou');
        $list[$i]['weishou'] = $adb->query_result($result, $i, 'weishou');
        $list[$i]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
        $list[$i]['fees'] = $adb->query_result($result, $i, 'fees');
        $list[$i]['rengongweifu'] = $adb->query_result($result, $i, 'rengongweifu');
        $list[$i]['expense_total'] = $adb->query_result($result, $i, 'expense_total');
        $list[$i]['commisson_taxprice'] = $adb->query_result($result, $i, 'commisson_taxprice');
        $list[$i]['feiyongheji'] = $adb->query_result($result, $i, 'feiyongheji');
        $list[$i]['taxamount'] = $adb->query_result($result, $i, 'taxamount');
        $list[$i]['maoli'] = $adb->query_result($result, $i, 'maoli');
        $list[$i]['maolilv'] = $adb->query_result($result, $i, 'maolilv');
        
    }
    
     for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['signed_data'] = '合计金额';
        $list['合计']['SUBJECT'] = '';
        if($list[$i]['salesorderid']!=$list[$i-1]['salesorderid']){
            $list['合计']['total'] += $list[$i]['total'];
            $list['合计']['yishou'] += $list[$i]['yishou'];
            $list['合计']['weishou'] += $list[$i]['weishou'];  
        }
        $list['合计']['taxprice'] += $list[$i]['taxprice'];
        $list['合计']['fees'] += $list[$i]['fees'];
        $list['合计']['rengongweifu'] += $list[$i]['rengongweifu'];
        $list['合计']['expense_total'] += $list[$i]['expense_total'];
        $list['合计']['commisson_taxprice'] += $list[$i]['commisson_taxprice'];
        $list['合计']['feiyongheji'] += $list[$i]['feiyongheji'];
        $list['合计']['taxamount'] += $list[$i]['taxamount'];
        $list['合计']['maoli'] += $list[$i]['maoli'];
        $list['合计']['maolilv'] ='';
    }
   /* foreach($list as $key=>$arr){
        unset($list[$key]['salesorderid']);
    }*/
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
    $smarty->display('Comprehensivereport/Projectprofitreportcontent.tpl');
else
    $smarty->display('Comprehensivereport/Projectprofitreport.tpl');

exit();
?>