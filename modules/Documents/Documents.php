<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/



require_once(globalStatic::$root_directory.'include/upload_file.php');

class Documents extends CRMEntity {
    static  function require_file($requiremodules='')
    {
         globalStatic::$arr_module_require['Documents']='Documents';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
	var $table_name = "ld_notes";
	var $table_index= 'notesid';
    var $table_code='note_no';
	var $default_note_name_dom = array('Meeting ld_notes', 'Reminder');
    
    var $Detail_table="ld_seattachmentsrel";//明细表名称
    var $Detail_table_id="attachmentsid";//明细表id
    var $Detail_table_scf = "ld_attachments";//明细scf表，目前不存在
    var $Detail_table_index="crmid";//明细表和主表关联的字段
    
	var $tab_name = Array('ld_crmentity','ld_notes','ld_documentscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_notes'=>'notesid','ld_senotesrel'=>'notesid','ld_documentscf'=>'documentsid');
    
    var $customFieldTable = Array('ld_documentscf','documentsid');
    
	var $column_fields = Array();
     var $module_name='Documents';
    //var $sortby_fields = Array('title','modifiedtime','filename','createdtime','lastname','filedownloadcount','smownerid');
    var $sortby_fields = Array('title','modifiedtime','createdtime','lastname','smownerid');

	// This is used to retrieve related lingdang_fields from form posts.
	var $additional_column_fields = Array('', '', '', '');


	var $search_fields = Array(
					'Title' => Array('notes'=>'notes_title'),
					'File Name' => Array('notes'=>'filename'),
					'Assigned To' => Array('crmentity'=>'smownerid'),
					'Folder Name' => Array('attachmentsfolder'=>'foldername')
		);

	var $search_fields_name = Array(
					'Title' => 'notes_title',
					'File Name' => 'filename',
					'Assigned To' => 'assigned_user_id',
					'Folder Name' => 'folderid'
	);
	var $list_link_field= 'notes_title';
	var $old_filename = '';
	//var $groupTable = Array('lingdang_notegrouprelation','notesid');
//管理模块
    var $relatedtab=array('documents'=>'','users'=>'','company'=>'');
	var $mandatory_fields = Array('createdtime' ,'modifiedtime','filesize','filetype','filedownloadcount','assigned_user_id');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'notes_title';
	var $default_sort_order = 'ASC';
	public $parent_type;

	function __construct() {
		//$this->log = LoggerManager::getLogger('notes');
		//$this->log->debug("Entering Documents() method ...");
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Documents',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Documents');
        $this->list_link_field=$entityname['fieldname'];
	}
     
	function save_module($module)
	{
		global $adb,$upload_badext;
		$insertion_mode = $this->mode;
		if(isset($this->parentid) && $this->parentid != '')
			$relid =  $this->parentid;
               
		//inserting into ld_senotesrel
		if(isset($relid) && $relid != '')
		{
			$this->insertintonotesrel($relid,$this->id);
		}
		$filetype_fieldname = $this->getFileTypeFieldName();
		$filename_fieldname = $this->getFile_FieldName();

        if(empty($this->column_fields[$filetype_fieldname]))
        {
            $this->column_fields[$filetype_fieldname]='I';
            
        }
      

		if($this->column_fields[$filetype_fieldname] == 'I'){
		   $filelocationtype = 'I';
       
		} else if($this->column_fields[$filetype_fieldname] == 'E' ){
			$filelocationtype = 'E';
          //33784: 知识管理新建弹出层界面：附件类型选为“链接”，附件文本框输入链接地址点击保存后，该条单据的附件列和查看明细界面的附件处都应显示链接地址

			$filename = $_REQUEST['name_E__'];
           
			// If filename does not has the protocol prefix, default it to http://
			// Protocol prefix could be like (https://, smb://, file://, \\, smb:\\,...)
			if(!empty($filename) && !preg_match('/^\w{1,5}:\/\/|^\w{0,3}:?\\\\\\\\/', trim($filename), $match)) {
				$filename = "http://$filename";
			}
			$filetype = '';
			$filesize = 0;
			$filedownloadcount = null;
		}

		$query = "UPDATE ld_notes SET filename = ? ,filesize = ?, filetype = ? , filelocationtype = ? , filedownloadcount = ? WHERE notesid = ?";
 		$re=$adb->pquery($query,array($filename,$filesize,$filetype,$filelocationtype,$filedownloadcount,$this->id));
	

    
    	//Inserting into attachments table
		if($filelocationtype == 'I') {
			//$this->insertIntoDOCAttachment($this->id,'Documents');
		}else{
			$query = "delete from ld_seattachmentsrel where crmid = ?";
			$qparams = array($this->id);
			$adb->pquery($query, $qparams);
		}
        $return_action = $_REQUEST['return_action'];
		if(!empty($for_module)){
			$for_module = $_REQUEST['return_module'];
			$for_crmid  = $_REQUEST['currentid'];
			$on_focus = CRMEntity::getInstance($for_module);
			$on_focus->save_related_module($for_module, $for_crmid, $module, $this->id);
		}
        
        if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']!='')
        {
            //弹出层界面保存方法
            $for_module = $_REQUEST['tablerelmodule'];
			$for_crmid  = $_REQUEST['tablerelid'];
			$on_focus = CRMEntity::getInstance($for_module);
			$on_focus->save_related_module($for_module, $for_crmid, $module, $this->id);
        }
        $_REQUEST['return_module']=$module;
        $_REQUEST['return_id']=$this->id;
	}


	/**
	 *      This function is used to add the ld_attachments. This will call the function uploadAndSaveFile which will upload the attachment into the server and save that attachment information in the database.
	 *      @param int $id  - entity id to which the lingdang_files to be uploaded
	 *      @param string $module  - the current module name
	*/
	function insertIntoDOCAttachment($id,$module)
	{
	  
		global $adb;
		$file_saved = false;
		foreach($_FILES as $fileindex => $files)
		{
			if($files['name'] != '' && $files['size'] > 0)
			{
				$files['original_name'] = vtlib_purify($_REQUEST[$fileindex.'_hidden']);
				//$file_saved = $this->uploadAndSaveFile($id,$module,$files);
                dump($files);
			}
		}
        exit();
	}

	/**    Function used to get the sort order for Documents listview
	*      @return string  $sorder - first check the $_REQUEST['sorder'] if request value is empty then check in the $_SESSION['NOTES_SORT_ORDER'] if this session value is empty then default sort order will be returned.
	*/
	function getSortOrder()
	{

        if (!empty($this->reportSortType)){
            return $this->reportSortType;
        }
		if(isset($_REQUEST['sorder']))
			$sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
		else
			$sorder = (($_SESSION['NOTES_SORT_ORDER'] != '')?($_SESSION['NOTES_SORT_ORDER']):($this->default_sort_order));
	
		return $sorder;
	}

	
	/**
	 * Function used to get the sort order for Documents listview
	 * @return String $sorder - sort order for a given folder.
	 */
	function getSortOrderForFolder($folderId) {
		if(isset($_REQUEST['sorder']) && $_REQUEST['folderid'] == $folderId) {
			$sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
		} elseif(is_array($_SESSION['NOTES_FOLDER_SORT_ORDER']) &&
					!empty($_SESSION['NOTES_FOLDER_SORT_ORDER'][$folderId])) {
				$sorder = $_SESSION['NOTES_FOLDER_SORT_ORDER'][$folderId];
		} else {
			$sorder = $this->default_sort_order;
		}
		return $sorder;
	}

	/**
	 * Function used to get the order by value for Documents listview
	 * @return String order by column for a given folder.
	 */
	function getOrderByForFolder($folderId) {
		$use_default_order_by = '';
		if(PerformancePrefs::getBoolean('LISTVIEW_DEFAULT_SORTING', true)) {
			$use_default_order_by = $this->default_order_by;
		}
		if (isset($_REQUEST['order_by'])  && $_REQUEST['folderid'] == $folderId) {
			$order_by = $this->db->sql_escape_string($_REQUEST['order_by']);
		} elseif(is_array($_SESSION['NOTES_FOLDER_ORDER_BY']) &&
				!empty($_SESSION['NOTES_FOLDER_ORDER_BY'][$folderId])) {
			$order_by = $_SESSION['NOTES_FOLDER_ORDER_BY'][$folderId];
		} else {
			$order_by = ($use_default_order_by);
		}
		return $order_by;
	}

	

	function del_create_def_folder($query)
	{
		global $adb;
		$dbQuery = $query." and ld_attachmentsfolder.folderid = 0";
		$dbresult = $adb->pquery($dbQuery,array());
		$noofnotes = $adb->num_rows($dbresult);
		if($noofnotes > 0)
		{
            $folderQuery = "select folderid from ld_attachmentsfolder";
            $folderresult = $adb->pquery($folderQuery,array());
            $noofdeffolders = $adb->num_rows($folderresult);

            if($noofdeffolders == 0)
            {
			    $insertQuery = "insert into ld_attachmentsfolder values (0,'Default','Contains all attachments for which a folder is not set',1,0)";
			    $insertresult = $adb->pquery($insertQuery,array());
            }
		}

	}

	function insertintonotesrel($relid,$id)
	{
		global $adb;
		$dbQuery = "insert into ld_senotesrel values ( ?, ? )";
		$dbresult = $adb->pquery($dbQuery,array($relid,$id));
	}



	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array();
		return $rel_tables[$secmodule];
	}

	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
		
	

		parent::unlinkDependencies($module, $id);
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		$sql = 'DELETE FROM ld_senotesrel WHERE notesid = ? AND crmid = ?';
		$this->db->pquery($sql, array($id, $return_id));

		$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
		$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
		$this->db->pquery($sql, $params);
	}


// Function to get fieldname for uitype 27 assuming that documents have only one file type field

	function getFileTypeFieldName(){
		global $adb;
		$query = 'SELECT fieldname from ld_field where tabid = ? and uitype = ?';
		$tabid = getTabid('Documents');
		$filetype_uitype = 27;
		$res = $adb->pquery($query,array($tabid,$filetype_uitype));
		$fieldname = null;
		if(isset($res)){
			$rowCount = $adb->num_rows($res);
			if($rowCount > 0){
				$fieldname = $adb->query_result($res,0,'fieldname');
			}
		}
		return $fieldname;

	}

//	Function to get fieldname for uitype 28 assuming that doc has only one file upload type

	function getFile_FieldName(){
		global $adb;
		$query = 'SELECT fieldname from ld_field where tabid = ? and uitype = ?';
		$tabid = getTabid('Documents');
		$filename_uitype = 28;
		$res = $adb->pquery($query,array($tabid,$filename_uitype));
		$fieldname = null;
		if(isset($res)){
			$rowCount = $adb->num_rows($res);
			if($rowCount > 0){
				$fieldname = $adb->query_result($res,0,'fieldname');
			}
		}
		return $fieldname;
	}

	/**
	 * Check the existence of folder by folderid
	 */
	function isFolderPresent($folderid) {
		global $adb;
		$result = $adb->pquery("SELECT folderid FROM ld_attachmentsfolder WHERE folderid = ?", array($folderid));
		if(!empty($result) && $adb->num_rows($result) > 0) return true;
		return false;
	}

	/**
	 * Customizing the restore procedure.
	 */
	function restore($modulename, $id) {
		parent::restore($modulename, $id);

		global $adb;
		$fresult = $adb->pquery("SELECT folderid FROM ld_notes WHERE notesid = ?", array($id));
		if(!empty($fresult) && $adb->num_rows($fresult)) {
			$folderid = $adb->query_result($fresult, 0, 'folderid');
			if(!$this->isFolderPresent($folderid)) {
				// Re-link to default folder
				$adb->pquery("UPDATE ld_notes set folderid = 1 WHERE notesid = ?", array($id));
			}
		}
	}

	function getQueryByModuleField($module, $fieldname, $srcrecord, $query) {
		if($module == "MailManager") {
			$tempQuery = split('WHERE', $query);
			if(!empty($tempQuery[1])) {
				$where = " ld_notes.filelocationtype = 'I' AND ld_notes.filename != '' AND ld_notes.filestatus != 0 AND ";
				$query = $tempQuery[0].' WHERE '.$where.$tempQuery[1];
			} else{
				$query = $tempQuery[0].' WHERE '.$tempQuery;
			}
			return $query;
		}
	}
   
	
}
Documents::require_file();
?>