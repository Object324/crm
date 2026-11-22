<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 



class VendorContactRecords extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['VendorContactRecords']='VendorContactRecords';
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include("modules/Calendar/Activity.php");
            }
            if(empty(globalStatic::$arr_module_require['Emails']))
            {
                globalStatic::$arr_module_require['Emails']='Emails';
                include("modules/Emails/Emails.php");
            }
            if(empty(globalStatic::$arr_module_require['Documents']))
            {
                globalStatic::$arr_module_require['Documents']='Documents';
                include("modules/Documents/Documents.php");
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_vendorcontactrecords';
    var $table_index='contactrecordsid';
    var $table_code='contactrecord_code';
    var $tab_name=Array('ld_crmentity','ld_vendorcontactrecords','ld_vendorcontactrecordsscf');//'ld_cnContactRecordrel','ld_SeaContactRecord');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_vendorcontactrecords'=>'contactrecordsid','ld_vendorcontactrecordsscf'=>'contactrecordsid');
   	var $customFieldTable = Array('ld_vendorcontactrecordsscf', 'contactRecordsid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
	var $relatedtab=array('vendorcontact'=>'','users'=>'','company'=>'','vendorcontactrecords'=>'');
	var $column_fields = Array();
    var $module_name='VendorContactRecords';
    var $IsCustomModule = false;
    var $sortby_fields=Array('contactRecordsid,Subject,ContactDate');
 
            var $list_link_field= 'subject';
            
            	var $search_fields_name = Array(
		
			);
            
            var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime');
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
    var $def_basicsearch_col="subject";
    var $popup_fields=Array();
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('VendorContactRecords');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('VendorContactRecords',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('VendorContactRecords');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=array($this->list_link_field);
    }
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
         global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','VendorContactRecords'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
    /** Function to handle module specific operations when saving a entity
     *reason: 更新客户的下次回访日期
     * edit by LD can
     * date:20130226
	*/
	function save_module($module) {
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
            $params[]=$current_user->id;
            $params[]=$calltype;
            if($adb->num_rows($callbutlerGetResult))
            {
                //存在
                $params[]=$restore_phone;
                $params[]=$this->id;
                
                 if(isset($_REQUEST['calltype'])&&$_REQUEST['calltype']==1)
                 {
                    $vendorid=$this->column_fields['vendor_id'];
                    $contactid=$this->column_fields['contact_id'];
                    $params[]=$vendorid;
                    $params[]=$contactid;
                 }
                $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
                if($_REQUEST['calltype']==1)
                {
                    //外拨
                    $sqlUpdate = "update ld_callbutler set userid=?,phone=? ,calltype = ?, vendorcontactrecordsid = ?,vendorid=?,vendorcontactid=?,description = ? where id = ? ";
                }
                else
                     $sqlUpdate = "update ld_callbutler set userid=?,phone=? , calltype = ?, vendorcontactrecordsid = ?,description = ? where id = ? ";
               
                $params[]=$callButlerRemarks;
                $params[]=$callButlerID;
                $updateResult=$adb->pquery($sqlUpdate,$params);
                
                
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
                if($_REQUEST['calltype']==1)
                {
                    $insertresult=$adb->pquery($sqlInsert,array($calltype,$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                      0,0,0,$this->column_fields['vendor_id'],$this->column_fields['contact_id'],0,$this->id,$callButlerRemarks));
                }
                else
                $insertresult=$adb->pquery($sqlInsert,array($calltype,$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                0,0,0,0,0,0,$this->id,$callButlerRemarks));
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

                if(isset($_REQUEST['calltype']) && $_REQUEST['calltype'] == 1)
                {
                    //外拨 去电
                    $sqlUpdate = "update ld_callbutler set vendorcontactrecordsid = ?, vendorid=?, vendorcontactid=?, description = ? where id = ? ";
                    $updateResult = $adb->pquery($sqlUpdate, array($this->id, $this->column_fields['vendor_id'], $this->column_fields['contact_id'], "", $callButlerID));
                } else{

                    $sqlUpdate = "update ld_callbutler set vendorcontactrecordsid = ?,description = ? where id = ? ";
                    $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $callButlerID));
                }

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                if($_REQUEST['calltype'] == 1)
                {
                    $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                        0, 0, 0, $this->column_fields['vendor_id'], $this->column_fields['contact_id'], 0, $this->id, 0, ''));
                }else
                    $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    0, 0, 0, 0, 0, 0, $this->id, 0, ''));
            }
        }

	}
    
    /*
    Edit by LD Can
    date:20130205
    reason:删除联系记录以及和联系记录相关的业务信息
    */
	function unlinkRelationship($id, $return_module, $return_id) 
    {
         $this->trash('VendorContactRecords',$id);
    }
    
     //add by tifa 20130226 for reminds      
    function getDatetimeHtml($fieldname,$sql){
        $adb = $this->db;
        
        $Result=$adb->pquery($sql);
        $value='';
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        $dateValue = $value;
        $date='';
        $isPop=false;
		if ($dateValue == '' || empty($dateValue)||$dateValue == '0000-00-00 00:00:00') {
			$date = new DateTimeField(date('Y-m-d H:i'));

		} else {
	    	$date = new DateTimeField($value);
            $isPop=true;
		}
		$displayValue = $date->getDisplayDateTimeValue();
        /*$dis_date=substr($displayValue,0,10); 
        $dis_time=substr($displayValue,11,5);
        $dis_time=explode(':',$dis_time);
        if(strstr($fieldname,'end')){
            $dis_time=getTimeHtml($dis_time,$fieldname); 
        }else{
            $dis_time=getTimeHtml($dis_time,$fieldname); 
        }*/  		
        $fieldvalue = array($displayValue,$isPop);
        return $fieldvalue;
    }
    
    function returnDatetime($sql){
        $adb = $this->db;        
        $Result=$adb->pquery($sql);
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        $dateValue = $value;
        $date='';
        $isPop='No';
		if ($dateValue == '' || empty($dateValue)) {
			$date = new DateTimeField(date('Y-m-d H:i'));

		} else {
	    	$date = new DateTimeField($value);
            $isPop='Yes';
		}
        $displayValue = $date->getDisplayDateTimeValue();
        $fieldvalue=array($isPop,$displayValue);
        return $fieldvalue;
    }
    
    function getContent($sql){
        $adb = $this->db;        
        $Result=$adb->pquery($sql);
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        return $value;
    }

    function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        $root_dir_index= dirname(dirname(dirname(__FILE__)));
        require_once($root_dir_index.'/CallCenter/lib/jiuWei.php');
        $jiuObj = jiuWei::autoLoad();
        if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
            return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'VendorContactRecords');
        }
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_vendorcontactrecords as T2 on  T1.vendorcontactrecordsid = T2.contactRecordsid 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.vendorcontactrecordsid > 0 and T1.vendorcontactrecordsid = '.$id;
        
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
        $query = 'SELECT 
							ld_vendorcontactrecords.contactrecordsid as crmid,ld_vendorcontactrecords.* '.$fromclause.' 
						FROM
							ld_vendorcontactrecords 
						LEFT JOIN ld_users 
							ON ld_vendorcontactrecords.smownerid = ld_users.id 
						left join ld_vendorcontacts 
							on ld_vendorcontacts.vendorcontactsid = ld_vendorcontactrecords.contactid 
						left join ld_vendor 
							on ld_vendor.vendorid = ld_vendorcontactrecords.vendorid 
							';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_vendorcontactrecords.contactrecordsid";
		   $query .= " WHERE ld_vendorcontactrecords.deleted = 0 " . $where;
           return $query;
    }*/

           
}
VendorContactRecords::require_file();
?>