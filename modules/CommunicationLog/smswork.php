<?php
/*+********************************************************************************
  *{*修改编码格式:统一编码：UTF-8*}
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  ********************************************************************************/





global $app_strings,$adb;
global $list_max_entries_per_page_new;
global $currentModule, $current_user;

//$log = LoggerManager::getLogger('smswork_list');
$smarty = new lingdangCRM_Smarty();

if(isset($_REQUEST['BatchIdAll']))
{
    $id = $_REQUEST['BatchIdAll'];
    $arr=array();
    $arr = explode(",",$id);
    $count = count($arr);
    //print_r($count);
    $newid = "";
    for($i=0;$i<$count;$i++)
    {
        if($arr[$i]!="")
        {
            $newid .= "'".$arr[$i]."',";
        }
    }
    
    $newid = substr($newid,0,strlen($newid)-1);
    if($count > 0)
    {
        $sqldel = "delete from ld_smssend where BatchNo in (".$newid.")";
        //print_r($sqldel);
        //exit();
        $result = $adb->pquery($sqldel,array());
        $num_row = $adb->num_rows($result);
       
    }
}


$where_sql = " where 1=1 ";
/*
    edit:cdw
    date:20130905
    reason:0004914: 通讯记录查询中 选择分页之后不能默认调回到首页
    */
if(isset($_REQUEST['pagenum']))
{
    $pagenum = $_REQUEST['pagenum'];
    
}
//end

#获取类别
$typename= $_REQUEST['typename']; 
//print_r($_REQUEST['typename']); 
$typename=str_replace("\r\n","",$typename);
if(strlen($typename)>0)
{
    if($_REQUEST['typename']!= 0)
    {
        $where_sql .= " and T1.typeid = '$typename'";
    }
    else
    {
        $where_sql .= "";
    }
    
    $smarty->assign("typename", $typename);
}
#获取员工
$operator= $_REQUEST['operator'];  
//print_r($operator);
$operator=str_replace("\r\n","",$operator);
if(strlen($operator)>0 && $operator != 'undefined')
{
    $operators = $operator;
    $operators=str_replace(" ","",$operators);
    $operators = "'".$operators;
    $operators=str_replace(",","','",$operators);
    $operators = $operators."'";
    //$where_sql .= " and operator like '%$operator%' ";
    $where_sql .= " and operator in ($operators) ";
    $smarty->assign("operator", $operator);
    $smarty->assign("recieverid", $_REQUEST['recieverid']);
}
#获取时间
/*
edit:cdw
date:20130716
reason:0004455: 短信作业查询、短信清单查询中时间应该设置一个默认值，一打开界面时应该默认显示当月
*/          

#点击查找获取时间
if(strlen($_REQUEST['begin_createdate'])>0 || (isset($_REQUEST['paging']) && $_REQUEST['paging'] == "true"))
{
    $begin_createdate= $_REQUEST['begin_createdate'];
    $end_createdate= $_REQUEST['end_createdate'];
    //$begin_createdate = "2013-08-01";
    if(strlen($begin_createdate)>0)
    {
        $where_sql .= " and createtime between '$begin_createdate 00:00:00' and '$end_createdate 23:59:59' ";
    }
}
#点击链接获取时间
else
{
    $date=date("Y-m-d");
    $fday = date("Y-m-01",strtotime($date));
    $lday = date("Y-m-d",strtotime("$fday +1 month -1 day"));
    $firstday = $fday;
    $lastday = $lday;
    $begin_createdate= $firstday;
    $end_createdate= $lastday;
    $where_sql .= " and createtime between '$begin_createdate 00:00:00' and '$end_createdate 23:59:59' "; 
}

$smarty->assign("begin_createdate", $begin_createdate);
$smarty->assign("end_createdate", $end_createdate);

$where_sql .= " order by createtime desc  ";
global $mod_strings;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_language;

$category = getParentTab();
$focus = new Users();
$no_of_users=UserCount();
$smarty->assign('TABID',getTabid($currentModule));
/*
edit:cdw
date:20130723
reason:弹出框需要接收人列表和短信内容，增加了SmsContent和Receive
*/


$list_query = " select T1.TaskId as id,T1.BatchNo as batchno,T1.Subject as subject,T1.operator as operator,T1.wx_userid,T1.Smscontent as smscontent,T1.Receive as receive,";
$list_query .= " T2.AllCount as allcount,T2.SmsBillingFee as smsbillingfee,ifnull(T3.SuccessCount,0) as successcount,T1.createtime,T1.typename,T1.typeid from ";
$list_query .= " (select BatchNo,Subject, ld_users.last_name as operator,ld_users.wx_userid,createtime,SmsContent,CONCAT(ReceiveContacts,'：',CalledNumber) as Receive,ld_smssendtype.typename,ld_smssendtype.typeid,ld_smssend.TaskId from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name left join ld_smssendtype on ld_smssend.type = ld_smssendtype.typeid group by BatchNo ) as T1 Left Join "; 
$list_query .= " (select count(1) as AllCount,BatchNo,Sum(ifnull(SmsBillingFee,0)) as SmsBillingFee   from ld_smssend group by BatchNo) as T2 ON T1.BatchNo = T2.BatchNo  Left join"; 
$list_query .= " (select count(1) as SuccessCount,BatchNo  from ld_smssend where SmsResult =1 group by BatchNo ) as T3 ON T1.BatchNo = T3.BatchNo ";
$list_query .= $where_sql;
if( $adb->dbType == "pgsql")
	$list_query = fixPostgresQuery($list_query,  0);

if(!$_SESSION['lvs'][$currentModule]) {
	unset($_SESSION['lvs']);
	$modObj = new ListViewSession();
	$modObj->sorder = $sorder;
	$modObj->sortby = $order_by;
	$_SESSION['lvs'][$currentModule] = get_object_vars($modObj);
}
$count_list_query = "select count(1) as count from ($list_query) as T1";
$count_result = $adb->query( $count_list_query);
if(!empty($count_result))
	$noofrows = $adb->query_result($count_result,0,0);
else 
	$noofrows = null;


$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

if( $adb->dbType == "pgsql"&&$_REQUEST['expt']!='type')
{
    	$list_result = $adb->pquery($list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new", array());
}    
elseif($_REQUEST['expt']!='type')
{
     
        $list_result = $adb->pquery($list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());
}else{
      $list_result = $adb->pquery($list_query, array());
}

  
$num_rows=$adb->num_rows($list_result);
$arr=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        //发件人
        $last_name=$adb->query_result($list_result,$i,'operator');
        $wx_userid=$adb->query_result($list_result,$i,'wx_userid');
        $userobj=new Users();
        $userobj->wx_userid=$wx_userid;
        $userobj->last_name=$last_name;
        if($_REQUEST['expt']=='type'){
            $operatename=getWxMobileRemindInfo($userobj);
        }
        else{
            $operatename=getUserlastName($userobj);
        }
        $arr[]=array(
            'BatchId'=> $adb->query_result($list_result,$i,'id'),
            'BatchNo'=> $adb->query_result($list_result,$i,'batchno'),
            'Subject'=> $adb->query_result($list_result,$i,'subject'),
            'Operator'=> $operatename,
            'AllCount'=> $adb->query_result($list_result,$i,'allcount'),
            'SmsBillingFee'=> $adb->query_result($list_result,$i,'smsbillingfee'),
            'SuccessCount'=> $adb->query_result($list_result,$i,'successcount'),
            'Createtime'=> $adb->query_result($list_result,$i,'createtime'),
            /*
            edit:cdw
            date:20130723
            reason:弹出框需要接收人列表和短信内容
            */
            'SmsContent'=> $adb->query_result($list_result,$i,'smscontent'),
            'Receive'=> $adb->query_result($list_result,$i,'receive')
        //end
        );
    }
}
/*
20150210
导出
andrew
*/

if($_REQUEST['expt']=='type'&&count($arr)==0){
    echo "<script>alert('".getFixedLabel('nodata')."');</script>";
}
if($_REQUEST['expt']=='type'&&count($arr)!=0){
        include('PHPExcel/PHPExcel.php');
        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet=$objPHPExcel->getActiveSheet();
        $listview_header=array('编号','作业号','标题','发件人','总份数','费用','完成份数','创建时间','内容','接收人');
        $headerlang = count($listview_header);
        for($i=0;$i<$headerlang;$i++) {
        	$header = $listview_header[$i];
        	$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($i).'1',$header);
        }
        $listview_entries=$arr;
        
        $j = 2;$list = 0;
        foreach($listview_entries as $arr){
        	$for_i = 0;
        	$list = 0;$arrcount = count($arr);
        	foreach($arr as $value){
        		if($value == '&&'){
        			$value = '';
        			++ $list;
        		}else if($value == '&nbsp;'){
        			$value = '';
        		}
        		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i).$j,$value);
        		++ $for_i;
        		if($arrcount == $list){
        			-- $j;
        		}
        	}
        	++ $j;
        }
        $moduleName = $currentModule;
        $modulelabel = getTranstab($moduleName);
        $modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
        $objPHPExcel->getActiveSheet()->setTitle($moduleName);
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
        $objWriter->save('storage/'.$moduleName.'.xls');
        //下载文件
        $file_name = ''.$moduleName.'.xls';
        $file_dir = 'storage/';
         if(isKehu001ServerPc()=='yes'){
            require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            $portobj=new cls_WeixinPort();
            $pathname=$file_dir.$file_name;
             $wx_downloadurl=  $portobj->UploadUserInfoFile(globalStatic::$root_directory.$pathname,$modulelabel.'.xls');
             header("Location:".$wx_downloadurl);
        }
        else
        {
            $file = fopen($file_dir.$file_name,"r"); 
            Header("Content-type: application/octet-stream");
            Header("Accept-Ranges: bytes");
            Header("Accept-Length: ".filesize($file_dir.$file_name));
            Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
            ob_clean();   
            flush(); 
            echo fread($file, filesize($file_dir.$file_name));
            fclose($file);
            exit();
        }
}

$smarty->assign("resultwork", $arr);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
//$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"CommunicationLog","index",'',$pagenum);
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
$smarty->assign('recordListRange',$recordListRangeMsg);

/*
edit:cdw
date:20130724
reason:0004471:短信作业查询、短信清单查询中 将员工改成 发送人
1.默认显示为空
2.获取焦点后，显示为下拉选择，下拉选择可显示的用户信息根据当前用户的角色权限显示。可参考提醒中的“提醒人
*/
$assigned_user_id = $current_user->id; 
$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $assigned_user_id), $assigned_user_id);
//print_r($users_combo);
$smarty->assign("users_combo",$users_combo);
//end

$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("CURRENT_USERID", $current_user->id);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("CATEGORY",$category);
$smarty->assign("PAGE_START_RECORD",$limit_start_rec);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("NAVIGATION", $navigationOutput);

$smarty->assign("TESTFILE",$testFile);
$Delete=isPermitted($currentModule,"Delete","");
$smarty->assign("DELETE",$Delete);
$_REQUEST['diony']='yes';
if(isset($_REQUEST['paging'])&&$_REQUEST['paging']=='1')
{
    echo "#########:#";
   $smarty->display("modules/CommunicationLog/smsworkpaging.tpl");
   exit();
   
}
else if($_REQUEST['ajax']=='yes')
{
   $arr['content']= $smarty->fetch("modules/CommunicationLog/smsworkpaging.tpl");
}
else
{
    $arr['content']=  $smarty->fetch("modules/CommunicationLog/smswork.tpl");
}
ConvertTojsonString(1,$arr,'success');

?>