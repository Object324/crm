<?php



require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class Emails extends CRMEntity {
	public $filename;
	public $parent_id;
	public $parent_type;
    static  function require_file($requiremodules='')
    {
             globalStatic::$arr_module_require['Emails']='Emails';
            if(empty(globalStatic::$arr_module_require['Contacts']))
            {
                globalStatic::$arr_module_require['Contacts']='Contacts';
                include('modules/Contacts/Contacts.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Accounts']))
            {
                 globalStatic::$arr_module_require['Accounts']='Accounts';
                include('modules/Accounts/Accounts.php');
               
            }
            if(empty(globalStatic::$arr_module_require['Potentials']))
            {
                globalStatic::$arr_module_require['Potentials']='Potentials';
                include('modules/Potentials/Potentials.php');
                
            }
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                 globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
               
            }

    }
	var $log;
	var $db;
	var $table_name = "ld_activity";
	var $table_index = 'activityid';
	// Stored lingdang_fields
	// added to check email save from plugin or not
	var $plugin_save = false;
	var $rel_users_table = "ld_salesmanactivityrel";
	var $rel_contacts_table = "ld_cntactivityrel";
	var $rel_serel_table = "ld_seactivityrel";
	var $tab_name = Array('ld_crmentity', 'ld_activity', 'ld_emaildetails');
	var $tab_name_index = Array('ld_crmentity' => 'crmid', 'ld_activity' => 'activityid',
		'ld_seactivityrel' => 'activityid', 'ld_cntactivityrel' => 'activityid', 'ld_email_track' => 'mailid', 'ld_emaildetails' => 'emailid');
    var $customFieldTable = Array('ld_emaildetails', 'emailid');//自定义字段所存储的表（快速查询）
	var $list_link_field = 'subject';
	var $column_fields = Array();
	var $sortby_fields = Array('subject', 'date_start', 'saved_toid');
	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'createdtime';
	var $default_sort_order = 'DESC';
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to lingdang_field.fieldname values.
	var $mandatory_fields = Array( 'assigned_user_id');
    
	/** This function will set the columnfields for Email module
	 */
	function __construct() {
		//$this->log = LoggerManager::getLogger('email');
		//$this->log->debug("Entering Emails() method ...");
	//	$this->log = LoggerManager::getLogger('email');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Emails',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
	//	$this->log->debug("Exiting Email method ...");
	}
    
        
	function save_module($module) {
		global $adb;
		//Inserting into seactivityrel
		//modified by Richie as raju's implementation broke the feature for addition of webmail to ld_crmentity.need to be more careful in future while integrating code
		if ($_REQUEST['module'] == "Emails" && $_REQUEST['smodule'] != 'webmails' && (!$this->plugin_save)) {
			if ($_REQUEST['currentid'] != '') {
				$actid = $_REQUEST['currentid'];
			} else {
				$actid = $_REQUEST['record'];
			}
			$parentid = $_REQUEST['parent_id'];
			if ($_REQUEST['module'] != 'Emails' && $_REQUEST['module'] != 'Webmails') {
				if (!$parentid) {
					$parentid = $adb->getUniqueID('ld_seactivityrel');
				}
				$mysql = 'insert into ld_seactivityrel(crmid,activityid) values(?,?)';
				$adb->pquery($mysql, array($parentid, $actid));
			} else {
				$myids = explode("|", $parentid);  //2@71|
				for ($i = 0; $i < (count($myids) - 1); $i++) {
					$realid = explode("@", $myids[$i]);
					$mycrmid = $realid[0];
					//added to handle the relationship of emails with ld_users
					if ($realid[1] == -1) {
						$del_q = 'delete from ld_salesmanactivityrel where smid=? and activityid=?';
						$adb->pquery($del_q, array($mycrmid, $actid));
						$mysql = 'insert into ld_salesmanactivityrel(smid,activityid) values(?,?)';
					} else {
						$del_q = 'delete from ld_seactivityrel where crmid=? and activityid=?';
						$adb->pquery($del_q, array($mycrmid, $actid));
						$mysql = 'insert into ld_seactivityrel(crmid,activityid) values(?,?)';
					}
					$params = array($mycrmid, $actid);
					$adb->pquery($mysql, $params);
				}
			}
		} else {
			if (isset($this->column_fields['parent_id']) && $this->column_fields['parent_id'] != '') {
				$adb->pquery("DELETE FROM ld_seactivityrel WHERE crmid = ? AND activityid = ? ",
						array($this->column_fields['parent_id'], $this->id));
				//$this->insertIntoEntityTable('ld_seactivityrel', $module);
				$sql = 'insert into ld_seactivityrel (crmid,activityid) values(?,?)';
				$params = array($this->column_fields['parent_id'], $this->id);
				$adb->pquery($sql, $params);
			} elseif ($this->column_fields['parent_id'] == '' && $insertion_mode == "edit") {
				$this->deleteRelation('ld_seactivityrel');
			}
		}


		//Insert into cntactivity rel

		if (isset($this->column_fields['contact_id']) && $this->column_fields['contact_id'] != '') {
			$this->insertIntoEntityTable('ld_cntactivityrel', $module);
		} elseif ($this->column_fields['contact_id'] == '' && $insertion_mode == "edit") {
			$this->deleteRelation('ld_cntactivityrel');
		}

		//Inserting into attachment
		/**
		 * 群发邮件多福建处理
		 * @author Tujt 2014-09-26
		 */
		global $groupemailattachment;
        //dump($groupemailattachment);
		if(isset($groupemailattachment) && 1 == $groupemailattachment){
			$this->insertgroupemailattachment($this->id, $module);
		}else{
			$this->insertIntoAttachment($this->id, $module);
		}
	}
	/**
	 * 群发邮件特别处理，附件只保存一次，不保存第二次
	 * @param $id Integer 当前邮件CRMID
	 * @param $module String 当前模块
	 * @returns 批量保存附件
	 * @author Tujt 2014-09-26
	 */
	function insertgroupemailattachment($id,$module) {
		global $adb;
		global $current_user;
		global $upload_badext;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
		$file_saved = false;
		if (isset($_REQUEST['pdf_attachment']) && $_REQUEST['pdf_attachment'] != '') {
			$file_saved = pdfAttach($this, $module, $pdfAttached, $id);
		}
		if(!empty($_REQUEST['groupemail-file_num']) && $_REQUEST['groupemail-file_num'] > 0){
			$file_nums = $_REQUEST['groupemail-file_num'];
			for($i = 1; $i <= 120; $i++){
			 $filename = $_REQUEST['groupemail-newfile_name_'.$i];
             if($filename=='')
                continue;
				$current_id = $adb->getUniqueID("ld_crmentity");//附件id
				$sql1 = "insert into ld_crmentity (crmid,setype) values(?, ?)";
				$params1 = array($current_id, $module . " Attachment");
				$adb->pquery($sql1, $params1);
				
				
				$filetype = $_REQUEST['groupemail-file_type_'.$i];
				$upload_file_path = $_REQUEST['groupemail-file_path_'.$i];
                
                //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                $isEncrypt = $_REQUEST['groupemail-isEncrypt_'.$i];	//是否加密
                $upload_file_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($upload_file_path) : $upload_file_path;
                $filename = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($filename) : $filename;
                
				$sql2 = "insert into ld_attachments(attachmentsid, name, description, type, path) values(?, ?, ?, ?, ?)";
				$params2 = array($current_id, $filename, $this->column_fields['description'], $filetype, $upload_file_path);
				$result = $adb->pquery($sql2, $params2);

				$sql3 = 'insert into ld_seattachmentsrel(crmid,attachmentsid) values(?,?)';
				$adb->pquery($sql3, array($id, $current_id));
			}
		}
		/*static $groupemailattachmentid;//群发邮件关联附件ID，为第一封邮件发送时保存的附件ID，附件不再保存第二次
		if(!empty($groupemailattachmentid)){//第二次开始，执行此处代码
			foreach($groupemailattachmentid as $achmentid){
				$sql3 = 'insert into ld_seattachmentsrel values(?,?)';
				$adb->pquery($sql3, array($id, $achmentid));
			}
			return true;
		}
	    $file_saved = false;
		//Added to send generated Invoice PDF with mail
		$pdfAttached = $_REQUEST['pdf_attachment'];
		//created Invoice pdf is attached with the mail
		if (isset($_REQUEST['pdf_attachment']) && $_REQUEST['pdf_attachment'] != '') {
			$file_saved = pdfAttach($this, $module, $pdfAttached, $id);
		}
		//循环保存群发邮件附件
		foreach ($_FILES as $fileindex => $files) {
			if ($files['name'] != '' && $files['size'] > 0) {
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex . '_hidden']);
				$date_var = date('Y-m-d H:i:s',time());
				$ownerid = $this->column_fields['assigned_user_id'];
				if (!isset($ownerid) || $ownerid == '')
					$ownerid = $current_user->id;
				if (isset($files['original_name']) && $files['original_name'] != null) {
					$file_name = $files['original_name'];
				} else {
					$file_name = $files['name'];
				}
				$file_name = trim($files['name']);
				//文件名的空格全部去掉，防止文件名不同意导致文件取不到 tujt 2014-09-26
				$file_name = preg_replace('/\s+/', '', $file_name);
				$binFile = sanitizeUploadFileName($file_name, $upload_badext);
				$lastfixs = explode(".",$binFile);
				$lastfix = $lastfixs[count($lastfixs)-1];
				$current_id = $adb->getUniqueID("ld_crmentity");//附件id
				$filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
				$filetype = $files['type'];
				$filesize = $files['size'];
				$filetmp_name = $files['tmp_name'];
				$upload_file_path = decideFilePath();//上传路径
				//$file_name = $current_id . "_" . $file_name;
            if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
			  {
				//获取系统类型，如果是非windows系统则不用修改编码格式
				 $upload_status = move_uploaded_file($filetmp_name,$upload_file_path.$file_name);
                
			  }
              else
				$upload_status = @move_uploaded_file($filetmp_name,mb_convert_encoding($upload_file_path.$file_name,'gb2312','UTF-8'));
				$save_file = 'true';
				if ($save_file == 'true' && $upload_status == 'true') {//上传成功，附件信息插入到数据库中
					$sql1 = "insert into ld_crmentity (crmid,setype) values(?, ?)";
					$params1 = array($current_id, $module . " Attachment");
					$adb->pquery($sql1, $params1);

					$sql2 = "insert into ld_attachments(attachmentsid, name, description, type, path) values(?, ?, ?, ?, ?)";
					$params2 = array($current_id, $filename, $this->column_fields['description'], $filetype, $upload_file_path);
					$result = $adb->pquery($sql2, $params2);

					$sql3 = 'insert into ld_seattachmentsrel values(?,?)';
					$adb->pquery($sql3, array($id, $current_id));
					$groupemailattachmentid[$current_id] = $current_id;
				} else {
				
				}
			}
		}*/
		return true;
	}
	function unicode_decode($name){
	 
	  $json = '{"str":"'.$name.'"}';
	  $arr = json_decode($json,true);
	  if(empty($arr)) return '';
	  return $arr['str'];

	}
	function insertIntoAttachment($id, $module) {
		global  $adb;
	
		$file_saved = false;

		//Added to send generated Invoice PDF with mail
		$pdfAttached = $_REQUEST['pdf_attachment'];
		//created Invoice pdf is attached with the mail
		if (isset($_REQUEST['pdf_attachment']) && $_REQUEST['pdf_attachment'] != '') {
			$file_saved = pdfAttach($this, $module, $pdfAttached, $id);
		}

		//This is to added to store the existing attachment id of the contact where we should delete this when we give new image

		foreach ($_FILES as $fileindex => $files) {
			if ($files['name'] != '' && $files['size'] > 0) {
		      
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex . '_hidden']);                
				$file_saved = $this->uploadAndSaveFile($id, $module, $files);
			}
		}
          
		if ($module == 'Emails' && isset($_REQUEST['att_id_list']) && $_REQUEST['att_id_list'] != '') {
			$att_lists = explode(";", $_REQUEST['att_id_list'], -1);
			$id_cnt = count($att_lists);
			if ($id_cnt != 0) {
				for ($i = 0; $i < $id_cnt; $i++) {
					$sql_rel = 'insert into ld_seattachmentsrel values(?,?)';
					$adb->pquery($sql_rel, array($id, $att_lists[$i]));
				}
			}
		}
		if ($_REQUEST['att_module'] == 'Webmails') {
			require_once("modules/Webmails/Webmails.php");
			require_once("modules/Webmails/MailParse.php");
			require_once('modules/Webmails/MailBox.php');
			//$mailInfo = getMailServerInfo($current_user);
			//$temprow = $adb->fetch_array($mailInfo);

			$MailBox = new MailBox($_REQUEST["mailbox"]);
			$mbox = $MailBox->mbox;
			$webmail = new Webmails($mbox, $_REQUEST['mailid']);
			$array_tab = Array();
			$webmail->loadMail($array_tab);
			if (isset($webmail->att_details)) {
				foreach ($webmail->att_details as $fileindex => $files) {
					if ($files['name'] != '' && $files['size'] > 0) {
						//print_r($files);
						$file_saved = $this->saveForwardAttachments($id, $module, $files);
					}
				}
			}
		}
		
	}

	function saveForwardAttachments($id, $module, $file_details) {
		
		global $adb, $current_user;
		global $upload_badext;
		require_once('modules/Webmails/MailBox.php');
    
		$mailbox = $_REQUEST["mailbox"];
		$MailBox = new MailBox($mailbox);
		$mail = $MailBox->mbox;
		$binFile = sanitizeUploadFileName($file_details['name'], $upload_badext);
		$filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
		$filetype = $file_details['type'];
		$filesize = $file_details['size'];
		$filepart = $file_details['part'];
		$transfer = $file_details['transfer'];
		$file = imap_fetchbody($mail, $_REQUEST['mailid'], $filepart);
		if ($transfer == 'BASE64')
			$file = imap_base64($file);
		elseif ($transfer == 'QUOTED-PRINTABLE')
			$file = imap_qprint($file);
		$current_id = $adb->getUniqueID("ld_crmentity");
		$date_var = date('Y-m-d H:i:s');
		//to get the owner id
		$ownerid = $this->column_fields['assigned_user_id'];
		if (!isset($ownerid) || $ownerid == '')
			$ownerid = $current_user->id;
		$upload_file_path = decideFilePath();
		file_put_contents($upload_file_path . $current_id . "_" . $filename, $file);

		$sql1 = "insert into ld_crmentity (crmid,smcreatorid,smownerid,setype,description,createdtime,modifiedtime) values(?,?,?,?,?,?,?)";
		$params1 = array($current_id, $current_user->id, $ownerid, $module . " Attachment", $this->column_fields['description'], $adb->formatDate($date_var, true), $adb->formatDate($date_var, true));
		$adb->pquery($sql1, $params1);

		$sql2 = "insert into ld_attachments(attachmentsid, name, description, type, path) values(?,?,?,?,?)";
		$params2 = array($current_id, $filename, $this->column_fields['description'], $filetype, $upload_file_path);
		$result = $adb->pquery($sql2, $params2);

		if ($_REQUEST['mode'] == 'edit') {
			if ($id != '' && $_REQUEST['fileid'] != '') {
				$delquery = 'delete from ld_seattachmentsrel where crmid = ? and attachmentsid = ?';
				$adb->pquery($delquery, array($id, $_REQUEST['fileid']));
			}
		}
		$sql3 = 'insert into ld_seattachmentsrel values(?,?)';
		$adb->pquery($sql3, array($id, $current_id));
		return true;
	
	}

	/** Returns a list of the associated contacts
	 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
	 * All Rights Reserved..
	 * Contributor(s): ______________________________________..
	 */
	function get_contacts($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view, $currentModule, $current_user;
		
		$this_module = $currentModule;

		$related_module = vtlib_getModuleNameById($rel_tab_id);
		require_once("modules/$related_module/$related_module.php");
		$other = new $related_module();
		vtlib_setup_modulevars($related_module, $other);
		$singular_modname = vtlib_toSingular($related_module);

		$parenttab = getParentTab();

		$returnset = '&return_module=' . $this_module . '&return_action=DetailView&return_id=' . $id;

		$button = '';

		if ($actions) {
			if (is_string($actions))
				$actions = explode(',', strtoupper($actions));
			if (in_array('SELECT', $actions) && isPermitted($related_module, 4, '') == 'yes') {
				$button .= "<input title='" . getTranslatedString('LBL_SELECT') . " " . getTranslatedString($related_module) . "' class='edit' type='button' onclick=\"return window.open('index.php?module=$related_module&return_module=$currentModule&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid=$id&parenttab=$parenttab','test','width=640,height=602,resizable=0,scrollbars=0');\" value='" . getTranslatedString('LBL_SELECT') . " " . getTranslatedString($related_module) . "'>&nbsp;";
			}
			if (in_array('BULKMAIL', $actions) && isPermitted($related_module, 1, '') == 'yes') {
				$button .= "<input title='" . getTranslatedString('LBL_BULK_MAILS') . "' class='create'" .
						" onclick='this.form.action.value=\"sendmail\";this.form.module.value=\"$this_module\"' type='submit' name='button'" .
						" value='" . getTranslatedString('LBL_BULK_MAILS') . "'>";
			}
		}

		$query = 'select ld_contactdetails.accountid, ld_contactdetails.contactid, ld_contactdetails.firstname,ld_contactdetails.lastname, ld_contactdetails.department, ld_contactdetails.title, ld_contactdetails.email, ld_contactdetails.phone, ld_contactdetails.emailoptout, ld_crmentity.crmid, ld_crmentity.smownerid, ld_crmentity.modifiedtime from ld_contactdetails inner join ld_cntactivityrel on ld_cntactivityrel.contactid=ld_contactdetails.contactid inner join ld_crmentity on ld_crmentity.crmid = ld_contactdetails.contactid left join ld_groups on ld_groups.groupid=ld_crmentity.smownerid where ld_cntactivityrel.activityid=' . $adb->quote($id) . ' and ld_crmentity.deleted=0';


		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);

		if ($return_value == null)
			$return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}

	/** Returns the column name that needs to be sorted
	 * Portions created by lingdangCRM are Copyright (C) lingdangCRM.
	 * All Rights Reserved..
	 * Contributor(s): Mike Crowe
	 */
	function getSortOrder() {

        if (!empty($this->reportSortType)){
            return $this->reportSortType;
        }
		if (isset($_REQUEST['sorder']))
			$sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
		else
			$sorder = (($_SESSION['EMAILS_SORT_ORDER'] != '') ? ($_SESSION['EMAILS_SORT_ORDER']) : ($this->default_sort_order));

		return $sorder;
	}

	/** Returns the order in which the records need to be sorted
	 * Portions created by lingdangCRM are Copyright (C) lingdangCRM.
	 * All Rights Reserved..
	 * Contributor(s): Mike Crowe
	 */
	function getOrderBy() {
		

		$use_default_order_by = '';
		if (PerformancePrefs::getBoolean('LISTVIEW_DEFAULT_SORTING', true)) {
			$use_default_order_by = $this->default_order_by;
		}

		if (isset($_REQUEST['order_by']))
			$order_by = $this->db->sql_escape_string($_REQUEST['order_by']);
		else
			$order_by = (($_SESSION['EMAILS_ORDER_BY'] != '') ? ('ld_activity.'.$_SESSION['EMAILS_ORDER_BY']) : ($use_default_order_by));

		return $order_by;
	}

	// Mike Crowe Mod --------------------------------------------------------

	/** Returns a list of the associated ld_users
	 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
	 * All Rights Reserved..
	 * Contributor(s): ______________________________________..
	 */
	function get_users($id) {
	
		global $adb;
		global $mod_strings;
		global $app_strings;

		$id = $_REQUEST['record'];

		$button = '<input title="' . getTranslatedString('LBL_BULK_MAILS') . '" accessykey="F" class="create"
				onclick="this.form.action.value=\"sendmail\";this.form.return_action.value=\"DetailView\";this.form.module.value=\"Emails\";this.form.return_module.value=\"Emails\";"
				name="button" value="' . getTranslatedString('LBL_BULK_MAILS') . '" type="submit">&nbsp;
				<input title="' . getTranslatedString('LBL_BULK_MAILS') . '" accesskey="" tabindex="2" class="edit"
				value="' . getTranslatedString('LBL_SELECT_USER_BUTTON_LABEL') . '" name="Button" language="javascript"
				onclick=\"return window.open("index.php?module=Users&return_module=Emails&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=true&return_id=' . $id . '&recordid=' . $id . '","test","width=640,height=520,resizable=0,scrollbars=0");\"
				type="button">';

		$query = 'SELECT ld_users.id, ld_users.first_name,ld_users.last_name, ld_users.user_name, ld_users.email1, ld_users.email2, ld_users.secondaryemail , ld_users.phone_home, ld_users.phone_work, ld_users.phone_mobile, ld_users.phone_other, ld_users.phone_fax from ld_users inner join ld_salesmanactivityrel on ld_salesmanactivityrel.smid=ld_users.id and ld_salesmanactivityrel.activityid=?';
		$result = $adb->pquery($query, array($id));

		$noofrows = $adb->num_rows($result);
		$header [] = $app_strings['LBL_LIST_NAME'];

		$header [] = $app_strings['LBL_LIST_USER_NAME'];

		$header [] = $app_strings['LBL_EMAIL'];

		$header [] = $app_strings['LBL_PHONE'];
		while ($row = $adb->fetch_array($result)) {

			global $current_user;

			$entries = Array();
            $entity_field_info = getEntityFieldNames('Users');
           $fieldsName = $entity_field_info['fieldname'];
			if (is_admin($current_user)) {
				$entries[] = $row[$fieldsName];
			} else {
				$entries[] =$row[$fieldsName];
			}

			$entries[] = $row['user_name'];
			$entries[] = $row['email1'];
			if ($email == '')
				$email = $row['email2'];
			if ($email == '')
				$email = $row['secondaryemail'];

			$entries[] = $row['phone_home'];
			if ($phone == '')
				$phone = $row['phone_work'];
			if ($phone == '')
				$phone = $row['phone_mobile'];
			if ($phone == '')
				$phone = $row['phone_other'];
			if ($phone == '')
				$phone = $row['phone_fax'];

			//Adding Security Check for User

			$entries_list[] = $entries;
		}

		if ($entries_list != '')
			$return_data = array("header" => $header, "entries" => $entries);

		if ($return_data == null)
			$return_data = Array();
		$return_data['CUSTOM_BUTTON'] = $button;
		return $return_data;
	}


	/**
	 * Used to releate email and contacts -- Outlook Plugin
	 */
	function set_emails_contact_invitee_relationship($email_id, $contact_id) {
	
		$query = "insert into $this->rel_contacts_table (contactid,activityid) values(?,?)";
		$this->db->pquery($query, array($contact_id, $email_id), true, "Error setting email to contact relationship: " . "<BR>$query");
		
	}

	/**
	 * Used to releate email and salesentity -- Outlook Plugin
	 */
	function set_emails_se_invitee_relationship($email_id, $contact_id) {
	
		$query = "insert into $this->rel_serel_table (crmid,activityid) values(?,?)";
		$this->db->pquery($query, array($contact_id, $email_id), true, "Error setting email to contact relationship: " . "<BR>$query");
	
	}

	/**
	 * Used to releate email and Users -- Outlook Plugin
	 */
	function set_emails_user_invitee_relationship($email_id, $user_id) {
	
		$query = "insert into $this->rel_users_table (smid,activityid) values (?,?)";
		$this->db->pquery($query, array($user_id, $email_id), true, "Error setting email to user relationship: " . "<BR>$query");
		
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		

		$sql = 'DELETE FROM ld_seactivityrel WHERE activityid=?';
		$this->db->pquery($sql, array($id));

		$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
		$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
		$this->db->pquery($sql, $params);
	}

	//public function getNonAdminAccessControlQuery($module, $user, $scope='') {
		//return " and ".$this->table_name."$scope.smownerid=$user->id ";
	//}

}
//根据模块ID，自动获取模块单据的客户和联系人的邮件email
function get_to_emailids_for_record($record){
	global $adb;
	$to_email = array();
	if(!empty($record)){
		$frommodule = getSalesEntityType($record);
		$focus = CRMEntity::getInstance($frommodule);
		$focus->retrieve_entity_info($record,$frommodule);
		//客户
		if(!empty($focus->column_fields['account_id'])){
			$emailsql = "SELECT fieldid,columnname FROM ld_field WHERE uitype=13 AND presence <> 1 AND tabid=(SELECT tabid FROM ld_tab WHERE name='Accounts') AND tablename <> 'ld_contactdetails' and typeofdata LIKE '%E%'";
			$emailresult = $adb->pquery($emailsql);
			$rowCount = $adb->num_rows($emailresult);
			for ($i = 0; $i < $rowCount; $i++) {
				$emilfieldid = $adb->query_result($emailresult, $i, 'fieldid');
				$emailFields[$emilfieldid] = $adb->query_result($emailresult, $i, 'columnname');
			}
			$query = 'SELECT  '.implode(",", $emailFields).' FROM ld_account
				   LEFT JOIN ld_accountscf ON ld_accountscf.accountid= ld_account.accountid
				   WHERE ld_account.deleted=0 AND ld_account.accountid IN ('.$focus->column_fields['account_id'].') AND ld_account.emailoptout=0';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0){
				for($i = 0; $i<$num_rows; $i++){
					foreach($emailFields as $columnname){
						$column_value = $adb->query_result($result,$i,$columnname);
						if(!empty($column_value)){
							$to_email[] = $column_value;
						}
					}
				}
			}
		}
		//联系人
		if(!empty($focus->column_fields['contact_id'])){
			$emailFields = array();
			$emailsql = "SELECT fieldid,columnname FROM ld_field WHERE uitype=13 AND presence <> 1 AND tabid=(SELECT tabid FROM ld_tab WHERE name='Contacts') AND typeofdata LIKE '%E%'";
			$emailresult = $adb->pquery($emailsql);
			$rowCount = $adb->num_rows($emailresult);
			for ($i = 0; $i < $rowCount; $i++) {
				$emilfieldid = $adb->query_result($emailresult, $i, 'fieldid');
				$emailFields[$emilfieldid] = $adb->query_result($emailresult, $i, 'columnname');
			}
			$query = 'SELECT '.implode(",", $emailFields).' 
				  FROM ld_contactdetails
				  LEFT JOIN ld_contactscf ON ld_contactdetails.contactid = ld_contactscf.contactid
				  WHERE ld_contactdetails.deleted=0 AND ld_contactdetails.contactid IN ('.$focus->column_fields['contact_id'].') AND ld_contactdetails.emailoptout=0';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0){
				for($i = 0; $i<$num_rows; $i++){
					foreach($emailFields as $columnname){
						$column_value = $adb->query_result($result,$i,$columnname);
						if(!empty($column_value)){
							$to_email[] = $column_value;
						}
					}
				}
			}
		}
	}
	return $to_email;
}
/** Function to get the emailids for the given ids form the request parameters
 *  It returns an array which contains the mailids and the parentidlists
 */
function get_to_emailids($module) {
    //$log->fatal($_REQUEST); 	bug:0024793
	global $adb, $current_user, $log;
	//$idlists1 = "";
	$mailds = '';
    //$idlist = ;//获取邮箱字段id
   // print_r($idlist);
    //echo $idlist."---------";
	$fieldids = explode(":", vtlib_purify($_REQUEST['field_lists']));
    
	if($_REQUEST['idlist'] == 'all' || $_REQUEST['idlist'] == 'relatedListSelectAll'){
		$idlist = getSelectedRecords($_REQUEST,vtlib_purify($_REQUEST['pmodule']),vtlib_purify($_REQUEST['idlist']),vtlib_purify($_REQUEST['excludedRecords']));
	} else {
		$idlist = explode(":", str_replace("undefined","",vtlib_purify($_REQUEST['idlist'])));
	}
    if($module=='Accounts'){
        $emailsql = "SELECT fieldid,columnname FROM ld_field WHERE uitype=13 AND fieldid in".'('.str_replace(':',',',$_REQUEST['field_lists']).')'." AND tabid=(SELECT tabid FROM ld_tab WHERE name='$module') AND tablename <> 'ld_contactdetails' and typeofdata LIKE '%E%'";
    }else{
        $emailsql = "SELECT fieldid,columnname FROM ld_field WHERE uitype=13 AND fieldid in".'('.str_replace(':',',',$_REQUEST['field_lists']).')'." AND tabid=(SELECT tabid FROM ld_tab WHERE name='$module') AND typeofdata LIKE '%E%'";
    }
   // echo $emailsql;
    $emailresult = $adb->pquery($emailsql);
    $rowCount = $adb->num_rows($emailresult);
    for ($i = 0; $i < $rowCount; $i++) {
        $emilfieldid = $adb->query_result($emailresult, $i, 'fieldid');
        $emailFields[$emilfieldid] = $adb->query_result($emailresult, $i, 'columnname');
    }
    
	$fieldobj=Field::getInstance($module,$adb);
	$moduleFields=$fieldobj->getModuleFields();
	foreach ($moduleFields as $fieldname=>$fieldinfo) {
		$fieldid = $fieldinfo->getFieldid();
		/*if (!in_array($fieldid, $fieldids)) {
			unset($emailFields[$key]);
		}*/
	}
    
    /**
     * edit:kevin
     * date:2013-10-24
     * reason:5425
     */ 
	if(empty($emailFields))
		return false;
	if ($module == 'Leads') {
		$query = 'SELECT firstname,lastname,'.implode(",", $emailFields).',ld_leaddetails.leadid as id
				  FROM ld_leaddetails
				  LEFT JOIN ld_leadscf ON ld_leaddetails.leadid = ld_leadscf.leadid
				  WHERE ld_leaddetails.deleted=0 AND ld_leaddetails.leadid IN ('.generateQuestionMarks($idlist).')';
	} else if ($module == 'Contacts'){
		$query = 'SELECT firstname,lastname,'.implode(",", $emailFields).',ld_contactdetails.contactid as id
				  FROM ld_contactdetails
				  LEFT JOIN ld_contactscf ON ld_contactdetails.contactid = ld_contactscf.contactid
				  WHERE ld_contactdetails.deleted=0 AND ld_contactdetails.contactid IN ('.generateQuestionMarks($idlist).') AND ld_contactdetails.emailoptout=0';
	} else if($module=='Vendors'){
	   $query='SELECT vendorname,'.implode(",", $emailFields).',ld_vendor.vendorid as id
				  FROM ld_vendor
				  LEFT JOIN ld_vendorcf ON ld_vendorcf.vendorid = ld_vendor.vendorid
				  WHERE ld_vendor.deleted=0 AND ld_vendor.vendorid IN ('.generateQuestionMarks($idlist).')';
	} 
    else {
		$query = 'SELECT ld_account.accountname, '.implode(",", $emailFields).',ld_account.accountid as id FROM ld_account
				   LEFT JOIN ld_accountscf ON ld_accountscf.accountid= ld_account.accountid
				   WHERE ld_account.deleted=0 AND ld_account.accountid IN ('.generateQuestionMarks($idlist).') AND ld_account.emailoptout=0';
	}

	$result = $adb->pquery($query,$idlist);
	
	if($adb->num_rows($result)>0){
		while($entityvalue = $adb->fetchByAssoc($result)){
			$vtwsid = $entityvalue['id'];
			foreach ($emailFields as $i => $emailFieldName) {
				if ($entityvalue[$emailFieldName] != NULL || $entityvalue[$emailFieldName] != '') {
					$idlists .= $vtwsid . '@' . $i . '|';
					if ($module == 'Leads' || $module == 'Contacts') {
						$mailids .= $entityvalue['lastname'] . " " . $entityvalue['firstname'] . "<" . $entityvalue[$emailFieldName] . ">;";
					}else if($module=='Vendors'){
					   $mailids .= $entityvalue['vendorname'] . "<" . $entityvalue[$emailFieldName] . ">;";
					} 
                    else {
						$mailids .= $entityvalue['accountname'] . "<" . $entityvalue[$emailFieldName] . ">;";
					}
				}
			}
		}
	}

	$return_data = array('idlists' => $idlists, 'mailds' => $mailids);

	return $return_data;
}

//added for attach the generated pdf with email
function pdfAttach($obj, $module, $file_name, $id) {
	

	global $adb, $current_user;
	global $upload_badext;
	$date_var = date('Y-m-d H:i:s');

	$ownerid = $obj->column_fields['assigned_user_id'];
	if (!isset($ownerid) || $ownerid == '')
		$ownerid = $current_user->id;

	$current_id = $adb->getUniqueID("ld_crmentity");

	$upload_file_path = decideFilePath();

	//Copy the file from temporary directory into storage directory for upload
	$source_file_path = "storage/" . $file_name;
    
	$status = copy($source_file_path, $upload_file_path . $current_id . "_" . $file_name);
	//Check wheather the copy process is completed successfully or not. if failed no need to put entry in attachment table
	if ($status) {
		$query1 = "insert into ld_crmentity (crmid,smcreatorid,smownerid,setype,description,createdtime,modifiedtime) values(?,?,?,?,?,?,?)";
		$params1 = array($current_id, $current_user->id, $ownerid, $module . " Attachment", $obj->column_fields['description'], $adb->formatDate($date_var, true), $adb->formatDate($date_var, true));
		$adb->pquery($query1, $params1);

		$query2 = "insert into ld_attachments(attachmentsid, name, description, type, path) values(?,?,?,?,?)";
		$params2 = array($current_id, $file_name, $obj->column_fields['description'], 'pdf', $upload_file_path);
		$result = $adb->pquery($query2, $params2);

		$query3 = 'insert into ld_seattachmentsrel values(?,?)';
		$adb->pquery($query3, array($id, $current_id));

		// Delete the file that was copied
		unlink($source_file_path);

		return true;
	} else {
	
		return false;
	}
}

//this function check email fields profile permission as well as field access permission
function emails_checkFieldVisiblityPermission($fieldname, $mode='readonly') {
	global $current_user;
	$ret = '0';
	return $ret;
}
Emails::require_file();
?>