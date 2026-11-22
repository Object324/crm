<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of txhe License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/



class HelpDesk extends CRMEntity {
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['HelpDesk']='HelpDesk';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
	var $table_name = "ld_troubletickets";
	var $table_index= 'ticketid';
    var $table_code='ticket_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_troubletickets','ld_ticketcf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_troubletickets'=>'ticketid','ld_ticketcf'=>'ticketid','ld_ticketcomments'=>'ticketid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_ticketcf', 'ticketid');
    //	//关联模块
    var $relatedtab=array('accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','helpdesk'=>'','salesorder'=>'','contacts'=>'');
	var $column_fields = Array();
     var $module_name='HelpDesk';
	//Pavani: Assign value to entity_table
        var $entity_table = "ld_crmentity";

	var $sortby_fields = Array('title','status','priority','crmid','firstname','smownerid');


	var $list_link_field= 'ticket_title';


	var $search_fields = Array(
		//'Ticket ID' => Array('ld_crmentity'=>'crmid'),
		'Ticket No' =>Array('ld_troubletickets'=>'ticket_no'),
		'Title' => Array('ld_troubletickets'=>'ticket_title')
		);
	var $search_fields_name = Array(
		'Ticket No' => 'ticket_no',
		'Title'=>'ticket_title',
		);
	//Specify Required fields
    var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime');

     //Added these variables which are used as default order by and sortorder in ListView
        var $default_order_by = 'ticket_title';
        var $default_sort_order = 'DESC';

	// For Alphabetical search
    /**
     * 4558: 服务单序时簿：字母查询无效，没有关联字母查询
     * edit:can
     * date:20130731
     * */
	var $def_basicsearch_col = 'ticket_title';
    
    

	//var $groupTable = Array('ld_ticketgrouprelation','ticketid');
   
	function __construct()
	{
		//$this->log =LoggerManager::getLogger('helpdesk');
		//$this->log->debug("Entering HelpDesk() method ...");
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('HelpDesk',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
	//	$this->log->debug("Exiting HelpDesk method ...");
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('HelpDesk');
        $this->list_link_field=$entityname['fieldname'];
	}


	function save_module($module)
	{
	    global $adb,$current_user;
		//Inserting into Ticket Comment Table
		$this->insertIntoTicketCommentTable("ld_ticketcomments",$module);
		
		//Inserting into ld_attachments
		//$this->insertIntoAttachment($this->id,$module);
		
		//service contract update
		$return_action = $_REQUEST['return_action'];
		$for_module = $_REQUEST['return_module'];
		$for_crmid  = $_REQUEST['return_id'];
        if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']!='')
        {
            //弹出层界面保存方法
            $for_module = $_REQUEST['tablerelmodule'];
			$for_crmid  = $_REQUEST['tablerelid'];
			$on_focus = CRMEntity::getInstance($for_module);
			$on_focus->save_related_module($for_module, $for_crmid, $module, $this->id);
        }
        /*
		if ($return_action && $for_module && $for_crmid) {
			if ($for_module == 'ServiceContracts'||$for_module=="Project"||$for_module=='Products') {
			     
				$on_focus = CRMEntity::getInstance($for_module);
				$on_focus->save_related_module($for_module, $for_crmid, $module, $this->id);
                $_REQUEST['return_module']=$module;
                $_REQUEST['return_id']=$this->id;
			}
		}*/
        if($this->id>0) {
            foreach ($this->before_field_info as $fieldinfo) {
                //获取保存前客户或销售机会ID
                $columnname = $fieldinfo->getColumnName();//
                $relateid = $fieldinfo->getColumn_Value();
                if ($columnname == 'accountid' && !empty($relateid)) {
                    $accountids[$relateid] = $relateid;
                }

            }
            if (!empty($this->column_fields['account_id'])) {
                $accountids[$this->column_fields['account_id']] = $this->column_fields['account_id'];
            }
            if ( is_array($accountids)&& sizeof($accountids) > 0) {
                $this->updateRelatedTableInfo('ld_account', $accountids);
            }
            //hjz 获取保存时联系人的id
            if(!empty($this->column_fields['contact_id'])){
              $contactids[$this->column_fields['contact_id']] = $this->column_fields['contact_id'];
            }
           
            if(is_array($contactids)&&  sizeof($contactids)>0) {
               $this->updateRelatedTableInfo('ld_contactdetails',$contactids);
            }
        }
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
             $one_filenames=$filenames.$restore_phone;
             if($callfilenames[1]!='')
             {
                $one_filenames.='_'.$callfilenames[1];
             }
                
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
               
                $sqlUpdate = "update ld_callbutler set userid=?,calltype = ?, ticketid = ?,description = ?,accountid=?,contactid=?
                
                 where id = ? ";
                $updateResult=$adb->pquery($sqlUpdate,array($current_user->id,$calltype,$this->id,$callButlerRemarks,$_REQUEST['account_id'],$_REQUEST['contact_id'],$callButlerID));
                
                
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
                $insertresult=$adb->pquery($sqlInsert,array($calltype,'','接通',null,null,'',$callbutlername,$current_user->id,
                $_REQUEST['account_id'],$_REQUEST['contact_id'],$this->id,0,0,0,0,$callButlerRemarks));
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

                $sqlUpdate = "update ld_callbutler set ticketid = ?,description = ?,accountid = ?,contactid = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $_REQUEST['account_id'], $_REQUEST['contact_id'], $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    $_REQUEST['account_id'],  $_REQUEST['contact_id'], $this->id, 0, 0, 0, 0, 0, ''));
            }
        }

		//更新服务合同的服务次数
		$query = 'select servicecontractsid from ld_troubletickets where servicecontractsid = ? and deleted = 0';
		$result = $adb->pquery($query,array($this->column_fields['servicecontractsid']));
       
		$num_rows = $adb->num_rows($result);
		if(empty($num_rows))$num_rows = 0;
		$adb->pquery('update ld_servicecontracts set service_units=? where servicecontractsid=?',array($num_rows,$this->column_fields['servicecontractsid']));
            
    }

    /**
    * @edit:dong
    * @data:2020/08/20
    * @reason:更新对应模块的某些字段
    * @description:
    */
    function updateRelatedTableInfo($table,$relateids)
    {
        global $adb;

        if(sizeof($relateids) > 0)
        {

            foreach($relateids as $accountid) {
                if(empty($accountid))
                {
                    continue;
                }
                if ($table == 'ld_account')    $condition = " accountid=$accountid ";
                if ($table == 'ld_contactdetails')  $condition = " contactid=$accountid ";
                $sql = "SELECT
								createdtime,
                                solution
							FROM " . $this->table_name . "
							WHERE deleted = 0
								AND " . $condition . "
							ORDER BY
								createdtime DESC limit 1";

                $result = $adb->pquery($sql);

                if ($adb->num_rows($result) > 0) {

                    $createdtime  = $adb->query_result($result, 0, 'createdtime');
                    $solution = $adb->query_result($result, 0, 'solution');


                    $sql = "update $table set  ";

                    $update_params = array();

                    if ($createdtime != '' && $createdtime > '1600-01-01') {
                        $lastservicetime = $createdtime;

                    }
                    
                    if ($lastservicetime > 0) {

                        if($table == 'ld_contactdetails'){//如果为ld_contactdetails，再更新最新联系日期
                            $sql .= ' lastcontactdate=?';
                        }else{
                            $sql .= ' lastservicetime=?';
                        }
                        
                        $update_params[] = $lastservicetime;
                    }
                    
                    if($table == 'ld_contactdetails'){
                        //hjz 添加解决方案字段
                        if (trim($solution) != '' ) {
                            if (is_array($update_params) && sizeof($update_params) > 0) 
                            	$sql .= ',';
                            $sql .= ' lastcontent=? ';
    
                            $update_params[] = vtlib_purify($solution);
    
                        }
                        //hjz 添加未联系天数字段
                        $nolinkdays=floor((time()-strtotime($createdtime))/3600/24) ;
                        if($nolinkdays<0) $nolinkdays=0;
                        $sql .= ', nolinkdays='.$nolinkdays;
                    }
                    if (is_array($update_params) && sizeof($update_params) > 0) {
                        if ($table == 'ld_account'){
                            $sql .= ' where accountid=? ;';
                        }
                        else if ($table == 'ld_contactdetails'){
                          $sql .= ' where contactid=? ;';
                        }
                        $update_params[] = $accountid;
                        $adb->pquery($sql, $update_params);
                    }

                } else {
                    //如果客户或者销售机会没有相关联系记录，则清空客户或销售机会的相关字段
                    if ($table == 'ld_account') {
                        $sql = "update $table set lastservicetime=? where accountid=? ";

                        $adb->pquery($sql, array(null, $accountid));
                    }
                    else if ($table == 'ld_contactdetails') {
                        $sql = "update $table set lastcontactdate=?,lastcontent=? where contactid=? ; ";

                        $adb->pquery($sql, array(null, null, $accountid));
                    }
                }
            }
        }
    }

	function save_related_module($module, $crmid, $with_module, $with_crmid) {	
	   
        $adb = $this->db;
        if($with_module=='Products')
        {
             if(!is_array($with_crmid)) $with_crmids = Array($with_crmid);
       	    foreach($with_crmids as $relcrmid) 
            {
                $adb->pquery("insert into ld_seproductsrel values(?,?,?)", array($crmid, $relcrmid, $module));
            }
        }
		else
        {
            parent::save_related_module($module, $crmid, $with_module, $with_crmid);
    		if ($with_module == 'ServiceContracts') {
    			$serviceContract = CRMEntity::getInstance($with_module);
    	 		$serviceContract->updateHelpDeskRelatedTo($with_crmid,$crmid);
    	 		$serviceContract->updateServiceContractState($with_crmid);
    	 	}
            /*if ($with_module == 'Faq') {
    			InsertTroubletickets2Faq($crmid,$with_crmid);
    	 	}*/
        }
       
        
	}

	/** Function to insert values in ld_ticketcomments  for the specified tablename and  module
  	  * @param $table_name -- table name:: Type varchar
  	  * @param $module -- module:: Type varchar
 	 */
	function insertIntoTicketCommentTable($table_name, $module)
	{
		
		global $adb;
		global $current_user;

		$current_time = $adb->formatDate(date('Y-m-d H:i:s'), true);
		if ($this->column_fields['from_portal'] != 1) {
			$ownertype = 'user';
			$ownerId = $current_user->id;
		} else {
			$ownertype = 'customer';
			$ownerId = $this->column_fields['parent_id'];
		}

		$comment = $this->column_fields['comments'];
		if ($comment != '') {
			$sql = "insert into ld_ticketcomments values(?,?,?,?,?,?)";
			$params = array('', $this->id, from_html($comment), $ownerId, $ownertype, $current_time);
			$adb->pquery($sql, $params);
		}
	}

	public function successApprove($crmid)
    {  
        // 商贸批发小程序
        // 东贸特殊开发，微信公众号，加班申请推送
		$version_info = getVersionInfo();
		if($version_info['trade'] == 'dongmao' && $version_info['account'] == 'dongmao' && !empty($crmid)){
			global $adb;
			$query = 'select accountname,ld_troubletickets.accountid,cf_5140,cf_5142,cf_5138,cf_5139,last_name,ld_groups.groupname,ld_contactdetails.lastname from ld_troubletickets 
			LEFT JOIN ld_ticketcf on ld_troubletickets.ticketid = ld_ticketcf.ticketid 
			LEFT JOIN ld_users on ld_users.id = ld_troubletickets.smownerid 
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users.groupid 
			LEFT JOIN ld_account on ld_account.accountid = ld_troubletickets.accountid 
			LEFT JOIN ld_contactdetails on ld_contactdetails.contactid = ld_troubletickets.contactid 
			where ld_troubletickets.ticketid = ?';
			$result = $adb->pquery($query,array($crmid));
			
			$cf_5140 = $adb->query_result($result,0,'cf_5140');	//加班原因
			$cf_5142 = $adb->query_result($result,0,'cf_5142');	//加班规定
			$cf_5138 = $adb->query_result($result,0,'cf_5138');	//加班开始时间
			$cf_5139 = $adb->query_result($result,0,'cf_5139');	//加班结束时间
			$last_name = $adb->query_result($result,0,'last_name');
			$groupname = $adb->query_result($result,0,'groupname');
			$accountid = $adb->query_result($result,0,'accountid');
			$accountname = $adb->query_result($result,0,'accountname');
			$lastname = $adb->query_result($result,0,'lastname');
			if(!empty($accountid)){
				$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
				$result = $adb->pquery($query,array($accountid));
				$unionid = $adb->query_result($result,0,0);
				$query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmsh'";
				$result = $adb->pquery($query,array($unionid));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					$open_id = $adb->query_result($result,0,'open_id');
					$wechatuserid = $adb->query_result($result,0,'wechatuserid');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMerchantMessage.php');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageMerchantDefault.php');
					$dongmaoObj = new cls_DongmaoMerchantMessage();
					$dmMsgData = cls_DMmessageMerchantDefault::$DMmessageData['WorkOvertime'];
					$dmMsgPage = cls_DMmessageMerchantDefault::$DMmessageJump['WorkOvertime'];
					// $open_id = 'oFb1D6vrhRAR99vOVhwslZTaJhKs';
					// $wechatuserid = 227441;
					$data = array(
						'title' => $dmMsgData['title'],	
						'name' => $accountname,
						'department' => '',
						'time_start' => $cf_5138,
						'time_end' => $cf_5139,
						'content' => $cf_5140,
						'remark' => $dmMsgData['remark']
					);
					$dongmaoObj->send('WorkOvertime',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'HelpDesk',$crmid,$dmMsgPage['pageType'],$accountid);
				}
			}

		}
	}

	/**
	 *      This function is used to add the ld_attachments. This will call the function uploadAndSaveFile which will upload the attachment into the server and save that attachment information in the database.
	 *      @param int $id  - entity id to which the lingdang_files to be uploaded
	 *      @param string $module  - the current module name
	
	function insertIntoAttachment($id,$module)
	{
		global $adb;
	
		$file_saved = false;

		foreach($_FILES as $fileindex => $files)
		{
			if($files['name'] != '' && $files['size'] > 0)
			{
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex.'_hidden']);
				$file_saved = $this->uploadAndSaveFile($id,$module,$files);
			}
		}

		
	}*/
	 function get_related_list($id, $cur_tab_id, $rel_tab_id, $actions = false) {
    
		global $currentModule, $app_strings, $singlepane_view;

		$parenttab = getParentTab();

		$related_module = getTabname($rel_tab_id);
		$other = CRMEntity::getInstance($related_module);


		$button = '';
		if ($actions) {
			if (is_string($actions))
				$actions = explode(',', strtoupper($actions));
			if (in_array('SELECT', $actions) && isPermitted($related_module, 4, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
				type="button" name="button" onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
				<span>'.getFixedLabel('SELECT').'</span>
				</a>';
			}
			if (in_array('ADD', $actions) && isPermitted($related_module, 'Create', '') == 'yes') {
                $button .= '<a title="'.getFixedLabel('CREATE').'"
                href="index.php?module='.$related_module.'&action=EditView&return_module='.$currentModule.'&return_action=DetailView&Create=yes&account_id='.$_REQUEST['account_id'].'&contact_id='.$_REQUEST['contact_id'].'&return_id='.$id.'&salesorder_id='.$_REQUEST['salesorder_id'].'" target="_blank"/>
                <span>'.getFixedLabel('CREATE').'</span>
                </a>';
			}
		}

		// To make the edit or del link actions to return back to same view.
		if ($singlepane_view == 'true')
			$returnset = "&return_module=$currentModule&return_action=DetailView&return_id=$id";
		else
			$returnset = "&return_module=$currentModule&return_action=CallRelatedList&return_id=$id";

		$query = 'SELECT ld_crmentity.*, '.$other->table_name.'.* ';
								//		'last_name' => 'LD_users.last_name'), 'Users');
		$query .= ', ld_users.last_name as user_name';

		$more_relation = '';
		if (!empty($other->related_tables)) {
			foreach ($other->related_tables as $tname => $relmap) {
				$query .= ','.$tname.'.* ';

				// Setup the default JOIN conditions if not specified
				if (empty($relmap[1]))
					$relmap[1] = $other->table_name;
				if (empty($relmap[2]))
					$relmap[2] = $relmap[0];
				$more_relation .= ' LEFT JOIN '.$tname.' ON '.$tname.'.'.$relmap[0].' = '.$relmap[1].'.'.$relmap[2].' ';
			}
		}

		$query .= ' FROM '.$other->table_name.' ';
		$query .= " INNER JOIN ld_crmentity ON ld_crmentity.crmid = $other->table_name.$other->table_index";
		$query .= ' INNER JOIN ld_crmentityrel ON (ld_crmentityrel.relcrmid = '.$other->table_name.'.'.$other->table_index.' OR ld_crmentityrel.crmid = '.$other->table_name.'.'.$other->table_index.') ';
		$query .= $more_relation;
		$query .= ' LEFT  JOIN ld_users ON ld_users.id = '.$other->table_name.'.smownerid ';
	//	$query .= " LEFT  JOIN LD_groups ON LD_groups.groupid = ld_crmentity.smownerid";
		$query .= ' WHERE '.$other->table_name.'.deleted = 0 AND (ld_crmentityrel.crmid = '.$id.' OR ld_crmentityrel.relcrmid = '.$id.')';
		//echo $query;
        $return_value = GetRelatedList($currentModule, $related_module, $other, $query, $button, $returnset);
        
		if ($return_value == null)
			$return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;

		return $return_value;
	}

	/**     Function to get the Ticket History information as in array format
	 *	@param int $ticketid - ticket id
	 *	@return array - return an array with title and the ticket history informations in the following format
							array(
								header=>array('0'=>'title'),
								entries=>array('0'=>'info1','1'=>'info2',etc.,)
							     )
	 */
	function get_ticket_history($ticketid)
	{
		global  $adb;

		$query="select title,update_log from ld_troubletickets where ticketid=?";
		$result=$adb->pquery($query, array($ticketid));
		$update_log = $adb->query_result($result,0,"update_log");

		$splitval = split('--//--',trim($update_log,'--//--'));

		$header[] = $adb->query_result($result,0,"title");

		$return_value = Array('header'=>$header,'entries'=>$splitval);

		return $return_value;
	}
    
    function get_communicationLog($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        $sql = 'select ld_smssend.ReceiveContacts,ld_smssend.CalledNumber,
        ld_smssend.Subject, ld_smssend.SmsContent,ld_smssend.SmsBillingFee,
        case when IFNUll(SmsResult,0)=-1 then "待提交" when IFNUll(SmsResult,0)=1 
        then "发送成功" when (IFNUll(SmsResult,0)<>1 and IFNUll(SmsResult,0)<>-1) 
        then "发送失败" end smsresultname,createtime, ld_users.last_name as operator  
        from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name  
        where relatieid = '.$id.' order by ld_smssend.createtime desc ';
        $count_result = $adb->query(mkCountQuery($sql));
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
        //手机、主题、接收人、发送时间、发件人、内容，
		$header = array(
			'<span title="'.getFixedLabel('Mobile').'">' . getFixedLabel('Mobile') . '</span>',
			'<span title="'.getFixedLabel('Recipient').'">' . getFixedLabel('Recipient') . '</span>',
			'<span title="'.getFixedLabel('Delivery_time').'">' . getFixedLabel('Delivery_time') . '</span>',
			'<span title="'.getFixedLabel('FROMMAIL').'">' . getFixedLabel('FROMMAIL') . '</span>',
			'<span title="'.getFixedLabel('Content').'">' . getFixedLabel('Content') . '</span>',
			'<span title="'.getFixedLabel('SENDSTATESMS').'">' . getFixedLabel('SENDSTATESMS') . '</span>'
		);
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
				$listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'callednumber').'">'.$adb->query_result($result,$i,'callednumber').'</span>';
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



function get_products($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;

        $related_module = vtlib_getModuleNameById($rel_tab_id);
		require_once("modules/$related_module/$related_module.php");
		$other = new $related_module();
        vtlib_setup_modulevars($related_module, $other);
		$singular_modname = vtlib_toSingular($related_module);

		$parenttab = getParentTab();

		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;

		$button = '';

		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= '<button title="'.getFixedLabel('SELECT').'" href="javascript:void(0);"
					type="button" name="button" onclick=\'return window.open("index.php?module='.$related_module.'&return_module='.$currentModule.'&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid='.$id.'&parenttab='.$parenttab.'","test","width=640,height=602,resizable=0,scrollbars=0");\'>
    				<span>'.getFixedLabel('SELECT').'</span>
    				</button>';
			}
			if(in_array('ADD', $actions) && isPermitted($related_module,"Create", '') == 'yes') {
				$button .= '<button title="'.getFixedLabel('CREATE').'"
					type="button" name="button" onclick="this.form.action.value=\'EditView\';this.form.module.value=\''.$related_module.'\';MoreCreateModuleFromAccount(this,this.form);">
    				<span>'.getFixedLabel('CREATE').'</span>
    				</button>';
			}
		}

		$query = "SELECT ld_products.productid, ld_products.productname,
			ld_products.productcode, ld_products.commissionrate,
			ld_products.qty_per_unit, ld_products.unit_price,ld_products.productcategory, 
			ld_crmentity.crmid, ld_crmentity.smownerid,ld_products.product_no,ld_products.usageunit,ld_products.productsheet
			FROM ld_products
			INNER JOIN ld_seproductsrel ON ld_products.productid = ld_seproductsrel.productid and ld_seproductsrel.setype='HelpDesk'
			INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_products.productid
			INNER JOIN ld_troubletickets ON ld_troubletickets.ticketid = ld_seproductsrel.crmid
			LEFT JOIN ld_users
				ON ld_users.id=ld_crmentity.smownerid
		
			WHERE ld_crmentity.deleted = 0 AND ld_troubletickets.ticketid = $id";
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);

		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
        
		return $return_value;
	}
	/**	Function to process the list query and return the result with number of rows
	 *	@param  string $query - query
	 *	@return array  $response - array(	list           => array(
											$i => array(key => val)
									       ),
							row_count      => '',
							next_offset    => '',
							previous_offset	=>''
						)
		where $i=0,1,..n & key = ticketid, title, firstname, ..etc(range_fields) & val = value of the key from db retrieved row
	**/
	function process_list_query($query,$row_offset=0, $limit = -1, $max_per_page = -1)
	{
	

   		$result =& $this->db->query($query,true,"Error retrieving $this->object_name list: ");
		$list = Array();
	        $rows_found =  $this->db->getRowCount($result);
        	if($rows_found != 0)
	        {
			$ticket = Array();
			for($index = 0 , $row = $this->db->fetchByAssoc($result, $index); $row && $index <$rows_found;$index++, $row = $this->db->fetchByAssoc($result, $index))
			{
		                foreach($this->range_fields as $columnName)
                		{
		                	if (isset($row[$columnName]))
					{
			                	$ticket[$columnName] = $row[$columnName];
                    			}
		                       	else
				        {
		                        	$ticket[$columnName] = "";
			                }
	     			}
    		                $list[] = $ticket;
                	}
        	}

		$response = Array();
	        $response['list'] = $list;
        	$response['row_count'] = $rows_found;
	        $response['next_offset'] = $next_offset;
        	$response['previous_offset'] = $previous_offset;

	
	        return $response;
	}

	/**	Function to get the HelpDesk field labels in caps letters without space
	 *	@return array $mergeflds - array(	key => val	)    where   key=0,1,2..n & val = ASSIGNEDTO,RELATEDTO, .,etc
	**/
	function getColumnNames_Hd()
	{
		global $current_user;
		
		$is_admin=is_admin($current_user);
		if($is_admin == true)
		{
			$sql1 = "select fieldlabel from ld_field where tabid=13 and block <> 30 and ld_field.uitype <> '61' and ld_field.presence in (0,2)";
			$params1 = array();
		}else
		{
			$profileList = $current_user->profileid;
			$sql1 = "select ld_field.fieldid,fieldlabel from ld_field inner join ld_profile2field on ld_profile2field.fieldid=ld_field.fieldid inner join ld_def_org_field on ld_def_org_field.fieldid=ld_field.fieldid where ld_field.tabid=13 and ld_field.block <> 30 and ld_field.uitype <> '61' and ld_field.displaytype in (1,2,3,4) and ld_profile2field.visible=0 and ld_def_org_field.visible=0 and ld_field.presence in (0,2)";
			$params1 = array();
			if (count($profileList) > 0) {
				$sql1 .= " and ld_profile2field.profileid in (". generateQuestionMarks($profileList) .")  group by fieldid";
				array_push($params1, $profileList);
			}
		}
		$result = $this->db->pquery($sql1, $params1);
		$numRows = $this->db->num_rows($result);
		for($i=0; $i < $numRows;$i++)
		{
			$custom_fields[$i] = $this->db->query_result($result,$i,"fieldlabel");
			$custom_fields[$i] = preg_replace("/\s+/","",$custom_fields[$i]);
			$custom_fields[$i] = strtoupper($custom_fields[$i]);
		}
		$mergeflds = $custom_fields;

		return $mergeflds;
	}

	/**
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
		$rel_table_arr = Array("Activities"=>"ld_seactivityrel","Attachments"=>"ld_seattachmentsrel","Documents"=>"ld_senotesrel");

		$tbl_field_arr = Array("ld_seactivityrel"=>"activityid","ld_seattachmentsrel"=>"attachmentsid","ld_senotesrel"=>"notesid");

		$entity_tbl_field_arr = Array("ld_seactivityrel"=>"crmid","ld_seattachmentsrel"=>"crmid","ld_senotesrel"=>"crmid");

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
			"Calendar" => array("ld_seactivityrel"=>array("crmid","activityid"),"ld_troubletickets"=>"ticketid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_troubletickets"=>"ticketid"),
			"Products" => array("ld_troubletickets"=>array("ticketid","product_id")),
			"Services" => array("ld_crmentityrel"=>array("crmid","relcrmid"),"ld_troubletickets"=>"ticketid"),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
       
		if(empty($return_module) || empty($return_id)) return;
        
        if($return_module == 'ServiceContracts')
        {
            $this->trash('HelpDesk',$id);
        }
		elseif($return_module == 'Contacts' || $return_module == 'Accounts') {
			$sql = 'UPDATE ld_troubletickets SET parent_id=? WHERE ticketid=?';
			$this->db->pquery($sql, array(null, $id));
			$se_sql= 'DELETE FROM ld_seticketsrel WHERE ticketid=?';
			$this->db->pquery($se_sql, array($id));
		} elseif($return_module == 'Products') {
			$sql = 'UPDATE ld_troubletickets SET product_id=? WHERE ticketid=?';
			$this->db->pquery($sql, array(null, $id));
           
		}
        elseif($return_module=='SalesOrder')
        {
            $sql = 'UPDATE ld_troubletickets SET salesorderid=? WHERE ticketid=?';
			$this->db->pquery($sql, array(null, $id));
        }
         else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
            
		}
	}


    public function restore($module,$id)
    {
        global $adb;
        parent::restore($module,$id);
         /*
        andrew
        20140226
        还原时候服务合同统计加1
        */

            $csdl =$adb->pquery("SELECT crmid FROM ld_crmentityrel where module='ServiceContracts' and relmodule='HelpDesk' and relcrmid=?",array($id));
            $rowCount = $adb->num_rows($csdl);
            for($i=0;$i<$rowCount;$i++){
                $crmids[$i] = $adb->query_result($csdl,$i,"crmid");
            }
            foreach($crmids as $arr){
   	            $su_qry = $adb->pquery("select service_units from ld_servicecontracts where servicecontractsid=?", array($arr));
	            $service_units = $adb->query_result($su_qry,0,"service_units");
    
                if(empty($service_units)){
                $service_units=1;
                }else{
                $service_units=$service_units+1;
                }
                $adb->pquery("update ld_servicecontracts set service_units=$service_units where servicecontractsid=?", array($arr));
            }
		
    }
	//获取单据对应客户的最晚服务到期日
	function getAccountsForLastservicedate($record,$frommodule = ''){
		//客户最晚服务到期日到期后是否允许创建客户服务单 1：是  0：否
		$deployarray=getSys_deploy(166);
		if($deployarray['deploy_value'] != 1){
			if(!empty($record)){
				if(empty($frommodule)){
					$frommodule = getSalesEntityType($record);
				}
				if($frommodule == 'Accounts' || $frommodule == 'ServiceCharge'){
					$focus = CRMEntity::getInstance($frommodule);
					$focus->retrieve_entity_info($record, $frommodule);
					$lastservicedate = $focus->column_fields['lastservicedate'];
				}else{
					$focus = CRMEntity::getInstance($frommodule);
					$focus->retrieve_entity_info($record, $frommodule);
					if($focus->column_fields['account_id'] > 0){
						$acc_focus = CRMEntity::getInstance('Accounts');
						$acc_focus->retrieve_entity_info($focus->column_fields['account_id'], 'Accounts');
						$lastservicedate = $acc_focus->column_fields['lastservicedate'];
					}
				}
                //20230608 duan 日期类型为空时在数据库可能存为'0000-00-00',不能只用empty判断
				if(!empty($lastservicedate) && strtotime($lastservicedate) > strtotime('1970-01-01') && $lastservicedate < date('Y-m-d')){
					return 'error';
				}else{
					return 'ok';
				}
			}
		}
		return 'ok';
	}
	function clearSingletonSaveFields() {
		$this->column_fields['comments'] = '';
	}
	function getHelpDesk_Log(){
		global $current_user,$adb;
		if($current_user->helpdesk_log == ''){
			$query = 'select helpdesk_log from ld_users where id = ?';
			$result = $adb->pquery($query,array($current_user->id));
			$helpdesk_log = $adb->query_result($result,0,'helpdesk_log');
		}else{
			$helpdesk_log = $current_user->helpdesk_log;
		}
		return $helpdesk_log;
	}
    function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        $root_dir_index= dirname(dirname(dirname(__FILE__)));
        require_once($root_dir_index.'/CallCenter/lib/jiuWei.php');
        $jiuObj = jiuWei::autoLoad();
        if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
            return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'HelpDesk');
        }
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_troubletickets as T2 on  T1.ticketid = T2.ticketid 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.ticketid > 0 and T1.ticketid = '.$id;
        
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
                $listview_entrie[]= fieldValueUitype::setReportMobileStyle($adb->query_result($result,$i,'phone'));
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
	}
    /*
    function getListQuery($module, $where = '') {
      
        $customview=CustomView::getInstance($module);
        $moduleobj=$this;
    	
    	$table_name = $moduleobj->table_name;
    
        $viewid=$customview->getViewId($module);
        $columnlist=$customview->getColumnsListByCvid($viewid);
       
        $fromclause="";
    	$ismodtable = array('ld_crmentity'=>'1','ld_accountbillads'=>'1',
    		'ld_accountshipads'=>'1','ld_contactaddress'=>'1','ld_contactsubdetails'=>'1');
    
        foreach($columnlist as $colmn)
        {
             $arrcolumn=explode(":",$colmn);
    	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
    				$arrcolumn[0] = $table_name;
    			 }
            $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
        }
        $fromclause = str_replace('ld_troubletickets.title','ld_troubletickets.ticket_title',$fromclause);
			$query = "SELECT ld_troubletickets.ticketid as crmid,ld_users.last_name".$fromclause .
			" FROM ld_troubletickets
			INNER JOIN ld_ticketcf
				ON ld_ticketcf.ticketid = ld_troubletickets.ticketid
			LEFT JOIN ld_contactdetails
				ON ld_troubletickets.contactid = ld_contactdetails.contactid
			LEFT JOIN ld_account
				ON ld_account.accountid = ld_troubletickets.accountid 
			LEFT JOIN ld_users
				ON ld_troubletickets.smownerid = ld_users.id
			LEFT JOIN ld_products
				ON ld_products.productid = ld_troubletickets.product_id";
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_troubletickets.ticketid";
			$query .= "  WHERE ld_troubletickets.deleted = 0 " . $where;
            return $query;
    }*/
    
}
HelpDesk::require_file();
?>