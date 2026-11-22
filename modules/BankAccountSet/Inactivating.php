<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author wangcong 2022-01-12
 */
global $current_user,$currentModule,$adb;
$error = 0;
$success = 0;
$focus = CRMEntity::getInstance($currentModule);
$storearray = getSelectedRecords($_REQUEST,$returnmodule,rtrim($_REQUEST['idlist'],';'),$excludedRecords);
$_REQUEST['diony']='yes';
if(isPermitted('BankAccountSet','Inactivating')!='yes')
{
    
    ConvertTojsonString(-1,array(),'no permit');  
}
if($_REQUEST['mode']=='disable'){
    $message_arr=Array();
    $arr=Array();
    foreach($storearray as $id){
        $time = date('Y-m-d H:i:s',time());
        $sql="select accountname,discontinued from ld_bankaccountset where bankaccountsetid=?";
        $result= $adb->pquery($sql,array($id));
        $accountname = $adb->query_result($result,0,'accountname');
        $discontinued = $adb->query_result($result,0,'discontinued');
        if($discontinued==1){//有效值为1，可以执行更新操作
            $sql="update ld_bankaccountset set discontinued=0 where bankaccountsetid=? and discontinued=1";
            $adb->pquery($sql,array($id));
            $tmp = "<span style='color:green;'>$accountname</span>";
            //$batcherrorlog = "单据[%s]成功！";
            $batcherrorlog =getFixedLabel('DISABLESUCCESSFULLY');
            $message.= sprintf($batcherrorlog,$tmp,$accountname);
            $message.="<br>";
            $success++;
            
            //添加日志
            //记录操作人员
            $add_basic_id = $adb->getUniqueID('ld_modtracker_basic');
            $query_modtracker_basic = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) values (?,?,?,?,?,?);';
            $adb->pquery($query_modtracker_basic,array($add_basic_id,$id,$currentModule,$current_user->id,$time,$status));
            
            //记录字段值变更信息
            $query_modtracker_detail="insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values (?,?,?,?)";
            $adb->pquery($query_modtracker_detail,array($add_basic_id,'discontinued',1,0));

            
        }else{//有效值不为1，不可以执行更新操作
            $tmp = "<span style='color:green;'>$accountname</span>";
            //$batcherrorlog = "单据[%s]失败！";
            $batcherrorlog =getFixedLabel('DISABLEFAILED');
            $message.= sprintf($batcherrorlog,$tmp,$accountname);
            $message.="<br>";
            $error++;
        }
    }
    $storearray = array_filter($storearray);
    $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');  
    $submitlog = sprintf($submitlog,count($storearray),$success,$error);   
    $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
    $message = "<div class='pop_prc_content'>".$message."</div>";//hjz 更改弹窗，添加提示信息。
    $message_arr[]=$submitlog.$message;
    $arr['title'] = getFixedLabel("INACTIVATING");
    $arr['oktext']=getFixedLabel("CONFIRMED");
    $arr['message_arr']=$message_arr;
    ConvertTojsonString(1,$arr,'success');  
       
}


?>