<?php
global $adb, $current_user, $weixin_user;


/*
 * editor:gyq_05
 * reason:提交审批弹框下拉选单事件,返回下一审批步骤信息
 * date  ：2016 3 1
 * */

$approve = new Approve();

//提交审批
if (isset($_REQUEST['record']) && $_REQUEST['record'] != '')
    $record = $_REQUEST['record'];
    
//haige报价单，审批判断报价单使用状态，若为“不可用”状态，则不允许提交审批
$VersionInfo = getVersionInfo();

if($VersionInfo['account'] == 'haige' && $_REQUEST['fld_module'] == 'Quotes'&&isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    $haigeavailable_status = 'yes';
    //获取使用状态yes:可用；no：不可用；
    crm_load_function_file('haige_getAvailableStatusByquoteid','modules/Quotes','Haigequotefunction');
    $haigeavailable_status = haige_getAvailableStatusByquoteid($_REQUEST['record']);
    if($haigeavailable_status == 'no')
    {    
        $retnousestatus = '该报价单已“失效”不允许提交';
        ConvertTojsonString("-1",array(),$retnousestatus);
    }
    else if($haigeavailable_status == 'nouse'){
        $retnousestatus = '有送货地址确认单未审批';
        ConvertTojsonString("-1",array(),$retnousestatus);
    }
}

/**
 * 下载提交审批日志文件
 * @project PROT144 审批功能改进
 * @author  Tujt 2014-12-26
 */
if (isset($_REQUEST['downfile'])) {//下载提交日志
    $filename = $_REQUEST['downfile'];    //要下载的文件名
    header("Content-Type: application/force-download");
    header("Content-Disposition: attachment; filename=ApproveSubmitLog.txt");
    @readfile(globalStatic::$root_directory.$filename);
    die;
}

if (isset($_REQUEST['fld_module']) && $_REQUEST['fld_module'] != '') {
    $fld_module = $_REQUEST['fld_module'];
    //19646: 服务收费管理>列表：勾选单据，提交审批，弹出提示信息。点击提示信息的链接字段，结果：页面跳转到的是客户模块。
    $old_module = $fld_module;
    if ($fld_module == 'ServiceCharge')
        $fld_module = 'Accounts';

    $returnmodule = $_REQUEST['returnmodule'];


    $blockid = getTabid($fld_module);

}

global $adb;
$smarty = new lingdangCRM_Smarty;
if ($_REQUEST['getnextstepinfo'] > 0) {
    //需要审批的单据id,可以是多个
    if (!empty($_REQUEST['approve_recordid'])) {
        $record = $_REQUEST['approve_recordid'];
    }

    //0025876: 报价单列表：勾选单据，点击【全选n条记录】在批量提交审批，选择审批流程：本部门，列表上不显示审批人
    if ($record != 'all') {
        $selectarr = explode(';', $record);
        $record = $selectarr[0];
    } else {
        $query = getListAllQuery($old_module, 1);//获取query，不需要任何附加条件
        $result = $adb->pquery($query['query'], array());
        $record = $adb->query_result($result, 0, 0);
    }


    $approveid = $_REQUEST['getnextstepinfo'];
    //edit:can 20210824 47616: （81mis.com/kfbcrm）合同订单-单据SO260，管理员操作反审批，使用新的审批流程流转时，选择加急审批流没有显示对应‘加急’选项
    $sql='select * from ld_approve where id=?';
    $result=$adb->pquery($sql,array($approveid));
    $approveinfo=[];
    $approveinfo['showurgent']=$adb->query_result($result,0,'showurgent');//[0]['showurgent'];
    //bug:0048892,反审批时新流程提交时不显示审批意见，则不限制必填
    $showsubmitremark = $adb->query_result($result,0,'showsubmitremark');
    $submitremarkrequire = $adb->query_result($result,0,'submitremarkrequire');
    $isnewapprove = $adb->query_result($result,0,'isnewapprove');
    $tabid = $adb->query_result($result,0,'tabid');
    $approveobj = Approve::getInstance(getTabname($tabid),$isnewapprove);
    
    if($showsubmitremark=='yes'&&$submitremarkrequire =='yes'){
        $markrequire = 'yes';
    }else{
        $markrequire = 'no';
    }
    $approveinfo['markrequire'] = $markrequire;
    
    $nextStepInfo = $approveobj->getApproveStepInfo($approveid, $record);
    $_REQUEST['diony'] = 'yes';
    $tmp = array();
    
    //审批日志显示
    //$WholeApproveLog = $approveobj->getSubmitApprovelog($approveid,$record);
    //if(!empty($WholeApproveLog)){
//        $smarty->assign("noapprovesetting",'yes');
//    	$smarty->assign('WholeApproveLog',$WholeApproveLog);
//        $smarty->assign('RECORD',$record);
//        $smarty->assign('MODULENAME',$fld_module);
//        $smarty->assign("pre_hidden_btn",'yes');
//        $smarty->assign("next_hidden_btn",'yes');
//    }
    $tmp['submitapprovelog']=$smarty->fetch("Approve/ApproveLogEntriesNew.tpl");
    $tmp['approveinfo']=$approveinfo;
    
    $tmp['steplist'] = $nextStepInfo;
    $tmp['isnewapprove'] = $isnewapprove;
    $tmp['labels'] = array('stepname' => getFixedLabel('NEXTAPPROVESTEP'), 'Countersigner' => getFixedLabel('Countersigner'), 'APPROVER' => getFixedLabel('APPROVER'));
    //echo json_encode($nextStepInfo);
    ConvertTojsonString(1, $tmp, 'success');
    exit;
}
//@edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（合同订单和自定义11-45模块提交审批时）
if (isset($_REQUEST['pushtype']) && $_REQUEST['pushtype'] == 'dingtalk') {
    require_once(globalStatic::$root_directory . 'modules/Approve/ApproveRemind.php');
    $appremindObj = new ApproveRemind();
    $result = $appremindObj->sendMessageByDingDing();
    $_REQUEST['diony'] = 'diony';
    if ($result) {
        ConvertTojsonString(1, array('res' => $result), '');
    } else {
        ConvertTojsonString(-1, array(), '');
    }
}


if (isset($_REQUEST['save']) && $_REQUEST['save'] != '') {

    $save = $_REQUEST['save'];

}

//更改状态
if (isset($_REQUEST['idstring']) && $_REQUEST['idstring'] != '')
    $record = $_REQUEST['idstring'];

//$approve=new Approve();

global $selectapprovecrmid_len;
$selectapprovecrmid_len = 1;//选择的单据数量，主要用于判断是否为批量提交（批量提交可能只选择一个单据

crm_load_class_file("ApproveCommon","modules/Approve");
$approvecommonobj = ApproveCommon::getInstance($fld_module);

if ($save == 'false') {
    //提交审批弹出
    //editor:gyq_132 reason:审批流程默认值改进  2019/7/23 11:42 ID1000479
    crm_load_class_file('weixin_user', 'WeiXinApp/modules/Users');
    $weixin_user = new weixin_user();
    $weixin_user->action = 'default_on_submit';
    $weixin_user->environment='pc';

    //获取所有审批流程信息

    $orgin_approveinfo = $approvecommonobj->submitApprove($blockid);
    
    if (empty($orgin_approveinfo)) {
        $_REQUEST['diony'] = 'diony';
        ConvertTojsonString(-1, array(), "NO");
    } else {
        /*
         * editor:gyq_05
         * reason:初始化审批步骤值
         * date  : 2016 3 1
         * */
        $selectid = $_REQUEST['selectid'];
        if (!empty($selectid)) {
            if ($selectid != 'all') {
                $selectarr = explode(',', trim($selectid, ','));
                $record = $selectarr[0];
            } else {
                $query = getListAllQuery($old_module, 1);//获取query，不需要任何附加条件

                $result = $adb->pquery($query['query'], array());
                $record = $adb->query_result($result, 0, 0);
            }
        }
        
        //根据审批流程适用范围和选中单据来控制审批流程的显示
        foreach($orgin_approveinfo as $tmp_key => $tmp_info){
            $tmp_approveid = $tmp_info['approveid'];
            
            if(empty($selectid)){
                $record_str = $record;
            }else{
                $record_str = $selectid;
            }

            if($approvecommonobj->getApplicationByCondition($tmp_approveid,$record_str)=='no'){
                //如果默认选中的流程被去掉，则重设默认流程
                if($tmp_info['selected'] == 'selected'){
                    $reset_defaultapprove = 'yes';
                }
            }else{
                $approveinfo[] = $tmp_info;
            }
        }

        if(empty($approveinfo)){
            $_REQUEST['diony'] = 'diony';
            ConvertTojsonString(-1, array(), "nopermit");
        }else if($reset_defaultapprove == 'yes'){
            $approveinfo[0]['selected'] = 'selected';
        }
        $approveid = $approveinfo[0]['approveid'];
        //根据审批流程id获取审批对象

        $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
        $nextStepInfo_arr = $approveobj->getApproveStepInfo($approveid, $record);

        $nextStepInfo = $nextStepInfo_arr;
        
        if ((!empty($selectid) && is_array($selectarr) && sizeof($selectarr) > 1) || $_REQUEST['selectlen']>1) {
            foreach ($nextStepInfo as $tmpindex => $tmpinfo) {
                $nextStepInfo[$tmpindex]['specifyapproverid'] = 1;
            }
        }
        //审批日志显示
        //$WholeApproveLog = $approveobj->getSubmitApprovelog($approveid,$record);
//        $smarty->assign("noapprovesetting",'yes');
//        if(!empty($WholeApproveLog)){
//        	$smarty->assign('WholeApproveLog',$WholeApproveLog);
//            $smarty->assign('RECORD',$record);
//            $smarty->assign('MODULENAME',$fld_module);
//            $smarty->assign("pre_hidden_btn",'yes');
//            $smarty->assign("next_hidden_btn",'yes');
//        }

        // dump($nextStepInfo);
        $smarty->assign('APPROVEFIRSTSTEP', $nextStepInfo);
        $smarty->assign('APPROVE', $approveinfo);
        $smarty->assign('RECORD', $record);
        $smarty->assign('BLOCK', $old_module);
        $smarty->assign("ApproveModule",$old_module);
        
        $smarty->assign('RETURNMODULE', $returnmodule);
        $smarty->assign('APPROVETYPE', $_REQUEST['approvetype']);
        $smarty->assign('SELECTLEN', $_REQUEST['selectlen']);

        $_REQUEST['diony'] = 'diony';
        $arr['title'] = getFixedLabel("APPROVAL") . ':' . getFixedLabel("SELECTAPPROVALPROC");
        $arr['oktext'] = getFixedLabel("CONFIRMED");
        $arr['canceltext'] = getFixedLabel("CANCEL");

        $str = $smarty->fetch("Approve/SubmitApproveNew.tpl");
        $arr['content'] = $str;
        ConvertTojsonString(1, $arr, "success");
    }
} else {
    //zkt 20230411 BUG0064054 提交审批时填写审批意见，审批日志中不显示填写的审批意见 
    if(isset($_REQUEST['submit_description'])){
        $_REQUEST['description'] = $_REQUEST['submit_description'];
    }
    //提交审批保存
    $approveid = $_REQUEST['approvevalue'];
    $isnewapprove = $_REQUEST['isnewapprove'];
    //组装sql，查询选中的id中，审批中、已批准的单据结果集
    $notapprove = array(constant('D_A_S_REJECTED') => 1,
                        constant('D_A_S_APPROVALOF') => 1,
                        constant('D_A_S_APPROVED') => 1);
    $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
    
    if (!isset($_REQUEST['batchsubmit'])) {
        if (!isset($_REQUEST['updatestate'])) {//提交审批
            $focus = CRMEntity::getInstance($fld_module);

            $sql = 'select approvestatus,deleted from ' . $focus->table_name . ' where ' . $focus->table_index . '=?';

            $result = $adb->pquery($sql, array($record));

            $approvestatus = $adb->query_result($result, 0, 'approvestatus');
            $deleted = $adb->query_result($result, 0, 'deleted');
            $issubmit = 'yes';
//            if (array_key_exists($approvestatus, $notapprove))
//                $issubmit = 'no';
            //ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）(单据详情提交审批)
            if ($approvestatus == constant('D_A_S_APPROVALOF') || (in_array($approvestatus,array(constant('D_A_S_APPROVED'),constant('D_A_S_REJECTED'))) && !$approveobj->recordAgainSubmit($fld_module))) {
                $issubmit = 'no';
            }
            $lastapproveinfo = $approveobj->getlastapproveinfo($record, $fld_module);

            if ($lastapproveinfo['stepid'] == -1 && $lastapproveinfo['approveresult'] == 1) {
                //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
                $issubmit = 'no';
            }
             if ($lastapproveinfo['approveresult'] == 2 ||constant('D_A_S_APPROVED')==$approvestatus) {
                //修改审批步骤，导致只提交审批的单据全部审批跳过后，没有办法重新提交审批了
                
               if( !$approveobj->recordAgainSubmit($fld_module))
                //已经审批成功
                $issubmit = 'no';
                else
                    $issubmit='yes';
                    
            }
             //duan 20240730 存在并发操作的问题,控制已删除单据不能提交审批
             if($deleted == 1){
                 $issubmit = 'no';
             }

            //查看界面提交保存
            
            if ($issubmit == 'yes') {
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($fld_module,$record,0);
                $PageValidataSaveobj->setApplication('submit');
                $PageValidataSaveobj->resetobj($fld_module,$record);
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    ConvertTojsonString(-3, [], $PageValidataSaveobj->errortip);
                }
                //$concurrentidStepCount=$_REQUEST['concurrentidStepCount'];
                //20230424 duan BUG0065462:保存并提交审批时增加条件是否满足判断
                if($approvecommonobj->getApplicationByCondition($approveid,$record)=='no'){
                    ConvertTojsonString(-3, [], getFixedLabel('NOTMEETCONDITIONSPLEASERESUBMIT'));
                }
                $stepinfo = $approveobj->ApproveSubmit($fld_module, $record, $approveid);
                //$_REQUEST['concurrentidStepCount']=$concurrentidStepCount;

                if ($stepinfo['nextstepid'] <= 0) {
                    //给出没有满足审批步骤的提示
                    $_REQUEST['diony'] = 'diony';
                    ConvertTojsonString(-1, array(), getFixedLabel("CURRENTAPPROVALPROCESSSELECTAPPROVAL"));
                }
            }

            if ($returnmodule == '')
                $returnmodule = $fld_module;
            $_REQUEST['diony'] = 'diony';
            $arr['refreshdetailmodules'] = array($returnmodule);

            //liushuai  20230803 XUQIU1001688 工作流程定制->调用 API 功能优化(提交审批弹窗)
            if (isset($stepinfo['workflow'])) {
                //检查是否有API调用
                crm_load_class_file("cls_savereverse", 'include/SaveReverse');
                $workflowreverseobj = cls_savereverse::getInstance($fld_module);
                $receive_msg = $workflowreverseobj->checkCallApiPop();
                $arr['workflow']['receive_msg'] = $receive_msg;
                if ($receive_msg == 'yes') {
                    $arr['workflow']['record'] = $record;
                    $arr['workflow']['module'] = $fld_module;
                    $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

                    $arr['workflow']['before_save_infos'] = $stepinfo['workflow']['before_save_infos'];
                    $arr['workflow']['after_save_infos'] = $stepinfo['workflow']['after_save_infos'];
                }
            }

            ConvertTojsonString(1, $arr, "success");
            //	header("location:index.php?module=$returnmodule&action=DetailView&record=$record");
        } else {//更改状态（无论单据什么类型，都可以重新提交审批）
            //获取批量处理数
            $deployarray = getSys_deploy(67);
            $btach_num = $deployarray['deploy_value'];
            /**
             * 更改单据审批状态
             * @project PROT195 审批管理改进
             * @author  Tujt 2015-04-09
             */
            $selectid = $_REQUEST['select_id'];//选中的ID
            $focus = CRMEntity::getInstance($fld_module);
            $tabname = $focus->table_name;
            $tabindex = $focus->table_index;
           
            if ('all' == $selectid) {//全选
                $sql = getListAllQuery($old_module, 1);//获取query，不需要任何附加条件
                $countquery = $sql['count'];
                $query = $sql['query'];
                if ($btach_num > 0) {
                    $query .= ' LIMIT ' . $btach_num . ' ';
                    $countquery .= ' LIMIT ' . $btach_num . ' ';
                }
                $countresult = $adb->query($countquery);
                $noofrows = $adb->query_result($countresult, 0, "count");
                $selectapprovecrmid_len = $noofrows;
              
                $selectlen = $_REQUEST['selectlen'];//提交的单据数量
               
            } else {//非全选
                $selectarr = explode(';', $selectid);

                $selectapprovecrmid_len = sizeof($selectarr);

                $concurrentidStepCount = $_REQUEST['concurrentidStepCount'];
                foreach ($selectarr as $key => $crmid) {
                    if ($key >= $btach_num) {
                        break;
                    }
                    if (empty($crmid)) continue;
                    $approveobj->ApproveSubmit($fld_module, $crmid, $approveid);//执行提交审批操作
                    $_REQUEST['concurrentidStepCount'] = $concurrentidStepCount;
                }
            }
            //获取销售机会模块的当前页数
            if (isset($_SESSION['lvs'][$fld_module]['viewname'])) {
                $viewid = $_SESSION['lvs'][$fld_module]['viewname'];
                $start = $_SESSION['lvs'][$fld_module][$viewid]['start'];
            }
            if (!$start) $start = 1;
            $entity['start']['value'] = $start;

            $json = new Zend_Json();
            $jsonentity = $json->encode($entity);
            echo $jsonentity;
            die;
        }
    } else {//批量提交审批
        /**
         * 批量提交审批
         * @project PROT144 审批功能改进
         * @author  Tujt 2014-12-26
         */
        $deployarray = getSys_deploy(67);
        $btach_num = $deployarray['deploy_value'];
        $selectid = $_REQUEST['selectid'];
        $selectlen = $_REQUEST['selectlen'];//提交的单据数量

        $correct = 0;
        $startrow = $_REQUEST['startrow'];
        $endrow = $_REQUEST['endrow'];
        if (!isset($_REQUEST['endrow'])) {
            $endrow = 99999999;
        }
        if ($startrow == 0 || !isset($_REQUEST['startrow'])) {
            $startrow = 0;
            unset($_SESSION['submitApprove']);//批量提交
        }


        $entityarray = getEntitynameInfo(getTabid($fld_module));
        $focus = CRMEntity::getInstance($fld_module);
        $enity_tabname = $entityarray['tablename'];
        $tabname = $focus->table_name;
        $tabindex = $focus->table_index;
        $tabnamecf = $focus->customFieldTable;
        $tabfieldname = $entityarray['fieldname'];
        if (empty($tabname)) $tabname = 'ld_' . strtolower($fld_module);
        if (empty($tabindex)) $tabname = strtolower($fld_module) . 'id';
        $submitlog = '';
        $module = $fld_module;
        if($_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['crmid'])
        {
            $selectarr = $_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['crmid']; //待处理的单据id集合
        }
        else
            {
            if ('all' == $selectid) {//全选模式
                /*$filter = array(//未提交、已驳回
                    'where'=>'    and ('.$tabname.'.approvestatus in
                            ("'.constant('D_A_S_UNAPPROVED').'","'.constant('D_A_S_DISMISSED').'")
                                    or '.$tabname.'.approvestatus = "") ',
                );*/
                //42336: （https://61mis.com/kfbtest [^]）多人审批流程，单据列表界面，批量提交时，若审批人有多个不同的审批人时，则不允许修改审批人；若审批人都是同一个审批人时，则允许修改审批人
                $_REQUEST['stepapproveuserid'] = '';

                //如果不为空，则判断当前有基本查询或高级查询条件
                if (is_array($_SESSION['LiveViewSearch'][$fld_module]['input']) && sizeof($_SESSION['LiveViewSearch'][$fld_module]['input'])) {
                    $searchinput = $_SESSION['LiveViewSearch'][$fld_module]['input'];

                    if ($searchinput['searchtype'] == 'BasicSearch') {
                        if (!empty($searchinput['search_text'])) {
                            $_REQUEST['search_field'] = $searchinput['search_field'];
                            $_REQUEST['search_text'] = $searchinput['search_text'];
                            $_REQUEST['SearchScope'] = $searchinput['SearchScope'];
                            $_REQUEST['searchtype'] = $searchinput['searchtype'];
                            $_REQUEST['type'] = $searchinput['type'];
                            $input['search_field'] = $searchinput['search_field'];
                            $input['search_text'] = $searchinput['search_text'];
                            $input['SearchScope'] = $searchinput['SearchScope'];
                            $input['searchtype'] = $searchinput['searchtype'];
                            $input['type'] = $searchinput['type'];
                            $input['query'] = 'true';
                        }
                    } else if ($searchinput['searchtype'] == 'advance'||$searchinput['searchtype'] == 'tiled') {
                        if (!empty($searchinput['advft_criteria']) && $searchinput['advft_criteria'] != '[]') {
                            $_REQUEST['advft_criteria'] = $searchinput['advft_criteria'];
                            $_REQUEST['advft_criteria_groups'] = $searchinput['advft_criteria_groups'];
                            $_REQUEST['SearchScope'] = $searchinput['SearchScope'];
                            $_REQUEST['searchtype'] = $searchinput['searchtype'];
                            $input['query'] = 'true';
                            $input['advft_criteria'] = $searchinput['advft_criteria'];
                            $input['advft_criteria_groups'] = $searchinput['advft_criteria_groups'];
                            $input['SearchScope'] = $searchinput['SearchScope'];
                            $input['searchtype'] = $searchinput['searchtype'];
                        }

                    }
                }
                //19837: 客户>列表界面：复选框勾选单据，”全选所有966条记录“点击批量提交按钮，弹出框信息点击确定，任意选择一个审批流程，点击保存按钮，界面没有反应
//                if (empty($startrow)) {
//                 unset($_SESSION['submitApprove']);
                    $where = getSelectQuery($input, $old_module, "where");//放到最上面，查询后全选批量提交有bug,如果移动位置
                    $from = getSelectQuery($input, $old_module, "from");

                    $orderby = getSelectQuery($input, $old_module, "orderby");
                    $sql = 'select distinct ' . $tabname . '.' . $tabindex . ' as crmid ' . $from . '  ' . $where;
                    $sql .= $filter['where'];


                    $countquery = $sql;
                    $query = $sql . " ORDER BY " . $orderby;

                    $countresult = $adb->query($countquery);
                    $noofrows = $adb->num_rows($countresult);//总行数
                    $selectapprovecrmid_len = $noofrows;
                    $dataresult = $adb->query($query);
                    $AllId_arr = [];       //所有单据id的集合
//                    if ($noofrows > $btach_num) {
//                        $noofrows = $btach_num;
//                    }

                    for ($i = 0; $i < $noofrows; $i++) {
                        $AllId_arr[] = $adb->query_result($dataresult, $i, 'crmid');

                    }
//                    $_SESSION['submitApprove']['allid' . $current_user->id] = $AllId_arr;
//                }

                $selectarr = $AllId_arr;

                /*$totalLen = sizeof($_SESSION['submitApprove']['allid' . $current_user->id]);
                if (($endrow) >= $totalLen) {
                    $id_arr = array_slice($_SESSION['submitApprove']['allid' . $current_user->id], $startrow, $totalLen - $startrow);

                } else
                    $id_arr = array_slice($_SESSION['submitApprove']['allid' . $current_user->id], $startrow, $endrow - $startrow);
                $selectid = implode(',', $id_arr);
                $selectarr = $id_arr;
                $selectlen = $totalLen;*/


                //ID 奇数列
            } else {//非全选
            $selectid = trim($selectid, ',');
            $selectarr = explode(',', $selectid);

            }

            $_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['allcrmid']=$selectarr;
            if(sizeof($selectarr)>$btach_num)
            {
                $selectarr=array_slice($selectarr,0,$btach_num);  //所有待处理的单据集合
            }

            $_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['crmid']=$selectarr;

        }

        $selectlen = sizeof($_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['allcrmid']);
        $selectarr = array_slice($selectarr, $startrow, $endrow - $startrow);
        $selectid = implode(',', $selectarr);


        if(!empty($selectid))
        {
             
             $failurearr = array();//不能提交审批的单据

            $approvestatusarr = array(
                '1' => constant('D_A_S_APPROVALOF'),//'审批中',
                '2' => constant('D_A_S_APPROVED'),//'已批准',
                '3' => constant('D_A_S_REJECTED'),//'已拒绝',
                '4' => constant('D_A_S_DISMISSED'),//'已驳回'
                '5' => constant('D_A_S_APPROVALOF'),//'审批中',
            );
            $query = 'SELECT distinct ' . $tabname . '.' . $tabindex . ' as crmid,
						' . $tabname . '.approvestatus,' . $enity_tabname . '.' . $tabfieldname . ' as subject 
							from ' . $tabname . ' left join ' . $tabnamecf[0] . ' on ' . $tabnamecf[0] . '.' . $tabnamecf[1] . ' = ' . $tabname . '.' . $tabindex . ' 
						where ' . $tabname . '.deleted = 0 and ' . $tabname . '.' . $tabindex . ' in (' . $selectid . ') order by field(' . $tabname . '.' . $tabindex . ',' . $selectid . ')';
            //0024365: 日程管理：列表界面批量提交时提示信息错误 order by field根据in内顺序排序 edit:xxs date:16-09-19
            if ($btach_num > 0) $query .= 'limit ' . $btach_num . ' ';
            //and ('.$tabname.'.approvestatus = "'.constant('D_A_S_REJECTED').'" or '.$tabname.'.approvestatus = "'.constant('D_A_S_APPROVALOF').'" or '.$tabname.'.approvestatus = "'.constant('D_A_S_APPROVED').'")
            $result = $adb->pquery($query, array());
            $rows = $adb->num_rows($result);
            $successlog_arr = array();
            $failurelog = array();
            $selectinfo = array();
            $selectarr = array();
            //获取符合审批流程的所有单据
            $permit_record_arr = $approvecommonobj->getApplicationByCondition($approveid,'','yes');
            //duan 20230112 批量提交审批时判断验证规则
            crm_load_class_file('cls_PageValidataSave','data');
            $PageValidataSaveobj=new cls_PageValidataSave($fld_module,0,0);
            $PageValidataSaveobj->setApplication('submit');
            $PageValidataSaveobj->batchoprate = 'yes';
            
            if ($rows > 0) {
                for ($i = 0; $i < $rows; ++$i) {
                    $crmid = $adb->query_result($result, $i, 'crmid');
                    $approvestatus = $adb->query_result($result, $i, 'approvestatus');
                    if ($approvestatus == constant('D_A_S_UNAPPROVED')) {
                        $approveinfo = $approveobj->approveStatus($crmid);
                        if (!empty($approveinfo) && $approveinfo['approvestatus'] >= 1) {
                            $approvestatus = $approvestatusarr[$approveinfo['approvestatus']];
                        }
                    }
                    $subject = $adb->query_result($result, $i, 'subject');

                    //ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）
                    //不允许提交的单据条件：审批中或者 已批准/已拒绝单据且不允许再次提交
                    if ($approvestatus == constant('D_A_S_APPROVALOF') || (in_array($approvestatus,array(constant('D_A_S_APPROVED'),constant('D_A_S_REJECTED'))) && !$approveobj->recordAgainSubmit($fld_module))) {
                        $failurelog[$crmid]['status'] = $approvestatus;
                        $failurelog[$crmid]['subject'] = $subject;
                        $failurearr[] = $crmid;//不能提交审批的单据ID
                    }else if(is_array($permit_record_arr)&&sizeof($permit_record_arr)>0&&!in_array($crmid,$permit_record_arr)){
                        $failurelog[$crmid]['status'] = 'noapplication';
                        $failurelog[$crmid]['subject'] = $subject;
                        $failurearr[] = $crmid;
                    } else {
                        //先判断不允许保存的验证规则
                        $PageValidataSaveobj->resetobj($fld_module,$crmid);//重置验证规则对象
                        $PageValidataSaveobj->setAllowSave('no');
                        $PageValidataSaveobj->getValidDataInfoPhp();
                        if(!empty($PageValidataSaveobj->errortip)){
                            $failurelog[$crmid]['status'] = 'validata';
                            $failurelog[$crmid]['errortip'] = $PageValidataSaveobj->errortip;
                            $failurelog[$crmid]['subject'] = $subject;
                            $failurearr[] = $crmid;
                        }else{
                            //判断允许保存的验证规则
                            $PageValidataSaveobj->setAllowSave('yes');
                            $PageValidataSaveobj->resetinfo = 'yes';
                            $PageValidataSaveobj->getValidDataInfoPhp();
                            if(!empty($PageValidataSaveobj->errortip)){
                                $successlog_arr[$crmid] = $PageValidataSaveobj->errortip;
                                $selectinfo[$crmid] = $subject;
                                $selectarr[] = $crmid;
                            }else{
                                $selectinfo[$crmid] = $subject;
                                $selectarr[] = $crmid;
                            }
                        }
                    }
                }
            }
            //批量提交选择9条  最后一条审批人等于第一条
 
            $selectapprovecrmid_len = sizeof( $_SESSION['submitApprove'][$current_user->id.'_'.$module.'batchsubmit']['crmid']);
            if (!empty($failurearr))//用array_diff获取两个数组的差集
                $selectarr = array_diff($selectarr, $failurearr);
            $successlog = '';//提交成功记录日志
            //if($selectlen > $btach_num) $selectlen = $btach_num;

            if (!empty($selectarr)) {
                $selectarrlen = count($selectarr);//执行提交审批的单据数量
//				$submitlog = sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),$selectlen,
//								$selectarrlen,($selectlen-$selectarrlen));
                $color = '#32A636';//提交审批成功的单据，颜色设为绿色
                if (sizeof($selectarr) > 1)//42336: （https://61mis.com/kfbtest [^]）多人审批流程，单据列表界面，批量提交时，若审批人有多个不同的审批人时，则不允许修改审批人；若审批人都是同一个审批人时，则允许修改审批人
                    $_REQUEST['stepapproveuserid'] = '';

                $concurrentidStepCount = $_REQUEST['concurrentidStepCount'];

                foreach ($selectarr as $key => $crmid) {
                    if ($key >= $btach_num) {

                        break;
                    }
                    //批量审批，判断报价单使用状态，若报价单使用状态为不可用，则该报价单不可提交审批
                    if($VersionInfo['account'] == 'haige' && $_REQUEST['fld_module'] == 'Quotes')
                    {
                        $haigeavailable_status = 'no';
                        //获取使用状态yes:可用；no：不可用；
                        crm_load_function_file('haige_getAvailableStatusByquoteid','modules/Quotes','Haigequotefunction');
                        $haigeavailable_status = haige_getAvailableStatusByquoteid($crmid);
                        if($haigeavailable_status == 'no')
                        {    
                            $failurelog[$crmid]['status'] = 'haigequotenosub';
                            $failurelog[$crmid]['subject'] = $selectinfo[$crmid];
                            $failurearr[] = $crmid;//使用状态为不可用的单据不能提交审批
                            continue ;
                        }
                    }
                    $before_requset = $_REQUEST;
                    $stepinfo = $approveobj->ApproveSubmit($fld_module, $crmid, $approveid);//执行提交审批操作

                    $_REQUEST = $before_requset;
                    $_REQUEST['concurrentidStepCount'] = $concurrentidStepCount;
                    
                    if ($stepinfo['nextstepid'] <= 0) {
                        //没有满足的审批步骤
                        $correct--;  //没有审批人应该算提交失败，不应+1；
                        $batchlog = getFixedLabel("APPROVE_BATCHSUBMITLOG_NOTSUBMIT");
                    } else if (array_key_exists('approveby', $stepinfo) && $stepinfo['approveby'] <= 0) {
                        //edit:can 2021-03-17045040: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），服务合同勾选（服务合同编号：SERCON196和SERCON196）单据使用审批流程“服务合同选人审批流程”批量提交时，审批结果提示错误（需要补丁）
                        $batchlog = getFixedLabel('BIll') . '[<a referencemodule="' . $old_module . '" referencerecord="' . $crmid . '"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:' . $color . '">' . $selectinfo[$crmid] . '</a>]' . getFixedLabel("NONEXTAPPROVER");
                        $correct--;  //没有审批人应该算提交失败，不应+1；
                    } else {
                        $batchlog = getFixedLabel('DOCUMENTSUCCESS');
                    }
                    //duan 20230112 验证规则判断，提交成功同样给出提示
                    if(isset($successlog_arr[$crmid])){
                        $validata_error = getFixedLabel('TIPS').':'.$successlog_arr[$crmid];
                    }else{
                        $validata_error = '';
                    }
                    
                    $successlog .= sprintf($batchlog, '<a referencemodule="' . $old_module . '" referencerecord="' . $crmid . '"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:' . $color . '">' . $selectinfo[$crmid] . '</a>', getFixedLabel('SUBMITAPPROVAL')).$validata_error . '<br>';


                    $callapimsg_arr = $stepinfo['workflow']['callapimsg_arr'];//工作流的调用API提示
                    if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                        $successlog .= implode('<br>',$callapimsg_arr)."<br/>";
                    }

                    $correct++;
                }
                $successlog = trim($successlog, '<br>');
            } else {
            }
            if (!empty($successlog)) {
                $submitlog .= $successlog;
            }
            if (!empty($failurelog)) {
                if (!empty($successlog))
                    $submitlog .= "<br>";
                $color = '';
                $key = 0;
                foreach ($failurelog as $crmid => $failure) {
                    if ($key >= $btach_num) {
                        break;
                    }
                    $key++;
                    if ($failure['status'] == constant('D_A_S_APPROVED')) {//'已批准'
                        $batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_APPROVED');
                        $color = '#FF0000';//已审批的单据，颜色设为红色
                    }
                    //海格报价单，使用状态为不可用的单据提示信息
                    elseif($failure['status'] == 'haigequotenosub' && $VersionInfo['account']=='haige'&&$_REQUEST['fld_module'] == 'Quotes'){
                        $batchlog = '单据[%s]提交失败！原因：该报价单已“失效”不允许提交';
                        $color = '';
                    }elseif($failure['status'] == 'noapplication'){
                        $batchlog = '单据[%s]提交失败！原因：该单据不属于当前审批流程的适用范围 ';
                        $color = '';
                    }elseif($failure['status'] == 'validata'){
                        $batchlog = '单据[%s]提交失败！原因：'.$failure['errortip'];
                        $color = '';
                    }else {
                        $batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_SUBMIT');
                        $color = '';
                    }
                    $submitlog .= sprintf($batchlog, '<a referencemodule="' . $old_module . '" referencerecord="' . $crmid . '"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:' . $color . '">' . $failure['subject'] . '</a>') . '<br>';
                }
                $submitlog = trim($submitlog, '<br>');
            }
        }

//		@edit:liushuai,2021-03-03,reason:【ID1001390】批量提交审批增加显示进度条
        if (!isset($_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct'])) {
            $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct'] = 0;
        }
     
        $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct'] += $correct;
        //chj 2021/3/10 44902: （61mis.com/kfbcrm）客户管理-跟进记录测试，全选单据列表20条跟进记录单据，操作提交审批，提交成功弹窗中，有的单据提示显示在同一行
        if (!empty($_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['edit_err'])) {
            $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['edit_err'] .= '<br>' . $submitlog;
        } else {
            $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['edit_err'] .= $submitlog;
        }

        $submitlog_title = sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'), $selectlen, $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct'], $selectlen - $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct']);
        $submitlog_content = $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['edit_err'];

        $arr['maxrows'] = sizeof($_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['crmid']);
        $arr['selectrows'] = $selectlen;
        $arr['correct'] = $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['correct'];

        $entity['log']['value'] = $_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['edit_err'];
        $entity['download']['value'] = getFixedLabel('CONFIRMED');//DOWNLOAD 下载
        if (isset($_SESSION['lvs'][$fld_module]['viewname'])) {
            $viewid = $_SESSION['lvs'][$fld_module]['viewname'];
            $start = $_SESSION['lvs'][$fld_module][$viewid]['start'];
        }
        if (!$start) $start = 1;
        $entity['start']['value'] = $start;
        $_REQUEST['diony'] = 'diony';
        $arr['title'] = getFixedLabel("APPROVAL") . ':' . getFixedLabel("SELECTAPPROVALPROC");
        $arr['oktext'] = getFixedLabel("CONFIRMED");
        $arr['content'] = '<div class="pop_remind_content"><div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">' . $submitlog_title . "</div></div><div class='pop_prc_content'>" . $submitlog_content . '</div></div>';

        if ($endrow >= sizeof($_SESSION['submitApprove'][$current_user->id . '_' . $module . 'batchsubmit']['crmid'])) {
            unset($_SESSION['submitApprove']);
        }

        ConvertTojsonString(1, $arr, "success");
    }

}
/**
 * 此处代码段需要反复调用，所以放到一个函数中统一调用
 * @param Object $approve    Approve.class对象
 * @param Object $result     Query查询结果集
 * @param String $module     模块名
 * @param Integer $approveid 审批流程ID
 * @project PROT144 审批功能改进
 * @return 执行提交审批操作
 * @author  Tujt 2014-12-25
 */
function submitApprove($approve, $result, $module, $approveid)
{
    global $adb;
    $rows = $adb->num_rows($result);
    $concurrentidStepCount = $_REQUEST['concurrentidStepCount'];

    if ($rows > 0) {
        $success = 0;
        for ($i = 0; $i < $rows; ++$i) {
            $crmid = $adb->query_result($result, $i, 'crmid');
            $approvestatus = $adb->query_result($result, $i, 'approvestatus');
            $subject = $adb->query_result($result, $i, 'subject');

            if ($approvestatus == constant('D_A_S_UNAPPROVED') || $approvestatus == constant('D_A_S_DISMISSED') || $approvestatus == '') {
                $batchlog = getFixedLabel('DOCUMENTSUCCESS');
                $color = '';

                if ($crmid > 0) {
                    $stepinfo = $approve->ApproveSubmit($module, $crmid, $approveid);
                    $_REQUEST['concurrentidStepCount'] = $concurrentidStepCount;
                    if ($stepinfo['nextstepid'] <= 0) {
                        $batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_NOTSUBMIT');
                        //如果该单据不满足所选择的审批流程的步骤查询条件
                        //则，前端弹出提示
                        //  $sql="select id from ld_approvelog where crmid=$crmid and approveresult=10 and approved_by=".$current_user->id.'  order by ld_approvelog.createdtime desc limit 1';

                        //  $result=$adb->pquery($sql,array());
                        //  $approvelogid=$adb->query_result($result,0,'id');
                        //删除记录的审批日志,不考虑并发
                        //  $sql='delete from ld_approvelog  where crmid= '.$crmid.' and approveid='.$approveid.' and id>='.$approvelogid;
                        // $adb->pquery($sql,array());
                    } else {
                        $success++;
                    }
                }
            } else {
                $batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_SUBMIT');
                $color = '#FF0000';//已审批的单据，颜色设为红色
            }
            $log .= sprintf($batchlog, '<a referencemodule="' . $module . '" referencerecord="' . $crmid . '"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:' . $color . '">' . $subject . '</a>', getFixedLabel('SUBMITAPPROVAL')) . '<br>';

        }
    }
    $data = array('log' => $log, 'success' => $success);
    return $data;
}

function resultExecApprove($approve, $result, $module, $approveid)
{
    global $adb;
    $rows = $adb->num_rows($result);
    $concurrentidStepCount = $_REQUEST['concurrentidStepCount'];
    if ($rows > 0) {
        for ($i = 0; $i < $rows; ++$i) {
            $crmid = $adb->query_result($result, $i, 'crmid');
            if ($crmid > 0) {
                $approve->ApproveSubmit($module, $crmid, $approveid);
                $_REQUEST['concurrentidStepCount'] = $concurrentidStepCount;
            }
        }
    }
    return $successlog;
}

/**
 * 删除生成的提交日志
 * @project PROT144 审批功能改进
 * @author  Tujt 2014-12-26
 */
function unsetApproveSubmitLogFiles()
{
    $cachepath = globalStatic::$root_directory . 'modules/Approve/';
    chmod($cachepath, 0777);
    $folder = @opendir($cachepath);
    if ($folder == false) return;
    $count = 0;
    $nowdate = date('Y-m-d', time());
    $isfile = array('.' => '1', '..' => '1', 'index.html' => '1', 'index.htm' => '1');
    while (false !== ($file = readdir($folder))) {
        if (isset($isfile[$file])) continue;//不可删除
        if (is_file($cachepath . $file)) {
            if (substr($file, 0, 16) != 'approvesubmitlog') continue;
            $files = explode('_', $file);
            $files = explode('.', $files[1]);
            $date = date('Y-m-d', strtotime($files[0]));
            if ($date < $nowdate) {
                chmod($cachepath . $file, 0777);
                if (@unlink($cachepath . $file)) ++$count;
            }
        }
    }
    closedir($folder);
    return $count;
}

?>