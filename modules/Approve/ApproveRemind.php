<?php
include(globalStatic::$root_directory . 'include/VarGeneralBol/ApproveNotice.php');

class ApproveRemind
{
    private $module;
    private $record;
    private $stepid;
    private $remindmethod;
    private $remindcontent;
    private $reminduser;
    private $remindtitle;
    public $weidu_remindsid_dingtalk;
    public $weidu_remindsid_fanwei;
    protected $weidu_remindsid_weixin;
    public $weidu_remindsid;
    public $approveresult;
    public $remindusertags;
    public $reminduserid;
    public $remindfields;
    public $reminduserinfos;
    public $all_remind_info_arr;


    /*  editor:gyq_05
     *  @param 参数$approvelog是一个包含审批历史的数组
     *  $approvelog['crmid']            数据ID
        $approvelog['approveid']        当前审批步骤ID
        $approvelog['stepid']           当前审批步骤ID
        $approvelog['approved_by']      当前审批人
        $approvelog['approveresult']    当前审批结果类型(1,2,3,4)  3,4:已拒绝，2：审批通过，1：审批中
        $approvelog['description']      备注
        $approvelog['nextstepid']       下一审批步骤
        $approvelog['approvedeal']      审批类型临时参数，用过即清除，暂时只应用在反审批中
        @param 审批类型参数 $approvedeal
                backstep 回撤上一步，若当前审批步骤不是第一步，则根据上一步审批不通过生成提醒
                submit 由于审批中和提醒审批approveresult都是1，此参数加以区分，参数值为submit表示提交审批状态
     * */

    public function CreateMultiApproveReminds($module, &$approvelog, $approvedeal = '')
    {
        $this->module = $module;
        if (!empty($approvelog['approvedeal'])) {
            $approvedeal = $approvelog['approvedeal'];
        }

        /*清除临时变量*/
        unset($approvelog['approvedeal']);
        /*外部审批日志数组转本地临时数组，避免取址后影响外部调用$approvelog*/
        $approvelogs = $approvelog;
        if (!empty($approvelogs['crmid'])) {
            $this->updateRemindStatus($approvelogs['crmid']);
        }
        if ($approvedeal == 'backlaststep') {
            //duan 20230316 BUG0063006:单据审批驳回无法收到提醒
            $approvelogs['approveresult'] = 4;//驳回
            $this->CreateMultiApproveRemind($module, $approvelogs);

            $approvelogs['stepid'] = $approvelogs['nextstepid'];
            $approvelogs['nextstepid'] = null;
            $approvelogs['approveresult'] = 5;//返回上一步
            $this->CreateMultiApproveRemind($module, $approvelogs);

        } else if ($approvedeal == 'backstep') {

            $approvelogs['stepid'] = $approvelogs['nextstepid'];
            $this->CreateMultiApproveRemind($module, $approvelogs);

            $approvelogs['nextstepid'] = null;
            $approvelogs['approveresult'] = 4;//驳回
            $approvelogs['nextstepapproveby'] = '';
            $this->CreateMultiApproveRemind($module, $approvelogs);

        } else {
            /* 正在审批可能生成两条提醒，当前步骤提醒和下一步提醒 */
            if ((1 == $approvelogs['approveresult']||$approvelogs['approveresult']==6) && $approvedeal != 'submit') {
             
                //根据下一步生成提醒
                $exchange = $approvelogs['stepid'];
                $approvelogs['stepid'] = $approvelogs['nextstepid'];

                $this->CreateMultiApproveRemind($module, $approvelogs);

                //根据当前步骤生成提醒
                $approvelogs['approveresult'] = 2;
                $approvelogs['stepid'] = $exchange;
                $this->CreateMultiApproveRemind($module, $approvelogs);
            } else {

                $this->CreateMultiApproveRemind($module, $approvelogs);
            }
        }

    }

    private function CreateMultiApproveRemind($module, $approvelog)
    {


        $this->initRemindInfo($module, $approvelog);
        $remindmethods = $this->remindmethod;

        foreach ($remindmethods as $type => $methods) {

            foreach ($methods as $method) {
                foreach ($this->all_remind_info_arr[$type][$method] as $tmp_remind_info_arr) {
                    $usertag = $tmp_remind_info_arr['remindusertag'];
                    $sendinfo = $tmp_remind_info_arr['reminduserinfo'];
                    $remindcontent = $tmp_remind_info_arr['remindcontent'];
                    $remindtitle = $tmp_remind_info_arr['remindtitle'];
                    $templateid = $tmp_remind_info_arr['templateid'];
                    $templateparamconf = $tmp_remind_info_arr['templateparamconf'];

                    if ($method == 'dialog') {
                        //弹框提醒
                        $this->CreateDialogRemind($sendinfo, $remindcontent,$remindtitle,$approvelog);
                    } // 发送邮件
                    else if ($method == 'email') {

                        $this->SendEmail($sendinfo, $remindcontent,$remindtitle);
                    } //发送短信
                    else if ($method == 'sms') {

                        $this->SendSMS($sendinfo, $remindcontent, $templateid, $templateparamconf);
                    } else if ($method == 'weixin') {
                        $this->CreateWeiXinRemind($sendinfo, $remindcontent,$remindtitle);

                    }
                }
            }


        }

    }

    // 初始化审批提醒方式、对象、内容
    private function initRemindInfo($module, $approvelog)
    {
        global $adb;
        $this->module = $module;

        $this->record = $approvelog['crmid'];
        $this->stepid = $approvelog['stepid'];


        $approveresult = $approvelog['approveresult'];
        //根据审批结果匹配提醒类型
        if ($approveresult == 3 || $approveresult == 4) { //拒绝、驳回配合提醒类型
            $remindType = 2;
        } elseif ($approveresult == 2) { // 批准配合提醒类型
            $remindType = 1;
        } elseif ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {   //审批中配合提醒类型
            $remindType = 0;
        }elseif ($approveresult == 3) { // 批准配合提醒类型
            $remindType = 3;
        }

        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();

//        $sql = 'select * from ld_approvereminds  where stepid=? and type=?';
        $sql = "select ld_approvereminds.*,ld_smsrelated.template_id,ld_smsrelated.templateparamconf from ld_approvereminds 
left join ld_smsrelated ON ld_approvereminds.id = ld_smsrelated.relatedid AND relatedtable='ld_approvereminds'
left join ld_smstemplates ON ld_smsrelated.template_id = ld_smstemplates.templateid
where ld_approvereminds.stepid=? and ld_approvereminds.type=?";
       
        $result = $adb->pquery($sql, array($this->stepid, $remindType));
		$this->approveresult = $approveresult;
        $this->remindmethod = array();
        $this->remindusertags = array();
        $this->reminduserid = array();
        $this->remindfields = array();
        $this->remindcontent = array();
        $this->all_remind_info_arr = array();

        //如果设置了提醒方式
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $approvereminds_id= $adb->query_result($result, $i, 'id');
            $templateid= $adb->query_result($result, $i, 'template_id');
            $templateparamconf= $adb->query_result($result, $i, 'templateparamconf');

            $remindmetod = $adb->query_result($result, $i, 'remindmethod');
            $type = $adb->query_result($result, $i, 'type');
            

            $tmp_remind_info_arr = [];

            if (is_array($this->remindmethod[$type])) {
                if (!in_array($remindmetod, $this->remindmethod[$type])) {
                    $this->remindmethod[$type][] = $remindmetod;//dialog,email,sms
                }
            } else
                $this->remindmethod[$type][] = $remindmetod;//dialog,email,sms
            $remindusertag = $adb->query_result($result, $i, 'reminduser');
            $this->remindusertags[$type][$remindmetod][] = $remindusertag;//Accounts_email,Accounts_sms,approver smowner smcreator,selectuser
            $tmp_remind_info_arr['remindusertag'] = $remindusertag;

            if (stripos($remindusertag, 'email') !== false || stripos($remindusertag, 'sms') !== false) {


                //指定邮箱和手机
                $this->reminduserinfos[$type][$remindmetod][$remindusertag] = $this->getAssignEmailOrSms($remindmetod, $remindusertag, $adb->query_result($result, $i, 'remindcolumnname'), $approvelog);
            } else {

                $this->reminduserinfos[$type][$remindmetod][$remindusertag] = $this->getRemindUser($remindmetod, $remindusertag, $approvelog, $adb->query_result($result, $i, 'reminduserid'));
            }
            $tmp_remind_info_arr['reminduserinfo'] = $this->reminduserinfos[$type][$remindmetod][$remindusertag];

            $remindcontent = $adb->query_result($result, $i, 'remindcontent');//提醒内容
            $approvenotice = new ApproveNotice($module, $this->record);//变量提醒内容
            if ($remindmetod == 'sms' && $cls_Send_MassSms->platform == 'aliyun') {
                $remindcontent = $approvenotice->getContent($templateparamconf);//短信解析设置的变量内容
            }else{
                $remindcontent = $approvenotice->getContent($remindcontent);

            }


            /*  正则替换{approver}{step}{description} */
            if ($remindcontent) {

                $stepname = '';
                $approver = '';
              //&& $remindusertag == 'approver'
                if ($approvelog['approved_by'] > 0  && stripos($remindcontent, '{approver}')) {
            
                    $sql = 'select last_name from ld_users  where id=?';
                    $userresult = $adb->pquery($sql, array($approvelog['approved_by']));
                    if ($adb->num_rows($userresult) > 0) {
                        $approver = $adb->query_result($userresult, 0, 'last_name');
                    }
                }
                if ($approvelog['stepid'] > 0 && stripos($remindcontent, '{step}') !== false) {

                    $sql = 'select name from ld_approvestep  where id=?';
                    $userresult = $adb->pquery($sql, array($approvelog['stepid']));
                    if ($adb->num_rows($userresult) > 0) {
                        $stepname = $adb->query_result($userresult, 0, 'name');
                    }
                }
                $description = $approvelog['description'];
                
                
               
                $search = array('/{step}/is', '/{approver}/is', '/{description}/is');
                $replace = array($stepname, $approver, $description );
                
                $remindcontent = preg_replace($search, $replace, $remindcontent);

            }

            $this->remindcontent[$type][$remindmetod][$remindusertag] = $remindcontent;
            $this->remindcontent[$type][$remindmetod]["templateid"]=$templateid;
            $this->remindcontent[$type][$remindmetod]["templateparamconf"]=$remindcontent;

            $tmp_remind_info_arr['remindcontent'] = $remindcontent;
            $tmp_remind_info_arr['templateid'] = $templateid;
            $tmp_remind_info_arr['templateparamconf'] = $remindcontent;

            //zkt 20220427 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
            //提醒标题
            $remindtitle = $adb->query_result($result, $i, 'remindtitle');
            //zkt 202200707 1000017  审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第二版）
            $remindtitle = $approvenotice->getContent($remindtitle);
            /*  正则替换{approver}{step}{description} */
            if ($remindtitle) {
                if (empty($approver)&&$approvelog['approved_by'] > 0  && stripos($remindtitle, '{approver}')) {
                    $sql = 'select last_name from ld_users  where id=?';
                    $userresult = $adb->pquery($sql, array($approvelog['approved_by']));
                    if ($adb->num_rows($userresult) > 0) {
                        $approver = $adb->query_result($userresult, 0, 'last_name');
                    }
                }
                if (empty($stepname)&&$approvelog['stepid'] > 0 && stripos($remindtitle, '{step}') !== false) {
                    $sql = 'select name from ld_approvestep  where id=?';
                    $userresult = $adb->pquery($sql, array($approvelog['stepid']));
                    if ($adb->num_rows($userresult) > 0) {
                        $stepname = $adb->query_result($userresult, 0, 'name');
                    }
                }
                $description = $approvelog['description'];
                $search = array('/{step}/is', '/{approver}/is', '/{description}/is');
                $replace = array($stepname, $approver, $description );
                $remindtitle = preg_replace($search, $replace, $remindtitle);
            }
            $this->remindtitle[$type][$remindmetod][$remindusertag] = $remindtitle;
            $tmp_remind_info_arr['remindtitle'] = $remindtitle;
            $this->all_remind_info_arr[$type][$remindmetod][] = $tmp_remind_info_arr;
        }

    }

    private function getAssignEmailOrSms($remindmethod, $remindusertag, $remindcolumnname, $approvelog)
    {
        global $adb;

        $remindcolumnname = trim($remindcolumnname, ",");
        if ($remindcolumnname == "") {
            return;
        }

        $focus = CRMEntity::getInstance($this->module);
        $tableindex = $focus->table_index;
        $tablename = $focus->table_name;
        $fieldobj = $focus->fieldobj;

        //$remindusertag:目前没有模块是有下划线的名称的
        $fieldmodules = explode("_", $remindusertag);

        $remindmodule = $fieldmodules[0];
        $remindfocus = CRMEntity::getInstance($remindmodule);
        $remindtableindex = $remindfocus->table_index;
        $remindtablename = $remindfocus->table_name;
        $remindcolumnnames = explode(',', $remindcolumnname);

        if ($remindmethod == 'sms') {

            $fieldtype = 'mobile';
        } else if ($remindmethod == 'email') {
            $fieldtype = 'email';
        }

        //邮箱不会包含逗号，所以可以用逗号区分
        foreach ($remindfocus->fieldobj->getModuleFields() as $fieldname => $fieldinfo) {
            $columnname = $fieldinfo->getColumnName();
            $remindcolumntablename = $fieldinfo->getTableName();
            if ($fieldinfo->getFieldDataType() != $fieldtype) {
                continue;
            }
            if (in_array($columnname, $remindcolumnnames)) {
                $tables[] = $remindcolumntablename;
                $selectcolumnname .= " ,$remindcolumntablename.$columnname  ";
                $selectcols[] = $columnname;
            }
        }
        //crm_load_class_file('cls_module_uitype','include/fields');
        crm_load_class_file('cls_Uitype_table', 'include/fields');
        if ($remindmodule == 'Accounts') {
            $leftjoins = cls_Uitype_table::getTableJoinByUitype(73, $tablename, 'accountid');

        } else {
            $leftjoins = cls_Uitype_table::getTableJoinByUitype(57, $tablename, 'contactid');
            $relatecolumnname = 'contactid';
        }
        $leftjoinscf = ' ';
        foreach ($tables as $tmptable) {
            if ($tmptable != $remindfocus->table_name) {
                $leftjoinscf = ' left join ' . $tmptable . ' on ' . $remindfocus->table_name . '.' . $remindfocus->table_index . '=' . $tmptable . '.' . $remindfocus->tab_name_index[$tmptable];
                break;
            }
        }
        //zkt 20220729  BUG0054330https://www.81mis.com/kfbtest/ 审批流程定制，“指定联系人邮箱”无法收到审批提醒   
        if(strpos($leftjoins['leftjoin'],'parentcontactdetails')!==false&&$remindfocus->table_name=='ld_contactdetails'){
            $selectcolumnname = str_replace('ld_contactdetails.','parentcontactdetails.',$selectcolumnname);
        }
        $sql = " select  $tablename.$tableindex $selectcolumnname  from $tablename  " . $leftjoins['leftjoin']
            . " $leftjoinscf  where $tablename.$tableindex=?";

        $result = $adb->pquery($sql, array($approvelog['crmid']));

        if ($adb->num_rows($result) > 0) {
            foreach ($selectcols as $col) {
                $colvalue = $adb->query_result($result, 0, $col);
                if (!empty($colvalue)) {
                    $values .= $colvalue . ',';
                }
            }
        }

        return trim($values, ',');


    }

    //获取审批创建人和负责人
    private function getRemindUser($remindmethod, $usertag, $approvelog, $selectuserids)
    {

        global $adb;
        static $approvebillsmownerid, $approvebillcreatorid;
        $focus = CRMEntity::getInstance($this->module);
        $smownercolumnname = $focus->getSmownerColumName();
        $createcolumnname = $focus->getCreateColumnName();


        $userids = array();
        if (strtolower($remindmethod) == 'dialog') {
            $usercolumnname = " ld_users.id ";
        } else if (strtolower($remindmethod) == 'sms') {
            $usercolumnname = 'ld_users.phone_mobile';
        } else if (strtolower($remindmethod) == 'email') {
            $usercolumnname = 'ld_users.email1';
        } else if (strtolower($remindmethod) == 'weixin') {
            $usercolumnname = ' ld_users.wx_userid ';
        }


        if ($usertag == 'smowner') {
            $sql = "select $usercolumnname  as reminduserid from " . $focus->table_name . " 
                        inner join ld_users on ld_users.id=" . $focus->table_name . ".$smownercolumnname  
                        where " . $focus->table_index . "=? and $usercolumnname is not null";

            $result = $adb->pquery($sql, array($this->record));
            $approvebillsmownerid = 0;
            if ($adb->num_rows($result) > 0)
                $approvebillsmownerid = $adb->query_result($result, 0, 0);


            $userids[$usertag] = $approvebillsmownerid;

        } else if ($usertag == 'smcreator') {
            $sql = "select $usercolumnname  as reminduserid from " . $focus->table_name . " 
                        inner join ld_users on ld_users.id=" . $focus->table_name . ".$createcolumnname 
                            where " . $focus->table_index . "=? and $usercolumnname is not null";
            //if(!empty($approvebillcreatorid))
            // {
            $result = $adb->pquery($sql, array($this->record));
            $approvebillcreatorid = "";
            if ($adb->num_rows($result))
                $approvebillcreatorid = $adb->query_result($result, 0, 0);
            //}

            return $approvebillcreatorid;
        } else if ($usertag == 'approver')//审批人
        {
            //目前审批人只有审批处理前才有
            $approvelog['nextstepapproveby'] = trim($approvelog['nextstepapproveby'], ',');

            $nextstepapproveby = explode(',', $approvelog['nextstepapproveby']);
            if (!empty($approvelog['nextstepapproveby'])) {
                $sql = 'select GROUP_CONCAT(' . $usercolumnname . ') from ld_users 
                    where id in( ' . $approvelog['nextstepapproveby'] . ') and ' . $usercolumnname . ' is not null';
                $result = $adb->pquery($sql, array());

                $approver = "";
                if ($adb->num_rows($result) > 0)
                    $approver = $adb->query_result($result, 0, 0);
                $userids[$usertag] = $approver;
            }


        } else if ($usertag == 'selectuser') {
            $selectuserids = trim($selectuserids, ',');
            if (!empty($selectuserids)) {
                $sql = 'select GROUP_CONCAT(' . $usercolumnname . ') from ld_users 
                    where id in( ' . $selectuserids . ') and ' . $usercolumnname . ' is not null';
                $result = $adb->pquery($sql, array());
                $selectuser = "";
                if ($adb->num_rows($result))
                    $selectuser = $adb->query_result($result, 0, 0);
                $userids[$usertag] = $selectuser;

            }
            $userids[$usertag] = $selectuser;
        } else {
            $approvetype_arr = [
                'selectrole' => '1',
                'departmentposition' => '2',
                'topposition' => '3',
                'departmentuser' => '4',
            ];
            if(array_key_exists($usertag,$approvetype_arr)){
                $approvetype = $approvetype_arr[$usertag];
            }else{
                $approvetype = intval($usertag);// 单选，多选用户字段
            }
            $target_userids = "";
            $approveobj = new Approve();
            $approveobj->setNeedApprovalClient('no');// 不需要获取审批委托人
            $target_userids = $approveobj->getApproveBy($approvetype,$selectuserids,$this->record);// 指定角色，三种职位级别，单选、多选用户字段获取用户id
            
            if (!empty($target_userids) && strtolower($remindmethod) != 'dialog') {
                $sql = "SELECT GROUP_CONCAT( $usercolumnname ) from ld_users 
                        where id in( $target_userids ) and $usercolumnname is not null";
                $result = $adb->pquery($sql, array());
                if ($adb->num_rows($result) > 0)
                    $target_userids = $adb->query_result($result, 0, 0);
            }
            $userids[$usertag] = $target_userids;
        }
        return $userids[$usertag];
    }
    //editor:gyq_165 reason:钉钉消息提醒不确定，此处代码似乎不会再调用了   2019/12/30 18:16
    private function CreateWeiXinRemind($wxuseridIds, $rmindcontent,$remindtitle)
    {
        require_once(globalStatic::$root_directory . '/WeiXinApp/modules/Reminds/cls_remindsWX.php');
        crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
        crm_load_class_file('StaticConst', 'WeiXinApp/WeiXin_common');
        $wxuseridIds = trim($wxuseridIds, ',');
        $arr = explode(',', $wxuseridIds);

        $r_multi_content = array(
            array(
                'userid' => $arr,//注意,这是微信用户id，即用户表中的wx_userid
                'message' => $rmindcontent,
                'reltab' => $this->module,
                'related_to' => $this->record,
                'date_time' => date("Y-m-d H:i:s"),
                'remindtype' => 'Approve',
                'title' => $remindtitle
            )
        );
        $remind = new cls_remindsWX();
        $errorno = $remind->send_multi_reminds($r_multi_content);
        global $adb;
        $sql = ' insert into ld_reminds_weixin(content,receiverid,createdtime,related_to,reltab)
        value(?,?,?,?,?)';
        $adb->pquery($sql, array($rmindcontent, $wxuseridIds, date("Y-m-d H:i:s"), $this->record, $this->module));

    }

    private function CreateDialogRemind($useridIds, $remindcontent,$remindtitle,$approvelog)
    {
        require_once(globalStatic::$root_directory . "modules/Reminds/Reminds.php");
        require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
		require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/cls_reminds_yzj.php');
        global $adb;

        $useridIds = trim($useridIds, ",");

        if (empty($useridIds)) {
            return;
        }
        
        $useridArr = explode(',', $useridIds);
        $ids = array();
        //zxm 小程序CRM 关联公众号CRM 发送消息需要的参数 比如客户名称等信息
        $moduleFocus = CRMEntity::getInstance($this->module);
        $moduleFocus->id = $this->record;
        $moduleFocus->retrieve_entity_info($this->record, $this->module);
        $subject[$this->record]['subject'] = $moduleFocus->column_fields[$moduleFocus->list_link_field];
        $subject[$this->record]['table_code'] = $moduleFocus->column_fields[$moduleFocus->table_code];
        if($approvelog['approveresult']==2){
            //zxm 20230828 审批通过的时候 审批人字段应当显示上一步审批人
            $subject[$this->record]['nextstepapproveby'] = $approvelog['approved_by'];//zxm 20230629 审批提醒应当获取当前审批人id
        }else{
            $subject[$this->record]['nextstepapproveby'] = $approvelog['nextstepapproveby'];//zxm 20230629 审批提醒应当获取当前审批人id
        }


        //提醒用户列表去重接受人ID
        foreach (array_unique($useridArr) as $recieverid) {
            if ($recieverid > 0) {

                $focusreminds = new Reminds();
                $date_time = date('Y-m-d H:i:s', time());
                $focusreminds->column_fields['related_to'] = $this->record;
                $focusreminds->column_fields['reltab'] = $this->module;
                $focusreminds->column_fields['is_del_send'] = 0;
                $focusreminds->column_fields['is_del_rec'] = 0;
                $focusreminds->column_fields['status_rmd'] = '未读';
                $focusreminds->column_fields['date_time'] = $date_time;
                $focusreminds->column_fields['wxremindstype'] = 'immediately';

                $focusreminds->column_fields['content'] = $remindcontent;
                $focusreminds->column_fields['recieverid'] = $recieverid;
                $focusreminds->column_fields['remindstype'] = 'Approve';
                $focusreminds->mode = 'create';
                $focusreminds->save('Reminds');
                $ids[] = $focusreminds->id;
            }
        }
        //审批提醒内容根据设置的提醒内容样式显示
        $remindcontent = str_replace("\n", '<br>', $remindcontent);
		$r_multi_content = array(
			array(
				'received_id' => implode(',',array_unique($useridArr)),
				'message' => $remindcontent,
				'reltab' => $this->module,
				'related_to' => $this->record,
				'date_time' => date("Y-m-d H:i:s"),
				'remindtype' => 'Approve',
				'weidu_remindsid' => $this->weidu_remindsid,	//审核操作前的未读消息
				'weidu_remindsid_fanwei' => $this->weidu_remindsid_fanwei,//泛微审批提醒消息有待办已办，
				'weidu_remindsid_dingtalk' => $this->weidu_remindsid_dingtalk,
				'weidu_remindsid_weixin' => $this->weidu_remindsid_weixin,
				'approveresult' => $this->approveresult,
				'approvelogid' => $approvelog['approvelogid'],
                'title' => $remindtitle,         //提醒标题
			)
		);
		//editor:gyq_165 reason:钉钉消息提醒类型,审批提醒   2019/12/28 16:51
		$remind = new MessageCorpconversation();
		$remind->sendAllTypeRemindsImmediately($ids, $r_multi_content,'Approve',$subject);
        //zxm 20221116 公众号提醒消息单独请求
        if($remind->judgeOffiaccount()=='yes'){
            require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
            $offiaccount_remind = new cls_reminds_offiaccount();
            $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($ids,'Approve',$subject);
        }
    }

    private function SendEmail($emails, $remindcontent,$remindtitle)
    {
        $emails = trim($emails, ',');
        if (empty($emails)) {
            return;
        }
        global $adb, $current_user, $server_username;
        //parent_name:收件人  from_email:发送者 ccmail:抄送  bccmail:密送  subject:主题  description1：内容
        if ($emails) {
            if (empty($server_username)) {
                require_once(globalStatic::$root_directory . 'modules/Emails/mail.php');//gyq_122

                $sql = "select server_username from ld_systems where server_type = 'email'";
                $result = $adb->pquery($sql);
                $server_username = $adb->query_result($result, 0, 'server_username');
            }

            if (empty($server_username)) {
                return;
            }

            //    $sql = "select id,email1  from ld_users WHERE id in ($userIds) ";

            $result = $adb->pquery($sql, array());
            $num_rows = $adb->num_rows($result);
            if (!class_exists('Emails')) {
                include(globalStatic::$root_directory . 'modules/Emails/Emails.php');
            }
            $emails = trim($emails, ',');
            $arr = explode(",", $emails);

            for ($i = 0; $i < sizeof($arr); $i++) {
                if (stripos($arr[$i], '@') === false || stripos($arr[$i], '.') === false) {
                    //简单email字段判断
                    continue;
                }
                if (stripos($arr[$i], '@') >= strripos($arr[$i], '.')) {
                    //简单email字段判断
                    continue;
                }
                $focus = new Emails();
                $focus->filename = $_REQUEST['file_name'];
                //$focus->parent_id = vtlib_purify($_REQUEST['parent_id']);
                //$focus->parent_type = vtlib_purify($_REQUEST['parent_type']);
                $focus->column_fields["assigned_user_id"] = $current_user->id;
                $focus->column_fields["subject"] = getFixedLabel('APPROVEREMINDS');
                $focus->column_fields["activitytype"] = "Emails";
                //editor:gyq date:20170215 reason:新增包含DateTimeField文件
                include_once globalStatic::$root_directory . 'include/fields/DateTimeField.php';
                $date_start = new DateTimeField('');

                $focus->column_fields["date_start"] = date($date_start->getDBInsertDateTimeValue());


                $email = $arr[$i];
                //$userid = $adb->query_result($result,$i,'id');

                $focus->column_fields['saved_toid'] = $email;
                $focus->column_fields['contactid'] = $this->record;
                // $all_to_ids=$_REQUEST['parent_name'];
                //$toemail=$_REQUEST['parent_name'];
                $from_email = $server_username;
                $ccmail = $email;
                $bccmail = $email;
                $subject = $remindtitle;
                $content = $remindcontent;

                if (array_key_exists('description', $focus->column_fields)) {
                    $focus->column_fields['description'] = '<p>' . $content . '</p>';
                }

                if (!empty($email)) {

                    $focus->save("Emails");
                    $content=str_replace("\r\n","<br>",$content);
                    $content=str_replace("\n","<br>",$content);
                    send_mail('Emails', $focus->column_fields['saved_toid'], '', $from_email, $subject, $content, $ccmail, $bccmail, 'all', $focus->id, '', $server_username);
                }
            }
        }

    }

    private function SendSMS($mobiles, $remindcontent, $templateid='', $templateparamconf='')
    {
        global $adb;
        global $current_user;
        $mobiles = trim($mobiles, ',');
        if (empty($mobiles)) {
            return;
        }
        $BatchNo = GetSMSBatchNo();
        $arr = explode(',', $mobiles);

        $SmsContent = $remindcontent;
        $now = date("Y-m-d H:i:s");
        $receiveTheme = getFixedLabel('APPROVEREMINDS'); // 短信主题：审批通知
        $operator = $current_user->user_name;
        $accountname = '';
        $outid = $this->record;
        crm_load_class_file('cls_Send_MassSms', 'include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();
        //$groupTelArr = explode(',',$groupTel);
        //提醒用户列表去重

        foreach ($arr as $tel) {

            if (!empty($tel) && preg_match(globalStatic::$reg_mobile_digit, $tel)) {

                if ($cls_Send_MassSms->platform == 'aliyun') {
                    $cls_Send_MassSms->send($tel,$SmsContent,'','',$templateid,$templateparamconf);
                }else{
                    $cls_Send_MassSms->getSmsType($SmsContent);
                    $cls_Send_MassSms->send($tel, $SmsContent);
                }

            }
        }
    }

    /**
     * 更改审批提醒为已读
     * @param 2017-09-11
     * @return
     * @author Chj
     */
    public function updateRemindStatus($crmid)
    {
        global $adb;
		$this->weidu_remindsid = $this->weidu_remindsid_fanwei = $this->weidu_remindsid_dingtalk = $this->weidu_remindsid_weixin = '';	//审核操作前的未读消息
        if (!empty($crmid)) {
			$query = "select GROUP_CONCAT(remindsid) as remindsids from ld_reminds where related_to = ? and push_to_yzj=3 and
                    (remindstype = ? or remindstype = ? or remindstype = ? or remindstype = ?) limit 1";
			$result = $adb->pquery($query,array($crmid,'Approve','AntiApprove','ForceAntiApprove','ExpeditingApprove'));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$this->weidu_remindsid = $adb->query_result($result,0,'remindsids');
			}

            $query = "select GROUP_CONCAT(remindsid) as remindsids from ld_reminds where related_to = ? and push_to_fw=3 and
                    (remindstype = ? or remindstype = ? or remindstype = ? or remindstype = ?) limit 1";
            $result = $adb->pquery($query,array($crmid,'Approve','AntiApprove','ForceAntiApprove','ExpeditingApprove'));
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){
                $this->weidu_remindsid_fanwei = $adb->query_result($result,0,'remindsids');
            }

            $query = "select GROUP_CONCAT(remindsid) as remindsids from ld_reminds where related_to = ? and push_to_ding=3 and
                    (remindstype = ? or remindstype = ? or remindstype = ? or remindstype = ?) limit 1";
            $result = $adb->pquery($query,array($crmid,'Approve','AntiApprove','ForceAntiApprove','ExpeditingApprove'));
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){
                $this->weidu_remindsid_dingtalk = $adb->query_result($result,0,'remindsids');
            }

            $query = "select GROUP_CONCAT(remindsid) as remindsids from ld_reminds where related_to = ? and push_to_weixin=3 and
                    (remindstype = ? or remindstype = ? or remindstype = ? or remindstype = ?) ";
            $result = $adb->pquery($query,array($crmid,'Approve','AntiApprove','ForceAntiApprove','ExpeditingApprove'));
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){
                $this->weidu_remindsid_weixin = $adb->query_result($result,0,'remindsids');
            }
          
            
            $query = 'update ld_reminds set status_rmd = ? where related_to = ? and (remindstype = ? or remindstype = ? or remindstype = ? or remindstype = ?)';
            $adb->pquery($query, array('已读', $crmid, 'Approve','AntiApprove','ForceAntiApprove','ExpeditingApprove'));
           
        }
		return $remindsid;
    }

//@edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（合同订单和自定义11-45模块提交审批时）
    public function sendMessageByDingDing()
    {
        global $adb;
        $sql = 'select * from ld_dingtalk_msg_conf where modulename=?';
        $sqlresult = $adb->pquery($sql, array($_REQUEST['fld_module']));
        if($adb->num_rows($sqlresult) <= 0)
            return 2;//不通知 该模块未配置钉钉
       if($_REQUEST['record']<=0)
       {
        //edit:can 2021-01-12 44215: （企业微信移动端-kfbcrm）合同订单新增界面，源单类型选择报价单，选择源单后，后台报错。
        return 2;
       }

        $keywods = $adb->query_result($sqlresult, 0, 'keywords');
        $webhook = $adb->query_result($sqlresult, 0, 'webhook');
        $content = $adb->query_result($sqlresult, 0, 'content');
        $is_enable = $adb->query_result($sqlresult, 0, 'is_enable');
        $tabid = $adb->query_result($sqlresult, 0, 'tabid');

        include(globalStatic::$root_directory.'include/VarGeneralBol/CommonVarSql.php');
        $templateprintsql=new CommonVarSql($_REQUEST['fld_module'],$_REQUEST['record']);
        $content_sql = $templateprintsql->CreateSql($content);//解析模板内容后最终生成的sql
    
        $content_sql_result=$adb->pquery($content_sql,array());
        $content_sql_result = $adb->fetch_array($content_sql_result);//自然索引和关联索引都有

        foreach ($content_sql_result as $k=>$val) {  //删除自然索引
            if(strpos($k,'[var.') === false){//不包含 删除自然索引和不相关结果集
                unset($content_sql_result[$k]);
            }
        }

        $content = strtolower($content); // 提醒内容里的字母变量改成小写字母

//        @edit:liushuai,2020-12-24,reason:(61mis.com/kfbcrm)销售管理-合同订单-提交审批（钉钉群消息提醒）；将合同订单提交审批后，钉钉群收到的消息提醒中，合计金额显示多个4个小数位；实际合同中的合计金额是2个小数位
        $sysdeploy = getSys_deploy(49);//数量小数位
        if(isset($sysdeploy['deploy_value']))
            $lengthdecimaldigits = $sysdeploy['deploy_value'];
        else
            $lengthdecimaldigits  = 2;
        $sysdeploy_93 = getSys_deploy(93);//单价

        foreach ($content_sql_result as $key=>$value) {
            $printcols = explode('[var.',$key);   //解析 key = [var.salesorder_hdnGrandTotal_SalesOrder]  查询结果为小写
            for ($i = 0; $i < count($printcols); $i++) {
                $fieldname = "";
                if (strpos($printcols[$i], ']') > 0) {
                    $endcol = strpos($printcols[$i], ']');
                    $colsinfo = substr($printcols[$i], 0, $endcol);
                    $tabcols = explode('_', $colsinfo);

                    for ($fi = 1; $fi < count($tabcols) - 1; $fi++) {
                        if ($fi != (count($tabcols) - 2))
                            $fieldname .= $tabcols[$fi] . '_';
                        else
                            $fieldname .= $tabcols[$fi];
                    }

                    $fieldsql = 'select fieldname,columnname,tablename,uitype,typeofdata,tabid from ld_field where fieldname=? and tabid=? limit 1';
                    $fieldsql_result = $adb->pquery($fieldsql,array($fieldname,$tabid));
                    if ($adb->num_rows($fieldsql_result) > 0) {
                        $typeofdata = $adb->query_result($fieldsql_result, 0, 'typeofdata');
                        $uitype = $adb->query_result($fieldsql_result, 0, 'uitype');

                        $typeofdata_arr = explode('~', $typeofdata);
                        if($typeofdata_arr[0] == 'N' || $typeofdata_arr[0] == 'NN'){
                            if(is_numeric($value)){
                                if ($uitype >= 10 && $uitype < 15) {//数量小数位格式化,根据系统参数小数位控制
                                    $value = setNumberFormat($value, $lengthdecimaldigits);
                                } elseif ($uitype == 71 || $uitype == 72 || $uitype == 163 || $uitype == 730 || $uitype == 731 || $uitype == 810 || $uitype == 811) {//单价
                                    $value = setNumberFormat($value, $sysdeploy_93['deploy_value']);//格式化单价、金额字段
                                } elseif ($uitype == 20 || $uitype == 15) {//小数位
                                    $lengthdecimal = substr($typeofdata_arr[2], strpos($typeofdata_arr[2], ',') + 1);
                                    $value = setNumberFormat($value, $lengthdecimal);
                                } else if ($uitype == 24){//整数
                                } else {
                                    $value = setNumberFormat($value, 2);
                                }
                            }
                        }
                    }
                }
            }
            $content = str_replace($key,$value,$content);
        }


        $message = $keywods."\r\n".$content;
        $data = array ('msgtype' => 'text','text' => array ('content' => $message));
        $data_string = json_encode($data);
        if ($is_enable == 'yes') {
            if (!empty($webhook)) {
                $result = json_decode($this->request_by_curl($webhook, $data_string));
                if(empty($result) || !isset($result->errcode) || $result->errcode != 0){
                    return false;//启用并且设置webhook，但是通知失败！   乱填地址没有任何回复
                }
            }else{
                return false;//启用但没有设置webhook   二次判断，其实页面保存时已经判断过了
            }
        }else{
            return 2;//没有启用不通知
        }
        return 1;//启用并通知成功通知

    }

    //钉钉的 自定义机器人消息通知
    function request_by_curl($remote_server, $post_string) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $remote_server);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);//请求超时时间加长
        curl_setopt($ch, CURLOPT_HTTPHEADER, array ('Content-Type: application/json;charset=utf-8'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_string);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        // 线下环境不用开启curl证书验证, 未调通情况可尝试添加该代码.两行
        curl_setopt ($ch, CURLOPT_SSL_VERIFYHOST, 0);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, 0);

        $data = curl_exec($ch);
        curl_close($ch);
        return $data;
    }

}


?>