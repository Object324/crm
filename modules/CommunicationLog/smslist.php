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


global $app_strings;
global $list_max_entries_per_page_new;
global $currentModule, $current_user;

//$log = LoggerManager::getLogger('smslist_list');
$smarty = new lingdangCRM_Smarty();
//删除按钮
if(isset($_REQUEST['BatchIdAll'])&&$_REQUEST['BatchIdAll']!="")
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
    //print_r($newid);
    //exit();
    if($count > 0)
    {
        $sqldel = "delete from ld_smssend where TaskID in (".$newid.")";
        //echo $sqldel;
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

#获取接收人
$receiveContacts= $_REQUEST['receiveContacts'];  
$receiveContacts=str_replace("\r\n","",$receiveContacts);
if(strlen($receiveContacts)>0)
{
    $where_sql .= " and ReceiveContacts like '%$receiveContacts%' ";
    $smarty->assign("receiveContacts", $receiveContacts);
}
#获取类别
$typename= $_REQUEST['typename'];  
$typename=str_replace("\r\n","",$typename);
if(strlen($typename)>0)
{
    if($_REQUEST['typename'] !=0)
    {
        $where_sql .= " and ld_smssendtype.typeid = '$typename' ";
    }
    else
    {
        $where_sql .= "";
    }
    $smarty->assign("typename", $typename);
}
#获取接收号码
$calledNumber= $_REQUEST['calledNumber'];  
$calledNumber=str_replace("\r\n","",$calledNumber);
if(strlen($calledNumber)>0)
{   
    $where_sql .= " and CalledNumber like '%$calledNumber%' ";
    $smarty->assign("calledNumber", $calledNumber);
}
#获取内容
$smsContent= $_REQUEST['smsContent'];  
$smsContent=str_replace("\r\n","",$smsContent);
if(strlen($smsContent)>0)
{
    $where_sql .= " and SmsContent like '%$smsContent%' ";
    $smarty->assign("smsContent", $smsContent);
}
#获取员工
$operator= $_REQUEST['operator'];
$operator=str_replace("\r\n","",$operator);

if(strlen($operator)>0)
{
    $operators = $operator;
    $operators=str_replace(" ","",$operators);
    $operators = "'".$operators;
    $operators=str_replace(",","','",$operators);
    $operators = $operators."'";
    //$where_sql .= " and operator like '%$operator%' ";
    $where_sql .= " and ld_users.last_name in ($operators) ";
    $smarty->assign("operator", $operator);
    $smarty->assign("recieverid", $_REQUEST['recieverid']);
}
/*
edit:cdw
date:20130805
reason:0004587: 短信作业查询和短信清单查询 中没有记录当前输入信息
*/
#获取主题
$subject= $_REQUEST['subject'];  
$subject=str_replace("\r\n","",$subject);
if(strlen($subject)>0)
{
    $where_sql .= " and subject like '%$subject%' ";
    $smarty->assign("subject", $subject);
}
#获取状态
$smsResultName= $_REQUEST['smsResultName']; 
//print_r($_REQUEST['smsResultName']); 
$smsResultName=str_replace("\r\n","",$smsResultName);
if(strlen($smsResultName)>0)
{ 
    if($_REQUEST['smsResultName']!= 2)
    {
        $where_sql .= " and SmsResult='$smsResultName' ";
    }
    else
    {
        $where_sql .= "";
    }
    $smarty->assign("smsResultName", $smsResultName);
    
}
#获取时间
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
#点击查找获取时间
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


$where_sql .= " order by TaskID desc  ";

global $mod_strings,$adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_language;
//$mod_strings = return_module_language($current_language,'CommunicationLog');
$category = getParentTab();
$focus = new Users();
$no_of_users=UserCount();
/*
        edit:cdw
        date:20130723
        reason:0004497: 短信清单查询里面 列表中 主题显示不出来信息(增加了Subject)
        */
        
$list_query = "select TaskID as taskid, ReceiveContacts as receivecontacts,CalledNumber as callednumber,Subject as subject,FDataStatu,";
$list_query .= " SmsContent as smscontent,SmsBillingFee as smsbillingfee,SmsResult,failed_msg,FDataStatu,lossreason, ";
$list_query .= " ld_users.last_name as operator,ld_users.wx_userid,ld_smssendtype.typename,createtime,SubmitTime as submittime,ld_smssend.type from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name left join ld_smssendtype on ld_smssend.type = ld_smssendtype.typeid ";
$list_query .= $where_sql;
//print_r($list_query);
if( $adb->dbType == "pgsql")
	$list_query = fixPostgresQuery($list_query,  0);

if(!$_SESSION['lvs'][$currentModule]) {
	unset($_SESSION['lvs']);
	$modObj = new ListViewSession();
	$modObj->sorder = $sorder;
	$modObj->sortby = $order_by;
	$_SESSION['lvs'][$currentModule] = get_object_vars($modObj);
}
if(!empty($list_query)){
	$count_result = $adb->query( mkCountQuery($list_query));
	$noofrows = $adb->query_result($count_result,0,"count");
}else{
	$noofrows = null;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

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

//print_r($list_result);
$num_rows=$adb->num_rows($list_result);
$arr=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $encode = 'UTF-8';;
        $smscontentlength = mb_strlen($adb->query_result($list_result,$i,'smscontent'),$encode);       
        $CallMobileNumber = fieldValueUitype::SetMobileStyle($contactid[$i],$adb->query_result($list_result,$i,'callednumber'),'CommunicationLog');     
		$smsresult = $adb->query_result($list_result,$i,'smsresult');
		$fdatastatu = $adb->query_result($list_result,$i,'fdatastatu');
		if($smsresult == 1){
			$smsresultname = getFixedLabel('Sent_successfully');	//成功
		}else if($smsresult == -1){
			$smsresultname = getFixedLabel('To_be_submitted');	//未提交
		}else{
			if(empty($fdatastatu))
				$smsresultname = getFixedLabel('waitforsending');	//待发送
			else
				$smsresultname = getFixedLabel('Failed_to_send');	//失败
		}
        //发件人
        $last_name=$adb->query_result($list_result,$i,'operator');
        $wx_userid=$adb->query_result($list_result,$i,'wx_userid');
        $type=$adb->query_result($list_result,$i,'type');
        $type = $type==201?'语音提醒':'';//zxm 2021-0910 语音提醒 type=201
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
			'TaskID'=> $adb->query_result($list_result,$i,'taskid'),	//编号
			'ReceiveContacts'=> $adb->query_result($list_result,$i,'receivecontacts'),	//接收人
			'CalledNumber'=>  $CallMobileNumber,       //手机 
			'Createtime'=> $adb->query_result($list_result,$i,'createtime'),	//创建时间
			'SubmitTime'=> $adb->query_result($list_result,$i,'submittime'),	//发送时间
			'SmsContent'=> $adb->query_result($list_result,$i,'smscontent'),	//内容
			'SmsContentLength'=> $smscontentlength,	//字数
			'Operator'=> $operatename,	//发件人
			'SmsResultName'=> $smsresultname,	//状态
			'type'=> $type,	//zxm 2021-0910 语音提醒 type=201
			'failed_msg' => $adb->query_result($list_result,$i,'failed_msg'),
			'SmsBillingFee'=> $adb->query_result($list_result,$i,'smsbillingfee'),
			'Lossreason'=> $adb->query_result($list_result,$i,'lossreason'),
			'Subject'=>$adb->query_result($list_result,$i,'subject')
		);
    }
}

$smarty->assign("resultlist", $arr);

/*
20150210
导出
andrew
*/
/*if($_REQUEST['expt']=='type'&&count($arr)==0){
    echo "<script>alert('".getFixedLabel('nodata')."');</script>";exit();
}*/
//if($_REQUEST['expt']=='type'&&count($arr)!=0){
if($_REQUEST['expt']=='type'){
        include('PHPExcel/PHPExcel.php');
        $objPHPExcel = new PHPExcel();
        $objPHPExcel->setActiveSheetIndex(0);
        $activesheet=$objPHPExcel->getActiveSheet();
        $listview_header=array(getFixedLabel('Numbers'),getFixedLabel('Recipient'),getFixedLabel('Mobile'),getFixedLabel('Createtime1'),getFixedLabel('Delivery_time'),getFixedLabel('Content'),getFixedLabel('CONTENTLENGTH'),getFixedLabel('Sender'),getFixedLabel('STATUS'));
        $headerlang = count($listview_header);
        for($i=0;$i<$headerlang;$i++) {
        	$header = $listview_header[$i];
        	$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($i).'1',$header);
        }
        foreach($arr as $key=>$var){
            unset($arr[$key]['Lossreason']);
            unset($arr[$key]['Subject']);
            unset($arr[$key]['SmsBillingFee']);
        }
        //print_r($arr);
       // die;
        $listview_entries=$arr;        
        $j = 2;$list = 0;
        /*echo "<pre>";
        print_r($listview_entries);
        echo "<pre>";die;*/
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
        require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
        
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
        }
        exit();
}
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
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("CURRENT_USERID", $current_user->id);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("CATEGORY",$category);
$smarty->assign("PAGE_START_RECORD",$limit_start_rec);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));
$smarty->assign("TESTFILE",$testFile);
$Delete=isPermitted($currentModule,"Delete","");
$smarty->assign("DELETE",$Delete);
$_REQUEST['diony']='yes';
if($_REQUEST['paging']&&$_REQUEST['paging']=='1')
{
    echo "#########:#";
   $smarty->display("modules/CommunicationLog/smslistpaging.tpl");
  exit();
    
}
else if($_REQUEST['ajax']=='yes')
{
   $arr['content']= $smarty->fetch("modules/CommunicationLog/smslistpaging.tpl");
}
else
{
   $arr['content']=$smarty->fetch("modules/CommunicationLog/smslist.tpl"); //$smarty->fetch("modules/CommunicationLog/smslist.tpl");
}
ConvertTojsonString(1,$arr,'success');	
    
?>