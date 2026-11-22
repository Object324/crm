<?php
/********************************************
**edit:kevin
**date:2013-09-16
**reason:审批回撤
********************************************/
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
if(isset($_REQUEST['approveid']) && $_REQUEST['approveid'])
$approveid=$_REQUEST['approveid'];
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid'])
$stepid=$_REQUEST['stepid'];
if(isset($_REQUEST['isapprove']) && $_REQUEST['isapprove'])
$isapprove=$_REQUEST['isapprove'];
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!='')
$fld_module=$_REQUEST['fld_module'];
require_once('modules/Approve/ApproveRemind.php');
$appremindObj = new ApproveRemind();
require_once('modules/Approve/Approve.php');
$approve=new Approve();
$num_rows=$approve->antiApprove($record,$approveid,$stepid);
$query="select * from ld_approvelog
where crmid=? and approveid=? order by createdtime
";
$result=$adb->pquery($query,array($record,$approveid));
$num_rows=$adb->num_rows($result);
$approveby=$adb->query_result($result,$num_rows-1,'approved_by');
$approveresult=$adb->query_result($result,$num_rows-2,'approveresult');//上步的审批状态

if($num_rows){
    //$query="delete from ld_approvelog where crmid=? and approveid=? and stepid=?";
	//删除之前的审批提醒
	$appremindObj->updateRemindStatus($record);
    $approvelogid=$adb->getUniqueID('ld_approvelog');
    $query="insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,
    approveresult,createdtime,nextstepid,nextstepapproveby)";
    $query .="value(?,?,?,?,?,?,?,?,?,?)";
    $adb->pquery($query,array($approvelogid,$record,'',$approveid,-2,$current_user->id,$approveresult,date('Y-m-d H:i:s'),$stepid,$approveby));
     switch($fld_module){
        case 'Quotes':
        $moduleid='quoteid';
        break;
        case 'HelpDesk':
        $tabname='ld_troubletickets';
        $moduleid='ticketid';
        break;
        case 'Accounts':
        $moduleid='accountid';
        $tabname='ld_account';
        break;
        /*
        新增操作，by andy,知识管理增加审批流程20131213
        */
        case 'Documents':
        $moduleid='notesid';
        $tabname='ld_notes';
        break;
        default:
        $tabname="ld_".$fld_module;
        $moduleid=$fld_module.'id';
    }
    if($approveresult==1 || $approveresult==5){
		$approveresult = constant('D_A_S_APPROVALOF');//'审批中';
	}

      $sql="update $tabname set approvestatus='".$approveresult."',approveby=$current_user->id where $moduleid=$record";
      $adb->query($sql);
      
    if($fld_module=='PutCash'){
        $smongysql = "SELECT inaccount,outaccount,cashmoney FROM ld_putcash WHERE putcashid=$record";
        $result = $adb->pquery($smongysql);
        $account = $adb->query_result($result,0,'outaccount');
        $monery = $adb->query_result($result,0,'cashmoney');
        $account2 = $adb->query_result($result,0,'inaccount');
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account";
        $adb->pquery($usql,array());
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE bankaccountsetid=$account2";
        $adb->pquery($usql,array());
    }elseif($fld_module=='CashDeposit'){
        $smongysql = "SELECT inaccount,cashmoney,outaccount FROM ld_cashdeposit WHERE cashdepositid=$record";
        $result = $adb->pquery($smongysql);
        $account = $adb->query_result($result,0,'inaccount');
        $monery = $adb->query_result($result,0,'cashmoney');
        $account2 = $adb->query_result($result,0,'outaccount');
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE bankaccountsetid=$account";
        $adb->pquery($usql,array());  
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account2";
        $adb->pquery($usql,array());  
    }elseif($fld_module=='Expense'){
        $smongysql = "SELECT bankaccountsetid,total FROM ld_expense WHERE expenseid=$record";
        $result = $adb->pquery($smongysql);
        $account = $adb->query_result($result,0,'bankaccountsetid');
        $monery = $adb->query_result($result,0,'total');
        $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account";
        $adb->pquery($usql,array());  
    }
    echo "###SUCCESS###";
    exit();
    
}
else{
    echo "###USED###";  
    exit();
}

?>