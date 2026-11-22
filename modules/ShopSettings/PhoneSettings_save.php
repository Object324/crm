<?php

global $adb,$current_user,$currentModule,$root_directory;
crm_load_class_file('cls_PhoneSettings',"modules/ShopSettings");
$phoneobj = new cls_PhoneSettings();
if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='save'){
    require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
    
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
    }
    $status = $_REQUEST['phone_status'];
    $name = $_REQUEST['phone_name'];
    $phone = $_REQUEST['phone_number'];
    $phoneid = $_REQUEST['recordid'];
    //更新或插入新客服电话
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid']))
    {
        $sql = "update ld_shop_phones set name = ?, status = ?,phone = ? where phoneid = ?";
        $adb->pquery($sql,array($name,$status,$phone,$phoneid));
    }
    else
    {
        $query = "select MAX(phoneseq) as phoneseq from ld_shop_phones";
        $queryresult = $adb->pquery($query,array());
        if($adb->num_rows($queryresult)){
            $phoneseq = $adb->query_result($queryresult,0,'phoneseq');
            $phoneseq = $phoneseq+1;
        }
        else{
            $phoneseq = 1;
        }
        $sql = "insert into ld_shop_phones(name,status,phone,phoneseq) values(?,?,?,?)";
        $adb->pquery($sql,array($name,$status,$phone,$phoneseq));
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='moveup'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
        $phoneseq = $phoneinfo['phoneseq'];

        if($phoneseq<=1){
            ConvertTojsonString(-1,array(),getFixedLabel('MOVEUP').getFixedLabel('CALLACTIONRESULTFAILED'));
            exit();
        }
        $phoneseqprev = $phoneseq-1;
        $sql = "select * from ld_shop_phones where phoneseq = ? limit 1;";
        $result = $adb->pquery($sql,array($phoneseqprev));
        $num = $adb->num_rows($result);
        if($num >0){
            $phoneidprev = $adb->query_result($result,0,'phoneid');
            $adb->pquery("update ld_shop_phones set phoneseq = ? where phoneid = ?",array($phoneseq,$phoneidprev));
        }
        $adb->pquery("update ld_shop_phones set phoneseq = ? where phoneid = ?",array($phoneseqprev,$phoneid));
        //ConvertTojsonString(1,array(),'success');
        //exit();                           
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='movedown'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
        $phoneseq = $phoneinfo['phoneseq'];
        $sql = "select MAX(phoneseq) as maxseq from ld_shop_phones;";
        $result = $adb->pquery($sql,array());
        if($adb->num_rows($result)<=0){
            exit();
        }
        $maxseq = $adb->query_result($result,0,'maxseq');
        if($phoneseq>=$maxseq){
            ConvertTojsonString(-1,array(),getFixedLabel('MOVEDOWN').' '.getFixedLabel('CALLACTIONRESULTFAILED'));
            exit();
        }
        $phoneseqnext = $phoneseq+1;
        $sql = "select * from ld_shop_phones where phoneseq = ? limit 1;";
        $result = $adb->pquery($sql,array($phoneseqnext));
        $num = $adb->num_rows($result);
        if($num >0){
            $phoneidnext = $adb->query_result($result,0,'phoneid');
            $adb->pquery("update ld_shop_phones set phoneseq = ? where phoneid = ?",array($phoneseq,$phoneidnext));
        }
        $adb->pquery("update ld_shop_phones set phoneseq = ? where phoneid = ?",array($phoneseqnext,$phoneid));
        //ConvertTojsonString(1,array(),'success');
        //exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='activate'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
        $status = $phoneinfo['status'];
        //if($status=='yes'){
            //ConvertTojsonString(1,array(),'success');
            //exit();
        //}
        $adb->pquery("update ld_shop_phones set status = ? where phoneid = ?",array('yes',$phoneid));
        //ConvertTojsonString(1,array(),'success');
        //exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='inactivate'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
        $status = $phoneinfo['status'];
        if($status=='no'){
            ConvertTojsonString(1,array(),'success');
            exit();
        }
        $adb->pquery("update ld_shop_phones set status = ? where phoneid = ?",array('no',$phoneid));
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='delete'){
    
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $phoneid = $_REQUEST['recordid'];
        $phoneinfo = $phoneobj->getPhoneinfoById($phoneid);
        if(empty($phoneinfo)){
            ConvertTojsonString(-1,array(),getFixedLabel('RECORDDELETED'));
            exit();
        }
        //删除记录
        $adb->pquery("delete from ld_shop_phones where phoneid = ?",array($phoneid));
        
        //phoneseq重新排序
        $phones_arr = $phoneobj->getAllPhoneinfos();
        foreach($phones_arr as $index=>$phone){
            $adb->pquery("update ld_shop_phones set phoneseq = ? where phoneid = ?",array($index+1,$phone['phoneid']));
        }
        //ConvertTojsonString(1,array(),'success');
        //exit();
    }
}
$allphones=$phoneobj->getAllPhoneinfos();
foreach($allphones as $key=>$phoneinfo)
{
    $phoneid=$phoneinfo['phoneid'];
    $name= $phoneinfo['name'];
    $status= $phoneinfo['status'];
    $phone= $phoneinfo['phone'];
    $phoneseq= $phoneinfo['phoneseq'];
    $list[]=array('phoneid'=>$phoneid,'name'=>$name,'status'=>$status,'phone'=>$phone,'phoneseq'=>$phoneseq);
}
$smarty = new lingdangCRM_Smarty;
$smarty->assign("List",$list);
$arr["content"] = $smarty->fetch("modules/ShopSettings/PhoneSettingsListContent.tpl");
ConvertTojsonString(1,$arr,'success');
exit();
?>