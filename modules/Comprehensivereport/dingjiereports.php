<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
require_once('include/utils/UserInfoUtil.php');
require_once('page.php');
$smarty=new lingdangCRM_Smarty();

    include './user_privileges/dingjie.inc.php';// 配置文件
    include './mssql/SqlServer.php';
    //Sql Server登录信息
    $user = $conf['db']['user'];
    $pwd = $conf['db']['pwd'];
    $hostname = $conf['db']['host'];
    $databasename = $conf['db']['db'];
    //链接Sql Server数据库

    $SqlCon = new SqlServer($user,$pwd,$databasename,$hostname);
    $conResult = $SqlCon->Connect();
    
if($_REQUEST['year']!=''){
    $wherebegindate=$_REQUEST['year'].'0101';
    $whereenddate=$_REQUEST['year'].'1231';
    $begin_date=$_REQUEST['year'].'-01-01';
    $end_date=$_REQUEST['year'].'-12-31';
    $type=1;
}else{
    $begin_dateget=$_REQUEST['begin_date'];
    $begin_end_date_arr=explode(' ',$_REQUEST['begin_date']);            
    $begin_date=trim($begin_end_date_arr[0]);
    $begin_dates=explode('-',$begin_date);
    
    $end_date=trim($begin_end_date_arr[2]);
    $end_dates=explode('-',$end_date);
    $wherebegindate = $begin_dates[0].$begin_dates[1].$begin_dates[2];
    $whereenddate = $end_dates[0].$end_dates[1].$end_dates[2];
    $begin_date=$begin_dates[0].'-'.$begin_dates[1].'-'.$begin_dates[2];
    $end_date=$end_dates[0].'-'.$end_dates[1].'-'.$end_dates[2];
     $type=0;
}
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("begin_dateget",$begin_dateget);
$accountname=strtolower($_REQUEST['accountname']);

$salesno=$_REQUEST['salesno'];
$username=$_REQUEST['username'];
$ajaxExport=$_REQUEST['ajaxExport'];
$search_text=$_REQUEST['search_text'];
if($search_text!=''){
    $prolisgs = explode(',',$search_text);
    $prolisg = implode("','",$prolisgs);
    $whereusername = " AND CMSMV.MV002 in ('$prolisg') ";
    $smarty->assign("receiverid",$search_text);
    $smarty->assign("receiverid_array",$prolisgs);
}else{
	$whereusername=" and 1<>1 ";
}
if($_REQUEST['page']){
    $page=$_REQUEST['page'];
}else{
    $page=1;
}
$smarty->assign("salesno",$salesno);
$smarty->assign("accountname",$accountname);
$smarty->assign("username",$username);

$ulist = getUserNameids();
$smarty->assign("ulist",$ulist);

    $listcounts = getcount($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$whereusername,$type);
    if($ajaxExport==''){
    $listvalue = getReport($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$whereusername,$type,$page);
    }
    $listvalueall = getReportall($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$whereusername,$type);


if($_REQUEST['ajaxExport']=='yes'){
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

					$listValue_header = array(
								'业务员',
                                '订单日期',
                                '客户',
                                '订单号码',
								'品名',
								'品号',
								'数量',
								'币种',
								'汇率',
								'单价',
								'杂费/佣金',
								'金额',
								'销售金额',
								'外贸税率',
								'成本单价',
								'成本合计',
                                '税率折价',
							);
foreach($listValue_header as $key=>$arr){
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
//print_r($listvalueall);die;
$listvalueall2=array(
            '总金额',
            $listvalueall['amount'],
            '毛利率',
            $listvalueall['price']*100,
            '杂费合计',
            $listvalueall['com'],
            '总成本',
            $listvalueall['subtotal'],
            '总税率折价',
            $listvalueall['discount']
);
foreach($listvalueall2 as $key=>$arr){
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'2',$arr);
}
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('storage/Report.xls');  
//print_r($listvalue['list']);die;
//echo ceil($listcounts/2);die;
for($i=0;$i<=ceil($listcounts/500);$i++){
$listvalue = getReport($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$whereusername,$type,$i);
foreach($listvalue['list'] as $key=>$arr){
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($v).(($key+3)+(($i-1)*500)),$arr2); 
       //echo (($key+2)+(($i-1)*2))."-".$i.'<br>';
       $v++;
    }
}


$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk','Report'));
$objPHPExcel->getActiveSheet()->setTitle('Report');


$objWriter->save('storage/Report.xls');   
}
 //下载文件
//die;
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
//print_r($listvalueall);
$smarty->assign("listvalueall",$listvalueall);
//分页
$params = array(
            'total_rows'=>$listcounts,
            'method'    =>'html',
            'parameter' =>"index.php?module=Comprehensivereport&action=dingjiereports&Report_form_query=true&ReportHeader=dheader&begin_date=$begin_dateget&accountname=$accountname&search_text=$search_text&salesno=$salesno",  #(必须)
            'now_page'  =>$page, 
            'list_rows' =>500,
);

$page = new Core_Lib_Page($params);


$smarty->assign("page_arr",$page->show(1));

//主搜索方法
function getReport($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$usernamewhere,$type,$page){
    $accountname=convert2gbk($accountname);
    $salesno=convert2gbk($salesno);
    $usernamewhere=convert2gbk($usernamewhere);
   // if($ajaxExport==''){
        $limitpagebegin=($page-1)*500;
        $limitpageend=$page*500;
      $wherelimit = " where T.RowNum>$limitpagebegin and T.RowNum<=$limitpageend";
   // }

    if($accountname!=''){
        $accountnamewhere=" and LOWER(COPMA.MA003) like LOWER('%$accountname%')";
    }
    if($salesno!=''){
        $salesnowhere=" and COPTC.TC001 + '+' + COPTC.TC002 like '%$salesno%'";
    }
    if($wherebegindate!=''&&$type!=1){
        $datewhere=" and COPTC.TC003 >= '$wherebegindate' and COPTC.TC003<='$whereenddate'";
    }else{
        $datewhere=" and 1<>1";
    }

					$header = array(
								'username'=>'业务员',
                                'salesdate'=>'订单日期',
                                'accountname'=>'客户',
                                'salesno'=>'订单号码',
								'productname'=>'品名',
								'productsheet'=>'品号',
								'num'=>'数量',
								'currency'=>'币种',
								'conversion_rate'=>'汇率',
								'price'=>'单价',
								'com'=>'杂费/佣金',
								'amount'=>'金额',
								'total'=>'销售金额',
								'tax'=>'外贸税率',
								'unit_price'=>'成本单价',
								'subtotal'=>'成本合计',
                                'discount'=>'税率折价',
								'packing'=>'包装方式',
								'snumber'=>'序列号',
								'logo'=>'客户LOGO',
                                'mmode'=>'打标方式',
							);
    $query = "select * from (
            SELECT  ROW_NUMBER() Over(order by COPTC.TC001,COPTC.TC002) as RowNum, 
            CMSMV.MV001 AS smownername,
            CMSMV.MV002 AS username,
            CONVERT(VARCHAR,CAST(COPTC.TC003 AS DATETIME),23) AS salesdate,
            COPMA.MA003 AS accountname,
            COPTC.TC001 + '+' + COPTC.TC002 AS salesno,
            COPTC.TC008 AS currency,
            COPTC.TC009 AS conversion_rate,
            ISNULL(COPTC.UDF57,0.00)+ISNULL(COPTC.UDF58,0.00) AS com,
            COPTD.TD005 AS productname,
            COPTD.TD004 AS productsheet,
            COPTD.TD008 AS num,
            COPTD.TD011 AS price,
            COPTD.TD008*COPTD.TD011 AS amount,
            COPTD.TD008*COPTD.TD011*COPTC.TC009 AS total,
            
            CASE 
            WHEN COPTC.TC001=2201  THEN COPTD.TD037 
            WHEN COPTC.TC001=2202  THEN COPTD.UDF58 
            ELSE COPTD.UDF58 END AS tax, 

            
            COPTD.UDF59 AS unit_price,
            
            
            COPTD.UDF59*COPTD.TD008 AS subtotal,
            
			CASE COPTC.TC001 WHEN 2202 THEN COPTD.TD012*COPTC.TC009*(1-COPTD.UDF58) 
            ELSE COPTD.TD012*COPTC.TC009*(1-COPTD.TD037) END AS discount,
            COPTD.UDF01 AS packing,COPTD.UDF02 AS snumber,COPTD.UDF03 AS logo,COPTD.UDF04 AS mmode
	
            FROM COPTC								
            LEFT JOIN COPTD ON COPTC.TC001=COPTD.TD001 AND COPTC.TC002=COPTD.TD002
            LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001
            LEFT JOIN CMSMV ON COPTC.TC006=CMSMV.MV001 
            LEFT JOIN INVMB ON INVMB.MB001=COPTD.TD004 where 1=1 
			$accountnamewhere $salesnowhere $datewhere $usernamewhere ) as T $wherelimit";
           
           //echo $query;
				$result = $SqlCon->Query_result($query);
				$rows = $SqlCon->num_rows($result); 
        for($i=0;$i<$rows;$i++){
				$order = $SqlCon->fetch_object($result);
				foreach($header as $fld=>$val){
                $order[$fld] = iconv('GBK','UTF-8',$order[$fld]);
				$listview_entrie['list'][$i][$fld] = $order[$fld];
				}
                $listview_entrie['all']['amount']+=$order['amount'];
                $listview_entrie['all']['com']+=$order['com'];
                $listview_entrie['all']['subtotal']+=$order['subtotal'];
                $listview_entrie['all']['price']+=($order['discount']-$order['com']-($order['subtotal']))/$order['discount'];
                $listview_entrie['all']['discount']+=$order['discount'];
        }
       //print_r($listview_entrie);
    return $listview_entrie;
}
function getcount($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$usernamewhere,$type){
    $accountname=convert2gbk($accountname);
    $salesno=convert2gbk($salesno);
     $usernamewhere=convert2gbk($usernamewhere);
    if($accountname!=''){
        $accountnamewhere=" and LOWER(COPMA.MA003) like '%$accountname%'";
    }
    if($salesno!=''){
        $salesnowhere=" and COPTC.TC001 + '+' + COPTC.TC002 like '%$salesno%'";
    }
    if($wherebegindate!=''&&$type!=1){
        $datewhere=" and COPTC.TC003 >= '$wherebegindate' and COPTC.TC003<='$whereenddate'";
    }else{
        $datewhere=" and 1<>1";
    }


    $query = "SELECT 
            count(1) as listcounts
            FROM COPTC								
            LEFT JOIN COPTD ON COPTC.TC001=COPTD.TD001 AND COPTC.TC002=COPTD.TD002
            LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001
            LEFT JOIN CMSMV ON COPTC.TC006=CMSMV.MV001
            LEFT JOIN INVMB ON INVMB.MB001=COPTD.TD004 where 1=1 $accountnamewhere $salesnowhere $datewhere $usernamewhere";
           //echo $query;
				$result = $SqlCon->Query_result($query);
				$order = $SqlCon->fetch_object($result);
                 $listcounts=$order['listcounts'];
       
    return $listcounts;
}
function getReportall($SqlCon,$wherebegindate,$whereenddate,$accountname,$salesno,$usernamewhere,$type,$page){
    $accountname=convert2gbk($accountname);
    $salesno=convert2gbk($salesno);
     $usernamewhere=convert2gbk($usernamewhere);
        $limitpagebegin=($page-1)*3;
        $limitpageend=$page*3;
    if($accountname!=''){
        $accountnamewhere=" and LOWER(COPMA.MA003) like '%$accountname%'";
    }
    if($salesno!=''){
        $salesnowhere=" and COPTC.TC001 + '+' + COPTC.TC002 like '%$salesno%'";
    }
    if($wherebegindate!=''&&$type!=1){
        $datewhere=" and COPTC.TC003 >= '$wherebegindate' and COPTC.TC003<='$whereenddate'";
    }else{
        $datewhere=" and 1<>1";
    }

    $query = "SELECT 
            SUM(ISNULL(COPTC.UDF57,0.00)+ISNULL(COPTC.UDF58,0.00)) AS com,
            SUM(COPTD.TD008*COPTD.TD011*COPTC.TC009) AS amount,
            SUM(COPTD.UDF59*COPTD.TD008) AS subtotal, 
            SUM(CASE COPTC.TC001 WHEN 2202 THEN COPTD.TD012*COPTC.TC009*(1-COPTD.UDF58) 
            ELSE COPTD.TD012*COPTC.TC009*(1-COPTD.TD037) END) AS discount  
            FROM COPTC								
            LEFT JOIN COPTD ON COPTC.TC001=COPTD.TD001 AND COPTC.TC002=COPTD.TD002
            LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001
            LEFT JOIN CMSMV ON COPTC.TC006=CMSMV.MV001
            LEFT JOIN INVMB ON INVMB.MB001=COPTD.TD004 where 1=1 $accountnamewhere $salesnowhere $datewhere $usernamewhere";
           
           //echo $query;
				$result = $SqlCon->Query_result($query);
				$rows = $SqlCon->num_rows($result); 
        for($i=0;$i<$rows;$i++){
				$order = $SqlCon->fetch_object($result);
                $listview_entrie['amount']=$order['amount'];
                $listview_entrie['subtotal']=$order['subtotal'];
                $listview_entrie['price']=($order['discount']-$order['com']-($order['subtotal']))/$order['discount'];
                $listview_entrie['discount']=$order['discount'];
        }
        $query = "select sum(com) as com from (SELECT distinct   COPTC.TC001 + '+' + COPTC.TC002 as num2,
            ISNULL(COPTC.UDF57,0.00)+ISNULL(COPTC.UDF58,0.00) AS com 
            FROM COPTC								
            LEFT JOIN COPTD ON COPTC.TC001=COPTD.TD001 AND COPTC.TC002=COPTD.TD002
            LEFT JOIN COPMA ON COPTC.TC004=COPMA.MA001
            LEFT JOIN CMSMV ON COPTC.TC006=CMSMV.MV001
            LEFT JOIN INVMB ON INVMB.MB001=COPTD.TD004 where 1=1 $accountnamewhere $salesnowhere $datewhere $usernamewhere
            ) as F1
            ";
           
           //echo $query;
				$result = $SqlCon->Query_result($query);
				$rows = $SqlCon->num_rows($result); 
        for($i=0;$i<$rows;$i++){
				$order = $SqlCon->fetch_object($result);
                $listview_entrie['com']=$order['com'];
        }
        $listview_entrie['price']=($listview_entrie['discount']-$listview_entrie['com']-($listview_entrie['subtotal']))/$listview_entrie['discount'];
    return $listview_entrie;
}

function getUserNameids(){
    global $current_user,$adb;
    $SQL ="SELECT roleid FROM ld_user2role WHERE userid=".$current_user->id;
	
    $result=$adb->pquery($SQL,array());
    $role = $adb->query_result($result, $i, 'roleid');
    //unset($result);
     $SQL="SELECT DISTINCT parentrole FROM ld_role WHERE parentrole like ('%$role%');";
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $parent = $adb->query_result($result, $i, 'parentrole');
       	$temp_list = explode('::',$parent);
        $ulist .= implode("','",$temp_list)."','";
       // unset($temp_list);
    }
	//echo $ulist;die;
    $ulist="'".substr($ulist,0,strlen($ulist)-2); 
    if($role!='H2'&&$role!='H3'&&$role!='H6'){
       $SQL="SELECT last_name FROM ld_users WHERE id =".$current_user->id;

    }else{
        $SQL="SELECT last_name FROM ld_users WHERE id in (SELECT userid FROM ld_user2role WHERE roleid IN ($ulist) AND roleid>='$role' );";
    }
 //echo $SQL;
    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {
        $usnamelist[] = $adb->query_result($result, $i, 'last_name');
       // unset($temp_list);
    }
    //print_r($usnamelist);
    return $usnamelist;
}
//print_r($salesList['slist']);
//页面赋值
//print_r($listvalue);
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$smarty->assign("roleList",$listvalue);
$smarty->display('Comprehensivereport/dingjiereport.tpl');
exit();
?>