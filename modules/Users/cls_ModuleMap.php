<?php


class cls_ModuleMap
{
	public $frommodule;
    public $module;
    public $fromrecordid;
    public $relatedid;
    public $defaultfrommodule = 'Default';
    public $nomapdate = '';
    public $sourcefromPC = 'yes';
    public $focus;
    public $hreffieldinfo;
    public $relationInfo;
    public $mapfieldinfo;
    public $joinsql;
    public $page_left_join;
    public $lockstate;
    
    public function __construct($frommodule,$module,$fromrecordid=0,$relatedid=0)
    {
        $this->frommodule = $frommodule;
        $this->module = $module;
        $this->focus = CRMEntity::getInstance($module);
        $this->fromrecordid = $fromrecordid;
        $this->relatedid = $relatedid;
        
        
        //超链接字段
        $entityfield = getEntityField($this->module);
        $hreffieldfieldname = $entityfield['fieldname'];
        $this->hreffieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$hreffieldfieldname);
        
    }

    //判断PC图谱还是移动端图谱，默认yes
    public function setSourceFromPC($sourcefromPC){
        $this->sourcefromPC = $sourcefromPC;
    }
    
    public function setRelationInfo($relationinfo)
    {
        $this->relationInfo = $relationinfo;
    }
    
    public function getRelationInfo()
    {
        if(empty($this->relationInfo)){
           crm_load_function_file('getRelatedListInfoById','include/utils','DetailViewUtils');
	       $this->relationInfo = getRelatedListInfoById($this->relatedid,$this->frommodule);
        }
        return $this->relationInfo;
    }
    
    
    
    //获取保存的图谱信息
    public function getmapdateinfo(){
        global $adb;
        $module = $this->module;
        $frommodule = $this->frommodule;
        $fromrecordid= $this->fromrecordid;
        if ($frommodule=='ServiceCharge'){// ljj 20230901 BUG0071452 kfbtest-客户管理-客户名称为“联系人图谱测试”的客户有联系人图谱内容，但在“服务收费管理”模块，此客户的联系人图谱无内容
            $frommodule ='Accounts';
        }
        $sql = 'select nodeid,parentnodeid,childrennodeid,moduleindexid from ld_moduledatamap where fromrecordid = ? and modulename = ? and frommodule = ? ';
        $mapdata_arr = array();
        $result = $adb->pquery($sql,array($fromrecordid,$module,$frommodule));
        $rows = $adb->num_rows($result);
        if($rows>0)
        {
            $this->nomapdate = 'no';
            for($i=0;$i<$rows;$i++)
            {
                $nodeid = $adb->query_result($result,$i,'nodeid');
                $parentnodeid = $adb->query_result($result,$i,'parentnodeid');
                $childrennodeid = $adb->query_result($result,$i,'childrennodeid');
                $moduleindexid = $adb->query_result($result,$i,'moduleindexid');
                $mapdata_arr[] = array('nodeid'=>$nodeid,'moduleindexid'=>$moduleindexid,
                        'parentnodeid'=>$parentnodeid,'childrennodeid'=>$childrennodeid);
            }
        }
        else{
            $this->nomapdate = 'yes';//表示没有设置过联系人关系
            //没有联系人关系时，显示两个空白节点
            $mapdata_arr[] = array('nodeid'=>1,'moduleindexid'=>0,'parentnodeid'=>0,'childrennodeid'=>'2');
            $mapdata_arr[] = array('nodeid'=>2,'moduleindexid'=>0,'parentnodeid'=>1,'childrennodeid'=>'');
        }
        return $mapdata_arr;
    }
    //保存图谱信息
    public function savemapdatainfo($mapdatainfo){
        global $adb;
        $module = $this->module;
        $frommodule = $this->frommodule;
        $fromrecordid= $this->fromrecordid;
        if ($frommodule == 'ServiceCharge'){// ljj 20230901 BUG0071452 kfbtest-客户管理-客户名称为“联系人图谱测试”的客户有联系人图谱内容，但在“服务收费管理”模块，此客户的联系人图谱无内容
            $frommodule = 'Accounts';
        }
        $sql = 'delete from  ld_moduledatamap where fromrecordid = ? and modulename = ? and frommodule = ?';
        $adb->pquery($sql,array($fromrecordid,$module,$frommodule));
        if(!empty($mapdatainfo)){
            foreach($mapdatainfo as $index=>$info)
            {
                $nodeid = $info['nodeid'];
                $parentnodeid = $info['parentnodeid'];
                $childrennodeid = trim($info['childrennodeid'],',');
                $moduleindexid = $info['moduleindexid'];
                
                $sql = 'insert into  ld_moduledatamap(frommodule,modulename,fromrecordid,moduleindexid,nodeid,parentnodeid,childrennodeid) values(?,?,?,?,?,?,?)';
                $result = $adb->pquery($sql,array($frommodule,$module,$fromrecordid,$moduleindexid,$nodeid,$parentnodeid,$childrennodeid));
                
            }
        }
    }
    
    //获取图谱设置字段
    public function getmodulemapFieldInfo($isdefault=false){
        global $adb;
        if(!empty($this->mapfieldinfo)){
            return $this->mapfieldinfo;
        }
        $focus = $this->focus;
        $frommodule = $this->frommodule;
        if($isdefault){
            $frommodule = $this->defaultfrommodule;
        }
        $sql = 'select * from ld_moduledatashowview where modulename=? and frommodule=? order by sequence;';
        $result = $adb->pquery($sql,array($this->module,$frommodule));
        $rows = $adb->num_rows($result);
        $mapfieldinfo = array();
        if($rows>0){
            for($i=0;$i<$rows;$i++)
            {
                $columns = $adb->query_result($result,$i,'columns');
                $columns_arr = explode(':',$columns);
                $columnname = $columns_arr[1];
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                if(!empty($fieldinfo)){
                    $fieldlabel = $fieldinfo->getFieldLabel();
                    $fieldname = $fieldinfo->getFieldName();
                    $tablename = $fieldinfo->getTableName();
                    $column_arr = array();
                    $column_arr['columns'] = $columns;
                    $column_arr['columnname'] = $columnname;
                    $column_arr['fieldname'] = $fieldname;
                    $column_arr['tablename'] = $tablename;
                    $column_arr['fieldlabel'] = $fieldlabel;
                    if ($columnname == 'tag' && $fieldname == 'tag'){
                        $blockid = $fieldinfo->getBlockid();
                        $display_status = getBlocksDisplayStatus($blockid);
                        if ($display_status != 2){
                            $temp=$column_arr;
                        }
                    }else{
                        $mapfieldinfo[] = $column_arr;
                    }
                }
            }
            if (isset($temp)){
                $mapfieldinfo[]=$temp;
            }
        }
        else{
            //未获取到字段信息
            if(!$isdefault){
                $mapfieldinfo = $this->getmodulemapFieldInfo(true);
            }
        }
        $this->mapfieldinfo = $mapfieldinfo;
        return $mapfieldinfo;
    }
    
    //设置图谱字段
    public function savemodulemapField($mapfieldarr){
        global $adb;
        
        $frommodule = $this->frommodule;
        $module = $this->module;
        $adb->pquery("delete from ld_moduledatashowview where modulename =? and frommodule = ? ;",array($module,$frommodule));
        if(!empty($mapfieldarr))
        {
            $len = count($mapfieldarr);
            for($i=0; $i<$len; $i++)
            {
                $columns = $mapfieldarr[$i];
                $sequence = $i+1;
                $sql = "insert into ld_moduledatashowview(frommodule,modulename,columns,sequence) value (?,?,?,?)";
                $adb->pquery($sql,array($frommodule,$module,$columns,$sequence));
            }
        }
        
    }
    //重新获取图谱字段
    public function ResetmodulemapField(){
        $this->mapfieldinfo = [];
        $this->getmodulemapFieldInfo();
        
    }
    
    //获取模块图谱可选择字段
    public function getmodulemapFieldAll(){
        global $adb;
        $module = $this->module;
        $focus=CRMEntity::getInstance($module);
        $is_module = $module;
        $main_module_fields=$focus->fieldobj->getModuleFields();
        foreach($main_module_fields as $fieldname=>$fieldinfo)
        {
            $tablename=$fieldinfo->getTableName();
    		 $columnname=$fieldinfo->getColumnName();
    		if($fieldinfo&&($fieldinfo->getSaveDataBase()=='no'))
    			continue;
            //附件、图片、签到字段不显示
            if($fieldinfo&&($tablename=='ld_attachments'||$fieldinfo->getUIType()==69||$fieldinfo->getUIType()==222))
    			continue;
            $typeofdata=$fieldinfo->getTypeOfData();
    		$types=explode('~',$typeofdata);
            $typeofname=$types[0];
            $fieldlabel=$fieldinfo->getFieldLabelKey();
    		if(!empty($columnname)){
    			if($is_module == 'ServiceCharge')$is_module = 'Accounts';
    			$templatearr[$tablename.':'.$columnname.':'.$fieldname.':'.$is_module.'_fieldlabel:'.$typeofname]=getTranstab($module).'_'.$fieldlabel;
    		}
        }
        return $templatearr;
    }
    
    //获取对应的数据信息
    public function getmoduleDatainfo(){
        global $adb,$global_picklist_colors_byvalue,$current_user;
        if(empty($this->fromrecordid)){
            return [];
        }
        $this->getmodulemapFieldInfo();
        if(empty($this->mapfieldinfo)){
            return [];
        }
        $module = $this->module;
        $frommodule = $this->frommodule;
        $fromrecordid= $this->fromrecordid;
        crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
        $picklistobj = new cls_PickList_Ori();
        
        
        $selectcolumn_arr = $this->getSelectColumn($this->mapfieldinfo);
        $table_index=$this->focus->table_index;
        $table_name=$this->focus->table_name;
        
        $fromfocus = CRMEntity::getInstance($frommodule);
        $from_table_index=$fromfocus->table_index;
        $from_table_name=$fromfocus->table_name;
        $joinsql = $this->joinsql ;
        
        $relationInfo=$this->getRelationInfo();
        if(!empty($relationInfo['related_coltable'])){
            $wheresql = ' and ld_'.$relationInfo['related_coltable'].'= '.$fromrecordid.' ';
        }
        $nosmownerid = 'no';
        if (!array_key_exists('assigned_user_id',$selectcolumn_arr)){
            $selectcolumn_arr['assigned_user_id'] = $this->focus->table_name.'.'.$this->focus->fieldobj->getFieldInfoBykeyValue('fieldname','assigned_user_id','columnname');
            $nosmownerid = 'yes';
        }

        $sql = "select $table_name.$table_index,".implode(',',$selectcolumn_arr)." from $table_name  $joinsql";
        $sql.="INNER JOIN( select $table_name.$table_index from $table_name  $joinsql WHERE $table_name.deleted = 0
	           $wheresql GROUP BY $table_name.$table_index) as temp 
                    on temp.$table_index=$table_name.$table_index WHERE $table_name.deleted = 0
	           $wheresql GROUP BY $table_name.$table_index order by $table_name.$table_index desc ";
        
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        $moduledata = array();
        crm_load_class_file('Cls_FieldShowValue', 'modules/Users');

        $customView = CustomView::getInstance($module);
        $queryGenerator = QueryGenerator::getInstance($module, $current_user, $customView);
        $smownerSearchSql = $queryGenerator->getSmOwnerSearchSql;
        $record_sql = "select distinct $table_name.$table_index from $table_name  $joinsql WHERE $table_name.deleted = 0
	           $wheresql $smownerSearchSql";
        $record_result = $adb->pquery($record_sql,array());
        $record_num_rows = $adb->num_rows($record_result);
        if ($record_num_rows > 0){
            for ($i=0;$i<$record_num_rows;$i++){
                $record = $adb->query_result($record_result,$i,$table_index);
                $record_arr[$record] = $record;
            }
        }

        if($rows>0){
            for($i=0;$i<$rows;$i++){
                $data = array();
                $indexvalue = $adb->query_result($result,$i,$table_index);
                $smownerids= getCurSmOwnerSearchScope($this->module);
                $smownerids_arr = $smownerids['UserCombo'];
                $accountallview = $current_user->accountallview;
                $isadmin = is_admin($current_user);
                $cls_fieldshowvalueobj = new Cls_FieldShowValue($module,$indexvalue,$table_index);
                if (!$isadmin && $accountallview == 0 && !array_key_exists($indexvalue,$record_arr) ){
                    $data['permitted_msg']=getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE');
                }else{
                    $data['permitted_msg'] = '';
                }

                foreach( $selectcolumn_arr as $tmpfieldname=>$tmpstr)
                {
                    
                    $fieldname = $tmpfieldname;
                    $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                    if(empty($fieldinfo)){
                        continue;
                    }
                    $columnname = $fieldinfo->getColumnName();
                    $columnnamevalue = $adb->query_result($result,$i,$columnname);
                    if(empty($columnnamevalue) &&$columnnamevalue!=0){
                        $columnnamevalue = '';
                    }
                    $cls_fieldshowvalueobj->resetfieldname($fieldname);
                    $showfieldvalue = $cls_fieldshowvalueobj->getShowfieldValue();
                    //$tdinnerhtml = $cls_fieldshowvalueobj->getListFieldValue();
                    $value = $showfieldvalue['value'];
                    $uitype = $fieldinfo->getUIType();
                    //ljj 20240605 XUQIU20240306-01 联系人图谱中显示的字段增加显示颜色，根据字段属性中的颜色或字段下拉选项颜色显示（史星磊）
                    if (!empty($value) && $uitype != 301){
                        if ($uitype == 15){//下拉框
                            $color = $global_picklist_colors_byvalue[$fieldname][$value];
                            if (empty($color)){
                                $picklistobj->getPickListValues($fieldname,$fieldinfo,'','');
                                $color = $global_picklist_colors_byvalue[$fieldname][$value];
                            }
                            $data[$columnname.'_style'] = 'color:'.$color.';';
                        }else{
                            $color = $fieldinfo->getFieldValueColor();
                            if (!empty($color)){
                                $data[$columnname.'_style'] = 'color:'.$color.';';
                            }
                        }
                    }elseif($uitype == 301){//标签
                        crm_load_class_file('cls_moduledata_tag','include/utils');
                        $cls_moduledata_tag = new cls_moduledata_tag($module,$indexvalue);
                        $moduledata_tag = $cls_moduledata_tag->getModuledataTagForUser();
                        if(!empty($moduledata_tag)) {
                            if ($this->sourcefromPC == 'yes'){
                                $value = '<span class="module_list_tagger_span" style="flex-wrap:wrap;" name="module_list_tagger_span_' . $indexvalue . '">';
                            }else{
                                $value = '<span tag="label" style="white-space: nowrap;font-size:12px;">'.$fieldinfo->getFieldLabelKey().':</span><span class="module_list_tagger_span" name="module_list_tagger_span_' . $indexvalue . '">';
                            }
                            foreach ($moduledata_tag as $key => $tag_info) {
                                if ($this->sourcefromPC == 'yes'){
                                    $value .= '<span  class="module-map-tagger-fm-button ' . $tag_info['tag_type'] . '" tag_id="' . $key . '">' . $tag_info['tag'] . '</span>';
                                }else{
                                    if ($tag_info['tag_type'] == 'personal'){
                                        $tag_style = 'color:#68DA94;background: rgba(104, 218, 148, 0.2);margin-right:5px;';
                                    }else{
                                        $tag_style = 'color: #EB8473;background: rgba(235, 132, 115, 0.2);margin-right:5px;';
                                    }
                                    $value .= '<span style="'.$tag_style.'" tag_id="' . $key . '">' . $tag_info['tag'] . '</span>';
                                }

                            }
                            $value .= '</span>';
                        } else{
                            if ($this->sourcefromPC == 'yes'){
                                $value ='<span tag="no">'.getFixedLabel('VALUENONE').'</span>';
                            }else{
                                $value ='<span>'.$fieldinfo->getFieldLabelKey().':</span><span>'.getFixedLabel('VALUENONE').'</span>';
                            }
                        }
                    }else{
                        $value = getFixedLabel('VALUENONE');
                    }
                    $data[$columnname] = $value;

                    //$data[$columnname] = $tdinnerhtml;
                }
                $moduledata[$indexvalue]=$data;
            }
        }
        return $moduledata;
    }
    
    
    //
    public function getSelectColumn($mapfieldinfo)
    {
        $focus = $this->focus;
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        $selectcolumn_arr = array();
        $leftjointable = array();
        foreach($mapfieldinfo as $index=>$info)
        {
            $tablename = $info['tablename'];
            if(in_array($tablename,$focus->tab_name)&&$tablename!=$focus->table_name){
                $leftjointable[$tablename] = " left join ".$tablename." on $tablename.$table_index = $table_name.$table_index ";
            }
            $columnname = $info['columnname'];
            $fieldname = $info['fieldname'];
            $selectcolumn_arr[$fieldname]=$tablename.'.'.$columnname;
        }
        
        //超链接字段
        $entityfield = getEntityField($this->module);
        $hreffieldfieldname = $entityfield['fieldname'];
        $hreffieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$hreffieldfieldname);
        if(!empty($hreffieldinfo)){
            $hreffieldlabel = $hreffieldinfo->getFieldLabel();
            $hreffieldcolumnname = $hreffieldinfo->getColumnName();
            $hreffieldtablename = $hreffieldinfo->getTableName();
        }
        if(!array_key_exists($hreffieldfieldname,$selectcolumn_arr)){
            $selectcolumn_arr[$hreffieldfieldname]=$hreffieldtablename.'.'.$hreffieldcolumnname;
        }
        
        $this->joinsql = '';
        foreach($leftjointable as $tmptablename =>$tmpsql){
            $this->joinsql .= $tmpsql;
        }
        
        
        if($this->module == 'Contacts'){
            
            $relationInfo=$this->getRelationInfo();
            if($relationInfo['related_coltable'] != '')
            {
                if(file_exists(globalStatic::$root_directory.'include/ListView/RelatedListView/DataCustomView/cls_'.$relationInfo['type'].'.php'))
                {
                    crm_load_class_file('cls_Parent_datacategory_Sql','include/ListView/RelatedListView/DataCustomView');
                    $classname='cls_'.$relationInfo['type'];
                    crm_load_class_file($classname,'include/ListView/RelatedListView/DataCustomView');
                    $obj=new $classname($this->frommodule,$relationInfo,$this->fromrecordid);
                    $obj->AddWhereFieldTable();
                    $whereFieldTables = $obj->querygeneratorobj->whereFieldTables;
                    $whereFieldTableJoinType = $obj->querygeneratorobj->whereFieldTableJoinType;
                    foreach($whereFieldTables as $wheretable=>$leftjoin)
                      {
                        
                         if($wheretable!=$this->focus->table_name&&!empty($wheretable))
                         {
                            $this->page_left_join.=' left join '.$leftjoin;
                            if(array_key_exists($wheretable,$whereFieldTableJoinType))
                            {
                                $joinsql.=$whereFieldTableJoinType[$wheretable].$leftjoin;
                            }
                            else
                            {   
                                $joinsql.=' left join   '.$leftjoin;
                                
                            }
                         }
                      }
                    $this->joinsql  .= $joinsql;
                    
                }
            }
        }
        return $selectcolumn_arr;
    }
    
    public function getCreatehtml()
    {
        if(isPermitted($module,'Create')){
            $relationInfo = $this->getRelationInfo();
            $frommodule = $this->frommodule;
            $module = $this->module;
            $record = $this->fromrecordid;
            crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
            $cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($frommodule,$relationInfo,$record);
            $target_url = 'index.php?module=' . $module . '&action=EditView&return_module=' . $mdoule.
                        '&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=' . $frommodule . '&fromid=' . $record . '&parent_id=' . $record . $cls_getRelatedInfoobj->RelatedCreateParams();
            $button = '<a title="' . getFixedLabel('CREATE') . '" style="text-decoration: none;"
    						href="javascript:void(0);" onclick="related_add_url(\'' . $target_url . '\',\'' . $frommodule . '\',\'' . $module . '\',\'' . $record . '\')">
    						<b class="icon-homeimg icon-plus"></b><span style="padding: 0 5px;color:#666;">' . getFixedLabel('CREATE') . '</span></a>';
        }
        return $button;
    }
    // ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
    //获取lockstate
    public function getLockState($record,$module,$frommodule)
    {
        global $adb;
        $sql = 'select distinct lockstate from ld_moduledatamap where fromrecordid = ? and modulename=? and frommodule=? and moduleindexid>0';
        $result = $adb->pquery($sql,array($record,$module,$frommodule));
        if($adb->num_rows($result)>0){
            $lockstate=$adb->query_result($result,0,'lockstate');
        }else{
            $lockstate='-1';
        }
        $this->lockstate=$lockstate;
        return $lockstate;
    }


}


?>