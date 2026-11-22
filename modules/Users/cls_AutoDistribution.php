<?php
crm_load_function_file('getAverageUserName','modules/Accounts','averageComputer');
/**
 * 自动分配   liushuai 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能
 * 
 * */
class cls_AutoDistribution{
    public $focus;
    public $setype;
    public $fld_module;
    public $ruleid;
    public $original_changetype;
    public function __construct($setype)
    {
        crm_load_class_file('ModTracker', 'modules/ModTracker');
        $this->setype=$setype;
        $this->original_changetype = $_REQUEST['changetype'];//记录操作日志，区分是分配、平均分配还是

        $_REQUEST['changetype'] = 'Allocate';
        $_REQUEST['fld_module']=$_REQUEST['from_module'];

        $this->allocatepermit= isPermitted($_REQUEST['fld_module'], $_REQUEST['changetype']);
        $this->fld_module = $_REQUEST['fld_module'];

        $this->focus = CRMEntity::getInstance($this->fld_module);

        $this->ruleid = $_REQUEST['ruleid'];//分配弹出层中勾选的 分配标准规则id  customform24id 即单据id
    }
    public function setChangeOperation(){
        if ('getselectusers' == $this->setype)
        {
            $select_users_info = $this->getselectusers();
            ConvertTojsonString(1,array("select_users_count"=>count($select_users_info)),"success");

        } else {
            $this->save();
        }
    }
     public function getselectusers()
     {
         global $adb;
         $sql = "select detailscf.line_users_id,IFNULL(NULLIF(detailscf.sf702, ''), 0) as ratio from ld_customform24detailscf detailscf 
    left join ld_customform24detail on ld_customform24detail.lineitem_id=detailscf.lineitem_id  
    left join ld_usersscf on ld_usersscf.id=detailscf.line_users_id
    where ld_customform24detail.id=? and IFNULL(detailscf.line_users_id,0)>0 and ld_usersscf.cf_7527 = '在线' ORDER BY ratio DESC";//在线的才去分配
         $result=$adb->pquery($sql,array($this->ruleid));
         $num_rows=$adb->num_rows($result);
         $select_user_arr = [];
         if($num_rows>0)
         {
             for($i=0;$i<$num_rows;$i++) {
                 $userid = $adb->query_result($result, $i, 'line_users_id');//待分配负责人
                 $ratio = $adb->query_result($result, $i, 'ratio');//相应的分配比例
                 $select_user_arr[$userid] = array("ratio"=>$ratio/100);
             }

         }
         return $select_user_arr;
     }
     /**
      * 判断是否有平均分配的权限
      * */
     public function havebtnPermit()
     {
        return $this->allocatepermit;
     }
     public function requirefile()
     {
        
     }
     private function setAccount_Smowner()
     {
         global $current_user,$adb;
         $module = $this->fld_module;

         if (!$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']) {
             $this->focus->getModuleStatic('ModTracker');//字段修改日志
             $this->focus->modstatic->saveOperationLog($module,'',$this->original_changetype,$this->ruleid);
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'] = $adb->getLastInsertID();

             $select_users_info = $this->getselectusers();//负责人对应的分配比例

             $this->smownerids = array_keys($select_users_info);//将勾选的用户ID转换为数组
             foreach ($this->smownerids as $tmp_val) {
                 if(!isset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$tmp_val])){
                     $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$tmp_val] = 0;
                 }
             }

             //获取列表所选的批量处理数 单据id
             $allrecordids = $recordids = $this->getSelectRecordIds();

             //开始去重
             //获取规则下的成员已分配的信息
             $allocated_data = $this->getAllocatedInfo();
             /*Array
              (
                  [132] => Array
                  (
                      [allocated_crmid] => [1,99]
                      [allocated_num] => 2
                 )

                 [133] => Array
                  (
                      [allocated_crmid] => [50]
                      [allocated_num] => 1
                  )
             )*/
             //将负责人的分配比例及已分配数量整理到一个数组里,方便下面处理
             foreach ($select_users_info as $smownerid=>&$ratio) {
                 if (isset($allocated_data[$smownerid])) {
                     $ratio = array_merge($ratio,$allocated_data[$smownerid]);
                 }
             }

             //获取已分配的全部crmid的集合,然后去重
             $allocated_crmid_arr = array();//已分配的全部crmid的集合(历史分配)
             foreach ($select_users_info as $item) {
                 if (isset($item["allocated_crmid"])) {
                     $allocated_crmid_arr = array_merge($allocated_crmid_arr, $item["allocated_crmid"]);
                 }
             }

             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allocated_crmid_arr'] = $allocated_crmid_arr;//已分配的客户
             $allrecordids_includehistory = array_unique(array_merge($allocated_crmid_arr,$allrecordids));//当前选择的crmid+历史已分配的crmid

             $recordids = array_values(array_diff($allrecordids,$allocated_crmid_arr));//去重后的待处理单据集合


            //计算本次分配的客户总个数+本月已分配的客户总数，注意需要去重。
            //按照规则中的比例计算每个人应该分配的客户数-已分配的客户数得出应该分配的客户数，并为其分配相应个数的客户数。

             //从总的客户id 去计算按照比例每个负责人能分配多少个客户
             $allocatedCustomers = $this->allocateCustomers(count($allrecordids_includehistory), array_column($select_users_info,'ratio'), $this->smownerids);

             $whether_reallocate = 'no';//是否需要重新分配
             foreach ($select_users_info as $key_smownerid=>$item) {
                 if (isset($item['allocated_num'])) {
                     foreach ($allocatedCustomers as $key_smownerid2=>&$allowAllocateNum){
                         if ($key_smownerid == $key_smownerid2) {//如果存在负责人已分客户数大于比例对应的客户数,则应该不分配该负责人,然后重新分配数量.
                             if ($item['allocated_num']>$allowAllocateNum) {
                                 $whether_reallocate='yes';
//                                 $this->smownerids = array_values(array_diff($this->smownerids, array($key_smownerid2)));//去掉不用分配的负责人及负责人信息
//                                 unset($select_users_info[$key_smownerid2]);

                                 $select_users_info[$key_smownerid2]['newratio']=0;//负责人不变，只将比例改为0，不然后面日志就不显示这个负责人的分配信息了(虽然分配个数为0)
                                 $allowAllocateNum = 0;
                             }else{
                                 $allowAllocateNum = $allowAllocateNum-$item['allocated_num'];
                                 $select_users_info[$key_smownerid2]['newratio']=$item['ratio'];
                             }

                             break;
                         }
                     }
                 }

             }

             //存在多分的（当修改分配比例后的极少情况）,则 重新计算分配数量??? 路总说先这么计算，因为始终都会存在这种情况
             if ($whether_reallocate=='yes') {
                 $allocatedCustomers = $this->allocateCustomers(count($recordids), array_column($select_users_info,'newratio'), $this->smownerids);
             }
//             dump($allocatedCustomers);
             $tmp_Account_Average_Group = $this->splitArrayByLength($recordids,$allocatedCustomers);

             //更改一下格式方便进度条请求后数据处理
             $new_Account_Average_Group = [];
             foreach ($tmp_Account_Average_Group as $tmp_smownerid=>$tmp_value) {
                 foreach ($tmp_value as $tmp_value2) {
                     $new_Account_Average_Group[$tmp_value2]=$tmp_smownerid;
                 }
             }


             $customerCount = count($recordids);
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'] = $allrecordids;//页面勾选的单据
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid'] = $recordids;//去重后实际处理的单据

             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average_Group'] = $new_Account_Average_Group;//实际处理的单据 格式处理后
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['total'] = $customerCount;
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['intervalrow'] = ceil($customerCount/10);//向上取整
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['start'] = 0;
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['intervalrow']; //当前处理到第几个

         }else{
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['start'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end'];
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end']+$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['intervalrow'];
         }


         $this->allrecordids=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'];
         $this->recordids=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid'];
         $this->Account_Average_Group=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average_Group'];

     }
    public function getSelectRecordIds()
    {
        global $current_user;
        $module=$this->fld_module;

        if($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'])
        {
            return $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'];
        }
        else{
            $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
            $idlist = $this->getIdList();
            if ($idlist == 'all') {
                //$_REQUEST['mass_batch_num_all']=$this->btach_num;
                $idArr = getSelectedRecords($_REQUEST, $this->fld_module, rtrim($idlist, ';'), $excludedRecords);
            } else
                $idArr = explode(';', rtrim($idlist, ';'));
            $recordids = array_values($idArr);
            return $recordids;
        }

    }
    public function getAllocatedInfo()
    {
         global $adb;
         $sql = "SELECT GROUP_CONCAT(basic.crmid) AS allocated_crmid,detail.postvalue AS smownerid,count(basic.crmid) AS allocated_num
FROM ld_operation_log AS log 
INNER JOIN ld_modtracker_basic AS basic ON log.id=basic.operation_logid 
INNER JOIN ld_modtracker_detail AS detail on basic.id = detail.id
WHERE log.module=? AND log.action='autoDistribution' AND log.actiontwo=? AND YEAR(log.operation_time) = YEAR(CURRENT_DATE())
AND MONTH(log.operation_time) = MONTH(CURRENT_DATE()) AND detail.fieldname='assigned_user_id' AND detail.postvalue in(".implode(',',$this->smownerids).") GROUP BY detail.postvalue";

        $result=$adb->pquery($sql,array($this->fld_module,$this->ruleid));
        $num_rows=$adb->num_rows($result);
        $allocated_arr = [];
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++) {
                $smownerid = $adb->query_result($result, $i, 'smownerid');//待分配负责人
                $allocated_crmid = $adb->query_result($result, $i, 'allocated_crmid');//已分配的客户id
                $allocated_arr[$smownerid] = array(
                    'allocated_crmid'=>explode(',',$allocated_crmid),
                    'allocated_num'=>$adb->query_result($result, $i, 'allocated_num')//已分配的客户数量
                );
            }

        }
        return $allocated_arr;

    }
    public function getUserId()
    {}
    public function getIdList()
    {
        $idlist = vtlib_purify($_REQUEST['select_id']);
        return $idlist;
    }
    public  function save(){
        $_REQUEST['diony'] = 'yes';
        $this->requirefile();
        global $adb, $current_user, $languageType;
        $focus = $this->focus;
        $module = $this->fld_module;

        $this->setAccount_Smowner();//设置对应负责人所分配的客户  及 初始化进度条缓存信息

        $start = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['start'];
        $intervalrow = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['intervalrow'];

        $new_recordids=array_slice($this->Account_Average_Group,$start,$intervalrow,true);//待处理的单据  截取后保留键值

        if ($this->fld_module == 'Accounts') {
            $SMSarray = GetSMSAutograph();
            $autograph = $SMSarray['autograph'];
        }
        $operation_logid = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'];

        $smcolumnname = $focus->getSmownerColumName();
        $fieldobj = Field::getInstance($module, $adb);
        $smownerid_fieldinfo = $fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);
        $smownerid_fieldlabel = $smownerid_fieldinfo->getFieldLabel();


        $batchlog = getFixedLabel('DOCUMENTNOSUCCESS');
        $batchsuccesslog = getFixedLabel('AVERAGE_PROMPT');
        $avgsuccesslog = getFixedLabel('AVERAGE_PROMPT');
        $dellog = getFixedLabel('thedocumenthasbeendeleted');
        $batchtype = getFixedLabel('CHANGE') . $smownerid_fieldlabel;
        $batcherrorlog = getFixedLabel('AllocateSmownerError');
        $batreachmax = getFixedLabel('ALLOCATERREACHMAXCUSTOMER');
        foreach($new_recordids as $recordid=>$smownerid)
        {
            $idlist = $this->getIdList();
            $email_content = array();
            $correct = 0;
            $error = 0;
            $edit_err = '';


            $entityarray = getEntitynameInfo(getTabid($module));
            $tabname = $entityarray['tablename'];
            $tabindex = $entityarray['entityidfield'];
            $tabfieldname = $entityarray['fieldname'];
            $smownercolumnname = $focus->getSmownerColumName();//$focus->fieldobj->getFieldInfoBykeyValue('columnname',$focus->getSmownerColumName(),'columnname');
            $smownerfieldname = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $smownercolumnname, 'fieldname');
            $smcreatorcolumnname = $focus->getCreateColumnName();
            $smcreatorfieldname = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $smcreatorcolumnname, 'fieldname');


            $tmpremindsid = array();

            crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
            $fieldruleobj = cls_fieldrule::getInstance($this->fld_module);
            if (isset($idlist)) {
                $assigned = $smownerid_fieldinfo->getFieldName();

                /* editor:gyq_07 reasom:适配分配 */
                $fields = $focus->fieldobj->getModuleAllPreseneceFields();
                if ($this->havebtnPermit() == 'yes') {

                    $crmid = $recordid;
                    $focus->retrieve_entity_info($crmid, $this->fld_module);

                    //工作流程获取改变前字段值
                    $beforefieldvalue_arr = $this->focus->column_fields;

                    $col_fields = $focus->column_fields;
                    $col_fields['db_' . $smownerfieldname] = $col_fields[$smownerfieldname];
                    $col_fields['db_' . $smcreatorfieldname] = $col_fields[$smcreatorfieldname];

                    $col_fields[$smownerfieldname] =$smownerid;

                    $error = 'no';
                    if ($_REQUEST['changetype'] == 'Allocate') {

                        $columnvalues = array();

                        $showfieldvalue = new ShowFieldValue($focus->fieldobj, $this->fld_module, constant('SHOW_POPUP'));
                        $showfieldvalue->col_fields = $col_fields;
                        $showfieldvalue->setRecorId($crmid);

                        foreach ($fields as $tmpfieldinfo) {
                            $tmpfieldname = $tmpfieldinfo->getFieldName();
                            $showvalue = $showfieldvalue->getFieldValueByField($tmpfieldinfo, $col_fields[$tmpfieldname], $col_fields[$tmpfieldname]);
                            $columnvalues[$tmpfieldinfo->getColumnName()] = $showvalue['value'];
                        }

                        $fieldruleobj->setColumnValues($columnvalues);
                        $_REQUEST['mass_edit_recordid'] = $crmid;
                        $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty($smownercolumnname);//布局规则字段的隐藏和必填项
                        $tmprequiredcolumns = $fieldrulecolsproperty['requiredcolumns'];//必填字段

                        unset($_REQUEST['mass_edit_recordid']);
                        foreach ($tmprequiredcolumns as $tmpcolumnname) {
                            $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $tmpcolumnname);
                            if (!$tmpfieldinfo || $tmpfieldinfo->getFieldName() == '')
                                continue;
                            if (trim($columnvalues[$tmpcolumnname]) == '') {
                                $this->errorcolumnname = $tmpcolumnname;

                                $edit_err .= sprintf($batcherrorlog, '<a referencemodule="'.$this->fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $col_fields[$focus->list_link_field] . '</a>', $focus->fieldobj->getFieldInfoBykeyValue("columnname", $tmpcolumnname, 'fieldlabel')) . '<br>';
                                $errorstr = 'yes';
                                $error++;
                                break;
                            }
                        }
                    }


                    if ($errorstr == 'yes') {
                        continue;
                    }

                    $subject[$crmid]['subject'] = $col_fields[$focus->list_link_field];// $adb->query_result($result, $i, 'subject');
                    //zxm crm小程序 推送消息到公众号的  获取单据编号
                    $subject[$crmid]['table_code'] = $col_fields[$focus->table_code];//编号
                    $subject[$crmid]['smcreatorid'] = $col_fields['db_' . $smcreatorfieldname];// $adb->query_result($result, $i, 'smcreatorid');
                    if ($focus->fieldobj->getFieldInfoobjBykey("columnname", 'accountid')) {
                        $subject[$crmid]['accountid'] = $col_fields['account_id'];
                    } else {
                        $subject[$crmid]['accountid'] = 0;
                    }
                    $subject[$crmid]['smownervalue'] = $col_fields['db_' . $smownerfieldname];;// $adb->query_result($result, $i, 'smownervalue');


                    $successids[] = $recordid;
                    $sql = 'update ' . $focus->table_name . ' set ' . $smownerid_fieldinfo->getColumnName() . ' = ?,modifiedtime=? where ' . $focus->table_index . ' = ? ';
                    $adb->pquery($sql, array($smownerid,date('Y-m-d H:i:s'), $recordid));
                    $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$smownerid]++;

                    $correct++;

                    if ($smownerid != $subject[$recordid]['smownervalue']) {
                        $focus->getModuleStatic('ModTracker');//字段修改日志

                        $focus->modstatic->saveFieldLogOne($module, $assigned, $recordid,
                            $subject[$recordid]['smownervalue'], $smownerid, $operation_logid);
                    }


                    if ($_REQUEST['changetype'] == 'Allocate') {
                        $accountfield = $focus->fieldobj->getFieldInfoBykeyValue("uitype", 73, 'columnname');
                        $oldsmownersql = "select last_name,wx_userid from ld_users where id=?";
                        $oldsmownerlastname = "";
                        $old_wx_userid='';
                        $oldsmownerresult = $adb->pquery($oldsmownersql, array($subject[$recordid]['smownervalue']));
                        if ($adb->num_rows($oldsmownerresult) > 0)
                        {
                            $old_wx_userid=$adb->query_result($oldsmownerresult, 0, 'wx_userid');
                            $oldsmownerlastname = $adb->query_result($oldsmownerresult, 0, 0);
                            $userobj=new Users();
                            $userobj->wx_userid=$old_wx_userid;
                            $userobj->last_name=$oldsmownerlastname;
                            $oldsmownerlastname=getUserlastName($userobj);

                        }

                        if ($accountfield != null) {
                            $accountsql = 'select accountname from ld_account where accountid = (select accountid from  '
                                . $focus->table_name . ' where ' . $focus->table_index . '= ? )';
                            $account_result = $adb->pquery($accountsql, array($recordid));
                            $accountname = '';
                            $accountname_message = '';
                            if ($adb->num_rows($account_result)) {
                                $accountname = $adb->query_result($account_result, 0, 0);
                                if (!empty($accountname)) {
                                    $accountname_message = getTranstab('Accounts') . '：' . $accountname;
                                }
                            }
                            //32501: 企业微信消息提醒

                            $RemindsContent = getUserlastName($current_user) . "将" . $oldsmownerlastname . '的' . getTranstab($module) . '分配给您，请及时关注！' . $accountname_message;
                            $email_content[] = $current_user->last_name . "将" . $oldsmownerlastname . '的' . getTranstab($module) . '(' . $subject[$recordid]['subject'] . ')' . '分配给您，请及时关注！' . $accountname_message;

                            //$RemindsContent = '有新的' . getTranstab($module) . '分配给您，请及时关注！' . $accountname_message;
                            //	$email_content[] = '有新的' . getTranstab($module) .'(' .$subject[$recordid]['subject']. ')'. '分配给您，请及时关注！' . $accountname_message;

                        } else if ($focus->fieldobj->getFieldInfoBykeyValue("uitype", 81, 'columnname') != '') {
                            $vendorsql = 'select vendorname from ld_vendor where vendorid = (select vendorid from  '
                                . $focus->table_name . ' where ' . $focus->table_index . '= ? )';
                            $vendor_result = $adb->pquery($vendorsql, array($recordid));
                            $vendorname = '';
                            $vendorname_message = '';
                            if ($adb->num_rows($vendor_result)) {
                                $vendorname = $adb->query_result($vendor_result, 0, 0);
                                if (!empty($vendorname)) {
                                    $vendorname_message = getTranstab('Vendors') . '：' . $vendorname;
                                }
                            }
                            $RemindsContent = getUserlastName($current_user). "将" . $oldsmownerlastname . '的' . getTranstab($module) . '分配给您，请及时关注！' . $vendorname_message;
                            $email_content[] = $current_user->last_name . "将" . $oldsmownerlastname . '的' . getTranstab($module) . '(' . $subject[$recordid]['subject'] . ')' . '分配给您，请及时关注！' . $vendorname_message;
                        } else {
                            $RemindsContent = getUserlastName($current_user) . "将" . $oldsmownerlastname . '的' . getTranstab($module) . '分配给您，请及时关注！';
                            $email_content[] = $current_user->last_name . "将" . $oldsmownerlastname . '的' . getTranstab($module) . '(' . $subject[$recordid]['subject'] . ')' . '分配给您，请及时关注！';
                        }
                        //客户、销售机会变更，发送短信提醒
                        if ($module == 'Potentials') {
                            $focus->receivecontent = '有销售机会[' . $subject[$recordid]['subject'] . ']分配给您，请及时关注！' . '【' . $autograph . '】';
                        } else if ($module == 'Accounts') {
                            $focus->receivecontent = '有客户[' . $subject[$recordid]['subject'] . ']分配给您，请及时关注！' . '【' . $autograph . '】';
                        }
                        $focus->id = $recordid;//26101: 服务收费管理和服务合同分配提醒问题
                        $tmpremindsid[] = $focus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $smownerid, $recordid);

                        $focus->id = 0;//26101: 服务收费管理和服务合同分配提醒问题
                    }

                    //工作流程反写
                    $pagemode = 'Allocated';
                    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
                    $workflowreverseobj = cls_savereverse::getInstance($module);
                    $workflowreverseobj->setPageMode($pagemode);
                    $workflowreverseobj->getInfo();

                    if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
                        $afterfieldvalue_arr = $col_fields;

                        $workflowreverseobj->setRecord($recordid);
                        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                    }


                }
                else {
                    $edit_err .= sprintf($batchlog, '<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject[$recordid]['subject'] . '</a>', $batchtype, $batchtype) . '<br/>';
                    $error++;
                }

                if(!isset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct']))
                {
                    $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct']=0;
                }
                $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct']+=$correct;
                $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['edit_err'].=$edit_err;

                if ($error == 0) {
                    $error = count($this->allrecordids) - $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'] - count($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allocated_crmid_arr']);//去重的不算错误
                }

                if ($_REQUEST['changetype'] == 'Allocate')//批量分配
                {
                    //editor:gyq_165 reason:钉钉消息提醒类型，分配提醒   2019/12/30 11:57
                    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/MessageCorpconversation.php");
                    $remind = new MessageCorpconversation();
                    $remind->setRemindType();
                    //有n条$客户$分配给您，敬请关注！点击查看$客户$列表
                    if ($remind->installWX || $remind->installDing || $remind->installYzj||$remind->judgeOffiaccount()=='yes') {

                        $sql = 'select wx_userid,dingtalk_userid,yunzhijia_openid from ld_users  where id=? and push_wx_reminds=1';
                        $tmpuserresult = $adb->pquery($sql, array($smownerid));
                        $wx_userid = $adb->query_result($tmpuserresult, 0, 'wx_userid');
                        $dingtalk_userid = $adb->query_result($tmpuserresult, 0, 'dingtalk_userid');
                        $yunzhijia_openid = $adb->query_result($tmpuserresult, 0, 'yunzhijia_openid');
                        //移动端-设置页签-“推送消息提醒”参数关闭应不发送提醒
                        $tmprows = $adb->num_rows($tmpuserresult);
                        //zkt 20220427 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                        //增加移动端提醒标题
                        $tmpremindtitle = sprintf(getFixedLabel('MODULEALLOCATEREMIND'),getTranstab($module));//【模块名称】分配提醒
                        if ($tmprows>0&&(!empty($wx_userid) || !empty($dingtalk_userid)||$remind->judgeOffiaccount()=='yes')) {

                            $modulelabel = getTranstab($module);
                            $allocatecount = sizeof($tmpremindsid);

                            if (sizeof($tmpremindsid) > 1) {

                                $RemindsContent = '有' . $allocatecount . '条' . $modulelabel . '分配给您，敬请关注！点击查看' . $modulelabel . " 列表";
                                $tmfocus = new CRMEntity();
                                $tmfocus->moduleName=$module;
                                $parenttmpremindid = $tmfocus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $smownerid, $recordid);


                                $sql = 'update ld_reminds set status_rmd=?,deleted=?,wxremindstype=? where remindsid=?';
                                $adb->pquery($sql, array('已读', 1, 'immediately', $parenttmpremindid));

                                $sql = 'update ld_reminds set push_to_weixin=3,push_time=?, parentid=?,remindstype=?,wxremindstype=? where remindsid in( ' . implode(',', $tmpremindsid) . ') ';
                                $adb->pquery($sql, array(date("Y-m-d H:i:s"), $parenttmpremindid, 'massallocate', 'immediately'));

                                $r_multi_content = array(
                                    array(
                                        'message' => $RemindsContent,
                                        'reltab' => $module,
                                        'related_to' => $parenttmpremindid,
                                        'date_time' => date("Y-m-d H:i:s"),
                                        'remindtype' => 'massallocate',
                                        'title' => $tmpremindtitle,
                                    )
                                );
                                if(!empty($wx_userid)){
                                    $r_multi_content[0]['userid'] = array($wx_userid);
                                }
                                if(!empty($dingtalk_userid)){
                                    $r_multi_content[0]['userid_ding'] = array($dingtalk_userid);
                                }
                                if(!empty($yunzhijia_openid)){
                                    $r_multi_content[0]['userid_openid'] = $yunzhijia_openid;
                                }
                                //zxm 20221116 公众号提醒消息单独请求
                                if($remind->judgeOffiaccount()=='yes'){
                                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                                    $offiaccount_remind = new cls_reminds_offiaccount();
                                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately(array($parenttmpremindid),'massallocate',$subject);
                                }
                                //企业微信/自建应用 钉钉 云之家
                                if(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid)) {
                                    $errorno = $remind->sendAllTypeRemindsImmediately(array($parenttmpremindid), $r_multi_content, 'massallocate', $subject);
                                }
                            } else//单个分配
                            {
                                $sql = 'update ld_reminds set remindstype=?,wxremindstype=? where remindsid in( ' . implode(',', $tmpremindsid) . ') ';
                                $adb->pquery($sql, array('', 'immediately'));
                                $r_multi_content = array(
                                    array(
                                        'message' => $RemindsContent,
                                        'reltab' => $module,
                                        'related_to' => $recordid,
                                        'date_time' => date("Y-m-d H:i:s"),
                                        'remindtype' => 'allocate',
                                        'title' => $tmpremindtitle,
                                    )
                                );
                                if(!empty($wx_userid)){
                                    $r_multi_content[0]['userid'] = array($wx_userid);
                                }
                                if(!empty($dingtalk_userid)){
                                    $r_multi_content[0]['userid_ding'] = array($dingtalk_userid);
                                }
                                if(!empty($yunzhijia_openid)){
                                    $r_multi_content[0]['userid_openid'] = $yunzhijia_openid;
                                }
                                //zxm 分配模板 业务分配提醒
                                //zxm 20221116 公众号提醒消息单独请求
                                if($remind->judgeOffiaccount()=='yes'){
                                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                                    $offiaccount_remind = new cls_reminds_offiaccount();
                                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($tmpremindsid,'massallocate',$subject);
                                }
                                //企业微信/自建应用 钉钉 云之家
                                if(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid)) {
                                    $errorno = $remind->sendAllTypeRemindsImmediately($tmpremindsid, $r_multi_content, 'massallocate', $subject);
                                }
                            }
                        }


                    }

                }
            }


            $userid=$smownerid;//  eg:1  105

        }

        if (is_array($successids) && sizeof($successids) > 0)
            $focus->massChangeUser_after($module, $successids, $_REQUEST['changetype']);

        if (isset($_SESSION['lvs'][$module]['viewname'])) {
            $viewid = $_SESSION['lvs'][$module]['viewname'];
            $pagestart = $_SESSION['lvs'][$module][$viewid]['start'];
        }

        if (!$pagestart) $pagestart = 1;

//        $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
//        $submitlog = sprintf($submitlog, count($this->allrecordids), $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'], $error);
        $submitlog = "共选择 ".count($this->allrecordids)." 条记录，成功提交 ".(int)$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct']." 条，失败 ".(int)$error." 条，去重 ".count($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allocated_crmid_arr'])." 条。";
        $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'. $submitlog . '</div></div>';


        foreach($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'] as $userid =>$value){
            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($userid),$value)."<br>";
        }


        $arr['title'] = getVarFixedLabel('CHANGECREATED', $smownerid_fieldlabel);// 确认
        $arr['progresstitle'] = getFixedLabel('AUTODISTRIBUTION')."(".$smownerid_fieldlabel.")";
        $arr['start'] = $start;//进度条开始处理的第几个
        $arr['end'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end'];
        $arr['total'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['total'];
        $percent = floor($arr['end']/($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['total'])*100);//NAN时,无法json_encode
        if (is_nan($percent)) $percent = 100;
        $arr['percent'] = $percent;
        $arr['error'] = $error;
        $arr['correct'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'];
        $arr['log'] = $submitlog ."<div class='pop_prc_content'>". $edit_err."</div>";//批量处理信息;
        $arr['pagestart'] = $pagestart;//当前列表的第几页
        $arr['SESSION'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']];


        if ($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['end'] < $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['total']){  //还未结束
            ConvertTojsonString(2, $arr, 'success');   //2 继续当前请求
        }else{
            unset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]);
            ConvertTojsonString(1, $arr, 'success');   // 结束
        }

    }
    
    protected function setsaveReturn($entity){}
    protected function set_AvgsaveReturn($entity)//平均分配后弹出层提示
    {

    }


    public function allocateCustomers($customerCount, $allocationRatios, $handlers) {
        $handlerCount = count($handlers);
        // 计算总的分配比例  防止总比例相加不是100%
        $totalRatio = array_sum($allocationRatios);

        // 计算每个负责人应该分配的客户数量
        $allocatedCustomers = [];
        $remainingCustomers = $customerCount;//四舍五入可能会出现，没有分配完的情况
        for ($i = 0; $i < $handlerCount; $i++) {
            $ratio = $allocationRatios[$i];
            $allocated = round($customerCount * $ratio / $totalRatio);
            $allocatedCustomers[] = $allocated;
            $remainingCustomers -= $allocated;
        }

        //重新分配剩余的客户
        for ($i = 0; $i < $handlers; $i++) {
            if ($remainingCustomers > 0) {
                $allocatedCustomers[$i]++;
                $remainingCustomers--;
            } else {
                break;
            }
        }


        //每个负责人最终相应的分配数量
        $allocation = [];
        for ($i = 0; $i < $handlerCount; $i++) {
            $handler = $handlers[$i];
            $customerCount = $allocatedCustomers[$i];
            $allocation[$handler] = $customerCount;
        }

        return $allocation;
    }

    public function splitArrayByLength($array, $allocatedCustomers) {
        $result = [];
        $startIndex = 0;

        foreach ($allocatedCustomers as $smownerid=>$customer) {
            $chunk = array_slice($array, $startIndex, $customer);
            $result[$smownerid] = $chunk;
            $startIndex += $customer;
        }

        return $result;
    }

    
}

?>