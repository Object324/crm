<?php
/******************************************************
*{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130407
**DESPRITION:邮件群发
******************************************************/ 

global $theme,$app_strings,$current_language,$currentModule,$default_charset;
global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$pmodule=vtlib_purify($_REQUEST['return_module']);
if(isset($_REQUEST["selectedColumnsString2"]))
{
    include("modules/lingdang/ViewOrderEditSave.php");
    unsetCacheDirectory('customview');
}
/**
 * reason:bug:0017680
 * editor:cyb
 * date:2015-09-11
 * start...
 **/
//$select_options=vtlib_purify($_REQUEST['select_options']);：
$select_options=vtlib_purify($_REQUEST['accountid_listview_email']);
$tabid_fieldlabel_listview_email=vtlib_purify($_REQUEST['tabid_fieldlabel_listview_email']);
$tab=explode("_",(string)$tabid_fieldlabel_listview_email);

//zkt 20231227 BUG0077828 客户管理--选中客户“323232”使用群发邮件功能，无论选择哪一个邮件，都会带出客户邮箱与联系人邮箱，但是从群发邮件模块进入去选、就会正常带出一个单据的邮箱
$parent_name_textarea_email_arr = array();//记录显示的邮箱地址，防止内容重复

if($select_options == 'all'){
    $storearray = getSelectedRecords($_REQUEST,'Accounts','all',$excludedRecords);//获取当前数据分类下的全部的客户ID。
    $select_options = implode(',',$storearray);
 
}
   $fieldlabels;
    $cur_tabid=0;
    $other_label='';
    for($i=0;$i<sizeof($tab);$i++)
    {
        if($i%2==1)
        {
             if(!empty($other_label))
                $fieldlabels[$cur_tabid][]=$other_label.'_'.$tab[$i];
             else
             {
                $fieldlabels[$cur_tabid][]=$tab[$i];
             }
        }
        elseif($tab[$i]==6 or $tab[$i]==4)
        {
            $cur_tabid=$tab[$i];
        }
        else
        {
            $other_label=$tab[$i];//防止字段名称带"_"
        }
    }
if($current_language=='zh_cn'){
    $languagetype='zh';
}
else{
    $languagetype='en';
}
 //该sql语句是为了获取email字段所在表
$sql='select  tablename,columnname,ld_field.tabid from ld_field inner join ld_tranlabel on ld_field.fieldid=ld_tranlabel.relateid
         where   ld_tranlabel.languagetype=\''.$languagetype.'\'and ld_tranlabel.trantable=\'ld_field\' ';

$wheretab = '';
$where_four_label = '';
$where_six_label = '';
if(is_array($fieldlabels[6]) && !empty($fieldlabels[6])){
    for($i=0;$i<sizeof($fieldlabels[6]);$i++)
    {
        $fieldlabel=$fieldlabels[6][$i];
        $where_six_label.=' ld_tranlabel.fieldlabel=\''.$fieldlabel .'\'  ';
        if($i<sizeof($fieldlabels[6]))
        {    
            $where_six_label.=' or ';//or左右两边都有空格。
            
        }
    }
    $where_six_label=substr($where_six_label,0,strlen($where_four_label)-3);//去掉sql拼接时多出来的“or”；length-3是因为or右边有空格。
}

if(is_array($fieldlabels[6]) && !empty($fieldlabels[6])){
    for($i=0;$i<sizeof($fieldlabels[4]);$i++)
    {
        $fieldlabel=$fieldlabels[4][$i];    
        $where_four_label.=' ld_tranlabel.fieldlabel=\''.$fieldlabel .'\'  ';
        if($i<sizeof($fieldlabels[4]))
        {
            $where_four_label.=' or ';//or左右两边都有空格。
        }
    }
    $where_four_label=substr($where_four_label,0,strlen($where_four_label)-3);//去掉sql拼接时多出来的“or”；length-3是因为or右边有空格。
}

if(!empty($where_six_label))
{
    $wheresixtab= ' (ld_tranlabel.tabid=6  and ( '.$where_six_label.') )';
    $wheretab=$wheresixtab;
}
if(!empty($where_four_label))
{
    $wherefourtab=' ( ld_tranlabel.tabid=4 and '.$where_four_label;
    if(!empty($where_six_label))
    {
            $wherefourtab.=' ) or '.$wheresixtab;//or左右两边都有空格。
            
    }
    else
    {
        $wherefourtab.=')';
    }
    $wheretab=$wherefourtab; 
}

if(!empty($wheretab)){
    $sql.=' and ( '.$wheretab.' )';
}

$fieldlabel_result=$adb->pquery($sql);
for($i=0;$i<$adb->num_rows($fieldlabel_result);$i++)
{
    $tablename=$adb->query_result($fieldlabel_result,$i,'tablename');
    $columnname=$adb->query_result($fieldlabel_result,$i,'columnname');
    $tabid=$adb->query_result($fieldlabel_result,$i,'tabid');
    $tables[]=$tablename;
    $colstables[]=$tablename.'.'.$columnname.' as  '.$tablename.'_'.$columnname;//防止字段名称重复
    $cols[]=$tablename.'_'.$columnname;
    $tablecols[$tablename.'_'.$columnname]=$tabid;
    $colswhere[]=$tablename.'.'.$columnname<>'\'\'';
}
$selectcols=implode(',',$colstables);

$colswhere=implode(' or ',$colswhere);//or左右两边都有空格。
if(!empty($select_options)) {
    switch ($pmodule) {
        case 'Accounts':
            $query = "select distinct ld_account.accountname,$selectcols";
            if (in_array('ld_contactdetails', $tables))
                $query .= " ,ld_contactdetails.lastname,ld_contactdetails.email ";

            $query .= " from ld_account left join ld_accountscf on ld_account.accountid=ld_accountscf.accountid";
            if (in_array('ld_contactscf', $tables)) {
                $query .= " LEFT JOIN ld_contactdetails con3 on con3.accountid = ld_account.accountid
                           LEFT JOIN ld_contactscf on ld_contactscf.contactid = con3.contactid";
            }
            //19054: 客户>明细>关联创建：发送邮件，勾选公司Email字段，结果：发送邮件弹出层，显示了三遍公司Email。
            if (in_array('ld_contactdetails', $tables))
                $query .= " left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid";

            $query .= " where ld_account.accountid in ($select_options)    ";
            if (in_array('ld_contactdetails', $tables))
                $query .= " and ld_contactdetails.deleted=0";
            //echo $query;
            $result = $adb->query($query);
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                foreach ($cols as $database_columnname) {
                    $emailname = $adb->query_result($result, $i, $database_columnname);
                    if (!empty($emailname)) {

                        if ($tabid == 6) {
                            $tmptoemailstr = $adb->query_result($result, $i, $database_columnname) . '<' . $adb->query_result($result, $i, 'accountname') . '>' ;
                        } else {
                            $tmptoemailstr = $adb->query_result($result, $i, $database_columnname) . '<' . $adb->query_result($result, $i, 'lastname') . '>' ;
                        }
                        if (!in_array($tmptoemailstr, $parent_name_textarea_email_arr)) {
                            $toemailstr .= $tmptoemailstr. "\r\n";
                            $parent_name_textarea_email_arr[] = $tmptoemailstr;
                        }
                    }

                }

            }
            break;
        case 'Contacts':
            $query = "select lastname,email from ld_contactdetails where contactid in ($select_options) and email<>'' and emailoptout=0";
            $result = $adb->query($query);
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                $tmptoemailstr = $adb->query_result($result, $i, 'email') . '<' . $adb->query_result($result, $i, 'lastname') . '>' ;
                if (!in_array($tmptoemailstr, $parent_name_textarea_email_arr)) {
                    $toemailstr .= $tmptoemailstr. "\r\n";
                    $parent_name_textarea_email_arr[] = $tmptoemailstr;
                }
            }
    }
/**
 *end
 **/
}



$image_path = 'themes/'.$theme.'/images/';
$smarty = new lingdangCRM_Smarty;
//$current_module_string=return_module_language($current_language,$currentModule);

$smarty->assign('TOEMAIL',$toemailstr);
$customView = new CustomView($currentModule);
if($_REQUEST['viewname'])
    $viewid=$_REQUEST['viewname'];
else
    $viewid = $customView->getViewId($currentModule);
if(is_admin($current_user)){
  $is_admin='yes';  
}
else{
    $is_admin='no';
}
$smarty->assign("IS_ADMIN",$is_admin);
$edit_permit = $customView->isPermittedCustomView($viewid,'Edit',$currentModule);
$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);
//print_r($customView->getViewNameDetail($viewid));
$customView->getViewDetailInfo($viewid);
$smarty->assign('VIEWNAME',$customView->getViewNameDetail($viewid));
$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 
$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category);

$smarty->assign('CUSTOMVIEW_HTML',$customview_html);
$smarty->assign("VIEWID", $viewid);
$smarty->assign("THEME", $theme);
//$smarty->assign('MOD',$current_module_string);
$smarty->assign('APP',$app_strings);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign('MODULE',$_REQUEST['module']);
if($languageType=='zh')
    $smarty->assign('MASSEMAILS',$app_strings['MassEmails']);
else
    $smarty->assign('MASSEMAILS',getFixedLabel('BULKMAIL'));
$smarty->assign('ACTION','GroupEmail');
$smarty->assign('CATEGORY','Marketing');
$smarty->assign("UPLOADSIZE", $upload_maxsize/1000000); // Convert to MB
$smarty->assign("UPLOAD_MAXSIZE",$upload_maxsize); //add by kara
if(empty($pmodule))$pmodule = $currentModule;
$smarty->assign('RETURN_MODULE',$pmodule);
$smarty->assign('PARENTTAB',$_REQUEST['parenttab']);
//发件地址
$query='select mail_username from ld_mail_accounts where user_id='.$current_user->id;

$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$frommail=array();
if($num_rows>0){
    //BUG20241129-39 ls 241202 	kfbcrm--群发短信报错
    for($i=0;$i<$num_rows;$i++)
    {
        $mail_username = $adb->query_result($result,$i,'mail_username');
        $frommail[$mail_username]='';
    }
}
$query="select server_username from ld_systems where server_type='email'";

$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows>0){
    for($i=0;$i<$num_rows;$i++)
    {
        $server_username = $adb->query_result($result,$i,'server_username');
        $frommail[$server_username]='';
    }
}
/**
更新操作
edit:cdw
date:20131128
reason:营销界面群发邮件功能改进
**/
$sql_accounttype_SMS = "";
$sql_accounttype_SMS .= " select ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename ";
$sql_accounttype_SMS .= " from ld_field inner join ld_tranlabel  ";
$sql_accounttype_SMS .= " on ld_field.fieldid = ld_tranlabel.relateid ";
$sql_accounttype_SMS .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=6 or ld_tranlabel.tabid=4) and uitype = 13 and ld_field.presence<>1 order by tabid desc ";
$accounttype_SMS_result = $adb->pquery($sql_accounttype_SMS,array($languageType,'ld_field'));
$num_rows=$adb->num_rows($accounttype_SMS_result);
$accounttype_SMS = array();
for($i=0;$i<$num_rows;$i++)
{
    $tabname=$adb->query_result($accounttype_SMS_result,$i,'name');

    $accounttype_SMS[]=array(
    'tabid'=>$adb->query_result($accounttype_SMS_result,$i,'tabid'),
    'fieldlabel'=>$adb->query_result($accounttype_SMS_result,$i,'fieldlabel'),
    'tablename'=>$adb->query_result($accounttype_SMS_result,$i,'tablename'),
    'newchinesename'=>$adb->query_result($accounttype_SMS_result,$i,'newchinesename')
    
    );
}
$html_accounttype_SMS = "";
for($i=0;$i<$num_rows;$i++)
{
   // $account_SMS[$i]['fieldlabel']
   /**
    * 从tabid中获取模块名
    * @reason 0012762: 群发邮件界面：请选择Email弹出层中，"联系人：公司email"标签不正确，应该是“客户：公司Email”
    * @author Tujt 2014-12-03
    */
   $emailmodule = 'Accounts';
   if($accounttype_SMS[$i]['tabid'] > 0){
		$emailmodule = getTabname($accounttype_SMS[$i]['tabid']);
   }
   
    if($i==0)
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' checked='checked' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
    else
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
}
$smarty->assign("html_accounttype_SMS",$html_accounttype_SMS);
$smarty->assign("num_rows",$num_rows);
if(isset($_REQUEST['account_detail']) && $_REQUEST['account_detail']!="")
{
    $request_email = $_REQUEST['account_detail'];
    $request_email = explode(";;",$request_email);
    $num=sizeof($request_email);
    $allinfo="";
    if($request_email[sizeof($request_email)]=="")
    {
        array_pop($request_email);
    }

    $num_of_info = sizeof($request_email);
    //print_r($num_of_info);//2
    
    for($i=0;$i<$num_of_info;$i++)
    {
        $tmpallinfo=$request_email[$i]."<".$request_email[$i+1].">";
        if(!in_array($tmpallinfo,$parent_name_textarea_email_arr)){
            $allinfo.=$tmpallinfo."\r";
            $parent_name_textarea_email_arr[] = $tmpallinfo;
        }
        $i++;
    }
    $smarty->assign("request_email",$allinfo);
}

/**
更新操作
edit：cdw
date：20131127
reason：客户联系人序时簿页面群发短信改进
**/
if(isset($_REQUEST['result']) &&$_REQUEST['result']!="")
{
   
	/**
	 * 传json格式过来，解析后循环出来
	 * @reason 0012733 客户叙事簿界面：群发短信-无法把联系人手机号码带出来
	 * @author Tujt 2014-12-02
	 */
	$fieldid = $_REQUEST['result'];
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->decode($fieldid);
	foreach($jsonentity as $mobile=>$name){
        $tmpallinfo = $mobile.'<'.$name.">";
        if(!in_array($tmpallinfo,$parent_name_textarea_email_arr)){
            $allinfo.=$tmpallinfo."\r";
            $parent_name_textarea_email_arr[] = $tmpallinfo;
        }
	}
	$smarty->assign("allinfo",$allinfo);
}
if(isset($_REQUEST['contact_detail']))
{
    $contact_detail = $_REQUEST['contact_detail'];
    $smarty->assign("contact_detail",$contact_detail);
}
if(isset($_REQUEST['account_detail']))
{
    $account_detail = $_REQUEST['account_detail'];
    //print_r($_REQUEST['account_detail']);
    $smarty->assign("account_detail",$account_detail);
}
if ($pmodule == 'Accounts')
    $num = 9;
elseif ($pmodule == 'Contacts')
    $num = 80;
$allids = '';
if (isset($_REQUEST['allids']) && $_REQUEST['allids'] != '')
    $allids = $_REQUEST['allids'];
$records = explode(',', $allids);
foreach ($records as $record) {
    $parentid .= $record . '@' . $num . '|';
}
if (count($records) > 1)
    $parentid = mb_substr($parentid, 0, strlen($parentid) - 1, $default_charset);
/***
更新操作
edit：cdw
date：20131209
reason：替换通配符，客户的群发邮件
***/
if(isset($_REQUEST['tabid_fieldlabel_listview_email']) && isset($_REQUEST['accountid_listview_email']))
{
 
    $tabid_fieldlabel_listview_email = $_REQUEST['tabid_fieldlabel_listview_email'];
    $accountid_listview_email = $_REQUEST['accountid_listview_email'];
    $smarty->assign("accountid_listview_email",$accountid_listview_email);
    $smarty->assign("tabid_fieldlabel_listview_email",$tabid_fieldlabel_listview_email);
	/**
	 * 客户列表页面全部客户群发邮件处理
	 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
	 * @author Tujt 2014-11-18
	 */
	if($accountid_listview_email == 'all'){//全选
		$return_module = $_REQUEST['return_module'];
		$allmodulequery = '';
		$allmodulequery = $_SESSION[$return_module.'_listquery'];//客户列表页面sql
		//客户所选择的邮件字段，在Acoounts/checkbox_check_email.php页面赋值
		$emailfld = $_SESSION[$return_module.'_sendmail_field'];
		if(!empty($allmodulequery)){
			$allmodulequery = strtolower($allmodulequery);//sql转换成小写，方便处理
			//获取left join的语句， 前面的全都去掉
			$pos = strpos($allmodulequery,'from ld_account')+strlen('from ld_account');
			$allmodulequery = substr($allmodulequery,$pos,strlen($allmodulequery));
		}
		$emailfldarr = explode(',',$emailfld);
		$email_join_tab = array();
		$table_index_array = array(
			'ld_accountscf'=>'ld_accountscf.accountid = ld_account.accountid ',
			
			'ld_contactdetails'=>'ld_contactdetails.accountid = ld_account.accountid ',
			'ld_contactscf'=>'ld_contactdetails.contactid = ld_contactscf.contactid ',
		);
		//循环email字段，判断是否有字段所属表未join进来
		$emailsql = '';$email_fori = 1;
		foreach($emailfldarr as $email_fld_val){
			if(empty($email_fld_val)) continue;
			$email_fld_val = strtolower($email_fld_val);
			$email_fld_arr = explode('.',$email_fld_val);
			$emailsql .= $email_fld_val.' as email'.($email_fori ++).',';
			if($email_fld_arr[0] == 'ld_contactdetails') continue;//过滤掉ld_contactdetails表，保证联系人主表在cf自定义表之前
			if(isset($email_join_tab[$email_fld_arr[0]])) continue;
			if(!empty($allmodulequery) && !stripos($allmodulequery,''.$email_fld_arr[0].' ')){//主表sql中未关联
				$email_join_tab[$email_fld_arr[0]] = 1;
				if(!isset($table_index_array[$email_fld_arr[0]])) continue;
				$allmodulequery = 'left join '.$email_fld_arr[0].' on '.$table_index_array[$email_fld_arr[0]].$allmodulequery;
			}
		}
		if(!empty($allmodulequery) && stripos($allmodulequery,'ld_contactscf ') && !stripos($allmodulequery,'left join ld_contactdetails ')){//如果关联了ld_contactscf但未关联ld_contactdetails，关联一下
			$allmodulequery = 'left join ld_contactdetails on '.$table_index_array['ld_contactdetails'].$allmodulequery;
		}else if(!empty($allmodulequery) && !stripos($allmodulequery,'left join ld_contactdetails ')){
			$allmodulequery = 'left join ld_contactdetails on '.$table_index_array['ld_contactdetails'].$allmodulequery;
		}
		//去掉limit分页
		if(!empty($allmodulequery)){
			$allmodulequeryarr = explode('limit',$allmodulequery);
			$allmodulequeryarr1 = explode(')',$allmodulequeryarr[1]);
			array_shift($allmodulequeryarr1);//删除第一个元素(分页信息，譬如 0,20)
			$allmodulequery = $allmodulequeryarr[0].')'.join(')',$allmodulequeryarr1);//将其余的sql重新用)组装一下
			//$allmodulequery = $allmodulequeryarr[0].')'.$allmodulequeryarr1[1];
		}
		$emailsql = trim($emailsql,',');
		if(!empty($allmodulequery)){
			$allmodulequery = 'select ld_account.accountname as emailname,'.$emailsql.' from ld_account '.$allmodulequery;
		}else{
			$allmodulequery = 'select ld_account.accountname as emailname,'.$emailsql.' from ld_account 
									left join ld_accountscf 
										on ld_accountscf.accountid = ld_account.accountid 
									left join ld_contactdetails 
										on ld_contactdetails.accountid = ld_account.accountid 
									left join ld_contactscf 
										on ld_contactscf.contactid = ld_contactdetails.contactid 
								where ld_account.deleted = 0 ';
		}
		if(!empty($allmodulequery) && $email_fori > 0){//sql组装完成，email字段数组不为空
			$allmoduleresult = $adb->pquery($allmodulequery,array());
			$allmodulerows = $adb->num_rows($allmoduleresult);
			if($allmodulerows > 0){
				$email_value_array = array();
				for($i=0;$i<$allmodulerows;++ $i){
				    for($j=1;$j<$email_fori;++ $j){
				        $email_value = $adb->query_result($allmoduleresult,$i,'email'.$j);
						if(!empty($email_value) && !isset($email_value_array[$email_value])){
							$email_value_array[$email_value] = 1;
							$email_name = $adb->query_result($allmoduleresult,$i,'emailname');
							if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$email_value)!=0)
								$allinfo .= $email_value."<".$email_name.">\r";
						}
				    }
				}
			}
		}
	}
}


/****
更新操作
edit：cdw
date：20131209
reason：替换通配符，联系人的群发邮件
***/
if(isset($_REQUEST['contact_email_tabid_fieldlabel']) && isset($_REQUEST['allids']))
{
    //print_r($_REQUEST['contact_email_tabid_fieldlabel']);
    //print_r($_REQUEST['allids']);
    $contact_email_tabid_fieldlabel = $_REQUEST['contact_email_tabid_fieldlabel'];
    $allids = $_REQUEST['allids'];
    $smarty->assign("contact_email_tabid_fieldlabel",$contact_email_tabid_fieldlabel);
    $smarty->assign("contactid",$allids);
	/**
	 * 联系人列表页面全部联系人群发邮件处理
	 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
	 * @author Tujt 2014-11-18
	 */
	if($allids == 'all'){
		$return_module = $_REQUEST['return_module'];
		/*$allmodulequery = $_SESSION[$return_module.'_listquery'];//客户列表页面sql
		$allmodulequery = strtolower($allmodulequery);//sql转换成小写，方便处理
		//获取left join的语句， 前面的全都去掉
		$pos = strpos($allmodulequery,'from ld_contactdetails')+strlen('from ld_contactdetails');
		$allmodulequery = substr($allmodulequery,$pos,strlen($allmodulequery));*/
		//客户所选择的邮件字段，在Acoounts/checkbox_check_email.php页面赋值
		$emailfld = $_SESSION[$return_module.'_sendmail_field'];
		$emailfldarr = explode(',',$emailfld);
		$allmodulequery_left = '';
		$email_join_tab = array();
		$table_index_array = array(
			'ld_contactscf'=>'ld_contactdetails.contactid = ld_contactscf.contactid ',
		);
		//循环email字段，判断是否有字段所属表未join进来
		$emailsql = '';$email_fori = 1;
		foreach($emailfldarr as $email_fld_val){
			if(empty($email_fld_val)) continue;
			$email_fld_val = strtolower($email_fld_val);
			$email_fld_arr = explode('.',$email_fld_val);
			$emailsql .= $email_fld_val.' as email'.($email_fori ++).',';
			if(isset($email_join_tab[$email_fld_arr[0]])) continue;
			if(!stripos($allmodulequery,''.$email_fld_arr[0].' ')){//主表sql中未关联
				$email_join_tab[$email_fld_arr[0]] = 1;
				if(!isset($table_index_array[$email_fld_arr[0]])) continue;
				$allmodulequery_left = 'left join '.$email_fld_arr[0].' on '.$table_index_array[$email_fld_arr[0]];
			}
		}
		$focus = CRMEntity::getInstance($return_module);
		$customView = CustomView::getInstance($return_module);
		$viewid = $customView->getViewId($return_module);
		$queryGenerator = new QueryGenerator($return_module, $current_user,$customView);
		$page_list_query = $queryGenerator->getQuery();
		list($page_list_query,$order_by,$order)=$queryGenerator->customview->getOrderWhere($page_list_query);
		$list_query = $queryGenerator->getQuery('',2);
		$emailsql = trim($emailsql,',');
		$allmodulequery = 'select ld_contactdetails.lastname as emailname,'.$emailsql.' from ld_contactdetails ' . $allmodulequery_left;
		$allmodulequery.=' inner join  ('.$page_list_query."" .' ) as tmp  on tmp.contactid=ld_contactdetails.contactid order by '.$order_by;
		if(!empty($allmodulequery) && $email_fori > 0){//sql组装完成，email字段数组不为空
			$allmoduleresult = $adb->pquery($allmodulequery,array());
			$allmodulerows = $adb->num_rows($allmoduleresult);
			if($allmodulerows > 0){
				$email_value_array = array();
				for($i=0;$i<$allmodulerows;++ $i){
				    for($j=1;$j<$email_fori;++ $j){
				        $email_value = $adb->query_result($allmoduleresult,$i,'email'.$j);
						if(!empty($email_value) && !isset($email_value_array[$email_value])){
							$email_value_array[$email_value] = 1;
							$email_name = $adb->query_result($allmoduleresult,$i,'emailname');
							if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$email_value)!=0)
								$allinfo .= $email_value."<".$email_name.">\r";
						}
				    }
				}
			}
		}
	}
}
//邮件模板
//zkt 20221128 管理员应该可以看到所有模板，非管理员应看到自己创建的以及公开的模板
//BUG0059166邮件模板中看不到私有模板，但是群发邮件时，却可以选择到私有模板
if(is_admin($current_user)){
    $sql = "select templateid,foldername,templatename,description,body from ld_emailtemplates order by templateid desc";
}
else{
    $sql = "select templateid,foldername,templatename,description,body from ld_emailtemplates where smcreatorid=".$current_user->id." or foldername = 'Public' order by templateid desc";
}
$result = $adb->pquery($sql, array());
$temprow = $adb->num_rows($result);
if($temprow > 0){
	for($i=0;$i<$temprow;$i++){
		$templateid = $adb->query_result($result, $i, "templateid");
		$foldername = $adb->query_result($result, $i, "foldername");
		$templatename = $adb->query_result($result, $i, "templatename");
		$description = $adb->query_result($result, $i, "description");
		$email_template[$templateid] = $templatename;
	}
}
$smarty->assign('EMAILTEPLATE',$email_template);
$to_email='';
if(isset($_REQUEST['record']) && $_REQUEST['record'] != "")
{
    $sql = "select from_email,to_email from ld_emaildetails where emailid = ?";
    $result = $adb->pquery($sql, array($_REQUEST['record']));  
    $smarty->assign('FROMEMAIL',$adb->query_result($result,0,'from_email'));
    $to_email = $adb->query_result($result,0,'to_email');
    $smarty->assign('ISJSON',$to_email);
   
    $smarty->assign('RECORDID',$_REQUEST['record']);
}
$smarty->assign("request_email",$allinfo);
$smarty->assign('PARENTID',$parentid);
$frommail[$current_user->column_fields['email1']]='selected';
$smarty->assign('FROMALLMAIL',$frommail);
if($_REQUEST['datajson']=='no'){
    $str=$smarty->display("GroupEmail.tpl");
    exit();
}
// diony 20200707 判断是否是客户001账套
include_once (globalStatic::$root_directory.'appCommon/appCommon.php');
$smarty->assign('iskehu001',isKehu001ServerPc());
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('BULKMAIL');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['toemail'] = $to_email;
$arr['special_ins'] = getFixedLabel("Up_to_six_the_number_of_files");
$str=$smarty->fetch("GroupEmail.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>