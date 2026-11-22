<?php
//zxm 20221128 approve.php中的代码优化  审批的操作
class cls_ApproveAction
{
    public $approveobj;

    public function __construct($approveobj)
    {
        $this->approveobj = $approveobj;
    }
    /**
     * 添加审批历史，执行审批步骤高级条件等
     * @param String $module 模块名
     * @param Array $approvelog 审批历史保存信息
     * Array(
     *	   crmid,//数据ID
     *     approveid,//审批流程
     *     stepid,//审批步骤
     *     approved_by,当前审批人
     *     approveresult,当前审批类型（通过、驳回、已审批等）
     *     description,//审批备注
     *     nextstepid,//下一步审批步骤
     *     nextstepapproveby,//下一步审批人
     * )
     * @return //执行审批操作
     * @project PROT144 审批功能改进
     * @author Tujt 2014-12-26
     */
    public function SaveApprovedLog($module,$approvelog) {
         
        global $adb,$current_user;
        global $approvestepinfo_arr;//审批流程下所有审批步骤信息（批量审批）
        //异常处理(通过并进行下一步：审批步骤或者下一步审批人为空)
        $stepinfo['curstepid']=$approvelog['stepid'];//要初始化
        $stepinfo['nextstepid']=$approvelog['nextstepid'];//要初始化
           
        //已拒绝，和审批失败都不需要获取满足审批条件的审批流程
        crm_load_class_file('cls_ApproveStep','modules/Approve');
        $stepobj=new cls_ApproveStep($module,$approvelog['approveid'],$_REQUEST['approvestatus']);
        $crmid=$approvelog['crmid'];
        $approveid=$approvelog['approveid'];
        $concurrentid=0;
        $islaststepconcurrent='yes';
        /*
        approvelog['approverresult']=1 and approvelog['stepid']=-2:反审批界面：回撤到上一步
          approvelog['approverresult']=4:驳回（包括反审批界面的按钮和审批
          approvelog['approverresult']=1 and approvelog['stepid']>0:表示审批中
          $approvelog['approveresult']=6:加签（审批中）
        */
        $getnewstep = 'no';
       
     
        //duan 20230220 会签审批时，为了避免并发操作，需要重新获取下一步审批人
        $stepid = $approvelog['stepid'];
        $cur_stepinfo = $this->approveobj->getStepInfo($stepid);
        //在操作审批通过时，判断审批的步骤是否属于正在审批的步骤
        if($approvelog['approveresult']==1 && $approvelog['stepid']>0){
            $approveinfo=$this->approveobj->approveStatus($crmid);//获取单据的最后一条审批历史记录
            if($approveinfo['logconcurrentid']>0){
                //判断所有并发步骤
                $tmp_sql = "SELECT 1 from ld_approvelog where crmid=? and logconcurrentid = ? and FIND_IN_SET(?,nextstepapproveby) and isfinished='no' ";
                $tmp_result = $adb->pquery($tmp_sql,[$crmid,$approveinfo['logconcurrentid'],$current_user->id]);
                if($adb->num_rows($tmp_result)<=0){
                    return '';
                }
            }else{
                if($approvelog['stepid']!=$approveinfo['nextstepid']){
                    return '';
                }
            }
        }

        if($cur_stepinfo['countersigner'] == 'yes'&&$approvelog['approveresult']==1&&$approvelog['nextstepid']==$approvelog['stepid']){
            $nextapproved_bys=explode(',',$approveinfo['nextstepapproveby']);
            $nextsetpbyuser='';
            
            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                 if($tmp_approveuserid==$current_user->id)
                 {
                    continue;//删除当前审批人
                 }
                 $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextsetpbyuser = rtrim($nextsetpbyuser,',');
            if(!empty($nextsetpbyuser)){
                $approvelog['nextstepapproveby'] = $nextsetpbyuser;
            }else{
                $getnewstep = 'yes';    
            }
        }
        //edit:can 20230323 63427 ： 	http://60.247.158.183:85/crm ；四川中卉；入库单编号：RKD-2303-8555的单据，在审批树上显示成本经理在审批中，但是单据的审
         if($approvelog['logconcurrentid']>0)
        {
            //是否为并发步骤最后一步
            $islaststepconcurrent=$this->approveobj->getisLastStepConcurrent($approvelog['crmid'],$approvelog['logconcurrentid'],$approvelog['approveid']);
        
            //duan 20221213 如果当前步骤是并发步骤最后一步，则避免两个用户同时操作导致的下一步审批错误的问题,判断当前步骤和下一步相同时，重新获取下一审批步骤
            if($islaststepconcurrent=='yes'&&$approvelog['approveresult']==1&&$approvelog['nextstepid']==$approvelog['stepid']){
                $getnewstep = 'yes';    
            }
            else{
                $getnewstep='no';
            }
        }
     
        //duan 20230220 如果并发和会签审批时，都出现了并发操作的问题，需要重新获取审批人
        if($getnewstep == 'yes'){
            $tmp_stepid = $approvelog['stepid'];
            $tmp_approveid = $approvelog['approveid'];
            $sql = "SELECT concurrentid,sequence from ld_approvestep where id = ?";
            $result = $adb->pquery($sql,array($tmp_stepid));
            if($adb->num_rows($result)>0){
                $tmp_concurrentid = $adb->query_result($result,0,'concurrentid');
                $tmp_sequence = $adb->query_result($result,0,'sequence');
                //因为当前步骤已经是并发步骤的最后一步，所以直接获取下一步
                if($tmp_concurrentid >0){
                    $sql = "SELECT id,approvetype,approvevalue,emptyapproverdeal from ld_approvestep where approveid = ? and concurrentid <> ? and sequence>?  order by sequence asc limit 1";
                    $result = $adb->pquery($sql,array($tmp_approveid,$tmp_concurrentid,$tmp_sequence));
                }else{
                    $sql = "SELECT id,approvetype,approvevalue,emptyapproverdeal from ld_approvestep where approveid = ? and sequence>?  order by sequence asc limit 1";
                    $result = $adb->pquery($sql,array($tmp_approveid,$tmp_sequence));
                }
                
                if($adb->num_rows($result)>0){
                    $tmp_nextstepid = $adb->query_result($result,0,'id');
                    $tmp_approvetype = $adb->query_result($result,0,'approvetype');
                    $tmp_approvevalue = $adb->query_result($result,0,'approvevalue');
                    $emptyapproverdeal = $adb->query_result($result,0,'emptyapproverdeal');
                    $approvelog['nextstepid'] = $tmp_nextstepid;
                    $approvelog['nextstepapproveby'] = $this->approveobj->getApproveBy($tmp_approvetype,$tmp_approvevalue,$crmid,$emptyapproverdeal);
                }else{
                    $approvelog['approveresult'] = 2;
                    $approvelog['nextstepid'] = '';
                    $approvelog['nextstepapproveby'] = '';
                }
            }
        }

        $iscanceloperation='no';//是否为反审批操作包括（不通过，返回负责人）

        if(1 == $approvelog['approveresult']||$approvelog['approveresult']==6||$approvelog['approveresult']==17||($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog')))
        {
            //通过并进行下一步
            //下一步审批步骤为空
            if($islaststepconcurrent=='no' && $approvelog['approveresult'] !=5 )
            {
                //并发步骤非最后一步
                $approvelog['nextstepid']=$approvelog['stepid'];
            }

            if(empty($approvelog['nextstepid'])){
                /// $this->approveobj->approveStatus($approvelog['crmid']);//获取审批日志的最后一步
                $query = 'select id,sequence,concurrentid from ld_approvestep where approveid = ? and id > (
						select nextstepid from ld_approvelog where crmid = ? ORDER BY id desc limit 1
						) ORDER BY sequence limit 1;';
                $result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['crmid']));
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    $approvelog['nextstepid'] = $adb->query_result($result,0,0);
                    $sequence=$adb->query_result($result,0,0);
                    $concurrentid=$adb->query_result($result,0,'concurrentid');
                }
            }
            else
            {
                $query="select  sequence,concurrentid from ld_approvestep where id=?";
                $result = $adb->pquery($query,array($approvelog['nextstepid']));
                $sequence=$adb->query_result($result,0,0);
                $concurrentid=$adb->query_result($result,0,'concurrentid');
            }
            if($approvelog['stepid']==-2 && ($_REQUEST['file']=='getCancelApprove' || $_REQUEST['action']=='getCancelApprove'))
            {
                //反审批 回撤到上一步，不需要处理，在module/Approve/getCancelApprove.php已经获取最新
                $iscanceloperation='yes';
                if($concurrentid>0)
                {
                    $sequence=floor($sequence);
                    $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approveid);
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo )
                    {
                        if($tmpstepinfo['sequence']==$sequence)
                        {
                            $approvelog['nextstepid']=$tmpstepinfo['stepid'];
                            break;
                        }
                    }
                }
                $stepinfo=$stepobj->getstepid($approvelog['nextstepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
            }
            else if($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog'))
            {
                //手机端审批：不通过，返回上一步
                $iscanceloperation='yes';
                //edit:can 2021-01-12 44190: （企业微信移动端-kfbcrm）待审批-销售机会，单据编号 pot97；审批流“销售机会第二步会签”；二级审批审批时操作驳回上一步，审批日志中显示“通过”
                //$approvelog['stepid']=-2;
                //$approvelog['approveresult']=1;
                if($concurrentid>0)
                {
                    $sequence=floor($sequence);
                    $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approveid);
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo )
                    {
                        if($tmpstepinfo['sequence']==$sequence)
                        {
                            $approvelog['nextstepid']=$tmpstepinfo['stepid'];
                            break;
                        }
                    }
                }
                $stepinfo=$stepobj->getstepid($approvelog['nextstepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
            }
            else
            {

                //加签不需要再做跳过判断

                if($islaststepconcurrent=='yes'&&($approvelog['approveresult']!='6'&&$approvelog['approveresult']!='17' ))//高级查询并发步骤跳过
                    $stepinfo=$stepobj->getstepid($approvelog['nextstepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
                else//如果是并发步骤且不是并发步骤的最后一步，则不需要判断高级查询条件
                    $stepinfo= array("curstepid"=>$approvelog['nextstepid'],"nextstepid"=>$approvelog['nextstepid'],'concurrentid'=>$concurrentid);;

                if($approvelog['approveresult']!=4&&$stepinfo['nextstepid']<=0)
                { //如果不是返回上一步，且没有找到满足的审批流程则，则认为审批成功

                    $approvelog['approveresult']=2;
                    $approvelog['nextstepapproveby']="";
                    //异常情况保存参数记录
                    $approvelog['description'] = $approvelog['description'];

                }
                else if(empty($approvelog['nextstepapproveby'])&&$stepinfo['nextstepid']==$approvelog['nextstepid'])//批量审批中下一步审批人为空
                {

                    $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approveid);
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo)
                    {
                        if($tmpstepinfo['stepid']==$approvelog['nextstepid'])
                        {
                            $approvetype = $tmpstepinfo['approvetype'];
                            $approvevalue = $tmpstepinfo['approvevalue'];
                            $approvelog['nextstepapproveby'] = $this->approveobj->getApproveBy($approvetype,$approvevalue,$crmid);
                            break;
                        }
                    }
                }
            }
        }
        else{
            $iscanceloperation='yes';
        }
         /* duan 20231030 上面已经判断过当前审批的步骤是否属于正在审批的步骤，这一段代码没用了，先注释
        //当前审批步骤的审批历史
        $sql='select approveid,stepid,urgent,augmentsinger,approveresult,countersigner,nextstep_countersigner from ld_approvelog 
        where crmid =? and approved_by>0 and isfinished="yes" order by id desc limit 1';
        $result=$adb->pquery($sql,array($approvelog['crmid']));
        if($adb->num_rows($result)>0&&$approvelog['approveresult']!=4)
        {
            $urgent = $adb->query_result($result,0,'urgent');//新增审批日志前暂存上一次是否加急审批urgent的值
            //解决并发，判断approveid,stepid都相同
            $tmpapprovied=$adb->query_result($result,0,'approveid');
            $prevapproveid=$tmpapprovied;//
            $tmpstepid=$adb->query_result($result,0,'stepid');
            $augmentsinger=$adb->query_result($result,0,'augmentsinger');
            $approveresult = $adb->query_result($result,0,'approveresult');
            $countersigner = $adb->query_result($result,0,'countersigner');
            $nextstep_countersigner = $adb->query_result($result,0,'nextstep_countersigner');
            if($tmpapprovied==$approvelog['approveid']&&$tmpstepid==$approvelog['stepid']&&!in_array($approveresult,array(5,6,15,16,17))
                &&$countersigner!='yes'&&$nextstep_countersigner!='yes')
            {
                return ;
            }
        }
        */
        if(!isset($approvelog['countersigner'])||$approvelog['countersigner']==''){
            $approvelog['countersigner']='no';
            //审批中心批量审批
            $sql='select countersigner from ld_approvestep where id=?';
            $tmpresult=$adb->pquery($sql,array($approvelog['stepid']));
            $approvelog['countersigner']=$adb->query_result($tmpresult,0,'countersigner');//当前步骤是否会签
        }
       
        

        $approvelog['nextstep_countersigner']='no';
        if($stepinfo['nextstepid']!=$approvelog['nextstepid'])//如果下一步审批步骤不满足条件，则下一步审批人为system
            $approvelog['nextstepapproveby']="-1";

        // $nextstepapprove_user_arr=array_filter(explode(",",$approvelog['nextstepapproveby']));
        if($approvelog['nextstepid']>0){//审批成功$approvelog['nextstepid']为空
            //如果下一步审批人大于1，则要判断下一步审批是否为会签
            $sql='select countersigner,augmentsinger from ld_approvestep where id=?';
            $tmpresult=$adb->pquery($sql,array($approvelog['nextstepid']));
            $tmpcountersigner=$adb->query_result($tmpresult,0,'countersigner');
            $approvelog['nextstep_countersigner']=$adb->query_result($tmpresult,0,'countersigner');//当前步骤是否会签
            $approvelog['augmentsinger']=$adb->query_result($tmpresult,0,'augmentsinger');//当前步骤是否加签

            if($approvelog['approveresult'] == 6){
                if($approvelog['augmentsinger'] == 'yes' || $approvelog['augmentsinger'] == 'no'){
                    $approvelog['nextstep_countersigner']= 'yes';
                    if($approvelog['augmentsinger'] == 'yes')
                        $approvelog['countersigner'] = 'yes';
                }else{

                    $approvelog['nextstep_countersigner']=$this->approveobj->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']);
                }
            }else{

                if($approvelog['augmentsinger'] == 'yes' && 1 == $approvelog['approveresult'] && $approvelog['stepid'] > 0){
                    $sql='select id,approveresult,stepid from ld_approvelog where crmid='.$crmid.' order by id desc limit 1';
                    $tmpresult=$adb->pquery($sql,array());
                    $last_approveresult=$adb->query_result($tmpresult,0,'approveresult');
                    $last_stepid=$adb->query_result($tmpresult,0,'stepid');
                    $last_approvelogid=$adb->query_result($tmpresult,0,'id');
                    //$last_stepid!=$approvelog['stepid']||$approvelog['stepid']!=$approvelog['nextstepid']:判断是否为加签的最后一步
                    if($last_approveresult!=6||$last_stepid!=$approvelog['stepid']||$approvelog['stepid']!=$approvelog['nextstepid'])
                    {
                        //edit:can 44769: （61mis.com/kfbcrm）费用报销单审批；单据编号EXP49，审批步骤是会签，5个成员进行会签审批，到第3人时会签结束了
                        $approvelog['nextstep_countersigner']=$approvelog['augmentsinger'];
                        if($tmpcountersigner=='yes'||$approvelog['augmentsinger']=='yes')
                        {
                            // 或签时并且加签（会签） 时，执行到下一步时，变成会签审批了
                            $isaugmentsinger = $this->approveobj->getIsaugmentsinger($last_approveresult,$last_approvelogid,$crmid,$approvelog['nextstepid'],$approvelog['stepid']);
                            if($tmpcountersigner == 'no' && $approvelog['augmentsinger'] == 'yes' && $isaugmentsinger == 'no'){
                                $approvelog['nextstep_countersigner']= 'no';
                            }else
                                $approvelog['nextstep_countersigner']=$this->approveobj->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']); //改步骤是会签且加签也是会签
                        }
                        else
                            $approvelog['nextstep_countersigner']= 'no';
                    }
                    else
                        $approvelog['nextstep_countersigner']= 'yes';
                }else{
                    $approvelog['nextstep_countersigner']=$this->approveobj->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']);
                }
            }
        }

        $fieldsql = '';$valuesql = '';
        //35083: （需要补丁）1.出库单明细界面：当审批流程只有一步的情况下反审批不会回撤到上一步。（但是审批的盖章从已批准变为了审批中）
        $insertcolumns=array('crmid','approveid','stepid','approved_by'
        ,'approveresult','description','nextstepid','nextstepapproveby','countersigner','nextstep_countersigner','augmentsinger');

        $tmp_countersigner_arr = array_filter($_REQUEST, function ($key) {//获取并发步骤的会签
            return strpos($key, 'countersigner_') === 0;
        }, ARRAY_FILTER_USE_KEY);

        if(($_REQUEST['countersigner']=='yes' || in_array('yes',$tmp_countersigner_arr))&&$approvelog['nextstep_countersigner']=='no'&&$islaststepconcurrent='yes'
                &&($approvelog['approveresult']==1&&$approvelog['stepid']>0))
        {
            //$_REQUEST['countersigner']=='yes'&&$approvelog['nextstep_countersigner']=='no':表示会签的最后一个成员
            //$islaststepconcurrent：yes:表示并发步骤的最后一步或者表示当前步骤不是并发步骤
            if($stepinfo['nextstepid']==$approvelog['nextstepid']&&$concurrentid>0)
            {
                //没有跳过审批步骤
                if(!array_key_exists($approvelog['approveid'],$approvestepinfo_arr))
                {
                    $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approvelog['approveid']);
                }
                $concurrentidStepCount=0;
                foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpstepseq=> $tmpallstepinfo)
                {
                    if($tmpallstepinfo['concurrentid']==$concurrentid)
                    {
                        $approvetype=$tmpallstepinfo['approvetype'];
                        $approvevalue=$tmpallstepinfo['approvevalue'];
                        $_REQUEST['userid_'.$concurrentidStepCount]=$this->approveobj->getApproveBy($approvetype,$approvevalue,$approvelog['crmid']);
                        $_REQUEST['nextstep_'.$concurrentidStepCount]=$tmpallstepinfo['stepid'];
                        $_REQUEST['nextstep_countersigner_'.$concurrentidStepCount]=$tmpallstepinfo['countersigner'];
                        $_REQUEST['nextstep_augmentsinger_'.$concurrentidStepCount]=$tmpallstepinfo['augmentsinger'];
                        $_REQUEST['stepseq_'.$concurrentidStepCount]=$concurrentidStepCount;
                        $concurrentidStepCount++;
                        $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
                    }
                    else  if($concurrentidStepCount>0)
                    {
                        break;
                    }

                }
            }


        }

        foreach($insertcolumns as $col){
            $fieldsql .= $col.',';
            $values[] = $approvelog[$col];
        }
        $fieldsql = trim($fieldsql,',');
        $time = time();
        $nowtime = date('Y-m-d H:i:s',$time);
        $approvelogid = $adb->getUniqueID('ld_approvelog');


        /*
        * approve_autograph 是否显示手写签名  approve_autograph_path 手写签名图片保存路径
        *edit:chj
        *date:2020-07-13
        *reason:审批意见增加手写签名
        */
        $approve_autograph = 'no';
        if(!empty($_REQUEST['approve_autograph_path'])){
            $approve_autograph = 'yes';
        }
        //反审批
        if($iscanceloperation=='yes')
        {
            $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? , approved_by=?,approve_autograph=?,approve_autograph_path=? 
            where crmid=? and isfinished="no" and ifnull(logconcurrentid,0) = 0';
            $adb->pquery($sql,array($approvelog['approveresult'],$current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$approvelog['crmid']));
            //并发步骤不更新approveresult,但需要更新isfinished
            $sql='update ld_approvelog set createdtime=now(),isfinished="yes", approved_by=?,approve_autograph=?,approve_autograph_path=? 
            where crmid=? and isfinished="no" and ifnull(logconcurrentid,0) > 0';
            $adb->pquery($sql,array($current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$approvelog['crmid']));
        }

        $logconcurrentid=$approvelog['logconcurrentid'];
        $currentapprover= $approvelog['nextstepapproveby'];

        if($approvelog['logconcurrentid']>0)
        {
            //是否为并发步骤最后一步
            //$islaststepconcurrent=$this->approveobj->getisLastStepConcurrent($approvelog['crmid'],$approvelog['logconcurrentid'],$approvelog['approveid']);

            // dump(array($approvelog['approveresult'],$current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
            if(($approvelog['approveresult']=='1'&&$_REQUEST['stepid']>0)||$approvelog['approveresult'] == 6||$approvelog['approveresult']==2||$approvelog['approveresult']==17)
            {
                $tmpapproveresult=$approvelog['approveresult'];
                if($tmpapproveresult==2)
                {
                    $tmpapproveresult=1;
                }

                if($approvelog['approveresult'] == 6)//加签
                {
                    $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? 
                     ,description=?,approved_by=?,nextstepapproveby=?,approve_autograph=?,approve_autograph_path=? where id=? ';
                    $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                        $current_user->id,$approvelog['nextstepapproveby'], $approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
                }else if($approvelog['approveresult'] == 17){//审批步骤设置变化，审批人变更
                    //如果是会签审批
					//按照新的审批人添加审批日志
					$query = 'insert into ld_approvelog(id,crmid,approveid,stepid,approved_by
						,approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner
						 ,nextstep_countersigner,augmentsinger,approve_autograph,approve_autograph_path
						 ,isfinished,stepseq,logconcurrentid,description)';
					$query .= ' value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
					
					$timesql='select current_timestamp(6) as seqtime ';
					$timeresult=$adb->pquery($timesql,array());
					$seqtime=$adb->query_result($timeresult,0,'seqtime');
					
                    if($approvelog['nextstep_countersigner'] == 'yes'){
                        //更新原有会签审批记录为已完成
                        $sql = "update ld_approvelog set isfinished=?,approveresult=?,approved_by=? where stepid = ? and logconcurrentid = ? and crmid = ?";
                        $adb->pquery($sql,array('yes',$tmpapproveresult,-1,$approvelog['stepid'], $approvelog['logconcurrentid'],$approvelog['crmid']));
                        
                        $nextstepapproveby_arr = explode(',',$approvelog['nextstepapproveby']);
                        foreach($nextstepapproveby_arr as $userid){
                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                            $param=array($approvelogid,$approvelog['crmid'], $approvelog['approveid'],$approvelog['stepid'],0,12,date('now'),$seqtime,$approvelog['stepid'],$userid
                            ,$approvelog['nextstep_countersigner'],'no','','no','','no',$stepseq,$approvelog['logconcurrentid'],'');
                            $adb->pquery($query,$param);
                        }


                    }else{
                        //如果修改前为会签，修改后为非会签
                        if($approvelog['countersigner'] == 'yes'){
                            //更新原有会签审批记录为已完成
                            $sql = "update ld_approvelog set isfinished=?,approveresult=?,approved_by=? where stepid = ? and logconcurrentid = ? and crmid = ?";
                            $adb->pquery($sql,array('yes',$tmpapproveresult,-1,$approvelog['stepid'], $approvelog['logconcurrentid'],$approvelog['crmid']));

                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                            $param=array($approvelogid,$approvelog['crmid'], $approvelog['approveid'],$approvelog['stepid'],0,12,date('now'),$seqtime,$approvelog['stepid'],$approvelog['nextstepapproveby']
                            ,$approvelog['nextstep_countersigner'],'no','','no','','no',$stepseq,$approvelog['logconcurrentid'],'');
                            $adb->pquery($query,$param);

                        }else{
                            $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? 
                             ,description=?,approved_by=?,nextstepapproveby=?,approve_autograph=?,approve_autograph_path=? where id=? ';
                            $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                                -1,$approvelog['nextstepapproveby'], $approve_autograph,$_REQUEST['approve_autograph_path'],$approvelog['approvelogid']));
							
							$approvelogid=$adb->getUniqueID('ld_approvelog');
                            $param=array($approvelogid,$approvelog['crmid'], $approvelog['approveid'],$approvelog['stepid'],0,12,date('now'),$seqtime,$approvelog['stepid'],$approvelog['nextstepapproveby']
                            ,$approvelog['nextstep_countersigner'],'no','','no','','no',$stepseq,$approvelog['logconcurrentid'],'');
                            $adb->pquery($query,$param);
							
                        }

                    }
                }
                else
                {
                    $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? 
                     ,description=?,approved_by=?,approve_autograph=?,approve_autograph_path=? where id=? ';


                    $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                        $current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
                }


                $logconcurrentid=$approvelog['logconcurrentid'];
                if($approvelog['approveresult'] == 6)//加签
                {
                    //加签
                    $nextstep_concurrentid=0;
                    $approvelogid=$adb->getUniqueID('ld_approvelog');

                    $sql='select stepseq,seqtime from ld_approvelog where id=? and logconcurrentid=? ';
                    $tmpresult=$adb->pquery($sql,array($approvelog['approvelogid'],$approvelog['logconcurrentid']));
                    $stepseq=$adb->query_result($tmpresult,0,'stepseq');
                    $seqtime=$adb->query_result($tmpresult,0,'seqtime');
                    $tmpvalues=$values;
                    $fieldsql_arr=explode(",",$fieldsql);
                    $tmpsearchindex=array_search('approved_by',$fieldsql_arr);
                    $sql='select * from ld_approvestep where id=?';
                    $tmpresult=$adb->pquery($sql,array($_REQUEST['stepid']));
                    $tmpaugmentsinger=$adb->query_result($tmpresult,0,'augmentsinger');


                    $tmpvalues[$tmpsearchindex]=0;//加签的当前审批人为空
                    if($tmpaugmentsinger=='yes')
                    {
                        $tmpsearchindex=array_search('countersigner',$fieldsql_arr);
                        $tmpvalues[$tmpsearchindex]='yes';

                        $tmpsearchindex=array_search('nextstepapproveby',$fieldsql_arr);
                        $tmpdesciptionsearchindex=array_search('description',$fieldsql_arr);
                        $tmpvalues[$tmpdesciptionsearchindex]='';

                        $nextstepapproveby_arr=explode(',',$tmpvalues[$tmpsearchindex]);

                        foreach($nextstepapproveby_arr as $tmpnextuserid)
                        {
                            $trimuserid=trim($tmpnextuserid,',');
                            if(empty($trimuserid))
                            {
                                continue;
                            }

                            $tmpvalues[$tmpsearchindex]=$tmpnextuserid;

                            $query = 'insert into ld_approvelog(id,createdtime,'.$fieldsql.',approve_autograph,approve_autograph_path,stepseq,seqtime,isfinished,logconcurrentid) 
            					values('.$approvelogid.',now(),'.generateQuestionMarks($tmpvalues).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\',\''.$stepseq.'\',\''.$seqtime.'\',\'no\','.$approvelog['logconcurrentid'].');';

                            $adb->pquery($query,array($tmpvalues));
                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                        }
                    }
                    else{
                        $tmpsearchindex=array_search('nextstep_countersigner',$fieldsql_arr);
                        $tmpvalues[$tmpsearchindex]='no';

                        $query = 'insert into ld_approvelog(id,createdtime,'.$fieldsql.',approve_autograph,approve_autograph_path,stepseq,seqtime,isfinished,logconcurrentid) 
            					values('.$approvelogid.',now(),'.generateQuestionMarks($tmpvalues).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\',\''.$stepseq.'\',\''.$seqtime.'\',\'no\','.$approvelog['logconcurrentid'].');';

                        $adb->pquery($query,array($tmpvalues));
                    }
                }
				else if($approvelog['approveresult'] == 17){
                }
                else{

                    //判断是否为并发审批的最后一步
                    if($islaststepconcurrent=='yes'&&$_REQUEST['concurrentidStepCount']<=0)
                    {
                        //当前审批步骤，是并发步骤的最后一个审批步骤
                        //下一步不是并发步骤
                        //dump($approvelog);
                        $sql=' select * from ld_approvestep where approveid=? and id=?';

                        $tmpresult=$adb->pquery($sql,array($approvelog['approveid'],$approvelog['nextstepid']));
                        $nextstep_concurrentid=0;
                        $nextstep_countersigner='no';
                        if($adb->num_rows($tmpresult))
                        {
                            $nextstep_concurrentid=$adb->query_result($tmpresult,0,'concurrentid');

                            $nextstep_countersigner=$adb->query_result($tmpresult,0,'countersigner');
                        }
                        $approvelog['nextstep_countersigner']=$nextstep_countersigner;
                        $tmpapprovelogid=$adb->getUniqueID('ld_approvelog');
                        $stepseq=0;
                        $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
    					values('.$tmpapprovelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
                        $adb->pquery($query,array($values));
                        $logconcurrentid=0;

                    }
                }

            }
            else{


                $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
        					values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
                $adb->pquery($query,array($values));
            }
        }
        else
        {
            // dump($stepobj->skipstepinfo);

            $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
    					values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
            $adb->pquery($query,array($values));


        }

        //修改催审状态
        $focus = CRMEntity::getInstance($module);
        $tabname = $focus->table_name;
        $table_index = $focus->table_index;
        //满足任一条件修改单据催审状态（即ld_appprovelog表增加一条日志）:①非并发审批;②并发审批：加签;③并发审批：非加签且为并发审批的最后一步;
        if($approvelog['logconcurrentid']<=0||((($approvelog['approveresult']=='1'&&$_REQUEST['stepid']>0)||$approvelog['approveresult']==2)&&$islaststepconcurrent=='yes'&&$_REQUEST['concurrentidStepCount']<=0)||$approvelog['approveresult']==6)
        {
            $adb->pquery("update $tabname set approveexpediting='no' where $table_index = ?",array($crmid));
        }

        $this->approveobj->insertStepID_arr=[];
        $this->approveobj->insertStepID_arr[]=$approvelog['stepid'];//已经插入的审批步骤
        $concurrentInsertStepInfo=array('logconcurrentid'=>0);

        $_REQUEST['new_concurrentidStepCount']=$_REQUEST['concurrentidStepCount'];
        $new_description=$_REQUEST['description'];
        $_REQUEST['description']='';

        //edit:can 2021-01-14 44276: （61mis.com/kfbcrm）并发审批；OA表单-常用审批单；单据编号PTSP117 ， 二级审批时，不通过，返回上一步，结果进入了三级的并发审批
        if($_REQUEST['concurrentidStepCount']>1&&($approvelog['approveresult']==1||
                ($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog'))
            )
        )
        {
            //界面传值下一步是并发审批步骤

            $concurrentInsertStepInfo= $this->approveobj->insertConcurrentApproveLog($stepobj,$approvelog);//插入并发步骤

            $logconcurrentid=$concurrentInsertStepInfo['logconcurrentid'];

            $with_concurrent = 'yes';
        }

        //跳过的审批步骤的审批历史
        $skipstepConcurrentinfo= $stepobj->saveSkipApproveLog($crmid);
        //edit:can 2020-12-17 43827: （61mis.com/kfbcrm）并发审批：OA表单-常用审批单；单据编号PTSP56，并发审批中，增加步骤审批人，审批人的审批意见在日志显示

        if(sizeof($stepobj->skipstepinfo)>0&&$stepinfo['nextstepid']>0)
        {
            //跳过进入的下一步判断是否为并发
            //$stepinfo['nextstepid']:防止反审批和审批结束
            $lastskipstepinfo=$stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1];

            if(is_array($approvestepinfo_arr)&&array_key_exists($approvelog['approveid'],$approvestepinfo_arr))
            {

            }
            else
            {
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
                $approvestepinfo_arr[$approvelog['approveid']]=$this->approveobj->getAllStepInfoByApproveid($approvelog['approveid']);
            }
            $tmpstartindex=0;
            $curstep_concurrentid=0;
            $con_sequence=0;
            foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpstepinfo)
            {
                if($tmpstepinfo['stepid']==$_REQUEST['nextstep_0'])
                {
                    $curstep_concurrentid=$tmpstepinfo['concurrentid'];
                    break;
                }
            }
            foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
            {

                if($tmpstepinfo['stepid']==$lastskipstepinfo['nextstepid'])
                {
                    //满足条件的步骤在并发步骤的中间，所以只能提前获取并发步骤ID判断
                    $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                    $con_sequence=$tmpstepinfo['sequence'];
                    break;
                }
            }

            // dump($this->approveobj->checkConcurrentStepAllSkip($tmpconcurrentid,$approvelog['approveid'],$stepobj));
            /**
             * 当前跳过并发步骤的所有步骤
             * **/
            if($tmpconcurrentid>0&&$this->approveobj->checkConcurrentStepAllSkip($tmpconcurrentid,$approvelog['approveid'],$stepobj)=='yes' && $approvelog['approveresult'] != 17)
            {
                //edit:can 2020-12-18 043841: （61mis.com/kfbcrm）并发审批：财务管理-销售发票；单据编号INV30；审批流“销售发票并发跳过”；第一步审批不符合条件跳过，直接进入并发步骤中跳过时，无法进入并发最后一步
                $con_sequence=floor($con_sequence)+1;//获取下一个sequence

                foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
                {
                    if($con_sequence<=$tmpstepinfo['sequence'])
                    {
                        $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                        if(empty($tmpconcurrentid))
                        {
                            //跳过进入的步骤不是并发
                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                            /*id,crmid,description,approveid,stepid,approved_by,
                               approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq
                             */
                            $tmpapprovetype=$tmpstepinfo['approvetype'];
                            $tmpapprovevalue=$tmpstepinfo['approvevalue'];

                            $tmpnextstepapproveby=$this->approveobj->getApproveBy($tmpapprovetype,$tmpapprovevalue,$approvelog['crmid']);
                            $stepobj->saveskip_nextstepapproveby=$tmpnextstepapproveby;
                            $currentapprover=$tmpnextstepapproveby;
                            $tmpvalues=$values;
                            $fieldsql_arr=explode(",",$fieldsql);

                            $tmpsearchindex=array_search('stepid',$fieldsql_arr);
                            //通过下一步并发步骤，当所有并发步骤都不满足条件时，当时步骤则显示并发里的第一步
                            //$tmpvalues[$tmpsearchindex]=$stepinfo['nextstepid'];
                            $tmpvalues[$tmpsearchindex]=$approvelog['nextstepid'];
                            $tmpsearchindex=array_search('approved_by',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]='-1';
                            $tmpsearchindex=array_search('nextstepapproveby',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]=$currentapprover;
                            $tmpsearchindex=array_search('nextstepid',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]=$tmpstepinfo['stepid'];
                            $tmpsearchindex=array_search('countersigner',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]='no';
                            $tmpsearchindex=array_search('nextstep_countersigner',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]=$tmpstepinfo['countersigner'];
                            //下一步跳过并发后，满足条件的审批步骤，记录了当前审批步骤的审批意见
                            $tmpsearchindex=array_search('description',$fieldsql_arr);
                            $tmpvalues[$tmpsearchindex]='';
                            $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.') 
    				                	values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($tmpvalues).');';
                            $adb->pquery($query,$tmpvalues);
                            $logconcurrentid=0;
                            $stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1]['nextstepid']=$tmpstepinfo['stepid'];
                            $stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1]['approvelogid']=$approvelogid;

                        }
                        else//跳过即将进入并发步骤
                            $skipstepConcurrentinfo=['logconcurrentid'=>0];
                        break;
                    }
                }
            }

            foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
            {
                if($tmpstepinfo['concurrentid']==$tmpconcurrentid)
                {
                    if($tmpstepinfo['concurrentid']<=0)
                    {
                        break;
                    }
                    else
                    {

                        //如果进入的是并发步骤
                        //$tmpconcurrentid=$tmpstepinfo['concurrentid'];
                        //echo $crmid.'ass'.$curstep_concurrentid."<br>";
                        if($tmpconcurrentid==$curstep_concurrentid)
                        {
                            //和界面传值过来的是同一个并发步骤
                            break;
                        }

                        if($skipstepConcurrentinfo['logconcurrentid']<=0)
                        {

                            $skipstepConcurrentinfo=[];
                            $skipstepConcurrentinfo['concurrentid']=$tmpconcurrentid;
                            $sql='select logconcurrentid,current_timestamp(6) as seqtime from ld_approvelog_concurrent ';
                            $tmpresult=$adb->pquery($sql,array());
                            $skipstepConcurrentinfo['logconcurrentid']=$adb->query_result($tmpresult,0,'logconcurrentid');
                            $skipstepConcurrentinfo['seqtime']=$adb->query_result($tmpresult,0,'seqtime');
                            $sql='update ld_approvelog_concurrent set logconcurrentid=logconcurrentid+1 ';
                            $adb->pquery($sql,array());
                        }
                        else{
                            //有并发步骤
                            // $skipstepConcurrentinfo['concurrentid']=$tmpconcurrentid;

                        }

                        $this->approveobj->insertSkipStepConcurrentApproveLog($stepobj,$skipstepConcurrentinfo,$approvelog);

                        $logconcurrentid=$skipstepConcurrentinfo['logconcurrentid'];
                        break;
                    }
                }
            }
        }
        //批量审批会用到
        $_REQUEST['description']=$new_description;

        if(in_array($approvelog['approveresult'],[2,4])){
            $approvelog['nextstepapproveby'] = '';
            $currentapprover=$approvelog['nextstepapproveby'];
        }else if($logconcurrentid>0)
        {
            //获取并发步骤的所有待审批人和审批步骤
            $sql='select GROUP_CONCAT(distinct nextstepapproveby),group_concat(distinct stepid)  from ld_approvelog 
           where approveid=? and logconcurrentid=? and isfinished="no" ';
            $tmpresult=$adb->pquery($sql,array($approvelog['approveid'],$logconcurrentid));
            $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,0)));

            $currentapprover=implode(',',$tmpstr_arr);
            //  $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,1)));
            //$currentapprovestepid=implode(',',$tmpstr_arr);
        }
        else
        {
            $sql='select nextstepapproveby,id from ld_approvelog where crmid=? order by id desc limit 1';
            $result=$adb->pquery($sql,array($approvelog['crmid']));
            $id = $adb->query_result($result,0,'id');
            //duan 判断下一步审批人是否为空，如果为空则执行特殊处理方式,因为需要修改单据中的值，所以获取到执行的结果
            $empty_approver_result = $this->approveobj->emptyapprover_solution($id);
            if ($empty_approver_result['type']=='change'){//转交其他审批人
                $approveby = $empty_approver_result['nextstepapproveby'];
            }else{
                $approveby = $adb->query_result($result,0,'nextstepapproveby');
            }
            $approvelog['nextstepapproveby'] = $approveby;
            $currentapprover=$approvelog['nextstepapproveby'];
        }

        /*
         * editor:gyq_05
         * reason:生成消息提醒
         * */


        global $global_approvereminds;
        require_once(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");
        //@param 参数$approvelog是一个包含审批历史的数组，需传审批步骤IDstepid、审批结果approveresult、下一步审批人nextstepapproveby
        if(sizeof($stepobj->skipstepinfo)>0)
            $approvelog['nextstepid']=$stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1]['nextstepid'];



        //获取审批步骤高级条件字段
        $focus = CRMEntity::getInstance($module);
        $tabname = $focus->table_name;
        $tabindex = $focus->table_index;
        //	$status = $this->approveobj->getApproveFieldColumnname($module);
        //获取审批步骤高级条件设定值
        $query="select modulestatus,pickcolumnname from ld_approvestep left join
		ld_approvestepdetails on ld_approvestep.id=ld_approvestepdetails.stepid
		where approveid=? and stepid=? and pass=? ";
        if($_REQUEST['file']=='getCancelApprove' && ($approvelog['stepid']==-2|| $approvelog['approveresult'] == 4)){
            //duan 路总要求反审批时不触发不通过的字段赋值
        }else{
            //ls 2022-05-18 0051805：审批步骤高级功能里，设置通过时的动态赋值，结果审批“不通过，返回上一”步时也执行了通过时的赋值
            if(3 == $approvelog['approveresult'] || 4 == $approvelog['approveresult'] || 5 == $approvelog['approveresult'])
            {
                //edit:can 2022 53445 合同订单审批流程，高级功能动态赋值：通过 订单状态＝项目经理已确认；不通过 项目经理已驳回。在该步骤审批时，选择不通过
                if($approvelog['stepid']=='-2')
                {
                    $sql='select nextstepid from ld_approvelog where crmid=? order by id desc limit 1 ';
                    $tmpresult=$adb->pquery($sql,array($approvelog['crmid']));
                    $result = $adb->pquery($query,array($approvelog['approveid'],$adb->query_result($tmpresult,0,'nextstepid'),1));

                }
                else
                    $result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['stepid'],1));
            }
            else
                $result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['stepid'],0));
        }



        if($adb->num_rows($result)>0)
        {
            $modulestatus = $adb->query_result($result,0,'modulestatus');
            $pickcolumnname=$adb->query_result($result,0,'pickcolumnname');
            $picktablename=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"tablename");
            $pickfieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"fieldname");
        }

        //提醒
        //require_once('./modules/Approve/Remind.php');
        /*
         * editor:gyq_05
         * reason:取消调用旧*提醒方法
         * date  : 2016 3 4
         * */
        //$this->approveobj->ApproveRemindInfo($module,$approvelog);
        //执行审批步骤高级条件
        $approvestatusarr = array(
            '1'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '2'=>constant('D_A_S_APPROVED'),//'已批准',
            '3'=>constant('D_A_S_REJECTED'),//'已拒绝',
            '4'=>constant('D_A_S_DISMISSED'),//'已驳回'
            '5'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '6'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '12'=>constant('D_A_S_APPROVALOF'),//'并发审批中',
            '14'=>constant('D_A_S_APPROVALOF'),//'审批中'
            '17'=>constant('D_A_S_APPROVALOF'),//'审批中'
            '18'=>constant('D_A_S_APPROVALOF'),//'审批中'
        );
        $pagemode='';

        $approvestatus = $approvestatusarr[$approvelog['approveresult']];

        if($approvestatus==$approvestatusarr['2'])
        {
            $pagemode='Approved';//已批准
        }
        else if($approvestatus==$approvestatusarr['4'])
        {
            $pagemode='Dismissed';//已驳回
        }
        else if($approvestatus==$approvestatusarr['3'])
        {
            $pagemode='Rejected';//已拒绝
        }
        if(!empty($pagemode))
        {
            crm_load_class_file("cls_savereverse",'include/SaveReverse');

            $workflowreverseobj=cls_savereverse::getInstance($module);
            $workflowreverseobj->setPageMode($pagemode);
            $workflowreverseobj->isRead = 'no';
            $workflowreverseobj->getInfo();
            if($adb->num_rows($workflowreverseobj->workflowresut)>0)
            {
                global $reset_retrieve_entity_info;//修改日志需要重新获取数据
                $reset_retrieve_entity_info='yes';//批量提交
                $focus->retrieve_entity_info($approvelog['crmid'], $module);
                $beforefieldvalue_arr=$focus->column_fields;
            }
        }


        $sql='select approvestatus from '.$tabname. ' where '.$tabindex.' = '.$approvelog['crmid'];
        //修改前的审批状态
        $before_approveresult=$adb->pquery($sql,array());
        global $before_approveinfo;
        $before_approveinfo['approvestatus']=$adb->query_result($before_approveresult,0,'approvestatus');
        // @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面。(批量审批时当前审批步骤：currentapprovestepid)
        if($tabname == 'ld_potential'){
            $query1 = 'SELECT sales_stage,potentialid FROM ld_potential WHERE potentialid = "'.$approvelog['crmid'].'" LIMIT 1;';
            $result = $adb->pquery($query1);
            $lastsales_stage = $adb->query_result($result,0,'sales_stage');
            $query = 'update '.$tabname.' set approvestatus="'.$approvestatus.'",approveby="'.$current_user->id.'",approvetime="'.date("Y-m-d H:i:s").'",currentapprovestepid="'.$approvelog['stepid'].'" , lastsales_stage="'.$lastsales_stage.'",currentapprover="'.$currentapprover.'" where '.$tabindex.' = '.$approvelog['crmid'];
        }else{
            $query = 'update '.$tabname.' set approvestatus="'.$approvestatus.'",approveby="'.$current_user->id.'",approvetime="'.date("Y-m-d H:i:s").'",currentapprovestepid="'.$approvelog['stepid'].'",currentapprover="'.$currentapprover.'" where '.$tabindex.' = '.$approvelog['crmid'];
        }

        $adb->pquery($query,array());

        if($adb->database->_errorMsg!='')
        {
            $errormsg=$adb->database->_errorMsg;
            unset($adb);
            $adb = new PearDatabase();;//::getInstance();
            $adb->connect();
            $adb->pquery($query,array());
            // $sql='insert into ld_adblog(errormsg,crmid,createdtime,`sql`)value(?,?,?,?)';
            //$adb->pquery($sql,array($errormsg,$approvelog['crmid'],date("Y-m-d H:i:s"),$query));

        }


        if($pickcolumnname!=''&&$modulestatus!='undefined')
        {
            $focus->retrieve_entity_info($approvelog['crmid'], $module);
            $focus->getModuleStatic('ModTracker');//字段修改日志
            //edit:duan date:2024/10/22 reason:字段值发生变化时增加修改日志
            if($modulestatus != $focus->column_fields[$pickfieldname]){
                $focus->modstatic->saveFieldLogOne($module,$pickfieldname,$approvelog['crmid'],$focus->column_fields[$pickfieldname], $modulestatus);
            }
            //修改下拉框赋值
            $query=" update ".$picktablename ." set $pickcolumnname='".$modulestatus."' where ".$focus->tab_name_index[$picktablename].'=?';
            $adb->pquery($query,array($approvelog['crmid']));
        }

        global $modulestatus_now;
        $modulestatus_now = $modulestatus;
        //回调函数
        $focus = CRMEntity::getInstance($module);

        if(3 == $approvelog['approveresult']){//已拒绝，审批失败
            $focus->failedApproved($approvelog['crmid']);
        }

        elseif(4 == $approvelog['approveresult']||$_REQUEST['setype']=='cancel'){
            //已驳回,不通过返回负责人,回撤到上一步，使用新的流程重新流转等等
            //$_REQUEST['setype']=='cancel'一定要添加，因为反审批有$approvelog['approveresult']=1
            $focus->rejectApproved($approvelog['crmid']);
        }

        elseif(2 == $approvelog['approveresult']){//已批准
            $focus->id = $approvelog['crmid'];
            $focus->successApprove($approvelog['crmid']);
            $focus->retrieve_entity_info($approvelog['crmid'], $module);
            $focus->save_workflow($module,$focus,'Approved');
            //edit:can 49411: 【融君】V8.4.5.4（无外网）服务合同审批通过后，客户的最晚服务到期日没有更新，但是驳回后重新审批又成功更新了，例：SXRJ0292、SXRJ0400（详情见说明）
            //批量审批两个或两个以上服务合同 ，这些服务合同的客户如果不一样,其中有的客户是无法更新最晚服务到期日
            $focus->column_fields['account_id']=0;
        }

        //elseif(1== $approvelog['approveresult'] && 'Project' == $module)
        elseif(1== $approvelog['approveresult']||$approvelog['approveresult']==6 ){

            if('Project' == $module){
                $focus->approveding($approvelog['crmid']);
            }
        }

        if(!empty($pagemode)&&$adb->num_rows($workflowreverseobj->workflowresut)>0)
        {

            $workflowreverseobj->setRecord($approvelog['crmid']);

            $focus->column_fields['approvestatus']=$approvestatus;

            $focus->column_fields['currentapprover']=$currentapprover;
            $focus->column_fields['approveby']=$current_user->id;
            $workflowreverseobj->setPageMode($pagemode);
            if (!isset($_REQUEST['batckapproved']) && $workflowreverseobj->checkCallApiPop() == 'yes') //审批中心批量审批
                $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));
            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$focus->column_fields,$pagemode);
            $stepinfo['workflow']['before_save_infos'] = $beforefieldvalue_arr;
            $stepinfo['workflow']['after_save_infos'] = $focus->column_fields;
            if (isset($_REQUEST['batckapproved']) && $workflowreverseobj->checkCallApiPop() == 'yes'){
                $stepinfo['workflow']['callapimsg_arr'] = $workflowreverseobj->getExecResultData();
            }
        }

        require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
        $appremindObj = new ApproveRemind();
        $approvelog['nextstepapproveby']=$currentapprover;//edit:can 20210625 45144: （81mis.com/kfbcrm）客户管理-跟进记录；单据编号LXJL2，审批流“初级并发审批”，流程中审批人默认是单据负责人，提交审批时将审批人改为了"夏至"，通过一级并发后，二级并发的待审批提醒发给了单据负责人
        // dump($approvelog);
        $approvelog['approvelogid'] = $approvelogid;
        $appremindObj->CreateMultiApproveReminds($module,$approvelog);
        if($_REQUEST['new_concurrentidStepCount']>1)
        {
            /*for($i=0;$i<$_REQUEST['new_concurrentidStepCount'];$i++)
            {
                $approvelog_arr=$approvelog;
                 $appremindObj = new ApproveRemind();
                 $approvelog_arr['stepid']=$_REQUEST['nextstep_'.$i];
                 $approvelog_arr['nextstepid']=$_REQUEST['nextstep_'.$i];
                 $approvelog_arr['nextstepapproveby']=$_REQUEST['userid_'.$i];
                $appremindObj->CreateMultiApproveReminds($module,$approvelog_arr);
            }*/
        }
        //duan 20240326自动跳过的步骤也需要发送提醒
        /*
        $tmp_arr = $approvelog;
        if(sizeof($stepobj->skipstepinfo)>=0){
            foreach ($stepobj->skipstepinfo as $tmp_info){
                $tmp_arr['stepid']=$tmp_info['curstepid'];
                $tmp_arr['nextstepid']=$tmp_info['nextstepid'];
                $tmp_arr['approvesult']=10;
                $tmp_arr['nextstepapproveby']=$currentapprover;
                $appremindObj->CreateMultiApproveReminds($module,$tmp_arr);
            }
        }
        */

        //批量循环
        $_REQUEST['new_concurrentidStepCount']=0;
        $_REQUEST['concurrentidStepCount']=0;

        //ls 2021-08-11  【ID1001881】航港：加急（优先）审批
        if ($urgent == 'yes' && !empty($prevapproveid) && !empty($approvelogid))
            $adb->pquery("update ld_approvelog set urgent=? where crmid=? and  id >=? and approveid=? "
                ,array($urgent,$approvelog['crmid'],$prevapproveid,$approvelog['approveid']));//更新最新审批步骤的审批日志urgent的值（并发审批多条记录）
        //判断审批人为空时执行
        if((sizeof($stepobj->skipstepinfo)<=0||$stepinfo['nextstepid']<=0) && $with_concurrent!='yes'){

        }


        return $stepinfo;
    }
    /**
     * edit:kevin
     * date:2013-09-23
     * reason:单据编辑
     */
    public function EditBlocks($smownerid,$record){
        global $current_user;
        $blockbuttons = $this->approveobj->blocksButton($smownerid,$record);
        $isedit = $blockbuttons[0];
        $approvestatus = $blockbuttons[4];
        if($isedit == 0){
            $alertstr = "###SUCCESS###";
        }
        else{
            if(empty($approvestatus)){
                $alertstr="###SUCCESS###";
            }
            else{

                $setype = getSalesEntityType($record);

                $deployarray=getSys_Approvedeploy($setype);
                $num = $deployarray['deploy_value'];
                if($num == 0)
                {
                    $alertstr="###SUCCESS###";
                }
                else
                {
                    switch($approvestatus){
                        case 1:
                            $alertstr="###APPROVE###".getFixedLabel('THERECORDPROCESSEDING');
                            break;
                        case 2:
                            $alertstr="###APPROVE###".getFixedLabel('THERECORDAPPROVED');
                            break;
                        case 3:
                            $alertstr="###APPROVE###".getFixedLabel('THERECORDEDITING');
                            break;
                    }
                }

            }
        }
        return $alertstr;
    }
    /**
     * 【费用报销单】、【提现单】、【存现单】反审批后账户反写
     * @param String $module 模块名
     * @param Array $approvelog 审批历史保存信息
     * @param String $record 单据ID
     * @param String $type 判断是否调用SaveApprovedLog修改审批状态
     * Array(
     *	   crmid,//数据ID
     *     approveid,//审批流程
     *     stepid,//审批步骤
     *     approved_by,当前审批人
     *     approveresult,当前审批类型（通过、驳回、已审批等）
     *     description,//审批备注
     *     nextstepid,//下一步审批步骤
     *     nextstepapproveby,//下一步审批人
     * )
     *
     * @project 反审批后，银行账户的金额没有反算。
     * @author andrew 2015-5-12
     */
    public function ApprovedcheckBankMonery($module,$approvelog,$record,$type='') {
        global $current_user,$adb;
        if($module=='PutCash'){
            $smongysql = "SELECT inaccount,outaccount,cashmoney,approvestatus FROM ld_putcash WHERE putcashid=$record";
            $result = $adb->pquery($smongysql);
            $account = $adb->query_result($result,0,'outaccount');
            $monery = $adb->query_result($result,0,'cashmoney');
            $account2 = $adb->query_result($result,0,'inaccount');
            $approvestatus = $adb->query_result($result,0,'approvestatus');
            if($approvestatus == constant('D_A_S_APPROVED')){//'已批准'
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account";
                $adb->pquery($usql,array());
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE bankaccountsetid=$account2";
                $adb->pquery($usql,array());
            }
        }elseif($module=='CashDeposit'){
            $smongysql = "SELECT inaccount,cashmoney,outaccount,approvestatus FROM ld_cashdeposit WHERE cashdepositid=$record";
            $result = $adb->pquery($smongysql);
            $account = $adb->query_result($result,0,'inaccount');
            $monery = $adb->query_result($result,0,'cashmoney');
            $account2 = $adb->query_result($result,0,'outaccount');
            $approvestatus = $adb->query_result($result,0,'approvestatus');
            if($approvestatus == constant('D_A_S_APPROVED')){//'已批准'
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-$monery WHERE bankaccountsetid=$account";
                $adb->pquery($usql,array());
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account2";
                $adb->pquery($usql,array());
            }
        }elseif($module=='Expense'){
            $smongysql = "SELECT bankaccountsetid,total,approvestatus FROM ld_expense WHERE expenseid=$record";
            $result = $adb->pquery($smongysql);
            $account = $adb->query_result($result,0,'bankaccountsetid');
            $monery = $adb->query_result($result,0,'total');
            $approvestatus = $adb->query_result($result,0,'approvestatus');
            if($approvestatus == constant('D_A_S_APPROVED')){//'已批准'
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account";
                $adb->pquery($usql,array());
            }
        }elseif($module=='Commission'){
            $smongysql = "SELECT bankaccountsetid,total,approvestatus FROM ld_commission WHERE commission_id=$record";
            $result = $adb->pquery($smongysql);
            $account = $adb->query_result($result,0,'bankaccountsetid');
            $monery = $adb->query_result($result,0,'total');
            $approvestatus = $adb->query_result($result,0,'approvestatus');
            if($approvestatus == constant('D_A_S_APPROVED')){//'已批准'
                $usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$monery WHERE bankaccountsetid=$account";
                $adb->pquery($usql,array());
            }
        }
        if($type!='nosave'){

            $this->approveobj->SaveApprovedLog($module,$approvelog);

        }

    }

    /**
     * 通过ID自动审批单据
     * @param Integer $record ID值
     * @param Integer $approvedtype 审批通过或返回负责人
     * @param String $description 备注
     * @author Tujt 2015-05-11
     */
    public function SaveRecordApproveLog($record,$approvedtype,$description = '',$approvelog_result=null) {
        global $adb,$current_user,$approvestepinfo_arr;
        //$approvestepinfo_arr:某个审批流程下所有的审批步骤信息
        //1、通过ID获取对应的模块名
        $query = 'select crmid,setype from ld_crmentity where crmid in ('.$record.'); ';
        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $successcount=0;

        $fldmodarr = array();$fld_module = '';$mes = '';
        if($rows > 0){
            for($i=0;$i<$rows;++ $i){
                $crmid = $adb->query_result($result,$i,'crmid');
                $setype = $adb->query_result($result,$i,'setype');
                $fldmodarr[$crmid] = $setype;
                //优化批量审批代码，将单据对应超链接字段名移出来
                $entityarray = getEntitynameInfo(getTabid($setype));
                $tabname = $entityarray['tablename'];
                $tabindex = $entityarray['entityidfield'];
                $tabfieldname = $entityarray['fieldname'];
                $query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.'='.$crmid;
                $res = $adb->pquery($query);
                $num_rows = $adb->num_rows($res);
                for($j = 0; $j<$num_rows; $j++){
                    $subject[$crmid]['subject'] = $adb->query_result($res,$j,'subject');
                }
            }
        }

        $result = $approvelog_result;
        $rows = $adb->num_rows($result);
        $approvelog = array();
        $err_mes = getFixedLabel('documenterrorinfo');
        $suc_mes = getFixedLabel('DOCUMENTSUCCESS');
        if(1 != $approvedtype){//3、已驳回，返回负责人

            if($rows > 0){
                //duan 20230112 批量反审批 时增加验证规则判断
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($setype,0,0);
                $PageValidataSaveobj->setApplication('cancel');
                $PageValidataSaveobj->batchoprate = 'yes';
                
                for($i=0;$i<$rows;++ $i){
                    $crmid = $adb->query_result($result,$i,'crmid');

//                    $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');//表示是否为并发步骤
                    if(!isset($fldmodarr[$crmid])) continue;
                    $fld_module = $fldmodarr[$crmid];
                    /*$fld_focus = CRMEntity::getInstance($fld_module);
                    $entityarray = getEntitynameInfo(getTabid($fld_module));
                    $tabname = $entityarray['tablename'];
                    $tabindex = $entityarray['entityidfield'];
                    $tabfieldname = $entityarray['fieldname'];
                    $query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.$crmid.')';
                    $res = $adb->pquery($query);
                    $num_rows = $adb->num_rows($res);
                    for($j = 0; $j<$num_rows; $j++){
                        $subject[$crmid]['subject'] = $adb->query_result($res,$j,'subject');
                    }*/
                    $approveresult = $adb->query_result($result,$i,'approveresult');//审批类型
                    //43703: （http://51mis.com/ys/lwljzgc/ [^]）客户问题（蔡云桥），演示账套（建筑工程行业演示账套），审批中心->待审批页签，点击材料采购单【开始处理】，待审批单据列表显示没有数据
                    if(in_array($approveresult,array(2,3,4))){	//已驳回、已批准、已拒绝等状态不可以批量审批
                        $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('dismissalapprovalrejecton')).'<br>';
                        continue;
                    }
                    $nextstepid = $adb->query_result($result,$i,'nextstepid');//下一步审批步骤
                    if(!$nextstepid){	//下一步审批步骤为空，则跳过
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('thenextstepofapproveisempty')).'<br>';
                        continue;
                    }
                    //批量反审批时增加验证规则判断，先判断阻断操作的验证规则
                    $PageValidataSaveobj->resetobj($fld_module,$crmid);//重置验证规则对象
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),$PageValidataSaveobj->errortip).'<br>';
                        continue;
                    }
                    
                    $approvelog['crmid'] = $crmid;//数据ID
                    $approvelog['approveid'] = $adb->query_result($result,$i,'approveid');//审批步骤ID
                    $approvelog['stepid'] = $nextstepid;//审批流程ID取上一部审批的下次审批流程值
                    $approvelog['approved_by'] = $current_user->id;//审批人
                    $approvelog['approveresult'] = 4;//已驳回
                    $approvelog['description'] = $description;//备注
                    $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
                    $currentapprover=$adb->query_result($result,$i,'currentapprover');
                    $nextuserids=explode(",",$currentapprover);
                    if(!in_array($current_user->id,$nextuserids))//如果当前步骤不在下一步审批人中，则跳过
                    {
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('thecurrentuserisnotinthenextapprover')).'<br>';
                        continue;
                    }
                    //判断允许保存的验证规则
                    $PageValidataSaveobj->setAllowSave('yes');
                    $PageValidataSaveobj->resetinfo = 'yes';
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
                    }else{
                        $validata_errortip = '';
                    }

                    $mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
                    $successcount++;

                    $flowinfo = $this->approveobj->SaveApprovedLog($fld_module,$approvelog);
                    $callapimsg_arr = $flowinfo['workflow']['callapimsg_arr'];//工作流的调用API提示
                    if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                        $mes .= implode('<br>',$callapimsg_arr)."<br/>";
                    }
                }
            }
        }else{//4、通过，并进行下一步，如果已经是最后一步，则为已审批状态
            if($rows > 0){
                //duan 20230301 批量审批时增加验证规则判断
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($setype,0,0);
                $PageValidataSaveobj->setApplication('finish');
                $PageValidataSaveobj->batchoprate = 'yes';//批量操作
                //duan 20230718批量通过修改审批必填字段判断
                crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
                $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($setype);

                $approvestepinfo_arr=[];
                $nextapproveinfo = array();
                $concurrentstep_arr=[];
                global $selectapprovecrmid_len;//edit:can 20220714 项目信息表（Potentials模块）-项目编号：22-190466-0002A-3524 ，目前该项目使用的是【项目立项】审批流
                $selectapprovecrmid_len=$rows;
                for($i=0;$i<$rows;++ $i){
                    $crmid = $adb->query_result($result,$i,'crmid');
                    $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');//表示是否为并发步骤
                    $approveid=$adb->query_result($result,$i,'approveid');
                    $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
                    $nextstep_countersigner=$adb->query_result($result,$i,'nextstep_countersigner');
                    $currentapprover=$adb->query_result($result,$i,'currentapprover');
//                    $all_crmid[] = $crmid;
                    if(!isset($fldmodarr[$crmid])) continue;

                    $fld_module = $fldmodarr[$crmid];

                    $approveresult = $adb->query_result($result,$i,'approveresult');//审批类型
                    //edit:can 2020-12-28 043978: (61mis.com/kfbcrm)审批中心-合同订单；成员Q 单据编号SO65，SO172，批量审批通过时，提示审批状态已改变，审批失败
                    if(!in_array($approveresult,array(1,5,6,10,14,15,16,17,18))&&empty($logconcurrentid))
                    {
                        /*$fld_focus = CRMEntity::getInstance($fld_module);
                        $tmptablename=$fld_focus->table_name;
                        $tmptable_index=$fld_focus->table_index;
                        $linkfield= $fld_focus->list_link_field;
                        $sql="select $linkfield from $tmptablename where $tmptable_index=?";
                        $tmpresult=$adb->pquery($sql,array($crmid));
                        $tmpsubject=$adb->query_result($tmpresult,0,$linkfield);*/
                        $err_mes="审批状态已改变";
                        $mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes."<br>";
                        continue;//已驳回、已批准、已拒绝等状态不可以批量审批
                    }
                    $nextstepid = $adb->query_result($result,$i,'nextstepid');//获取审批日志下一步审批步骤，实际为下一个审批日志的当前步骤
                    $curstepid=$nextstepid;

                    if($logconcurrentid>0)
                    {
                        $tmp_approveinfo=$this->approveobj->approveStatus($crmid);//获取单据的最后一条审批历史记录
                        //获取审批日志下一步审批步骤，实际为下一个审批日志的当前步骤
                        $nextstepid=$tmp_approveinfo['stepid'];//并发步骤的stepid和nextstepid值一样
                        $curstepid=$nextstepid;
                        //是并发步骤
                        //是否为并发步骤的最后一步，yes:是
                        $islastconcurrentstep=$this->approveobj->getisLastStepConcurrent($crmid,$logconcurrentid,$approveid);



                    }
                    else{
                        $islastconcurrentstep='yes';
                    }

                    if($islastconcurrentstep=='yes')
                    {
                        //是并发步骤的最后的步骤或者下一个步骤
                        if(!array_key_exists($approveid,$approvestepinfo_arr))
                        {

                            $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approveid);

                        }


                        foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                        {
                            if($tmpstepInfo['stepid']==$nextstepid)
                            {
                                $sequence=floor($tmpstepInfo['sequence'])+1;
                                break;
                            }
                        }
                        foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                        {
                            if($sequence>=1&&$tmpstepInfo['sequence']>=$sequence)
                            {
                                //获取下一步审批步骤信息
                                $concurrentid=$tmpstepInfo['concurrentid'];

                                // $nextstepid=$tmpstepInfo['stepid'];
                                $concurrentidStepCount=0;//并发的审批步骤个数
                                if($concurrentid>0)
                                {
                                    //下一步也是并发步骤
                                    foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                                    {
                                        if($tmpstepInfo['concurrentid']==$concurrentid)
                                        {
                                            $approvetype=$tmpstepInfo['approvetype'];
                                            $approvevalue=$tmpstepInfo['approvevalue'];
                                            $stepuserid=$this->approveobj->getApproveBy($approvetype,$approvevalue,$crmid);
                                            $concurrentstep_arr[$crmid]['concurrentinfo']['userid_'.$concurrentidStepCount]=$stepuserid;
                                            $concurrentstep_arr[$crmid]['concurrentinfo']['nextstep_countersigner_'.$concurrentidStepCount]=$tmpstepInfo['countersigner'];
                                            $concurrentstep_arr[$crmid]['concurrentinfo']['nextstep_augmentsinger_'.$concurrentidStepCount]=$tmpstepInfo['augmentsinger'];
                                            $concurrentstep_arr[$crmid]['concurrentinfo']['stepseq_'.$concurrentidStepCount]=$concurrentidStepCount;
                                            $concurrentstep_arr[$crmid]['concurrentinfo']['nextstep_'.$concurrentidStepCount]=$tmpstepInfo['stepid'];
                                            $concurrentidStepCount++;
                                        }
                                    }
                                    $concurrentstep_arr[$crmid]['concurrentidStepCount']=$concurrentidStepCount;
                                    //$_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
                                }
                                else if($logconcurrentid>0){
                                    //已经判断是并发步骤最后一步了
                                    //并发步骤的第一个步骤，最后审批，需要重新获取nextstepid;
                                    if($tmpstepInfo['stepid']>0)//大于零，是判断是否为审批流程的最后一步
                                    {
                                        $nextstepid=$curstepid;//$tmpstepInfo['stepid'];

                                        $approvelog[$crmid]['nextstepid']=$curstepid;
                                        $nextstep_countersigner=$tmpstepInfo['countersigner'];
                                    }


                                }
                                break;
                            }
                        }

                    }


                    if(!$nextstepid)
                    {
                        $err_mes="当前审批步骤为空！";

                        $mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes."<br>";

                        continue;//下一步审批步骤为空，则跳过
                    }

                    $nextuserids=explode(",",$currentapprover);
                    if(!in_array($current_user->id,$nextuserids))//如果当前步骤不在下一步审批人中，则跳过
                    {
                        $err_mes="登录用户不在下一步审批人中!";

                        $mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes;
                        continue;
                    }
                    //批量审批时增加验证规则判断，先判断阻断操作的验证规则
                    $PageValidataSaveobj->resetobj($fld_module,$crmid);//重置验证规则对象
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $err_mes = getFixedLabel('documenterrorinfo');
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),$PageValidataSaveobj->errortip).'<br>';
                        continue;
                    }
                    
                    $approveid = $adb->query_result($result,$i,'approveid');
                    $approvelog[$crmid]['islastconcurrentstep']=$islastconcurrentstep;
                    //将审批日志保存信息按crmid放入数组中
                    $approvelog[$crmid]['crmid'] = $crmid;//数据ID
                    $approvelog[$crmid]['approveid'] = $approveid;//当前审批步骤ID
                    $approvelog[$crmid]['stepid'] = $curstepid;//当前审批流程ID

                    $approvelog[$crmid]['countersigner']=$nextstep_countersigner;
                    $approvelog[$crmid]['cur_stepapproveby']=$nextstepapproveby;
                    $approvelog[$crmid]['logconcurrentid']=$logconcurrentid;
                    $approvelog[$crmid]['approved_by'] = $current_user->id;//当前审批人
                    $approvelog[$crmid]['approveresult'] = 1;//通过（也可能是已审批，不在此处判断）
                    $approvelog[$crmid]['description'] = $description;//备注
                    $approvelog[$crmid]['approvelogid']=0;

                    if($logconcurrentid>0)
                    {
                        $query="SELECT
                          ld_approvelog.approveresult,ld_approvelog.nextstepapproveby,
                         ld_approvelog.id FROM ld_approvelog
                          left JOIN ld_approve ON ld_approve.id = ld_approvelog.approveid
                          inner join ld_approvestep on ld_approvestep.id=ld_approvelog.stepid
                        WHERE ld_approvelog.crmid =?  and ld_approvelog.logconcurrentid=? and ld_approvelog.isfinished='no'
                        and FIND_IN_SET(?,nextstepapproveby)
                                        ORDER BY ld_approvelog.seqtime desc,ld_approvelog.stepseq asc,ld_approvelog.createdtime desc,ld_approvelog.id asc
                                        LIMIT 1 ";
                        $tmpresult=$adb->pquery($query,array($crmid,$logconcurrentid,$current_user->id));

                        $approvelog[$crmid]['approvelogid']=$adb->query_result($tmpresult,0,'id');
                    }

                    //将当前提交的审批流程ID统一放到数组中
                    $nextapproveinfo['approveid'][$approveid] = $approveid;
                    //保存每一个crmid对应的审批流程approveid、审批步骤stepid
                    $nextapproveinfo['stepid'][$crmid]['approveid'] = $approveid;
                    $nextapproveinfo['stepid'][$crmid]['stepid'] = $nextstepid;


                }


                //5、获取对应审批流程ID全部审批步骤以及对应的审批人
                if (isset($nextapproveinfo['approveid']) && !empty($nextapproveinfo['approveid'])) {
                    $approvesql = join(',',$nextapproveinfo['approveid']);
                    $query = 'select approveid,id,approvevalue from ld_approvestep 
							where approveid in ('.$approvesql.') ORDER BY sequence;';
                    $result = $adb->pquery($query,array());
                    $rows = $adb->num_rows($result);
                    $approvestep = array();
                    if($rows > 0){
                        for($i=0;$i<$rows;++ $i){
                            $approveid = $adb->query_result($result,$i,'approveid');
                            $stepid = $adb->query_result($result,$i,'id');
                            $approvetype = $adb->query_result($result,$i,'approvetype');
                            $approvevalue = $adb->query_result($result,$i,'approvevalue');
                            //一个审批流程ID对应多个审批步骤，放入一个数组中，方便查找下一步审批步骤
                            $approvestep['approve'][$approveid][] = $stepid;
                            //审批流程对应的审批人，统一放入数组中
                            $approvestep['user'][$stepid] = $this->approveobj->getApproveBy($approvetype,$approvevalue,$crmid);
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
                    /*$entityarray = getEntitynameInfo(getTabid($fld_module));
                    $tabname = $entityarray['tablename'];
                    $tabindex = $entityarray['entityidfield'];
                    $tabfieldname = $entityarray['fieldname'];
                    $query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.implode(',',$all_crmid).')';
                    $result = $adb->pquery($query);
                    $num_rows = $adb->num_rows($result);
                    for($i = 0; $i<$num_rows; $i++){
                        $crmid = $adb->query_result($result,$i,$tabindex);
                        $subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
                    }*/

                    //6、循环每一个crmid对应的审批流程和步骤
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
                        if($islastconcurrentstep=='no'&&$logconcurrentid>0)
                        {
                            //并发审批
                            $approveseq = array_search($approveinfo['stepid'],$approvestep['approve'][$approveinfo['approveid']]);
                        }
                        //存在下一步审批步骤，取出审批步骤ID和审批人信息
                        if(!isset($fldmodarr[$crmid])) continue;
                        if(isset($approvestep['approve'][$approveinfo['approveid']][$approveseq])){


                            if(!is_array($tmp_nextstep_user_arr)||sizeof($tmp_nextstep_user_arr)<=1){
                                $stepid = $approvestep['approve'][$approveinfo['approveid']][$approveseq];
                                $approvelog[$crmid]['nextstepid'] = $stepid;

                                $approvelog[$crmid]['nextstepapproveby'] = $approvestep['user'][$stepid];
                            }
                            else{
                                //会签步骤有多个人，则继续使用该会签步骤
                                $approvelog[$crmid]['nextstepid'] = $cur_stepid;
                                $tmp_nextstep_user='';//
                                foreach($tmp_nextstep_user_arr as $tmpuserid){
                                    if($tmpuserid==$current_user->id){
                                        continue;
                                    }
                                    $tmp_nextstep_user.=','.$tmpuserid;
                                }
                                $approvelog[$crmid]['nextstepapproveby'] = trim($tmp_nextstep_user,',');

                            }
                        }else{//没有下一步审批步骤，说明当前这一步审批步骤直接结束流程
                            $approvelog[$crmid]['approveresult'] = 2;//标注为已审批

                        }

                        if($approvelog[$crmid]['logconcurrentid']>0)
                        {
                            //重算并发步骤的stepid和nextstepid
                            $approvelog[$crmid]['nextstepid']=$approvelog[$crmid]['stepid'];
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
                                $isapprovesteplast='yes';
                                foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                                {
                                    if($tmpstepInfo['sequence']>=$tmpsequence)//获取当前步骤的下一个步骤
                                    {
                                        $approvelog[$crmid]['nextstepid']=$tmpstepInfo['stepid'];
                                        $isapprovesteplast='no';
                                        break;
                                    }
                                }
                                if($isapprovesteplast=='yes')
                                {
                                    //审批流程的最后一步
                                    $approvelog[$crmid]['approveresult'] = 2;//标注为已审批
                                    $approvelog[$crmid]['nextstepid'] = '';//标注为已审批
                                }


                            }
                        }

                        $fld_module = $fldmodarr[$crmid];
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
                        $approvestepinfo=$this->approveobj->getStepInfo($approvelog[$crmid]['stepid']);//审批步骤信息

                        if($approvestepinfo['approveremarkrequire'] =="yes" && trim($approvelog[$crmid]['description'])=='')//判断当前步骤审批意见必填时，审批意见是否为空
                        {
                            $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'), getFixedLabel('APPROVEREMARKREQUIRE')).'<br>';

                            //$mes .=sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVEREMARKREQUIRE')).'<br>';
                            continue;
                        }
                        //批量审批通过时,增加需要的必填字段判断
                        $choose_fieldname_arr = $mandatoryfieldobj->getMandatoryFieldByApprovesult($approvelog[$crmid]['stepid'],1);
                        $module_status = $this->approveobj->getModuleRecordStatus(implode(',',$choose_fieldname_arr),$crmid,$fld_module,'pc');

                        if($module_status=='no')
                        {
                            //edit:can 2021-01-05 43803: （61mis.com/kfbcrm）审批必填：OA表单-常用审批单；单据编号PTSP43，在审批中心操作批量审批单据，没有提示必填字段
                            $mes .= '<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="OpenTabDetailView(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>['.getFixedLabel('approvesetrequiredfield').']<br>';

                            continue;
                        }

                        if ($approvelog[$crmid]['approveresult'] == 2) {
                            //ls 20221201 XUQIU1000685  增加审批功能（盘点单、调拨单审批中心批量审批成功时，前置条件判断）
                            if ($fld_module == 'Checks') {
                                crm_load_class_file('CommonStock','include/Stock');
                                $infos = getChecksProductInfo($crmid,1,selCheckInfo($crmid,2));
                                if (sizeof($infos)>0) {
                                    $error_mes_warehouse = implode('',$infos['list']);
                                    $error_mes_warehouse = rtrim($error_mes_warehouse,'<br>');
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),'<br>'.$error_mes_warehouse).'<br>';
                                    continue;
                                }
                            } elseif ($fld_module == 'WareHouseTransfer') {
                                crm_load_class_file('CommonStock','include/Stock');
                                $fld_focus->retrieve_entity_info($crmid, $fld_module);
                                $outwarehouse = $fld_focus->column_fields['outwarehouse'];//调出仓库ID
                                $inwarehouse = $fld_focus->column_fields['inwarehouse'];//调入仓库ID
                                if($inwarehouse == $outwarehouse) {
                                    //调入和调出仓库不能一致
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('INANDOUTNOTSAME')).'<br>';
                                    continue;
                                }
                                elseif(is_admin($current_user) === false && getUserWarehouseStatus($inwarehouse) == false && getUserWarehouseStatus($outwarehouse) ==false)
                                {    //对仓库没有权限
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT')).'<br>';
                                    continue;
                                }else{
                                    if($deploy_value_48==0) {
                                        //产品A出库数量大于当前批次号产品数量
                                        $tmps= getMinZero_Batchtext_whenApprove('WareHouseTransfer',$crmid);
                                        if(is_array($tmps)&&sizeof($tmps)>0)
                                        {
                                            $error_mes_warehouse = '';
                                            foreach($tmps as $index=>$content) {
                                                $productname=$content['productname'];
                                                $error_mes_warehouse.=str_replace('{productname}','"'.$productname.'"',getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH'))."<br>";
                                            }
                                            $error_mes_warehouse = rtrim($error_mes_warehouse,'<br>');
                                            $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),'<br>'.$error_mes_warehouse).'<br>';
                                            continue;
                                        }
                                    }
                                }
                            }
                        }
                        
                        //判断允许保存的验证规则
                        $PageValidataSaveobj->setAllowSave('yes');
                        $PageValidataSaveobj->resetobj($fld_module,$crmid);
                        $PageValidataSaveobj->getValidDataInfoPhp();
                        if(!empty($PageValidataSaveobj->errortip)){
                            $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
                        }else{
                            $validata_errortip = '';
                        }
                        
                        if($fld_module == 'OutboundOrder' && $deploy_value_48 != 1 && $deploy_value_101 != 1){
                            if($approvelog[$crmid]['approveresult'] == 2){
                                $res = $fld_focus->getInventoryProductForWareQty($crmid);
                                if($res == 'yes'){
                                    $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('USERSAVEFAIL')).$validata_errortip.'<br>';
                                }
                                else{
                                    $mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
                                    $successcount++;
                                    $flowinfo = $this->approveobj->SaveApprovedLog($fld_module,$approvelog[$crmid]);
                                }
                            }else{
                                $mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
                                $successcount++;
                                $flowinfo = $this->approveobj->SaveApprovedLog($fld_module,$approvelog[$crmid]);
                            }
                        }else{
                            $mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
                            $successcount++;

                            $flowinfo = $this->approveobj->SaveApprovedLog($fld_module,$approvelog[$crmid]);
                        }

                        $callapimsg_arr = $flowinfo['workflow']['callapimsg_arr'];//工作流的调用API提示,拼接消息
                        if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                            $mes .= implode('<br>',$callapimsg_arr)."<br/>";
                        }

                    }
                }
            }
        }

        if (!isset($_SESSION[$current_user->id . '_Approve_batchapproved']['correct'])) {
            $_SESSION[$current_user->id . '_Approve_batchapproved']['correct'] = 0;
        }
        $_SESSION[$current_user->id . '_Approve_batchapproved']['correct'] += $successcount;
        $_SESSION[$current_user->id . '_Approve_batchapproved']['edit_err'] .= $mes;


        return $mes;
    }
}