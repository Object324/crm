<?php



class Signout extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Signout']='Signout';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='Signout';
	var $table_name = "ld_signout";
	var $table_index= 'signoutid';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_signout','ld_signoutscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_signout'=>'signoutid','ld_signoutscf'=>'signoutid',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_signoutscf', 'signoutid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','Signout'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='';
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
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Signout',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Signout');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
        global $current_user,$adb,$PlatformMC;
        $signdata=$_REQUEST['signData'];
        $longtitude=$signdata['longitude'];//+$littlelong;
        $longtitude=is_numeric($longtitude)?$longtitude:null;
        $latitude=$signdata['latitude'];//+$littlelati;
        $latitude=is_numeric($latitude)?$latitude:null;
        $uuid=$signdata['uuid'];
        $signway=$signdata['signway'];
        $record=$this->column_fields['selectlistval'];
        $module = $this->column_fields['entitytype'];
        $signaddress = $signdata['address'];
        $signin_id = $_REQUEST['signoutfromid'];
        $signout_type = empty($_REQUEST['signout_type'])?'signout':$_REQUEST['signout_type'];
        if(empty($module)){
            $module = getSalesEntityType($record);
        }
        $distance=$signdata['distance'];
        $tabid = getTabid($module);
        
        //editor:gyq_20190412 0036579: CRM小程序：拜访签到保存后，【signway】字段跟企业微信保存后值是一样，建议区分开来。
        if($PlatformMC['type_mini']){
            //editor:gyq_20190412 0036567: 小程序-考勤签到-常用报表-签到考勤表不显示手机设备号。
            $sql = 'select wx_openid from ld_users where id=?';
            $result = $adb->pquery($sql,array($current_user->id));
            $uuid = $adb->query_result($result,0,'wx_openid');
        }
        //用时计算
        $signout_time = $this->column_fields['signout_time'];
        $select_sql = "SELECT createdtime from ld_singin where signid = ?";
        $select_result = $adb->pquery($select_sql, array($signin_id));
        $signin_time = $adb->query_result($select_result, 0, 'createdtime');
        
        $signin_time = new DateTime($signin_time);
        $signout_time = new DateTime($signout_time);
        $timeused = $signin_time->diff($signout_time);
        $timeused = $timeused->format('%d'.'天'.'%h'.'时'.'%i'.'分');//转换成几天几时几分
        $update_sql = 'UPDATE ld_signout set signout_type = ?,signout_longtitude = ?,signout_latitude = ?,signout_distance = ?,signout = ?,signout_address = ?,timeused = ?,signin_id = ? 
                where signoutid = ?';
        $adb->pquery($update_sql,array($signout_type,$longtitude,$latitude,$distance,$signaddress,$signaddress,$timeused,$signin_id,$this->id));

        //签退信息反写入对应签到单据
        $this->reversWriteInSignin('save',$this->id,$signin_id);
        
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
   	}
   
    function trash($module, $id) {
        global $current_user,$adb;

		parent::trash($module,$id);
        //删除签退单据，将对应签到单据中签退信息都清空
        $this->reversWriteInSignin('delete',$id);
   	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}
    //签退信息反写入对应签到单据
    private function reversWriteInSignin($mode,$signout_id,$signin_id=0) {
        global $current_user,$adb,$PlatformMC;

        $Signin_tabid = getTabid('Singin');
        $select_sql1 = "SELECT tablename,columnname,ld_related_field.fromvalue_info,bigtype from ld_field INNER JOIN ld_related_field ON ld_field.fieldid = ld_related_field.effect_fieldid 
                        WHERE ld_field.tabid = ? and ld_related_field.frommodule = 'Signout' and ld_field.relatedmodulefield = 'yes'";
        $select_result1 = $adb->pquery($select_sql1,array($Signin_tabid));
        $num_rows = $adb->num_rows($select_result1);
        if($num_rows > 0) {
            if($mode == 'save'){
                for($i = 0; $i<$num_rows; $i++){
                    $fromcolumnnames_arr[] = $adb->query_result($select_result1,$i,'fromvalue_info');//被引用的字段columnname
                }
                $fromcolumnnames_str = implode(',',$fromcolumnnames_arr);
                $select_sql2 = "SELECT $fromcolumnnames_str from ld_signout INNER JOIN ld_signoutscf ON ld_signout.signoutid = ld_signoutscf.signoutid WHERE ld_signout.signoutid = ?";
                $select_result2 = $adb->pquery($select_sql2,array($signout_id));
                for($i = 0; $i<$num_rows; $i++){
                    $tablename = $adb->query_result($select_result1,$i,'tablename');
                    $columnname = $adb->query_result($select_result1,$i,'columnname');
                    $bigtype = $adb->query_result($select_result1,$i,'bigtype');
                    $value = $adb->query_result($select_result2,0,$fromcolumnnames_arr[$i]);
                    $update_setsql .= " $tablename.$columnname = '".$value."'";
                    if($i < $num_rows-1){
                        $update_setsql .= ",";
                    }
                    //引用图片附件字段添加附件
                    if($bigtype == 'fileattachment'){
                        $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id
                        $sql1 = 'INSERT into ld_crmentity (crmid,setype) values(?,?);';
                        $params1 = array($current_id, "Singin Image");
                        $adb->pquery($sql1, $params1);
                        $sql2 = "INSERT INTO ld_attachments(attachmentsid, name,newfile_name, description,type, path,size,imagefromtype,cloud_path,storage_location,upload_from)
                                SELECT ?, name,newfile_name, description,type, path,size,imagefromtype,cloud_path,storage_location,upload_from from ld_attachments INNER JOIN ld_seattachmentsrel ON ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid 
                                WHERE attachmentcolumnname = ? and crmid = ? and not exists (select 1 from ld_attachments WHERE attachmentsid = ?)";
                        $adb->pquery($sql2, array($current_id,$fromcolumnnames_arr[$i],$signout_id,$current_id));
                        $sql3 = 'INSERT into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                        $adb->pquery($sql3, array($signin_id, $current_id, $columnname));
                    }
                }
            
                $update_sql = "UPDATE ld_singin JOIN ld_singinscf on ld_singin.signid = ld_singinscf.signid set ld_singin.signout_id = ?, ".$update_setsql." WHERE ld_singin.signid = ?";
                $adb->pquery($update_sql,array($signout_id,$signin_id));
            }else if($mode == 'delete'){
                $select_sql3 = "SELECT signid from ld_singin WHERE signout_id = ?";
                $select_result3 = $adb->pquery($select_sql3,array($signout_id));
                $signin_id = $adb->query_result($select_result3,0,'signid');
                for($i = 0; $i<$num_rows; $i++){
                    $tablename = $adb->query_result($select_result1,$i,'tablename');
                    $columnname = $adb->query_result($select_result1,$i,'columnname');
                    $bigtype = $adb->query_result($select_result1,$i,'bigtype');
                    $update_setsql .= " $tablename.$columnname = ''";
                    if($i < $num_rows-1){
                        $update_setsql .= ",";
                    }
                    if($bigtype == 'fileattachment'){
                        $fileattachment_columnname[$i] = $columnname;
                    }
                }
                $update_sql = "UPDATE ld_singin JOIN ld_singinscf on ld_singin.signid = ld_singinscf.signid set ld_singin.signout_id = NULL, ".$update_setsql." WHERE ld_singin.signout_id = ?";                
                $adb->pquery($update_sql,array($signout_id));

                // $fileattachment_columnname = implode(',',$fileattachment_columnname);
                //删除引用图片附件字段的附件
                $select_sql4 = 'SELECT ld_attachments.attachmentsid from ld_attachments inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                                WHERE ld_seattachmentsrel.crmid=? AND ld_seattachmentsrel.attachmentcolumnname in (\''.implode('\',\'',$fileattachment_columnname).'\')';
                $select_result4 = $adb->pquery($select_sql4,array($signin_id));
                $num_rows = $adb->num_rows($select_result4);
                if($num_rows > 0) {
                    for($i = 0; $i<$num_rows; $i++){
                        $delattachmentsid[$i] = $adb->query_result($select_result4, $i, 'attachmentsid');
                    }
                    $delattachmentsid = implode(',', $delattachmentsid);
                    $delete_sql1 = 'delete from ld_attachments where attachmentsid in ( ' . $delattachmentsid . ' )';
                    $adb->pquery($delete_sql1, array());
                    $delete_sql2 = "delete from ld_seattachmentsrel where crmid=? AND attachmentcolumnname in ($fileattachment_columnname)";
                    $adb->pquery($delete_sql2, array($signin_id));
                }
            }
        }
    }

}
Signout::require_file();
?>