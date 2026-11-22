<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);


//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(!isset($_REQUEST['record'])){
    die("A record number must be specified to delete the note.");
    }else{
    //附件id
    $record = $_REQUEST['record'];
    //得到附件信息
    $attachmentsforbillssql = "select * from ld_attachmentsforbills where attachmentsid = ".$record;
    $attachmentsforbillsresult = $adb->query($attachmentsforbillssql);
    //得到关联id
    $relationRecord = $adb->query_result($attachmentsforbillsresult,0,'record');
    //得到要删除文件的文件名
    $filename = $adb->query_result($attachmentsforbillsresult,0,'filename');
    //删除单据前删除对应的文件
    $focus->delete_related_attachment($record);
    
	if(!empty($_REQUEST['attach_detailid']) && $_REQUEST['attach_detailid'] > 0){
        //@edit:liushuai,2020-09-18,reason:0042690: (51mis.com.cn/XS/shchaolun/)（客户问题）销售管理-合同订单-点开详情-附件管理；若附件单据有多个附件存在的情况下，进行选择一个附件删除，则全部附件都会删除（需要补丁）
	    //如果只有一个附件则删除ld_attachmentsforbillsdetails和ld_attachmentsforbills，如果多个附件只删除对应的附件记录ld_attachmentsforbillsdetails

        //删除附件明细
		$query = 'select * from ld_attachmentsforbillsdetails where attachmentsid = ?';
		$result = $adb->pquery($query,array($record));
		if($adb->num_rows($result) == 1){
			//执行删除操作
			$sqldelete = "delete from ld_attachmentsforbills where  attachmentsid = ".$record; 
			$deleteresult = $adb->query($sqldelete);
		}
		$sqldetaildelete="delete from ld_attachmentsforbillsdetails where  id = ".$_REQUEST['attach_detailid'];
		$detaildeleteresult = $adb->query($sqldetaildelete);
	}else{
		//执行删除操作
		$sqldelete = "delete from ld_attachmentsforbills where  attachmentsid = ".$record; 
		$deleteresult = $adb->query($sqldelete);
		//删除附件明细
		$sqldetaildelete="delete from ld_attachmentsforbillsdetails where  attachmentsid = ".$record;
		$detaildeleteresult = $adb->query($sqldetaildelete);
	}

    //调用提醒方法
    AddReminds($current_user->last_name.getFixedLabel('DELETEANNEX').$filename,$relationRecord);
    }
    
/*
*更新操作
*edit:diony
*time:2013-12-20
*reson:附件新增保存成功或者删除附件成功后，执行判断：若当前操作人与当前资料的“负责人”不是同一个人，则生成提醒
*/    
function AddReminds($RemindsContent,$relationRecord)
{
    global $adb,$current_user; 
    $record = $relationRecord;
    if($record!='')
    {
       //$smownersql = "select setype from ld_crmentity where crmid = ".$record;
        //$smownerresult = $adb->query($smownersql);
      
        //$setype = $adb->query_result($smownerresult,0,'setype');
		$setype = 'Attachment';
        require_once('modules/'.$setype.'/'.$setype.'.php');
        $relatefocus=new $setype();
        $sql='select smownerid from '.$relatefocus->table_name.' where '.$relatefocus->table_index.'='.$record;
        $smownerresult=$adb->pquery($sql,array());
        if($adb->num_rows($smownerresult)>0)
        {
            $smownerid=$adb->query_result($smownerresult,0,0);
            
        }
        /*Liver 现在权限没有上下级了，所以注销这块代码
        if($smownerid!=$current_user->id)
        {   
            //发送给当前资料负责人
            $focus_rel =CRMEntity::getInstance('Reminds');                    
        	$focus_rel->column_fields['date_time'] = date('Y-m-d H:i');	   
            $focus_rel->column_fields['related_to']=$record;
            $focus_rel->column_fields['reltab']=$setype;
            
            $focus_rel->column_fields['recieverid']=$smownerid;
            
            $focus_rel->column_fields['status_rmd']='未读';
            $focus_rel->column_fields['content']=$RemindsContent;
            $focus_rel->mode="create";
            $focus_rel->save('Reminds');            
            
            //发送给当前资料负责人的上级
            $roleQuery = "select * from ld_user2role where userid =?";
    		$roleResult = $adb->pquery($roleQuery, array($smownerid));
    		$roleid = $adb->query_result($roleResult, 0, 'roleid');  
            $roleDetails=getRoleInformation($roleid);
            $roleInfo=$roleDetails[$roleid];    
            $parentRole=$roleInfo[1];
            $roles=explode('::',$parentRole);                                                          
            $lastRole = $roles[sizeof($roles)-2];          
                 
            $userQuery = "select * from ld_user2role where roleid =?  and userid<>?";
    		$userResult = $adb->pquery($userQuery, array($lastRole,$current_user->id));
    		$user_num_rows=$adb->num_rows($userResult);                               
            if($user_num_rows)
            {
                for($i=0;$i<$user_num_rows-1;$i++)
                {
                    $usersid = $adb->query_result($userResult,$i,'userid');
                    
                    $focus_rel =CRMEntity::getInstance('Reminds');                    
                	$focus_rel->column_fields['date_time'] = date('Y-m-d H:i');	   
                    $focus_rel->column_fields['related_to']=$record;
                    $focus_rel->column_fields['reltab']=$setype;
                    
                    $focus_rel->column_fields['recieverid']=$usersid;
                    
                    $focus_rel->column_fields['status_rmd']='未读';
                    $focus_rel->column_fields['content']=$RemindsContent;
                    $focus_rel->mode="create";
                    $focus_rel->save('Reminds');
                }
            }      
        }
        */
         
    }
}
//$parenttab = getParentTab();
ConvertTojsonString(1,$arr,"success");
echo '##YES##';
?>