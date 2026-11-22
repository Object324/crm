<?php

global $adb,$current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
	exit('sorry');
}
//审批流程和审批步骤的保存
$approveid=$_REQUEST['approveid'];
$approveinfo_arr=json_decode($_REQUEST['approveinfo'],true);

$tabid=$_REQUEST['tabid'];
if(empty($tabid))
	$tabid=4;
//dump($approveinfo_arr);
$name=$approveinfo_arr['name'];
$description=$approveinfo_arr['description'];
$status=$approveinfo_arr['status'];
$approveallocatetype=$approveinfo_arr['approveallocatetype'];
$approveallocateid=$approveinfo_arr['approveallocateid'];
$allowediting=$approveinfo_arr['allowediting'];
$allowantiapproval=$approveinfo_arr['allowantiapproval'];
$finishedallowedit=$approveinfo_arr['finishedallowedit'];
$default_on_new=$approveinfo_arr['default_on_new'];
$default_on_submit=$approveinfo_arr['default_on_submit'];
$showsubmitremark=$approveinfo_arr['showsubmitremark'];
$submitremarkrequire=$approveinfo_arr['submitremarkrequire'];
$showurgent=$approveinfo_arr['showurgent'];
$allowagainsubmit=$approveinfo_arr['allowagainsubmit'];
$enableexpediting=$approveinfo_arr['enableexpediting'];
$finishedfield_allocatetype=$approveinfo_arr['finishedfield_allocatetype'];
$finishedfield_allocateid=$approveinfo_arr['finishedfield_allocateid'];
$fininsedselectfieldtype=$approveinfo_arr['fininsedselectfieldtype'];
$finishedalloweditchoosefield= ($approveinfo_arr['finishedalloweditchoosefield']);
$editresetapprove= ($approveinfo_arr['editresetapprove']);

$isnewapprove='yes';
$advancesearch=$approveinfo_arr['advancesearch'];
$groupcondition=$approveinfo_arr['groupcondition'];
 
if(empty($approveid)){
    $query="select name from ld_approve where tabid=$tabid and name='$name'";
}
else{
    $query="select name from ld_approve where tabid=$tabid and name='$name' and id!=$approveid";
}


$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$_REQUEST['diony']='yes';
if($num_rows){
	ConvertTojsonString(-1,array(),"流程名称已存在！");
}

if($default_on_new=='yes'){
    $sql = 'update ld_approve set default_on_new=\'no\' where tabid=?';
    $adb->pquery($sql,array($tabid));
}
if ($default_on_submit=='yes'){
    $sql = 'update ld_approve set default_on_submit=\'no\' where tabid=?';
    $adb->pquery($sql,array($tabid));
}
if ($allowagainsubmit=='yes'){
    $sql = 'update ld_approve set allowagainsubmit=\'no\' where tabid=?';
    $adb->pquery($sql,array($tabid));
}
if($finishedallowedit!='yes')
{
    $finishededittype='';
    $selectfinishededitid='';
    $fininsedselectfield='';
}

if(empty($approveid))
{
	$mode='new';
	$wenhao_arr=[];
	for($i=0;$i<=25;$i++)
	{
		$wenhao_arr[]='?';
	}
//weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序） 后台设置--系统定制-审批流程定制
    $sequence = 10000;//设置一个默认值,保证插入数据显示在最后面
    $tmpsql="SELECT MAX(sequence) as sequence FROM ld_approve WHERE tabid=?;";
    $tmpresult = $adb->pquery($tmpsql,array($tabid));//$adb->pquery执行SQL
    if($adb->num_rows($tmpresult)>0){//$adb->num_rows获取SQL结果行数
        $sequence = $adb->query_result($tmpresult,0,0)+1;//$adb->query_result 获取SQL执行结果
    }
	  $approveid=$adb->getUniqueID('ld_approve');
	$sql='insert into ld_approve(id,tabid,name,description,status,smcreatorid,createdtime,modifiedby,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,default_on_new,default_on_submit,showsubmitremark,submitremarkrequire,showurgent,allowagainsubmit,enableexpediting
	,finishedfield_allocatetype,finishedfield_allocateid,isnewapprove,dataadv,dataadvgroup,sequence,editresetapprove)
	value(?,'. implode(",",$wenhao_arr) .') ';
	 $adb->pquery($sql,array($approveid,$tabid,$name,$description,$status,$current_user->id,date("Y-m-d H:i:s"),$current_user->id,date("Y-m-d H:i:s"),$approveallocatetype,$allowediting,$allowantiapproval,$finishedallowedit,$default_on_new,$default_on_submit,$showsubmitremark,$submitremarkrequire,$showurgent,$allowagainsubmit,$enableexpediting,$finishedfield_allocatetype,$finishedfield_allocateid,'yes',$advancesearch,$groupcondition,$sequence,$editresetapprove));
	 
}
else{
	$mode='edit';
	$sql='update ld_approve set name=?,description=?,status=?,modifiedby=?,modifiedtime=?,approveallocatetype=?,allowediting=?,allowantiapproval=?,finishedallowedit=?,default_on_new=?,default_on_submit=?,
	showsubmitremark=?,submitremarkrequire=?,showurgent=?,allowagainsubmit=?,enableexpediting=?,finishedfield_allocatetype=?,finishedfield_allocateid=?,dataadv=?,dataadvgroup=?,editresetapprove=?
	where id=?';
	$adb->pquery($sql,array($name,$description,$status,$current_user->id,date("Y-m-d H:i:s"),$approveallocatetype,$allowediting,$allowantiapproval,$finishedallowedit,$default_on_new,$default_on_submit,$showsubmitremark,$submitremarkrequire,$showurgent,$allowagainsubmit,$enableexpediting,$finishedfield_allocatetype,$finishedfield_allocateid,$advancesearch,$groupcondition,$editresetapprove,$approveid));

	$sql='delete from ld_approve_finishededitfield where approveid=?';
    $adb->pquery($sql,array($approveid));
}


//审批流程适用范围
if($approveallocatetype=='0'){
    if($mode=='edit'){
        $query="delete from ld_approve2user where approveid=?";
        $adb->pquery($query,array($approveid));
    }
    $sql='insert into ld_approve2user(approveid,userid)values(?,?)';
    $adb->pquery($sql,array($approveid,'-1'));

}elseif($approveallocatetype=='1'||$approveallocatetype=='2'||$approveallocatetype=='3'){
    if($mode=='edit'){
        $query="delete from ld_approve2user where approveid=?";
        $adb->pquery($query,array($approveid));

    }
    $owner_arr = explode(",",$approveallocateid);
    foreach($owner_arr as $key=>$allocateid){
        $sql="insert into ld_approve2user(approveid,userid) values(?,?)";
        $adb->pquery($sql,array($approveid,$allocateid));
    }
}

if($finishedallowedit=='yes'&&$fininsedselectfieldtype=='part')
{

	
    foreach($finishedalloweditchoosefield as $tmpindex=>$tmpinfo)
    {
    	 $tmpcolums=$tmpinfo['value'];
        $sql=' insert into ld_approve_finishededitfield(columns,approveid,userid)
        value(?,?,?)';
       $adb->pquery($sql,array($tmpcolums,$approveid,$current_user->id));
   
    }
}


$existstepid_arr=[];
$sequence=1;
if($mode=='edit')
{
	$sql='select group_concat(id) as id from ld_approvestep where approveid=? ';
	$result=$adb->pquery($sql,array($approveid));
	if($adb->num_rows($result)>0)
	{
		$existstepid_arr=explode(",",$adb->query_result($result,0,'id'));

	}
}
$stepid_arr=[];//保存到数据库的stepid
$steplist_arr=json_decode($_REQUEST['stepinfo'],true);


$haveUpdateInsertflowStepId_arr=[];
global $global_approvereminds,$approveremindlabels,$approveremind_email_user,$approveremind_sms_user;
include(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();

insertStep(-1, $steplist_arr, $tabid, $cls_Send_MassSms);//保存步骤
if($mode=='edit')
{
	//删除
	$delstepid_arr= array_diff($existstepid_arr, $stepid_arr);
	if(is_array($delstepid_arr) && sizeof($delstepid_arr)>0)
	{
        $sql='delete ld_smsrelated from ld_smsrelated inner join ld_approvereminds on ld_smsrelated.relatedid = ld_approvereminds.id and ld_smsrelated.relatedtable=? where  ld_approvereminds.stepid in('.implode(",",$delstepid_arr).')';
        $adb->pquery($sql,array('ld_approvereminds'));

		$sql='delete from ld_approvereminds where  stepid in('.implode(",",$delstepid_arr).')';
		$adb->pquery($sql,array());
		$sql='delete from ld_approvestepadvfilter where stepid in('.implode(",",$delstepid_arr).')';
		$adb->pquery($sql,array());
		$sql='delete from ld_approvestepadvfilter_grouping  where stepid in ('.implode(",",$delstepid_arr).')';
		$adb->pquery($sql,array());
		$sql='delete from ld_approvestep where approveid=? and id  in('.implode(",",$delstepid_arr).')';
		$adb->pquery($sql,array($approveid));
	}
	
}

ConvertTojsonString(1,array([$existstepid_arr,$stepid_arr,$delstepid_arr]),'success');

function insertStep($childid, $arry, $tabid, $cls_Send_MassSms)
{
     
	global $global_approvereminds,$approveremindlabels,$approveremind_email_user,$approveremind_sms_user;
	global $stepid_arr,$adb,$current_user,$approveid,$sequence,$haveUpdateInsertflowStepId_arr;
	$childArry = GetChildArry($childid, $arry);
	$module_field='';//必填字段
    
	if(is_array($childArry) && sizeof($childArry)>0)
	{
		$stepmode='create';
      
		foreach($childArry as $info_arr)
		{
			$stepinfo=$info_arr['stepinfo'];
			$stepid=$info_arr['id'];
			$flowstepid=$info_arr['flowstepid'];
		 
			if(in_array($flowstepid,$haveUpdateInsertflowStepId_arr))
			{
				//有共同的子节点
				continue;
			}

			$haveUpdateInsertflowStepId_arr[]=$flowstepid;
		      
			$stepname=$info_arr['stepname'];
			$branchflowstepid=$info_arr['branchstepid'];//分支ID
			$childids=$info_arr['childid'];
				 
			$steptype=$info_arr['steptype'];
			$description=$info_arr['stepinfo']['description'];
			$approvevalue=$info_arr['stepinfo']['approvevalue'];//审批值
			$approvetype=$info_arr['stepinfo']['approvetype'];//审批人类型
			$emptyapproverdeal=$info_arr['stepinfo']['emptyapproverdeal'];//审批人为空
			$countersigner=$info_arr['stepinfo']['countersigner'];//或签/会签
			$alloweditbill=$info_arr['stepinfo']['alloweditbill'];//允许审批人编辑单据
			$ended=$info_arr['stepinfo']['ended'];//允许直接结束审批流程
			$specifyapproverid=$info_arr['stepinfo']['specifyapproverid'];//允许更换本步骤审批人
			$augmentsinger=$info_arr['stepinfo']['augmentsinger'];///加签和 加签类型 空值表示没有加签，no:加签或签
			$step=$info_arr['stepinfo']['step'];//允许指定下一步审批节点
			$approveremarkrequire=$info_arr['stepinfo']['approveremarkrequire'];//审批意见必填
			$writesignrequired=$info_arr['stepinfo']['writesignrequired'];//手写签名必填
			$writesignlogtype=$info_arr['stepinfo']['writesignlogtype'];
			$approverremovetype=$info_arr['stepinfo']['approverremovetype'];//审批人去重，no：表示没有去重
			$approvalauthority=ldcrm_json_encode($info_arr['stepinfo']['approvalauthority']);//审批权限
			if($stepid>0)
			{
				//编辑步骤
				$stepid_arr[]=$stepid;
                
                
                    
				$stepmode='edit';
				if($steptype=='start')
				{
					//开始节点
					$sql='update  ld_approvestep set childids=? where id=? ';
					$adb->pquery($sql,array($childids, $stepid));
				}
				else if($steptype=='condition')
				{
					//查询节点
					$sql='update  ld_approvestep set name=?, childids=?,sequence=?,branchflowstepid=? where id=? ';
					$adb->pquery($sql,array($stepname, $childids,$sequence,$branchflowstepid, $stepid));
					 
						
				}
				else if($steptype=='conditionvirtual')
				{
					//虚拟节点
					$sql='update  ld_approvestep set childids=?,sequence=?,branchflowstepid=? where id=? ';
					$adb->pquery($sql,array($childids,$sequence,$branchflowstepid, $stepid));
				}
				else if($steptype=='approver')
				{
					//审批人选择节点
                    	if($info_arr['stepinfo']['edit']!='yes')
                        {
                            $sql='UPDATE ld_approvestep set name=?,description=?,ended=?,step=?,sequence=?,
									modifiedtime=?,approvetype=?,approvevalue=?,specifyapproverid=?,alloweditbill=?,
									countersigner=?,augmentsinger=?,approveremarkrequire=?,
									emptyapproverdeal=?,childids=?,branchflowstepid=?,
									writesignlogtype=?,writesignrequired=?,approverremovetype=?,approvalauthority=?
									where id=? ';
							$adb->pquery($sql,array($stepname,$description,$ended,$step,$sequence,date("Y-m-d H:i:s"),$approvetype
								,$approvevalue,$specifyapproverid,$alloweditbill,$countersigner,$augmentsinger,$approveremarkrequire,$emptyapproverdeal,$childids
								,$branchflowstepid,$writesignlogtype,$writesignrequired,$approverremovetype,$approvalauthority,$stepid));
                        }
                        else
    				    {
							$sql='UPDATE ld_approvestep set name=?,description=?,ended=?,step=?,sequence=?,
									modifiedtime=?,approvetype=?,approvevalue=?,specifyapproverid=?,alloweditbill=?,
									countersigner=?,augmentsinger=?,module_field=?,approveremarkrequire=?,
									emptyapproverdeal=?,childids=?,branchflowstepid=?,
									writesignlogtype=?,writesignrequired=?,approverremovetype=?,approvalauthority=?
									where id=? ';
        					$adb->pquery($sql,array($stepname,$description,$ended,$step,$sequence,date("Y-m-d H:i:s"),$approvetype
								,$approvevalue,$specifyapproverid,$alloweditbill,$countersigner,$augmentsinger,$module_field,$approveremarkrequire,$emptyapproverdeal,$childids
								,$branchflowstepid,$writesignlogtype,$writesignrequired,$approverremovetype,$approvalauthority,$stepid));

    				    }
				}
				if($info_arr['stepinfo']['edit']!='yes')
                {
                    //如果该审批步骤没有被编辑过就不做保存处理
                    insertStep($info_arr['childid'], $arry, $tabid, $cls_Send_MassSms);
                    continue;
                }

                $sql="delete ld_smsrelated from ld_smsrelated inner join ld_approvereminds on ld_smsrelated.relatedid = ld_approvereminds.id and ld_smsrelated.relatedtable='ld_approvereminds' where  ld_approvereminds.stepid=?";
                $adb->pquery($sql,array($stepid));

				$sql='delete from ld_approvereminds  where stepid=? ';
                $adb->pquery($sql,array($stepid));
                $sql='delete from ld_approvestepdetails where stepid=?';
                $adb->pquery($sql,array($stepid));
                
                
			}
			else{
				
				$stepid=$adb->getUniqueID('ld_approvestep');
				if($steptype=='start')
				{
					//开始节点
					$sql='insert into ld_approvestep(id,approveid,name,sequence,flowstepid,childids,branchflowstepid,isnewstep,steptype)value(?,?,?,?,?,?,?,?,?)';
					$adb->pquery($sql,array($stepid,$approveid,'开始',$sequence,$flowstepid,$childids,$branchflowstepid,'yes',$steptype));
				}
				else if($steptype=='condition')
				{
					//查询节点
					$sql='insert into ld_approvestep(id,approveid,name,sequence,flowstepid,childids,branchflowstepid,isnewstep,steptype)
					value(?,?,?,?,?,?,?,?,?)';
					$adb->pquery($sql,array($stepid,$approveid,$stepname,$sequence,$flowstepid,$childids,$branchflowstepid,'yes',$steptype));
				}
				else if($steptype=='conditionvirtual')
				{
					//虚拟节点
					$sql='insert into ld_approvestep(id,approveid,name,sequence,flowstepid,childids,branchflowstepid,isnewstep,steptype)
					value(?,?,?,?,?,?,?,?,?)';
					$adb->pquery($sql,array($stepid,$approveid,$stepname,$sequence,$flowstepid,$childids,$branchflowstepid,'yes',$steptype));
				}
				else if($steptype=='approver'){
					// 所要插入的字段数组
					$insert_column_arr = array($stepid,$approveid,$stepname,$description,$ended,$step,$sequence,date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),$approvetype,$approvevalue,$specifyapproverid
						,$alloweditbill,$countersigner,$augmentsinger,$module_field,$approveremarkrequire,$emptyapproverdeal,$steptype,'yes',$flowstepid,$childids
						,$branchflowstepid,$writesignlogtype,$writesignrequired,$approverremovetype,$approvalauthority);

					$sql='insert into ld_approvestep(id,approveid,name,description,ended,step,sequence, createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid
							,alloweditbill,countersigner,augmentsinger,module_field,approveremarkrequire,emptyapproverdeal,steptype,isnewstep,flowstepid,childids
							,branchflowstepid,writesignlogtype,writesignrequired,approverremovetype,approvalauthority)
							value('.generateQuestionMarks($insert_column_arr).')';
					$adb->pquery($sql,$insert_column_arr);
					//echo $approveid;
					//dump($adb);
				}
				
				
			}
			if($steptype=='condition')
			{
				$advancesearch_arr=  $info_arr['stepinfo']['advancesearch'] ;

				$advft_criteria_groups= $info_arr['stepinfo']['groupcondition'];
				
				 $deletesql = "DELETE FROM ld_approvestepadvfilter WHERE stepid = ?";
			    $deleteresult = $adb->pquery($deletesql, array($stepid));
			    
			    $deletesql = "DELETE FROM ld_approvestepadvfilter_grouping WHERE stepid = ?";
			    $deleteresult = $adb->pquery($deletesql, array($stepid));

			    if(is_array($advancesearch_arr)&&sizeof($advancesearch_arr)>0)
			    {
			    
			    				foreach($advancesearch_arr as $column_index => $column_condition) 
			    				{
			    
			    							if(empty($column_condition)) continue;
			    							$adv_filter_column = $column_condition["columnname"];
			    							$adv_filter_comparator = $column_condition["comparator"];
			    							$adv_filter_value = $column_condition["value"];
			    							$adv_filter_column_condition = $column_condition["columncondition"];
			    							$adv_filter_groupid = $column_condition["groupid"];
			    							$irelcriteriasql = "INSERT INTO ld_approvestepadvfilter(stepid,columnindex,columnname,comparator,value,groupid,column_condition) values (?,?,?,?,?,?,?)";
			    						     
			                            	$irelcriteriaresult = $adb->pquery($irelcriteriasql, array($stepid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));
			    							
			    							$groupConditionExpression = '';
			    							if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
			    								$groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
			    							}
			    							$groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
			    							$advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
			    					} 
			    }
			    
			    if(is_array($advft_criteria_groups)&&sizeof($advft_criteria_groups)>0)
			    {

			        foreach($advft_criteria_groups as $group_index => $group_condition_info) 
			        {
			            if(empty($group_condition_info)) continue;
			        	 if(empty($group_condition_info["conditionexpression"])) continue; 
			            $irelcriteriagroupsql = "insert into ld_approvestepadvfilter_grouping(groupid,stepid,group_condition,condition_expression) values (?,?,?,?)";
			            $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $stepid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
			        }
			    }
			    else{
			        //$irelcriteriagroupsql = "insert into ld_approvestepadvfilter_grouping(groupid,stepid,group_condition,condition_expression) values (?,?,?,?)";
			        //$irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, 0, ''));
			    }

			}
            else {
                //审批必填
                $module_field=$info_arr['stepinfo']['module_field'];
                if (is_array($module_field) && count($module_field)>0) {
                    $sql='update ld_approvestep set module_field=? where id=? ';
                    $adb->pquery($sql,array(implode(",",$module_field),$stepid));
                }

                //duan 20230714 审批必填字段区分'通过'和不通过,保存必填字段的信息
                $mandatoryfield_json = $info_arr['stepinfo']['mandatoryfield'];
                crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
                cls_ApproveMandatoryField::saveMandatoryField($stepid,$mandatoryfield_json);

                //提醒保存
                $reminddata_arr= $info_arr['stepinfo']['reminddata'];
                if(is_array($reminddata_arr) && sizeof($reminddata_arr)>0)
                {
                
                    foreach($reminddata_arr as $remindtype=> $remindinfo_arr){
                        if(is_array($remindinfo_arr) && sizeof($remindinfo_arr)>0)
                       {
                      
                            $type= array_search($remindtype,$global_approvereminds['groups']);
                            
                            
                            foreach($remindinfo_arr as $remindinfo)
                            {
                                $method=$remindinfo['method'];
                                $reminduser=$remindinfo['users'];
                                $reminduserid=$remindinfo['reminduserid'];
                                $remindcolumnname=$remindinfo['remindcolumnname'];
                                $content=$remindinfo['content'];
                                $title=$remindinfo['title'];
                                $templateid=$remindinfo['templateid'];
                                $templateparamconf=is_array($remindinfo['templateparamconf'])?json_encode($remindinfo['templateparamconf']):$remindinfo['templateparamconf'];
                                $sql='insert into ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle)
                                value(?,?,?,?,?,?,?,?)';
                                
                                $adb->pquery($sql,array($stepid,$type,$method,$reminduser,$content,$reminduserid,$remindcolumnname,$title));
                                if ($method == 'sms' && $cls_Send_MassSms->platform == 'aliyun') {
                                    $cls_Send_MassSms->insertSmsRelated("ld_approvereminds", $adb->getLastInsertID(), getTabModuleName($tabid), $templateid, $templateparamconf, 'approveremind');
                                }



                            }
                            
                       }
                       
                    }
                }
                $fieldvalue_arr=$info_arr['stepinfo']['fieldvalue'];
                if(is_array($fieldvalue_arr) && sizeof($fieldvalue_arr)>0)
                {
                    $sql='select max(approvestepdetailid) as maxid from ld_approvestepdetails';
                    $tmpresult=$adb->pquery($sql,array());
                    $maxdetailid=$adb->query_result($tmpresult,0,'maxid')+1;
                    
                    foreach($fieldvalue_arr as $tmpvalueinfo)
                    {
                        $passtype=$tmpvalueinfo['passtype'];
                        $modulestatus=$tmpvalueinfo['value'];
                        $pickcolumnname=$tmpvalueinfo['columnname'];
                        $sql=' insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname,approvestepdetailid)
                        value(?,?,?,?,?)';
                        $adb->pquery($sql,array($stepid,$passtype,$modulestatus,$pickcolumnname,$maxdetailid));
                        $maxdetailid++;
                    }
                }
            }
			$sequence++;
			insertStep($info_arr['childid'], $arry, $tabid, $cls_Send_MassSms);

		}
	}
}
function GetChildArry ($parentflowstepid, $arry) 
{
        
		$newArry = explode(",",$parentflowstepid);

		$newlen=is_array($newArry)?sizeof($newArry):0;
		$tmparr=[];
		$length=is_array($arry)?sizeof($arry):0;
		for($i=0;$i<$length;$i++){
			
			if(in_array($arry[$i]['flowstepid'],$newArry))
			{
			    
				$tmparr[]=$arry[$i];
		        if($newlen==1)
		        {
		            //只有一个子节点
		            break;
		        }
		        
			 
			}   
		}
		return $tmparr;
} 
  

?>