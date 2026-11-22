<?php
require_once(globalStatic::$root_directory."modules/Home/DataRangeHomeboard.php");
/**
 * 处理首页穿透的类
 */
class cls_getPenetrateModuleList
{
    public $penetrateModule;
    public $scopemodule;//穿透模块数据范围依赖模块
    public $DataRangeHomeboardObj;//条件子查询类

    public $datarangesql;//这个数组中的条件sql子查询是不带inner join 和on 的
    public $datarangesqlInnerJoin;//这个数组中的条件sql子查询是 带inner join 和on 的
    public $stuffinfo;//组件信息
    public $basicsearchArr;
    public $advancesearchArr;

    public $boardid;
    public $stuffid;
    public $boardstuffid;

    public $scopeType;
    public $selectuserid;
    public $search_date_custom_value='';
    public $approve_value;

    public $params;
    public $stufftype;
    public $daterange;
    public $popuptitle;
    public $penetrateModuleArr = [];
    public $curdatarangsql_str;
    public $curdatarangsql;
    public $datarangesqlArr = [];

    protected $sortColumnName;//排序字段
    protected $sortType = '';//排序类型

    public function __construct(){

    }
    public function setParams($params){
        $this->params = $params;

        $this->boardid = $params['boardid'];
        $this->boardstuffid = $params['boardstuffid'];
        $this->stufftype = $params['stufftype'];
        $this->stuffid = $params['stuffid'];

        $this->scopeType = $params['scopeType'];//数据范围类型
        $this->selectuserid = $params['selectuserid'];//选择的userid
        if(isset($params['search_date_custom_value'])&&!empty($params['search_date_custom_value']))
            $this->search_date_custom_value = $params['search_date_custom_value'];//时间范围的值

        $this->daterange = getHomeDateScope($this->search_date_custom_value);
        $this->approve_value = $params['approve_value'];//审批状态的值
        $this->penetrateModule = $params['penetrateModule'];//穿透模块

        //字段排序功能
        $this->sortType = $params['sortType'] ?? 'DEFAULT';
        $this->sortColumnName = $params['sortColumnName'] ?? '';

    }
    /**
     * @return void
     * 获取页面传过来的基本查找和高级查找的参数
     */
    public function getPageSearch(){
        //基本查找和高級查找
        $searchType = $_REQUEST['searchType'];

        $temparr_basic = [];
        $temparr_advance = [];
        if($searchType=='Basic'){
            $temparr_advance = [];
            $temparr_basic['searchtype'] = 'Basic';
            $temparr_basic['search_field'] = $_REQUEST['searchField'];
            $temparr_basic['search_text'] = $_REQUEST['searchText'];
        }
        if($searchType=='advance'){
            $temparr_basic = [];
            $temparr_advance['searchtype'] = 'advance';
            $temparr_advance['advft_criteria'] = stripslashes($_REQUEST['advance_demand']);
            $temparr_advance['advft_criteria_groups'] = stripslashes($_REQUEST['advance_demand_groups']);
        }
        $this->basicsearchArr = $temparr_basic;
        $this->advancesearchArr = $temparr_advance;
    }
    //删除时间条件 --有一些组件不需要根据首页筛选控制时间  是写死的时间
    public function deleteDaterange(){
        $this->daterange = "";
    }
    /**
     * @return array|mixed
     * @throws Exception
     * 获取组件基本信息  boardid stuffid stufftype datarangmodule
     */
    public function getStuffinfo (){
        global $adb,$languageType;
        $boardstuffid = $this->boardstuffid;

        $sql = "select * from ld_homeboard_plate_stuff a where boardstuffid=? ";
        $res = $adb->pquery($sql,array($boardstuffid));
        $info = $adb->query_result_rowdata($res,0);

        if($this->stufftype=='defaultstuff'){
            $modulesql = "select datarangmodule,stufftitle from ld_stuff where stuffid=?";
            $moduleres = $adb->pquery($modulesql,array($this->stuffid));
            $stufftitle = $adb->query_result($moduleres,0,'stufftitle');
            if(!is_array($info))
            {
                $info=[];
            }
            //穿透弹窗的标题
            if($info['stufftitle_zh']=='')
            {
                $info['stufftitle_zh']=getFixedLabel($stufftitle);

            }
            if($info['stufflabel_en']=='')
            {
                $info['stufflabel_en']=getFixedLabel($stufftitle);
            }
            if ($languageType == 'en') {
                $label = $info['stufflabel_en'];
            }else{
                $label = $info['stufflabel_en'];
            }
        }else{
            $modulesql = "select mainmodule as datarangmodule,report_name as stufftitle from ld_customreport where report_id=?";
            $moduleres = $adb->pquery($modulesql,array($this->stuffid));
            $label = $adb->query_result($moduleres,0,'stufftitle');
        }

        $info['datarangmodule'] = $adb->query_result($moduleres,0,'datarangmodule');
        $info['stufftitle'] = $adb->query_result($moduleres,0,'stufftitle');
        $info['stufftype'] = $this->stufftype;
        $info['stuffid'] = $this->stuffid;

        $this->stuffinfo = $info;//组件信息

        $this->popuptitle = $label;//穿透弹窗的标题
        
        if(!empty($this->stuffinfo['datarangmodule']))
            $this->penetrateModuleArr = explode(',',$this->stuffinfo['datarangmodule']);//穿透模块数组
        //判断模块激活
        foreach ($this->penetrateModuleArr as $k=>$modulename){
            if(!vtlib_isModuleActive($modulename)){
                unset($this->penetrateModuleArr[$k]);
            }
        }
        $this->penetrateModuleArr = array_values($this->penetrateModuleArr);

        $this->penetrateModule = empty($this->penetrateModule)?$this->penetrateModuleArr[0]:$this->penetrateModule;//穿透模块第一个 先考虑一个模块的穿透
        return $info;
    }
    public function getDatarangeObj(){
        $this->DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
    }
    //额外的高级查找条件  组装好的高级条件传过来
    public function setHighSearchArr($input){
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($input,$this->penetrateModule);//設置高級查找和基本查找的參數
    }
    //额外的条件 什么都没写   供子类使用
    public function setExtroCondition(){

    }

    /**
     * @param $boardstuffid
     * @param $scope
     * @param $senioruserid
     * @param $daterange
     * @param $appravevalue
     * @return mixed
     * 获取条件子sql
     */
    public function getDatarangesqlArr($boardstuffid){
        //$this->datarangesql 这个数组中的条件sql子查询是不带inner join 和on 的
        $daterange = $this->daterange;
        if($this->stuffid==25&&$this->stufftype=='defaultstuff'){
            //25 30天内及过期回款计划 不传时间条件
            $daterange = '';
        }



        $this->DataRangeHomeboardObj->setPenetrateModule($this->penetrateModule);

        $this->datarangesql = $this->DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$boardstuffid,$this->scopeType,$this->selectuserid,$daterange,$this->approve_value);

        $this->datarangesqlInnerJoin = $this->DataRangeHomeboardObj->datarangesqlArr;//这个数组中的条件sql子查询是带inner join 和on 的
        $this->curdatarangsql_str = $this->datarangesql[$this->penetrateModule]; //不带innerjoin 的
        $this->curdatarangsql=$this->datarangesqlInnerJoin['datarangesql_'.$this->penetrateModule];//带inner join 的
      
    }
    public function getSalesKitInfo()
    {
        
    }
    public function getScopeModule()
    {
        //数据范围依赖模块
        $scopeisrelated = $this->DataRangeHomeboardObj->filterArr['usercomponent_'.$this->penetrateModule]['isrelated'];
        $this->scopemodule = $scopeisrelated=='yes'?$this->DataRangeHomeboardObj->filterArr['usercomponent_' . $this->penetrateModule]['filtermodule']:$this->DataRangeHomeboardObj->frommodule;//未关联则默认数据范围模块为首页
        
    }
    public function getListView()
    {

        $this->getPageSearch();

        $this->getSalesKitInfo();//销售简报

        $this->getStuffinfo();

        $this->setOrderByTable();//设置排序

        $this->setExtroCondition();


        $this->getDatarangeObj();//设置数据范围类

        if(!empty($this->basicsearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->basicsearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

        $this->getScopeModule();
        $this->commonReturn();
    }
    public function commonReturn(){
        global $list_max_entries_per_page_new,$languageType;
        global $current_user,$adb,$currentModule;
        $smarty = new lingdangCRM_Smarty();

        $penetrateModule = $this->penetrateModule;
        //wym 230605 获取该模块列表最多条数
        $list_max_entries_per_page_new=getUsersettingByLabel($penetrateModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
        $list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

        $smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);//每一页最大条数

        $smarty->assign('penetrateModuleArr', $this->penetrateModuleArr);
        $smarty->assign('penetrateModule', $penetrateModule);

        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
        crm_load_class_file('Inventory','data');

        $focus = CRMEntity::getInstance($penetrateModule);//模块的类

        $smarty->assign('scopemodule',$this->scopemodule);
        $smarty->assign('MODULE', $penetrateModule);//模块

        $customView = CustomView::getInstance($penetrateModule);
        global $viewid;
        $viewid = $customView->getViewIdByName('All', $penetrateModule);//获取[全部]的视图ID
        $smarty->assign("VIEWNAME", getFixedLabel('ALL'));

        Crm_load_class_file("CommonView","modules/CustomView");
        $smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));//高级查找的时间下拉框
        //页面传过来的基本查找和高级查找条件的处理
        //crm_load_class_file('cls_Report_CustomView','modules/lingdang/cls_Report');
        // $queryGenerator = $this->DataRangeHomeboardObj->get_query_obj($penetrateModule);
        //edit: xll 2024/02/01 BUG20240201-25 部分组件查询与多个模块相关时 $tmp_queryobj 需要以数组形式存储
        if(!isset($this->DataRangeHomeboardObj->queryObjArr[$penetrateModule]))
            $this->DataRangeHomeboardObj->queryObjArr[$penetrateModule] = $this->DataRangeHomeboardObj->get_query_obj($penetrateModule);
        $queryGenerator=$this->DataRangeHomeboardObj->queryObjArr[$penetrateModule];

        $list_query = $queryGenerator->getQuery('',2);//获取SQL
        $list_query = explode('WHERE',$list_query)[0];//公告 SQL后面带了where 条件

        $list_query = $list_query.$this->curdatarangsql;//zxm 将首页看板设置的组件条件组装的子sql拼接上

        $page_list_query=$queryGenerator->getQuery('','groupby');//获取总条数的sql


        $page_list_query_arr = explode('WHERE',$page_list_query);//以WHERE分界分隔一下

        $page_list_query_arr[0] = $page_list_query_arr[0].$this->curdatarangsql;//前半部分 inner join 首页看板设置的组件条件组装的子sql

        $page_list_query = implode(' WHERE ',$page_list_query_arr);

        $queryGenerator->setParams($page_list_query);
        $queryRow_Count=$queryGenerator->getQueryRow_Count('','groupby');//获取本页条数的SQL

        $count_result = $adb->query($queryRow_Count);
        if(!empty($count_result))
            $noofrows = $adb->query_result($count_result,0,0);
        else
            $noofrows = null;
        $smarty->assign('NUMOFROWS',$noofrows);//本页条数

        $controller =  $this->DataRangeHomeboardObj->get_controller_obj($penetrateModule,$queryGenerator);
        $controller->havelistcheckbox = 'no';//不要多选列
        $controller->haveExistsOperation = 'no';//不要操作列
        $controller->haveoperation = false;//不要操作列 最后一列不要合并

        list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

        $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
        $start = ListViewSession::getRequestCurrentPage($penetrateModule, $noofrows, $viewid, $queryMode);

        $navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

        //分类默认排序设置
        $limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
        $list_query1=$list_query;
        $list_query=$list_query." inner join ( $page_list_query limit $limit_start_rec,$list_max_entries_per_page_new ) as 
        temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";

        $list_query=$list_query.$queryGenerator->getWhereClause();

        $list_query2=$queryGenerator->getWhereClause();
        list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);


        $list_result = $adb->pquery($list_query);

        if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
            $recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
        else
            $recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);

        $smarty->assign('recordListRange',$recordListRangeMsg);//共xx条

        $navigationOutput = $this->getTableNavigation($navigation_array, '', $penetrateModule, 'index', $viewid);
        $smarty->assign("NAVIGATION", $navigationOutput);

        global $global_picklist_colors_byvalue;
        $listview_header = $controller->getListViewHeader($focus,$penetrateModule,'',$sorder,$order_by);//表头 数组形式
        $listview_entries = $controller->getListViewEntries($focus,$penetrateModule,$list_result,$navigation_array);//表体数据  数组形式
        crm_load_class_file('cls_TotalList_KanBan','modules/lingdang/cls_Report');

        //获取主模块显示列的总列数
        $row_count=$queryGenerator->getMainColumnCount();
        $row_header = count($listview_header)+1;
        //基本查询列
        $listview_header_search_tmp=$controller->getBasicSearchFieldInfoList();
        $listview_header_search = array();

        $smarty->assign('LISTHEADER', $listview_header);


        //合并列
        $smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
        $smarty->assign('DEAILHTML', $listview_entries);
        $totalfldhtml = '';//合計小計
        // wym 列头需要模块和字段信息,没分录明细的取值
        $headerinfo['fieldname']=$controller->headername['fieldname'];
        $headerinfo['module']=$controller->headername['module'];
        //有明细的和没有明细的创建html不一样
        if(get_file_address($penetrateModule,"ProductDetails")
            ||get_file_address($penetrateModule,$penetrateModule.'DetailFieldsHtml')
            ||$penetrateModule=='Accounts'||$penetrateModule=='ServiceCharge'||$penetrateModule=='Vendors'){
            //有明細
            $tbodycontent = Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,'no',"yes",$controller);
            $smarty->assign('PROHTML',$tbodycontent);
            if(get_file_address($penetrateModule,"ProductDetails")||$penetrateModule=='Accounts'||$penetrateModule=='ServiceCharge'||$penetrateModule=='Vendors'){
                $listview_header_search = $queryGenerator->productDetails->getListViewHeaderSearch();
                // wym 列头需要模块和字段信息,有分录明细的取值
                $headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();
            }
            if(get_file_address($penetrateModule,$penetrateModule.'DetailFieldsHtml')){
                $listview_header_search = $queryGenerator->TabDetails->getBasicSearchFieldInfoList();
                // wym 列头需要模块和字段信息,有分录明细的取值
                $headerinfo=$queryGenerator->TabDetails->getListViewHeaderInfo();
            }
        }else{
            if(sizeof($listview_entries)<=0){
                //首页穿透 没有数据不要刷新按钮不要新建按钮的
                $tbodycontent = Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,'no',"yes",$controller);
            }else{
                //沒明細
                $tbodycontent = Inventory::createHTML($listview_entries,$penetrateModule,0,sizeof($listview_header)+1,array(),$controller,'no');
            }

            if($penetrateModule=='Accounts'){
                $listview_header_search = $queryGenerator->productDetails->getListViewHeaderSearch();
                // wym 列头需要模块和字段信息,有分录明细的取值
                $headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();
            }

            $smarty->assign('PROHTML',$tbodycontent);
        }
        if(empty($listview_header_search)){
            //不带分录的模块
            foreach($listview_header_search_tmp as $tmpfieldname=>$fieldlabel){
                $tmpfieldobj = $focus->fieldobj->getFieldInfoObjByKey("fieldname", $tmpfieldname);
                $tmptypeofdata = $tmpfieldobj->getTypeOfData();
                $tmptypeofdata_arr = explode('~',$tmptypeofdata);
                $tmpfieldinfo = $tmpfieldobj->getTableName().':'.$tmpfieldobj->getColumnName().':'.$tmpfieldname.':'.$this->penetrateModule.'_fieldlabel:'.$tmptypeofdata_arr[0];
                $listview_header_search[$tmpfieldinfo] = $fieldlabel;
            }
        }
        $smarty->assign('HEADERNAME',$headerinfo['fieldname']);
        $smarty->assign('HEADERMODULE',$headerinfo['module']);
        //小计合计行
        $clstotalkanbanobj=new cls_TotalList_KanBan($controller);
        $clstotalkanbanobj->setallTotal_pageList_query($this->curdatarangsql_str);

        $totalfldhtml = $clstotalkanbanobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
        $smarty->assign('TOTALFLDHTML',$totalfldhtml);//小计合计行
        $smarty->assign('SEARCHLISTHEADER',$listview_header_search);

        $fieldnames = $controller->getAdvancedSearchOptionString();

        setGLobalURLSmarty($smarty);//设置js,css等访问路径
        $smarty->assign("FIELDNAMES", $fieldnames);
        $smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
        $smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));
        $smarty->assign('IS_ADMIN', is_admin($current_user));

        /**
         * 每列宽度的信息
         * */
        $smarty->assign("FieldWidthSetting",ldcrm_json_encode($controller->getModuleViewFieldsWidth()));

        $widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$penetrateModule);

        $table_Hundred_percent_width=getModuleWidth($focus,$controller->table_Hundred_percent_width,$penetrateModule);
        $table_Hundred_percent_width=$controller->getListTotalWidth($table_Hundred_percent_width,0);
        $smarty->assign("TABLE_HUNDRED_PERCENT_WIDTH",$table_Hundred_percent_width);

        $smarty->assign("LAST_FIELD_WIDTH",$widthinfo[sizeof($widthinfo)-1]);
        $smarty->assign('LISTHEADERWIDTH',$widthinfo);

        $total_width=$controller->getListTotalWidth($widthinfo,0);
        $smarty->assign('TOTALWIDTH',$total_width);
        // @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
        $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
        $smarty->assign('current_language',$languageType);
        //wym 销售简报数据穿透,增加导出按钮,按钮根据当前列表权限显示
        $export_display = isPermitted($this->penetrateModule,"Export","");
        $smarty->assign('export_display',$export_display);

        //wym 231115 BUG0075528 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
        $displayinactiv=getUsersettingByLabel('Home','','Scope_DisplayInactiveuser')??'yes';
        $smarty->assign("displayinactiv",$displayinactiv);
        $inactive_userinfo=get_user_array(FALSE, "Inactive", "");
        $inactive_userid=array_keys($inactive_userinfo);
        $smarty->assign("inactiveuser",$inactive_userid);
        //xll 20221214 获取最近一次的基本搜索框字段选项
        $controller->getFieldStorage($smarty);

        if($_REQUEST['issearch']=='yes') {
            //$content = $tbodycontent.$totalfldhtml;
            //zxm 20240919 搜索和分页 增加返回表头
            if(get_file_address($this->penetrateModule, 'ProductDetails') == true || $this->penetrateModule == 'MarketSpread' || get_file_address($this->penetrateModule, 'DocumentsDetails') || get_file_address($this->penetrateModule, 'AttachmentDetails') || get_file_address($this->penetrateModule, 'VendorsDetails') || get_file_address($this->penetrateModule, 'ContactsDetails')){
                $content = $smarty->fetch('ProductListViewEntriesChuantou.tpl');
            }else{
                $content = $smarty->fetch('ListViewEntriesChuantou.tpl');
            }
            $pagehtml = '<div class="ld-flex-start" style="position: relative;">
                <div class="ld-pagenum-div">'.$recordListRangeMsg.'</div>
                '.$navigationOutput.'
            </div>';
        }else{
            $content = $smarty->fetch('ListViewChuantou.tpl');
            $pagehtml = '';
        }
        $currentpage = $navigation_array['current'];//当前是第几页
        $maxpagenum = $navigation_array['verylast'];//总共多少页

        //导出，对sql进行加密
        crm_load_class_file('cls_MyCRMcrypt',"Register");
        $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
        $export_data = [];
        $export_data['listheader']=array_values($listview_header_search);
        $export_data['page_list_query']=$cls_MyCRMcryptobj->encode($page_list_query);
        $export_data['list_query1']=$cls_MyCRMcryptobj->encode($list_query1);
        $export_data['list_query2']=$cls_MyCRMcryptobj->encode($list_query2);
        $export_data['order_by']=$cls_MyCRMcryptobj->encode($order_by);
        $export_data['sorder']=$cls_MyCRMcryptobj->encode($sorder);
        $export_data['exportnum_onestep']=$list_max_entries_per_page_new;

        $arr=[
            'content'=>$content,
            'pagehtml'=>$pagehtml,
            'currentpage'=>$currentpage,
            'maxpagenum'=>$maxpagenum,
            'total_width'=>$total_width,
            'penetrateModule'=>$penetrateModule,
            'scopemodule'=>$this->scopemodule,
            'title'=>$this->popuptitle,
            'export_data'=>$export_data,
            'viewid'=>$viewid,
        ];
        if ($_REQUEST['stufftype']=='workBriefReport'){
            $arr=array_merge($arr,['advance_demand'=>$_REQUEST['advance_demand'],'advance_demand_groups'=>$_REQUEST['advance_demand_groups']]);
        }
        ConvertTojsonString(1, $arr, 'success');
    }
    //移动端穿透的条件SQL
    public function getChuantouSql(){
        $this->getSalesKitInfo();//销售简报
        $this->getStuffinfo();
        $this->setExtroCondition();
        $this->getDatarangeObj();//设置数据范围类
        //只有高级查找 移动端
        if(!empty($this->advancesearchArr))
            $this->DataRangeHomeboardObj->setBasicAndHighsearchParam($this->advancesearchArr,$this->penetrateModule);//設置高級查找和基本查找的參數

        $this->datarangesqlArr = $this->getDatarangesqlArr($this->boardstuffid);

        $this->getScopeModule();
        return $this->curdatarangsql;
    }
    //新的分页函数  目前只在穿透弹窗中用到
    public function getTableNavigation($navigation_array)
    {
        $output = '<div class="ld-pagenum-div">
                    <div class="ld-pagenum-value outline bgwhite">
                    <div id="pagenum_show">'.$navigation_array['current']."/" . $navigation_array['verylast'].'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'.$navigation_array['verylast'].'</b></div>';
        $output .= '<div class="ld-pagenum-list" ><ol class="D_more_menua">';
        for($pnum=1;$pnum<=$navigation_array['verylast'];$pnum++){
            $selected = '';
            if($pnum==$navigation_array['current']){
                $selected = 'selected';
            }
            $output .= '<li name="pagenum_list" data-linum="'.$pnum.'" class="'.$selected.'"><a>'.$pnum."/" . $navigation_array['verylast'].'</a></li>';
        }
        $output .= '</ol></div></div>';
        $output .= '</div>';
        $output .= "";
        if (($navigation_array['prev']) != 0) {
            //zxm 20221207 上一页下一页样式优化
            $output .= '<div id="prevpage" class="ld-pagenum-div tip-items-list icon-left-active" data-tip="' . getFixedLabel('PREVPAGE') . '" data-direction="top" data-type="position"><b class="icon-pre-next"></b></div>';
        } else {
            $output .= '<div class="ld-pagenum-div icon-left-inactive"><b class="icon-pre-next cursorNotAllowed"></b></div>';
        }
        if (($navigation_array['next']) != 0) {
            $output .= '<div id="nextpage" class="ld-pagenum-div tip-items-list icon-right-active" data-tip="' . getFixedLabel('NEXTPAGE') . '" data-direction="top" data-type="position"><b class="icon-pre-next"></b></div>';
        } else {
            $output .= '<div class="ld-pagenum-div icon-right-inactive"><b class="icon-pre-next cursorNotAllowed"></b></div>';
        }
        if ($navigation_array['first'] == '')
            return '';
        else
            return $output;
    }

    /**
     * 以时间字段当作维度时，需要对其高级查找的值进行特殊处理，获取具体的时间区间
     * @param string $groupbytype 时间统计方式
     * @param string $input_value 前端传入的搜索值
     * @return string 起始时间和结束时间，以 , 连接
     */
    public function getStartAndEndDate($groupbytype,$input_value) {
        $compare_select = 'cur';
        if(isset($this->params['compare_select'])&&!empty($this->params['compare_select'])){
            $compare_select = $this->params['compare_select'];
        }
        crm_load_class_file('DateOperation','include');
        if($groupbytype=='byYear'){
            $year = $input_value;
            $dateinfo = DateOperation::get_thisyear($year);
        }else if($groupbytype=='byQuarter'){
            $timeArr = explode('第',$input_value);
            $year = $timeArr[0];
            $quarter = explode('季度',$timeArr[1])[0];
            if ($quarter < 1 || $quarter > 4) {
                return false; // 季度范围应在1到4之间
            }

            // 计算季度的起始月份和结束月份
            $startMonth = (($quarter - 1) * 3) + 1;
            $quarterStartDate = $year . '-' . $startMonth . '-01 00:00:00';
            $dateinfo = DateOperation::getQuarterDateInfo($quarterStartDate);

        }else if($groupbytype=='byMonth'){
            $date = $input_value.'-01';
            $dateinfo = DateOperation::getMonthDateInfo($date);
        }else if($groupbytype=='byWeek'){
            $timeArr = explode('-',$input_value);
            $year = $timeArr[0];
            $week = $timeArr[1];
            $firstDayOfYear = strtotime($year . '-01-01');
            // 计算第一周的起始时间
            $firstWeekStartDate = strtotime('+' . (1 - date('N', $firstDayOfYear)) . ' days', $firstDayOfYear);
            $weekStartDate = date('Y-m-d 00:00:00',strtotime('+' . (($week) * 7) . ' days', $firstWeekStartDate));
            $dateinfo = DateOperation::getWeekDateInfo($weekStartDate);

        }else if($groupbytype=='byDay'){
            $dateinfo = DateOperation::getDayDateInfo($input_value);
        }else{
            return '';
        }

        if($compare_select=='prev'){
            //环比
            $start = $dateinfo['huanbi_starttime'];
            $end = $dateinfo['huanbi_endtime'];
        }else if($compare_select=='prev_lastyear'&&$groupbytype!='byYear'){
            //同比  按年没有同比
            $start = $dateinfo['tongbi_starttime'];
            $end = $dateinfo['tongbi_endtime'];
        }else{
            $start = $dateinfo['starttime'];
            $end = $dateinfo['endtime'];
        }
        $timeString = $start.','.$end;

        return $timeString;
    }

    //提前排序所需要的连表orderby_tables
    public function setOrderByTable()
    {
        if (empty($this->penetrateModule)){
            return false;
        }
        $focus = CRMEntity::getInstance($this->penetrateModule);
        $sortType = empty($this->sortType) ? 'DEFAULT' : $this->sortType;
        $focus->setReportSortType($sortType,$this->sortColumnName);
//        $sortColumnName = explode('.',$this->sortColumnName)[1];
//        if (is_string($sortColumnName) && !empty($sortColumnName) && !empty($sortType) && $sortType != 'DEFAULT'){
//            $tablename = $focus->table_name;
//            $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$sortColumnName);
//            if (!empty($fieldinfo) && $fieldinfo->getTableName() == $tablename) {//字段是主表字段
//                $arr[$tablename] = $tablename;
//                if($sortColumnName==$focus->getSmownerColumName()){//XUQIU1001909 点击列头负责人字段进行排序时,排序字段为负责人姓名而不是负责人
//                    $arr['ld_users'] = 'ld_users';
//                }
//                $focus->orderby_tables = $arr;
//
//            }
//        }
        return true;
    }


}