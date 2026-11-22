<?php

/**
 * Created by PhpStorm.
 * User: gyq_29
 * Date: 2017/3/27 0027
 * Time: 下午 5:49
 */
crm_load_class_file('WorkReportModelMC','appCommon/modules/Home');
class WorkReportModelWX extends WorkReportModelMC
{
    //gyq_45 gyqTE 如何处理好和PC端getUserArrayWX的关系？
    public function __construct() {
        parent::__construct();
        $this->plateform='mobile';

    }
    public function getUserArrayWX() {
        $userarr_orign = $this->getUserArray();

        $field_arr= array('userid','username','lastname','phone_mobile','userimgpath','status','groupid','email','wx_userid');
        $i=0;
        $user_arr = array();
        $mobile_exist = array();
        $email_exist = array();
        $wx_userid_exist = array();
        foreach($userarr_orign as $key=>$content){
            $mobile = $content['phone_mobile']['value'];
            $email = $content['email']['value'];
            $status = $content['status']['value'];
            if(empty($mobile)&&empty($email) || strtolower($status)=='inactive'){
                continue;
            }else{
                $wx_userid = $content['wx_userid']['value'];
                if(in_array($mobile,$mobile_exist) || in_array($email,$email_exist) || in_array($wx_userid,$wx_userid_exist)){continue;}
                if(!empty($mobile)){$mobile_exist[] = $mobile ;}
                if(!empty($email)){$email_exist[] = $email ;}
                if(!empty($wx_userid)) {
                    $wx_userid_exist[] = $wx_userid;
                    //editor:gyq_111 reason:企业微信小程序授权  2019/5/16 14:10
                    // 若系统用户没有使用过微信，将登录用户名作为微信通讯录账号
                    $content['username']['value'] = $wx_userid;
                }
                foreach($content as $fieldname=>$value){
                    if(in_array($fieldname,$field_arr)){
                        if($fieldname=='groupid'&&empty($value['value'])){//gyq_52 20171206 注册定制化 部门为空的用户默认为一级公司部门
                            $user_arr[$i]['groupid'] = 1;
                        }else{
                            $user_arr[$i][$fieldname] = $value['value'];
                        }
                    }
                }
                $i++;
            }
        }
        return $user_arr;
    }
    public function getGroupInfoWX(){
        global $adb;
        $count_sql = 'SELECT depth,count(groupid) rownum FROM ld_groups  GROUP BY depth';
        $count_result = $adb->pquery($count_sql,array());
        $count_rows = $adb->num_rows($count_result);
        $groupby_arr = array();
        for($i=0;$i<$count_rows;++ $i){
            $groupbydepth = $adb->query_result($count_result,$i,'depth');
            $groupbynum = $adb->query_result($count_result,$i,'rownum');
            $groupby_arr[$groupbydepth] = $groupbynum;
        }
        $query = 'SELECT groupname,depth,groupid,parentgroup FROM ld_groups  ORDER BY groupid ASC ';
        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $group_arr = array();
        if($rows > 0){
            $groupbynum = array();
            for($i=0;$i<$rows;++ $i){
                $groupindex = $adb->query_result($result,$i,'groupid');
                $groupname = $adb->query_result($result,$i,'groupname');
                $depth = $adb->query_result($result,$i,'depth');
                $parentgroup = $adb->query_result($result,$i,'parentgroup');
                $p_group_arr = explode('::',$parentgroup);
                $groupid= $p_group_arr[$depth];
                $group_arr[$groupindex]['name'] = $groupname;
                if($depth==0){
                    $group_arr[$groupindex]['parentid'] =$parentid =  0;
                }else{
                    $group_arr[$groupindex]['parentid'] = $parentid =$p_group_arr[$depth-1];
                }
                $group_arr[$groupindex]['id'] = $groupid;
                if(empty($groupbynum[$parentid] )){
                    $groupbynum[$parentid] = 0;
                }
                $group_arr[$groupindex]['order'] = $groupbynum[$parentid]+100;
                $group_arr[$groupindex]['depth'] = $depth;
                $groupbynum[$parentid] = $groupbynum[$parentid]+100;
            }
        }
        $group_arr_new = arraySequence($group_arr,'depth','SORT_ASC');
        return $group_arr_new;
        /*{
   "name": "广州研发中心",
   "parentid": 1,
   "order": 1,
   "id": 2
        参数	必须	说明
access_token	是	调用接口凭证
name	是	部门名称。长度限制为1~64个字节，字符不能包括\:?”<>｜
parentid	是	父部门id，32位整型
order	否	在父部门中的次序值。order值大的排序靠前。有效的值范围是[0, 2^32)
id	否	部门id，32位整型。指定时必须大于1，否则自动生成
}*/
    }
    //editor:gyq date:20170327 reason:格式化日志输出样式
    protected function init_outputStyle(&$entity,$entitytype,$saleskit_day,$saleskit_week,$saleskit_month,$type,$worksummary,$workplan,$workexperience,$workplan_tuesday,$workplan_wednesday,$workplan_thursday,$workplan_friday,$workfldkeyarr,$adb,$result,$i){
        //editor:gyq reason: 日志、周计划、月计划返回格式修改 date:20161031
        if($entitytype == 'workreport') {
            $HomeTransfor = array('1'=>'dayreport','2'=>'weekreport','3'=>'monthreport');
            $workReportTemplate = $this->getallFieldsForTable();
            $fieldinfoArr = $workReportTemplate[$entitytype][$HomeTransfor[$type]]['fieldinfo'];
            foreach($fieldinfoArr as $key=>$val){
                if(strpos($val['label'],'请填写') === 0){
                    $label = substr($val['label'],9);
                }else{
                    $label = $val['label'];
                }
                $fieldinfoArrNew[$val['name']] = $label;
            }
            $saleskit_showtype = $entity['saleskit_showtype'];
            $saleskit_listinfo = $entity['saleskit_listinfo'];
            $saleskit_cell['saleskit_showtype'] = $saleskit_showtype;
            $saleskit_cell['saleskit_listinfo'] = $saleskit_listinfo;
        }
        $fieldinfoArrCopy = $fieldinfoArrNew;
        //editor:gyq_20190114
        if(!empty($saleskit_day)){
            $saleskit_cell['label'] = $fieldinfoArrNew['saleskit_day'];
            $saleskit_cell['value']  = str_replace("\n","<br>",$saleskit_day);
            $fieldinfoArrCopy['saleskit_day'] = $saleskit_cell;
        }
        if(!empty($saleskit_week)){
            $saleskit_cell['label'] = $fieldinfoArrNew['saleskit_week'];
            $saleskit_cell['value']  = str_replace("\n","<br>",$saleskit_week);
            $fieldinfoArrCopy['saleskit_week'] = $saleskit_cell;
        }
        if(!empty($saleskit_month)){
            $saleskit_cell['label'] = $fieldinfoArrNew['saleskit_month'];
            $saleskit_cell['value']  = str_replace("\n","<br>",$saleskit_month);
            $fieldinfoArrCopy['saleskit_month'] = $saleskit_cell;
        }

        if(!empty($worksummary)){
            $worksummary_orign = $worksummary;
            $worksummary = array();
            $worksummary['value'] = $this->filterWorkSummary($worksummary_orign);
            $worksummary['label'] = $fieldinfoArrNew['worksummary'];
            $fieldinfoArrCopy['worksummary'] = $worksummary;
        }else{
            unset($fieldinfoArrCopy['worksummary']);
        }
        if(!empty($workplan)){
            $worksummary_orign = $workplan;
            $workplan = array();
            $workplan['value'] = $this->filterWorkSummary($worksummary_orign);
            $workplan['label'] = $fieldinfoArrNew['workplan'];
            $fieldinfoArrCopy['workplan'] = $workplan;
        }else{
            unset($fieldinfoArrCopy['workplan']);
        }
        if(!empty($workexperience)){
            $worksummary_orign = $workexperience;
            $workexperience = array();
            $workexperience['value'] = $this->filterWorkSummary($worksummary_orign);
            $workexperience['label'] = $fieldinfoArrNew['workexperience'];
            $fieldinfoArrCopy['workexperience'] = $workexperience;
        }else{
            unset($fieldinfoArrCopy['workexperience']);
        }

        if(!empty($workplan_tuesday)){
            $worksummary_orign = $workplan_tuesday;
            $workexperience = array();
            $workexperience['value'] = $this->filterWorkSummary($worksummary_orign);
            $workexperience['label'] = $fieldinfoArrNew['workplan_tuesday'];
            $fieldinfoArrCopy['workplan_tuesday'] = $workexperience;
        }else{
            unset($fieldinfoArrCopy['workplan_tuesday']);
        }
        // //$workplan_wednesday,$workplan_thursday,$workplan_friday
        if(!empty($workplan_wednesday)){
            $worksummary_orign = $workplan_wednesday;
            $workexperience = array();
            $workexperience['value'] = $this->filterWorkSummary($worksummary_orign);
            $workexperience['label'] = $fieldinfoArrNew['workplan_wednesday'];
            $fieldinfoArrCopy['workplan_wednesday'] = $workexperience;
        }else{
            unset($fieldinfoArrCopy['workplan_wednesday']);
        }
        if(!empty($workplan_thursday)){
            $worksummary_orign = $workplan_thursday;
            $workexperience = array();
            $workexperience['value'] = $this->filterWorkSummary($worksummary_orign);
            $workexperience['label'] = $fieldinfoArrNew['workplan_thursday'];
            $fieldinfoArrCopy['workplan_thursday'] = $workexperience;
        }else{
            unset($fieldinfoArrCopy['workplan_thursday']);
        }
        if(!empty($workplan_friday)){
            $worksummary_orign = $workplan_friday;
            $workexperience = array();
            $workexperience['value'] = $this->filterWorkSummary($worksummary_orign);
            $workexperience['label'] = $fieldinfoArrNew['workplan_friday'];
            $fieldinfoArrCopy['workplan_friday'] = $workexperience;
        }else{
            unset($fieldinfoArrCopy['workplan_friday']);
        }
        if (!empty($workfldkeyarr) && $entitytype == 'workreport') {

            foreach ($workfldkeyarr as $workfld) {
                $value = $adb->query_result($result, $i, $workfld);
                if (!empty($value)) {
                    $value = str_replace("\n", "<br>", $value);
                } else {
                    $value = '';
                }
                if(!empty($value)){
                    $orignArr = array();
                    $orignArr['value'] = $this->filterImage($value);
                    $orignArr['label'] = $fieldinfoArrNew[$workfld];
                    $fieldinfoArrCopy[$workfld] = $orignArr;
                }else{
                    unset($fieldinfoArrCopy[$workfld]);
                }
            }
        }
        $entity['linedetail'] = array_values($fieldinfoArrCopy);
    }

    //editor:gyq  reason:重写图片返回数据格式
    public function getWorkAchmentInfo($workreportid) {
        global $adb;
        static $static_workachment_arr;//防止重复执行
        $workachment = array();
        if(!empty($static_workachment_arr) && isset($static_workachment_arr[$workreportid])){
            $workachment = $static_workachment_arr[$workreportid];
        }else{
            $workachmentquery = 'SELECT achmentid,name,type,path,size,newfile_name,storage_location,cloud_path FROM ld_workachments
					WHERE workreportid = ? ORDER BY achmentid;';
            $workachmentresult = $adb->pquery($workachmentquery,array($workreportid));
            $workachmentrows = $adb->num_rows($workachmentresult);
            if($workachmentrows > 0){
                for($i=0;$i<$workachmentrows;++ $i){
                    $achmentid = $adb->query_result($workachmentresult,$i,'achmentid');
                    $achmentname = $adb->query_result($workachmentresult,$i,'name');
                    $newfile_name = $adb->query_result($workachmentresult,$i,'newfile_name');
                    if($newfile_name == ''){
                        $newfile_name = $achmentname;
                    }
                    $imgtype = $adb->query_result($workachmentresult,$i,'type');
                    $achmentpath = trim($adb->query_result($workachmentresult,$i,'path'));
                    $achmentsize= trim($adb->query_result($workachmentresult,$i,'size'));
                    if(strrchr($achmentpath,'/')!='/')
                    {
                        $achmentpath.='/';
                    }
                    if ($achmentsize < 1024)
        				$showsize = $achmentsize . ' B';
        			elseif ($achmentsize > 1024 && $achmentsize < 1048576)
        				$showsize = round($achmentsize / 1024, 2) . ' KB';
        			else if ($achmentsize > 1048576)
        				$showsize = round($achmentsize / (1024 * 1024), 2) . ' MB';
                    //gyqCom0320 date:20170320 reason:附件图片分类
                    $tempunit['name'] = $achmentname;
                    $tempunit['path'] = $achmentpath.urlencode($newfile_name);
                    $tempunit['real_path'] = $achmentpath;
                    $tempunit['urlencode_path'] = urlencode($achmentpath.$newfile_name);//editor:gyq date:20170330 reasn:附件预览传递文件路径
                    $tempunit['size'] = $showsize;
                    $tempunit['sizeraw'] = $achmentsize;
                    $tempunit['achmentid'] = $adb->query_result($workachmentresult,$i,'achmentid');
                    $tempunit['newfile_name'] = $newfile_name;
                    $tempunit['storage_location']=trim($adb->query_result($workachmentresult,$i,'storage_location'));
                    $tempunit['cloud_path']=trim($adb->query_result($workachmentresult,$i,'cloud_path')??'');
                    $workachment[$imgtype][] = $tempunit;
                    //$workachment[$imgtype][] = $achmentpath.urlencode($achmentname);
                    if(isset($workachment[$imgtype.'_count'])){
                        $workachment[$imgtype.'_count']++;
                    }else{
                        $workachment[$imgtype.'_count']=1;
                    }
                }
                //$workachment['count'] = $i;
            }else{
                $workachment['image'] = array();
                $workachment['count'] = 0;
            }
            $static_workachment_arr[$workreportid] = $workachment;
        }
        if(!empty($workachment)) return $workachment;
        return '';
    }
    //过滤表情
    protected function filterImage($worksummary){
        $worksummary_orign = preg_replace("/<img height=\"18\" width=\"18\" style=\"vertical-align:middle\" src=\".*\" >/i", "", htmlspecialchars_decode($worksummary));
        return $worksummary;
    }


//gyq date:20170325 reason:获取回复列表重写   	0027535: 微信端：工作协同>看日志>个人信息>工作回复界面：进入后数据显示不全
    protected function  Wait_getworkReplyAppList(){
        $viewuserid = $_REQUEST['viewuserid'];
        global $adb, $current_user, $mobile_pagerecordcount;
        $jsonArray['summary']['icontype'] = 0;
        $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.name as userimagename ,
             workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1, ld_workreport.workreportid,
                ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
            from ld_workreply
            left join ld_users on ld_users.id=ld_workreply.replyuserid
            left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
           left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
            inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
            where ld_workreport.smcreatorid=? AND replyuserid=?";
        $orderby = ' order by ld_workreply.createdtime desc ';
        $params = array($current_user->id,$viewuserid);
        $sqlcounts = explode('from', $sql);
        $sqlcount = 'select 1  from ' . $sqlcounts[1];
        $resultcount = $adb->pquery($sqlcount, $params);
        $noofrows = $adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows'] = $noofrows;
        $startpagenum = 0;
        $endpagenum = $mobile_pagerecordcount;
        $startpagerecord = 0;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';
        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $_REQUEST['page'] = 1;
        }
        $startpagenum = $_REQUEST['page'] - 1;
        if ($_REQUEST['page'] >= $totalpagecount)//是否有下一页
        {
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($_REQUEST['page'] <= 1)//是否有上一页
        {
            $haveprevpage = 'no';
            $startpagenum = 0;
        }
        $jsonArray['summary']['pagecount'] = $totalpagecount;
        $jsonArray['summary']['havenextpage'] = $havenextpage;
        $jsonArray['summary']['haveprevpage'] = $haveprevpage;
        $jsonArray['summary']['curpagenum'] = $startpagenum + 1;

        $startpagerecord = $startpagenum * $mobile_pagerecordcount;
        $endpagerecord = $startpagerecord + $mobile_pagerecordcount;
        $sql .= "    $orderby  limit $startpagerecord, $mobile_pagerecordcount ";
        $entityContent = array();
        $result = $adb->pquery($sql, $params);
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $replyuserid = $adb->query_result($result, $i, 'replyuserid');
            $replyusername = getUserFullName($replyuserid);
            $content = $adb->query_result($result, $i, 'text');
            $type = $adb->query_result($result, $i, 'type');
            $attachmentsid = $adb->query_result($result, $i, 'attachmentsid');
            $path = $adb->query_result($result, $i, 'path');
            $userimagename = $adb->query_result($result, $i, 'userimagename');
            $userfilepath = $this->getUserImage($path, $userimagename, $attachmentsid,$replyuserid);
            $reporttype = $adb->query_result($result, $i, 'entitytype');
            $workreporttype = $adb->query_result($result, $i, 'workreporttype');
            $workreportcontent = $adb->query_result($result, $i, 'workexperience');
            if ($reporttype == 'cocmd') {
                $workreportcontent = '回复我的'.getFixedLabel('TASK').':' . $workreportcontent;
                $reporttypeStr = getFixedLabel('TASK');
            } else if ($reporttype == 'workreport') {
                if ($workreporttype == 1) {
                    $workreportcontent = '回复我的'.getFixedLabel('JOURNAL').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                } else if ($workreporttype == 2) {
                    $workreportcontent = '回复我的'.getFixedLabel('WEEKPLAN').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                } else if ($workreporttype == 3) {
                    $workreportcontent = '回复我的'.getFixedLabel('MONTHPLAN').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }

            } else if ($reporttype == 'weibo') {
                $workreportcontent = '回复我的'.getFixedLabel('BLOG').':' . $workreportcontent;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            if (!empty($content)) {
                $content = str_replace("\n", "<br>", $content);
            }
            $entityContent[] = array('replyid' => $adb->query_result($result, $i, 'workreplyid'), 'replycontent' => $content, 'createdtime' => $this->getDateDescription($adb->query_result($result, $i, 'createdtime')), 'replyusername' => $replyusername,
                'replyuserid' => $replyuserid, 'userimage' => $userfilepath, 'reportid' => $adb->query_result($result, $i, 'workreportid'),
                'reportcontent' => $workreportcontent, 'reporttype' => $reporttype, 'reporttypeStr' => $reporttypeStr
            );
        }
        $jsonArray['list'] = $entityContent;
        return $jsonArray;
    }
    /**
     * edit:can
     * reason:获取我发出工作的回复
     * */
    /*gyq date:20170325 reason:获取回复列表不区分已读未读*/
    function getworkReplyAppList_WaitDelete()
    {
        global $adb, $current_user, $mobile_pagerecordcount;
        $sql = "select id from ld_workreport_remind  where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0";
        $result = $adb->pquery($sql, array($current_user->id));
        //$workreminds['approveicon']=1;//表示有提醒数量
        if ($adb->num_rows($result) > 0) {
            $jsonArray['summary']['replyicon'] = 1;
            $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.name as userimagename ,
                     workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1 ,ld_workreport.workreportid,
                    ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
                from ld_workreply
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
				inner join (select relatedto,createdtime From ld_workreport_remind where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0 )
								 as tmpremindreply  on tmpremindreply.relatedto=ld_workreply.workreplyid
                inner join ld_workreport on  ld_workreport.workreportid=ld_workreply.workreportid";
            $jsonArray['summary']['icontype'] = 1;

            $orderby = ' order by tmpremindreply.createdtime desc ';

            //修改工作提醒状态
            $update_remind_sql = " update ld_workreport_remind set remind_status=1 where relatedtable='workreply' and remindtype=2 and userid=? and remind_status=0";


        } else {
            $jsonArray['summary']['icontype'] = 0;
            $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.name as userimagename ,
                 workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1, ld_workreport.workreportid,
                    ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype
                from ld_workreply
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
                where ld_workreport.smcreatorid=? ";
            $jsonArray['summary']['approveicon'] = 0;
            $orderby = ' order by ld_workreply.createdtime desc ';
        }


        $params = array($current_user->id);
        $sqlcounts = explode('from', $sql);
        $sqlcount = 'select 1  from ' . $sqlcounts[1];

        $resultcount = $adb->pquery($sqlcount, $params);
        $noofrows = $adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows'] = $noofrows;


        $startpagenum = 0;
        $endpagenum = $mobile_pagerecordcount;
        $startpagerecord = 0;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';

        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $_REQUEST['page'] = 1;
        }
        $startpagenum = $_REQUEST['page'] - 1;
        if ($_REQUEST['page'] >= $totalpagecount)//是否有下一页
        {
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($_REQUEST['page'] <= 1)//是否有上一页
        {
            $haveprevpage = 'no';
            $startpagenum = 0;
        }

        $jsonArray['summary']['pagecount'] = $totalpagecount;
        $jsonArray['summary']['havenextpage'] = $havenextpage;
        $jsonArray['summary']['haveprevpage'] = $haveprevpage;
        $jsonArray['summary']['curpagenum'] = $startpagenum + 1;
        $startpagerecord = $startpagenum * $mobile_pagerecordcount;
        $endpagerecord = $startpagerecord + $mobile_pagerecordcount;
        $sql .= "    $orderby  limit $startpagerecord, $mobile_pagerecordcount ";
        $entityContent = array();
        //echo $sql;echo '<br>';
        //print_r($params);die;
        $result = $adb->pquery($sql, $params);
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $replyuserid = $adb->query_result($result, $i, 'replyuserid');
            $replyusername = getUserFullName($replyuserid);
            $content = $adb->query_result($result, $i, 'text');
            $type = $adb->query_result($result, $i, 'type');
            $attachmentsid = $adb->query_result($result, $i, 'attachmentsid');
            $path = $adb->query_result($result, $i, 'path');
            $userimagename = $adb->query_result($result, $i, 'userimagename');
            $userfilepath = $this->getUserImage($path, $userimagename, $attachmentsid,$replyuserid);
            $reporttype = $adb->query_result($result, $i, 'entitytype');
            $workreporttype = $adb->query_result($result, $i, 'workreporttype');
            $workreportcontent = $adb->query_result($result, $i, 'workexperience');
            if ($reporttype == 'cocmd') {
                $workreportcontent = '回复我的'.getFixedLabel('TASK').':' . $workreportcontent;
                $reporttypeStr = getFixedLabel('TASK');
            } else if ($reporttype == 'workreport') {
                if ($workreporttype == 1) {
                    $workreportcontent = '回复我的'.getFixedLabel('JOURNAL').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                } else if ($workreporttype == 2) {
                    $workreportcontent = '回复我的'.getFixedLabel('WEEKPLAN').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                } else if ($workreporttype == 3) {
                    $workreportcontent = '回复我的'.getFixedLabel('MONTHPLAN').':' . $workreportcontent;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }

            } else if ($reporttype == 'weibo') {
                $workreportcontent = '回复我'.getFixedLabel('BLOG').':' . $workreportcontent;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            if (!empty($content)) {
                $content = str_replace("\n", "<br>", $content);
            }
            $entityContent[] = array('replyid' => $adb->query_result($result, $i, 'workreplyid'), 'replycontent' => $content, 'createdtime' => $this->getDateDescription($adb->query_result($result, $i, 'createdtime')), 'replyusername' => $replyusername,
                'replyuserid' => $replyuserid, 'userimage' => $userfilepath, 'reportid' => $adb->query_result($result, $i, 'workreportid'),
                'reportcontent' => $workreportcontent, 'reporttype' => $reporttype, 'reporttypeStr' => $reporttypeStr
            );
        }
        $jsonArray['list'] = $entityContent;
        if (isset($update_remind_sql)) {
            //修改工作提醒状态
            $adb->pquery($update_remind_sql, array($current_user->id));
        }
        return $jsonArray;

    }

    /**
     * edit:can
     * reason:@我的回复
     * */
    public function Wait_getAtReplyAppList()
    {
        global $adb, $current_user, $mobile_pagerecordcount;
        $sql = "select id from ld_workreport_remind  where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0";
        $result = $adb->pquery($sql, array($current_user->id));
        //$workreminds['approveicon']=1;//表示有提醒数量
        if ($adb->num_rows($result) > 0) {
            $jsonArray['summary']['replyicon'] = 1;
            $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.name as userimagename ,
                     ld_workreply.workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1
                     ,ld_workreport.workreportid,userreply.last_name as replyusername,
                    ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,ld_users.last_name
                from ld_workreply
                left join ld_users as userreply on userreply.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   userreply.id=ld_salesmanattachmentsrel.smid
                left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
				inner join (select relatedto,createdtime From ld_workreport_remind where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0 )
								 as tmpremindreply  on tmpremindreply.relatedto=ld_workreply.workreplyid
                inner join ld_workreport on  ld_workreport.workreportid=ld_workreply.workreportid
                left join ld_users on ld_users.id=ld_workreport.smcreatorid ";
            $jsonArray['summary']['icontype'] = 1;

            $orderby = ' order by tmpremindreply.createdtime desc ';

            //修改工作提醒状态
            $update_remind_sql = " update ld_workreport_remind set remind_status=1 where relatedtable='workreply' and remindtype=4 and userid=? and remind_status=0";


        } else {
            $jsonArray['summary']['icontype'] = 0;
            $sql = "select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.name as userimagename ,
                 ld_workreply.workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1,
                  ld_workreport.workreportid,userreply.last_name as replyusername,
                    ld_workreport.workexperience,ld_workreport.entitytype,ld_workreport.type as workreporttype,ld_users.last_name
                from ld_workreply
                left join ld_users as userreply on userreply.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   userreply.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                inner join ld_workreport  on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_users on ld_users.id=ld_workreport.smcreatorid
                inner join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
                where ld_workreply2user.userid=?  and (user_type=2 or user_type=4)";
            $jsonArray['summary']['approveicon'] = 0;
            $orderby = ' order by ld_workreply.createdtime desc ';
        }


        $params = array($current_user->id);
        $sqlcounts = explode('from', $sql);
        $sqlcount = 'select 1  from ' . $sqlcounts[1];

        $resultcount = $adb->pquery($sqlcount, $params);
        $noofrows = $adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows'] = $noofrows;


        $startpagenum = 0;
        $endpagenum = $mobile_pagerecordcount;
        $startpagerecord = 0;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';

        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $_REQUEST['page'] = 1;
        }
        $startpagenum = $_REQUEST['page'] - 1;
        if ($_REQUEST['page'] >= $totalpagecount)//是否有下一页
        {
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($_REQUEST['page'] <= 1)//是否有上一页
        {
            $haveprevpage = 'no';
            $startpagenum = 0;
        }

        $jsonArray['summary']['pagecount'] = $totalpagecount;
        $jsonArray['summary']['havenextpage'] = $havenextpage;
        $jsonArray['summary']['haveprevpage'] = $haveprevpage;
        $jsonArray['summary']['curpagenum'] = $startpagenum + 1;
        $startpagerecord = $startpagenum * $mobile_pagerecordcount;
        $endpagerecord = $startpagerecord + $mobile_pagerecordcount;
        $sql .= "    $orderby  limit $startpagerecord, $mobile_pagerecordcount ";

        $result = $adb->pquery($sql, $params);
        $entityContent = array();
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $replyuserid = $adb->query_result($result, $i, 'replyuserid');
            //$replyusername = getUserFullName($replyuserid);
            $replyusername = $adb->query_result($result, $i, 'replyusername');
            $content = $adb->query_result($result, $i, 'text');
            $type = $adb->query_result($result, $i, 'type');
            $attachmentsid = $adb->query_result($result, $i, 'attachmentsid');
            $path = $adb->query_result($result, $i, 'path');
            $userimagename = $adb->query_result($result, $i, 'userimagename');
            $userfilepath = $this->getUserImage($path, $userimagename, $attachmentsid,$replyuserid);
            $reporttype = $adb->query_result($result, $i, 'entitytype');
            $workreporttype = $adb->query_result($result, $i, 'workreporttype');
            $workreportcontent = $adb->query_result($result, $i, 'workexperience');
            $workreportuser = $adb->query_result($result, $i, 'last_name');

            if ($reporttype == 'cocmd') {
                $workreportcontent = "回复$workreportuser" . "的".getFixedLabel('TASK').":" . $workreportcontent;
                $reporttypeStr = getFixedLabel('TASK');
            } else if ($reporttype == 'workreport') {
                if ($workreporttype == 1) {
                    $workreportcontent = "回复$workreportuser" . "的".getFixedLabel('JOURNAL').":" . $workreportcontent;
                    $reporttypeStr = getFixedLabel('JOURNAL');
                } else if ($workreporttype == 2) {
                    $workreportcontent = "回复$workreportuser" . "的".getFixedLabel('WEEKPLAN').":" . $workreportcontent;
                    $reporttypeStr = getFixedLabel('WEEKPLAN');
                } else if ($workreporttype == 3) {
                    $workreportcontent = "回复$workreportuser" . "的".getFixedLabel('MONTHPLAN').":" . $workreportcontent;
                    $reporttypeStr = getFixedLabel('MONTHPLAN');
                }

            } else if ($reporttype == 'weibo') {
                $workreportcontent = "回复$workreportuser" . "的".getFixedLabel('BLOG').":" . $workreportcontent;
                $reporttypeStr = getFixedLabel('BLOG');
            }

            if (!empty($content)) {
                $content = str_replace("\n", "<br>", $content);
            }
            $entityContent[] = array('replyid' => $adb->query_result($result, $i, 'workreplyid'), 'replycontent' => $content, 'createdtime' => $this->getDateDescription($adb->query_result($result, $i, 'createdtime')), 'replyusername' => $replyusername,
                'replyuserid' => $replyuserid, 'userimage' => $userfilepath, 'reportid' => $adb->query_result($result, $i, 'workreportid'),
                'reportcontent' => $workreportcontent, 'reporttype' => $reporttype, 'reporttypeStr' => $reporttypeStr
            );
        }
        $jsonArray['list'] = $entityContent;
        if (isset($update_remind_sql)) {
            //修改工作提醒状态
            $adb->pquery($update_remind_sql, array($current_user->id));
        }
        return $jsonArray;
    }

    public function getRangeCommentExecutorCommon()
    {
        global $adb, $current_user;
        $userid = $current_user->id;
        $ccgroup = '';
        $ccgroupname = '';
        $ccuser = '';
        $ccusername = '';
        $comment_execution = '';
        $comment_execution_name = '';
        $com_execname = '';
        $type = $_REQUEST['type'];
        if ($type == 'ItemLogday') {
            $entitytype = 'workreport';
            $type = '1';
            $workreprottype = 'day';
        } else if ($type == 'ItemLogweek') {
            $entitytype = 'workreport';
            $type = '2';
            $workreprottype = 'week';
        } else if ($type == 'ItemLogmonth') {
            $entitytype = 'workreport';
            $type = '3';
            $workreprottype = 'month';
        } else if ($type == 'ItemWeibo') {
            $entitytype = 'weibo';
            $type = '1';
        } else if ($type == 'ItemCocmd') {
            $entitytype = 'cocmd';
            $type = '1';
        }
        $sql = "SELECT 
                    type, 
                    entitytype, 
                    CASE 
                        WHEN ld_workrangenote.rang_group='all' THEN 'all' 
                        WHEN ld_workrangenote.rang_group LIKE '%all%' AND IFNULL(ld_workrangenote.rang_group,'')<>'all' THEN 
                            CONCAT('all,',(SELECT GROUP_CONCAT(groupid) FROM ld_groups WHERE FIND_IN_SET(groupid,ld_workrangenote.rang_group) ORDER BY groupid)) 
                        ELSE 
                            (SELECT GROUP_CONCAT(groupid) FROM ld_groups WHERE FIND_IN_SET(groupid,ld_workrangenote.rang_group) ORDER BY groupid) 
                    END AS rang_group, 
                    CASE 
                        WHEN ld_workrangenote.rang_group='all' THEN '全部' 
                        WHEN ld_workrangenote.rang_group LIKE '%all%' AND IFNULL(ld_workrangenote.rang_group,'')<>'all' THEN 
                            CONCAT('全部,',(SELECT GROUP_CONCAT(groupname) FROM ld_groups WHERE FIND_IN_SET(groupid,ld_workrangenote.rang_group) ORDER BY groupid)) 
                        ELSE 
                            (SELECT GROUP_CONCAT(groupname order by groupid desc separator 'a##a') FROM ld_groups WHERE FIND_IN_SET(groupid,ld_workrangenote.rang_group) ORDER BY groupid) 
                    END AS rang_group_name, 
                    (SELECT GROUP_CONCAT(id) FROM ld_users WHERE `status`='Active' AND FIND_IN_SET(id,ld_workrangenote.rang_users) ORDER BY id) AS rang_users, 
                    (SELECT GROUP_CONCAT(last_name order by id desc separator 'a##a') FROM ld_users WHERE `status`='Active' AND FIND_IN_SET(id,ld_workrangenote.rang_users) ORDER BY id) AS rang_users_name, 
                    (SELECT GROUP_CONCAT(id) FROM ld_users WHERE `status`='Active' AND FIND_IN_SET(id,ld_workrangenote.comment_execution) ORDER BY id) AS comment_execution, 
                    (SELECT GROUP_CONCAT(last_name) FROM ld_users WHERE `status`='Active' AND FIND_IN_SET(id,ld_workrangenote.comment_execution) ORDER BY id) AS comment_execution_name 
                FROM ld_workrangenote 
                WHERE userid = ?
                    AND type = ? 
                    AND entitytype = ? ";
        $result = $adb->pquery($sql, array($userid, $type, $entitytype));
        $contents = array();
        if ($adb->num_rows($result) > 0) {
            $ccgroup = $adb->query_result($result, 0, 'rang_group');
            $ccgroup_arr=explode(",",$ccgroup);
            //edit:can 20210204 44567: 企业微信->kehu001账套->工作汇报->发布周计划之后，再次发布周计划，抄送范围记住的用户信息异常
            $ccgroupname = $adb->query_result($result, 0, 'rang_group_name');
            $ccgroupname_arr=explode("a##a",$ccgroupname);
            $groupname_arr=[];
            for($i=0;$i<sizeof($ccgroupname_arr);$i++)
            {
                $groupobj=new Users();
                $groupobj->groupname=$ccgroupname_arr[$i];
                $groupobj->groupid=$ccgroup_arr[$i];
               $groupname_arr[]=getWxRemindGroupName($groupobj);
                
            }
            $ccgroupname=implode(",",$groupname_arr);
            $ccuser = $adb->query_result($result, 0, 'rang_users');
            $ccusername = $adb->query_result($result, 0, 'rang_users_name');
            $ccuserid_arr=explode(",",$ccuser);
            $ccusername_arr=explode("a##a",$ccusername);
          
            $len=sizeof($ccuserid_arr);
            $userobj=new Users();
            $lastname_arr=[];
            for($i=0;$i<$len;$i++)
            {
                $userobj->last_name=$ccusername_arr[$i];
                $userobj->id=$ccuserid_arr[$i];
                $userobj->wx_userid='';
                $lastname_arr[]=getUserlastName($userobj);
            }
            $ccusername=implode(",",$lastname_arr);
            $comment_execution = $adb->query_result($result, 0, 'comment_execution');
            $comment_execution_name = $adb->query_result($result, 0, 'comment_execution_name');
        }

        if ($entitytype == 'workreport'){
            $setting_presence = getUsersettingByLabel('WorkTemplateRule',1,$workreprottype);
            $setting_presence = empty($setting_presence)?'yes':$setting_presence;

            if ($setting_presence == 'yes'){
                crm_load_class_file('WorkTemplateRule','modules/Settings');
                $workTemplateRuleobj = new WorkTemplateRule();
                $workTemplateRuleobj->setWorkReportType($workreprottype);
                $applicable_ruleinfo = $workTemplateRuleobj->getApplicableRuleByUserid($current_user->id);
                $reuser_userinfo = $applicable_ruleinfo['reuser_value_userinfo'];
                $reuser_presence = $applicable_ruleinfo['reuser_presence'];
                $ccuser_userinfo = $applicable_ruleinfo['ccuser_value_userinfo'];
                $ccuser_presence = $applicable_ruleinfo['ccuser_presence'];
                //点评人
                if ($reuser_presence == 'yes'){
                    if (empty($reuser_userinfo)){
                        $comment_execution = '';
                        $comment_execution_name = '';
                    }else{
                        $comment_execution = key($reuser_userinfo);
                        $comment_execution_name = $reuser_userinfo[$comment_execution];
                        $contents['resuerdisabled'] = 'yes';
                    }
                }
//                dump([$ccuserid_arr,$ccuser_userinfo]);
                //抄送范围
                if ($ccuser_presence == 'yes'){
                    $disableduser = implode(',',array_keys($ccuser_userinfo));
                    $contents['disableduser'] = $disableduser;
                    foreach ($ccuserid_arr as $key => $tmpuserid){
                        if (!array_key_exists($tmpuserid,$ccuser_userinfo)){
                            $ccuser_userinfo[$tmpuserid] = $ccusername_arr[$key];
                        }
                    }
                    $ccuser =  implode(',',array_keys($ccuser_userinfo));
                    $ccusername = implode(',',$ccuser_userinfo);
                }
            }


        }
        $contents['ccgroup'] = $ccgroup;
        $contents['ccgroupname'] = $ccgroupname;
        $contents['ccuser'] = $ccuser;
        $contents['ccusername'] = $ccusername;
        $contents['com_exec'] = $comment_execution;
        if (!empty($comment_execution)) {
            $userobj=new Users();
            $userobj->id=$comment_execution;
            $userobj->last_name=$comment_execution_name;
            $com_execname = getUserlastName($userobj);//点评人
        }else{
            $com_execname = '';
        }
        $contents['com_execname'] = $com_execname;//点评人
        $entity['list'] = $contents;
        return $entity;
    }

    //获取发送范围、点评人或执行人
    public function getRangeCommentExecutor()
    {

        ConvertTojsonString('1', $this->getRangeCommentExecutorCommon(), '');
    }

    public function getCRMModules(){
        global $adb,$current_user;
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        $availabletables_mixed= cls_Home_SpecialMC::getHomeModule();
        if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='quick'){
            //获取快速创建模块
            foreach($availabletables_mixed as $val){
                foreach($val['list'] as $listval){
                     $wxmodulearr[] = $listval;
                }
            }
            //移动端不允许快速创建的模块
            $noquickmodule = array('ChinaMap','ElectricCard','Shopping','TrackLocationMap');
            foreach($wxmodulearr as $wxmodules){
                $wxmodule = $wxmodules['module'];
                $wxtitle = $wxmodules['title'];
                $tab_tablename=$wxmodules['tab_tablename'];
                //editor:gyq_20191104 reason:变量书写错误：$wxmodules['module']被错误写成可$wxmodule['module']
                //0038272: 移动端，快速创建，将【客户地图】和【自定义链接网址模块】去掉（邱：客户地图未去掉。）
                if($tab_tablename!='ld_tab'||in_array($wxmodule,$noquickmodule))
                {
                    //38272: 移动端，快速创建，将【客户地图】和【自定义链接网址模块】去掉
                    continue;
                }
                $create_buttons = -1;
                if(in_array($wxmodule,array('PaymentPlan','ServiceReturn','Approve','Signin','CooperativeWork','NearbyAccounts','PublicAccounts','PublicLeads'))) continue;
                if(isPermitted($wxmodule,'Create','') == 'yes'){
                    //创建客户根据序时簿“新建”功能下拉按钮选项参数走
                    if($wxmodule=='Accounts') 
                    {
                        $create_buttons = $this->getAccountsCreateBtn();
                        if($create_buttons=='yes')
                            $quickmodules[$wxmodule] = array('title'=>$wxtitle,'module'=>$wxmodule,'accountType'=>$create_buttons);
                    }else if($wxmodule=='Leads'){
                        $create_buttons = $this->getLeadsCreateBtn();
                        if($create_buttons=='yes')
                            $quickmodules[$wxmodule] = array('title'=>$wxtitle,'module'=>$wxmodule,'accountType'=>$create_buttons);

                    }
                    else
                   
                        $quickmodules[$wxmodule] = array('title'=>$wxtitle,'module'=>$wxmodule,'accountType'=>$create_buttons);
                }
                
                
                //zxm 2021-1217 快速创建模块图标
                if(isset($wxmodules['active_icon'])&&isset($quickmodules[$wxmodule])){
                    $quickmodules[$wxmodule]['active_icon'] = $wxmodules['active_icon'];
                }
            }
            $entity['quicklist'] = array_values($quickmodules);
           
        }else{
            // diony 2024-05-14 设置放在WorkReportControllerWX.php中getCRMSetting方法，方便公用
            // $sql = 'select userid,deploy_value from ld_appsystem where userid= ? and deploy_type = 3';
            // $result=$adb->pquery($sql,array($current_user->id));
            // if($adb->num_rows($result)>0){
            //     $deploy_value = $adb->query_result($result,0,'deploy_value');
            //     $showtype = $deploy_value;
            // }
            // else{
            //     $showtype = '1';
            // }
            // $entity['showtype'] = $showtype;
            //通用设置 zxm 2021-0407
            $sql_common = 'select userid,is_open,deploy_value,deploy_type from ld_appsystem where userid= ? and deploy_type in(7,10,12,13,14) and is_open="yes"';
            $result_common = $adb->pquery($sql_common,array($current_user->id));
            $nums = $adb->num_rows($result_common);
            $entity['showListBtn'] = 'no';
            $entity['multiLineShowBtn'] = 'no';
            $entity['haveReturnHome'] = 'no';
            $entity['isSimpletype'] = 'no';
            $entity['distanceVisible'] = '5';
            if($nums>0){
                for($i=0;$i<$nums;$i++){
                    $deploy_type = $adb->query_result($result_common,$i,'deploy_type');
                    if($deploy_type==7){
                        $entity['showListBtn'] = 'yes';
                    }
                    if($deploy_type==10){
                        $entity['multiLineShowBtn'] = 'yes';
                    }
                    if($deploy_type==12){
                        $entity['haveReturnHome'] = 'yes';
                    }
                    if($deploy_type==13){
                        $entity['isSimpletype'] = 'yes';
                    }
                    if($deploy_type==14){
                        $entity['distanceVisible'] = $adb->query_result($result_common,$i,'deploy_value');
                    }
                }
            }
            $entity['blocklist'] = $availabletables_mixed;
        }
        //20171109更改前台返回，base/more
        /*
        $type = $_REQUEST['type'];
        if($type=='base'){
            if(count($wxmodulearr)>7){
                $entity['blocklist']['list'] = array_slice($wxmodulearr,0,7);
                $entity['blocklist']['showmore'] = 'yes';
            }else{
                $entity['blocklist']['list'] = $wxmodulearr;
                $entity['blocklist']['showmore'] = 'no';
            }
            $entity['quicklist'] = $quickmodules;
            $entity['showtype'] = $showtype;
        }elseif($type=='more'){
            $entity['blocklist'] = $availabletables_mixed;
            $entity['showtype'] = $showtype;
        }*/
        return $entity;
        //ConvertTojsonString(1,$entity,"");//gyq171124
    }

    public function getAccountsCreateBtn(){
       /* $publicaccount = getAccount_Set('publicaccount');
        if(cls_StaticCommonFun::isPublicAccountUser()) {
            // editor:gyqX170728 reason:给每个buttons加参数1
            $create_buttons = $publicaccount+1;
        }else{
            $create_buttons= 1;
        }*/
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = new cls_PublicAccounts('Accounts');
        $data = $cls_PublicAccounts->getPublicAccount();
        $create_buttons='no';
       
        if($data['status']=='yes')
        {
            //edit:can 20210409 45411: （kfbcrm，企业微信移动端）客户问题（戚涛），客户模块不启用公海，客户没有显示【新建】操作按钮（需要补丁）
            if($data['is_commonaccount_create']=='yes')
		      $create_buttons='yes';
        }
        else
        {
            //duan 2022-6-16 :客户未启用公海时，应该允许快速创建
            $create_buttons='yes';
        }
        return $create_buttons;
    }
    //duan 20240419 销售线索模块不允许创建普通销售线索时,不显示快速创建
    public function getLeadsCreateBtn(){
        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicAccounts = new cls_PublicLeads('Leads');
        $data = $cls_PublicAccounts->getPublicAccount();

        $create_buttons='no';

        if($data['status']=='yes')
        {

            if($data['is_commonaccount_create']=='yes')
                $create_buttons='yes';
        }
        else
        {
            $create_buttons='yes';
        }
        return $create_buttons;
    }

    public function savemoduleshowset(){
        global $adb,$current_user;
        $showtype=$_REQUEST['showtype'];//1方格显示，2列表显示
        $deploy_type = 3;
        $userid=$current_user->id;

        $sql = 'select userid,deploy_value from ld_appsystem where userid= ? and deploy_type = ?';
        $result=$adb->pquery($sql,array($userid,$deploy_type));
        if($adb->num_rows($result)>0)
        {
            $sql_update='update ld_appsystem set deploy_value = ? where userid= ? and deploy_type = ?';
            $adb->pquery($sql_update,array($showtype,$userid,$deploy_type));
        }
        else
        {
            $sql_insert='insert into ld_appsystem(userid,deploy_value,deploy_type,description)values(?,?,?,?)';
            $adb->pquery($sql_insert,array($userid,$showtype,$deploy_type,'微信模块显示方式'));
        }
        $cachekey = 'getWXUserModules'.$userid;
		unsetCacheDirOne('wxmodules',$cachekey);
        ConvertTojsonString(1,array(),'');
    }

    /**
     * 设置是否开启 单据列表是否显示快速操作按钮
     * zxm 2021-04-07
     * 设置保存值
     * diony 2023-09-20
     */
    public function savelistbtnshowset(){
        global $adb,$current_user;
        $is_open = $_REQUEST['is_open'];
        $deploy_type =$_REQUEST['deploy_type'];
        $deploy_type = empty($deploy_type)?7:$deploy_type;
        //描述
        if($deploy_type == '8'){
            $description = '功能菜单是否启用全局查找';
        }else if($deploy_type == '9'){
            $description = '启用扫一扫功能';
        }else if($deploy_type == '11'){
            $description = '单据分录明细是否折叠显示';
        }else if($deploy_type == '12'){
            $description = '是否启用快捷返回页签首页按钮';
        }else if($deploy_type == '13'){
            $description = '移动端图标是否更换简易风格';
        }else if($deploy_type == '14'){
            $description = '附近客户地图默认可见范围';
        }else{
            $description = '单据列表是否显示快速操作按钮';
        }
        $userid = $current_user->id;

        $sql = 'select userid,deploy_value from ld_appsystem where userid= ? and deploy_type = ?';
        $result=$adb->pquery($sql,array($userid,$deploy_type));
        if($adb->num_rows($result)>0)
        {
            if($deploy_type == '14'){
                $sql_update='update ld_appsystem set deploy_value = ? where userid= ? and deploy_type = ?';
                $adb->pquery($sql_update,array($is_open,$userid,$deploy_type));
            }
            else{
                $sql_update='update ld_appsystem set is_open = ? where userid= ? and deploy_type = ?';
                $adb->pquery($sql_update,array($is_open,$userid,$deploy_type));
            }
        }
        else
        {
            if($deploy_type == '14'){
                $sql_insert='insert into ld_appsystem(userid,deploy_value,is_open,deploy_type,description)values(?,?,?,?,?)';
                $adb->pquery($sql_insert,array($userid,$is_open,'yes',$deploy_type,$description));
            }
            else{
                $sql_insert='insert into ld_appsystem(userid,is_open,deploy_type,description)values(?,?,?,?)';
                $adb->pquery($sql_insert,array($userid,$is_open,$deploy_type,$description));
            }
        }
        ConvertTojsonString(1,array(),'');
    }
    /**
     * edit:xxs
     * reason:配置微信推送提醒参数
     * */
	public function saveRemindSet() {
	    global $adb,$current_user;
        $userid = $current_user->id;
        $sql="update ld_users set push_wx_reminds = !push_wx_reminds where id=?;";
        $adb->pquery($sql,array($userid));
		//更新当前用户的user_privileges的php文件
        crm_load_class_file('CreateUserPrivilegeFile','modules/Users');
		createUserPrivilegesfile($userid);
	}

    /**
     * edit:xxs
     * reason:获取微信推送提醒参数
     * */
	public function getRemindSet() {
	    global $current_user;
        $set = ($current_user->push_wx_reminds)?'1':'';
        return array('remindset'=>$set);
	}

    public function getHomeSetting(){
        global $current_user,$adb;
        $reg=RegOp::getInstance();
        //版本号
        //require(globalStatic::$root_directory.'include/language/zh_cn_version.lang.php');
        if(file_exists(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php")){
            require(globalStatic::$root_directory."dataCache/Login/zh_cn_version_new.lang.php");
        }else{
            require(globalStatic::$root_directory."include/language/zh_cn_version.lang.php");
        }
        if(!file_exists(globalStatic::$root_directory."dataCache/Login/LoginSettingsInfo.php"))
        {
            file_put_contents(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php',file_get_contents(globalStatic::$root_directory."LoginSettingsInfo_default.php"));
        }
        require_once(globalStatic::$root_directory.'dataCache/Login/LoginSettingsInfo.php');
        include (globalStatic::$root_directory.'lingdangversion.php');
        $version_no = $reg->GetVersionNo();
        $version_num = $common_version['lblversion'];
        $version_str = $versions[$version_no]['lblversion'];
        $ver_arr=[];
        if(!empty($version_str)&&!empty($version_num))
        {
            $version_str = mb_substr($version_str,0,strlen($version_str)-strlen($version_num));
            //editor:gyq_20190123 0036027: 企业微信-设置-当前版本，其中的版本号信息应该读取lingdangversion.php
            $ver_arr = explode('V',$version_str);
        }
        $version_str_2 = $ver_arr[0].$lingdang_current_version;
        $entity['versionname'] = $version_str_2;
        //有效期
        if($reg->softGetType()==1){
            $expiredate = getMobileFixedLabel('PERMANENTAUTHORIZATION');
        }else{
            $expiredate = $reg->getExpireDate();
        }
        //$entity['expired_time'] = $expiredate;
        //判断是否开启提醒
        $set = ($current_user->push_wx_reminds)?'1':'';
        $entity['remindset'] = $set;
        $isadmin = $current_user->is_admin=='on'?'yes':'no';
        $entity['isshow'] = $isadmin;
        //是否公海用户
        $entity['ispublicaccount'] = cls_StaticCommonFun::isPublicAccountUser()?'yes':'no';

        $entity['isdemo']=$reg->isDemo();

        $entity['isadmin']=$current_user->is_admin;

        $entity['versionno']=$reg->GetVersionNo();
        $entity['searchcrmversion']=isSearchCRMVersion();//是否为查询版本
        require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
        $wx_authinfo=doCorpInfo("get_auth_info",array());
        $wx_agentid="";
        $wx_corpid="";
        if($wx_authinfo!=''){
          $wx_auth_arr=  json_decode($wx_authinfo,true);
          $wx_agentid=$wx_auth_arr['crm']['auth_info']['agent'][0]['agentid'];
          $wx_corpid=$wx_auth_arr['crm']['auth_corp_info']['corpid'];
        }
        $entity['app']["agentid"]=$wx_agentid;
        $entity['app']['iskehu001']=isKehu001ServerPc();
        /*$entity['app']["corpid"]=$wx_corpid;
        crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
        $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
         $agentjsapi_ticket = $port_obj->getAgentJsApiTicket();
         $jsapi_ticket=$port_obj->getJsApiTicket();
            
         $http_html_url=GetCurUrl();
         $timestamp = time() ;
         $nonceStr =getRandChar(16);
         $agentjsapi_string = "jsapi_ticket=" . $agentjsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;
         $jsapi_string = "jsapi_ticket=" . $jsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;
         $agent_signature = sha1($agentjsapi_string);
         $signature = sha1($jsapi_string);
            
          $entity['app']["timestamp"]=$timestamp;
          $entity['app']["nonceStr"]=$nonceStr;
          $entity['app']["signature"]=$agent_signature;*/
          
        //是否开启外部联系人
        if(cls_StaticCommonFun::isExternalContactUser()) $entity['isexternalcontact'] = 'yes';

        //有效期和成员数量做数组返回 xxs 20180411
        $list1 = array();
        if($isadmin=='yes'){
            // $usernumsql = 'select user_name from ld_users where crm_user_type=\'crm\' and  status=\'active\' ';//获取启动的用户数
            $usernumsql = 'select crm_user_type,count(crm_user_type) as usercount from ld_users where status=\'active\' GROUP BY crm_user_type ORDER BY case when crm_user_type =\'crm\' then 1 else 2 end';//获取启动的用户数
            $usernumresult=$adb->pquery($usernumsql,array());
            $prmFlag = 'no';
            if($adb->num_rows($usernumresult) > 1){
                $crmcount = $adb->query_result($usernumresult,0,'usercount');
                $membersnum = $reg->GetUserCount().'（'.getMobileFixedLabel('USED2').$crmcount.'）';
                $prmFlag = 'yes';
                $prmcount = $adb->query_result($usernumresult,1,'usercount');
                $prmnum = $reg->getPrmUserCount().'（'.getMobileFixedLabel('USED2').$prmcount.'）';
            }
            else if($adb->num_rows($usernumresult) == 1){
                $usercount = $adb->query_result($usernumresult,0,'usercount');
                $membersnum = $reg->GetUserCount().'（'.getMobileFixedLabel('USED2').$usercount.'）';
            }
            $list1[] = array('a'=>getMobileFixedLabel('VALIDUNTIL'),'b'=>$expiredate);
            $list1[] = array('a'=>getMobileFixedLabel('LICENSEDUSERS2'),'b'=>$membersnum);
            if($prmFlag == 'yes'){
                $list1[] = array('a'=>getMobileFixedLabel('LICENSEDDEALERUSERS'),'b'=>$prmnum);
            }
        }
        //editor:gyq_20181101 设置加入热线号码
        $apptellabel = $global_logininfo['apptellabel'];
        $entity['servicephone']  = '';
        if($apptellabel['content'] != '' && $apptellabel['isshow'] == 'yes' ){
            $entity['servicephone'] = $apptellabel['content'];
        }
        $entity['list1'] = $list1;
        return $entity;
    }

    public function saveappuiset($setname,$settype){
        global $adb,$current_user;
        $userid=$current_user->id;
        //editor:gyq_157 reason:企业微信模块显示设置增加自定义表单\链接模块\报表  2019/11/5 17:27
        //不兼容APP
        $hiddenValueArr = explode(',',$setname);
        $sql = 'select 1 from ld_appuiset where userid=? and setname=? and settype=?  and  ifnull(tab_tablename,\'\')=? and apptype=?';
        $result=$adb->pquery($sql,array($userid,$hiddenValueArr[0],$hiddenValueArr[1],$hiddenValueArr[2],'weixin'));
        if($adb->num_rows($result)>0)
        {
            $sql_del='delete from ld_appuiset where userid=? and setname=? and settype=? and ifnull(tab_tablename,\'\')=? and apptype=?';
            $adb->pquery($sql_del,array($userid,$hiddenValueArr[0],$hiddenValueArr[1],$hiddenValueArr[2],'weixin'));
        }
        else
        {
            $sql_insert='insert into ld_appuiset(userid,setname,settype,tab_tablename,apptype) values(?,?,?,?,?)';
            $adb->pquery($sql_insert,array($userid,$hiddenValueArr[0],$hiddenValueArr[1],$hiddenValueArr[2],'weixin'));
        }
        if($settype=='module'){
            $cachekey = 'getWXUserModules'.$current_user->id;
            unsetCacheDirOne('wxmodules',$cachekey);
        }
    }

    public function getMeModules()
    {
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        $entity = cls_Home_SpecialMC::getWXModulesForMe();
        return array('list'=>$entity);
    }
    //editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/28 14:43
    public function getSendLog_SalesKit_Detail($r_type,$r_createtime,$r_userid,$r_datemark){
        global $current_user;
	    //editor:gyq_20180904 0035135: （珞落计划企业微信登录）工作汇报模块：新建日志和周计划界面销售简报区块中的数字和单据列表界面中的数据记录不一致
        //editor:gyq_90 reason:日志日期修改为自定义选择日期 2018/12/6 16:38
        //获取日志等单据详情时，传入的时间即是格式化好的时间
        if($r_datemark=='DetailView') {
            $sendlog_date = $r_createtime;
        }else{
            if (empty($r_createtime))
                $createtime = time();
            else{
                $createtime = explode('~',$r_createtime)[0];
                $createtime = strtotime($createtime);
            }
            if ($r_type == 'ItemLogday' || $r_type == 1) {
                $sendlog_date = date('Y-m-d', $createtime);
                $r_type = 'day';
            } elseif ($r_type == 'ItemLogweek' || $r_type == 2) {
                if (empty($r_datemark)) $r_datemark = 'week';
                $r_type = 'week';
                $sendlog_date = implode(' ~ ', rangeTimeToDate($r_datemark, $createtime));
            } elseif ($r_type == 'ItemLogmonth' || $r_type == 3) {
                if (empty($r_datemark)) $r_datemark = 'month';
                $r_type = 'month';
                $sendlog_date = implode(' ~ ', rangeTimeToDate($r_datemark, $createtime));
            } else {
                return array();
            }
        }
        crm_load_class_file('WorkTemplateRule','modules/Settings');
        //XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华）wsh
        $workTemplateRuleobj = new WorkTemplateRule();
        $workTemplateRuleobj->setWorkReportType($r_type);
        $applicable_ruleinfo = $workTemplateRuleobj->getApplicableRuleByUserid($current_user->id);

        $orign_list = $this->getSendLog_SalesKit($sendlog_date,$r_userid);
        $final_output = array();
        $final_output['title'] = getFixedLabel('Jobbriefing');
        $final_output['date'] = $sendlog_date;
        $final_output['auto_generate_brief'] = $applicable_ruleinfo['auto_generate_brief'];
        $final_output['list'] = $orign_list['list'];
        return $final_output;
    }
    //editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/28 17:02
    public function getDetailView(){

	    $list = parent::getDetailView();
	    if(isset($list['report'][0])){
	        $workreporttype = $list['report'][0]['workreporttype'];
	        $userid = $list['report'][0]['userid'];
	        $sendlog_workdate = $list['report'][0]['sendlog_workdate'];
	        $entitytype = $list['report'][0]['entitytype'];
            if ($entitytype == 'workreport'){
                $result =$this->getSendLog_SalesKit_Detail($workreporttype, $sendlog_workdate,$userid,'DetailView');
                $list['sales_kit'] = $result;
            }
            // diony 2023-09-21 水印
            crm_load_class_file('MenuUtils','modules/Users');
            $MenuUtilsObj = new MenuUtils();
            $watermark_txt = $MenuUtilsObj->getwatermark_setting();
            $list['watermark_txt'] =$watermark_txt;
        }
        //客户001判断
        if(isKehu001ServerPc() == 'yes'){
            // require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
            $wx_authinfo=doCorpInfo("get_auth_info",array());
            $wx_agentid="";
            $wx_corpid="";
            if($wx_authinfo!=''){
                $wx_auth_arr=  json_decode($wx_authinfo,true);
                $wx_agentid=$wx_auth_arr['crm']['auth_info']['agent'][0]['agentid'];
                $wx_corpid=$wx_auth_arr['crm']['auth_corp_info']['corpid'];
            }
            $list['app']["agentid"]=$wx_agentid;
            $list['app']['iskehu001']=isKehu001ServerPc();
        }
        return $list;
    }
    //editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 10:42

    //editor:gyq_159 reason:系统设置增加移动端报表菜单定制   2019/11/13 16:27 ID1000638
    public function getReportSettingData(){
        global $adb,$current_user;
        require_once globalStatic::$root_directory.'appCommon/modules/Home/cls_Home_SpecialMC.php';
        $orignList = cls_Home_SpecialMC::getWXReportList();
        $setData = array();
        $sql = 'select id,userid,tabid,tab_tablename from ld_mobile_report_user_set where userid=?';
        $result = $adb->pquery($sql,array($current_user->id));
        $num = $adb->num_rows($result);
        for($i=0;$i<$num;$i++){
           $tabid = $adb->query_result($result,$i,'tabid');
           $tab_tablename = $adb->query_result($result,$i,'tab_tablename');
            $setData[$tabid.'_'.$tab_tablename] = $adb->query_result($result,$i,'id');
        }
        $finalList = array();
        foreach ($orignList as $keyOne=>$valueOne){
            $finalList[$keyOne]['blockname'] = $current_user->user_type=='prm'?'':$valueOne['blockname'];
            $finalList[$keyOne]['menudescription'] = $valueOne['menudescription'];
            foreach ($valueOne['list'] as $keyTwo=>$valueTwo){
                if(isset($setData[$valueTwo['tabid'].'_'.$valueTwo['tab_tablename']]))
                    $display = 0;
                else
                    $display = 1;
                $finalList[$keyOne]['list'][$keyTwo]['display'] = $display;
                $finalList[$keyOne]['list'][$keyTwo]['hidden_value'] = $valueTwo['tabid'].','.$valueTwo['tab_tablename'];
                $finalList[$keyOne]['list'][$keyTwo]['module'] = $valueTwo['orign_name'];
                $finalList[$keyOne]['list'][$keyTwo]['tab_tablename'] = $valueTwo['tab_tablename'];
                $finalList[$keyOne]['list'][$keyTwo]['title'] = $valueTwo['title'];
                $finalList[$keyOne]['list'][$keyTwo]['image'] = $valueTwo['image'];
            }
        }
        return $finalList;
    }
    //变更报表显示状态
    public function changePersonalReportSet($rValue){
        global $adb,$current_user;
        $userid=$current_user->id;
        //editor:gyq_157 reason:企业微信模块显示设置增加自定义表单\链接模块\报表  2019/11/5 17:27
        //不兼容APP
        $hiddenValueArr = explode(',',$rValue);
        $sql = 'select 1 from ld_mobile_report_user_set where userid=? and tabid=? and tab_tablename=? ';
        $result=$adb->pquery($sql,array($userid,$hiddenValueArr[0],$hiddenValueArr[1]));
        if($adb->num_rows($result)>0)
        {
            $sql_del='delete from ld_mobile_report_user_set where userid=? and tabid=? and tab_tablename=? ';
            $adb->pquery($sql_del,array($userid,$hiddenValueArr[0],$hiddenValueArr[1]));
        }
        else
        {
            $sql_insert='insert into ld_mobile_report_user_set(userid,tabid,tab_tablename) values(?,?,?)';
            $adb->pquery($sql_insert,array($userid,$hiddenValueArr[0],$hiddenValueArr[1]));
        }
    }
    //获取个人的报表列表
    public function getPersonalReportList(){
        global $adb,$current_user;
        global $PlatformMC;
        crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
        $orignList = cls_Home_SpecialMC::getWXReportList();
        $setData = array();
        $sql = 'select id,userid,tabid,tab_tablename from ld_mobile_report_user_set where userid=?';
        $result = $adb->pquery($sql,array($current_user->id));
        $num = $adb->num_rows($result);
        for($i=0;$i<$num;$i++){
            $tabid = $adb->query_result($result,$i,'tabid');
            $tab_tablename = $adb->query_result($result,$i,'tab_tablename');
            $setData[$tabid.'_'.$tab_tablename] = $adb->query_result($result,$i,'id');
        }

        //非crm报表url增加传输参数
        $db = PearDatabase::getInstance();
        $scopeobj = new ScopOfAuthority($db,$_REQUEST['module']);
        if($scopeobj->modulescolist[$_REQUEST['module']]['scopeauthority']=='1'){
            $uuid_range = 'all';
        }
        else{
            $uuid_range = $scopeobj->getCurUserScopeId();
        }
       
        $cur_range = $uuid_range;
         global $PlatformMC;
          if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
            {
                $encryptobj=new cls_MyCRMcrypt();
                $crmreporturl = 'crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period=thismonth';
                
                
                $crmreporturl .= '&userid='.$encryptobj->encode($_REQUEST['userid']);
                $crmreporturl .="&appusertoken=".$_REQUEST['appusertoken'];
                
            }
            else
                $crmreporturl = 'crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period=thismonth';
        
        
        $finalList = array();
        //editor:gyq_20191121 reason:在已有一级键$keyOne的情况下，$j应该放在foreach里面
        //0038623: 移动端，报表模块列表返回值键不是自然数组
        crm_load_class_file("cls_LinkModuleCustom",'include/utils');

        foreach ($orignList as $keyOne=>$valueOne){
            $j = 0;
            foreach ($valueOne['list'] as $keyTwo=>$valueTwo){
                if(isset($setData[$valueTwo['tabid'].'_'.$valueTwo['tab_tablename']]))
                    continue;
                else{
                    
                    if($valueTwo['tab_tablename']=='ld_linkmodulecustom')
                    {
                        
                        $tmplinkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($valueTwo['tabid']);
                        $linkcvid = $tmplinkinfo['linkcvid'];
                        $valueTwo['linkcvid'] = $linkcvid;
                        //非crm的报表链接地址增加参数
                        $url = $valueTwo['module'];
                        if(strstr($url,'/CustomReport/JsReport/index.php?crm_report_key')== false&&$tmplinkinfo['entitytype']=='custom')
                        {
                            if(strstr($url,'?')!= false)
                            {
                                $valueTwo['module'] .='&'.$crmreporturl;
                            }
                            else
                            {
                                $valueTwo['module'] .='?'.$crmreporturl;
                            }
                            //zxm 20231114
                            $corpurl_all_customreort_arr = explode('WeiXinApp',getCorpUrl());
                            $valueTwo['module'] = $corpurl_all_customreort_arr[0].$valueTwo['module'];
                            $valueTwo['module'] = htmlspecialchars_decode($valueTwo['module']);
                        }
                        else if($tmplinkinfo['linkmodule']=='CustomTables'&&$tmplinkinfo['entitytype']=='category')
                        {
                                if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
                                {
                                    $url=str_replace('index.php?','indexnavtive.php',$url);
                                    
                                }
            
                        }
                    }
                    
                    $finalList[$keyOne]['list'][$j] = $valueTwo;
                    $j++;
                }
            }
            if(!empty($finalList[$keyOne]['list'])){
                $finalList[$keyOne]['blockname'] = $current_user->user_type=='prm'?'':$valueOne['blockname'];
                $finalList[$keyOne]['menudescription'] = $valueOne['menudescription'];
                $finalList[$keyOne]['display'] = 'yes';
            }
        }
        return $finalList;
    }

}

?>