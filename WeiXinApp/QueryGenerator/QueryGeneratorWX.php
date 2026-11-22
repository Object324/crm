<?php

/**
 * Created by PhpStorm.
 * User: gyq161216
 * Date: 2016/12/16 0016
 * Time: 下午 2:38
 */
class QueryGeneratorWX extends QueryGenerator
{
    public $query;
    public $searchcontentwhere;

    protected $lastmodified_mark = 1;

    public  static function getInstance($module, $user,$customview='',$productDetails='',$isSingle='yes')
    {
        if(isset(self::$_instance_queryGenerator[$module])&&$isSingle=='yes')
        {

            return self::$_instance_queryGenerator[$module];
        }
        if(get_file_address($module,"ProductDetails"))
        {
            if($module=='ServiceCharge')
            {
                crm_load_class_file('ServiceChargeQueryGeneratorWX', 'WeiXinApp/QueryGenerator');
                self::$_instance_queryGenerator[$module]=new ServiceChargeQueryGeneratorWX($module, $user,$customview,$productDetails);
            }else if($module=='WorkSheet'){
                    
                    crm_load_class_file("WorkSheetQueryGeneratorWX",'WeiXinApp/QueryGenerator');
                    self::$_instance_queryGenerator[$module]=new WorkSheetQueryGeneratorWX($module, $user,$customview,$productDetails);
            }
            else
            {
                crm_load_class_file('ProductQueryGeneratorWX', 'WeiXinApp/QueryGenerator');
                self::$_instance_queryGenerator[$module]=new ProductQueryGeneratorWX($module, $user,$customview,$productDetails);
            }
        }
        else if($module=='PublicAnnouncement')
        {
            crm_load_class_file("ReceiptQueryGeneratorWX",'WeiXinApp/QueryGenerator');

            self::$_instance_queryGenerator[$module]=new ReceiptQueryGeneratorWX($module, $user,$customview,$productDetails);

        }
        else if(get_file_address($module,'ContactsDetails'))
        {
            crm_load_class_file("AccountsQueryGeneratorWX",'WeiXinApp/QueryGenerator');

            self::$_instance_queryGenerator[$module]=new AccountsQueryGeneratorWX($module, $user,$customview,$productDetails);

        }
        else if(get_file_address($module,'VendorsDetails'))
        {
            crm_load_class_file("VendorsQueryGeneratorWX",'WeiXinApp/QueryGenerator');
            self::$_instance_queryGenerator[$module]=new VendorsQueryGeneratorWX($module, $user,$customview,$productDetails);
        }
        else if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            crm_load_class_file("TabDetailQueryGeneratorWX",'WeiXinApp/QueryGenerator');
            self::$_instance_queryGenerator[$module]=new TabDetailQueryGeneratorWX($module, $user,$customview,$productDetails);
        }
        else if($module=='InventoryQuery')
        {
            crm_load_class_file("InventoryQueryGenerator",'include/QueryGenerator');
            self::$_instance_queryGenerator[$module]=crm_load_class_obj('InventoryQueryGenerator','include/QueryGenerator',array($module, $user,$customview,$productDetails));
        }
        else if($module=='InventoryAccount')
        {
            crm_load_class_file("InventoryAccountQueryGenerator",'include/QueryGenerator');
            self::$_instance_queryGenerator[$module]=crm_load_class_obj('InventoryAccountQueryGenerator','include/QueryGenerator',array($module, $user,$customview,$productDetails));
        }
        else if($module=='Documents' || $module=='Attachment')
        {
            crm_load_class_file("AttachmentQueryGeneratorWX",'WeiXinApp/QueryGenerator');

            self::$_instance_queryGenerator[$module]=new AttachmentQueryGeneratorWX($module, $user,$customview,$productDetails);

        }
        else if($module=='Reminds')
        {
            crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
            self::$_instance_queryGenerator[$module]=new RemindsQueryGenerator($module, $user,$customview)  ;
        }
        else if($module=='Calendar')
        {   //editor:gyq_109 reason:日程管理模块  2019/4/29 16:55
            crm_load_class_file('CalendarQueryGeneratorWX','WeiXinApp/QueryGenerator');
            self::$_instance_queryGenerator[$module]=new CalendarQueryGeneratorWX($module, $user,$customview)  ;
        }
        else
        {
            self::$_instance_queryGenerator[$module]=new QueryGeneratorWX($module, $user,$customview);

        }
        return  self::$_instance_queryGenerator[$module];
    }


    public function __construct($module, $user,$customerview=null,$productDetails=null) {
        parent::__construct($module, $user,$customerview,$productDetails);

        $this->productDetails=$productDetails;
        if(isset($this->productDetails))
             $this->productDetails->querygenerator=$this;
    }

    public function getQuery($popup = '', $type = '')
    {
        if(!empty($_REQUEST['related_module'])){
            //editor:gyq_20180813 0034743: （珞落计划企业微信登录）市场活动相关创建销售机会保存时，市场活动相关销售机会列表界面不显示该单据
            unset(self::$_instance_queryGenerator[$this->module]);
           $relate_info = $this->getRelatedQuery();
           $this->whereFieldTables = $relate_info['whereFieldTables'];
           $this->whereFieldTableJoinType = $relate_info['whereFieldTableJoinType'];
       }
        //editor:gyq_20181011 reason:批量分配的提醒，点击后进入单据序时簿
        $page_query_seaction = '';
        if(isset($_REQUEST['second_action'])){
            $second_action = $_REQUEST['second_action'];
            $second_para = $_REQUEST['second_para'];
            if($second_action=='mass_remind' && !empty($second_para)){
                require_once globalStatic::$root_directory.'WeiXinApp/modules/Reminds/cls_remindsWX.php';
                $remindobj = new cls_remindsWX();
                $page_query_seaction = $remindobj->get_mass_remind($second_para,$this);
                $this->whereClause= ' where 1=1 ';
                //editor:gyq_147 reason:扬锻销售报表  2019/9/29 20:30 
            }else if($second_action=='report_list' && !empty($second_para)){
                //zxm 自定义统计图 穿透参数
                $baseTable = $this->moduleobj->table_name;
                $moduleTableIndexList = $this->moduleobj->tab_name_index;
                $baseTableIndex = $moduleTableIndexList[$baseTable];
                $page_query_seaction = " AND $baseTable.$baseTableIndex in ($second_para)";
                $this->whereClause= ' where 1=1 ';
            }elseif ($second_action=='saleskit_yangduan'){
                require_once globalStatic::$root_directory.'WeiXinApp/modules/Dashboard/report_saleskit_yangduan.php';
                $report_obj = new report_saleskit_yangduan(null);
                $this->whereClause = $report_obj->listview_where($this->module);
            }
        }
        $sql= parent::getQuery($popup, $type); // TODO: Change the autogenerated stub
        if($type==1){
            if(!empty($this->searchcontentwhere))
                $sql.= ' and '.$this->searchcontentwhere;
            $sql .= $relate_info['list_query'];
            $sql .= $page_query_seaction;
        }
        return $sql;
    }
    //相关信息
    public function getRelatedQuery(){
        $related_query = '';
        if(!empty($_REQUEST['related_id'])&&!empty($_REQUEST['related_module'])&&!empty($_REQUEST['recordid'])){
            $focus=$this->moduleobj;
            $detailComFun = crm_load_class_obj('cls_DetailView_CommonFun', 'WeiXinApp/include');
            $related_info = $detailComFun->jsongetModuleRelatedDetails($_REQUEST['related_module'],$_REQUEST['recordid'],$_REQUEST['related_id']);
            //$related_query = $related_info['list_query'];
        }
        return $related_info;
    }

    public function addStdSearchContentWX($lastmodified){
        if(!empty($lastmodified) && $lastmodified!='unlimit') {
            include_once(globalStatic::$root_directory.'modules/CustomView/CommonView.php');
            $dateArr = CommonView::stdFilterDateTimeStr($lastmodified);
           
            global $adb;
            $fieldobj = Field::getInstance($this->module, $adb);
            $fieldname = $fieldobj->getFieldInfoBykeyValue('columnname', 'modifiedtime', 'fieldname');

            $newTime[] = $dateArr[$lastmodified][0] . ' 00:00:00';
            $newTime[] = $dateArr[$lastmodified][1] . ' 23:59:59';
            // 0025852: （微信端iphone6s plus）客户、联系人：筛选-最新更新时间，除了“不限”之外的条件都筛选不出单据
            //$this->startGroup("and");
            //$this->startGroup(self::$AND);
            if(!empty($this->conditionals)){
                $this->startGroup(self::$AND);
            }else{
                $this->startGroup('');
            }
            $this->addCondition($fieldname, $newTime, 'BETWEEN', $tablename);
            $this->endGroup();


        }
    }
    //gyqTS 显示列方法暂定  gyq_32  删除
   /* public function getSelectClauseColumnSQL(){
        $columns = '';
        foreach($_REQUEST['displayColumns'] as $val){
            $columns .= $val['tablename'].'.'.$val['columnname'].',';
            $this->selecttables[$val['tablename']]='';//gyqCom0313
        }
        $columns = rtrim($columns,',');
        $this->columns = $columns;
        return $this->columns;
    }*/
}


?>