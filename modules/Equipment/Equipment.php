<?php

use Picqer\Barcode\BarcodeGeneratorPNG;

class Equipment extends CRMEntity
{
	var $db, $log; // Used in class functions of CRMEntity
	static function require_file($requiremodules = '')
	{
		globalStatic::$arr_module_require['Equipment'] = 'Equipment';
		if (!empty($requiremodules) && empty(globalStatic::$arr_module_require[$requiremodules])) {
			globalStatic::$arr_module_require[$requiremodules] = $requiremodules;
			include("modules/$requiremodules/$requiremodules.php");
		}
	}
	var $table_name = 'ld_equipment';
	var $table_index = 'equipmentid';
	var $table_code = 'equipment_no';//表编号字段(审批中心)
	var $column_fields = array();
	var $module_name = 'Equipment';
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = array('ld_equipmentcf', 'equipmentid');

	var $tab_name = array('ld_crmentity', 'ld_equipment', 'ld_equipmentcf');

	var $tab_name_index = array('ld_crmentity' => 'crmid', 'ld_equipment' => 'equipmentid', 'ld_equipmentcf' => 'equipmentid');

	//reason:打印关联模块
	var $relatedtab = array('equipment' => '', 'vendors' => '', 'users' => '', 'company' => '', 'accounts' => '');

	var $list_link_field = 'equipment_no';

	var $search_fields = array(
		'Name' => array('contactdetails' => 'lastname'),
		'Title' => array('contactdetails' => 'title'),
		'Account Name' => array('contactdetails' => 'account_id'),
		'Assigned To' => array('crmentity' => 'smownerid'),
	);

	var $search_fields_name = array(
		'Name' => 'lastname',
		'Title' => 'title',
		'Account Name' => 'account_id',
		'Assigned To' => 'assigned_user_id'
	);

	var $required_fields = array(
		'equipmentname' => 1
	);

	// Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
	var $sortby_fields = array();
	var $def_basicsearch_col = 'equipmentname';

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'equipmentname';
	var $default_sort_order = 'ASC';

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to lingdang_field.fieldname values.
	var $mandatory_fields = array('createdtime', 'modifiedtime', 'equipmentname', 'assigned_user_id');
	// Josh added for importing and exporting -added in patch2
	var $unit_price;
	public $code_fieldname = 'equipmentcode';// 二维码/条形码编码 字段
	protected $codeimage_actiontype = 'insert';// 二维码/条形码图片操作类型，insert：需要插入关联附件表/update：需要更新关联附件表/delete：删除图片及表中数据/none：不需要进行操作

	/**	Constructor which will set the column_fields in this object
	 */
	function __construct()
	{
		//$this->log =LoggerManager::getLogger('product');
		//$this->log->debug("Entering Equipment() method ...");
		$this->db = PearDatabase::getInstance();
		$this->fieldobj = Field::getInstance('Equipment', $this->db);
		$this->column_fields = $this->fieldobj->getFieldArray('fieldname', $this);
		$entityname = getEntitynameByModulename('Equipment');
		$this->list_link_field = $entityname['fieldname'];

	}
	/** Function to handle module specific operations when saving a entity
	 */
	function save_module($module)
	{

	}
	public function before_save($record){
		
		// 判断 二维码/条形码编码 字段不允许有特殊字符和中文
		$code_content = $this->column_fields[$this->code_fieldname];
		if(!empty($code_content)){
			$error_msg = '';
			$code_fieldinfo = $this->fieldobj->getFieldInfoobjBykey("fieldname",$this->code_fieldname);
			if($code_fieldinfo){
				$code_fieldLableKey = $code_fieldinfo->getFieldLabelKey();
				$error_msg = $code_fieldLableKey.'，';
			}

			$code_content = $this->column_fields[$this->code_fieldname] = preg_replace('/\s+/', '', $code_content);
			if(!preg_match('/^[A-Za-z0-9_-]+$/', $code_content)){
				$error_msg .= getFixedLabel('CannotContainSpecialorChinese');
				return ConvertTojsonString(-1, [], $error_msg);
			}
			// 不能只包含符号，需要有数字英文
			if (preg_match('/[A-Za-z\d]/', $code_content)) {
				
			} else {
				$error_msg .= getFixedLabel('INCORRECTFORMAT');
				return ConvertTojsonString(-1, [], $error_msg);
			}
		}
	}
	public function after_save()
	{
		$codeimagepath_arr = $this->createCodeImages($this->code_fieldname);// 生成二维码/条形码编码
		if($codeimagepath_arr){
			// 将生成的二维码/条形码文件，保存到附件表中
			$this->saveCodeImagesToAttachment($codeimagepath_arr);
		}
	}

	function restore($module, $id)
	{
		parent::restore($module, $id);
	}



	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id)
	{
		parent::unlinkRelationship($id, $return_module, $return_id);
	}
	/**
     * 根据code字段生成二维码/条形码，并保存到本地文件夹
     */
	public function createCodeImages($code_fieldname){
		global $adb, $current_user;
		require_once globalStatic::$root_directory . '/vendor/autoload.php';
		$Qrcode_imagepath = '';
		$Barcode_imagepath = '';
		//非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
			$fieldinfo = $this->fieldobj->getFieldInfoobjBykey("fieldname",$code_fieldname);
			$fieldid = $fieldinfo->getFieldid();
			// 判断是否只读
			if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
				return false;
			}
		}
		if(isset($this->column_fields[$code_fieldname])){
			if(!empty($this->column_fields[$code_fieldname])){

				$code_content = $this->column_fields[$code_fieldname];

				// 创建目录
				$filepath = 'storage/'.strtolower($this->module_name).'/'.$this->id.'/';
				if (!is_dir(globalStatic::$root_directory.$filepath)) {
					// 如果不存在，创建
					if (!mkdir(globalStatic::$root_directory.$filepath, 0777, true)) {
						return false;
					}
				}
				// 生成二维码
                $Qrcode_imagepath = $filepath . 'qrcode_'.time().'.png';
                $builder = new Endroid\QrCode\Builder\Builder();
                $builder

                    ->data($code_content)
                    ->size(300)
                    ->ForegroundColor(new Endroid\QrCode\Color\Color(0,0,0))
                    ->BackgroundColor(new Endroid\QrCode\Color\Color(255,255,255))
                    // ->labelText($productcode)
                    ->margin(10);
                $result = $builder->build();
                // 生成图片
                file_put_contents(globalStatic::$root_directory.$Qrcode_imagepath, $result->getString());
				// 生成条形码

                $generator = new Picqer\Barcode\BarcodeGeneratorJPG();
                $Barcode_imagepath = $filepath . 'barcode_'.time().'.png';
                // 生成图片
                file_put_contents($Barcode_imagepath, $generator->getBarcode($code_content, $generator::TYPE_CODE_128,1,25));
				return ['qrcode' => $Qrcode_imagepath, 'barcode' => $Barcode_imagepath];
			}else{
				// 为空则删除以前的图片
				$filepath = globalStatic::$root_directory.'storage/'.strtolower($this->module_name).'/'.$this->id;
				if (is_dir($filepath)){
					$del_files = glob($filepath . '/*');
					foreach ($del_files as $file) {
						if (!is_dir($file)) {
							@unlink($file);
						}
					}
					@rmdir($filepath);
				}
				$this->deleteCodeImage();
			}
		}
		return false;
	}
	/**
     * 将生成的二维码/条形码文件，保存到附件表中
     */
	public function saveCodeImagesToAttachment($codeimagepath_arr){
		global $adb, $current_user;
		// 先删除旧的图片
		$this->deleteCodeImage();
		foreach ($codeimagepath_arr as $key => $imagepath) {
			// $hyperlink_value = getModuleHref($this->module_name,$this->id);
			// 删除附件表中数据
			// if($this->codeimage_actiontype == 'delete'){
			// 	$this->deleteAttachment($this->id,$this->module_name,[$key.'image']);
			// }else{
				if(!empty($imagepath)){
					$extension = pathinfo($imagepath, PATHINFO_EXTENSION);
					$filename = $this->column_fields['equipmentname'];
					if($key == 'qrcode'){
						$filename .= '-二维码';
					}else{
						$filename .= '-条形码';
					}
					$filename .= '.'.$extension;
					$newfile_name = mb_substr($imagepath, mb_strrpos($imagepath, '/') + 1);
					$filepath = pathinfo($imagepath, PATHINFO_DIRNAME).'/';// 文件路径
					$size = filesize(globalStatic::$root_directory.$imagepath);

					if ($size < 1024)
						$size = $size . ' B';
					else if ($size > 1024 && $size < 1048576)
						$size = round($size / 1024, 2) . ' KB';
					else if ($size > 1048576)
						$size = round($size / (1024 * 1024), 2) . ' MB';

					// if($this->codeimage_actiontype == 'update'){
					// 	$update_sql = "UPDATE ld_attachments INNER JOIN ld_attachments ON ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
					// 					SET newfile_name = ?,`size` = ? WHERE crmid = ? AND attachmentcolumnname = ?";
					// 	$adb->pquery($update_sql, array($newfile_name, $size, $this->id, $key.'_image'));
					// }else{
						$current_id = $adb->getUniqueID("ld_crmentity");// 附件明细id
						$sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
						$adb->pquery($sql1, array($current_id, $this->module_name . " Image"));

						//插入附件明细关联表ld_seattachmentsrel
						$sqlInsertRel = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
						$adb->pquery($sqlInsertRel, array($this->id, $current_id, $key.'image'));
						
						$filetype = getFileTypeByfilename($imagepath);

						//插入附件明细表ld_attachments
						$sqlInsertAttachments = 'insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from,watermark) values(?,?,?, ?, ?, ?, ?,?,?,?,?,?)';
						$adb->pquery($sqlInsertAttachments, array($current_id, $filename, $newfile_name, '-无-', $filetype, $filepath, $size, 'Computer', '', 'local', '', 'no'));
					// }
				}
			// }
		}
	}
	// 删除与附件表的关系
	private function deleteCodeImage(){
		global $adb;
		$id = $this->id;
		$module = $this->module_name;
		$columnnamearr = ['qrcodeimage','barcodeimage'];

		$sql = "SELECT ld_seattachmentsrel.attachmentsid,path,newfile_name,
					ld_attachments.storage_location,ld_attachments.cloud_path from ld_seattachmentsrel
					inner join ld_crmentity on ld_seattachmentsrel.attachmentsid=ld_crmentity.crmid  
					inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
					where ld_seattachmentsrel.crmid=?
					and ld_crmentity.setype = ? and FIND_IN_SET(ld_seattachmentsrel.attachmentcolumnname,?);";

		$result = $adb->pquery($sql, array($id, "$module Image" , implode(',', $columnnamearr)));
		for ($i = 0; $i < $adb->num_rows($result); $i++) {
			$attachments_id = $adb->query_result($result, $i, 'attachmentsid');
			$sql = 'delete from ld_crmentity where crmid=?';
			$adb->pquery($sql, array($attachments_id));
			$sql = "delete from ld_seattachmentsrel where attachmentsid=?";
			$adb->pquery($sql, array($attachments_id));
			$sql = "delete from ld_attachments  where attachmentsid=?";
			$adb->pquery($sql, array($attachments_id));
		}
	}
}
Equipment::require_file();
?>