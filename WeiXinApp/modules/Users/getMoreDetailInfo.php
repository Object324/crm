<?php
/**
 *  获取明细界面其他页签信息
 *  reason：明细界面加载的内容过多，将审批历史和修改日志的加载在点击后另外加载
 *  editor:xxs
 *  date:2017-11-30
 */
global $adb, $weixin_user,$current_user;

$module = $_REQUEST['frommodule'];
$record = $_REQUEST['record'];
$type = $_REQUEST['type'];

if (empty($module)) $module = getSalesEntityType($record);
//editor:gyq_123 reason:新增type=goutong,自助小程序中，日志替换为沟通信息  2019/6/17 16:45 ID1000512

if ($type == 'goutong'&&!empty($weixin_user) && $weixin_user->environment == 'weixin_self_help') {
    require_once globalStatic::$root_directory . 'weixinmp/detail/cls_DetailViewMP.php';
    $obj = new cls_DetailViewMP(null);
    $entity['list'] = $obj->get_communicate_detail($record, $module);
}elseif ($type == 'other') {

    //加载客户公海操作记录
    $publiclog = array();

    //开启公海参数&&公海用户
    if ($module == 'Accounts' && cls_StaticCommonFun::isPublicAccountUser()) {
        $sql = "select ld_users.wx_userid,ld_users.last_name,ld_logpublicaccount.username,operation,opdate,ld_logpublicaccount.userid from ld_logpublicaccount 
        left join ld_users on ld_users.id=ld_logpublicaccount.userid
        where accountid=? order by opdate desc";
        $result = $adb->pquery($sql, array($record));
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $relase_v = '';
            $loguserid=$adb->query_result($result, $i, "userid");
            $userobj=new Users();
            if(!empty($loguserid)){
                $userobj->last_name= $adb->query_result($result, $i, "last_name");
            }
            else{
                $userobj->last_name= $adb->query_result($result, $i, "username");
            }
            $userobj->wx_userid= $adb->query_result($result, $i, "wx_userid");
            $username_arr = array('k' => getFixedLabel('OPERATOR'), 'v' => getUserlastName($userobj));
            $operation = $adb->query_result($result, $i, "operation");
            if (stripos($operation, '$###$') !== false) {
                $strs = explode('$###$', $operation);
                $operation_v =htmlspecialchars_decode(sprintf(getFixedLabel($strs[0]), $strs[1]));
            } else if (stripos($adb->query_result($result, $i, "operation"), '$####$') !== false) {
                $strs = explode('$####$', $operation);
                $operation_v = htmlspecialchars_decode(getFixedLabel($strs[0]));
                $relase_v = $strs[1];
            } else {
                $operation_v = htmlspecialchars_decode(getFixedLabel($operation));
            }
            $operation_arr = array();
            $operation_arr['operation'] = array('k' => getFixedLabel('OPERATING'), 'v' => $operation_v);
            if (!empty($relase_v)) {
                $operation_arr['relasereason'] = array('k' => getFixedLabel('RELEASEACCOUNTTREASON'), 'v' => $relase_v);
            }
            $opdate = $adb->query_result($result, $i, 'opdate');
            $opdate_arr = array('k' => getFixedLabel('DATE'), 'v' => $opdate);
            $publiclog[] = array_merge(array('username' => $username_arr, 'opdate' => $opdate_arr), $operation_arr);
        }
        $entity['publiclog'] = $publiclog;
    }

    //加载审批历史
    $approvelog = array();

    //列头key对应翻译数组
    $approvefield = array('OPERATE' => 'OPERATING', 'STEPNAME' => 'APPROVALSTEP', 'OPERATOR' => 'operatoroer', 'APPROVERESULT' => 'APPROVALRESULT',
        'NEXTSTEPBYNAME' => 'NEXTOPERATOR', 'DESCRIPTION' => 'APPROVALSUGGESTION', 'CREATEDTIME' => 'operatoroertime','APPROVEAUTOGRAPHPATH' => 'handwriting');
    if ($module == 'ServiceCharge') $module = 'Accounts';
    crm_load_class_file("ApproveCommon","modules/Approve");
    $approvecommonobj = ApproveCommon::getInstance($module);
    $sql = "select approveid from ld_approvelog where crmid = ? order by id desc limit 1";
    $result = $adb->pquery($sql,array($record));
    if($adb->num_rows($result)>0){
        $approveid = $adb->query_result($result,0,'approveid');
        $approve = $approvecommonobj->getApproveobjByApproveid($approveid);
    }else{
        $approve = new Approve();
    }
    //判断当前模块是否开启审批，未开启的话就不显示审批历史
    $approvemod = $approve->getApproveModuleInfo();
	require_once(globalStatic::$root_directory.'Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
	$regop=RegOp::getInstance();
    // diony 2022-09-06 最新版不显示审批日志
    if (isset($approvemod[$module]) && 1==2) {
        $approvelog = $approve->approveLog($record);
        $j = sizeof($approvelog);
        for ($i = 0; $i < sizeof($approvelog); $i++) {
            $operatename = $approvelog[$i]['operatename'];
            unset($approvelog[$i]['curlogconcurrentid']);
            unset($approvelog[$i]['nextlogconcurrentid']);
            unset($approvelog[$i]['operatecol_rowspan']);
            unset($approvelog[$i]['seqno']);
            $stepinfo = $approvelog[$i]['stepinfo'];
            for ($k = 0; $k < sizeof($stepinfo); $k++) {
                $stepname = $stepinfo[$i]['STEPNAME'];
                if ($stepname == '' || $stepname == null) {
                    $stepinfo[$k]['STEPNAME'] = '';
                } else {
                    $stepinfo[$k]['STEPNAME'] = $stepinfo[$k]['STEPNAME'];
                }
                if (!empty($stepinfo[$k]['OPERATE'])) {
                    $stepinfo[$k]['OPERATOR'] .= '（' . $stepinfo[$k]['OPERATE'] . '）';
                }
                unset($stepinfo[$k]['OPERATE']);
                foreach ($stepinfo[$k] as $key => $val) {
                    if (!empty($val) && $key != 'BACKUP') {
                        if ($key == 'DESCRIPTION') {
                            $val=str_replace("\r\n","<br>",$val);
                            $val=str_replace("\n","<br>",$val);
                            $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val, 't' => $approvelog[$k]['BACKUP'] == 'YES' ? 'f' : 'z');
                        }else if($key == 'APPROVEAUTOGRAPHPATH'){
                            if($regop->gethandleWriteSign_interface() == 1){
                                $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val);
                            }
                        } else {
                            $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val);
                        }
                    }
                }
                unset($stepinfo[$k]['BACKUP']);
            }
            $approvelog[$i]['stepinfo'] = $stepinfo;
            $j--;
        }
        $ApprovelogSetInfo = $approve->getApprovelogSet($record);
        $WholeApproveLog = $approve->getWholeApproveLog($record,$ApprovelogSetInfo);
        
        $entity['approvelog'] = $approvelog;
        $entity['wholeapprovelog'] = $WholeApproveLog;
        $entity['approvelog1216'] = 'yes';// diony 20201216 用来判断是否是并发审批后的日志
    }

    //加载修改日志
    // 2021-07-19 diony
    // 0047006: （企业微信移动端-kfbcrm）附件管理-日志；显示有修改日志，移动端不应该显示修改日志
    if($module != 'Attachment'){
        $changelog = array();
        $fieldlogobj = crm_load_class_obj("SetRelatedInfo", 'modules/Users');
        $$relationInfo = array('label' => 'ViewHistory');
        $fieldlogobj->logs_from = 'mobile';

        //$richtexthide用来获取前端按钮改变状态
        $richtexthide = $_REQUEST['richtexthide'];
        //按钮状态改变后改变数据库状态值设置
        if(isset($richtexthide) && $richtexthide!='') {
            setUsersettingByLabel($module, $current_user->id, 'Richtexthide', $richtexthide);
        }
        $logdata = $fieldlogobj->getFieldUpdateLog($module, $record, getTabid($module), $$relationInfo);
        //editor:gyq_20190816 reason:key自然数组化 0037775: 企业微信明细界面-日志-修改日志不显示
        if (!empty($logdata['entries'])) {
            foreach ($logdata['header'] as $logfield => $logfieldname) {
                $i=0;
                foreach ($logdata['entries'] as $key => $val) {
                    if ($logfield == 'whodid') $logfield = 'username';
                    $changelog[$i][$logfield] = array('k' => $logfieldname, 'v' => $val[$logfield]);
                    $i++;
                }
            }
        }
        $entity['changelog'] = $changelog;
        $entity['richtexthide'] = $logdata['Richtexthide'];// 富文本框选择是否隐藏 zl XUQIU1000760 $Richtexthide返回更新后的按钮状态

        //diony 20240626 设置移动端单据详情界面相关模块是否横向显示
        $deploy_350 = getSys_deploy(350);
        if($deploy_350['deploy_value'] == '1'){
            $operationlog = array();
            $fieldlogobj = crm_load_class_obj("SetRelatedInfo", 'modules/Users');
            $$relationInfo = array('label' => 'OperationLogs');

            $fieldlogobj->logs_from = 'mobile';
            $logdata = $fieldlogobj->getFieldUpdateLog($module, $record, getTabid($module), $$relationInfo);
            if (!empty($logdata['entries'])) {
                foreach ($logdata['header'] as $logfield => $logfieldname) {
                    $i=0;
                    foreach ($logdata['entries'] as $key => $val) {
                        if ($logfield == 'isEditDetail' || $logfield == 'logid'){
                            $operationlog[$i][$logfield] = $val[$logfield];
                        }else{
                            $operationlog[$i][$logfield] = array('k' => $logfieldname, 'v' => $val[$logfield]);
                        }
                        $i++;
                    }
                }
            }
            $entity['operationlog'] = $operationlog;
        }
    }

    //加载评论
    $comentslog = array();
    if (vtlib_isModuleActive('ModComments')) {
        if (isPermitted('ModComments', 'DetailView', '') == 'yes') {
            $query = 'SELECT ld_modcomments.modcommentsid as crmid,
                    ld_modcomments.commentcontent,ld_modcomments.createdtime,ld_users.last_name,ld_users.real_name,ld_modcomments.remindusers 
                    FROM ld_modcomments 
                    LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id 
                    LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid 
                    WHERE ld_modcomments.deleted = 0 AND ld_modcomments.related_to=? 
                    ORDER BY ld_modcomments.modcommentsid DESC ';
            $result = $adb->pquery($query, array($record));
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                $crmid = $adb->query_result($result, $i, "crmid");
                $commentcontent = nl2br($adb->query_result($result, $i, "commentcontent"));
                $commentcontent_arr = array('k' => '评论内容', 'v' => $commentcontent);
                $createdtime = $adb->query_result($result, $i, "createdtime");
                $createdtime_arr = array('k' => '评论时间', 'v' => $createdtime);
                $last_name = $adb->query_result($result, $i, "last_name");
                $real_name = $adb->query_result($result, $i, "real_name");
                if(isKehu001ServerPc()=="yes"){
                    $last_name_arr = array('k' => '评论人', 'v' => $real_name);
                }else{
                    $last_name_arr = array('k' => '评论人', 'v' => $last_name);
                }
                $remindusers = $adb->query_result($result, $i, "remindusers");
                $remindsuser_array = explode(',',$remindusers);
                if(empty($remindusers)||sizeof($remindsuser_array)<=0){
                    $remindusersStr = '';
                }
                else{
                    $remindusersStr = sizeof($remindsuser_array).getFixedLabel('COLLEAGUES');
                }
                $remindusers_arr = array('i' => $remindusers, 'k' => '抄送范围', 'v' => $remindusersStr);

                $tmp_fileImg_arr = getModCommentsFileImgInfo($crmid);
                $fileImg_arr = empty($tmp_fileImg_arr)?'':$tmp_fileImg_arr;
                if(!is_array($fileImg_arr))
                {
                    $fileImg_arr=[];
                }

                $reply_query='SELECT ld_modcomments.modcommentsid AS crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,ld_attachments.storage_location,ld_attachments.cloud_path,ld_modcomments.createdtime,ld_users.last_name,ld_users.real_name
                        FROM ld_modcomments
                        LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id
                        left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                        left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
                        LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_modcomments.modcommentsid
                        WHERE ld_modcomments.deleted = 0 AND ld_modcomments.parent_comments = ? 
                        ORDER BY ld_modcomments.createdtime DESC ';
                $reply_result = $adb->pquery($reply_query, array($crmid));
                if($adb->num_rows($reply_result) > 0){
                    for ($j = 0; $j < $adb->num_rows($reply_result); $j++) {
                        $reply_crmid = $adb->query_result($reply_result, $j, "crmid");
                        $reply_commentcontent = nl2br($adb->query_result($reply_result, $j, "commentcontent"));
                        $reply_commentcontent_arr = array('k' => '回复内容', 'v' => $reply_commentcontent);
                        $reply_createdtime = $adb->query_result($reply_result, $j, "createdtime");
                        $reply_createdtime_arr = array('k' => '回复时间', 'v' => $reply_createdtime);
                        $reply_last_name = $adb->query_result($reply_result, $j, "last_name");
                        $reply_real_name = $adb->query_result($reply_result, $j, "real_name");
                        if(isKehu001ServerPc()=="yes"){
                            $reply_last_name_arr = array('k' => '回复人', 'v' => $reply_real_name);
                        }else{
                            $reply_last_name_arr = array('k' => '回复人', 'v' => $reply_last_name);
                        }
                        $reply_remindusers = $adb->query_result($reply_result, $j, "remindusers");
                        $reply_remindsuser_array = explode(',',$reply_remindusers);
                        if(empty($reply_remindusers)||sizeof($reply_remindsuser_array)<=0){
                            $reply_remindusersStr = '';
                        }
                        else{
                            $reply_remindusersStr = sizeof($reply_remindsuser_array).getFixedLabel('COLLEAGUES');
                        }
                        $reply_remindusers_arr = array('i' => $reply_remindusers, 'k' => '抄送范围', 'v' => $reply_remindusersStr);
                        $tmp_reply_fileImg_arr = getModCommentsFileImgInfo($reply_crmid);
                        $reply_fileImg_arr = empty($tmp_reply_fileImg_arr)?'':$tmp_reply_fileImg_arr;
                        if(!is_array($reply_fileImg_arr))
                        {
                            $reply_fileImg_arr=[];
                        }
                        $reply_list[] = array('id' => $reply_crmid, 'parentid' => $crmid, 'commentcontent' => $reply_commentcontent_arr, 'createdtime' => $reply_createdtime_arr,
                            'last_name' => $reply_last_name_arr, 'remindusers' => $reply_remindusers_arr,'image'=>$reply_fileImg_arr['image'],'filename'=>$reply_fileImg_arr['filename']);
                    }
                }
                else{
                    $reply_list = array();
                }

                $comentslog[] = array('id' => $crmid, 'commentcontent' => $commentcontent_arr, 'createdtime' => $createdtime_arr, 'last_name' => $last_name_arr,
                    'remindusers' => $remindusers_arr, 'replylist' => $reply_list,'image'=>$fileImg_arr['image'],'filename'=>$fileImg_arr['filename']);
            }
            $entity['commentslog'] = $comentslog;
        }
    }


    require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
    $modulelist = cls_StaticCommonFun::getOptionModule('Singin');
    $modulelist_new = array_values($modulelist);
    $module_arr = _array_column($modulelist_new, 'value');
    if (in_array($module, $module_arr)) {
        //签到记录
        $singinlog = array();
        $singin_query = 'SELECT
                            a.address,
                            a.createdtime,
                            a.distince,
                            b.last_name
                        FROM
                            ld_singin a
                        LEFT JOIN ld_users b ON a.userid = b.id
                        WHERE
                            a.record = ?
                        ORDER BY
                            a.id DESC; ';
        $singin_result = $adb->pquery($singin_query, array($record));
        for ($i = 0; $i < $adb->num_rows($singin_result); $i++) {
            $address = array('k' => '地址', 'v' => $adb->query_result($singin_result, $i, "address"));
            $distince = array('k' => '误差(米)', 'v' => $adb->query_result($singin_result, $i, "distince"));
            $createdtime = array('k' => '签到时间', 'v' => $adb->query_result($singin_result, $i, "createdtime"));
            $last_name = array('k' => '拜访人', 'v' => $adb->query_result($singin_result, $i, "last_name"));
            $singinlog[] = array('address' => $address, 'distince' => $distince, 'createdtime' => $createdtime, 'last_name' => $last_name);
        }
        $entity['singinlog'] = $singinlog;
    }
}elseif ($type == 'OperationLogs' || $type == 'ViewHistory') {// 操作日志
    if($module != 'Attachment'){
        $operationlog = array();
        $fieldlogobj = crm_load_class_obj("SetRelatedInfo", 'modules/Users');
        $relationInfo = array('label' => $type);
        $getEditDetail =  vtlib_purify($_REQUEST['isEditDetail']);
        $logid =  vtlib_purify($_REQUEST['logid']);
        $fieldlogobj->setLogId($logid);
        $fieldlogobj->setIsEditDetail($getEditDetail);
        $fieldlogobj->logs_from = 'mobile';
        $logdata = $fieldlogobj->getFieldUpdateLog($module, $record, getTabid($module), $relationInfo);
        if (!empty($logdata['entries'])) {
            foreach ($logdata['header'] as $logfield => $logfieldname) {
                $i=0;
                foreach ($logdata['entries'] as $key => $val) {
                    //wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
                    if ($logfield == 'isEditDetail' || $logfield == 'logid'){
                        $operationlog[$i][$logfield] = $val[$logfield];
                    }else{
                        $operationlog[$i][$logfield] = array('k' => $logfieldname, 'v' => $val[$logfield]);
                    }
                    $i++;
                }
            }
        }
        $entity['operationlog'] = $operationlog;
    }

} elseif ($type == 'relation') {
    //加载相关信息页签内容
    $RelatedList = array();
    $detailComFun = crm_load_class_obj('cls_DetailView_CommonFun', 'WeiXinApp/include');
    $focus = cls_Instance::get_module_Instance($module);
    $focus->id = $record;
    $RelatedList = $detailComFun->jsongetModuleRelatedList($module, $focus);
    $entity['relatedList'] = $RelatedList;
} elseif ($type == 'relatedCreationInfo') {
    //获取相关创建带出的值(relatedCreationInfo)
    $related_id = $_REQUEST['relatedid'];
    $related_module = $_REQUEST['relatedmodule'];
    crm_load_class_file("cls_ListViewWX", 'WeiXinApp/list');
    $listobj = new cls_ListViewWX($module);
    $relatedCreationInfo = $listobj->relatedModuleActions($related_id, $related_module, $record, $module);
    if (!empty($relatedCreationInfo)) {
        $entity['relatedinfo'] = $relatedCreationInfo;
    }
    //客户最晚服务到期日到期后是否允许创建客户服务单
    if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'HelpDesk') {
        $focus = CRMEntity::getInstance('HelpDesk');
        $res = $focus->getAccountsForLastservicedate($record, $_REQUEST['relatedmodule']);
        if ($res == 'error') {
            ConvertTojsonString(-1, array(), getFixedLabel('thecurstomerserviceordersarenotallowedtobe'));
        }
    }
} elseif ($type == 'sales_trends') {//动态
    if($_REQUEST['frommodule'] =='Accounts'||$_REQUEST['frommodule'] =='ServiceCharge'){
        crm_load_class_file('cls_sales_trends', 'modules/Accounts');
        $obj_trends = new cls_sales_trends($_REQUEST['record'], $_REQUEST['frommodule']);
        $result = $obj_trends->getList();
        $entity['sales_trends'] = $result;
    }else if($_REQUEST['frommodule'] =='WorkSheet'){
        crm_load_class_file('cls_worksheet_trends', 'modules/WorkSheet');
        $obj_trends = new cls_worksheet_trends($_REQUEST['record'], $_REQUEST['frommodule']);
        $result = $obj_trends->getList();
        $entity['sales_trends'] = $result;
    }  
} elseif ($type == 'callrecord') {// 通话记录
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $obj_callrecord = new cls_CallRecord($_REQUEST['frommodule'], $_REQUEST['record']);
    $result = $obj_callrecord->getList();
    $entity['callrecord'] = $result;
} elseif (in_array($module,array('Accounts','Contacts')) && $type == 'wechatsession') {//会话
    crm_load_class_file('cls_WechatSession', 'modules/WechatSession');
    $result = '';
    if (!empty($_REQUEST['record'])) {
        //$obj_wechatsession = new cls_WechatSession($_REQUEST['record'], $_REQUEST['frommodule']);
        //$result = $obj_wechatsession->getSessionList();
        global $wechatsession_page_size;
        $wechatsession_page_size=100000;
        include (globalStatic::$root_directory.'modules/Accounts/WeChatSession.php');
        $result = get_wechatsession($_REQUEST['frommodule'],$_REQUEST['record']);
    }

    $entity['wechatsession'] = $result['weChatDatas'];
} elseif (in_array($module,array('Accounts','Contacts')) && $type == 'wechatsession_detail') {//会话详情
    crm_load_class_file('cls_WechatSession', 'modules/WechatSession');
    $result = '';
    if (!empty($_REQUEST['record'])) {
        $obj_wechatsession_detail = new cls_WechatSession($_REQUEST['record'], $_REQUEST['frommodule']);
        $result = $obj_wechatsession_detail->getChatdataList();
    }

    $entity['wechatsession_detail'] = $result;
} elseif($type = 'shopcartCreationInfo' ){
    //edit:duan reason:通过购物车关联创建订单
    global $adb;
    $selectcartid = $_REQUEST['selectcartid'];
    $related_id = $_REQUEST['relatedid'];
    $related_module = $_REQUEST['relatedmodule'];
    if(!empty($selectcartid)){
        $sql = 'select productid from ld_shopcartdetails where cartid in ('.$selectcartid.')';
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $productid_arr = array();
            for($i=0;$i<$num_rows;$i++){
                $productid_arr[] = $adb->query_result($result,$i,'productid');
            }
        }
        $cartid_arr = explode(',',$selectcartid);
    }
    require_once (globalStatic::$root_directory.'include/utils/DetailViewUtils.php');
    $relationInfo = getRelatedListInfoById($related_id,$related_module);
    if(stripos($relationInfo['actions'],'add')!==false){
        $RelatedList['fromid'] = $productid_arr[0];
        $RelatedList['frommodule'] = $related_module;
        $RelatedList['type'] = $type;
        $RelatedList['cartids'] = $cartid_arr;
    }
    $entity['relatedinfo'] = json_encode($RelatedList);
}


ConvertTojsonString(1, $entity, 'success');
?>