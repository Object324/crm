<?php
/*
edit:duan
date:2022-4-13
reason:审批设置中相关设置修改后批量更新正在使用当前步骤的客户
*/

global $adb,$current_user;

$arr = array();
if(empty($_REQUEST['start'])){
    $start = 0;
}else{
    $start = $_REQUEST['start'];
}
$interval = 10;//批量操作数
$width = 100;
$arr['width'] = $width;
$arr['title'] = getFixedLabel('UPDATERELATEDRECORDS');
//进度条
$progresshtml='<div id="selectpopup_1">
                  <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0" align="center">
                    <tr>
                      <td style="padding: 10px;">
                        <div style="font-size: 16px;margin-bottom: 10px;color: #868686;text-align: center;" id="dvc" >'.getFixedLabel('UPDATINGRELATEDRECORDS').'</div>
                       
                        <div id="dv"></div>
                        <div class="progress" style="display:block">
                          <div id="dvExportprogress" class="bar">&nbsp;</div>
                        </div>
                         <div style="margin-top:10px;text-align:left" id="dvctimedescription" ></div>
                        <div class="clear"></div>        
                      </td>
                    </tr>   
                  </table>
                </div>
                <div style="height:20px"></div>';
$arr['content']= $progresshtml;

if(isset($_REQUEST['stepid'])&&$_REQUEST['stepid']>0){
    $stepid = $_REQUEST['stepid'];
}else{
    ConvertTojsonString(-1,$arr,'finished');
}
$approve = new Approve();

//筛选出所有需要操作的单据id
if(isset($_REQUEST['id_str'])&&$_REQUEST['id_str']!=''){
    $id_str = $_REQUEST['id_str'];
}else{
    $sql="select concurrentid,approveid,countersigner from ld_approvestep where id=?";
    $result = $adb->pquery($sql,array($stepid));
    $rows = $adb->num_rows($result);
    if($rows > 0){
        for($i=0;$i<$rows;++ $i){
            $approveid = $adb->query_result($result,$i,'approveid');
            $concurrentid = $adb->query_result($result,$i,'concurrentid');
            $nextstep_countersigner = $adb->query_result($result,$i,'countersigner');
        }
    }
    //是否为并发步骤
    $crmid_arr = array();

    if($concurrentid > 0){
        //先获取当前的并发步骤id，在进一步根据stepid筛选
        $sql = "SELECT crmid,logconcurrentid from ld_approvelog 
            INNER JOIN (select max(id) as max_id from ld_approvelog GROUP BY crmid) as tmp on tmp.max_id = ld_approvelog.id
			where ld_approvelog.logconcurrentid >0 and ld_approvelog.approveid = ?";
        $result = $adb->pquery($sql,array($approveid));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $logconcurrentid = $adb->query_result($result,$i,'logconcurrentid');
                if($logconcurrentid >0){
                    $tmp_sql = " SELECT crmid from ld_approvelog where logconcurrentid = ? and nextstepid =? and isfinished = 'no'";
                    $tmp_result = $adb->pquery($tmp_sql,array($logconcurrentid,$stepid));
                    $tmp_rows = $adb->num_rows($tmp_result);
                    for($j = 0;$j<$tmp_rows;$j++){
                        $crmid = $adb->query_result($tmp_result,$j,'crmid');
                        if(!in_array($crmid,$crmid_arr)){
                            $crmid_arr[] = $crmid;
                        }
                    }
                }
            }
        }
    }else{
        $sql = "SELECT crmid from ld_approvelog 
            INNER JOIN (select max(id) as max_id from ld_approvelog GROUP BY crmid) as tmp on tmp.max_id = ld_approvelog.id
			where ld_approvelog.nextstepid =? and approveresult not in (2,4)";
        $result = $adb->pquery($sql,array($stepid));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $crmid = $adb->query_result($result,$i,'crmid');
                if(!in_array($crmid,$crmid_arr)){
                    $crmid_arr[] = $crmid;
                }
            }
        }
    }
    if(sizeof($crmid_arr)>0){
        $id_str = implode(',',$crmid_arr);
    }else{
        ConvertTojsonString(-1,$arr,'finished');
    }
}

$id_arr = explode(',',$id_str);
$max_rows = sizeof($id_arr);

if($max_rows > $start+$interval){
    $tmp_id_arr = array_slice($id_arr,$start,$interval);
    $end = 'no';
    $new_start = $start+$interval;
    $width = ($start+$interval)/$max_rows*100;
}else{
    $tmp_id_arr = array_slice($id_arr,$start,$max_rows-$start);
    $new_start = $max_rows;
    $end = 'yes';
    $width = 100;
}
$tmp_id_str = implode(',',$tmp_id_arr);

$approvestepinfo_arr=array();
$nextapproveinfo = array();
$concurrentstep_arr=array();
$sql = 'SELECT crmid,logconcurrentid,approveid,nextstepapproveby,countersigner,stepid,nextstepid,id from ld_approvelog 
    INNER JOIN (select max(id) as max_id from ld_approvelog GROUP BY crmid) as tmp on tmp.max_id = ld_approvelog.id
    where ld_approvelog.crmid in ('.$tmp_id_str.') ';
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);

//审批步骤设置修改后，重新走当前审批流程
if($num_rows >0){
    for($i=0;$i<$num_rows;$i++){
        $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');//表示是否为并发步骤
        $nextstepid = $adb->query_result($result,$i,'nextstepid');
        $crmid = $adb->query_result($result,$i,'crmid');
        $approveid=$adb->query_result($result,$i,'approveid');
        $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
        $countersigner=$adb->query_result($result,$i,'countersigner');
        $approvelogid = $adb->query_result($result,$i,'id');
        $curstepid = $adb->query_result($result,$i,'stepid');
        $all_crmid[] = $crmid;
        //是并发步骤

        if($logconcurrentid>0)
        {
            $curstepid=$nextstepid;
            //是否为并发步骤的最后一步，yes:是
            $islastconcurrentstep='no';

            $sql = 'select approveid,nextstepapproveby,countersigner,stepid,nextstepid,id from ld_approvelog where logconcurrentid = ?
                and crmid = ? and nextstepid = ? and isfinished = "no" ';
            $tmp_result = $adb->pquery($sql,array($logconcurrentid,$crmid,$stepid));

            $tmp_numrow = $adb->num_rows($result);
            if($tmp_numrow<=0){
                continue;
            }
            $approveid=$adb->query_result($tmp_result,0,'approveid');
            $nextstepapproveby=$adb->query_result($tmp_result,0,'nextstepapproveby');
            $countersigner=$adb->query_result($result,0,'countersigner');
            $approvelogid = $adb->query_result($tmp_result,0,'id');
            $curstepid = $adb->query_result($tmp_result,0,'stepid');

        }
        else{
            if($nextstepid != $stepid){
                continue;
            }
            $islastconcurrentstep='yes';
        }

        $nextstepid = $stepid;
        $approveid = $adb->query_result($result,$i,'approveid');
        $approvelog[$crmid]['islastconcurrentstep']=$islastconcurrentstep;
        //将审批日志保存信息按crmid放入数组中
        $approvelog[$crmid]['crmid'] = $crmid;//数据ID
        $approvelog[$crmid]['approveid'] = $approveid;//当前审批步骤ID
        $approvelog[$crmid]['stepid'] = $curstepid;//当前审批流程ID

        $approvelog[$crmid]['countersigner']=$countersigner;
        $approvelog[$crmid]['nextstep_countersigner']=$nextstep_countersigner;
        $approvelog[$crmid]['cur_stepapproveby']=$nextstepapproveby;
        $approvelog[$crmid]['logconcurrentid']=$logconcurrentid;
        $approvelog[$crmid]['approved_by'] = -1;//当前审批人
        $approvelog[$crmid]['approveresult'] = 17;//系统设置变更，审批信息变化
        $approvelog[$crmid]['description'] = $description;//备注
        $approvelog[$crmid]['approvelogid']=0;

        if($logconcurrentid>0)
        {
            $approvelog[$crmid]['approvelogid']=$approvelogid;
        }

        //将当前提交的审批流程ID统一放到数组中
        $nextapproveinfo['approveid'][$approveid] = $approveid;
        //保存每一个crmid对应的审批流程approveid、审批步骤stepid
        $nextapproveinfo['stepid'][$crmid]['approveid'] = $approveid;
        $nextapproveinfo['stepid'][$crmid]['stepid'] = $nextstepid;
    }

    //5、获取对应审批流程ID全部审批步骤以及对应的审批人
    $approvesql = join(',',$nextapproveinfo['approveid']);
    $query = 'select approveid,id,approvevalue,approvetype,emptyapproverdeal from ld_approvestep 
    			where approveid in ('.$approvesql.') ORDER BY sequence;';
    $result = $adb->pquery($query,array());
    $rows = $adb->num_rows($result);

    $approvestep = array();
    if($rows > 0){
        for($i=0;$i<$rows;$i++){
            $approveid = $adb->query_result($result,$i,'approveid');
            $stepid = $adb->query_result($result,$i,'id');
            $approvetype = $adb->query_result($result,$i,'approvetype');
            $approvevalue = $adb->query_result($result,$i,'approvevalue');
            //一个审批流程ID对应多个审批步骤，放入一个数组中，方便查找下一步审批步骤
            $approvestep['approve'][$approveid][] = $stepid;
            //审批流程对应的审批人，统一放入数组中
            foreach($all_crmid as $tmp_crmid){
                $approverids = $approve->getApproveBy($approvetype,$approvevalue,$tmp_crmid);
                //如果下一步审批人为空，则转交其他审批人
                $allow_emptyapprover = $approve->get_allow_emptyapprover($stepid,$nextStepType);
                if(empty($approverids) && $allow_emptyapprover == 'yes'){ //如果该类型可以设置对应参数
                    $emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
                    $approverids = $approve->getTransferUsers($emptyapproverdeal);
                }
                $approvestep['user'][$stepid][$tmp_crmid] = $approverids;
            }

        }
    }
    $approveseq = 0;$stepid = 0;

    if(!empty($nextapproveinfo['stepid']) && !empty($approvestep)){
        //设置出库单或入库单更新库存流水记录的触发点  1保存  0审核
        $deployarray_48=getSys_deploy(48);
        $deploy_value_48 = $deployarray_48['deploy_value'];
        //设置是否允许负库存出库	// 1是 0否
        $deployarray=getSys_deploy(141);
        $deploy_value_101 = $deployarray['deploy_value'];
        $fld_focus = CRMEntity::getInstance($fld_module);
        $entityarray = getEntitynameInfo(getTabid($fld_module));
        $tabname = $entityarray['tablename'];
        $tabindex = $entityarray['entityidfield'];
        $tabfieldname = $entityarray['fieldname'];
        $query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.implode(',',$all_crmid).')';
        $result = $adb->pquery($query);
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++){
            $crmid = $adb->query_result($result,$i,$tabindex);
            $subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
        }


        foreach($nextapproveinfo['stepid'] as $crmid=>$approveinfo)
        {

            if(!isset($approvelog[$crmid])) continue;
            $approveseq=99999999999;
            //crmid对应的审批步骤，查找在审批流程中对应的下标
            $approveseq = array_search($approveinfo['stepid'],$approvestep['approve'][$approveinfo['approveid']]);
            $approveid=$approveinfo['approveid'];
            $cur_stepid=$approvelog[$crmid]['stepid']; //当前步骤
            $cur_stepapproveby=$approvelog[$crmid]['cur_stepapproveby'];//当前步骤的审批人
            $nextstepapproveby=$cur_stepapproveby;//当前步骤的审批人
            $nextstep_countersigner=$approvelog[$crmid]['countersigner'];//当前步骤是否为会签
            $countersigner=$approvelog[$crmid]['countersigner'];

            /*
    	   *edit: chj
    	   *date: 2020/7/27
    	   *reason: 42125: （61mis.com/kfbcrm）审批中心>待处理>费用报销单模块：批量审批单据，会导致下一步审批人与审批流程中设置的审批人不一致，而且审批历史显示异常（如图，需要补丁）
    	   */
            //43668: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），设置审批流程定制步骤为“会签审批”（使用合同订单审批流程：123_1）时，批量审批错误，仅其中一人审批就审批通过了（需要补丁）
            if($nextstep_countersigner=='yes'){//判断当前步骤是否为会签
                //  $tmp_nextstep_user_arr=array(0,1);
                $tmp_nextstep_user_arr=array_filter(explode(',',$nextstepapproveby));
                if(sizeof($tmp_nextstep_user_arr)<=1){
                    //会签步骤的审批人只有当前登录用户了
                    $approveseq ++;//查找下一个审批流程对应的审批步骤
                }
            }else{
                $tmp_nextstep_user_arr=[];
                $approveseq ++;//查找下一个审批流程对应的审批步骤
            }

            $approvelog[$crmid]['nextstepapproveby'] = $approvestep['user'][$nextstepid][$crmid];
            if($approvelog[$crmid]['logconcurrentid']>0)
            {
                //重算并发步骤的stepid和nextstepid
                $approvelog[$crmid]['nextstepid']=$nextstepid;
                if($approvelog[$crmid]['islastconcurrentstep']=='yes')
                {

                    //并发步骤的最后一步
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                    {
                        if($tmpstepInfo['stepid']==$cur_stepid)
                        {
                            $tmpsequence=floor($tmpstepInfo['sequence'])+1;
                            break;
                        }
                    }
                    $approvelog[$crmid]['nextstepid']=$nextstepid;
                    $isapprovesteplast='no';
                    if($isapprovesteplast=='yes')
                    {
                        //审批流程的最后一步
                        $approvelog[$crmid]['approveresult'] = 2;//标注为已审批
                        $approvelog[$crmid]['nextstepid'] = '';//标注为已审批
                    }
                }
            }else{
                $approvelog[$crmid]['nextstepid'] = $nextstepid;
            }

            $fld_module = getTabname($_REQUEST['tabid']);
            $_REQUEST['stepid']=$approvelog[$crmid]['stepid'];
            $_REQUEST['approvelogid']=$approvelog[$crmid]['approvelogid'];
            $_REQUEST['logconcurrentid']=$approvelog[$crmid]['logconcurrentid'];
            $concurrentidStepCount=0;

            $_REQUEST['nextstep_0']=$approvelog[$crmid]['nextstepid'];
            if(array_key_exists($crmid,$concurrentstep_arr))//当前单据有并发步骤
            {
                $concurrentidStepCount=$concurrentstep_arr[$crmid]['concurrentidStepCount'];
                foreach($concurrentstep_arr[$crmid]['concurrentinfo'] as $requestkey=>$requestvalue)
                {
                    $_REQUEST[$requestkey]=$requestvalue;
                }

                $_REQUEST['nextstep_0']=$concurrentstep_arr[$crmid]['concurrentinfo']['nextstep_0'];
            }
            $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
            $approvestepinfo=$approve->getStepInfo($approvelog[$crmid]['stepid']);//审批步骤信息

            $approve->SaveApprovedLog($fld_module,$approvelog[$crmid]);
        }
    }
}
$arr['width'] = $width;
$arr['max_rows']= $max_rows;
$arr['id_str']= $id_str;
$arr['start']= $new_start;
$arr['end']= $end;
ConvertTojsonString(1,$arr,'success');
?>