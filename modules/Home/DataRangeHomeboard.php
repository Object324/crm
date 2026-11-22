<?php
//zxm 20230615 处理首页默认组件的数据范围设置解析的类
class DataRangeHomeboard{
    private static $_instance;//单例返回类实例
    public $filterArr;//组件的数据范围设置  ld_homeboard_plate_filter的数据
    public $datarangesqlArr;//表连接SQL
    public $boardid;//看板id
    public $frommodule='Home';//来源模块默认首页  目前看板首页Home/可视化分析/freedom自由/都会调用这个类 要区分  FreedomRelated自由关联的情况下 每个模块的数据范围依赖模块取决于自己模块
    public $boardfilterArr;//按看板查询所有的条件
    public $boarddatarangmoduleArr;//所有默认组件的datarangmodul
    public $scopeModule;
    public $penetrateModule='';
    public $queryobj;
    public $selectcolumns;
    public $dataranginnerJoinTable_arr;
    public $DefaultdatarangmoduleArr;
    public $queryObjArr = [];
    public $chuantouSearchArr = [];
    public $CustomEchartSearchArr = [];
    private $PenetrateModuleListobj;

    public function __construct($boardid,$frommodule=''){
        $this->boardid = $boardid;
        $this->getBoardfilterArr();//根据boardid获取所有的条件设置信息 数组索引值为boardstuffid
        $this->getBoarddatarangmoduleArr();//获取所有默认组件的datarangmodule 数组索引值为boardstuffid
        $this->getDefaultdatarangmoduleArr();//获取所有默认组件的datarangmodule 数组索引值为$type_$stuffid

        if(!empty($frommodule)){
            $this->frommodule = $frommodule;
        }
        $this->dataranginnerJoinTable_arr=[];
    }
    public function setPenetrateModuleListobj($PenetrateModuleListobj){
            $this->PenetrateModuleListobj=$PenetrateModuleListobj;
    }
    public function setScopeModule($scopeModule)
    {
        $this->scopeModule=$scopeModule;
    }
    public function getTotalGroupBy()
    {


         if( $this->PenetrateModuleListobj)
         {

             return $this->PenetrateModuleListobj->getTotalGroupBy();
         }
         else {

             return  $this->queryobj->moduleobj->table_name.'.'.$this->queryobj->moduleobj->table_index;
         }

    }
    //穿透的时候使用  穿透模块 穿透的时候不要将多个模块的page_list_query返回  而应该穿透哪个模块返回哪个模块的
    public function setPenetrateModule($penetrateModule)
    {
        $this->penetrateModule=$penetrateModule;
    }
    static function getInstance($boardid){
        if(empty(self::$_instance)){//是否为当前类的实例
            self::$_instance = new DataRangeHomeboard($boardid);
        }
        return self::$_instance;
    }
    /**
     * @return void
     * @throws Exception
     * 根据boardid获取所有的条件设置信息  数组索引值为boardstuffid
     */
    public function getBoardfilterArr(){
        global $adb;
        $filterArr = [];
        if($this->boardid<=0){
            return;
        }
        //获取设置好的条件
        $filtersql = "select a.* from ld_homeboard_plate_filter a left join ld_homeboard_plate_stuff b on a.boardstuffid=b.boardstuffid where b.boardid=?";
        $filterres = $adb->pquery($filtersql, array($this->boardid));
        $filternums = $adb->num_rows($filterres);


        if ($filternums > 0){
            for ($i = 0; $i < $filternums; $i++) {
                $boardstuffid = $adb->query_result($filterres, $i, 'boardstuffid');
                $conditionkey = $adb->query_result($filterres, $i, 'conditionkey');
                $stuffmodule = $adb->query_result($filterres, $i, 'stuffmodule');
                $advance_demand = $adb->query_result($filterres, $i, 'advance_demand');
                $advance_demand_groups = $adb->query_result($filterres, $i, 'advance_demand_groups');
                if(isset($advance_demand_groups))
                     $advance_demand_groups = html_entity_decode($advance_demand_groups);
                //将中文字段名 转换成fieldlabel
                if(!empty($advance_demand)) {
                    $advance_demand_arr = Zend_Json::decode($advance_demand, true);
                    foreach ($advance_demand_arr as $k=>&$tmp_advance_demand_line) {
                        if (!empty($tmp_advance_demand_line)) {
                            $tmpcolumnname = $tmp_advance_demand_line['columnname'];
                            $tmpcolumnname_arr = explode(':', $tmpcolumnname);
                            $tmpmodulefieldlabel = $tmpcolumnname_arr[3];
                            $tmpmodulefieldlabel_arr = explode('_',$tmpmodulefieldlabel);
                            $tmpmodulefieldlabel_arr[1] = 'fieldlabel';
                            $tmpcolumnname_arr[3] = implode('_',$tmpmodulefieldlabel_arr);
                            $tmp_advance_demand_line['columnname'] = implode(':', $tmpcolumnname_arr);
                        }
                    }
                    $advance_demand = html_entity_decode(Zend_Json::encode($advance_demand_arr));
                }

                $stuffmodule = empty($stuffmodule)?'':'_'.$stuffmodule;
                if(!isset($filterArr[$boardstuffid])){
                    $filterArr[$boardstuffid] = [];
                }
                $filterArr[$boardstuffid][$conditionkey.$stuffmodule] = $adb->query_result_rowdata($filterres,$i);
                $filterArr[$boardstuffid][$conditionkey.$stuffmodule]['advance_demand'] = $advance_demand;
                $filterArr[$boardstuffid][$conditionkey.$stuffmodule]['advance_demand_groups'] = $advance_demand_groups;

            }
        }

        $this->boardfilterArr = $filterArr;
    }
    /**
     * @return void
     * @throws Exception
     * 获取所有默认组件的datarangmodule 数组索引值为boardstuffid
     */
    public function getBoarddatarangmoduleArr(){
        global $adb;
        //获取关联模块
        $stuffsql = "select a.boardstuffid,b.stuffid,b.stufftitle,b.datarangmodule 
        from ld_homeboard_plate_stuff a left join ld_stuff b on a.stuffid=b.stuffid  where a.stufftype='defaultstuff'
        union all 
        select a.boardstuffid,b.report_id as stuffid ,b.report_name as stufftitle,b.mainmodule as datarangmodule 
        from ld_homeboard_plate_stuff a left join ld_customreport b on a.stuffid=b.report_id where a.stufftype='customreport' ";
        $stuffresult = $adb->pquery($stuffsql,array());
        $datarangmodule = [];
        $stuffnums = $adb->num_rows($stuffresult);
        if($stuffnums>0){
            for ($i = 0; $i < $stuffnums; $i++) {
                $boardstuffid = $adb->query_result($stuffresult, $i, 'boardstuffid');
                $tmpstrmodule=$adb->query_result($stuffresult,$i, 'datarangmodule');
                $tmparr=[];
                if(!empty($tmpstrmodule))
                    $tmparr=explode(",",$tmpstrmodule);
                $str_arr=[];
                foreach($tmparr as $tmpmodule){

                    if(vtlib_isModuleActive($tmpmodule))
                    {
                        $str_arr[]=$tmpmodule;
                    }
                }
                $datarangmodule[$boardstuffid] =implode(",",$str_arr);
            }
        }

        $this->boarddatarangmoduleArr = $datarangmodule;
    }
    //没有看板boardid的时候  获取组件穿透模块
    public function getDefaultdatarangmoduleArr(){
        global $adb;
        //获取关联模块
        $stuffsql = "select stuffid,stufftitle,datarangmodule,'defaultstuff' as type
        from ld_stuff
        union all 
        select report_id as stuffid ,report_name as stufftitle,mainmodule as datarangmodule,'customreport' as type
        from ld_customreport where show_athome='yes' and report_type='chart' ";
        $stuffresult = $adb->pquery($stuffsql,array());
        $datarangmodule = [];
        $stuffnums = $adb->num_rows($stuffresult);
        if($stuffnums>0){
            for ($i = 0; $i < $stuffnums; $i++) {
                $stuffid = $adb->query_result($stuffresult, $i, 'stuffid');
                $type = $adb->query_result($stuffresult, $i, 'type');
                $datarangmodule[$type.'_'.$stuffid] = $adb->query_result($stuffresult,$i, 'datarangmodule');
            }
        }
        $this->DefaultdatarangmoduleArr = $datarangmodule;
    }

    /**
     * @param $tmpmodulename
     * @param $scopemodule
     * @param $highsearchisrelated
     * @param $tmpadvance_demand
     * @param $tmpadvance_demand_groups
     * @param $date_adv //时间条件高级查找
     * @return string|void
     * 高级查找条件子sql--//20240515这个方法不返回pagelistquery了 只是为了获取querygenerator
     */
    public function getDataRangeSqlHigh($tmpmodulename,$scopemodule,$highsearchisrelated,$tmpadvance_demand,$tmpadvance_demand_groups,$date_adv=array()){

        $tmp_queryobj = $this->get_query_obj($tmpmodulename);

        $tmp_queryobj->setScopeModule($scopemodule);

        $tmp_queryobj->setSmOwnerSearchSql();
        if($highsearchisrelated=='yes'){
            if ($tmpadvance_demand && $tmpadvance_demand_groups != '[]') {
                $tmpinput['advft_criteria'] = $tmpadvance_demand;
                $tmpinput['advft_criteria_groups'] = $tmpadvance_demand_groups;
                $tmpinput['searchtype'] = 'advance';
                $tmp_queryobj->addUserSearchConditions($tmpinput);
            }
        }

        if(isset($this->chuantouSearchArr[$tmpmodulename])){
            $tmpChuantouSearchArr = $this->chuantouSearchArr[$tmpmodulename];
            if(isset($tmpChuantouSearchArr['searchtype'])&&$tmpChuantouSearchArr['searchtype']=='Basic'){
                //增加基本查找
                $tmp_queryobj->addUserSearchConditions($tmpChuantouSearchArr);
            }
            if(isset($tmpChuantouSearchArr['searchtype'])&&$tmpChuantouSearchArr['searchtype']=='advance'){
                //增加页面的高级查找
                $tmp_queryobj->addUserSearchConditions($tmpChuantouSearchArr);
            }
        }

        //自定义统计图自带的高价查找条件
        if(!empty($this->CustomEchartSearchArr)&&isset($this->CustomEchartSearchArr['searchtype'])&&$this->CustomEchartSearchArr['searchtype']=='advance'){
            $tmp_queryobj->addUserSearchConditions($this->CustomEchartSearchArr);
        }
        //时间条件是分录表的时候 需要连一下分录表
        if(!empty($date_adv)){
            $tmp_queryobj->addUserSearchConditions($date_adv);
        }

        //$tmp_queryobj->setPageListQueryColumn(['ld_salesorderdetail.lineitem_id']);
        //return  $tmp_queryobj->getQuery(1);
    }

    /**
     * @param $scopemodule
     * @param $tmpmodulename
     * @param $smownerfieldname
     * @param $scopeType
     * @param $senioruserid
     * @param $tmpfocus
     * @return string
     * 首页组件 -- 查看范围子SQL
     */
    public function getDataRangeSqlSmownerid ($scopemodule,$tmpmodulename,$smownerfieldname,$scopeType,$senioruserid,$tmpfocus){
        global $adb;
        //$moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
        //if(isset($moduleAllPreseneceFields[$smownerfieldname])&&$tmpmodulename!='PublicAnnouncement'){
        if($tmpmodulename!='PublicAnnouncement'){
            crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
            //看板传过来的筛选值 比如首页看板Home  移动端看板MobileReport  可视化分析VisualAnalysis
            $HomeScopeObj = new cls_ScopOfAuthority($adb, $this->frommodule);
            $HomeScopeObj->setParams($scopeType, $senioruserid);
            $tmpsmownersql = $HomeScopeObj->getHomeSmOwnerSearchSql($scopeType, $senioruserid);
            if(!empty($tmpsmownersql)){
                $HomeScopesql = $tmpfocus->table_name . '.' . $tmpsmownersql;
            }
            //数据范围模块的userid值  按看板组件 右侧设置选择的模块数据范围
            $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
            $ModuleScopeObj->setParams('SmOwner_Search_All', '');
            $scopesql = $ModuleScopeObj->getHomeSmOwnerSearchSql('SmOwner_Search_All','');
            //两者取交集
            if(!empty($HomeScopesql)){
                $scopesql = $HomeScopesql.' and '.$tmpfocus->table_name . '.' .$scopesql;
            }


            //如果是按首页数据范围来 调用方法getHomeSmOwnerSearchSql else 调用方法getSmOwnerSearchSql
            //edit: xll 2023/08/12 BUG0070832 kfbtest-管理驾驶舱-商机分析-最近销售机会组件-点击分页，弹出层列表单据变为空
            /*$BoardModule_arr = ['Home','VisualAnalysis','MobileReport'];
            if(in_array($scopemodule,$BoardModule_arr)) {
                //数据范围跟看板模块走  例如首页数据范围:首页数据范围选中值与首页数据范围的交集 即直接取前者就可
                $HomeScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
                $HomeScopeObj->setParams($scopeType, $senioruserid);
                $tmpsmownersql = $HomeScopeObj->getHomeSmOwnerSearchSql($scopeType, $senioruserid);
                if(!empty($tmpsmownersql)){
                    $HomeScopesql = $tmpfocus->table_name . '.' . $tmpsmownersql;
                }

                $ModuleScopeObj = $HomeScopeObj;
                $ModuleScopeObj->setParams('SmOwner_Search_All', '');
                $scopesql = $ModuleScopeObj->getHomeSmOwnerSearchSql('SmOwner_Search_All','');

                if(!empty($HomeScopesql)){
                    $scopesql = $HomeScopesql.' and '.$scopesql;
                }
            }
            else{
                //数据范围跟统计模块走  例如首页数据范围:首页数据范围选中值与统计模块数据范围的交集
                $HomeScopeObj = new cls_ScopOfAuthority($adb, $this->frommodule);
                $HomeScopeObj->setParams($scopeType, $senioruserid);
                $tmpsmownersql = $HomeScopeObj->getHomeSmOwnerSearchSql($scopeType, $senioruserid);
                if(!empty($tmpsmownersql)) {
                    $HomeScopesql = $tmpfocus->table_name . '.' . $tmpsmownersql;
                }
                $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
                $ModuleScopeObj->setParams('SmOwner_Search_All', '');
                $scopesql = $ModuleScopeObj->getHomeSmOwnerSearchSql('SmOwner_Search_All','');
                if(!empty($HomeScopesql)){
                    $scopesql = $HomeScopesql.' and '.$scopesql;
                }
            }*/
            $scopesql = trim($scopesql,' ');
            $scopesql = trim($scopesql,'and');
            if (!empty($scopesql)) {
                return $scopesql;
            }
        }
        return '';
    }
    //获取数据范围内的用户id集合  字符串 逗号分隔
    public function getDataRangeSmownerid ($scopemodule,$scopeType,$senioruserid){
        global $adb,$current_user;
        crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
        //看板传过来的筛选值 比如首页看板Home  移动端看板MobileReport  可视化分析VisualAnalysis
        $HomeScopeObj = new cls_ScopOfAuthority($adb, $this->frommodule);
        $HomeScopeObj->setParams($scopeType, $senioruserid);
        $SearchUserId_frommodule = $HomeScopeObj->getHomeSmOwnerSearchIds($scopeType, $senioruserid);
        $SearchUserId_frommodule_arr = explode(',',$SearchUserId_frommodule);
        //BUG20240923-10 首页按部门设置数据范围  人员选全部,当前登录人没有算进去
        if($scopeType=='SmOwner_Search_All'){
            $SearchUserId_frommodule_arr[] = $current_user->id;
        }
        //数据范围模块的userid值  按看板组件 右侧设置选择的模块数据范围
        //BUG20240807-18 工作简报查看别人的简报，数据还是显示别人的数据，不受数据权限影响，穿透后显示会根据数据权限
        if ($this->boardid == 'WorkBriefReport'){
            $SearchUserId = $SearchUserId_frommodule;
        }else{
            $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
            $ModuleScopeObj->setParams('SmOwner_Search_All', '');
            $SearchUserId_scopemodule = $ModuleScopeObj->getCurUserScopeIds();
            $SearchUserId_scopemodule_arr = explode(',',$SearchUserId_scopemodule);
            $SearchUserId_arr = array_intersect($SearchUserId_frommodule_arr,$SearchUserId_scopemodule_arr);
            $SearchUserId = empty($SearchUserId_arr)?'':implode(',',$SearchUserId_arr);
        }


        /*$BoardModule_arr = ['Home','VisualAnalysis','MobileReport'];
        if(in_array($scopemodule,$BoardModule_arr)) {
            $HomeScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
            $HomeScopeObj->setParams($scopeType, $senioruserid);
            $SearchUserId_str = $HomeScopeObj->getHomeSmOwnerSearchIds($scopeType, $senioruserid);
            $SearchUserId_frommodule_arr = explode(',',$SearchUserId_str);
            //移动端传过来的userid并未控制数据范围 这里需要也查询一下数据范围 取传过来的userid和数据范围userid的交集
            $ModuleScopeObj = $HomeScopeObj;
            $ModuleScopeObj->setParams('SmOwner_Search_All', '');
            $SearchUserId_scopemodule = $ModuleScopeObj->getCurUserScopeIds();
            $SearchUserId_scopemodule_arr = explode(',',$SearchUserId_scopemodule);
            $SearchUserId_arr = array_intersect($SearchUserId_frommodule_arr,$SearchUserId_scopemodule_arr);
            $SearchUserId = empty($SearchUserId_arr)?'':implode(',',$SearchUserId_arr);
        }else{
            $HomeScopeObj = new cls_ScopOfAuthority($adb, $this->frommodule);
            $HomeScopeObj->setParams($scopeType, $senioruserid);
            $SearchUserId_frommodule = $HomeScopeObj->getHomeSmOwnerSearchIds($scopeType, $senioruserid);
            $SearchUserId_frommodule_arr = explode(',',$SearchUserId_frommodule);
            //BUG20240923-10 首页按部门设置数据范围  人员选全部,当前登录人没有算进去
            if($scopeType=='SmOwner_Search_All'){
                $SearchUserId_frommodule_arr[] = $current_user->id;
            }
            //BUG20240807-18 工作简报查看别人的简报，数据还是显示别人的数据，不受数据权限影响，穿透后显示会根据数据权限
            if ($this->boardid == 'WorkBriefReport'){
                $SearchUserId = $SearchUserId_frommodule;
            }else{
                $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
                $ModuleScopeObj->setParams('SmOwner_Search_All', '');
                $SearchUserId_scopemodule = $ModuleScopeObj->getCurUserScopeIds();
                $SearchUserId_scopemodule_arr = explode(',',$SearchUserId_scopemodule);
                $SearchUserId_arr = array_intersect($SearchUserId_frommodule_arr,$SearchUserId_scopemodule_arr);
                $SearchUserId = empty($SearchUserId_arr)?'':implode(',',$SearchUserId_arr);
            }
        }*/
        return $SearchUserId;
    }
    /**
     * @return void
     * 有些组件没传boardstuffid过来 去数据库查吧
     */
    public function getboardstuffid($stuffid){
        $boardstuffid = 0;
        //zxm 20230616 查询 boardstuffid
        if($this->boardid>0&&$stuffid>0) {
            global $adb;
            $sql = "select boardstuffid from ld_homeboard_plate_stuff where stuffid=? and boardid=? and stufftype='defaultstuff'";
            $res = $adb->pquery($sql, array($stuffid, $this->boardid));
            $numrows = $adb->num_rows($res);

            if ($numrows > 0) {
                $boardstuffid = $adb->query_result($res, 0, 'boardstuffid');
            }
        }
        return $boardstuffid;
    }
    //首页默认组件的
    /**
     * @param $stuffid //1 ld_stuff表的主键ID
     * @param $boardstuffid//2 ld_homestuff_plate_stuff表的主键ID
     * @param $scope//SmOwner_Search_All
     * @param $senioruserid//'1,2,3,4'
     * @param $timerange  //between a and b
     * @param $approve_value//'approved,'
     * @return void
     * @throws Exception
     */
    public function getDataRangeSql($stuffid,$boardstuffid,$scope,$senioruserid,$timerange,$approve_value,$stufftype='defaultstuff'){
        global $adb,$current_user;
        $datarangesql_arr = [];
        if($boardstuffid<=0){
            $boardstuffid = $this->getboardstuffid($stuffid);
        }
        //获取设置好的条件
        $filterArr = $this->boardfilterArr[$boardstuffid];

        //获取关联模块
        if($boardstuffid>0){
            //新看板
            $datarangmodule = $this->boarddatarangmoduleArr[$boardstuffid];
        }else{
            //旧的看板 以及新建看板还没保存的时候
            $datarangmodule = $this->DefaultdatarangmoduleArr[$stufftype.'_'.$stuffid];
        }

        //按模块生成条件SQL
        if (!empty($datarangmodule)) {
            $tmpdatarangmodule_arr = explode(',', $datarangmodule);

            foreach ($tmpdatarangmodule_arr as $tmpmodulename) {
                //移动端  简报有新增跟进记录数  还有个跟进频次排行榜  跟进频次排行榜没数据.原因是同一个请求queryobj是同一个
                if($this->penetrateModule!=''){
                    //说明是穿透 穿透的时候 应该是只获取穿透模块的page_list_query
                    if($tmpmodulename!=$this->penetrateModule){
                        continue;
                    }
                }
                $this->resetModuleQueryObj($tmpmodulename);
                $this->datarangesqlArr['datarangesql_'.$tmpmodulename] = '';//表连接SQL
                $tmpfocus = CRMEntity::getInstance($tmpmodulename);

                if ($tmpfocus->fieldobj) {

                    $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
                    //查看范围sql拼接
                    $scopeisrelated = $filterArr['usercomponent_'.$tmpmodulename]['isrelated'];

                    if($scopeisrelated=='yes'){
                        $scopemodule = $filterArr['usercomponent_' . $tmpmodulename]['filtermodule'];
                    }else{
                        if($this->frommodule=='FreedomRelated'){
                            $scopemodule = $tmpmodulename;//Freedom自由的情况下 每个模块的数据范围依赖模块取决于自己模块
                        }else{
                            $scopemodule = $this->frommodule;//未关联则默认数据范围模块为首页
                        }
                    }
                    //高级查找条件
                    $filterArr['highsearch_' . $tmpmodulename]['filterssql'] = '';//高级查找单独的条件sql
                    $highsearchisrelated = $filterArr['highsearch_'.$tmpmodulename]['isrelated'];
                    $tmpadvance_demand = $filterArr['highsearch_'.$tmpmodulename]['advance_demand'];
                    $tmpadvance_demand_groups = $filterArr['highsearch_'.$tmpmodulename]['advance_demand_groups'];
                    $this->getDataRangeSqlHigh($tmpmodulename,$scopemodule,$highsearchisrelated,$tmpadvance_demand,$tmpadvance_demand_groups);//这个方法不返回pagelistquery了 只是为了获取querygenerator
                    $page_list_query = $this->queryObjArr[$tmpmodulename]->getQuery();
                    $datarangesql_arr[$tmpmodulename] = $page_list_query;


                    //获取负责人字段columnname 转折获取负责人字段的fieldname
                    //$smownercolumnname=$tmpfocus->getSmownerColumName();
                    //$smownerfieldinfo=$tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",$smownercolumnname);
                    //$scopesql = '';
                    //首页预设组件 除销售简报 龙虎榜 公告之外 全都是控制负责人
                    //if(!empty($smownerfieldinfo)) {
                        //$smownerfieldname = $smownerfieldinfo->getFieldName();
                        $scopesql = $this->getDataRangeSqlSmownerid($scopemodule, $tmpmodulename, '', $scope, $senioruserid, $tmpfocus);
                    //}
                    if (!empty($scopesql) && $stuffid != 118) {
                        if($boardstuffid>0&&$scopeisrelated=='yes'){
                            $datarangesql_arr[$tmpmodulename] .= ' and ' . $scopesql;
                        }
                        else if($boardstuffid<=0){
                            //老首页的数据范围
                            $datarangesql_arr[$tmpmodulename] .= ' and ' . $scopesql;
                        }
                    }

                    $timeisrelated = $filterArr['timecomponent_' . $tmpmodulename]['isrelated'];

                    $defaulttimefield = $this->getTimeDefaultField($tmpfocus->table_name,$stufftype,$stuffid);//默认的时间字段
                    $filterArr['timecomponent_' . $tmpmodulename]['filtersfield'] = $defaulttimefield;//默认的时间字段是什么
                    //时间范围sql拼接
                    if (($stuffid == 32 && $stufftype == 'defaultstuff') || $stuffid == 118 ) {
                        
                    }
                    else{
                        if ($boardstuffid > 0 && $timeisrelated == 'yes') {
                            //关联时间
                            $tmptimecolumns = $filterArr['timecomponent_' . $tmpmodulename]['filters'];

                            if (!empty($tmptimecolumns)) {
                                $tmptimecolumns_arr = explode(':', $tmptimecolumns);
                                //判断字段存在 再拼接时间条件
                                if (!empty($timerange) && isset($moduleAllPreseneceFields[$tmptimecolumns_arr[2]])) {
                                    //判断是不是自定义表
                                    if ($tmptimecolumns_arr[0] == $tmpfocus->customFieldTable[0]) {
                                        //是自定义表
                                        $tmpsql = explode('WHERE', $datarangesql_arr[$tmpmodulename]);
                                        $tmpsql[0] = $tmpsql[0] . ' left join ' . $tmpfocus->customFieldTable[0] . ' as selftable on selftable.' . $tmpfocus->customFieldTable[1] . '=' . $tmpfocus->table_name . '.' . $tmpfocus->table_index;
                                        $datarangesql_arr[$tmpmodulename] = implode(' WHERE ', $tmpsql);
                                        $datarangesql_arr[$tmpmodulename] .= ' and selftable.' . $tmptimecolumns_arr[1] . ' ' . $timerange;
                                    } else {
                                        $datarangesql_arr[$tmpmodulename] .= ' and ' . $tmptimecolumns_arr[0] . '.' . $tmptimecolumns_arr[1] . ' ' . $timerange;
                                    }

                                }
                                $filterArr['timecomponent_' . $tmpmodulename]['filtersfield'] = $tmptimecolumns_arr[0] . '.' . $tmptimecolumns_arr[1];//时间字段
                            }
                        }
                        else if ($boardstuffid <= 0) {
                            //老首页的数据范围
                            //判断字段存在 再拼接时间条件
                            $defaulttimefield_arr = explode('.', $defaulttimefield);
                            if (!empty($timerange)&&!empty($defaulttimefield))
                                $datarangesql_arr[$tmpmodulename] .= ' and ' . $defaulttimefield . ' ' . $timerange;
                        }
                    }

                    //审批条件
                    $approvestatusisrelated = $filterArr['approvestatuscomponent_'.$tmpmodulename]['isrelated'];
                    $filterArr['approvestatuscomponent_' . $tmpmodulename]['filterssql'] = '';//审批字段单独的条件sql
                    if(($boardstuffid>0&&$approvestatusisrelated=='yes')||$boardstuffid<=0) {
                        $approvestatussql = $this->getApproveQuery($tmpfocus,$approve_value);
                        $datarangesql_arr[$tmpmodulename] .= $approvestatussql;
                        $filterArr['approvestatuscomponent_' . $tmpmodulename]['filterssql'] = $approvestatussql;//审批字段单独的条件sql
                    }

                    //默认看板的默认组件的默认条件  比如25  30天内及过期回款计划
                    if($boardstuffid<=0&&$stufftype=='defaultstuff'){
                        $datarangesql_arr[$tmpmodulename] .= $this->getDefaultKanbanStuffCondition($stuffid);
                    }

                    if(!empty($datarangesql_arr[$tmpmodulename])){
                        $this->datarangesqlArr['datarangesql_'.$tmpmodulename] = ' inner join ('.$datarangesql_arr[$tmpmodulename].') datarangesql_'.strtolower($tmpmodulename).' on datarangesql_'.strtolower($tmpmodulename).'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                    }
                }
            }
        }

        $this->filterArr = $filterArr;
        return $datarangesql_arr;
    }
    /**
     * @param $datarangmodule //主模块--自定义统计图
     * @param $computemodule //统计模块 也是穿透模块
     * @param $stuffid //1 ld_stuff表的主键ID
     * @param $boardstuffid//2 ld_homestuff_plate_stuff表的主键ID
     * @param $scope//SmOwner_Search_All
     * @param $senioruserid//'1,2,3,4'
     * @param $date_adv  //高级查找数组 字段用字符串替换的
     * @param $approve_value//'approved,'
     * @return void
     * @throws Exception
     */
    public function getDataRangeSqlCharts($params){
        global $adb,$current_user;
        $datarangmodule = $params['datarangmodule'];//条件模块--也就是主模块
        $computemodule = $params['computemodule'];//统计模块--也就是穿透模块
        $stuffid = $params['stuffid'];//组件id  报表id
        $boardstuffid = $params['boardstuffid'];
        $scope = $params['scope'];
        $senioruserid = $params['senioruserid'];
        $date_adv = $params['date_adv'];//时间条件 高级查找数组
        $approve_value = $params['approve_value'];//审批条件
        $ischuantou = $params['ischuantou'];
        $stufftype = 'customreport';//自定义统计图
        $iscomputedetailtable = $params['iscomputedetailtable'];//统计字段是否有明细字段
        $datarangesql_arr = [];
        if($boardstuffid<=0){
            $boardstuffid = $this->getboardstuffid($stuffid);
        }
        //获取设置好的条件
        $filterArr = $this->boardfilterArr[$boardstuffid];
        $tmpmodulename = $datarangmodule;
        //按模块生成条件SQL
        if (!empty($tmpmodulename)) {
            $this->datarangesqlArr['datarangesql_'.$tmpmodulename] = '';//表连接SQL
            $tmpfocus = CRMEntity::getInstance($tmpmodulename);
            $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index];
            $joinon_field = $tmpfocus->table_index;
            $jointable = $tmpfocus->table_name;
            if ($tmpfocus->fieldobj) {
                $advft = [];
                $advft_criteria = [];
                $advft_criteria_groups = '[{"groupcondition":""}]';
                //审批条件
                $this->setApproveStatusAdv($tmpfocus,$advft_criteria,['filterArr'=>$filterArr,'boardstuffid'=>$boardstuffid,'approve_value'=>$approve_value]);
                //人员条件
                $this->setUseridAdv($tmpfocus,$advft_criteria,['filterArr'=>$filterArr,'boardstuffid'=>$boardstuffid,'scope'=>$scope,'senioruserid'=>$senioruserid]);
                $scopeisrelated = $filterArr['usercomponent_'.$tmpmodulename]['isrelated'];
                if($scopeisrelated=='yes'){
                    //关联数据范围
                    $scopemodule = $filterArr['usercomponent_' . $tmpmodulename]['filtermodule'];
                }else{
                    $scopemodule = $tmpmodulename;
                }
                $tmptimecolumns = '';
                $timeisrelated = $filterArr['timecomponent_' . $tmpmodulename]['isrelated'];
                $defaulttimefield = $this->getTimeDefaultField($tmpfocus->table_name,$stufftype,$stuffid);//默认的时间字段
                $filterArr['timecomponent_' . $tmpmodulename]['filtersfield'] = $defaulttimefield;//默认的时间字段是什么

                if ($boardstuffid > 0 && $timeisrelated == 'yes') {
                    //关联时间
                    $tmptimecolumns = $filterArr['timecomponent_' . $tmpmodulename]['filters'];
                }
                else if ($boardstuffid <= 0) {
                    //老首页的数据范围
                    //判断字段存在 再拼接时间条件
                    $tmptimecolumns = $this->getTimeDefaultFieldColumns($tmpfocus,$stufftype,$stuffid);
                }
                //时间高级查找条件

                if(!empty($date_adv)&&!empty($tmptimecolumns)){
                    $date_adv['advft_criteria'] = str_replace('{timefieldstr}', $tmptimecolumns, $date_adv['advft_criteria']);
                }
                //高级查找条件--这个是看板页面设置的高级查找
                $filterArr['highsearch_' . $tmpmodulename]['filterssql'] = '';//高级查找单独的条件sql
                $highsearchisrelated = $filterArr['highsearch_'.$tmpmodulename]['isrelated'];
                $tmpadvance_demand = $filterArr['highsearch_'.$tmpmodulename]['advance_demand'];
                $tmpadvance_demand_groups = $filterArr['highsearch_'.$tmpmodulename]['advance_demand_groups'];
                $this->getDataRangeSqlHigh($tmpmodulename,$scopemodule,$highsearchisrelated,$tmpadvance_demand,$tmpadvance_demand_groups,$date_adv);//这个方法不返回pagelistquery了 只是为了获取querygenerator
                if(!empty($advft_criteria)){
                    $advft['advft_criteria'] = json_encode($advft_criteria);
                    $advft['advft_criteria_groups'] = $advft_criteria_groups;
                    $advft['searchtype'] = 'advance';
                }

                //人员高级查找条件和审批条件高级查找
                if(!empty($advft))
                {
                    $this->queryObjArr[$tmpmodulename]->addUserSearchConditions($advft);
                }
                $this->queryObjArr[$tmpmodulename]->getWhereClause();
                $jointype = 'main';
                if(!empty($this->queryObjArr[$tmpmodulename]->whereDetailTable)&&$iscomputedetailtable=='yes') {
                    //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid  还需要判断条件子SQL是否连了明细表(即是否有明细表的条件)
                    $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index, $tmpfocus->Detail_table . '.' . $tmpfocus->Detail_table_id];
                    $joinon_field = $tmpfocus->Detail_table_id;
                    $jointable =  $tmpfocus->Detail_table;
                    $jointype = 'detail';
                }
                $this->queryObjArr[$tmpmodulename]->setPageListQueryColumn($pagelistquerycol_arr);
                $page_list_query = $this->queryObjArr[$tmpmodulename]->getQuery();
                $datarangesql_arr[$tmpmodulename] = $page_list_query;
                if(!empty($datarangesql_arr[$tmpmodulename])){
                    $tmpinnerjoinon=$joinon_field.'='.$jointable.'.'.$joinon_field;
                    $this->datarangesqlArr['datarangesql_'.$tmpmodulename] = ' inner join ('.$datarangesql_arr[$tmpmodulename].') datarangesql_'.strtolower($tmpmodulename).' on datarangesql_'.strtolower($tmpmodulename).'.'.$tmpinnerjoinon;
                    $this->datarangesqlArr['jointype_'.$tmpmodulename] =$jointype;
                }
            }
        }

        $this->filterArr = $filterArr;
        return $datarangesql_arr;
    }
    //销售简报的条件sql--销售简报和数据龙虎榜会用到这个
    //$stuffid,$computemodule,$scope,$senioruserid,$timerangecur,$timerangeprev,$approve_value,$advance_demand,$advance_demand_groups
    public function getDataRangeSqlSalesKit($params){
        global $adb,$current_user;
        $computemodule = $params['compute_module'];
        $compute_columns=$params['compute_columns'];
        $scope = $params['scopeType'];
        $senioruserid = $params['senioruserid'];
        $date_adv = $params['date_adv'];//本月 时间高级查找数组
        $date_advbefore = $params['date_advbefore'];//上月 时间高级查找数组

        $timerangeprev = $params['before_datewhere'];
        $approve_value = $params['approve_value'];
        $advance_demand = $params['advance_demand'];
        $advance_demand_groups = $params['advance_demand_groups'];
        $datarangesql_str['cur'] = '';//本期
        $datarangesql_str['prev'] = '';//上期
        $this->datarangesqlArr['cur']='';
        $this->datarangesqlArr['prev']='';

        $iscomputedetailtable='no';
        //$this->selectcolumns=$compute_columns;

        //按模块生成条件SQL
        if (!empty($computemodule)) {
            $tmpfocus = CRMEntity::getInstance($computemodule);
            $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index];
            $joinon_field = $tmpfocus->table_index;
            $jointable = $tmpfocus->table_name;
            if (!empty($compute_columns)){
                $compute_column_arr = explode(".", $compute_columns);
                $computetablename = $compute_column_arr[0];
                //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid
                if (in_array($computetablename, [$tmpfocus->Detail_table, $tmpfocus->Detail_table_scf])
                    || (in_array($computetablename, ['ld_products', 'ld_productcf']) && $computemodule != 'Products')) {
                    $iscomputedetailtable = 'yes';
                }
            }
            if ($tmpfocus->fieldobj) {
                //edit: xll 2023/10/07 BUG0072860 数据简报、龙虎榜的查看范围筛选条件映射字段关闭时，不受模块数据范围影响，即$scopemodule为空
                $viewrange = $params['viewrange'];//数据范围限制字段
                $scopemodule = '';
                $advft = [];
                $advft_criteria = [];
                $advft_criteria_groups = '[{"groupcondition":""}]';
                //审批条件放高级查找
                if($approve_value!='all') {
                    $tmpFieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', 'approvestatus');
                    $approvestatus_zh = $this->getApproveValue($tmpfocus,$approve_value);
                    if($tmpFieldInfo&&!empty($approvestatus_zh)){
                        $typeofdata_arr = explode('~', $tmpFieldInfo->getTypeOfData());
                        $advft_criteria[] = ['groupid' => 1,
                            'columnname' => $tmpFieldInfo->getTableName() . ":" . $tmpFieldInfo->getColumnName() . ":" . $tmpFieldInfo->getFieldName() . ":" . $computemodule . "_fieldlabel:" . $typeofdata_arr[0],
                            'comparator' => 'findinset',
                            'value' =>  $approvestatus_zh,
                            'columncondition' => 'and'
                        ];
                    }
                }

                //如果这个字段值为空 则表示不限制数据范围 //BUG0070640	【通用】首页销售简报的筛选器，可否不控制必选时间范围映射（路总安排）
                if (!empty($viewrange)) {
                    //人员的高级查找--如果设置的是自定义表的人员字段  需要连自定义表
                    $SearchUserId = $this->getDataRangeSmownerid($computemodule,$scope, $senioruserid);

                    //if(!empty($SearchUserId)){
                        $advft_criteria[]=['groupid'=>1,
                            'columnname'=>$viewrange,
                            'comparator'=>'findinset',
                            'value'=>$SearchUserId,
                            'columncondition'=>''
                        ];//zxm 20240626 成员筛选变成高级查找放进去
                    //}
                    $scopemodule = $computemodule;
                }
                if(!empty($advft_criteria)){
                    $advft['advft_criteria'] = json_encode($advft_criteria);
                    $advft['advft_criteria_groups'] = $advft_criteria_groups;
                    $advft['searchtype'] = 'advance';
                }

                //时间范围改高级查找
                if (!empty($params['daterange'])) {
                    $daterange = $params['daterange'];
                    if(isset($date_adv['advft_criteria']))
                         $date_adv['advft_criteria'] = str_replace('{timefieldstr}', $daterange, $date_adv['advft_criteria']);
                    if(isset($date_advbefore['advft_criteria']))
                        $date_advbefore['advft_criteria'] = str_replace('{timefieldstr}', $daterange, $date_advbefore['advft_criteria']);

                } else {
                    $date_adv = array();
                    $date_advbefore = array();
                }

                if($params['searchtype']!='last') {
                    //本期

                    $this->resetModuleQueryObj($computemodule);

                    //高级查找条件sql
                    $this->getDataRangeSqlHigh($computemodule, $scopemodule, 'yes', $advance_demand, $advance_demand_groups, $date_adv);

                    if(!empty($advft)){
                        $this->queryObjArr[$computemodule]->addUserSearchConditions($advft);
                    }
                    $this->queryObjArr[$computemodule]->getWhereClause();
                    if(!empty($this->queryObjArr[$computemodule]->whereDetailTable)&&$iscomputedetailtable=='yes') {
                        //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid  还需要判断条件子SQL是否连了明细表(即是否有明细表的条件)
                        $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index, $tmpfocus->Detail_table . '.' . $tmpfocus->Detail_table_id];
                        $joinon_field = $tmpfocus->Detail_table_id;
                        $jointable =  $tmpfocus->Detail_table;
                    }
                    $this->queryObjArr[$computemodule]->setPageListQueryColumn($pagelistquerycol_arr);

                    $page_list_query = $this->queryObjArr[$computemodule]->getQuery();



                }
                if($params['searchtype']!='now') {
                    //上期
                    $this->resetModuleQueryObj($computemodule);
                    $this->getDataRangeSqlHigh($computemodule, $scopemodule, 'yes', $advance_demand, $advance_demand_groups, $date_advbefore);
                    if(!empty($advft)) {
                        $this->queryObjArr[$computemodule]->addUserSearchConditions($advft);
                    }
                    $this->queryObjArr[$computemodule]->getWhereClause();
                    if(!empty($this->queryObjArr[$computemodule]->whereDetailTable)&&$iscomputedetailtable=='yes') {
                        //判断统计字段是主表还是明细表  明细表的话pagelistquery字段是lineitemid 主表的话是salesorderid  还需要判断条件子SQL是否连了明细表(即是否有明细表的条件)
                        $pagelistquerycol_arr = [$tmpfocus->table_name . '.' . $tmpfocus->table_index, $tmpfocus->Detail_table . '.' . $tmpfocus->Detail_table_id];
                        $joinon_field = $tmpfocus->Detail_table_id;
                        $jointable =  $tmpfocus->Detail_table;
                    }
                    $this->queryObjArr[$computemodule]->setPageListQueryColumn($pagelistquerycol_arr);
                    $page_list_query_prev = $this->queryObjArr[$computemodule]->getQuery();
                }

                $datarangesql_str['cur'] = $page_list_query;
                $datarangesql_str['prev'] = $page_list_query_prev;//上期 条件  上面条件都一样

                $tmpinnerjoinon=$joinon_field.'='.$jointable.'.'.$joinon_field;
                $this->datarangesqlArr['cur'] = ' inner join ('.$datarangesql_str['cur'].') datarangesql_'.strtolower($computemodule).
                            ' on datarangesql_'.strtolower($computemodule).'.'.$tmpinnerjoinon;
                if(!empty($timerangeprev)) {
                    $this->datarangesqlArr['prev'] = ' inner join (' . $datarangesql_str['prev'] . ') datarangesql_' . strtolower($computemodule)
                        . ' on datarangesql_' . strtolower($computemodule) . '.' . $tmpinnerjoinon;
                }
            }
        }
        return $datarangesql_str;
    }
    public static function getHomeDateScope($search_date,$EqualDuration) {
        crm_load_class_file('DateOperation','include');
        $date = DateOperation::getHomeDateScope($search_date);
        $datevalue='';
        $before_datevalue='';
        $datecomparator='';
        $before_datecomparator='';
        $datewhere=$date;
        $before_datewhere=$date;//环比上期

        //把首页时间条件条件组成一个高级查找条件数组
        $advft_criteria_groups = '[{"groupcondition":""}]';
        $tmp_criteria = ['groupid'=>1,
            'columnname'=>'{timefieldstr}',
            'comparator'=>$datecomparator,
            'value'=>'',
            'columncondition'=>''
        ];//本期
        $tmp_criteria_before = $tmp_criteria;//上期
        $returntype = 'comparatorvalue';
        switch(trim($search_date)){
            case 'thistoday':	//今日
            case 'today'://手机端
                $before_datewhere = getHomeDateScope('yestoday',$EqualDuration,$returntype);
                $curlabel=getFixedLabel('checktoday');
                $beforelabel=getFixedLabel('YESTERDAY');
                $datecomparator='today';

                $before_datecomparator='syesterday';//高级查询使用
                $tmp_criteria['comparator']= $datecomparator;//本期
                $tmp_criteria_before['comparator']= $before_datecomparator;//上期
                break;
            case 'yestoday':	//昨日
            case 'syesterday'://手机daunt
                $before_datewhere = date('Y-m-d',strtotime("-2 day"));
                $before_datevalue="$before_datewhere 00:00:00,$before_datewhere 23:59:59";
                $before_datecomparator='bw';//高级查询使用
                $datecomparator='syesterday';//高级查询使用

                $before_datewhere= " like '%$before_datewhere%' " ;
                $curlabel=getFixedLabel('checkyesterday');
                $beforelabel=getFixedLabel('BeforeYesterday');
                $tmp_criteria['comparator']= $datecomparator;//本期
                $tmp_criteria_before['comparator']= $before_datecomparator;//上期
                $tmp_criteria_before['value']= $before_datevalue;
                break;
            case 'thisweek':	//本周
                $datewhere = getHomeDateScope('thisweek',$EqualDuration,$returntype);
                $before_datewhere = getHomeDateScope('lastweek',$EqualDuration,$returntype);
                $curlabel=getFixedLabel('thisweek');
                $beforelabel=getFixedLabel('lastweek');

                $datecomparator='thisweek';
                $before_datecomparator='lastweek';
                $tmp_criteria['comparator']= 'bw';//本期
                $tmp_criteria['value']= $datewhere;//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $before_datevalue = str_replace('and',',',str_replace('between','',$before_datewhere));
                $tmp_criteria_before['value']= $before_datevalue;//上期
                break;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                $datevalue="$nowStart,$nowEnd";
                $lastStart = date('Y-m-d 00:00:00',strtotime("$nowStart - 7 days"));  //上上周开始时间
                $lastEnd   = date('Y-m-d 23:59:59',strtotime("$nowStart - 1 days"));  //上上周结束时间
                $before_datevalue="$lastStart,$lastEnd";
                $before_datecomparator='bw';

                $before_datewhere= " between '$lastStart' and '$lastEnd' " ;
                $curlabel=getFixedLabel('lastweek');
                $beforelabel=getFixedLabel('beflastweek');
                $datecomparator='lastweek';
                $tmp_criteria['comparator']= $datecomparator;//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $tmp_criteria_before['value']= "$lastStart,$lastEnd";
                break;
            case 'thismonth':	//本月
            case 'month':
                $datewhere = getHomeDateScope('thismonth',$EqualDuration,$returntype);
                $before_datewhere = getHomeDateScope('lastmonth',$EqualDuration,$returntype);
                $curlabel=getFixedLabel('thismonth');
                $beforelabel=getFixedLabel('lastmonth');
                $tmp_criteria['comparator']= 'bw';//本期
                $tmp_criteria['value']= $datewhere;//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $tmp_criteria_before['value']= $before_datewhere;//上期

                break;
            case 'lastmonth':	//上月
                //zxm 20230104 选择上月的时候  上上月的时间计算错误
                $date = date("Y-m",strtotime("-2 month"));
                $monthdays=DateOperation::getMonthDays("$date-01");
                $before_datevalue="$date-01 00:00:00 $date-$monthdays 23:59:59";
                $before_datecomparator='bw';

                $before_datewhere= " like '%$date%' " ;
                $curlabel=getFixedLabel('lastmonth');
                $beforelabel=getFixedLabel('beflastmonth');
                $datecomparator='lastmonth';
                $tmp_criteria['comparator']= 'lastmonth';//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $tmp_criteria_before['value']= "$date-01 00:00:00,$date-$monthdays 23:59:59";

                break;

            case 'thisyear':	//本年度
            case 'year':
            case 'thisfy'://手机端
                $datewhere = getHomeDateScope('thisyear',$EqualDuration,$returntype);
                $before_datewhere=getHomeDateScope('lastyear',$EqualDuration,$returntype);
                $curlabel=getFixedLabel('thisyear1');
                $beforelabel=getFixedLabel('lastyear1');
                $datecomparator='thisfy';
                $before_datecomparator='prevfy';
                $tmp_criteria['comparator']= 'bw';//本期
                $tmp_criteria['value']= $datewhere;//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $tmp_criteria_before['value']= $before_datewhere;//上期
                break;
            case 'lastyear':	//上年度
            case 'prevfy'://手机端
                $before_datewhere = date('Y',strtotime("-2 year"));
                $before_datevalue="$before_datewhere-01-01 00:00:00,$before_datewhere-12-31 23:00:00";


                $before_datewhere= " like '%$before_datewhere%' " ;
                $curlabel=getFixedLabel('lastyear1');
                $beforelabel=getFixedLabel('BeforeLastYear');
                $datecomparator='prevfy';
                $tmp_criteria['comparator']= 'prevfy';//本期
                $tmp_criteria_before['comparator']= 'bw';//上期
                $tmp_criteria_before['value']= $before_datevalue;
                break;
            case 'thisquarter':	//本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $datewhere = getHomeDateScope('thisquarter',$EqualDuration,$returntype);
                $before_datewhere=getHomeDateScope('lastquarter',$EqualDuration,$returntype);
                $curlabel=getFixedLabel('thisfq');
                $beforelabel=getFixedLabel('prevfq');

                $before_datecomparator='prevfq';
                $datecomparator='thisfq';
                $tmp_criteria['comparator']= 'bw';
                $tmp_criteria['value']= $datewhere;
                $tmp_criteria_before['comparator']= 'bw';
                $tmp_criteria_before['value']= $before_datewhere;
                break;
            case 'lastquarter':	//上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-2;
                $startdate = date('Y-m-d H:i:s', mktime(0, 0, 0,$season*3-3+1,1,date('Y')));
                $enddate = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));

                $datecomparator='prevfq';
                $before_datecomparator='bw';
                $before_datevalue=$startdate.','.$enddate;
                //edit:can 50817: (http://81.70.62.132/crm [^])(客户问题-苏宁) 首页 模块销售简报部分蓝色字体无法穿透点击，数据异常
                $before_datewhere=" between '$startdate' and '$enddate' ";
                $curlabel=getFixedLabel('prevfq');
                $beforelabel=getFixedLabel('PrevPrevfq');
                $tmp_criteria['comparator']= 'prevfq';
                $tmp_criteria_before['comparator']= 'bw';
                $tmp_criteria_before['value']= "$startdate,$enddate";
                break;
            case 'all':
                $before_datevalue='';
                $curlabel="";
                $beforelabel="";
                $tmp_criteria['comparator']= 'isnotnull';
                $tmp_criteria_before['comparator']= 'isnotnull';
                $tmp_criteria_before['value']= "";
                break;
            default:
                $date = explode('~',$search_date);
                if(sizeof($date) > 1){
                    $datevalue=$date[0].','.$date[1];
                    //edit:can 20200820 42434: （61mis.com/kfbcrm）客户问题（易冲半导体），首页>销售简报：时间选择“自定义时间”，“2020-5-1至2020-5-31”点击确定，销售简报显示的时间只有一天“2020-5-1至2020-5-1”（需要补丁）
                    $curlabel=$search_date;
                    $beforelabel='';//$before_datewhere_one.'~'.$before_datewhere_two;BUG20240614-56 微信小程序端工作台--目标完成率分析--数据简报：筛选条件是自定义时间段的简报，数据简报右边不需要显示对比字段和数据（邱：如果是自定义时间，看我截图返回值，beforelabel返回值改成“”即可）
                    $before_datewhere= " between '$date[0] 00:00:00' and '$date[1] 23:59:59' " ;
                    $tmp_criteria['comparator']= 'bw';
                    $tmp_criteria['value']= "$date[0] 00:00:00,$date[1] 23:59:59";
                    $tmp_criteria_before['comparator']= 'bw';
                    $tmp_criteria_before['value']= "$date[0] 00:00:00,$date[1] 23:59:59";
                }

        }

        //本期
        $advft_criteria[] = $tmp_criteria;
        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';
        //上期

        $advft_criteria_before[] = $tmp_criteria_before;
        $advft_before['advft_criteria'] = json_encode($advft_criteria_before);
        $advft_before['advft_criteria_groups'] = $advft_criteria_groups;
        $advft_before['searchtype'] = 'advance';
        return [
            'datevalue'=>$datevalue,
            'before_datevalue'=>$before_datevalue,
            'date_adv'=>empty($search_date)?array():$advft,//本期
            'date_advbefore'=>empty($search_date)?array():$advft_before,//上期
            'datecomparator'=>$datecomparator,//本期
            'before_datecomparator'=>$before_datecomparator,//上期
            'datewhere'=>$datewhere,
            'curlabel'=>$curlabel,
            'beforelabel'=>$beforelabel,
            'before_datewhere'=>$before_datewhere
        ];
    }

    //首頁穿透  基本查找和高級查找的參數設置
    public function setBasicAndHighsearchParam($chuantouSearchArr,$penetrateModule){
        $this->chuantouSearchArr[$penetrateModule] = $chuantouSearchArr;
    }
    //自定义统计图  传过来的自定义统计图设置的高级查找条件
    public function setCustomEchartHighSearchParam($CustomEchartSearchArr){
        $this->CustomEchartSearchArr = $CustomEchartSearchArr;
    }
    /**
     * @param $tablename
     * @return string
     * 获取某个表默认的时间筛选字段  格式：表名.字段名
     */
    public function getTimeDefaultField($tablename,$type,$stuffid){
        switch ($tablename){
            case 'ld_account':
                $fieldname = $tablename.'.createdtime' ;
                //zxm BUG0075210 首页->今日待联系组件，时间映射字段默认值错误，默认值应该是“下次回访日期”，目前是创建时间
                if($type=='defaultstuff'&&$stuffid==13){
                    $fieldname = $tablename.'.nextcontactdate' ;
                }
                return $fieldname ;

            case 'ld_cashbill':return $tablename.'.cashbilldate' ;
            case 'ld_salesorder':return $tablename.'.signed_data' ;
            case 'ld_servicecontracts':return $tablename.'.due_date' ;
            case 'ld_invoice':return $tablename.'.invoicedate' ;
            case 'ld_outboundorder':return $tablename.'.outdate' ;
            case 'ld_paymentplan':return $tablename.'.plandate' ;
            case 'ld_contactrecords':return $tablename.'.contactdate' ;
            case 'ld_cashback':return $tablename.'.cashbackdate' ;
            case 'ld_products':
                $fieldname = $tablename.'.createdtime' ;
                if($type=='defaultstuff'&&$stuffid==60){
                    //zxm 20231128 产品销售排行榜  不限制产品表时间
                    $fieldname = '' ;
                }
                return $fieldname ;
            default:return $tablename.'.createdtime' ;
        }
    }
    /**
     * @param $focus
     * @param $type //自定义统计图 还是默认组件
     * @param $stuffid //组件id或者报表id
     * @return string 格式 表名：columnname:fieldname:模块_fieldlable:typeofdata
     * 获取某个表默认的时间筛选字段  格式：表名.字段名
     */
    public function getTimeDefaultFieldColumns($focus,$type,$stuffid){
        $tablename = $focus->table_name;
        switch ($tablename){
            case 'ld_account':
                $fieldname = 'createdtime' ;
                //zxm BUG0075210 首页->今日待联系组件，时间映射字段默认值错误，默认值应该是“下次回访日期”，目前是创建时间
                if($type=='defaultstuff'&&$stuffid==13){
                    $fieldname = 'nextcontactdate' ;
                }
               break;

            case 'ld_cashbill':$fieldname = 'cashbilldate' ;break;
            case 'ld_salesorder':$fieldname ='signed_data' ;break;
            case 'ld_servicecontracts':$fieldname ='due_date' ;break;
            case 'ld_invoice':$fieldname ='invoicedate' ;break;
            case 'ld_outboundorder':$fieldname ='outdate' ;break;
            case 'ld_paymentplan':$fieldname ='plandate' ;break;
            case 'ld_contactrecords':$fieldname ='contactdate' ;break;
            case 'ld_cashback':$fieldname ='cashbackdate' ;break;
            case 'ld_products':
                $fieldname = 'createdtime' ;
                if($type=='defaultstuff'&&$stuffid==60){
                    //zxm 20231128 产品销售排行榜  不限制产品表时间
                    $fieldname = '' ;
                }
                break;
            default:$fieldname='createdtime' ;break;
        }
        $tmpFieldInfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname', $fieldname);
        $columns = '';
        if($tmpFieldInfo){
            $typeofdata_arr = explode('~', $tmpFieldInfo->getTypeOfData());
            $columns = $tmpFieldInfo->getTableName() . ":" . $tmpFieldInfo->getColumnName() . ":" . $tmpFieldInfo->getFieldName() . ":" . $focus->module_name . "_fieldlabel:" . $typeofdata_arr[0];
        }
        return $columns;
    }
    //组装审批高级查找格式--自定义统计图
    public function setApproveStatusAdv($tmpfocus,&$advft_criteria,$params){
        $filterArr = $params['filterArr'];
        $boardstuffid = $params['boardstuffid'];
        $approve_value = $params['approve_value'];

        $tmpmodulename = $tmpfocus->module_name;
        $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
        $Approvedeploy = getSys_Approvedeploy($tmpmodulename);//deploy_value=0是开启 =1是关闭

        $approvestatusisrelated = $filterArr['approvestatuscomponent_'.$tmpmodulename]['isrelated'];
        if(($boardstuffid>0&&$approvestatusisrelated=='yes')||$boardstuffid<=0) {
            if(is_array($Approvedeploy)&&$Approvedeploy['deploy_value']==0&&$approve_value!='all'&&!empty($approve_value)&&isset($moduleAllPreseneceFields['approvestatus'])) {
                $tmpFieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', 'approvestatus');
                $approvestatus_zh = $this->getApproveValue($tmpfocus,$approve_value);
                if($tmpFieldInfo&&!empty($approvestatus_zh)){
                    $typeofdata_arr = explode('~', $tmpFieldInfo->getTypeOfData());
                    $advft_criteria[] = ['groupid' => 1,
                        'columnname' => $tmpFieldInfo->getTableName() . ":" . $tmpFieldInfo->getColumnName() . ":" . $tmpFieldInfo->getFieldName() . ":" . $tmpmodulename . "_fieldlabel:" . $typeofdata_arr[0],
                        'comparator' => 'findinset',
                        'value' => $approvestatus_zh,
                        'columncondition' => 'and'
                    ];
                }
            }
        }
    }
    //组装人员高级查找格式--自定义统计图
    public function setUseridAdv($tmpfocus,&$advft_criteria,$params)
    {
        $filterArr = $params['filterArr'];
        $boardstuffid = $params['boardstuffid'];
        $scope = $params['scope'];
        $senioruserid = $params['senioruserid'];
        $tmpmodulename = $tmpfocus->module_name;
        //zxm 20240626 成员筛选变成高级查找放进去
        $scopeisrelated = $filterArr['usercomponent_'.$tmpmodulename]['isrelated'];
        if($scopeisrelated=='yes'||$boardstuffid<=0){
            $scopemodule = $filterArr['usercomponent_' . $tmpmodulename]['filtermodule'];
            //老看板 $filterArr['usercomponent_' . $tmpmodulename]['filtermodule']没值 scopemodule取主模块
            $scopemodule = $boardstuffid<=0?$tmpmodulename:$scopemodule;
            $SearchUserId = $this->getDataRangeSmownerid($scopemodule,$scope, $senioruserid);

            $tmpSmownerColumName = $tmpfocus->getSmownerColumName();//负责人字段
            $tmpFieldInfo = $tmpfocus->fieldobj->getFieldInfoobjBykey('columnname', $tmpSmownerColumName);

            //if($tmpFieldInfo&&!empty($SearchUserId)) {
            if($tmpFieldInfo) {
                $typeofdata_arr = explode('~', $tmpFieldInfo->getTypeOfData());
                $advft_criteria[] = ['groupid' => 1,
                    'columnname' => $tmpFieldInfo->getTableName() . ":" . $tmpSmownerColumName . ":" . $tmpFieldInfo->getFieldName() . ":" . $tmpmodulename . "_fieldlabel:" . $typeofdata_arr[0],
                    'comparator' => 'findinset',
                    'value' => $SearchUserId,
                    'columncondition' => ''
                ];
            }

        }
    }
    /**
     * @return void
     * 获取默认看板的某几个特殊组件的高级查找条件 ---写死  就默认看板用
     * 25 ---  30天内及过期回款计划
     */
    public function getDefaultKanbanStuffCondition($stuffid){
        switch ($stuffid){
            case '25':return " and ld_paymentplan.paymentstatus='未收' and ld_paymentplan.plandate < DATE_ADD(DATE_FORMAT(NOW(),'%Y-%m-%d'),INTERVAL 30 DAY) and ld_paymentplan.plandate > '1900-01-01 ' " ;
            case '32':
                $nowdate = date('Y-m-d');
                return " and ('$nowdate' between ld_publicannouncement.startdate and ld_publicannouncement.enddate) ";;
            default:return "" ;
        }
    }

    /**
     * @param $tablename
     * @param $approve_value
     * @return array|string|string[]
     * 获取审批sql
     */
    public function getApproveQuery($tmpfocus,$approve_value){
        $query = '';
        $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
        $tablename = $tmpfocus->table_name;
        //新首页的审批条件                                  //老首页的时间范围
        //获取审批是否开启
        $Approvedeploy = getSys_Approvedeploy($tmpfocus->module_name);//deploy_value=0是开启 =1是关闭

        //判断字段存在 再拼接时间条件
        if (is_array($Approvedeploy)&&$Approvedeploy['deploy_value']==0&&!empty($approve_value)&&isset($moduleAllPreseneceFields['approvestatus'])) {

            if(!empty($approve_value)){
                if($approve_value == 'all' || strpos($approve_value,'all') !== false){
                    //$query = ' and ifnull('.$tablename.'.approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                    //zxm 审批状态条件以设置为准,用户在界面勾选什么就判断什么
                    $query = ' ';
                }else{
                    $query = ' and '.$tablename.'.approvestatus in ('.$approve_value.')';
                    $query = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$query);
                    $query = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$query);
                    $query = str_replace("approved","'" . D_A_S_APPROVED . "'",$query);
                    $query = str_replace("rejected","'" . D_A_S_REJECTED . "'",$query);
                    $query = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$query);
                }
            }
        }

        return $query;
    }
    //首页传过来的审批值是unapproved，approving，approved，rejected，dismissed，替换成中文
    public function getApproveValue($tmpfocus,$approve_value){
        $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
        //新首页的审批条件                                  //老首页的时间范围
        //获取审批是否开启
        $Approvedeploy = getSys_Approvedeploy($tmpfocus->module_name);//deploy_value=0是开启 =1是关闭
        $approve_value_zh = '';
        //判断字段存在 再拼接时间条件
        if (is_array($Approvedeploy)&&$Approvedeploy['deploy_value']==0&&!empty($approve_value)&&isset($moduleAllPreseneceFields['approvestatus'])) {
            if(!empty($approve_value)){
                if($approve_value == 'all' || strpos($approve_value,'all') !== false){
                    //$query = ' and ifnull('.$tablename.'.approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                    //zxm 审批状态条件以设置为准,用户在界面勾选什么就判断什么
                    $approve_value_zh = ' ';
                }else{
                    $approve_value_zh = $approve_value;
                    $approve_value_zh = str_replace("unapproved",D_A_S_UNAPPROVED,$approve_value_zh);
                    $approve_value_zh = str_replace("approving",D_A_S_APPROVALOF,$approve_value_zh);
                    $approve_value_zh = str_replace("approved",D_A_S_APPROVED,$approve_value_zh);
                    $approve_value_zh = str_replace("rejected",D_A_S_REJECTED,$approve_value_zh);
                    $approve_value_zh = str_replace("dismissed",D_A_S_DISMISSED,$approve_value_zh);
                }
            }
        }

        return $approve_value_zh;
    }
    public function getViewid($customview){
        $module = $customview->customviewmodule;
        static $module_viewid_popup;
        $statickey = 'module_viewid'.$module;
        if(!empty($module_viewid_popup) && isset($module_viewid_popup[$statickey]))
            return $module_viewid_popup[$statickey];
        if($module=='Calendar'){
            //日程管理的数据分类 entitytype是events
            $viewid = $this->getViewIdByName('All', 'Events');//获取全部的视图ID
        }else{
            $viewid = $this->getViewIdByName('All', $module);//获取全部的视图ID
        }
        $module_viewid_popup[$statickey] = $viewid;
        return $viewid;
    }
    function getViewIdByName($viewname, $module) {
        global $adb;
        if (isset($viewname)) {
            $query = "select cvid from ld_customview where viewname=? and entitytype=? ";
            if($module=='Accounts'||$module=='Leads'){
                $query .= " and customcategory = 'ALLACCOUNT' ";
            }
            $query .= " order by cvid desc limit 1 ;";//有个客户不清楚为什么有两个All数据分类  取最新一条
            $cvresult = $adb->pquery($query, array($viewname, $module));

            $viewid = $adb->query_result($cvresult, 0, 'cvid');
            return $viewid;
        } else {
            return 0;
        }
    }

    //获取查询sql对象
    public function get_query_obj($module){
        global $current_user;

        if(isset($this->queryObjArr[$module]))
        {
            $this->queryobj=$this->queryObjArr[$module];

            return $this->queryObjArr[$module];
        }

        crm_load_class_file('cls_Report_CustomView','modules/lingdang/cls_Report');
        global $customView,$viewid; //查询语句排序需要
        $customview = $customView= new cls_Report_CustomView($module);
        $viewid = $this->getViewid($customview);
		//wym 显示列表宽度需要customview上有cvid属性
        $customview->cvid = $viewid;

        if(get_file_address($module,"ProductDetails"))
        {
            crm_load_class_file('cls_Report_Productdetail','modules/lingdang/cls_Report');
            $productDetails = cls_Report_Productdetail::getInstance($module);

           // if(!empty($this->selectcolumns))
             //   $productDetails->HeaderColumns[]=$this->selectcolumns;

            crm_load_class_file("cls_Report_ProductQueryGenerator",'modules/lingdang/cls_Report');
            $productviewobj=new ProductDetailViewInfo();
            $productviewobj->setCvid($viewid);
            $productDetails->setViewObj($productviewobj);
            $queryobj = new cls_Report_ProductQueryGenerator($module, $current_user,$customview,$productDetails);
            $queryobj->setDataRangeHomeBoardObj($this);
        }
        else if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            crm_load_class_file('cls_Report_TabDetails','modules/lingdang/cls_Report');
            $productDetails = cls_Report_TabDetails::getInstance($module);
            crm_load_class_file("cls_Report_TabDetailQueryGenerator",'modules/lingdang/cls_Report');

            $queryobj = new cls_Report_TabDetailQueryGenerator($module, $current_user,$customview,$productDetails);
            $queryobj->setDataRangeHomeBoardObj($this);
        }
        else if($module == 'Accounts' || $module == 'ServiceCharge'){
            crm_load_class_file('cls_Report_Productdetail','modules/lingdang/cls_Report');
            $productDetails = cls_Report_Productdetail::getInstance($module);
            crm_load_class_file("cls_Report_AccountsQueryGenerator",'modules/lingdang/cls_Report');
            if(empty($this->scopeModule))
            {
                $this->scopeModule=$module;
            }
            $productviewobj=new ProductDetailViewInfo();
            $productviewobj->setCvid($viewid);
            $productDetails->setViewObj($productviewobj);
            $queryobj = new cls_Report_AccountsQueryGenerator($module, $current_user,$customview,$productDetails,$this->scopeModule);
        }
        else if($module == 'Vendors'){
            crm_load_class_file('cls_Report_Productdetail','modules/lingdang/cls_Report');
            $productDetails = cls_Report_Productdetail::getInstance($module);
            crm_load_class_file("cls_Report_VendorsQueryGenerator",'modules/lingdang/cls_Report');
            $productviewobj=new ProductDetailViewInfo();
            $productviewobj->setCvid($viewid);
            $productDetails->setViewObj($productviewobj);
            $queryobj = new cls_Report_VendorsQueryGenerator($module, $current_user,$customview,$productDetails);
        }
        else if($module=='PublicAnnouncement'){
            crm_load_class_file('cls_Report_ReceiptQueryGenerator','modules/lingdang/cls_Report');
            $queryobj = new cls_Report_ReceiptQueryGenerator($module, $current_user,$customview);
        }
        else if($module=='Reminds'){
            crm_load_class_file('cls_Report_RemindsQueryGenerator','modules/lingdang/cls_Report');
            $queryobj = new cls_Report_RemindsQueryGenerator($module, $current_user,$customview);
        }else{
            crm_load_class_file('cls_Report_QueryGenerator','modules/lingdang/cls_Report');
            $queryobj = new cls_Report_QueryGenerator($module, $current_user,$customview);
            $queryobj->setDataRangeHomeBoardObj($this);
        }
       
        $queryobj->initForCustomViewById($viewid);
        //edit: xll 2024/02/01 BUG20240201-25 部分组件查询与多个模块相关时 $tmp_queryobj 需要以数组形式存储
        $this->queryObjArr[$module] = $queryobj;
        $this->queryobj=$this->queryObjArr[$module];
        return $queryobj;
    }


    //获取controller
    public function get_controller_obj ($module,$queryGenerator){
        global $adb,$current_user;
        if(get_file_address($module,"ProductDetails")||$module=='Accounts'||$module=='ServiceCharge'||$module=='Vendors')
        {
            crm_load_class_file('ReportProductDetail_ListController','modules/lingdang/cls_Report');
            $controllerobj = new ReportProductDetail_ListController($adb, $current_user, $queryGenerator);
        }else if(get_file_address($module,$module.'DetailFieldsHtml')){
            crm_load_class_file('ReportTabDetailListViewController','modules/lingdang/cls_Report');
            $controllerobj = new ReportTabDetailListViewController($adb, $current_user, $queryGenerator,$module);
        }else{
            crm_load_class_file('ReportListViewController','modules/lingdang/cls_Report');
            $controllerobj = new ReportListViewController($adb, $current_user, $queryGenerator);
        }
        return $controllerobj;
    }
    //重置queryobj的查询条件
    public function resetModuleQueryObj($module) {
        if(isset($this->queryObjArr[$module])) {
            $this->queryObjArr[$module]->reset();
            $this->queryObjArr[$module]->conditionals = array();
            $this->queryObjArr[$module]->groupInfo = '';
            $this->queryObjArr[$module]->conditionalWhere = '';
            $this->queryObjArr[$module]->conditionInstanceCount = 0;
        }
    }
}
?>