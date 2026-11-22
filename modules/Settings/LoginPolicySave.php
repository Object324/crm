<?php

global $adb;
if($_REQUEST['ruleid'])
{
    $ruleid=$_REQUEST['ruleid'];
}
$rulename = $_REQUEST['rulename'];
$ruletype = $_REQUEST['ruletype'];
$controlmode = $_REQUEST['controlmode'];
$scopetype = $_REQUEST['scopetype'];
$enablestatus = $_REQUEST['enablestatus'];//是否启用
$description = $_REQUEST['description'];
$scopeids = $_REQUEST['scopeids'];
$scopeids = !empty($scopeids)?explode(',', $scopeids):[];

if($ruletype == 'Geographicalregion'){
    $typecontent=$_REQUEST['cityvalue'];
    $statusvalue=$_REQUEST['statusvalue'];

}
else if($ruletype == 'IPaddress'){
    // $tmptypecontent=$_REQUEST['IPaddress'];
    //$typecontent=serialize($tmptypecontent);
     $typecontent=$_REQUEST['IPaddress'];
}
else{
    $typecontent='';
}

//适用范围类型
if($scopetype == 'group') $applicablescope = 'group';
else if($scopetype == 'user') $applicablescope = 'user';
else if($scopetype == 'role') $applicablescope = 'role';
else{ $applicablescope = 'all'; $scopeids = [-1];}
//每次创建优先级+1
$sql_len="select * from ld_loginpolicy";
$result_len=$adb->pquery($sql_len,array());
$priority = $adb->num_rows($result_len)+1;
//是否启用
if($enablestatus == 'on'|| $enablestatus == 'yes'|| $enablestatus == 'true') {
    $enablestatus = 'yes';
}
else {
    $enablestatus = 'no';
}

// $isDefault=$_REQUEST['isDefault'];
// $sql="select name from ld_tab where tabid=?";
// $result=$adb->pquery($sql,array($printtabid));
// $tabname=$adb->query_result($result,0,0);

if($_REQUEST['mode']=="create")//创建
{
    if($_REQUEST['isDuplicate'])//判断模板名称是否重复
    {
        $sql="select ruleid from ld_loginpolicy where rulename=?";
        $result=$adb->pquery($sql,array($rulename));
        $_REQUEST['diony']='diony';
        if(isset($ruleid)&&$adb->num_rows($result)>1)
        {
            ConvertTojsonString(-1,array(),"规则名称重复！");
        }
        if(!isset($ruleid)&&$adb->num_rows($result)>0)
        {
            ConvertTojsonString(-1,array(),"规则名称重复！");
        }
    }
    $sql='INSERT into ld_loginpolicy(rulename,ruletype,priority,controlmode,applicablescope,enablestatus,`description`,typecontent,`statusvalue`)values(?,?,?,?,?,?,?,?,?)';
    $adb->pquery($sql,array($rulename,$ruletype,$priority,$controlmode,$applicablescope,$enablestatus,$description,$typecontent,$statusvalue));
    
    $ruleid=$adb->getLastInsertID($ruleid);//读取最后插入ruleid
    for($i=0;$i<count($scopeids);$i++){ //根据最后插入的ruleid循环插入适用范围人员id
        $sql_user=' insert into ld_loginpolicy_user(ruleid,userid)value(?,?)';
        $adb->pquery($sql_user,array($ruleid,$scopeids[$i]));
    }
}
else if($_REQUEST['mode']=="updatesort"){
    $priorityupdate=$_REQUEST['priorityupdate'];
    $priorityupdate = !empty($priorityupdate)?explode(';',$priorityupdate):[];

    for($i=0 ;$i<count($priorityupdate);$i++){
        if(!empty($priorityupdate[$i])){
            $columnsql = "UPDATE ld_loginpolicy set `priority`=? where ruleid = ?";
            $columnsqlresult = $adb->pquery($columnsql, array(($i+1),$priorityupdate[$i]));
        }
    }
}
else if($_REQUEST['mode']=="updateenable"){
    $enablestatus=$_REQUEST['enablestatus'];
    if($enablestatus == 'no' && !checkAtLeastOnePolicy($ruleid)){// 必须启用至少一个策略，保证系统的可登录性
        $error_msg = getFixedLabel('PleaseEnableOneRule');
        ConvertTojsonString(-1,array(),$error_msg);
    }
    $updatesql = "UPDATE ld_loginpolicy set `enablestatus`=? where ruleid = ?";
    $updatesqlresult = $adb->pquery($updatesql, array($enablestatus,$ruleid));
}
else
{
    if($enablestatus == 'no' && !checkAtLeastOnePolicy($ruleid)){// 必须启用至少一个策略，保证系统的可登录性
        $error_msg = getFixedLabel('PleaseEnableOneRule');
        ConvertTojsonString(-1,array(),$error_msg);
    }
    $sql='SELECT rulename,typecontent from ld_loginpolicy where ruleid=?';
    $result=$adb->pquery($sql,array($ruleid));
    $tmptypecontent = $adb->query_result($result,0,'typecontent');
    //字符串转换成数组合并数据后，再转换成字符串存入数据库
    // $tmptypecontent=explode(',',$tmptypecontent);
    // $typecontent=explode(',',$typecontent);
    // $typecontent=array_filter($typecontent);
    // $newtypecontent = $tmptypecontent + $typecontent;
    // $newtypecontent = implode(',',$newtypecontent);

    $num_rows = $adb->num_rows($result);
    if($num_rows<=0)
    {
		ConvertTojsonString(-1,array(),"规则已被删除！");
    }
    if($_REQUEST['mode']=="edit"){
        $sql="UPDATE ld_loginpolicy set rulename=?,ruletype=?,controlmode=?,enablestatus=?,`description`=?,typecontent=?,statusvalue=? where ruleid=?";
    }
    $adb->pquery($sql,array($rulename,$ruletype,$controlmode,$enablestatus,$description,$typecontent,$statusvalue,$ruleid));
    //传的有值时才执行更新数据库
    if(isset($scopetype)){
        $sql="UPDATE ld_loginpolicy set applicablescope=? where ruleid=?";
        $adb->pquery($sql,array($applicablescope,$ruleid));
        
        $sql_del="DELETE from ld_loginpolicy_user where ruleid=?";
        $adb->pquery($sql_del,array($ruleid));
        for($i=0;$i<count($scopeids);$i++){ //根据当前ruleid循环插入适用范围人员id
            $sql_user=' insert into ld_loginpolicy_user(ruleid,userid)value(?,?)';
            $adb->pquery($sql_user,array($ruleid,$scopeids[$i]));
        }
    }
}

function checkAtLeastOnePolicy($ruleid){
    global $adb;
    $select_sql = "SELECT * from ld_loginpolicy where ruleid !=? and enablestatus = 'yes'";
    $result = $adb->pquery($select_sql,array($ruleid));
    $num_rows = $adb->num_rows($result);
    if($num_rows > 0)
        return true;
    else
        return false;
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>