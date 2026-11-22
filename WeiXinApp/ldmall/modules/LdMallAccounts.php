<?php

class LdMallAccounts extends LdMall
{
	public function __construct(){
		//默认显示字段
		$this->contact_fields = array('lastname','mobile','mailingstreet');
		// $this->account_fields = array('accountname','account_type','rating','important_level','lastname','mobile','mailingstreet','filename');
		$this->account_fields = array('accountname','account_type','rating','important_level','lastname','mobile','mailingstreet');
        //zxm 2022-7-13 捷利康特殊判断
        $tradeinfo = getVersionTradeInfo();
        if($tradeinfo['account']=='jielikang'){
            $this->account_fields = array('accountname','account_type','lastname','mobile','cf_4801');
        }
        if($tradeinfo['account']=='haopengyou'){
            $this->account_fields = array('accountname','lastname','mobile','mailingstreet');
        }


		if(!empty($_REQUEST['wxuserid'])){
			//客户联系人
			$wechatuser_focus = CRMEntity::getInstance('WeChatUser');
			$wechatuser_focus->retrieve_entity_info($_REQUEST['wxuserid'],'WeChatUser');
	        $wechatuser_focus_fields=$wechatuser_focus->column_fields;
	        if(!empty($wechatuser_focus_fields['account_id'])){
	        	$this->accountid = $wechatuser_focus_fields['account_id'];
				$this->account_focus = CRMEntity::getInstance('Accounts');
				$this->account_field_obj =Field::getInstance('Accounts',$adb);
				$this->account_moduleFields=$this->account_focus->fieldobj->getModuleFields();
				if(!empty($this->accountid)){
					$this->account_focus->retrieve_entity_info($this->accountid,'Accounts');
					$this->account_col_fields=$this->account_focus->column_fields;
					$this->account_showfieldvalue=new ShowFieldValue($this->account_focus->fieldobj,'Accounts',constant('SHOW_POPUP'));
					$this->account_showfieldvalue->col_fields=$this->account_col_fields;
					$this->account_showfieldvalue->setRecorId($this->accountid);
				}
	        }
	        if(!empty($wechatuser_focus_fields['contact_id'])){
	        	$this->contactid = $wechatuser_focus_fields['contact_id'];
	        	$this->contacts_focus = CRMEntity::getInstance('Contacts');
				$this->contacts_field_obj =Field::getInstance('Contacts',$adb);
				$this->contacts_moduleFields=$this->contacts_focus->fieldobj->getModuleFields();
				$this->contacts_focus->retrieve_entity_info($wechatuser_focus_fields['contact_id'],'Contacts');
		        $this->contacts_col_fields=$this->contacts_focus->column_fields;
				$this->contact_showfieldvalue=new ShowFieldValue($this->contacts_focus->fieldobj,'Contacts',constant('SHOW_POPUP'));
				$this->contact_showfieldvalue->col_fields=$this->contacts_col_fields;
				$this->contact_showfieldvalue->setRecorId($wechatuser_focus_fields['contact_id']);
	        }
			$this->getFieldLabel();
		}
	}

	//修改微信用户绑定的客户和联系人
	public function getAccounts(){
		global $current_user;
		$tradeInfo = getVersionTradeInfo();
		$list_fields = $this->account_fields;
		$k = 0;
		foreach($list_fields as $key => $fieldname){
			if(in_array($fieldname,$this->contact_fields)){
				$field = $this->contacts_moduleFields[$fieldname];
				$showvalue=$this->contact_showfieldvalue->getFieldValueByField($field,$this->contacts_col_fields[$fieldname],$this->contacts_col_fields[$fieldname]);
			}else{
				$field = $this->account_moduleFields[$fieldname];
				if(!empty($field) && !empty($this->accountid))
					$showvalue=$this->account_showfieldvalue->getFieldValueByField($field,$this->account_col_fields[$fieldname],$this->account_col_fields[$fieldname]);
				else
					$showvalue = array('value'=>'','rawvalue' => '');
			}

			if(!empty($field)){
				$uitype = $field->getUIType();
				$columnname = $field->getColumnName();
				$typeofdata = $field->getTypeOfData();
				$typeofdata_array = explode("~", $typeofdata);
				$option = [];
				if($uitype == 15 || $uitype == 33){
					$picklist = $this->getPickList($columnname);
					foreach($picklist as $val){
						if(!empty($val)){
							$option[] = array('text'=>$val,'value'=>$val);
						}
					}
				}
				$readonly = 'no';
				$fieldtype = 'O';
				$fieldtype = $typeofdata_array[1];
				if($uitype == 33){
					$showvalue['value'] = str_replace(" |##| ",",",$showvalue['value']);
				}
				$type = $uitype;
				$fieldatatype = $field->getFieldDataType();
				$text = $showvalue['value'];
				if($uitype == 1109){
					$text = $this->getAttachmentInfo($this->accountid);
					if($text == null){
						$text = '';
					}
				}
				// 联科生物特殊开发
				if($tradeInfo['account']=='liankeshengwu'){
					if($fieldname == 'accountname' || $fieldname == 'lastname' || $fieldname == 'mobile'){
						$readonly = 'yes';
					}
					if($showvalue['rawvalue'] && $fieldname == 'rating'){
						$readonly = 'yes';
						$uitype = '1';
					}
				}
				$data['list'][$k] = array(
					'columnname' => $columnname,
					'readonly' => $readonly,
					'fieldlabel' => $this->module_fieldlabel[$fieldname],
					'fieldtype' => $fieldtype,
					'fieldname' => $fieldname,
					'text' => $text,
					'uitype' => $uitype,
					'type' => $fieldatatype,
					'value' => $showvalue['rawvalue'],
				);
				if($uitype == 1109){
					$data['list'][$k]['take_photo_only'] = '0';
				}
				if(!empty($option)){
					$data['list'][$k]['option'] = $option;
				}
				if($uitype == 33){
					$data['list'][$k]['textstr'] = '';
				}
				$k++;

			}
		}
		return [1,$data,'success'];
	}

	//上传、下载附件
	public function Upload(){
		crm_load_class_file('cls_download_cloud','WeiXinApp/ldmall/include');
		$cls_download_cloud = new cls_download_cloud();
		$data = $cls_download_cloud->download();
		ConvertTojsonString(1, $data, 'success');
	}

	//保存
	public function saveAccounts(){
		$list_fields = $this->account_fields;	//大巴车
		$post_data = json_decode($_REQUEST['listObj']);
		foreach($list_fields as $key => $fieldname){
			if(in_array($fieldname,$this->contact_fields)){
				if(!empty($post_data->$fieldname)){
					$_REQUEST[$fieldname] = $post_data->$fieldname;
					$this->contacts_focus->column_fields[$fieldname] = $post_data->$fieldname;
				}
			}else{
				if(!empty($post_data->$fieldname)){
					if($fieldname == 'filename'){
						$_REQUEST[$fieldname.'-file_num'] = sizeOf($post_data->$fieldname);
						$row = 1;
						foreach($post_data->$fieldname as $arr){
							$_REQUEST[$fieldname.'-file_size_'.$row] = $arr->filesize;
							$_REQUEST[$fieldname.'-file_name_'.$row] = $arr->filename;
							$_REQUEST[$fieldname.'-file_path_'.$row] = $arr->filepath;
							$_REQUEST[$fieldname.'-file_type_'.$row] = $arr->filetype;
							$_REQUEST[$fieldname.'-newfile_name_'.$row] = $arr->newfile_name;
							$_REQUEST[$fieldname.'-fileid_'.$row] = '';
							$_REQUEST[$fieldname.'-storage_location_'.$row] = 'local';
							$_REQUEST[$fieldname.'-cloud_path_1'.$row] = '';
							$row++;
						}
					}
					else{
						$_REQUEST[$fieldname] = $post_data->$fieldname;
						$this->account_focus->column_fields[$fieldname] = $post_data->$fieldname;
					}
				}
			}
		}
		//联系人保存
		//$this->contacts_focus->column_fields['reference']=1;
		$this->contacts_focus->id = $this->contactid;
		$this->contacts_focus->mode = 'edit';
		$_REQUEST['mode'] = 'edit';
		$this->contacts_focus->save('Contacts');
		//dump($this->contacts_focus->column_fields);
		//客户保存
		$this->account_focus->id = 0;
		unset($_REQUEST['contactid']);
		if(!empty($this->accountid)){
			$this->account_focus->id = $this->accountid;
			$this->account_focus->mode = 'edit';
		}
		$this->account_focus->save('Accounts');
		return [1,array(),'success'];
	}

	//获取下拉框值
	public function getPickList($columnname){
		global $adb;
		crm_load_class_file('PickListUtils','modules/PickList');
		$picklistValues = getAssignedPicklistValues($columnname, '', $adb,array(),"");
		return $picklistValues;
	}

	//获取附件信息
	public function getAttachmentInfo($record){
		global $adb;
		$query = "SELECT
			ld_seattachmentsrel.attachmentsid,
			ld_attachments. NAME,
			ld_attachments.type,
			ld_attachments.path,
			storage_location,
			cloud_path,
			ld_attachments.size,
			ld_attachments.newfile_name,
			ld_attachments.imagefromtype,
			ld_attachments.attachmentsid
		FROM
			ld_attachments
		LEFT JOIN ld_crmentity ON ld_attachments.attachmentsid = ld_crmentity.crmid
		LEFT JOIN ld_seattachmentsrel ON ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid
		where ld_seattachmentsrel.crmid=? and ld_crmentity.setype='Attachment'";
		$result = $adb->pquery($query,array($record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$path = $adb->query_result($result,$i,'path');
				$newfile_name = $adb->query_result($result,$i,'newfile_name');
				$data[] = array(
					'ext' => 'img',
					'httppath' => $path . $newfile_name,
					'id' => $adb->query_result($result,$i,'attachmentsid'),
					'imagefromtype' => 'Albums',
					'name' => $adb->query_result($result,$i,'name'),
					'newfile_name' => $newfile_name,
					'path' => $path,
					'size' => $adb->query_result($result,$i,'size'),
					'storage_location' => 'local',
					'type' => 'image/png'
				);
			}
		}
		return $data;
	}

	public function getFieldLabel(){
		global $adb;
		$query = "select ld_field.fieldname,ld_tranlabel.fieldlabel from ld_field 
		LEFT JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_field.fieldid 
		where ld_field.tabid = 4 and ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable = 'ld_field'";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$fieldname = $adb->query_result($result,$i,'fieldname');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				if(in_array($fieldname,$this->contact_fields)){
					$this->module_fieldlabel[$fieldname] = $fieldlabel;
				}
			}
		}

		$query = "select ld_field.fieldname,ld_tranlabel.fieldlabel from ld_field 
		LEFT JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_field.fieldid 
		where ld_field.tabid = 102 and ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable = 'ld_field'";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$fieldname = $adb->query_result($result,$i,'fieldname');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				if(in_array($fieldname,$this->account_fields)){
					$this->module_fieldlabel[$fieldname] = $fieldlabel;
				}
			}
		}
	}

}