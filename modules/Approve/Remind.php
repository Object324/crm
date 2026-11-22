<?php
/******************************************
**edit:kevin
**date:2013-09-17
reason:提醒
******************************************/
global $adb;
require_once(globalStatic::$root_directory.'modules/Reminds/Reminds.php');
/**
andrew
20141217
审批完没有提醒
0012957: 订单审批后，负责人收不到审批提醒。
*/
$query="select DISTINCT T1.smownerid,T1.$moduleid as crmid from ld_approvelog left join (select $moduleid,smownerid from $tabname left join ld_crmentity
on $tabname.$moduleid=ld_crmentity.crmid where $tabname.deleted=0 and  approvestatus='".constant('D_A_S_APPROVALOF')."')
 as T1 on ld_approvelog.crmid=T1.$moduleid where crmid=? and T1.$moduleid <>''";
 
$result=$adb->pquery($query,array($record));

$num_rows=$adb->num_rows($result);
$focus = new Reminds();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $smownerid=$adb->query_result($result,$i,'smownerid');
       $crmid=$adb->query_result($result,$i,'crmid');
        $focus->column_fields['related_to']=$crmid;
        $focus->column_fields['reltab']=$_REQUEST['fld_module'];
        $focus->column_fields['is_del_send']=0;
        $focus->column_fields['is_del_rec']=0;
        $focus->column_fields['status_rmd']="未读";
        $focus->column_fields['date_time']=date('Y-m-d H:i:s');
        $focus->column_fields['recieverid']=$smownerid;
        if(!empty($description))
        $description="备注：".$description;
        if($approvestatus==4){
            $focus->column_fields['content']="您提交的单据审批不通过，请修改后重新提交审批！".$description;
        }else if($approvestatus==2){
            $focus->column_fields['content']="您提交的单据已经审核成功！".$description;
        }else if($approvestatus==3){
             $focus->column_fields['content']="您提交的单据审核失败，敬请关注！".$description;
        }else if($approvestatus==-1)
        {//强制返回提交审批
            $focus->column_fields['content']="您提交的单据被强制返回提交审批，敬请关注！".$description;  
        }
		$focus->column_fields['remindstype']='Approve';
        if($approvestatus!=1){            
            $focus->save('Reminds');
        }

    }
}




//insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec)
?>