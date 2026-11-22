<?php

/**
 * 说明:/*
 * viewname 数据分类
 * SearchScope 查看范围
 * accounttype 是否公海
 * */
class cls_ListViewWX
{
    public $focus;
    public $fieldobj;
    public $module;
    public $jsonArr;
    public $lastmodifiedArr = array('unlimit' => '不限', 'syesterday' => '昨天', 'today' => '今天', 'thisweek' => '本周', 'lastweek' => '上周'
    , 'thismonth' => '本月', 'lastmonth' => '上月');
    public $customview;
    public $viewid;
    protected $mark_tab_main; //我的标签页   0 初始值 1我的标签页,微信我的全部页签数据分类特殊写定为’全部‘
    protected $mixedDisplayColumns;
    protected $page_list_query;
    protected $list_query;
    public $relatedModuleActions;//模块明细界面关联信息序时簿头部按钮
    protected $output_style;//输出样式特殊控制 related_listview:关联序时簿，无筛选
    public $custom_fields;//列头字段
    public $search_custom_fields;//可搜索字段
    public $obj_query;
    public $order_by;//editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 14:40
    public $report_date_field;

    public $queryWithDetail = '';//sql语句是否带分录表连接
    public $relatedmodule;

    public $relate_create_where_sql = '';

    public function __construct($module)
    {
        $this->focus = cls_Instance::get_module_Instance($module);
        $this->fieldobj = $this->focus->fieldobj;
        $this->module = $module;
        $this->mark_tab_main = 0;
        $this->lastmodifiedArr = array('unlimit' => getFixedLabel('UNLIMITED'), 'syesterday' => getFixedLabel('syesterday'), 'today' => getFixedLabel('today'), 'thisweek' => getFixedLabel('thisweek'), 'lastweek' => getFixedLabel('lastweek')
        , 'thismonth' => getFixedLabel('thismonth'), 'lastmonth' => getFixedLabel('lastmonth'));
    }

    protected function getModuleRelatedList(){
        $showmodules = array();
        $showcreatemodules = array();
        $detailComFun = crm_load_class_obj('cls_DetailView_CommonFun', 'WeiXinApp/include');
        //判断存在相关信息的模块有值，则返回模块数组给后台，让后台留相关页签位置，不去读相关信息的具体内容。
        $wxshowmodules = $detailComFun->wx_presenceModules($this->module);
        $pcshowmodules = isPresentRelatedLists($this->module);
        $relatecustomreports=Detail_Edit_View::getRelatedCustomReport($this->module);
        //$wxpcmodules = array_intersect($wxshowmodules,$pcshowmodules);
        require_once(globalStatic::$root_directory . 'include/utils/DetailViewUtils.php');

        foreach ($pcshowmodules as $relatedid => $showmodule) {
            if (in_array($showmodule, array('ViewHistory', 'ChangeView', 'AccountHierarchy', 'Print','Singin'))) continue;
            if(array_key_exists($relatedid,$relatecustomreports))
            {
                //自定义报表
                $default_report=0;
                if($relatecustomreports[$relatedid]['related_coltable']=='crmlink')
                {
                    $default_report=1;
                }
                if($relatecustomreports[$relatedid]['type']=='datacategory_templatelink')
                {
                    $url='CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key='.$relatecustomreports[$relatedid]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$relatedid]['label'];


                }
                else
                {
                    $url='CustomReport/JsReport/index.php?crm_report_key='.$relatecustomreports[$relatedid]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$relatedid]['label'];
                }
                $showcreatemodules[]=array('id' => $relatedid
                , 'name' => $relatecustomreports[$relatedid]['label'],'type'=>'relatecustomreport'
                ,'module'=>$url);
                continue;

            }
            if (in_array($showmodule, $wxshowmodules)) {
                $relationInfo = getRelatedListInfoById($relatedid, $this->module);
                $showmodules[] = $showmodule;
                if ($showmodule == 'QuotesChange') continue;
                if (isPermitted($showmodule, 'Create', '') == 'yes' && stripos($relationInfo['actions'], 'add') !== false) {
                    $cancreate = $this->specialDisplayCreatebutton($showmodule);
                    if ($cancreate == 0) continue;
                    $transname = getTransTab($showmodule);
                    if ($this->module == 'SalesOrder' && $showmodule == 'SalesOrder') $transname = getFixedLabel('CHANGEORDER');
                    $showcreatemodules[] = array('id' => $relatedid, 'module' => $showmodule, 'name' => $transname,'type'=>'');
                }
            }
        }
        if (!empty($showmodules)) {
            $this->jsonArr['relatedList'] = reset($showmodules);
            //dion 20200527 增加两个快速创建
            if(!empty($showcreatemodules)){
                $relate_count = 2;
                if(sizeof($showcreatemodules) < 2){
                    $relate_count = sizeof($showcreatemodules);
                }
                for ($i = 0; $i < $relate_count; $i++) {
                    $relate_quick[] = $showcreatemodules[$i];
                }
                $this->jsonArr['relatedCreateListQuick'] = $relate_quick;
            }
        }
    }
    protected function specialDisplayCreatebutton($showmodule)
    {
        $is_display = 1;
        if ($this->module == 'PaymentPlan' && $showmodule == 'CashBill') {

            if ($this->focus->column_fields['paymentstatus'] == '已收') {
                $is_display = 0;
            }
        }
        //付款计划如果已付则隐藏新建按钮
        if ($this->module == 'SendPayment' && $showmodule == 'SendCashBill') {
            if ($this->focus->column_fields['cpstatus'] == '已付') {
                $is_display = 0;
            }
        }
        return $is_display;
    }
    public function addUsersSearchContent($querygenerator,$plateform){
        
        $queryFun = crm_load_class_obj('QueryGenerator_FunctionsMC','appCommon/include/QueryGenerator');
        $queryFun->addsearchContent($querygenerator,$plateform);
       
        
    }
    //editor:gyq_82 reason:附件客户优化，增加筛选 2018/10/12 10:58 
    public function get_page_query($showtype,$isSingle){
        global  $current_user,$weixin_user,$adb;
        //树形结构 查询
        if(!empty($_REQUEST['moduletreejson'])){
            $_REQUEST['isshowModuleListTree'] = 'yes';
            $moduletree_arr = ldcrm_json_decode($_REQUEST['moduletreejson']);
            $_SESSION['module_list_tree'][$this->module]['list'] = $moduletree_arr;
        }
        //zxm 1225 销售助手跳转条件
        if($_REQUEST['report_name']=="SalesAssistant") {
            $_REQUEST['filter']['SearchScope'] = "SmOwner_Search_Me";//负责人是我的
            $_REQUEST['method'] = 'getXiaoshouZhushouHighSearch';
            if($_REQUEST['is_list'] != "yes"){
                require globalStatic::$root_directory."WeiXinApp/modules/Approve/ApproveFunctions.php";
                $ApproveFunctionsObj = new cls_ApproveFunctions();
                $ApproveFunctionsObj->getXiaoshouZhushouHighSearch();
            }

        }
        //zxm 2020-0114 关键视图的人员范围
        if($_REQUEST['report_name']=="keyViews") {
            $_REQUEST['filter']['SearchScope'] = "SmOwner_Search_All";
        }
        if(!empty($_REQUEST['related_module'])){
            $this->relatedmodule = $_REQUEST['related_module'];
            /*单据明细相关信息列表，根据单据数据分类“全部”显示数据，不根据PC端相关信息列表当前选择的数据分类显示*/
            $this->set_customview_all();
            //edit:can 20221114 586066 企业微信移动端，维保管理->送货单，点开送货单的相关页签，显示有2条维保记录，点进维保记录后，显示空。例如编号：SHD00013。 
            $_REQUEST['viewid']=$_REQUEST['viewname'];
            
        }

        $customview_obj = $this->init_custom();

        crm_load_class_file('QueryGeneratorWX', 'WeiXinApp/QueryGenerator');
        if($_REQUEST['dashboard']=='yes'){
            if($_REQUEST['selectuserid']=='all'){
                //edit:can 20210813 47452: （http://39.101.140.149:85/crm/ [^]）客户问题（金晖兆隆）登录shihuitao账号微信小程序首页中，销售龙虎榜和销售简报中的数据显示没有或少数据
            ///说明	登陆地址：http://39.101.140.149:85/crm/ [^]
                setSearchAllAccount();//设置查询所有的客户（包括公海客户）
                // $_REQUEST['SearchScope']='SmOwner_Search_All';
                // diony 2020.12.16 报表穿透，数据范围根据【移动端报表】查找
                $module_users = getCurSmOwnerSearchScope('MobileReport');
                $selectuid = implode(',', array_keys($module_users['UserCombo']));
                $_REQUEST['senioruserid'] = $selectuid;
            }else{
                $_REQUEST['senioruserid']=$_REQUEST['selectuserid'];
            }
         }
        $this->obj_query = $querygenerator = QueryGeneratorWX::getInstance($this->module, $current_user,$customview_obj,'',$isSingle);

        $querygenerator->initForCustomViewById($this->viewid);
        $_REQUEST['initForCustomViewById'] = true;//避免后面方法中重复调用该方法
        $this->custom_fields = $querygenerator->customViewFields;

        $this->getSearchField();//获取列表搜索字段


		$searchtype = $_REQUEST['searchtype'];
        //头部搜索 editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/29 16:47
        if (!empty($_REQUEST['searchcontent']) || !empty($_REQUEST['session_search_criteria'])) {
           // $queryFun = crm_load_class_obj('QueryGenerator_FunctionsMC','appCommon/include/QueryGenerator');
            //$queryFun->addsearchContent($querygenerator,'weixin');
            //销售简报的穿透  模糊搜索先不调用获取高级查找数组 因为简报有个参数叫searchtype=now或者last会被重写
            if($_REQUEST['reportname']!='Saleskit')
                $this->addUsersSearchContent($querygenerator,'weixin');
            
        }
        if($_REQUEST['report_name']=="SalesAssistant"&&$_REQUEST['salesassistant_name']=="ServiceContracts") {
            $_REQUEST['filter']['SearchScope'] = "SmOwner_Search_Me";//负责人是我的
            $advft_criterias[]= array(
                'groupid' =>1,
                'columnname' => "ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:products_服务到期日:D",
                'comparator' => 'bw',
                'value' => $_REQUEST['servicecontracts_end_date_bw'],
                'columncondition' => ' ',
            );
            $_REQUEST['advft_criteria'] = json_encode($advft_criterias);
            $_REQUEST['advft_criteria_groups'] = '';
            $_REQUEST['searchtype'] = 'advance';
            $querygenerator->addUserSearchConditions($_REQUEST);
        }

		//chj,2022/6/20,reason:ID1000927/页面设置，选择源单增加其他条件，可设置选择源单过滤条件
		if(!empty($_REQUEST['fieldname']) && !empty($_REQUEST['frommodule']) && !empty($_REQUEST['selectmodule'])){
			$fieldinfo=$this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$_REQUEST['fieldname']);
			if(!empty($fieldinfo)){
				if($fieldinfo->getBigType() == 'selectsource'){
					$tabid = getTabid($_REQUEST['frommodule']);
					$option_tabid = getTabid($_REQUEST['selectmodule']);
					if ($tabid > 0) {
						global $adb;
						$query = "SELECT effectivecondition FROM ld_option_module WHERE tabid=? AND option_tabid=? AND presence=0 LIMIT 1";
						$result = $adb->pquery($query,array($tabid, $option_tabid));
						$rows = $adb->num_rows($result);
						if($rows > 0){
							$effectivecondition = $adb->query_result($result,0,'effectivecondition');
							if(!empty($effectivecondition)){
								$effectivecondition = html_entity_decode($effectivecondition);
								$effectivecondition_arr = json_decode($effectivecondition,true);
								//自动带出所选源单的分录明细   设置控制生效条件 
								if(!empty($effectivecondition_arr['withdetail'])){
									$_REQUEST['advft_criteria'] = $effectivecondition_arr['withdetail']['advft_criteria'];
									$_REQUEST['advft_criteria_groups'] = $effectivecondition_arr['withdetail']['advft_criteria_groups'];
									$_REQUEST['searchtype'] = 'advance';
									$querygenerator->addUserSearchConditions($_REQUEST);
								}
								//s审批要求 其他设置
								if(!empty($effectivecondition_arr['approve'])){
									$_REQUEST['advft_criteria'] = $effectivecondition_arr['approve']['advft_criteria'];
									$_REQUEST['advft_criteria_groups'] = $effectivecondition_arr['approve']['advft_criteria_groups'];
									$_REQUEST['searchtype'] = 'advance';
									$querygenerator->addUserSearchConditions($_REQUEST);
								}
							}
						}

					}
				}
			}
		}
        if($_REQUEST['dashboard']=='yes'){
            $advft_criterias=array();
            if($_REQUEST['report_name']=='salesdragontiger'){
                
                //销售龙虎榜
                $ranking_module=$this->module;
                $dashboard_focus=$querygenerator->moduleobj;
                $tmp_fieldlabel=$dashboard_focus->fieldobj->getFieldInfoBykeyValue("columnname","createdtime",'fieldlabel');
                $tmp_tablename=$dashboard_focus->table_name;
                if($_REQUEST['search_date_custom_value']!='all')
                {
                    //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
                    if($_REQUEST['search_date_custom_value']!='custom') {
                        if ($ranking_module == "ServiceContracts") {
                            //ServiceContracts的创建时间的columnname特殊
                            $advft_criterias[] = array(
                                'groupid' => 1,
                                'columnname' => "$tmp_tablename:createdtime:" . $ranking_module . "createdtime:" . $ranking_module . "_" . $tmp_fieldlabel . ":DT",
//                        'columnname'=>"ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_创建时间:DT",
                                'comparator' => $_REQUEST['search_date_custom_value'],
                                'value' => '',
                                'columncondition' => '',
                            );
                        } else {
                            $advft_criterias[] = array(
                                'groupid' => 1,
                                'columnname' => "$tmp_tablename:createdtime:createdtime:" . $ranking_module . "_" . $tmp_fieldlabel . ":DT",
                                'comparator' => $_REQUEST['search_date_custom_value'],
                                'value' => '',
                                'columncondition' => '',
                            );
                        }
                    }else{
                        $time_arr = explode('~',$_REQUEST['custom_data']);
                        if ($ranking_module == "ServiceContracts") {
                            //ServiceContracts的创建时间的columnname特殊
                            $advft_criterias[] = array(
                                'groupid' => 1,
                                'columnname' => "$tmp_tablename:createdtime:" . $ranking_module . "createdtime:" . $ranking_module . "_" . $tmp_fieldlabel . ":DT",
//                        'columnname'=>"ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_创建时间:DT",
                                'comparator' => 'bw',
                                'value' => $time_arr[0].' 00:00:00,'.$time_arr[1].' 23:59:59',
                                'columncondition' => '',
                            );
                        } else {
                            $advft_criterias[] = array(
                                'groupid' => 1,
                                'columnname' => "$tmp_tablename:createdtime:createdtime:" . $ranking_module . "_" . $tmp_fieldlabel . ":DT",
                                'comparator' => 'bw',
                                'value' => $time_arr[0].' 00:00:00,'.$time_arr[1].' 23:59:59',
                                'columncondition' => '',
                            );
                        }
                    }
                   $_REQUEST['advft_criteria'] = json_encode($advft_criterias);
                	$_REQUEST['advft_criteria_groups'] = '';
                	$_REQUEST['searchtype'] = 'advance';
                }
            }
            else if($_REQUEST['report_name']=='RegionalStatistics'){
                //zxm 2020-1119 大树科技 区域统计客户列表 bill_city 类型zhuce注册 shouxin授信 rongzi融资
                //城市
                if($_REQUEST['rsbg_city'] != 'all'){
                    if($_REQUEST['rsbg_city'] == '无') {
                        $bill_city = "null";
                    }else{
                        $bill_city = $_REQUEST['rsbg_city'];
                    }
                    $advft_criterias[]= array(
                        'groupid' =>1,
                        'columnname' => "ld_account:bill_city:bill_city:Accounts_实际经营市:V",
                        'comparator' => 'e',//等于
                        'value' => $bill_city,
                        'columncondition' => '  ',

                    );
                }
                //类型
                $rsbg_type = $_REQUEST['rsbg_type'];
                if($_REQUEST['rsbg_type']!='zhuce'&&!empty($rsbg_type)) {
                    if ($rsbg_type == "shouxin") {
                        $columnnamestr = "ld_account:platform_amt:platform_amt:Accounts_授信额度:N";
                    }else{
                        $columnnamestr = "ld_account:ths_fnc_amt:ths_fnc_amt:Accounts_融资额度:N";
                    }
                    $advft_criterias[]= array(
                        'groupid' =>1,
                        'columnname' => $columnnamestr,
                        'comparator' => 'g',//大于
                        'value' => 0,
                        'columncondition' => '  ',

                    );
                }
                if(!empty($advft_criterias)){
                    if(count($advft_criterias) == 2){
                        //两个条件需要加and
                        $advft_criterias[0]['columncondition']=' and ';
                    }
                    $_REQUEST['advft_criteria'] = json_encode($advft_criterias);
                    $_REQUEST['advft_criteria_groups'] = '';
                    $_REQUEST['searchtype'] = 'advance';
                }
            }
            else if(strtolower($_REQUEST['report_name'])=="salesfunnel"){
                //这里是公共的销售简报的穿透--zxm 20230807 简报自定义之后 需要重新穿透方法
                require_once(globalStatic::$root_directory.'include/utils/HomeReport.php');
                //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
                if($_REQUEST['search_date_custom_value']=='custom'){
                    $time_arr = $_REQUEST['custom_data'];
                }else{
                    $time_arr = $_REQUEST['search_date_custom_value'];
                }
                $ChuantouSql = getSalesFunnelChuantouSql($time_arr);
            }
            else if($_REQUEST['report_name']=="TD_PotentialsFunnel"){
                //天地特殊开发 销售漏斗（含目标）
                //这里是公共的销售简报的穿透--zxm 20230807 简报自定义之后 需要重新穿透方法
                require_once(globalStatic::$root_directory.'include/utils/HomeReport.php');
                //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
                if($_REQUEST['search_date_custom_value']=='custom'){
                    $time_arr = $_REQUEST['custom_data'];
                }else{
                    $time_arr = $_REQUEST['search_date_custom_value'];
                }
                $ChuantouSql = getTD_PotentialsFunnelChuantouSql($time_arr);
            }
            else if($_REQUEST['report_name']=='contractkit'){
                //合同简报
                $dashboard_focus=$querygenerator->moduleobj;
                $ranking_module=$dashboard_focus->module_name;

                $scopemodule = $ranking_module;//先写死吧 没办法了  合同的数据范围 跟传过来的数据范围 做一个交集
                crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
                $ModuleScopeObj = new cls_ScopOfAuthority($adb, $scopemodule);
                $ModuleScopeObj->setParams('SmOwner_Search_All', '');
                $SearchUserId_scopemodule = $ModuleScopeObj->getCurUserScopeIds();
                $tmpsmownercolumnname = $dashboard_focus->getSmownerColumName();
                $tmp_fieldfieldname=$dashboard_focus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpsmownercolumnname,'fieldname');
                $advft_criterias[]= array(
                    'groupid' =>1,
                    'columnname' => $dashboard_focus->table_name.":".$tmpsmownercolumnname.":".$tmp_fieldfieldname.":".$ranking_module."_fieldlabel:V",
                    'comparator' =>'findinset',
                    'value' => $SearchUserId_scopemodule,
                    'columncondition' => ' and ',

                );

                $tmp_tablename=$dashboard_focus->table_name;
                $search_date_columnname='createdtime';

                 if($_REQUEST['second_para']!=''){
                     if(!empty($this->report_date_field)){
                         //zxm 20240102 合同简报 合同数量穿透时间字段跟传过来的参数有关
                         $search_date_columnname = $this->report_date_field;
                     }
                    if($ranking_module=='SalesOrder'){
                        
                         $tmp_fieldlabel=$dashboard_focus->fieldobj->getFieldInfoBykeyValue("columnname",'sostatus','fieldlabel');
                         
                        $advft_criterias[]= array(
                				'groupid' =>1,
                				'columnname' => "ld_salesOrder:sostatus:sostatus:SalesOrder_$tmp_fieldlabel:V",
                				'comparator' =>'n',
                				'value' => '已作废',
                				'columncondition' => ' and ',
                				
                			);


                    }
                 }
                 $tmp_fieldlabel=$dashboard_focus->fieldobj->getFieldInfoBykeyValue("columnname",$search_date_columnname,'fieldlabel');
                if($_REQUEST['search_date_custom_value']!='all')
                {

                    $typeofdata=$dashboard_focus->fieldobj->getFieldInfoBykeyValue("columnname",$search_date_columnname,'typeofdata');
                    $typeofdatas=explode("~",$typeofdata);
                    $tmptypeofdata=$typeofdatas[0];
                    //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
                    if($_REQUEST['search_date_custom_value']=='custom'){
                        $time_arr = $_REQUEST['custom_data'];
                        $advft_criterias[]= array(
                            'groupid' =>1,
                            'columnname' => "$tmp_tablename:$search_date_columnname:$search_date_columnname:$ranking_module_$tmp_fieldlabel:$tmptypeofdata",
                            'comparator' => 'bw',
                            'value' => str_replace('~',',',$time_arr),
                            'columncondition' => '',
                        );
                    }else{
                        $advft_criterias[]= array(
                            'groupid' =>1,
                            'columnname' => "$tmp_tablename:$search_date_columnname:$search_date_columnname:$ranking_module_$tmp_fieldlabel:$tmptypeofdata",
                            'comparator' => 'bw',
                            'value' => getHomeDateScope($_REQUEST['search_date_custom_value'],'no','comparatorvalue'),//BUG20240902-13  	企业微信移动端，功能--报表--合同简报，查看范围全部-本年，点进入穿透列表没有数据;
                            'columncondition' => '',
                        );
                    }
                }
                
                 $_REQUEST['advft_criteria'] = json_encode($advft_criterias);
               	$_REQUEST['advft_criteria_groups'] = '';
               	$_REQUEST['searchtype'] = 'advance';
            }
            else
            {
                //销售简报
                $searchmodule = $_REQUEST['searchmodule'];
                if($_REQUEST['search_date_custom_value']!='all'){
                    //zxm 2021-0113【移动端首页界面，时间查询范围中增加“自定义时间”选项】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000289
                    if($_REQUEST['search_date_custom_value']=='custom'){
                        $time_arr = $_REQUEST['custom_data'];
                    }else{
                        $time_arr = $_REQUEST['search_date_custom_value'];
                    }
                    //zxm 2020-1203 誉帆 营销报告穿透 report_name=‘Yufan_MarketingReport’时才会传reportlabel值
                    $reportlabel = $_REQUEST['reportlabel'];
                    if(!empty($reportlabel)&&($_REQUEST['report_name']=='Yufan_MarketingReport'||$_REQUEST['report_name']=='Yufan_ProjectReport')){
                        $version = getVersionInfo();
                        if($version['trade'] == 'construction'){
                            include(globalStatic::$root_directory.'modules/Home/CustomMade/ConstructionUtils.php');
                            $ConstructionUtilsObj = new ConstructionUtils();
                            $advft_criterias = $ConstructionUtilsObj->setMarketingReportSession($time_arr, $reportlabel);
                        }else{
                            include(globalStatic::$root_directory.'modules/Home/CustomMade/YufanUtils.php');
                            $YufanUtilsObj = new YufanUtils();
                            $advft_criterias = $YufanUtilsObj->setMarketingReportSession($time_arr, $reportlabel);
                        }
                        $advft_criterias=$advft_criterias[$reportlabel];
                    }else if(!empty($reportlabel)&&$_REQUEST['report_name']=='Yichong_Saleskit'){
                        //zxm 2021-0303 易冲 销售简报报告穿透 report_name=‘Yichong_Saleskit’时 传reportlabel值
                        include(globalStatic::$root_directory.'modules/Home/CustomMade/YichongUtils.php');
                        $YichongUtilsObj = new YichongUtils();
                        $advft_criterias = $YichongUtilsObj->setMarketingReportSession($time_arr, $reportlabel);
                        if(isset($advft_criterias['advft_criteria_groups'])){
                            $advft_criteria_groups_value = $advft_criterias['advft_criteria_groups'];
                        }
                        $advft_criterias=$advft_criterias[$reportlabel];
                    }else{
                        //这里是公共的销售简报的穿透--zxm 20230807 简报自定义之后 需要重新穿透方法
                        require_once(globalStatic::$root_directory.'include/utils/HomeReport.php');
                        if($_REQUEST['report_name']=='Saleskit'||$_REQUEST['report_name']=='saleskit'){
                            $ChuantouSql = getSalesKitChuantouSql($time_arr,$querygenerator);
                        }else if($_REQUEST['report_name']=='DataDragonTigerList'||$_REQUEST['penetrate_class']=='cls_getPenetrateModuleList'){
                            $ChuantouSql = getHomeboardChuantouSql($time_arr);
                        }
                    }

                    $modules=explode(",",$searchmodule);
                    foreach($modules as $tmpmodule)
                	{
                       if(is_array($advft_criterias[$tmpmodule]))
                            $advft_criterias[$tmpmodule][sizeof($advft_criterias[$tmpmodule])-1]['columncondition']='';
                	    $_REQUEST['advft_criteria'] = json_encode($advft_criterias[$tmpmodule]);
                        $_REQUEST['advft_criteria_groups'] = empty($advft_criteria_groups_value)?'':$advft_criteria_groups_value;
                    	$_REQUEST['searchtype'] = 'advance';

                        break;
                	}
               }else{
                    //这里是公共的销售简报的穿透--zxm 20230807 简报自定义之后 需要重新穿透方法
                    require_once(globalStatic::$root_directory.'include/utils/HomeReport.php');
                    if($_REQUEST['report_name']=='Saleskit'||$_REQUEST['report_name']=='saleskit'){
                        $ChuantouSql = getSalesKitChuantouSql('all',$querygenerator);
                    }else if($_REQUEST['report_name']=='DataDragonTigerList'||$_REQUEST['penetrate_class']=='cls_getPenetrateModuleList'){
                        $ChuantouSql = getHomeboardChuantouSql('all');
                    }
                }
                
            }
            //移动端报表穿透增加审批条件
            if(isset($_REQUEST['dashboard_approve_value']) && !empty($_REQUEST['dashboard_approve_value']) && $_REQUEST['dashboard_approve_value'] != 'all'){
                $sys_approve= getSys_Approvedeploy($this->module);
                $focus = $this->focus;
                $approvevalue_arr = explode(',',$_REQUEST['dashboard_approve_value']);
                $approvestatus_arr = array();
                foreach($approvevalue_arr as $tmp_value){
                    switch($tmp_value){
                        case 'unapproved':$approvestatus = D_A_S_UNAPPROVED;break;
                        case 'approving':$approvestatus = D_A_S_APPROVALOF;break;
                        case 'approved':$approvestatus = D_A_S_APPROVED;break;
                        case 'rejected':$approvestatus = D_A_S_REJECTED;break;
                        case 'dismissed':$approvestatus = D_A_S_DISMISSED;break;
                        default:$approvestatus = '';break;
                    }
                    if(!empty($approvestatus)){
                        $approvestatus_arr[] = $approvestatus;
                    }
                }
                //对应模块需要开启审批参数,并启用字段
                if(sizeof($approvestatus_arr)>0 && $sys_approve['deploy_value']==0 && isset($focus->column_fields['approvestatus'])){
                    $old_advft_criterias_json = $_REQUEST['advft_criteria'];
                    $old_advft_criteria_groups_json = $_REQUEST['advft_criteria_groups'];
                    
                    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname','approvestatus');
                    if(!empty($fieldinfo)){
                        $com_columnname = $fieldinfo->getTableName().":".$fieldinfo->getColumnName().":".$fieldinfo->getFieldName().":".$this->module."_".$fieldinfo->getFieldLabelKey().":V";
                        //如果报表穿透带出了高级查询条件
                        if(!empty($old_advft_criterias_json)){
                            $groupid_arr= array();
                            $max_groupid = 0;
                            $new_advft_criteria_groups = array();
                            $new_advft_criteria_groups[0] = null;
                            //在原有的查询条件中添加
                            $old_advft_criterias_arr = json_decode($old_advft_criterias_json,true);
                            $old_advft_criteria_groups_arr = json_decode($old_advft_criteria_groups_json,true);
                            foreach($old_advft_criterias_arr as $tmp_advftinfo){
                                $tmp_groupid = $tmp_advftinfo['groupid'];
                                if(!in_array($tmp_groupid,$groupid_arr)){
                                    $groupid_arr[] = $tmp_groupid;
                                    if($tmp_groupid>$max_groupid){
                                        $max_groupid = $tmp_groupid;
                                    }
                                    $new_advft_criteria_groups[$tmp_groupid] = $old_advft_criteria_groups_arr[$tmp_groupid];
                                }
                            }
                            $newgroupid = $max_groupid+1;

                            $new_advft_criteria_groups[$max_groupid]['groupcondition'] = 'and';
                            $new_advft_criteria_groups[$newgroupid]['groupcondition'] = '';
                            $new_advft_criterias_arr = $old_advft_criterias_arr;
                        }else{
                            //没有原条件时，只添加审批状态
                            $new_advft_criteria_groups = array(null,array('groupcondition'=>''));
                            $new_advft_criterias_arr = array();
                            $newgroupid = 1;
                        }
                        
                        $length = sizeof($approvestatus_arr);
                        for($tmp_index = 0;$tmp_index<$length;$tmp_index++){
                            $tmp_value = $approvestatus_arr[$tmp_index];
                            $condition = 'or';
                            if($tmp_index == $length-1){
                                $condition = '';
                            }
                            $tmp_searchinfo = array(
                                'groupid' =>$newgroupid,
                                'columnname' => $com_columnname,
                                'comparator' => 'e',
                                'value' => $tmp_value,
                                'columncondition' => $condition,
                            );
                            $new_advft_criterias_arr[] = $tmp_searchinfo;
                        }
                        $_REQUEST['advft_criteria'] = json_encode($new_advft_criterias_arr);
                        $_REQUEST['advft_criteria_groups'] = json_encode($new_advft_criteria_groups);
                    }
                }
            }
            
        	$querygenerator->addUserSearchConditions($_REQUEST);
        }

        //高级查询条件
		if(!empty($_REQUEST['high_search'])){
			$search = array();
			foreach($_REQUEST['high_search'] as $key => $search_info){
				$columnname = $search_info['value'];
				$search_value = $search_info['m_content'];
				if(!empty($search_value)){
					$search_value2 = $search_info['m_content_end'];
					$columncondition = 'and';
					if(empty($search_value2)){
						$comparator = 'c';
					}else{
						$comparator = 'bw';
						$search_value = $search_value .','.$search_value2;
					}
					$search[] = array(
						'groupid' => 1,
						'columnname' => $columnname,
						'comparator' => $comparator,
						'value' => $search_value,
						'columncondition' => $columncondition
					);
				}
			}
			if(!empty($search)){
				$search[sizeOf($search)-1]['columncondition'] = '';
				$search = json_encode($search);
				$_REQUEST['advft_criteria'] = $search;
				$_REQUEST['advft_criteria_groups'] = '';
				$_REQUEST['searchtype'] = 'advance';
			}
			$querygenerator->addUserSearchConditions($_REQUEST);
		}
        //筛选中选择最新更改时间
        if(!empty($_REQUEST['lastmodified'])){
            $querygenerator->addStdSearchContentWX($_REQUEST['lastmodified']);
        }
        // editor:gyq_20180914  	0035234: （珞落计划企业微信登录）客户查重：客户查重不受权限控制，应可以查询到所有的客户单据
        //editor:gyq_20200221 reason:0039253: （51mis.com/kfbcrm）企业微信>灵当CRM>跟进记录新增选择客户界面：当“客户”模块全部页签为“全部（不含公海）”的情况下，在跟进记录选择客户界面输入值进行搜索公海已分配客户，搜索不出来。（pc端是正常的，需要补丁）
        //eidtor:gyq_20200225
        if(isset($_REQUEST['duplicate_related_popu_multifields']) ){
            $querygenerator->getSmOwnerSearchSql = '';
        }
        //editor:gyq_130 reason:合同简报、销售简报序时簿  2019/7/10 11:38 ID1000554
        if(isset($_REQUEST['saleskitscope'])&&!empty($_REQUEST['saleskitscope'])){
            $weixin_user->action = 'saleskitscope';
        }
        //选择源单 不允许重复 带出分录时没有明细表添加明细表连接
        $getQueryWithDetail = $this->getQueryWithDetail();

        $moduleobj = $this->obj_query->moduleobj;
        $ld_inventoryproductrel = $moduleobj->Detail_table;
        if ($getQueryWithDetail == 'yes' && !empty($ld_inventoryproductrel)){
            if (!array_key_exists($ld_inventoryproductrel,$this->obj_query->whereProductTable)){
                $this->obj_query->whereProductTable[$ld_inventoryproductrel]=" left join ".$ld_inventoryproductrel.' on '.$ld_inventoryproductrel.'.'.$moduleobj->Detail_table_index.'='.$moduleobj->table_name.'.'.$moduleobj->table_index;
            }
        }
        $page_list_query = $this->get_page_list_query($showtype);

        $selectDetailLineitemid = $_REQUEST['selectDetailLineitemid'];
        $selectlistvalue = $_REQUEST['selectlistvalue'];
        if ($getQueryWithDetail == 'yes' && !empty($selectDetailLineitemid)){
            $page_list_query .= ' AND '.$moduleobj->Detail_table.'.'.$moduleobj->Detail_table_id.' not in ('.$selectDetailLineitemid.') ';
        }elseif ($getQueryWithDetail == 'no' && !empty($selectlistvalue)){
            $page_list_query .= ' AND '.$moduleobj->table_name.'.'.$moduleobj->table_index.' not in ('.$selectlistvalue.') ';
        }
        if($_REQUEST['report_name']=='contractkit'){
            return $page_list_query;
        }
        //zxm 20230807 销售简报移动端穿透
        if($_REQUEST['report_name']=='Saleskit'||$_REQUEST['report_name']=='saleskit'
            ||$_REQUEST['report_name']=='Salesfunnel'||$_REQUEST['report_name']=='salesfunnel'
            ||$_REQUEST['report_name']=='TD_PotentialsFunnel'
            ||$_REQUEST['report_name']=='DataDragonTigerList'||$_REQUEST['penetrate_class']=='cls_getPenetrateModuleList'
        ) {
            $page_list_query_arr = explode('WHERE', $page_list_query);//以WHERE分界分隔一下
            $page_list_query_arr[0] = $page_list_query_arr[0] . $ChuantouSql;//前半部分 inner join 首页看板设置的组件条件组装的子sql
            $page_list_query = $page_list_query_arr[0];
            //zxm 20240805 简报穿透 不要再带公海条件了  所有条件都在ChuantouSql里面了
            //$page_list_query = implode(' WHERE ', $page_list_query_arr);
        }

        if($_REQUEST['frommodule'] == 'Shopping'){
            $page_list_query .= " and ld_products.productid in (select productid from ld_shop_productproperty where productstatus = '上架')";
        }

        return $page_list_query;
    }
    public function get_page_list_query($showtype)
    {

        //edit:can 20230710 68436  	（扬州中福）之前路总给订单上做了特殊开发，选择收款银行时，只会显示出运公司相关的收款银行。但是这个功能在移动端不生效，移动端没法选择收款银行 
       return  $this->obj_query->getQuery($showtype, 1);
       
        
    }
    protected function set_listdetail($showtype,$isSingle='yes'){
        global  $current_user;

        $this->page_list_query = $this->get_page_query($showtype,$isSingle);

        $this->list_query = $this->obj_query->getQuery($showtype, 2);

        $relatedCreationInfo = $this->relatedModuleActions($_REQUEST['related_id'],$_REQUEST['related_module'],$_REQUEST['recordid'],$_REQUEST['module']);
        if(!empty($relatedCreationInfo)){
            $this->jsonArr['relatedCreationInfo'] = $relatedCreationInfo;
        }

        //date:2017-06-15 editor:xxs reason:前端需要模块名
        $this->jsonArr['modulename'] = getTranstab($this->module);
        //editor:gyq_75 reason:为了方便小程序读取模块名 2018/7/30 13:43
        if (isset($_REQUEST['frommodule'])) {
            $this->jsonArr['page_title'] = getTranstab($_REQUEST['selectmodule']).'-'.getTranstab($this->module);
        }else{
            require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
            $this->jsonArr['page_title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($this->module);
        }
//        $this->jsonArr['page_title'] = getTranstab($this->module);
        //第一次进入列表提示
        //注释 不需要了【移动端，进入“名片申请单”单据列表界面，去掉“当销售同事需要印刷名片时，可以填写名片申请单”提示信息】https://www.tapd.cn/63637123/prong/stories/view/1163637123001001251
        //$this->firstViewModuleWithTips();

        //duan 20240726 列表页返回设置信息,避免从消息提醒进入小程序时错误
        crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
        $workobj = new WorkReportControllerWX();
        $this->jsonArr['setting'] = $workobj->getCRMSetting('index');

        //duan 20221017 获取列表页翻译字符串
        $this->getListviewFixedlabel();
    }

    public function get_listdetail($showtype='',$generatorName='')
    {
        global $adb,$viewid,$current_user;

        $this->set_listdetail("");

        $page_list_query = $this->page_list_query;//获取总条数的sql

        $list_query = $this->list_query;

        //联系人序时簿额外获取手机号码信息
        $list_query = $this->get_phone_sql($this->focus,$list_query);
        if($this->mark_tab_main == 1){
            global $customView;
            $viewid = $customView->getViewIdByName('All',$this->module);
        }
        //editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 14:52
        if(empty($this->customview)){
            $page_list_query2 = $page_list_query;
            $order_by = $this->order_by;
            // @edit:dong @date:2020/08/07 @reason: 没有排序导致pc查重和手机端查重结果不一致
            $page_list_query2 .= ' order by '.$order_by;
        }else{

            list($page_list_query2, $order_by, $sorder) = $this->customview->getOrderWhere($page_list_query);

        }
//        dump($list_query);
        //$count_result = $adb->query(mkCounntListQuery($this->module, $page_list_query));
       // file_put_contents(globalStatic::$root_directory.'WeiXinApp/list/2.txt',$page_list_query,FILE_APPEND);

        $count_result = $adb->query($page_list_query);
        if (!empty($count_result)){
            $noofrows = $adb->num_rows($count_result);
        }
        else{
            $noofrows = null;
        }
        // @edit:dong @date:2020/08/11 @reason:  bug0042360: （曙光计划）客户查重，没有根据参数“设置客户查重列表每页显示记录的条数”控制显示
        if($_REQUEST['action']=='duplicate_related_popu' || $_REQUEST['action']=='duplicate_related_popu_multifields'){
            $noofrows = $this->limitAccountsRowsBySetting($noofrows);
        }
        $page_list_query = $this->page_list_query($noofrows, $page_list_query2, $order_by);

        $list_query = $list_query . '  inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' . 
                $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index
                .' order by '.$order_by.' '.$sorder;

        $list_result = $adb->pquery($list_query,array());
        $num_rows = $adb->num_rows($list_result);
        $_REQUEST['weixin_mark'] = 1; //微信端号码原样输出 gyqTE
        $this->jsonArr['search_reminds'] = $this->getSearchReminds();
        $list1 = $this->getListViewEntries($adb,$list_result,null);

        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type = 7';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'yes';
        }
        if($this->module!='SocialPromotion'&&$is_open=='yes'){
            //zxm 2021-04-01【移动端，单据列表界面增加更多中的操作按钮】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001348
            $this->getModuleRelatedList();
        }
        $this->jsonArr['list1'] = $list1;
        $this->jsonArr['high_search'] = $this->getHigheSearchField();//diony 20200528 功能完成后放开
		if($this->module=='Accounts'||$this->module=='Leads'){
			$this->getPublicAccountPool();//chj 2020/12/10 获取公海池
		}
        $this->set_outputStyle("");

		//判断电话是否隐藏显示
        $Sys_deploy_80 = getSys_deploy(80);
        $deploy_value = $Sys_deploy_80['deploy_value'];
        $this->jsonArr['listSettings'] = ['havephone'=>'no'];
        //bug zxm BUG0053046   根据用户的参数 手机显示样式控制 is_mobile_style=0 则不需要判断 $Sys_deploy_80
        if($deploy_value==0||$current_user->is_mobile_style!=1){
            //判断模块是否有电话或者手机号码字段  zxm 2021-02-24
            $tempFocus = CRMEntity::getInstance($this->module);
            $fieldArr_mobile = $tempFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'mobile');
            $fieldArr_phone = $tempFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'phone');
            $fieldArr_contactsmobile = [];
            $fieldArr_contactsphone = [];
            if($this->module=="Accounts"){
                //如果是客户模块  还可以判断联系人模块
                $contactsFocus = CRMEntity::getInstance($this->module);
                $fieldArr_contactsmobile = $contactsFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'mobile');
                $fieldArr_contactsphone = $contactsFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'phone');
            }
            $fieldArr = array_merge($fieldArr_mobile,$fieldArr_phone,$fieldArr_contactsmobile,$fieldArr_contactsphone);
            if(sizeof($fieldArr)>0){
                $this->jsonArr['listSettings']['havephone'] = 'yes';
            }
        }
        //获取模块的树结构信息  移动端现在仅订货商城需要这个数据
        $this->getModuleTreeList();
        //moduletreejson = {"productcategory":"921","usageunit":"1145"}
        $this->getKanBanInfo();//销售机会  项目 移动端的看板页面信息
        return $this->jsonArr;

    }
    //获取模块的树结构信息  移动端现在仅订货商城需要这个数据
    public function getModuleTreeList(){
        //订货商城 树形结构
        if($_REQUEST['frommodule'] == 'Shopping'){
            //加载初始listview树状结构
            crm_load_class_file('cls_Module_Tree', 'include/utils');
            $cls_module_tree = cls_Module_Tree::getInstance('ShoppingMall');
            if($cls_module_tree->moduleenable=='no'){
                //zxm @date:2024/11/1 @reason: 订货商城的树结构未开启 则取产品的树结构
                $cls_module_tree = cls_Module_Tree::getInstance('Products');
            }
            $modulelisttree = $cls_module_tree->getModuleListTree();
            if(!empty($modulelisttree)){
                $version = getVersionInfo();
                $listtree_key = array_keys($modulelisttree['list']);
                $modulelisttree['list'] = array_merge($modulelisttree['list']);
                foreach($modulelisttree['list'] as $key => $arr){
                    //呼博士特殊控制
                    if($version['account'] == 'huboshi' && $arr['value'] == '充值'){
                        unset($modulelisttree['list'][$key]);
                    }else{
                        $modulelisttree['list'][$key]['listid'] = $listtree_key[$key];
                    }
                }
                $modulelisttree['list'] = array_values($modulelisttree['list']);
            }
            $this->jsonArr['tree_list'] = $modulelisttree;
            //获取购物车数量
            crm_load_class_file('Shopcart','modules/Products');
            $shopcartobj = new Shopcart();
            $shopcartobj->check_nums();
            $shopcart_num = $shopcartobj->cartdetail_num;//购物车 数量

            $this->jsonArr['shopcart_num'] = $shopcart_num;
            $this->jsonArr['shopcart_modulelist'] = getTranstab('SalesOrder');
        }
    }
    //销售机会  项目 移动端的看板页面信息
    public function getKanBanInfo(){
        // 销售机会增加标签
        if($this->module == 'Potentials' || $this->module == 'Project'){
            //获取当前的的推进字段(自动化设置)--zxm改成读取缓存
            crm_load_class_file('cls_module_advance','modules/Settings');
            $cls_module_advance = cls_module_advance::getInstance($this->module);
            $ModuleAdvanceinfo=$cls_module_advance->getModuleAdvance();//推进阶段设置信息
            if ($ModuleAdvanceinfo['enable'] == 'yes' && $ModuleAdvanceinfo['method'] == 'field' && array_key_exists($ModuleAdvanceinfo['module_field'],$this->focus->column_fields) ){
                $ModuleAdvanceinfo['list'] = [['label'=>'列表视图','value'=>'listView'],['label'=>'看板视图','value'=>'kanbanView']];
                $this->jsonArr['listShowData'] = $ModuleAdvanceinfo;

                //销售机会阶段字段
                crm_load_class_file("cls_PickList", 'modules/PickList');
                $objpinklist = new cls_PickList();
                $pick_fieldname=$ModuleAdvanceinfo['module_field'];
                $result_pick = $objpinklist->getPickListValues($pick_fieldname,'',array(),'kanban');
                foreach($result_pick as $key => $pick_info){
                    $result_pick[$key]['selected'] = 'no';
                    if($result_pick[$key]['bgcolor'] == ''){
                        $result_pick[$key]['bgcolor'] = '#0083ff';
                    }
                    if ($this->module != 'Potentials'){
                        unset($result_pick[$key]['winrate']);
                    }
                }

//                crm_load_class_file('cls_KanBan','modules/lingdang');
//                $Kanbanobj = cls_KanBan::getInstance($this->module);
//                $result_pick=$Kanbanobj->getKanBanPickAmounts();
                $this->jsonArr['kanbanStageData'] = $result_pick;
            }
        }
    }
	//获取当前用户有权限看到的所有公海池
	public function getPublicAccountPool(){
        $className = "cls_Public".$this->module;
        crm_load_class_file($className, 'modules/'.$this->module);
		$cls_Public = new $className($this->module);
		$public_account = $cls_Public->getPublicAccountConfig();
		if($public_account['status'] == 'yes' && !empty($public_account['public_account_pool'])){
			// $kk = 0;
            $have_default_pool = 'no';
			foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
				$selected = 'no';
				// if($kk == 0){
				// 	$selected = 'yes';
				// }
                if($pool_info['default_pool'] == 'yes'){
                    $selected = 'yes';
                    $have_default_pool = 'yes';
                }
				$all_pool[] = array('label'=> $pool_info['pool_name'], 'value'=> $pool_id, 'selected'=>$selected);
				// $kk++;
			}
            if($have_default_pool == 'no'){
                $all_pool[0]['selected'] = 'yes';
            }
			$this->jsonArr['public_account_pool'] = $all_pool;
		}
		
	}
	//获取列表高级查询字段
	public function getHigheSearchField(){
		crm_load_class_file('CustomView_Special','modules/CustomView');
		$module_fields =$this->getByModule_ColumnsList($this->module,'');
		$columnsList[] = array(
			'name' => $this->module,
			'label' => getTranstab($this->module),
			'list' => array_values($module_fields)
		);
		if(get_file_address($this->module,'ProductDetails'))
		{
			$module_fields = CustomView_Special::getProductSearchCustom($this->module,'');
			$columnsList[] = array(
				'name' => 'Products',
				'label' => getTranstab('Products'),
				'list' => array_values($module_fields)
			);
		}
        else if(get_file_address($this->module,$this->module."DetailFieldsHtml"))
        {
            $module_fields = CustomView_Special::getFinacialSearchCustom($this->module,''); 
			$columnsList[] = array(
				'name' => $this->module,
				'label' => getTranstab($this->module),
				'list' => array_values($module_fields)
			);
        }
		else if($this->module=='Accounts')
		{
			//35893:设置-系统设置-参数设置-自动提醒设置,选择模块“客户”新建，数据范围，高级查询，筛选字段里面没有联系人模块的字段，可以参考客户模块高级查找是有的
			$module_fields = CustomView_Special::getAccountContact('Contacts',''); 
			$columnsList[] = array(
				'name' => 'Contacts',
				'label' => getTranstab('Contacts'),
				'list' => array_values($module_fields)
			);
		}
		// $this->jsonArr['high_search']['list'] = $columnsList;
        $num_rows = count($columnsList[0]['list']);
        $columnname_arr = [];
        $uitype_arr = [4,73,81];
        if($this->module=='Accounts'){
            $uitype_arr = [2,4,81];
        }
        for($i = 0; $i< $num_rows; $i++){
            $tmp_info = $columnsList[0]['list'][$i];
            if(in_array($tmp_info['uitype'],$uitype_arr)){
                $columnname_arr[] = $tmp_info;
            }
        }
        crm_load_class_file("CommonView","modules/CustomView");
        $fLabels = CommonView::getComparatorLabel();
        unset($fLabels['curuser']);
		// $this->jsonArr['high_search']['flabels'] = $fLabels;
        // 2020-12-30 diony 高级查找条件
        $rh_list['list'] = $columnsList;
        $rh_list['flabels'] = $fLabels;
        $rh_list['choosecolumn'] = $columnname_arr;
        return $rh_list;
	}

	public function getByModule_ColumnsList($module,$columnname) {
		global $adb,$currentModule,$current_user,$MobileLanguageType;
		$fieldobj=Field::getInstance($module,$adb);
        $fieldModules=$fieldobj->getModuleFields();
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        $sqlField = "select tablename,columnname,ld_field.uitype,ld_field.fieldname,typeofdata,case when ifnull(ld_tranlabel.fieldlabel,'')='' then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
        from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
         where presence in (0,2) and ld_tranlabel.languagetype=? and ld_tranlabel.trantable=? and ld_tranlabel.tabid=? and ld_field.tabid = ?";

        if($currentModule == 'ServiceCharge' && $module == 'ServiceContracts')
        {
            $sqlField.= ' and ld_field.uitype not in(52,53,70,73,57)';
            $column = 'ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D';
            if(!empty($columnname) && in_array($column,$columnname))
            {
                $selected = "selected = selected";
            }
            $ProductInfo[0] = array(
                'value'=> $column,
                'text' => getFixedLabel('PERIODOFSERVICEEND'),
                'selected' => $selected,
				'uitype' => 5
            );
            $stdcriteria_list['ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D'] = getFixedLabel('PERIODOFSERVICEEND');
        }
        $resField = $adb->pquery($sqlField, array($MobileLanguageType,'ld_field',getTabid($module),getTabid($module)));
        
        for($i = 1; $i<=$adb->num_rows($resField); $i++)
        {
            $selected = "";
            $fieldtablename = $adb->query_result($resField, $i - 1, "tablename");
            $fieldcolname = $adb->query_result($resField, $i -1, "columnname");
            $fieldname = $adb->query_result($resField, $i - 1, "fieldname");
            $fieldtype = $adb->query_result($resField, $i - 1, "typeofdata");
			$uitype = $adb->query_result($resField, $i - 1, "uitype");
            $fieldtype = explode("~", $fieldtype);
			$fieldinfo=$fieldModules[$fieldname];
			if(!$fieldinfo||$fieldinfo->getFieldName()=='')
			{
				continue;
			}
			if($fieldinfo->getSaveDataBase()=='no')
			{
				continue;
			}
			if($fieldinfo&&($fieldinfo->getUIType()==1109||$fieldinfo->getUIType()==10||$fieldinfo->getUIType()==69||$fieldinfo->getUIType()==64||$fieldinfo->getUIType()==65))
			{
				//032281: 公告>数据分类：添加附件字段查找，结果报错了。
				continue;
			}
			if($module == 'ServiceCharge' && $fieldinfo->getTableName() == 'ld_contactdetails')continue;
            switch($fieldtype[0])
            {
               // case DT:
                //    $fieldtypeofdata = 'D';
                 //   break;
                case 'NN':
                    $fieldtypeofdata = 'N';
                    break;
                default:
                    $fieldtypeofdata = $fieldtype[0];
            }

            $fieldlabel = $adb->query_result($resField, $i - 1, "fieldlabel");
            $column = $fieldtablename . ':' . $fieldcolname . ':' . $fieldname . ':' . $module.'_' .
            'fieldlabel' . ':' . $fieldtypeofdata;
                $columncheck = $fieldtablename . ':' . $fieldcolname;
            

            if(!empty($columnname) && in_array($column,$columnname) )
            {
                $selected = "selected = selected";
            }
            $column_list[$i] = array(
                'value'=> $column,
                'text' => $fieldlabel,
                'selected' => $selected,
				'uitype' => $uitype,
                'm_content' => '',
                'm_content_end' => ''
            );
        }
        return $column_list;
}

    public function getSearchField(){
        global $adb;
        //xxy 2023-11-30 根据所设置的获取模块中允许用于搜索的字段
        $select_sql = 'SELECT * from ld_cvcolumnlist_wx where modulename = ? and presence = ? and isforsearch = ?';
        $select_result = $adb->pquery($select_sql, array($this->module,0,'yes'));
        $num_rows = $adb->num_rows($select_result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $columnname = $adb->query_result($select_result,$i,'columnname');
                if (preg_match('/^.*?:.*?:(.*?):/', $columnname, $matches)) {
                    $this->search_custom_fields[$i] = $matches[1];
                }
            }
        }
    }
    //获取头部搜索text，包含搜索内容字段
    public function getSearchReminds(){
        global $MobileLanguageType;
        $field_trans = getFixedLabel('SEARCHNEW');
        if($MobileLanguageType == 'en'){
            $field_trans .= ' ';
        }
        if(!empty($this->search_custom_fields)){
            $i = 1;
            $count = count($this->search_custom_fields);
            foreach($this->search_custom_fields as $field){
                $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('fieldname',$field);
                if(empty($fieldinfo)) continue;
                $field_trans .= $fieldinfo->getFieldLabel().($count==$i?'':'、');
                $i++;
            }
        }
        return $field_trans;
    }
    //联系人模块获取查询手机号码的查询语句 gyq_32
    protected function get_phone_sql($focus,$list_query){
        return $list_query;
    }
    //模块明细界面关联信息序时簿关联创建待传值 MOBILEREPEAT
    public function relatedModuleActions($related_id,$related_module,$related_module_recordid,$module){
        if(!empty($related_id)&&!empty($related_module)){
            /* editor:gyq_20190617 reason:在服务收费管理中，相关创建跟进记录，不能将$related_module赋值为Accounts,
                否则getRelatedListInfoById返回值为空 2019/6/17 18:00
             * 0037332: （落落计划）企业微信>灵当CRM>服务收费管理：关联创建跟进记录，不会将客户名称、联系人姓名自动带出来，
                客户模块和pc端是可以正常带出的*/
            //if($related_module=='ServiceCharge') $related_module='Accounts';
            $this->output_style = 'related_listview';
            require_once (globalStatic::$root_directory.'include/utils/DetailViewUtils.php');
            $relationInfo = getRelatedListInfoById($related_id,$related_module);
            if(stripos($relationInfo['actions'],'add')!==false&&!$this->get_approvedemand($related_module,$related_module_recordid,$module)&&$this->get_advancedemand($related_module,$related_module_recordid,$module)){
                $this->relatedModuleActions = 'add';
                //editor:gyq_146 reason:关联创建带出信息改进  2019/9/24 11:41 
                $RelatedList['fromid'] = $related_module_recordid;
                $RelatedList['frommodule'] = $related_module;
                return json_encode($RelatedList);
            }else{
                $this->relatedModuleActions='empty';
                return '';
            }
        }else{
            return '';
        }
     
    }
 
    //输出样式
    protected function set_outputStyle($content=""){
        if($this->output_style=='related_listview'){
            unset($this->jsonArr['list']);
            unset($this->jsonArr['listtab']);
        }
    }
    //gyq_32 移动端序时簿显示内容统一
    public function getListViewEntries($adb,$list_result,$approvestatus)
    {
        crm_load_class_file('QueryGenerator_FunctionsMC', 'appCommon/include/QueryGenerator');
        $QFN = new QueryGenerator_FunctionsMC();
        //XUQIU20240703-03 敏感规则，增加“禁用场景”参数，支持自定义设置模块列表或相关信息列表加密方式生效范围（安康金源）
        if(!empty($this->relatedmodule)){
            $QFN->setApplicationScene('RelatedModuleListView');
        }else{
            $QFN->setApplicationScene('ModuleListView');
        }
        $list1_complex = $QFN->getListViewEntries($this->focus,$this->module,$list_result,null);
        return $list1_complex;
    }
    //data:20170503 reason:审批中心序时簿还在插入审批状态
    protected function set_detail_value(&$detail_value,$approvestatus,$value,$real_i){
        return false;
    }

    public function init_custom()
    {
        /*
         * viewname 数据分类
         * SearchScope 查看范围
         * accounttype 是否公海
         * */
        global $customView,$viewid; //查询语句排序需要
        crm_load_class_file('cls_CustomViewWX', 'WeiXinApp/WeiXin_CustomView');
        $this->setFilterRequest();//获取查询参数
        if (empty($_REQUEST['SearchScope'])) {
            $_REQUEST['SearchScope'] = 'SmOwner_Search_Me';
        }
        $this->customview = $customView = new cls_CustomViewWX($this->module);
        //读取显示字段;初始化高级查找
        //$this->setDisplayColumns();
        $this->init_custom_special();
          
        if(!empty($_REQUEST['switch_accounttype'])){
            return $this->setCustomViewFormat();
        }

        //后台返回去除筛选即键值为list和listtab的内容 date:2017-11-20 edit:xxs
        //筛选第一页加载显示筛选信息 date:2018-01-11 edit:xxs
        if(empty($_REQUEST['page'])){
            $this->setreturnJson_listContent(); //初始化jsonArr中值
            //unset($this->jsonArr['listtab']);
        }

        if(isset($_REQUEST['senioruserid'])&&$_REQUEST['senioruserid']=='all'){
            $module_users = getCurSmOwnerSearchScope('Home');
            $selectuid = implode(',', array_keys($module_users['UserCombo']));
            $_REQUEST['senioruserid'] = $selectuid;
        }

        return $customView;
    }
    // 初始化viewid 和viewname
    public function init_custom_special(){
        global $viewid,$adb,$current_user; //查询语句排序需要
        if (isset($_REQUEST['viewid']) && $_REQUEST['viewid']) {
            $viewid = $_REQUEST['viewid'];
            $_REQUEST['viewname'] = $viewid;
        //}  elseif($_REQUEST['SearchScope'] != 'SmOwner_Search_Me') { gyq_21
        }  else {
            //$viewid = $this->customview->getViewId($this->module);
			//43824: （http://xmshj.ufyct.com:85/ [^]）（厦门拓友）移动端的跟进记录中无法查到客户。比如说客户名称中查找一个“爱”字，电脑端可以看到三条记录，但是移动端没有。
           
           //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
            $sql='select ld_customview.setdefault,ld_user_module_preferences.default_cvid,ld_customview.cvid,
                ld_user_module_preferences.userid,ld_customview.`status` from  ld_customview
                 left join ld_user_module_preferences
                 on ld_customview.cvid=ld_user_module_preferences.default_cvid
                  where ld_customview.entitytype=? and (setdefault=1 or (ld_user_module_preferences.userid=?)) 
                  and (ld_customview.customcategory is null or ld_customview.customcategory ="")
                  order by ld_user_module_preferences.default_cvid desc ';
           
            $result=$adb->pquery($sql,array($this->module,$current_user->id));
        
            $rows=$adb->num_rows($result);
            $userdefault_cvid = 0;
            $setdefault_cvid = 0;
            $cur_viewid = 0;
            for($i=0;$i<$rows;$i++)
            {
                $default_cvid=$adb->query_result($result,$i,'default_cvid');
                $userid=$adb->query_result($result,$i,'userid');
                $status=$adb->query_result($result,$i,'status');
                
                if($default_cvid>0&&$userid==$current_user->id)
                {
                    $cur_viewid = $default_cvid;
                    break;
                   
                }
               
            }

            $viewid = $cur_viewid;

            if( empty($viewid))
            {
                for($i=0;$i<$rows;$i++)
                {
                    $default_cvid=$adb->query_result($result,$i,'default_cvid');
                    $userid=$adb->query_result($result,$i,'userid');
                    $status=$adb->query_result($result,$i,'status');
                        //设为公开默认
                    if($default_cvid>0&&$status==3)
                    {
                        $viewid=$default_cvid;
                        break;
                       
                    }
                   
                }
                //zxm 20231122 工作台简报穿透 数据分类根据全部分类来
                if(empty($viewid)||$_REQUEST['dashboard']=='yes')
                    $viewid = $this->customview->getViewIdByName('All',$this->module);
            }
                 
            $_REQUEST['viewid']=$viewid;
        }

        if ($viewid == 0 && is_numeric($_REQUEST['viewid'])) {
            ConvertTojsonString('-1', null, getFixedLabel('NOPERMITTEDEXECUTE'));
        }
        if (!isset($_REQUEST['viewid'])) {
            $_REQUEST['viewid'] = $this->customview->getViewIdByName('All',$this->module);
            $_REQUEST['viewname'] = 'SmOwner_Search_Me';
        }
        if ($_REQUEST['viewid'] == 'Account_publicAccount') {
            $_REQUEST['viewid'] = 'SmOwner_Search_All';
            $_REQUEST['viewname'] = 'Account_publicAccount';
        }
        if ($_REQUEST['viewid'] == 'Leads_publicLeads') {
            $_REQUEST['viewid'] = 'SmOwner_Search_All';
            $_REQUEST['viewname'] = 'Leads_publicLeads';
        }
        $this->viewid = $viewid;
        
        $customviewinfoobj = new CustomViewInfo();
        $customviewinfoobj->setCvid($viewid);
        $this->customview->setViewInfoObj($customviewinfoobj);
    }
    protected function page_list_query($noofrows, $page_list_query, $order_by)
    {
        global $mobile_pagerecordcount,$weixin_user;
        $this->jsonArr['pageTip'] = getVarFixedLabel('DSFMFFQOTSTT5OTQR',$mobile_pagerecordcount);
        $endpagenum = $mobile_pagerecordcount;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';
        //editor:gyq_20191111 reason:若每页显示条数大于总条数，则每页显示条数应重新赋值
        //0038454: （51mis.com/kfbcrm）拜访签到选择拜访对象时，选择源单单据显示条数没有根据源单定制中设置的显示条数显示
        if($mobile_pagerecordcount >  $noofrows && $noofrows > 0){
            $mobile_pagerecordcount = $noofrows;
        }
        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $_REQUEST['page'] = 1;
        } else {
            $_REQUEST['page']++;
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

        $_REQUEST['start'] = $startpagenum + 1;
        $startpagerecord = $startpagenum * $mobile_pagerecordcount;

        $page_list_query .=' LIMIT '. $startpagerecord.','. $mobile_pagerecordcount ;
        //editor:gyq_81 reason:签到考勤优化 2018/9/27 15:50
        //editor:gyq_20200224 reason:选择源单的序时簿，应没有下一页   2020/2/24 15:30
        //0039266: （51mis.com/kfbcrm）页面设置>合同订单>编辑“客户名称”字段最多显示数据条数设置为“10”>企业微信灵当CRM落落计划：新增合同订单，选择客户名称，显示数据未受参数控制（PC端显示正常）
        //editor:gyq_20200227
        if($weixin_user->action=='related_popu'|| (isset($_REQUEST['related_pop_type'])&&$_REQUEST['related_pop_type']=='signin')){
            $havenextpage = 'no';
        }
        if(isset($_REQUEST['selectrelationfrom'])&&$_REQUEST['selectrelationfrom']=='entry'&&$_REQUEST['selectmodule']=='Products'){
            $havenextpage = 'yes';
            //是否有下一页
            if ($_REQUEST['page'] >= $totalpagecount){
                $havenextpage = 'no';
            }
        }
        $this->jsonArr['pagecount'] = $totalpagecount;
        $this->jsonArr['totalrows'] = $noofrows;
        $this->jsonArr['havenextpage'] = $havenextpage;
        $this->jsonArr['haveprevpage'] = $haveprevpage;
        $this->jsonArr['curpagenum'] = $startpagenum + 1;

        // diony 2023-09-21 水印
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $watermark_txt = $MenuUtilsObj->getwatermark_setting();
        $this->jsonArr['watermark_txt'] =$watermark_txt;

        return $page_list_query;
    }
    public function setFilterRequest()
    {
       
        if (!empty($_REQUEST['filter'])) {
            $filter_arr = $_REQUEST['filter'];
           
            $_REQUEST['SearchScope'] = $filter_arr['SearchScope']; //查看范围
            if(empty($filter_arr['viewname']) && $filter_arr['SearchScope']=='SmOwner_Search_Me'){
                //$_REQUEST['viewid']  = 'SmOwner_Search_Me';
                $this->mark_tab_main = 1;
            }
            $_REQUEST['viewid'] = $filter_arr['viewname'];  //数据分类
            $_REQUEST['lastmodified'] = $filter_arr['lastmodified']; //最新改改日期
            $_REQUEST['searchcontent'] = $filter_arr['searchcontent']; //序时簿查找内容
            if(empty($_REQUEST['senioruserid'])){
                $_REQUEST['senioruserid'] = $filter_arr['senioruserid']; //高级查找用户
            }
        }
    }

    public function setLastmodifiedFormat()
    {
        $lastmodified = $this->lastmodifiedArr;
        $lastmodifiedNe['fieldname'] = 'lastmodified';
        $lastmodifiedNe['fieldlabel'] = getFixedLabel('UPDATETIME');//更新时间
        $i = 0;
        foreach($lastmodified as $key => $val){
            $lastmodifiedArr[$i]['text'] = $val;
            $lastmodifiedArr[$i]['value'] = $key;
            $lastmodifiedArr[$i]['select'] = $i==0?'yes':'no';
            $i++;
        }
        $lastmodifiedNe['option'] = $lastmodifiedArr;
        return $lastmodifiedNe;
    }

    public function setCustomViewFormat(){
        //2024-10-11 hzx 之前使用的移动端特殊的获取查询分类的方法 现在改为跟pc端一致的方式了
        //$customview_html = $this->customview->jsongetCustomViewCombo2($this->viewid, $this->module);
        $customview_arr = $this->customview->getCustomViewAll($this->viewid, $this->module,'','');
        $customview_html = [];

        for($i = 0;$i < count($customview_arr);$i++){
            $customview_html[] = array('title'=>$customview_arr[$i]['viewname'],'viewname'=>$customview_arr[$i]['cvid']);
        }
        //dump($customview_html);
        //array_shift($customview_html);

        $customview_htmlNe['fieldname'] = 'viewname';
        $customview_htmlNe['fieldlabel'] = getFixedLabel('DATACATEGORY');//数据分类

        foreach($customview_html as $key=>$val){
            $customview_htmlNeOp[$key]['text'] = html_entity_decode($val['title']);
            $customview_htmlNeOp[$key]['value'] = $val['viewname'];
            if($this->viewid==$val['viewname']){
                $customview_htmlNeOp[$key]['select'] = 'yes';
                $select = true;
            }else{
                $customview_htmlNeOp[$key]['select'] = 'no';
            }
        }
        if(!$select) $customview_htmlNeOp[0]['select']='yes';
        $customview_htmlNe['option'] = $customview_htmlNeOp;
        return $customview_htmlNe;
    }

    public function setreturnJson_listContent()
    {
        global $current_user;
        $MergeSmowner = getCurSmOwnerSearchScope($this->module);
        unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
        //个人权限不显示高级
        if(empty($MergeSmowner["UserCombo"])){
            unset($MergeSmowner["OtherInfo"]['smowner_search_senior']);//去除高级
        }
        unset($MergeSmowner["UserCombo"]);
        $MergeSmowner2 = array();
        $MergeSmowner2['fieldname'] = 'SearchScope';
        $MergeSmowner2['fieldlabel'] = getFixedLabel('VIEWRANGE');//查看范围 
        
        foreach($MergeSmowner['OtherInfo'] as $key => $val){
            if($key=='smowner_search_senior'){
                $senior = array('text'=>getFixedLabel('LBL_SENIOR'),'value'=>'smowner_search_senior','select'=>'no');
                continue;
            }
            foreach($val as $key1 => $val1){
                $MergeSmownerOn = array();
                $MergeSmownerOn['text'] = $key1;
                $MergeSmownerOn['value'] = $key;
                $MergeSmownerOn['select'] = $key=='SmOwner_Search_All'?'yes':'no';
                $MergeSmowner2Op[] = $MergeSmownerOn;
            }
        }
        if(!empty($senior)) $MergeSmowner2Op[] = $senior;
        $MergeSmowner2['option'] = $MergeSmowner2Op;
        // @edit:dong @date:2020/12/07 @reason: 数据分类设置为链接模块 打开无须数据分类
        if($_REQUEST['linkemodule_category'] !='yes'){
            $this->jsonArr['list'][] = $this->setCustomViewFormat(); //数据分类
        }
        
        $this->jsonArr['list'][] = $MergeSmowner2;  //查看范围
        //没有修改时间字段不显示该分类  //BUG0066804 ls 20230907 服务合同模块，筛选缺少根据更新时间筛选
        if(isset($this->focus->column_fields['modifiedtime'])||isset($this->focus->column_fields['promodifiedtime'])  || isset($this->focus->column_fields['ServiceContractsmodifiedtime'])){
            $this->jsonArr['list'][] = $this->setLastmodifiedFormat(); //最新更新日期
        }
    }
    //判断关联创建是否有已审批限制->当前单据是否审批
    public function get_approvedemand($related_module,$related_module_recordid,$module){
        global $adb;
    	$frommodule=$related_module;
    	$fromid=$related_module_recordid;
    	if(empty($frommodule))
    	{
    	   $frommodule= getSalesEntityType($fromid);   
    	}
    	$from_focus=CRMEntity::getInstance($frommodule);    
    	$approve_demand= $from_focus->get_approve_demand_byModule($module);
    	   
    	if($approve_demand==1)
    	{
    		$approvestatusColumnname=$from_focus->getApproveStatusColumnName();
    		$sql='select '.$approvestatusColumnname.' from '.$from_focus->table_name.'  where '.$from_focus->table_index.'=?';

    		$result=$adb->pquery($sql,array($fromid));
    		if($adb->num_rows($result)>0)
    		{
    			$approvestatus_label=$adb->query_result($result,0,0);
                //zkt 20220602 52420(http://erp.zonergy.com:85/crm/)(客户问题-龙卫东）收款单模块-选择源单-销售合同审批要求修改“已审批后”中文环境正常，英文环境在已审批的销售合同详情下推收款单会报错
    			if($approvestatus_label==$from_focus->getApproveStatus_label())
    			{
    			}
    			else
    			{
		            if($_REQUEST['type']=='relatedCreationInfo'){
		                ConvertTojsonString(-1,null,getFixedLabel('NOTCREATERELVANTBILL'));
		            }
    				return 1;
    			}
    		}
    	}
        return 0;
    }

    //判断关联创建是否有"其他条件"限制【参考PC端CRMQuit.php】  $related_module：当前模块；$module：相关信息关联创建的模块
    public function get_advancedemand($related_module,$related_module_recordid,$module){
        global $adb;
        $frommodule=$related_module;
        $fromid=$related_module_recordid;
        if(empty($frommodule))
        {
            $frommodule= getSalesEntityType($fromid);
        }
        $from_focus=CRMEntity::getInstance($frommodule);

        $uitype_arr=cls_module_uitype::getModuleUitype($module,$frommodule);
        $focus=CRMEntity::getInstance($module);

        foreach($uitype_arr as $tmpuitype=>$uitype)
        {
            $_REQUEST['fieldname']=$focus->fieldobj->getFieldInfoBykeyValue('uitype',$uitype,'fieldname');
            break;
        }
        if($_REQUEST['fieldname']!=''&&$related_module_recordid>0)
        {
            if($frommodule=='Accounts'||$frommodule=='Leads')
            {
                setSearchAllAccount();//设置查询所有的客户（包括公海客户）
            }

            //edit:can 2020-10-19  v42930: (61mis.com/kfbcrm)系统设置-页面设置-合同订单-客户名称；在系统设置-页面设置-合同订单-客户名称字段，设置筛选条件后，在合同订单模块，新建订单，不符合条件的客户不显示；但在客户模块，不符合条件的客户却可以新建订单。
            $_REQUEST['selectmodule']=$frommodule;
            $_REQUEST['frommodule']=$module;
            $requestvalue_arr = [];
            if(!isset($_REQUEST['requestvalues'])){
                $currentmodulefields = $focus->fieldobj->getModuleFields();
                foreach($currentmodulefields as $tmpfieldname=>$tmpfieldinfo)
                {
                    $tmpcolumnname = $tmpfieldinfo->getcolumnname();
                    $defaultvalue = $tmpfieldinfo->getDefaultvalue();
                    $requestvalue_arr[$tmpcolumnname] = $defaultvalue;
                }
            }

            crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
            $SelectRelatedPopuobj=new SelectRelatedPopu($frommodule,$adb);
            $SelectRelatedPopuobj->set_request_columnvalue($requestvalue_arr);
            $SelectRelatedPopuobj->setRelatedPopopSql();
            $fromtablename=$from_focus->table_name;
            $fromtableindex=$from_focus->table_index;

            $sql=$SelectRelatedPopuobj->page_list_query." and $fromtablename.$fromtableindex=$related_module_recordid";

            $result=$adb->pquery($sql,array());

            if($adb->num_rows($result)<=0)
            {
                //duan 20220620 从详情页的相关信息进列表页不能直接返回-1
                if($_REQUEST['type']=='relatedCreationInfo'){
	                ConvertTojsonString(-1,null,getFixedLabel('BillMeetCondition'));
	            }
                return false;
            }
        }

        return true;
    }

    //获取仓库信息
    public function setWareHouseFormat(){
        global $adb;
        crm_load_class_file('CommonStock','include/Stock');
        $result = selWareAll();
        $num_rows=$adb->num_rows($result);
        $warehouses=array();
        for($i=0;$i<$num_rows;$i++){
            $id = $adb->query_result($result,$i,'id');
            $name = $adb->query_result($result,$i,'name');
            $warehouses['option'][] = array('text'=>$name,'value'=>$id);
        }
        $warehouses['fieldlabel'] = '仓库';
        $warehouses['fieldname'] = 'wareid';
        
        return $warehouses;
    }
    public function firstViewModuleWithTips(){
        global $current_user,$adb;
        $userid = $current_user->id;
        $module = $this->module;
        if($module=='Accounts'&&$_REQUEST['publicaccounts']=='yes') $module='NearbyAccounts';
        //涉及到提示的模块
        $tipmodules = array('Invoice','CashBill','CardApply','Commission','NearbyAccounts');
        $this->jsonArr['firstview'] = 'no';
        if(in_array($module,$tipmodules)){
            $sql = "select 1 from ld_users where id=? and wxviewedmodules like '%$module%'";
            $result = $adb->pquery($sql,array($userid));

            if(!$adb->num_rows($result)){
                $this->jsonArr['firstview'] = 'yes';
                $query = "update ld_users set wxviewedmodules = concat(IFNULL(wxviewedmodules,''),?) 
                            where id = ? and (wxviewedmodules not like '%$module%' or wxviewedmodules is null)";

                $adb->pquery($query,array($module.',',$userid));
            }
        }
    }
    
    //选客户以及客户查重，显示条目数根据系统参数走
    public function limitAccountsRowsBySetting($noofrows){
        global $mobile_pagerecordcount;
        $sys_151 = getSys_deploy(151);
        $limitrows = $sys_151['deploy_value'];
        $mobile_pagerecordcount=$limitrows;
        return $limitrows;
    }
    //获得全部数据分类 editor:gyq_20181026
    /*单据明细相关信息列表，根据单据数据分类“全部”显示数据，不根据PC端相关信息列表当前选择的数据分类显示*/
    public function set_customview_all(){
        global $adb;
        $sql = 'select cvid from ld_customview where viewname=? and entitytype=? group by entitytype order by entitytype';
        $result = $adb->pquery($sql,array('All',$this->module));
        $viewid = $adb->query_result($result,0,'cvid');
        $_REQUEST['viewname'] = $viewid;
        $_REQUEST['switchview'] = $viewid;
        return $viewid;
    }
    //获取一条记录的列表头部内容
    public function getRecordContent($record){
        global $adb;
        static $moduleapprovesql;
        if(empty($moduleapprovesql[$this->module])){
            //不读静态类里面的数据
            $this->set_listdetail('','no');
            $list_query = $this->list_query;
            $moduleapprovesql[$this->module] = $list_query;
        }else{
            $list_query = $moduleapprovesql[$this->module];
        }
        //editor:gyq_20180929   35291: （企业微信登录）审批列表界面：待处理页签处显示的数据数量与待处理页签列表显示的数据数量不一致
        //editor:gyq_20180918	0035247: （企业微信登录）审批列表界面：已删除的单据不应显示在列表界面
        if($this->module=='PublicAnnouncement')
        {
            //edit:can 2021-03-04 044833: （企业微信移动端kfbcrm）待办-审批事项-公告；公告显示有待审批单据，点进去后看不到单据
        }else if($this->module=='Reminds'){
            $list_query .= ' where 1 = 1 ';
        }
        else
            $list_query .= ' where '.$this->focus->table_name.'.deleted=0 ';

        $list_query .=' and '.$this->focus->table_name.'.'.$this->focus->table_index.'='.$record;

        $list_result = $adb->pquery($list_query,array());
        $contentArr = $this->getListViewEntries($adb,$list_result,null);
        return $contentArr[0];
    }

     //zxm 2022-0225 //获取客户关联的联系人列表  获取ID 名字lastname 头像imagename  sql
    public function getRecordContentSql($record,$relatedidKey,$relatedmodule){
        global $current_user;
        static $moduleapprovesql,$current_user;
        if(empty($moduleapprovesql[$this->module])){
            //不读静态类里面的数据
            $this->set_listdetail('','no');
            $list_query = $this->list_query;
            $moduleapprovesql[$this->module] = $list_query;
        }else{
            $list_query = $moduleapprovesql[$this->module];
        }
        $list_query .= ' where '.$this->focus->table_name.'.deleted=0 ';

        $list_query .=' and '.$this->focus->table_name.'.'.$relatedidKey.'='.$record;
        if($current_user->accountallview!=1&& $current_user->is_admin != 'on'){
            //zxm 20230308 成员管理-角色权限区块，关闭“单据相关信息查询所有关联数据”这个参数后，微信小程序的“客户模块”，客户详情页，联系人区块有其他自己 查看权限之外的联系人
            $Smownerids= getCurSmOwnerSearchScope($relatedmodule);
            $tmpuserid_arr = array_keys($Smownerids['UserCombo']);
            if(!empty($tmpuserid_arr)){
                $tmpuserid_str = implode(',',$tmpuserid_arr);
                $list_query .= ' and find_in_set('.$this->focus->table_name.'.smownerid,"'.$tmpuserid_str.'") ';
            }
        }
        return $list_query;
    }
    //duan 列表页获取翻译字符串
    public function getListviewFixedlabel(){
        //duan 移动端增加字符串翻译返回
        if(!empty($_REQUEST['related_module'])){
            //相关信息列表
            $label_arr=array(
                'DELETE',//删除
                'zhang',//张
                'nodata',//没有数据
                'NOTMPDATA',//没有%s数据
                'NOMORETMPDATA',//没有更多%s数据
                'NEW',//新增
                'SHARE',//共享
                'RECORDSINTOTAL',//共%d条记录
                'LBL_Creates',//创建
                'SELECT',//选择
                'QuotesChange_Add',//新建->追加
                'QuotesChange_Edit',//新建->修改
                'QuotesChange_Replace',//新建->更换
                'SUREWANTDELETE',//确定要删除吗？
                'SuccessDeleted',//删除成功！
                'CONTACTMAP',//联系人图谱
            );
            $fixedlabel_arr = TransFieldlabel($label_arr);
            $fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
            $fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
            $fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);
            // 联系人图谱，模块名称动态显示
            $fixedlabel_arr['CONTACTMAP'] = getFixedLabel('ContactsMap');
            
        }else if($_REQUEST['frommodule'] == 'Shopping'){
            //订货商城
            $label_arr=array(
                'CANCEL',//取消
                'MYORDER',//我的订单
                'ALL',//全部
                'NOTMPDATA',//没有%s数据
                'NOMORETMPDATA',//没有更多%s数据
                'SEARCHNEW',//搜索
                'shopping',//订货商城
                'SHOPCART',//购物车
                'nodata',//没有数据
                'NOMOREDATA',//没有更多数据
                'SUCCESSADDCART',//已添加购物车
            );
            $fixedlabel_arr = TransFieldlabel($label_arr,'no');
            $fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
            $fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
        }
        else{
            //列表页面
            $label_arr=array(
                'LBL_NOALLOCATE',//公海未分配
                'LBL_PUBLICALLOCATE',//公海已分配
                'ALL',//全部
                'TOBEALLOCATED',//待分配
                'BEURGED',//已催单
                'INPROCESS',//处理中
                'CLOSEDBILL',//已结单
                'zhang',//张
                'EXPANDINVENTORYDETAILS',//展开库存详情
                'nodata',//没有数据
                'NOMOREDATA',//没有更多数据
                'NOTMPDATA',//没有%s数据
                'NOMORETMPDATA',//没有更多%s数据
                'MYSCHEDULE',//我的日程
                'OTHERSCHEDULE',//他人日程
                'CUSTOMIZESEARCH',//高级查找
                'PLEASESELECTSTARTDATE',//请选择开始日期
                'PLEASESELECTENDDATE',//请选择结束日期
                'TO',//至
                'pleaseenter',//请输入
                'NOADVANCEDSEARCHCONDITIONS',//暂无高级查找条件，请%s前往设置
                'RESET',//重置
                'ALLSELECT',//全选
                'LBL_PLEASE_SELECT',//请选择
                'SEARCHNEW',//搜索
                'NEW',//新增
                'TOTALOF',//共
                'RECORDNUMS',//条记录
                'Paymentplan',//收款
                'CHECK',//查重
                'Highseaspool',//公海池
                'CREATEBUSINESSCARD',//拍名片
                'ENTERPRISEWECHATCUSTOMERS',//企业微信客户
                'CreateDebuction',//预收
                'NORMAL',//普通
                'SEARCHFORVISITORS',//搜索拜访对象、地址、人员、签到时间、误差
                'ONEPICTUREBUSINESSCARD',//创建名片时只能上传1张图片
                'UPLOADFAILED',//上传失败
                'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
                'CONFIGURECUSTOMERCONTACTPARAMETERS',//企业微信后台没有配置客户联系参数
                'STOWINVENTORYDETAILS',//收起库存详情
                'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
                'RECORDSINTOTAL',//共%d条记录
                'UPLOADING',//上传中
                'UPLOADSUCCEEDED',//上传成功
                'Quickly_create',//快速创建
                'PLEASESELECTATLEASTONEITEM',//请至少选择一项
                'FORMATERROR',//格式错误
                'MORE',//更多
                'NOOPERATIONPERMISSIONS',//没有更多操作权限
                'ALLOCATE',//分配
                'EDIT',//编辑
                'SHARE',//共享
                'SUBMITAPPROVAL',//提交审批
                'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
                'RETRACEMENT',//回撤
                'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
                'RETREATSUCCEEDED',//回撤成功
                'COPY',//复制
                'DELETE',//删除
                'SUREWANTDELETE',//确定要删除吗？
                'DELETESUCCESSFUL',//删除成功
                'RECEIVE',//领取
                'SUREYOUWANTCOLLECT',//确定要领取？
                'SUCCESSFULLYRECEIVED',//领取成功
                'InventoryQuery',//即时库存查询
                'INVENTORYINQUIRY',//库存查询
                'ALLSELECT',//全选
                'LBL_UNREADEN',//未读
                'LBL_READEN',//已读
                'LBL_SENDED',//我发送的
                'SetAllAsRead',//全部标为已读
                'NONUMBERTODIAL',//没有可拨打号码
                'CREATETMPQUICKLY',//是否快速创建%s？
            );
            $fixedlabel_arr = TransFieldlabel($label_arr);
            $fixedlabel_arr = CombineLabelSolution('%s','NOADVANCEDSEARCHCONDITIONS',$fixedlabel_arr);// 没有更多%s数据
            $fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
            $fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
            $fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);
            $fixedlabel_arr = CombineLabelSolution('%s','CREATETMPQUICKLY',$fixedlabel_arr);
            
            //列表内容
            $label_arr=array(
                'RELATIONAL',//关联
                'TOBEALLOCATED',//待分配
                'BEURGED',//已催单
                'INPROCESS',//处理中
                'CLOSEDBILL',//已结单
                'MORE',//更多
                'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
                'DISCUSSIONGROUP',//讨论组
                'ALLOCATE',//分配
                'NOOPERATIONPERMISSIONS',//没有更多操作权限
                'EDIT',//编辑
                'SHARE',//共享
                'RECEIVE',//领取
                'SUREYOUWANTCOLLECT',//确定要领取？
                'URGE',//催单
                'CLOSEBILL',//结单
                'REOPEN',//重新打开
                'SUBMITAPPROVAL',//提交审批
                'RETRACEMENT',//回撤
                'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
                'COPY',//复制
                'DELETE',//删除
                'SuccessDeleted',//删除成功！
                'SUREWANTDELETE',//确定要删除吗？
                'SUCCESSFULLYRECEIVED',//领取成功
                'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
                'RETREATSUCCEEDED',//回撤成功
                'SURETOASSOCIATE',//确定要关联吗？
                'NONUMBERTODIAL',//没有可拨打号码
                'CREATETMPQUICKLY',//是否快速创建%s？
                'QTY',
                'MAOHAO'
            );
            $fixedlabel_content_arr = TransFieldlabel($label_arr);
            $fixedlabel_content_arr = CombineLabelSolution('%s','CREATETMPQUICKLY',$fixedlabel_content_arr);
            $this->jsonArr['arrFixedLabel_content']=$fixedlabel_content_arr;
        }
        $this->jsonArr['arrFixedLabel']=$fixedlabel_arr;
        return $this->jsonArr;
    }
    //设置sql语句是否需要带明细分录表连接
    public function setQueryWithDetail($queryWithDetail)
    {
        $this->queryWithDetail = $queryWithDetail;
    }

    public function getQueryWithDetail()
    {
        return $this->queryWithDetail;
    }

}

