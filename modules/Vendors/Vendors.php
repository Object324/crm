<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/



class Vendors extends CRMEntity {
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Vendors']='Vendors';
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    
	var $log;
	var $db;
	var $table_name = "ld_vendor";
	var $table_index= 'vendorid';
    var $table_code='vendor_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_vendor','ld_vendorcf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_vendor'=>'vendorid','ld_vendorcf'=>'vendorid');
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('vendors'=>'','users'=>'','company'=>'');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_vendorcf', 'vendorid');
	var $column_fields = Array();
    var $module_name='Vendors';
        //Pavani: Assign value to entity_table
        var $entity_table = "ld_crmentity";
        var $sortby_fields = Array('vendorname','category');

        var $list_link_field= 'vendorname';

	var $search_fields = Array(
                                'Vendor Name'=>Array('vendor'=>'vendorname'),
                                'Phone'=>Array('vendor'=>'phone')
                                );
        var $search_fields_name = Array(
                                        'Vendor Name'=>'vendorname',
                                        'Phone'=>'phone'
                                     );
	//Specifying required fields for vendors
        var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to lingdang_field.fieldname values.
	var $mandatory_fields = Array('createdtime', 'modifiedtime', 'vendorname');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'vendorname';
	var $default_sort_order = 'ASC';
    var $IsCustomModule = true;//查重
	// For Alphabetical search
	var $def_basicsearch_col = 'vendorname';
	
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('vendor');
		//$this->log->debug("Entering Vendors() method ...");
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Vendors',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
	   /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Vendors');
        $this->list_link_field=$entityname['fieldname'];
	}

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
                
                $sqlUpdate = "update ld_callbutler set userid=?, phone=?, calltype = ?, vendorid = ?,description = ? where id = ? ";
                $updateResult=$adb->pquery($sqlUpdate,array($current_user->id,$restore_phone, $calltype,$this->id,$callButlerRemarks,$callButlerID));
                
                
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
                0,0,0,$this->id,0,0,0,$callButlerRemarks));
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

                $sqlUpdate = "update ld_callbutler set vendorid = ?,description = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    0,  0, 0, $this->id, 0, 0, 0, 0, ''));
            }
        }
        
        //供应商地址保存后重算经纬度
        if(isset($_REQUEST['bill_state'])||isset($_REQUEST['bill_city'])
                ||isset($_REQUEST['bill_street'])||isset($_REQUEST['bill_area'])||isset($_REQUEST["bill_street_mass_edit_check"])
                || ($_REQUEST['ajxaction'] == 'DETAILVIEW' && in_array($_REQUEST['fldName'],array('bill_state','bill_city','bill_area')))){
	               $this->updateVendorsAddress($this->id);
		}
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
		$rel_table_arr = Array("Products"=>"ld_products","PurchaseOrder"=>"ld_purchaseorder","Contacts"=>"ld_vendorcontactrel");

		$tbl_field_arr = Array("ld_products"=>"productid","ld_vendorcontactrel"=>"contactid","ld_purchaseorder"=>"purchaseorderid");

		$entity_tbl_field_arr = Array("ld_products"=>"vendor_id","ld_vendorcontactrel"=>"vendorid","ld_purchaseorder"=>"vendorid");

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

	/** Returns a list of the associated emails
	 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
	 * All Rights Reserved..
	 * Contributor(s): ______________________________________..
	*/
    //邮件管理
	function get_emails($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;

        $related_module = 'Emails';
		$other = CRMEntity::getInstance($related_module);

		if($singlepane_view == 'true')
			$returnset = '&return_module='.$this_module.'&return_action=DetailView&return_id='.$id;
		else
			$returnset = '&return_module='.$this_module.'&return_action=CallRelatedList&return_id='.$id;

		$button = '';

		$button .= '<input type="hidden" name="email_directing_module"><input type="hidden" name="record">';

		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('ADD', $actions) && isPermitted($related_module,'Create', '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('Send_mail').'" href="javascript:void(0);"
                onclick="fnvshobj(this,\'sendmail_cont\');sendmail(\''.$this_module.'\','.$id.');">			 
                <span>'.getFixedLabel('Send_mail').'</span></a>';
        	}
		}

		//$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
				//			'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
		$query = "SELECT ld_users.last_name as user_name,
			ld_activity.activityid, ld_activity.subject,
			ld_activity.activitytype, ld_activity.modifiedtime,
			ld_crmentity.crmid, ld_activity.smownerid, ld_activity.date_start, ld_seactivityrel.crmid as parent_id
			FROM ld_activity, ld_seactivityrel, ld_vendor, ld_users, ld_crmentity,ld_emaildetails
			
			WHERE ld_seactivityrel.activityid = ld_activity.activityid 
				AND ld_activity.activityid = ld_emaildetails.emailid
				AND ld_vendor.vendorid = ld_seactivityrel.crmid
				AND ld_users.id=ld_activity.smownerid
				AND ld_crmentity.crmid = ld_activity.activityid
				AND ld_vendor.vendorid = ".$id."
				AND ld_activity.activitytype='Emails'
				AND ld_activity.deleted = 0";
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}

	

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Products" =>array("ld_products"=>array("vendor_id","productid"),"ld_vendor"=>"vendorid"),
			"PurchaseOrder" =>array("ld_purchaseorder"=>array("vendorid","purchaseorderid"),"ld_vendor"=>"vendorid"),
			"Contacts" =>array("ld_vendorcontactrel"=>array("vendorid","contactid"),"ld_vendor"=>"vendorid"),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
		
		//Deleting Vendor related PO.
		$po_q = 'SELECT ld_crmentity.crmid FROM ld_crmentity
			INNER JOIN ld_purchaseorder ON ld_crmentity.crmid=ld_purchaseorder.purchaseorderid
			INNER JOIN ld_vendor ON ld_vendor.vendorid=ld_purchaseorder.vendorid
			WHERE ld_crmentity.deleted=0 AND ld_purchaseorder.vendorid=?';
		$po_res = $this->db->pquery($po_q, array($id));
		$po_ids_list = array();
		for($k=0;$k < $this->db->num_rows($po_res);$k++)
		{
			$po_id = $this->db->query_result($po_res,$k,"crmid");
			$po_ids_list[] = $po_id;
			$sql = 'UPDATE ld_crmentity SET deleted = 1 WHERE crmid = ?';
			$this->db->pquery($sql, array($po_id));
		}
		//Backup deleted Vendors related Potentials.
		$params = array($id, RB_RECORD_UPDATED, 'ld_crmentity', 'deleted', 'crmid', implode(",", $po_ids_list));
		$this->db->pquery('INSERT INTO ld_relatedlists_rb VALUES (?,?,?,?,?,?)', $params);

		//Backup Product-Vendor Relation
		$pro_q = 'SELECT productid FROM ld_products WHERE vendor_id=?';
		$pro_res = $this->db->pquery($pro_q, array($id));
		if ($this->db->num_rows($pro_res) > 0) {
			$pro_ids_list = array();
			for($k=0;$k < $this->db->num_rows($pro_res);$k++)
			{
				$pro_ids_list[] = $this->db->query_result($pro_res,$k,"productid");
			}
			$params = array($id, RB_RECORD_UPDATED, 'ld_products', 'vendor_id', 'productid', implode(",", $pro_ids_list));
			$this->db->pquery('INSERT INTO ld_relatedlists_rb VALUES (?,?,?,?,?,?)', $params);
		}
		//Deleting Product-Vendor Relation.
		$pro_q = 'UPDATE ld_products SET vendor_id = 0 WHERE vendor_id = ?';
		$this->db->pquery($pro_q, array($id));

	

		parent::unlinkDependencies($module, $id);
	}
    
    
  
	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();

		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
      
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Contacts')
				$adb->pquery("insert into ld_vendorcontactrel values (?,?)", array($crmid, $with_crmid));
			elseif($with_module == 'Products')
			//	$adb->pquery("update ld_products set vendor_id=? where productid=?", array($crmid, $with_crmid));
            $adb->pquery("insert into ld_seproductsrel values (?,?,?)", array($crmid, $with_crmid, 'Vendors'));
          
			else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}
    
    //duan 20220816 更新供应商定位地址、经纬度
	function updateVendorsAddress($crmid){
        //duan 20220816 考虑到根据地址获取经纬度存在不精确的问题(泰康制药问题))
        //增加优化，如果通过移动端的定位功能获取到经纬度，则不需要重新计算经纬度（在详细地址不修改的情况下）
        global $weixin_user,$adb;
        if(!empty($weixin_user)&&$_REQUEST['locationaddress_lat']!=''&&$_REQUEST['locationaddress_lng']!=''){
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
        //31591: 供应商新增保存后，获取地址经纬度判断服务器是否能上网
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
        
        $this->updateVendorsAddressWithoutCheckNet($crmid);
	}
    
    //供应商地址保存后计算经纬度
    function updateVendorsAddressWithoutCheckNet($crmid){
        global $adb;
        $tablename = $this->table_name;
        $tableindex = $this->table_index;
        //供应商模块没有街道字段,去掉bill_street
        $query = "select CONCAT(
					IF(LOCATE(bill_state,street)>0 or LOCATE(bill_state,bill_city)>0 ,'',bill_state),
					IF(LOCATE(bill_city,street)>0,'',bill_city),
					IF(LOCATE(bill_area,street)>0,'',bill_area),
					street) as address,locationaddress from $tablename";
		if(!empty($crmid)){
			$query .= " where $tableindex = ?";
		}
        
		$result = $adb->pquery($query,array($crmid));
        
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
	/*
    function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {

		 editor:gyq_11 reason:当处在九维呼叫中心，通话记录序时簿由新方法生成 date:20160603

		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;

		$root_dir= dirname(dirname(dirname(__FILE__)));
		require_once($root_dir.'/CallCenter/lib/jiuWei.php');
		$jiuObj = jiuWei::autoLoad();
		if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
			return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'Vendors');
		}
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_vendor as T2 on  T1.vendorid = T2.vendorid 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.vendorid > 0 and T1.vendorid = '.$id;
        
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
	}
  */
    
}
Vendors::require_file();
?>