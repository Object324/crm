<?php

/**
 * @edit: cyb
 * @date:2016-03-16
 * @reason: 相关信息下显示共享人选项；
 **/
class SetRelatedInfo
{
    public $fieldname;
    public $logId;
    public $isEditDetail;
    public $curLogInfo = [];
    public $logs_from = 'pc';// pc端还是移动端请求
    protected $attachment_img_logs_arr;
    //获取单据共享人数量
    public function get_SharedUsersNum($id)
    {
        global $adb;
        $query = "SELECT viewuserid from ld_tabshare  inner JOIN ld_users
                                on ld_users.id=ld_tabshare.viewuserid where crmid=$id";
        $result = $adb->pquery($query);
        $noofrows = $adb->num_rows($result);
        $return_value['record'] = $adb->query_result($result, 0, 0);
        $return_value['relcount'] = $noofrows;
        return $return_value;
    }

    public function get_SharedUsers($module, $id, $cur_tab_id, $relationId, $rel_tab_id, $actions = false)
    {
        global $current_user;

        global $adb;
        global $related_left_start;
        global $list_max_entries_per_page_new_more;
        //获取列头
        $rel_listheader = array();

        $fieldlabelarr = $current_user->fieldobj->getFieldLables();
        $fieldObj = Field::getInstance('Users', $adb);
        $moduleFields = $fieldObj->getModuleFields();

        //	0022221: 客户查看明细界面：相关信息-共享人：当用户管理>页面设置中把【email】字段隐藏时，共享人序列表中会有一个空白列
        if (!empty($moduleFields['groupid'])) {
            $rel_listheader[] = $fieldlabelarr['groupid'];
            $columns[] = 'groupid';
        }

        if (!empty($moduleFields['last_name'])) {
            $rel_listheader[] = getFixedLabel('Staff'); //edit:can 20210419  广告行业项目立项页面增加项目团队      //$fieldlabelarr['last_name'];
            $columns[] = 'last_name';
        }
        if (!empty($moduleFields['phone_mobile'])) {
            $rel_listheader[] = $fieldlabelarr['phone_mobile'];
            $columns[] = 'phone_mobile';
        }
        $rel_listheader[] = getFixedLabel('Duty');
        $columns[] = 'viewuserduty';
        if (!empty($moduleFields['email1'])) {
            $rel_listheader[] = $fieldlabelarr['email1'];
            $columns[] = 'email1';
        }
        //wym 240226 XUQIU20240118-06 在单据详情页--相关信息--共享人的列表，Email后面增加一列：操作人，显示共享行为的操作人
        $rel_listheader[] = getFixedLabel('operatoroer');
        $columns[] = 'Shareuserid';
        $rel_listheader[] = getFixedLabel("REMARK");
        $columns[] = 'viewuserremark';
        $rel_listheader[] = getFixedLabel('OPERATING');

        //获取分页  
        $return_value = $this->get_SharedUsersNum($id);
        $noofrows = $return_value['relcount'];
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = vtlib_purify($_REQUEST['start']);
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        $related_left_start = $start;
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        $shareuser_query = "";
        $shareuser_query .= "select id," . implode(',', $columns) . " ,ld_users.wx_userid from ld_tabshare inner JOIN ld_users
                                on ld_users.id=ld_tabshare.viewuserid
                                where ld_tabshare.crmid=$id
                                order by CONVERT(last_name USING  gbk) ";
        $shareuser_query .= " limit " . $limstart . "," . $list_max_entries_per_page_new_more . " ";

        $shareuser_result = $adb->pquery($shareuser_query);
        $shareuser_num = $adb->num_rows($shareuser_result);
        if ($_REQUEST['related_left_type'] != '3')//3:获取数量
        {
            $focus = CRMEntity::getInstance($module);
            $smowner_columnname = $focus->getSmownerColumName();
            $sql = 'select ' . $smowner_columnname . ' from ' . $focus->table_name . ' where ' . $focus->table_index . ' =' . $id;


            $result = $adb->pquery($sql, array());

            $smownerid = $adb->query_result($result, 0, 0);
        }
        $groupfieldinfo = $current_user->fieldobj->getFieldInfoobjBykey("columnname", 'groupid');

        $deploy_value = getSys_deploy(33);
        if ($shareuser_num > 0) {
            for ($j = 0; $j < $shareuser_num; $j++) {
                $share_userid = $adb->query_result($shareuser_result, $j, 'id');
                $last_name = $adb->query_result($shareuser_result, $j, 'last_name');
                $wx_userid = $adb->query_result($shareuser_result, $j, 'wx_userid');
                $operatorid = $adb->query_result($shareuser_result, $j, 'shareuserid');
                $phone_mobile = $adb->query_result($shareuser_result, $j, 'phone_mobile');
                $email = $adb->query_result($shareuser_result, $j, 'email1');
                //21277: （设置是否仅允许系统管理员用户取消共享 为是） 客户>客户查看明细>相关信息>共享，共享人能被删除
                $operate_delete = '';
                //BUG0070705 hzx 取消共享按钮消失
                if (isPermitted($module, "Share", '') == 'yes' && ($current_user->is_admin != 'off' || $deploy_value['deploy_value'] == 1 || ($deploy_value['deploy_value'] == 1 && $smownerid == $current_user->id))) {
                    if ($current_user->is_admin == 'off' && $smownerid != $current_user->id) {
                        //22699: 单据明细界面：相关信息-共享人：单据负责人不是当前用户时，操作列不应该显示：删除 按钮
                        //这种情况出现：系统参数共享：否，非管理员，
                    } else
                        $operate_delete = '<a  class="Anu3_a" style="text-decoration:none" href="javascript:void(0);" onclick="DeleteShareUser(\'' . $module . '\',' . $id . ',' . $share_userid . ',' . $relationId . ')">' . getFixedLabel('CANCELSHARE') . '</a>';
                }
                if (in_array('groupid', $columns)) {
                    crm_load_class_file("ShowFieldValue", 'include/fields');
                    $showfieldvalueobj = new ShowFieldValue($current_user->fieldobj, 'Users', 'SHOW_EDITVIEW');
                    $showfieldvalueobj->setRecorId($share_userid);

                    $showvalues = $showfieldvalueobj->getFieldValueByField($groupfieldinfo, "", "");

                    $rel_listentries[$share_userid]['groupname'] = $showvalues['value'];

                }
                if (in_array('last_name', $columns)) {
                    $userobj = new Users();
                    $userobj->wx_userid = $wx_userid;
                    $userobj->last_name = $last_name;
                    $rel_listentries[$share_userid]['last_name'] = getUserlastName($userobj);

                }
                if (in_array('phone_mobile', $columns)) {
                    $rel_listentries[$share_userid]['phone_mobile'] = $phone_mobile;
                }
                $rel_listentries[$share_userid]['viewuserduty'] = $adb->query_result($shareuser_result, $j, 'viewuserduty');
                if (in_array('email1', $columns)) {
                    $rel_listentries[$share_userid]['email'] = $email;
                }
                if (in_array('Shareuserid', $columns)) {//wym 240226 XUQIU20240118-06 在单据详情页--相关信息--共享人的列表，Email后面增加一列：操作人，显示共享行为的操作人
                    $shareuserobj = new Users();
                    $shareuserobj->id = $operatorid;//操作人的colomunname就是Shareuserid
                    $tmpsql = 'select last_name from ld_users where id=?';
                    $tmpresult = $adb->pquery($tmpsql, array($operatorid));
                    $operatorname = $adb->query_result($tmpresult, 0, 0);
                    $shareuserobj->last_name = $operatorname;
                    $rel_listentries[$share_userid]['opretor'] = getUserlastName($shareuserobj);
                }
                $rel_listentries[$share_userid]['viewuserremark'] = $adb->query_result($shareuser_result, $j, 'viewuserremark');
                $rel_listentries[$share_userid]['operate_delete'] = $operate_delete;
            }
        }
        if ($actions) {
            if (is_string($actions)) $actions = explode(',', strtoupper($actions));

            if ((in_array('SHARE', $actions) && isPermitted($module, "Share", '') == 'yes') || $current_user->is_admin == 'on') {
                if ($deploy_value['deploy_value'] == 0 && $current_user->id != $smownerid && $current_user->is_admin == 'off') {//仅允许单据负责人和管理员用户操作

                } else {
                    if(($module == 'Accounts' && (getSys_deploy(61))['deploy_value'] == 'part') || ($module == 'Potentials' && (getSys_deploy(26))['deploy_value'] == 'part')){
                        $onclick_html = 'onclick="SeniorAllocateShare.getInstance(\'' . $module . '\',\'seniorShare\').getPopup('.$id.')"';
                    }else{
                        $onclick_html = 'onclick="SetModuleShare(\'' . $module . '\',' . $id . ',\'related_portion\',' . $relationId . ')"';
                    }
                    $button .= '<a title="' . getFixedLabel('SHARE') . '"  style="text-decoration:none"
                    href="javascript:void(0);" '.$onclick_html.'> 
                    <b class="icon-homeimg icon-share"></b><span>' . getFixedLabel('SHARE') . '</span></a>';
                }
            }
        }
        $navigationOutput = array();
        $url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
        crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
        $navigationOutput[] = getRecordRangeMessage($shareuser_result, $limstart, $noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, "$module", 'SharedUsers', $id);


        $total_width = 0;
        $sql = 'select * from ld_list_headerwidth where module=? and type=? and userid=? ';
        $result = $adb->pquery($sql, array('SharedUsers', 'SharedUsers', $current_user->id));
        $rows = $adb->num_rows($result);

        if ($rows <= 0) {
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(19);//部门
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(1);//人员
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(1);//手机
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(1);//职责
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(1);//Email
            $tmpwidth['fieldwidth'][] = getModuleFieldProportion(19);//备注

        } else{
            for ($i = 0; $i < $rows; $i++) {
                $columns = $adb->query_result($result, $i, 'columns');

                $tmpwidth['fieldwidth'][$columns] = $adb->query_result($result, $i, 'header_width') . 'setting';

            }
        }
        $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $module);
        $tmpwidth['fieldwidth'] = $widthinfo;

        foreach ($widthinfo as $tmp_width) {
            $total_width += $tmp_width;

        }


        //35599: （1.6）单据明细界面>相关模块：共享人、修改日志增加拖动列宽功能，可以参照其他模块。（需要补丁）
        $tmp['headername']['columnname'][] = 'share1';
        $tmp['headername']['columnname'][] = 'share2';
        $tmp['headername']['columnname'][] = 'share3';
        $tmp['headername']['columnname'][] = 'share4';
        $tmp['headername']['columnname'][] = 'share5';
        $tmp['headername']['columnname'][] = 'share6';

        $tmp['headername']['fieldname'][] = 'share1';
        $tmp['headername']['fieldname'][] = 'share2';
        $tmp['headername']['fieldname'][] = 'share3';
        $tmp['headername']['fieldname'][] = 'share4';
        $tmp['headername']['fieldname'][] = 'share5';
        $tmp['headername']['fieldname'][] = 'share6';

        $return_value = array('CUSTOM_BUTTON' => $button, 'header' => $rel_listheader, 'entries' => $rel_listentries,
            'headername' => $tmp['headername'], 'fieldwidth' => $tmpwidth['fieldwidth'],
            'total_width' => $total_width, 'navigation' => $navigationOutput, 'relcount' => $noofrows, 'noofrows' => $noofrows);
        return $return_value;
    }

    //公海操作记录
    public function getPublicLeadsLog($module, $record, $tabid, $relationInfo)
    {

        return $this->getRelatedInfoLog($module, $record, $tabid, $relationInfo);

    }

    //微信用户签到日志
    public function getWeChatUserSignLog($module, $record, $tabid, $relationInfo)
    {

        return $this->getRelatedInfoLog($module, $record, $tabid, $relationInfo);

    }

    public function getWeChatUserSignLogNum($record)
    {
        global $adb;
        $query = "select 1 from ld_wechatuser_sign where wechatuserid = ? ";
        $result = $adb->pquery($query, array($record));
        $noofrows = $adb->num_rows($result);
        $return_value['record'] = $record;
        $return_value['relcount'] = $noofrows;
        return $return_value;
    }

    //公海操作记录
    public function getPublicAccountLog($module, $record, $tabid, $relationInfo)
    {

        return $this->getRelatedInfoLog($module, $record, $tabid, $relationInfo);

    }

    //公海操作记录 - 条目数
    public function getPublicAccountLogNum($record, $module = '')
    {
        global $adb, $current_user, $currentModule;
        if ($module == 'Leads') {
            $logtable = 'ld_logpublicleads';
            $logtable_index = 'leadsid';
        } else {
            $logtable = 'ld_logpublicaccount';
            $logtable_index = 'accountid';
        }
        $query = "SELECT ld_users.wx_userid,ld_users.last_name,$logtable.username,operation,opdate,$logtable.userid from $logtable 
            left join ld_users on ld_users.id = $logtable.userid
            where $logtable.$logtable_index = ? ";
        $result = $adb->pquery($query, array($record));
        $noofrows = $adb->num_rows($result);
        $return_value['relcount'] = $noofrows;

        return $return_value;
    }

    public function getFieldUpdateLogNum($module, $id, $label)
    {
        global $adb, $current_user, $logid;
        $isEditDetail = $this->getIsEditDetail();
        $logid = $this->getLogId();
        $tabid = getTabid($module);

        $where = '';
        if ($label == 'ChangeView') {
            $focus = CRMEntity::getInstance($module);
            $columname = $focus->getSmownerColumName();
            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $columname);
            if (!empty($fieldinfo))
                $this->fieldname = $fieldname = $fieldinfo->getFieldName();

            $where = " and ld_field.fieldname='$fieldname' and ld_modtracker_basic.module='" . $module . "' ";
        } else if ($label == 'ViewHistory') {
            //富文本框选择是否隐藏 zl XUQIU1000760 $Richtexthide获取按钮状态
            $Richtexthide = getUsersettingByLabel($module, $current_user->id, 'Richtexthide');
            $Richtexthide = empty($Richtexthide) ? 'yes' : $Richtexthide;
            $focus = CRMEntity::getInstance($module);
            $fieldinfo230 = $focus->fieldobj->getFieldInfoobjBykey('uitype', '230');
            $fieldinfo231 = $focus->fieldobj->getFieldInfoobjBykey('uitype', '231');
            if (empty($fieldinfo230) && empty($fieldinfo231)) {
                $Richtexthide = '';
            }
            if ($Richtexthide == 'yes') {
                $where = ' and ld_field.uitype != 230 and ld_field.uitype != 231 ';          //筛选富文本框
            }
        }

        $count_query = $this->getLogQuery($module, $label);
        $count_query .= $where;
//wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        if ($label == "ViewHistory" && $isEditDetail == 'yes') {  //改动3
            $count_result = $adb->pquery($count_query, array($tabid, $logid, $id));
        } else {
            $count_result = $adb->pquery($count_query, array($tabid, $id));
        }


        $noofrows = $adb->num_rows($count_result);

        $return_value['relcount'] = $noofrows;

        return $return_value;
    }

    public function getFieldUpdateLog($module, $record, $tabid, $relationInfo)
    {
        //读取单据分录修改日志信息
        if ($_REQUEST['detaillog'] == 'yes') {
            return $this->getDetailUpdatelog($module, $record, $tabid, $relationInfo);
        }
        return $this->getRelatedInfoLog($module, $record, $tabid, $relationInfo);
    }

    //读取单据分录修改日志
    public function getDetailUpdatelog($module, $record, $tabid, $relationInfo)
    {
        crm_load_class_file('showProductDetailFieldValue', 'include/fields');
        crm_load_class_file('TabDetailFieldsHtmlTd', 'include/TabDetailFields');
        global $adb, $list_max_entries_per_page_new_more;
        global $current_user, $PlatformMC;
        $isEditDetail = $this->getIsEditDetail();
        $focus = CRMEntity::getInstance($module);
        $focus->mode = 'Details';
        $focus->id = $record;
        $focus->retrieve_entity_info($record, $module);
        $entitytype = '';
        if ($module == 'CashBill' || $module == 'SendCashBill') {
            $source_list = $focus->column_fields['selectlistval'];
            $source_list_arr = explode(',', $source_list);
            $entitytype = getSalesEntityType($source_list_arr[0]);
            // $focus->detailfieldobj->setsourceModulesqlwhere($sourcemodulename);
            $focus->Resetdetailfieldobj($entitytype);
        }
        $label = $relationInfo['label'];
        $tabid = getTabid($module);
        $languageType = getLanguageType($current_user);

        //表头字段显示
        $showfieldvalue = new ShowFieldValue($focus->fieldobj, $module, SHOW_POPUP);
        $showfieldvalue->setRecorId($record);
        //产品分录字段显示
        $showfieldvalueobj = new showProductDetailFieldValue($focus->detailfieldobj, $this->module, SHOW_DETAILVIEW);
        $showfieldvalueobj->setadbResult('');
        $showfieldvalueobj->setRecorId($this->record);
        //普通分录显示
        $TabDetailFieldsHtmlTd = new TabDetailFieldsHtmlTd($focus, $module);
        //分录字段信息

        $DetailToolFiledsInfo = $focus->detailfieldobj->getModuleProductToolField($tabid, $languageType);
        $isproductentitytype = 'no';
        if ($module == 'CashBill' || $module == 'SendCashBill') {
            if (array_key_exists("productname", $DetailToolFiledsInfo)) {
                $isproductentitytype = 'yes';
            }
        }
        $ProductsFiled = Field::getInstance('Products', $adb);

        $Detail_table = $focus->Detail_table;
        $Detail_table_scf = $focus->Detail_table_scf;

        $total_columnname = 'total';
        $total_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname', $total_columnname);
        //wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        $query = 'SELECT * from ld_detailtracker_basic ';
        if ($isEditDetail == 'yes'){
            $logId = $this->logId;
            $relationId = $this->getRelationId($logId);
            $query .= ' INNER JOIN ld_crmlog_relation ON ld_crmlog_relation.relation_id = ld_detailtracker_basic.trackid ';
        }
        $query .= ' where modulename = ? and record = ? ';
        if ($isEditDetail == 'yes'){
            $query .= ' and ld_crmlog_relation.relation_id = ? ';
        }
        $Smownerids = getCurSmOwnerSearchScope($module);// 数据范围
        $userids = $current_user->id;
        foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
            if (!empty($userid))
                $userids .= "," . $userid;
        }
        $query .= " AND (whodid in ( $userids ) or ifnull(whodid,-1) < 0)";
        $result = $adb->pquery($query, array($module, $record));
        $noofrows = $adb->num_rows($result);

        $filter = array();
        $filter['record'] = $record;
        //order by 排序
        $order_by = 'ld_detailtracker_basic.changedon desc,ld_detailtracker_basic.trackid ';
        $sorder = 'desc';

        $filter['order_by'] = $order_by;
        $filter['sorder'] = $sorder;
        $query .= ' ORDER BY ' . $order_by . ' ' . $sorder . ' ';

        //获取当前页数
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = $_REQUEST['start'];
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        $filter['start'] = $start;
        //计算limit
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        if (!empty($PlatformMC)) {
            $query .= ' limit 0,10';
        } else {
            $query .= ' LIMIT ' . $limstart . ',' . $list_max_entries_per_page_new_more . ' ';
        }

        //读取修改日志基础信息
        if ($isEditDetail == 'yes'){
            $result = $adb->pquery($query, array($module, $record, $relationId));
        }else{
            $result = $adb->pquery($query, array($module, $record));
        }
        $rows = $adb->num_rows($result);

        $detail_basic_info = array();
        $trackid_arr = array();
        for ($i = 0; $i < $rows; $i++) {
            $trackid = $adb->query_result($result, $i, 'trackid');
            $trackid_arr[] = $trackid;
            $detail_basic_info[$trackid]['version'] = $adb->query_result($result, $i, 'trackid_no');
            $this->curLogInfo['username'] = getUserFullName($adb->query_result($result, $i, 'whodid'));
            $this->curLogInfo['changedon'] = $adb->query_result($result, $i, 'changedon');
            if ($this->getIsEditDetail() !== 'yes'){
                $detail_basic_info[$trackid]['changedon'] = $adb->query_result($result, $i, 'changedon');
                $detail_basic_info[$trackid]['whodid'] = getUserFullName($adb->query_result($result, $i, 'whodid'));

            }
            $total_value = $adb->query_result($result, $i, 'total');
            $showvalue = $showfieldvalue->getFieldValueByField($total_fieldinfo, $total_value, $total_value);
            $detail_basic_info[$trackid]['total'] = $showvalue['value'];
            $rowspan[$trackid] = 0;
        }

        //设置列头信息
        $this->curLogInfo['operator'] = getFixedLabel('OPERATOR');
        $this->curLogInfo['operateTime'] = getFixedLabel('OPERATTIME');
        $header = array('version' => getFixedLabel('VERSION'),
            'changedon' => getFixedLabel('OPERATTIME'),
            'whodid' => getFixedLabel('OPERATOR'));
        if ($this->getIsEditDetail() == 'yes'){
            $header = array('version' => getFixedLabel('VERSION'));
        }
        $tmp['headername']['columnname']['version'] = 'version';
        $tmp['headername']['columnname']['changedon'] = 'changedon';
        $tmp['headername']['columnname']['whodid'] = 'whodid';
        $tmp['headername']['fieldname']['version'] = 'version';
        $tmp['headername']['fieldname']['whodid'] = 'whodid';
        $tmp['headername']['fieldname']['changedon'] = 'changedon';
        $tmpwidth['fieldwidth']['version'] = 60;
        $tmpwidth['fieldwidth']['changedon'] = 150;
        $tmpwidth['fieldwidth']['whodid'] = 100;
        $tdalign['version'] = 'center';
        $tdalign['changedon'] = 'left';
        $tdalign['whodid'] = 'left';

        //合计列信息读取当前模块‘total’字段
        $detailtotalinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $total_columnname);
        $total_field_presence = 'yes';
        if (!empty($total_fieldinfo)) {
            $fieldlabel = $total_fieldinfo->getFieldLabel();
            $total_fieldname = $total_fieldinfo->getFieldName();
        } else if (!empty($detailtotalinfo)) {
            $fieldlabel = $detailtotalinfo->getFieldLabel();
            $total_fieldname = $detailtotalinfo->getFieldName();
        } else {
            $fieldlabel = '';
            $total_fieldname = '';
            $total_field_presence = 'no';
        }
        if ($total_field_presence == 'yes') {
            $header[$total_columnname] = $fieldlabel;
            $tmp['headername']['columnname'][$total_columnname] = $total_columnname;
            $tmp['headername']['fieldname'][$total_columnname] = $total_fieldname;
            $tmpwidth['fieldwidth'][$total_columnname] = 100;
            $tdalign[$total_columnname] = 'right';
        } else {
            foreach ($detail_basic_info as $tmp_trackid => $tmp_info) {
                if (isset($detail_basic_info[$tmp_trackid]['total'])) {
                    unset($detail_basic_info[$tmp_trackid]['total']);
                }
            }
        }

        $detail_filed = array();
        $alldetail_fields = array();
        $productdetail_column_sql = [];
        //将分录宽度中的mm与px相互转化,96px=25.4mm
        $proportion = 96 / 25.4;
        //获取所有开启的分录字段信息
        foreach ($DetailToolFiledsInfo as $key => $detailfieldinfo) {
            //BUG20240919-30 hzx  	自定义模块16，分录中‘成本1’这个字段没有给销售人员设置权限，此时，新建编辑，查看详情都看不到这个字段，但是在修改日志中，可以看到这个字段 
            if($detailfieldinfo->getDetailsFieldsProfile('details') == 'hidden'){
                continue;
            }
            $columnname = $detailfieldinfo->getColumnName();

            $tablename = strtolower($detailfieldinfo->getTableName());
            $fieldname = $detailfieldinfo->getFieldName();
            $width = $detailfieldinfo->getWidth();
            $typeofdata = $detailfieldinfo->getTypeOfData();
            $fieldlabel = $detailfieldinfo->getFieldLabel();
            if (($detailfieldinfo->getSaveDataBase() == 'yes' || $tablename == 'ld_products' || $tablename == 'ld_productcf') ||
                ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid'
                || $columnname == 'lasttaxprice' || $columnname == 'lastlistprice' || $columnname == 'pro_id') {
                if (array_key_exists($columnname, $header)) {
                    continue;
                }
                if ($tablename == 'ld_products' || $tablename == 'ld_productcf') {
                    $fieldinfo = $ProductsFiled->getFieldInfoobjBykey('columnname', $columnname);
                    if (empty($fieldinfo) || !$fieldinfo) {
                        continue;
                    }

                    $header[$columnname] = $fieldlabel;
                    $tmp['headername']['columnname'][$columnname] = $columnname;
                    $tmp['headername']['fieldname'][$columnname] = $fieldname;
                    $tmpwidth['fieldwidth'][$columnname] = $width * $proportion;
                    //数字类型靠右显示，字符串靠左显示
                    if (($typeofdata[0] == 'N' || $typeofdata[0] == 'NN')) {
                        $tdalign[$columnname] = 'right';
                    } else {
                        $tdalign[$columnname] = 'left';
                    }
                    $productcolumnname[] = $columnname;
                    $productdetail_column_sql[] = $tablename . '.' . $columnname;
                    $alldetail_fields[] = $columnname;
                } else if ($tablename == $Detail_table || $tablename == $Detail_table_scf) {
                    $header[$columnname] = $fieldlabel;
                    $tmp['headername']['columnname'][$columnname] = $columnname;
                    $tmp['headername']['fieldname'][$columnname] = $fieldname;
                    if ($columnname == 'entitytypeid' && $width <= 0) {
                        $tmpwidth['fieldwidth'][$columnname] = 50 * $proportion;
                    } else {
                        $tmpwidth['fieldwidth'][$columnname] = $width * $proportion;
                    }
                    //数字类型靠右显示，字符串靠左显示
                    if (($typeofdata[0] == 'N' || $typeofdata[0] == 'NN')) {
                        $tdalign[$columnname] = 'right';
                    } else {
                        $tdalign[$columnname] = 'left';
                    }
                    $detail_filed[] = $columnname;
                    $alldetail_fields[] = $columnname;
                }
            }
        }

        $total_width = 0;
        foreach ($tmpwidth['fieldwidth'] as $columnname => $width) {
            $total_width += $width;
        }

        // if(sizeof($productcolumnname)>0){
        //     $sql = "SELECT ".implode(',',$productdetail_column_sql).",trackid,prevaluejson,postvaluejson,lineitem_id from ld_detailtracker_detail ";
        //     $product_sql = " INNER JOIN ld_products on CONVERT(postvaluejson->'$.productid',signed) = ld_products.productid
        //         INNER JOIN ld_productcf on  ld_products.productid = ld_productcf.productid";
        //     $sql.= $product_sql;
        // }else{
        //     $sql = "SELECT trackid,prevaluejson,postvaluejson,lineitem_id from ld_detailtracker_detail ";
        // }
        $num_row = 0;
        //读取修改日志版本明细
        if(!empty($trackid_arr)){
            $sql = "SELECT trackid,prevaluejson,postvaluejson,lineitem_id,changetype from ld_detailtracker_detail ";
            $sql .= " where trackid in (" . implode(',', $trackid_arr) . ") order by lineitem_id asc;";

            $result = $adb->pquery($sql, array());
            $num_row = $adb->num_rows($result);
        }
        $change_column_arr = [];
        $navigationOutput = [];
        if ($num_row > 0) {
            for ($i = 0; $i < $num_row; $i++) {
                $detailinfo = array();
                $tmp_detailinfo = array();
                $trackid = $adb->query_result($result, $i, 'trackid');
                $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
                $changetype = $adb->query_result($result, $i, 'changetype');
                $prevaluejson = $adb->query_result($result, $i, 'prevaluejson');
                $postvaluejson = $adb->query_result($result, $i, 'postvaluejson');
                $postvalue = ldcrm_json_decode(html_entity_decode($postvaluejson));
                if (sizeof($productdetail_column_sql) > 0) {
                    $productid = $postvalue['productid'];
                    $product_sql = "SELECT " . implode(',', $productdetail_column_sql) . " from ld_products
                    INNER JOIN ld_productcf on  ld_products.productid = ld_productcf.productid 
                    where ld_products.productid = ?";
                    $product_result = $adb->pquery($product_sql, array($productid));

                    foreach ($productcolumnname as $columnname) {
                        $tmp_detailinfo[$columnname] = $adb->query_result($product_result, 0, $columnname);
                    }
                }
                //zkt 20240202 BUG0077116 销售订单（XSHT363）修改日志->单据分录，新增明细行没有标红（以前是段剑波做的）
                if ($prevaluejson != '' || ($prevaluejson == '' && $changetype == 'change')) {
                    $prevalue = ldcrm_json_decode(html_entity_decode($prevaluejson));
                    //产品修改后按新增行处理
                    if (is_array($prevalue) && is_array($postvalue) && $prevalue['productid'] != $postvalue['productid']) {
                        $change_column_arr[$trackid][$lineitem_id]['productname'] = 'yes';
                        foreach ($productcolumnname as $columnname) {
                            $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                        }
                        foreach ($detail_filed as $columnname) {
                            $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                            $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                        }
                    } else {
                        foreach ($detail_filed as $columnname) {
                            $tmp_detailinfo[$columnname] = $postvalue[$columnname];

                            $detailfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $columnname);
                            // 判断此版本与上个版本相比哪些字段修改过
                            // 附件图片字段需要分开处理
                            if($detailfieldinfo && ($detailfieldinfo->getBigType() == 'fileattachment' || $detailfieldinfo->getBigType() == 'image')){
                                $this->getAttachmentImgHistory($record,'detail');
                                // 图片不需要标红
                                if($detailfieldinfo->getBigType() == 'image'){
                                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                                }
                                // 判断附件是否修改过
                                $is_attachment_change = $this->isDetailAttachmentChange($prevalue[$columnname],$postvalue[$columnname]);
                                if ($is_attachment_change == 'yes') {

                                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                                } else {
                                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                                }
                            }else{
                                if ($prevaluejson != '' && $postvalue[$columnname] != $prevalue[$columnname]) {

                                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                                } else {
                                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                                }
                            }
                        }
                    }

                } else if ($changetype == 'create' && $detail_basic_info[$trackid]['version'] != 'V1.0') {
                    //duan 20220802 对新加行的所有字段进行标红处理
                    foreach ($detail_filed as $columnname) {
                        $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                        $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                    }
                    foreach ($productcolumnname as $columnname) {
                        $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                    }
                    $change_column_arr[$trackid][$lineitem_id]['productname'] = 'yes';
                } else {
                    foreach ($detail_filed as $columnname) {
                        $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                        $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                    }
                }

                //收款单模块的合同金额和合同已收总额需要读取最新的数据
                if (!empty($tmp_detailinfo['entitytype']) && !empty($tmp_detailinfo['entitytypeid'])) {
                    if ($module == 'CashBill') {
                        $entitytype = $tmp_detailinfo['entitytype'];
                        $source_focus = CRMEntity::getInstance($entitytype);
                        $entitytypeid = $tmp_detailinfo['entitytypeid'];
                        if ($entitytype == 'PaymentPlan') {
                            //回款计划收款，改为获取合同信息单据相关的收款单明细信息
                            $payment_sql = "select entitytype,entitytypeid from ld_paymentplan where paymentplanid=$entitytypeid";
                            $payment_result = $adb->pquery($payment_sql, array());
                            $sourcemodule = $adb->query_result($payment_result, 0, 'entitytype');
                            $sourcemodule_id = $adb->query_result($payment_result, 0, 'entitytypeid');
                            $source_focus = CRMEntity::getInstance($sourcemodule);

                            $query = "select total as source_total,received_amount as received_amount,currency_id,conversion_rate,currency_symbol 
                                        from $source_focus->table_name where $source_focus->table_index = $sourcemodule_id";
                        } else {
                            $query = "select total as source_total,received_amount as received_amount,currency_id,conversion_rate,currency_symbol 
                                        from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                        }
                        $tmp_result = $adb->pquery($query, array());
                        if ($adb->num_rows($tmp_result) > 0) {
                            $tmp_detailinfo['source_total'] = $adb->query_result($tmp_result, 0, 'source_total');
                            $tmp_detailinfo['received_amount'] = $adb->query_result($tmp_result, 0, 'received_amount');
                        }

                    } else if ($module == 'SendCashBill') {
                        $entitytype = $tmp_detailinfo['entitytype'];
                        $source_focus = CRMEntity::getInstance($entitytype);
                        $entitytypeid = $tmp_detailinfo['entitytypeid'];
                        if ($entitytype == 'SendPayment') {
                            //付款计划付款，改为获取采购订单信息单据相关的明细信息
                            $sendpayment_sql = "select purchaseorder_id from ld_sendpayment where sendpaymentid=$entitytypeid";
                            $sendpayment_result = $adb->pquery($sendpayment_sql, array());
                            $entitytypeid = $adb->query_result($sendpayment_result, 0, 'purchaseorder_id');
                            $sourcemodule = 'PurchaseOrder';
                            $source_focus = CRMEntity::getInstance($sourcemodule);
                            $query = "select total as source_total,pay_amount as pay_amount  
                                from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                        } else {
                            $query = "select total as source_total,pay_amount as pay_amount 
                                from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                        }
                        $tmp_result = $adb->pquery($query, array());
                        $tmp_detailinfo['source_total'] = $adb->query_result($tmp_result, 0, 'source_total');
                        $tmp_detailinfo['pay_amount'] = $adb->query_result($tmp_result, 0, 'pay_amount');
                    }
                }


                //通过字段类型控制显示格式
                foreach ($alldetail_fields as $columnname) {
                    $value = $tmp_detailinfo[$columnname];
                    //项目工时模块，关联类型特殊显示
                    if ($module == 'TimeSheet' && $columnname == 'timetype') {
                        if ($value == 'Direct') {
                            $value = getFixedLabel('timesheet_direct');
                        } else if ($value == 'Indirect') {
                            $value = getFixedLabel('timesheet_indirect');
                        }
                    }

                    if ($columnname == 'source_total') {
                        //收款单和付款单的合同金额字段增加小数位控制
                        $delopy_value = getSys_deploy(93);

                        //$value = setNumberFormat($value,$delopy_value['delopy_value']);

                    }

                    if (get_file_address($module, "ProductDetails")

                        || (($module == 'CashBill' || $module == 'SendCashBill') && $isproductentitytype == 'yes')) {
                        //产品分录显示
                        $detailfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $columnname);

                        // 附件图片修改日志
                        if ($detailfieldinfo->getBigType() == 'fileattachment' || $detailfieldinfo->getBigType() == 'image') {
                            $showvalue['rawvalue'] = '';
                            $showvalue['value'] = '';
                            if(!empty($value)){
                                $showvalue['rawvalue'] = $value;
                                $showvalue['value'] = $this->getAttachmentImgLogsHtml($record,$detailfieldinfo,$value,'detail');
                            }
                        }else{
                            $showvalue = $showfieldvalueobj->getFieldValueByField($detailfieldinfo, $value, $value);
                        }

                        if ($detailfieldinfo->getBigType() == 'multipicklist') {
                            //多选框处理
                            $showvalue['value'] = str_replace(' |##| ', ' , ', $showvalue['value']);
                            $showvalue['rawvalue'] = str_replace(' |##| ', ' , ', $showvalue['rawvalue']);
                        } else if ($detailfieldinfo->getBigType() == 'reference') {
                            //日志中不需要显示超链接
                            $fld_module = $detailfieldinfo->getReferenceModule();
                            $showvalue = array();
                            $showvalue['value'] = getModuleHref($fld_module, $value);
                        }
                    } else if (get_file_address($module, $module . "DetailFieldsHtml")) {
                        //其他分录显示
                        $detailfieldinfo = $DetailToolFiledsInfo[$columnname];

                        // 附件图片修改日志
                        if ($detailfieldinfo->getBigType() == 'fileattachment' || $detailfieldinfo->getBigType() == 'image') {
                            $showvalue['rawvalue'] = '';
                            $showvalue['value'] = '';
                            if(!empty($value)){
                                $showvalue['rawvalue'] = $value;
                                $showvalue['value'] = $this->getAttachmentImgLogsHtml($record,$detailfieldinfo,$value,'detail');
                            }
                        }else{
                            $showvalue = $TabDetailFieldsHtmlTd->getColumnValue($detailfieldinfo, $columnname, $value, SHOW_EDITVIEW);
                        }

                        if ($detailfieldinfo->getFieldType() == 'SelectComBox') {
                            //多选框处理
                            $showvalue['value'] = str_replace(' |##| ', ' , ', $showvalue['value']);
                            $showvalue['rawvalue'] = str_replace(' |##| ', ' , ', $showvalue['rawvalue']);
                        } else if ($detailfieldinfo->getBigType() == 'reference') {
                            //日志中不需要显示超链接
                            $fld_module = $detailfieldinfo->getReferenceModule();
                            $showvalue = array();
                            $showvalue['value'] = getModuleHref($fld_module, $value);
                        }
                    }

                    if (empty($showvalue['value'])) {
                        $value = $showvalue['rawvalue'];
                    } else {
                        $value = $showvalue['value'];
                    }
                    $detailinfo[$columnname] = $value;
                }

                $detail_basic_info[$trackid]['detail'][$lineitem_id] = $detailinfo;
                $rowspan[$trackid] += 1;
            }

            //分页信息
            crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
            $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
            $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
            $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, $module, 'ModTrackerFldLog', $record);
        }

        $return_value = array('header' => $header, 'entries' => $detail_basic_info, 'navigation' => $navigationOutput,
            'headername' => $tmp['headername'], 'fieldwidth' => $tmpwidth['fieldwidth'], 'total_width' => $total_width,
            'title' => getFixedLabel('View History'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'),
            'noofrows' => $noofrows, 'rowspan' => $rowspan, 'tdalign' => $tdalign, 'changedcolumn' => $change_column_arr);

        return $return_value;
    }

    /**
     * 获取日志sql
     */
    protected function getLogQuery($module, $label)
    {
        global $current_user,$adb;
        $isEditDetail = $this->isEditDetail;
        $Smownerids = getCurSmOwnerSearchScope($module);// 数据范围
        $userids = $current_user->id;
        foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
            if (!empty($userid))
                $userids .= "," . $userid;
        }
        if($module=='Users'&&isPermitted($module)=='yes')
        {
            $sql='select group_concat(id) as ids from ld_users ';
            $result =$adb->pquery($sql,array());
            $userids=$adb->query_result($result,0,'ids');

        }



        if ($label == 'OperationLogs') {
            $query = "SELECT *,? as tabid FROM ld_crmlog_entity where crmid = ? AND userid in ( $userids )";
        } else if ($label == 'signlog') {
            $query = "SELECT sign_date,channelcode_id,address,longtitude,latitude,? as tabid from ld_wechatuser_sign where wechatuserid = ? ";
        } else if ($label == 'publicaccount_log') {
            if ($module == 'Leads') {
                $query = "SELECT ld_users.wx_userid,ld_users.last_name,ld_logpublicleads.username,operation,opdate,ld_logpublicleads.userid,zh_name,en_name,? as tabid
                        from ld_logpublicleads 
                        left join ld_users on ld_users.id=ld_logpublicleads.userid 
                        LEFT JOIN ld_leads_public_pool on ld_leads_public_pool.id = ld_logpublicleads.pool_id 
                        where leadsid=? ";
            } else {
                $query = "SELECT ld_users.wx_userid,ld_users.last_name,ld_logpublicaccount.username,operation,opdate,ld_logpublicaccount.userid,zh_name,en_name,? as tabid 
                    from ld_logpublicaccount 
                    left join ld_users on ld_users.id=ld_logpublicaccount.userid 
                    LEFT JOIN ld_account_public_pool on ld_account_public_pool.id = ld_logpublicaccount.pool_id 
                    where ld_logpublicaccount.accountid=? ";
            }//wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        } else if ($label == "ViewHistory" && $isEditDetail == 'yes') { //改动1
            $query = 'SELECT DISTINCT ld_modtracker_basic.id,ld_modtracker_basic.module,ld_field.uitype,
                            ld_modtracker_basic.whodid,ld_modtracker_basic.changedon,
                            ld_modtracker_basic.status,ld_modtracker_detail.fieldname,
                            ld_modtracker_detail.prevalue,ld_modtracker_detail.postvalue 
                        FROM ld_modtracker_basic 
                            INNER JOIN ld_modtracker_detail ON ld_modtracker_detail.`id` = ld_modtracker_basic.`id`
                            INNER JOIN ld_field ON ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ? and ld_field.presence <> 1 
                            INNER JOIN ld_crmlog_relation ON ld_crmlog_relation.relation_id = ld_modtracker_basic.`id` and ld_crmlog_relation.operation_log_id = ?
                        WHERE ld_modtracker_basic.`crmid` = ? AND ld_modtracker_basic.whodid in ( ' . $userids . ' )';
        } else {
            $query = 'SELECT DISTINCT ld_modtracker_basic.id,ld_modtracker_basic.module,ld_field.uitype,
                            ld_modtracker_basic.whodid,ld_modtracker_basic.changedon,
                            ld_modtracker_basic.status,ld_modtracker_detail.fieldname,
                            ld_modtracker_detail.prevalue,ld_modtracker_detail.postvalue 
                        FROM ld_modtracker_basic 
                            INNER JOIN ld_modtracker_detail ON ld_modtracker_detail.`id` = ld_modtracker_basic.`id`
                            INNER JOIN ld_field ON ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ? and ld_field.presence <> 1 
                        WHERE ld_modtracker_basic.`crmid` = ? AND ld_modtracker_basic.whodid in ( ' . $userids . ' )';
        }
        
        return $query;
    }

    /**
     * 获取表头翻译
     */
    protected function getHeaderLabel($label)
    {
        $isEditDetail = $this->isEditDetail;
        $this->curLogInfo['operator'] = getFixedLabel('OPERATOR');
        $this->curLogInfo['operateTime'] = getFixedLabel('OPERATTIME');
        if ($label == 'ChangeView') {//负责人变更历史
            $header = array(
                'prevalue' => getFixedLabel('LBL_Earlier'),
                'postvalue' => getFixedLabel('LBL_Present'),
                'whodid' => getFixedLabel('OPERATOR'),
                'changedon' => getFixedLabel('OPERATTIME')
            );
//wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        } elseif ($label == "ViewHistory" && $isEditDetail == 'yes') {  //改动2
            $header = array('fieldname' => getFixedLabel('LBL_Field'),
                'prevalue' => getFixedLabel('LBL_Earlier'),
                'postvalue' => getFixedLabel('LBL_Present'));
        } else if ($label == 'OperationLogs') {
            global $PlatformMC;
            if (!empty($PlatformMC)) {
                $header = array(
                    'operator' => getFixedLabel('operatoroer'),
                    'operationtime' => getFixedLabel('operatoroertime'),
                    'operationbehavior' => getFixedLabel('OperationBehavior'),
                    'operationdetails' => getFixedLabel('OperationDetails'),
                    'logid' => '',
                    'isEditDetail' => ''
                );
            }
            else{
                $header = array(
                    'operator' => getFixedLabel('operatoroer'),
                    'operationtime' => getFixedLabel('operatoroertime'),
                    'operationbehavior' => getFixedLabel('OperationBehavior'),
                    'operationModules' => getFixedLabel('OperationModules'),
                    'OperationData' => getFixedLabel('OperationData'),
                    'operationdetails' => getFixedLabel('OperationDetails')
                );
            }
        } else if ($label == 'signlog') {
            $version_info = getVersionInfo();

            if ($version_info['account'] == 'dongmao') {
                $header = array(
                    'prevalue' => getFixedLabel('channelname'),
                    'postvalue' => getFixedLabel('accountname2'),
                    'whodid' => getFixedLabel('SIGNTIME'),
                    'address' => getFixedLabel('SINGINADDRESS'),
                    'longtitude' => getFixedLabel('signlongtitude'),
                    'latitude' => getFixedLabel('signlatitude'),
                );
            } else {
                $header = array(
                    'whodid' => getFixedLabel('SIGNTIME')
                );
            }
        } else if ($label == 'publicaccount_log') {
            $header = array(
                'prevalue' => getFixedLabel('DATE'),
                'postvalue' => getFixedLabel('OPERATING'),
                'Highseaspool' => getFixedLabel('Highseaspool'),
                'whodid' => getFixedLabel('operatoroer')
            );
        } else {
            $header = array('fieldname' => getFixedLabel('LBL_Field'),
                'prevalue' => getFixedLabel('LBL_Earlier'),
                'postvalue' => getFixedLabel('LBL_Present'),
                'whodid' => getFixedLabel('OPERATOR'),
                'changedon' => getFixedLabel('OPERATTIME'));
        }

        return $header;
    }
    /**
     * 获取字段td宽度
     */
    protected function getFieldWidth($label)
    {
        global $adb, $current_user, $PlatformMC, $currentModule;
        $isEditDetail = $this->isEditDetail;
        if ($label == 'OperationLogs') {
            $tmpwidth['fieldwidth']['operator'] = 200;
            $tmpwidth['fieldwidth']['operationtime'] = 250;
            $tmpwidth['fieldwidth']['operationbehavior'] = 150;
        }
//wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        else if ($label == 'ViewHistory') {
            if ($isEditDetail == 'yes') {
                $tmpwidth['fieldwidth']['fieldname'] = 300;
                $tmpwidth['fieldwidth']['prevalue'] = 300;
                $tmpwidth['fieldwidth']['postvalue'] = 300;
            } else {
                crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
                $sql = 'select * from ld_list_headerwidth where module=? and type=? and userid=? ';
                $result = $adb->pquery($sql, array('viewhistory', 'viewhistory', $current_user->id));
                $rows = $adb->num_rows($result);
            }
            if ($rows <= 0) {
                $tmpwidth['fieldwidth']['fieldname'] = getModuleFieldProportion(1);
                $tmpwidth['fieldwidth']['prevalue'] = getModuleFieldProportion(1);
                $tmpwidth['fieldwidth']['postvalue'] = getModuleFieldProportion(1);
                $tmpwidth['fieldwidth']['whodid'] = getModuleFieldProportion(1);
                $tmpwidth['fieldwidth']['changedon'] = getModuleFieldProportion(1);

            } else{
                for ($i = 0; $i < $rows; $i++) {
                    $columns = $adb->query_result($result, $i, 'columns');

                    $tmpwidth['fieldwidth'][$columns] = $adb->query_result($result, $i, 'header_width') . 'setting';

                }
            }
            $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $currentModule);
            $tmpwidth['fieldwidth']['fieldname'] = $widthinfo[0];
            $tmpwidth['fieldwidth']['prevalue'] = $widthinfo[1];
            $tmpwidth['fieldwidth']['postvalue'] = $widthinfo[2];
            $tmpwidth['fieldwidth']['whodid'] = $widthinfo[3];
            $tmpwidth['fieldwidth']['changedon'] = $widthinfo[4];
        } else if ($label == 'signlog') {
            crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
            $version_info = getVersionInfo();
            $tmpwidth['fieldwidth']['sign_date'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['address'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['longtitude'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['latitude'] = getModuleFieldProportion(1);
            if ($version_info['account'] == 'dongmao') {
                $tmpwidth['fieldwidth']['channel_name'] = getModuleFieldProportion(1);
                $tmpwidth['fieldwidth']['accountname'] = getModuleFieldProportion(1);

                $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $currentModule);
                $tmpwidth['fieldwidth']['channel_name'] = $widthinfo[0];
                $tmpwidth['fieldwidth']['accountname'] = $widthinfo[1];
                $tmpwidth['fieldwidth']['sign_date'] = $widthinfo[2];
                $tmpwidth['fieldwidth']['address'] = $widthinfo[3];
                $tmpwidth['fieldwidth']['longtitude'] = $widthinfo[4];
                $tmpwidth['fieldwidth']['latitude'] = $widthinfo[5];

            } else {

                $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $currentModule);
                $tmpwidth['fieldwidth']['sign_date'] = $widthinfo[0];
                $tmpwidth['fieldwidth']['address'] = $widthinfo[1];
                $tmpwidth['fieldwidth']['longtitude'] = $widthinfo[2];
                $tmpwidth['fieldwidth']['latitude'] = $widthinfo[3];

            }
        } else if ($label == 'publicaccount_log') {
            $tmpwidth['fieldwidth']['opdate'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['operation'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['username'] = getModuleFieldProportion(1);
            $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $currentModule);
            $tmpwidth['fieldwidth']['prevalue'] = 200;
            $tmpwidth['fieldwidth']['Highseaspool'] = 200;
            $tmpwidth['fieldwidth']['whodid'] = 200;

        }

        return array('tmpwidth' => $tmpwidth, 'widthinfo' => $widthinfo);
    }
    protected function getHeadername($label)
    {
        global $adb, $current_user, $PlatformMC, $currentModule;

        if ($label == 'ViewHistory') {
            $tmp['headername']['columnname']['fieldname'] = 'fieldname';
            $tmp['headername']['columnname']['prevalue'] = 'prevalue';
            $tmp['headername']['columnname']['postvalue'] = 'postvalue';
            $tmp['headername']['columnname']['whodid'] = 'whodid';
            $tmp['headername']['columnname']['changedon'] = 'changedon';
            $tmp['headername']['fieldname']['fieldname'] = 'fieldname';
            $tmp['headername']['fieldname']['prevalue'] = 'prevalue';
            $tmp['headername']['fieldname']['postvalue'] = 'postvalue';
            $tmp['headername']['fieldname']['whodid'] = 'whodid';
            $tmp['headername']['fieldname']['changedon'] = 'changedon';

        } else if ($label == 'signlog') {
            $version_info = getVersionInfo();
            if ($version_info['account'] == 'dongmao') {

                $tmp['headername']['columnname']['channel_name'] = 'channel_name';
                $tmp['headername']['columnname']['accountname'] = 'accountname';
                $tmp['headername']['columnname']['sign_date'] = 'sign_date';
                $tmp['headername']['columnname']['address'] = 'address';
                $tmp['headername']['columnname']['longtitude'] = 'longtitude';
                $tmp['headername']['columnname']['latitude'] = 'latitude';
                $tmp['headername']['fieldname']['channel_name'] = 'channel_name';
                $tmp['headername']['fieldname']['accountname'] = 'accountname';
                $tmp['headername']['fieldname']['sign_date'] = 'sign_date';
                $tmp['headername']['fieldname']['address'] = 'address';
                $tmp['headername']['fieldname']['longtitude'] = 'longtitude';
                $tmp['headername']['fieldname']['latitude'] = 'latitude';

            } else {

                $tmp['headername']['columnname']['sign_date'] = 'sign_date';
                $tmp['headername']['columnname']['address'] = 'address';
                $tmp['headername']['columnname']['longtitude'] = 'longtitude';
                $tmp['headername']['columnname']['latitude'] = 'latitude';
                $tmp['headername']['fieldname']['sign_date'] = 'sign_date';
                $tmp['headername']['fieldname']['address'] = 'address';
                $tmp['headername']['fieldname']['longtitude'] = 'longtitude';
                $tmp['headername']['fieldname']['latitude'] = 'latitude';

            }
        } else if ($label == 'publicaccount_log') {

            $tmp['headername']['columnname']['opdate'] = 'opdate';
            $tmp['headername']['columnname']['operation'] = 'operation';
            $tmp['headername']['columnname']['username'] = 'username';
            $tmp['headername']['fieldname']['opdate'] = 'opdate';
            $tmp['headername']['fieldname']['operation'] = 'operation';
            $tmp['headername']['fieldname']['username'] = 'username';
        }

        return $tmp;
    }

    /**
     * 获取字段td宽度
     */
    protected function getNoofrows($module, $record, $label)
    {
        global $adb, $current_user, $PlatformMC, $currentModule;

        if ($label == 'signlog' || $label == 'publicaccount_log') {
            $query = $this->getLogQuery($module, $label);
            $tabid = getTabid($module);
            $result = $adb->pquery($query, array($tabid,$record));
            $noofrows = $adb->num_rows($result);
        } else {
            $lognum = $this->getFieldUpdateLogNum($module, $record, $label);// 条数
            $noofrows = $lognum['relcount'];
        }

        return $noofrows;
    }

    /**
     * 获取相关信息中的几种类型日志
     */
    public function getRelatedInfoLog($module, $record, $tabid, $relationInfo)
    {

        global $adb, $list_max_entries_per_page_new_more, $currentModule;
        global $current_user, $PlatformMC, $languageType;
        $logid = $this->logId;
        $label = $relationInfo['label'];
        $tabid = getTabid($module);
        $focus = CRMEntity::getInstance($module);
        $version_info = getVersionInfo();

        $noofrows = $this->getNoofrows($module, $record, $label);
        $isEditDetail = $this->isEditDetail;
        $query = $this->getLogQuery($module, $label);

        if ($label == 'OperationLogs') {// 操作日志
            // 显示最大条数
            $list_max_entries_per_page_new_more = getUsersettingByLabel('OperationLogs', $current_user->id, 'MaxEntriesPerPageByuser') ?? getUsersettingByLabel('OperationLogs', 1, 'MaxEntriesPerPage');
            $list_max_entries_per_page_new_more = empty($list_max_entries_per_page_new_more) ? '20' : $list_max_entries_per_page_new_more;

            $query .= ' ORDER BY ld_crmlog_entity.operationtime desc ';
        } else if ($label == 'signlog') {

            $query .= " order by ld_wechatuser_sign.sign_date desc";
        } else if ($label == 'publicaccount_log') {

            $query .= " order by opdate desc";
        } else {
            if ($label == 'ViewHistory') {
                //富文本框选择是否隐藏
                $Richtexthide = getUsersettingByLabel($module, $current_user->id, 'Richtexthide');
                $Richtexthide = empty($Richtexthide) ? 'yes' : $Richtexthide;
                //同个模块下富文本框类型字段是否存在,不存在则不显示"隐藏富文本框的修改日志"按钮
                $fieldinfo230 = $focus->fieldobj->getFieldInfoobjBykey('uitype', '230');
                $fieldinfo231 = $focus->fieldobj->getFieldInfoobjBykey('uitype', '231');
                if (empty($fieldinfo230) && empty($fieldinfo231)) {
                    $Richtexthide = '';
                }
            }
            //zkt 20240308 BUG20240218-37 kfbcrm-自定义表单11-“文本加密”字段有敏感规则，负责人或创建人不是当前操作员时，字段加密显示，单据ZDYBD11-21，admin账号查看该单据 单据详情中字段是加密显示的，但是在修改日志中字段显示明文
            $focus->retrieve_entity_info($record, $module);
            crm_load_class_file("cls_fieldSensitiverule", "include/fields");
            $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
            $cls_fieldSensitiveruleobj->setColumnValuesbyfieldnamearr($focus->column_fields);
            $cls_fieldSensitiveruleobj->setRecord($record);
            $sensitiveresultinfo = $cls_fieldSensitiveruleobj->getSensitiveResultInfobyColumnname();

            if ($module == "Potentials") {//BUG0062878 xxy 2023-9-27 “销售机会”编辑单据分录改变价格，修改日志中会出现两行重复的“合计”字段
                $sys_205 = getSys_deploy(205);
                if ($sys_205['deploy_value'] == 0) {
                    $query .= " AND ld_field.fieldname != 'amount' AND ld_modtracker_detail.fieldname != 'amount' ";
                }
            }
            $where = '';
            if ($label == 'ChangeView') {
                $where .= " and ld_field.fieldname='$this->fieldname' and ld_modtracker_basic.module='" . $module . "' ";
            }
            if ($Richtexthide == 'yes') {
                $where .= " and ld_field.uitype != 230 and ld_field.uitype != 231 ";
            }
            $query .= $where;
            $filter = array();
            $filter['record'] = $input['record'];
            //order by 排序
            $order_by = 'ld_modtracker_basic.changedon';
            $sorder = 'desc';

            $filter['order_by'] = $order_by;
            $filter['sorder'] = $sorder;
            $query .= ' ORDER BY ' . $order_by . ' ' . $sorder . ',ld_modtracker_basic.id desc ';

        }

        //获取当前页数
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = $_REQUEST['start'];
            //zkt 20220817 BUG0055210客户详情界面，选择修改日志，跳转到大于最大页数的页面，出现如下界面，且没有再输入的地方，关联BUG：BUG0054429
            if ($start > ceil($noofrows / $list_max_entries_per_page_new_more)) {
                $start = 'last';
            }
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        $filter['start'] = $start;
        //计算limit
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        if (!empty($PlatformMC)) {
//            $query .= ' limit 0,10';
        } else {
            $query .= ' LIMIT ' . $limstart . ',' . $list_max_entries_per_page_new_more . ' ';
        }

        //读取数据
//wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
        if ($label == 'ViewHistory' && $isEditDetail == 'yes') {
            $result = $adb->pquery($query, array($tabid, $logid, $record));
        } else {
            $result = $adb->pquery($query, array($tabid, $record));
        }


        $rows = $adb->num_rows($result);
        // 获取表头翻译
        $header = $this->getHeaderLabel($label);
        $entity = array();
        $navigationOutput = array();
        $url_qry = '';

        if ($rows >= 0) {
            if ($label == 'OperationLogs') {
                for ($i = 0; $i < $rows; $i++) {
                    $logid = $adb->query_result($result, $i, 'id');
                    $actiontype = $adb->query_result($result, $i, 'actiontype');
                    $relatedid = $adb->query_result($result, $i, 'relatedid');
                    if (!empty($relatedid))
                        $log_arr[$actiontype][] = $relatedid;
                    else
                        $log_arr[$actiontype][] = $logid;
                }
                crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');

                foreach ($log_arr as $actiontype => $logids) {
                    $cls_operationlogs = cls_OperationLogs::getInstance($module, $actiontype);
                    $cls_operationlogs->setLogsFrom($this->logs_from);
                    $action_info = $cls_operationlogs->getRelatedListInfo($logids);
                    if (empty($entity)) {
                        $entity = $action_info;
                    } else {
                        if (!empty($action_info))
                            $entity = array_merge($entity, $action_info);
                    }
                }
                // 根据操作时间降序
                usort($entity, function ($a, $b) {
                    return strtotime($b['operationtime']) - strtotime($a['operationtime']);
                });
            } else if ($label == 'signlog') {
                for ($i = 0; $i < $rows; $i++) {
                    $sign_date = $adb->query_result($result, $i, 'sign_date');
                    $channelcode_id = $adb->query_result($result, $i, 'channelcode_id');
                    if ($version_info['account'] == 'dongmao') {
                        $channel_query = 'select channel_name,ld_account.accountname from ld_channelcode 
                        LEFT JOIN ld_account on ld_account.accountid = ld_channelcode.servicecharge_id 
                        where ld_channelcode.id = ?';
                        $channel_result = $adb->pquery($channel_query, array($channelcode_id));
                        $channel_name = $adb->query_result($channel_result, 0, 'channel_name');
                        $accountname = $adb->query_result($channel_result, 0, 'accountname');
                        $entity[$i]['channel_name'] = $channel_name;
                        $entity[$i]['accountname'] = $accountname;
                        $entity[$i]['sign_date'] = $sign_date;
                    } else {
                        $entity[$i]['sign_date'] = $sign_date;
                    }
                    $entity[$i]['address'] = $adb->query_result($result, $i, 'address');
                    $entity[$i]['longtitude'] = $adb->query_result($result, $i, 'longtitude');
                    $entity[$i]['latitude'] = $adb->query_result($result, $i, 'latitude');
                }
            } else if ($label == 'publicaccount_log') {
                for ($i = 0; $i < $rows; $i++) {
                    $opdate = $adb->query_result($result, $i, 'opdate');
                    $operation = $adb->query_result($result, $i, 'operation');
                    $loguserid = $adb->query_result($result, $i, "userid");
                    $zh_name = $adb->query_result($result, $i, "zh_name");
                    $en_name = $adb->query_result($result, $i, "en_name");
                    if (stripos($operation, '$###$') !== false) {

                        $strs = explode('$###$', $operation);

                        $operation = sprintf(getFixedLabel($strs[0]), $strs[1]);

                    } else if (stripos($operation, '$####$') !== false)//释放原因
                    {
                        $strs = explode('$####$', $operation);
                        $operation = getFixedLabel($strs[0]);

                        $operation .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('RELEASEACCOUNTTREASON') . ':' . $strs[1];
                    } else {
                        //chj 2021/1/14 44264: 公海操作日志：将客户转为公海客户，建议后面增加“公海池信息”
                        if ($operation == 'TOBETHEHIGHSEASCUSTOMTERS') {
                            if ($languageType == 'zh')
                                $operation = getFixedLabel($operation) . ',' . getFixedLabel('Highseaspool') . ': ' . $zh_name;
                            else
                                $operation = getFixedLabel($operation) . ',' . getFixedLabel('Highseaspool') . ': ' . $en_name;
                        } else {
                            $operation = getFixedLabel($operation);
                        }
                    }
                    if (!empty($loguserid)) {
                        $userobj = new Users();
                        $userobj->last_name = $adb->query_result($result, $i, "last_name");
                        $userobj->wx_userid = $adb->query_result($result, $i, "wx_userid");
                        $user_lastname = getUserlastName($userobj);
                    } else {
                        $userobj = new Users();
                        $userobj->last_name = $adb->query_result($result, $i, "username");
                        $userobj->wx_userid = $adb->query_result($result, $i, "wx_userid");
                        $user_lastname = getUserlastName($userobj);
                    }
                    $entity[$i]['opdate'] = $opdate;
                    $entity[$i]['operation'] = $operation;
                    $entity[$i]['zh_name'] = $zh_name;
                    $entity[$i]['username'] = $user_lastname;
                }

            } else {
                //$module = $adb->query_result($result,0,'module');
                $fieldobj = Field::getInstance($module, $adb);
                $modulefield = $fieldobj->getModuleFields();
                $showfieldvalue = new ShowFieldValue($fieldobj, $module, SHOW_POPUP);
                $showfieldvalue->setRecorId($record);
                $showfieldvalue->result = $result;

                for ($i = 0; $i < $rows; $i++) {
                    $fieldname = $adb->query_result($result, $i, 'fieldname');
                    $prevalue = html_entity_decode((string)$adb->query_result($result, $i, 'prevalue'));
                    $postvalue = html_entity_decode((string)$adb->query_result($result, $i, 'postvalue'));
                    $whodid = $adb->query_result($result, $i, 'whodid');
                    $changedon = $adb->query_result($result, $i, 'changedon');
                    $trackid = $adb->query_result($result, $i, 'id');
                    if (!empty($modulefield[$fieldname])) {
                        $fieldlabel = $modulefield[$fieldname]->getFieldLabel($module, $fieldname);
                    }
                    if ($fieldname == 'deleted') {
                        //18579: 销售退货单>明细：删除销售退货单后，在回收站还原。查看该销售退货单的修改日志，结果：修改日志显示为deleted。
                        $fieldlabel = getFixedLabel('DELETE');
                        if ($prevalue == 1) {
                            $prevalue = getFixedLabel('DELETE');
                            $postvalue = getFixedLabel('REDUCTION');
                        } else {
                            $prevalue = '';
                            $postvalue = getFixedLabel('DELETE');
                        }

                    } else {

                        $field = $modulefield[$fieldname];
                        if (!$field) {
                            continue;
                        }
                        //BUG0068644 ls 成员管理->个人头像：个人头像的修改日志记录不正确，修改前和修改后的内容是一样的(修改为页面显示修改日志表原值)
                        if ($field->getBigType() != 'Signin' && $field->getUIType() != '105' && $field->getBigType() != 'fileattachment') {
                            $showvalue = $showfieldvalue->getFieldValueByField($field, $prevalue, $prevalue);
                            $prevalue = $showvalue['value'];
                            $showvalue = $showfieldvalue->getFieldValueByField($field, $postvalue, $postvalue);
                            $postvalue = $showvalue['value'];

                        }
                        else if($field->getBigType() == 'fileattachment'){
                            $prevalue = $this->getAttachmentImgLogsHtml($record,$field,$prevalue);
                            $postvalue = $this->getAttachmentImgLogsHtml($record,$field,$postvalue);
                            // dump($prevalue);
                        }
                    }
                    if ($label != 'ChangeView') {
                        $entity[$i]['fieldname'] = $fieldlabel;
                    }
                    $username = 'System';
                    if ($whodid > 0) {
                        $username = getUserFullName($whodid);
                    }
                    if ($whodid == -1503) {
                        //表单码修改，显示为链接
                        $username = '<a onclick="FormQrCode_Viewlog(' . $trackid . ',\'' . $module . '\',0,0,0)">' . getFixedLabel('FORMCODE') . getFixedLabel('UPDATES') . '</a>';
                    }
                    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname', $fieldname);
                    if ($fieldinfo->gethavesensitivevalue() == 'yes') {
                        $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
                        $tmpcolumn_value = $prevalue;
                        $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($fieldinfo, $tmpcolumn_value);
                        if (!empty($tmpcolumn_value_arr)) {
                            $prevalue = $tmpcolumn_value_arr['secretvalue'];
                        }
                        $tmpcolumn_value = $postvalue;
                        $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($field, $tmpcolumn_value);
                        if (!empty($tmpcolumn_value_arr)) {
                            $postvalue = $tmpcolumn_value_arr['secretvalue'];
                        }

                    }
                    $entity[$i]['prevalue'] = $prevalue;
                    $entity[$i]['postvalue'] = $postvalue;
                    $entity[$i]['username'] = $username;
                    $entity[$i]['changedon'] = $changedon;
                    $this->curLogInfo['username'] = $username;
                    $this->curLogInfo['changedon'] = $changedon;
                    if ($label == 'ViewHistory')
                        $entity[$i]['autowordwrap'] = $fieldinfo->getautowordwrap() == 'yes' ? 'yes' : 'no';// 字段自动换行属性
                        //wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
                        if ($isEditDetail == 'yes') {
                            unset($entity[$i]['username']);
                            unset($entity[$i]['changedon']);
                        }

                }
            }

            crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
            $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
            $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
            $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, $module, 'ModTrackerFldLog', $record);
        }
        // 宽度
        $total_width = 0;
        $widthinfo_arr = $this->getFieldWidth($label);
        $tmpwidth = $widthinfo_arr['tmpwidth'];
        foreach ($widthinfo as $tmp_width) {
            $total_width += $tmp_width;
        }

        $tmp = $this->getHeadername($label);

        if ($label == 'ChangeView') {//负责人变更历史
            $return_value = array('header' => $header, 'entries' => $entity, 'navigation' => $navigationOutput,
                'title' => $languageheader . getFixedLabel('ChangeView'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'), 'noofrows' => $noofrows);

        } else if ($label == 'OperationLogs') {
            $return_value = array('header' => $header, 'entries' => $entity, 'navigation' => $navigationOutput, 'fieldwidth' => $tmpwidth['fieldwidth'], 'total_width' => $total_width,
                'title' => getFixedLabel('OperationLogs'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'), 'noofrows' => $noofrows);

        } else if ($label == 'signlog' || $label == 'publicaccount_log') {
            $return_value = array('header' => $header, 'entries' => $entity, 'navigation' => $navigationOutput,
                'headername' => $tmp['headername'], 'fieldwidth' => $tmpwidth['fieldwidth'], 'total_width' => $total_width, 'noofrows' => $noofrows,
                'title' => getFixedLabel('RECORDSOFOPERATION'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'));
        } else {
            $return_value = array('header' => $header, 'entries' => $entity, 'navigation' => $navigationOutput,
                'headername' => $tmp['headername'], 'fieldwidth' => $tmpwidth['fieldwidth'], 'total_width' => $total_width,
                'title' => getFixedLabel('View History'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'), 'noofrows' => $noofrows,
                'Richtexthide' => $Richtexthide);

        }
        return $return_value;
    }

    public function getRelationId($logId){
        global $adb;
        $query = 'select * from ld_crmlog_relation where operation_log_id = ? and type = ?';
        $result = $adb->pquery($query, array($logId, 'detailTrackerLog'));
        return $result->fields['relation_id'];
    }

    /**
     * @return mixed
     */
    public function getLogId()
    {
        return $this->logId;
    }

    /**
     * @param mixed $logId
     */
    public function setLogId($logId): void
    {
        $this->logId = $logId;
    }

    /**
     * @return mixed
     */
    public function getIsEditDetail()
    {
        return $this->isEditDetail;
    }

    /**
     * @param mixed $isEditDetail
     */
    public function setIsEditDetail($isEditDetail): void
    {
        $this->isEditDetail = $isEditDetail;
    }

    public function getCurLogInfo(): array
    {
        return $this->curLogInfo;
    }

    public function setCurLogInfo(array $curLogInfo): void
    {
        $this->curLogInfo = $curLogInfo;
    }

    /**
     * 从对应history表中获取附件图片历史信息
     */
    public function getAttachmentImgHistory($record,$logtype='field'){
        // 一次性都查找出来
        if(empty($this->attachment_img_logs_arr)){
            crm_load_class_file('AttachmentUtils','modules/Attachment');
            $AttachmentUtilsObj = new AttachmentUtils();
            $this->attachment_img_logs_arr = $AttachmentUtilsObj->getAttachmentImgHistory($record,$logtype);
        }
    }
    /**
     * 获取附件图片修改日志的内容
     * value：附件id字符串
     * logtype：field（表头附件字段），detail（分录附件字段）
     */
    public function getAttachmentImgLogsHtml($record,$fieldinfo,$value,$logtype='field')
    {
        $value_html = '';
        if(empty($value)){
            return $value_html;
        }
        if(empty($this->attachment_img_logs_arr)){
            $this->getAttachmentImgHistory($record,$logtype);
        }
        $value_arr = explode(',',(string)$value);
        if(!empty($fieldinfo)){
            if($fieldinfo->getUIType() == '69' || $fieldinfo->getBigType() == 'image'){
                // pc端预览
                if($this->logs_from == 'pc'){
                    $value_html .= '<div name="" onclick="previewImage(this);">';
                }
                foreach ($value_arr as $tmpi => $attid) {
                    if(!empty($attid)){
                        $tmp_src = '';
                        $attachmentinfo = $this->attachment_img_logs_arr[$attid];
                        if($attachmentinfo['storage_location'] == 'cos'){
                            $tmp_src = $attachmentinfo['cloud_path'];
                        }else{
                            $tmp_src = $attachmentinfo['path'].$attachmentinfo['newfile_name'];
                        }
                        if($this->logs_from != 'pc'){
                            $tmp_src = curPageURL().'/'.$tmp_src;
                        }
                        $value_html .= '<img style="width: 50px;height: 50px;" src="'.$tmp_src.'" onclick="" alt="">';
                    }
                }
                if($this->logs_from == 'pc'){
                    $value_html .= '</div>';
                }
            }else{
                $value_html_arr = [];
                foreach ($value_arr as $tmpi => $attid) {
                    $attachmentinfo = $this->attachment_img_logs_arr[$attid];
                    $value_html_arr[] = $attachmentinfo['name'];
                }
                $value_html = implode(' , ',$value_html_arr); 
            }
        }
        return $value_html;
    }
    /**
     * 判断分录附件是否修改过
     */
    public function isDetailAttachmentChange($prevalue,$postvalue){
        if(empty($prevalue) && empty($postvalue)){
            return 'no';
        }else if((empty($prevalue) && !empty($postvalue)) || (!empty($prevalue) && empty($postvalue))){
            return 'yes';
        }else{
            $pre_attachmentid_arr = explode(',',$prevalue);
            $post_attachmentid_arr = explode(',',$postvalue);
            if(count($pre_attachmentid_arr) != count($post_attachmentid_arr)){
                return 'yes';
            }else{
                $prevalue_newfilename_arr = [];
                $postvalue_newfilename_arr = [];
                foreach ($pre_attachmentid_arr as $index => $attid) {
                    $prevalue_newfilename_arr[] = $this->attachment_img_logs_arr[$attid];
                }
                foreach ($post_attachmentid_arr as $index => $attid) {
                    $postvalue_newfilename_arr[] = $this->attachment_img_logs_arr[$attid];
                }
                // 前后文件数相同时，比较数组元素是否一致，即便文件内容不变但只要重写上传了文件newfile_name就会变，就需要记录日志
                ksort($prevalue_newfilename_arr);
                ksort($postvalue_newfilename_arr);
                if(!empty(array_diff($prevalue_newfilename_arr,$postvalue_newfilename_arr)) || !empty(array_diff($postvalue_newfilename_arr,$prevalue_newfilename_arr))){
                    return 'yes';
                }else{
                    // 前后不变
                    return 'no';
                }
            }
        }
    }
}

?>