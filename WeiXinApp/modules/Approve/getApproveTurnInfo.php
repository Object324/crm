<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    $record = $_REQUEST['record'];
    $module = $_REQUEST['fld_module'];
    if(empty($module)) $module=getSalesEntityType($record);
    
    crm_load_class_file("cls_Approve_StepWX", 'WeiXinApp/modules/Approve/cls_Approve');
    $approveobj = new cls_Approve_StepWX($record,$module,array('approvepermit'));
    $approveinfo = $approveobj->getApproveInfo();
    if($approveobj->isnewlog =='yes'){
        $turn = $approveobj->getTrunInfoNew();
        $pass = $approveobj->getPassInfoNew();
    }else{
        $turn = $approveobj->getTrunInfo();
        $pass = $approveobj->getPassInfo();
    }
    $entity['turnlist'] = $turn;
    $entity['pass'] = $pass;
    $entity['list'] = $approveinfo['list'];
    $entity['list']['remarkrequire']=$approveinfo['remarkrequire'];
    $entity['list']['writesignrequired']=$approveinfo['writesignrequired'];
    
    //duan 20221020 移动端增加翻译字符串返回
    $label_arr=array(
        'REFERRAL',//转审
        'APPROVALSTEP',//审批步骤
        'LBL_PLEASE_SELECT',//请选择
        'APPROVALSUGGESTION',//审批意见
        'PLEASEFILLINYOURCOMMENTS',//请填写意见
        'handwriting',//手写签名
        'AUTOGRAPH',//签名
        'REWRITING',//重签
        'SUBMIT',//提交
        'APPROVER',//审批人
        'Countersigner',//会签审批人
        'APPROVEREMARKREQUIRE',//审批意见不能为空
        'SIGNATURECANNOTBEEMPTY',//手写签名不能为空
        'APPROVALSTEPISEMPTY',//审批步骤为空，无法提交
        'APPROVERISEMPTY',//审批人为空，无法提交
    );
    $entity['arrFixedLabel'] = TransFieldlabel($label_arr,'no');
    
    ConvertTojsonString(1, $entity, 'success');    
?>