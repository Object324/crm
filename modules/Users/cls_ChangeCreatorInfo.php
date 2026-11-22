<?php


class cls_ChangeCreatorInfo
{
    public $focus;
    public $setype;
    public $fld_module;
    public $btach_num;
    public $original_changetype;
    public $addreminds_relatedto_linkarr = [];
    public $relateddata;
    public $relatedinfoset_arr = [];// 分配相关信息的设置
    public $public_account;
    public function __construct($setype)
    {
        crm_load_class_file('ModTracker', 'modules/ModTracker');
        $deployarray = getSys_deploy(67);
        $this->btach_num = $deployarray['deploy_value'];
      
        $this->setype = $setype;
        if ('opts' == $this->setype) {//获取下拉框值
            $this->fld_module = $_REQUEST['fld_module'];
        } else {
            $this->fld_module = $_REQUEST['from_module'];
        }
		if($this->fld_module == 'Accounts'){
			crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
			$cls_PublicAccounts = new cls_PublicAccounts($this->fld_module);
			$this->public_account = $cls_PublicAccounts->getPublicAccountConfig();
		}
        if($this->fld_module == 'Leads'){
			crm_load_class_file('cls_PublicLeads', 'modules/Leads');
			$cls_PublicAccounts = new cls_PublicLeads($this->fld_module);
			$this->public_account = $cls_PublicAccounts->getPublicAccountConfig();
		}
        $this->setFocus();
    }

    public function setChangeOperation()
    {
        if ('opts' == $this->setype)//获取下拉框值
        {
            $this->getUserselectOptions();
        } else {
            $this->save();
        }
    }

    private function setFocus()
    {
        $this->focus = CRMEntity::getInstance($this->fld_module);
    }

    private function getUserselectOptions()
    {
        ConvertTojsonString(-1,array(),getUserSelectOptions($this->fld_module));
    }

    public function getIdList()
    {
        $idlist = vtlib_purify($_REQUEST['select_id']);
        return $idlist;
    }

    public function getUserId()
    {

        return $_REQUEST['caterorid'];

    }

    /**
     * 获取所选择单据Id
     * */
    public function getSelectRecordIds()
    {
        $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
        $idlist = $this->getIdList();
        if ($idlist == 'all') {
            //26613: 分配：全选列表界面数据，点击“全选所有N条记录”，设置上限为20条，分配完成后给出的提示信息条数有误：
            //先注释，等我想到办法才修改
            //$_REQUEST['mass_batch_num_all']=$this->btach_num;
            $idArr = getSelectedRecords($_REQUEST, $this->fld_module, rtrim($idlist, ';'), $excludedRecords);
        } else
            $idArr = explode(';', rtrim($idlist, ';'));
        $recordids = array_values($idArr);
        return $recordids;
    }

    /**
     * 判断按钮权限
     * */
    public function havebtnPermit()
    {
        return isPermitted($this->fld_module, $_REQUEST['changetype'], $recordid);
    }

    public function requirefile()
    {

    }

    public function isRequiredFieldRule()
    {

        $focus = CRMEntity::getInstance($this->fld_module);
        $smownercolumnname = $focus->getSmownerColumName();
        crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
        $fieldruleobj = cls_fieldrule::getInstance($this->fld_module);

        $allfieldrule = $fieldruleobj->getAllRules();//布局规则必填项
        if (array_key_exists($smownercolumnname, $allfieldrule)) {
            $triggeroperatecolumns = $fieldruleobj->getAllTriggerOperate();
            //获取触发字段（负责人是否设置必填字段）
            foreach ($triggeroperatecolumns[$smownercolumnname] as $basicsearchid => $triggerinfo) {
                if ($triggerinfo['type'] == 'required') {
                    return 'yes';
                }
            }
            //exit();
            //return 'yes';
            return 'no';
        } else {
            return 'no';
        }

    }

    public function save()
    {
        $this->requirefile();
        global $adb, $current_user, $languageType;
        $focus = $this->focus;
        $module = $this->fld_module;
        require_once  globalStatic::$root_directory.'modules/Users/Group.class.php';
        $group_focus = new Group();
        //陌远
        $versionInfo = getVersionInfo();
        if($versionInfo['account'] == "moyuan") {
            include_once globalStatic::$root_directory . 'modules/Home/CustomMade/MoyuanUtils.php';
            $moyuan_obj = new MoyuanUtils();
        }

        if ($this->fld_module == 'Accounts' || $this->fld_module == 'Potentials') {
            $SMSarray = GetSMSAutograph();
            $autograph = $SMSarray['autograph'];
        }
        /*
         * editor:gyq_07
         * reason:根据changtype判断是更改负责人还是创建者
         * date :2016 3 11
         * */
        if ($_REQUEST['changetype'] == 'Allocate') {
            $smcolumnname = $focus->getSmownerColumName();
        } elseif ($_REQUEST['changetype'] == 'ChangeCreator') {
            $smcolumnname = $focus->getCreateColumnName();
        }

        $idlist = $this->getIdList();
        $email_content = array();
        $return_action = 'index';
        $correct = 0;
        $error = 0;
        $judge = [];
        global $rstart;
        //获取批量处理数

        $btach_num = $this->btach_num;
        $fieldobj = Field::getInstance($module, $adb);
        $creator[] = $fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);

        $edit_err = '';
        $startrow=$_REQUEST['startrow'];
        $endrow=$_REQUEST['endrow'];
        if(!isset($_REQUEST['endrow']))
        {
            //平均分配没有做代码优化
            $endrow=99999999;
        }
        if($startrow==0||!isset($_REQUEST['startrow']))
        {
            $startrow=0;
            unset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]);
        }
        if($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid'])
        {
            //$recordids
           $recordids=$_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid'];
        }
        else
        {
            $recordids = $this->getSelectRecordIds();
            $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']=$recordids;
            if(sizeof($recordids)>$this->btach_num)
            {
               
                $recordids=array_slice($recordids,0,$this->btach_num);
            }
            
            $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid']=$recordids;

            if ($_REQUEST['changetype'] == 'Allocate') {
                $this->focus->getModuleStatic('ModTracker');//操作日志
                $this->focus->modstatic->saveOperationLog($module,'',$_REQUEST['changetype'],'');
                $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'] = $adb->getLastInsertID();
            }

        }
        $operation_logid = $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['operation_logid'];

    
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
            $batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
            $documenterror = getFixedLabel('documenterrorinfo');
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
            
            $this->addreminds_relatedto_linkarr = array();//批量分配时对应移动端提醒内容增加对应列表
            /* editor:gyq_07 reasom:适配分配 */
            $fields = $focus->fieldobj->getModuleAllPreseneceFields();
            $validata_errormsg = '';
            if ($this->havebtnPermit() == 'yes') {
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($this->fld_module,0,0);
                $PageValidataSaveobj->setApplication('allocated');
                $PageValidataSaveobj->batchoprate = 'yes';
                $errormsg_arr = [];

                $rows = count($recordids);
                for ($index = $startrow; $index < $rows&&$index<$endrow; ++$index) {

                    if ($btach_num <= $index) break;
                    $recordid = $recordids[$index];
                    if ($recordid == '') continue;

                    $crmid = $recordids[$index];// $adb->query_result($result, $i, $tabindex);
                    
                    $focus->retrieve_entity_info($crmid, $this->fld_module);

                    //工作流程获取改变前字段值
                    $beforefieldvalue_arr = $this->focus->column_fields;

                    //duan  20240429 XUQIU20240423-05 奥克兰：分配时判断验证规则
                    $PageValidataSaveobj->resetobj($module,$recordid);//重置验证规则对象
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->setNewSmownerid($this->getUserId());
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $validata_errormsg = $PageValidataSaveobj->errortip;
                        $edit_err .= sprintf($documenterror, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $this->focus->column_fields[$focus->list_link_field] . '</a>', $batchtype, $validata_errormsg) . '<br>';
                        $errorstr = 'yes';
                        $error++;
                        continue;
                    }

                    $col_fields = $focus->column_fields;
                    $col_fields['db_' . $smownerfieldname] = $col_fields[$smownerfieldname];
                    $col_fields['db_' . $smcreatorfieldname] = $col_fields[$smcreatorfieldname];

                    if ($_REQUEST['changetype'] == 'Allocate')
                        $col_fields[$smownerfieldname] = $this->getUserId();
                    else
                        $col_fields[$smcreatorfieldname] = $this->getUserId();
                    $errorstr = 'no';
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
                    //全部（含所有公海）页签下，批量分配只跟是否有分配权限有关，跟单据客户类型无关

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

                    //在这之前的代码全部为判断是否错误的逻辑
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
                        if($versionInfo['account'] == "moyuan"){
                            $judge = $moyuan_obj->judgePotentials('Allocate',$this->getUserId(),$recordid);
                            if($judge['code'] == -1){
                                $edit_err .= '单据【'.'<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject[$recordid]['subject'] . '</a>】'.$judge['msg'] . '<br/>';
                                continue;
                            }
                        }
                    }
                    $successids[] = $recordid;
                    $sql = 'update ' . $focus->table_name . ' set ' . $creator[0]->getColumnName() . ' = ?,modifiedtime=? where ' . $focus->table_index . ' = ? ';
                    $adb->pquery($sql, array($this->getUserId(),date('Y-m-d H:i:s'), $recordid));

                    //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）(重新分配（或批量）负责人或者更改创建人（或批量）时，更改成员所属部门字段，批量平均分配不走这里)
                    if ($_REQUEST['changetype'] == 'Allocate') {
                        //分配后更改成员所属部门字段，仅当负责人变更，所属部门字段启用并设置为assigned_user_id时
                        // if ($this->getUserId() != $subject[$recordid]['smownervalue']) { //批量分配前如果在页面的字段设置被更改过会有问题，故每次都更新成员所属部门
                        $depInfo = $group_focus->getUserGroup($this->getUserId());//变更后的负责人
                        // $depName = implode(',',$depInfo);//部门名
                        ksort($depInfo);
                        $depId = implode(',',array_keys($depInfo));//部门id
                        foreach($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
                        {
                            //wym XUQIU1000290 平均分配单据时,引用成员管理字段需要同时更新
                            //wym 240612 BUG20240612-16 批量分配时为了避免执行很多次sql 所以把更新引用成员字段内容放到了循环外 但由此引用成员字段工作流无法触发 现在重新放回循环
                            if($tmp_fieldinfo->getrelatedmodulefield()=='yes'||$tmp_fieldinfo->getUIType() == 1600)
                            {
                                $relateddata='ownerrelatedinfo_'.$this->getUserId();
                                $relatedfielddata = array();
                                if(!$this->relateddata){
                                    crm_load_class_file('cls_RelatedField_Data','include/RelatedField');
                                    $cls_RelatedField_Data = new cls_RelatedField_Data($this->fld_module,$this->getUserId(),$smownercolumnname);
                                    $this->relateddata=$cls_RelatedField_Data->getData();
                                }
                                $relatedfielddata = $this->relateddata;
                                crm_load_class_file('cls_MyCRMcrypt',"Register");
                                $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                                foreach ($relatedfielddata as $related_info){
                                    $effect_fieldname=$related_info['rawValue']['input_name'];
                                    $tmp_effect_fieldinfo = $focus->fieldobj->FieldInfoListByKeyValue("fieldname", $effect_fieldname);
                                    if($tmp_effect_fieldinfo['savedatabase']=='yes'){//只有存数据库的值需要更新
                                        if($tmp_effect_fieldinfo['uitype']=='1109' || $tmp_effect_fieldinfo['uitype']=='69'){
                                            $deletesql = "delete from ld_seattachmentsrel where crmid = ? AND attachmentcolumnname = '".$tmp_effect_fieldinfo['columnname']."' AND  EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)";
                                            $result=$adb->pquery($deletesql, array($recordid, $this->getUserId()));
                                            foreach ($related_info['rawValue']['value'][$effect_fieldname] as $key=>$value){
                                                $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id
                                                $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                                                $params1 = array($current_id, $this->fld_module . " Image");
                                                $adb->pquery($sql1, $params1);
                                                $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name, description, 
                                                        type, path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?, ?, ?, ?,?,?,?,?,?)";
                                                $params2 = array($current_id, $value['file_name'], $cls_MyCRMcrypt->decode($value['newfile_name']), "", $value['file_type'], $cls_MyCRMcrypt->decode($value['file_path']), $value['file_size'],
                                                    $value['imagefromtype'], $cls_MyCRMcrypt->decode($value['cloud_path']), $value['storage_location'], $value['upload_from']);

                                                $result = $adb->pquery($sql2, $params2);
                                                $sql3 = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                                                $adb->pquery($sql3, array($recordid, $current_id, $tmp_effect_fieldinfo['columnname']));
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
//                        }
                    }else{
//                        if ($this->getUserId() != $subject[$recordid]['smcreatorid']) {
                            $depInfo = $group_focus->getUserGroup($this->getUserId());//变更后的创建人
                            ksort($depInfo);
                            $depId = implode(',',array_keys($depInfo));//部门id
                            foreach($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
                            {
                                if($tmp_fieldinfo->getUIType() == 1600)
                                {
                                    $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                                    $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                                    if ($adb->num_rows($result_related_field) >= 1) {
                                        $tmp_trigger_fieldid = $adb->query_result($result_related_field,0,'trigger_fieldid');
                                        $sql_field = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                                        $result_field = $adb->pquery($sql_field, array($tmp_trigger_fieldid));
                                        if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field,0,'columnname') == $smcolumnname) {//触发字段为创建人
                                            $sql = 'update ' . $tmp_fieldinfo->getTableName() . ' set ' . $tmp_fieldinfo->getColumnName() . ' = ? where ' . $focus->table_index . ' = ? ';
                                            $adb->pquery($sql, array($depId, $recordid));
                                        }
                                    }
                                }
                            }
//                        }
                    }






                   if($_REQUEST['changetype'] == 'ChangeCreator')
                    {
                        if ($this->getUserId() != $subject[$recordid]['smcreatorid']) {
                            $focus->getModuleStatic('ModTracker');//字段修改日志
    
                            $focus->modstatic->saveFieldLogOne($module, $assigned, $recordid,
                                $subject[$recordid]['smcreatorid'], $this->getUserId());
                        }
                        
                    }
                    else{
                        
                        if ($module == 'Accounts' || $module == 'ServiceCharge') {
                            if(!empty($pool_id))
                            {
                                //edit:can 20220913 公海已分配客户的保护结束日期计算异常：分配日期不应该参与计算，这导致了保护结束日期没有显示真实的回收日期
                   
                                //edit:can 2020-12-28 43954: 分配公海客户的时候，保护截止日期没有更新
                                  $ruleinfo=getAccount_set_rule('complete',$pool_id);
                                 //edit:can  反写普通客户的保护截止日期
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


                        //分配成功之后再记录日志
                        if ($this->getUserId() != $subject[$recordid]['smownervalue']) {
                            $focus->getModuleStatic('ModTracker');//字段修改日志

                            $focus->modstatic->saveFieldLogOne($module, $assigned, $recordid,
                                $subject[$recordid]['smownervalue'], $this->getUserId(), $operation_logid);
                            //系统操作日志-分配
                            crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
                            cls_OperationLogs::saveLogs($module,'Allocate',$recordid,'',staticModTracker::$lastinsertid);
                        }
                        
                    }

                    //成功提示语
                    $edit_err .= sprintf($batchsuccesslog, '<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject[$recordid]['subject'] . '</a>', $batchtype) . '<br/>';

                    $correct++;


                    //工作流程反写
                    $pagemode = 'Allocated';
                    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
                    $workflowreverseobj = cls_savereverse::getInstance($module);
                    $workflowreverseobj->setPageMode($pagemode);
                    $workflowreverseobj->getInfo();

                    if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
                        $afterfieldvalue_arr = $col_fields;

                        $workflowreverseobj->setRecord($recordid);
                        if ($_REQUEST['mode']=='detail' && $workflowreverseobj->checkCallApiPop() == 'yes') {
                            $workflowreverseobj->setNotCallActionType(array('API'));
                        }
                        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);

                        if ($_REQUEST['mode']=='detail') {
                            //检查是否有API调用
                            $receive_msg = $workflowreverseobj->checkCallApiPop();
                            $entity['workflow']['receive_msg'] = $receive_msg;
                            if ($receive_msg == 'yes') {
                                $entity['workflow']['record'] = $recordid;
                                $entity['workflow']['module'] = $module;
                                $entity['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
                                $entity['workflow']['before_save_infos'] = $beforefieldvalue_arr;
                                $entity['workflow']['after_save_infos'] = $afterfieldvalue_arr;
                            }
                        }elseif($_REQUEST['mode']=='list'){
                            $callapimsg_arr = $workflowreverseobj->getExecResultData();
                            if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                                $callapimsg = implode('<br>',$callapimsg_arr);
                            }
                            $edit_err .= $callapimsg."<br/>";
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
                        //zkt 20230807 BUG0070759  	kfbtest-销售线索分配 触发的消息提醒，提醒内容后半句总会带着“客户管理：上海灵当信息科技有限公司 ”，实际线索并不关联此客户（线索编号 LEA7 LEA6） 
                        if ($accountfield != null && ($accountfield != 'upgradeaccountid' && $focus->moduleName != 'Leads')) {
                            $accountsql = 'select accountname from ld_account where deleted=0 and  '.$accountfield.' = (select '. $focus->table_name . '.accountid from  '
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

                        $tmpaddremindsid = $focus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $this->getUserId(), $recordid);
                        $tmpremindsid[] = $tmpaddremindsid;
                        if(!empty($subject[$recordid]['subject'])){
                            $this->addreminds_relatedto_linkarr[$tmpaddremindsid] = $subject[$recordid]['subject'];
                        }
                        

                        $focus->id = 0;//26101: 服务收费管理和服务合同分配提醒问题
                    }
                    //工单管理分配服务人员后,更改状态为已分配
                    if($module == 'WorkSheet'&&$_REQUEST['changetype'] == 'Allocate'){
                        $sql = 'update ' . $focus->table_name . ' set worksheet_status=?,receivedtime = ? where ' . $focus->table_index . ' = ? ';
                        $adb->pquery($sql, array('inprocess',date("Y-m-d H:i:s"), $recordid));
                    }elseif($module == 'CollectionSlip'&&$_REQUEST['changetype'] == 'Allocate'&&($_REQUEST['navbar'] == 'uncollected' || $_REQUEST['mode'] == 'detail')){  //收款认领单在未认领页签下分配负责人，状态更改为已分配 wym 240312 XUQIU20240218-01 新增预制表单：收款认领单
                        //wym 240515 BUG20240514-16 收款认领单，编辑界面-点分配按钮，分配更改负责人后，收款认领单状态没有改变成：已认领
                        $sql = 'update ' . $focus->table_name . ' set collectionslip_status=?,collectionslip_time = ? where ' . $focus->table_index . ' = ? and collectionslip_status="uncollected"';
                        $adb->pquery($sql, array('collected',date("Y-m-d H:i:s"), $recordid));
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
//            if ($error == 0) {
                $error = count($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']) - $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'];
//            }
            $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
           
            $submitlog = sprintf($submitlog, count($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']), $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['correct'], $error);
            $table = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">' . $submitlog . '</div></div>';
            if ($_REQUEST['changetype'] == 'Allocate')//批量分配
            {

                //wym 240612 BUG20240612-16 分配触发的工作流  如果更新的字段取值是引用成员管理字段 则无法触发工作流 更新代码移到了循环内
                /*if($focus->fieldobj->getFieldInfoBykeyValue('relatedmodulefield','yes','columnname')||$focus->fieldobj->getFieldInfoBykeyValue('uitype','1600','columnname'))
                {//wym XUQIU1000290 分配单据时,引用成员管理字段需要同时更新
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
                                $deletecol_arr[]="'".$tmp_effect_fieldinfo['columnname']."'";
                                if(!empty($related_info['rawValue']['value'])){
                                    foreach ($related_info['rawValue']['value'][$effect_fieldname] as $key=>$value){
                                        $insert_arr[$tmp_effect_fieldinfo['columnname']]=$value['fileid'];
                                    }
                                }
                            }else{
                                $massupdate_arr[$tmp_effect_fieldinfo['tablename']][$tmp_effect_fieldinfo['columnname']]=$related_info['rawValue']['value'];
                            }
                        }
                    }
                    $update_recordids=implode(',',$recordids);
                    if(isset($massupdate_arr)){//更新列表字段
                        foreach ($massupdate_arr as $updatetable=>$updateinfo){
                            foreach ($updateinfo as $coloumnname=>$data){
                                $update.= $coloumnname."='".$data."' ,";
                            }
                            $update=trim($update,',');
                            //wym BUG0076365
                            $updatesql = 'update ' . $updatetable . ' set ' . $update. ' where ' . $focus->table_index .' in ('.$update_recordids.') AND EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)' ;
                            $adb->pquery($updatesql, array($this->getUserId()));
                        }
                    }

                    if(isset($deletecol_arr)){//更新附件图片字段
                        $deletesql = "delete from ld_seattachmentsrel 
                        where crmid in (".$update_recordids.") AND attachmentcolumnname in ('" . implode("', '", $deletecol_arr) . "')  AND  EXISTS (SELECT 1 FROM ld_users WHERE ld_users.id = ?)";
                        $adb->pquery($deletesql, array($this->getUserId()));
                        if(isset($insert_arr)){
                            foreach ($recordids as $recordid){
                                foreach ($insert_arr as $coloumnname=>$data){
                                    $insert_value .= "(".$recordid.",'".$coloumnname."',".$data.")";
                                }
                                $insert_value.=",";
                            }
                            $insert_value=trim($insert_value,',');
                            $insertsql = "insert into ld_seattachmentsrel(crmid,attachmentcolumnname,attachmentsid) values ".$insert_value;
                            $adb->pquery($insertsql, array());
                        }
                    }
                }*/
                //editor:gyq_165 reason:钉钉消息提醒类型，分配提醒   2019/12/30 11:57
                require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/MessageCorpconversation.php");
                $remind = new MessageCorpconversation();
                $remind->setRemindType();
                //有n条$客户$分配给您，敬请关注！点击查看$客户$列表
                if ($remind->installWX || $remind->installDing || $remind->installYzj||$remind->installWXSelfBuilt || $remind->installZy ||$remind->judgeOffiaccount()=='yes' || $remind->installFanwei) {
                    $sql = 'select wx_userid,dingtalk_userid,yunzhijia_openid,zhiyuan_userid,fanwei_userid from ld_users  where id=? and push_wx_reminds = 1';
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
                    if ($tmprows>0&&(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid) || !empty($zhiyuan_userid) ||$remind->judgeOffiaccount()=='yes' || !empty($fanwei_userid))) {

                        $modulelabel = getTranstab($module);
                        $allocatecount = sizeof($tmpremindsid);

                        if (sizeof($tmpremindsid) > 1) {

                            $RemindsContent = '有' . $allocatecount . '条' . $modulelabel . '分配给您，敬请关注！';
                            //批量操作-移动端提醒，添加对应单据展示
                            $tmpRemindContentaddstr = '';
                            if(!empty($this->addreminds_relatedto_linkarr)){
                                $tmpindex = 0;
                                foreach($tmpremindsid as $tpmremindid){
                                    if(empty($this->addreminds_relatedto_linkarr[$tpmremindid])){
                                        continue;
                                    }
                                    if($tmpindex==0){
                                        $tmpRemindContentaddstr .= getTranstab($this->module).'如下：';
                                    }
                                    if($tmpindex > 3){
                                        $tmpRemindContentaddstr.='<br>······';
                                        break;
                                    }
                                    $tmpRemindContentaddstr .= "<br>".$this->addreminds_relatedto_linkarr[$tpmremindid];
                                    $tmpindex ++;
                                }
                            }
                            else{
                                $tmpRemindContentaddstr .='点击查看' . $modulelabel . " 列表";
                            }
                            $RemindsContent.=$tmpRemindContentaddstr;
                            
                            //zkt 20220728 BUG0054354https://www.81mis.com/kfbtest/ 以合同订单模块为例，分配提醒与批量分配提醒出错。共享/批量共享/取消共享提醒出错 
                            $tmfocus = new CRMEntity();
                            $tmfocus->moduleName=$module;
                            $parenttmpremindid = $tmfocus->AddReminds($RemindsContent, date("Y-m-d H:i:s"), $this->getUserId(), $recordid);
                                                 


                            $sql = 'update ld_reminds set status_rmd=?,deleted=?,wxremindstype=? where remindsid=?';
                            $adb->pquery($sql, array('已读', 1, 'immediately', $parenttmpremindid));

                            $sql = 'update ld_reminds set push_to_weixin=3,push_time=?, parentid=?,remindstype=?,wxremindstype=? where remindsid in( ' . implode(',', $tmpremindsid) . ') ';
                            $adb->pquery($sql, array(date("Y-m-d H:i:s"), $parenttmpremindid, 'massallocate', 'immediately'));
                            $r_multi_content = array(
                                array(
                                    'received_id' => $this->getUserId(),//zxm 20230707 云之家批量分配消息  浏览器端点开空白的问题
                                    'message' => $RemindsContent,
                                    'reltab' => $module,
                                    'related_to' => $parenttmpremindid,
                                    'date_time' => date("Y-m-d H:i:s"),
                                    'remindtype' => 'massallocate',
                                    'title' => $tmpremindtitle,
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
                            if(!empty($wx_userid) || !empty($dingtalk_userid) || !empty($yunzhijia_openid) || !empty($zhiyuan_userid) || !empty($fanwei_userid)){
                                $errorno = $remind->sendAllTypeRemindsImmediately(array($parenttmpremindid), $r_multi_content,'massallocate',$subject);
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
                                    'remindtype' => '',
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
                                $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($tmpremindsid,'allocate',$subject);
                            }
                            //企业微信/自建应用 钉钉 云之家
                            if(!empty($wx_userid) || !empty($dingtalk_userid)|| !empty($yunzhijia_openid) || !empty($zhiyuan_userid) || !empty($fanwei_userid)) {
                                $errorno = $remind->sendAllTypeRemindsImmediately($tmpremindsid, $r_multi_content, 'allocate', $subject);
                            }
                        }
                    }


                }
                if($versionInfo['account'] == "moyuan"&&$module == 'Leads') {
                    $moyuan_obj->emailLeadsForSave($_REQUEST['changetype'],$_REQUEST['select_id']);
                }
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

        if (isset($_SESSION['lvs'][$module]['viewname'])) {
            $viewid = $_SESSION['lvs'][$module]['viewname'];
            $start = $_SESSION['lvs'][$module][$viewid]['start'];
        }

        if (!$start) $start = 1;
        $entity['log']['value'] = '';
        $entity['moyuan_msg'] = $judge;//moyuan  1228 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
        $entity['errorcount'] = $error;
        if ($_REQUEST['mode'] == 'detail') {
            if ($this->errorcolumnname != '') {
                $entity['errorcount'] = 1;
                $entity['log']['value'] = $focus->fieldobj->getFieldInfoBykeyValue("columnname", $this->errorcolumnname, 'fieldlabel') . getFixedLabel('FieldCANNOTEMPTY');
            }else if(!empty($validata_errormsg)){
                $entity['errorcount'] = 1;
                $entity['log']['value'] =  "<div class='pop_prc_content'>" . $validata_errormsg . "</div>";
            }

        } else
            $entity['log']['value'] = $table . "<div class='pop_prc_content'>" . $_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['edit_err'] . "</div>";//批量处理信息
        $entity['start']['value'] = $start;//当前页数
        $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认

        $field = $focus->fieldobj->getFieldInfoobjBykey('columnname', $smcolumnname);
        $entity['title']['value'] = getVarFixedLabel('CHANGECREATED', $field->getFieldLabel());// 确认

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

        if (($module == 'Accounts' && (getSys_deploy(61)['deploy_value'] == 'all')) || ($module == 'Potentials' && (getSys_deploy(26)['deploy_value'] == 'all'))) {
            $this->relatedinfoset_arr = [
                'sharerelatedinfo' => 'yes',
                'shareoldsmowner' => '',
                'relmodule_scope' => 'all',
                'relmodule_selectedtabid_str' => '',
                'reldata_scope' => 'all',
            ];
        }
        if(!empty($this->relatedinfoset_arr)){
            $this->relatedinfoset_arr['oldsmowner'] = $col_fields['db_' . $smownerfieldname];// 旧负责人
            $focus->relatedinfoset_arr = $this->relatedinfoset_arr;// 分配相关信息的设置
        }

        if (is_array($successids) && sizeof($successids) > 0)
            $focus->massChangeUser_after($module, $successids, $_REQUEST['changetype']);
      
      
        $this->setsaveReturn($entity);
    }

    //gyqX161111
    protected function setReturnStyleInDetail()
    {

        if ($_REQUEST['mode'] == 'detail') {//明细界面弹出提示(Liver增加|| $_REQUEST['mode'] == 'list'，判断列表界面)
            ConvertTojsonString(-1,array(),"###REACHMAXCUSTOMER###");
            exit();
        };
    }


    public function setpublicAccountCount($module, $recordid)
    {
        static $publicaccountcount;
        global $adb;
        if (!empty($publicaccountcount) && $publicaccountcount > 2000) {
            return;
        }
		$sql_accountid = 'select publicaccount,pool_id from ld_account  where accountid=? limit 1;';

		$sql_result = $adb->pquery($sql_accountid, array($recordid));
		$publicaccount = $adb->query_result($sql_result, 0, 'publicaccount');
		$pool_id = $adb->query_result($sql_result, 0, 'pool_id');
        if ($this->public_account['status'] == 'yes') {
            //0025702: 客户列表：公海参数设置，按角色控制，设置报表库数量上限4
            crm_load_function_file('getUserRoleId', 'include/utils', 'UserInfoUtil');
            $roleid = getUserRoleId($this->getUserId());
            //公海已分配客户数量上限
			$public_account_limit_type = $this->public_account['public_account_pool'][$pool_id]['limit_type'];
			if ($public_account_limit_type == 'user') {
				$count = $this->public_account['public_account_pool'][$pool_id]['limit_count'];//按用户上限
			}else if ($public_account_limit_type == 'role'){
				$sql = 'SELECT limit_count FROM ld_account_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

				$result = $adb->pquery($sql, array($roleid,$pool_id));
				$rows = $adb->num_rows($result);
				if ($rows > 0) {
					$count = $adb->query_result($result, 0, 'limit_count');
				} else {
					$count = 0;
				}
			}else{
                $count = 9999999999;
            }
            $publicaccountcount = $count;

            if ($count >= 20000) {

                return;
            }
        }
        $count = $publicaccountcount;

        //分配公海已分配的客户，判断被分配人的公海已分配客户数量是否达上限
        if ($module == 'Accounts' || $module == 'ServiceCharge') {
            

            //是否启用公海参数
            if ($this->public_account['status'] == 'yes' && $publicaccount > 1) {
                $sql = "select ld_account.accountname from ld_account
                              where ld_account.smownerid=? and ld_account.deleted=0 and ld_account.publicaccount>1 and pool_id = ?";
                $result = $adb->pquery($sql, array($this->getUserId(),$pool_id));
                $have_allocate = $adb->num_rows($result);


                if ($count == '') {
                    $count = 0;
                }

                if ($count <= $have_allocate) {
                    //ls 20221115 BUG0058744 批量提示 公海已分配客户超出上限提示修改
                    //公海已分配   移动端和PC端详情页分配可以直接提示(因为只有一条单据)，PC端列表分配要修改成错误弹窗信息，需要一直往下分配。
                    if ($_REQUEST['mode'] == 'detail') {
                        $this->setReturnStyleInDetail();  //editor:gyq reason:返回值不同
                    }else{
                        return -1;//公海已分配超出上限错误提示
                    }
                    //$edit_err .= sprintf($batreachmax, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $subject[$recordid]['subject'] . '</a>', $batchtype, getUserFullName($_REQUEST['caterorid'])) . '<br>';

                }
            }

            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（客户分配）
            if ($publicaccount == 0) {//普通客户
                $focus = CRMEntity::getInstance('Accounts');
                $limit_count = $focus->getCommonAccountLimitCount($this->getUserId());
                if($limit_count<9999999999)
                {
                    $haved_count = $focus->getSmowerNumForCommonAccount($this->getUserId());
                    if ($limit_count <= $haved_count) {
                        //历史原因没办法，只能兼容。PC详情页、PC列表页、移动端，返回值格式风格迥异。
                        global $weixin_user;
                        if(!empty($weixin_user)){
                            if ($this->public_account['status'] == 'yes')
                                ConvertTojsonString(-1,array(),getFixedLabel('ALLOCATERREACHMAXCUSTOMERAppError1'));//被分配人普通客户数量已达上限!
                            else
                                ConvertTojsonString(-1,array(),getFixedLabel('ALLOCATERREACHMAXCUSTOMERAppError'));
                        }elseif ($_REQUEST['mode'] == 'detail'){
                            $tmpmsg = $this->public_account['status'] == 'yes'?'###ALLOCATERREACHMAXCUSTOMERJSError1###':'###ALLOCATERREACHMAXCUSTOMERJSError###';//PC详情页返回
                            ConvertTojsonString(-1,array(),$tmpmsg);
                        }else{
                            return -2;//普通客户超出上限错误提示 列表页
                        }
                    }
                }
            }
        }
        return $pool_id;
        
    }

    protected function setsaveReturn($entity)
    {
        global $current_user;
        
        $module=$_REQUEST['from_module'];//
        if($_REQUEST['mode']=='list')
        {
            $maxrows=sizeof($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['crmid']);
            $entity['maxrows']=$maxrows;
            $entity['selectrows']=sizeof($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['allcrmid']);
            
            $focus=CRMEntity::getInstance($module);
            if($_REQUEST['changetype']=='Allocate')
           {
             $smownercolumnname=$focus->getSmownerColumName();
            $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldlabel');
            $entity['progresstitle']=getFixedLabel('ALLOCATE')."(".$fieldlabel.")";
           }
            else
            {
                 $smownercolumnname=$focus->getCreateColumnName();
                 $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldlabel');
                 $entity['progresstitle']=getFixedLabel('CHANGE')."(".$fieldlabel.")";
            }
                
            $endrow=$_REQUEST['endrow'];
            if($endrow>=$maxrows)
           {
           // dump($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]['edit_err']);
             unset($_SESSION[$current_user->id.'_'.$module.$_REQUEST['changetype']]);
           }
        }
        
       
        ob_clean();
        ob_flush();

        $_REQUEST['diony'] = 'yes';
        $entity['operatedate'] = date("Y-m-d");
        $entity['result']['fieldhreffieldname']=$this->focus->list_link_field;
        if($_REQUEST['changetype']=='Allocate')
            $fieldname=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",$this->focus->getSmownerColumName(),'fieldname');
        else
            $fieldname=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",$this->focus->getCreateColumnName(),'fieldname');
        $entity['result']['datainfo'][$fieldname]=array("fieldname"=>$fieldname,'value'=>$_REQUEST['username'],'secid'=>$_REQUEST['caterorid'],'value_name'=>$_REQUEST['username']);
        ConvertTojsonString(1,$entity,"success");
    }
}


?>