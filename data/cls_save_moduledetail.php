<?php
require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class cls_save_moduledetail
{
    public $module;
    public $record;
    public $saveRow_Count;
    public $focus;
    public $db;
    public $table_index;
    public $table_name = '';
    public $id;
    public function __construct($module,$record)
    {
        $this->module=$module;
        $this->record=$record;
        $this->focus=$this->createFocus();
    }
    public function createFocus()
    {
     
        $this->focus=CRMEntity::getInstance($this->module);
        return $this->focus;
    }
    //明细保存前的操作
    public function before_save()
    {
        global $adb;
         $detailtablename=$this->focus->Detail_table;
         $detailtablenamescf=$this->focus->Detail_table_scf;
         $detail_table_id=$this->focus->Detail_table_id;
         $detail_table_index=$this->focus->Detail_table_index;
          $query = "delete from  $detailtablenamescf where $detail_table_id in (select $detail_table_id from $detailtablename where $detail_table_index=?)";
       	  $adb->pquery($query,array($this->record));
        $query = 'delete from ' . $detailtablename . ' where ' . $detail_table_index .' = ?';
 
        $adb->pquery($query,array($this->record));
      
				
    }
    public function Savedetail()
    {
         if($_REQUEST['action'] != $this->module.'Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            //查看界面的小编辑和批量修改
            return ;
        }
        global $adb,$weixin_user;
        $row_cnt=$this->GetsaveRowCount();
        //记录保存前的分录信息
        $before_db_value_arr = $this->save_before_detailinfo();
        $this->before_save();
        $versioninfo = getVersionInfo();
        if($this->module == 'Expense'){
            $expensetypeinfo=  $this->focus->getExpenseTypeInfo();
        }
      
        $detailtablescf=$this->focus->Detail_table_scf;
        $detailtablename=$this->focus->Detail_table;
        $detail_table_index=$this->focus->Detail_table_index;
       	require_once(globalStatic::$root_directory.'include/TabDetailFields/TabDetailFields.php');
		$TabDetailFields = new TabDetailFields(getTabid($this->module));
		$tabDetailFields = $TabDetailFields->getTabDetailFields();
        
        $i=1;
        do{
				$insertTable = array();
				$insertValue=array();
			     if($this->Checkrowissave($i)=='no')
                 {
                    $i++;
                     continue;
                 }
				foreach($tabDetailFields as $columnname => $field){
					$columnname = $field->getColumnName();
					$tablename = $field->getTableName();
					$savedatabase = $field->getSaveDataBase();
					$fieldtype = $field->getFieldType();
					if($savedatabase == 'no'){
						continue;
					}

					if($field->getNewLine() == 1)
						$value = $_REQUEST[$columnname];
					else
						$value = $_REQUEST[$columnname . $i];

                    // 附件，图片
                    if($fieldtype == 'Image' || $fieldtype == 'Attachment'){
                        $value = "";
                        // continue;
                    }
					//复选框
					if($field->getFieldType() == 'CheckBox'){
						if($value === 'on'||$value==1){
							$value = 1;
						}else{
							$value = 0;
						}
					}
					if($field->getFieldType() == 'SelectComBox'){
						//$value = implode(' |##| ',$value);
                        $value = setsaveMutliPickListValue($value);//str_replace('########'," |##| ",$value);
					}
					//源单
					if($field->getFieldType() == 'SelectSource'){
						if($columnname == 'entitytypeid'){
							$insertTable[$tablename][$columnname] = $value;
							if(empty($value)){
								$insertTable[$tablename]['entitytype'] = '';
							}else{
								$entitype = $_REQUEST['select_' . $columnname . $i];
                                //editor:gyq_20190830 reason:0037902:
                                // 企业微信：新增的佣金单，关联服务合同，保存后 ld_commission2payment 表 entitytype 没有赋值  2019/8/30 15:28
                                if($weixin_user->environment_weixin){
                                    $entitype = $_REQUEST['entitytype'. $i];
                                }
								$insertTable[$tablename]['entitytype'] = $entitype;
							}
							
							if(!empty($entitype) && !empty($value)){
								$insertTable[$tablename]['entitytype_value'] = getModuleHref($entitype,$value);
							}
						}
					}
					$insertTable[$tablename][$columnname] = $value;
					if($columnname == 'currency_id'){
						$currencyobj=new Currency($adb,$value);
						$insertTable[$tablename]['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
					}
				}
				//联合技术MER特殊控制:根据费用类别控制显示隐藏列
				if($versioninfo['account'] == 'utrc' && $this->module == 'Expense'){
					$expensetype_value = $insertTable[$detailtablename]['expensetype'];
					if($expensetypeinfo[$expensetype_value] == 'MileageReimbursement'){
						$insertTable[$detailtablescf]['currency_id'] = 1;
						$currencyobj=Currency::getInstance($adb,1);
						$conversion_rate = $currencyobj->getCurrencyRate();
						$insertTable[$detailtablescf]['conversion_rate'] = $conversion_rate;
					}
				}
               
                $insertValue[$detailtablename] = $insertTable[$detailtablename];
                $insertValue[$detailtablescf] = $insertTable[$detailtablescf];
                $insertValue[$detailtablename][$detail_table_index]=$this->record;
				foreach($insertValue as $tablename => $columvalues){
					$column = !empty($columvalues)?array_keys($columvalues):[];
					$updatefld = array();
                  
					if($tablename != strtolower($this->focus->table_name)){
					   if($tablename==$detailtablename)
                       {
        					
        						//明细
                           if($versioninfo['account']=='langjie' && $this->module == 'Commission')
                           {
                               $query = 'insert into '.$tablename.'('.$this->table_index.','.implode(',',$column). ',parent_lineitem_id,sequence) values('.$this->id.','.generateQuestionMarks($columvalues).',?,?)';

                               $columvalues['parent_lineitem_id']=$_REQUEST['parent_lineitem_id'.$i];
                           }
                           else{
                               $query = 'insert into '.$tablename.'('.implode(',',$column). ',sequence) values( '.generateQuestionMarks($columvalues).',?)';

                               //$columvalues['parent_lineitem_id']=$_REQUEST['parent_lineitem_id'.$i];
                           }

							$columvalues['sequence']=$i;
                           
                            $adb->pquery($query,$columvalues);
                            $id=$adb->getLastInsertID();
                            //记录新旧Detail_table_id用于保存修改日志
                            if($_REQUEST[$this->focus->Detail_table_id.$i]>0){
                                $detail_id = $_REQUEST[$this->focus->Detail_table_id.$i];
                                $new_detailid_arr[$detail_id] = $id;
                            }else{
                                $new_detailid_arr[$id] = $id;
                                $detail_id = $id;
                            }
                            if(is_array($insertValue[$this->focus->Detail_table_scf])&&sizeof($insertValue[$this->focus->Detail_table_scf])>0){
                                $request_value_arr[$detail_id] = array_merge($columvalues,$insertValue[$this->focus->Detail_table_scf]);
                            }else{
                                $request_value_arr[$detail_id] = $columvalues;
                            }

                           if($versioninfo['account']=='langjie' && $this->module == 'Commission'){
                               $commission2payment_id=$_REQUEST['commission2payment_id'.$i];//detailid
                               if($_REQUEST['commissiontype']=='入库'&&$commission2payment_id>0){
                                   $updatelangjieparent_lineitem_id_arr[$commission2payment_id]=$id;
                               }
                           }


                           //记录行数与lineitem_id的关系
                           $new_lineitemid[$i] = array('new_lineitemid'=>$id,'old_lineitemid'=>$_REQUEST[$this->focus->Detail_table_id.$i]);

						}//明细scf
						else if($tablename == $this->focus->Detail_table_scf){
                            if(is_array($columvalues) && count($columvalues) > 0){
                                $query = 'insert into '.$tablename.'('.$this->focus->Detail_table_id.',`'.implode('`,`',$column). '`) values('.$id.','.generateQuestionMarks($columvalues).')';
                                $adb->pquery($query,$columvalues);
                            }else{
                                $query = 'insert into '.$tablename.'('.$this->focus->Detail_table_id.') values('.$id.')';
                                $adb->pquery($query,[]);
                            }
						}
					}
				}
				$i++;
			}while($i<=$row_cnt);

            //保存图片
            $this->insertIntoImage($new_lineitemid);

            //保存分录修改日志
            $this->save_moduleddetail_log($before_db_value_arr,$new_detailid_arr,$request_value_arr);

            //主表
            foreach($insertValue as $tablename => $columvalues){
                $column = !empty($columvalues)?array_keys($columvalues):[];
                $updatefld = array();
                if($tablename == strtolower($this->table_name)){
                    foreach($column as $col){
                        $updatefld[] = $col . '=?';
                    }
                    if(!empty($_REQUEST['adjustmentType'])){
                        $updatefld[] = 'subtotal = ?';//小计
                        if($_REQUEST['adjustmentType'] == '-')
                            $columvalues['subtotal'] = $_REQUEST['total'] + $_REQUEST['noamount'];
                        else
                            $columvalues['subtotal'] = $_REQUEST['total'] - $_REQUEST['noamount'];
                    }
                    $query = 'update '.$tablename.' set '.implode(',',$updatefld).' where ' . $this->table_index . '=?';
                    array_push($columvalues,$this->id);
                    $this->db->pquery($query,$columvalues);
                }
            }

            if($versioninfo['account']=='langjie' && $this->module == 'Commission'){
                $this->focus->langjieaftersave(langjie);
            }

            $this->After_save();
        
		
    }
    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（保存非产品分录明细“图片”字段）
    public function insertIntoImage($new_lineitemid=array())
    {
        global $adb,$current_user,$weixin_user,$upload_badext;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        if (empty($new_lineitemid)) {
            return;
        }else if($_REQUEST['file'] == 'ListDetailEditSave'){
            foreach($new_lineitemid as $tmp_info){
                $sql = 'update ld_detailattachments set lineitem_id = ? where lineitem_id = ? and crmid = ?';
                $adb->pquery($sql,[$tmp_info['new_lineitemid'],$tmp_info['old_lineitemid'],$this->record]);
            }
            return;
        }
        require_once(globalStatic::$root_directory.'include/TabDetailFields/TabDetailFields.php');
        $TabDetailFields = new TabDetailFields(getTabid($this->module));
        $tabDetailFields = $TabDetailFields->getTabDetailFields();

        $detailfieldinfo = $this->focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", 'image');
        //edit: xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（保存产品分录明细“附件”字段）
        $detailfieldinfo_file = $this->focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", 'fileattachment');
        if (!$detailfieldinfo && !$detailfieldinfo_file)//如果没有图片字段
        {
            return;
        }
        // if($weixin_user->environment_weixin){//移动端分录图片字段暂时没做，删除动作需要处理
        //     foreach ($new_lineitemid as $lineitemid_arr) {//更新图片字段的lineitem_id
        //         $adb->pquery("update ld_detailattachments set lineitem_id=? where lineitem_id=?", array($lineitemid_arr['new_lineitemid'],$lineitemid_arr['old_lineitemid']));
        //     }
        //     return;
        // }

        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];

        if($_REQUEST['mode'] == 'edit'){
            // 记录编辑前的附件信息
            $att_select_sql = "SELECT id,lineitem_id,newfile_name,columnname from ld_detailattachments where crmid = ? ";
            $att_select_result = $adb->pquery($att_select_sql,array($this->record));
			$num_rows = $adb->num_rows($att_select_result);
            $prevalue_attachmentlogsinfo_arr = [];
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $attachmentsid = $adb->query_result($att_select_result, $i, 'id');
                    $lineitem_id = $adb->query_result($att_select_result, $i, 'lineitem_id');
                    $newfile_name = $adb->query_result($att_select_result, $i, 'newfile_name');
                    $columnname = $adb->query_result($att_select_result, $i, 'columnname');

                    $tabdetail_fieldinfo = $this->focus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);

                    if(!empty($tabdetail_fieldinfo)){
                        $fieldname = $tabdetail_fieldinfo->getFieldName();
                        // $cur_new_lineitem_id = $new_detailid_arr[$lineitem_id];
                        $prevalue_attachmentlogsinfo_arr[$fieldname][$lineitem_id][$attachmentsid] = [
                            'attachmentsid' => $attachmentsid,
                            'newfile_name' => $newfile_name,
                        ];
                    }
                }
            }

            //编辑保存时，先删除分录明细表数据
            $adb->pquery("delete from ld_detailattachments where crmid=?", array($this->record));
        }
        
        $rowid = 1;
        $rowcnt = $_REQUEST['rowcnt'];
        do {
            if($this->Checkrowissave($rowid)=='no')
            {
                $rowid++;
                continue;
            }

            foreach ($tabDetailFields as $columnname=>$fieldInfo) {
                // $columnname = $fieldInfo->getColumnName();
                //edit: xll 2023/06/29 XUQIU1000357 单据分录定制，增加“附件”字段类型（非产品分录，保存附件字段信息）
                if (strtolower($fieldInfo->getFieldType()) != 'image' && strtolower($fieldInfo->getFieldType()) != 'attachment') {
                    continue;
                }
                $fieldname = $fieldInfo->getFieldName();
                // 附件图片prevalue初始化
                $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['prevalue'] = [];
                if($_REQUEST['mode'] == 'edit'){
                    if(!empty($prevalue_attachmentlogsinfo_arr) && !empty($prevalue_attachmentlogsinfo_arr[$fieldname][$new_lineitemid[$rowid]['old_lineitemid']])){
                        $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['prevalue'] = $prevalue_attachmentlogsinfo_arr[$fieldname][$new_lineitemid[$rowid]['old_lineitemid']];
                    }
                }
                $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['postvalue'] = [];
                
                if ($_REQUEST[$fieldname.$rowid . '-file_num'] > 0) {
                    for ($i = 1; $i <= 220; $i++) {

                        $tmp_attachmentlogsinfo_arr = [];

                        $filename = $_REQUEST[$fieldname.$rowid . '-file_name_' . $i]??'';    //附件名称
                        //
                        $filename = from_html(preg_replace('/\s+/', '_', $filename));
                        $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $filetype = $_REQUEST[$fieldname.$rowid . '-file_type_' . $i];    //附件类型
                        $filepath = $_REQUEST[$fieldname.$rowid . '-file_path_' . $i];    //附件路径

                        $filesize = $_REQUEST[$fieldname.$rowid . '-file_size_' . $i];    //附件大小
                        $newfile_name = $_REQUEST[$fieldname.$rowid . '-newfile_name_' . $i]??'';    //附件在服务器上名称
                        
                        //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                        $isEncrypt = $_REQUEST[$fieldname.$rowid.'-isEncrypt_'.$i];	//是否加密
                        $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($filepath) : $filepath;
                        $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($newfile_name) : $newfile_name;
                        
                        $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $newfile_name = str_replace("&", "_", $newfile_name);

                        $cloud_path = $_REQUEST[$fieldname.$rowid . '-cloud_path_' . $i];    //附件路径
                        $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;

                        //editor:gyq_20190326 reason:小程序附件记录上传方式
                        $imagefromtype = $_REQUEST[$fieldname.$rowid . '-imagefromtype_' . $i];    //附件上传的方式
                        if (empty($imagefromtype)) $imagefromtype = 'Computer';
                        if ($filename == '' && $filesize <= 0.0001) {
                            //附件删除会有错误
                            continue;
                        }
                        //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                        $upload_from = $_REQUEST[$fieldname .$rowid. '-upload_from_' . $i];
                        if (empty($upload_from) || $upload_from == 'undefined') {
                            $upload_from = '';
                        }
                        //文件存储位置:腾讯云存储桶/本地 （cos/local）
                        $storage_location = $_REQUEST[$fieldname.$rowid . '-storage_location_' . $i];
                        if (empty($storage_location) || $storage_location == 'undefined') {
                            $storage_location = 'local';
                            $cloud_path = '';
                        } elseif ($storage_location == 'cos') {
                            //给存储桶链接增加头，以便界面显示
                            $cloud_path = str_replace("http://", 'https://', $cloud_path);
                            if (stripos($cloud_path, 'https://') === false) {
                                $cloud_path = 'https://' . $cloud_path;
                            }
                            //else{
                            //     $cloud_path = $filepath;
                            // }

                            //删除文件临时表数据
                            // $this->deleteQcloudTempFile($newfile_name);
                        }

                        $binFile = sanitizeUploadFileName($filename, $upload_badext);
                        $filename = str_replace(" ", "_", $filename);
                        $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters

                        $sql1 = "insert into ld_detailattachments(crmid,lineitem_id,columnname,`name`,newfile_name, description, 
                            `type`, path,`size`,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?,?, ?, ?,?,?,?,?,?,?,?)";
                        $params1 = array($this->record, $new_lineitemid[$rowid]['new_lineitemid'],$columnname,$filename, $newfile_name, "", $filetype, $filepath, $filesize,
                            $imagefromtype, $cloud_path, $storage_location, $upload_from);


                        $result = $adb->pquery($sql1, $params1);
                        $current_id=$adb->getLastInsertID();

                        //edit: xll 2023/06/26 XUQIU1000357 单据分录定制，增加“附件”字段类型（更新附件日志表中的lineitem_id以保持日志可读取）
                        $updateLog_sql = "update ld_fileoperationlog set lineitem_id=? where crmid=? and lineitem_id=? and newfile_name=?";
                        $adb->pquery($updateLog_sql, array($new_lineitemid[$rowid]['new_lineitemid'], $this->record,$new_lineitemid[$rowid]['old_lineitemid'], $newfile_name));

                        // 记录附件图片修改日志
                        $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                        $tmp_attachmentlogsinfo_arr['crmid'] = $this->record;
                        $tmp_attachmentlogsinfo_arr['lineitem_id'] = $new_lineitemid[$rowid]['new_lineitemid'];
                        $tmp_attachmentlogsinfo_arr['name'] = $filename;
                        $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                        $tmp_attachmentlogsinfo_arr['type'] = $filetype;
                        $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                        $tmp_attachmentlogsinfo_arr['size'] = $filesize;
                        $tmp_attachmentlogsinfo_arr['imagefromtype'] = $imagefromtype;
                        $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                        $tmp_attachmentlogsinfo_arr['upload_from'] = $upload_from;
                        $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                        $tmp_attachmentlogsinfo_arr['description'] = '';
                        // 分录用 $fieldname_$lineitemid 来区分不同行同一个字段的内容
                        $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;


                        //百特，local则转存aws，已经是awsserver的不用处理。
                        if(getVersionInfo()['account']=='baxter' && $storage_location == 'local'){
                            crm_load_class_file('AWS', 'include');
                            $aws = AWS::getInstance();
                            if (file_exists($filepath.$newfile_name)) {
                                $aws_path = 'crm/'.$aws->bucket . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
                                $cloud_path = $aws->uploadFileByPath($aws_path.$newfile_name,$filepath.$newfile_name);
                                if (!empty($cloud_path)) {
                                    @unlink(globalStatic::$root_directory . $filepath . $newfile_name);
                                    $adb->pquery("update ld_detailattachments set path=?,storage_location=?,cloud_path=? where id=?",array($aws_path,'awsserver',$cloud_path,$current_id));
                                }

                            }
                        }
                    }
                }

            }
            $rowid++;
        } while ($rowid <= $rowcnt);

        // 记录修改日志
        $this->focus->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'prevalue','detail');
        $this->focus->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'postvalue','detail');
        
        if(!empty($this->focus->modstatic->getAttachmentImgLogs())){
			$this->focus->modstatic->insertAttachmentImgLogs('detail');
		}
    }

    //获取保存的行数
    public function GetsaveRowCount()
    {
        $row_cnt = $_REQUEST['rowcnt'];
        $this->saveRow_Count=$row_cnt;
        return $row_cnt;
    }
    //判断该行是否要保存
    public function Checkrowissave($rowindex)
    {
        // 1表示删除行  2表示空行
            if(!isset($_REQUEST['hidden_rowid_'.$rowindex]))
            {
                return 'no';
            }
        	if($_REQUEST['hidden_rowid_'.$rowindex] == 1 || $_REQUEST['hidden_rowid_'.$rowindex] == 2){
        	       return 'no';
     	   }
           else
           {
            return 'yes';
           }
    }
    //明细保存后的操作
    public function After_save()
    {
        global $adb;
        $tablename=$this->focus->table_name;
        $tableindex=$this->focus->table_index;
        $total=$_REQUEST['total'];
        if(isset($_REQUEST['sum_total']))
        {
            //自定义表单
            $total=$_REQUEST['sum_total'];
        }
        $sql="update $tablename set total=? where $tableindex=?" ;
   
        $adb->pquery($sql,array($total,$this->record));
    }
    public function save_before_detailinfo(){
        if($_REQUEST['mode']!='edit'){
            return array();
        }
        
        global $adb,$weixin_user,$current_user;
        $row_cnt=$_REQUEST['rowcnt'];
        $record = $this->record;
        $module = $this->module;
        $focus = $this->focus;
        $char = 'V';
        
        $detailtablescf=$this->focus->Detail_table_scf;
        $detailtablename=$this->focus->Detail_table;
        $detail_table_index=$this->focus->Detail_table_index;
        $detail_table_id_name = $this->focus->Detail_table_id;
        
       	require_once(globalStatic::$root_directory.'include/TabDetailFields/TabDetailFields.php');
		$TabDetailFields = new TabDetailFields(getTabid($this->module));
		$tabDetailFields = $TabDetailFields->getTabPresenceDetailFields();
        
		foreach($tabDetailFields as $columnname => $field){
			$columnname = $field->getColumnName();
			$tablename = $field->getTableName();
			$savedatabase = $field->getSaveDataBase();
			if($savedatabase == 'no'){
				continue;
			}
            //收款单和付款单中从源单获取信息的字段不需要保存
            if($module =='CashBill'&&($columnname=='source_total'||$columnname=='received_amount')){
                continue;
            }
            if($module =='SendCashBill'&&($columnname=='source_total'||$columnname=='pay_amount')){
                continue;
            }
			
            if(strtolower($tablename) == $detailtablescf||strtolower($tablename) ==$detailtablename){
                $detail_columns[] = $columnname;
                $detail_column_sql[] =  $tablename. '.' . $columnname;
			}
		}
        
        $detail_column_sql[] = $detailtablename.'.'.$detail_table_id_name;
        $detail_column_sql[] = $focus->table_name.'.total';
        
        $query = 'select ' . implode(',',$detail_column_sql) . ' from '.$detailtablename." 
		LEFT JOIN $detailtablescf on $detailtablescf.$detail_table_id_name = $detailtablename.$detail_table_id_name  
		LEFT JOIN ".$focus->table_name.' on '.$focus->table_name.'.'.$focus->table_index." = $detailtablename.$detail_table_index
		where $detailtablename.$detail_table_index = ? order by $detailtablename.$detail_table_id_name asc";

        $result = $adb->pquery($query,array($record));
		$data_num = $adb->num_rows($result);

        $total = 0;
		for($i = 0; $i<$data_num; $i++){
			$detail_table_id = $adb->query_result($result,$i,$detail_table_id_name);
			foreach($detail_columns as $columnname){
			    $value = $adb->query_result($result,$i,$columnname);
                if($value==0 && $columnname=='entitytypeid'){
                    $value = '';
                }
				$before_db_value_arr[$detail_table_id][$columnname] = $value;
			}
            
		}
        $total=0;
        if($adb->num_rows($result)>0)
            $total = $adb->query_result($result,0,'total');
        
        //考虑到历史数据不存在V1.0版本的情况
        if($data_num>0){
            $sql = 'select trackid_no from ld_detailtracker_basic where record = ?';
            $result = $adb->pquery($sql,array($record));
            $num_rows = $adb->num_rows($result);
            //为没有版本的已创建单据增加1.0版本
            if($num_rows==0){
                $trackid_no = $char.sprintf("%.1f",$num_rows+1);   
                $datetime = date('Y-m-d H:i:s');     
                //增加新版本
                $sql = 'insert into ld_detailtracker_basic(trackid_no,modulename,record,whodid,changedon,total) values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($trackid_no,$module,$record,$current_user->id,$datetime,$total));

                //获取新增加的日志id
                $sql = 'select max(trackid) as trackid from ld_detailtracker_basic';
                $result = $adb->pquery($sql,array());
                $trackid = $adb->query_result($result,0,'trackid');
                
                foreach($before_db_value_arr as $detail_table_id =>$before_detailinfo ){
                    $before_json_info = '';
                    if(sizeof($before_detailinfo)>0){
                        $after_json_info = ldcrm_json_encode($before_detailinfo);
                    }else{
                        continue;
                    }
                    $type = 'create';
                    $sql = 'insert into ld_detailtracker_detail(trackid,crmid,lineitem_id,prevaluejson,postvaluejson,changetype) values(?,?,?,?,?,?)';
                    $adb->pquery($sql,array($trackid,$record,$detail_table_id,$before_json_info,$after_json_info,$type));
                }

                if ($_REQUEST['is_qrcode_expand'] == 'yes') {
                    $qrcodeid = $_REQUEST['qrcodeid'];
                    $wechatuserid = $_REQUEST['wechatuserid'];
                    //表单码分录修改日志
                    $query = 'insert into ld_qrcode_operatelog_detail(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
                    $adb->pquery($query,array($qrcodeid,$wechatuserid,$datetime,'submit',$trackid,$record));
                }

            }
        }
        
        return $before_db_value_arr;
    }
    
    
    
    //保存分录修改日志
    /**
     * $request_value_arr：保存后的值
     * $new_detailid_arr:新的分录表主键的值（lineitem_id)
     * */
    public function save_moduleddetail_log($before_db_value_arr,$new_detailid_arr,$request_value_arr){
        global $adb,$weixin_user,$current_user;
        $row_cnt=$_REQUEST['rowcnt'];
        $record = $this->record;
        $module = $this->module;
        $focus = $this->focus;
        $char = 'V';
        
        $detailtablescf=$this->focus->Detail_table_scf;
        $detailtablename=$this->focus->Detail_table;
        
       	require_once(globalStatic::$root_directory.'include/TabDetailFields/TabDetailFields.php');
		$TabDetailFields = new TabDetailFields(getTabid($this->module));
		$tabFields = $TabDetailFields->getTabPresenceDetailFields();
        
        $detailid_arr = array();
        $changetype_arr = array();
        $pay_amount_total = 0;
        
		foreach($tabFields as $columnname => $field){
			$columnname = $field->getColumnName();
			$tablename = $field->getTableName();
			$savedatabase = $field->getSaveDataBase();
			if($savedatabase == 'no'){
				continue;
			}
            
            if(strtolower($tablename) == $detailtablescf||strtolower($tablename) ==$detailtablename){
                $detail_columns[] = $columnname;
			}
		}
        
        if($_REQUEST['mode']=='edit'){
            $save_newlog = 'no';
            //因为收款单和付款单保存时不传行id(lineitem_id),所以按照分录顺序逐行判断是否修改过
            if($module=='CashBill'||$module=='SendCashBill'){
                $i = 0;
                $change_db_value_arr = array();
                if(is_array($request_value_arr)){
                    for($i = 0;$i<sizeof($request_value_arr);$i++){
                        if($i==0){
                            //获取数组第一个元素
                            $request_detailinfo = reset($request_value_arr);
                            $detail_id = key($request_value_arr);
                            $before_detailinfo = reset($before_db_value_arr);
                        }else{
                            //获取数组下一个元素
                            $request_detailinfo = next($request_value_arr);
                            $detail_id = key($request_value_arr);
                            $before_detailinfo = next($before_db_value_arr);
                        }
                        
                        $type = 'same';
                        $row_change = 'no';
                        if(is_array($before_detailinfo)&&sizeof($before_detailinfo)>0){
                            $is_arr = 'yes';
                        }else{
                            $is_arr = 'no';
                        }
                        //付款单不传合计，所以重新计算
                        if($module=='SendCashBill'){
                            $pay_amount_total+=$request_detailinfo['amount'];
                        }
                        foreach($request_detailinfo as $columnname=>$commonvalue){
                            //如果该字段未启用或不显示则不存为日志
                            if(!in_array($columnname,$detail_columns)){
                                unset($request_value_arr[$detail_table_id][$columnname]);
                                continue;
                            }
                            //收款单和付款单中从源单获取信息的字段不需要保存
                            if($module =='CashBill'&&($columnname=='source_total'||$columnname=='received_amount')){
                                continue;
                            }
                            if($module =='SendCashBill'&&($columnname=='source_total'||$columnname=='pay_amount')){
                                continue;
                            }

                            $fieldinfo = $TabDetailFields->getFieldInfoobjBykey('columnname',$columnname);
                            if(!empty($fieldinfo)){
                                // 附件图片修改日志
                                if($fieldinfo->getBigType() == 'fileattachment' || $fieldinfo->getBigType() == 'image'){
                                    $commonvalue = '';
                                    $fieldname = $fieldinfo->getFieldName();
                                    $cur_new_lineitem_id = $new_detailid_arr[$detail_table_id];// 当前行新的lineitem_id
                                    $all_attachment_img_logs_arr = $focus->modstatic->getAttachmentImgLogs();
                                    if(!empty($all_attachment_img_logs_arr)){
                                        $cur_attachment_img_logs_arr = $all_attachment_img_logs_arr['detail'][$fieldname.'_'.$cur_new_lineitem_id];
                                        if(!empty($cur_attachment_img_logs_arr)){
                                            if(!empty($cur_attachment_img_logs_arr['prevalue']) && !empty($cur_attachment_img_logs_arr['postvalue'])){
                                                $attachment_prevalue_arr = $cur_attachment_img_logs_arr['prevalue']['attachmentsid_arr']??[];
                                                $attachment_postvalue_arr = $cur_attachment_img_logs_arr['postvalue']['attachmentsid_arr']??[];
                                                $attachment_prevalue_str = implode(',',$attachment_prevalue_arr);
                                                $attachment_postvalue_str = implode(',',$attachment_postvalue_arr);
                                                $change_db_value_arr[$detail_table_id][$columnname] = $attachment_prevalue_str;
                                                $request_value_arr[$detail_table_id][$columnname] = $attachment_postvalue_str;
                                                // getAttachmentImgLogs 函数获取的附件日志信息是已经判断过是否编辑过的
                                                if($cur_attachment_img_logs_arr['postvalue']['save_newlog'] == 'yes'){
                                                    $save_newlog = 'yes';
                                                    $row_change = 'yes';
                                                    $type = 'change';
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            if($row_change == 'yes'){
                                continue;
                            }else if($is_arr == 'yes'){
                                if($commonvalue !=$before_detailinfo[$columnname]){
                                    $save_newlog = 'yes';
                                    $row_change = 'yes';
                                    $type = 'change';
                                }
                            }else{
                                $save_newlog = 'yes';
                                $row_change = 'yes';
                                $type = 'create';
                            }
                        }
                        
                        $changetype_arr[$detail_id] = $type;
                        $change_db_value_arr[$detail_id] = $before_detailinfo;
                    }
                }
            }else{
                //将每一行的值与数据库中的值相比较
                $rowid = 1;
                foreach($request_value_arr as $detail_table_id => $request_detailinfo){
                    $type = 'same';
                    $row_change = 'no';
                    $before_db_key_arr = array_keys($before_db_value_arr);
                    if(isset($before_db_value_arr[$detail_table_id])){
                        $before_detailinfo = $before_db_value_arr[$detail_table_id];
                    }else{
                        if(isset($before_db_key_arr[$rowid-1])&&isset($before_db_value_arr[$before_db_key_arr[$rowid-1]])){
                            $before_detailinfo = $before_db_value_arr[$before_db_key_arr[$rowid-1]];
                        }else{
                            $before_detailinfo = array();
                        }
                    }
                    // $before_detailinfo = $before_db_value_arr[array_keys($before_db_value_arr)[0]];
                    if(is_array($before_detailinfo)&&sizeof($before_detailinfo)>0){
                        $is_arr = 'yes';
                    }else{
                        $is_arr = 'no';
                    }
                    
                    foreach($request_detailinfo as $columnname=>$commonvalue){
                        //如果该字段未启用或不显示则不存为日志
                        if(!in_array($columnname,$detail_columns)){
                            unset($request_value_arr[$detail_table_id][$columnname]);
                            continue;
                        }
                        $fieldinfo = $TabDetailFields->getFieldInfoobjBykey('columnname',$columnname);

                        if(!empty($weixin_user)){
                            //移动端分录单选框特殊处理
							//chj 2022-04-13 费用报销单提交审批被驳回后、在企业微信端对费用报销单再次编辑时会卡顿很长时间
							if(!empty($fieldinfo)){
								if($fieldinfo->getBigType() =='boolean'){
									if($commonvalue=='否'||$commonvalue==''){
										$commonvalue = 0;
									}else{
										$commonvalue = 1;
									}
									$request_value_arr[$detail_table_id][$columnname] = $commonvalue;
								}
							}
                        }
                        if(!empty($fieldinfo)){
                            // 附件图片修改日志
                            if($fieldinfo->getBigType() == 'fileattachment' || $fieldinfo->getBigType() == 'image'){
                                $commonvalue = '';
                                $fieldname = $fieldinfo->getFieldName();
                                $cur_new_lineitem_id = $new_detailid_arr[$detail_table_id];// 当前行新的lineitem_id
                                $all_attachment_img_logs_arr = $focus->modstatic->getAttachmentImgLogs();
                                if(!empty($all_attachment_img_logs_arr)){
                                    $cur_attachment_img_logs_arr = $all_attachment_img_logs_arr['detail'][$fieldname.'_'.$cur_new_lineitem_id];
                                    if(!empty($cur_attachment_img_logs_arr)){
                                        if(!empty($cur_attachment_img_logs_arr['prevalue']) && !empty($cur_attachment_img_logs_arr['postvalue'])){
                                            $attachment_prevalue_arr = $cur_attachment_img_logs_arr['prevalue']['attachmentsid_arr']??[];
                                            $attachment_postvalue_arr = $cur_attachment_img_logs_arr['postvalue']['attachmentsid_arr']??[];
                                            $attachment_prevalue_str = implode(',',$attachment_prevalue_arr);
                                            $attachment_postvalue_str = implode(',',$attachment_postvalue_arr);
                                            $before_db_value_arr[$detail_table_id][$columnname] = $attachment_prevalue_str;
                                            $request_value_arr[$detail_table_id][$columnname] = $attachment_postvalue_str;
                                            // getAttachmentImgLogs 函数获取的附件日志信息是已经判断过是否编辑过的
                                            $save_newlog = 'yes';
                                            $row_change = 'yes';
                                            $type = 'change';
                                        }
                                    }
                                }
                            }
                        }
                        if($row_change == 'yes'){
                            continue;
                        }else if($is_arr == 'yes'){
                            if($commonvalue !=$before_detailinfo[$columnname]){
                                $save_newlog = 'yes';
                                $row_change = 'yes';
                                $type = 'change';
                            }
                        }else{
                            $save_newlog = 'yes';
                            $row_change = 'yes';
                            $type = 'create';
                        }
                    }
                    $rowid ++;
                    $changetype_arr[$detail_table_id] = $type;
                }   
            }
        }else{
            $save_newlog = 'yes';
        }
        
        //如果需要增加新版本
        if($save_newlog == 'yes'){
            //获取版本号
            $sql = 'select trackid_no from ld_detailtracker_basic where record = ?';
            $result = $adb->pquery($sql,array($record));
            $num_rows = $adb->num_rows($result);
            $trackid_no = $char.sprintf("%.1f",$num_rows+1);   
            $datetime = date('Y-m-d H:i:s');      
            
            if(isset($_REQUEST['total'])&&$_REQUEST['total']>0){
                $total = $_REQUEST['total'];
            }else if($module == 'CashBill'&&isset($_REQUEST['cashbill_total'])&&$_REQUEST['cashbill_total']>0){
                $total = $_REQUEST['cashbill_total'];
            }else if($module == 'SendCashBill'&&isset($_REQUEST['sendcashbill_total'])&&$_REQUEST['sendcashbill_total']>0){
                $total = $_REQUEST['sendcashbill_total'];
            }else{
                $total = 0;
            }
            //增加新版本
            $sql = 'insert into ld_detailtracker_basic(trackid_no,modulename,record,whodid,changedon,total) values(?,?,?,?,?,?)';
            $adb->pquery($sql,array($trackid_no,$module,$record,$current_user->id,$datetime,$total));
            //获取新增加的日志id
            $sql = 'select max(trackid) as trackid from ld_detailtracker_basic';
            $result = $adb->pquery($sql,array());
            $trackid = $adb->query_result($result,0,'trackid');
            
            foreach($new_detailid_arr as $detail_table_id => $new_detailid){
                $re_detailinfo = $request_value_arr[$detail_table_id];
                if(is_array($re_detailinfo)&&sizeof($re_detailinfo)>0){
                    $after_json_info = ldcrm_json_encode($re_detailinfo);
                }else{
                    $after_json_info = '';
                }
                if($after_json_info==''){
                    continue;
                }
                
                if($module == 'CashBill'||$module=='SendCashBill'){
                    $db_detailinfo = $change_db_value_arr[$detail_table_id];
                    if(is_array($db_detailinfo)&&sizeof($db_detailinfo)>0){
                        $before_json_info = ldcrm_json_encode($db_detailinfo);
                    }else{
                        $before_json_info = '';
                    }
                }else{
                    $db_detailinfo = $before_db_value_arr[$detail_table_id];
                    if(is_array($db_detailinfo)&&sizeof($db_detailinfo)>0){
                        $before_json_info = ldcrm_json_encode($db_detailinfo);
                    }else{
                        $before_json_info = '';
                    }
                }
                
                if(empty($changetype_arr[$detail_table_id])){
                    $type = 'create';
                }else{
                    $type = $changetype_arr[$detail_table_id];
                }
                
                $sql = 'insert into ld_detailtracker_detail(trackid,crmid,lineitem_id,prevaluejson,postvaluejson,changetype) values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($trackid,$record,$new_detailid,$before_json_info,$after_json_info,$type));

                //ls 20221231  XUQIU1000922：表单码-分录可编辑（普通分录日志）
                if ($_REQUEST['is_qrcode_expand'] == 'yes') {
                    $qrcodeid = $_REQUEST['qrcodeid'];
                    $wechatuserid = $_REQUEST['wechatuserid'];
                    //表单码分录修改日志
                    $query = 'insert into ld_qrcode_operatelog_detail(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
                    $adb->pquery($query,array($qrcodeid,$wechatuserid,$datetime,'submit',$trackid,$record));
                }
            }
        }else{
            foreach($new_detailid_arr as $pre_detailid=>$post_detailid){
                if($pre_detailid != $post_detailid){
                    $sql = 'update ld_detailtracker_detail INNER JOIN ld_detailtracker_basic ON ld_detailtracker_basic.trackid = ld_detailtracker_detail.trackid
                             set lineitem_id = ? where modulename = ? and record = ? and lineitem_id=?';
                    $adb->pquery($sql,array($post_detailid,$module,$record,$pre_detailid));
                }
            }
        }
        $focus->trackId = $trackid;
    }
}
?>