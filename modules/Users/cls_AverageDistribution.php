<?php
crm_load_class_file('cls_ChangeCreatorInfo','modules/Users');
crm_load_function_file('setAccount_Average_Group','modules/Accounts','averageComputer');
crm_load_function_file('getAverageUserName','modules/Accounts','averageComputer');
/**
 * 平均分配
 * 
 * */
class cls_AverageDistribution extends cls_ChangeCreatorInfo{
    private  $success;
    public $allocatepermit;
    public $selectindex;
    public $smownerids;

    public function __construct($setype)
    {
        // crm_load_class_file('ModTracker', 'modules/ModTracker');
        $this->setype = $setype;
        $this->original_changetype = $_REQUEST['changetype'];//记录操作日志，区分是分配还是平均分配

        $_REQUEST['changetype'] = 'Allocate';
        $_REQUEST['fld_module']=$_REQUEST['from_module'];

        $this->allocatepermit= isPermitted($_REQUEST['fld_module'], $_REQUEST['changetype']);
        parent::__construct($setype);
        
    }
    public function setChangeOperation(){
        $this->selectindex=-1;
       $this->save();
    }
     /*public function setpublicAccountCount($module,$recordid)
     {
     }*/
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
    
        $caterorid = $_REQUEST['caterorid'];//分配弹出层中勾选的用户
        $this->smownerids = explode(',', $caterorid);//将勾选的用户ID转换为数组
    
        $smownerid_count = count($this->smownerids);//勾选的用户总数
        

        //获取批量处理数
        $deployarray = getSys_deploy(67);
        $btach_num = $deployarray['deploy_value'];
        $select_id_str = $_REQUEST['select_id']??'';
        $recordids = explode(',', $select_id_str);
        $success=count($recordids);//选中的客户条数
        
        if($success>$btach_num){//选择的客户大于系统参数批量修改上限
            for($j=$btach_num;$j<=max(array_keys($recordids));$j++){
                unset($recordids[$j]);//删除超出分配条数范围的客户
            }
        }

         // @edit:liushuai,2021-03-03,reason:【ID1001390】批量平均分配增加显示进度条
         $startrow = $_REQUEST['startrow'];
         $endrow = $_REQUEST['endrow'];
         if(!isset($_REQUEST['endrow']))
         {
             $endrow = count($recordids);
         }
          if($startrow==0||!isset($_REQUEST['startrow']))
          {
            unset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]);
          }
          $allrecordids = $recordids = $this->getSelectRecordIds();
          if(sizeof($recordids)>$btach_num)
            {
               
                $recordids=array_slice($recordids,0,$this->btach_num);
            }
         if($startrow==0||!isset($_REQUEST['startrow']))
         {
             $startrow=0;
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']=$allrecordids;
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid']=$recordids;
             $this->focus->getModuleStatic('ModTracker');//操作日志
             $this->focus->modstatic->saveOperationLog($module,'',$this->original_changetype,'');
             $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'] = $adb->getLastInsertID();
            
         }
         if (count($recordids)>1) {
             $new_recordids = array_slice($recordids,$startrow,$endrow-$startrow);
         }

         $this->success=$success;
         $this->recordids=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid'];
         $this->allrecordids=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'];
         $this->Account_Average_Group = setAccount_Average_Group($new_recordids,$this->smownerids);//将客户,按用户个数平均分组  通过开始行  结束行截取

        //array_chunk($recordids,$this->Account_Group_Nums);
      
     }
    public function getSelectRecordIds()
    {
        global $current_user;
        $module=$this->fld_module;
    
        if($this->selectindex==-1)
        {
            $this->selectindex++;
            if($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'])
            {
          
                return $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid'];
            }
            else
                return parent::getSelectRecordIds();
        }
        else
        {
            return $this->Account_Average_Group[$this->selectindex];
        }
    }
    public function getUserId()
   {
    $_REQUEST['caterorid']=$this->smownerids[$this->selectindex];
     return $this->smownerids[$this->selectindex];
   }
    public  function save(){
        $this->requirefile();
        global $adb, $current_user, $languageType;
        $focus = $this->focus;
        $module = $this->fld_module;
        require_once  globalStatic::$root_directory.'modules/Users/Group.class.php';
        $group_focus = new Group();
        $this->setAccount_Smowner();//获取后设置没有用户所分配的客户
        // @edit:liushuai,2021-03-03,reason:【ID1001390】批量平均分配增加显示进度条
        /*//陌远
        $versionInfo = getVersionInfo();
        if($versionInfo['account'] == "moyuan") {
            include_once globalStatic::$root_directory . 'modules/Home/CustomMade/MoyuanUtils.php';
            $moyuan_obj = new MoyuanUtils();
        }*/

        if ($this->fld_module == 'Accounts' || $this->fld_module == 'Potentials') {
            $SMSarray = GetSMSAutograph();
            $autograph = $SMSarray['autograph'];
        }
        $operation_logid = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'];

        /*
         * editor:gyq_07
         * reason:根据changtype判断是更改负责人还是创建者
         * date :2016 3 11
         * */
        if ($_REQUEST['changetype'] == 'Allocate') {
            $smcolumnname = $focus->getSmownerColumName();
//            $smcolumnname= $_REQUEST['from_module']=='ServiceCharge'?'servicecasher':'smownerid';//服务收费人平均分配后，确定后弹出看显示分配负责人
        } elseif ($_REQUEST['changetype'] == 'ChangeCreator') {
            $smcolumnname = $focus->getCreateColumnName();
        }


        foreach($this->Account_Average_Group as $accountids)
        {
            $idlist = $this->getIdList();
            $email_content = array();
            $correct = 0;
            $error = 0;
//            $judge = [];
            //获取批量处理数

            $btach_num = $this->btach_num;
            $fieldobj = Field::getInstance($module, $adb);
            $creator[] = $fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);

            $edit_err = '';


            $entityarray = getEntitynameInfo(getTabid($module));
            $tabname = $entityarray['tablename'];
            $tabindex = $entityarray['entityidfield'];
            $tabfieldname = $entityarray['fieldname'];
            $smownercolumnname = $focus->getSmownerColumName();//$focus->fieldobj->getFieldInfoBykeyValue('columnname',$focus->getSmownerColumName(),'columnname');
            $smownerfieldname = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $smownercolumnname, 'fieldname');
            $smcreatorcolumnname = $focus->getCreateColumnName();
            $smcreatorfieldname = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $smcreatorcolumnname, 'fieldname');

            $isexistrequirefield = $this->isRequiredFieldRule();

            $tmpremindsid = array();

            $fieldruleobj = cls_fieldrule::getInstance($this->fld_module);
            if (isset($idlist)) {
                $batchlog = getFixedLabel('DOCUMENTNOSUCCESS');
//            $batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
                $batchsuccesslog = getFixedLabel('AVERAGE_PROMPT');
                $avgsuccesslog = getFixedLabel('AVERAGE_PROMPT');
                $dellog = getFixedLabel('thedocumenthasbeendeleted');
                $batchtype = getFixedLabel('CHANGE') . $creator[0]->getFieldLabel();
                $batcherrorlog = getFixedLabel('AllocateSmownerError');
                $batreachmax = getFixedLabel('ALLOCATERREACHMAXCUSTOMER');
                if ($module == 'Accounts' || $module == 'ServiceCharge') {
                    $batreachmax_common = $this->public_account['status'] == 'yes'?getFixedLabel('ALLOCATERREACHMAXCUSTOMERError1'):getFixedLabel('ALLOCATERREACHMAXCUSTOMERError');//普通客户分配上限提示内容
                } else if($module=='Leads') {
                    $batreachmax_common = $this->public_account['status'] == 'yes'?getFixedLabel('ALLOCATERREACHMAXLeadsError1'):getFixedLabel('ALLOCATERREACHMAXLeadsError');
                }

                /*editor:gyq_07 reason:已准确获取负责人或创建人字段名，无需判断 date:2016 3 11  */
                $columname = $smcolumnname;

                $assigned = $creator[0]->getFieldName();

                /* editor:gyq_07 reasom:适配分配 */
                $fields = $focus->fieldobj->getModuleAllPreseneceFields();
                if ($this->havebtnPermit() == 'yes') {
                    $recordids = $accountids;
                    $rows = count($recordids);
                    if(!isset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$this->getUserId()])){
                        $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$this->getUserId()] = 0;
                    }
                    for ($index = 0; $index < $rows; ++$index) {
                        if ($btach_num <= $index) break;
                        $recordid = $recordids[$index];
                        if ($recordid == '') continue;

                        $crmid = $recordids[$index];// $adb->query_result($result, $i, $tabindex);
                        $focus->retrieve_entity_info($crmid, $this->fld_module);

                        //工作流程获取改变前字段值
                        $beforefieldvalue_arr = $this->focus->column_fields;

                        $col_fields = $focus->column_fields;
                        $col_fields['db_' . $smownerfieldname] = $col_fields[$smownerfieldname];
                        $col_fields['db_' . $smcreatorfieldname] = $col_fields[$smcreatorfieldname];

                        if ($_REQUEST['changetype'] == 'Allocate')
                            $col_fields[$smownerfieldname] = $this->getUserId();
                        else
                            $col_fields[$smcreatorfieldname] = $this->getUserId();
                        $error = 'no';
                        if ($isexistrequirefield == 'yes' && $_REQUEST['changetype'] == 'Allocate') {

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

                        if ($module == 'Accounts' || $module == 'ServiceCharge') {
                            $pool_id=$this->setpublicAccountCount($module, $recordid);
                        }
                        else if($module=='Leads')
                        {
                            $pool_id=$focus->setpublicLeadsCount($this, $recordid);
                        }
                        if ($pool_id == -1) { //$pool_id  返回值包括成功返回pool_id，失败返回错误提示标识 -1：公海已分配上限提示 -2 普通客户上限提示。
                            $edit_err .= sprintf($batreachmax, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $col_fields[$focus->list_link_field] . '</a>', $batchtype, getUserFullName($_REQUEST['caterorid'])) . '<br>';
                            $errorstr = 'yes';
                            $error++;
                        } elseif ($pool_id == -2) {
                            //单据【分配测试11】更改销售负责人失败！原因：单据负责人【张三】普通客户数量已经达到上限！
                            $edit_err .= sprintf($batreachmax_common, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $col_fields[$focus->list_link_field] . '</a>', $batchtype, getUserFullName($_REQUEST['caterorid'])) . '<br>';
                            $errorstr = 'yes';
                            $error++;
                        }

                        if ($errorstr == 'yes') {
                            continue;
                        }

                        // $edit_err .= sprintf($batchsuccesslog, '<a href="index.php?module='.$this->fld_module.'&action=DetailView&record=' . $crmid . '"  target="_black" >' . $col_fields[$focus->list_link_field] . '</a>') . '<br>';
                        $subject[$crmid]['subject'] = $col_fields[$focus->list_link_field];// $adb->query_result($result, $i, 'subject');
                        //zxm crm小程序 推送消息到公众号的  获取单据编号
                        $subject[$crmid]['table_code'] = $col_fields[$focus->table_code];//编号
                        $subject[$crmid]['smcreatorid'] = $col_fields['db_' . $smcreatorfieldname];// $adb->query_result($result, $i, 'smcreatorid');
                        // $subject[$crmid]['accountid'] = $adb->query_result($result, $i, 'accountid');
                        if ($focus->fieldobj->getFieldInfoobjBykey("columnname", 'accountid')) {
                            $subject[$crmid]['accountid'] = $col_fields['account_id'];
                        } else {
                            $subject[$crmid]['accountid'] = 0;
                        }
                        $subject[$crmid]['smownervalue'] = $col_fields['db_' . $smownerfieldname];;// $adb->query_result($result, $i, 'smownervalue');

                        //$edit_err .= sprintf($dellog, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $subject[$recordid]['subject'] . '</a>', $batchtype) . '<br/>';

                        //0025874: 销售机会：分配单据后，明细界面查看“分配日期”，分配日期字段后显示为空
                        if ($module == 'Potentials') {
                            $allocated_time = date("Y-m-d");
                            $adb->pquery("UPDATE ld_potential set allocated_time=? where potentialid=?", array($allocated_time, $recordid));
                            //2020-1228 zxm 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
                            /*if($versionInfo['account'] == "moyuan"){
                                $judge = $moyuan_obj->judgePotentials('Allocate',$this->getUserId(),$recordid);
                                if($judge['code'] == -1){
                                    $edit_err .= '单据【'.'<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject[$recordid]['subject'] . '</a>】'.$judge['msg'] . '<br/>';
                                    continue;
                                }
                            }*/
                        }
                        $successids[] = $recordid;
                        $sql = 'update ' . $focus->table_name . ' set ' . $creator[0]->getColumnName() . ' = ?,modifiedtime=? where ' . $focus->table_index . ' = ? ';
                        $adb->pquery($sql, array($this->getUserId(),date('Y-m-d H:i:s'), $recordid));
                        $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$this->getUserId()]++;//分配可能达到上限，故改为逐条记录。

                        //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）
                        if ($_REQUEST['changetype'] == 'Allocate') {
                            $depInfo = $group_focus->getUserGroup($this->getUserId());//变更后的负责人
                            ksort($depInfo);
                            $depId = implode(',',array_keys($depInfo));//部门id
                            foreach($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
                            {
                                //wym XUQIU1000290 平均分配单据时,引用成员管理字段需要同时更新
                                if($tmp_fieldinfo->getrelatedmodulefield()=='yes'||$tmp_fieldinfo->getUIType() == 1600)
                                {
                                    $relateddata='ownerrelatedinfo_'.$this->getUserId();
                                    $relatedfielddata = array();
                                    if(!$this->$relateddata){
                                        crm_load_class_file('cls_RelatedField_Data','include/RelatedField');
                                        $cls_RelatedField_Data = new cls_RelatedField_Data($this->fld_module,$this->getUserId(),$smownercolumnname);
                                        $this->$relateddata=$cls_RelatedField_Data->getData();
                                    }
                                    $relatedfielddata = $this->$relateddata;
                                    foreach ($relatedfielddata as $related_info){
                                        $effect_fieldname=$related_info['rawValue']['input_name'];
                                        $tmp_effect_fieldinfo = $focus->fieldobj->FieldInfoListByKeyValue("fieldname", $effect_fieldname);
                                        if($tmp_effect_fieldinfo['savedatabase']=='yes'){//只有存数据库的值需要更新
                                            if($tmp_effect_fieldinfo['uitype']=='1109' || $tmp_effect_fieldinfo['uitype']=='69'){
                                                /*$selectsql="select * from ld_seattachmentsrel
                                                where crmid = ? AND attachmentcolumnname = '".$tmp_effect_fieldinfo['columnname']."' AND  EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)";
                                                $selectresult=$adb->pquery($selectsql, array($recordid, $this->getUserId()));*/
                                                $deletesql = "delete from ld_seattachmentsrel 
                                                where crmid = ? AND attachmentcolumnname = '".$tmp_effect_fieldinfo['columnname']."' AND  EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)";
                                                $result=$adb->pquery($deletesql, array($recordid, $this->getUserId()));
                                                foreach ($related_info['rawValue']['value'][$effect_fieldname] as $key=>$value){
                                                    $insertsql = "insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,'".$tmp_effect_fieldinfo['columnname']."')";
                                                    $adb->pquery($insertsql, array($recordid, $value['fileid']));
                                                }
                                            }else{
                                                $updatesql = 'update ' . $tmp_effect_fieldinfo['tablename'] . ' set ' . $tmp_effect_fieldinfo['columnname']
                                                    . ' = ? where ' . $focus->table_index
                                                    . ' = ? AND EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)' ;
                                                $adb->pquery($updatesql, array($related_info['rawValue']['value'], $recordid, $this->getUserId()));
                                            }
                                        }
                                    }
                                    break;
                                }
                            }
                        }
//                        $edit_err .= sprintf($batchsuccesslog, '<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject[$recordid]['subject'] . '</a>', $batchtype) . '<br/>';


                        $correct++;
                        if($_REQUEST['changetype'] == 'ChangeCreator')
                        {
                            if ($this->getUserId() != $subject[$recordid]['smcreatorid']) {
                                $focus->getModuleStatic('ModTracker');//字段修改日志

                                $focus->modstatic->saveFieldLogOne($module, $assigned, $recordid,
                                    $subject[$recordid]['smcreatorid'], $this->getUserId(), $operation_logid);
                            }

                        }
                        else{
                            if ($this->getUserId() != $subject[$recordid]['smownervalue']) {
                                $focus->getModuleStatic('ModTracker');//字段修改日志

                                $focus->modstatic->saveFieldLogOne($module, $assigned, $recordid,
                                    $subject[$recordid]['smownervalue'], $this->getUserId(), $operation_logid);
                                //系统操作日志-分配
                                crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
                                cls_OperationLogs::saveLogs($module,'Allocate',$recordid,'',staticModTracker::$lastinsertid);
                            }

                            if ($module == 'Accounts' || $module == 'ServiceCharge') {
                                if(!empty($pool_id))
                                {
                                    //edit:can 2020-12-28 43954: 分配公海客户的时候，保护截止日期没有更新
                                    $ruleinfo=getAccount_set_rule('complete',$pool_id);
                                    $focus->updateAccountInfo($ruleinfo[0]['tabname'],$recordid);
                                }

                            }
                            else if($module=='Leads')
                            {
                                if(!empty($pool_id))
                                {
                                    //edit:can 2020-12-28 43954: 分配公海客户的时候，保护截止日期没有更新
                                    $ruleinfo=getLeads_set_rule('complete',$pool_id);
                                    $focus->updateAccountInfo($ruleinfo[0]['tabname'],$recordid);
                                }
                            }

                        }
                        //	0033967: （1.6登录）将销售负责人为自己的单据分配给自己时，也应该收到分配提示消息   editor:gyq 20180702
                        if ($_REQUEST['changetype'] == 'Allocate' && $subject[$recordid]['smownervalue'] != $this->getUserId()) {
                        // if ($_REQUEST['changetype'] == 'Allocate') {
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
                            $tmpremindsid[] = $focus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $this->getUserId(), $recordid);

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
                    $error = count($this->allrecordids) - $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'];
                }

                if ($_REQUEST['changetype'] == 'Allocate')//批量分配
                {
                    //editor:gyq_165 reason:钉钉消息提醒类型，分配提醒   2019/12/30 11:57
                    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/MessageCorpconversation.php");
                    $remind = new MessageCorpconversation();
                    $remind->setRemindType();
                    //有n条$客户$分配给您，敬请关注！点击查看$客户$列表
                    if ($remind->installWX || $remind->installDing || $remind->installYzj || $remind->installZy ||$remind->judgeOffiaccount()=='yes' || $remind->installFanwei) {

                        $sql = 'select wx_userid,dingtalk_userid,yunzhijia_openid,zhiyuan_userid,fanwei_userid from ld_users  where id=? and push_wx_reminds=1';
                        $tmpuserresult = $adb->pquery($sql, array($this->getUserId()));
                        $wx_userid = $adb->query_result($tmpuserresult, 0, 'wx_userid');
                        $dingtalk_userid = $adb->query_result($tmpuserresult, 0, 'dingtalk_userid');
                        $yunzhijia_openid = $adb->query_result($tmpuserresult, 0, 'yunzhijia_openid');
                        $zhiyuan_userid = $adb->query_result($tmpuserresult, 0, 'zhiyuan_userid');
                        $fanwei_userid = $adb->query_result($tmpuserresult, 0, 'fanwei_userid');

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
                                $parenttmpremindid = $tmfocus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $this->getUserId(), $recordid);


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
                                        'received_id' => $this->getUserId(),
                                        'remindsid' => implode(',', $tmpremindsid),
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
                                /*if(!empty($zhiyuan_userid)){
                                    $r_multi_content[0]['userid_zhiyuan'] = $zhiyuan_userid;
                                }*/
                                if(!empty($fanwei_userid)){
                                    $r_multi_content[0]['userid_fanwei'] = $fanwei_userid;
                                }
                                //zxm 20221116 公众号提醒消息单独请求
                                if($remind->judgeOffiaccount()=='yes'){
                                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                                    $offiaccount_remind = new cls_reminds_offiaccount();
                                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately(array($parenttmpremindid),'massallocate',$subject);
                                }
                                //企业微信/自建应用 钉钉 云之家
                                if(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid) || !empty($zhiyuan_userid) || !empty($fanwei_userid)) {
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
                                        'received_id' => $this->getUserId(),
                                        'remindsid' => implode(',', $tmpremindsid),
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
                                /*if(!empty($zhiyuan_userid)){
                                    $r_multi_content[0]['userid_zhiyuan'] = $zhiyuan_userid;
                                }*/
                                if(!empty($fanwei_userid)){
                                    $r_multi_content[0]['userid_fanwei'] = $fanwei_userid;
                                }
                                //zxm 分配模板 业务分配提醒
                                //zxm 20221116 公众号提醒消息单独请求
                                if($remind->judgeOffiaccount()=='yes'){
                                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                                    $offiaccount_remind = new cls_reminds_offiaccount();
                                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($tmpremindsid,'massallocate',$subject);
                                }
                                //企业微信/自建应用 钉钉 云之家
                                if(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid)|| !empty($zhiyuan_userid)|| !empty($fanwei_userid)) {
                                    $errorno = $remind->sendAllTypeRemindsImmediately($tmpremindsid, $r_multi_content, 'massallocate', $subject);
                                }
                            }
                        }


                    }
                    /*if($versionInfo['account'] == "moyuan"&&$module == 'Leads') {
                        $moyuan_obj->emailLeadsForSave($_REQUEST['changetype'],$_REQUEST['select_id']);
                    }*/
                }
            }


            //单据分配时是否发送邮件通知负责人
            $sys = getSys_deploy(145);
            if ($sys['deploy_value'] == 1) {

                if (!empty($email_content)) {
                    crm_load_class_file('cls_email', 'include/Email');
                    if (count($recordids) > 1) {
                        $content = implode('<br>', $email_content);
                        cls_email::send_email($content, 'Users', $this->getUserId());
                    } else {
                        foreach ($email_content as $content) {
                            cls_email::send_email($content, 'Users', $this->getUserId());
                        }
                    }
                }
            }

            /* editor:gyqX16526 reason:调用反写函数 date:2016.5.26 */
            if ($_REQUEST['changetype'] == 'Allocate' && $module == 'ContactRecords') {
                $accountidArr = array();
                foreach ($subject as $key => $item) {
                    $accountidArr[] = $subject[$key]['accountid'];
                }

                if (count($accountidArr) > 0) {
                    //gyq161214
                    require_once(globalStatic::$root_directory . 'modules/ContactRecords/ContactRecords.php');
                    $focus = new ContactRecords();

                    $focus->updateRelatedTableInfo('ld_account', $accountidArr);
                }

            }


          


            $userid=$this->getUserId();//  eg:1  105
//            $Account_Average[$userid]=$accountids;
//            $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'][$userid] += count($accountids);
            $this->selectindex++;

        }
        //edit；can 20220531 客户问题（智家），客户（灵当测试数据）勾选单据平均分配后，跟进记录负责人会将分配客户时勾选的负责人都分配一次（通用问题） 
          if (is_array($successids) && sizeof($successids) > 0)
                $focus->massChangeUser_after($module, $successids, $_REQUEST['changetype']);

        if (isset($_SESSION['lvs'][$module]['viewname'])) {
            $viewid = $_SESSION['lvs'][$module]['viewname'];
            $start = $_SESSION['lvs'][$module][$viewid]['start'];
        }

        if (!$start) $start = 1;

//        $entity['moyuan_msg'] = $judge;//moyuan  1228 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
//        $entity['errorcount'] = $error;
//        $entity['log']['value'] = $table . "<div class='pop_prc_content'>" . $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['edit_err'] . "</div>";//批量处理信息

        $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
        $submitlog = sprintf($submitlog, count($this->allrecordids), $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'], $error);
        $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'. $submitlog . '</div></div>';

        /*foreach($Account_Average as $userid =>$value){
            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($userid),count($Account_Average[$userid]))."<br>";
        }*/
        foreach($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['Account_Average'] as $userid =>$value){
            $edit_err .= sprintf($batchsuccesslog,getAverageUserName($userid),$value)."<br>";
        }
        $entity['recordids'] = $this->recordids;
        $entity['error'] = $error;
        $entity['correct'] = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'];

        $entity['log']['value'] = $submitlog ."<div class='pop_prc_content'>". $edit_err."</div>";//批量处理信息
        $entity['start']['value'] = $start;//当前页数
        $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
        $field = $focus->fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);
        $entity['title']['value'] = getVarFixedLabel('CHANGECREATED', $field->getFieldLabel());// 确认


        $this->set_AvgsaveReturn($entity);
    }
    
    protected function setsaveReturn($entity){}
    protected function set_AvgsaveReturn($entity)//平均分配后弹出层提示
    {
        global $current_user;

        $module=$_REQUEST['from_module'];//
        if($_REQUEST['mode']=='list')
        {
            $entity['maxrows']=sizeof($this->recordids);
            $entity['selectrows']=sizeof($this->allrecordids);

            $focus=CRMEntity::getInstance($module);

            $smownercolumnname=$focus->getSmownerColumName();
            $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldlabel');
            $entity['progresstitle']=getFixedLabel('AVERAGEDISTRIBUTION')."(".$fieldlabel.")";

            $endrow = $_REQUEST['endrow'];
            if($endrow >= sizeof($this->recordids))
            {
                unset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]);
            }
        }

        ob_clean();
        ob_flush();
        $_REQUEST['diony'] = 'yes';
        ConvertTojsonString(1,$entity,"success");
    }

    
    
}

?>