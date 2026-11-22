<?php
class cls_QrcodeField
{
	public function __construct(){
	   global $adb;
       $this->adb = $adb;
       $this->productEntry_mode = array('CreateView' => 'create', 'DetailView' => 'details', 'EditView' => 'edit');
       $this->outputProductFieldArr = array('productname','productsheet','sequence_no','quantity','taxprice','tax_amount');
       $this->record='';
       $this->modulename ='';
       $this->qrcodetemplateid='';
	}

	//获取验证二维码字段权限
	public function qrcode_effctive($wechatuserid){
        $qrcodeid = $_REQUEST['qrcodeid'];
        $sql = "SELECT ld_qrcode_template.template_content,ld_qrcode_creation.modifiedtime,ld_qrcode_creation.modifiedby,ld_qrcode_creation.modulename,ld_qrcode_creation.token,
                ld_qrcode_creation.record,ld_qrcode_template.qrcodetemplateid,ld_tranlabel.fieldlabel FROM ld_qrcode_creation
                INNER JOIN ld_qrcode_template ON ld_qrcode_template.qrcodetemplateid = ld_qrcode_creation.qrcodetemplateid
                INNER JOIN ld_field ON ld_field.fieldid = ld_qrcode_template.fieldid
                INNER JOIN ld_tranlabel on ld_tranlabel.relateid = ld_field.fieldid and ld_field.tabid = ld_tranlabel.tabid
                WHERE ld_field.uitype = 1503 and ld_tranlabel.languagetype='zh' and ld_qrcode_creation.qrcodebasicid = ?";
        $result = $this->adb->pquery($sql,array($qrcodeid));
        $datetime_now = date('Y-m-d H:i:s');
        if($this->adb->num_rows($result)>0){
            $this->modulename = $this->adb->query_result($result,0,'modulename');
            $this->record = $this->adb->query_result($result,0,'record');
            $fieldlabel = $this->adb->query_result($result,0,'fieldlabel');
            $this->qrcodetemplateid = $this->adb->query_result($result,0,'qrcodetemplateid');
            $modifiedtime = $this->adb->query_result($result,0,'modifiedtime');
            $userid = $this->adb->query_result($result,0,'modifiedby');
            $token = $this->adb->query_result($result,0,'token');
            $template_content_json = $this->adb->query_result($result,0,'template_content');
            $template_content = ldcrm_json_decode(html_entity_decode($template_content_json));
            $duration = $template_content['duration'];
            $endatetime = $template_content['endatetime'];
            $limit = $template_content['limit'];
        }else{
            return array(-1,array(),'二维码已失效');
        }
        
        if($duration == 'endate'){
            //截至日期
            $interval = strtotime($endatetime)-strtotime($datetime_now);
            if($interval < 0){
                return array(-1,array(),'二维码已过期');
            }
        }else if($duration == 'permanently' || $duration == ''){
            //永久有效
        }else{
            //有效天数
            $interval = strtotime($datetime_now)-strtotime($modifiedtime);
            $days = $interval/3600/24;
            if($days > $duration){
                return array(-1,array(),'二维码已过期');
            }
        }
        $type = 'view';
        if($limit != 'nolimit' && $limit > 0){
            $sql = "SELECT DISTINCT(wechatuserid) from ld_qrcode_operatelog 
            where qrcodebasicid =? and type = ? and wechatuserid <> ? ";
            $result = $this->adb->pquery($sql,array($qrcodeid,$type,$wechatuserid));
            $num_rows = $this->adb->num_rows($result);
            if($num_rows >= $limit){
                return array(-1,array(),'二维码查看人数已达上限');
            }
        }
        
        $sql = 'insert into ld_qrcode_operatelog(qrcodebasicid,wechatuserid,viewtime,type,crmid) values(?,?,?,?,?)';
        $this->adb->pquery($sql,array($qrcodeid,$wechatuserid,$datetime_now,$type,$this->record));
        
        $sql = "select para_one,para_two from ld_wx_config where name=?";
        $result = $this->adb->pquery($sql,array('wechat_miniprogram_setting'));
        $mini_basename = $this->adb->query_result($result,0,'para_one');
        $crm_url = $this->adb->query_result($result,0,'para_two');
        $userid = 1;
        
        $qrocde_data =array('templateid'=>$this->qrcodetemplateid,
                            'modulename'=>$this->modulename,
                            'record'=>$this->record,
                            'label'=>$fieldlabel,
                            'userid'=>$userid,
                            'mini_basename'=>$mini_basename,
                            'url'=>$crm_url,
                            'token'=>$token);

        return $this->getAllQrcodeField($qrocde_data);
    }
    
    public function getAllQrcodeField($qrocde_data){
        $modulename = $qrocde_data['modulename'];
        $record = $qrocde_data['record'];
        $qrcodetemplateid = $qrocde_data['templateid'];
        $qrcode_field_arr = $this->getQrcode_FieldsDetail($qrcodetemplateid);
        //获取对应模块移动端对象
        require_once(globalStatic::$root_directory.'/WeiXinApp/qrcodepro/cls_FormCode_Detailview.php');
        require_once(globalStatic::$root_directory.'/WeiXinApp/modules/Approve/cls_Approve/ApproveWX.php');
        $mobj = new cls_FormCode_Detailview($modulename);
        $mobj->focus->retrieve_entity_info($record,$modulename);
        $mobj->focus->id = $record;
        $mobj->qrcode_field_arr = $qrcode_field_arr;
        
        $act_data = $mobj->getBlockFields_Formcode($modulename, 'edit_view', 'edit', $mobj->focus->column_fields);
        //审批状态:未提交、已驳回、已拒绝
        $approve_arr = array(constant('D_A_S_UNAPPROVED'),constant('D_A_S_REJECTED'),constant('D_A_S_DISMISSED'));
        //获取单据审批状态
        if(empty($mobj->focus->column_fields['approvestatus']))
        {
            $sql="select approvestatus from ".$mobj->focus->table_name.' where '.$mobj->focus->table_index."=?";
            $result=$this->adb->pquery($sql,array($record));
            if($this->adb->num_rows($result)>0)
                $mobj->focus->column_fields['approvestatus']=$this->adb->query_result($result,0,'approvestatus');
        }
        if(in_array($mobj->focus->column_fields['approvestatus'],$approve_arr)){
            $approve = false;
        }else{
            $approve = true;
        }
        $allow_save = 'no';
        
        foreach($act_data as $block_key => $blockinfo){
            $tmp_fieldinfo_arr = $blockinfo['fieldinfo'];
            foreach($tmp_fieldinfo_arr as $field_key => $fieldinfo){
                $columnname = $fieldinfo['columnname'];
                $tmp_field = $qrcode_field_arr[$columnname];
                if(!array_key_exists($columnname,$qrcode_field_arr)||$tmp_field['view']=='no'){
                    unset($act_data[$block_key]['fieldinfo'][$field_key]);
                    continue;
                }
                $act_data[$block_key]['fieldinfo'][$field_key]['fieldlabel'] = $tmp_field['label'];
                $is_empty = true;
                if($fieldinfo['value']!="" || $fieldinfo['text']!=""){
                    $is_empty = false;
                }
                if($fieldinfo['bigtype'] == 'date' || $fieldinfo['bigtype'] == 'datetime'){
                    if($fieldinfo['value_name']!="" || $fieldinfo['text']!=""){
                        $is_empty = false;
                    }else{
                        $is_empty = true;
                    }
                }
                
                if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                    $readonly = 'yes'; 
                }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                    $readonly = 'yes'; 
                }else if($tmp_field['input']=='no'){
                    $readonly = 'yes'; 
                }else{
                    $readonly = 'no';
                    $allow_save = 'yes';
                }
                if($readonly == 'yes'){
                    $act_data[$block_key]['fieldinfo'][$field_key]['readonly'] = $readonly;
                }else{
                    unset($act_data[$block_key]['fieldinfo'][$field_key]['readonly']);
                }
                
                //判断字段是否必填
                if($readonly!='yes'&&$tmp_field['require']=='yes'){
                    $fieldtype = 'M';
                }else{
                    $fieldtype = 'O';
                }
                $act_data[$block_key]['fieldinfo'][$field_key]['fieldtype'] = $fieldtype;
            }
            if(sizeof($act_data[$block_key]['fieldinfo'])==0){
                unset($act_data[$block_key]);
            }else{
                $act_data[$block_key]['fieldinfo'] = array_values($act_data[$block_key]['fieldinfo']);
            }
        }
        if(sizeof($act_data)>0){
            $act_data = array_values($act_data);
        }
        $this->approve = $approve;
        unset($qrocde_data['templateid']);
        $qrocde_data['data'] = $act_data;
        $qrocde_data['allow_save'] = $allow_save;
          //表单增加单据附录字段
        $qrocde_data['entry'] = $this->getentry();
        if($qrocde_data['entry']['allow_save'] == 'yes'){
            $qrocde_data['allow_save'] = 'yes';
        }
        
        return array(1,$qrocde_data,'success');
    }
    
    public function getQrcode_FieldsDetail($qrcodetemplateid,$fieldidtype="normal"){
        $qrcode_field_arr = array();
        $qrcode_viewfield_arr = array();
        if($fieldidtype == 'detailed'){
            $frommodulename =$this->modulename;
            if(get_file_address($frommodulename,"ProductDetails")){
                $sql = 'select ld_qrcode_fieldsdetail.*,ld_producttoolfield.columnname from ld_qrcode_fieldsdetail 
                    INNER JOIN ld_producttoolfield on ld_qrcode_fieldsdetail.fieldid = ld_producttoolfield.producttoolfieldid 
                    where qrcodetemplateid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype = ? ';
                $result = $this->adb->pquery($sql,array($qrcodetemplateid,'yes',$fieldidtype));
            }else if(get_file_address($frommodulename,$frommodulename."DetailFieldsHtml")){
                $sql = 'select ld_qrcode_fieldsdetail.*,ld_tabdetailfield.columnname from ld_qrcode_fieldsdetail 
                    INNER JOIN ld_tabdetailfield on ld_qrcode_fieldsdetail.fieldid = ld_tabdetailfield.tabdetailfieldid 
                    where qrcodetemplateid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype = ? ';
                $result = $this->adb->pquery($sql,array($qrcodetemplateid,'yes',$fieldidtype));
            } 
        }else{
            $sql = 'select ld_qrcode_fieldsdetail.*,ld_field.columnname from ld_qrcode_fieldsdetail 
                INNER JOIN ld_field on ld_qrcode_fieldsdetail.fieldid = ld_field.fieldid 
                where qrcodetemplateid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype = ? ';
            $result = $this->adb->pquery($sql,array($qrcodetemplateid,'yes',$fieldidtype));
        }
        $num_rows = $this->adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $tmp_columnname = $this->adb->query_result($result,$i,'columnname');
                $view = $this->adb->query_result($result,$i,'viewpermit');
                $qrcode_viewfield_arr[] = $tmp_columnname;
                $qrcode_field_arr[$tmp_columnname] = array('label'=>$this->adb->query_result($result,$i,'qrcode_fieldlabel'),
                                                        'view'=>$this->adb->query_result($result,$i,'viewpermit'),
                                                        'input'=>$this->adb->query_result($result,$i,'editpermit'),
                                                        'edit'=>$this->adb->query_result($result,$i,'editcontentpermit'),
                                                        'approve'=>$this->adb->query_result($result,$i,'approvepermit'),
                                                        'require'=>$this->adb->query_result($result,$i,'requirecontent')
                                                        );
            }
            //筛选不可见字段
            $_REQUEST['qrcode_viewfield'] = $qrcode_viewfield_arr;
        }
        return $qrcode_field_arr;
    }
    //获取分录字段信息数组
    public function getentry(){
        global $adb;
        $frommodulename =$this->modulename;
        $detail_arr = array();
        //获取模块当前保存的已显示分录字段
        $sql ="select fieldid from ld_qrcode_fieldsdetail where viewpermit ='yes' and qrcodetemplateid =? ";
        $resulty=$adb->pquery($sql,array($this->qrcodetemplateid));
        $num_rows = $adb->num_rows($resulty);
        if($num_rows>=1){
            for($i = 0; $i < $num_rows; $i++){
                $fieldid_detail=$adb->query_result($resulty,$i,'fieldid');
                $detail_arr[$i]=$fieldid_detail;
            }
        }
        //获取设置的分录二维码字段信息
        $allow_save = 'no';
        $approve = $this->approve;
        $qrcode_detailfield_arr = $this->getQrcode_FieldsDetail($this->qrcodetemplateid,'detailed');
        
        $isshow_arr=array();
        $focus = CRMEntity::getInstance($frommodulename);
        if(get_file_address($frommodulename,"ProductDetails")||get_file_address($frommodulename,$frommodulename."DetailFieldsHtml")){
            $detailfieldobj = $focus->detailfieldobj;
            $detail_module_field = $detailfieldobj->getModuleFields();
            //获取当前模块的分录字段的文本标签（中/英）
            foreach($detail_module_field as $detail_fieldinfo){
                $detail_columnname=$detail_fieldinfo->getColumnName();
                $detail_fieldlabel = $detail_fieldinfo->getFieldLabel();
                if(empty($detail_fieldinfo)||!$detail_fieldinfo){
                    continue;
                }
                if(get_file_address($frommodulename,"ProductDetails")){
                    $detail_fieldid = $detail_fieldinfo->getProductToolFieldid();
                }else{
                    $detail_fieldid = $detail_fieldinfo->getTabDetailFieldid();
                }
                if($detail_columnname=='total'){
                    $totallabel=$detail_fieldinfo->getFieldLabel();
                }
                //剔除未允许查看的字段
                if(!in_array($detail_fieldid,$detail_arr)){
                    continue;
                }
                $isshow_arr[$detail_columnname] = $detail_fieldlabel;
            }
            //判断当前模块是否含有产品分录
            $detail_entry=array();
            if(get_file_address($frommodulename,"ProductDetails")){
                crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
                $detailObj = new cls_ProductDetailUitype_PageRecordValueWX($frommodulename,'details',$this->record,'Products',$this->actionname);
                $detailObj->qrcodefield="yes";
                $entry = $detailObj->set_entrydetail('DetailView',$this->outputProductFieldArr,null);
                 //剔除掉未允许查看的字段信息
                foreach($entry['entry']['list'] as $tmpkey=>$tmpvalue){
                    foreach ($tmpvalue['list'] as $tmp_key=>$tmp_val){
                        if(!in_array($tmp_val['k'],$isshow_arr)){
                            unset($entry['entry']['list'][$tmpkey]['list'][$tmp_key]);
                        }else{
                            $detail_columnname = array_search($tmp_val['k'],$isshow_arr);            
                            $tmp_field = $qrcode_detailfield_arr[$detail_columnname];
                            $is_empty = true;
                            if(!empty($tmp_val['v']))$is_empty = false;
                            
                            if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                                $readonly = 'yes'; 
                            }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                                $readonly = 'yes'; 
                            }else if($tmp_field['input']=='no'){
                                $readonly = 'yes'; 
                            }else{
                                $allow_save = 'yes';
                            }
                        }
                    } 
                    $entry['entry']['list'][$tmpkey]['list'] = array_values($entry['entry']['list'][$tmpkey]['list']);
                }
               
              $detail_entry['list'] = $entry['entry']['list'];
              if(in_array($totallabel,$isshow_arr)){ 
                
                   $detail_entry['p_total']= $entry['entry']['p_total'];
              }
              
    
            }else if(get_file_address($frommodulename,$frommodulename."DetailFieldsHtml")){
                crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
                $detailObj = new cls_TabDetail_PageRecordValueWX($frommodulename,'edit',$this->record,'',$this->actionname);
                $detailObj->qrcodefield="yes";
                $entry = $detailObj->set_entrydetail('DetailView');
                 //剔除掉未允许查看的字段信息
                foreach($entry['list'] as $tmpkey=>$tmpvalue){
                    foreach ($tmpvalue['list'] as $tmp_key=>$tmp_val){
                        if(!in_array($tmp_val['k'],$isshow_arr)){
                            unset($entry['list'][$tmpkey]['list'][$tmp_key]);
                        }else{
                            $detail_columnname = array_search($tmp_val['k'],$isshow_arr);            
                            $tmp_field = $qrcode_detailfield_arr[$detail_columnname];
                            $is_empty = true;
                            if(!empty($tmp_val['v']))$is_empty = false;
                            
                            if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                                $readonly = 'yes'; 
                            }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                                $readonly = 'yes'; 
                            }else if($tmp_field['input']=='no'){
                                $readonly = 'yes'; 
                            }else{
                                $allow_save = 'yes';
                            }
                        }
                    }
                    $entry['list'][$tmpkey]['list'] = array_values($entry['list'][$tmpkey]['list']);
                }
                $detail_entry['list'] = $entry['list'];
                if(in_array($totallabel,$isshow_arr)){  
                   $detail_entry['p_total']= $entry['p_total'];
                }
            }
            $detail_entry['allow_save'] = $allow_save;
           
            return($detail_entry );
        }else{
            return false;
        }
    }


    //ls 20221231  XUQIU1000922：表单码-分录可编辑
    //表单码编辑页面返回值
    public function qrcodeEditReturn($qrcodeid,$outputinfo,$focus,$module){
        global $adb;
        //1、获取qrcodetemplateid
        $sql = "SELECT ld_qrcode_template.template_content,ld_qrcode_creation.modifiedtime,ld_qrcode_creation.modifiedby,ld_qrcode_creation.modulename,ld_qrcode_creation.token,
                ld_qrcode_creation.record,ld_qrcode_template.qrcodetemplateid,ld_tranlabel.fieldlabel FROM ld_qrcode_creation
                INNER JOIN ld_qrcode_template ON ld_qrcode_template.qrcodetemplateid = ld_qrcode_creation.qrcodetemplateid
                INNER JOIN ld_field ON ld_field.fieldid = ld_qrcode_template.fieldid
                INNER JOIN ld_tranlabel on ld_tranlabel.relateid = ld_field.fieldid and ld_field.tabid = ld_tranlabel.tabid
                WHERE ld_field.uitype = 1503 and ld_tranlabel.languagetype='zh' and ld_qrcode_creation.qrcodebasicid = ?";
        $result = $adb->pquery($sql,array($qrcodeid));
        if($adb->num_rows($result)>0){
            $qrcodetemplateid = $adb->query_result($result,0,'qrcodetemplateid');
        }else{
            ConvertTojsonString(-1, array(),'二维码已失效');
        }

        //获取单据审批状态:未提交、已驳回、已拒绝
        $approve_arr = array(constant('D_A_S_UNAPPROVED'),constant('D_A_S_REJECTED'),constant('D_A_S_DISMISSED'));
        //获取单据审批状态
        if(empty($focus->column_fields['approvestatus']))
        {
            $sql="select approvestatus from ".$focus->table_name.' where '.$focus->table_index."=?";
            $result=$adb->pquery($sql,array($focus->id));
            if($adb->num_rows($result)>0)
                $focus->column_fields['approvestatus']=$adb->query_result($result,0,'approvestatus');
        }
        if(in_array($focus->column_fields['approvestatus'],$approve_arr)){
            $approve = false;
        }else{
            $approve = true;
        }

        //2、获取单据头所有字段
        if($module == 'Users'){
            //duan 20221012 因为登陆时生成了用户模块field对象的缓存，所以重新获取一次更新语言类型
            $fieldobj = new Field($module, $adb);
        }else{
            $fieldobj = Field::getInstance($module, $adb);
        }
        $moduleFields = $fieldobj->getModuleFields();

        //2.1 获取表单码设置的单据头字段信息（隐藏，必填等）
        $qrcode_field_arr = $this->getQrcode_FieldsDetail($qrcodetemplateid);

        //参考布局规则 cls_DetailViewWX.php
        $hide_source_list = 'yes';//源单类型字段比较特殊，它不在$moduleFields里，因此下面的循环处理不到它，需要再次循环处理。
        $blockinfos = $outputinfo['list'];
        $tmpblockinfos = $blockinfos;
        $tmpblockindex = 0;
        foreach ($tmpblockinfos as $blockindex => $blockfieldinfo) {
            $tmpfieldindex = 0;
            $isdeleteblock = 'no';
            foreach ($blockfieldinfo['fieldinfo'] as $fieldindex => $tmpfieldinfo) {
                $fieldinfo = $moduleFields[$tmpfieldinfo['fieldname']];
                //editor:gyq_20190820  reason:选择源单字段前，特殊插入的源单类型字段，增加特殊标识tempfield=1
                if (isset($tmpfieldinfo['tempfield'])) {//源单类型  没有columnname,fieldname为 selectsourcename
                    $tmpfieldindex++;
                    continue;
                }

                if (!$fieldinfo) {
                    $tmpfieldindex++;
                    continue;
                }
                $tmpcolumnname = $fieldinfo->getColumnName();
                $tmpfieldname = $fieldinfo->getFieldName();

                if($fieldinfo->getBigType() == 'selectsource'){
                    $tmp_selectsourcefield = $tmpfieldname;
                }

                if (array_key_exists($tmpcolumnname,$qrcode_field_arr)) {
                    if ($tmpcolumnname=='source_list' || $fieldinfo->getBigType() == 'selectsource') {//选择源单隐藏，源单类型也应该隐藏
                        $hide_source_list = 'no';
                    }

                    $tmp_field = $qrcode_field_arr[$tmpcolumnname];
                    $is_empty = true;

                    if($tmpfieldinfo['value']!="" || $tmpfieldinfo['text']!=""){
                        $is_empty = false;
                    }
                    if($tmpfieldinfo['bigtype'] == 'date' || $tmpfieldinfo['bigtype'] == 'datetime'){
                        if($tmpfieldinfo['value_name']!="" || $tmpfieldinfo['text']!=""){
                            $is_empty = false;
                        }else{
                            $is_empty = true;
                        }
                    }

                    if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                        $readonly = 'yes';
                    }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                        $readonly = 'yes';
                    }else if($tmp_field['input']=='no'){
                        $readonly = 'yes';
                    }else{
                        $readonly = 'no';
                    }
                    $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['readonly'] = $readonly;

                    //判断字段是否必填
                    if($readonly!='yes'&&$tmp_field['require']=='yes'){
                        $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['fieldtype'] = "M";
                    }else{
                        $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['fieldtype'] = 'O';
                    }
                    //只读的下拉框字段，应该以span显示，否则获取不到值
                    if($readonly=='yes'&&$blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['uitype'] == 15){
                        $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['type'] = 1;
                    }
                }else{
                    //隐藏字段
                    array_splice($blockinfos[$tmpblockindex]['fieldinfo'], $tmpfieldindex, 1);
                    if (sizeof($blockinfos[$tmpblockindex]['fieldinfo']) <= 0) {

                        array_splice($blockinfos, $tmpblockindex, 1);
                        $isdeleteblock = 'yes';
                    }
                    continue;
                }

                $tmpfieldindex++;
            }
            if ($isdeleteblock == 'no')//区块是0,1,2,3排序的，所以有次判断
                $tmpblockindex++;
        }

        if ($hide_source_list == 'yes') {//选择源单隐藏，源单类型也应该隐藏（那个布局规则实际上源单隐藏，源单类型也应该隐藏，移动端特殊是两个字段）
            foreach ($blockinfos as $blockindex => $blockfieldinfo) {
                foreach ($blockfieldinfo['fieldinfo'] as $fieldindex => $tmpfieldinfo) {
                    $tmp_fieldname = $tmpfieldinfo['fieldname'];
                    if ($tmp_fieldname == 'selectsourcename' || (!empty($tmp_selectsourcefield) && $tmp_fieldname == $tmp_selectsourcefield.'_type')) {
                        unset($blockinfos[$blockindex]['fieldinfo'][$fieldindex]);
                        $blockinfos[$blockindex]['fieldinfo'] = array_values($blockinfos[$blockindex]['fieldinfo']);
                        break 2;
                    }
                }
            }
        }

        $outputinfo['list'] = $blockinfos;


        //当前模块是否有分录
        if(get_file_address($module,"ProductDetails")||get_file_address($module,$module."DetailFieldsHtml")){
            //3、获取模块当前保存的已显示分录字段 及设置的信息
            $detail_arr = array();
            if(get_file_address($module,"ProductDetails")){
                $sql = 'select ld_qrcode_fieldsdetail.*,ld_producttoolfield.columnname from ld_qrcode_fieldsdetail 
                left JOIN ld_producttoolfield on ld_qrcode_fieldsdetail.fieldid = ld_producttoolfield.producttoolfieldid 
                where qrcodetemplateid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype ="detailed" ';
            }
            else if(get_file_address($module,$module."DetailFieldsHtml")){
                $sql = 'select ld_qrcode_fieldsdetail.*,ld_tabdetailfield.columnname from ld_qrcode_fieldsdetail 
                left JOIN ld_tabdetailfield on ld_qrcode_fieldsdetail.fieldid = ld_tabdetailfield.tabdetailfieldid 
                where qrcodetemplateid = ? and ld_qrcode_fieldsdetail.viewpermit = ? and ld_qrcode_fieldsdetail.fieldidtype ="detailed" ';
            }

            $resulty = $adb->pquery($sql,array($qrcodetemplateid,'yes'));
            $num_rows = $adb->num_rows($resulty);
            if($num_rows>0){
                for($i=0;$i<$num_rows;$i++){
                    $tmp_columnname = $adb->query_result($resulty,$i,'columnname');
                    $detail_arr[$tmp_columnname] = array('label'=>$adb->query_result($resulty,$i,'qrcode_fieldlabel'),
                        'view'=>$adb->query_result($resulty,$i,'viewpermit'),
                        'input'=>$adb->query_result($resulty,$i,'editpermit'),
                        'edit'=>$adb->query_result($resulty,$i,'editcontentpermit'),
                        'approve'=>$adb->query_result($resulty,$i,'approvepermit'),
                        'require'=>$adb->query_result($resulty,$i,'requirecontent')
                    );
                }
            }

            //根据表单码设置信息处理返回值
            if(get_file_address($module,"ProductDetails")){
                //剔除掉未允许查看的字段信息
                foreach($outputinfo['entry']['listfield'] as $tmpkey=>$tmpvalue){
                    $columnname = $tmpvalue['columnname'];

                    $tmp_field = $detail_arr[$columnname];
                    if(!array_key_exists($columnname,$detail_arr)){
                        unset($outputinfo['entry']['listfield'][$tmpkey]);
                        //把隐藏的字段从listfield去除并丢到nopresencefield数组里
                        if (!empty($tmpvalue['columnname'])) {
                            $tmp_nopresencefield = array('producttoolfieldid'=>$tmpvalue['producttoolfieldid'], 'columnname'=>$tmpvalue['columnname'], 'defaultvalue'=>$tmpvalue['defaultvalue']);
                            if (empty($outputinfo['entry']['nopresencefield'])) {
                                $outputinfo['entry']['nopresencefield'] = array();
                            }
                            array_push($outputinfo['entry']['nopresencefield'],$tmp_nopresencefield);
                        }
                        continue;
                    }

                    $is_empty = true;
                    foreach($outputinfo['entry']['list'] as $tmp_arr){
                        if($tmp_arr[$columnname]['value']!=""){
                            $is_empty = false;
                        }else{
                            $is_empty = true;
                            break;
                        }
                    }

                    if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                        $edit_permission = '1';
                    }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                        $edit_permission = '1';
                    }else if($tmp_field['input']=='no'){
                        $edit_permission = '1';
                    }else{
                        $edit_permission = '0';
                    }
                    $outputinfo['entry']['listfield'][$tmpkey]['edit_permission'] = $edit_permission;


                    //判断字段是否必填
                    if($edit_permission!='1'&&$tmp_field['require']=='yes'){
                        $fieldtype = 'M';
                    }else{
                        $fieldtype = 'O';
                    }
                    $outputinfo['entry']['listfield'][$tmpkey]['fieldtype'] = $fieldtype;
                }
                $outputinfo['entry']['listfield'] = array_values($outputinfo['entry']['listfield']);//重置索引

            }
            else if(get_file_address($module,$module."DetailFieldsHtml")){
                //剔除掉未允许查看的字段信息
                foreach($outputinfo['entry']['listfield'] as $tmpkey=>$tmpvalue){
                    $columnname = $tmpvalue['columnname'];
                    $tmp_field = $detail_arr[$columnname];
                    if(!array_key_exists($columnname,$detail_arr)){
                        unset($outputinfo['entry']['listfield'][$tmpkey]);
                        //把隐藏的字段从listfield去除并丢到nopresencefield数组里
                        if (!empty($tmpvalue['columnname'])) {
                            $tmp_nopresencefield = array( 'columnname'=>$tmpvalue['columnname'], 'defaultvalue'=>$tmpvalue['defaultvalue']);
                            if (empty($outputinfo['entry']['nopresencefield'])) {
                                $outputinfo['entry']['nopresencefield'] = array();
                            }
                            array_push($outputinfo['entry']['nopresencefield'],$tmp_nopresencefield);

                        }
                        continue;
                    }

                    $is_empty = true;
                    foreach($outputinfo['entry']['list'] as $tmp_arr){
                        if($tmp_arr[$columnname]['value']!=""){
                            $is_empty = false;
                        }else{
                            $is_empty = true;
                            break;
                        }
                    }

                    if($approve && $tmp_field['approve']=='no'){//单据审批时该字段是否允许编辑
                        $edit_permission = '1';
                    }else if(!$is_empty && $tmp_field['edit']=='no'){//字段值不为空时该字段是否允许编辑
                        $edit_permission = '1';
                    }else if($tmp_field['input']=='no'){
                        $edit_permission = '1';
                    }else{
                        $edit_permission = '0';
                    }
                    $outputinfo['entry']['listfield'][$tmpkey]['edit_permission'] = $edit_permission;

                    //判断字段是否必填
                    if($edit_permission!='1'&&$tmp_field['require']=='yes'){
                        $fieldtype = 'M';
                    }else{
                        $fieldtype = 'O';
                    }
                    $outputinfo['entry']['listfield'][$tmpkey]['fieldtype'] = $fieldtype;
                }

                $outputinfo['entry']['listfield'] = array_values($outputinfo['entry']['listfield']);

            }

        }

        //5、去掉审批流程
        unset($outputinfo['approvestep']);

        //6、去掉布局规则
        $outputinfo['fieldrulelist']=array();

        return $outputinfo;
    }
}
?>