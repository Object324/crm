<?php

/*
{*修改编码格式:统一编码：UTF-8*}
*/
require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class Attachment extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Attachment']='Attachment';
        if(empty(globalStatic::$arr_module_require['Attachment']))
        {
            globalStatic::$arr_module_require['Attachment']='Attachment';
            include('modules/Attachment/Attachment.php');

        }
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
        {
            include("modules/$requiremodules/$requiremodules.php");
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
        }

    }
    var $log;
    var $db;
    var $table_name = "ld_attachmentsforbills";
    var $table_index= 'attachmentsid';
    // @edit:dong @date:2020/09/15 @reason: 附件导出用
    var $table_code='attachment_no';

    var $Detail_table="ld_attachmentsforbillsdetails";//明细表名称
    var $Detail_table_id="id";//明细表主键名称
    var $Detail_table_index="attachmentsid";//明细表和主表关联的字段
    var $Detail_table_scf = "ld_attachmentsforbillsdetailscf";//明细scf表

    var $customFieldTable = Array('ld_attachmentsforbillscf', 'attachmentsid');
    //var $default_note_name_dom = array('Meeting ld_notes', 'Reminder');
    var $module_name='Attachment';
    var $tab_name = Array('ld_crmentity','ld_attachmentsforbills','ld_attachmentsforbillscf');
    var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_attachmentsforbills'=>'attachmentsid','ld_attachmentsforbillscf'=>'attachmentsid');

    var $column_fields = Array();
    var $def_basicsearch_col = 'filename';
    //var $sortby_fields = Array('name','modifiedtime','filename','createdtime','lastname','filedownloadcount','smownerid');

    // This is used to retrieve related lingdang_fields from form posts.
    var $additional_column_fields = Array('', '', '', '');

    var $sortby_fields = Array('smownerid','createdtime');
    var $old_filename = '';

    var $default_order_by = 'attachmentsid';
    var $default_sort_order = 'DESC';
    public $date_due_flag;
    public $parent_type;
    function __construct() {

        $this->db = PearDatabase::getInstance();
        //$this->column_fields = getColumnFields('Attachment',$this);
        $this->fieldobj = Field::getInstance('Attachment',$this->db);
        $this->column_fields = $this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Attachment');
        $this->list_link_field=$entityname['fieldname'];
    }

    /**
     * 获取模块创建人字段
     * */
    public function getCreateColumnName()
    {
        return "creator";
    }

    function save_module($module)
    {
        global $adb, $current_user,$weixin_user;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        //	if(!empty($_REQUEST['filename-file_num'])){
        $creator = $current_user->id;
        //用户详情页新建附件
        if (isset($_REQUEST['user_id']) && $_REQUEST['user_id'] > 0) {
            $reltab = 'Users';
            $creator = $_REQUEST['user_id'];
        } else {
            $creator = $current_user->id;
        }
        $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("uitype", 1108);
        //非管理员
    	if($current_user->is_admin=='off'){
    		$profileobj=Profile::getInstance();
    		$profilefields= $profileobj->getProfileInfos($current_user->profileid);
    		$profilefields=$profilefields['field'];
    	}
        if(!empty($fieldinfo)){
            $fieldid = $fieldinfo->getFieldid();
            //附件字段 只读和编辑时只读（编辑） 不保存图片字段
            if(!empty($profilefields) &&($fieldinfo->getReadOnly() ==1||($profilefields[$fieldid]['editreadonly']==1&&$this->mode != 'create'))){
                
            }
            else{
                $attachmentdelfileid = explode(",", (string)$_REQUEST['attachmentdelfileid']);
                //关联过其他单据的附件只删除记录，不删除文件
                $related_fileids = $this->attachment_related_record($this->id);
                if(sizeof($related_fileids)>0&&sizeof($attachmentdelfileid)>0){
                    foreach($attachmentdelfileid as $key => $value){
                        if(in_array($value,$related_fileids)){
                            unset($attachmentdelfileid[$key]);
                        }
                    }
                }
                
                
                if (is_array($attachmentdelfileid) && $attachmentdelfileid[0] > 0) {
                    $sql = "select * from ld_attachmentsforbillsdetails where attachmentsid=?";
                    $result = $adb->pquery($sql, array($this->id));
                    for ($i = 0; $i < $adb->num_rows($result); $i++) {
                        $fileid = $adb->query_result($result, $i, 'id');
                        $newfile_name = $adb->query_result($result, $i, 'newfile_name');
                        $path = $adb->query_result($result, $i, 'path');
                        $storage_location = $adb->query_result($result, $i, 'storage_location');
                        $cloud_path = $adb->query_result($result, $i, 'cloud_path');
                        if (in_array($fileid, $attachmentdelfileid)) {
                            $delfileList[$i]['storage_location'] = $storage_location;
                            $delfileList[$i]['path'] = $path;
                            $delfileList[$i]['cloud_path'] = $cloud_path;
                            $delfileList[$i]['newfile_name'] = $newfile_name;
                            /*if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'){
        
                            }else{
                                    $newfile_name= iconv('utf-8', 'gbk',$newfile_name);
                            }
        
                            //35709: 附件上传删除保存后，希望将服务器里附件同步删除
                            @unlink(globalStatic::$root_directory.$path.$newfile_name);*/
                        }
                    }
                    $this->deleteQcloudFileFromTable($delfileList);
                }
                //editor:gyq_20181228 reason:附件模块删除附件，不再在执行微信保存附件之前又执行PC端附件保存 0035709: 附件上传删除保存后，希望将服务器里附件同步删除
                //editor:gyq_20190326 reason:增加empty($PlatformMC['type_mini']),小程序还是走PC的保存代码
                //if (!empty($PlatformMC) && $PlatformMC['type'] = 'weixin' && empty($PlatformMC['type_mini'])) {
                if ($weixin_user->environment == 'weixinh5') {
                   // return false;
                }
                if ($_REQUEST['ajxaction'] != 'DETAILVIEW') {
                    // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
                    crm_load_class_file('FileWaterMark', 'modules/Settings');
                    $fileWaterMarkobj = FileWaterMark::getInstance($module);
                    $fileWaterMarkobj->setWaterMarkByAttachmentsidInBillsArr($this->id);

                    $deletesql = 'DELETE FROM ld_attachmentsforbillsdetails where attachmentsid=?';
                    $adb->pquery($deletesql, array($this->id));
                    $reltab = $_REQUEST['reltab'];
                    if (empty($reltab) && $related_to > 0) {
                        $reltab = getSalesEntityType($related_to);
                    }
                    $sql = 'update ld_attachmentsforbills set reltab=?,creator=?,record=? where attachmentsid=?';
                   
                    $adb->pquery($sql, array($reltab, $creator, $related_to, $this->id));
                    //就让小于30,不要用$_REQUEST['file_name']
                    for ($i = 1; $i <= 420; $i++) {
                        $reltab = $_REQUEST['related_to_type'];//附件插入的模块名称
                        $related_to = $_REQUEST['related_to'];
                        $file_name = $_REQUEST['filename-file_name_' . $i];    //附件名称
                        $file_name=FileFileterString($file_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $file_type = $_REQUEST['filename-file_type_' . $i];    //附件类型
                        $file_path = $_REQUEST['filename-file_path_' . $i];    //附件路径
                        $isEncrypt = $_REQUEST['filename-isEncrypt_' . $i];	//是否加密
                        $file_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($file_path) : $file_path;      //解密
                        $file_path=FileFileterString($file_path);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $file_size = $_REQUEST['filename-file_size_' . $i];    //附件大小
                        $newfile_name = $_REQUEST['filename-newfile_name_' . $i];
                        $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($newfile_name) : $newfile_name;  //解密
                        $newfile_name=FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $storage_location = $_REQUEST['fieldname-storage_location_'.$i];
                        //editor:gyq_20190326 reason:小程序附件记录上传方式
                        $imagefromtype = $_REQUEST['filename-imagefromtype_' . $i];    //附件上传的方式
                        $imagefromtype ? $imagefromtype : 'Computer';
        
                        if ($file_name == '' && $file_size <= 0.0001) {
                            //附件删除会有错误
                            continue;
                        }
                        //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                        $upload_from = $_REQUEST['filename-upload_from_'.$i];
                        if(empty($upload_from)||$upload_from=='undefined'){
                            $upload_from = '';
                        }
                        //文件存储位置:腾讯云存储桶/本地 （cos/local）
                        $storage_location = $_REQUEST['filename-storage_location_'.$i];
                        if(empty($storage_location) || $storage_location=='undefined'){
                            $storage_location = 'local';
                            $cloud_path = '';
                        }elseif($storage_location=='cos'){
                            //给存储桶链接增加头，以便界面显示
                            $cloud_path = $_REQUEST['filename-cloud_path_' . $i];    //附件路径
                            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;    //解密
                            $cloud_path = str_replace("http://",'https://',$cloud_path);
                            if(stripos($cloud_path,'https://') === false){
                                $cloud_path = 'https://'.$cloud_path;
                            }
        //                    $file_path = '';
                            
                            //删除文件临时表数据
                            $this->deleteQcloudTempFile($newfile_name);
                        }
                        $file_name = str_replace(" ", "_", $file_name);
                        //	$file_name=mysql_real_escape_string($file_name);
                        if (!strpos($file_size, 'B')) {//Liver 只有新增的附件，才需要计算附件大小并加上單位
                            if ($file_size < 1024)
                                $file_size = $file_size . ' B';
                            elseif ($file_size > 1024 && $file_size < 1048576)
                                $file_size = round($file_size / 1024, 2) . ' KB';
                            else if ($file_size > 1048576)
                                $file_size = round($file_size / (1024 * 1024), 2) . ' MB';
                        }
                        $size = $file_size;
                        // echo $newfile_name;

                        $watermark = $fileWaterMarkobj->getWaterMarkByNewFileName($newfile_name);

                        $insertsql = 'INSERT INTO ld_attachmentsforbillsdetails(
                                      attachmentsid,filename,newfile_name,size,path,type,imagefromtype,
                                      cloud_path,storage_location,upload_from,watermark
                                      ) VALUES (?,?,?,?,?,?,?,?,?,?,?);';
                        $adb->pquery($insertsql, array($this->id, $file_name, $newfile_name, $size, $file_path,
                            $file_type, $imagefromtype,$cloud_path,$storage_location,$upload_from,$watermark));

                        $word_watermark = $fieldinfo->getWordWaterMark();
                        $excel_watermark = $fieldinfo->getExcelWaterMark();
                        if($watermark == 'no' && ($word_watermark == 'yes' || $excel_watermark == 'yes') && $storage_location == 'local' && $fileWaterMarkobj->issetGD == 'yes'){
                            $info['fieldname'] = $fieldinfo->getFieldName();
                            $info['uitype'] = 1108;
                            $info['module'] = $module;
                            $info['word_watermark'] = $word_watermark;
                            $info['excel_watermark'] = $excel_watermark;
                            $info['attachmentsid'] = $this->id;
                            $info['recordid'] = $this->id;
                            $info['storage_location'] = $storage_location;
                            $info['newfile_name'] = $newfile_name;
                            $info['watermark'] = $watermark;//是否有水印
                            $info['path'] = $file_path;
                            $fileWaterMarkobj->addWaterMark($info);
                        }
                    }

                    $fileWaterMarkobj->deleteTextImagePath();
                }
            }
        }

    }
    function addFileToAttachment($id,$module)
    {

    }

    /**
     *      This function is used to add the ld_attachments. This will call the function uploadAndSaveFile which will upload the attachment into the server and save that attachment information in the database.
     *      @param int $id  - entity id to which the lingdang_files to be uploaded
     *      @param string $module  - the current module name
     */
    function insertIntoAttachment($id,$module)
    {
        global  $adb;

        $file_saved = false;

        foreach($_FILES as $fileindex => $files)
        {
            if($files['name'] != '' && $files['size'] > 0)
            {   
                $files['original_name'] = vtlib_purify($_REQUEST[$fileindex.'_hidden']);
                $file_saved = $this->uploadAndSaveFile($id,$module,$files);
            }
        }
    }

    /**    Function used to get the sort order for Attachment listview
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

    /**     Function used to get the order by value for Attachment listview
     *       @return string  $order_by  - first check the $_REQUEST['order_by'] if request value is empty then check in the $_SESSION['NOTES_ORDER_BY'] if this session value is empty then default order by will be returned.
     */
    function getOrderBy()
    {
        return parent::getOrderBy();
    }

    /**
     * Function used to get the sort order for Attachment listview
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
     * Function used to get the order by value for Attachment listview
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



    function insertintonotesrel($relid,$id)
    {
        global $adb;
        $dbQuery = "insert into ld_senotesrel values ( ?, ? )";
        $dbresult = $adb->pquery($dbQuery,array($relid,$id));
    }

    /*function save_related_module($module, $crmid, $with_module, $with_crmid){
    }*/





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

        /*//Backup Attachment Related Records
        $se_q = 'SELECT crmid FROM ld_senotesrel WHERE notesid = ?';
        $se_res = $this->db->pquery($se_q, array($id));
        if ($this->db->num_rows($se_res) > 0) {
            for($k=0;$k < $this->db->num_rows($se_res);$k++)
            {
                $se_id = $this->db->query_result($se_res,$k,"crmid");
                $params = array($id, RB_RECORD_DELETED, 'ld_senotesrel', 'notesid', 'crmid', $se_id);
                $this->db->pquery('INSERT INTO ld_relatedlists_rb VALUES (?,?,?,?,?,?)', $params);
            }
        }
        $sql = 'DELETE FROM ld_senotesrel WHERE notesid = ?';
        $this->db->pquery($sql, array($id));*/

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

    function getFileTypeFieldName(){
        global $adb;
        $query = 'SELECT fieldname from ld_field where tabid = ? and uitype = ?';
        $tabid = getTabid('Attachment');
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
        $tabid = getTabid('Attachment');
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
     * edit:andy
     * date:2014-02-21
     * reason:删除
     * */
    function trash($module, $id)
    {
        global $adb;
        
        //系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveDeletedRecordInfo($module,[$id]);
        //删除单据前删除对应的文件
        $this->delete_related_attachment($id);
        // parent::trash($module,$id);
        $sql='delete from ld_attachmentsforbills where attachmentsid=?';
        $adb->pquery($sql,array($id));
        $sqldetaildelete="delete from ld_attachmentsforbillsdetails where  attachmentsid = ".$id;
        $detaildeleteresult = $adb->query($sqldetaildelete);


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
						distinct	ld_attachmentsforbills.attachmentsid as crmid,ld_attachmentsforbills.* '.$fromclause.'
						FROM
							ld_attachmentsforbills
						LEFT JOIN ld_users
							ON ld_attachmentsforbills.smownerid = ld_users.id ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_attachmentsforbills.attachmentsid";
		   $query .= "  WHERE ld_attachmentsforbills.deleted = 0 " . $where;
      return $query;
    }*/
    
    //edit:duan date:2021-9-30 附件删除之前判断，该附件是否与其他单据相关联
    public function attachment_related_record($record){
        global $adb;
        $module = $this->moduleName;
        $fieldjsondata=json_decode(getAttachmentForBills($record,$module),true);
        $attachment_arr = array();
        
        foreach($fieldjsondata as $key=>$pathinfo){
            $fileid = $pathinfo['fileid'];
            $storage_location = $pathinfo['storage_location'];
            if($storage_location=='cos'){
                $cloud_path = $pathinfo['cloud_path'];
                $sql = 'select * from ld_attachmentsforbillsdetails 
                        inner join ld_attachmentsforbills on ld_attachmentsforbills.attachmentsid=ld_attachmentsforbillsdetails.attachmentsid
                        WHERE  ld_attachmentsforbillsdetails.cloud_path=? and ld_attachmentsforbills.attachmentsid>0';
                $result = $adb->pquery($sql,array($cloud_path));
                $num_row = $adb->num_rows($result);
                if($num_row>1){
                    $attachment_arr[] = $fileid;
                }
            }else{
                $path = $pathinfo['file_path'];
                $newfile_name = $pathinfo['newfile_name'];
                $sql = 'select * from ld_attachmentsforbillsdetails 
                        inner join ld_attachmentsforbills on ld_attachmentsforbills.attachmentsid=ld_attachmentsforbillsdetails.attachmentsid
                        WHERE  ld_attachmentsforbillsdetails.path=? and ld_attachmentsforbillsdetails.newfile_name=? and ld_attachmentsforbills.attachmentsid>0';
                $result = $adb->pquery($sql,array($path,$newfile_name));
                
                $num_row = $adb->num_rows($result);
                if($num_row>1){
                    $attachment_arr[] = $fileid;
                }
            }
        }
                
        return $attachment_arr;
    }
    //edit:duan date:2021-9-30 删除单据后，删除关联的附件记录和文件
    public function delete_related_attachment($record){
        global $adb;
        $module = $this->moduleName;
        $sql = "select ld_attachmentsforbills.attachmentsid,ld_attachmentsforbillsdetails.path,ld_attachmentsforbillsdetails.id,
            ld_attachmentsforbillsdetails.newfile_name,ld_attachmentsforbillsdetails.storage_location,
            ld_attachmentsforbillsdetails.cloud_path from ld_attachmentsforbillsdetails
            inner join ld_attachmentsforbills on ld_attachmentsforbills.attachmentsid=ld_attachmentsforbillsdetails.attachmentsid
            where ld_attachmentsforbills.attachmentsid=?";
            
        $related_fileids = $this->attachment_related_record($record);

        $delfileList = array();
        
        $result = $adb->pquery($sql, array($record));
 
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $attachments_id = $adb->query_result($result, $i, 'attachmentsid');
            $sql = 'delete from ld_crmentity where crmid=?';
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_attachmentsforbills where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_attachmentsforbillsdetails  where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $newfile_name = $adb->query_result($result, $i, 'newfile_name');
            $path = $adb->query_result($result, $i, 'path');
            $storage_location = $adb->query_result($result, $i, 'storage_location');
            $cloud_path = $adb->query_result($result, $i, 'cloud_path');
            $id = $adb->query_result($result, $i, 'id');
            if (sizeof($related_fileids)<=0 || !in_array($id, $related_fileids)){
                $delfileList[$i]['storage_location'] = $storage_location;
                $delfileList[$i]['path'] = $path;
                $delfileList[$i]['cloud_path'] = $cloud_path;
                $delfileList[$i]['newfile_name'] = $newfile_name;
            }
        }
        
        if(sizeof($delfileList)>0){
                   
            $this->deleteQcloudFileFromTable($delfileList);
        }
    }
    

}
Attachment::require_file();
?>