<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$weixin_user;
require_once(globalStatic::$root_directory.'Smarty_setup.php');

if(isset($_REQUEST['record']) && $_REQUEST['record']!=''){
    $record=$_REQUEST['record'];
}
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){
    $fld_module=$_REQUEST['fld_module'];
    if($fld_module=='ServiceCharge'){
        $fld_module='Accounts';
    }
    if($fld_module == 'Calendar')
    {
        $sql="SELECT tabid from ld_tab where name='Calendar'";
        $sqldeployresult=$adb->pquery($sql,array());
        $blockid=$adb->query_result($sqldeployresult,0,'tabid');  
    }else{
        $blockid=getTabid($fld_module);
    }
}
$module = $fld_module;
//@edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（合同订单和自定义11-45模块提交审批时）
//if (isset($_REQUEST['pushtype']) && $_REQUEST['pushtype']=='dingtalk') {
    require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
    $appremindObj = new ApproveRemind();
    $result = $appremindObj->sendMessageByDingDing();
//    $_REQUEST['diony']='diony';
//    if ($result) {
//        ConvertTojsonString(1,array('res'=>$result),'');
//    }else{
//        ConvertTojsonString(-1,array(),'');
//    }
//}

crm_load_class_file("ApproveCommon","modules/Approve");
$approvecommonobj = ApproveCommon::getInstance($fld_module);

$focus=CRMEntity::getInstance($fld_module);
if(!empty($record))$focus->id = $record;

if(isset($_REQUEST['check']) && $_REQUEST['check']=='true'){
    $approveinfo=$approvecommonobj->approveStatus($record);
    if($approveinfo['approvestatus']==1)
    {
        ConvertTojsonString(-1,$approveinfo,getFixedLabel('MODULE_HAVED_APPROVED'));
    }
    else{
        if($record >0 ){
            //duan 20230112 移动端提交审批时时判断验证规则
            if($_REQUEST['operate_again'] != 'yes'){
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($fld_module,$record,0);
                $PageValidataSaveobj->MobileValidataInfo('submit');
            }
        }
        
        //editor:gyq_132 reason:审批流程默认值改进  2019/7/23 10:07 ID1000479
        $weixin_user->action = 'default_on_submit';
        if(isset($_REQUEST['assigneduserid'])&&$_REQUEST['assigneduserid']>0){
            $assigneduserid=$_REQUEST['assigneduserid'];
            $table_index=$focus->table_index;
            $tablename=$focus->table_name;

        }
        else{
            $assigneduserid=$current_user->id;
        }

        $columnvalue_arr = [];
        $get_request = 'no';
        if(isset($_REQUEST['requestvalues']))
         {
             $get_request = 'yes';
            //edit:can 20220707 http://123.135.130.44:85/chengtao/
            $requestvalues=$_REQUEST['requestvalues'];
            $requestvalue_arr=ldcrm_json_decode($requestvalues);

             $columnvalue_arr = $requestvalue_arr;
             if(isset($_REQUEST['detaildata_arr'])){
                 $detaildata_arr = $_REQUEST['detaildata_arr'];
                 $columnvalue_arr = array_merge($columnvalue_arr,$detaildata_arr);
             }

             //获取不在界面上显示的字段值
             if($record > 0){
                 $focus->mode = 'edit';
                 $focus->id = $record;
                 $focus->retrieve_entity_info($record,$module);
                 //布局规则控制不显示的字段不应该赋值
                 crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
                 $fieldruleobj=cls_fieldrule::getInstance($module);
                 $fieldruleobj->setColumnValues($requestvalue_arr);
                 $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
                 $hidden_column = $fieldrulecolsproperty['hidecolumns'];
                 foreach ($hidden_column as $tmp_column){
                     $columnvalue_arr[$tmp_column] = '';
                 }
             }

             $modulefields=$focus->fieldobj->getModuleFields();
             foreach($modulefields as $fieldname=>$fieldinfo)
             {
                 $focus->column_fields[$fieldname]=$requestvalue_arr[$fieldinfo->getColumnName()];
             }
         }
         //if(stripos($assigneduserid,",")!==false)
//         {
//            $assigneduserid_arr=explode(",",$assigneduserid);
//            $approveinfos=$approvecommonobj->getAllApprovesByUserid($blockid,$current_user->id);
//         }
//         else
//             $approveinfos=$approvecommonobj->getAllApprovesByUserid($blockid,$assigneduserid);
//        
//         duan 20221102 移动端获取审批流程应该按照当前用户获取，暂时不知道原有的逻辑是什么样的，暂时注释掉
        if($get_request == 'yes'){
            crm_load_class_file("cls_approvestep_change","modules/Approve");
            $approvestep_change_obj = new cls_approvestep_change($module);
            $approvestep_change_obj->set_focus($focus);
            $approvestep_change_obj->set_approveobj('');
            $approvestep_change_obj->set_column_value($columnvalue_arr);

            $approvestep_change_obj->setdetailrowcnt($detaildata_arr['rowcnt']);
            $approveinfos = $approvestep_change_obj->getApplicableApproveInfo();
        }else{
            $approveinfos=$approvecommonobj->getAllApprovesByUserid($blockid,$current_user->id);
        }
        $cur_approveid = $_REQUEST['cur_approveid'];
        $selected = 'no';
        //第一次循环先获取所有的流程id，用于判断当前的审批流程是否可用
        $approveid_arr = [];
        $in_arr = 'no';
        foreach($approveinfos as $approveindex=>$approveinfo){
            $approveid = $approveinfo['approveid'];
            if($cur_approveid == $approveid){
                $in_arr = 'yes';
            }
        }
        $have_default = 'no';
        foreach($approveinfos as $approveindex=>$approveinfo){
            $approveid = $approveinfo['approveid'];
            //判断所选单据是否符合条件
            if($get_request == 'no'){
                if(!empty($record)&&$approvecommonobj->getApplicationByCondition($approveid,$record)=='no'){
                    unset($approveinfos[$approveindex]);
                    continue;
                }
            }
            
            $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
            if($get_request == 'yes'){
                $approveobj->setApprovechangeCheck($columnvalue_arr);
            }
            $nextStepInfo = $approveobj->getApproveStepInfo($approveinfo['approveid'],$_REQUEST['record'],$_REQUEST['assigneduserid']);
            
           /* $approveinfos[$approveindex]['userids']=$nextStepInfo[3];
            $approveinfos[$approveindex]['usernames']=$nextStepInfo[1];
            
            $approveinfos[$approveindex]['specifyuser']=$nextStepInfo[2];
            $approveinfos[$approveindex]['countersigner']=$nextStepInfo[4];*/
           
            foreach($nextStepInfo as &$tmpstepinfo)
            {
                if(isset($_REQUEST['requestvalues']))
                {
                        $stepuserids = $approveobj->getApproveByInfo($tmpstepinfo['nextsteptype'],$tmpstepinfo['nextstepvalue'],$focus);
                    //duan 2022-3-31 提交审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
                    if(empty($stepuserids) && $approveobj->get_allow_emptyapprover($tmpstepinfo['stepid'],$tmpstepinfo['nextsteptype']) == 'yes'){ //如果该类型可以设置对应参数
                        $emptyapproverdeal=$tmpstepinfo['emptyapproverdeal'];
                        $stepuserids = $approveobj->getTransferUsers($emptyapproverdeal);
                    }
                    $tmpstepinfo['stepuserids']=$stepuserids;
                }
                else
                    $stepuserids=$tmpstepinfo['stepuserids'];
                $userdata= cls_StaticCommonFun::getUserDetailInfo($stepuserids);
                $tmpstepinfo['userdata']=$userdata;
            }
            if(!empty($cur_approveid) && $in_arr == 'yes'){
                if($approveid == $cur_approveid){
                    $have_default = 'yes';
                    $approveinfos[$approveindex]['selected'] = 'selected';
                }else{
                    $approveinfos[$approveindex]['selected'] = '';
                }
            }
            $approveinfos[$approveindex]['steplist']=$nextStepInfo;
        }
        $approveinfos = array_values($approveinfos);
        if(count($approveinfos) >0){
            if($have_default == 'no' && !empty($cur_approveid)){
                $approveinfos[0]['selected'] = 'selected';
            }
        }

        $arrapprove['list'] = $approveinfos;
        //duan 20221019 移动端获取翻译字符串
        $label_arr=array(
            'Approval_Process',//审批流程
            'UrgentApproval',//需要加急审批
            'APPURGENTAPPROVAL',//加急审批
            'SUBMITCOMMENTS',//提交意见
            'PLEASEFILLINYOURCOMMENTS',//请填写意见
            'SUBMIT',//提交
            'SUBMITAPPROVAL',//提交审批
            'APPROVER',//审批人
            'ConcurrentApproval',//并发审批
            'Countersigner',//会签审批人
            'AddApprover',//添加审批人
            'APPROVERISEMPTY',//审批人为空，无法提交
            'APPROVEREMARKREQUIRE',//审批意见不能为空
            'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
        );
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $arrapprove['arrFixedLabel'] = $fixedlabel_arr;
        
        if(empty($approveinfos)||$approveinfos==''){
            ConvertTojsonString(-1,$arrapprove,getFixedLabel('NOPROCESSPLEASESETPROCESS'));
        }
        else{
            ConvertTojsonString(1,$arrapprove,'');
        }
    }
}elseif(isset($_REQUEST['save']) && $_REQUEST['save']=='true'){
    $approveid = $_REQUEST['approvevalue'];
    $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
    $lastapproveinfo=$approveobj->getlastapproveinfo($record,$fld_module);

    $issubmit='yes';
    if($lastapproveinfo['stepid']==-1&&$lastapproveinfo['approveresult']==1)
    {
        //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
        $issubmit='no';
    }

    if($lastapproveinfo['approveresult']==2  && !$approveobj->recordAgainSubmit($fld_module))
    {
        //已经审批成功
        $issubmit='no';
    }
    //duan 20240730 存在并发操作的问题,控制已删除单据不能提交审批
    if($lastapproveinfo['deleted']==1 )
    {
        //已经审批成功
        $issubmit='no';
    }

     if($issubmit=='no')
     {
        ConvertTojsonString(-1,$approveinfo,getFixedLabel("Approvestephavechangetip"));
     }
    //20230424 duan BUG0065462:保存并提交审批时增加条件是否满足判断
    if($approvecommonobj->getApplicationByCondition($approveid,$record)=='no'){
        ConvertTojsonString(-1, [], getFixedLabel('NOTMEETCONDITIONSPLEASERESUBMIT'));
    }
    crm_load_class_file('cls_PageValidataSave','data');
    $PageValidataSaveobj=new cls_PageValidataSave($fld_module,$record,0);
    $PageValidataSaveobj->setApplication('submit');

    $PageValidataSaveobj->setAllowSave('no');
    $PageValidataSaveobj->getValidDataInfoPhp();
    if(!empty($PageValidataSaveobj->errortip)){
        ConvertTojsonString(-1, [], $PageValidataSaveobj->errortip);
    }


    //$nextStepInfo = $approveobj->getApproveStepInfo($approveid,$record);
    $concurrentidStepCount=$_REQUEST['concurrentidStepCount'];
    
    if($concurrentidStepCount>0)
    {
         $approvestepinfo_arr[$approveid]= $approveobj->getAllStepInfoByApproveid($approveid);
      
       $alltotalCount=sizeof($approvestepinfo_arr[$approveid]);
       $concurrentidStepCount=0;
       $i=-1;
      $_REQUEST['concurrentid']=$approvestepinfo_arr[$approveid][0]['concurrentid'];
      
       foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo)
       {
            $tmpconcurrentid= $tmpstepinfo['concurrentid'];
            $i++;
            if($tmpconcurrentid!=$_REQUEST['concurrentid'])
                continue;
                
             $_REQUEST['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];
                   
            $_REQUEST['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
            $_REQUEST["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
            $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
            $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');
            
            $_REQUEST["userid_$concurrentidStepCount"]=$approveobj->getApproveBy($approvetype,$approvevalue,$record);
            $_REQUEST["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
            $concurrentidStepCount++;
       }
       $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
    }
    /*for($i=0;$i<$concurrentidStepCount;$i++)
    {
        if($_REQUEST["userid_$i"]==0||$_REQUEST["userid_$i"]=='')
        {
             ConvertTojsonString(-1,$approveinfo,getFixedLabel('NONEXTAPPROVER'));
        }
    }*/
     $stepinfo= $approveobj->ApproveSubmit($fld_module,$record,$approveid);
  //  if(empty($nextStepInfo[1])){
   // }else{
      
         if($stepinfo['nextstepid']<=0)
         {
                
                //如果该单据不满足所选择的审批流程的步骤查询条件
                //则，前端弹出提示
                $sql="select id from ld_approvelog where crmid=$record and approveresult=10 and approved_by=".$current_user->id.'  order by ld_approvelog.createdtime desc limit 1';
                
                $result=$adb->pquery($sql,array());
                $approvelogid=$adb->query_result($result,0,'id');
                //删除记录的审批日志,不考虑并发
                $sql='delete from ld_approvelog  where crmid= '.$record.' and approveid='.$approveid.' and id>='.$approvelogid;
                $adb->pquery($sql,array());
                //给出没有满足审批步骤的提示
                ConvertTojsonString(-1,array(1),getFixedLabel("CURRENTAPPROVALPROCESSSELECTAPPROVAL"));
         }
    $arr = [];
    if (isset($stepinfo['workflow'])) {
        //检查是否有API调用
        crm_load_class_file("cls_savereverse",'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($fld_module);
        $receive_msg = $workflowreverseobj->checkCallApiPop();
        $arr['workflow']['receive_msg'] = $receive_msg;
        if ($receive_msg == 'yes') {
            $arr['workflow']['record'] = $record;
            $arr['workflow']['module'] = $fld_module;
            $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
        }
    }


        ConvertTojsonString(1,$arr,'');
    //}
}
/*require_once(globalStatic::$root_directory.'appCommon/modules/Approve/SubmitApprove.php');*/
?>