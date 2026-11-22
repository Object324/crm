<?php
	global $current_user;
	global $adb;
    global $global_approvereminds;
    include(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");
	$approveid=$_REQUEST['approveid'];
    $module = $_REQUEST['frommodule'];
if($current_user->getHaveSetProfile("Settings")!="yes")
	{
		exit('sorry');
	}
	//branchstepid 对应的是flowstepid ,变量名称不想修改了
	$stepflow_arr=[];
	$rows=0;
	if(!empty($approveid))
	{
        crm_load_class_file('cls_AdvftOperate','include');
        $AdvftOperateobj = cls_AdvftOperate::getInstance($module);
        $Advftinfo_arr = $AdvftOperateobj->getAdvftinfoByapproveid($approveid);
		//获取审批步骤高级查询条件
        
        crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');

        $sql='select * from ld_approvestep  where approveid=?  order by sequence asc  ';
		$result=$adb->pquery($sql,array($approveid));
		$rows=$adb->num_rows($result);
		$startdata=[];
		for($i=0;$i<$rows;$i++)
		{
			$id=$adb->query_result($result,$i,'id');
			$steptype=$adb->query_result($result,$i,'steptype');
			$stepname=$adb->query_result($result,$i,'name');
			$branchstepid=$adb->query_result($result,$i,'branchflowstepid');
			$flowstepid=$adb->query_result($result,$i,'flowstepid');
			$description=$adb->query_result($result,$i,'description');
			$ended=$adb->query_result($result,$i,'ended');
			$step=$adb->query_result($result,$i,'step');
			$approvetype=$adb->query_result($result,$i,'approvetype');
			$approvevalue=$adb->query_result($result,$i,'approvevalue');
			$specifyapproverid=$adb->query_result($result,$i,'specifyapproverid');
			$alloweditbill=$adb->query_result($result,$i,'alloweditbill');
			$countersigner=$adb->query_result($result,$i,'countersigner');
			$augmentsinger=$adb->query_result($result,$i,'augmentsinger');
			$module_field=$adb->query_result($result,$i,'module_field');
			$approveremarkrequire=$adb->query_result($result,$i,'approveremarkrequire');
			$emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
			$childids=$adb->query_result($result,$i,'childids');
			$writesignlogtype=$adb->query_result($result,$i,'writesignlogtype');
			$writesignrequired=$adb->query_result($result,$i,'writesignrequired');
			$approverremovetype=$adb->query_result($result,$i,'approverremovetype');
			$approvalauthority = ldcrm_json_decode(html_entity_decode($adb->query_result($result,$i,'approvalauthority')));
			if(empty($approverremovetype))
			{
				$approverremovetype='no';
			}
			$stepinfo_arr=[];
			if($steptype=='approver')
			{
				
				$stepinfo_arr=['stepname'=>$stepname,'description'=>$description,'ended'=>$ended,'step'=>$step,'approvetype'=>$approvetype,'approvevalue'=>$approvevalue,'approvevaluename'=>'', 'specifyapproverid'=>$specifyapproverid,'alloweditbill'=>$alloweditbill,'countersigner'=>$countersigner,
				'augmentsinger'=>$augmentsinger,'module_field'=>$module_field,'approveremarkrequire'=>$approveremarkrequire,'emptyapproverdeal'=>$emptyapproverdeal,'emptyapproverdeal_username'=>'', 'writesignlogtype'=>$writesignlogtype,'writesignrequired'=>$writesignrequired,'approverremovetype'=>$approverremovetype];
                //duan 根据审批人类型获取审批人
                $approverinfo = getApproverText($module,$approvetype,$approvevalue);
                
                $stepinfo_arr['approvetype_label'] = $approverinfo['approvetype_label'];
                $stepinfo_arr['approvevalue_label'] = $approverinfo['approvevalue_label'];
                $stepinfo_arr['approvevalue_name'] = $approverinfo['approvevalue_label'];
                // 审批必填
                $mandatoryfield_str = cls_ApproveMandatoryField::getMandatoryField($id);
                $stepinfo_arr['mandatoryfield'] = $mandatoryfield_str;
            }
			else if($steptype=='condition')
			{
				$stepinfo_arr=['stepname'=>$stepname,'advancesearch'=>'','groupcondition'=>''];
                if(isset($Advftinfo_arr[$id])){
                    $advft_criteria = $Advftinfo_arr[$id]['advft_criteria'];
                    $advft_criteria_groups = $Advftinfo_arr[$id]['advft_criteria_groups'];
                    
                    $stepinfo_arr['advftlabel'] = $AdvftOperateobj->TransAdvftTostring($advft_criteria,$advft_criteria_groups);
                    
                }
			}
            $stepinfo_arr = array_map("html_entity_decode",$stepinfo_arr);
            $stepname = html_entity_decode($stepname);

            // 上面的stepinfo经过html_entity_decode，下面的不需要
            if($steptype=='approver'){
                $stepinfo_arr['approvalauthority'] = $approvalauthority;
                // 2024-6-18 xxy 读取到节点中所有信息，复制节点时会用到
                $select_sql_r = "SELECT `type`,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle from ld_approvereminds where stepid=?";
                $select_result_r = $adb->pquery($select_sql_r,array($id));
                $num_rows_r = $adb->num_rows($select_result_r);
                $reminddatas=[];
                if($num_rows_r > 0){
                    for($j=0;$j<$num_rows_r;$j++)
                    {
                        $remindtype = $adb->query_result($select_result_r,$j,'type');
                        $remindmethod = $adb->query_result($select_result_r,$j,'remindmethod');
                        $reminduser = $adb->query_result($select_result_r,$j,'reminduser');
                        $remindcontent = $adb->query_result($select_result_r,$j,'remindcontent');
                        $reminduserid = $adb->query_result($select_result_r,$j,'reminduserid');
                        $remindcolumnname = $adb->query_result($select_result_r,$j,'remindcolumnname');
                        $remindtitle = $adb->query_result($select_result_r,$j,'remindtitle');

                        $groupname = $global_approvereminds['groups'][$remindtype];
                        $reminddatas[$groupname][] = array('method'=>$remindmethod,'users'=>$reminduser
                                            ,'reminduserid'=>$reminduserid,'remindcolumnname'=>$remindcolumnname
                                            ,'content'=>$remindcontent,'title'=>$remindtitle);  
                    }
                    $stepinfo_arr['reminddata'] = $reminddatas;
                }

                $select_sql_d = 'SELECT * from ld_approvestepdetails where stepid=? order by approvestepdetailid asc ';
                $select_result_d = $adb->pquery($select_sql_d,array($id));
                $num_rows_d = $adb->num_rows($select_result_d);
                $fieldvalue_arr=[];
                if($num_rows_d > 0){
                    for($k=0;$k<$num_rows_d;$k++)
                    {
                        $fieldvalue_arr[] = array('passtype'=>$adb->query_result($select_result_d,$k,'pass')
                            ,'value'=>$adb->query_result($select_result_d,$k,'modulestatus')
                            ,'columnname'=>$adb->query_result($select_result_d,$k,'pickcolumnname'));
                            
                    }
                    $stepinfo_arr['fieldvalue'] = $fieldvalue_arr;
                }
            }
            else if($steptype=='condition')
			{
                $stepinfo_arr['advancesearch'] = $advft_criteria;
                $stepinfo_arr['groupcondition'] = $advft_criteria_groups;
            }
			$startdata[]=['id'=>$id,'steptype'=>$steptype,'branchstepid'=>$branchstepid,'flowstepid'=>$flowstepid,'childid'=>$childids,'stepname'=>$stepname,
                            'stepinfo'=>$stepinfo_arr];

		}
	}
	if(empty($approveid)||empty($rows)){
		
		
		//branchstepid 对应的是flowstepid
		$startdata[]=[ 'id'=>"",'childid'=>"1",'steptype'=>'start', 'stepname'=>'开始','branchstepid'=>'-1','flowstepid'=>'-1','stepinfo'=>array()];
		$startdata[]=['id'=>"",  'childid'=>"",'steptype'=>'approver','stepname'=>getFixedLabel("APPROVALSTEP"),'branchstepid'=>"-1",'flowstepid'=>'1','stepinfo'=>array()];

		
	}
	$stepflow_arr=$startdata;	
	$smarty=new lingdangCRM_Smarty();

    $_REQUEST['diony']='yes';
    $chooseapproverlabel=getFixedLabel('Pleasesettheapproversjs');//请选择审批人
    $addconditionlabel=getFixedLabel('addcondition');
    $endworkflowlabel=getFixedLabel('endworkflow');//流程结束

    $arr['label']=['chooseapprover'=>$chooseapproverlabel,'addcondition'=>$addconditionlabel,'endflow'=>$endworkflowlabel];
    $arr['stepflowlist']=$stepflow_arr;
    $arr['content']=$smarty->fetch("Approve/newApproveStepFlow.tpl");

	 

ConvertTojsonString(1,$arr,'success');

function getApproverText($module,$approvetype,$approvevalue){
    global $adb;
    $approvetype_label = '';
    $approvevalue_label = '';
    switch($approvetype){
        case '0':
            $approvetype_label = getFixedLabel('SPECIFYUSER');//指定成员
            $userid_arr=explode(',',$approvevalue);
            $username_arr = array_map("getUserFullName",$userid_arr);
            $approvevalue_label = implode(',',$username_arr);
            
            break;
        case '1':
            $approvetype_label = getFixedLabel('SPECIFYROLE');//指定角色
            $sql = "select GROUP_CONCAT(profilename) as name_str from ld_profile where profileid in ($approvevalue)";
            $result = $adb->pquery($sql,array());
            if($adb->num_rows($result)>0){
                $approvevalue_label = $adb->query_result($result,0,'name_str');
            }
            break;
        case '2':
            $approvetype_label = getFixedLabel('SPECIFYPROMOTERDEP');//单据负责人部门成员的职位级别
            $approvevalue_label = $approvevalue;
            break;
        case '3':
            $approvetype_label = getFixedLabel('LBL_POSITIONLEVEL');//单据负责人直属上级部门成员的职位级别
            $approvevalue_label = $approvevalue;
            break;
        case '4':
            $approvetype_label = getFixedLabel('LBL_POSITIONDEPARTMENT');//指定部门成员的职位级别
            $approvearray = explode('::', $approvevalue);
            $groupid = $approvearray[0];
            $userlevel = $approvearray[1];
            $sql = "SELECT groupname from ld_groups where groupid = ?;";
            $result = $adb->pquery($sql,array($groupid));
            if($adb->num_rows($result)>0){
                $groupname = $adb->query_result($result,0,'groupname');
            }
            $approvevalue_label = $groupname.':'.$userlevel;
            break;
        case '5':
            $approvetype_label = getFixedLabel('DATACREATOR');//单据创建人
            break;
        case '6':
            $approvetype_label = getFixedLabel('DATASSIGNEDTO');//单据负责人
            break;
        default:
            break;
        //审批人字段
        
    }
    if($approvetype >6){
        $foucs = CRMEntity::getInstance($module);
        $fieldinfo = $foucs->fieldobj->getFieldInfoobjBykey('fieldid',$approvetype);
        if(!empty($fieldinfo)){
            $approvetype_label = $fieldinfo->getFieldLabel();
        }
    }
    
    return array('approvetype_label'=>$approvetype_label,'approvevalue_label'=>$approvevalue_label);
}


?>