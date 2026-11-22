<?php



class Contacts extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Contacts']='Contacts';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='Contacts';
	var $table_name = "ld_contactdetails";
	var $table_index= 'contactid';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_contactdetails','ld_contactscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_contactdetails'=>'contactid','ld_contactscf'=>'contactid',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_contactscf', 'contactid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','contacts'=>'','users'=>'','company'=>'');


    var $table_code='contact_no';//审批中链接字段
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('lastname','assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';
    var $moduleName = 'Contacts';
	public $firstname;
	public $lastname;
	public $email_opt_out;
	public $do_not_call;
	public $CheckFieldProfile;
	
	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Contacts',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Contacts');
        $this->list_link_field=$entityname['fieldname'];
       
	}



	

	/** Returns a list of the associated emails
	 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
	 * All Rights Reserved..
	 * Contributor(s): ______________________________________..
	*/
	function get_emails_list($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;

        $related_module ='Emails';
		$other = CRMEntity::getInstance($related_module);

		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;

		$button = '';

		$button .= '<input type="hidden" name="email_directing_module"><input type="hidden" name="record">';

		if($actions) {
			/**
			 * #0008392 联系人更多信息中邮件管理，新建按钮不合理
			 * 原来的value：getFixedLabel('CREATE') getTranstab($singular_modname)
			 *	修改为：getFixedLabel('Send_mail') 发送邮件
			 * @author Tujt 2014-04-16
			 */
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('ADD', $actions) && isPermitted($related_module,3, '') == 'yes') {
                $button .= '<a title="'.getFixedLabel('Send_mail').'" href="javascript:void(0);"
				onclick="sendmail(\''.$this_module.'\','.$id.');">
				<span>'.getFixedLabel('Send_mail').'</span></a>';
			}
		}
        
		$query = "select ld_users.last_name as user_name," .
				" ld_activity.activityid, ld_activity.subject, ld_activity.activitytype, ld_crmentity.modifiedtime," .
				" ld_crmentity.crmid, ld_crmentity.smownerid, ld_activity.date_start, ld_seactivityrel.crmid as parent_id " .
				" from ld_activity, ld_seactivityrel, ld_contactdetails, ld_users, ld_crmentity" .
			 
				" where ld_seactivityrel.activityid = ld_activity.activityid" .
				" and ld_contactdetails.contactid = ld_seactivityrel.crmid and ld_users.id=ld_crmentity.smownerid" .
				" and ld_crmentity.crmid = ld_activity.activityid  and ld_contactdetails.contactid = ".$id." and" .
						" ld_activity.activitytype='Emails' and ld_crmentity.deleted = 0";

		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
global $adb;
        $result=$adb->pquery($query,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $cs=$adb->query_result($result, $i, 'subject');
        $total[$cs] = $adb->query_result($result, $i, 'crmid');
        }
		if(isset($return_value['entries']) && !empty($return_value['entries'])){
			foreach($return_value['entries'] as $key=>$arr){
				foreach($total as $key2=>$arr2){
					if($key2==trim(strip_tags($return_value['entries'][$key][0]))){
						$return_value['entries'][$key][0]="<a target='_blank' href='index.php?module=Emails&action=EmailsAjax&file=DetailView&record=$arr2'>$key2</a>";
					}
				}
			}
		}

		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}

	/**
	 * @project PROT93 邮件管理改进
	 * @author Tujt 2014-09-23
	 */
	function get_emails($id, $cur_tab_id, $rel_tab_id, $actions=false) {
	    global $adb;
		global $currentModule,$current_user;
		global $list_max_entries_per_page_new_more;
		//1、获取字段
        $query = 'SELECT GROUP_CONCAT(CONCAT(tablename,".",columnname)) AS columnname
						FROM ld_field WHERE uitype = 13 AND (tabid = 4) AND presence IN (0,2) LIMIT 1;';
		$result = $adb->pquery($query,array());
		$emailfield = $adb->query_result($result,0,'columnname');
		//2、取email值
		$query = 'select '.$emailfield.' from ld_contactdetails 
					left join ld_contactscf 
						on ld_contactscf.contactid = ld_contactdetails.contactid 
					where ld_contactdetails.deleted = 0 and ld_contactdetails.contactid = ? ';
		$result = $adb->pquery($query,array($id));
		$rows = $adb->num_rows($result);
		$emailarr = array();
		if($rows > 0){
			$fieldarr = explode(',',$emailfield);
			for($i=0;$i<$rows;$i++){
                foreach($fieldarr as $flds){
                    $fld = explode('.',$flds);
                    if(isset($fld[1])){
                        $val = $adb->query_result($result,$i,$fld[1]);
						if(!empty($val))
							$emailarr[$val] = $val;
                    }
                }
            }
		}
		//手机、主题、接收人、发送时间、发件人，
        $email_field_obj = Field::getInstance('Emails',$adb);
		$arrpaymentLabel =$email_field_obj->getFieldLables();
        $header = array($arrpaymentLabel['from_email'],$arrpaymentLabel['subject'],$arrpaymentLabel['date_start'],getFixedLabel('TOMAIL'),getFixedLabel('STATUS'),getFixedLabel('OPERATING'));
		
		$button = '';
		$button .= '<input type="hidden" name="email_directing_module"><input type="hidden" name="record">';
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('ADD', $actions) && isPermitted($related_module,1, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('Send_mail').'" href="javascript:void(0);"
				onclick="sendmail(\''.$currentModule.'\','.$id.');">
				<span>'.getFixedLabel('Send_mail').'</span></a>';
                $button .= '<a title="'.getFixedLabel('Receive_mail').'" href="javascript:void(0);"
				onclick="receivemail();">
				<span>'.getFixedLabel('Receive_mail').'</span></a>';
			}
		}

		//3、获取email对应的往来邮件记录
		$where = '';
		if(!empty($emailarr)){
			$lt ='<';
			$gt ='>';
			foreach($emailarr as $email){
				//$where .= ' ((to_email like "%'.$lt.$email.$gt.'%" or to_email like '."'%\"{$email}\"%'".') or (cc_email like "%'.$lt.$email.$gt.'%" or cc_email like '."'%\"{$email}\"%'".') or (bcc_email like "%'.$lt.$email.$gt.'%" or bcc_email like '."'%\"{$email}\"%'".')) or';
				// 需求是接收人为当前客户邮箱，所以暂未考虑抄送密送
				$where .= '(ld_emaildetails.to_email like "%'.$lt.$email.$gt.'%" or ld_emaildetails.to_email like '."'%\"{$email}\"%'".') or';
                $tmp_where = '(ld_mailmanager_mailrecord.mto like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mto like '."'%{$email}%'".') or';//系统发送的邮件
                $tmp_where .= '(ld_mailmanager_mailrecord.mfrom like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mfrom like '."'%{$email}%'".') or';//系统收取的邮件
                $tmp_where .= '(ld_mailmanager_mailrecord.mcc like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mcc like '."'%{$email}%'".') or';//抄送的邮件
			}
		}else{//没有邮箱信息，返回空
			$return_value = array('header'=>$header,'entries'=>array(),'navigation'=>array(),'CUSTOM_BUTTON'=>$button);
			return $return_value;
		}
		$where = trim($where,'or');
		$query = 'SELECT ld_emaildetails.from_email,ld_activity.subject,ld_activity.createdtime,
						ld_emaildetails.to_email,ld_emaildetails.emailid,\'1\' as seen,\'emaildetails\' AS email_from
					FROM ld_activity 
				 LEFT JOIN ld_emaildetails 
					ON ld_emaildetails.`emailid` = ld_activity.`activityid` ';
		if($current_user->accountallview != 1 && $current_user->is_admin != 'on'){
			$this->table_name = 'ld_activity';
			$sql = $this->getNonAdminAccessControlQuery('Emails',$current_user);
			$this->table_name = 'ld_contactdetails';
			if(!empty($sql)){
				$query .= $sql;
			}
		}
		$query .= 'WHERE ld_activity.`deleted` = 0 and ld_activity.activitytype = "Emails" ';
		$query .= 'and ('.$where.') ';
		 $tmp_where = trim($tmp_where,'or');
        $query.='union all select mfrom,msubject,mdate as createdtime,mto,mailrecordid,seen,\'mailmanager\' as email_from from ld_mailmanager_mailrecord ';
        $query.=" where deleted=0  and  ( ".$tmp_where.')';

		//4、计算总数
        $noofrows=$adb->num_rows($adb->pquery($query,array()));
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if($noofrows <= 0){
			$return_value = array('header'=>$header,'entries'=>array(),'navigation'=>array(),'CUSTOM_BUTTON'=>$button);
			return $return_value;
		}
		//5、分页
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
	$query =" select * from ($query ) as tmp order by createdtime desc ". ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
		//6、取值
		$result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $mail_sql = "select GROUP_CONCAT(mail_username) as mailaccounts  from ld_mail_accounts where user_id =? order by createdtime desc";
            $mail_result = $adb->pquery($mail_sql,array($current_user->id));
            $mailaccounts = $adb->query_result($mail_result,0,'mailaccounts');

			$json = new Zend_Json();
            for($i=0;$i<$num_rows;$i++){
                $listview_entrie = array();
                $from_email = $adb->query_result($result,$i,'from_email');
                $listview_entrie[] = $from_email;
                $listview_entrie[] = $adb->query_result($result,$i,'subject');
                $listview_entrie[] = $adb->query_result($result,$i,'createdtime');
				$to_email = $adb->query_result($result,$i,'to_email');
				if(is_array($to_email))
				{
				    // $to_email = $json->decode($to_email);
                              
				    $to_email = vt_suppressHTMLTags(@implode(',',$to_email));
				}
				else{
				    $to_email=vt_suppressHTMLTags($to_email);
				}
				$listview_entrie[] = $to_email;

				$seen = $adb->query_result($result,$i,'seen');
                $listview_entrie[] = $seen == '1'?getFixedLabel('LBL_READEN'):getFixedLabel('LBL_UNREADEN');

                $emailid = $adb->query_result($result,$i,'emailid');
                $email_from = $adb->query_result($result,$i,'email_from');

                //只有来自邮件管理表ld_mailmanager_mailrecord的保存有邮件内容，表ld_emaildetails没有邮件主题和内容，故没有查看功能
                if ($email_from == 'mailmanager') {
                    $havereply = false;
                    if (stripos($mailaccounts,$from_email) === false || stripos($mailaccounts,$to_email) !== false) {
                        $havereply = true;
                    }

                    if ($havereply) {
                        $reply = '<a class="Anu3_a" href="###" onclick="view_EmailContent(ld(this),\''.$emailid.'\',\''.$email_from.'\')" record="'.$emailid.'" module="'.$currentModule.'">'.getFixedLabel('VIEW').'</a>';
                        $reply .= '<a class="Anu3_a" href="###" onclick="reply_EMail_popup(ld(this),\''.$emailid.'\')" module="'.$currentModule.'">'.getFixedLabel('Reply').'</a>';
                    }else{
                        $reply = '<a class="Anu3_a" href="###" onclick="view_EmailContent(ld(this),\''.$emailid.'\',\''.$email_from.'\')" record="'.$emailid.'" module="'.$currentModule.'">'.getFixedLabel('VIEW').'</a>';
                    }
                }else{
                    $reply = '';
                }
                $listview_entrie[] = $reply;
                $listview_entries[] = $listview_entrie;
            }
        }
		//7、获取分页组件
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');                
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'Emails',$id);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput,'CUSTOM_BUTTON'=>$button);
		return $return_value;
	}



	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	    global $image_from_module,$current_user;
        /**
         * 更新操作
         * by andy
         * date 20140319
         * reason:销售机会更多信息联系人增加创建联系人按钮
         */	   	   
	    global $adb;
       	if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Potentials'){
			$relid =  $_REQUEST['tablerelid'];
            $this->insertintonotesrel($relid,$this->id);
        } 
       else if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Project'){
			$relid =  $_REQUEST['tablerelid'];
           $sql='insert  into ld_crmentityrel(crmid,module,relcrmid,relmodule)value(?,?,?,?)';
           $adb->pquery($sql,array($relid,'Project',$this->id,'Contacts'));
        } 
       // if($image_from_module!='Accounts')  //edit:can ,判断客户保存照片时，不要保存为联系人的照片                       
	       //	$this->insertIntoAttachment($this->id,$module);
        /*
        edit:can
        data:20131011
        reason:客户的联系人录入改进(控制客户只能有一个首要联系人)
        更新操作
        edit:can
        date:20131030
        reason:5552: 在联系人单据查看页面，用“首要联系人”后面的小编辑按钮编辑，结果可以设置一个客户有多个首要联系人。
        */
        $sql="select reference from ld_contactdetails  where contactid=?";
        $result=$adb->pquery($sql,array($this->id));
        $reference=$adb->query_result($result,0,0);
        if($reference!=0)
        {
            $sqlcontact='update ld_contactdetails set reference=0 where contactid<>? and accountid=?';
            $adb->pquery($sqlcontact,array($this->id,$this->column_fields['account_id']));
        }
      
        /*if(array_key_exists('account_id',$this->column_fields)&&!empty($this->column_fields['account_id']))
        {
            
            $sql='select 1 from ld_account left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid
                where ld_account.accountid=? and ld_contactdetails.reference=1';
            $result=$adb->pquery($sql,array($this->column_fields['account_id']));
            if($adb->num_rows($result)<=0)
            {
                $sql=' update ld_contactdetails set reference=1 where contactid=?';
                $adb->pquery($sql,array($this->id));
            }
            
        }*/
        
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
            if($adb->num_rows($callbutlerGetResult))
            {
                //存在
                $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
                if($_REQUEST['calltype'] == 1){
					$calltype = '去电';
				}else{
					$calltype = '来电';
				}
			
                $sqlUpdate = "update ld_callbutler set userid=?, calltype = ?,contactid = ?,description = ? where id = ? ";
                $updateResult=$adb->pquery($sqlUpdate,array($current_user->id, $calltype,$this->id,$callButlerRemarks,$callButlerID));
                
                
            }
            else
            {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                 accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ";
				if($_REQUEST['calltype'] == 1){
					$calltype = '去电';
				}else{
					$calltype = '来电';
				}
                $callbutlername = str_replace("\\\\","\\",$one_filenames);
                $insertresult=$adb->pquery($sqlInsert,array($calltype,'','接通',null,null,'',$callbutlername,$current_user->id,
                0,$this->id,0,0,0,0,0,$callButlerRemarks));
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

                $sqlUpdate = "update ld_callbutler set contactid = ?,description = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                     0, $this->id, 0, 0, 0, 0, 0, 0, ''));
            }
        }

		//同步、更新联系人信息到帮我吧
		$this->SyncContactsToBangwoba($this->id,$this->mode);
        
        //联系人地址保存后重算经纬度
        if(isset($_REQUEST['bill_state'])||isset($_REQUEST['bill_city'])
                ||isset($_REQUEST['bill_area'])||isset($_REQUEST["bill_street_mass_edit_check"])
                || ($_REQUEST['ajxaction'] == 'DETAILVIEW' && in_array($_REQUEST['fldName'],array('bill_state','bill_city','bill_area')))){
	               $this->updateContactsAddress($this->id);
		}
              
	}
	//同步、更新联系人信息到帮我吧
	function SyncContactsToBangwoba($contactid,$mode){
	   
       	global $adb;
        static $bangwo_presences;
        if(is_array($bangwo_presences))
        {
           $activate=$bangwo_presences['activate'];
           if($activate=='yes')
           {
                $num_rows=1;
           }
        }
        else
        {
            $bangwo_presences=array();
            $bangwo_presences['activate']='no';
    		$query = 'select is_customer,presence from ld_bangwo8';
    		$result = $adb->pquery($query,array());
    		$num_rows = $adb->num_rows($result);
            
            if($num_rows>=1)
            {
                $is_customer = $adb->query_result($result,0,'is_customer');
	           $presence = $adb->query_result($result,0,'presence');
                if($is_customer == 0 && $presence == 0)
                {
                    $bangwo_presences['activate']='yes';
                }
                else
                {
                    $num_rows=0;
                }
            }
            
        }
		if($num_rows >= 1){
			
			//启用并且同步客户
			
				crm_load_class_file('cls_Bangwoba', 'modules/Users');
				$cls_Bangwoba = new cls_Bangwoba();
				if($mode == 'edit'){
					$cls_Bangwoba->setContactsToBangwoba($contactid,'edit');
				}else{
				$cls_Bangwoba->setContactsToBangwoba($contactid,'create');
				}
			
		}
        
	}
	function restore($module, $id) {
		//调用帮我吧接口
		parent::restore($module,$id); 
		$this->SyncContactsToBangwoba($id,'create');
   	}
    /**
     * 更新操作
     * by andy
     * date 20140319
     * reason:销售机会更多信息联系人增加创建联系人按钮
     */                             
    function insertintonotesrel($relid,$id)
	{
		global $adb;
        $adb->pquery("insert into ld_contpotentialrel values(?,?)", array($id,$relid));
	}

	/**
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
        parent::transferRelatedRecords($module, $transferEntityIds, $entityId);
   
		$rel_table_arr = Array("Potentials"=>"ld_contpotentialrel","Activities"=>"ld_activity","Emails"=>"ld_seactivityrel",
				"Products"=>"ld_seproductsrel","Documents"=>"ld_senotesrel",
				"Attachments"=>"ld_seattachmentsrel","Campaigns"=>"ld_campaigncontrel");

		$tbl_field_arr = Array("ld_contpotentialrel"=>"potentialid","ld_activity"=>"activityid","ld_seactivityrel"=>"activityid",
			     "ld_seproductsrel"=>"productid","ld_senotesrel"=>"notesid",
				"ld_seattachmentsrel"=>"attachmentsid","ld_campaigncontrel"=>"campaignid");

		$entity_tbl_field_arr = Array("ld_contpotentialrel"=>"contactid","ld_activity"=>"contactid","ld_seactivityrel"=>"crmid",
			 "ld_seproductsrel"=>"crmid","ld_senotesrel"=>"crmid",
				"ld_seattachmentsrel"=>"crmid","ld_campaigncontrel"=>"contactid");

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

	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts') {
			$sql = 'UPDATE ld_contactdetails SET accountid = ? WHERE contactid = ?';
			$this->db->pquery($sql, array(null, $id));
		} elseif($return_module == 'Potentials') {
			$sql = 'DELETE FROM ld_contpotentialrel WHERE contactid=? AND potentialid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Campaigns') {
			$sql = 'DELETE FROM ld_campaigncontrel WHERE contactid=? AND campaignid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Products') {
			$sql = 'DELETE FROM ld_seproductsrel WHERE crmid=? AND productid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Vendors') {
			$sql = 'DELETE FROM ld_vendorcontactrel WHERE vendorid=? AND contactid=?';
			$this->db->pquery($sql, array($return_id, $id));
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}

	//added to get mail info for portal user
	//type argument included when when addin customizable tempalte for sending portal login details
	public static function getPortalEmailContents($entityData, $password, $type='') {
        require_once 'config.inc.php';
		global $PORTAL_URL;

		$adb = PearDatabase::getInstance();
		$moduleName = $entityData->getModuleName();

		$portalURL = '<a href="'.$PORTAL_URL.'" style="font-family:Arial, Helvetica, sans-serif;font-size:12px; font-weight:bolder;text-decoration:none;color: #4242FD;">'.getTranslatedString('Please Login Here', $moduleName).'</a>';

		//here id is hardcoded with 5. it is for support start notification in lingdang_notificationscheduler
		$query='SELECT ld_emailtemplates.subject,ld_emailtemplates.body
					FROM ld_notificationscheduler
						INNER JOIN ld_emailtemplates ON ld_emailtemplates.templateid=ld_notificationscheduler.notificationbody
					WHERE schedulednotificationid=5';

		$result = $adb->pquery($query, array());
		$body=$adb->query_result($result,0,'body');
		$contents=$body;
		$contents = str_replace('$contact_name$',$entityData->get('firstname')." ".$entityData->get('lastname'),$contents);
		$contents = str_replace('$login_name$',$entityData->get('email'),$contents);
		$contents = str_replace('$password$',$password,$contents);
		$contents = str_replace('$URL$',$portalURL,$contents);
		$contents = str_replace('$support_team$',getTranslatedString('Support Team', $moduleName),$contents);
		$contents = str_replace('$logo$','<img src="cid:logo" />',$contents);

		if($type == "LoginDetails") {
			$temp=$contents;
			$value["subject"]=$adb->query_result($result,0,'subject');
			$value["body"]=$temp;
			return $value;
		}
		return $contents;
	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();
        
		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Products') {
				$adb->pquery("insert into ld_seproductsrel values (?,?,?)", array($crmid, $with_crmid, 'Contacts'));

			} elseif($with_module == 'Campaigns') {
				$adb->pquery("insert into ld_campaigncontrel(campaignid,contactid ) values(?,?)", array($with_crmid, $crmid));
                
              //  dump("insert into ld_campaigncontrel(contactid,campaignid)values($with_crmid, $crmid)");
			} elseif($with_module == 'Potentials') {
				$adb->pquery("insert into ld_contpotentialrel values(?,?)", array($crmid, $with_crmid));

			} else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}
	/**
	* Function to Recursively get all the upper accounts of a given Account
	* @param  integer   $id      		- accountid
	* @param  array   $parent_contacts   - Array of all the parent accounts
	* returns All the parent accounts of the given accountid in array format
	*/
	function __getParentContacts($id, &$parent_contacts, &$encountered_contact) {
		global $adb;
		$query = 'SELECT parentid FROM ld_contactdetails WHERE ld_contactdetails.deleted = 0 and ld_contactdetails.contactid = ? limit 1';
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$rows = $adb->num_rows($res);
		if($rows > 0){
			$parentid = $adb->query_result($res, 0, 'parentid');
			if(!empty($parentid) && $parentid > 0 && (empty($encountered_contact) or !in_array($parentid,$encountered_contact))){
				$parentid = $adb->query_result($res, 0, 'parentid');
				$encountered_contact[] = $parentid;
				$this->__getParentContacts($parentid,$parent_contacts,$encountered_contact);
			}
		}

	   //edit:can 20210427 45598: （https://61mis.com/kfbcrm [^]）联系人查看详情界面，相关信息中点击【查看上下级关系】报错
        $query = 'SELECT
				lastname,
				department,
				title,
				ld_contactdetails.contactid,
				ld_account.accountname,ld_account.accountid,ld_contactdetails.parentid
			FROM
				ld_contactdetails
			LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
			WHERE
				ld_contactdetails.contactid = ?';
		$params = array($id);
		$res = $adb->pquery($query, $params);

		$parent_contact_info = array();
		$depth = 0;
		$immediate_parentid = $adb->query_result($res, 0, 'parentid');
		if (isset($parent_contacts[$immediate_parentid])) {
			$depth = $parent_contacts[$immediate_parentid]['depth'] + 1;
		}
		$parent_contact_info['depth'] = $depth;
        $parent_contact_info['lastname'] = $adb->query_result($res, 0, 'lastname');
		$parent_contact_info['department'] = $adb->query_result($res, 0, 'department');
		$parent_contact_info['title'] = $adb->query_result($res, 0, 'title');
		$parent_contact_info['accountname'] = $adb->query_result($res, 0, 'accountname');
		$parent_contact_info['accountid'] = $adb->query_result($res, 0, 'accountid');
		$parent_contact_info['contactid'] = $adb->query_result($res, 0, 'contactid');
		$parent_contact_info['parentid'] = $adb->query_result($res, 0, 'parentid');
		$parent_contacts[$id] = $parent_contact_info;
		$parent_contacts = $this->__getChildContacts_1($id, $parent_contacts, $depth);
		return $parent_contacts;
	}
	function __getChildContacts_1($id, &$child_contact, $depth) {
		global  $adb;
		$query = 'SELECT
				lastname,
				department,
				title,
				ld_contactdetails.contactid,
				ld_account.accountname,ld_account.accountid,ld_contactdetails.parentid
			FROM
				ld_contactdetails
			LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
			WHERE
				ld_contactdetails.parentid = ?';
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$num_rows = $adb->num_rows($res);
		if ($num_rows > 0) {
			$depth = $depth + 1;
			for($i=0;$i<$num_rows;$i++) {
				$child_con_id = $adb->query_result($res, $i, 'contactid');
				if(array_key_exists($child_con_id,$child_contact)) {
					continue;
				}
				$child_contact_info = array();
				$child_contact_info['depth'] = $depth;
                $child_contact_info['lastname'] = $adb->query_result($res, $i, 'lastname');
				$child_contact_info['department'] = $adb->query_result($res, $i, 'department');
				$child_contact_info['title'] = $adb->query_result($res, $i, 'title');
				$child_contact_info['accountname'] = $adb->query_result($res, $i, 'accountname');
				$child_contact_info['accountid'] = $adb->query_result($res, $i, 'accountid');
				$child_contact_info['contactid'] = $adb->query_result($res, $i, 'contactid');
				$child_contact_info['parentid'] = $adb->query_result($res, $i, 'parentid');
				$child_contact[$child_con_id] = $child_contact_info;
				$this->__getChildContacts($child_con_id, $child_contact, $depth);
			}
		}
		return $child_contact;
	}
	function __getChildContacts($id, &$child_contact, $depth) {
		global  $adb;
		$query = 'SELECT
				lastname,
				department,
				title,
				contactid,
				ld_account.accountname,ld_account.accountid,ld_contactdetails.parentid
			FROM
				ld_contactdetails
			LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
			WHERE
				ld_contactdetails.parentid = ?';
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$num_rows = $adb->num_rows($res);
		if ($num_rows > 0) {
			$depth = $depth + 1;
			for($i=0;$i<$num_rows;$i++) {
				$child_con_id = $adb->query_result($res, $i, 'contactid');
				if(array_key_exists($child_con_id,$child_contact)) {
					continue;
				}
				$child_contact_info = array();
				$child_contact_info['depth'] = $depth;
                $child_contact_info['lastname'] = $adb->query_result($res, $i, 'lastname');
				$child_contact_info['department'] = $adb->query_result($res, $i, 'department');
				$child_contact_info['title'] = $adb->query_result($res, $i, 'title');
				$child_contact_info['accountname'] = $adb->query_result($res, $i, 'accountname');
				$child_contact_info['accountid'] = $adb->query_result($res, $i, 'accountid');
				$child_contact_info['contactid'] = $adb->query_result($res, $i, 'contactid');
				$child_contact_info['parentid'] = $adb->query_result($res, $i, 'parentid');
				$child_contact[$child_con_id] = $child_contact_info;
				$this->__getChildContacts($child_con_id, $child_contact, $depth);
			}
		}
		return $child_contact;
	}

    /**
     * ANDY 
     * DATE 20140321
     * REASON；联系人查看上下级联系人
     */
     function getContctsHierarchy($id) {
		global  $adb, $current_user, $currentModule;
        
        $languageType= getLanguageType($current_user);
		$field_obj=Field::getInstance('Contacts',$adb);
		$moduleFields=$field_obj->getModuleFields();
        $queryGenerator = new QueryGenerator($currentModule, $current_user);
		$listview_header = Array();
		$listview_entries = array();
        $tabid = getTabid('Contacts');
		//获取上级ID
        $sql = "select parentid from ld_contactdetails where contactid = ?";
        $result = $adb->pquery($sql, array($id));
        $parentid = $adb->query_result($result,0,'parentid');
        if(isset($parentid))
            $num = 2;
        else
            $nun = 1;
        $recordidArr = array(0=>$parentid,1=>$id);
        //获取下级ID
        $sqlNextPartentId = "select contactid from ld_contactdetails where parentid = ?";
        $nextResult = $adb->pquery($sqlNextPartentId, array($id));
        for($i = 0; $i<$adb->num_rows($nextResult);$i++)
        {
              $recordidArr[$num + $i] = $adb->query_result($nextResult,$i,'contactid');
        }
        $recordid = implode(',', $recordidArr);
        $query = 'SELECT
				lastname,
				department,
				title,
				contactid,
				ld_account.accountname,ld_account.accountid
			FROM
				ld_contactdetails
			LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
			WHERE
				ld_contactdetails.contactid in ('.$recordid.')';
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 0){
			for($i = 0; $i < $num_rows; $i++){
				$contactid = $adb->query_result($result,$i,'contactid');
				if($contactid == $id){
					$cur_accountid =  $adb->query_result($result,$i,'accountid');
					break;
				}
			}
			$depth = 0;
			for($i = 0; $i < $num_rows; $i++){
				
				$description = [];
				$contactid = $adb->query_result($result,$i,'contactid');
				if($id == $contactid){
					$depth = 1;
				}else{
					if($depth == 1){
						$depth = 2;
					}
				}
				$last_name =  $adb->query_result($result,$i,'lastname');
				if($adb->query_result($result,$i,'department') != '' && !empty($moduleFields['department'])){
					$description[] = $adb->query_result($result,$i,'department');
				}
				if($adb->query_result($result,$i,'title') != '' && !empty($moduleFields['title'])){
					$description[] = $adb->query_result($result,$i,'title');
				}
				$accountid =  $adb->query_result($result,$i,'accountid');
				if($contactid != $id && $accountid != $cur_accountid){
					$description[] = $adb->query_result($result,$i,'accountname');
				}
				$data[$i]['contactid'] = $contactid;
				$data[$i]['type'] = 'Contacts';
				$data[$i]['name'] = $last_name . '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#DADADA;font-size:12px;">' . implode('-',$description) . '</span>';
				$data[$i]['depth'] = $depth;
			}
		}
		return $data;
	} 
    
    function get_communicationLog($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        //获取字段
        $sql_field = 'select GROUP_CONCAT(CONCAT(tablename,".",columnname)) as columnname
         from ld_field where uitype = 1101 and tabid = 4 LIMIT 1;';
        //echo $sql_field;
        $result_field=$adb->pquery($sql_field,array());
        $fieldlabel = $adb->query_result($result_field,0,'columnname');

        $sql_field_value='SELECT '.$fieldlabel.'  from ld_contactdetails
	   
	   LEFT JOIN ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
       WHERE ld_contactdetails.deleted = 0 AND ld_contactdetails.contactid = ?;';
        //echo $sql_field_value;
        $result = $adb->pquery($sql_field_value,array($id));
        $rows = $adb->num_rows($result);
        if($rows > 0){
            $fieldarr = explode(',',$fieldlabel);
            $mobilearr = array();
            for($i=0;$i<$rows;$i++){
                foreach($fieldarr as $flds){
                    $fld = explode('.',$flds);
                    if(isset($fld[1])){
                        $val = $adb->query_result($result,$i,$fld[1]);
                        $mobilearr[$val] = $val;
                    }
                }
            }
        }
		if(!empty($mobilearr)){
			$phone_str = '"'.join('","',$mobilearr).'"';
			$phone_str=trim($phone_str,',');
		}else{
			$phone_str = '0';
		}
        //echo $phone_str;
		$sql = 'select ld_smssend.taskid, ld_smssend.ReceiveContacts,ld_smssend.CalledNumber,
        ld_smssend.Subject, ld_smssend.SmsContent,ld_smssend.SmsBillingFee,
        case when IFNUll(SmsResult,0)=-1 then "待提交" when IFNUll(SmsResult,0)=1 
        then "发送成功" when (IFNUll(SmsResult,0)<>1 and IFNUll(SmsResult,0)<>-1) 
        then "发送失败" end smsresultname,createtime, ld_users.last_name as operator 
        from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name  where
        ld_smssend.CalledNumber in  ('.$phone_str.') order by createtime desc ';
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

        //手机、主题、接收人、发送时间、发件人，
		$header = array(
			'<span title="'.getFixedLabel('Mobile').'">' . getFixedLabel('Mobile') . '</span>',
			'<span title="'.getFixedLabel('Recipient').'">' . getFixedLabel('Recipient') . '</span>',
			'<span title="'.getFixedLabel('Delivery_time').'">' . getFixedLabel('Delivery_time') . '</span>',
			'<span title="'.getFixedLabel('FROMMAIL').'">' . getFixedLabel('FROMMAIL') . '</span>',
			'<span title="'.getFixedLabel('Content').'">' . getFixedLabel('Content') . '</span>',
			'<span title="'.getFixedLabel('SENDSTATESMS').'">' . getFixedLabel('SENDSTATESMS') . '</span>'
		);
        //$header = array('手机','主题','接收人','发送时间','发件人','内容');
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
       // fieldValueUitype::SetMobileStyle($taskid,$callednumber,"CommunicationLog")
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $taskid=$adb->query_result($result,$i,'taskid');
                $callednumber=$adb->query_result($result,$i,'callednumber');
                $listview_entrie = array();
				$listview_entrie[]= '<span title="'.fieldValueUitype::SetMobileStyle($taskid,$callednumber,"CommunicationLog").'">'.fieldValueUitype::SetMobileStyle($taskid,$callednumber,"CommunicationLog").'</span>';
                //$listview_entrie[]= $adb->query_result($result,$i,'subject');
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'receivecontacts').'">'.$adb->query_result($result,$i,'receivecontacts').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'createtime').'">'.$adb->query_result($result,$i,'createtime').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'operator').'">'.$adb->query_result($result,$i,'operator').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smscontent').'">'.$adb->query_result($result,$i,'smscontent').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smsresultname').'">'.$adb->query_result($result,$i,'smsresultname').'</span>';
                $listview_entries[] = $listview_entrie;
            }
        }
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        //print_r($listview_entries);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput,'noofrows'=>$noofrows);
		return $return_value;
	}
    /*
    *更新操作
    *edit:andrwe
    *date:2015-05-27
    *reson:获取工作协同信息
    */
    function get_WorkReport($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user,$adb;
        //duan 20221216 管理员和设置了查看所有关联数据的用户可以看到全部数据
        if($current_user->is_admin == 'on' || $current_user->accountallview == '1'){
            $tmp_sql = ' 1=1 ';    
        }else{
            $tmp_sql = ' ld_workreport2user.userid = ? ';
        }
        
        $SQL_WorkReport="SELECT COUNT(1) as count FROM (
        SELECT
        	ld_workreport.workreportid
        FROM
        	ld_workreport
        LEFT JOIN ld_workreport2user ON ld_workreport.workreportid = ld_workreport2user.workreportid
        LEFT JOIN ld_users ON ld_users.id = ld_workreport2user.userid
        LEFT JOIN ld_users AS usercreator ON ld_workreport.smcreatorid = usercreator.id
        LEFT JOIN ld_salesmanattachmentsrel ON usercreator.id = ld_salesmanattachmentsrel.smid
        LEFT JOIN ld_attachments ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid
        LEFT JOIN ld_workreportcf ON ld_workreportcf.workreportid = ld_workreport.workreportid
        LEFT JOIN (
        	SELECT
        		count(workreportid) AS usercount,
        		workreportid
        	FROM
        		(
        			SELECT
        				(userid),
        				workreportid
        			FROM
        				ld_workreport2user
        			GROUP BY
        				workreportid,
        				userid
        		) AS counttmp
        	GROUP BY
        		workreportid
        ) AS tmp ON tmp.workreportid = ld_workreport.workreportid
        WHERE
        	$tmp_sql
        GROUP BY
        	ld_workreport.workreportid
        ORDER BY
        	ld_workreport.createdtime DESC
        ) as F2 
        INNER JOIN 
        (
        SELECT
        	ld_workreportrelatedto.Relatedto,
        	workreportid
        FROM
        	ld_workreportrelatedto
        LEFT JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.Relatedto
        WHERE
          ld_contactdetails.deleted=0 AND Relatedto=?
        ) as F1 
        ON F1.workreportid=F2.workreportid
        ;";
        
        if($current_user->is_admin == 'on' || $current_user->accountallview == '1'){
            $result = $adb->pquery($SQL_WorkReport,array($id));
        }else{
            $result = $adb->pquery($SQL_WorkReport,array($current_user->id,$id));
        }
        $noofrows = $adb->query_result($result,0,'count');
    	$related_entries = array();
    	$related_entries['relcount'] = $noofrows;
		return $related_entries;
	}
    
    //duan 20220816 更新联系人定位地址、经纬度
	function updateContactsAddress($crmid){
        //duan 20220816 考虑到根据地址获取经纬度存在不精确的问题(泰康制药问题))
        //增加优化，如果通过移动端的定位功能获取到经纬度，则不需要重新计算经纬度（在详细地址不修改的情况下）
        global $weixin_user,$adb;
        if(!empty($weixin_user)&&!empty($_REQUEST['locationaddress'])&&(!isset($_REQUEST['mailingstreet'])||$_REQUEST['mailingstreet'] == $_REQUEST['locationaddress'])
            &&$_REQUEST['locationaddress_lat']>0&&$_REQUEST['locationaddress_lng']>0){
            $tablename = $this->table_name;
            $tableindex = $this->table_index;
            $address = $_REQUEST['locationaddress'];
            $latitude = $_REQUEST['locationaddress_lat'];
            $longtitude = $_REQUEST['locationaddress_lng'];
            $update_address_sql = "update $tablename set location_address =?, longtitude = ?, latitude = ? where $tableindex = ?";
            $adb->pquery($update_address_sql,array($address,$longtitude,$latitude,$crmid));
            return ;
        }
        $module = $this->module_name;
        $lower_module = strtolower($module);
        //缓存文件路径
        $filepath = "modules/".$module."/".$lower_module."address.txt";
        //31591:联系人新增保存后，获取地址经纬度判断服务器是否能上网
        if(file_exists(globalStatic::$root_directory.$filepath))
        {
            $filehandler=file_get_contents(globalStatic::$root_directory.$filepath);
            $handlerinfos=explode("\r\n",$filehandler);
          
            $date=$handlerinfos[0];
            $tmpcheck=$handlerinfos[1];
            if($date!=date("Y-m-d"))
            {
                file_put_contents(globalStatic::$root_directory.$filepath,date("Y-m-d"));
                //$check = @fopen('http://www.baidu.com',"r");  
                $check = @fopen('https://apis.map.qq.com',"r"); 
                if($check){  
                    file_put_contents(globalStatic::$root_directory.$filepath,"\r\n".'yes',FILE_APPEND); 
                }else{  
                    file_put_contents(globalStatic::$root_directory.$filepath,"\r\n".'no',FILE_APPEND);
                    return ; 
                } 
            }
            
            if($tmpcheck=='no')
            {
                return ;
            }
        }
        else
        {
            file_put_contents(globalStatic::$root_directory.$filepath,date("Y-m-d"));
            
             //$check = @fopen('https://www.baidu.com/',"r");  
             $check = @fopen('https://apis.map.qq.com',"r"); 
            if($check){  
             file_put_contents(globalStatic::$root_directory.$filepath,"\r\n".'yes',FILE_APPEND); 
            }else{  
             file_put_contents(globalStatic::$root_directory.$filepath,"\r\n".'no',FILE_APPEND);
             return ; 
            }    
        }
        
        $this->updateContactsAddressWithoutCheckNet($crmid);
	}
    
    //供应商地址保存后计算经纬度
    function updateContactsAddressWithoutCheckNet($crmid){
        global $adb;
        $tablename = $this->table_name;
        $tableindex = $this->table_index;
        //供应商模块没有街道字段,去掉bill_street

        try{

            $query = "select CONCAT_WS('',mailingstate,mailingcity,mailingarea,mailingstreet) as address,locationaddress from $tablename";
            if(!empty($crmid)){
                $query .= " where $tableindex = ?";
            }

            $result = $adb->pquery($query,array($crmid));
        }
        catch (Exception $ex)
        {
            return ;
        }

        
		$num_rows = $adb->num_rows($result);
        if($num_rows>0){
            //用于更新定位地址和经纬度的sql语句
            $update_address_sql = "update $tablename set location_address =?, longtitude = ?, latitude = ? where $tableindex = ?";
            for($i=0; $i<$num_rows; $i++){
    			$address = $adb->query_result($result,$i,'address');
                //天眼查回填时可能出现地址字段信息为空的情况，可直接使用定位地址获取经纬度
                $locationaddress = $adb->query_result($result,$i,'locationaddress');
                if(empty($address) && !empty($locationaddress)){
                    $address = $locationaddress;    
                }
    			if(!empty($address)){
                    $AddressInfos=getCoordinateByTecentApi($address);
                    
    				if(array_key_exists('result',$AddressInfos)){
    					$longtitude = $AddressInfos['result']['location']['lng'];
    					$latitude = $AddressInfos['result']['location']['lat'];
    					$adb->pquery($update_address_sql,array($address,$longtitude,$latitude,$crmid));
    				}else{
    				    //0033639: 企业微信>灵当CRM>拜访签到>添加拜访客户：结果地址没有改变。
                        $adb->pquery($update_address_sql,array($address,'','',$crmid));
    				}
    			}else{
    			     $adb->pquery($update_address_sql,array($address,'','',$crmid));
    			}
    		}
        }
    }
    
    //获取角色字段权限
    public function getProfileFields($profileid){
        //从客户模块保存联系人时，不需要判断字段权限
        if($this->CheckFieldProfile == 'no'){
            return '';
        }
        $profileobj = Profile::getInstance();
        $profilefields = $profileobj->getProfileInfos($profileid);
        $profilefields = $profilefields['field'];
        
        return $profilefields;
    }
    
    //获取当前模块主表字段
    public function getMainModuleFields(){
        //从客户模块保存联系人时，不需要判断字段权限
        if($this->CheckFieldProfile == 'no'){
            $modulefields = $this->fieldobj->getModuleAllPreseneceFields();
        }
        else{
            //zkt 20241129 BUG20241128-55 用户 联系人-客户名称 字段权限为只读时，编辑保存变为空
            $modulefields = parent::getMainModuleFields();
        }
        return $modulefields;
    }

    public function get_ContactsNetGraph($record){
        crm_load_class_file('ContactsNetGraph','modules/Contacts');
        $NetGraphObj = new ContactsNetGraph($record);
        $NetGraphObj->getNetGraphData();
    }

}
Contacts::require_file();
?>