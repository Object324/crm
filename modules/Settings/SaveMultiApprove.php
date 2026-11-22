<?php
/***************************************************
**edit:kevin
**date:2013-08-20
**reason:保存流程
***************************************************/


global $adb,$current_user;
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
if(isset($_REQUEST['name']) && $_REQUEST['name']!='')
$approvename=$_REQUEST['name'];
if(isset($_REQUEST['mode']) && $_REQUEST['mode']!='')
$mode=$_REQUEST['mode'];

if($mode!='edit'){
    $query="select name from ld_approve where tabid=$blockid and name='$approvename'";
}
else{
    $query="select name from ld_approve where tabid=$blockid and name='$approvename' and id!=$record";
}


$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$_REQUEST['diony']='yes';
if($num_rows){
	ConvertTojsonString(-1,array(),"流程名称已存在！");
}
    


$finishedallowedit=$_REQUEST['finishedallowedit'];//审批结束后是否允许编辑
$allowagainsubmit=$_REQUEST['allowagainsubmit'];//审批结束编辑单据保存，自动提交审批时默认审批流程
//editor:gyq_132 reason:审批流程默认值改进，增加default_on_new,default_on_submit  2019/7/22 15:19 ID1000479
$default_on_new = $_REQUEST['default_on_new'];
$default_on_submit = $_REQUEST['default_on_submit'];
$showsubmitremark = $_REQUEST['showsubmitremark'];
$submitremarkrequire = $_REQUEST['submitremarkrequire'];
$showurgent = $_REQUEST['showurgent'];
$enableexpediting = $_REQUEST['enableexpediting'];
//确认默认值只有一个
if($default_on_new=='yes'){
    $sql = 'update ld_approve set default_on_new=\'no\' where tabid=?';
    $adb->pquery($sql,array($blockid));
}
if ($default_on_submit=='yes'){
    $sql = 'update ld_approve set default_on_submit=\'no\' where tabid=?';
    $adb->pquery($sql,array($blockid));
}
if ($allowagainsubmit=='yes'){
    $sql = 'update ld_approve set allowagainsubmit=\'no\' where tabid=?';
    $adb->pquery($sql,array($blockid));
}
$finishededittype=$_REQUEST['finishededittype'];//审批结束后编辑适用范围
$selectfinishededitid=$_REQUEST['selectfinishededitid'];//审批结束后编辑适用范围选择的ID
$fininsedselectfield=$_REQUEST['fininsedselectfield'];//审批结束后可以编辑的字段
$editresetapprove=$_REQUEST['editresetapprove'];//编辑单据后是否重置其审批状态
if($finishedallowedit!='yes')
{
    $finishededittype='';
    $selectfinishededitid='';
    $fininsedselectfield='';
}
if($mode=='edit'){
    $query="update ld_approve set name=?,description=?,status=?,modifiedby=?,modifiedtime=?,approveallocatetype=?,allowediting=?,allowantiapproval=?,finishedallowedit=?,default_on_new=?,default_on_submit=?
            ,showsubmitremark=?,submitremarkrequire=?,showurgent=?,allowagainsubmit=?,enableexpediting=?
            ,finishedfield_allocatetype=?,finishedfield_allocateid=?,editresetapprove=? where id=?";
    $adb->pquery($query,array($approvename,$_REQUEST['description'],$_REQUEST['status'],$current_user->id,date('Y-m-d H:i:s')
            ,$_REQUEST['radiotype'],$_REQUEST['allowediting'],$_REQUEST['allowantiapproval'],$finishedallowedit
            ,$default_on_new,$default_on_submit,$showsubmitremark,$submitremarkrequire,$showurgent,$allowagainsubmit
            ,$enableexpediting,$finishededittype,$selectfinishededitid,$editresetapprove,$record));
    
    $sql='delete from ld_approve_finishededitfield where approveid=?';
    $adb->pquery($sql,array($record));
    

}else{
    if($record>0){
        //新增的审批流程
        $approveid=$record;
    }else
        $approveid=$adb->getUniqueID('ld_approve');
    
    $query="insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby
        ,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit
        ,default_on_new,default_on_submit,showsubmitremark,submitremarkrequire,showurgent
        ,allowagainsubmit,enableexpediting,finishedfield_allocatetype,finishedfield_allocateid,editresetapprove)";
    $query .="value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    $adb->pquery($query,array($approveid,$blockid,$approvename,$_REQUEST['description'],$_REQUEST['status']
    ,$current_user->id,$current_user->id,date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),$_REQUEST['radiotype']
    ,$_REQUEST['allowediting'],$_REQUEST['allowantiapproval'],$finishedallowedit,$default_on_new,$default_on_submit
    ,$showsubmitremark,$submitremarkrequire,$showurgent,$allowagainsubmit,$enableexpediting,$finishededittype,$selectfinishededitid,$editresetapprove));
    $record=$approveid;
}
if($finishedallowedit=='yes'&&$_REQUEST['fininsedselectfieldtype']=='part')
{
    $fininsedselectfield_arr=json_decode($fininsedselectfield,true);
    foreach($fininsedselectfield_arr as $tmpcolums)
    {
        $sql=' insert into ld_approve_finishededitfield(columns,approveid,userid)
        value(?,?,?)';
       $adb->pquery($sql,array($tmpcolums,$record,$current_user->id));
      
    }
}
/*
     * editor:gyq_05
     * reason:控制面板新建审批，新增适用范围
     * date  : 2016 02 18
     * explain: $_REQUEST['selectallocateid'] => 选中的具体内容,$_REQUEST['radiotype']=>单选框选中的类型
     * */
if($_REQUEST['radiotype']=='0'){
    if($mode=='edit'){
        $query="delete from ld_approve2user where approveid=?";
        $adb->pquery($query,array($record));
    }
    $sql='insert into ld_approve2user(approveid,userid)values(?,?)';
    $adb->pquery($sql,array($record,'-1'));

}elseif($_REQUEST['radiotype']=='1'||$_REQUEST['radiotype']=='2'||$_REQUEST['radiotype']=='3'){
    if($mode=='edit'){
        $query="delete from ld_approve2user where approveid=?";
        $adb->pquery($query,array($record));

    }
    $owners = explode(",",$_REQUEST['selectallocateid']);
    foreach($owners as $key=>$arr){
        $sql="insert into ld_approve2user(approveid,userid) values(?,?)";
        $adb->pquery($sql,array($record,$arr));
    }
}




// function insertRole($approveid)
// {
//     global $adb;
//     $selected_role_col_string=$_REQUEST['selectedRoleColumnsString'];
//     $roleArray=Array();
//     $member_array=explode(';',$selected_role_col_string);
//     foreach($member_array as $member){
//         $memSubArray=explode('::',$member);
//         if($memSubArray[0] == 'roles'){
//             $roleArray[]=$memSubArray[1];
//         }        
//     }    
//     foreach($roleArray as $roleid){
//         $query="insert into ld_approve2role(approveid,roleid)";
//         $query .="value(?,?)";
//         $adb->pquery($query,array($approveid,$roleid));
//     }
// }



$_REQUEST['diony']='yes';
 ConvertTojsonString(1,array(),"success");
?>