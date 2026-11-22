<?php
global $adb;
$focus=CRMEntity::getInstance('ServiceCharge');
$fieldobj=$focus->fieldobj;
$version = getVersionTradeInfo();
if(isset($_REQUEST['accountid']) && isset($_REQUEST['fieldname']))
{
    $accountid = $_REQUEST['accountid']; 
    $tabid_fieldname = $_REQUEST['fieldname'];
}
$array_fieldname = explode(",",$tabid_fieldname);
if($array_fieldname[sizeof($array_fieldlabel)]=="")
{
    array_pop($array_fieldname);
}
$leftjoin=" from  ld_account ";
foreach($array_fieldname as $fieldname)
{
    if(empty($fieldname))
            continue;
    if(strpos($fieldname,"#")!==false)
    {
                //目前只有客户或服务收费管理模块有该功能
                $modules=explode("#",$fieldname);
                $othermodule=$modules[0];
                $realfieldname=$modules[1];
              
                $otherfocus=CRMEntity::getInstance($othermodule);
                $fieldinfo=$otherfocus->fieldobj->getFieldInfoobjBykey('fieldname',$realfieldname);
    }
    else
    {
        $fieldinfo=$fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    }
    
     
    $columns_all[]=$fieldinfo->getTableName().".".$fieldinfo->getColumnName();
    $columns[]=$fieldinfo->getColumnName();
   $tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
}  

foreach($tables as $tablename)
{
    if($tablename=='ld_contactscf')
    { 
        //保证from 子句中 先连接ld_contactdetails,后连接ld_contactscf
        $leftjoin.=' left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid and ld_contactdetails.deleted=0';
        $leftjoin.=' left join ld_contactscf on ld_contactdetails.contactid=ld_contactscf.contactid';
       $contactcolumn=" ,ld_contactdetails.lastname ";
    }
    else if($tablename=='ld_contactdetails')
    {
        //保证from 子句中 先连接ld_contactdetails,后连接ld_contactscf
        if(!array_key_exists('ld_contactscf',$tables))
        {
            $contactcolumn=" ,ld_contactdetails.lastname ";
            //$columns[]="lastname";
             $leftjoin.=' left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid and ld_contactdetails.deleted=0';
        }
            
    }
    else if($tablename=='ld_accountscf')
    {
        $leftjoin.=' left join ld_accountscf on ld_accountscf.accountid=ld_account.accountid ';
    }
}
if($accountid=='all')
{
    //duan 东贸-区分大巴车和下游客户
    if($version['account']=='dongmao'){
        $leftjoin.=' left join  ld_customform10 on ld_account.customform10_id=ld_customform10.customform10id ';
        if(!array_key_exists('ld_contactdetails',$tables)){
            $leftjoin .= ' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid ';
        }
        if(!array_key_exists('ld_contactscf',$tables)){
            $leftjoin .=' left join  ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
        }
    }
    //高级查询可能涉及自定义字段
    if(!array_key_exists('ld_accountscf',$tables)){
        $leftjoin .=' left join  ld_accountscf on ld_account.accountid=ld_accountscf.accountid ';
    }
    //edit:duan reason:群发短信，选择联系人全选所有单据时没有带出高级查询条件
    if(isset($_SESSION['PopupViewSearch']['ServiceCharge']['input'])){
        $input = $_SESSION['PopupViewSearch']['ServiceCharge']['input'];
    }else{
        $input = $_REQUEST;
    }
    
    $tm_where=getSelectQuery($input,'ServiceCharge','where');
    $sql=' select ld_account.accountname,'.implode(',',$columns_all). $contactcolumn.$leftjoin.$tm_where;
}
else
    $sql=' select ld_account.accountname,'.implode(',',$columns_all). $contactcolumn.$leftjoin.' where ld_account.deleted=0 and ld_account.accountid in( '.$accountid.")";

$result=$adb->pquery($sql,array());

$num_rows=$adb->num_rows($result);
$accepter = '';
$showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'ServiceCharge',SHOW_LISTVIEW);
for($i=0;$i<$num_rows;$i++)
{
    $record=$adb->query_result($result,$i,'accountid');
    $showfieldvalueobj->setRecorId($record);
    foreach($columns as $columnname)
    {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                 $mobile= $adb->query_result($result,$i,$columnname);
                 
                 $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,$mobile,$mobile);
                 if($fieldinfo->getTableName()=='ld_contactscf'||$fieldinfo->getTableName()=='ld_contactdetails')
                    $subject=$adb->query_result($result,$i,'lastname');
                 else
                    $subject=$adb->query_result($result,$i,'accountname');
                 
                 if($mobile!=''&&!array_key_exists($mobile,$mobiles))
                 {
                   
                     if(preg_match(globalStatic::$reg_mobile_digit,$mobile))
                     {
                        $mobiles[$mobile]=$showvalue['value'];
                         $accepter .=$mobiles[$mobile].'<'.$subject.'>'."\r\n";  
                         $hiddenaccepter .=base64_encode($mobile)."\r\n";
                     }
                     
                 }     
    }
}

//chj 2021/1/5 44066: 子淇软件（没有外网）短信群发模块>选择"联系人"/"客户档案"后，确认按钮点击异常，无响应。（切换浏览器无法解决）
//echo "#####SUCCESS#####".$accepter."#####SUCCESS#####".$hiddenaccepter;
//exit();
$_REQUEST['diony']='diony';
$arr['content']=$accepter;
ConvertTojsonString(1,$arr,"success");
?>