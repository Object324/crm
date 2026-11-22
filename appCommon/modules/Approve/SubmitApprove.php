<?php
global $adb,$current_user;
require_once(globalStatic::$root_directory.'Smarty_setup.php');

if(isset($_REQUEST['save']) && $_REQUEST['save']!=''){
    $save=$_REQUEST['save'];
}
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

require_once(globalStatic::$root_directory.'modules/Approve/Approve.php');
$approve=new Approve();

/*	0027292: （app）单据提交审批当一级审批为空时提示：暂无审批人，请检查审批流程步骤！*/
if($_REQUEST['getnextstepinfo'] > 0){
    //需要审批的单据id,可以是多个
    if(!empty($_REQUEST['approve_recordid'])){
        $record = $_REQUEST['approve_recordid'];
    }
    //0025876: 报价单列表：勾选单据，点击【全选n条记录】在批量提交审批，选择审批流程：本部门，列表上不显示审批人
    if($record != 'all'){
        $selectarr = explode(';',$record);
        $record = $selectarr[0];
    }else{
        $query = getListAllQuery($fld_module,1);//获取query，不需要任何附加条件
        $result = $adb->pquery($query['query'],array());
        $record = $adb->query_result($result,0,0);
    }


    $approveid = $_REQUEST['getnextstepinfo'];

    $nextStepInfo = $approve->getApproveStepInfo($approveid,$record);
    if(empty($nextStepInfo[1])){
        ConvertTojsonString(-1,$approveinfo,getFixedLabel('NONEXTAPPROVER'));
    }else{
        ConvertTojsonString(1,array(),'success');
    }
}

if(isset($_REQUEST['check']) && $_REQUEST['check']=='true'){
    $approveinfo=$approve->approveStatus($record);
    if($approveinfo['approvestatus']==1)
    {
        ConvertTojsonString(-1,$approveinfo,getFixedLabel('MODULE_HAVED_APPROVED'));
    }
    else{
        ConvertTojsonString(1,$approveinfo,'');
    }
}
else{
    if($save=='false'){
        $approve=$approve->submitApprove($blockid);
        $arrapprove['list'] = $approve;
        if(empty($approve)||$approve==''){
            ConvertTojsonString(-1,$arrapprove,getFixedLabel('NOPROCESSPLEASESETPROCESS'));
        }
        else{
            ConvertTojsonString(1,$arrapprove,'');
        }
    }
    else{
        $approveid = $_REQUEST['approvevalue'];
        $stepinfo=$approve->ApproveSubmit($fld_module,$record,$approveid);
        if($stepinfo['nextstepid']<=0)
        {
            $sql='delete from ld_approvelog where crmid=? and approveresult=4 ORDER BY createdtime desc,id desc limit 1';
            $adb->pquery($sql,array($record));
            ConvertTojsonString("-1",array(),getFixedLabel("CURRENTAPPROVALPROCESSSELECTAPPROVAL"));
        }
        ConvertTojsonString(1,array(1),'');
    }
}
?>