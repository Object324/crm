<?php
class WorkTemplateRule{

    public $ruleinfo =array();
    public $reporttype;
    public $applicableRuleByUserid;//当前用户满足的规则
    public $editDateByType = array();//当前用户满足规则的编辑时限

    public function __construct()
    {

    }

    public function setWorkReportType($reporttype){
        $this->reporttype = $reporttype;
    }
    public function getWorkReportType(){
        return $this->reporttype ;
    }

    //获取单个规则所有数据 或者新建默认数据
    public function getWorkTemplateRuleInfo($ruleid){
        if (!empty($ruleid) && is_array($this->ruleinfo[$ruleid]) && sizeof($this->ruleinfo[$ruleid])>0){
            return $this->ruleinfo[$ruleid];
        }
        global $adb;
        if (!empty($ruleid)){
            $sql = 'select * from ld_workreport_rulesettings where id = ? ';
            $result = $adb->pquery($sql,array($ruleid));
            $num_rows = $adb->num_rows($result);
            $info = [];
            if ($num_rows > 0 ){
                $info['id'] = $ruleid;
                $info['status'] = $adb->query_result($result,0,'status');
                $info['name'] = $adb->query_result($result,0,'name');
                $info['rule_range'] = $adb->query_result($result,0,'rule_range');
                $rule_range = $adb->query_result($result,0,'rule_value');
                $info['rule_value'] = empty($rule_range)?'':$rule_range;
                $info['reuser_presence'] = $adb->query_result($result,0,'reuser_presence');
                $reuser_type = $adb->query_result($result,0,'reuser_type');
                $reuser_value = $adb->query_result($result,0,'reuser_value');
                $info['reuser_type'] =$reuser_type;
                $info['reuser_value'] = $reuser_value;
                $info['reuser_value_label'] = $this->getLabelByType($reuser_type,$reuser_value);
                $info['ccuser_presence'] = $adb->query_result($result,0,'ccuser_presence');
                $ccuser_type = $adb->query_result($result,0,'ccuser_type');
                $ccuser_value = $adb->query_result($result,0,'ccuser_value');
                $info['ccuser_type'] = $ccuser_type;
                $info['ccuser_value'] = $ccuser_value;
                $info['ccuser_value_label'] = $this->getLabelByType($ccuser_type,$ccuser_value);
                $info['deadline_date'] = $adb->query_result($result,0,'deadline_date');
                $remind_time = $adb->query_result($result,0,'remind_time');
                $remind_time = date('H:i', strtotime($remind_time));
                $info['remind_time'] = $remind_time;
                $info['remind_num'] = $adb->query_result($result,0,'remind_num');
                $info['first_value'] = $adb->query_result($result,0,'first_value');
                $info['second_value'] = $adb->query_result($result,0,'second_value');
                $info['third_value'] = $adb->query_result($result,0,'third_value');
                $info['report_date'] = $adb->query_result($result,0,'report_date');
                $info['edit_date'] = $adb->query_result($result,0,'edit_date');
                $info['auto_generate_brief'] = $adb->query_result($result,0,'auto_generate_brief');//XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华）wsh
                $this->ruleinfo[$ruleid] = $info;
            }
        }else{
            $reprottype = $this->getWorkReportType();
            $remind_time = $reprottype == 'day'? '18:00': '09:00';
            $deadline_date = $reprottype == 'week'? '6': '';//周计划默认周五
            $report_date = $reprottype == 'day'? 'all': 'yes';//周计划默认周五
            $info=array('id'=>'','status'=>'yes','name'=>'','rule_range'=>'all','reuser_presence'=>'no',
                'reuser_type'=>'user','resuer_value'=>'','ccuser_presence'=>'no','ccuser_type'=>'user','ccuser_value'=>'','deadline_date'=>$deadline_date
            ,'remind_time'=>$remind_time,'remind_num'=>3,'first_value'=>3,'second_value'=>2,'third_value'=>1,'report_date'=>$report_date,'edit_date'=>'all'
            );
        }
        return $info;
    }

    //获取单个规则的适用范围
    public function getAllocateInfo($ruleid){
        if (!empty($ruleid)){
            $info = $this->getWorkTemplateRuleInfo($ruleid);
            $arr['ruleid'] = $ruleid;
            $arr['rule_range'] = $info['rule_range'];
            $arr['rule_value'] = $info['rule_value'];
        }else{
            /*reason:新建审批流程，初始化值,-5仅表示新建时各值为空*/
            $arr['ruleid'] = '';
            $arr['rule_range'] = 'all';
            $arr['rule_value'] = '-1';
        }
        return $arr;
    }

    //获取单个日志类型所有规则列表
    public function getRuleListbyReportType(){
        global $adb;
        $reporttype = $this->getWorkReportType();
        $sql = 'select id,`status`,`name`,rule_range,rule_value from ld_workreport_rulesettings where type = ? order by sequence';
        $result = $adb->pquery($sql,array($reporttype));
        $num_rows = $adb->num_rows($result);
        $info = [];
        if ($num_rows > 0){
            for ($i=0;$i<$num_rows;$i++){
                $id = $adb->query_result($result,$i,'id');
                $status = $adb->query_result($result,$i,'status');
                $name = $adb->query_result($result,$i,'name');
                $rule_range = $adb->query_result($result,$i,'rule_range');
                $rule_value = $adb->query_result($result,$i,'rule_value');
                if ($rule_range == 'all'){
                    $rule_value = getFixedLabel('ALLTHEUSERS');
                }else{
                    $rule_value = $this->getLabelByType($rule_range,$rule_value);
                }
                $info[$i] = array('id'=>$id,'status'=>$status,'name'=>$name,'range'=>$rule_value);
            }
        }
        return $info;

    }

    //获取单个日志类型所有启用规则的内容
    public function getAllPresenceRulesbyReportType(){
        global $adb;
        $reporttype = $this->getWorkReportType();
        $sql = 'select * from ld_workreport_rulesettings where type = ? and `status`=? order by sequence';
        $result = $adb->pquery($sql,array($reporttype,'yes'));
        $num_rows = $adb->num_rows($result);
        $info = [];
        if ($num_rows > 0){
            for ($i=0;$i<$num_rows;$i++){
                $ruleid = $adb->query_result($result,$i,'id');
                $info['ruleid'] = $ruleid;
                $info['status'] = $adb->query_result($result,$i,'status');
                $info['name'] = $adb->query_result($result,$i,'name');
                $rule_range = $adb->query_result($result,$i,'rule_range');
                $info['rule_range'] = $rule_range;
                $rule_value = $adb->query_result($result,$i,'rule_value');
                $info['rule_value'] = empty($rule_value)?'':$rule_value;
                $info['rule_value_userinfo'] = $this->getUseridByType($rule_range,$rule_value);
                $info['reuser_presence'] = $adb->query_result($result,$i,'reuser_presence');
                $reuser_type = $adb->query_result($result,$i,'reuser_type');
                $reuser_value = $adb->query_result($result,$i,'reuser_value');
                $info['reuser_type'] =$reuser_type;
                $info['reuser_value'] = $reuser_value;
                $info['reuser_value_userinfo'] = $this->getUseridByType($reuser_type,$reuser_value);
                $info['ccuser_presence'] = $adb->query_result($result,$i,'ccuser_presence');
                $ccuser_type = $adb->query_result($result,$i,'ccuser_type');
                $ccuser_value = $adb->query_result($result,$i,'ccuser_value');
                $info['ccuser_type'] = $ccuser_type;
                $info['ccuser_value'] = $ccuser_value;
                $info['ccuser_value_userinfo'] = $this->getUseridByType($ccuser_type,$ccuser_value);
                $info['deadline_date'] = $adb->query_result($result,$i,'deadline_date');
                $info['remind_time'] = $adb->query_result($result,$i,'remind_time');
                $info['remind_num'] = $adb->query_result($result,$i,'remind_num');
                $info['first_value'] = $adb->query_result($result,$i,'first_value');
                $info['second_value'] = $adb->query_result($result,$i,'second_value');
                $info['third_value'] = $adb->query_result($result,$i,'third_value');
                $info['report_date'] = $adb->query_result($result,$i,'report_date');
                $info['edit_date'] = $adb->query_result($result,$i,'edit_date');
                $info['auto_generate_brief'] = $adb->query_result($result,$i,'auto_generate_brief');
                $arr[$ruleid] = $info;
            }
        }
        return $arr;

    }


    //获取当前用户适用的规则
    public function getApplicableRuleByUserid($userid){
        $reporttype = $this->reporttype;
        if (!empty($this->applicableRuleByUserid[$reporttype])){
            return $this->applicableRuleByUserid[$reporttype];
        }
        $allPresenceRules = $this->getAllPresenceRulesbyReportType();
        if (empty($allPresenceRules)){
            return [];
        }else{
            foreach ($allPresenceRules as $ruleid => $ruleinfo){
                $applicable_userinfo = $ruleinfo['rule_value_userinfo'];
                if (array_key_exists($userid,$applicable_userinfo) && !empty($applicable_userinfo[$userid])){
                    $this->applicableRuleByUserid[$reporttype] = $ruleinfo;
                    return $ruleinfo;
                }
            }
        }
    }

    //获取选择成员名、部门名、角色名
    public function getLabelByType($type,$value_str){
        if (empty($value_str)){
            return '';
        }
        $arr = [];
        if ($type == 'user' || $type == 'group') {
            crm_load_class_file('UsersUtils','modules/Users');
            $UsersUtilsObj = new UsersUtils();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                if ($type == 'user'){
                    $arr[] = $UsersUtilsObj->getUserFullName($id);
                }else{
                    $arr[] = $UsersUtilsObj->getGroupFullName($id);
                }
            }
            return implode(',',$arr);
        }elseif($type == 'role'){
            $profileobj=Profile::getInstance();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                $profileinfo = $profileobj->getProfileinfo($id);
                $arr[] = $profileinfo['profilename'];
            }
            return implode(',',$arr);
        }
    }

    //获取部门、角色下是所有启用的user信息
    public function getUseridByType($type,$value_str){
        global $current_user;
        if (empty($value_str) && $type != 'all'){
            return '';
        }
        if($type == 'group' || $type == 'user' || $type == 'Users' || $type == 'all'){
            crm_load_class_file('UsersUtils','modules/Users');
            $UsersUtilsObj = new UsersUtils();
            if($type == 'group' || $type == 'user' || $type == 'all'){
                if ($type == 'all'){
                    $arr = $UsersUtilsObj->get_user_array(false);
                }else{
                    $value_arr = explode(',',$value_str);
                    foreach ($value_arr as $key => $id){
                        if ($type == 'group'){
                            $userinfo = $UsersUtilsObj->getGroupOfActiveUsers($id);
                            foreach ($userinfo as $userid => $last_name){
                                $arr[$userid] = $last_name;
                            }
                        }else{
                            $arr[$id] = $UsersUtilsObj->getUserFullName($id);
                        }
                    }
                }

            }else if ($type == 'Users'){
                $focus = CRMEntity::getInstance('Users');
                $focus->retrieve_entity_info($current_user->id,'Users');
                $userid = $focus->column_fields[$value_str];
                $arr[$userid] = $UsersUtilsObj->getUserFullName($userid);
            }
        }else if($type == 'role'){
            $profileobj=Profile::getInstance();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                $userinfo = $profileobj->getProfileOfActiveUsers($id);
                foreach ($userinfo as $userid => $last_name){
                    $arr[$userid] = $last_name;
                }
            }
        }
        return $arr;
    }

    //获取提醒截止时间数据
    public function getDeadlineDateArr(){
        global $languageType;
        $reporttype = $this->getWorkReportType();
        if ($reporttype == 'day'){
            $arr = array('today'=>getFixedLabel('SameDay'));
        }else if($reporttype == 'week'){
            $arr = array('5'=>getFixedLabel('Thursday'),
                '6'=>getFixedLabel('Friday'),//Friday
                '7'=>getFixedLabel('Saturday'),//Saturday
                '8'=>getFixedLabel('Sunday'),//Sunday
            );
        }else{
            if($languageType=='en'){
                $arr=array('20'=>'NO.20',
                    '25'=>'NO.25',
                    '28'=>'NO.28',
                    '40'=>getFixedLabel('ENDOFMONTH'),
                    '1'=>'The 1st day of next month',
                    '2'=>'The 2nd day of next month',
                    '3'=>'The 3rd day of next month',
                    '4'=>'The 4th day of next month',
                    '5'=>'The 5th day of next month',
                    );
            }else{
                $arr=array('20'=>'20号',
                    '25'=>'25号',
                    '28'=>'28号',
                    '40'=>getFixedLabel('ENDOFMONTH'),
                    '1'=>'下月1号',
                    '2'=>'下月2号',
                    '3'=>'下月3号',
                    '4'=>'下月4号',
                    '5'=>'下月5号',
                    );
            }
        }
        return $arr;

    }


    //获取成员管理单选用户字段
    public function getSelectUserField(){
        global $adb;
        $fieldobj=Field::getInstance('Users',$adb);
        $allModuleInfo = $fieldobj->getModuleFields();
        $modulelabel = getTranstab('Users');
        foreach ($allModuleInfo as $fieldname => $fieldinfo){
            if ($fieldinfo->getUitype() == 153){
//                dump($fieldinfo);
                $fieldlabel = $fieldinfo->getFieldLabelKey();
                $columnname = $fieldinfo->getColumnName();
                $fieldid = $fieldinfo->getFieldid();
                $arr[$fieldname]['label'] = $modulelabel.'_'.$fieldlabel;
                $arr[$fieldname]['columnname'] = $columnname;
                $arr[$fieldname]['module'] = 'Users';
                $arr[$fieldname]['fieldid'] = $fieldid;
            }
        }
        return $arr;
    }

    //新建编辑保存
    public function saveRule($ruleid,$dataArr){
        global $adb;
        $reporttype = $this->getWorkReportType();
        if (empty($ruleid)){
            $sequence_sql = 'select max(sequence) as maxsequence from ld_workreport_rulesettings where type=?';
            $sequence_result = $adb->pquery($sequence_sql,array($reporttype));
            $sequence = $adb->query_result($sequence_result,0,'maxsequence')+1;
            $columnname_arr = array_keys($dataArr);
            $insert_sql = 'insert into ld_workreport_rulesettings(type,sequence,`'.implode('`,`',$columnname_arr).'`) values(?,?,"'.implode('","',$dataArr).'")';
            $adb->pquery($insert_sql,array($reporttype,$sequence));
        }else{
            $set_str = [];
            foreach ($dataArr as $columnname => $value){
                $set_str[]= '`'.$columnname.'`="'.$value.'"';
            }
            $update_sql = 'update ld_workreport_rulesettings set '.implode(',',$set_str).' where id=? and type=?';
            $adb->pquery($update_sql,array($ruleid,$reporttype));
        }

    }

    //XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川）
    //获取汇报日期结果 editDate:日期是否可编辑 minDate:最小日期 maxDate:最大日期
    public function getReportDateData(){
        global $current_user;
        $ruleinfo = $this->getApplicableRuleByUserid($current_user->id);
        $report_date = $ruleinfo['report_date'];
        $reporttype = $this->reporttype;
        if ($reporttype == 'week' || $this->reporttype == 'month'){//周月
            return array('editDate'=>$report_date);
        }
        Crm_load_class_file("CommonView","modules/CustomView");
        $dateTimeStr = CommonView::stdFilterDateTimeStr();
        //今天
        $today = $dateTimeStr['today'][1];
//        dump($dateTimeStr);
        switch ($report_date){
            case 'all'://日志 不限时间
                $editDate = 'yes';
                $minDate = '';
                $maxDate = '';
                $label = getFixedLabel('UnlimitedTime');
                break;
            case '1_0'://日志 仅当天
                $editDate = 'no';
                $minDate = $today;
                $maxDate = $today;
                $label = getFixedLabel('SameDay');
                break;
            case '1_1'://日志 仅当天及过去1天
                $editDate = 'yes';
                $minDate = $dateTimeStr['last1days'][0];
                $maxDate = $today;
                $label = getVarFixedLabel('CurrentDayAndThePastSomeDay',1);
                break;
            case '1_3'://日志 仅当天及过去3天
                $editDate = 'yes';
                $minDate = $dateTimeStr['last3days'][0];
                $maxDate = $today;
                $label = getVarFixedLabel('CurrentDayAndThePastSomeDay',3);
                break;
            case '1_7'://日志 仅当天及过去7天
                $editDate = 'yes';
                $minDate = $dateTimeStr['last7days'][0];
                $maxDate = $today;
                $label = getVarFixedLabel('CurrentDayAndThePastSomeDay',7);
                break;
        }
        return array('editDate'=>$editDate,'minDate'=>$minDate,'maxDate'=>$maxDate,'label'=>$label);
    }

    //XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川）
    public function getReportEditDate($reporttype){
        if (!empty($this->editDateByType[$reporttype]) && sizeof($this->editDateByType[$reporttype]) > 0){
            return $this->editDateByType[$reporttype];
        }
        global $current_user;
        $this->setWorkReportType($reporttype);
        $ruleinfo = $this->getApplicableRuleByUserid($current_user->id);
        $edit_date = $ruleinfo['edit_date'];
        $minDate = '';
        $maxDate = '';
        Crm_load_class_file("CommonView","modules/CustomView");
        $dateTimeStr = CommonView::stdFilterDateTimeStr();
        switch ($edit_date){
            case '1':
                $minDate = $dateTimeStr['last1days'][0];
                $maxDate = $dateTimeStr['today'][1];
                break;
            case '3':
                $minDate = $dateTimeStr['last3days'][0];
                $maxDate = $dateTimeStr['today'][1];
                break;
            case '7':
                $minDate = $dateTimeStr['last7days'][0];
                $maxDate = $dateTimeStr['today'][1];
                break;
        }
        $this->editDateByType[$reporttype] = array('editDate'=>$edit_date,'minDate'=>$minDate,'maxDate'=>$maxDate);
        return $this->editDateByType[$reporttype];
    }

}
?>