<?php
/*********************************************
**edit:kevin
**date:2013-09-11
**reason:审批
*********************************************/
global $adb,$current_user,$modulestatus_now;
//批量操作数上线
$deployarray=getSys_deploy(67);
$batchnum = $deployarray['deploy_value'];
$approve = Approve::getInstance($_REQUEST['fld_module']);

if(!isset($_REQUEST['batckapproved'])){//非批量审批
	//不明白干啥的，没敢删 tujt 2014-12-26
    if($_REQUEST['fld_module']=='Project')
    {
        global $projectstatus_old;
    	$sqlss = "select projectstatus from ld_project where projectid=".$_REQUEST['record'];
    	$paymentstatusrestu = $adb->pquery($sqlss,array());
    	$projectstatus_old = $adb->query_result($paymentstatusrestu,0,'projectstatus');
    }
    $approveid = $_REQUEST['approveid'];
    $approveinfo = $approve->getApproveInfo($approveid);
    $isnewapprove = $approveinfo['isnewapprove'];
    $approveobj = Approve::getInstance($_REQUEST['fld_module'],$isnewapprove);
	//审批

	$approvelog = array();
	$approvelog['crmid'] = $_REQUEST['record'];//数据ID
	$approvelog['approveid'] = $_REQUEST['approveid'];//当前审批步骤ID
	$approvelog['stepid'] = $_REQUEST['stepid'];//当前审批流程ID
	$approvelog['approved_by'] = $current_user->id;//当前审批人
	$approvelog['approveresult'] = $_REQUEST['approvestatus'];//当前审批类型（通过、驳回等）
	$approvelog['description'] = $_REQUEST['description'];//备注
    $approvelog['countersigner']=$_REQUEST['countersigner'];//会签
	$approvelog['augmentsinger']=$_REQUEST['augmentsinger_userid'];//加签



	if(1 == $approvelog['approveresult'] || $approvelog['approveresult'] == 6) //下一步审批步骤
		$approvelog['nextstepid'] = $_REQUEST['nextstep_0'];

    //审批前保存必填字段值
    if($_REQUEST['savefieldvalue']=='yes'){
        //保存字段对应的值
        crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
        $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($_REQUEST['fld_module']);
        //保存前判断是否有布局规则的必填字段判断
        $mandatoryfieldobj->setRequestColumn($_REQUEST['fieldvaluejson']);

        $error = $mandatoryfieldobj->JudgeRequiredFieldRule($_REQUEST['record']);

        if($error == 'yes'){
            ConvertTojsonString(-1, ['info'=>'fieldrule','stepid'=>$approvelog['stepid']], getFixedLabel('APPROVEFIELDRULEREMIND'));
        }

        $result_arr = $mandatoryfieldobj->saveFieldValue($_REQUEST['record'],$_REQUEST['fieldvaluejson']);

        //判断是否需要重新生产审批人 会签和加签不需要考虑重新获取审批人的问题
        if($approvelog['approveresult']==1 && $approvelog['stepid'] != $approvelog['nextstepid']){
            //获取审批必填字段编辑的字段内容
            $focus = CRMEntity::getInstance($_REQUEST['fld_module']);
            $request_value = $_REQUEST['fieldvaluejson'];
            $request_column = ldcrm_json_decode(urldecode($request_value));
            $fieldobj = $focus->fieldobj;
            $fieldid_arr = [];
            foreach ($request_column as $tmp_fieldname=>$tmp_value){
                $tmp_fieldid = $fieldobj->getFieldInfoBykeyValue('fieldname',$tmp_fieldname,'fieldid');
                if($tmp_fieldid >0){
                    $fieldid_arr[] = $tmp_fieldid;
                }
            }
            $reset_approver = 'no';
            if($isnewapprove == 'yes' ){
                //保存后判断需要流转的节点是否发生变化
                $nextstepinfo = $approveobj->getnextstepinfo($flowstepid,$approvelog['stepid'],$approveid,$approvelog['crmid']);

                if($nextstepinfo['nextstepid'] <0){
                    $approvelog['nextstepid'] = '';
                    $approvelog['approveresult'] = 2;
                }else{
                    //如果审批的流转节点发生变化
                    if($nextstepinfo['nextstepid'] != $approvelog['nextstepid']){
                        $approvelog['nextstepid'] = $nextstepinfo['nextstepid'];
                        $reset_approver = 'yes';
                    }
                    $next_stepinfo = $approveobj->getStepInfo($approvelog['nextstepid']);
                    $approvevalue = $next_stepinfo['approvevalue'];//下一步审批人
                    $approvetype =$next_stepinfo['approvetype'];//下一步审批人类型（指定用户，指定角色，部门等待)
                    $emptyapproverdeal=$next_stepinfo['emptyapproverdeal'];
                    //如果审批人是根据字段获取的,且编辑的字段中包含该字段，则在保存后重新获取一次审批人
                    if($approvetype > 6 && in_array($approvetype,$fieldid_arr)){
                        $reset_approver = 'yes';
                    }
                }
            }else{
                $next_stepinfo = $approveobj->getStepInfo($approvelog['nextstepid']);
                $approvevalue = $next_stepinfo['approvevalue'];//下一步审批人
                $approvetype =$next_stepinfo['approvetype'];//下一步审批人类型（指定用户，指定角色，部门等待)
                $emptyapproverdeal=$next_stepinfo['emptyapproverdeal'];
                //如果审批人是根据字段获取的,且编辑的字段中包含该字段，则在保存后重新获取一次审批人
                if($approvetype > 6 && in_array($approvetype,$fieldid_arr)){
                    $reset_approver = 'yes';
                }
            }
            if($reset_approver == 'yes'){
                $_REQUEST['userid_0'] = $approveobj->getApproveBy($approvetype,$approvevalue,$approvelog['crmid'],$emptyapproverdeal);
            }
        }
    }
    
     
	//修改操作，by andrew,修正费用报销审批状态不正确，添加break,20140102
	if(!empty($_REQUEST['userid_0']) && !empty($approvelog['nextstepid'])){//指定下一步审批人
		$userids = $_REQUEST['userid_0'];//查询是否有审批委托
		$query = 'select distinct case when approvestatus=0 then approveby else id end as userid 
					from ld_users where id in ('.$userids.') order by userid;';
        $result = $adb->pquery($query,array());
        $num_rows=$adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $approveby .= $adb->query_result($result,$i,'userid').",";
        }
		$approveby = trim($approveby,',');
		$approvelog['nextstepapproveby'] = $approveby;
	}
	if(6 == $approvelog['approveresult']){ //加签
		$approvelog['nextstepid'] = $approvelog['stepid'];
		//会签中加签
		if($_REQUEST['counter_augmentsinger'] == 'yes' && !empty($_REQUEST['cur_nextstepby'])){
			$approvelog['nextstepapproveby'] = $_REQUEST['cur_nextstepby'] . ','.$approvelog['augmentsinger'];
		}else{
			$approvelog['nextstepapproveby'] = $approvelog['augmentsinger'];
		}
		$approvelog['augmentsinger'] = $_REQUEST['augmentsinger'];
		$approvelog['countersigner'] = $approvelog['augmentsinger'];
	}
	else{
		$approvelog['augmentsinger'] = $_REQUEST['augmentsinger'];
	}
   
	//不通过，返回到上一步
	if($_REQUEST['approvestatus'] == 5){
		
	   /*	$query="select  ld_approvelog.approveid,stepid,nextstepid,nextstepapproveby,approveresult,approved_by ,approvevalue,approvetype,ld_approvelog.countersigner,ld_approvelog.augmentsinger
				FROM ld_approvelog
				LEFT JOIN ld_approvestep on ld_approvestep.id = ld_approvelog.stepid 
				WHERE ld_approvelog.crmid = ?  and  ld_approvelog.id > 0  and ld_approvelog.approved_by>0 
				and ld_approvelog.id <=(select id from ld_approvelog where crmid=? and nextstepid=? 
				and stepid>0 and approveresult<>5
					ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc limit 1)
				 ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc";
              
        $result = $adb->pquery($query,array($_REQUEST['record'],$_REQUEST['record'],$_REQUEST['stepid']));*/
        //edit:can 2021-01-12 44192: （企业微信移动端-kfbcrm）加签审批；待审批-销售机会，单据编号 POT70 ；流程“销售机会加签；加签人驳回至上一步后，当前步骤也操作驳回，但无法驳回成功
		/* chj 2021/7/1 approved_by != -1
		* approved_by != -1     
		* 问题：不满足条件条过后，直接返回上一步，上一步操作步骤不对。  因为并发跳过返回时，approved_by为0，所以这里先加-1判断
		*/
        $query='select stepid,nextstepid,nextstepapproveby ,approveresult
        ,approved_by,ld_approvelog.countersigner,ld_approvelog.augmentsinger from ld_approvelog where crmid=? and approved_by != -1 
        ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc ';
        $result=$adb->pquery($query,array($_REQUEST['record']));
        
    	$tmprowindex=$approveobj->getBackStepLogIndex($result);
        
        $approvelog['nextstepid'] = $adb->query_result($result,$tmprowindex,'stepid');
        
        if($approvelog['nextstepid']>0)
        {
            $approveid=$_REQUEST['approveid'];
            
            global $approvestepinfo_arr;
            if(!is_array($approvestepinfo_arr))
            {
                $approvestepinfo_arr=[];
            }
            $approvestepinfo_arr[$approveid]= $approveobj->getAllStepInfoByApproveid($approveid);
            $tmprows=sizeof($approvestepinfo_arr[$approveid]);
            
            $concurrentidStepCount=0;
            for($i=0;$i<$tmprows;$i++)
            {
                if($approvestepinfo_arr[$approveid][$i]['stepid']==$approvelog['nextstepid'])
                {
                    $tmpconcurrentid=$approvestepinfo_arr[$approveid][$i]['concurrentid'];
                    break;
                }
            }
            for($i=0;$i<$tmprows;$i++)
            {
            
                if(empty($tmpconcurrentid))
                {
                break;
                }
                    
                
                if($tmpconcurrentid>0&&$approvestepinfo_arr[$approveid][$i]['concurrentid']==$tmpconcurrentid)
                {
                    $_REQUEST['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];
                   
                    $_REQUEST['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
                    $_REQUEST["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
                    $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
                    $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');
                    
                    $_REQUEST["userid_$concurrentidStepCount"]=$approveobj->getApproveBy($approvetype,$approvevalue,$record);
                    $_REQUEST["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
                    $concurrentidStepCount++;
                }
            }
            
            $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
        }
          
		$nextsetpby =$adb->query_result($result,$tmprowindex,'approved_by'); 
		$augmentsinger = $adb->query_result($result,$tmprowindex,'augmentsinger');
		
       
		$approvelog['approved_by'] =  $current_user->id;
		$approvelog['nextstepapproveby'] = $nextsetpby;
		$approvelog['augmentsinger'] = $augmentsinger;
            
		$approvelog['stepid'] = $_REQUEST['stepid'];	//上一步审批步骤id
		$approvelog['approvedeal'] = 'backlaststep';
        
	}
    $issave='yes';
    
    if($_REQUEST['approvestatus']==1||$_REQUEST['approvestatus']==2)
    {
        //$_REQUEST['approvestatus']:审批成功 2
        //$_REQUEST['approvestatus']:通过继续下一步 1
        $lastapproveinfo=$approveobj->getlastapproveinfo($record,$_REQUEST['fld_module']);
      
        if($lastapproveinfo['approveresult']==2) {
            //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
            $issave='no';//已经审批
        
        }else if($lastapproveinfo['approveresult']==4&&$lastapproveinfo['stepid']=='-2') {
            $issave='no';//已经回撤
            
        } else if($lastapproveinfo['approveresult']==1) {
            $lastcreatedtime=$lastapproveinfo['createdtime'];
            $seconds= DateOperation::sencods_between_time(date("Y-m-d H:i:s"),$lastcreatedtime);
            //审批中
            //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
            //abs($seconds)<=10&&
            if( $lastapproveinfo['stepid']==$_REQUEST['stepid']&&$approveinfo['approved_by']==$current_user->id) {
                $issave='no';
                
            }
        }
    }
    
    $approvelog['logconcurrentid']=$_REQUEST['logconcurrentid'];//审批历史并发步骤id
    $approvelog['approvelogid']=$_REQUEST['approvelogid'];//审批历史中主键ID
   
    if($issave=='yes') {
        $stepinfo = $approveobj->SaveApprovedLog($_REQUEST['fld_module'], $approvelog);
        /**
         * 如果result_aprove_step=1，添加result_aprove=1参数，点击返回列表按钮依然会返回到审批中心模块
         * @reason 0009141 审批完成后，点击返回列表按钮，建议返回到我的审批中心
         * @author Tujt 2014-05-27
         */
        $url = '';
        if (isset($_REQUEST['result_aprove_step']) && $_REQUEST['result_aprove_step'] == 1) {
            $url = '&result_aprove=1';
        }
        /**
         * edit:kevin
         * date:2013-10-14
         * reason:5244
         */
        $fld_module = $_REQUEST['fld_module'];
        $returnmodule = $_REQUEST['returnmodule'];
        if ($returnmodule == '')
            $returnmodule = $fld_module;
        $_REQUEST['diony'] = 'diony';
        $arr['refreshdetailmodules'] = array($returnmodule);

        //liushuai  20230803 XUQIU1001688 工作流程定制->调用 API 功能优化(提交审批弹窗)
        if (isset($stepinfo['workflow'])) {
            //检查是否有API调用
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');
            $workflowreverseobj = cls_savereverse::getInstance($fld_module);
            $receive_msg = $workflowreverseobj->checkCallApiPop();
            $arr['workflow']['receive_msg'] = $receive_msg;
            if ($receive_msg == 'yes') {
                $arr['workflow']['record'] = $record;
                $arr['workflow']['module'] = $fld_module;
                $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

                $arr['workflow']['before_save_infos'] = $stepinfo['workflow']['before_save_infos'];
                $arr['workflow']['after_save_infos'] = $stepinfo['workflow']['after_save_infos'];
            }
        }
        ConvertTojsonString(1, $arr, "success");
    }
}else{//批量审批
    $description = Input('description');
    $approvedtype = $_REQUEST['approvedtype'];
    global $current_user;

    $startrow = $_REQUEST['startrow'];
    $endrow = $_REQUEST['endrow'];
    if(!isset($_REQUEST['endrow']) || $endrow > $_REQUEST['selectlen'])
    {
        $endrow = $_REQUEST['selectlen'];
    }
    if($startrow == 0 || !isset($_REQUEST['startrow']))
    {
        $startrow=0;
        unset($_SESSION[$current_user->id.'_Approve_batchapproved']);
    }

    if(isset($_SESSION[$current_user->id.'_Approve_batchapproved']['selectid']))
    {
        $selectid_arr = $_SESSION[$current_user->id.'_Approve_batchapproved']['selectid']; //待处理的单据id集合
    }else{
        if ('All' == $_REQUEST['selectid']) {//全选
            $fromApproveModule = $_REQUEST['fromapprovemodule'];
            $focus = CRMEntity::getInstance($fromApproveModule);
            crm_load_class_file('cls_Approve_CustomView', 'modules/Approve/ListView');
            $customView = new cls_Approve_CustomView($fromApproveModule);
            crm_load_class_file('cls_Approve_ListView', 'modules/Approve/ListView');
            $queryGenerator = new cls_Approve_ListView();
            $list_query = $queryGenerator->getquery($fromApproveModule, $current_user, $customView);
            $page_list_query = $queryGenerator->getPageListQuery();
            $result = $adb->pquery($page_list_query, array());
            $rows = $adb->num_rows($result);
            $selectid_arr = array();
            for ($i = 0; $i < $rows; ++$i) {
                $crmid = $adb->query_result($result, $i, $focus->table_index);
                $selectid_arr[] = $crmid;
            }

        } else {//非全选
            $selectid = trim($_REQUEST['selectid'], ',');//选中的数据ID
            $selectid_arr = explode(',', $selectid);
        }

        $_SESSION[$current_user->id.'_Approve_batchapproved']['allselectid'] = $selectid_arr;  //所有单据id的集合

//        根据参数上限处理（设置序时簿列表界面批量操作记录条数的上限）
        if(sizeof($selectid_arr)>$batchnum)
        {
            $selectid_arr=array_slice($selectid_arr,0,$batchnum);  //所有待处理的单据集合
        }

        $_SESSION[$current_user->id.'_Approve_batchapproved']['selectid']=$selectid_arr;
    }
    $_REQUEST['approvebatchnum'] = count($_SESSION[$current_user->id.'_Approve_batchapproved']['allselectid']);//审批头显示会用到

    $selectid = implode(',', array_slice($selectid_arr, $startrow, ($endrow-$startrow)));

    if (!empty($selectid)) {
        crm_load_class_file("ApproveCommon","modules/Approve");
        $ApproveCommonObj = ApproveCommon::getInstance($_REQUEST['fromapprovemodule']);
        $res = $ApproveCommonObj->SaveRecordApproveLog($selectid, $approvedtype, $description);
    } else {
        $res = '<div class="pop_prc_content">没有选择的单据</div>';
        
    }

    //@edit:liushuai,2021-03-08,reason:【ID1001390】批量审批增加显示进度条
	$data = array('content'=>$res, 'title'=>getFixedLabel('APPROVE_BATCHAPPROVED'));
    //edit:can 20210603 046152: （81mis.com/kfbcrm）审批中心-项目立项审批；待审批单据审批流都是一样的，批量操作审批，通过/不通过；审批完成后的弹窗错误
    $data['maxrows'] = count($_SESSION[$current_user->id.'_Approve_batchapproved']['selectid']);
    $data['selectrows'] = $_REQUEST['approvebatchnum'];
    $data['correct'] = $_SESSION[$current_user->id . '_Approve_batchapproved']['correct'];
    $data['edit_err'] = $_SESSION[$current_user->id . '_Approve_batchapproved']['edit_err'];
    if($endrow >= count($_SESSION[$current_user->id.'_Approve_batchapproved']['selectid']))
    {
        unset($_SESSION[$current_user->id.'_Approve_batchapproved']);
    }
	//require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($data);
	echo $jsonentity;die;
}

/**
 * 从session中获取列表query信息，去掉limit信息
 * @param String $fld_module 模块名
 * @return 返回模块列表sql（不带limit）
 * @author Tujt 2015-01-07
 */
function getApproveListAllQuery($fld_module,$filter='') {
    $entityarray = getEntitynameInfo(getTabid($fld_module));
  	$tabname = $entityarray['tablename'];
  	$tabindex = $entityarray['entityidfield'];
  	if(empty($tabname)) $tabname = 'ld_'.strtolower($fld_module);
  	if(empty($tabindex)) $tabindex = strtolower($fld_module).'id';
  	$allmodulequery = $_SESSION[$fld_module.'_listquery'];//获取页面sql
  	$allmodulequery = strtolower($allmodulequery);//sql转换成小写，方便处理
  	if(stripos($allmodulequery,'limit') > -1){
  		//2、去除limit分页信息
  		$allmodulequeryarr = explode('limit',$allmodulequery);//取出limit分页
  		$allmodulequeryarr1 = explode(')',$allmodulequeryarr[1]);
  		array_shift($allmodulequeryarr1);//删除第一个元素(分页信息，譬如 0,20)
  		$allmodulequery = $allmodulequeryarr[0].')'.join(')',$allmodulequeryarr1);//将其余的sql重新用)组装一下
  	}
  	if(stripos($allmodulequery,'order by') > -1){
  		$orderbyarr = explode('order by',$allmodulequery);//取出limit分页
  		$allmodulequery = $orderbyarr[0];
  	}
  	//3、添加未提交过滤条件
	$field = '';
	if(!empty($filter)){
		if(isset($filter['where'])){
			$allmodulequery .= ' '.$filter['where'];
		}
		if(isset($filter['field'])){
			$field = ','.$filter['field'];
		}
	}
  	//4、将字段修改为单据ID，同时组装查询总条数sql语句
  	$pos = strpos($allmodulequery,'FROM ')?strpos($allmodulequery,'FROM '):strpos($allmodulequery,'from ');
  	$countquery = 'SELECT count(distinct ld_approvelog.crmid) as count '.substr($allmodulequery, $pos,strlen($allmodulequery));
  	$query = 'SELECT distinct ld_approvelog.crmid as crmid '.$field.' '.substr($allmodulequery, $pos,strlen($allmodulequery));
  	if(isset($orderbyarr[1])){
  		$query .= ' order by '.$orderbyarr[1];
  	}
  	$sql['query'] = $query;
  	$sql['count'] = $countquery;
  	return $sql;
}

