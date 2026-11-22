<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$weixin_user;
require_once(globalStatic::$root_directory.'Smarty_setup.php');

if(isset($_REQUEST['record']) && $_REQUEST['record']!=''){
    $record=$_REQUEST['record'];
}
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){
    $module=$_REQUEST['fld_module'];
}
if(isset($_REQUEST['save'])&&$_REQUEST['save']=='true')
{
//    if(empty($_REQUEST['reminders'])||!isset($_REQUEST['reminders']))
//    {
//        //请设置提醒人
//        ConvertTojsonString(-1,array(),getFixedLabel('PLEASESETREMINDER'));
//    }
    $reminders = trim($_REQUEST['reminders']);
    $reminderarr = explode(',',$reminders);

    $remindlogids = trim($_REQUEST['remindlogids']);
    if(empty($remindlogids))
    {
        ConvertTojsonString(-1,array(),getFixedLabel('TIXING').getFixedLabel('Failed_to_send'));
    }
//    if(empty($_REQUEST['remindconten'])||!isset($_REQUEST['remindconten']))
//    {
//        //提醒内容不能为空
//        ConvertTojsonString(-1,array(),getFixedLabel('REMINDSCONTENT').getFixedLabel('CANOTEMPTYGTH'));
//    }
    $remindconten = $_REQUEST['remindconten'];
    $focus = CRMEntity::getInstance($module);
    $time = date('Y-m-d H:i:s',time());
    //zxm 小程序CRM 关联公众号CRM 发送消息需要的参数 比如客户名称等信息
    $focus->id = $record;
    $focus->retrieve_entity_info($record, $module);
    $subject[$record]['subject'] = $focus->column_fields[$focus->list_link_field];
    $subject[$record]['table_code'] = $focus->column_fields[$focus->table_code];
    //保存单据催审状态
    $tabname = $focus->table_name;
    $table_index = $focus->table_index;
    $adb->pquery("update $tabname set approveexpediting='yes' where $table_index=?",array($record));
    //记录催审时间
    $remindlogidarr = explode(',',$remindlogids);
    foreach($remindlogidarr as $remindlogid)
    {
        $adb->pquery("update ld_approvelog set expediting='yes',expeditingtime=? where crmid=? and id =?",array($time,$record,$remindlogid));
    }
    
    //发送提醒
    require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/MessageCorpconversation.php");
    
    foreach($reminderarr as $reminderuserid)
    {
        $remindsinfo = array();
        $remindsinfo[] = ExpeditingAddReminds_WX($remindconten,$time,$reminderuserid,$record,$module);
        $remind = new MessageCorpconversation();
        $remind->setRemindType();
        if ($remind->installWX || $remind->installDing || $remind->installYzj || $remind->installZy || $remind->judgeOffiaccount()=='yes' || $remind->installFanwei)
        {
            $sql = 'select wx_userid,dingtalk_userid,yunzhijia_openid,zhiyuan_userid,fanwei_userid from ld_users  where id=? and push_wx_reminds = 1';
            $tmpuserresult = $adb->pquery($sql, array($reminderuserid));
            $wx_userid = $adb->query_result($tmpuserresult, 0, 'wx_userid');
            $dingtalk_userid = $adb->query_result($tmpuserresult, 0, 'dingtalk_userid');
        	$yunzhijia_openid = $adb->query_result($tmpuserresult, 0, 'yunzhijia_openid');
            $zhiyuan_userid = $adb->query_result($tmpuserresult, 0, 'zhiyuan_userid');
            $fanwei_userid = $adb->query_result($tmpuserresult, 0, 'fanwei_userid');
            //移动端-设置页签-“推送消息提醒”参数关闭应不发送提醒
            if($adb->num_rows($tmpuserresult)<=0){
                continue;
            }
            //zkt 20220427 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
            $tmpremindtitle = sprintf(getFixedLabel('MODULEEXPEDITINGREMIND'),getTranstab($module));
            if (!empty($wx_userid) || !empty($dingtalk_userid)||$remind->judgeOffiaccount()=='yes' || !empty($yunzhijia_openid) || !empty($zhiyuan_userid) || !empty($fanwei_userid)) {
                $sql = 'update ld_reminds set remindstype=?,wxremindstype=? where remindsid in( ' . implode(',', $remindsinfo) . ') ';
                $adb->pquery($sql, array('ExpeditingApprove', 'immediately'));
                $r_multi_content = array(
                    array(
                        'message' => $remindconten,
                        'reltab' => $module,
                        'related_to' => $record,
                        'date_time' => date("Y-m-d H:i:s"),
                        'remindtype' => 'ExpeditingApprove',
                        'title' => $tmpremindtitle,
                        'remindsid' => implode(',', $remindsinfo),
                        'received_id' => $reminderuserid,
                    )
                );
                if(!empty($wx_userid)){
                    $r_multi_content[0]['userid'] = array($wx_userid);
                }
                if(!empty($dingtalk_userid)){
                    $r_multi_content[0]['userid_ding'] = array($dingtalk_userid);
                }
        		if(!empty($yunzhijia_openid)){
                    $r_multi_content[0]['userid_openid'] = $yunzhijia_openid;
                }
                /*if(!empty($zhiyuan_userid)){
                    $r_multi_content[0]['userid_zhiyuan'] = $zhiyuan_userid;
                }*/
                if(!empty($fanwei_userid)){
                    $r_multi_content[0]['userid_fanwei'] = $fanwei_userid;
                }
                //$tmpremindsid = implode(',', $remindsinfo);
                $errorno = $remind->sendAllTypeRemindsImmediately($remindsinfo, $r_multi_content,'Approve',$subject);
                //zxm 20221116 公众号提醒消息单独请求
                if($remind->judgeOffiaccount()=='yes'){
                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                    $offiaccount_remind = new cls_reminds_offiaccount();
                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($remindsinfo,'Approve',$subject);
                }
            }
        }
        
    }
    ConvertTojsonString(1,array(),'');
    
}
else if(isset($_REQUEST['check']) && $_REQUEST['check']=='true')
{
    require_once(globalStatic::$root_directory.'modules/Approve/Approve.php');
    $approve_focus = Approve::getInstance($module);
    $startapprovemodule = $approve_focus->startBlocksApprove();
    if(!isset($startapprovemodule[$module])){//审批模块
        ConvertTojsonString(-1,array(),getFixedLabel('APPROVALNOTENABLED'));
    }
    //判断催审参数是否开启
    $query = 'SELECT approveid FROM ld_approvelog WHERE ld_approvelog.crmid = ? ORDER BY createdtime DESC LIMIT 1';
    $result = $adb->pquery($query,array($record));
    $rows = $adb->num_rows($result);
    if($rows>=0){
        $approveid = $adb->query_result($result,0,'approveid');
    }
    $tabid = getTabid($module);
    $userapprovearr = $approve_focus->getAllApprovesByUserid($tabid,$current_user->id);
    //获取单据审批流程对应“是否启用催审功能”设置的值
    $enableexpediting = 'no';
    foreach($userapprovearr as $index=>$settingapproveinfo){
        $settingenableexpediting = $settingapproveinfo['enableexpediting'];
        $settingapproveid = $settingapproveinfo['approveid'];
        if($settingapproveid == $approveid && $settingenableexpediting == 'yes')
        {
            $enableexpediting = 'yes';
            break;
        }
    }
    if($enableexpediting == 'no')
    {
        ConvertTojsonString(-1,array(),getFixedLabel('EXPEDITINGNOTENABLED'));
    }
    
    //判断单据状态是否为“审批中”
    $focus = CRMEntity::getInstance($module);
    $tabname = $focus->table_name;
    $table_index = $focus->table_index;
    $sql = "select approvesubmitter,approvestatus from $tabname where $table_index = ? and deleted = 0";
    $result = $adb->pquery($sql,array($record));
    $nums = $adb->num_rows($result);
    if($nums<0)
    {
        ConvertTojsonString(-1,array(),getFixedLabel('INFORMATIONNOTEXIST'));
    }
    else
    {
        $approvestatus = $adb->query_result($result,0,'approvestatus');
        $approvesubmitter = $adb->query_result($result,0,'approvesubmitter');
        $approvestatusnum = $approve_focus->getApproveStatus($approvestatus);//获取审批状态：审批中：1
        if($approvestatusnum!= 1)
        {
            ConvertTojsonString(-1,array(),getFixedLabel('APPROVALSTATUSHASCHANGED'));//单据审批状态为
        }
        if($approvesubmitter != $current_user->id)
        {
            ConvertTojsonString(-1,array(),getFixedLabel('CANNOTURGEDOCUMENT'));
        }
    }
    
    
    
    $query = 'SELECT ld_approvelog.id as approvelogid,nextstepapproveby,logconcurrentid,expediting,expeditingtime,nextstepid,ld_approvestep.name as nextstepname FROM ld_approvelog
         LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.nextstepid and ld_approvestep.approveid = ld_approvelog.approveid WHERE ld_approvelog.crmid = ? 
        ORDER BY ld_approvelog.seqtime DESC,ld_approvelog.stepseq desc, ld_approvelog.id desc
        LIMIT 1';
    
    $result = $adb->pquery($query,array($record));
    $rows = $adb->num_rows($result);
    $reminduserarr = array();
    $remindsteparr = array();
    $remindlogids = '';
    if($rows>0)
    {
        $remindlogid = $adb->query_result($result,0,'approvelogid');
        $logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
        $nextstepapproveby=$adb->query_result($result,0,'nextstepapproveby');
        $expediting = $adb->query_result($result,0,'expediting');
        $expeditingtime = $adb->query_result($result,0,'expeditingtime');
        $nextstepid = $adb->query_result($result,0,'nextstepid');
        $nextstepname = $adb->query_result($result,0,'nextstepname');
        $reminduserarr = explode(',',trim($nextstepapproveby,','));
        $remindsteparr[$nextstepid] = $nextstepname;
        $remindlogids = $remindlogid;
        if($logconcurrentid>0)
        {
            $query="SELECT ld_approvelog.id as approvelogid,nextstepapproveby,expediting,expeditingtime,nextstepid,ld_approvestep.name as nextstepname FROM ld_approvelog 
                   LEFT JOIN ld_approvestep ON ld_approvestep.id = ld_approvelog.nextstepid and ld_approvestep.approveid = ld_approvelog.approveid
                    WHERE ld_approvelog.crmid =?  and ld_approvelog.logconcurrentid=? and ld_approvelog.isfinished='no'
                ORDER BY ld_approvelog.seqtime desc,ld_approvelog.stepseq asc,ld_approvelog.createdtime desc,ld_approvelog.id asc";
            $result = $adb->pquery($query,array($record,$logconcurrentid));
            $rows = $adb->num_rows($result);
            $reminduserarr = array();
            $remindsteparr = array();
            $remindlogids = '';
            for($i=0;$i<$rows;$i++)
            {
                $tmparr = array();
                $remindlogid = $adb->query_result($result,$i,'approvelogid');
                $remindlogids .= $remindlogid.',';
                $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
                $expediting = $adb->query_result($result,$i,'expediting');
                $expeditingtime = $adb->query_result($result,$i,'expeditingtime');
                $nextstepid = $adb->query_result($result,$i,'nextstepid');
                $nextstepname = $adb->query_result($result,$i,'nextstepname');
                $remindsteparr[$nextstepid] = $nextstepname;
                $tmparr = explode(',',trim($nextstepapproveby,','));
                foreach($tmparr as $index => $userid)
                {
                    if(!in_array($userid,$reminduserarr))
                    {
                        $reminduserarr[] = $userid;
                    }
                }
            }
        }
        $remindlogids = trim($remindlogids,',');
        //30分钟内不可重复提交
        if($expediting == 'yes')
        {
            $time1 = time();
            $time2 = strtotime($expeditingtime);
            $diff = abs($time1 - $time2); 
            $minutes = floor($diff / 60);
            if($minutes<30)
            {
                ConvertTojsonString(-1,array(),getFixedLabel('NOTREPEATEIN30MINUTES'));
            }
        }
    }
    if(!empty($reminduserarr))
    {
        $smarty = new lingdangCRM_Smarty;
        //提醒人姓名
        $remindusers = trim(implode(',',$reminduserarr),',');
        $sql = "select id,last_name from ld_users where id in ($remindusers)";
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        if($rows>0)
        {
            $remindinfo = array();
            for($i=0;$i<$rows;$i++)
            {
                $id = $adb->query_result($result,$i,'id');
                $last_name = $adb->query_result($result,$i,'last_name');
                $reminduser['reminder'][$id] = $last_name; 
            }
        }
        //提醒内容
        $reminduser['reminds'] = $current_user->last_name.'提醒你审批他的单据'.getTranstab($module);
        //提醒人
        $namestr = '';
        foreach($reminduser['reminder'] as $userid=>$last_name)
        {
            $namestr .= $last_name.',';
        }
        $namestr = trim($namestr,',');
        //审批步骤
        $stepids = '';
        $stepnames = '';
        foreach($remindsteparr as $stepid=>$stepname)
        {
            $stepids .= $stepid.',';
            $stepnames .= $stepname.',';
        }
        $stepids = trim($stepids,',');
        $stepnames = trim($stepnames,',');
        $arr['remindsconten']= $reminduser['reminds'];
        $arr['remindusers']= $remindusers;
        $arr['remindlogids']=$remindlogids;
        $arr['record']=$record;
        $arr['remindnames']=$namestr;
        $arr['remindstepids']=$stepids;
        $arr['remindstepnames']=$stepnames;
        //duan 20221020 移动端增加翻译返回
        $label_arr = array('Expediting','APPROVALSTEP','Recipient','REMINDSCONTENT','PLEASEFILLINREMINDERCONTENT','SUBMIT','EXPEDITIONSUCCEEDED');
        $arr['arrFixedLabel'] = TransFieldlabel($label_arr,'no');
        
        ConvertTojsonString(1,$arr,'');
    }
    else
    {
        ConvertTojsonString(-1,array(),getFixedLabel('APPROVALSTATUSHASCHANGED'));;
    }
}

function ExpeditingAddReminds_WX($RemindsContent,$datetime,$recieverid,$record,$modulename)
{
      global $adb,$current_user;
      
        
        $focusreminds =CRMEntity::getInstance('Reminds');                    
    	$focusreminds->column_fields['date_time'] = $datetime;	   
        $focusreminds->column_fields['related_to']=$record;
        $focusreminds->column_fields['reltab']=$modulename;
        
        $focusreminds->column_fields['recieverid']=$recieverid;
        $focusreminds->column_fields['wxremindstype'] = 'immediately';

        $focusreminds->column_fields['remindstype'] = 'ExpeditingApprove';
        
        $focusreminds->column_fields['status_rmd']='未读';
        $focusreminds->column_fields['content']=$RemindsContent;
        $focusreminds->mode="create";
        $focusreminds->save('Reminds');
        return $focusreminds->id;
}

?>