<?php
class ReportAnalysisActions
{
    public $adb,$language;
    public $current_user;
    public $group;
    public $permit_info;
    public $listType='list';
    public function __construct()
    {
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->permit_info = $this->getPermitInfo();
        $this->getGroupInfo();

        if(isset($_REQUEST['listtype'])){
            $this->listType =$_REQUEST['listtype'];
        }else{
            //获取视图类型--列表视图list  分屏试图screen  ReportAnalysis_listtype
            crm_load_class_file("cls_SaveUserChoosen",'modules/lingdang');
            $getShowTypeObj = new cls_SaveUserChoosen('ReportAnalysis','ReportAnalysis_listtype');
            $getShowType = $getShowTypeObj -> getValueByType();
            $this->listType = ($getShowType == '') ? 'list' : $getShowType;//默认列表视图
        }
    }
    //部门名称信息
    public function getGroupInfo(){
        $tmp_sql = "select groupid, groupname from ld_groups";
        $tmp_res = $this->adb->query($tmp_sql);
        $tmp_nums = $this->adb->num_rows($tmp_res);
        for ($k = 0; $k < $tmp_nums; $k++) {
            $this->group[$this->adb->query_result($tmp_res, $k, 'groupid')] = $this->adb->query_result($tmp_res, $k, 'groupname');
        }
    }
    public function getPermitInfo(){
        $permit_arr = ['Create','EditView','Delete','Allocate','Print','Export'];
        $permit_info = [];
        foreach($permit_arr as $value){
            $permit_info['permit_'.$value] = isPermitted('ReportAnalysis',$value);
        }
        return $permit_info;
    }
    public function getBtnArr($linedata){
        $btnArr = [];
        $permit_info = $this->permit_info;
        //编辑按钮--有编辑权限 且不是综合报表不是常用报表
        if($linedata['modulename'] !='OftenUseReport'&&$linedata['modulename'] !='Comprehensivereport'&&$permit_info['permit_EditView']=='yes'){
            $btnArr[] = 'edit';
        }
        if($linedata['modulename'] !='OftenUseReport'&&$linedata['modulename'] !='Comprehensivereport'&&$permit_info['permit_Create']=='yes'){
            //$btnArr[] = 'copy';//复制报表//SQL统计图统计表 自定义统计图统计表都有
        }
        //分配按钮--有分配权限的
        if($permit_info['permit_Allocate']=='yes'){
            $btnArr[] = 'allocate';
        }
        //创建按钮 文件夹才有 有创建权限的
        if($linedata['modulename'] =='ReportAnalysis'&&$permit_info['permit_Create']=='yes'){
            $btnArr[] = 'create';
        }
        //sort排序按钮 文件夹才有
        if($linedata['modulename'] =='ReportAnalysis'&&$linedata['isfolder']=='yes'){
            $btnArr[] = 'sort';
        }
        //delete 删除按钮--有删除权限的
        if($permit_info['permit_Delete']=='yes' && $linedata['modulename']!='OftenUseReport'&& $linedata['modulename']!='Comprehensivereport'){
            //--最近浏览只有取消显示/编辑/分配
            //if($linedata['recentview']!='yes')$btnArr[] = 'delete';
            $btnArr[] = 'delete';
        }

        //move 移动文件夹
        if($permit_info['permit_EditView']=='yes'&&$linedata['modulename'] !='ReportaAnalysis'){
            //--最近浏览只有取消显示/编辑/分配
            if($linedata['recentview']!='yes')$btnArr[] = 'move';
        }
        //print 打印--只有自定义统计表和SQL统计表有--分屏视图显示
        if($permit_info['permit_Print']=='yes'&&in_array($linedata['modulename'],['CustomTables'])&&$this->listType=='screen'){
            $btnArr[] = 'print';
        }
        //export 导出excel --只有自定义统计表和SQL统计表有--分屏视图显示
        if($permit_info['permit_Export']=='yes'&&in_array($linedata['modulename'],['CustomTables'])&&$this->listType=='screen'){
            $btnArr[] = 'export';
        }
        //cancel 取消显示--只有最近浏览文件夹有
        if($linedata['recentview']=='yes'){
            $btnArr[] = 'cancel';
        }
        if($this->listType=='list'){
            //列表模式 返回数组形式
            $btnLength = sizeof($btnArr);
            if($btnLength>4){
                $btnArr_ret['list'] = array_slice($btnArr,0,3);//如果按钮大于4个 超出的按钮放到more中
                $btnArr_ret['list'][] = 'more';
                $btnArr_ret['more'] = array_slice($btnArr,3);//如果按钮大于4个 超出的按钮放到more中
                return $btnArr_ret;
            }
            $btnArr_ret['list'] = $btnArr;
            return $btnArr_ret;
        }
        $btnArr_ret = implode(',',$btnArr);//分屏视图 按钮返回字符串 逗号分隔
        return $btnArr_ret;
    }
    /**
     * @param $parent_id
     * @return array
     * @throws Exception
     * 根据父级id获取统计图列表
     * type参数  init表示新进入页面  else区间表示页面搜索框输入关键词搜索
     * $type=='folder' 仅查询文件夹且parent_id合法的 report 仅查询报表且parent_id合法的  all所有且parent_id合法的
     */
    public function getReportListByParentId($parent_id,$type)
    {
        $language = $this->language;
        $tradeinfo = getVersionTradeInfo();
        $version = $tradeinfo['account'];//客户
        $trade = $tradeinfo['trade'];//行业
        //分配条件
        //$whereallocateids = $this->getAllocateIds();
        $keyWords = $_REQUEST['keyWords'];
        $keyWordsWhereSql = "";
        $folderWhereSql = " and 1=1 ";
        $reportWhereSql = "analysisfolder_id>=0 ";
        if(!empty($keyWords)){
            $keyWordsWhereSql = " where (a.modulename='OftenUseReport' or a.modulename='Comprehensivereport' or a.report_name like '%$keyWords%') ";
        }else if(is_array($parent_id)){
            //parent_id是个数组
            $parent_ids_str = implode(',',$parent_id);
            $folderWhereSql = " and 1=2 ";
            $reportWhereSql = "analysisfolder_id in ($parent_ids_str) ";
        }else if($parent_id!=-1&&$parent_id!=''){
            $folderWhereSql = " and ld_report_analysis_folder.parent_id=$parent_id";
            $reportWhereSql = "analysisfolder_id=$parent_id ";
        }else{
            $type='RecentView';
        }
        //edit: xll 2024/03/06 BUG20240209-01 报表分析--模板报表--使用模板参数配置不生效
        //常用报表 父节点条件
        $usereportparentwhere = $this->getFolderVersionWhere($trade);
        //报表分析 ld_report_analysis_folder
        $analysis_sql = "
            select ld_report_analysis_folder.`sequence`,
            ld_report_analysis_folder.folderlabel_".$language." as report_name,
            ld_report_analysis_folder.description,
            '' as report_template,
            ld_report_analysis_folder.createdtime,ld_report_analysis_folder.approveallocatetype,
            'yes' as isfolder,
            ld_report_analysis_folder.analysisfolder_id as report_id,
            ld_report_analysis_folder.parent_id,
            '' as databaselinktype,
            ld_report_analysis_folder.depth as `level`,
            'ReportAnalysis' as `modulename`,
            '文件夹' as `type`,
            (case when ifnull(child.childnum,0)>0 then 'yes' else 'no' end )as ishavefolder,
            ld_users.last_name as last_name,ld_users.real_name,ld_users.wx_userid 
            from ld_report_analysis_folder  left join ld_users on ld_report_analysis_folder.smcreatorid=ld_users.id 
            left join(
                select count(1)as childnum,ld_report_analysis_folder.parent_id
                from ld_report_analysis_folder 
                where ld_report_analysis_folder.deleted=0 
                and ld_report_analysis_folder.visible='yes' 
                and (ld_report_analysis_folder.version='$version' or ifnull(ld_report_analysis_folder.version,'')='')
                $usereportparentwhere
                group by ld_report_analysis_folder.parent_id
            )child on child.parent_id=ld_report_analysis_folder.analysisfolder_id
        where ld_report_analysis_folder.deleted=0 
        and ld_report_analysis_folder.visible='yes' 
        $folderWhereSql
        and (ld_report_analysis_folder.version='$version' or ifnull(ld_report_analysis_folder.version,'')='')
        $usereportparentwhere
        order by ld_report_analysis_folder.`sequence` asc,ld_report_analysis_folder.createdtime desc";
        //常用报表
        //子节点条件
        $usereportwhere = $this->getReportListWhere($trade);
        $usereport_sql = $this->getOftenUseReportSql($reportWhereSql.' '.$usereportwhere,$usereportparentwhere,$version);
        //报表库  Customreport
        $customreport_sql = $this->getCustomreportSql($reportWhereSql);
        //综合报表 Comprehensivereport
        //判断version
        $comprehensivereport_sql = $this->getComprehensivereportSql($reportWhereSql);
        //自定义统计图 CustomEcharts
        $customcharts_sql = $this->getCustomEchartsSql($reportWhereSql);
        //自定义统计表 CustomTables
        $customtables_sql = $this->getCustomTablesSql($reportWhereSql);

        if(($parent_id==0 && empty($keyWords)) || $type=='folder'){
            $sql = "select a.*,b.userid as allocateids from ($analysis_sql)a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename
                order by b.sequence asc,a.createdtime desc ";
        }else if(!empty($keyWords)||$type=='report'){
            $sql = " select a.*,b.userid as allocateids from (select * from ($usereport_sql)a
            union all ($customreport_sql) 
            union all ($comprehensivereport_sql)
            union all ($customcharts_sql)
            union all ($customtables_sql))a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename
            $keyWordsWhereSql order by `level` asc,b.sequence asc,a.createdtime desc
            ";
        }else{
            $sql = " select a.*,b.userid as allocateids from (select * from ($analysis_sql)a
            union all ($usereport_sql) 
            union all ($customreport_sql) 
            union all ($comprehensivereport_sql)
            union all ($customcharts_sql)
            union all ($customtables_sql))a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename
            $keyWordsWhereSql order by `level` asc,b.sequence asc,a.createdtime desc
            ";
        }

        //wyt 221129 XUQIU1000911 报表分析，增加“最近浏览”文件夹 ($parent_id==-1表示最近浏览文件)
        if($parent_id==-1){
            $userid=$this->current_user->id;
            $sql = " select a.*,b.userid as allocateids from (select * from ($analysis_sql)a
            union all ($usereport_sql) 
            union all ($customreport_sql) 
            union all ($comprehensivereport_sql)
            union all ($customcharts_sql)
            union all ($customtables_sql))a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename
            $keyWordsWhereSql 
            inner JOIN (SELECT * from ld_report_analysis_folder_log where visible='yes' and userid=$userid)reportlog on reportlog.reportid=a.report_id and reportlog.module=a.modulename
             order by reportlog.view_time desc  limit 10
            ";
        }

        $res = $this->adb->pquery($sql,array());
        $list = $this->getReportAnalysisInfo($res,$type,$keyWords);

        return $list;
    }
    public function getReportAnalysisInfo($res,$type,$keyWords){
        $nums = $this->adb->num_rows($res);
        $list = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++) {
                $approveallocatetype = $this->adb->query_result($res,$i,'approveallocatetype');
                $modulename = $this->adb->query_result($res,$i,'modulename');
                $allocateids = $this->adb->query_result($res,$i,'allocateids');
                $allocateids_array = [];
                if(!empty($allocateids)){
                    $allocateids_array = explode(',',$allocateids);
                }
                //分配权限  20220131 zxm 之前的那个方法判断不行了 因为按部门分配的时候 userid字段存的是部门id
                $allocates = "";

                if($approveallocatetype==1&&!empty($allocateids)&&!is_admin($this->current_user)&&$modulename!='ReportAnalysis'){
                    //按部门
                    $usergroupids_arr = explode(',',$this->current_user->groupid);
                    $usergroupids_arr_intersect = array_intersect($usergroupids_arr,$allocateids_array);
                    if(empty($usergroupids_arr_intersect)){
                        continue;
                    }
                }

                if($approveallocatetype==2&&!empty($allocateids)&&!is_admin($this->current_user)&&$modulename!='ReportAnalysis'){
                    //按成员
                    if(!in_array($this->current_user->id,$allocateids_array)){
                        continue;
                    }
                }
                if($approveallocatetype==0){
                    //全部
                    $allocates = getFixedLabel('ALLTHEUSERS');
                }else if ($approveallocatetype == 1) {
                    $group_name_arr = [];
                    $usergroupids_arr = explode(',',$allocateids);
                    foreach ($usergroupids_arr as $temp_groupid) {
                        $group_name_arr[] = $this->group[$temp_groupid];
                    }
                    $allocates = implode(',', $group_name_arr);
                }else if($approveallocatetype==2){
                    $user_name_arr = [];
                    foreach ($allocateids_array as $tmp_userid){
                        $user_name_arr[] = getUserFullName($tmp_userid);
                    }
                    $allocates = implode(',',$user_name_arr);
                }


                $report_name = html_entity_decode($this->adb->query_result($res,$i,'report_name'));
                $reportlabel = $report_name;
                $orgin_report_name = $report_name;
                if($modulename=='OftenUseReport'||$modulename=='Comprehensivereport'){
                    $report_name = getFixedLabel($report_name);//报表名称翻译 的 fieldlabel
                    //模糊搜索--常用报表和综合报表的报表名称是翻译来的
                    if(!empty($keyWords)&&strpos($report_name,$keyWords)===false){
                        continue;
                    }
                }
                //duan 20221130 火狐浏览器不显示签到轨迹表
                if($orgin_report_name=='Sign_in_track' && strpos($_SERVER['HTTP_USER_AGENT'],'Firefox') !== false){
                    continue;
                }
                $list[$i] = $this->adb->query_result_rowdata($res, $i);
                $list[$i]['modulelabel'] = getTranstab($list[$i]['modulename']);
                $list[$i]['report_name'] = $report_name;
                $list[$i]['reportlabel'] = $reportlabel;
                $list[$i]['allocates'] = $allocates;
                //排序字段
                if($list[$i]['sequence']<=0){
                    $list[$i]['sequence'] = $i+1;
                }
                $list[$i]['no'] = $i+1;
                if($modulename=='ReportAnalysis'){
                    //判断kehu001的创建人的显示
                    $last_name = $list[$i]['last_name'];
                    $smcreatorid = $list[$i]['smcreatorid'];
                    $wx_userid = $list[$i]['wx_userid'];
                    $userobj = new Users();
                    $userobj->wx_userid=$wx_userid;
                    $userobj->id=$smcreatorid;
                    $userobj->last_name=$last_name;
                    $list[$i]['last_name']= getUserlastName($userobj);
                }

                if($modulename=='CustomTables'){
                    $list[$i]['type_name'] = $list[$i]['type']=='sql'?'sql报表':'模块报表';
                }else if($modulename=='CustomEcharts'){
                    $list[$i]['type_name'] = $list[$i]['type']=='sqlchart'?'sql统计图':'模块统计图';
                }else if($modulename=='Customreport'){
                    $list[$i]['type_name'] = $list[$i]['type']=='url'?getFixedLabel('LINKADDRESS'):getFixedLabel('STIMULSORTREPORTSPHP');
                }else{
                    $list[$i]['type_name'] = $list[$i]['type'];
                }
                //查询范围
                $analysis2usersql = "select userid from ld_report_analysis2user where report_id=? and modulename=?";
                $analysis2userres = $this->adb->pquery($analysis2usersql,[$list[$i]['report_id'],$modulename]);
                $analysis2usernums = $this->adb->num_rows($analysis2userres);
                $allocatetypeids = [];
                for($j=0;$j<$analysis2usernums;$j++){
                    $allocatetypeids[$j] = $this->adb->query_result($analysis2userres, $j,'userid');
                }
                if($type=="RecentView"){
                    $list[$i]['level'] = 2;
                    $list[$i]['recentview'] = 'yes';
                }else{
                    $list[$i]['recentview'] = 'no';
                }
                $list[$i]['allocatetypeids'] = empty($allocatetypeids)?'-1':implode(',',array_unique($allocatetypeids));
                $list[$i]['btnarr'] = $this->getBtnArr($list[$i]);
                //搜索的时候 只搜索报表 前面不需要缩进
                if(!empty($keyWords))$list[$i]['level'] = 0;
            }
        }
        return $list;
    }
    public function getCustomTablesSql($reportWhereSql){
        return "select 
            ld_customtable.sequence,
            ld_customtable.report_name,
            ld_customtable.description,
            '' as report_template,
            ld_customtable.createdtime,ld_customtable.approveallocatetype,
            'no' as isfolder,
            ld_customtable.report_id,
            ld_customtable.analysisfolder_id as parent_id,
            '' as databaselinktype,
            (ld_report_analysis_folder.depth+1) as `level`,
            'CustomTables' as `modulename`,
            ld_customtable.report_type as `type`,'no' as ishavefolder,
            ld_users.last_name as last_name,ld_users.real_name,ld_users.wx_userid 
            from ld_customtable 
            left join ld_report_analysis_folder on ld_report_analysis_folder.analysisfolder_id=ld_customtable.analysisfolder_id
            left join ld_users on ld_customtable.smcreatorid=ld_users.id 
        where ld_customtable.$reportWhereSql  and ld_customtable.deleted=0 and ld_customtable.isfolder<>'yes'   order by ld_customtable.sequence asc
        ";
    }
    public function getCustomEchartsSql($reportWhereSql){
        return "select 
            ld_customreport.sequence,
            ld_customreport.report_name,
            ld_customreport.report_desc as description,
            '' as report_template,
            ld_customreport.createdtime,ld_customreport.approveallocatetype,
            'no' as isfolder,
            ld_customreport.report_id,
            ld_customreport.analysisfolder_id as parent_id,
            '' as databaselinktype,
            (ld_report_analysis_folder.depth+1) as `level`,
            'CustomEcharts' as `modulename`,
            ld_customreport.report_type as `type`,'no' as ishavefolder,
            ld_users.last_name as last_name,ld_users.real_name,ld_users.wx_userid 
            from ld_customreport 
            left join ld_report_analysis_folder on ld_report_analysis_folder.analysisfolder_id=ld_customreport.analysisfolder_id
            left join ld_users on ld_customreport.smcreatorid=ld_users.id 
        where ld_customreport.$reportWhereSql  and ld_customreport.deleted=0   order by ld_customreport.sequence asc
        ";
    }

    /**
     * @param $reportWhereSql
     * @param $usereportparentwhere//报表文件夹条件   之前有常用报表的特殊开发,放在指定文件夹,需要限制不是该客户搜索的时候不要显示出来
     * @param $version//版本
     * @return string
     */
    public function getOftenUseReportSql($reportWhereSql,$usereportparentwhere='',$version=''){
        if(!empty($usereportparentwhere)) {
            $analysis_where = "inner join (select 
            ld_report_analysis_folder.analysisfolder_id as report_id
            from ld_report_analysis_folder  
            left join ld_users on ld_report_analysis_folder.smcreatorid=ld_users.id 
            where ld_report_analysis_folder.deleted=0 
            and ld_report_analysis_folder.visible='yes' 
            and (ld_report_analysis_folder.version='$version' or ifnull(ld_report_analysis_folder.version,'')='')
        $usereportparentwhere)analysis_where on analysis_where.report_id=ld_usereport.analysisfolder_id ";
        }
        $usereport_sql = "
            select ld_usereport.`sequence`,
            ld_usereport.name as report_name,
            '' as description,
            '' as report_template,
            '系统预设' as createdtime,ld_usereport.approveallocatetype,
            'no' as isfolder,
            ld_usereport.usereportid as report_id,
            ld_usereport.analysisfolder_id as parent_id,
            '' as databaselinktype,
            (ld_report_analysis_folder.depth+1) as `level`,
            'OftenUseReport' as `modulename`,
            '' as `type`,'no' as ishavefolder,
            '系统预设' as last_name,'系统预设' as real_name,'' as wx_userid 
            from ld_usereport  left join ld_report_analysis_folder on ld_report_analysis_folder.analysisfolder_id=ld_usereport.analysisfolder_id 
            $analysis_where
        where ld_usereport.parent_id>0 and ld_usereport.deleted=0 
        and ld_usereport.$reportWhereSql    
        order by ld_usereport.`sequence` asc
        ";
        return $usereport_sql;
    }
    public function getCustomreportSql($reportWhereSql){
        return "select 
            ld_customreport_info.`sequence`,
            ld_customreport_info.report_name,
            ld_customreport_info.report_describe as description,
            (case when ld_customreport_info.report_type='url' then ld_customreport_info.report_url else ld_customreport_info.report_template end) as report_template,
            ifnull(ld_customreport_info.createdtime,'')as createdtime,ld_customreport_info.approveallocatetype,
            'no' as isfolder,
            ld_customreport_info.report_id,
            ld_customreport_info.analysisfolder_id as parent_id,
            ld_customreport_info.databaselinktype as databaselinktype,
            (ld_report_analysis_folder.depth+1) as `level`,
            'Customreport' as `modulename`,
            ld_customreport_info.report_type as `type`,'no' as ishavefolder,
            (case when ld_customreport_info.systemdefault=1 then '系统预设'  else  ld_users.last_name end ) as last_name,ld_users.real_name as real_name,ld_users.wx_userid as wx_userid 
            from ld_customreport_info left join ld_users on ld_customreport_info.smcreatorid=ld_users.id 
        left join ld_report_analysis_folder on ld_report_analysis_folder.analysisfolder_id=ld_customreport_info.analysisfolder_id
        where ld_customreport_info.$reportWhereSql   and ld_customreport_info.deleted=0 
        order by ld_customreport_info.`sequence` asc
        ";
    }
    public function getComprehensivereportSql($reportWhereSql){
        return "select 
            ld_comprehensivereport.id as sequence,
            ld_comprehensivereport.name as report_name,
            '' as description,
            '' as report_template,
            '系统预设' as createdtime,ld_comprehensivereport.approveallocatetype,
            'no' as isfolder,
            ld_comprehensivereport.id as report_id,
            ld_comprehensivereport.analysisfolder_id as parent_id,
            '' as databaselinktype,
            (ld_report_analysis_folder.depth+1) as `level`,
            'Comprehensivereport' as `modulename`,
            '' as `type`,'no' as ishavefolder,
            '系统预设' as last_name,'系统预设' as real_name,'' as wx_userid 
            from ld_comprehensivereport left join ld_report_analysis_folder on ld_report_analysis_folder.analysisfolder_id=ld_comprehensivereport.analysisfolder_id
        where ld_comprehensivereport.$reportWhereSql and ld_comprehensivereport.deleted=0 and ld_comprehensivereport.typename in('SALESLIST','GROSSMARGINSTATISTICS')
        order by ld_comprehensivereport.id asc
        ";
        //zxm 20240816 综合报表公共的除了'SALESLIST','GROSSMARGINSTATISTICS'其他的都是特殊开发  不应该显示
    }
    //常用报表的条件
    public function getReportListWhere ($trade){
        global $currentModule,$current_user;
        if($trade=='德卡'){
            $where = "";
        }else {
            $where = " and ld_usereport.name not in ('SalesOrderImplementation') ";
        }
        if(!vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
            $where .= " and ld_usereport.name not in ('SalesOrderTrack','Contractnumber','Contractamount') ";
        }
        if($trade!='lueyang'){
            $where .= " and ld_usereport.name not in ('Reportingpaymentschedulestatistics') ";
        }
        if($trade!='jierun'){
            $where .= " and ld_usereport.name not in ('Eachprojectcontractincomestatisticsreport') ";
        }
        if($trade!='futai'){
            $where .= " and ld_usereport.name not in ('hoursqueryreport')";
        }
        if($trade!='ruiai'){
            $where .= " and ld_usereport.name not in ('librarytrackreport')";
        }
        if($trade!='yuanzhou'){
            $where .= " and ld_usereport.name not in ('yuanzhoureport')";
        }
        if(!vtlib_isModuleActive('Potentials')){
            $where .= " and ld_usereport.name not in ('Salesforecastandanalysistable') ";
        }
        if(!vtlib_isModuleActive('CashBill')){
            $where .= " and ld_usereport.name not in ('THESINGNINGAMOUNTOFBILLBOARD','CashBillSum_Paymentplan','CashBillSum_SalesOrder','Performancestatisticscollection') ";
        }
        if(!vtlib_isModuleActive('PurchaseOrder')){
            $where .= " and ld_usereport.name not in ('PurchaseOrderTrack') ";
        }
        if(!vtlib_isModuleActive('Project')){
            $where .= " and ld_usereport.name not in ('Thestatisticalreportofprojectperformance') ";
        }
        if(!vtlib_isModuleActive('SendCashBill')){
            $where .= " and ld_usereport.name not in ('SendCashBillSum_PurchaseOrder','SendCashBillSum_SendPayment') ";
        }
        if(!vtlib_isModuleActive('OutboundOrder')){
            $where .= " and ld_usereport.name not in ('CashBillSum_Outboundorder') ";
        }
        //zxm 2020-1209 合同与服务合同模块未开则不显示收费奖金报表_按合同 提成报表_按合同
        if(!vtlib_isModuleActive('SalesOrder')&&!vtlib_isModuleActive('ServiceContracts')){
            $where .= " and ld_usereport.name not in ('SalesCommissionsByOrder','ServiceChargeBonusByOrder') ";
        }
        //zxm 2020-1209 合同与服务合同模块未开则不显示收费奖金报表_按收款 提成报表_按收款
        if(!vtlib_isModuleActive('CashBill')){
            $where .= " and ld_usereport.name not in ('ServiceChargeBonusByCash','SalesCommissionsByCash') ";
        }
        //条件 --
        /**
         * @reason 0012334 常用报表>>服务绩效统计表：希望【客户服务单】、【项目任务】模块都没有开启的情况下，该报表不显示
         * @author Tujt 2014-11-10
         */
        if(1 != vtlib_isModuleActive('HelpDesk') && 1 != vtlib_isModuleActive('ProjectTask')){
            $where .= " and ld_usereport.name not in ('Serviceperformanceappraisal') ";//服务绩效统计表
        }

        if(1 != vtlib_isModuleActive('CashBill')){
            $where .= " and ld_usereport.name not in ('The billboard of Receivables') ";//回款金额龙虎榜
        }
        if(1 != vtlib_isModuleActive('TimeSheet') ){
            $where .= " and ld_usereport.name not in ('TimeSheet personal monthly summary') ";//判断工时模块是否开启
        }
        if(1 != vtlib_isModuleActive('PaymentPlan') ){
            $where .= " and ld_usereport.name not in ('CashBillSum_Paymentplan') ";
        }
        if(1 != vtlib_isModuleActive('SendPayment') ){
            $where .= " and ld_usereport.name not in ('SendCashBillSum_SendPayment') ";
        }
        //editor:20181229 0035903: 库存报表，当库存模块一个都不启用时，报表应该不显示
        //出库单、入库单、盘点单、库间调拨、销售退货单、采购退货单、库存初始化
        if(1 != vtlib_isModuleActive('OutboundOrder')||
            1 != vtlib_isModuleActive('Stock')||
            1 != vtlib_isModuleActive('WareHouseTransfer')||
            1 != vtlib_isModuleActive('Checks')||
            1 != vtlib_isModuleActive('Prdtnums')||
            1 != vtlib_isModuleActive('SalesBack')||
            1 != vtlib_isModuleActive('PurchaseBack')){
            $where .= " and ld_usereport.name not in ('InventoryReport') ";
        }
        //chj:应收账款汇总表：如果数据接口没有连接金蝶旗舰版则不显示当前报表  AccountsReceivableSummary
        if(getDatainterface('soft_version') != 5){
            $where .= " and ld_usereport.name not in ('AccountsReceivableSummary') ";
        }

        $where .= " and ld_usereport.name not in ('AccountsReceivableSummary') "; //应收款汇总表
        /*if(!is_admin($current_user))  ---不要
        {
            //角色权限增加常用报表权限
            $SQL='select * from ld_profile2standardpermissions where profileid=? and tabid=?  ';
            $profile_result=$this->adb->pquery($SQL,array($current_user->profileid,getTabid($currentModule)));
            $relatednames=$this->adb->query_result($profile_result,0,'relatednames');
            $relatednames = explode(',',$relatednames);
            $relatednames = implode("','",$relatednames);
            $where .= " and ld_usereport.name in ('$relatednames') ";
        }*/
        return $where;
    }
    public function getFolderVersionWhere($trade){
        //常用报表 父节点条件
        if($trade=='training'){
            $usereportparentwhere = "";
        }else {
            $usereportparentwhere = " and ld_report_analysis_folder.name not in ('CourseEnquiryReport')";
        }

        if($trade!='jierun'){
            $usereportparentwhere .= " and ld_report_analysis_folder.name not in ('JIERUNREPORTS') ";
        }
        if($trade!='xycp'){
            $usereportparentwhere .= " and ld_report_analysis_folder.name not in ('XuanYuanLawn')";
        }
        if($trade!='zhongyuan'){
            $usereportparentwhere .= " and ld_report_analysis_folder.name not in ('ZHONGYUANREPORTS')";
        }
        return $usereportparentwhere;
    }
    //报表的分配条件
    public function getAllocateIds(){
        //OftenUseReport Customreport Comprehensivereport CustomEcharts CustomTables
        $report_ids = [
            'OftenUseReport'=>[],
            'Customreport'=>[],
            'Comprehensivereport'=>[],
            'CustomEcharts'=>[],
            'CustomTables'=>[],
        ];
        //非ADMIN用户需要看分配
        if(!is_admin($this->current_user)){
            //20220131 userid的值有可能是部门id  通过这个方法不可取了
            $range_sql = "select report_id,modulename from ld_report_analysis2user where ifnull(report_id,'')<>'' and (find_in_set(".$this->current_user->id.",userid) or userid=-1)";
            $range_res = $this->adb->pquery($range_sql);
            $range_nums = $this->adb->num_rows($range_res);
            if($range_nums>0){
                for($k=0;$k<$range_nums;$k++){
                    $tmpmodulename = $this->adb->query_result($range_res,$k,'modulename');
                    $report_ids[$tmpmodulename][$k] = $this->adb->query_result($range_res,$k,'report_id');
                }
            }
        }
        //分配的条件
        $where['OftenUseReport'] = ' and 1=1 ';
        $where['Customreport'] = ' and 1=1 ';
        $where['Comprehensivereport'] = ' and 1=1 ';
        $where['CustomEcharts'] = ' and 1=1 ';
        $where['CustomTables'] = ' and 1=1 ';
        if(!is_admin($this->current_user)){
            $where['OftenUseReport'] = ' and ld_usereport.approveallocatetype=0 ';
            $where['Customreport'] = ' and ld_customreport_info.approveallocatetype=0  ';
            $where['Comprehensivereport'] = ' and ld_comprehensivereport.approveallocatetype=0 ';
            $where['CustomEcharts'] = ' and ld_customreport.approveallocatetype=0 ';
            $where['CustomTables'] = ' and ld_customtable.approveallocatetype=0 ';
        }

        if(!empty($report_ids)){
            //1.常用报表
            $report_ids_OftenUseReport = $report_ids['OftenUseReport'];
            if(!empty($report_ids_OftenUseReport)){
                $report_ids_OftenUseReport = implode(',',$report_ids_OftenUseReport);
                $where['OftenUseReport'] = " and (ld_usereport.usereportid in ($report_ids_OftenUseReport) or ld_usereport.approveallocatetype=0)";
            }
            //2.报表库
            $report_ids_Customreport = $report_ids['Customreport'];
            if(!empty($report_ids_Customreport)){
                $report_ids_Customreport = implode(',',$report_ids_Customreport);
                $where['Customreport'] = " and (ld_customreport_info.report_id in ($report_ids_Customreport) or ld_customreport_info.approveallocatetype=0)";
            }
            //3.综合报表
            $report_ids_Comprehensivereport = $report_ids['Comprehensivereport'];
            if(!empty($report_ids_Comprehensivereport)){
                $report_ids_Comprehensivereport = implode(',',$report_ids_Comprehensivereport);
                $where['Comprehensivereport'] = " and (ld_comprehensivereport.id in ($report_ids_Comprehensivereport) or ld_comprehensivereport.approveallocatetype=0)";
            }
            //4.统计图
            $report_ids_CustomEcharts = $report_ids['CustomEcharts'];
            if(!empty($report_ids_CustomEcharts)){
                $report_ids_CustomEcharts = implode(',',$report_ids_CustomEcharts);
                $where['CustomEcharts'] = " and (ld_customreport.report_id in ($report_ids_CustomEcharts) or ld_customreport.approveallocatetype=0)";
            }
            //5.统计表
            $report_ids_CustomTables = $report_ids['CustomTables'];
            if(!empty($report_ids_CustomTables)){
                $report_ids_CustomTables = implode(',',$report_ids_CustomTables);
                $where['CustomTables'] = " and (ld_customtable.report_id in ($report_ids_CustomTables) or ld_customtable.approveallocatetype=0)";
            }
        }
        return $where;
    }
    //获取单个报表的信息
    public function getReportInfo($modulename,$report_id){
        $fun_name = 'get'.$modulename.'Sql';
        // 返回文件夹
        if(!method_exists($this,$fun_name)) {
            return $this->getFolderInfo($report_id,'all');
        }
        $sql = $this->$fun_name('analysisfolder_id>0');
        $sql = "select a.*,b.userid as allocateids from($sql)a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename where a.report_id=?";

        $res = $this->adb->pquery($sql,array($report_id));
        $nums = $this->adb->num_rows($res);
        $list = array();
        if($nums>0){
            $list = $this->getReportAnalysisInfo($res,'report','');
        }
        return $list;
    }
    //获取文件夹信息 编辑完文件夹之后返回文件夹
    public function getFolderInfo($analysisfolder_id,$type){
        $language = $this->language;
        //报表分析 ld_report_analysis_folder
        $analysis_sql = "
            select ld_report_analysis_folder.`sequence`,
            ld_report_analysis_folder.folderlabel_".$language." as report_name,
            ld_report_analysis_folder.description,
            '' as report_template,
            ld_report_analysis_folder.createdtime,ld_report_analysis_folder.approveallocatetype,
            'yes' as isfolder,
            ld_report_analysis_folder.analysisfolder_id as report_id,
            ld_report_analysis_folder.parent_id,
            '' as databaselinktype,
            ld_report_analysis_folder.depth as `level`,
            'ReportAnalysis' as `modulename`,
            '文件夹' as `type`,
            (case when ifnull(child.childnum,0)>0 then 'yes' else 'no' end )as ishavefolder,
            ld_users.last_name as last_name,ld_users.real_name,ld_users.wx_userid 
            from ld_report_analysis_folder  left join ld_users on ld_report_analysis_folder.smcreatorid=ld_users.id 
            left join(
                select count(1)as childnum,ld_report_analysis_folder.parent_id
                from ld_report_analysis_folder 
                where ld_report_analysis_folder.deleted=0 
                and ld_report_analysis_folder.visible='yes' 
                group by ld_report_analysis_folder.parent_id
            )child on child.parent_id=ld_report_analysis_folder.analysisfolder_id
        where ld_report_analysis_folder.deleted=0 
        and ld_report_analysis_folder.visible='yes' and ld_report_analysis_folder.analysisfolder_id=?";
        $sql = "select a.*,b.userid as allocateids from ($analysis_sql)a left join (select * from ld_report_analysis2user group by report_id,modulename)b on a.report_id=b.report_id and a.modulename=b.modulename order by b.sequence asc,a.createdtime desc ";
        $res = $this->adb->pquery($sql,array($analysisfolder_id));
        $list = $this->getReportAnalysisInfo($res,$type,'');
        return $list;
    }
    //获取所有文件夹的数据
    public function getAllFolder(){
        $language = $this->language;
        $tradeinfo = getVersionTradeInfo();
        $version = $tradeinfo['account'];//客户
        $trade = $tradeinfo['trade'];//行业
        //常用报表 父节点条件
        $usereportparentwhere = $this->getFolderVersionWhere($trade);
        //报表分析 ld_report_analysis_folder
        $analysis_sql = "select a.* from(
            select ld_report_analysis_folder.`sequence`,
            ld_report_analysis_folder.folderlabel_".$language." as report_name,
            ld_report_analysis_folder.analysisfolder_id as report_id,
            ld_report_analysis_folder.parent_id,
            ld_report_analysis_folder.createdtime,
            ld_report_analysis_folder.depth as `level`
            from ld_report_analysis_folder  left join ld_users on ld_report_analysis_folder.smcreatorid=ld_users.id 
        where ld_report_analysis_folder.deleted=0 
        and ld_report_analysis_folder.visible='yes' 
        and (ld_report_analysis_folder.version='$version' or ifnull(ld_report_analysis_folder.version,'')='')
        $usereportparentwhere
        )a left join (select * from ld_report_analysis2user where modulename='ReportAnalysis')b on a.report_id=b.report_id
        order by `level` asc,b.sequence asc,a.createdtime desc";
        $res = $this->adb->pquery($analysis_sql,array());
        $nums = $this->adb->num_rows($res);
        $list = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++) {
                $tmp_report_id = $this->adb->query_result($res,$i,'report_id');
                $list[$tmp_report_id]['report_name'] = $this->adb->query_result($res,$i,'report_name');
                $list[$tmp_report_id]['report_id'] = $tmp_report_id;
                $list[$tmp_report_id]['parent_id'] = $this->adb->query_result($res,$i,'parent_id');
                $list[$tmp_report_id]['level'] = $this->adb->query_result($res,$i,'level');
                $list[$tmp_report_id]['sequence'] = $this->adb->query_result($res,$i,'sequence');
            }
        }
        return $list;
    }
    //递归获取子文件夹
    public function getChildFolder($parent_id,&$list){
        $language = $this->language;
        $tradeinfo = getVersionTradeInfo();
        $version = $tradeinfo['account'];//客户
        $trade = $tradeinfo['trade'];//行业
        $usereportparentwhere = $this->getFolderVersionWhere($trade);
        //报表分析 ld_report_analysis_folder
        $analysis_sql = "
            select ld_report_analysis_folder.`sequence`,
            ld_report_analysis_folder.folderlabel_".$language." as report_name,
            ld_report_analysis_folder.analysisfolder_id as report_id,
            ld_report_analysis_folder.parent_id,
            ld_report_analysis_folder.depth as `level`
            from ld_report_analysis_folder  left join ld_users on ld_report_analysis_folder.smcreatorid=ld_users.id 
        where ld_report_analysis_folder.deleted=0 
        and ld_report_analysis_folder.visible='yes' 
        and ld_report_analysis_folder.parent_id=$parent_id 
        and (ld_report_analysis_folder.version='$version' or ifnull(ld_report_analysis_folder.version,'')='')
        $usereportparentwhere
        order by ld_report_analysis_folder.`sequence` asc,ld_report_analysis_folder.createdtime desc";
        $res = $this->adb->pquery($analysis_sql,array());
        $nums = $this->adb->num_rows($res);
        if($nums>0){
            for($i=0;$i<$nums;$i++) {
                $tmp_report_id = $this->adb->query_result($res,$i,'report_id');
                $list[$tmp_report_id]['report_name'] = $this->adb->query_result($res,$i,'report_name');
                $list[$tmp_report_id]['report_id'] = $tmp_report_id;
                $list[$tmp_report_id]['parent_id'] = $this->adb->query_result($res,$i,'parent_id');
                $list[$tmp_report_id]['level'] = $this->adb->query_result($res,$i,'level');
                $list[$tmp_report_id]['sequence'] = $this->adb->query_result($res,$i,'sequence');
                $this->getChildFolder($tmp_report_id,$list);
            }
        }
        return $list;
    }
    //文件夹数据下拉框options
    public function getOptionsTree($list,&$options,$analysisfolder_id){
        foreach($list as $lineoption){
            $depth = $lineoption['level'];
            $prevstr = '';
            if($depth>1){
                $prevstr = str_pad('',$depth*2,'-',STR_PAD_RIGHT);
            }
            $selected = '';
            if($lineoption['report_id']==$analysisfolder_id){
                $selected = 'selected';
            }
            $options .='<option '.$selected.' value="'.$lineoption['report_id'].'">'.$prevstr.$lineoption['report_name'].'</option>';
            if(isset($lineoption['son'])&&!empty($lineoption['son'])){
                $this->getOptionsTree($lineoption['son'],$options,$analysisfolder_id);
            }
        }
        return $options;
    }
    //文件夹树结构
    public function genDirTree($items) {
        foreach ($items as $item)
            $items[$item['parent_id']]['son'][$item['report_id']] = &$items[$item['report_id']];

        return isset($items[0]['son']) ? $items[0]['son'] : array();

    }
    public function getAllFolderOptions($analysisfolder_id){
        $list = $this->getAllFolder();
        $list = $this->genDirTree($list);
        $options = '';
        $this->getOptionsTree($list,$options,$analysisfolder_id);
        return $options;
    }
}