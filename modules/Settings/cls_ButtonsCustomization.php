<?php
crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
/**
 * XUQIU20240829-12 增加自定义按钮，并支持绑定工作流
 */
class cls_ButtonsCustomization
{
    private $module = '';
    private $tabid = 0;
    private $cls_fieldsearchconditionobj;
    private $clsmoduleadvanceObj;
    
    public $btnposition_label_arr = []; // 按钮位置翻译
    public $relatedtable_arr = [ // 自定义按钮关联的表，目前有工作流
        'workflow' => 'ld_workflow',
    ];
    public function __construct($module){
        global $current_user;

        $this->module = $module;
        if(!empty($module)){
            $this->tabid = getTabid($module);
        }
        $this->btnposition_label_arr = [
            'pc_detail' => getFixedLabel('WebPageDetails'),
            'pc_listlink' => getFixedLabel('ListOperationColumn'),
            'mobile_detail' => getFixedLabel('AppPageDetails'),
        ];
        
        crm_load_class_file('cls_fieldsearchcondition','include/utils');
        $this->cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($this->module);
	}
    public function __destruct(){

    }
    /**
     * 获取可选模块
     */
    public function getOptionModules(){
        global $adb,$current_user,$languageType;
        $sql = "SELECT DISTINCT ld_tab.tabid,`name`,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
                    INNER JOIN ld_tranlabel on ld_tab.tabid = ld_tranlabel.relateid                  
                    INNER JOIN ld_field on ld_field.tabid = ld_tab.tabid and columnname = 'smownerid'
                    WHERE languagetype = ? and trantable = ? and ld_tab.presence in (0,2) 
                    GROUP BY tabid order by tabsequence;";
        $result = $adb->pquery($sql,array($languageType,'ld_tab'));
        $num_rows = $adb->num_rows($result);
        $optionmodule_arr = [];
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $tabid = $adb->query_result($result,$i,'tabid');
                $module = $adb->query_result($result,$i,'name');
                if(vtlib_isModuleActive($module)){
                    $optionmodule_arr[] = [
                        'tabid' => $tabid,
                        'module' => $module,
                        'label' => getTranstab($module)
                    ];
                }
                
            }
        }
        // dump($customView_arr);
        return $optionmodule_arr;
    }
    /**
     * 获取列表头
     */
    public function getListHeader(){
        $header_arr = [
            ['label' => '#','width' => 'min-width:50px;'],
            ['label' => getFixedLabel('suoshumodule'),'width' => 'width:10%;'],
            ['label' => getFixedLabel('ButtonName').'（ZH）','width' => 'width:12%;'],
            ['label' => getFixedLabel('ButtonName').'（EN）','width' => 'width:12%;'],
            ['label' => getFixedLabel('ButtonPosition'),'width' => 'width:25%;'],
            ['label' => getFixedLabel('DESCRIPTION'),'width' => 'width:20%;'],
            ['label' => getFixedLabel('ACTIVATE'),'width' => 'width:10%;'],
            ['label' => getFixedLabel('OPERATING'),'width' => 'min-width:150px;'],
        ];
        return $header_arr;
    }
    /**
     * 根据所选模块获取当前模块下所有自定义按钮的列表数据
     */
    public function getListData(){
        global $adb;

        $select_sql = "SELECT * from ld_buttonscustomization WHERE deleted = 0 AND is_showlist = 'yes' ";
        if(!empty($this->module)){
            $select_sql .= " AND module = ? ";
        }else{
            $select_sql .= " AND module <> ? ";
        }
        $select_result = $adb->pquery($select_sql, array($this->module));
        // dump($select_result);
        $num_rows = $adb->num_rows($select_result);
        $listdata_arr = [];
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata_arr[$i]['showitems']['#'] = $i + 1;
                $module = $adb->query_result($select_result,$i,'module');
                $listdata_arr[$i]['showitems']['module'] = getTranstab($module);
                $listdata_arr[$i]['showitems']['label_zh'] = $adb->query_result($select_result,$i,'label_zh');
                $listdata_arr[$i]['showitems']['label_en'] = $adb->query_result($select_result,$i,'label_en');
                $btnposition = $adb->query_result($select_result,$i,'btnposition');
                $btnposition_arr = explode(',',$btnposition);
                $btnposition_label_arr = [];
                foreach ($btnposition_arr as $index => $value) {
                    $default_seq = array_search($value,array_keys($this->btnposition_label_arr));// 固定排序
                    $btnposition_label_arr[$default_seq] = $this->btnposition_label_arr[$value];
                }
                ksort($btnposition_label_arr);
                $listdata_arr[$i]['showitems']['btnposition'] = implode('，',$btnposition_label_arr);
                $listdata_arr[$i]['showitems']['description'] = $adb->query_result($select_result,$i,'description');
                
                $listdata_arr[$i]['btnid'] = $adb->query_result($select_result,$i,'btnid');
                $listdata_arr[$i]['tabid'] = getTabid($module);
                $listdata_arr[$i]['is_active'] = $adb->query_result($select_result,$i,'is_active');
                $listdata_arr[$i]['type'] = $adb->query_result($select_result,$i,'type');
                $listdata_arr[$i]['related_id'] = $adb->query_result($select_result,$i,'related_id');
                // $label_zh = $adb->query_result($select_result,$i,'label_zh');
                // $label_en = $adb->query_result($select_result,$i,'label_en');
                // $effectivemethod = $adb->query_result($select_result,$i,'effectivemethod');
            }
        }
        
        return $listdata_arr;
    }
    /**
     * 获取用户字段
     */
    public function getUserFields($module){
        $focus = CRMEntity::getInstance($module);
        $fieldobjs = $focus->fieldobj->getModuleFields();
        $userfields_arr = array();
        foreach($fieldobjs as $fieldname => $fieldinfo)
        {
            $columnname = $fieldinfo->getColumnName();
            $fieldname = $fieldinfo->getFieldName();
            $fieldlabel = $fieldinfo->getFieldLabel();
            $fieldid = $fieldinfo->getFieldid();
            $bigtype = $fieldinfo->getBigType();
            if($fieldinfo->getSaveDataBase()=='no' || $fieldinfo->isRelatedModuleField())
                continue;
            //单选用户字段和多选用户字段
            if($fieldinfo->getUIType() == 153 || $fieldinfo->getUIType() == 154){
                $userfields_arr[$fieldid] = $fieldlabel;
            }
            //负责人字段和创建人字段
            if($fieldinfo->getUIType() == 53 || $fieldinfo->getUIType() == 52){
                $userfields_arr[$fieldid] = $fieldlabel;
            }
        }
        return $userfields_arr;
    }
    /**
     * 根据btnid, 获取到按钮信息
     */
    public function getButtonInfo($btnid){
        global $adb,$current_user;
        $select_sql = "SELECT * from ld_buttonscustomization ";
        // $select_sql .= $this->getRelatedJoinSql();
        $select_sql .= " WHERE ld_buttonscustomization.deleted = 0 AND ld_buttonscustomization.btnid = ? ";
        $select_result = $adb->pquery($select_sql, array($btnid));
        // dump($select_result);
        $num_rows = $adb->num_rows($select_result);
        $buttoninfo_arr = [];
        if($num_rows > 0) {
            $buttoninfo_arr['btnid'] = $adb->query_result($select_result,0,'btnid');
            $module = $adb->query_result($select_result,0,'module');
            $buttoninfo_arr['modulelabel'] = getTranstab($module);
            $buttoninfo_arr['label_zh'] = $adb->query_result($select_result,0,'label_zh');
            $buttoninfo_arr['label_en'] = $adb->query_result($select_result,0,'label_en');
            $btnposition = $adb->query_result($select_result,0,'btnposition');
            $btnposition_arr = explode(',',$btnposition);
            foreach ($btnposition_arr as $index => $value) {
                $buttoninfo_arr[$value] = 'checked';
            }
            $buttoninfo_arr['profileid'] = $adb->query_result($select_result,0,'profileid');
            $buttoninfo_arr['userid'] = $adb->query_result($select_result,0,'userid');
            $buttoninfo_arr['userfieldid'] = $adb->query_result($select_result,0,'userfieldid');
            $buttoninfo_arr['description'] = $adb->query_result($select_result,0,'description');
            $buttoninfo_arr['tabid'] = getTabid($module);
            $buttoninfo_arr['is_active'] = $adb->query_result($select_result,0,'is_active');
            $buttoninfo_arr['effectivemethod'] = $adb->query_result($select_result,0,'effectivemethod');
            $buttoninfo_arr['advft_criteria'] = ($adb->query_result($select_result,0,'advft_criteria'));
            $buttoninfo_arr['advft_criteria_groups'] = ($adb->query_result($select_result,0,'advft_criteria_groups'));

            $type = $adb->query_result($select_result,0,'type');
            $related_id = $adb->query_result($select_result,0,'related_id');
            $buttoninfo_arr['type'] = $type;
            $buttoninfo_arr['related_id'] = $related_id;
            // 获取到关联信息
            $relatedinfo_arr = $this->getRelatedInfo($type,$related_id);
            $buttoninfo_arr['relatedinfo'] = $relatedinfo_arr;
        }
        return $buttoninfo_arr;
    }
    /**
     * 根据自定义按钮的类型，获取到关联的信息，例如工作流
     */
    public function getRelatedInfo($type,$related_id){
        $relatedinfo_arr = [];
        // 工作流
        if($type == 'workflow'){
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');
            $workflowreverseobj = new cls_savereverse($this->module);
            $relatedinfo_arr = $workflowreverseobj->getActionInfo($related_id);
        }
        unset($workflowreverseobj);
        return $relatedinfo_arr;
    }
    /**
     * 保存按钮信息，插入或更新表ld_buttonscustomization
     */
    public function saveButton($btnid,$params){
        global $adb,$current_user;
        // dump($params);
        if($btnid > 0){
            $update_sql = "UPDATE ld_buttonscustomization set is_active = ? ,label_zh=? ,label_en = ? ,btnposition = ? ,profileid = ? ,userid = ?,
                userfieldid = ? ,`description` = ? ,effectivemethod = ? ,advft_criteria = ? ,advft_criteria_groups = ? ,modifiedtime = ? where btnid = ?";
            $adb->pquery($update_sql,array($params['is_active'],$params['label_zh'],$params['label_en'],$params['btnposition'],
                $params['profileid'],$params['userid'],$params['userfieldid'],$params['description'],$params['effectivemethod'],
                $params['advft_criteria'],$params['advft_criteria_groups'],date('Y-m-d H:i:s'),$btnid));
            $savetype = 'edit';
        }else{
            $insert_columns = "module,is_active,label_zh,label_en,deleted,is_showlist,btnposition,profileid,userid,userfieldid,`type`,related_id,
                effectivemethod,`description`,advft_criteria,advft_criteria_groups,modifiedtime";
            $insert_sql = "INSERT into ld_buttonscustomization( $insert_columns ) 
                values ( ".generateQuestionMarks($insert_columns)." )";
            $adb->pquery($insert_sql,array($this->module,$params['is_active'],$params['label_zh'],$params['label_en'],0,'yes',$params['btnposition'],
                $params['profileid'],$params['userid'],$params['userfieldid'],$params['type'],$params['related_id'],$params['effectivemethod'],$params['description'],
                $params['advft_criteria'],$params['advft_criteria_groups'],date('Y-m-d H:i:s')));
            $btnid = $adb->getLastInsertID();
            $btnkey = 'CustomButton_'.$btnid;
            $update_sql = "UPDATE ld_buttonscustomization set btnkey = ? where btnid = ?";
            $adb->pquery($update_sql,array($btnkey,$btnid));
            $savetype = 'create';
        }
        if($params['type'] == 'workflow'){
            $this->saveWorkflow($savetype,$params);
        }
    }
    /**
     * 保存工作流信息，插入或更新表ld_workflow
     */
    protected function saveWorkflow($savetype,$params){
    	global $adb,$current_user;

        $workflow_id = $params['related_id'];
        $status = $params['is_active']=='yes'?'Active':'Inactive';
        if($savetype == 'edit'){
            $update_sql = "UPDATE ld_workflow set `name` = ? ,`status`=? where id = ?";
            $adb->pquery($update_sql,array($params['label_zh'],$status,$workflow_id));
        }else{
            $insert_columns = "id,tabid,`name`,`status`,description,triggertime,repeatmode,deleted,createdtime,advft_criteria,advft_criteria_groups";
            $insert_sql = "INSERT into ld_workflow( $insert_columns ) 
                values ( ".generateQuestionMarks($insert_columns)." )";
            $adb->pquery($insert_sql,array($workflow_id,$this->tabid,$params['label_zh'],$status,'','ButtonsCustomization','every',0,date('Y-m-d H:i:s'),
                '[]','[]'));
        }
        // 更新工作流操作的排序
        $workflowactionid_arr = explode(",", $params['workflowactionids']);
        $sequence = 1;
        foreach ($workflowactionid_arr as $workflowactionid) {
            $sql = "UPDATE ld_workflow_actions set `sequence` = ? where id = ? ";
            $adb->pquery($sql, array($sequence++,$workflowactionid));
        }
    }
    /**
     * 根据模块获取到启用的按钮
     */
    public function getActiveButtons(){
        global $adb,$languageType;

        $cachekey = 'cache_custom_activebuttons_'.$this->module;
        // unsetCache($cachekey);
        $active_buttoninfo_arr = Cache($cachekey);
        if(!$active_buttoninfo_arr){

            $select_sql = "SELECT * from ld_buttonscustomization WHERE deleted = 0 AND is_active = 'yes' AND module = ? ";
            $select_result = $adb->pquery($select_sql, array($this->module));
            // dump($select_result);
            $num_rows = $adb->num_rows($select_result);
            $active_buttoninfo_arr = [];
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $active_buttoninfo_arr[$i]['btnid'] = $adb->query_result($select_result,$i,'btnid');
                    $active_buttoninfo_arr[$i]['btnposition'] = $adb->query_result($select_result,$i,'btnposition');
                
                    $active_buttoninfo_arr[$i]['btnkey'] = $adb->query_result($select_result,$i,'btnkey');
                    $active_buttoninfo_arr[$i]['label_zh'] = $adb->query_result($select_result,$i,'label_zh');
                    $active_buttoninfo_arr[$i]['label_en'] = $adb->query_result($select_result,$i,'label_en');
                    $active_buttoninfo_arr[$i]['label'] = $languageType=='en'?$active_buttoninfo_arr[$i]['label_en']:$active_buttoninfo_arr[$i]['label_zh'];
                    $active_buttoninfo_arr[$i]['effectivemethod'] = $adb->query_result($select_result,$i,'effectivemethod');
                    $active_buttoninfo_arr[$i]['type'] = $adb->query_result($select_result,$i,'type');
                    $active_buttoninfo_arr[$i]['is_active'] = $adb->query_result($select_result,$i,'is_active');

                    
                    $active_buttoninfo_arr[$i]['profileid'] = $adb->query_result($select_result,$i,'profileid');
                    $active_buttoninfo_arr[$i]['userid'] = $adb->query_result($select_result,$i,'userid');
                    $active_buttoninfo_arr[$i]['userfieldid'] = $adb->query_result($select_result,$i,'userfieldid');
                    
                    $active_buttoninfo_arr[$i]['advft_criteria'] = html_entity_decode($adb->query_result($select_result,$i,'advft_criteria'));
                    $active_buttoninfo_arr[$i]['advft_criteria_groups'] = html_entity_decode($adb->query_result($select_result,$i,'advft_criteria_groups'));

                    $active_buttoninfo_arr[$i]['permit'] = 'yes';
                }
            }
            Cache($cachekey,$active_buttoninfo_arr);
        }
        return $active_buttoninfo_arr;
    }
    /**
     * 根据条件获取到应该显示的按钮（包括显示位置，显示条件，用户权限）
     */
    public function getAllowButtons($activebtn_arr,$values){
        global $adb,$current_user,$languageType;

        // position: 按钮位置（detail 详情页，listlink 列表操作列）
        $btn_from_position = $values['btn_from'].'_'.$values['position'];
        // 列表操作列需要先获取单据的字段值
        $this->cls_fieldsearchconditionobj->focus->id = $values['record'];
        if($values['position'] == 'listlink'){
            $tmp_columnvalue = $adb->query_result_rowdata($values['result'],$values['i']);
            // if($values['i'] == 1){
                // dump($tmp_columnvalue);
            // }
            $this->cls_fieldsearchconditionobj->setModuleColumnValues($this->module, $tmp_columnvalue);
            $this->cls_fieldsearchconditionobj->fieldvalue_arr = [];
        }

        $buttoninfo_arr = [];
        foreach ($activebtn_arr as $i => $btninfo) {
            $btnposition = $btninfo['btnposition'];
            $btnposition_arr = explode(',',$btnposition);
            // 判断是否符合显示位置
            if(!in_array($btn_from_position,$btnposition_arr)){
                continue;
            }

            $btn_permit = 'no';// 按钮权限
            $btn_permit = $this->getButtonPermit($btninfo,$values['record']);
            
            $buttoninfo_arr[$i]['btnid'] = $btninfo['btnid'];
            $buttoninfo_arr[$i]['btnkey'] = $btninfo['btnkey'];
            $buttoninfo_arr[$i]['label'] = $btninfo['label'];
            $buttoninfo_arr[$i]['permit'] = $btn_permit;
            $buttoninfo_arr[$i]['type'] = $btninfo['type'];
            // $buttoninfo_arr[$i]['custombtn'] = 'yes';
            
        }
        // dump($buttoninfo_arr);

        return $buttoninfo_arr;
    }
    /**
     * 判断当前按钮是否符合显示条件
     */
    public function getButtonPermit($btninfo,$record){
        global $adb,$current_user,$languageType;

        $btn_permit = 'no';// 按钮权限

        if($btninfo['is_active'] == 'yes'){
            $effectivemethod = $btninfo['effectivemethod'];
            $profileid = $btninfo['profileid'];
            $userid = $btninfo['userid'];
            $userfieldid = $btninfo['userfieldid'];
            // 用户权限
            $user_permit = $this->getPermitByUser($profileid,$userid,$userfieldid,$record);
            // dump($user_permit);
            $btn_permit = $user_permit;
            // 若用户有权限则继续判断单据是否符合条件
            if($user_permit == 'yes'){
                $advft_criteria = $btninfo['advft_criteria'];
                $advft_criteria_groups = $btninfo['advft_criteria_groups'];
                $btn_permit = $this->getPermitByRecord($advft_criteria,$advft_criteria_groups,$effectivemethod);
            }
        }
        return $btn_permit;
    }
    /**
     * 判断当前用户是否符合显示条件
     */
    protected function getPermitByUser($profileid,$userid,$userfieldid,$record){
        global $adb,$current_user;
        
        // 指定用户
        if(!empty($userid)){
            $tmp_userid_arr = explode(',',$userid);
            $tmp_userid_arr = array_unique($tmp_userid_arr);
            if(sizeof($tmp_userid_arr)>0&&in_array($current_user->id,$tmp_userid_arr))
                return 'yes';
        }
        // 指定角色
        if(!empty($profileid)){
            $profileid_array = explode(",", $profileid);
            if (in_array($current_user->profileid, $profileid_array)) {
                return 'yes';
            }
        }
        
        // 用户字段
        if(!empty($userfieldid)){
            $userfieldid_arr = explode(',', $userfieldid);
            $focus = CRMEntity::getInstance($this->module);
            $fieldobj = Field::getInstance($this->module, $adb);
            $allpresenecefields_arr = $fieldobj->getModuleAllPreseneceFields();// 不考虑字段权限获取所有启用字段

            foreach ($userfieldid_arr as $tmp_fieldid) {
                $userfield_fieldname = $fieldobj->getFieldInfoBykeyValue('fieldid',$tmp_fieldid,'fieldname');
                $userfieldobj = $allpresenecefields_arr[$userfield_fieldname];

                if($userfieldobj){
                    $userfield_columnname = $userfieldobj->getColumnName();
                    $userfield_fieldname = $userfieldobj->getFieldName();
                    $userfield_value = '';
                    if(!empty($this->cls_fieldsearchconditionobj->modueColunmValArr[$this->module])) {
                        $userfield_value = $this->cls_fieldsearchconditionobj->modueColunmValArr[$this->module][$userfield_columnname];
                    }else if(!empty($focus->column_fields)){
                        $userfield_value = $focus->column_fields[$userfield_fieldname];
                    }else{
                        continue;
                    }
                    if(!empty($userfield_value)){
                        $userfield_value_arr = explode(',', $userfield_value);
                        if (in_array($current_user->id, $userfield_value_arr)) {
                            return 'yes';
                        }
                    }else{
                        continue;
                    }
                }
            }
        }
        if(empty($userid) && empty($profileid) && empty($userfieldid)){
            return 'yes';
        }else{
            return 'no';
        }
    }
    /**
     * 判断当前单据是否符合显示条件
     */
    protected function getPermitByRecord($advft_criteria,$advft_criteria_groups,$effectivemethod){
        $searchcondition_arr['searchtype'] = 'advance';
        $searchcondition_arr['advft_criteria'] = $advft_criteria;
        $searchcondition_arr['advft_criteria_groups'] = $advft_criteria_groups;
        $btn_permit = 'no';
        $tmp_searchconditioninfo = $this->cls_fieldsearchconditionobj->getsearchcondition($searchcondition_arr);
        // 设置的条件为空
        if(empty($tmp_searchconditioninfo['advft_criteria'][0]['selectfield']) && empty($tmp_searchconditioninfo['advft_criteria'][0]['comparefield'])){
            $btn_permit = 'yes';
        }else{
            $tmp_value = $this->cls_fieldsearchconditionobj->getresultbySearchconditioninfo($searchcondition_arr);
            if($this->judgeConditionType($tmp_value,$effectivemethod)){
                $btn_permit = 'yes';
            }
        }
        return $btn_permit;
    }
    /**
     * 根据"满足条件时显示/不满足条件时显示"判断条件是否成立
     */
    public function judgeConditionType($conditionstatus,$effectivemethod){
        $flage = false;
        if(($effectivemethod == 'notmeetcondition' && empty($conditionstatus))||($effectivemethod == 'meetcondition' && !empty($conditionstatus))){
            $flage = true;
        }
        return $flage;
    }
    /**
     * 获取条件中需要的columnname，在queryGenerator中获取列头字段时一起读取出来
     */
    public function getSelectClauseColumn($columns) {
        $columnsArr = empty($columns) ? [] : explode(',',$columns);
        $tmpcolumns_arr = $columnsArr;
        $tmpcolumns_arr = array_map("trim",$tmpcolumns_arr);
        $tmpjointables_arr = [];

        $focus = CRMEntity::getInstance($this->module);
        $custom_activebuttons_arr = $this->getActiveButtons();
        if(is_array($custom_activebuttons_arr) && count($custom_activebuttons_arr) > 0) {
            foreach($custom_activebuttons_arr as $btninfo) {
                $advft_criteria = ldcrm_json_decode($btninfo['advft_criteria']);
                // 用户字段
                $userfieldid_str = $btninfo['userfieldid'];
                $userfieldid_arr = explode(',',$userfieldid_str);
                foreach ($userfieldid_arr as $index => $userfieldid) {
                    $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldid',$userfieldid);
                    if(!empty($tmpfieldinfo)){
                        $tmpcolumnname = $tmpfieldinfo->getColumnName();
                        $tmptablename = $tmpfieldinfo->getTableName();
                        $tmpselectcolumn = $tmptablename.'.'.$tmpcolumnname;
                        if(!in_array($tmpselectcolumn,$tmpcolumns_arr)){
                            $tmpcolumns_arr[] = $tmpselectcolumn;
                            // 增加连表
                            $tmpjointables_arr[] = $tmptablename;
                            // if(!in_array($tmptablename,$tmpjointables_arr)){
                                // $tmpjointables_arr[$tmptablename] = '';
                            // }
                        }
                    }
                }
                // 显示条件
                foreach ($advft_criteria as $advft_criteriainfo){
                    $columnnames = $advft_criteriainfo['columnname'];
                    $columnname_arr = explode(':',$columnnames);
                    $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname_arr[1]);

                    if(!empty($tmpfieldinfo)){
                        $tmpcolumnname = $tmpfieldinfo->getColumnName();
                        $tmptablename = $tmpfieldinfo->getTableName();
                        $tmpselectcolumn = $tmptablename.'.'.$tmpcolumnname;
                        if(!in_array($tmpselectcolumn,$tmpcolumns_arr)){
                            $tmpcolumns_arr[] = $tmpselectcolumn;
                            // 增加连表
                            $tmpjointables_arr[] = $tmptablename;
                            // if(!in_array($tmptablename,$tmpjointables_arr)){
                            //     $tmpjointables_arr[$tmptablename] = '';
                            // }
                        }
                    }
                }
            }
        }
        $tmpcolumns_str = implode(',',$tmpcolumns_arr);
        $return_arr = [
            'columns' => $tmpcolumns_str,
            'join_tables' => $tmpjointables_arr,
        ];

        return $return_arr;
    }
    /**
     * 删除按钮，deleted更新为1
     */
    public function deleteButton($btnid,$type,$related_id){
        global $adb,$current_user;
        if($btnid > 0){
            $update_sql = "UPDATE ld_buttonscustomization set deleted = ? where btnid = ?";
            $adb->pquery($update_sql,array(1,$btnid));

            if($type == 'workflow'){
                $update_sql2 = "UPDATE ld_workflow set deleted = ? where id = ?";
                $adb->pquery($update_sql2,array(1,$related_id));
            }
        }
    }
    /**
     * 启用/不启用按钮
     */
    public function changeButtonActive($btnid,$is_active,$type,$related_id){
        global $adb,$current_user;
        if($btnid > 0){
            $update_sql = "UPDATE ld_buttonscustomization set is_active = ? where btnid = ?";
            $adb->pquery($update_sql,array($is_active,$btnid));

            if($type == 'workflow'){
                $status = $is_active=='yes'?'Active':'Inactive';
                $update_sql2 = "UPDATE ld_workflow set `status` = ? where id = ?";
                $adb->pquery($update_sql2,array($status,$related_id));
            }
        }
    }
}