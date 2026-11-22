<?php
//电话录音设置
global $current_user;
global $adb;
$arr=[];
$_REQUEST['diony']='yes';
if($_REQUEST['method']=='saveallowuploadcall')
{
    $value=$_REQUEST['value'];
    $sql='select * from ld_module_setting_byuser where modulename=? and userid=? and type=? ';
    $result=$adb->pquery($sql,array("CallLog",$current_user->id,'allowuploadcall'));
    if($adb->num_rows($result)<=0)
    {
        $sql=' insert into ld_module_setting_byuser (modulename,userid,type,content,createdtime,modifiedtime)
    value(?,?,?,?,?,?)';

        $adb->pquery($sql,array("CallLog",$current_user->id,"allowuploadcall",$value,date("Y-m-d H:i:s"),date("Y-m-d H:i:s")));
    }
    else{
        $sql='update ld_module_setting_byuser set content =? where id=? ';
        $adb->pquery($sql,array($value,$adb->query_result($result,0,'id')));

    }


}
else if($_REQUEST['method']=='saveautouploadcall') {

    $value=$_REQUEST['value'];
    $sql='select * from ld_module_setting_byuser where modulename=? and userid=? and type=? ';
    $result=$adb->pquery($sql,array("CallLog",$current_user->id,'autouploadcall'));
    if($adb->num_rows($result)<=0)
    {
        $sql=' insert into ld_module_setting_byuser (modulename,userid,type,content,createdtime,modifiedtime)
    value(?,?,?,?,?,?)';
        $adb->pquery($sql,array("CallLog",$current_user->id,"autouploadcall",$value,date("Y-m-d H:i:s"),date("Y-m-d H:i:s")));

    }
    else{
        $sql='update ld_module_setting_byuser set content =? where id=? ';
        $adb->pquery($sql,array($value,$adb->query_result($result,0,'id')));
    }
}
else if($_REQUEST['method']=='saverecordpath')
{
    //录音文件的路径
    $value=$_REQUEST['value'];
    $sql='select * from ld_module_setting_byuser where modulename=? and userid=? and type=? ';
    $result=$adb->pquery($sql,array("CallLog",$current_user->id,'saverecordpath'));
    if($adb->num_rows($result)<=0) {
        $sql = ' insert into ld_module_setting_byuser (modulename,userid,type,content,createdtime,modifiedtime)
    value(?,?,?,?,?,?)';
        $adb->pquery($sql, array("CallLog", $current_user->id, "saverecordpath", $value, date("Y-m-d H:i:s"), date("Y-m-d H:i:s")));
    }
    else{
        $sql='update ld_module_setting_byuser set content =? where id=? ';
        $adb->pquery($sql,array($value,$adb->query_result($result,0,'id')));
    }
}
else if($_REQUEST['method']=='getvalueinfo')
{
     $sql='select * from ld_module_setting_byuser  where modulename=? and userid=? and (type=? or type=?)';
     $result=$adb->pquery($sql,array('CallLog',$current_user->id,"allowuploadcall","autouploadcall"));

     for($i=0;$i<$adb->num_rows($result);$i++)
     {
        $type=$adb->query_result($result,$i,'type');
        $content=$adb->query_result($result,$i,'content');
        $arr[]=['type'=>$type,'value'=>$content];


     }

}
ConvertTojsonString(1,['list'=>$arr],'sucesss');

?>