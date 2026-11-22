<?php

Class cls_MappingFields{
	
	private $mappingfields;
    public $db;
    public $tabid;
    public $module;

	public function __construct($module){
		$this->db = PearDatabase::getInstance();
		$this->tabid = getTabid($module);
        $this->module = $module;
	}

    //获取模块的映射字段信息
	public function getMappingFields($map_module){ // wym 240320 XUQIU20240204-09 销售线索可编辑追踪字段
		if(is_array($this->mappingfields[$map_module])&&sizeof($this->mappingfields[$map_module]) > 0)
		{
			return $this->mappingfields[$map_module];
		}
        if(empty($map_module)){
            return '';
        }
		$cachekey = 'getMappingFields'.$this->tabid.'_'.$map_module;
		$modulemappingfields = CacheDirectory($cachekey,'mappingfields');
		if(!is_array($modulemappingfields)||!isset($modulemappingfields[$this->tabid]) || empty($modulemappingfields[$this->tabid])){
			if(!empty($this->tabid)){
                if($map_module=='Accounts'){ // wym XUQIU20240204-09 客户模块有首要联系人区块 特殊
                    $query = 'select fieldid,columnname,mapping_module,mapping_columnname,is_disabled,mapped_columnname from ld_module_mappingfields where tabid = ? and (mapping_module=? or mapping_module="Contacts") ';
                }else{
                    $query = 'select fieldid,columnname,mapping_module,mapping_columnname,is_disabled,mapped_columnname from ld_module_mappingfields where tabid = ? and mapping_module=?';
                }
				$result = $this->db->pquery($query,array($this->tabid,$map_module));
				$num_rows = $this->db->num_rows($result);
				for($i = 0; $i<$num_rows; $i++){
					$columnname = $this->db->query_result($result,$i,'columnname');
					$mapping_module = $this->db->query_result($result,$i,'mapping_module');
					$mapping_columnname = $this->db->query_result($result,$i,'mapping_columnname');
					$is_disabled = $this->db->query_result($result,$i,'is_disabled');
					$fieldid = $this->db->query_result($result,$i,'fieldid');
                    //edit:duan date:2021-12-6 销售线索映射字段优化
                    $mapped_columnname = $this->db->query_result($result,$i,'mapped_columnname');
					$columns[$columnname] = array(
						'fieldid' => $fieldid,
						'mapping_module' => $mapping_module,
						'mapping_columnname' => $mapping_columnname,
						'is_disabled' => $is_disabled,
                        'mapped_columnname' =>$mapped_columnname
					);
				}
                if(!is_array($modulemappingfields))
                {
                    $modulemappingfields=[];
                }
                $modulemappingfields[$this->tabid] = $columns;
                
                CacheDirectory($cachekey,'mappingfields',($modulemappingfields));
            }
		}
		$this->mappingfields[$map_module]=$modulemappingfields[$this->tabid];
		return $modulemappingfields[$this->tabid];
	}

    //wym 240321 XUQIU20240204-09 升级映射字段到新建模块（把原先内容整理成方法）
    public function getMapfieldsTomodule($upgradefromid,$mapmodule){
        global $current_user;
        if($this->module!=''&&$upgradefromid>0)
        {
            //销售线索升级
            $upgradefocus=CRMEntity::getInstance($this->module);
            $upgradefocus->retrieve_entity_info($upgradefromid,$this->module);
            //获取升级设置对应字段
            $mappingfields_info = $this->getMappingFields($mapmodule);
            $focus = CRMEntity::getInstance($mapmodule);
            foreach($upgradefocus->column_fields as $upgradefieldname=>$upgradevalue)
            {
                $upgradecolumnname=$upgradefocus->fieldobj->getFieldInfoBykeyValue('fieldname',$upgradefieldname,'columnname');
                $upgradefieldinfo= $mappingfields_info[$upgradecolumnname];
                //edit:duan date:2021-12-6 销售线索映射字段优化
                $mapped_columnname = $upgradefieldinfo['mapped_columnname'];
                if(!empty($mapped_columnname)){
                    if($mapped_columnname == 'curuser'){
                        $upgradevalue = $current_user->id;
                    }else{
                        $mapped_fieldname = $upgradefocus->fieldobj->getFieldInfoBykeyValue('columnname',$mapped_columnname,'fieldname');
                        $userid = $upgradefocus->column_fields[$mapped_fieldname];
                        if($userid>0){
                            $upgradevalue = $userid;
                        }
                    }
                }
                $after_upgradecolumn=$upgradefieldinfo['mapping_columnname'];//客户界面字段
                $after_upgradefieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$after_upgradecolumn,'fieldname');
                if(!empty($after_upgradefieldname))
                {
                    $focus->column_fields[$after_upgradefieldname]=$upgradevalue;
                }
            }
            //zkt 20240401 BUG20240328-15  销售线索推进选择“升级到销售机会”选项后，销售机会新建界面没有带过来“销售线索”数据值
            crm_load_class_file('cls_module_uitype','include/fields');
            $uitypes=cls_module_uitype::getModuleAllUtitype($this->module);
            foreach ($uitypes as $tmpindex=>$tmpuitype)
            {
                $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('uitype',$tmpuitype);
                if(!empty($tmpfieldinfo)&&!$tmpfieldinfo->isRelatedModuleField()){
                    //关联选择单据字段要赋值
                    $tmpfieldname = $tmpfieldinfo->getFieldName();
                    if(empty($focus->column_fields[$tmpfieldname])){
                        $focus->column_fields[$tmpfieldname] = $upgradefromid;
                    }
                    break;
                }
            }
            //duan 20221128 销售线索升级附件字段映射
            $before_fieldjsondata=getAllFile_imageInfo($upgradefromid,$this->module);
            if(sizeof($before_fieldjsondata)>0){
                $fieldjsondata = array();
                foreach($before_fieldjsondata as $tmp_column => $tmp_fileinfo){
                    $upgradefieldinfo= $mappingfields_info[$tmp_column];
                    $mapping_columnname = $upgradefieldinfo['mapping_columnname'];
                    if(!empty($mapping_columnname)){
                        if(isset($fieldjsondata[$mapping_columnname])){
                            $orgin_fileinfo = $fieldjsondata[$mapping_columnname];
                            $new_fileinfo = array_merge($tmp_fileinfo,$orgin_fileinfo);
                            $fieldjsondata[$mapping_columnname] = array_values($new_fileinfo);
                        }else{
                            $fieldjsondata[$mapping_columnname] =  $tmp_fileinfo;
                        }
                    }
                }
            }
            return array('mapped_column_fields'=>$focus->column_fields,'mapped_fieldjsondata'=>$fieldjsondata);
        }else{
            return array('mapped_column_fields'=>'','mapped_fieldjsondata'=>'');
        }
    }
}

?>