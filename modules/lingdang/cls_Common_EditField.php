<?php
/*
 * edit:duan
 * reason:通用方法,用于字段小编辑操作
 * date:20230717
 * */
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
class cls_Common_EditField
{
    public $approveid;
    public $stepid;
    public $record;
    public $module;
    public $db;
    public $user;
    public $withattachment; //字段中是否包含附件字段
    public $usefieldrule;
    public $withselectsource; //是否包含源单字段
    public $filejsondata;//附件信息
    public $EmptyFieldOnly;
    public $triggerfieldname_arr = [];
    public $triggerfieldvalue_arr = [];
    public $MandatoryField;
    public $requestcolumn;
    public $focus;
    public function __construct($module)
    {
        global $adb,$current_user;
        $this->db = $adb;
        $this->module=$module;
        $this->user = $current_user;
        $this->usefieldrule = 'yes';//判断是否需要使用布局规则
        $this->EmptyFieldOnly = 'no'; //值为yes时只显示为空的字段,no时不为空的字段也显示
        $this->triggerfieldname_arr = [];//判断布局规则字段
        $this->triggerfieldvalue_arr = [];//布局规则字段值
    }

    public static function getInstance($module)
    {
        static $static_common_editfieldobj_arr;
        if(is_array($static_common_editfieldobj_arr)&&array_key_exists($module,$static_common_editfieldobj_arr))
        {
            return $static_common_editfieldobj_arr[$module];
        }
        if(!is_array($static_common_editfieldobj_arr))
        {
            $static_common_editfieldobj_arr=[];
        }
        $static_common_editfieldobj_arr[$module]=new cls_Common_EditField($module);
        return $static_common_editfieldobj_arr[$module];
    }
    //判断字段是否需要设置为必填
    public function setMandatoryField($MandatoryField){
        $this->MandatoryField = $MandatoryField;
    }
    //判断是否只显示为空的字段,值为yes时只显示为空的字段,no时不为空的字段也显示
    public function setEmptyFieldOnly($EmptyFieldOnly){
        $this->EmptyFieldOnly = $EmptyFieldOnly;
    }
    //判断字段是否需要判断布局规则
    public function setusefieldrule($usefieldrule){
        $this->usefieldrule = $usefieldrule;
    }

    //根据审批必填字段生成编辑字段的table
    public function CreateFieldHtml($record,$choose_fieldname_arr){

        if(sizeof($choose_fieldname_arr)<=0) {
            return  [];
        }

        $current_user = $this->user;
        $this->record = $record;
        $smarty=new lingdangCRM_Smarty;
        crm_load_class_file('cls_MyCRMcrypt','Register');
        crm_load_class_file('AttachmentUtils','modules/Attachment');
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();

        //非管理员  控制只读字段不在模块的新增和编辑时显示
        if($current_user->is_admin=='off'){
            $profileobj=Profile::getInstance();
            $profilefields= $profileobj->getProfileInfos($current_user->profileid);
            $profilefields=$profilefields['field'];
        }

        $focus = CRMEntity::getInstance($this->module);
        //预先读取字段值，以及必须的参数
        $focus->id = $record;
        $focus->retrieve_entity_info($record,$this->module);
        $this->focus = $focus;
        $sourcemodules=getSourceModule($this->module);
        $this->setColumnValuesFromRequest();
        $focus = $this->focus;
        $smarty->assign('SOURCEMODULE',$sourcemodules);
        $smarty->assign("CURRENT_USERID", $current_user->id);
        $smarty->assign('ISADMIN',$current_user->is_admin);
        $smarty->assign('ID', $record);
        $smarty->assign('MODE','edit');
        $smarty->assign('MODULE',$this->module);
        $version_info = getVersionInfo();
        $smarty->assign('VERSIONTRADE',$version_info['trade']);
        $smarty->assign('VERSIONACCOUNT',$version_info['account']);
        $smarty->assign('VERSION_ACCOUNT',$version_info['account']);
        $smarty->assign("THEME", $theme);
        //币种
        $smarty->assign('CURRENCYID',$focus->column_fields['currency_id']);
        $smarty->assign('CONVERSIONRATE', $focus->column_fields['conversion_rate']);
        $smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
        $smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
        $smarty->assign("MINI_EDIT",1);
        $isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$this->module);
        $smarty->assign('ISALLOW',$isallow);

        $alltriggercolumn = [];
        if($this->usefieldrule == 'yes'){
            //审批必填字段增加布局规则判断
            $fieldrulecolsproperty = $this->getFieldRuleColumn($focus);
            $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏字段
            //$displaycolumns=$fieldrulecolsproperty['displaycolumns'];//不是快速创建的字段，但是符合布局规则的要求
            $requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
            $alltriggercolumn=$fieldrulecolsproperty['alltriggercolumn'];//获取所有的触发字段
        }

        //循环获取所有的字段信息
        $choose_fieldobj_arr = [];
        $choose_fieldinfo_arr = [];
        $col_fields = $focus->column_fields;
        crm_load_class_file('cls_module_advance','modules/Settings');
        foreach ($choose_fieldname_arr as $tmp_fieldname){
            $fieldname = $tmp_fieldname;
            //模块对应的$smarty传值
            cls_module_advance::setSmartyassignBymodule($smarty,$this->module,$fieldname);
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);

            //字段未启用或缺少该字段的查看权限
            if(empty($fieldinfo)){
                continue;
            }
            $columnname = $fieldinfo->getColumnName();
            //如果布局规则需要隐藏该字段,则不显示
            if(in_array($columnname,$hidecolumns)){
                continue;
            }

            $fieldid = $fieldinfo->getFieldid();
            //编辑时只读的字段在编辑时，显示但不可编辑，
            if( !empty($profilefields) && ($profilefields[$fieldid]['editreadonly']==1 ||$profilefields[$fieldid]['readonly'] )){
                $fieldinfo->set_allowedit('no');
            }
            $fields_arr=array('uitype'=>$fieldinfo->getUIType(),'fieldlabel'=>$fieldinfo->getFieldLabel(),'allowedit'=>$fieldinfo->get_allowedit()
            ,'fieldname'=>$fieldinfo->getFieldName(),'columnname'=>$fieldinfo->getColumnName(),'fieldonly'=>$fieldinfo->getfieldOnly()
            ,'displaytype'=>$fieldinfo->getDisplaytype(),'tablename'=>$fieldinfo->getTableName(),'bigtype'=>$fieldinfo->getBigType(),
                'fieldvaluecolor'=>$fieldinfo->getFieldValueColor(),'fieldplaceholder'=>$fieldinfo->getFieldPlaceholder(),
                'editpage'=>$fieldinfo->getEditpage(),'savedatabase'=>$fieldinfo->getSaveDataBase());
            $typeofdata = $fieldinfo->getTypeOfData();
            $fields_arr['typeofdata'] = str_replace('O','M',$typeofdata);

            $uitype=$fieldinfo->getUIType();
            $fieldonly=$fieldinfo->getfieldOnly();
            $fieldvaluecolor = $fieldinfo->getFieldValueColor();//文字颜色
            $fieldplaceholder = $fieldinfo->getFieldPlaceholder();
            $allowedit = $fieldinfo->allowedit;//是否允许编辑
            $allowedit = 'no';

            $columnname=$fieldinfo->getColumnName();
            $maxlength = $fieldinfo->getMaximumLength();
            $generatedtype = $fieldinfo->getGeneratedtype();
            $typeofdata = $fieldinfo->getTypeOfData();
            $defaultvalue =$fieldinfo->getDefaultValue();
            $bigtype=$fieldinfo->getBigType();
            $focusmode = 'edit';

            //避免重复读取附件信息
            if($bigtype == 'fileattachment' && !is_array($filejsondata)){
                $this->withattachment = 'yes';
                $filejsondata=getAllFile_imageInfo($record,$this->module);
            }else if($uitype == 151){
                crm_load_function_file('selWareAll','include/Stock','CommonStock');
                $wareresult = selWareAll();
                for($i = 0; $i<$this->db->num_rows($wareresult); $i++)
                {
                    $wareArray[$this->db->query_result($wareresult, $i, "id")] = $this->db->query_result($wareresult, $i, "name");
                }
                $smarty->assign("WAREALL", $wareArray);
            }
            if($bigtype=='fileattachment')
            {

                $fieldname=$fieldinfo->getFieldName();
                $tmp_filedata = [];
                for($i=1;$i<120;$i++)
                {

                    if(!isset($this->requestcolumn[$fieldname.'-file_name_'.$i]))
                    {
                        continue;
                    }

                    $storage_location='local';
                    $cloud_path='';
                    $upload_from=$this->requestcolumn[$fieldname.'-upload_from_'.$i];
                    if(isset($this->requestcolumn[$fieldname.'-storage_location_'.$i]))
                    {
                        //edit:can 20200813 42401: (61mis.com/kfbcrm)跟进记录模块>新建单据界面：先上传“附件”，然后“客户状态”字段选择“潜在客户”（客户状态字段做了布局规则），附件就不显示了
                        $storage_location=$this->requestcolumn[$fieldname.'-storage_location_'.$i];
                        $cloud_path=$this->requestcolumn[$fieldname.'-cloud_path_'.$i];

                    }
                    $filename=$this->requestcolumn[$fieldname.'-file_name_'.$i];
                    $newfile_name=$this->requestcolumn[$fieldname.'-newfile_name_'.$i];
                    $file_path=$this->requestcolumn[$fieldname.'-file_path_'.$i];
                    $file_size=$this->requestcolumn[$fieldname.'-file_size_'.$i];
                    $file_type=$this->requestcolumn[$fieldname.'-file_type_'.$i];
                    $isencrypt=$this->requestcolumn[$fieldname.'-isEncrypt_'.$i];

                    // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（布局规则重新获取预览按钮）
                    if($isencrypt == 'yes'){
                        $httppath = $cls_MyCRMcrypt->decode($cloud_path) ;
                        $pre_path = $cls_MyCRMcrypt->decode($file_path) . $cls_MyCRMcrypt->decode($newfile_name);
                    }
                    $file = array('id'=>$i,'storage_location'=>$storage_location,'httppath'=>$httppath,
                        'pre_path'=>$pre_path,'name'=>$filename,'type'=>$file_type,'isEncrypt'=>$isencrypt
                    ,'path'=>$file_path,'cloud_path'=>$cloud_path,'newfile_name'=>$newfile_name);
                    $pre_button = AttachmentUtils::getPreviewButton($file);

                    $tmp_filedata[]=array('file_name'=>$filename,'newfile_name'=>$newfile_name
                    ,'file_path'=>$file_path,'file_size'=>$file_size
                    ,'file_type'=>$file_type,'cloud_path'=>$cloud_path
                    ,'upload_from'=>$upload_from,'storage_location'=>$storage_location
                    ,'isEncrypt'=>$isencrypt,'pre_button'=>$pre_button);
                }
                if(is_array($tmp_filedata) && sizeof($tmp_filedata)>0){
                    $filejsondata[$fieldname] = $tmp_filedata;
                }
                $this->filejsondata = $filejsondata;
            }

            //只显示为空的字段,不为空的字段隐藏  //如果当前模块设置了布局规则，则不为空的字段也需要显示
            if($this->EmptyFieldOnly == 'yes' && sizeof($alltriggercolumn) == 0){

                if($bigtype == 'fileattachment'){
                    if(is_array($filejsondata[$columnname]) && count($filejsondata[$columnname]) > 0){
                        continue;
                    }
                }else if($bigtype == 'reference' || field::user_fields($uitype) ||$uitype == 251){
                    //关联选择单据字段的值为0时，也视为空
                    if(!empty($col_fields[$tmp_fieldname])){
                        continue;
                    }
                }else{
                    //普通字段的值为0时，不视为空
                    if(is_numeric($col_fields[$tmp_fieldname]) && ($col_fields[$tmp_fieldname] == 0 || $col_fields[$tmp_fieldname] == '0')){
                        continue;
                    }else if(!empty($col_fields[$tmp_fieldname])){
                        continue;
                    }
                }
            }
            if($columnname == 'source_list'){
                $this->withselectsource = 'yes';
            }


            if(empty($obj_cls)){
                crm_load_class_file('cls_EditView_OutPut','include/utils');
                $obj_cls = new cls_EditView_OutPut();
                if(isset($advfilter_arr)&&!empty($advfilter_arr)){
                    $obj_cls->setAdvFilter($advfilter_arr);
                }
            }

            $custfld = $obj_cls->getEditViewOutputHtml($fieldinfo, $maxlength, $col_fields,$generatedtype,$this->module,$focusmode,$typeofdata,$fieldonly,$curapproveformodulefield);

            //判断字段是否需要设为必填
            if($this->MandatoryField == 'yes'){
                $custfld[4] = 'M';
            }
            $choose_fieldobj_arr[]=$fields_arr;
            $choose_fieldinfo_arr[] = $custfld;
            //获取布局规则的触发字段
            if(is_array($alltriggercolumn) && in_array($fieldname,$alltriggercolumn)){
                $this->triggerfieldname_arr[] = $fieldname;
                $this->triggerfieldvalue_arr[$fieldname] = $focus->column_fields[$fieldname];
            }
        }

        $smarty->assign('data',$choose_fieldinfo_arr);
        $table_html = $smarty->fetch("Approve/ApproveEditField.tpl");

        $result_arr = ['field'=>$choose_fieldobj_arr,'html'=>$table_html];
        return $result_arr;
    }

    //保存审批必填字段值
    public function saveFieldValue($record,$fieldvaluejson){
        global $weixin_user;
        $module = $this->module;
        $adb = $this->db;
        $focus = CRMEntity::getInstance($module);
        $before_request = $_REQUEST;

        $_REQUEST['mode'] = 'edit';
        $_REQUEST['apiDeleteAttach'] ='no';
        $_REQUEST['ajxaction'] = 'DETAILVIEW';
        $_REQUEST['action'] ='ApiNoEditDetails';

        $focus->id = $record;
        $focus->retrieve_entity_info($focus->id,$module);
        $focus->mode = $_REQUEST['mode'];
        $focus->is_check_business='no';//不经过工商查询判断
        $attachfield_arr = array();

        $fieldvalue_arr = ldcrm_json_decode($fieldvaluejson);

        if(isset($_REQUEST['description']))unset($_REQUEST['description']);
        foreach ($fieldvalue_arr as $tmp_key => $tmp_value){
            $_REQUEST[$tmp_key] = urldecode($tmp_value);
            $newvalue_arr[$tmp_key] = urldecode($tmp_value);
        }

        foreach($focus->column_fields as $fieldname => $fieldvalue){
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
            if(empty($fieldinfo)){
                continue;
            }
            if($fieldinfo->getBigType() == 'fileattachment' && isset($_REQUEST[$fieldname.'-file_num'])){
                $uitype = $fieldinfo->getUIType();
                $columnname = $fieldinfo->getColumnName();
                if($uitype==1109||$uitype==28){
                    $attachfield_arr['filetoattachment'][] = $columnname;
                }
                if($uitype==69){
                    $attachfield_arr['imageattachment'][] = $columnname;
                }
            }

            if(isset($_REQUEST[$fieldname])){
                $focus->column_fields[$fieldname] = $_REQUEST[$fieldname];
                if (!empty($weixin_user)&&$fieldinfo->getBigType()=='richtext') {
                    $tablename = $fieldinfo->getTableName();
                    $columnname = $fieldinfo->getColumnName();
                    $table_index = $focus->table_index;
                    $sql = "update $tablename set $columnname=? where $table_index = ?";
                    $adb->pquery($sql,array($_REQUEST[$fieldname],$record));

                    continue;
                }
            }
        }
        // 不走公共代码来保存附件
        $focus->set_Is_needcommonsave_attachments('no');
        $focus->save($module);
        //附件字段单独保存
        if(sizeof($attachfield_arr)>0){
            $focus->addFileToAttachmentSavenoJudge($focus->id,$module,$attachfield_arr);
        }
        crm_load_class_file("cls_mainfieldformula","include/fields");
        $mainfieldformula=cls_mainfieldformula::getInstance($module);
        //设置哪些字段 在界面上保存
        $mainfieldformula->setMainFieldHadRequest($newvalue_arr);
        $mainfieldformula->setRecord($record);
        //设置数据库字段的值
        $mainfieldformula->setColumn_fieldsValue($focus->retrieve_entity_info($record,$module));
        foreach ($fieldvalue_arr as $tmp_key => $tmp_value){
            $mainfieldformula->updateDbValue($tmp_key,$record);
        }

        $_REQUEST = $before_request;
    }

    //获取移动端编辑界面的字段信息
    public function getEditviewReturn($record,$choose_fieldname_arr,$outputinfo){
        $adb = $this->db;
        $module = $this->module;
        $this->record = $record;
        //2、获取单据头所有字段
        if($module == 'Users'){
            //duan 20221012 因为登陆时生成了用户模块field对象的缓存，所以重新获取一次更新语言类型
            $fieldobj = new Field($module, $adb);
        }else{
            $fieldobj = Field::getInstance($module, $adb);
        }
        $moduleFields = $fieldobj->getModuleFields();
        //审批必填字段增加布局规则判断
        $focus = CRMEntity::getInstance($module);
        $focus->retrieve_entity_info($record,$module);
        $this->focus = $focus;
        $this->setColumnValuesFromRequest();
        $col_fields = $this->focus->column_fields;
        $alltriggercolumn = [];
        if($this->usefieldrule == 'yes'){
            $fieldrulecolsproperty = $this->getFieldRuleColumn($this->focus);
            $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏字段
            //$displaycolumns=$fieldrulecolsproperty['displaycolumns'];//不是快速创建的字段，但是符合布局规则的要求
            //$requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
            $alltriggercolumn=$fieldrulecolsproperty['alltriggercolumn'];//获取所有的触发字段
        }
        $withfieldrule = 'no';
        //如果审批必填字段在布局规则的触发字段当中,则直接进入大编辑保存方式
        foreach ($choose_fieldname_arr as $tmp_fieldname){
            if(in_array($tmp_fieldname,$alltriggercolumn)){
                $withfieldrule = 'yes';
            }
        }

        $hide_source_list = 'no';
        $blockinfos = $outputinfo['list'];
        $tmpblockinfos = $blockinfos;
        $tmpblockindex = 0;
        foreach ($tmpblockinfos as $blockindex => $blockfieldinfo) {
            $tmpfieldindex = 0;
            $isdeleteblock = 'no';
            foreach ($blockfieldinfo['fieldinfo'] as $fieldindex => $tmpfieldinfo) {
                $fieldname = $tmpfieldinfo['fieldname'];
                $tmp_fieldname = $fieldname;
                $fieldinfo = $moduleFields[$fieldname];
                //editor:gyq_20190820  reason:选择源单字段前，特殊插入的源单类型字段，增加特殊标识tempfield=1
                if (isset($tmpfieldinfo['tempfield'])) {//源单类型  没有columnname,fieldname为 selectsourcename
                    $tmpfieldindex++;
                    continue;
                }

                if (!$fieldinfo) {
                    $tmpfieldindex++;
                    continue;
                }

                $bigtype = $fieldinfo->getBigType();
                $uitype = $fieldinfo->getUIType();
                $tmpcolumnname = $fieldinfo->getColumnName();
                $hide_field = 'no';

                //只显示为空的字段,不为空的字段隐藏
                if($this->EmptyFieldOnly == 'yes' && sizeof($alltriggercolumn) == 0){
                    if($bigtype == 'fileattachment' && !is_array($filejsondata)){
                        $this->withattachment = 'yes';
                        $filejsondata=getAllFile_imageInfo($record,$this->module);
                    }
                    if($bigtype == 'fileattachment'){
                        if(is_array($filejsondata[$tmpcolumnname]) && count($filejsondata[$tmpcolumnname]) > 0){
                            $hide_field = 'yes';
                        }
                    }else if($bigtype == 'reference'||$uitype == 251){
                        //关联选择单据字段的值为0时，也视为空
                        if(!empty($col_fields[$tmp_fieldname])){
                            $hide_field = 'yes';
                        }
                    }else if(field::user_fields($uitype)){
                        //用户字段的值为0时，也视为空
                        if(!empty($col_fields[$tmp_fieldname])){
                            $hide_field = 'yes';
                        }
                    }else{
                        //普通字段的值为0时，不视为空
                        if(is_numeric($col_fields[$tmp_fieldname]) && ($col_fields[$tmp_fieldname] == 0 || $col_fields[$tmp_fieldname] == '0')){
                            $hide_field = 'yes';
                        }else if(!empty($col_fields[$tmp_fieldname])){
                            $hide_field = 'yes';
                        }
                    }
                }

                if (in_array($fieldname,$choose_fieldname_arr) && !in_array($tmpcolumnname,$hidecolumns) && $hide_field=='no') {
                    //判断字段是否需要设为必填
                    if($this->MandatoryField == 'yes'){
                        $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['fieldtype'] = 'M';
                    }
                }else if($withfieldrule == 'no'){
                    if ($tmpcolumnname=='source_list') {//选择源单隐藏，源单类型也应该隐藏
                        $hide_source_list = 'yes';
                    }
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
                    if ($tmp_fieldname == 'selectsourcename') {
                        unset($blockinfos[$blockindex]['fieldinfo'][$fieldindex]);
                        $blockinfos[$blockindex]['fieldinfo'] = array_values($blockinfos[$blockindex]['fieldinfo']);
                        if (sizeof($blockinfos[$blockindex]['fieldinfo']) <= 0) {
                            array_splice($blockinfos, $blockindex, 1);
                            $isdeleteblock = 'yes';
                        }
                        break 2;
                    }
                }
            }
        }

        $outputinfo['list'] = $blockinfos;
        //5、去掉审批流程
        unset($outputinfo['approvestep']);

        //审批必填字段包含了布局规则的触发字段，则直接进入大编辑操作
        $outputinfo['miniedit_fieldrule'] = 'no';
        if($withfieldrule == 'yes'){
            $outputinfo['miniedit_fieldrule'] = 'fromapprove';
            return $outputinfo;
        }

        //4.去掉单据分录
        unset($outputinfo['entry']);

        //6、去掉布局规则
        $outputinfo['fieldrulelist']=array();
        //7、去掉币种信息
        $outputinfo['currency']=array();
        unset($outputinfo['currency']);
        //8、去掉主表字段公式
        //$outputinfo['mainfieldformula']=array();
        //9.去掉签到信息 signData
        $outputinfo['signData']=array();
		unset($outputinfo['signData']);

        return $outputinfo;
    }
    //获取请求中传的字段值
    public function setColumnValuesFromRequest(){
        if(is_array($this->requestcolumn) && count($this->requestcolumn) >0){
            $modulefields = $this->focus->fieldobj->getModuleFields();
            foreach($modulefields as $fieldname=>$fieldinfo){
                if(isset($this->requestcolumn[$fieldname])){
                    if($fieldinfo->getUIType()==33)
                    {
                        $this->focus->column_fields[$fieldname]=setsaveMutliPickListValue($this->requestcolumn[$fieldname]);
                    }else{
                        $this->focus->column_fields[$fieldname] = $this->requestcolumn[$fieldname];
                    }
                }
            }
        }
        return $this->focus;
    }

    //判断布局规则
    public function getFieldRuleColumn($focus){
        $fieldruleobj=cls_fieldrule::getInstance($this->module);

        //将fieldname的value值转化为columnname
        $module_field = $focus->fieldobj->getModuleFields();
        $new_value_arr = [];
        foreach ($module_field as $tmp_field){
            $fieldname = $tmp_field->getFieldName();
            $columnname = $tmp_field->getColumnName();
            $new_value_arr[$columnname] = $focus->column_fields[$fieldname];
        }

        $fieldruleobj->setColumnValues($new_value_arr);
        $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        $fieldrulecolsproperty['alltriggercolumn'] = $fieldruleobj->getAllFieldNameSetChangeEvent();
        return $fieldrulecolsproperty;
    }

    //获取特殊返回值
    public function getReturnApproveData(){
        $approvedata = [];
        if($this->withattachment == 'yes'){
            $filejsondata=array();
            if($this->record > 0 && empty($this->filejsondata)){
                $filejsondata=getAllFile_imageInfo($this->record,$this->module);
            }else{
                $filejsondata = $this->filejsondata;
            }
            $approvedata['filejsondata'] = $filejsondata;
        }
        if($this->withselectsource == 'yes'){
            $approvedata['sourcemodule'] = getSourceModule($this->module);
            $approvedata['label_arr']['SELECTTHESOURCEDOCUMENTTYPE'] = getFixedLabel('SELECTTHESOURCEDOCUMENTTYPE');
        }
        $approvedata['trigger_fieldname_arr'] = $this->triggerfieldname_arr;
        $approvedata['trigger_fieldvalue_arr'] = $this->triggerfieldvalue_arr;
        if(!empty($this->focus)){
            $approvedata['mainfieldformula']=$this->focus->fieldobj->getFormula();
            $approvedata['columnfields_value'] = $this->focus->column_fields;
        }

        return $approvedata;
    }

    //设置请求的值
    public function setRequestColumn($request_value){
        $request_column = ldcrm_json_decode($request_value);
        foreach ($request_column as $tmp_key => $value){
            $request_column[$tmp_key] = urldecode($value);
        }
        $this->requestcolumn = $request_column;
    }

    //判断是否存在布局规则控制的必填字段
    public function JudgeRequiredFieldRule($focus)
    {
        $this->focus = $focus;
        $focus = $this->setColumnValuesFromRequest();

        $record = $focus->id;
        $columnvalues=array();
        $fieldruleobj=cls_fieldrule::getInstance($this->module);
        //金额字段查询条件错误，要修改为SHOW_EDITVIEW
        $showfieldvalue=new ShowFieldValue($focus->fieldobj,$this->module,constant('SHOW_EDITVIEW'));
        $col_fields=$focus->column_fields;
        $showfieldvalue->setRecorId($record);
        $module_field = $focus->fieldobj->getModuleFields();
        foreach($module_field as $tmpfieldinfo)
        {
            $tmpfieldname=$tmpfieldinfo->getFieldName();
            $showvalue=$showfieldvalue->getFieldValueByField($tmpfieldinfo,$col_fields[$tmpfieldname],$col_fields[$tmpfieldname]);
            $columnvalues[$tmpfieldinfo->getColumnName()]=$showvalue['value'];
        }
        $fieldruleobj->setColumnValues($columnvalues);
        $fieldruleobj->fieldPropertys = '';
        $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        $tmprequiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
		$hidecolumns = $fieldrulecolsproperty['hidecolumns'];
		
		//非管理员  控制只读字段不在模块的新增和编辑时显示
		if($this->user->is_admin=='off'){
			$profileobj=Profile::getInstance();
			$profilefields= $profileobj->getProfileInfos($this->user->profileid);
			$profilefields=$profilefields['field'];
		}
		
        $error = 'no';
        foreach($tmprequiredcolumns as $tmpcolumnname)
        {
			//被布局规则隐藏的字段不需要判断必填
			if(in_array($tmpcolumnname,$hidecolumns))continue;
			
            $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumnname);
            if(!$tmpfieldinfo||$tmpfieldinfo->getFieldName()=='')
                continue;

            $fieldname = $tmpfieldinfo->getFieldName();
			$fieldid = $tmpfieldinfo->getFieldid();
            //界面上显示的字段不需要判断
            if(isset($this->requestcolumn[$fieldname])){
                continue;
            }
			//只读权限的字段不判断必填
			if( !empty($profilefields) && $profilefields[$fieldid]['readonly']==1){
				continue;
			}
			
            if($tmpfieldinfo->getBigType() == 'fileattachment'){
                if(isset($this->requestcolumn[$fieldname.'-file_num'])){
                    $file_num = $this->requestcolumn[$fieldname.'-file_num'];
                    if(empty($file_num) || $file_num == 0){
                        $error='yes';
                        break;
                    }
                }else{
                    $filejsondata=getAttachmentsTableInfo($record,$this->module,$tmpcolumnname);
                    if(empty($filejsondata)){
                        $error='yes';
                        break;
                    }
                }
            }else if(trim($columnvalues[$tmpcolumnname])==''){
                $error='yes';
                break;
            }
        }
        return $error;
    }

    public function getContactInfo($focus){
        global $adb;
        $sqlcontact='select columnname,tablename,fieldname from ld_field where tabid=6 and tablename in(?,?) and presence in(0,2)';
        $resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf'));
        $contactcolumns=Array();
        $contactfieldnames=Array();
        for($i=0;$i<$adb->num_rows($resultcontact);$i++)
        {
            $contactcol=$adb->query_result($resultcontact,$i,'columnname');
            $tablename=$adb->query_result($resultcontact,$i,'tablename');
            $fieldname=$adb->query_result($resultcontact,$i,'fieldname');
            $contactfieldnames[]=$fieldname;
            $contactcolumns[]=$contactcol;

        }
        $columns=implode(',',$contactcolumns);
        $sqlcontact="select $columns,ld_contactdetails.contactid from ld_contactdetails 
              left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
              where accountid=? and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
        $resultcontact=$adb->pquery($sqlcontact,array($focus->id));
        $contactfieldjsondata = array();
        if($adb->num_rows($resultcontact)>0)
        {
            for($i=0;$i<sizeof($contactfieldnames);$i++)
            {
                $focus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
            }
            $contactid = $adb->query_result($resultcontact,0,'contactid');
            $focus->column_fields["contactid"]=$contactid;
            $contactfieldjsondata=getAllFile_imageInfo($contactid,'Contacts');
            foreach($contactfieldjsondata as $tmp_columname => $fileinfo){
                if($tmp_columname == 'filename'){
                    $new_columnname = $tmp_columname.'_mapping';
                    $contactfieldjsondata[$new_columnname] = $fileinfo;
                    unset($contactfieldjsondata[$tmp_columname]);
                }
            }
        }
        return $focus;
    }

}

?>