<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Emails/Save.php,v 1.27 2005/04/29 08:54:38 rank Exp $
 * Description:  Saves an Account record and then redirects the browser to the 
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Emails/mail.php');
global $adb;

if(isset($_REQUEST['server_check']) && $_REQUEST['server_check'] == 'true')
{
	$sql="select * from ld_systems where server_type = ?";
	$records=$adb->num_rows($adb->pquery($sql, array('email')),0,"id");  
	$_REQUEST['diony']='diony';
	if($records != ''){
		$sender=$adb->query_result($adb->pquery($sql, array('email')),$i,'server_username');
		ConvertTojsonString(1,array(),"success");
	}else{
		ConvertTojsonString(-1,array(),getFixedLabel('LBL_CONF_MAILSERVER_ERROR'));
	}	
}
//$_REQUEST['description1'] = $_POST['description1'];//邮件发送内容被过滤，发送的邮件没有格式 tujt 2014-12-16
if(isset($_REQUEST['WebMail_check']) && $_REQUEST['WebMail_check'] == 'true')
{
	$sql="select * from ld_mail_accounts where user_id = ?";
	$records=$adb->num_rows($adb->pquery($sql,array($current_user->id)),0,"account_id");
	$_REQUEST['diony']='diony';
	if($records>0)
		ConvertTojsonString(1,array(),"success");
	else
		ConvertTojsonString(-1,array(),"success");	
}


/**
 * REQUEST的传值都被过滤了，所以需要从POST中取值，再传递到REQUEST中
 * @reason 0012815: 邮件管理界面：写信界面，选择联系人、客户、用户邮件后发送，结果收件人无法收到邮件
 * @author Tujt 2014-12-05
 */

//$_REQUEST['parent_name'] = $_GET['parent_name'];

//Added on 09-11-2005 to avoid loading the webmail lingdang_files in Email process
if($_REQUEST['smodule'] != '')
{
	define('SM_PATH','modules/squirrelmail-1.4.4/');
	/* SquirrelMail required lingdang_files. */
	require_once(SM_PATH . 'functions/strings.php');
	require_once(SM_PATH . 'functions/imap_general.php');
	require_once(SM_PATH . 'functions/imap_messages.php');
	require_once(SM_PATH . 'functions/i18n.php');
	require_once(SM_PATH . 'functions/mime.php');
	require_once(SM_PATH .'include/load_prefs.php');
	//require_once(SM_PATH . 'class/mime/Message.class.php');
	require_once(SM_PATH . 'class/mime.class.php');
	sqgetGlobalVar('key',       $key,           SQ_COOKIE);
	sqgetGlobalVar('username',  $username,      SQ_SESSION);
	sqgetGlobalVar('onetimepad',$onetimepad,    SQ_SESSION);
	$mailbox = 'INBOX';
}

require_once('modules/Emails/Emails.php');

//$local_log =LoggerManager::getLogger('index');
include("include/simple_html_dom.php");

$focus = new Emails();

global $current_user,$mod_strings,$app_strings;
if(isset($_REQUEST['description1']) && $_REQUEST['description1'] !='')
	$_REQUEST['description1'] = fck_from_html($_REQUEST['description1']);

$all_to_ids = $_REQUEST["hidden_toid"];
/**
 * edit:kevin
 * date:2013-10-23
 * reason:5418
 */ 
if(isset($_REQUEST["groupemail"]) && $_REQUEST["groupemail"] !='groupemail')
$all_to_ids .= $_REQUEST["saved_toid"];
else
$all_to_ids = $_REQUEST["hidden_toid"];


$_REQUEST["saved_toid"] = $all_to_ids;
//we always save the email with "save" status and when it is sent it is marked as SENT
/**
 * 因为发送的邮件，类型默认是SAVED（草稿箱），需要对是否发送邮件做判断，如果发送邮件，则类型设为SENT（发送）
 * @reason 0011832 邮件管理写信，发送后，结果收件人没有收到邮件
 * @author Tujt 2014-09-29
 */
if(isset($_REQUEST['send_mail']) && $_REQUEST['send_mail'])
	$_REQUEST['email_flag'] = 'SENT';
else
	$_REQUEST['email_flag'] = 'SAVED';

setObjectValuesFromRequest($focus);

/**
 * 更新操作
 * edit:can
 * date:20131228
 * reason:6525: 知识管理明细界面（有附件），点击“把附件作为电子邮件附件发送”，输入收件人，主题保存；到邮件管理->草稿箱，“所有邮件”界面，收件人无显示，如图：
 * */
if(isset($_REQUEST['filename_hidden'])) {
	$file_name = $_REQUEST['filename_hidden'];
} else {
	$file_name = $_FILES['filename']['name'];
}

$errorCode =  $_FILES['filename']['error'];
$errormessage = "";
if($file_name != '' && $_FILES['filename']['size'] == 0)
{
	if($errorCode == 4 || $errorCode == 0)
	{
		 if($_FILES['filename']['size'] == 0)
			 $errormessage = "<B><font color='red'>".getFixedLabel('VALIDFILEATTACH')."</font></B> <br>";
	}
	else if($errorCode == 2)
	{
		  $errormessage = "<B><font color='red'>".getFixedLabel('MAXFILEATTACHSORRY').$upload_maxsize.getFixedLabel('BYTES')." </font></B> <br>";
	}

	else if($errorCode == 3 )
	{
	     if($_FILES['filename']['size'] == 0)
		     $errormessage = "<b><font color='red'>".getFixedLabel('VALIDFILEATTACH')."</font></b><br>";
	}
	else{}
	if($errormessage != ""){
		$ret_error = 1;
		$ret_parentid = vtlib_purify($_REQUEST['parent_id']);
		$ret_toadd = vtlib_purify($_REQUEST['parent_name']);
		$ret_subject = vtlib_purify($_REQUEST['subject']);
		$ret_ccaddress = vtlib_purify($_REQUEST['ccmail']);
		$ret_bccaddress = vtlib_purify($_REQUEST['bccmail']);
		$ret_description = vtlib_purify($_REQUEST['description1']);
		echo $errormessage;
        	include("EditView.php");	
		exit();
	}
}


if($_FILES["filename"]["size"] == 0 && $_FILES["filename"]["name"] != '')
{
        $file_upload_error = true;
        $_FILES = '';
}

//if((isset($_REQUEST['deletebox']) && $_REQUEST['deletebox'] != null) && $_REQUEST['addbox'] == null)
//{
    //028872: 群发邮件：点击【群发】按钮后，页面跳转到邮件管理界面了
    if(!$_REQUEST['send_mail'])
	{
	   imap_delete($mbox,$_REQUEST['deletebox']);
    	imap_expunge($mbox);
    	header("Location: index.php?module=Emails&action=index");
    	exit();
	}
//}

function checkIfContactExists($mailid)
{

	global $adb;
	$sql = "select contactid from ld_contactdetails inner join ld_crmentity on ld_crmentity.crmid=ld_contactdetails.contactid where ld_crmentity.deleted=0 and email= ?";
	$result = $adb->pquery($sql, array($mailid));
	$numRows = $adb->num_rows($result);
	if($numRows > 0)
	{
		
		return $adb->query_result($result,0,"contactid");
	}
	else
	{
		
		return -1;
	}
}
//assign the focus values
$focus->filename = $_REQUEST['file_name'];
$focus->parent_id = vtlib_purify($_REQUEST['parent_id']);
$focus->parent_type = vtlib_purify($_REQUEST['parent_type']);
$focus->column_fields["assigned_user_id"]=$current_user->id;
$focus->column_fields["activitytype"]="Emails";
/**
 * AUTHOR:BY LD KEVIN
 * DATE:20130418
 * DESPRITION:bug3768
*/
//$date_start=new DateTimeField(getNewDisplayDate().' '.'00:00:00');
//$date_start=new DateTimeField();


$focus->column_fields["date_start"]= date("Y-m-d H:i:s");//This will be converted to db date format in save

if((!empty($_REQUEST['record'])&& $_REQUEST['send_mail']==false &&
		!empty($_REQUEST['mode']))) {
	$focus->mode = 'edit';
} elseif(empty($_REQUEST['record']) ||(!empty($_REQUEST['record'])&& $_REQUEST['send_mail']== false
		&& empty($_REQUEST['mode'])) || !empty($_REQUEST['record'])&& $_REQUEST['send_mail']==true
		&& empty($_REQUEST['mode'])) {
	$focus->mode = '';
	$focus->id = '';
} else {
	$focus->mode = 'edit';
}
$sql="select * from ld_systems where server_type = ?";
$records=$adb->num_rows($adb->pquery($sql, array('email')),0,"id");    
if($records != '')
{
    $sender=$adb->query_result($adb->pquery($sql, array('email')),$i,'server_username');        		
        	
}

 $domobj = new simple_html_dom();     //new simple_html_dom对象</p><p>      
$domobj->load($_REQUEST['description1']); 

$arr = $domobj->find('img');  
 
 
    $corp_link = getCrmUrl();
 
foreach($arr as $index=> $imgobj)
{
    if(stripos($imgobj->src,'https://')!==false||stripos($imgobj->src,'http://')!=false)
    {
        
    }
    else
	   $imgobj->src=$corp_link."/".$imgobj->src;
}
 
 $arr = $domobj->find('image');  

foreach($arr as $index=> $imgobj)
{
    if(stripos($imgobj->src,'https://')!==false||stripos($imgobj->src,'http://')!=false)
    {
        
    }
    else
	   $imgobj->src= $corp_link."/".$imgobj->src;
}
 $_REQUEST['description1']=$domobj->save();
$domobj->clear();
//群发邮件
/**
 * edit:kevin
 * date:20130614
 * reason:4175
 */ 

if(isset($_REQUEST['groupemail'])&&$_REQUEST['groupemail']=='groupemail')
{
    $allids=$_REQUEST['tabid_fieldlabel_btn_listview_email'];//获取所选择的用户或联系人或客户的id和模块中邮件字段fieldid
    $parentids=explode(',',$allids);
	$ismailname = false;
  
	if(stripos($_REQUEST['parent_name'],'<') > 0){
		$results = str_replace(">",";",$_REQUEST['parent_name']);
		$results = str_replace("<",";",$results);
		//将信息分割成数组
		$results_arr = array();
		$results_arr = explode(",",$results);
       //edit:can 2020-12-14 043691: （https://61mis.com/kfbcrm [^]）使用群发邮件功能的时候只有前两个邮箱可以收到邮件。
	//	$results_arr=array_chunk ($results_arr,2);
		$ismailname = true;
       
	}else{
		$results = str_replace("\r\n",";",$_REQUEST['parent_name']);
		//将信息分割成数组
		$results_arr = array();
		$results_arr = explode(",",$results);
	}
  
    $parent_index = 0;
	$is_email_id = 0;
	if(strlen($results_arr[sizeof($results_arr)-1])<=0)
		unset($results_arr[sizeof($results_arr)-1]);
        if(is_array($results_arr[0]))
        {
            $results_arr=$results_arr[0];
        }
     
        foreach ($results_arr as $result)
        {
                $focusemail = new Emails();
                $mail_arr=explode(";",$result);
                $emailname='';
               
                if(sizeof($mail_arr)>1)
                {
                    $result=$mail_arr[0];
                    $emailname=$mail_arr[1];
                    
                }
             	$focus->mode = '';
                $focus->id = '';
              
					$email = $result;
					$toemail = $result;
                    
				
				                  
				//发送一条邮件，会插入一条空记录，所以添加邮箱非空判断，杜绝此现象 tujt 2014-09-18
				if(!$toemail || empty($toemail)) continue;
				// 去除收件人换行
				$toemail = trim($toemail);
				$toemail = str_replace(PHP_EOL, '', $toemail);
                $email = str_replace("\r\n","",$email);
                //print_r($email);
                #获取内容
                $receivecontentonly = $_REQUEST['description1'];
              
              
                if(stripos($receivecontentonly,"{name}")!==false)
                {
                    $sqlCName = 'select tablename,columnname from ld_field where tabid in (4,6) and uitype = 13';
                    $sqlCNameResult=$adb->query($sqlCName);
                    $sqlCNameCount = $adb->num_rows($sqlCNameResult);
                    if($sqlCNameCount>0)
                    {
                        $columnnames = '';
                        for($i=0;$i<$sqlCNameCount;$i++)
                        {
                            $tablename = $adb->query_result($sqlCNameResult,$i,'tablename');
                            $columnname = $adb->query_result($sqlCNameResult,$i,'columnname');
                            if($i+1==$sqlCNameCount)
                            {
                                $columnnames .= $tablename.'.'.$columnname;
                            }
                            else
                            {
                                $columnnames .= $tablename.'.'.$columnname.',';
                            }
                        }
                    }
                    $columnnames=explode(",",$columnnames);
                    $where = ' ld_contactdetails.deleted= 0 and ld_account.deleted = 0 and (';
                    foreach ($columnnames as $columnname)
                    {
                           $where .= $columnname." = '$email' or " ;
                    } 
                    $where .= ' 1 = 2 )order by ld_account.accountid   ';   
                    
                    $sql = 'select ld_account.accountname,ld_contactdetails.lastname,ld_contactdetails.salutation 
                    from ld_contactdetails  left join ld_account on ld_account.accountid = ld_contactdetails.accountid
                    LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
                    LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid    where  '.$where;
                  //  echo $sql."========";
                  //  exit();
                    $sqlResult=$adb->pquery($sql,array());
                    $sqlCount = $adb->num_rows($sqlResult);
                    if($sqlCount>0)
                    {
                        $lastname = $adb->query_result($sqlResult,0,'lastname');
                    }
                
                    if(empty($lastname))
                    {
                        $receivecontentonly = str_replace("{name}",'',$receivecontentonly);
                    }
                    else
                    {
                        $receivecontentonly = str_replace("{name}",$lastname,$receivecontentonly);
                    } 
                }
                 
                if(stripos($receivecontentonly,"{app}")!==false)
                {   
                    $sqlCName = 'select tablename,columnname from ld_field where tabid in (4,6) and uitype = 13';
                    $sqlCNameResult=$adb->query($sqlCName);
                    $sqlCNameCount = $adb->num_rows($sqlCNameResult);
                    if($sqlCNameCount>0)
                    {
                        $columnnames = '';
                        for($i=0;$i<$sqlCNameCount;$i++)
                        {
                            $tablename = $adb->query_result($sqlCNameResult,$i,'tablename');
                            $columnname = $adb->query_result($sqlCNameResult,$i,'columnname');
                            if($i+1==$sqlCNameCount)
                            {
                                $columnnames .= $tablename.'.'.$columnname;
                            }
                            else
                            {
                                $columnnames .= $tablename.'.'.$columnname.',';
                            }
                        }
                    }
                    $columnnames=explode(",",$columnnames);
                    $where = ' ld_contactdetails.deleted= 0 and ld_account.deleted = 0 and (';
                    foreach ($columnnames as $columnname)
                    {
                           $where .= $columnname." = '$email' or " ;
                    } 
                    $where .= ' 1 = 2 ) order by ld_account.accountid   ';   
                    
                    $sql = 'select ld_account.accountname,ld_contactdetails.lastname,ld_contactdetails.salutation from ld_contactdetails 
                    left join ld_account  on ld_account.accountid = ld_contactdetails.accountid 
                    LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
                    LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid  where  '.$where;
                    $sqlResult=$adb->query($sql);
                    $sqlCount = $adb->num_rows($sqlResult);
                    if($sqlCount>0)
                    {
                        $salutation = $adb->query_result($sqlResult,0,'salutation');
                    }
                    if(empty($salutation))
                    {
                        $receivecontentonly = str_replace("{app}",'',$receivecontentonly);
                    }
                    else
                    {
                        $receivecontentonly = str_replace("{app}",$salutation,$receivecontentonly);
                    }        
                }

                if(stripos($receivecontentonly,"{comname}")!==false)
                {
                    $sqlCName = 'select tablename,columnname from ld_field where tabid in (4,6) and uitype = 13';
                    $sqlCNameResult=$adb->query($sqlCName);
                    $sqlCNameCount = $adb->num_rows($sqlCNameResult);
                    if($sqlCNameCount>0)
                    {
                        $columnnames = '';
                        for($i=0;$i<$sqlCNameCount;$i++)
                        {
                            $tablename = $adb->query_result($sqlCNameResult,$i,'tablename');
                            $columnname = $adb->query_result($sqlCNameResult,$i,'columnname');
                            if($i+1==$sqlCNameCount)
                            {
                                $columnnames .= $tablename.'.'.$columnname;
                            }
                            else
                            {
                                $columnnames .= $tablename.'.'.$columnname.',';
                            }
                        }
                    }
                    $columnnames=explode(",",$columnnames);
                    $where = ' ld_contactdetails.deleted= 0 and ld_account.deleted = 0 and (';
                    foreach ($columnnames as $columnname)
                    {
                           $where .= $columnname." = '$email' or " ;
                    } 
                    $where .= ' 1 = 2 ) order by ld_account.accountid   ';   
                    
                    $sql = 'select ld_account.accountname,ld_contactdetails.lastname,ld_contactdetails.salutation from ld_account 
                    left join ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid 
                    LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
                    LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid  where  '.$where;
                   // echo $sql."=========";
                   // exit();
                    $sqlResult=$adb->query($sql);
                    $sqlCount = $adb->num_rows($sqlResult);
                    if($sqlCount>0)
                    {
                        $accountnames = $adb->query_result($sqlResult,0,'accountname');
                    }
                      
                    if(empty($accountnames))
                    {
                        $receivecontentonly = str_replace("{comname}",'',$receivecontentonly);
                    }
                    else
                    {
                        $receivecontentonly = str_replace("{comname}",$accountnames,$receivecontentonly);
                    }
                    
                }
                 setObjectValuesFromRequest($focusemail);
                 /*if(is_array($parentids)&&$parent_index<sizeof($parentids))
                     $focusemail->column_fields['parent_id']=$parentids[$parent_index].'|';//获取当前收件人所对应的模块信(息id+"@")
                 else*/
                    $focusemail->column_fields['parent_id']='';
                 $focusemail->column_fields['from_email']=$_REQUEST['from_email'];
                 $focusemail->column_fields['saved_toid']=$emailname.'<'.$toemail.'>';
                 $focusemail->column_fields['subject']=$_REQUEST['subject'];
                 $focusemail->column_fields['email_flag']='SENT';
				 $focusemail->column_fields["activitytype"]="Emails";
				 $focusemail->column_fields["assigned_user_id"] = $current_user->id;
                $focusemail->column_fields["date_start"] = date("Y-m-d H:i:s");
                
                 if(array_key_exists('description',$focusemail->column_fields))
                 {
                    $focusemail->column_fields['description']=$receivecontentonly;
                 }
                
				/**
				 * 群发邮件多福建处理
				 * @author Tujt 2014-09-26
				 */
				global $groupemailattachment;
				$groupemailattachment = 1;
               // $focusemail->mode='Create';
                $focusemail->save("Emails");
               $sql='update ld_activity set description=? where activityid=?';
                 
                 $adb->pquery($sql,array($receivecontentonly,$focusemail->id));
				//if(empty($is_email_id)){
				    //edit:can 20210726 047053: （http://www.xiaoshou360.com/KH/chenigen [^]）（苏州市仓嘉超净科技有限公司）使用群发邮件给两个不同的成员发邮件时，收到的邮件中联系人姓名却是相同的。
					$is_email_id = $focusemail->id;
				//}
				 
                $user_mail_status = send_mail('Emails',$toemail,$current_user->user_name,$_REQUEST['from_email'],$_REQUEST['subject'],$receivecontentonly,'','','all',$is_email_id,'',$sender);
    }
  
    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,array(),"success");
	//die;
    
}
else{
    /**
 * 更新操作
 * edit:can
 * date:20131228
 * reason:6525: 知识管理明细界面（有附件），点击“把附件作为电子邮件附件发送”，输入收件人，主题保存；到邮件管理->草稿箱，“所有邮件”界面，收件人无显示，如图：
 * */
    if($_REQUEST['parent_name']!='')
    {
       $focus->column_fields['saved_toid']=$_REQUEST['parent_name'];
        $all_to_ids=$_REQUEST['parent_name'];
    }
     $from_email=$_REQUEST['from_email'];
     $toemail=$_REQUEST['parent_name'];
     $ccmail=$_REQUEST['ccmail'];
     $bccmail=$_REQUEST['bccmail'];
     $subject=$_REQUEST['subject'];
     $content=$_REQUEST['description1'];
     require_once('modules/Emails/mail.php');
     if(array_key_exists('description',$focus->column_fields))
     {
        $focus->column_fields['description']=$content;
     }
	global $groupemailattachment;
	$groupemailattachment = 1;
    $focus->save("Emails");	

   if(isset($_REQUEST['send_mail']) && $_REQUEST['send_mail'])//如果是保存邮件则不用发送
	{
		$savedids = array_unique(explode(';',$focus->column_fields['saved_toid']));
		for($i = 0; $i<count($savedids); $i++){
			send_mail('Emails',$savedids[$i],'',$from_email,$subject,$content,$ccmail,$bccmail,'all',$focus->id,'',$sender);
		}
    }
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
	//$return_id = $focus->id;
    //$focus->retrieve_entity_info($return_id,"Emails");
   
}




//this is to receive the data from the Select Users button
if($_REQUEST['source_module'] == null)
{
	$module = 'users';
}
//this will be the case if the Select Contact button is chosen
else
{
	$module = $_REQUEST['source_module'];
}

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") 
	$return_module = vtlib_purify($_REQUEST['return_module']);
else 
	$return_module = "Emails";

if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") 
	$return_action = vtlib_purify($_REQUEST['return_action']);
else 
	$return_action = "DetailView";

if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") 
	$return_id = vtlib_purify($_REQUEST['return_id']);

if(isset($_REQUEST['filename']) && $_REQUEST['filename'] != "") 
	$filename = vtlib_purify($_REQUEST['filename']);


/**
 * AUTHOR:BY LD KEVIN
 * DATE:20130403
 */	

if(isset($_REQUEST['send_mail']) && $_REQUEST['send_mail'] && $_REQUEST['parent_id'] == ''){
	if($_REQUEST["parent_name"] != '' && isset($_REQUEST["parent_name"])&& $_REQUEST['groupemail']=='') {
	//	include("modules/Emails/webmailsend.php");//edit:can 暂时找不到该句话有什么用，我就把它删除了，
                                                    //如果添加这个语句邮件管理就会发送两个邮件
	}
} 
$datajson=urlencode("&datajson=no");
if(isset($_REQUEST['return_action']) && ($_REQUEST['return_action'] == 'mailbox'||$_REQUEST['return_action'] == 'GroupEmail'))
{   
    
    if(isset($_REQUEST['groupemail'])&&$_REQUEST['groupemail']!='')
    {
    echo "<script>document.location.href='index.php?pageto_module=MassEmails&pageto_action=GroupEmail&page_addurl=$datajson';</script>";
    }
    else
    	header("Location: index.php?module=$return_module&action=index");
}
else {
	if($_REQUEST['return_viewname'] == '') $return_viewname='0';
	if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
	//Added for 4600
	$inputs="<script>window.opener.location.href=window.opener.location.href;window.self.close();</script>";
	echo $inputs;
}
?>