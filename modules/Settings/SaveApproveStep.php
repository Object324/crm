<?php
/**************************************************************
**edit:kevin
**date:2013-08-16
**reason:保存流程步骤
**************************************************************/

global $adb;
$date=DateOperation::addDays(date("Y-m-d"),"-1");

$sql='select GROUP_CONCAT(id) from ld_approvestep  where approveid  not in(select id from ld_approve )
and createdtime< ?';
$result=$adb->pquery($sql,array($date));
if($adb->num_rows($result))
{
    //删除一天前没有用的审批步骤数据
    $delstepids=$adb->query_result($result,0,0);
    if (!empty($delstepids)){
        $adb->pquery("delete from ld_approvestep where id in( ".$delstepids.")");
        $adb->pquery("delete from ld_approvestepadvfilter where stepid in( ".$delstepids.")");
        $adb->pquery("delete from ld_approvestepadvfilter_grouping where stepid in( ".$delstepids.")");
    }
}

if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];//审批流程iD
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
$stepname=$_REQUEST['stepname'];
$ended=$_REQUEST['ended'];
$step=$_REQUEST['step'];

$approveobj=new Approve();
$approveresult=$approveobj->approveUsed($record,$blockid); 

if($approveresult==1 || $approveresult==5){
        
        //审批流程管理>>审批步骤界面：若该审批流程正在使用时，审批通知和高级功能页签中的操作应该可以修改使用不受限制，并去掉这两个页签后面的红色说明
     //   $_REQUEST['diony']='diony';
        
     //  $arr=array();
      //  ConvertTojsonString(-1,$arr,"used");
      $isused = 'yes';
}else{
    $isused = 'no';
}
$description=$_REQUEST['description'];
$approve_type=$_REQUEST['approve_type'];
$advft_criteria=$_REQUEST['advft_criteria'];
$advft_criteria = $_REQUEST['advft_criteria'];
$advft_criteria = Zend_Json::decode($advft_criteria);
$advft_criteria_groups = $_REQUEST['advft_criteria_groups'];

$advft_criteria_groups = Zend_Json::decode($advft_criteria_groups);
$selectapproveuser=$_REQUEST['selectapproveuser'];
    //20995: 控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后，下一步审批控制区块中没有显示参数“是否允许指定下一步处理人”
//说明	控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后
    /*if($approve_type!=0){
        $selectapproveuser=1;
    }*/
    
switch($approve_type){
    case 0:
    $approve_value=$_REQUEST['userid'];
    //$selectapproveuser=$_REQUEST['selectapproveuser'];
    break;    
    case 1:
    $approve_value=$_REQUEST['user_role'];
    break;
    case 2:
    $approve_value=$_REQUEST['position'];
    break;
    case 3:
    $approve_value=$_REQUEST['positionlevel'];
    break;
    case 4:
        $positiondepartment1 = $_REQUEST['positiondepartment1'];
        $positiondepartment2 = $_REQUEST['positiondepartment2'];
        $approve_value = $positiondepartment1.'::'.$positiondepartment2;
    break;
}
$pass_value=$_REQUEST['passvalue'];
$nopass_value=$_REQUEST['nopassvalue'];
/*
 * editor:gyq_05
 * */
$before = $_REQUEST['before_approve_arr'];
$after = $_REQUEST['after_approve_arr'];
$refuse = $_REQUEST['refuse_approve_arr'];
$alloweditbill=$_REQUEST['alloweditbill'];
$approveremarkrequire=$_REQUEST['approveremarkrequire'];//审批意见是否必填
$countersigner=$_REQUEST['countersigner'];//是否会签（yes ,no)
$augmentsinger=$_REQUEST['augmentsinger'];//是否加签（yes,no）
$module_field = $_REQUEST['approve_module_field'];	//审批必填字段
$emptyapproverdeal = $_REQUEST['emptyapproverdeal'];//审批人为空时处理方式

if(isset($_REQUEST['stepid']) && $_REQUEST['stepid']>0){
    //编辑审批步骤
    $stepid=$_REQUEST['stepid'];
    //duan 2022-4-12 因为使用中的审批步骤也可编辑，为了便于检查问题，则增加审批步骤修改日志,存储修改前的设置信息
    //duan 对比新旧的审批步骤信息判断是否需要更新单据
    $new_stepinfo = array('approve_value'=>$approve_value,'approve_type'=>$approve_type,'countersigner'=>$countersigner,
                        'advft_criteria'=>$advft_criteria,'advft_criteria_groups'=>$advft_criteria_groups);
    $arr['updaterecord'] = SaveApprovestepLog($stepid,$new_stepinfo,$isused);
    
    $approve=new Approve();
    $approveresult=$approve->approveUsed($record,$blockid);
//    if($approveresult==1 || $approveresult==5){
//        //已经使用的审批流程 不能编辑
//    }
//    else
//    {
    $query="update ld_approvestep set name=?,description=?,ended=?,step=?,modifiedtime=?,
    approvetype=?,approvevalue=?,specifyapproverid=? ,alloweditbill=?,approveremarkrequire=?,countersigner=?,augmentsinger=?,module_field=?,emptyapproverdeal=? where id=?";
    $adb->pquery($query,array($stepname,$description,$ended,$step,date('Y-m-d H:i:s'),$approve_type
        ,$approve_value,$selectapproveuser,$alloweditbill,$approveremarkrequire,$countersigner,$augmentsinger,$module_field,$emptyapproverdeal,$stepid));
       
    //}
    
     $passpickcolumnname=$_REQUEST['pass'];
     $nopasspickcolumnname=$_REQUEST['nopass'];
    /*
    *更新操作
    *edit:diony
    *time:2013-12-10
    *reson:0005988: 控制面板->审批流程管理，新增审批步骤时，“高级选项”中审批状态无法保存
    */
    $query="select * from ld_approvestepdetails where stepid=?";       
    $result = $adb->pquery($query,array($stepid));
    $num_rows=$adb->num_rows($result);
    if($num_rows)
    {
        $query="update ld_approvestepdetails set modulestatus=?,pickcolumnname=? where stepid=? and pass=0";
        $adb->pquery($query,array($pass_value,$passpickcolumnname,$stepid));
        $query="update ld_approvestepdetails set modulestatus=?,pickcolumnname=? where stepid=? and pass=1";
        $adb->pquery($query,array($nopass_value,$nopasspickcolumnname,$stepid));           
    }
    else
    {
       
        
        $query="insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname)";
        if($pass_value !='')
        {
            $query .=" value($stepid,0,'$pass_value','$passpickcolumnname')";
        }
        else
        {
            $query .=" value($stepid,0,null,null)";
        }
        $adb->query($query);
        $query="insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname)";
        if($nopass_value !='')
        {
            $query .=" value($stepid,1,'$nopass_value','$nopasspickcolumnname')";
        }
        else
        {
            $query .=" value($stepid,1,null,null)";
        }   
        $adb->query($query);
    }

    
    
    
} else{
    $stepid=$adb->getUniqueID('ld_approvestep');
    if(!empty($record))
    {
        $query="select max(sequence) as sequence from ld_approvestep where approveid=$record";
        $result=$adb->query($query);
        if($adb->num_rows($result))
        $sequence=floor($adb->query_result($result,0,'sequence'))+1;
        else
        $sequence=1; 
    } 
    else
    {
        $record=$adb->getUniqueID('ld_approve');
        $sequence=1; 
        
    }
    $concurrentstepid=$_REQUEST['concurrentstepid'];
  
    $concurrentid=0;
    if($concurrentstepid>0)
    {
        $sql='select concurrentid,sequence from ld_approvestep  where id=? order by sequence asc  ';
        $result=$adb->pquery($sql,array($concurrentstepid));
        $tmprows=$adb->num_rows($result);
       
        if($adb->num_rows($result)>0)
        {
            $sequence=floor($adb->query_result($result,0,'sequence'));
            $concurrentid=$adb->query_result($result,0,'concurrentid');
            
        }
      
        if(empty($concurrentid))
        {
            $sql='select max(concurrentid) as concurrentid from ld_approvestep   ';
            $result=$adb->pquery($sql,array());
            
            $concurrentid=$adb->query_result($result,0,'concurrentid');
            $concurrentid+=1;
           
            //ended:是否允许结束审批流程
            //step:指定审批步骤
            $sql='update ld_approvestep set concurrentid=?,ended=1,step=1 where id=? ';
            $adb->pquery($sql,array($concurrentid,$concurrentstepid));
        }
        else{
            //获取该并发步骤有几个步骤
            $sql='select concurrentid from ld_approvestep  where concurrentid=?  ';
            $tmpresult=$adb->pquery($sql,array($concurrentid));
            $tmprows=$adb->num_rows($tmpresult);
        }
       
        $tmpsequence=$tmprows*Approve_Concurrent_Stepseq+$sequence;
        $sequence=$tmpsequence;
        
        $ended=1;
        $step=1;
    }
    $query="insert into ld_approvestep(id,alloweditbill,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid,countersigner,augmentsinger,module_field,concurrentid,approveremarkrequire,emptyapproverdeal)";
    $query .=" value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
   // echo $query."<br>".$selectapproveuser;die();
    $result=$adb->pquery($query,array($stepid,$alloweditbill,$record,$stepname,$description,$ended,$step,$sequence,date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),$approve_type,$approve_value,$selectapproveuser,$countersigner,$augmentsinger,$module_field,$concurrentid,$approveremarkrequire,$emptyapproverdeal));
    
     $passpickcolumnname=$_REQUEST['pass'];
     $nopasspickcolumnname=$_REQUEST['nopass'];
    $query="insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname)";
        if($pass_value !='')
        {
            $query .=" value($stepid,0,'$pass_value','$passpickcolumnname')";
        }
        else
        {
            $query .=" value($stepid,0,null,null)";
        }
        $adb->query($query);
        $query="insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname)";
        if($nopass_value !='')
        {
            $query .=" value($stepid,1,'$nopass_value','$nopasspickcolumnname')";
        }
        else
        {
            $query .=" value($stepid,1,null,null)";
        }   
        $adb->query($query);

    /*
     * editor : gyq_05
     * reason : 0 前  1 通过  2 拒绝,依次保存审批通知提醒
     * */
   

}

    //允许指定审批步骤
    $sql='select * from ld_approvestep  where approveid=? and id=?';
    $result=$adb->pquery($sql,array($record,$stepid));
    $sequence=$adb->query_result($result,0,'sequence');
    $concurrentid=$adb->query_result($result,0,'concurrentid');
     $tmpsequence=intval($sequence);
    if($concurrentid>0)
    {
        //如果当前步骤是并发步骤，则修改并发步骤的上一步
       
        $sql='select * from ld_approvestep  where approveid=? and  sequence<?  order by sequence desc limit 1';
        $result=$adb->pquery($sql,array($record,$tmpsequence));
        $id=$adb->query_result($result,0,0);
        $sql='update ld_approvestep set step=1 where id=?';
        $adb->pquery($sql,array($id));
    }
    else if($step==0)
    {
       
        //如果当前步骤允许指定审批步骤
        $tmpsequence+=1;
         $sql='select * from ld_approvestep  where approveid=? and  sequence>=?  order by sequence asc limit 1';
        $result=$adb->pquery($sql,array($record,$tmpsequence));
        $concurrentid=$adb->query_result($result,0,'concurrentid');
        if($concurrentid>0)
        {
            //如果下一步是并发步骤
            $id=$adb->query_result($result,0,0);
            $sql='update ld_approvestep set step=1 where id=?';
            $adb->pquery($sql,array($stepid));
        }
    }

//duan 20230714 审批必填字段区分'通过'和不通过,保存必填字段的信息
$mandatoryfield_json = $_REQUEST['mandatoryfield'];
crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
cls_ApproveMandatoryField::saveMandatoryField($stepid,$mandatoryfield_json);
 
saveApproveReminds($before,$stepid,0);

//保存高级查询
//正在使用的流程不能编辑查询条件
//if($approveresult==1||$approveresult==5)
//{
//    $advft_criteria="";
//    $advft_criteria_groups="";
//    
//}
//else

$modulename=getTabname($_REQUEST['blockid']);
$focus = CRMEntity::getInstance($modulename);
$moduleFields = $focus->fieldobj->getModuleFields();
//duan 2022-4-13 正在使用的流程允许编辑查询条件
if(true)
{
    $deletesql = "DELETE FROM ld_approvestepadvfilter WHERE stepid = ?";
    $deleteresult = $adb->pquery($deletesql, array($stepid));
    
    $deletesql = "DELETE FROM ld_approvestepadvfilter_grouping WHERE stepid = ?";
    $deleteresult = $adb->pquery($deletesql, array($stepid));
    if(!empty($advft_criteria))
    {
    
    				foreach($advft_criteria as $column_index => $column_condition) 
    				{
    
    							if(empty($column_condition)) continue;
    
    							$adv_filter_column = $column_condition["columnname"];
    							$adv_filter_comparator = $column_condition["comparator"];
    							$adv_filter_value = $column_condition["value"];
    							$adv_filter_column_condition = $column_condition["columncondition"];
    							$adv_filter_groupid = $column_condition["groupid"];
                                if(empty($adv_filter_column))continue;
    							$column_info = explode(":",$adv_filter_column);
    
    							$fieldName = $column_info[2];
    							$fieldObj = $moduleFields[$fieldName];
    							$newModule = explode('_',$column_info[3]);
    							$fieldType = '';
    							if($newModule[0] == $moduleFields)
    							{
    								$fieldType = $fieldObj->getFieldDataType();
    							}
    							else
    							{
    								if($column_info[4] == 'D')
    								{
    									$fieldType == 'date';
    								}
    							}
    							$temp_val = explode(",",$adv_filter_value);
    							if(($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '' )) {
    								$val = Array();
    								for($x=0;$x<count($temp_val);$x++) {
    								
    									if(trim($temp_val[$x]) != '') {
    										$date = new DateTimeField(trim($temp_val[$x]));
    										if($fieldType == 'date') {
    											$val[$x] = DateTimeField::convertToDBFormat(
    													trim($temp_val[$x]));
    										} elseif($fieldType == 'datetime') {
    											$val[$x] = $date->getDBInsertDateTimeValue();
    										} else {
    											$val[$x] = $date->getDBInsertTimeValue();
    										}
    									}
    								}
    								$adv_filter_value = implode(",",$val);
    							}
    							$irelcriteriasql = "INSERT INTO ld_approvestepadvfilter(stepid,columnindex,columnname,comparator,value,groupid,column_condition) values (?,?,?,?,?,?,?)";
    						     
                            	$irelcriteriaresult = $adb->pquery($irelcriteriasql, array($stepid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));
    							// Update the condition expression for the group to which the condition column belongs
    							$groupConditionExpression = '';
    							if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
    								$groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
    							}
    							$groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
    							$advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
    					} 
    }
    
    if(!empty($advft_criteria_groups))
    {
        foreach($advft_criteria_groups as $group_index => $group_condition_info) 
        {
            if(empty($group_condition_info)) continue;
            if(empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria
    
            $irelcriteriagroupsql = "insert into ld_approvestepadvfilter_grouping(groupid,stepid,group_condition,condition_expression) values (?,?,?,?)";
            $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $stepid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
        }
    }
    else{
        if (!empty($group_index)){
            $irelcriteriagroupsql = "insert into ld_approvestepadvfilter_grouping(groupid,stepid,group_condition,condition_expression) values (?,?,?,?)";
            $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, 0, ''));
        }
    }
}

/*
 * editor: gyq_05
 * reason:新增保存审批提醒方法
 * date  :2016 2 26
 * */

function saveApproveReminds($string,$stepid,$sstype){

    global $adb,$global_approvereminds;
    
    $sql='delete from ld_approvereminds where stepid=?';
    $adb->pquery($sql,array($stepid));
    $modulename=getTabname($_REQUEST['blockid']);
   include(globalStatic::$root_directory.'modules/Approve/CommonApproveVar.php');
   $sql='insert into ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle)
                value(?,?,?,?,?,?,?,?)';
 $approvereminds=$global_approvereminds;
  foreach($approvereminds['groups'] as $groupindex=> $groupname)
    {
        $type=$groupindex;
        
        foreach($approvereminds[$groupname]['method'] as $method)
        {
            //提醒方式
            $remindmethod=$method;
            
            if($_REQUEST[$groupname.'_'.$method.'_method']==0||$_REQUEST[$groupname.'_'.$method.'_method']=="")
            {
                //提醒方式没有选中
                continue;
            }
                        
            //提醒人
                             
            foreach($approvereminds[$groupname][$method]['reminduser'] as $usertag)
            {
                if($_REQUEST[$groupname.'_'.$method.'_'.$usertag]==0||$_REQUEST[$groupname.'_'.$method.'_'.$usertag]=='')
                {
                    //提醒人没有选中
                    continue;
                }
                $params=array();
                $params[]=$stepid;
                $params[]=$type;
                $params[]=$remindmethod;
                $remindcontent=$_REQUEST[$groupname.'_'.$method.'_'.$usertag.'_remindcontent'];//提醒内容
                if(empty($remindcontent))
                {
                    $remindcontent=$global_approvereminds[$groupname]['defaultremind'][$usertag];
                    $remindcontent=str_replace('{$MODULE$}',getTranstab($modulename),$remindcontent);
                }
                //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                $remindtitle=$_REQUEST[$groupname.'_'.$method.'_'.$usertag.'_remindtitle'];//提醒标题
                if(($method=='dialog'||$method=='weixin')&&empty($remindtitle))
                {
                    $remindtitle=$global_approvereminds[$groupname]['defaultremindtitle'][$usertag];
                    $remindtitle=str_replace('{$MODULE$}',getTranstab($modulename),$remindtitle);
                }
                $reminduser=$usertag;
                $params[]=$reminduser;
                $params[]=$remindcontent;
                if(in_array($usertag,$approvereminds['reminduser']['chkselect']))
                {
                    if($usertag=='selectuser')//指定用户
                    {
                        $params[]=$_REQUEST[$groupname.'_'.$method.'_'.$usertag.'_hidden'];
                        $params[]="";
                    }
                    else
                    {
                        $params[]="";
                        $params[]=$_REQUEST[$groupname.'_'.$method.'_'.$usertag.'_hidden'];
                    }
                }
                else
                {
                    $params[]="";
                    $params[]="";
                }
                
                $params[]=$remindtitle;
                $adb->pquery($sql,$params);
               
						
            }
          
        }
       
    }
    

}

crm_load_class_file('cls_ApproveStep','modules/Approve');
$select_approve_type = array();
$blockname=getTabname($_REQUEST['blockid']);
$focus=CRMEntity::getInstance($blockname);
$fieldobjs=$focus->fieldobj->getModuleFields();
 foreach($fieldobjs as $fieldname=>$fieldinfo)
 {
	$columnname=$fieldinfo->getColumnName();
	$fieldlabel=$fieldinfo->getFieldLabel();
	$fieldid = $fieldinfo->getFieldid();
	//edit: chj date: 2020/9/24 reason:单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
	if($fieldinfo->getUIType() == 153 || $fieldinfo->getUIType() == 154){
		$select_approve_type[$fieldid] = getFixedLabel('BIll') . $fieldlabel;
	}
 }

$smarty=new lingdangCRM_Smarty();
$smarty->assign("RECORD",$record);
$smarty->assign("BLOCKID",$blockid); 
$smarty->assign('SELECT_APPRIVE_TYPE',$select_approve_type);
$approvestepobj=new cls_ApproveStep($blockname,$record,"");
//获取审批步骤
$smarty->assign('STEP',$approvestepobj->getApproveStepList());
crm_load_class_file('staticProfile.class','modules/Users');
$editprofile = staticProfile::isModuleExistsProfile($blockname,'EditView');
$smarty->assign('editprofile',$editprofile);

$_REQUEST['diony']='diony';
$arr['record']=$record;
$arr['stepid']=$stepid;
$arr['content']=$smarty->fetch("Approve/EditMultiApproveEntries.tpl");
ConvertTojsonString(1,$arr,"success");

// duan 2022-4-12 因为使用中的审批步骤也可编辑，为了便于检查问题，则增加审批步骤修改日志,存储修改前的设置信息
function SaveApprovestepLog($stepid,$new_stepinfo,$isused){
    global $adb,$current_user;
    //将高级查询条件存为一个数组保存为json
    $sql = "select * from ld_approvestepadvfilter where stepid = ? order by columnindex asc";
    $result = $adb->pquery($sql,array($stepid));
    $num_rows = $adb->num_rows($result);
    $advft_criteria = array();
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
             $advft_criteria[] = array('groupid'=>$adb->query_result($result,$i,'groupid'),
                                       'columnname'=>$adb->query_result($result,$i,'columnname'),
                                       'comparator'=>$adb->query_result($result,$i,'comparator'),
                                       'value'=>$adb->query_result($result,$i,'value'),
                                       'columncondition'=>$adb->query_result($result,$i,'column_condition'));
        }
        //查询组之间关系
        $sql = "SELECT group_condition,condition_expression from ld_approvestepadvfilter_grouping where stepid = ? ORDER BY groupid asc ";
        $result = $adb->pquery($sql,array($stepid));
        $num_rows = $adb->num_rows($result);
        $advft_criteria_groups = array(null);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                 $advft_criteria_groups[] = array('groupcondition'=>$adb->query_result($result,$i,'group_condition'),
                                           'conditionexpression'=>$adb->query_result($result,$i,'condition_expression'));
            }
        }
        $all_advft_criteria = array('advft_criteria'=>$advft_criteria,'advft_criteria_groups'=>$advft_criteria_groups);
        $all_advft_criteria_json = ldcrm_json_encode($all_advft_criteria);
    }
    
    $sql = "insert into ld_approvestep_settinglog(stepid,changedon,whodid,advft_criteria,alloweditbill,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid,countersigner,augmentsinger,module_field,concurrentid,approveremarkrequire,emptyapproverdeal)
            select ?,now(),?,?,alloweditbill,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid,countersigner,augmentsinger,module_field,concurrentid,approveremarkrequire,emptyapproverdeal from ld_approvestep 
            where ld_approvestep.id = ?";
    $adb->pquery($sql,array($stepid,$current_user->id,$all_advft_criteria_json,$stepid));
    //如果审批步骤未在使用中，不需要进行多余的判断
    if($isused != 'yes'){
        return 'no';
    }
    
    //根据审批人类型，会签审批，筛选条件判断是否需要修改对应单据的审批日志信息
    $sql = 'select approvevalue,approvetype,countersigner from ld_approvestep where id = ? ';
    $result = $adb->pquery($sql,array($stepid));
    $num_rows = $adb->num_rows($result);
    $old_stepinfo = array();
    if($num_rows>0){
        $approve_value = $adb->query_result($result,0,'approvevalue');
        //$old_stepinfo['approve_value'] = $adb->query_result($result,0,'approvevalue');
        $old_stepinfo['approve_type'] = $adb->query_result($result,0,'approvetype');
        $old_stepinfo['countersigner'] = $adb->query_result($result,0,'countersigner');
        foreach($old_stepinfo as $key=>$value){
            if($value != $new_stepinfo[$key]){
                return 'yes';
            }
        }
        //考虑到审批人顺序的问题，需要转换成数组进行判断
        if($approve_value != $new_stepinfo['approve_value']){
            $approve_value_arr = explode(',',$approve_value);
            $new_approve_value_arr = explode(',',$new_stepinfo['approve_value']);
            //由数字组成的数组，直接排序然后遍历判断就可以
            if(sizeof($new_approve_value_arr) == sizeof($approve_value_arr)){
                sort($new_approve_value_arr);
                sort($approve_value_arr);
                foreach($approve_value_arr as $key=>$value){
                    if($new_approve_value_arr[$key]!=$value){
                        return 'yes';
                    }
                }
            }else{
                return 'yes';
            }
        }
        //比较高级查询条件是否变化
        if(!empty($advft_criteria)&&!empty($new_stepinfo['advft_criteria'])){
            $result = CompareAdvft_criteria($all_advft_criteria,$new_stepinfo);
            //如果两个高级查询条件不相同，则需要更新相关单据
            if($result == 'no'){
                return 'yes';
            }
        }
        //如果审批人相关设置没有变更，则不需要更新相关单据
        return 'no';
    }else{
        return 'no';
    }
}

//比较两个高级搜索记录是否相同
function CompareAdvft_criteria($tmp_searchvalue,$searchvalue){
    $advft_criteria = $searchvalue['advft_criteria'];
    $advft_criteria_groups = $searchvalue['advft_criteria_groups'];
    $tmp_advft_criteria = $tmp_searchvalue['advft_criteria'];
    $tmp_advft_criteria_groups = $tmp_searchvalue['advft_criteria_groups'];
    //判断条件数量是否相同
    if(sizeof($advft_criteria)!=sizeof($tmp_advft_criteria) ||sizeof($advft_criteria_groups)!=sizeof($tmp_advft_criteria_groups)){
        return 'no';
    }
    //判断搜索组合之间的关系是否相同
    if(sizeof($advft_criteria_groups)>=2){
        foreach($advft_criteria_groups as $key => $value){
            if($value['groupcondition']!=$tmp_advft_criteria_groups[$key]['groupcondition']){
                return 'no';
            }
        }
    }
    //判断搜索条件是否相同
    foreach($advft_criteria as $key=>$value){
        foreach($value as $tmp_key =>$tmp_value){
            if($tmp_advft_criteria[$key][$tmp_key]!=$tmp_value){
                return 'no';
            }
        }
    }
    return 'yes';
}
?>