<?php





// Contact is used to store customer information.
class VendorContact extends CRMEntity {
     static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['VendorContact']='VendorContact';
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include("modules/Calendar/Activity.php");
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;

	var $table_name = "ld_vendorcontacts";
	var $table_index= 'vendorcontactsid';
	var $tab_name = Array('ld_crmentity','ld_vendorcontacts','ld_vendorcontactscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_vendorcontacts'=>'vendorcontactsid','ld_vendorcontactscf'=>'vendorcontactsid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
    var $table_code='vendorcontact_no';//2016/0905 Liver:导入时，根据这个字段判断编号字段
	var $customFieldTable = Array('ld_vendorcontactscf', 'vendorcontactsid');

	var $column_fields = Array();
    var $module_name='VendorContact';
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','vendorname');

	var $list_link_field= 'lastname';
      /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('vendors'=>'','users'=>'','company'=>'','vendorcontact'=>'');


	var $search_fields = Array(
	'Name' => Array('ld_vendorcontacts'=>'lastname'),
	'Title' => Array('ld_vendorcontacts'=>'title'),
	'Account Name'=>Array('ld_vendorcontacts'=>'vendorcontactsid'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Vendor Name'=>'vendor_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','lastname','createdtime' ,'modifiedtime','imagename');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
		//$this->log = LoggerManager::getLogger('VendorContact');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('VendorContact',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('VendorContact');
        $this->list_link_field=$entityname['fieldname'];
	}

	// Mike Crowe Mod --------------------------------------------------------Default ordering for us
	/** Function to get the number of Contacts assigned to a particular User.
	*  @param varchar $user name - Assigned to User
	*  Returns the count of contacts assigned to user.
	*/
	function getCount($user_name)
	{
	
		$query = "select count(1) from ld_vendorcontacts  inner join ld_crmentity on ld_crmentity.crmid=ld_vendorcontacts.vendorcontactsid inner join ld_users on ld_users.id=ld_crmentity.smownerid where user_name=? and ld_crmentity.deleted=0";
		$result = $this->db->pquery($query,array($user_name),true,"Error retrieving contacts count");
		$rows_found =  $this->db->getRowCount($result);
		$row = $this->db->fetchByAssoc($result, 0);

		return $row["count(*)"];
	}


	// This function doesn't seem to be used anywhere. Need to check and remove it.
	/** Function to get the Contact Details assigned to a particular User based on the starting count and the number of subsequent records.
	*  @param varchar $user_name - Assigned User
	*  @param integer $from_index - Initial record number to be displayed
	*  @param integer $offset - Count of the subsequent records to be displayed.
	*  Returns Query.
	*/
    function get_vendorcontacts($user_name,$from_index,$offset)
    {

      $query = "select ld_users.user_name,ld_groups.groupname,ld_contactdetails.department department, ld_vendorcontacts.phone office_phone, ld_vendorcontacts.fax fax, 
      ld_contactsubdetails.assistant assistant_name, ld_contactsubdetails.otherphone other_phone, 
      ld_vendorcontacts.homephone home_phone,ld_vendorcontacts.birthday birthdate, 
      ld_vendorcontacts.lastname last_name,ld_contactdetails.firstname first_name,ld_vendorcontacts.vendorcontactsid as id, ]
      ld_vendorcontacts.salutation as salutation, ld_vendorcontacts.email as email1,
      ld_vendorcontacts.title as title,ld_vendorcontacts.mobile as phone_mobile,ld_vendor.vendorname as vendor_name,
      ld_vendor.vendorid as vendor_id,  from ld_vendorcontacts inner join ld_crmentity on ld_crmentity.crmid=ld_vendorcontacts.vendorcontactid
       inner join ld_users on ld_users.id=ld_crmentity.smownerid left join ld_vendor on ld_vendor.accountid=ld_contactdetails.accountid left join ld_contactaddress on ld_contactaddress.contactaddressid=ld_contactdetails.contactid left join ld_contactsubdetails on ld_contactsubdetails.contactsubscriptionid = ld_contactdetails.contactid left join ld_groups on ld_groups.groupid=ld_crmentity.smownerid left join ld_users on ld_crmentity.smownerid=ld_users.id where user_name='" .$user_name ."' and ld_crmentity.deleted=0 limit " .$from_index ."," .$offset;
      return $this->process_list_query1($query);
    }
   
   


//End
/** Function to get the Contacts assigned to a user with a valid email address.
* @param varchar $username - User Name
* @param varchar $emailaddress - Email Addr for each contact.
* Used By lingdangCRM Outlook Plugin
* Returns the Query
*/
function get_searchbyemailid($username,$emailaddress)
{

	global $current_user;
	$seed_user=new Users();
	$user_id=$seed_user->retrieve_user_id($username);
	$current_user=$seed_user;
	$current_user->retrieve_entity_info($user_id, 'Users');
	require('user_privileges/user_privileges_'.$current_user->id.'.php');

	$query = "select ld_contactdetails.lastname,ld_contactdetails.firstname,
					ld_contactdetails.contactid, ld_contactdetails.salutation,
					ld_contactdetails.email,ld_contactdetails.title,
					ld_contactdetails.mobile,ld_vendor.accountname,
					ld_vendor.accountid as accountid  from ld_contactdetails
						inner join ld_crmentity on ld_crmentity.crmid=ld_contactdetails.contactid
						inner join ld_users on ld_users.id=ld_crmentity.smownerid
						left join ld_vendor on ld_vendor.accountid=ld_contactdetails.accountid
						left join ld_contactaddress on ld_contactaddress.contactaddressid=ld_contactdetails.contactid
			      ";
	$query .= getNonAdminAccessControlQuery('Contacts',$current_user);
	$query .= "where ld_crmentity.deleted=0";
	if(trim($emailaddress) != '') {
		$query .= " and ((ld_contactdetails.email like '". formatForSqlLike($emailaddress) .
		"') or ld_contactdetails.lastname REGEXP REPLACE('".$emailaddress.
		"',' ','|') or ld_contactdetails.firstname REGEXP REPLACE('".$emailaddress.
		"',' ','|'))  and ld_contactdetails.email != ''";
	} else {
		$query .= " and (ld_contactdetails.email like '". formatForSqlLike($emailaddress) .
		"' and ld_contactdetails.email != '')";
	}

	
	return $this->plugin_process_list_query($query);
}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
        global $adb,$current_user;
	   
        //判断是否有录音文件，并插入或者修改录音文件信息
        $callButlerRemarks = "";
        if(isset($_REQUEST['callButlerRemarks']) && $_REQUEST['callButlerRemarks'] != '')
        {
            $callButlerRemarks = $_REQUEST['callButlerRemarks'];
        }
        if(isset($_REQUEST['callbutlername']) && $_REQUEST['callbutlername'] != '')
        {
             crm_load_class_file('cls_PhoneEncrypt','include');
             $obj=new cls_PhoneEncrypt();
             $callbutlername = $_REQUEST['callbutlername'];
             $one_callfiles=explode('\\',$callbutlername);
             $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
             $callfilenames=explode('_',$two_callfilename);
             $callphone=$callfilenames[0];
             $restore_phone= $obj->Restore_Phone_token($callphone);
             for($i=0;$i<sizeof($one_callfiles)-1;$i++)
                 {
                    $filenames.=$one_callfiles[$i].'\\';
                 }
             $one_filenames=$filenames.$restore_phone.'_'.$callfilenames[1];
                
             $callbutlernameNew = str_replace("\\","\\\\",$one_filenames);    
             $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
            
            $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
            $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
			if($_REQUEST['calltype'] == 1){
				$calltype = '去电';
			}else{
				$calltype = '来电';
			}
            if($adb->num_rows($callbutlerGetResult))
            {
                //存在
                $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
                
                
                $sqlUpdate = "update ld_callbutler set phone=?, calltype = ?, vendorcontactid = ?,description = ? where id = ? ";
                $updateResult=$adb->pquery($sqlUpdate,array($restore_phone,$calltype,$this->id,$callButlerRemarks,$callButlerID));
                
                
            }
            else
            {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                 accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ";
                $callbutlername = str_replace("\\\\","\\",$one_filenames);
                $insertresult=$adb->pquery($sqlInsert,array($calltype,$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                0,0,0,0,$this->id,0,0,$callButlerRemarks));
            }
        }
        //九维 思孚 汉天 单据新增保存更新对应通话记录表
        if(isset($_REQUEST['jiuweiaccount'])&&isset($_REQUEST['callcenter_switch'])){
            crm_load_class_file('cls_UpdatePhoneRecord','CallCenter/lib');
            $obj=new cls_UpdatePhoneRecord($_REQUEST['jiuweiaccount'],$_REQUEST['callcenter_switch'],$this->id,$module);
            $obj->updatePhoneRecord();
        }

//        @edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”
        //灵当语音盒
        if (isset($_REQUEST['calltalkid']) && $_REQUEST['calltalkid'] != '') {
            $calltalkid = $_REQUEST['calltalkid'];

            $callbutlerGetSql = "select id from ld_callbutler where talkid = ? and userid = ? ";
            $callbutlerGetResult = $adb->pquery($callbutlerGetSql, array($calltalkid, $current_user->id));
            if ($adb->num_rows($callbutlerGetResult)) {
                //存在
                $callButlerID = $adb->query_result($callbutlerGetResult, 0, 'id');

                $sqlUpdate = "update ld_callbutler set vendorcontactid = ?,description = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    0,  0, 0, 0, $this->id, 0, 0, 0, ''));
            }
        }

	}

	/**
	 *      This function is used to add the LD. This will call the function uploadAndSaveFile which will upload the attachment into the server and save that attachment information in the database.
	 *      @param int $id  - entity id to which the lingdang_files to be uploaded
	 *      @param string $module  - the current module name
	
	function insertIntoAttachment($id,$module)
	{
		global  $adb;
	
		$file_saved = false;
		//This is to added to store the existing attachment id of the contact where we should delete this when we give new image
		$old_attachmentid = $adb->query_result($adb->pquery("select ld_crmentity.crmid from ld_seattachmentsrel inner join ld_crmentity on ld_crmentity.crmid=ld_seattachmentsrel.attachmentsid where  ld_seattachmentsrel.crmid=?", array($id)),0,'crmid');
		foreach($_FILES as $fileindex => $files)
		{
			if($files['name'] != '' && $files['size'] > 0)
			{
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex.'_hidden']);
				$file_saved = $this->uploadAndSaveFile($id,$module,$files);
			}
		}

		//This is to handle the delete image for contacts
		if($module == 'Contacts' && $file_saved)
		{
			if($old_attachmentid != '')
			{
				//$setype = $adb->query_result($adb->pquery('select setype from ld_crmentity where crmid=? limit 1;', array($old_attachmentid)),0,'setype');
				$setype = getEntitySetype($old_attachmentid);//获取setype字段方法 tujt 2014-07-31
				if($setype == 'Contacts Image')
				{
					$del_res1 = $adb->pquery("delete from ld_attachments where attachmentsid=?", array($old_attachmentid));
					$del_res2 = $adb->pquery("delete from ld_seattachmentsrel where attachmentsid=?", array($old_attachmentid));
				}
			}
		}

	}*/

	/**
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
        parent::transferRelatedRecords($module, $transferEntityIds, $entityId);
		$rel_table_arr = Array("Emails"=>"ld_seactivityrel",
			     "Products"=>"ld_seproductsrel","Documents"=>"ld_senotesrel",
				"Attachments"=>"ld_seattachmentsrel");

		$tbl_field_arr = Array("ld_seactivityrel"=>"activityid",
				"ld_seproductsrel"=>"productid","ld_senotesrel"=>"notesid",
				"ld_seattachmentsrel"=>"attachmentsid");

		$entity_tbl_field_arr = Array("ld_seactivityrel"=>"crmid",
				"ld_seproductsrel"=>"crmid","ld_senotesrel"=>"crmid",
				"ld_seattachmentsrel"=>"crmid");

		foreach($transferEntityIds as $transferId) {
			foreach($rel_table_arr as $rel_module=>$rel_table) {
				$id_field = $tbl_field_arr[$rel_table];
				$entity_id_field = $entity_tbl_field_arr[$rel_table];
				// IN clause to avoid duplicate entries
				$sel_result =  $adb->pquery("select $id_field from $rel_table where $entity_id_field=? " .
						" and $id_field not in (select $id_field from $rel_table where $entity_id_field=?)",
						array($transferId,$entityId));
				$res_cnt = $adb->num_rows($sel_result);
				if($res_cnt > 0) {
					for($i=0;$i<$res_cnt;$i++) {
						$id_field_value = $adb->query_result($sel_result,$i,$id_field);
						$adb->pquery("update $rel_table set $entity_id_field=? where $entity_id_field=? and $id_field=?",
							array($entityId,$transferId,$id_field_value));
					}
				}
			}
		}
	
	}

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" => array("ld_cntactivityrel"=>array("contactid","activityid"),"ld_contactdetails"=>"contactid"),
			"HelpDesk" => array("ld_troubletickets"=>array("parent_id","ticketid"),"ld_contactdetails"=>"contactid"),
			"Quotes" => array("ld_quotes"=>array("contactid","quoteid"),"ld_contactdetails"=>"contactid"),
			"PurchaseOrder" => array("ld_purchaseorder"=>array("contactid","purchaseorderid"),"ld_contactdetails"=>"contactid"),
			"SalesOrder" => array("ld_salesorder"=>array("contactid","salesorderid"),"ld_contactdetails"=>"contactid"),
			"Products" => array("ld_seproductsrel"=>array("crmid","productid"),"ld_contactdetails"=>"contactid"),
			"Campaigns" => array("ld_campaigncontrel"=>array("contactid","campaignid"),"ld_contactdetails"=>"contactid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_contactdetails"=>"contactid"),
			"Accounts" => array("ld_contactdetails"=>array("contactid","accountid")),
			"Invoice" => array("ld_invoice"=>array("contactid","invoiceid"),"ld_contactdetails"=>"contactid"),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
		
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	       //删除供应商联系人信息 20140114 lmx
           if($return_module == 'Vendors'&& !empty($id)) {
			$sql = 'DELETE FROM ld_vendorcontacts WHERE vendorcontactsid=?';
			$this->db->pquery($sql, array($id));
          }
	
	}

	//added to get mail info for portal user
	//type argument included when when addin customizable tempalte for sending portal login details
	public static function getPortalEmailContents($entityData, $password, $type='') {
        
	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();

		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Products') {
				$adb->pquery("insert into ld_seproductsrel values (?,?,?)", array($crmid, $with_crmid, 'Contacts'));

			} elseif($with_module == 'Campaigns') {
				$adb->pquery("insert into ld_campaigncontrel values(?,?,1)", array($with_crmid, $crmid));

			} elseif($with_module == 'Potentials') {
				$adb->pquery("insert into ld_contpotentialrel values(?,?)", array($crmid, $with_crmid));

			} else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}

  /*
    function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {

	
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;

		$root_dir= dirname(dirname(dirname(__FILE__)));
		require_once($root_dir.'/CallCenter/lib/jiuWei.php');
		$jiuObj = jiuWei::autoLoad();
		if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
			return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'VendorContact');
		}
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_vendorcontacts as T2 on  T1.vendorcontactid = T2.vendorcontactsid 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.vendorcontactid > 0 and T1.vendorcontactid = '.$id;
        
        $count_result = $adb->query( mkCountQuery( $sql));
		$noofrows = $adb->query_result($count_result,0,'count');
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
			$start = vtlib_purify($_REQUEST['start']);
			if($start == 'last'){
				if($noofrows > 0){
					$start = ceil($noofrows/$list_max_entries_per_page_new_more);
				}
			}
			if(!is_numeric($start)) $start = 1;
			elseif($start < 1) $start = 1;
			$start = ceil($start);
		}else{
			$start = 1;
		}
		global $related_left_start;
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        //用户、时间、类型、电话号码、状态、时长、操作
        //$header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('STATUS'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
                $soundrecordingfile = $adb->query_result($result,$i,'soundrecordingfile');
                $soundrecordingfilenew = str_replace("\\","/",$soundrecordingfile);

                $listview_entrie[]= $adb->query_result($result,$i,'last_name');
                $listview_entrie[]= $adb->query_result($result,$i,'begintime');
                $listview_entrie[]= $adb->query_result($result,$i,'calltype');
                $listview_entrie[]=  fieldValueUitype::setReportMobileStyle($adb->query_result($result,$i,'phone'));
                //$listview_entrie[]= $adb->query_result($result,$i,'status');
                $time = $adb->query_result($result,$i,'time');
                $listview_entrie[]= $time;
				
				if(empty($time)){
					$listview_entrie[]= "";
				}else{
					$listview_entrie[]= "<a class='Anu3_a' onclick='play_click(this,\"".$soundrecordingfilenew."\")' href='###'>".getFixedLabel('PLAYER')."</a>";
				}
                $listview_entries[] = $listview_entrie;
            }
        }
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        //print_r($listview_entries);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
		return $return_value;
	}*/
    
}
VendorContact::require_file();
?>