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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Emails/EditView.php,v 1.25 2005/04/18 10:37:49 samk Exp $
 * Description: TODO:  To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include(globalStatic::$root_directory . 'include/mail/MailDb.php');
include(globalStatic::$root_directory . 'include/mail/MailAccount.php');
include(globalStatic::$root_directory . 'include/mail/MailInfo.php');
include(globalStatic::$root_directory . 'include/mail/MailRead.php');
global $theme, $adb, $current_language, $currentModule, $default_charset;
global $current_user;
require('user_privileges/user_language_' . $current_user->id . '.php');

$smarty = new lingdangCRM_Smarty();
setGLobalURLSmarty($smarty);
$mailaccountid = $_REQUEST['mailaccountid'];
$mailaccountobj = new MailAccount();
$mailaccountinfos = $mailaccountobj->getMailAccountInfo();


$smarty->assign("MAILACCOUNT", $mailaccountinfos);
$smarty->assign("SELECTMAILACCOUNTID", $mailaccountid);

$mailrecorid = $_REQUEST['mailrecordid'];
$content = "";
$fileinfos['path'] = 'dataCache/';
$version_info = getVersionInfo();
// @edit:dong @date:2020/09/16 @reason:  dataCache目录会被清除缓存清除
if($version_info['account'] == 'langjie'){
    $fileinfos['path'] = 'storage/downCacheFile/';
}

$fileinfos['filename'] = $_REQUEST['attachment'];
if ($_REQUEST['attachment'] && $_REQUEST['attachment'] != "") {
    if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {

        $filesize = filesize($fileinfos['path'] . $fileinfos['filename']);
    } else
        $filesize = filesize($fileinfos['path'] . mb_convert_encoding($fileinfos['filename'], 'GBK', 'auto'));
    $str = ceil($filesize / 1024);
    $str .= 'k';
    $files[] = array('file_name' => $fileinfos['filename'], 'file_size' => $str
                     , 'file_type' => '', 'file_path' => $fileinfos['path'], 'newfile_name' => $fileinfos['filename']
                     , 'fileid' => '');

    $smarty->assign("ATTACHMENTINFO", json_encode($files));
}
//朗捷特殊控制 报关表单导出带入发送邮件标题（默认为报关日期 + 订单类型 可自行修改调整）

if($version_info['account'] =='langjie'){
    $smarty->assign("VERSION_ACCOUNT", $version_info['account']);
    if ($_REQUEST['emailtitle'] && $_REQUEST['emailtitle'] != "") {
        $smarty->assign("SUBJECT", $_REQUEST['emailtitle']);
    }

    $emailFilePath ='storage/langjieEmailAddress.txt';
    if(!file_exists($emailFilePath)){
        file_put_contents($emailFilePath,'');
    }else{
        $emailAddress = file_get_contents($emailFilePath);
        $smarty->assign("EMAILADDRESS", $emailAddress);
    }
    if ($_REQUEST['fromModule'] && $_REQUEST['fromModule'] != "") {
        unset($_SESSION['Email']['fromModule']);
        $smarty->assign("fromModule",$_REQUEST['fromModule']);
        $_SESSION['Email']['fromModule'] = $_REQUEST['fromModule'];
    }
}

$request_idlist = '';
if(isset($_REQUEST['idlist']) && !empty($_REQUEST['idlist'])){
    $request_idlist = $_REQUEST['idlist'];
}
$request_field_lists = '';
if(isset($_REQUEST['field_lists']) && !empty($_REQUEST['field_lists'])){
    $request_field_lists = $_REQUEST['field_lists'];
}
if (trim($request_idlist, ',') != '' && trim($request_field_lists, ',') != '') {

    $sql = 'select setype from ld_crmentity where crmid in( ' . trim($request_idlist, ',') . ')  limit 1';

    $crmentityresult = $adb->pquery($sql, array());
    $frommodule = $adb->query_result($crmentityresult, 0, 'setype');
    $field_list = $request_field_lists;

    //36305: 客户详情界面，左边相关信息 邮件管理-发送邮件，无法带出联系人的email
    if (stripos($field_list, ':') !== false) {
        $field_lists = explode(':', $field_list);
        $field_list = implode(',', $field_lists);
    }
    $sql = 'select GROUP_CONCAT(concat(tablename,".",columnname)) as columns,group_concat(columnname) as columnnames
     from ld_field where fieldid in( ' . $field_list . ')';
    $result = $adb->pquery($sql, array());

    $columns = $adb->query_result($result, 0, 'columns');
    $columnnames = $adb->query_result($result, 0, 'columnnames');

    if ($frommodule == 'Accounts') {
        $sql = 'select distinct ' . $columns
            . ' from ld_account
                left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid
                 left join ld_contactdetails  on ld_account.accountid=ld_contactdetails.accountid
                left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
      
                where ld_account.accountid in(' . $_REQUEST['idlist'] . ')';
//  ls 2021-11-11  0048693: （81mis.com/kfbcrm/index.php）客户单据XSXS1028003、yhaic619详情，相关信息中点击邮箱管理发送邮件时，邮箱地址无法带入收件人(有些客户可能没有联系人或者有联系人但是没有设置首要联系人，故不合理，应该去掉)

    } else {
        $sql = 'select ' . $columns . ' from ld_contactdetails left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
                 where ld_contactdetails.contactid in(' . $_REQUEST['idlist'] . ')';


    }
   

    $result = $adb->pquery($sql, array());
    $rows = $adb->num_rows($result);
    $tmpcolumnnames = explode(",", $columnnames);
    $emails = array();
    for ($i = 0; $i < $rows; $i++) {
        foreach ($tmpcolumnnames as $tmpcolumnname) {
            $emailvalue = $adb->query_result($result, $i, $tmpcolumnname);
            if (!empty($emailvalue) && stripos($emailvalue, '@') !== false) {
                //edit:can 20211206 049071: （https://www.51mis.com/hy/DGEWHF/ [^]）客户管理->客户->武汉启诚生物技术有限公司->单据详情的相关信息->邮件管理->发送邮件，公司和联系人全部勾选，收件人出现了重复的收件邮箱。
                if(!in_array($emailvalue,$emails))
                    $emails[] = $emailvalue;
            }
        }
    }

    $smarty->assign("MTO", implode(";", $emails));
} else if ($_REQUEST['fromid'] > 0 & $_REQUEST['fieldname'] != '') {
    //明细界面邮件字段发送邮件
    $fromid = $_REQUEST['fromid'];
    $fromModule = $_REQUEST['frommodule'];
    $fieldname = $_REQUEST['fieldname'];
    $fromfocus = CRMEntity::getInstance($fromModule);
    $fromfieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
    // @edit:dong @date:2020/09/22 @reason: bug 0042674 服务收费管理模块>单据详情界面：点击“Email链接”
    if (($fromModule == 'Accounts' || $fromModule == 'ServiceCharge') && !in_array($fromfieldinfo->getTableName(), $fromfocus->tab_name)) {
        $sql = 'select ' . $fromfieldinfo->getTableName() . '.' . $fromfieldinfo->getColumnName()
            . ' from ld_account inner join ld_contactdetails  on ld_account.accountid=ld_contactdetails.accountid
                left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
                where ld_account.accountid=? and ld_contactdetails.deleted = 0';

    } else {
        $a = $fromfieldinfo->getTableName();

        $sql = 'select ' . $fromfieldinfo->getColumnName() . ' from ' . $fromfieldinfo->getTableName() . ' where ' . $fromfocus->tab_name_index[$fromfieldinfo->getTableName()] . '=?';

    }

    $result = $adb->pquery($sql, array($fromid));
//    0043135: （51mis.com.cn/XS/smy）采购管理-采购订单-详情(深明阳电子)；单据编号PO2011332，在该单据详情点击供联Email：；跳转到邮件管理界面报错(引用字段 勾选 保存到数据库 才正常带出值 savedatabase)
    $num_rows=$adb->num_rows($result);
    if ($num_rows >= 1) {
        $smarty->assign("MTO", $adb->query_result($result, 0, 0));
    }


}
$smarty->assign('CONTENT', $content);
$smarty->assign("EMAILPAGETYPE", 'pop');
$smarty->display('send_email.tpl');

exit();

require_once("include/Zend/Json.php");

global $app_list_strings;
global $current_user;
global $currentModule;
global $default_charset;
require('user_privileges/user_language_' . $current_user->id . '.php');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$json = new Zend_Json();
$smarty->display("send_email.tpl");


$smarty->assign("UPLOADSIZE", $upload_maxsize / 1000000); // Convert to MB
$smarty->assign("UPLOAD_MAXSIZE", $upload_maxsize); //add by kara
if ($_REQUEST['upload_error'] == true) {
    echo '<br><b><font color="red"> The selected file has no data or a invalid file.</font></b><br>';
}
setGLobalURLSmarty($smarty);
//Email Error handling
if ($_REQUEST['mail_error'] != '') {
    require_once("modules/Emails/mail.php");
    echo parseEmailErrorString($_REQUEST['mail_error']);
}
//added to select the module in combobox of compose-popup
if (isset($_REQUEST['par_module']) && $_REQUEST['par_module'] != '') {
    $smarty->assign('select_module', vtlib_purify($_REQUEST['par_module']));
} elseif (isset($_REQUEST['pmodule']) && $_REQUEST['pmodule'] != '') {
    $smarty->assign('select_module', vtlib_purify($_REQUEST['pmodule']));
}
if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'], "Emails");
    $query = 'select idlists,from_email,to_email,cc_email,bcc_email from ld_emaildetails where emailid =?';
    $result = $adb->pquery($query, array($focus->id));
    $from_email = $adb->query_result($result, 0, 'from_email');
    $smarty->assign('FROM_MAIL', $from_email);
    $to_email = implode(',', $json->decode($adb->query_result($result, 0, 'to_email')));
    $smarty->assign('TO_MAIL', $to_email);
    if ($_REQUEST["forward"] == "true") {
        $smarty->assign('TO_MAIL', '');
    }

    $cc_add = implode(',', $json->decode($adb->query_result($result, 0, 'cc_email')));
    $smarty->assign('CC_MAIL', $cc_add);
    $bcc_add = implode(',', $json->decode($adb->query_result($result, 0, 'bcc_email')));
    $smarty->assign('BCC_MAIL', $bcc_add);
    $idlist = $adb->query_result($result, 0, 'idlists');
    $smarty->assign('IDLISTS', $idlist);
    $focus->name = $focus->column_fields[$focus->list_link_field];
} elseif (isset($_REQUEST['sendmail']) && $_REQUEST['sendmail'] != '') {

    $mailids = get_to_emailids($_REQUEST['pmodule']);
    if ($mailids['mailds'] != '') {
        $to_add = trim($mailids['mailds'], ",");
    }

    $smarty->assign('TO_MAIL', $to_add);
    $smarty->assign('IDLISTS', $mailids['idlists']);
    $focus->mode = '';
} elseif (!empty($_REQUEST['fromid'])) {
    //	0027407: 发送邮件添加附件时应该可以自动添加收件人信息
    $to_mail_val = get_to_emailids_for_record($_REQUEST['fromid']);
    $smarty->assign('TO_MAIL', implode(';', $to_mail_val));
}
// INTERNAL MAILER
if ($_REQUEST["internal_mailer"] == "true") {

    $smarty->assign('INT_MAILER', "true");
    $rec_type = $_REQUEST["type"];
    $rec_id = $_REQUEST["rec_id"];
    $fieldname = $_REQUEST["fieldname"];

    //added for getting list-ids to compose email popup from list view(Accounts,Contacts,Leads)
    if (isset($_REQUEST['field_id']) && strlen($_REQUEST['field_id']) != 0) {
        if ($_REQUEST['par_module'] == "Users")
            $id_list = $_REQUEST['rec_id'] . '@' . '-1|';
        else
            $id_list = $_REQUEST['rec_id'] . '@' . $_REQUEST['field_id'] . '|';
        $smarty->assign("IDLISTS", $id_list);
    }
    if ($rec_type == "record_id") {
        $type = $_REQUEST['par_module'];
        //check added for email link in user detail view


        /*
        *更新操作
        *edit:diony
        *time:20131220
        *reson:之前发送邮件发送方法中，表名是固定的，
        *客户中增加特殊控制（首要联系人），点击发送信息，发送失败，原因是没有设定对应的表
        *所以这里改成根据模块名称和字段名称获取表名
        **/
        /*
        $normal_tabs = Array('Users'=>'ld_users', 'Leads'=>'ld_leaddetails', 'Contacts'=>'ld_contactdetails', 'Accounts'=>'ld_account', 'Vendors'=>'ld_vendor');
		$cf_tabs = Array('Accounts'=>'ld_accountscf', 'Campaigns'=>'ld_campaignscf', 'Contacts'=>'ld_contactscf', 'Invoice'=>'ld_invoicecf', 'Leads'=>'ld_leadscf', 'Potentials'=>'ld_potentialscf', 'Products'=>'lingdang_productcf',  'PurchaseOrder'=>'ld_purchaseordercf', 'Quotes'=>'ld_quotescf', 'SalesOrder'=>'ld_salesordercf', 'HelpDesk'=>'ld_ticketcf', 'Vendors'=>'ld_vendorcf');
		if(substr($fieldname,0,2)=="cf")
			$tablename = $cf_tabs[$type];
		else
			$tablename = $normal_tabs[$type];
         */

        $tabidnew = getTabid($type);
        $tablenamesql = "select tablename from ld_field where tabid = " . $tabidnew . " and fieldname = '" . $fieldname . "'";
        $tablename = $adb->query_result($adb->query($tablenamesql));
        if ($type == "Users")
            $q = "select $fieldname from $tablename where id=?";
        elseif ($type == "Leads")
            $q = "select $fieldname from $tablename where leadid=?";
        elseif ($type == "Contacts")
            $q = "select $fieldname from $tablename where contactid=?";
        elseif ($type == "Accounts")
            $q = "select $fieldname from $tablename where accountid=?";
        elseif ($type == "Vendors")
            $q = "select $fieldname from $tablename where vendorid=?";
        elseif ($type == "VendorContact")
            $q = "select $fieldname from $tablename where vendorcontactsid=?";
        else {
            // vtlib customization: Support for email-type custom field for other modules.
            $module_focus = CRMEntity::getInstance($type);
            vtlib_setup_modulevars($type, $module_focus);
            if (!empty($module_focus->customFieldTable)) {
                $q = "select $fieldname from " . $module_focus->customFieldTable[0] . " where " . $module_focus->customFieldTable[1] . "= ?";
            }
            // END
        }
        $email1 = $adb->query_result($adb->pquery($q, array($rec_id)), 0, $fieldname);
    } elseif ($rec_type == "email_addy") {
        $email1 = $_REQUEST["email_addy"];
    }

    $smarty->assign('TO_MAIL', trim($email1, ",") . ",");
}

//handled for replying emails
if ($_REQUEST['reply'] == "true") {
    $fromadd = $_REQUEST['record'];
    $query = "select from_email,idlists,cc_email,bcc_email,to_email from ld_emaildetails where emailid =?";
    $result = $adb->pquery($query, array($fromadd));
    $from_mail = $adb->query_result($result, 0, 'from_email');

    $to_email = implode(',', $json->decode($adb->query_result($result, 0, 'to_email')));
    /**
     * edit:kevin
     * date:2013-05-27
     * reason:3901
     */
    //$smarty->assign('TO_MAIL',trim($from_mail,",").',');
    $smarty->assign('TO_MAIL', $to_email);
    $cc_add = implode(',', $json->decode($adb->query_result($result, 0, 'cc_email')));
    $smarty->assign('CC_MAIL', $cc_add);
    $bcc_add = implode(',', $json->decode($adb->query_result($result, 0, 'bcc_email')));
    $smarty->assign('BCC_MAIL', $bcc_add);
    $smarty->assign('IDLISTS', preg_replace('/###/', ',', $adb->query_result($result, 0, 'idlists')));
}

// Webmails
if (isset($_REQUEST["mailid"]) && $_REQUEST["mailid"] != "") {
    $mailid = $_REQUEST["mailid"];
    $mailbox = $_REQUEST["mailbox"];
    require_once('include/utils/UserInfoUtil.php');
    require_once("modules/Webmails/Webmails.php");
    require_once("modules/Webmails/MailParse.php");
    require_once('modules/Webmails/MailBox.php');

    $mailInfo = getMailServerInfo($current_user);
    $temprow = $adb->fetch_array($mailInfo);

    $MailBox = new MailBox($mailbox);
    $mbox = $MailBox->mbox;

    $webmail = new Webmails($mbox, $mailid);
    $array_tab = array();
    $webmail->loadMail($array_tab);
    $hdr = @imap_headerinfo($mbox, $mailid);
    $smarty->assign('WEBMAIL', "true");
    $smarty->assign('mailid', $mailid);
    $smarty->assign('mailbox', $mailbox);
    $temp_id = $MailBox->boxinfo['mail_id'];
    $smarty->assign('from_add', $temp_id);
    $webmail->subject = utf8_decode(utf8_encode(imap_utf8($webmail->subject)));
    if ($_REQUEST["reply"] == "all") {

        $smarty->assign('TO_MAIL', $webmail->from . ",");
        //added to remove the emailid of webmail client from cc list....to fix the issue #3818
        $cc_address = '';

        $use_to_header = htmlentities($webmail->to_header, ENT_QUOTES, $default_charset);
        $use_cc_address = htmlentities($hdr->ccaddress, ENT_QUOTES, $default_charset);

        $cc_array = explode(',', $use_to_header . ',' . $use_cc_address);
        for ($i = 0; $i < count($cc_array); $i++) {
            if (trim($cc_array[$i]) != trim($temp_id)) {
                $cc_address .= $cc_array[$i];
                $cc_address = ($i != (count($cc_array) - 1)) ? ($cc_address . ',') : $cc_address;
            }
        }
        if (trim($cc_address) != '')
            $cc_address = trim($cc_address, ",") . ",";
        $smarty->assign('CC_MAIL', $cc_address);
        // fix #3818 ends
        /*if(is_array($webmail->cc_list))
        {
            $smarty->assign('CC_MAIL',implode(",",$webmail->cc_list).",".implode(",",$webmail->to));
        }
        else
        {
            //Commenting this to fix #3231
        //	$smarty->assign('CC_MAIL',implode(",",$webmail->to));
        }*/
        if (preg_match("/RE:/i", $webmail->subject))
            $smarty->assign('SUBJECT', $webmail->subject);
        else
            $smarty->assign('SUBJECT', "RE: " . $webmail->subject);

    } elseif ($_REQUEST["reply"] == "single") {
        $replyToInfo = $webmail->getReplyToInformation();
        if (!empty($replyToInfo)) {
            $smarty->assign('TO_MAIL', $replyToInfo['name'] . "<" . $webmail->reply_to[0] . ">" . ",");
            $smarty->assign('IDLISTS', $replyToInfo['id'] . '@' . $replyToInfo['fieldId'] . '|');
        } else
            $smarty->assign('TO_MAIL', $replyToInfo['name'] . "<" . $webmail->reply_to[0] . ">" . ",");

        //$smarty->assign('BCC_MAIL',$webmail->to[0]);
        if (preg_match("/RE:/i", $webmail->subject))
            $smarty->assign('SUBJECT', $webmail->subject);
        else
            $smarty->assign('SUBJECT', "RE: " . $webmail->subject);

    } elseif ($_REQUEST["forward"] == "true") {
        //added for attachment handling

        $attachment_links = array();
        for ($i = 0; $i < count($webmail->attname); $i++) {
            $attachment_links[$i] = $webmail->anchor_arr[$i] . decode_header($webmail->attname[$i]) . "</a></br>";
        }
        $smarty->assign('webmail_attachments', $attachment_links);

        if (preg_match("/FW:/i", $webmail->subject))
            $smarty->assign('SUBJECT', $webmail->subject);
        else
            $smarty->assign('SUBJECT', "FW: " . $webmail->subject);
    }
    $smarty->assign('DESCRIPTION', $webmail->replyBody());
    $focus->mode = '';
}

global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$disp_view = getView($focus->mode);

$details = getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign('PRINTID', $_REQUEST['printid']);


//changed this below line to view description in all language - bharath
if ($languageType == 'en')
    $smarty->assign("BLOCKS", $details['Custom Information']);
else
    $smarty->assign("BLOCKS", $details[getFixedLabel('EMAILINFO')]);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", getFixedLabel('EMAIL'));
//id list of attachments while forwarding
$smarty->assign("ATT_ID_LIST", $att_id_list);

//needed when creating a new email with default values passed in
if (isset($_REQUEST['contact_name']) && is_null($focus->contact_name)) {
    $focus->contact_name = vtlib_purify($_REQUEST['contact_name']);
}
if (isset($_REQUEST['contact_id']) && is_null($focus->contact_id)) {
    $focus->contact_id = vtlib_purify($_REQUEST['contact_id']);
}
if (isset($_REQUEST['parent_name']) && is_null($focus->parent_name)) {
    $focus->parent_name = vtlib_purify($_REQUEST['parent_name']);
}
if (isset($_REQUEST['parent_id']) && is_null($focus->parent_id)) {
    $focus->parent_id = vtlib_purify($_REQUEST['parent_id']);
}
if (isset($_REQUEST['parent_type'])) {
    $focus->parent_type = vtlib_purify($_REQUEST['parent_type']);
}
if (isset($_REQUEST['filename']) && $_REQUEST['isDuplicate'] != 'true') {
    $focus->filename = vtlib_purify($_REQUEST['filename']);
} elseif (is_null($focus->parent_type)) {
    $focus->parent_type = $app_list_strings['record_type_default_key'];
}

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");


if ($focus->mode == 'edit') {
    //$smarty->assign("UPDATEINFO",updateInfo($focus->id));
    if (((!empty($_REQUEST['forward']) || !empty($_REQUEST['reply'])) &&
            $focus->column_fields['email_flag'] != 'SAVED') || (empty($_REQUEST['forward']) &&
            empty($_REQUEST['reply']) && $focus->column_fields['email_flag'] != 'SAVED')) {
        $mode = '';
    } else {
        $mode = $focus->mode;
    }
    $smarty->assign("MODE", $mode);
}

if (isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else $smarty->assign("RETURN_MODULE", 'Emails');
if (isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else $smarty->assign("RETURN_ACTION", 'index');
if (isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$smarty->assign("ENTITY_ID", vtlib_purify($_REQUEST["record"]));
$smarty->assign("ENTITY_TYPE", vtlib_purify($_REQUEST["email_directing_module"]));
$smarty->assign("OLD_ID", $old_id);
//Display the RTE or not? -- configure $USE_RTE in config.php
$USE_RTE = vt_hasRTE();
$smarty->assign("USE_RTE", $USE_RTE);

if (empty($focus->filename)) {
    $smarty->assign("FILENAME_TEXT", "");
    $smarty->assign("FILENAME", "");
} else {
    $smarty->assign("FILENAME_TEXT", "(" . $focus->filename . ")");
    $smarty->assign("FILENAME", $focus->filename);
}
if ($ret_error == 1) {
    require_once('modules/Webmails/MailBox.php');
    $smarty->assign("RET_ERROR", $ret_error);
    if ($ret_parentid != '') {
        $smarty->assign("IDLISTS", $ret_parentid);
    }
    if ($ret_toadd != '')
        $smarty->assign("TO_MAIL", $ret_toadd);
    $ret_toadd = '';
    if ($ret_subject != '')
        $smarty->assign("SUBJECT", $ret_subject);
    if ($ret_ccaddress != '')
        $smarty->assign("CC_MAIL", $ret_ccaddress);
    if ($ret_bccaddress != '')
        $smarty->assign("BCC_MAIL", $ret_bccaddress);
    if ($ret_description != '')
        $smarty->assign("DESCRIPTION", $ret_description);
    $temp_obj = new MailBox($mailbox);
    $temp_id = $temp_obj->boxinfo['mail_id'];
    if ($temp_id != '')
        $smarty->assign('from_add', $temp_id);
}
//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
//发件地址
$query = 'select mail_username from ld_mail_accounts where user_id=' . $current_user->id;
$result = $adb->query($query);
$num_rows = $adb->num_rows($result);
$frommail = array();
if ($num_rows) {
    foreach ($result as $mail) {
        $frommail[$mail['mail_username']] = '';
    }
}
$query = "select server_username from ld_systems where server_type='email'";

$result = $adb->query($query);
if ($adb->num_rows($result)) {
    foreach ($result as $mail) {
        $frommail[$mail['server_username']] = '';
    }
}
$frommail[$current_user->column_fields['email1']] = 'selected';

/**
 * 更新操作
 * edit：cdw
 * date：20131202
 * reason：手机、Email、QQ类型字段在查看明细界面时改进
 **/
if (isset($_REQUEST['id']) && isset($_REQUEST['fieldlabel']) && isset($_REQUEST['return_module'])) {
    $return_module = $_REQUEST['return_module'];
    $id = $_REQUEST['id'];
    $fieldlabel = $_REQUEST['fieldlabel'];
    if ($return_module == "Accounts") {
        $sql = "select tablename,columnname from ld_field where uitype = 13 and columnname = '" . $fieldlabel . "' and tabid = 6";
    } elseif ($return_module == "Contacts") {
        $sql = "select tablename,columnname from ld_field where uitype = 13 and columnname = '" . $fieldlabel . "' and tabid = 4";
    } else {
        $sql_tabid = "select tabid from ld_tab where name = '" . $return_module . "'";
        $result_tabid = $adb->pquery($sql_tabid, array());
        $tabid = $adb->query_result($result_tabid, 0, 'tabid');
        $sql = "select tablename,columnname from ld_field where uitype = 13 and columnname = '" . $fieldlabel . "' and tabid = " . $tabid . "";
    }
    $result = $adb->pquery($sql, array());
    $num = $adb->num_rows($result);
    if ($num) {
        $tablename = $adb->query_result($result, 0, 'tablename');
        $columnname = $adb->query_result($result, 0, 'columnname');
    }
    $focus = CRMEntity::getInstance($return_module);
    if ($return_module == 'Accounts') {
        if ($tablename == 'ld_account') {
            $sql_info = "select " . $columnname . ",accountname from ld_account where accountid = " . $id;
        } else if ($tablename == 'ld_accountscf') {
            $sql_info = "select " . $columnname . ",accountname from ld_account LEFT JOIN ld_accountscf 
            on ld_account.accountid = ld_accountscf.accountid where ld_account.accountid = " . $id;
        } else {
            $sql_info = "select " . $columnname . ",accountname from ld_account LEFT JOIN ld_contactdetails 
            on ld_account.accountid = ld_contactdetails.accountid where ld_account.accountid = " . $id . " LIMIT 1";
        }

        $result_info = $adb->pquery($sql_info, array());
        $num_row = $adb->num_rows($result_info);
        if ($num_row) {
            $allinfo = $adb->query_result($result_info, 0, 'accountname') . "<" . $adb->query_result($result_info, 0, $columnname) . ">;";
        }
    } elseif ($return_module == 'Contacts') {
        $sql_info = "select " . $columnname . ",lastname from " . $tablename . " where contactid = " . $id . "";
        $result_info = $adb->pquery($sql_info, array());
        $num_row = $adb->num_rows($result_info);
        if ($num_row) {
            $mail = $adb->query_result($result_info, 0, $columnname);
            $name = $adb->query_result($result_info, 0, 'lastname');
            $allinfo = $name . '<' . $mail . '>,';
        }
    } else {
        /**
         * 判断Users模块，指定主键字段名为 id
         * @reason 0011471 用户管理：查看用户界面，点击Email后面的图标，
         * 结果用户的Email没有被自动传入撰写邮件窗口收件人中
         * @author Tujt 2014-09-19
         */
        if ($return_module == 'Users') {
            $idcolumnname = 'id';
        } else {
            $idcolumnname = substr(substr($tablename, 3), 0, strlen(substr($tablename, 3)) - 3) . "id";
        }
        $idcolumnname = $focus->tab_name_index[$tablename];
        $sql_info = "select " . $columnname . " from " . $tablename . " where " . $idcolumnname . " = " . $id . "";
        $result_info = $adb->pquery($sql_info, array());
        $num_row = $adb->num_rows($result_info);
        if ($num_row) {
            $mail = $adb->query_result($result_info, 0, $columnname);
            $allinfo = '<' . $mail . '>;';
        }

    }
    $smarty->assign("allinfo", $allinfo);
}
//end
/**
 * 附件添加邮件时，显示的名称需是模块名
 * @@reason 0011749 邮件管理->收信：回复邮件时，点击【选择附件】按钮，程序没有反应
 * @author Tujt 2014-09-28
 */
if (isset($_REQUEST['attachment']) && !empty($_REQUEST['attachment'])) {
    $attachment = $_REQUEST['attachment'];
    $attachmentarr = explode('-', $attachment);
    $smarty->assign("ATTACHMENT", $attachment);
}

$smarty->assign('FROMALLMAIL', $frommail);
//$smarty->assign('FROM_EMAIL',$current_user->column_fields['email1']);

if ($_REQUEST['popup'] == 'yes') {
    $_REQUEST['diony'] = 'diony';
    $arr['title'] = getTransTab($_REQUEST['selectmodule']);
    $str = $smarty->fetch("ComposeEmail.tpl");
    $arr['content'] = $str;
    ConvertTojsonString(1, $arr, "success");
    exit();
} else {
    $smarty->display("ComposeEmail.tpl");
}

?>