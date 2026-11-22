<?php
/*
 * edit:duan
 * reason:审批必填字段操作类
 * date:20230717
 * */
class cls_ApproveMandatoryField
{
    public $approveid;
    public $stepid;
    public $record;
    public $module;
    public $db;
    public $user;
    public $approvereulst_arr;
    public $withattachment;
    public  $CommonEditFieldobj;
    public function __construct($module)
    {
        global $adb,$current_user;
        $this->db = $adb;
        $this->module=$module;
        $this->user = $current_user;
        //设置审批结果和审批方式的对应关系
        $this->approvereulst_arr = [];
        $this->approvereulst_arr['pass'] = [1,2];
        $this->approvereulst_arr['back'] = [4,5];
        $this->approvereulst_arr['reject'] = [3];
        $this->approvereulst_arr['addsign'] = [6];
        //调用通用字段编辑类
        crm_load_class_file('cls_Common_EditField','modules/lingdang');
        $this->CommonEditFieldobj = cls_Common_EditField::getInstance($module);
        $this->CommonEditFieldobj->setMandatoryField('yes');//把所有的字段设为必填
        $this->CommonEditFieldobj->setEmptyFieldOnly('yes');//审批必填字段只显示不为空的字段Invoice
    }

    public static function getInstance($module)
    {
        static $static_approve_mandatoryfieldobj_arr;
        if(is_array($static_approve_mandatoryfieldobj_arr)&&array_key_exists($module,$static_approve_mandatoryfieldobj_arr))
        {
            return $static_approve_mandatoryfieldobj_arr[$module];
        }
        if(!is_array($static_approve_mandatoryfieldobj_arr))
        {
            $static_approve_mandatoryfieldobj_arr=[];
        }
        $static_approve_mandatoryfieldobj_arr[$module]=new cls_ApproveMandatoryField($module);
        return $static_approve_mandatoryfieldobj_arr[$module];
    }
    //根据审批方式判断需要必填的字段信息
    public function getMandatoryFieldByApprovesult($stepid,$approvereulst){
        //读取所有的必填字段
        $mandatoryfield_str = cls_ApproveMandatoryField::getMandatoryField($stepid);

        $mandatoryfield_arr = ldcrm_json_decode($mandatoryfield_str);
        //根据审批结果获取需要的审批方式
        $approvefunc = 'pass';
        foreach ($this->approvereulst_arr as $tmp_key => $tmp_arr){
            if(in_array($approvereulst,$tmp_arr)){
                $approvefunc = $tmp_key;
                break;
            }
        }

        //根据审批方式获取需要的必填字段
        //$focus = CRMEntity::getInstance($this->module);
        $choose_fieldname_arr = [];

        foreach ($mandatoryfield_arr as $tmp_arr){
            $tmp_approve_func = $tmp_arr['approvefunc'];
            if($tmp_approve_func == $approvefunc){
                $tmp_fieldname_str = $tmp_arr['mandatoryfield'];
                $tmp_fieldname_arr = explode(',',$tmp_fieldname_str);

                foreach ($tmp_fieldname_arr as $tmp_fullfieldname){
                    //解析完整的字段名,例如:ld_account:industry:industry:Accounts_fieldlabel:V
                    $tmp_arr = explode(':',$tmp_fullfieldname);

                    if(count($tmp_arr)>=3){
                        /* 如果选中的字段中包含分录的字段,则改用大编辑(暂时不做,留着以后拓展)
                        $tmp_tablename = $tmp_arr[0];
                        if($tmp_tablename == $focus->Detail_table || $tmp_tablename == $focus->Detail_table_scf){
                             return [];
                        }*/

                        $tmp_fieldname = $tmp_arr[2];
                        if(!in_array($tmp_fieldname,$choose_fieldname_arr)){
                            $choose_fieldname_arr[] = $tmp_fieldname;
                        }
                    }
                }
            }
        }

        return $choose_fieldname_arr;
    }

    //根据审批必填字段生成编辑字段的table
    public function CreateFieldHtml($record,$stepid,$approveresult){
        $choose_fieldname_arr = $this->getMandatoryFieldByApprovesult($stepid,$approveresult);
        if(sizeof($choose_fieldname_arr)<=0) {
            return  [];
        }
        //根据选中的字段生成需要的html
        $result = $this->CommonEditFieldobj->CreateFieldHtml($record,$choose_fieldname_arr);
        $this->withattachment = $this->CommonEditFieldobj->withattachment;
        $this->withselectsource = $this->CommonEditFieldobj->withselectsource;
        return $result;
    }
    //保存必填字段值
    public function  saveFieldValue($record,$fieldvaluejson){
        //调用通用方法保存必填字段值
        $this->CommonEditFieldobj->saveFieldValue($record,$fieldvaluejson);
    }

    //获取移动端编辑界面的字段信息
    public function getEditviewReturn($record,$approveinfo,$outputinfo){
        $stepid = $approveinfo['stepid'];
        $approvestatus = $approveinfo['approvestatus'];
        $choose_fieldname_arr = $this->getMandatoryFieldByApprovesult($stepid,$approvestatus);
        //根据选中的审批必填字段设置移动端编辑页面返回值
        $outputinfo = $this->CommonEditFieldobj->getEditviewReturn($record,$choose_fieldname_arr,$outputinfo);
        return $outputinfo;
    }

    //执行审批操作
    public function saveApproveLog($request_approveinfo){
        if(empty($request_approveinfo))return '';

        $adb = $this->db;
        $current_user = $this->user;
        $approvebyid=$current_user->id;

        $module=$frommodule = $request_approveinfo['fld_module'];
        $focus=cls_Instance::get_module_Instance($module);
        $moduleid=$focus->table_index;
        $tabname=$focus->table_name;
        if(isset($request_approveinfo['approvestatus']) && $request_approveinfo['approvestatus']!='')
            $approvestatus=$request_approveinfo['approvestatus'];

        require_once(globalStatic::$root_directory.'modules/Approve/Remind.php');

        crm_load_class_file("ApproveCommon","modules/Approve");
        $approvecommonobj = ApproveCommon::getInstance($module);
        $approveid = $request_approveinfo['approveid'];
        $approve = $approvecommonobj->getApproveobjByApproveid($approveid);

        $record=$request_approveinfo['record'];
        $approvelog = array();
        $approvelog['crmid'] = $request_approveinfo['record'];//数据ID
        $approvelog['approveid'] = $request_approveinfo['approveid'];//当前审批步骤ID

        $approvelog['stepid'] = $request_approveinfo['stepid'];//下拉框选择的步骤id
        $approvelog['nextstepid'] = $request_approveinfo['nextstep_0'];//下拉框选择的步骤id
        $approvelog['approved_by'] = $current_user->id;//当前审批人
        $approvelog['approveresult'] = $request_approveinfo['approvestatus'];//当前审批类型（通过、驳回等）
        $approvelog['description'] = $request_approveinfo['description'];//备注
        $approvelog['logconcurrentid']=$request_approveinfo['logconcurrentid'];//审批历史并发步骤id
        $approvelog['approvelogid']=$request_approveinfo['approvelogid'];//审批历史并发步骤id

        if(empty($approvelog['approveid'])){
            ConvertTojsonString(-1,array(),'参数错误:Approveid');
        }
        if(empty($approvelog['approveresult'])){
            ConvertTojsonString(-1,array(),'参数错误:Approveresult');
        }
        $tmp_info = $approvecommonobj->getApproveInfo($approveid);
        //判断是否需要重新生产审批人 会签和加签不需要考虑重新获取审批人的问题
        if($approvelog['approveresult']==1 && $approvelog['stepid'] != $approvelog['nextstepid']){
            $focus = CRMEntity::getInstance($module);
            $request_column = $_REQUEST['wx_fieldInfo'];
            $fieldobj = $focus->fieldobj;
            $fieldid_arr = [];
            foreach ($request_column as $tmp_fieldname=>$tmp_value){
                $tmp_fieldid = $fieldobj->getFieldInfoBykeyValue('fieldname',$tmp_fieldname,'fieldid');
                if($tmp_fieldid >0){
                    $fieldid_arr[] = $tmp_fieldid;
                }
            }
            $reset_approver = 'no';
            if($tmp_info['isnewapprove'] == 'yes' ){
                $nextstepinfo = $approve->getnextstepinfo($flowstepid,$request_approveinfo['stepid'],$approveid,$approvelog['crmid']);
                if($nextstepinfo['nextstepid'] <0){
                    $approvelog['nextstepid'] = '';
                    $approvelog['approveresult'] = 2;
                }else{
                    if($approvelog['nextstepid'] != $nextstepinfo['nextstepid']){
                        $approvelog['nextstepid'] = $nextstepinfo['nextstepid'];
                        $reset_approver = 'yes';
                    }
                    $next_stepinfo = $approve->getStepInfo($approvelog['nextstepid']);
                    $approvevalue = $next_stepinfo['approvevalue'];//下一步审批人
                    $approvetype =$next_stepinfo['approvetype'];//下一步审批人类型（指定用户，指定角色，部门等待)
                    $emptyapproverdeal=$next_stepinfo['emptyapproverdeal'];
                    //如果审批人是根据字段获取的,且编辑的字段中包含该字段，则在保存后重新获取一次审批人
                    if($approvetype > 6 && in_array($approvetype,$fieldid_arr)){
                        $reset_approver = 'yes';
                    }
                }
            }else{
                //普通流程需要重新获取一下审批人
                $next_stepinfo = $approve->getStepInfo($approvelog['nextstepid']);
                $approvevalue = $next_stepinfo['approvevalue'];//下一步审批人
                $approvetype =$next_stepinfo['approvetype'];//下一步审批人类型（指定用户，指定角色，部门等待)
                $emptyapproverdeal=$next_stepinfo['emptyapproverdeal'];
                //如果审批人是根据字段获取的,且编辑的字段中包含该字段，则在保存后重新获取一次审批人
                if($approvetype > 6 && in_array($approvetype,$fieldid_arr)){
                    $reset_approver = 'yes';
                }
            }
            if($reset_approver == 'yes'){
                $request_approveinfo['userid_0'] = $approve->getApproveBy($approvetype,$approvevalue,$approvelog['crmid'],$emptyapproverdeal);
            }
        }


        //editor:gyq_20191120 reason:增加$frommodule
        $frommodule = $request_approveinfo['fld_module'];
        $approveinfo=$approve->getlastapproveinfo($record,$frommodule);
        $issave='yes';
        $approveid=$approvelog['approveid'];

        if($request_approveinfo['approvestatus']==1||$request_approveinfo['approvestatus']==2)
        {
            $islastconcurrentstep='no';

            if($request_approveinfo['concurrentid']>0)
            {
                //表示进入了并发步骤

                $approvestepinfo_arr[$approvelog['approveid']]= $approve->getAllStepInfoByApproveid($approvelog['approveid']);

                $alltotalCount=sizeof($approvestepinfo_arr[$approvelog['approveid']]);
                $concurrentidStepCount=0;
                $i=-1;
                foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpstepinfo)
                {
                    $tmpconcurrentid= $tmpstepinfo['concurrentid'];
                    $i++;
                    if($tmpconcurrentid!=$request_approveinfo['concurrentid'])
                        continue;

                    $request_approveinfo['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];

                    $request_approveinfo['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
                    $request_approveinfo['nextstep_countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];
                    $request_approveinfo["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
                    $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
                    $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');

                    $request_approveinfo["userid_$concurrentidStepCount"]=$approve->getApproveBy($approvetype,$approvevalue,$record);
                    $request_approveinfo["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
                    $concurrentidStepCount++;
                }
                $request_approveinfo['concurrentidStepCount']=$concurrentidStepCount;
            }
            else if($request_approveinfo['logconcurrentid']>0)
            {
                $approvelog['logconcurrentid']=$request_approveinfo['logconcurrentid'];
                $islastconcurrentstep=$approve->getisLastStepConcurrent($record,$request_approveinfo['logconcurrentid'],$approvelog['approveid']);
                $logconcurrentid=$request_approveinfo['logconcurrentid'];
            }

            $approveid=$approvelog['approveid'];
            $crmid=$record;

            $lastapproveinfo=$approve->getlastapproveinfo($record,$module);
            if($islastconcurrentstep=='yes')
            {
                global $approvestepinfo_arr;
                //是并发步骤的最后的步骤或者下一个步骤
                if(!array_key_exists($approveid,$approvestepinfo_arr))
                {

                    $approvestepinfo_arr[$approveid]=$approve->getAllStepInfoByApproveid($approveid);

                }
                foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                {
                    //edit:can 49477: （http://124.225.200.21:85/crm [^] ）（海南爱恩）付款单FKD20211227-690使用流程：付款单选人审批流程审批时，三级审批后直接走五级审批跳过了四级，且四级审批的审批人变成了五级审批人
                    if($tmpstepInfo['stepid']==$approvelog['stepid'])
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



                        if($concurrentid>0&&$request_approveinfo['concurrentid']<=0)
                        {
                            $concurrentidStepCount=0;//并发的审批步骤个数
                            //下一步也是并发步骤
                            foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                            {
                                if($tmpstepInfo['concurrentid']==$concurrentid)
                                {
                                    $approvetype=$tmpstepInfo['approvetype'];
                                    $approvevalue=$tmpstepInfo['approvevalue'];
                                    $stepuserid=$approve->getApproveBy($approvetype,$approvevalue,$crmid);
                                    $request_approveinfo['userid_'.$concurrentidStepCount]=$stepuserid;
                                    $request_approveinfo['nextstep_countersigner_'.$concurrentidStepCount]=$tmpstepInfo['countersigner'];
                                    $request_approveinfo['nextstep_augmentsinger_'.$concurrentidStepCount]=$tmpstepInfo['augmentsinger'];
                                    $request_approveinfo['stepseq_'.$concurrentidStepCount]=$concurrentidStepCount;
                                    $request_approveinfo['nextstep_'.$concurrentidStepCount]=$tmpstepInfo['stepid'];
                                    $concurrentidStepCount++;
                                }
                            }
                            $request_approveinfo['concurrentidStepCount']=$concurrentidStepCount;

                        }
                        else if($logconcurrentid>0){

                            //已经判断是并发步骤最后一步了
                            //并发步骤的第一个步骤，最后审批，需要重新获取nextstepid;
                            if($tmpstepInfo['stepid']>0)//大于零，是判断是否为审批流程的最后一步
                            {


                                $approvelog['nextstepid']=$tmpstepInfo['stepid'];
                                $nextstep_countersigner=$tmpstepInfo['countersigner'];
                            }


                        }
                        break;
                    }
                }

            }

            if($lastapproveinfo['approveresult']==2 || $lastapproveinfo['approveresult']==13)
            {
                //approveresult 13；单据从审批结束编辑后到未提交时，不应该有反审批操作(PC端和手机端同时操作会出现这种情况)
                //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
                $issave='no';//已经审批

            }
            else if($lastapproveinfo['approveresult']==1)
            {
                $lastcreatedtime=$lastapproveinfo['createdtime'];
                $seconds= DateOperation::sencods_between_time(date("Y-m-d H:i:s"),$lastcreatedtime);

                //审批中
                //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
                //abs($seconds)<=10&&
                if( $lastapproveinfo['stepid']==$request_approveinfo['stepid']&&$approveinfo['approved_by']==$current_user->id)
                {
                    $issave='no';

                }
            }

        }

        if($issave=='no')
        {
            ConvertTojsonString(1,array(),'');
            //ConvertTojsonString('error_load',array(),getFixedLabel("Approvestephavechangetip"));
        }


        //通过进入下一步
        if($approvestatus==1){
            $nextstepid=$request_approveinfo['stepid'];
            $query="select approvetype,approvevalue from ld_approvestep where approveid=? and id=?";
            $result=$adb->pquery($query,array($approvelog['approveid'],$nextstepid));
            $approvetype=$adb->query_result($result,0,'approvetype');
            $approvevalue=$adb->query_result($result,0,'approvevalue');
            //$approveby=$approve->getApproveBy($approvetype,$approvevalue).',';//下一步审批人
            //审批时间相同有问题
            if($approvelog['logconcurrentid']>0)
                $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].' and isfinished="no"  order by ld_approvelog.stepseq asc, ld_approvelog.createdtime DESC, id desc limit 1';
            else
                $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].'  order by  ld_approvelog.createdtime DESC, id desc limit 1';
            $nextapproveresult=$adb->pquery($sql,array());//获取当前步骤id
            if($adb->num_rows($nextapproveresult)>0)
            {
                $stepid=$adb->query_result($nextapproveresult,0,0);

            }
            $approvelog['stepid']=$stepid;

        }
        $stepid = $request_approveinfo['stepid'];
        if($approvestatus==2&&empty($stepid))//审核成功结束流程,apple没有传stepid
        {
            $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].' order by seqtime desc, createdtime desc limit 1';
            $nextapproveresult=$adb->pquery($sql,array());
            if($adb->num_rows($nextapproveresult)>0)
            {
                $stepid=$adb->query_result($nextapproveresult,0,0);

            }
            $approvelog['stepid']=$stepid;
        }

        //修改操作，by andrew,修正费用报销审批状态不正确，添加break,20140102
        if(!empty($request_approveinfo['userid_0']) && !empty($approvelog['nextstepid'])){//指定下一步审批人
            $userids = $request_approveinfo['userid_0'];//查询是否有审批委托
            $query = 'select distinct case when approvestatus=0 then approveby else id end as userid 
				from ld_users where id in ('.$userids.') order by userid;';
            $result = $adb->pquery($query,array());
            $num_rows=$adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $approveby .= $adb->query_result($result,$i,'userid').",";
            }

            //echo $approveby;die;
            $approveby = trim($approveby,',');
            //if(empty($approveby)) ConvertTojsonString(-1,array(),'下一步审批人不能为空');
            $approvelog['nextstepapproveby'] = $approveby;
        }

        //不通过，返回到上一步
        if($approvestatus == 5){

            //edit:can 2021-01-12 44192: （企业微信移动端-kfbcrm）加签审批；待审批-销售机会，单据编号 POT70 ；流程“销售机会加签；加签人驳回至上一步后，当前步骤也操作驳回，但无法驳回成功
            $query='select stepid,nextstepid,nextstepapproveby ,approveresult
            ,approved_by,ld_approvelog.countersigner,ld_approvelog.augmentsinger from ld_approvelog where crmid=? 
            and ld_approvelog.approved_by>0
            ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc ';
            $result=$adb->pquery($query,array($request_approveinfo['record']));

            $num_rows=$adb->num_rows($result);
            //edit:can 2021-03-25 45147: （企业微信移动端-kfbcrm）跟进记录，已审批单据编号LXJL587，成员ASD，操作驳回（反审批）单据异常
            $tmprowindex=$approve->getBackStepLogIndex($result);
            if($adb->num_rows($result)>0)
            {
                $nextstepid=$adb->query_result($result,$tmprowindex,'nextstepid');
                $nextstep = $adb->query_result($result,$tmprowindex,'stepid');//需要回撤或者返回的上一个审批步骤
                if($nextstep==-1)
                {
                    $isreject=1;
                }
                $nextstepapproveby=$adb->query_result($result,$tmprowindex,'approved_by');
                $augmentsinger = $adb->query_result($result,$tmprowindex,'augmentsinger');
            }
            else
            {
                $isreject=1;
                $augmentsinger='no';
                $nextstep='-1';
            }

            $approvelog['nextstepid'] = $nextstep;
            if($nextstep>0)
            {
                //进入的是并发步骤
                global $approvestepinfo_arr;
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
                $approvestepinfo_arr[$approveid]= $approve->getAllStepInfoByApproveid($approveid);

                $tmprows=sizeof($approvestepinfo_arr[$approveid]);

                $concurrentidStepCount=0;
                for($i=0;$i<$tmprows;$i++)
                {
                    if($approvestepinfo_arr[$approveid][$i]['stepid']==$nextstep)
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
                        $request_approveinfo['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];

                        $request_approveinfo['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
                        $request_approveinfo["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
                        $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
                        $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');

                        $request_approveinfo["userid_$concurrentidStepCount"]=$approve->getApproveBy($approvetype,$approvevalue,$record);
                        $request_approveinfo["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
                        $concurrentidStepCount++;
                    }
                }

                $request_approveinfo['concurrentidStepCount']=$concurrentidStepCount;
            }

            $approvelog['approved_by'] =  $current_user->id;
            $approvelog['nextstepapproveby'] = $nextstepapproveby;

            $approvelog['stepid'] = $request_approveinfo['stepid'];	//上一步审批步骤id
            $approvelog['approvedeal'] = 'backlaststep';

        }

        if($approvestatus==4)
        {
            //edit:can 2021-03-04 44798: （kfbcrm，企业微信移动端）审批中心，单据驳回选择【不通过，返回负责人】后，单据查看详情界面，【驳回】按钮应该显示【重新提交】按钮（企业微信操作）
            $approvelog['nextstepid']='';
            $approvelog['nextstepapproveby']='';
        }
        if($approvestatus==2)
        {
            //edit:can 2021-03-26 0045167: （企业微信小程序-kfbcrm）待办-跟进记录审批；单据编号LXJL598，审批流程“跟进记录提前结束”；二级审批时操作审批“审批成功，结束流程”，但审批日志仍显示下一审批步骤
            $approvelog['nextstepid']='';
            $approvelog['nextstepapproveby']='';
            $request_approveinfo['concurrentidStepCount']=0;
        }
        if($approvestatus==3)
        {

            //edit:can 20220627 https://61mis.com/WX/kh46733/）PC端审批中新显示3个待审批，但点进去没有数据，审批失败的单据不应该有nextstepid值
            $approvelog['nextstepid']='';
            $approvelog['nextstepapproveby']='';
            unset($request_approveinfo['nextstepid']);

        }
        $before_request = $_REQUEST;
        foreach ($request_approveinfo as $tmp_key => $tmp_value){
            $_REQUEST[$tmp_key] = $tmp_value;
        }
        $approve->SaveApprovedLog($request_approveinfo['fld_module'],$approvelog);
        $_REQUEST = $before_request;
        ConvertTojsonString(1,array(),'');
    }

    //获取审批步骤的必填字段
    public static function getMandatoryField($stepid){
        global $adb;
        $tmp_sql = "SELECT stepid,approveresult,allfieldname from ld_approvestep_mandatoryfield where stepid = ? ORDER BY sequence asc";
        $result = $adb->pquery($tmp_sql,[$stepid]);
        $num_rows = $adb->num_rows($result);
        $mandatoryfield_arr = [];
        for ($tmp_index=0;$tmp_index<$num_rows;$tmp_index++){
            $approvefunc = $adb->query_result($result,$tmp_index,'approveresult');
            $mandatoryfield = $adb->query_result($result,$tmp_index,'allfieldname');
            $mandatoryfield_arr[] = ['approvefunc'=>$approvefunc,'mandatoryfield'=>$mandatoryfield];
        }
        $mandatoryfield_str = ldcrm_json_encode($mandatoryfield_arr);
        return $mandatoryfield_str;
    }
    //保存审批步骤单必填字段
    public static function saveMandatoryField($stepid,$mandatoryfield_json){
        global $adb;
        //先删除原有的必填字段
        $tmp_sql = "DELETE from ld_approvestep_mandatoryfield where stepid = ?";
        $adb->pquery($tmp_sql,[$stepid]);
        if(!empty($mandatoryfield_json)){
            $insert_sql = 'INSERT into ld_approvestep_mandatoryfield(stepid,approveresult,allfieldname,sequence) values';
            $mandatoryfield_arr = ldcrm_json_decode($mandatoryfield_json);
            $tmp_sql_arr = [];
            for ($tmp_i = 0;$tmp_i<sizeof($mandatoryfield_arr);$tmp_i++){
                $sequence = $tmp_i +1;
                $tmp_info = $mandatoryfield_arr[$tmp_i];
                $tmp_sql_arr[] = "($stepid,'".$tmp_info['approvefunc']."','".$tmp_info['mandatoryfield']."',$sequence)";
            }
            if(sizeof($tmp_sql_arr)>0){
                $insert_sql .= implode(',',$tmp_sql_arr);
                $adb->query($insert_sql);
            }
        }
    }

    public function getReturnApproveData(){
        return $this->CommonEditFieldobj->getReturnApproveData();
    }

    //设置请求的值
    public function setRequestColumn($request_column){
        $this->CommonEditFieldobj->setRequestColumn($request_column);
    }
    //判断是否存在布局规则控制的必填字段
    public function JudgeRequiredFieldRule($record){
        $focus = CRMEntity::getInstance($this->module);
        $focus->retrieve_entity_info($record,$this->module);
        $focus->id = $record;
        if($this->module == 'Accounts' ){
            $focus = $this->CommonEditFieldobj->getContactInfo($focus);
        }

        return $this->CommonEditFieldobj->JudgeRequiredFieldRule($focus);
    }

}

?>