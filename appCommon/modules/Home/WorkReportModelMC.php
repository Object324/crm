<?php

/**
 * Created by PhpStorm.
 * User: gyq_29
 * Date: 2017/3/27 0027
 * Time: 下午 3:46
 */
crm_load_class_file('WorkReportModel', 'modules/Home');
class WorkReportModelMC extends WorkReportModel
{
    protected function ishighseaallocate($query,$where,$Jurisdiction)
    {
        if($_REQUEST['ishighseaallocate']=='yes'){//公海分配按钮事件
            $useraccount=getAccount_Set('usersaccount');
            $adminaccount=getAccount_Set('adminaccount');
            if(!empty($adminaccount) && !empty($useraccount))
                $where2 ='and (ld_users.id in('.$adminaccount.') or ld_users.id in ('.$useraccount.')or is_admin="on")' ;
            elseif(!empty($adminaccount) && empty($useraccount))
                $where2 ='and (ld_users.id in('.$adminaccount.') or is_admin="on")' ;
            elseif((empty($adminaccount) && !empty($useraccount)))
                $where2 ='and (ld_users.id in('.$useraccount.') or is_admin="on")' ;
            else
                $where2 ='and ( is_admin="on")' ;
        }
        if($Jurisdiction=='yes' || $_REQUEST['ishighseaallocate']=='yes'){
            return $query.$where.$where2;
        }else{
            return $query.$where;
        }
    }
    /**
     * edit:diony
     * reason:获取单条信息
     * */
    public function getDetailView()
    {
        global $adb, $current_user, $PlatformMC;
        $readers = array();//批阅人数组
        $workreportid = $_REQUEST['workreportid'];
        $bigcategory = $_REQUEST['bigcategory'];
        $leftcategory = $_REQUEST['leftcategory'];
        $languagetype = getLanguageType($current_user);

        if (empty($bigcategory)) {
            $bigcategory = 1;
        }
        $smallcategory = $_REQUEST['smallcategory'];
        if (empty($smallcategory)) {
            $smallcategory = 'all';
        }
        if (!empty($leftcategory)) {
            $bigcategory = 0;
            $smallcategory = '';
        }
        $entitytype = 'workreport';
        $workfldarr = $this->getWorkCfFieldInfo($entitytype);
        $workfldsql = '';
        if (!empty($workfldarr)) {
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.' . join(',ld_workreportcf.', $workfldkeyarr);
        }
        $jsonArray = array();
        //注意 变量$sql的第一个from字符串全部小写，以后的from都写成From,因为分页要用到全部小写的from
        $sql = "select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.sendlog_workdate,
  ld_workreport.saleskit_day,ld_workreport.saleskit_month,ld_workreport.saleskit_week,ld_workreport.startdate,ld_users.last_name ,ld_workreport.saleskit_showtype,ld_workreport.saleskit_listinfo,
worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
        ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,usercreator.wx_userid as usercreator_wx_userid,ld_workreport2user.user_type,replycount,path,ld_workreport.workreportid,editcount,praisecount,
        ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
        ld_workreport.filename,ld_workreport.filepath,
        usercreator.last_name as usercreator,longtitude,latitude,
        ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount $workfldsql
        from ld_workreport
            left join ld_workreportcf on ld_workreportcf.workreportid=ld_workreport.workreportid
          left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
          left join ld_users on ld_users.id=ld_workreport2user.userid
          left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
          left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
          left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
        left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid  ) as tmp
        on tmp.workreportid=ld_workreport.workreportid where ld_workreport.workreportid = ? ";
        //editor:gyq_20191031 reason:由于工作协同增加了查看全部日志，所以应删除ld_workreport2user.userid=?的限制
        //$sql .= ' and ld_workreport2user.userid=? ';
        $params = array($workreportid);
        $sql .= "   GROUP BY workreportid  order by createdtime desc  ";
        $result = $adb->pquery($sql, $params);
        $entityContents = array();
        $rownum = $adb->num_rows($result);
        //	0030006: 微信端：消息提醒--工作提醒、移动crm提醒，当关联的单据和日志被删除了，点击消息进入明细，界面报错
        // editor:gyq 20170927
        if($rownum < 1){
            ConvertTojsonString(-1,array(),getFixedLabel('LINKCONTENTDELETED'));
        }
        /*
        if($PlatformMC['type']=='weixin'){
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $portObj = new cls_WeixinPort();//gyq_41
            $portObj->getAgentId();
            $ins_crm = 0;
            if(array_key_exists('ldcrm',$portObj->agentid)){
                $install_ldcrm = 1;
            }
        }*/
        $userobj=new Users();
        for ($i = 0; $i < $rownum; $i++) {
            $lastname = $adb->query_result($result, $i, 'usercreator');
            $userid = $adb->query_result($result, $i, 'userid');
            $usercreator_wx_userid=$adb->query_result($result,$i,'usercreator_wx_userid');
            
            $userobj->id=$userid;
            $userobj->wx_userid=$usercreator_wx_userid;
            $userobj->last_name=$lastname;
            $lastname=getUserlastName($userobj);
            
            $attachmentsid = $adb->query_result($result, $i, 'attachmentsid');
            $path = $adb->query_result($result, $i, 'path');
            $userimagename = $adb->query_result($result, $i, 'userimagename');
            $storage_location = $adb->query_result($result, $i, 'storage_location');
            if($storage_location == 'cos'){
                $userfilepath = $adb->query_result($result, $i, 'cloud_path');
            }
            else{
                $userfilepath = $this->getUserImage($path, $userimagename, $attachmentsid,$userid);
            }
            $entitytype = $adb->query_result($result, $i, 'entitytype');
            $type = $adb->query_result($result, $i, 'type');
            if($entitytype == 'weibo'){
                $reporttype='ItemWeibo';
            }
            else if($entitytype == 'cocmd'){
                $reporttype='ItemCocmd';
            }
            else if($entitytype == 'workreport'){
                if($type == 1) {
                    $reporttype = 'ItemLogday';
                }
                else if($type == 2) {
                    $reporttype = 'ItemLogweek';
                }
                else if($type == 3) {
                    $reporttype = 'ItemLogmonth';
                }
            }
            $createDateTime = $adb->query_result($result, $i, 'createdtime');
            //editor:gyq_90 reason:日志日期修改为自定义选择日期 2018/12/7 10:30
            $sendlog_workdate = $adb->query_result($result, $i, 'sendlog_workdate');
            //editor:gyq_20190114
            $saleskit_day = $adb->query_result($result,$i,'saleskit_day');
            $saleskit_month = $adb->query_result($result,$i,'saleskit_month');
            $saleskit_week = $adb->query_result($result,$i,'saleskit_week');
            $saleskit_showtype = $adb->query_result($result,$i,'saleskit_showtype');
            $saleskit_listinfo = $adb->query_result($result,$i,'saleskit_listinfo');
            $saleskit_listinfo = html_entity_decode($saleskit_listinfo);
            if ($saleskit_showtype == 'html'){//获取最新的label
                $tmp_saleskit_listinfo = ldcrm_json_decode($saleskit_listinfo);
                $moduleRecordLabel_arr = $this->getSalesKitListInfoLabel($tmp_saleskit_listinfo);
                foreach ($tmp_saleskit_listinfo as $tmp_index => &$listinfo){
                    foreach ($listinfo['list'] as $tmp_key => &$list){
                        foreach ($list['href'] as $tmp_i => &$hrefinfo){
                            $module = $hrefinfo['module'];
                            $record = $hrefinfo['record'];
                            if(isset($moduleRecordLabel_arr[$module]) && isset($moduleRecordLabel_arr[$module][$record])){
                                $hrefinfo['label'] = $moduleRecordLabel_arr[$module][$record];
                            }
                        }
                    }
                }
                $saleskit_listinfo = $tmp_saleskit_listinfo;
            }
            $timedescription = $this->getTimeDescription($createDateTime);
            $worksummary = $adb->query_result($result, $i, 'worksummary');
            if (is_null($worksummary)) {
                $worksummary = '';
            }
            $workplan = $adb->query_result($result, $i, 'workplan');
            if (is_null($workplan)) {
                $workplan = '';
            }
            $workexperience = $adb->query_result($result, $i, 'workexperience');
            if (is_null($workexperience)) {
                $workexperience = '';
            }
            $workplan_tuesday=$adb->query_result($result,$i,'workplan_tuesday');
            if(is_null($workplan_tuesday)){
                $workplan_tuesday='';
            }
            $workplan_wednesday=$adb->query_result($result,$i,'workplan_wednesday');
            if(is_null($workplan_wednesday)){
                $workplan_wednesday='';
            }
            $workplan_thursday=$adb->query_result($result,$i,'workplan_thursday');
            if(is_null($workplan_thursday)){
                $workplan_thursday='';
            }
            $workplan_friday=$adb->query_result($result,$i,'workplan_friday');
            if(is_null($workplan_friday)){
                $workplan_friday='';
            }
            $signaddress = $adb->query_result($result, $i, 'signaddress');
            if (is_null($signaddress)) {
                $signaddress = '';
            }
            $longtitude = $adb->query_result($result, $i, 'longtitude');
            $latitude = $adb->query_result($result, $i, 'latitude');
            $editcount=$adb->query_result($result,$i,'editcount');
            $praisecount = $adb->query_result($result, $i, 'praisecount');
            $replycount = $adb->query_result($result, $i, 'replycount');
            $workreportid = $adb->query_result($result, $i, 'workreportid');
            $approved = $adb->query_result($result, $i, 'approved');
            $usercount = $adb->query_result($result, $i, 'usercount') - 1;//获取报告相关用户的数量,把包含自己的用户去除
            $startDateTime = $adb->query_result($result, $i, 'startdate');
            $startDateDescription = '';
            if (!empty($startDateTime)) {
                $startDateDescription = $this->getStartDateDescription($workreportid, $startDateTime);
            }
            if ($praisecount > 0) {//判断当前用户是否已经点赞
                $praisesql = 'select 1 from ld_praise where workreportid=? and userid=?';
                $praiseresult = $adb->pquery($praisesql, array($workreportid, $current_user->id));
                if ($adb->num_rows($praiseresult) > 0) {//已经点赞
                    $praisecurrentuser = 'yes';
                } else {
                    $praisecurrentuser = 'no';
                }
            } else {
                $praisecurrentuser = 'no';
            }
            $filename = $adb->query_result($result, $i, 'filename');
            $filereportpath = $adb->query_result($result, $i, 'filepath');
            if (!empty($filename))
                $workreportfilename = $filereportpath . '/' . $filename;
            else
                $workreportfilename = '';
            $sql = "select 'Accounts'  as relatedtab ,ld_account.accountname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto
					LEFT JOIN ld_account on ld_account.accountid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_account.deleted=0
					UNION
					select 'Contacts'  as relatedtab ,ld_contactdetails.lastname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto
					LEFT JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_contactdetails.deleted=0
                    UNION
					select 'Products'  as relatedtab ,ld_products.productname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto
					LEFT JOIN ld_products on ld_products.productid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_products.deleted=0";
            $resultrelated = $adb->pquery($sql, array($workreportid, $workreportid, $workreportid));
            $relatedModules = array();
            for ($tmp_related = 0; $tmp_related < $adb->num_rows($resultrelated); $tmp_related++) {
                $relatedtab = $adb->query_result($resultrelated, $tmp_related, 'relatedtab');
                $relatedto = $adb->query_result($resultrelated, $tmp_related, 'relatedto');
                $name = $adb->query_result($resultrelated, $tmp_related, 'name');
                if($PlatformMC['type']=='weixin'){
                    if(isPermitted($relatedtab)=='yes'&&vtlib_isModuleActive($relatedtab)){
                        $relatedModules[$relatedtab][] = array('curid' => $relatedto, 'name' => $name);
                    }
                }else{
                    $relatedModules[$relatedtab][] = array('curid' => $relatedto, 'name' => $name);
                }
            }
            //查找日志批阅人、任务执行人、微博为空
            $sqlReader = "select ld_workreport2user.workreportid,ld_workreport2user.userid,
                        ld_workreport2user.user_type,ld_workreport2user.id,
                        ld_users.last_name as readername,ld_users.wx_userid
                        from ld_workreport2user
                        left join ld_users on ld_workreport2user.userid = ld_users.id
                        where ld_workreport2user.workreportid = ? and ld_workreport2user.user_type = ? ";
            switch ($entitytype) {
                case 'weibo': //微博
                    $user_type = 0;
                    break;
                case 'workreport': //日志
                    $user_type = 5;
                    break;
                case 'cocmd': //任务
                    $user_type = 6;
                    break;
            }
            if ($entitytype != 'weibo') {
                $sqlReaderResult = $adb->pquery($sqlReader, array($workreportid, $user_type));
                $reader = $adb->query_result($sqlReaderResult, 0, 'userid');
                $readername = $adb->query_result($sqlReaderResult, 0, 'readername');
                $wx_userid=$adb->query_result($sqlReaderResult,0,'wx_userid');
                $userobj=new Users();
                $userobj->id=$reader;
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$readername;
                $readername=getUserlastName($userobj);
            }
            if ($reader == null || $reader == '') {
                $reader = '';
            }
            if ($readername == null || $readername == '') {
                $readername = '';
            }
            if (empty($usercount) || $usercount == '') {//如果该工作报告没有抄送范围和@,则显示点评人的名称
                $usercount = $readername;
            } else {
                $usercount = $usercount . getFixedLabel('COLLEAGUES');
            }
            if ($usercount == '') {
                $usercount = getFixedLabel('PRIVATEAPP');
            }
            $isEdit = 'no';
            if ($current_user->id == $userid && $approved != 2 && !($entitytype=='cocmd'&&$approved!=0)) {
                $isEdit = 'yes';
            }
            $isDel = 'no';
            if ($current_user->id == $userid && $replycount == 0) {
                $isDel = 'yes';
            }
            if ($reader == $current_user->id && $approved == 0) {
                $readerbutton = 'yes';
            } else {
                $readerbutton = 'no';
            }
            //关联图片
            $workachment = $this->getWorkAchmentInfo($workreportid);
            $entitytypename = '';
            $workreportstatus = '';
            $workreportstatusclass = '';
            if ($entitytype == 'weibo') {
                $entitytypename = getFixedLabel('BLOG');
                $workreportstatusclass = 'ui-hide';
            } else if ($entitytype == 'cocmd') {
                $entitytypename = getFixedLabel('TASK');
                if ($approved == 0) {
                    if(strtotime(date('Y-m-d H:i:s'))<strtotime($startDateTime)){
                        $workreportstatus = getFixedLabel('UNDERIMPLEMENTATION');
                    }else{
                        $workreportstatus = getFixedLabel('TIMEDOUT');
                    }
                } else if ($approved == 1) {
                    $workreportstatus = getFixedLabel('COMPLETED');
                    $workreportstatusclass = 'greenFont';
                } else if ($approved == 2) {
                    $workreportstatus = getFixedLabel('CANCELED');
                    $workreportstatusclass = 'redFont';
                }
            } else if ($entitytype == 'workreport') {
                if ($type == 1) {
                    $entitytypename = getFixedLabel('JOURNAL');
                } else if ($type == 2) {
                    $entitytypename = getFixedLabel('WEEKPLAN');
                } else if ($type == 3) {
                    $entitytypename = getFixedLabel('MONTHPLAN');
                }
                if ($approved == 0) {
                    $workreportstatus = getFixedLabel('NOCOMMENTS');
                } else if ($approved == 1) {
                    $workreportstatus = getFixedLabel('REVIEWEDAPP');
                    $workreportstatusclass = 'greenFont';
                }
            }
            $strInfo = '';//日志，任务内容前描述，微博没有描述
            if ($entitytype == 'workreport') {
                if($languagetype == 'en'){
                    $strInfo = "This ". $entitytypename ." is reviewed by <span class='fontblue'>" . $readername . "</span>.";
                }else{
                    $strInfo = "该". $entitytypename ."由<span class='fontblue'>" . $readername . "</span>点评。";
                }
            } else if ($entitytype == 'cocmd') {
                if($languagetype == 'en'){
                    $strInfo = "This task is carried out by <span class=''>".$readername."</span>，".$startDateDescription;
                }else{
                    $strInfo = "该".getFixedLabel('TASK')."由<span class=''>".$readername."</span>执行，".$startDateDescription;
                }
            }
            $cocmdcancel = 'no';
            if ($entitytype == 'cocmd' && $approved == 0 && $userid == $current_user->id) {
                $cocmdcancel = 'yes';
            }
            //editor:gyq_78 reason:增加key=createtime 发布工作汇报时显示销售简报 2018/8/28 17:43
            $entity = array('userimage' => $userfilepath, 'username' => $lastname, 'userid' => $userid, 'workreporttime' => $timedescription,
                'entitytype' => $entitytype, 'entitytypename' => $entitytypename, 'workreporttype' => $type,'reporttype' => $reporttype, 'workreportstatusclass' => $workreportstatusclass, 'workreportstatus' => $workreportstatus,
                'signaddress' => $signaddress, 'replycount' => $replycount, 'cocmdcancel' => $cocmdcancel,
                'editcount' => $editcount,'praisecount' => $praisecount, 'ispraise' => $praisecurrentuser, 'approved' => $approved,
                'Accounts' => $relatedModules['Accounts'], 'Contacts' => $relatedModules['Contacts'],
                'Products' => $relatedModules['Products'], 'isEdit' => $isEdit,'isDel' => $isDel,
                'relateUserDescription' => $usercount, 'longtitude' => $longtitude, 'latitude' => $latitude,
                'L' => $workreportfilename, 'curid' => $workreportid, 'reader' => array('userid' => $reader, 'username' => $readername, 'startDateDescription' => $strInfo), 'readerbutton' => $readerbutton, 'workachment' => $workachment,
                'createtime'=>$createDateTime,'sendlog_workdate'=>$sendlog_workdate,'workplan_tuesday'=>$workplan_tuesday,'workplan_wednesday'=>$workplan_wednesday,'workplan_thursday'=>$workplan_thursday,'workplan_friday'=>$workplan_friday,
                'saleskit_showtype'=>$saleskit_showtype,'saleskit_listinfo'=>$saleskit_listinfo);

            $this->init_outputStyle($entity,$entitytype,$saleskit_day,$saleskit_week,$saleskit_month,$type,$worksummary,$workplan,$workexperience,$workplan_tuesday,$workplan_wednesday,$workplan_thursday,$workplan_friday,$workfldkeyarr,$adb,$result,$i);
        }
        $entityContents[] = $entity;
        $jsonArray['report'] = $entityContents;
        //$jsonArray['field']=$this->getallFieldsForTable();

        $entityreply = array();
        $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1
                from ld_workreply
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
               where workreportid=? and ld_workreply.type =1
           ";
        $result = $adb->pquery($sql, array($workreportid));
        if ($adb->num_rows($result) > 0) {
            $ishave = '1';
            $replyuserid = $adb->query_result($result, 0, 'replyuserid');
            $replyusername = getUserFullName($replyuserid);
            $content = $adb->query_result($result, 0, 'text');
            $createdtime = $adb->query_result($result, 0, 'createdtime');
            if (!empty($content)) {
                $content = str_replace("\n", "<br>", $content);
            }
        } else {
            $ishave = '0';
            $replyuserid = 0;
            $replyusername = '';
            $content = '';
            $createdtime = null;
        }
        $entityreply = array('ishave' => $ishave, 'replyuserid' => $replyuserid, 'replyusername' => $replyusername, 'content' => $content, 'createdtime' => $createdtime);
        $jsonArray['reply'] = $entityreply;
        $jsonArray['permit'] = array('download'=>isPermitted('CooperativeWork','DownLoad',''),'preview'=>isPermitted('CooperativeWork','Preview',''));
        return $jsonArray;

    }
    /**
     * edit:gyq_38 data:20170711 reason:移动端主页合并
     * reason:获取CRM模块
     * */
    public function getCRMModules()
    {
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        $availabletables_mixed= cls_Home_SpecialMC::getHomeModule();
       
        $entity['blocklist'] = $availabletables_mixed;
        $entity['showtype']='1';
        ConvertTojsonString(1,$entity,"");
    }
    /**
     * edit:diony data:20170823 reason:移动端工作主页
     * reason:获取工作主页
     * */
    public function getWorkHome()
    { 
        global $PlatformMC;
//        ls 2021-10-20 【1002089】工作汇报，工作类别增加编辑功能（小程序）
        $workhome=
            array(
                  array('title'=>getFixedLabel('BLOG'),'imagename'=>'weibo.png','type'=>'ItemWeibo','mode'=>'create'),
                  array('title'=>getFixedLabel('JOURNAL'),'imagename'=>'day.png','type'=>'ItemLogday','mode'=>'create'),
                  array('title'=>getFixedLabel('WEEKPLAN'),'imagename'=>'week.png','type'=>'ItemLogweek','mode'=>'create'),
                  array('title'=>getFixedLabel('MONTHPLAN'),'imagename'=>'month.png','type'=>'ItemLogmonth','mode'=>'create'),
                  array('title'=>getFixedLabel('TASK'),'imagename'=>'jihua.png','type'=>'ItemCocmd','mode'=>'create')
            );
        if($PlatformMC['type']=='weixin'){
            $entity['isshow'] = 'yes';
            if(cls_StaticCommonFun::checkVersionIs001()){
                unset($workhome[0]);
                unset($workhome[4]);
                $entity['isshow'] = 'no';
            }
        }
        $entity['list'] = $workhome;        
        ConvertTojsonString(1,$entity,"");
    }
    //个人权限设置信息
    public function getMeInfo()
    {
        global $current_user, $adb;
        $type = $_REQUEST['type'];
        require(globalStatic::$root_directory.'user_privileges/user_privileges_' . $current_user->id . '.php');
        $user_info['highercount'] = $current_user->getHigerUserCounts($current_user->id);
        $user_info['imagename'] = $current_user->getUserImage($current_user->id);
        $user_info['profilename'] = $current_user->getUserOfProfileName();
        $hs['userinfo'] = $user_info;
        if ($type == 'view') {
            //允许查看其他用户单据
            if ($user_info['viewothers'] == 1) {
                $hs['userinfo']['viewothers'] = '是';
            } else {
                $hs['userinfo']['viewothers'] = '否';
            }
            $editothersvalue = '否';//允许编辑其他用户单据
            if ($user_info['editothers'] == 1) {
                $hs['userinfo']['editothers'] = '是';
            } else {
                $hs['userinfo']['editothers'] = '否';
            }
            $delothersvalue = '否';//允许删除其他用户单据
            if ($user_info['delothers'] == 1) {
                $hs['userinfo']['delothers'] = '是';
            } else {
                $hs['userinfo']['delothers'] = '否';
            }
            $viewselfbillsvalue = '否';//允许查询自己创建的单据
            if ($user_info['viewselfbills'] == 1) {
                $hs['userinfo']['viewselfbills'] = '是';
            } else {
                $hs['userinfo']['viewselfbills'] = '否';
            }
            $accountallviewvalue = '否';//允许查看全景资料
            if ($user_info['accountallview'] == 1) {
                $hs['userinfo']['accountallview'] = '是';
            } else {
                $hs['userinfo']['accountallview'] = '否';
            }
            //允许编辑其他用户单据的手机号码字段
            if ($user_info['edit_other_mobile'] == 1) {
                $hs['userinfo']['edit_other_mobile'] = '是';
            } else {
                $hs['userinfo']['edit_other_mobile'] = '否';
            }
            //手机号码显示样式根据系统参数控制
            if ($user_info['is_mobile_style'] == 1) {
                $hs['userinfo']['is_mobile_style'] = '是';
            } else {
                $hs['userinfo']['is_mobile_style'] = '否';
            }
            unset($hs['userinfo']['telephone_view']);
        }
        if ($type == 'home') {
            unset($hs['userinfo']['email1']);
            //unset($hs['userinfo']['phone_mobile']);
            unset($hs['userinfo']['phone_home']);

            unset($hs['userinfo']['viewothers']);
            unset($hs['userinfo']['editothers']);
            unset($hs['userinfo']['delothers']);
            unset($hs['userinfo']['viewselfbills']);
            unset($hs['userinfo']['accountallview']);
            unset($hs['userinfo']['edit_other_mobile']);
            unset($hs['userinfo']['is_mobile_style']);
        }
        unset($hs['userinfo']['is_admin']);
        unset($hs['userinfo']['profileid']);
        unset($hs['userinfo']['status']);
        unset($hs['userinfo']['description']);
        unset($hs['userinfo']['secondaryemail']);
        unset($hs['userinfo']['email2']);
        unset($hs['userinfo']['phone_other']);

        unset($hs['userinfo']['reports_to_id']);
        unset($hs['userinfo']['date_format']);
        unset($hs['userinfo']['time_zone']);
        unset($hs['userinfo']['theme']);
        unset($hs['userinfo']['language']);

        unset($hs['userinfo']['select_servicedetail']);
        unset($hs['userinfo']['select_due_date']);
        unset($hs['userinfo']['login_sms']);
        unset($hs['userinfo']['trackpostion']);
        unset($hs['userinfo']['jw_user']);

        unset($hs['userinfo']['push_work_reminds']);
        unset($hs['userinfo']['push_news_reminds']);

        unset($hs['userinfo']['currency_name']);
        unset($hs['userinfo']['currency_code']);
        unset($hs['userinfo']['currency_symbol']);
        unset($hs['userinfo']['conv_rate']);
        unset($hs['userinfo']['record_module']);

        unset($hs['userinfo']['highercount']);

        unset($hs['userinfo']['user_password']);
        unset($hs['userinfo']['confirm_password']);
        unset($hs['userinfo']['lead_view']);
        unset($hs['userinfo']['approvestatus']);
        unset($hs['userinfo']['approveby']);
        unset($hs['userinfo']['activity_view']);
        unset($hs['userinfo']['hour_format']);
        unset($hs['userinfo']['start_hour']);
        unset($hs['userinfo']['currency_grouping_pattern']);
        unset($hs['userinfo']['currency_decimal_separator']);
        unset($hs['userinfo']['currency_grouping_separator']);
        unset($hs['userinfo']['currency_symbol_placement']);
        unset($hs['userinfo']['address_street']);
        unset($hs['userinfo']['address_country']);
        unset($hs['userinfo']['address_city']);
        unset($hs['userinfo']['address_postalcode']);
        unset($hs['userinfo']['address_state']);
        unset($hs['userinfo']['scopeauthority']);
        unset($hs['userinfo']['menuapproval']);
        unset($hs['userinfo']['reminder_interval']);
        unset($hs['userinfo']['accesskey']);
        unset($hs['userinfo']['asterisk_extension']);
        unset($hs['userinfo']['use_asterisk']);
        unset($hs['userinfo']['attachmentsid']);
        unset($hs['userinfo']['record_id']);
        return $hs;
    }
    public function saveMe()
    {
        global $current_user;
        $_REQUEST['record'] = $current_user->id;
        $focus = new Users();
        $focus->id = $_REQUEST['record'];
        $focus->mode = 'edit';
        $focus->retrieve_entity_info($_REQUEST['record'], 'Users');
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                $focus->column_fields[$fieldname] = $_REQUEST[$fieldname];
            }
        }
        $focus->save("Users");
    }
    /**
     * edit:can
     * reason:获取工作提醒列表数据
     * */
    public function getWorkRemindsAppList()
    {
        $type=$_REQUEST['bigcategory'];
        switch($type)
        {
            case 'approvelist'://待处理
            case 'atworklist'://@我的工作
            case 'mylaunchlist'://我发出的工作
                return $this->getApproveAppList();
            case 'replylist'://我发出工作的回复
                return $this->getworkReplyAppList();
            case 'atreplylist'://@我的回复
                return $this->getAtReplyAppList();
            case 'mypraiselist'://我收到的赞
                return  $this->getPraiseAppList();
        }
    }

    /**
     * edit:can
     * reason:获取待处理的日志或者任务,@我的工作，我发出的工作
     * */
    protected  function getApproveAppList()
    {
        global $adb,$current_user,$mobile_pagerecordcount;
        $smallcategory=$_REQUEST['smallcategory'];
        $bigcategory=$_REQUEST['bigcategory'];

        $reportwhere='';
        $remindwhere ='';
        $workfldarr = $this->getWorkCfFieldInfo($entitytype);
        $workfldsql = '';
        $definecolumn='';
        if(!empty($workfldarr)){
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.'.join(',ld_workreportcf.',$workfldkeyarr);
        }
        switch($bigcategory)
        {
            case 'approvelist'://待审批
                if($smallcategory=='cocmd')
                {
                    $operationtype=5;
                    $jsonArray=$this->getApproveAppCount('workreport');
                }
                else if($smallcategory=='workreport')
                {
                    $operationtype=4;
                    $jsonArray=$this->getApproveAppCount('cocmd');
                    $definecolumn=$workfldsql;
                }
                $remindtype=1;

                $reportwhere=" where approved=0 and ld_workreport2user.userid=? and entitytype ='$smallcategory' and ld_workreport2user.user_type in(5,6,7)";
                $remindwhere=" where relatedtable='workreport' and  userid=? and remind_status=0  and remindtype =1 and operationtype=$operationtype";
                $sqlinnerjoin =" INNER JOIN (select relatedto ,createdtime  From ld_workreport_remind $remindwhere) as tmpremind
                                on ld_workreport.workreportid=tmpremind.relatedto ";
                break;
            case 'atworklist'://@我的工作
                $remindtype=3;
                $definecolumn=$workfldsql;
                if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                    $reportwhere=" where ld_workreport.smcreatorid=? ";
                }
                else{
                    $reportwhere=" where ( ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=2  ";
                }
                $remindwhere=" where relatedtable='workreport' and userid=? and remind_status=0  and remindtype =3";
                $sqlinnerjoin =" INNER JOIN (select relatedto ,createdtime From ld_workreport_remind $remindwhere) as tmpremind
                                on ld_workreport.workreportid=tmpremind.relatedto ";
                break;
            case  'mylaunchlist'://我发出的工作
                $definecolumn=$workfldsql;
                $reportwhere=" where  ld_workreport.smcreatorid=? ";
                $remindwhere=" where relatedtable='workreply' and userid=? and remind_status=0  and remindtype =5";
                $remindtype=5;
                $sqlinnerjoin =" INNER JOIN (select workreportid as relatedto ,ldremind.createdtime From ld_workreply
                                inner join
                                (select relatedto,createdtime  From ld_workreport_remind $remindwhere) as ldremind
                                on ldremind.relatedto=ld_workreply.workreplyid
                                ) as tmpremind on ld_workreport.workreportid=tmpremind.relatedto ";
                break;
        }
        //$workreminds['approveicon']=1;//表示有提醒数量
        $sql= "select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name ,worksummary,workplan,workexperience,signaddress,
                ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,replycount,path,ld_workreport.workreportid,praisecount,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreport.filename,ld_workreport.filepath,usercreator.last_name as usercreator,
                ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude $definecolumn
                from ld_workreport
                left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                left join ld_users on ld_users.id=ld_workreport2user.userid
                left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
                left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp
                on tmp.workreportid=ld_workreport.workreportid";
        if(!empty($definecolumn))
        {
            $sql.=' left join ld_workreportcf on ld_workreportcf.workreportid=ld_workreport.workreportid ';
        }

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $sql.= $reportwhere ;
            $jsonArray['summary']['icontype']=0;
            $orderby=' order by ld_workreport.createdtime desc ';
            $params=array($_REQUEST['viewuserid']);
        }
        else{
            $approve_sql="select  id from ld_workreport_remind  $remindwhere  limit 1";
            $result=$adb->pquery($approve_sql,array($current_user->id));
            if($adb->num_rows($result)>0)
            {
                $sql.=$sqlinnerjoin;
                $jsonArray['summary']['icontype']=1;
                //修改工作提醒状态
                $update_remind_sql="update ld_workreport_remind set remind_status=1  $remindwhere";
                $orderby=' order by tmpremind.createdtime desc ';
            }
            else
            {
                $sql.= $reportwhere ;
                $jsonArray['summary']['icontype']=0;
                $orderby=' order by ld_workreport.createdtime desc ';
            }
            $params=array($current_user->id);
        }

        $sqlcounts=explode('from',$sql);
        $sqlcount='select 1  from '.$sqlcounts[1] ;
        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $sqlcount .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id and ld_workreport2user.user_type = 2 ) ";
        }
        $sqlcount .= ' GROUP BY ld_workreport.workreportid ';
        //echo $sqlcount;echo '<br><br>';print_r($params);echo '<br><br>';
        $resultcount=$adb->pquery($sqlcount,$params);
        $noofrows=$adb->num_rows($resultcount);

        $noofrowsStr = '';
        $noofrowsDisplay = 'no';
        if($noofrows!=0){
            if($noofrows<=99){
                $noofrowsStr = $noofrows;
            }
            else{
                $noofrowsStr = "99+";
            }
            $noofrowsDisplay = 'yes';
        }
        if($smallcategory=='cocmd'){//任务
            $jsonArray['summary']['cocmd_count']=$noofrowsStr;
            $jsonArray['summary']['cocmd_display']=$noofrowsDisplay;
        }
        else{
            $jsonArray['summary']['workreport_count']=$noofrowsStr;
            $jsonArray['summary']['workreport_display']=$noofrowsDisplay;
        }

        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';

        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
            $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
            $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
            $havenextpage='no';
            $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
            $haveprevpage='no';
            $startpagenum=0;
        }

        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            //if($bigcategory=='atworklist'){//@我的工作
            $sql .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id and ld_workreport2user.user_type = 2 ) ";
        }
        $sql.="   GROUP BY ld_workreport.workreportid  $orderby limit $startpagerecord, $mobile_pagerecordcount ";
        //echo $sql;echo '<br>';print_r($params);die;
        $result=$adb->pquery($sql,$params);
        $entityContents=$this->createWorkRepotList($result);

        $jsonArray['report']=$entityContents;
        $jsonArray['field']=$this->getallFieldsForTable();
        if(isset($update_remind_sql))
        {
            $adb->pquery($update_remind_sql,array($current_user->id));//修改工作提醒状态，
        }
        return $jsonArray;
    }
    /**
     * edit:can
     * reason:我收到的赞列表
     * */
    protected function getPraiseAppList()
    {
        global $adb,$current_user,$mobile_pagerecordcount;

        $entitytype = 'workreport';
        $workfldarr = $this->getWorkCfFieldInfo($entitytype);
        $workfldsql = '';
        if(!empty($workfldarr)){
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.'.join(',ld_workreportcf.',$workfldkeyarr);
        }
        $sql='select id from ld_workreport_remind where  remindtype=6 and userid=? and remind_status=0';
        $resultt=$adb->pquery($sql,array($current_user->id));
        $userid=$current_user->id;
        if($adb->num_rows($resultt)>0)
        {
            $jsonArray['summary']['icontype']=1;
            $query="select ld_praise.userid,ld_praise.createdtime,ld_salesmanattachmentsrel.attachmentsid,ld_users.id,ld_users.last_name,ld_workreport.workreportid,
            ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,
            ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
            ld_attachments.path
             from ld_praise
            inner join ld_workreport
            on ld_praise.workreportid=ld_workreport.workreportid
             left join ld_users on ld_users.id=ld_praise.userid
            left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
            left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
             INNER JOIN (select relatedto,createdtime  From ld_workreport_remind where relatedtable='praise' and  remindtype=6 and userid=$userid and remind_status=0)
            as tmppraiseremind on tmppraiseremind.relatedto=ld_praise.praiseid
             ";
            $orderby='  order by tmppraiseremind.createdtime desc ';
            //修改工作提醒状态
            $update_remind_sql="update ld_workreport_remind  set remind_status=1 where relatedtable='praise' and  remindtype=6 and userid=$userid and remind_status=0 ";

        }
        else
        {
            $jsonArray['summary']['icontype']=0;
            $query="select ld_praise.userid,ld_praise.createdtime,ld_salesmanattachmentsrel.attachmentsid,ld_users.id,ld_users.last_name,ld_workreport.workreportid,
            ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,
            ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
            ld_attachments.path
             from ld_praise
            inner join ld_workreport
            on ld_praise.workreportid=ld_workreport.workreportid
             left join ld_users on ld_users.id=ld_praise.userid
            left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
            left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid

            where ld_workreport.smcreatorid=$userid and ld_workreport.praisecount>0 and ld_praise.userid>0 ";
            $orderby='  order by ld_praise.createdtime desc ';
        }
        $params=array();
        $sqlcounts=explode('from',$sql);
        $sqlcount='select 1  from '.$sqlcounts[1];

        //  $resultcount=$adb->pquery($sqlcount,$params);
        $noofrows=1;
        $jsonArray['summary']['totalrows']=$noofrows;
        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';
        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
            $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
            $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
            $havenextpage='no';
            $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
            $haveprevpage='no';
            $startpagenum=0;
        }

        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;
        $query.="    $orderby limit $startpagerecord, $mobile_pagerecordcount ";

        //echo $query;die;
        $praiseresult=$adb->pquery($query,array());
        $entityContent=array();
        for($i=0;$i<$adb->num_rows($praiseresult);$i++)
        {

            $attachmentsid=$adb->query_result($praiseresult,$i,'attachmentsid');
            $path=$adb->query_result($praiseresult,$i,'path');
            $userimagename=$adb->query_result($praiseresult,$i,'userimagename');
            $storage_location = $adb->query_result($result, $i, 'storage_location');
            $userid = $adb->query_result($result, $i, 'userid');
            if($storage_location == 'cos'){
                $userfilepath = $adb->query_result($result, $i, 'cloud_path');
            }
            else{
                $userfilepath = $this->getUserImage($path, $userimagename, $attachmentsid,$userid);
            }
            $reporttype=$adb->query_result($praiseresult,$i,'entitytype');
            $workreporttype=$adb->query_result($praiseresult,$i,'workreporttype');
            $content=$adb->query_result($praiseresult,$i,'workexperience');
            $praiseusername=$adb->query_result($praiseresult,$i,'last_name');
            if($reporttype=='cocmd')
            {
                $content='对我的'.getFixedLabel('TASK').':'.$content;
                $reporttypeStr = getFixedLabel('TASK');
            }
            else if($reporttype=='workreport')
            {
                if($workreporttype==1){
                    $content='对我的'.getFixedLabel('JOURNAL').':'.$content;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                }
                else if($workreporttype==2){
                    $content='对我的'.getFixedLabel('WEEKPLAN').':'.$content;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                }
                else if($workreporttype==3){
                    $content='对我的'.getFixedLabel('MONTHPLAN').':'.$content;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }
            }
            else if($reporttype=='weibo')
            {
                $content='对我的'.getFixedLabel('BLOG').':'.$content;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            $entityContent[]=array('curid'=>$adb->query_result($praiseresult,$i,'workreportid'),'content'=>$content,'createdtime'=>$this->getDateDescription($adb->query_result($praiseresult,$i,'createdtime')),
                'praiseusername'=>$praiseusername,'praiseuserid'=>$adb->query_result($praiseresult,$i,'userid'),
                'userimage'=>$userfilepath,'reporttype'=>$reporttype,'reporttypeStr'=>$reporttypeStr);
        }

        $jsonArray['list']=$entityContent;
        $jsonArray['field']=$this->getallFieldsForTable();//editor:gyqX170628 reason:前端需要field
        if(isset($update_remind_sql))
        {
            //修改工作提醒状态
            $adb->pquery($update_remind_sql);
        }
        return $jsonArray;

    }
    /**
     * edit:can
     * reason:获取我发出工作的回复
     * */
    public function getworkReplyAppList()
    {
        global $adb,$current_user,$mobile_pagerecordcount;

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $jsonArray['summary']['icontype']=0;
            $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
            ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
            workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1, ld_workreport.workreportid,
            ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
            from ld_workreply
            left join ld_users on ld_users.id=ld_workreply.replyuserid
            left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
            left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
            inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
            where ld_workreply.replyuserid=? ";
            $jsonArray['summary']['approveicon']=0;
            $sql .= " and ld_workreply.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id) ";
            $orderby=' order by ld_workreply.createdtime desc ';
        }
        else{
            $sql="select id from ld_workreport_remind  where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0";
            $result=$adb->pquery($sql,array($current_user->id));
            //$workreminds['approveicon']=1;//表示有提醒数量
            if($adb->num_rows($result)>0)
            {
                $jsonArray['summary']['replyicon']=1;
                $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1 ,ld_workreport.workreportid,
                ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
                from ld_workreply
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join (select relatedto,createdtime From ld_workreport_remind where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0 )
                as tmpremindreply  on tmpremindreply.relatedto=ld_workreply.workreplyid
                inner join ld_workreport on  ld_workreport.workreportid=ld_workreply.workreportid";
                $jsonArray['summary']['icontype']=1;

                $orderby=' order by tmpremindreply.createdtime desc ';

                //修改工作提醒状态
                $update_remind_sql=" update ld_workreport_remind set remind_status=1 where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0";


            }
            else
            {
                $jsonArray['summary']['icontype']=0;
                $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1, ld_workreport.workreportid,
                ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
                from ld_workreply
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
                where ld_workreport.smcreatorid=? ";
                $jsonArray['summary']['approveicon']=0;
                $orderby=' order by ld_workreply.createdtime desc ';
            }
        }

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $params=array($_REQUEST['viewuserid']);
        }
        else{
            $params=array($current_user->id);
        }

        $sqlcounts=explode('from',$sql);
        $sqlcount='select 1  from '.$sqlcounts[1];

        $resultcount=$adb->pquery($sqlcount,$params);
        $noofrows=$adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows']=$noofrows;


        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';

        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
            $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
            $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
            $havenextpage='no';
            $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
            $haveprevpage='no';
            $startpagenum=0;
        }

        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;
        $sql.="    $orderby  limit $startpagerecord, $mobile_pagerecordcount ";
        $entityContent=array();
        //echo $sql;echo '<br>';
        //print_r($params);die;
        $result=$adb->pquery($sql,$params);
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $replyuserid = $adb->query_result($result,$i,'replyuserid');
            $replyusername = getUserFullName($replyuserid);

            $content=$adb->query_result($result,$i,'text');
            $type=$adb->query_result($result,$i,'type');
            $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
            $path=$adb->query_result($result,$i,'path');
            $userimagename=$adb->query_result($result,$i,'userimagename');
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$replyuserid);
            $reporttype=$adb->query_result($result,$i,'entitytype');
            $workreporttype=$adb->query_result($result,$i,'workreporttype');
            $workreportcontent=$adb->query_result($result,$i,'workexperience');
            $workreportcontent = $this->filterWorkSummary($workreportcontent);
            if($reporttype=='cocmd')
            {
                $workreportcontent='回复我的'.getFixedLabel('TASK').':'.$workreportcontent;
                $reporttypeStr = getFixedLabel('TASK');
            }
            else if($reporttype=='workreport')
            {
                if($workreporttype==1){
                    $workreportcontent='回复我的'.getFixedLabel('JOURNAL').':'.$workreportcontent;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                }
                else if($workreporttype==2){
                    $workreportcontent='回复我的'.getFixedLabel('WEEKPLAN').':'.$workreportcontent;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                }
                else if($workreporttype==3){
                    $workreportcontent='回复我的'.getFixedLabel('MONTHPLAN').':'.$workreportcontent;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }
            }
            else if($reporttype=='weibo')
            {
                $workreportcontent='回复我的'.getFixedLabel('BLOG').':'.$workreportcontent;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            if(!empty($content)){
                $content = $this->filterWorkSummary($content);
            }
            $entityContent[]=array('replyid'=>$adb->query_result($result,$i,'workreplyid'),'replycontent'=>$content,'createdtime'=>$this->getDateDescription($adb->query_result($result,$i,'createdtime')),'replyusername'=>$replyusername,
                'replyuserid'=>$replyuserid,'userimage'=>$userfilepath,'reportid'=>$adb->query_result($result,$i,'workreportid'),
                'reportcontent'=>$workreportcontent,'reporttype'=>$reporttype,'reporttypeStr'=>$reporttypeStr
            );
        }
        $jsonArray['list']=$entityContent;
        $jsonArray['field']=$this->getallFieldsForTable();
        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
        }
        else{
            if(isset($update_remind_sql)){
                //修改工作提醒状态
                $adb->pquery($update_remind_sql,array($current_user->id));
            }
        }
        return $jsonArray;
    }
    /**
     * edit:can
     * reason:@我的回复
     * */
    public function getAtReplyAppList()
    {
        global $adb,$current_user,$mobile_pagerecordcount;

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $jsonArray['summary']['icontype']=0;
            $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
            ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
            ld_workreply.workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1,
            ld_workreport.workreportid,userreply.last_name as replyusername,userreply.wx_userid as replywxuserid,
            ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,ld_users.last_name,ld_users.wx_userid as la_wx_userid
            from ld_workreply
            left join ld_users as userreply on userreply.id=ld_workreply.replyuserid
            left join ld_salesmanattachmentsrel on   userreply.id=ld_salesmanattachmentsrel.smid
            left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
            inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
            left join ld_users on ld_users.id=ld_workreport.smcreatorid
            left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
            where ld_workreport.smcreatorid=?  and (ld_workreport2user.user_type=2 or ld_workreport2user.user_type=4 or ld_workreport2user.user_type=1 or ld_workreply.replyuserid = ?)";
            $jsonArray['summary']['approveicon']=0;
            $orderby=' GROUP BY ld_workreply.workreplyid order by ld_workreply.createdtime desc ';
        }
        else{
            $sql="select id from ld_workreport_remind  where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0";
            $result=$adb->pquery($sql,array($current_user->id));
            //$workreminds['approveicon']=1;//表示有提醒数量
            if($adb->num_rows($result)>0)
            {
                $jsonArray['summary']['replyicon']=1;
                $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreply.workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1
                ,ld_workreport.workreportid,userreply.last_name as replyusername,userreply.wx_userid as replywxuserid,
                ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,ld_users.last_name,ld_users.wx_userid as la_wx_userid
                from ld_workreply
                left join ld_users as userreply on userreply.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   userreply.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join (select relatedto,createdtime From ld_workreport_remind where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0 )
                as tmpremindreply  on tmpremindreply.relatedto=ld_workreply.workreplyid
                inner join ld_workreport on  ld_workreport.workreportid=ld_workreply.workreportid
                left join ld_users on ld_users.id=ld_workreport.smcreatorid ";
                $jsonArray['summary']['icontype']=1;

                $orderby=' order by tmpremindreply.createdtime desc ';

                //修改工作提醒状态
                $update_remind_sql=" update ld_workreport_remind set remind_status=1 where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0";
            }
            else
            {
                $jsonArray['summary']['icontype']=0;
                $sql="select ld_salesmanattachmentsrel.attachmentsid,path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreply.workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1,
                ld_workreport.workreportid,userreply.last_name as replyusername,userreply.wx_userid as replywxuserid,
                ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,ld_users.last_name,ld_users.wx_userid as la_wx_userid
                from ld_workreply
                left join ld_users as userreply on userreply.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   userreply.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_users on ld_users.id=ld_workreport.smcreatorid
                left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
                where ld_workreply2user.userid=?  and (ld_workreport2user.user_type=2 or ld_workreport2user.user_type=4 or ld_workreport2user.user_type=1)";
                $jsonArray['summary']['approveicon']=0;
                $orderby=' order by ld_workreply.createdtime desc ';
            }
        }
        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $params=array($_REQUEST['viewuserid'],$_REQUEST['viewuserid']);
        }
        else{
            $params=array($current_user->id);
        }
        $sqlcounts=explode('from',$sql);
        $sqlcount='select 1  from '.$sqlcounts[1];
        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $sqlcount .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id and ld_workreport2user.user_type = 4 or ld_workreport2user.user_type=1) ";
            $sqlcount .= " GROUP BY ld_workreply.workreplyid ";
        }
        //echo $sqlcount;echo '<br><br>';print_r($params);echo '<br><br>';
        $resultcount=$adb->pquery($sqlcount,$params);
        $noofrows=$adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows']=$noofrows;

        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';

        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
            $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
            $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
            $havenextpage='no';
            $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
            $haveprevpage='no';
            $startpagenum=0;
        }

        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;

        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
            $sql .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id and ld_workreport2user.user_type = 4 or ld_workreport2user.user_type=1 or ld_workreport2user.user_type=3) ";
        }

        $sql.="  $orderby  limit $startpagerecord, $mobile_pagerecordcount ";
        //echo $sql;echo '<br>';print_r($params);die;
        $result=$adb->pquery($sql,$params);
        $entityContent=array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $replyuserid = $adb->query_result($result,$i,'replyuserid');
            //$replyusername = getUserFullName($replyuserid);
            $replyusername=$adb->query_result($result,$i,'replyusername');
			$replywxuserid=$adb->query_result($result,$i,'replywxuserid');
			$userobj=new Users();
			$userobj->wx_userid=$replywxuserid;
			$userobj->last_name=$replyusername;
			$replyusername=getUserlastName($userobj);
            $content=$adb->query_result($result,$i,'text');
            $type=$adb->query_result($result,$i,'type');
            $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
            $path=$adb->query_result($result,$i,'path');
            $userimagename=$adb->query_result($result,$i,'userimagename');
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$replyuserid);
            $reporttype=$adb->query_result($result,$i,'entitytype');
            $workreporttype=$adb->query_result($result,$i,'workreporttype');
            $workreportcontent=$adb->query_result($result,$i,'workexperience');
			$userobj=new Users();
			$userobj->wx_userid=$adb->query_result($result,$i,'la_wx_userid');;
			$userobj->last_name=$adb->query_result($result,$i,'last_name');;
			$workreportuser=getUserlastName($userobj);
            $workreportcontent = $this->filterWorkSummary($workreportcontent);
            if($reporttype=='cocmd')
            {
                $workreportcontent="回复$workreportuser"."的".getFixedLabel('TASK').":".$workreportcontent;
                $reporttypeStr = getFixedLabel('TASK');
            }
            else if($reporttype=='workreport')
            {
                if($workreporttype==1){
                    $workreportcontent="回复$workreportuser"."的".getFixedLabel('JOURNAL').":".$workreportcontent;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                }
                else if($workreporttype==2){
                    $workreportcontent="回复$workreportuser"."的".getFixedLabel('WEEKPLAN').":".$workreportcontent;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                }
                else if($workreporttype==3){
                    $workreportcontent="回复$workreportuser"."的".getFixedLabel('MONTHPLAN').":".$workreportcontent;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }
            }
            else if($reporttype=='weibo')
            {
                $workreportcontent="回复$workreportuser"."的".getFixedLabel('BLOG').":".$workreportcontent;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            if(!empty($content)){
                $content = $this->filterWorkSummary($content);
            }
            $entityContent[]=array( 'replyid'=>$adb->query_result($result,$i,'workreplyid'),'replycontent'=>$content,'createdtime'=>$this->getDateDescription($adb->query_result($result,$i,'createdtime')),'replyusername'=>$replyusername,
                'replyuserid'=>$replyuserid,'userimage'=>$userfilepath,'reportid'=>$adb->query_result($result,$i,'workreportid'),
                'reportcontent'=>$workreportcontent,'reporttype'=>$reporttype,'reporttypeStr'=>$reporttypeStr
            );
        }
        $jsonArray['list']=$entityContent;
        $jsonArray['field']=$this->getallFieldsForTable();
        if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
        }
        else{
            if(isset($update_remind_sql)){//修改工作提醒状态
                $adb->pquery($update_remind_sql,array($current_user->id));
            }
        }
        return $jsonArray;
    }
    //格式化返回值&替换表情路径
    protected function filterWorkSummary($value){
        $value = str_replace("\n","<br>",$value);
        $value = str_replace('themes/softed/emojicookie/','http://www.51mis.cn/websaas/wx_images/emojicookie/',$value);
        return $value;
    }
}