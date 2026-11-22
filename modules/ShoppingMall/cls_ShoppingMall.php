<?php
class cls_ShoppingMall
{
    public $Module = 'ShoppingMall';
    public $DataModule = 'Products';
    public $QuantityDecimal=0;
    public $PriceDecimal=2;
    public $list_max_entries_per_page_new=20;
    public function __construct()
    {
        global $current_user;
        $system_deploy_49 = getSys_deploy(49);
        $this->QuantityDecimal = $system_deploy_49['deploy_value'];//数量小数位
        $system_deploy_93 = getSys_deploy(93);
        $this->PriceDecimal = $system_deploy_93['deploy_value'];//单价小数位

        //每页显示条数 按订货商城模块设置的
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
        //wym 230605 获取该模块列表最多条数
        //wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
        $list_max_entries_per_page_new=getUsersettingByLabel($this->Module,$this->current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($this->Module,1,'MaxEntriesPerPage');
        $this->list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

    }
    //列表页面
    public function index()
    {
        $smarty = new lingdangCRM_Smarty();
        $Module = $this->Module;//当前模块
        $smarty->assign("MODULE", $Module);

        $this->getTreeData($smarty);//树结构

        $productdata = $this->getListData($smarty);
        //价格 显示优惠价 产品属性的价格
        $smarty->assign("productdata",$productdata);
        $smarty->display('ListView.tpl');
    }
    public function getListData($smarty){
        global $current_user,$adb;
        $DataModule = $this->DataModule;//数据模块 目前数据是来源产品模块
        $Module = $this->Module;//当前模块  订货商城模块

        $focus = CRMEntity::getInstance($DataModule);
        $Shopfocus = CRMEntity::getInstance($Module);
        // Custom View
        $customView = CustomView::getInstance($DataModule);
        $viewid = $customView->getViewId($DataModule);
        $smarty->assign("VIEWID", $viewid);

        $Shopfocus->getModuleLogic($Module)->getListViewButtons();

        $queryGenerator =  QueryGenerator::getInstance($DataModule, $current_user,$customView);
        //基本查找
        if(isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1'
            && isset($_SESSION['LiveViewSearch'][$Module])) {
            $input = $_SESSION['LiveViewSearch'][$Module]['input'];
            global $search_session;
            $search_session = 1;
            if ($input['searchtype'] == 'BasicSearch') {
                if (!empty($input['search_text'])) {
                    $_REQUEST['search_field'] = $input['search_field'];
                    $_REQUEST['search_text'] = $input['search_text'];
                    $_REQUEST['SearchScope'] = $input['SearchScope'];
                    $_REQUEST['searchtype'] = $input['searchtype'];
                    $_REQUEST['type'] = $input['type'];
                } else {
                    $search_session = 0;
                    unset($_SESSION['LiveViewSearch'][$Module]);
                }
            }
        }
        $queryGenerator->initForCustomViewById($viewid);
        $url_string = '';
        if($_REQUEST['query'] == 'true') {
            $_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
            //不知道原因这个参数值带上了反义符号 ,去掉就好了
            $_REQUEST['search_field_arr'] = stripslashes($_REQUEST['search_field_arr']);
            $queryGenerator->addUserSearchConditions($_REQUEST);
            /**
             * query=true时 把搜索参数存入session中
             * @project 序时簿查询记住搜索条件
             * @author Tujt 2014-04-25
             */
            if ($_REQUEST['searchtype'] == 'BasicSearch') {
                $_REQUEST['search_text'] = trim($_REQUEST['search_text']);
                $searcharr = explode(':', $_REQUEST['search_field']);
                //18399: 回款计划、付款计划、收款单、付款单、费用报销单、佣金单、提现单、存现单-序列表界面：基本查找，按照金额等于0查找，结果基本查找区块会自动收起
                if ($_REQUEST['search_text'] != '' || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr) - 1])) {
                    $input['search_field'] = trim($_REQUEST['search_field']);
                    $input['search_text'] = trim($_REQUEST['search_text']);
                    $input['SearchScope'] = trim($_REQUEST['SearchScope']);
                    $input['searchtype'] = trim($_REQUEST['searchtype']);
                    $input['type'] = trim($_REQUEST['type']??'');
                } else {
                    unset($_SESSION['LiveViewSearch'][$Module]);
                }
            }
            ////上一页和下一页点击使用使用
            $ustring = getSearchURL($_REQUEST);
            $url_string .= "&query=true$ustring";
            $smarty->assign('SEARCH_URL', $url_string);

            if(!empty($input)){
                $_SESSION['LiveViewSearch'][$Module]['input'] = $input;
                $_SESSION['LiveViewSearch'][$Module]['url'] = $url_string;
                $smarty->assign('SEATCH_INPUT',$input);
            }
        }
        $page_list_query = $queryGenerator->getQuery('','groupby');
        //订货商城--移动端加了上架条件的 这里保持一致
        $page_list_query .= " and ld_products.productid in (select productid from ld_shop_productproperty where productstatus = '上架')";

        $count_result = $adb->query($page_list_query);
        $noofrows = $adb->num_rows($count_result);
        if(empty($order_by)){
            list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
        }
        ListViewSession::setSessionQuery($Module,$page_list_query,$viewid);
        $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
        $start = ListViewSession::getRequestCurrentPage($Module, $noofrows, $viewid, $queryMode);

        $navigation_array = VT_getSimpleNavigationValues($start,$this->list_max_entries_per_page_new,$noofrows);
        $table_id_index=$focus->table_index;

        $limit_start_rec = ($start-1) * $this->list_max_entries_per_page_new;
        $from  = $queryGenerator->getFromClause();
        $fieldlist = [];
        $list_fieldname = $Shopfocus->getlist_fieldname();
        foreach($list_fieldname as $tmpfieldname){
            $fieldlist[] = $Shopfocus->table_name.'.'.$tmpfieldname;
        }
        $smarty->assign("list_fieldname", $list_fieldname);
        $fieldlist_str = implode(',',$fieldlist).',';
        $list_query =' select '.$fieldlist_str.' ld_products.productid,property_status '.$from.' inner join ( '.$page_list_query. " LIMIT $limit_start_rec, $this->list_max_entries_per_page_new ) as tmp
             on tmp.$table_id_index=".$focus->table_name.'.'.$table_id_index;

        list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);
        $list_result = $adb->pquery($list_query, array());
        $productdata = $this->getProductsArr($focus,$list_result,$page_list_query,$limit_start_rec);
        $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
        $smarty->assign("Encrypt_page_list_query",$cls_MyCRMcryptobj->encode($page_list_query));
        // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
        $smarty->assign("Encrypt_TreeWhere", $cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));


        Crm_load_class_file("CommonView","modules/CustomView");
        $smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

        //基本查找
        $controller = new ListViewController($adb, $current_user, $queryGenerator);
        $listview_header_search = $controller->getBasicSearchFieldInfoList();
        $smarty->assign('SEARCHLISTHEADER',$listview_header_search);


        //hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
        $smarty->assign("TABNAME", getParentTab());
        $smarty->assign("STARTPAGE", ceil($start));
        $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
        $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$this->list_max_entries_per_page_new));
        $smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($this->list_max_entries_per_page_new)));
        //zxm 20230614 获取列表页面公共参数并assign到tpl
        ListViewCommonAssign($Module,$smarty,$Shopfocus);

        $smarty->assign('LINKMODULECUSTOM', false);//不显示设置按钮
        $smarty->assign('HIGBTNSTATUS', 'no');
        $smarty->assign('TILEDBTNSTATUS', 'no');
        $smarty->assign('TAGBTNSTATUS', 'no');
        $smarty->assign('noofrows', $noofrows);
        return $productdata;
    }
    public function getProductsArr($focus,$list_result,$page_list_query,$limit_start_rec){
        global $adb;
        $productdata = [];
        $table_id_index=$focus->table_index;
        $nums = $adb->num_rows($list_result);
        //获取主表图片 每个产品只要一个图 --todo--
        $imgArr = [];
        $imgSql = "SELECT
	a.attachmentcolumnname,
	b.storage_location,
	b.path,
	b.newfile_name,
	b.cloud_path,
	a.crmid
FROM
	ld_seattachmentsrel a
LEFT JOIN ld_attachments b ON a.attachmentsid = b.attachmentsid
inner join  ( ".$page_list_query. " LIMIT $limit_start_rec, $this->list_max_entries_per_page_new ) as tmp on tmp.$table_id_index=a.crmid order by b.attachmentsid asc ";
        $imgres = $adb->pquery($imgSql);
        $imgnum = $adb->num_rows($imgres);
        $defaultimg = 'themes/ldmallimg/goods/default_cartimg.png';
        if($imgnum>0){
            for($j=0;$j<$nums;$j++) {
                $tmpproductid = $adb->query_result($imgres,$j,'crmid');
                if(!isset($imgArr[$tmpproductid])){
                    $temp_attachmentcolumnname = $adb->query_result($imgres,$j,'attachmentcolumnname');
                    $temp_storage_location = $adb->query_result($imgres,$j,'storage_location');
                    $temp_path = $adb->query_result($imgres,$j,'path');
                    $temp_newfile_name = $adb->query_result($imgres,$j,'newfile_name');
                    $temp_cloud_path = $adb->query_result($imgres,$j,'cloud_path');
                    //封面
                    $imgArr[$tmpproductid] = $defaultimg;
                    if($temp_attachmentcolumnname=="imagename"){
                        if($temp_storage_location == "cos"){
                            $imgArr[$tmpproductid] = $temp_cloud_path;
                        }
                        if($temp_storage_location == "local"){
                            $imgArr[$tmpproductid] = $temp_path.$temp_newfile_name;
                        }
                    }
                }
            }
        }
        $Module = $this->Module;//当前模块  订货商城模块
        $Shopfocus = CRMEntity::getInstance($Module);
        $list_fieldname = $Shopfocus->getlist_fieldname();
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $productid = $adb->query_result($list_result,$i,'productid');

                $tmppdata = ['productid'=>$productid];
                $tmppdata = ['property_status'=>$adb->query_result($list_result,$i,'property_status')];
                foreach($list_fieldname as $tmpfieldname){
                    $tmppdata[$tmpfieldname] = $adb->query_result($list_result,$i,$tmpfieldname);

                }
                $productdata[$productid] = $tmppdata;

                $unit_price = $adb->query_result($list_result,$i,'unit_price');
                if($focus->ProductPropertyIsActive=='no') {
                    //价格策略
                    $unit_price = $focus->getShopProPrice($productid,$unit_price,1);//放到后面计算
                }
                $productdata[$productid]['unit_price'] = number_format((float)$unit_price,$this->PriceDecimal,".","");

                $productdata[$productid]['imagename'] = isset($imgArr[$productid])?$imgArr[$productid]:$defaultimg;

            }

            if($focus->ProductPropertyIsActive=='yes') {
                crm_load_class_file('ProductPropertyUtils', 'modules/Products');
                //先获取默认的属性组合
                $defaultproperty_info = ProductPropertyUtils::getDefaultPropertyByProductid(implode(',',array_keys($productdata)));
                $productdetail_lineitem_id_str = implode(',',array_values($defaultproperty_info));

                $productproperty_info = ProductPropertyUtils::getPropertyInfoByProductDetailId($productdetail_lineitem_id_str);
                foreach($productdata as $tmpproductid=>$productinfo){

                    $tmpproductdetail_lineitem_id = $defaultproperty_info[$tmpproductid];
                    //开启产品属性的产品才去找属性组合的价格
                    if($productinfo['property_status']==1&&isset($productproperty_info[$tmpproductdetail_lineitem_id])&&$productproperty_info[$tmpproductdetail_lineitem_id]>0) {
                        $unit_price_tmp = $productproperty_info[$tmpproductdetail_lineitem_id]['line_unit_price'];//取按属性设置的价格

                        //$quantity = $productinfo['quantity'];
                        //$unit_price = $focus->getShopProPrice($tmpproductid,$unit_price_tmp, $quantity);//价格策略
                        //--价格政策//应该在getShopProPrice方法中去处理吧?

                        $unit_price = number_format((float)$unit_price_tmp,$this->PriceDecimal,".","");
                        $productdata[$tmpproductid]['unit_price'] =$unit_price;
                    }
                }
            }
        }
        return $productdata;
    }
    public function getTreeData($smarty){
        //$Module = $this->DataModule;
        $Module = $this->Module;
        //zkt 列表界面增加树结构显示
        crm_load_class_file('cls_Module_Tree', 'include/utils');
        $cls_module_tree = cls_Module_Tree::getInstance($Module);

        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
        {

        }
        else
        {
            if($cls_module_tree->moduleenable=='yes'){
                //加载初始listview树状结构
                $modulelisttree = $cls_module_tree->getModuleListTree();
                $smarty->assign('MODULElISTTREE',$modulelisttree);
                $module_list_treeselectrecord=0;
                //若$_SESSION中储存的selectrecord值,为级联下拉值id，设置selectrecord为0（或获取下级对应html）
                if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$Module]['selectrecord']])){
                    //$_SESSION['module_list_tree'][$Module] = array('selectrecord'=>0,'list'=>array());
                    //获取下级对应html
                    $sessionarr = $_SESSION['module_list_tree'][$Module];

                    $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
                    $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
                }
            }
            //获取设置选中的树结构id和list
            $module_list_treeselectrecord=0;
            if(isset($_SESSION['module_list_tree'][$Module])){
                $module_list_treeselectrecord= $_SESSION['module_list_tree'][$Module]['selectrecord'];
            }
            $smarty->assign('MODULE_TREE_PICKLIST_ID',$module_list_treeselectrecord);
        }
    }
}