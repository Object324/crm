<?php

require_once(globalStatic::$root_directory . 'include/upload/FileUtil.php');

// Account is used to store ld_account information.

class SalesOrder extends CRMEntity
{
    static function require_file($requiremodules = '')
    {
        globalStatic::$arr_module_require['SalesOrder'] = 'SalesOrder';
        if (empty(globalStatic::$arr_module_require['Accounts'])) {
            globalStatic::$arr_module_require['Accounts'] = 'Accounts';
            include(globalStatic::$root_directory . 'modules/Accounts/Accounts.php');
        }
        if (!empty($requiremodules) && empty(globalStatic::$arr_module_require[$requiremodules])) {
            include(globalStatic::$root_directory . "modules/$requiremodules/$requiremodules.php");
            globalStatic::$arr_module_require[$requiremodules] = $requiremodules;
        }
    }

    var $Detail_table = "ld_salesorderdetail";//明细表名称
    var $Detail_table_id = "lineitem_id";//明细表主表和自定义表关联字段
    var $Detail_table_scf = "ld_salesorderdetailscf";//明细scf表
    var $Detail_table_index = "id";//明细表和主表关联的字段
    var $echokis = '';//金蝶同步错误信息
    var $log;
    var $db;
    var $module_name = 'SalesOrder';
    var $table_name = "ld_salesorder";
    var $table_index = 'salesorderid';
    var $table_code = 'salesorder_no';//表编号字段(审批中心)
    var $tab_name = array('ld_crmentity', 'ld_salesorder', 'ld_salesordercf');//'ld_invoice_recurring_info'
    var $tab_name_index = array('ld_crmentity' => 'crmid', 'ld_salesorder' => 'salesorderid', 'ld_salesordercf' => 'salesorderid');//'ld_invoice_recurring_info'=>'salesorderid'
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab = array('salesorder' => '', 'accounts' => '', 'potentials' => '', 'contacts' => '', 'users' => '', 'products' => '', 'company' => '', 'quotes' => '',);
    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = array('ld_salesordercf', 'salesorderid');
    var $entity_table = "ld_crmentity";

    var $billadr_table = "ld_sobillads";

    var $object_name = "SalesOrder";

    var $new_schema = true;

    var $update_product_array = array();

    var $column_fields = array();

    var $sortby_fields = array('subject', 'smownerid', 'accountname', 'lastname');

    // This is used to retrieve related ld_fields from form posts.
    var $additional_column_fields = array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id');


    var $list_link_field = 'subject';

    var $search_fields = array(
        'Order No' => array('salesorder' => 'salesorder_no'),
        'Subject' => array('salesorder' => 'subject'),
        'Account Name' => array('account' => 'accountid'),
        'Quote Name' => array('salesorder' => 'quoteid')
    );

    var $search_fields_name = array(
        'Order No' => 'salesorder_no',
        'Subject' => 'subject',
        'Account Name' => 'account_id',
        'Quote Name' => 'quote_id'
    );

    // This is the list of ld_fields that are required.
    var $required_fields = array("accountname" => 1);

    //Added these variables which are used as default order by and sortorder in ListView
    var $default_order_by = 'subject';
    var $default_sort_order = 'ASC';
    //var $groupTable = Array('ld_sogrouprelation','salesorderid');

    var $mandatory_fields = array('createdtime', 'modifiedtime');

    // For Alphabetical search
    var $def_basicsearch_col = 'subject';
    static $mass_before_focus = array();

    /** Constructor Function for SalesOrder class
     *  This function creates an instance of LoggerManager class using getLogger method
     *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
     */
    function __construct()
    {

        $this->db = PearDatabase::getInstance();
        $this->fieldobj = Field::getInstance('SalesOrder', $this->db);
        $this->column_fields = $this->fieldobj->getFieldArray('fieldname', $this);
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname = getEntitynameByModulename('SalesOrder');

        $this->list_link_field = $entityname['fieldname'];
        $this->moduleName = 'SalesOrder';
        crm_load_class_file('ProductToolFields', 'include/ProductDetails');
        $this->detailfieldobj = ProductToolFields::getInstance($this->module_name);

    }

    public function successApprove($crmid)
    {
        //获取订单同步接口触发点
        $deployarray = getSys_deploy(92);
        if (isset($deployarray['deploy_value']) && $deployarray['deploy_value'] == 0) {
            $focus = CRMEntity::getInstance('SalesOrder');
            $focus->retrieve_entity_info($crmid, 'SalesOrder');
            $focus->id = $crmid;
            if (get_versiontrade() == 'yangduan') {
                crm_load_class_file('cls_interface_yadon', 'include/InterfaceClass');
                $cls_interface_yadon = new cls_interface_yadon();
                $_SESSION['kiserror'] = $cls_interface_yadon->Sales_Synchronous($crmid, 'SalesOrder');
            } else {
                $this->SyDataInterFace($focus);
            }

        }
        /**
         * @reason:基金行业更改合同订单状态生成产品份额交易历史记录
         * @edit: cyb
         * @date: 2016-06-22
         **/
        $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
        if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
            require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
            $trade_class_name = $tradename . '_SalesOrder';
            if (class_exists($trade_class_name)) {
                $trade_focus = new $trade_class_name($this);
                if (method_exists($trade_focus, "redemption_approveStatus")) {
                    $trade_focus->redemption_approveStatus($crmid); //审批完成后，生成交易记录。
                }
            }
        }
        //合同订单审批通过创建服务合同
        $deployarray = getSys_deploy('130');
        if ($deployarray['deploy_value'] == 2) {
            $this->createServiceContracts($crmid);
        }
        $this->autocreateCasbhill($crmid, 'approve');
        //中孚处理
        global $adb;
		$sql='update ld_salesorder set triggercount=triggercount+1 where salesorderid=?';
		$adb->pquery($sql,array($crmid));

    }

    public function createServiceContracts($salesorderid)
    {
        global $adb, $current_user;
        SalesOrder::require_file('ServiceContracts');
        $this->retrieve_entity_info($salesorderid, 'SalesOrder');
        $ser_focus = new ServiceContracts();//不能调用CRMEntity::getInstance(),因为上面创建了OutboundOrder对象


        $signdate = $this->column_fields['signed_data'];
        //41435: （61mis.com/kfbcrm）合同订单模块新增界面>填写数据保存（需要填写“服务类型”字段）：在保存后系统自动生成的服务合同中，服务类型字段的值没有自动带出来。
        $ser_focus->getModuleLogic('ServiceContracts')->setQuickCreateColumnValues('ServiceContracts', $salesorderid);
        $tmp_modulefields = $ser_focus->fieldobj->getModuleFields();
        foreach ($tmp_modulefields as $fieldname => $fieldinfo) {
            if ($fieldinfo->isRelatedModuleField() && $fieldinfo->getSaveDataBase() == 'yes') {
                $_REQUEST[$fieldname] = $ser_focus->column_fields[$fieldname];

            }
            if ($fieldinfo->getBigType() == 'date') {
                //edit:can 46177: （81mis.com/kfbcrm）（客户问题需要补丁）系统设置服务合同的服务到期日默认365天后，在合同订单新建/审批通过后，自动创建的服务合同单据，“服务到期日”是空的
                $showfieldvalue = new ShowFieldValue($ser_focus->fieldobj, 'ServiceContracts', constant('SHOW_EDITVIEW'));
                $showvalue = $showfieldvalue->getFieldValueByField($fieldinfo, $fieldinfo->getDefaultvalue(), $fieldinfo->getDefaultvalue());
                $_REQUEST[$fieldname] = $showvalue['value'];

            }
        }
        $ser_focus->column_fields['account_id'] = $this->column_fields['account_id'];//客户
        $_REQUEST['account_id'] = $this->column_fields['account_id'];
        $ser_focus->column_fields['contact_id'] = $this->column_fields['contact_id'];//联系人
        $_REQUEST['contact_id'] = $this->column_fields['contact_id'];

        $_REQUEST['salesorder_id'] = $salesorderid;//合同订单


        $ser_focus->column_fields['due_date'] = $signdate;//签约日期
        $ser_focus->currency_status = true;

        $ser_focus->column_fields['currency_id'] = $this->column_fields['currency_id'];
        $currencyobj = Currency::getInstance($adb, $ser_focus->column_fields['currency_id']);
        $cur_sym_rate['symbol'] = $currencyobj->getCurrencySymbol();
        $cur_sym_rate['rate'] = $currencyobj->getCurrencyRate();
        $ser_focus->column_fields['conversion_rate'] = $cur_sym_rate['rate'];

        $assigned_user_id = '';


        $salesorder_smownercolumname = $this->getSmownerColumName();
        $salesorder_smownerfieldname = $this->fieldobj->getFieldInfoBykeyValue('columnname', $salesorder_smownercolumname, 'fieldname');

        $servicecontracts_smownercolname = $ser_focus->getSmownerColumName();
        $servicecontracts_smownerfieldname = $ser_focus->fieldobj->getFieldInfoBykeyValue('columnname', $servicecontracts_smownercolname, 'fieldname');
        $ser_focus->column_fields['salesorder_id'] = $salesorderid;//合同订单id
        $_REQUEST['selectsourcename'] = 'SalesOrder';
        $_REQUEST['selectlistval'] = $salesorderid;
        //36574: 系统设置>系统参数设置>业务参数>设置合同订单保存后是否自动创建1年免服务费的服务合同：无论是不是开启图片中的参数，自动创建的服务合同销售负责人都取值为合同订单的负责人。
        $ser_focus->column_fields[$servicecontracts_smownerfieldname] = $this->column_fields[$salesorder_smownerfieldname];
        $_REQUEST[$servicecontracts_smownerfieldname] = $this->column_fields[$salesorder_smownerfieldname];

        $ser_focus->column_fields['hdnGrandTotal'] = 0;
        $ser_focus->column_fields['hdnSubTotal'] = 0;
        $productSql = "select productid,sequence_no,lineitem_id ,quantity from ld_salesorderdetail where id = ? order by lineitem_id ";
        $productResult = $adb->pquery($productSql, array($salesorderid));

        $productTotal = $adb->num_rows($productResult);
        //edit:can 2020-08-27 42527: （61mis.com/kfbcrm）客户问题（北京蝶金时代），合同订单模块>新建单据界面：选择两个“产品”点击保存，然后审批通过系统自动生成“服务合同”只显示一个“产品”（设置合同订单保存后是否自动创建1年免服务费的服务合同:“审核通过时创建”）（需要补丁
        $_REQUEST['rowcnt'] = $productTotal;
        for ($i = 1; $i <= $productTotal; $i++) {
            $_REQUEST['selectSourceModuleid' . $i] = $salesorderid;//源单ID
            $_REQUEST['lineitem_id' . $i] = $adb->query_result($productResult, $i - 1, "lineitem_id");//关联ID
            $_REQUEST['entitytype' . $i] = 'SalesOrder';//源单模块
            $_REQUEST['quantity' . $i] = $adb->query_result($productResult, $i - 1, "quantity");
            $_REQUEST['lineitem_id' . $i] = $adb->query_result($productResult, $i - 1, "lineitem_id");//关联ID
            $_REQUEST['hdnProductId' . $i] = $adb->query_result($productResult, $i - 1, "productid");
            $_REQUEST['hidden_rowid_' . $i] = 0;
            $_REQUEST['servicecontracts_start_date' . $i] = $signdate;
            $_REQUEST['servicecontracts_end_date' . $i] = DateOperation::get_nyears_later_date($signdate);
            $_REQUEST['listprice' . $i] = 0;
            $_REQUEST['taxprice' . $i] = 0;
            $_REQUEST['tax_amount' . $i] = 0;
            $_REQUEST['list_amount' . $i] = 0;
            $_REQUEST['discount_percent' . $i] = 100;
            $_REQUEST['entitytype' . $i] = 'SalesOrder';
            $_REQUEST['entitytypeid' . $i] = $salesorderid;
        }

        $_REQUEST['subtotal'] = 0;
        $_REQUEST['total'] = 0;
        $ser_focus->column_fields['description'] = getFixedLabel('AUTOCREATE');
        $ser_focus->mode = "Create";
        $_REQUEST['mode'] = "Create";
        $_REQUEST['record'] = 0;
        $tmfiles = $_REQUEST['filename-file_num'];
        setObjectValuesFromRequest($ser_focus);
        //043417: （本地php54，8.3.1版本）销售管理-合同订单；系统设置中“设置合同订单保存后是否自动创建1年免服务费的服务合同”保存后，自动生成的服务合同分录中币种不显示
        $ser_focus->column_fields['currency_id'] = $this->column_fields['currency_id'];
        //edit:can 2020-12-31 43834: （https://61mis.com/kfbcrm [^]）通过参数自动新建的服务合同的合计不显示币种符号
        $ser_focus->column_fields['currency_symbol'] = decode_html($cur_sym_rate['symbol']);
        $_REQUEST['filename-file_num'] = 0;
        $ser_focus->save('ServiceContracts');
        /*if (!empty($ser_focus->id)) {
            $query = "update ld_servicecontracts set entitytype = ?,source_list = ?,total = 0 where servicecontractsid = ?";
            $adb->pquery($query, array('SalesOrder', $salesorderid, $ser_focus->id));
        }*/
        $_REQUEST['filename-file_num'] = $tmfiles;
        $_REQUEST['record'] = $salesorderid;//35407: （1.6账套）合同订单明细界面>提交审批：审批成功后，显示单据已删除。

    }

    /*
    根据系统参数控制自动创建收款单
    */
    public function autocreateCasbhill($salesorderid, $operationtype)
    {
        $deploy_values = getSys_deploy(162);
        $deploy_value = $deploy_values['deploy_value'];
        if (empty($deploy_value)) {
            return;
        } else if ($deploy_value == 1 || $deploy_value == 3) { //wym 240223 XUQIU20240204-05 免费的 销售订单/服务合同 可以设置不生成收款单
            if (strtolower($this->mode) == 'edit' || $operationtype != 'create') {
                return false;
            }
        } else if ($deploy_value == 2 || $deploy_value == 4) {
            if ($operationtype != 'approve') {
                return false;
            }
        }
        crm_load_class_file("CashBill", "modules/CashBill");

        $this->retrieve_entity_info($salesorderid, 'SalesOrder');

        $cashbillfocus = new CashBill();

        $_REQUEST['account_id'] = $this->column_fields['account_id'];
        $_REQUEST['currency_id'] = $this->column_fields['currency_id'];
        $_REQUEST['entitytypeid1'] = $salesorderid;
        $_REQUEST['deleterow1'] = 0;
        //edit:can 48171: （https://81mis.com/kfbcrm/index.php? [^]）销售管理》合同订单》新建，新建的合同订单自动创建了收款单，但是收款单详情界面选择源单没有源单
        $_REQUEST['selectlistval'] = $salesorderid;
        //editor:gyq_161 reason:本次收款金额Key值改动  2019/11/26 18:45
        //$_REQUEST['curCashBill1']=$this->column_fields['receivable_balance'];
        $_REQUEST['amount1'] = $this->column_fields['receivable_balance'];


        if (empty($this->column_fields['receivable_balance'])) {
            //$_REQUEST['curCashBill1']=0;
            $_REQUEST['amount1'] = 0;
        }
        $_REQUEST['cashbill_total'] = $this->column_fields['receivable_balance'];
        if ($operationtype == 'create') {
            //edit:can 20210719 46988: （https://81mis.com/kfbcrm [^]）（客户问题-需要补丁）销售管理-合同订单-新增/复制；合同订单保存后，系统自动新建了收款单，收款单详情的本地收款金额为0，没有等于合同金额
            $_REQUEST['amount1'] = $this->column_fields['hdnGrandTotal'];
            $_REQUEST['cashbill_total'] = $this->column_fields['hdnGrandTotal'];
        }
        //wym 240223 XUQIU20240204-05 免费的 销售订单/服务合同 可以设置不生成收款单
        if ($deploy_value == 3 || $deploy_value == 4) {
            if((int)$_REQUEST['amount1']==0) {
                return false;
            }
        }
        $_REQUEST['selectsource'] = $this->module_name;
        $_REQUEST['selectsourcename'] = $this->module_name;
        $_REQUEST['detail_sequence1'] = 1;
        $smownerfieldname = $this->fieldobj->getFieldInfoBykeyValue("uitype", 53, 'fieldname');
        $cashbillsmownerfieldname = $cashbillfocus->fieldobj->getFieldInfoBykeyValue("uitype", 53, 'fieldname');
        $_REQUEST[$cashbillsmownerfieldname] = $this->column_fields[$smownerfieldname];
        //37265: 后台设置创建合同订单自动生成一个服务合同，合同订单里有附件，生成的服务合同也把附件也带过来了，怎么可以取消
        $tmfiles = $_REQUEST['filename-file_num'];
        $_REQUEST['filename-file_num'] = 0;
        $cashbillfocus->autocreateCasbhill($this);
        $_REQUEST['filename-file_num'] = $tmfiles;
    }

    /**
     * @reason 反审批结束操作函数
     * @edit cyb
     * @date 2016-06-23
     **/
    public function rejectApproved($record)
    {

        $this->deleteKisDataAfterApprove($record);
        /**
         * @reason:基金行业更改合同订单状态生成产品份额交易历史记录
         * @edit: cyb
         * @date: 2016-06-23
         **/
        $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
        if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
            require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
            $trade_class_name = $tradename . '_SalesOrder';
            if (class_exists($trade_class_name)) {
                $trade_focus = new $trade_class_name($this);
                if (method_exists($trade_focus, "cancelApproved")) {

                    $trade_focus->cancelApproved($record, $this->module_name); //每一次反审批操作结束，生成交易记录。
                }
            }
        }
        global $adb;
		$sql='update ld_salesorder set triggercount=triggercount+1 where salesorderid=?';
		$adb->pquery($sql,array($record));
    }

    function getKisError()
    {
        return $this->echokis;
    }

    function special_ImportXls()
    {

        $this->trade_fun("addNewlybuy");

    }

    private function trade_fun($methodname)
    {
        $trade = getVersionTradeInfo();
        $tradename = ucwords($trade['trade']);

        if (!empty($tradename) && file_exists("include/trade/$tradename/$tradename" . "_SalesOrder.php")) {
            require_once("include/trade/$tradename/$tradename" . "_SalesOrder.php");
            $tradeclass = $tradename . "_SalesOrder";
            if (class_exists($tradeclass)) {
                $trademodule = $tradename . "_SalesOrder";
                $tradefocus = new $trademodule($this);
                if (method_exists($tradefocus, $methodname)) {
                    $tradefocus->$methodname($this->id);//金融行业合同订单保存生成交易历史


                }
            }

        }
    }

    function save_module($module)
    {

        global $adb, $current_user;
        $languageType = getLanguageType($current_user);

        // Update the currency id and the conversion rate for the sales order
        //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        //25906: pc端 合同订单 订单编号 SO11-15626 新建合同订单 币种选择欧元 。关联创建发票 发票金额253.80欧元到合同订单已开票金额那边看，把253.80欧元当成人民币有换算成欧元了
        if ($this->currency_status === true) {
            $update_query = "update ld_salesorder set currency_id=?, conversion_rate=?,currency_symbol=? where salesorderid=?";
            $update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'], $this->column_fields['currency_symbol'], $this->id);
            $this->db->pquery($update_query, $update_params);
        }

        //in ajax save we should not call this function, because this will delete all the existing product values
        // @edit:dong @date:2021/01/06 @reason: ApiNoEditDetails 防止api接口没有分录数据删除分录
        if ($_REQUEST['action'] != 'SalesOrderAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
            && $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' && $_REQUEST['action'] != 'ApiNoEditDetails') {


            //合同订单明细保存
            // crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            //saveInventoryProductDetails($this, 'SalesOrder');

            crm_load_class_file('saveInventory', 'include/utils');
            $saveInventoryobj = new saveInventory();
            $saveInventoryobj->save($this, 'SalesOrder');
            $this->trade_fun("save");

        }

        //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute', 'include/OptionModule');

        cls_Source_InverseCompute::Source_InveverseCompute($module, $this->id, $this);
        $deployarray = getSys_deploy(48);//灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
        crm_load_class_file('cls_OutSale_InverseCompute', 'include/OptionModule');
        if ($deployarray['deploy_value'] == 1) {
            cls_OutSale_InverseCompute::updateSourceModuleOutboundAmount($this->id, $module);
        }
        /*新增合同订单，给contractid赋值  edit:xiaoshun  date:2016-09-01
       $modules=  getHaveSourceModulebyModule("SalesOrder");
       //saveInventoryProductDetails:函数中有修改conractid,715行左右
       foreach($modules as $tabmodule)
       {
            $tab_focus=CRMEntity::getInstance($tabmodule);
            $detailtablename=$tab_focus->Detail_table;
            $detailtableindex=$tab_focus->Detail_table_index;
            $sql = "update $detailtablename set contractid = id where $detailtableindex = ?";
            $adb->pquery($sql,array($this->id));
       }*/

        /*
         * editor : gyq_02
         * reason : 新增，新建、编辑合同订单更新对应客户最新订单日期，销售机会最新订单日期
         * date   : 2016  1  22
         * explain :
         *       $mass_before_focus : 修改前客户ID或类似ID
         * */

        $accountids = [];
        $potentialids = [];
        foreach ($this->before_field_info as $fieldinfo) {
            //获取保存前客户或销售机会ID
            $columnname = $fieldinfo->getColumnName();//
            $relateid = $fieldinfo->getColumn_Value();
            if ($columnname == 'accountid' && !empty($relateid)) {
                $accountids[$relateid] = $relateid;
            }
            if ($columnname == 'potentialid' && !empty($relateid)) {
                $potentialids[$relateid] = $relateid;
            }
        }
        if (!empty($this->column_fields['account_id']))
            $accountids[$this->column_fields['account_id']] = $this->column_fields['account_id'];

        if (sizeof($accountids) > 0) {
            $this->updateRelatedTableInfo('ld_account', $accountids);

        }
        if (!empty($this->column_fields['potential_id']))
            $potentialids[$this->column_fields['potential_id']] = $this->column_fields['potential_id'];

        if (sizeof($potentialids) > 0) {
            $this->updateRelatedTableInfo('ld_potential', $potentialids);
        }


        /**
         * edit:kevin
         * date:2013-07-22
         * reason:相关客户是否是已分配,分配则改变客户信息
         */
        /*if (isset($_REQUEST['account_id'])) {
            $account = new Accounts();
            $account->updateAccountInfo($module, $_REQUEST['account_id']);
        }*/

        //chj 20220516 订单商城   订单来源
        if ($this->mode != 'edit') {    //create
            if ($_REQUEST['from_mobile'] == 'yes'||(isset($_REQUEST['cartid'])&&!empty($_REQUEST['cartid']))) {
                $order_source = '订货商城';
            } else if ($_REQUEST['from_shopapp'] == 'yes') {
                $order_source = '商城小程序';
            } else {
                $order_source = '合同模块';
            }
            $adb->pquery("update ld_salesorder set order_source = ? where salesorderid = ?", array($order_source, $this->id));
        }
        /**
         * edit:andy
         * date:2014-01-07
         * reason:附件目录，保存合同订单时，判断是否引用了报价单
         *如果引用再判断引用的报价单是否有附件
         *如果包含附件，那么将该附件保存到对应的合同订单附件目录中
         */
        //判断是否引用报价单
        if ($this->column_fields['quote_id'] != '') {
            //判断报价单是否有附件
            $quoteid = $this->column_fields['quote_id'];
            //echo $quoteid;exit;
            $sql = "select * from ld_attachmentsforbills where record =? ";
            $result = $adb->pquery($sql, array($quoteid));
            if ($adb->num_rows($result)) {
                $salesOrderid = $this->id;
                $quotesPath = 'storage/Quotes/' . $quoteid . '/';
                $SalesOrderPath = 'storage/SalesOrder/' . $salesOrderid . '/';
                //如果存在文件夹，将该文件夹复制到对应的额报价单附件文件夹下
                if (is_dir($quotesPath)) {
                    //判断合同订单附件目录是否存在，不存在的话创建附件
                    if (!is_dir('storage/SalesOrder/')) {
                        mkdir('storage/SalesOrder/');
                    }
                    //exit;
                    if (!is_dir($SalesOrderPath)) {
                        mkdir($SalesOrderPath);
                    }
                    //exit;
                    //判断在合同订单附件中创建报价单的附件文件夹
                    if (!is_dir($SalesOrderPath . 'Quotes/')) {
                        mkdir($SalesOrderPath . 'Quotes/');
                    }
                    //exit;
                    $fu = new FileUtil();
                    $fu->copyDir($quotesPath, $SalesOrderPath . 'Quotes/');
                }
            }
        }
        //合同订单交付日期前Ｎ天提醒负责人（为0表示当天提醒，为空表示不提醒
        $deployarray = getSys_deploy(18);
        $deployvalue = $deployarray['deploy_value'];
        //$rowCount = $adb->num_rows($result);

        if ($deployvalue != '') {

            $datetime = date('Y-m-d H:i:s', strtotime($_REQUEST['duedate']) - 60 * 60 * 24 * $deployvalue);
            $entitynames = getEntitynameInfo(getTabid('SalesOrder'));

            if ($_REQUEST['duedate'] != '') {
                $RemindsContent = getFixedLabel('DELIVERYDATEREMINDERINFO') . $_REQUEST[$entitynames['fieldname']];
                $this->AddReminds($RemindsContent, $datetime, $_REQUEST['assigned_user_id'], $this->id);
            }
        }

        /**
         * 新增操作 by andy
         * reason:参数控制创建合同时是否自动更新客户\机会状态
         * data:20140612
         * verson:v5.31
         * others:NONE
         */
        if ($_REQUEST['Create'] == 'yes' && $_REQUEST['sostatus'] != '已作废') {
            //获取系统参数缓存文件值
            $deployarray = getSys_deploy(37);//设置合同订单新增保存后是否更新客户的客户状态字段为
            $deploy_value_37 = $deployarray['deploy_value'];
            $deployarray_38 = getSys_deploy(38);
            $deploy_value_38 = $deployarray_38['deploy_value'];
            //modify Account rating field
            if ($deploy_value_37 != '' && $_REQUEST['account_id'] != '' && $deploy_value_37 != '') {
                $query = 'select rating from ld_account where accountid = ? limit 1';
                $result = $adb->pquery($query, array($_REQUEST['account_id']));
                $rating = $adb->query_result($result, 0, 0);
                // @edit:dong @date:2020/10/21 @reason:  销售订单更新客户类型的时候同时修改修改时间
                $tabid = getTabid('Accounts');
                $query = "select 1 from ld_settings_advance where tabid = ? and module_field = 'rating' and `enable` = 'yes'";
                $result = $adb->pquery($query, array($tabid));
                $num_rows = $adb->num_rows($result);
                if ($num_rows >= 1) {
                    $adb->pquery("UPDATE ld_account set rating = '" . $deploy_value_37 . "',advance_stage = '" . $deploy_value_37 . "',modifiedtime ='" . date('Y-m-d H:i:s') . "'  where accountid =" . $_REQUEST['account_id'] . " and rating != '" . $deploy_value_37 . "'", array());
                } else {
                    $adb->pquery("UPDATE ld_account set rating = '" . $deploy_value_37 . "',modifiedtime ='" . date('Y-m-d H:i:s') . "'  where accountid =" . $_REQUEST['account_id'] . " and rating != '" . $deploy_value_37 . "'", array());
                }

                $account_focus = CRMEntity::getInstance('Accounts');
                $account_focus->SyncAccountToBangwoba($_REQUEST['account_id'], 'create');
                if ($rating != $deploy_value_37) {

                    $time = date('Y-m-d H:i:s', time());
                    $status = 0;
                    $modtrackerId = $adb->getUniqueID('ld_modtracker_basic');
                    $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) values (?,?,?,?,?,?);';
                    $adb->pquery($query, array($modtrackerId, $_REQUEST['account_id'], 'Accounts', -1, $time, $status));
                    //}
                    $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';

                    $adb->pquery($query, array($modtrackerId, 'rating', $rating, $deploy_value_37));
                }
            }
            //modify Potential sales_stage field
            if ($deploy_value_38 != '' && $_REQUEST['potential_id'] != '' && $deploy_value_38 != '') {
                $query = 'SELECT sales_stage FROM ld_potential WHERE potentialid = "' . $_REQUEST['potential_id'] . '" LIMIT 1;';
                $result = $adb->pquery($query);
                $lastsales_stage = $adb->query_result($result, 0, 'sales_stage');
                $tabid = getTabid('Potentials');
                $query = "select 1 from ld_settings_advance where tabid = ? and module_field = 'sales_stage' and `enable` = 'yes'";
                $result = $adb->pquery($query, array($tabid));
                $num_rows = $adb->num_rows($result);
                if ($num_rows >= 1) {
                    $adb->pquery("UPDATE ld_potential set sales_stage = '" . $deploy_value_38 . "',advance_stage = '" . $deploy_value_38 . "',lastsales_stage = '" . $lastsales_stage . "',modifiedtime ='" . date('Y-m-d H:i:s') . "' where potentialid =" . $_REQUEST['potential_id'], array());
                } else {
                    $adb->pquery("UPDATE ld_potential set sales_stage = '" . $deploy_value_38 . "',lastsales_stage = '" . $lastsales_stage . "',modifiedtime ='" . date('Y-m-d H:i:s') . "' where potentialid =" . $_REQUEST['potential_id'], array());
                }


                //$focus = CRMEntity::getInstance('Potentials');
                $time = date('Y-m-d H:i:s', time());
                $status = 0;
                $modtrackerId = $adb->getUniqueID('ld_modtracker_basic');
                $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) values (?,?,?,?,?,?);';
                $version_info = getVersionInfo();
                if ($version_info['trade'] == "zhongfu") {//中孚系统中合同管理商机时，将修改人从系统改为当前用户。
                    $adb->pquery($query, array($modtrackerId, $_REQUEST['potential_id'], 'Potentials', $current_user->id, $time, $status));
                } else {
                    $adb->pquery($query, array($modtrackerId, $_REQUEST['potential_id'], 'Potentials', -1, $time, $status));
                }
                //}
                $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';

                $adb->pquery($query, array($modtrackerId, 'sales_stage', $lastsales_stage, $deploy_value_38));
            }
        }

        /**********判断基金行业生成积分 begin************/

        //判断是基金行业
        if (get_versiontrade() == 'fund') {
            require(globalStatic::$root_directory . 'include/trade/fund.php');
            //获取客户ID
            $integralAccountID = $this->column_fields['account_id'];
            trade_fund::CalculationIntegral($integralAccountID);

        }

        /**********判断基金行业生成积分 end************/


        /**********判断基金行业并且是凯银数据库时，同步合同订单（投资协议） begin************/

        /**
         * edit:diony
         * time:2014-12-05
         * 凯银同步合同订单
         * 判断产品明细中，产品类别为基金时，才会同步，凯银产品类别字段为cf_1387
         */
        if (get_versiontrade() == 'fund' && get_versionaccount() == 'kylin' && $_REQUEST['signed_data'] > '2014-12-19') {
            require(globalStatic::$root_directory . 'include/trade/fund/kylin.php');
            project_kylin::addData($this);
        }
        /**********判断基金行业并且是凯银数据库时，同步合同订单（投资协议） end************/

        /**********合同订单保存后自动创建出库单 begin************/
        //新增保存

        $deployarray = getSys_deploy('56');
        $warehouseid = $deployarray['deploy_value'];
        //编辑保存
        $deployarray_edit = getSys_deploy('63');
        $warehouseid_edit = $deployarray_edit['deploy_value'];
        //灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
        $deployarray = getSys_deploy(48);
        //设置是否允许负库存出库
        $deployarray_141 = getSys_deploy(141);
        //触发点为保存，并且负库存不能出口。 则判断产品数量
        $status = true;
        if ($deployarray_141['deploy_value'] != 1 && $deployarray['deploy_value'] == 1 && ((empty($_REQUEST['mode']) && !empty($warehouseid)) || ($_REQUEST['mode'] == 'edit' && !empty($warehouseid_edit)))) {
            if (!$this->getInventoryProductNum($this->id)) {
                $status = false;
            }
        }
        //同时还需判断仓库是否为空，为空直接不创建，不为空继续判断仓库是否可用
        //edit:hzx  46657: （http://51mis.com/hy/new [^]）客户问题（申雅琪），系统参数->业务参数，“设置合同订单新增保存后是否自动创建出库单（为空表示不创建）”参数没有生效
        if ($status == true && (($_REQUEST['mode'] == 'create' && !empty($warehouseid)) || ($_REQUEST['mode'] == 'edit' && !empty($warehouseid_edit)))) {
            $issaveoutorer = 'true';
            //判断仓库是否可用，yes可用，如果为no不可用，在保存后做弹出
            if (getWarehouseStatus($warehouseid) == 'no') {
                $warehouseid = $_REQUEST['autowarehouseid'];
                if ($warehouseid == '0') {
                    $issaveoutorer = 'false';
                }
            }
            //0018950: 库存流水账序列表界面：触发点为：审核时，没有审核的库存单据也统计进去了
            //如果是编辑保存，需要先将对应出库单信息给删除
            if (($_REQUEST['mode'] == 'edit')) {
                $warehouseid = $warehouseid_edit;
                $seloutSql = "select distinct id from ld_outboundorderdetail 
                left JOIN ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id 
                where entitytypeid = ?  and ld_outboundorder.deleted=0";


                $seloutResult = $adb->pquery($seloutSql, array($this->id));

                if ($adb->num_rows($seloutResult) > 0) {

                    $outids = '';
                    for ($i = 0; $i < $adb->num_rows($seloutResult); $i++) {
                        $outid = $adb->query_result($seloutResult, $i, 'id');
                        $seloutStatusSql = "select presence,wareid,smownerid from ld_outboundorder where out_id = ?";
                        $seloutStatusResult = $adb->pquery($seloutStatusSql, array($outid));
                        $presence = $adb->query_result($seloutStatusResult, 0, 'presence');
                        $wareid = $adb->query_result($seloutStatusResult, 0, 'wareid');
                        $out_smownerid = $adb->query_result($seloutStatusResult, 0, 'smownerid');

                        if ($presence == ALLOUTBOUND) {
                            $issaveoutorer = 'false';
                            break;
                        }

                        $focus_out = CRMEntity::getInstance('OutboundOrder');
                        $focus_out->id = $outid;

                        $focus_out->retrieve_entity_info($outid, 'OutboundOrder');

                        $query = 'select quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,wareid ,batchtext
                                    from ld_outboundorderdetail 
                                    left join ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id where id = ? ';
                        $result = $adb->pquery($query, array($outid));
                        $num_rows = $adb->num_rows($result);
                        DeleteEntity('OutboundOrder', 'OutboundOrder', $focus_out, $outid, '');

                        crm_load_class_file('cls_Source_InverseCompute', 'include/OptionModule');
                        for ($j = 0; $j < $num_rows; $j++) {
                            $entitytypeid = $adb->query_result($result, $j, 'entitytypeid');
                            $productid = $adb->query_result($result, $j, 'productid');
                            $qty = $adb->query_result($result, $j, 'quantity');
                            $entitytypeid = $adb->query_result($result, $j, 'entitytypeid');
                            $parent_lineitem_id = $adb->query_result($result, $j, 'parent_lineitem_id');
                            $lineitem_id = $adb->query_result($result, $j, 'lineitem_id');
                            $wareid = $adb->query_result($result, $j, 'wareid');
                            $batchtext = $adb->query_result($result, $i, 'batchtext');
                            //更新合同订单的出库状态、未出库和已出库数量
                            cls_Source_InverseCompute::Source_InveverseCompute("SalesOrder", $entitytypeid);
                            if ($deployarray['deploy_value'] == 1) {
                                insertCondtion($batchtext, $entitytypeid, '删除出库单', $wareid, $productid, 'OutboundOrder', $out_smownerid, 0, $qty, $parent_lineitem_id, $lineitem_id);
                            }
                        }

                    }
                }
            }
            if (!empty($this->column_fields['account_id'])) {
                $salesorder_account_id = $this->column_fields['account_id'];
                $acc_focus = CRMEntity::getInstance('Accounts');
                $acc_focus->retrieve_entity_info($salesorder_account_id, 'Accounts');
                if (isset($acc_focus->column_fields['allowdelivery_date']) && !empty($acc_focus->column_fields['allowdelivery_date'])) {
                    $allowdelivery_date = $acc_focus->column_fields['allowdelivery_date'];
                    $now_date = date('Y-m-d');
                    //如果小于等于不允许保存。并给出提示信息：该客户在yyyy-mm-dd之后才允许发货，保存失败！
                    if ($now_date <= $allowdelivery_date) {
                        $issaveoutorer = 'false';
                    }
                }
            }
            if ($issaveoutorer == 'true') {
                SalesOrder::require_file('OutboundOrder');
                $retrieve_entity_info_modules = '';//重新获取数据库值
                $this->retrieve_entity_info($this->id, 'SalesOrder');
                $out_focus = new OutboundOrder();//不能调用CRMEntity::getInstance(),因为上面创建了OutboundOrder对象
                $out_focus->column_fields['account_id'] = $this->column_fields['account_id'];//客户
                $out_focus->column_fields['contact_id'] = $this->column_fields['contact_id'];//联系人
                $time = date('Y-m-d', time());

                $out_focus->column_fields['outdate'] = $time;//出库时间
                $out_focus->column_fields['wareid'] = $warehouseid;//仓库ID
                //$out_focus->column_fields['taxtype'] = $_REQUEST['taxtype'];//税的类型
                $out_focus->currency_status = true;
                $out_focus->column_fields['currency_id'] = $this->column_fields['currency_id'];
                $out_focus->column_fields['conversion_rate'] = $this->column_fields['conversion_rate'];
                $currencyobj = Currency::getInstance($adb, $out_focus->column_fields['currency_id']);
                $cur_sym_rate['symbol'] = $currencyobj->getCurrencySymbol();
                $cur_sym_rate['rate'] = $currencyobj->getCurrencyRate();
                $out_focus->column_fields['conversion_rate'] = $cur_sym_rate['rate'];
                $out_focus->column_fields['currency_symbol'] = decode_html($cur_sym_rate['symbol']);
                $out_focus->column_fields['adjustmentType'] = $_REQUEST['adjustmentType'];//调整状态
                $out_focus->column_fields['adjustment'] = $_REQUEST['adjustment'];//调整
                //edit:hzx  46657: （http://51mis.com/hy/new [^]）客户问题（申雅琪），系统参数->业务参数，“设置合同订单新增保存后是否自动创建出库单（为空表示不创建）”参数没有生效
                $out_focus->column_fields['selectsourcename'] = 'SalesOrder';
                $out_focus->column_fields['selectlistval'] = $this->id;
                $out_focus->column_fields['assigned_user_id'] = $current_user->id;
                $out_focus->column_fields['hdnGrandTotal'] = $focus->column_fields['hdnGrandTotal'];
                $out_focus->column_fields['hdnSubTotal'] = $focus->column_fields['hdnSubTotal'];
                if (isset($_REQUEST['allSingledDiscount']) && $_REQUEST['allSingledDiscount'] == '-') {
                    $out_focus->column_fields['hdnDiscountAmount'] = $_REQUEST['discount_amount'];
                } else {
                    $out_focus->column_fields['hdnDiscountPercent'] = $_REQUEST['discount_amount'];
                }
                $out_focus->column_fields['autocreateoutorder'] = 'yes';//用来判断是否是自动创建出库单
                crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
                $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('OutboundOrder', $this->id, '');

                $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
                //edit:can 2021092247995: （上海鑫选客户问题）http://121.5.34.219:85/crm/ [^]，已经设置合同订单新增保存时自动创建出库单，但自动创建的出库单无法带出合同订单中的两个引用字段，这两个引用字段为“提货日期”和“归还日期”
                foreach ($relatedfielddata as $relateinfo) {
                    $rawvalue_arr = $relateinfo['rawValue'];
                    $fieldname = $rawvalue_arr['input_name'];
                    $fieldinfo = $out_focus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
                    if ($fieldinfo && $fieldinfo->getSaveDataBase() == 'yes') {
                        $out_focus->column_fields[$fieldinfo->getFieldName()] = $rawvalue_arr['value'];

                    }

                }

                $productSql = "select productid,sequence_no,lineitem_id from ld_salesorderdetail where id = ? order by lineitem_id ";
                $productResult = $adb->pquery($productSql, array($this->id));

                $productTotal = $_REQUEST['rowcnt'];
                for ($i = 1; $i <= $productTotal; $i++) {
                    $out_focus->column_fields['selectSourceModuleid' . $i] = $this->id;//源单ID
                    $out_focus->column_fields['lineitem_id' . $i] = $adb->query_result($productResult, $i - 1, "lineitem_id");//关联ID
                    $out_focus->column_fields['entitytype' . $i] = 'SalesOrder';//源单模块
                    $_REQUEST['entitytype' . $i] = 'SalesOrder';
                    //edit:hzx  46657: （http://51mis.com/hy/new [^]）客户问题（申雅琪），系统参数->业务参数，“设置合同订单新增保存后是否自动创建出库单（为空表示不创建）”参数没有生效
                    $_REQUEST['entitytypeid' . $i] = $this->id;
                    $_REQUEST['lineitem_id' . $i] = $adb->query_result($productResult, $i - 1, "lineitem_id");//关联ID
                    $_REQUEST['wareid' . $i] = $warehouseid;//设置合同订单新增保存后是否自动创建出库单（为空表示不创建）,设置合同订单编辑保存后是否自动创建出库单（为空表示不创建）
                }
                if ($languageType == 'en') {
                    $autoRemark = 'Automatically create';
                } else {
                    $autoRemark = '自动创建';
                }

                $out_focus->column_fields['remark'] = $autoRemark;
                $out_focus->mode = "Create";
                //37265: 后台设置创建合同订单自动生成一个服务合同，合同订单里有附件，生成的服务合同也把附件也带过来了，怎么可以取消
                $tmfiles = $_REQUEST['filename-file_num'];
                $_REQUEST['filename-file_num'] = 0;
                $out_focus->save('OutboundOrder');
                $_REQUEST['filename-file_num'] = $tmfiles;
                if ($deployarray['deploy_value'] == 1) {

                    cls_OutSale_InverseCompute::updateSourceModuleOutboundAmount($this->id, $module);
                }

            }
        }

        /**********合同订单保存后自动创建服务合同************/
        $deployarray = getSys_deploy('130');

        if (vtlib_isModuleActive('ServiceContracts')) {
            //edit:can 2020-12-31 43649: （本地8.3.4）销售管理-合同订单；参数中“合同订单保存后是否自动创建1年免服务费的服务合同”设为了“新建保存时创建”；但在合同单据列表，选择单据进行批量编辑保存后，服务合同也新建了
            if (strtolower($this->mode) != 'edit' && $deployarray['deploy_value'] == 1) {

                $this->createServiceContracts($this->id);
            }
        }
        if (strtolower($this->mode) != 'edit') {
            //合同订单保存后是否自动创建收款单
            $this->autocreateCasbhill($this->id, 'create');
        } else {
            //die;
            //编辑单据反写收款单明细字段
            $sendfocus = CRMEntity::getInstance('CashBill');
            $sendfocus->updateSourceInfo($this->id, 'SalesOrder');
        }
        //订单保存时，“实际交货日期”与 “评审日期”进行对比，实际交货日期晚于评审日期，自动更新产品分录字段“是否延期”为是。
        if (get_versiontrade() == 'yangduan') {
            $detailtable = $this->Detail_table;
            $detailtablescf = $this->Detail_table_scf;

            //预计入库日期=评审日期+3天
            $query = "update $detailtable
				inner JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id
				set $detailtablescf.sf4753 = date_add($detailtablescf.sf799, interval 3 day)
				where $detailtablescf.sf799 != '' and ($detailtablescf.sf4753 = '' or $detailtablescf.sf4753 = '0000-00-00') and $detailtable.id = ?";
            $adb->pquery($query, array($this->id));
            //预计交货日期2=预计入库日期+5天
            $query = "update $detailtable
				inner JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id
				set $detailtablescf.sf3311 = date_add($detailtablescf.sf4753, interval 5 day)
				where $detailtablescf.sf4753 != '' and ($detailtablescf.sf3311 = '' or $detailtablescf.sf3311 = '0000-00-00') and $detailtable.id = ?";
            $adb->pquery($query, array($this->id));
            //预计确认时间=预计交货时间+20天，当入库日期填写后就不在执行此任务，预计确认时间可以手动修改
            $query = "update $detailtable
				inner JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id
				set $detailtablescf.sf1309 = date_add($detailtablescf.sf3311, interval 20 day)
				where $detailtablescf.sf3311 != '' and ($detailtablescf.sf1309 = '' or $detailtablescf.sf1309 = '0000-00-00') and ($detailtablescf.sf1105 = '' or $detailtablescf.sf1105 = '0000-00-00') and $detailtable.id = ?";
            $adb->pquery($query, array($this->id));

            $query = "select $detailtable.lineitem_id,sf2281,sf799 from $detailtable
					inner JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id where id = ?";
            $result = $adb->pquery($query, array($this->id));
            $num_rows = $adb->num_rows($result);
            if ($num_rows >= 1) {
                for ($i = 0; $i < $num_rows; $i++) {
                    $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
                    $sf2281 = $adb->query_result($result, $i, 'sf2281');    //实际交货日期
                    $sf799 = $adb->query_result($result, $i, 'sf799');    //评审日期
                    if (!empty($sf799) && !empty($sf2281)) {
                        $sf6195 = 0;    //是否延期
                        if ($sf2281 < $sf799) {
                            $sf6195 = 1;
                        }
                        $update_query = "update $detailtablescf set sf6195 = ? where lineitem_id = ?";
                        $adb->pquery($update_query, array($sf6195, $lineitem_id));
                    }
                }
            }
            if ($this->mode != 'edit' && !empty($_REQUEST['signed_data'])) {
                $query = "update $detailtable
					inner JOIN $detailtablescf on $detailtable.lineitem_id = $detailtablescf.lineitem_id
					set $detailtablescf.sf7637 = ? where $detailtable.id = ?";
                $adb->pquery($query, array($_REQUEST['signed_data'], $this->id));
            }
        }

        //zxm 全盛 用EXCEL表格导入合同订单，订单编号不用按以上规则生成，直接读取EXCEL表格中的编号即可
        $trade_info = getVersionTradeInfo();
        if ($trade_info['account'] == 'quansheng') {
            $automatic_numbering_sql = "SELECT automatic_numbering FROM ld_salesorder where  salesorderid=?";
            $automatic_numbering_res = $adb->pquery($automatic_numbering_sql, array($this->id));
            $automatic_numbering = $adb->query_result($automatic_numbering_res, 0, 0);    //==no  说明是导入进来的
            if ($automatic_numbering == 'no') {
                //导入的时候编码不需要走触发器修改
            } else {
                $sql = "UPDATE ld_salesorder SET automatic_numbering='yes' WHERE salesorderid=?";
                $adb->pquery($sql, array($this->id));
            }
        }

        //XUQIU1000855:服务合同增加数量合计，实现该需求时顺便优化销售合同的保存 Add by luyx at 2022-11-10
        $sql = "UPDATE ld_salesorder a 
			INNER JOIN (
				SELECT 
					id,
					SUM(IFNULL(quantity,0)) AS totalquantity
				FROM ld_salesorderdetail
				WHERE id=?
				GROUP BY id
			) b ON b.id=a.salesorderid
			SET 
				a.totalquantity=IFNULL(b.totalquantity,0),
				a.balanceoutboundcount=IFNULL(b.totalquantity,0)-IFNULL(a.haveoutboundcount,0),
				a.balanceoutboundamount=ROUND(IFNULL(a.total,0)-IFNULL(a.haveoutboundamount,0),2);";
        $adb->pquery($sql, array($this->id));
		
		$sql = "UPDATE ld_salesorder SET triggercount=triggercount+1 WHERE salesorderid=?";
		$adb->pquery($sql, array($this->id));

        //zxm @date:2024/10/21 @reason: 保存合同之后删除购物车
        $cartid_str =$_REQUEST['cartid'];
        if(!empty($cartid_str)){
            crm_load_class_file('Shopcart','modules/Products');
            $shopcartobj = new Shopcart();
            $shopcartobj->mass_deletecart("",$cartid_str);
        }
    }


    //济凡生物科技：产品最低售价
    public function updateSalesOrderFDownPrice($record)
    {
        global $adb;
        $query = 'select ld_salesorderdetail.lineitem_id,product_no,cf_4469,cf_4482,cf_4460 from ld_salesorder 
		LEFT JOIN ld_salesordercf on ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
		LEFT JOIN ld_salesorderdetail on ld_salesorder.salesorderid = ld_salesorderdetail.id 
		LEFT JOIN ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id 
		LEFT JOIN ld_products on ld_products.productid = ld_salesorderdetail.productid 
		LEFT JOIN ld_productcf on ld_products.productid = ld_productcf.productid 
		where ld_salesorder.salesorderid = ?';
        $result = $adb->pquery($query, array($record));
        $num_rows = $adb->num_rows($result);
        if ($num_rows >= 1) {
            crm_load_class_file('cls_module_api', 'include/Module_Api');
            for ($i = 0; $i < $num_rows; $i++) {
                $_REQUEST['product_no'] = $adb->query_result($result, $i, 'cf_4460');
                $_REQUEST['cf_4469'] = $adb->query_result($result, $i, 'cf_4469');
                $_REQUEST['cf_4482'] = $adb->query_result($result, $i, 'cf_4482');
                $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
                $cls_module_api = new cls_module_api('SalesOrder');
                $api_data = $cls_module_api->get();
                if (!empty($api_data)) {
                    $columnn = array_keys($api_data);
                    $field = $columnn[0];
                    $query = 'update ld_salesorderdetailscf set ' . $field . '= ? where lineitem_id = ?';
                    $adb->pquery($query, array($api_data[$field], $lineitem_id));
                }
            }
        }
    }

    /**
     * 订单同步
     * @param
     * @return
     * @author Chj
     */
    public function SyDataInterFace($focus)
    {
        /**
         * 更新操作
         * edit:diony
         * date:20140613
         * reason:新增/编辑保存时判断是否启用订单接口，如果启用订单接口，自动更新KIS3信息
         * */
        require_once(globalStatic::$root_directory . 'include/InterfaceClass/InterfaceClass.php');
        require_once(globalStatic::$root_directory . 'include/Sqlsrv/sqlsrv.class.php');
        if (getDatainterface('using_order') == 1 && getDatainterface('soft_version') != '') {
            $InterfaceClass = new InterfaceClass();
            if (getDatainterface('soft_version') == 101) {//用友T+
                $_SESSION['kiserror'] = $InterfaceClass->TySynchronous($focus);
            } else if (getDatainterface('soft_version') == 102) {//用友U8+
                $_SESSION['kiserror'] = $InterfaceClass->TyuInterface($focus);
            } else if (getDatainterface('soft_version') == 103) {//T6
                $_SESSION['kiserror'] = $InterfaceClass->TySynchronous_6($focus);
            } else if (getDatainterface('soft_version') == 201) {//鼎捷易助7.0
                $_SESSION['kiserror'] = $InterfaceClass->DigiWinInterface($focus);
            } else {
                $_SESSION['kiserror'] = $InterfaceClass->KisSynchronous($focus);
            }
        }
    }

    //获取明细产品的数量和产品对应的总库存数量
    function getInventoryProductNum($record)
    {
        global $adb;
        $query = 'select ld_products.productid,quantity,qtyinstock,productname from ld_salesorderdetail
				LEFT JOIN ld_products on ld_products.productid =ld_salesorderdetail.productid where id = ?';
        $result = $adb->pquery($query, array($record));
        $num_rows = $adb->num_rows($result);
        if ($num_rows >= 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $quantity = $adb->query_result($result, $i, 'quantity');
                $qtyinstock = $adb->query_result($result, $i, 'qtyinstock');
                if ($quantity > $qtyinstock) {
                    return false;
                    break;
                }
            }
        }
        return true;
    }

    /*
       * editor : gyq_02
       * function : 更新对应客户最新进度和最新联系日期，销售机会最新联系日期
       * date   : 2016  1  26
       * explain :
       *      $id    ： accountid，存有更改前后客户ID或类似ID数组
       *      $table : 待更新的数据表名，例如ld_account
       * */
    function updateRelatedTableInfo($table, $id)
    {
        global $adb;

        if (sizeof($id) > 0) {

            foreach ($id as $accountid) {

                if (empty($accountid)) {
                    continue;
                }

                if ($table == 'ld_account') $condition = " accountid=$accountid ";
                if ($table == 'ld_potential') $condition = " potentialid=$accountid ";

                $sql = " SELECT signed_data,createdtime FROM ld_salesorder
             WHERE deleted=0 and  " . $condition . " ORDER BY signed_data DESC,createdtime desc LIMIT 1 ";

                $result = $adb->pquery($sql);

                if ($adb->num_rows($result) > 0) {

                    $signed_data = $adb->query_result($result, 0, 'signed_data');
                    $createdtime = $adb->query_result($result, 0, 'createdtime');

                    $sql = "update $table set  ";

                    $update_params = array();

                    if ($signed_data != '' && $signed_data > '1600-01-01') {
                        $lastorderdate = $signed_data;

                    } elseif ($createdtime != '' && $createdtime > '1600-01-01') {

                        $lastorderdate = date('Y-m-d', strtotime($createdtime));

                    }

                    if ($lastorderdate > 0) {

                        $sql .= ' lastorderdate=?';

                        $update_params[] = $lastorderdate;

                    }

                    if (is_array($update_params) && sizeof($update_params) > 0) {
                        if ($table == 'ld_account')

                            $sql .= ' where accountid=? ;';
                        else
                            $sql .= ' where potentialid=? ;';

                        $update_params[] = $accountid;

                        $adb->pquery($sql, $update_params);
                    }

                } else {

                    if ($table == 'ld_account') {
                        $sql = "update $table set lastorderdate=? where accountid=? ";

                        $adb->pquery($sql, array(null, $accountid));
                    } elseif ($table == 'ld_potential') {
                        $sql = "update $table set lastorderdate=? where potentialid=? ; ";

                        $adb->pquery($sql, array(null, $accountid));
                    }

                }
            }


        }

        SalesOrder::$mass_before_focus = array();
    }

    function restore($module, $salesorderid)
    {
        global $adb;
        parent::restore($module, $salesorderid);

        crm_load_class_file("cls_Source_InverseCompute", 'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module, $salesorderid);


        if (array_key_exists("account_id", $this->column_fields) || array_key_exists("potential_id", $this->column_fields)) {
            $sql = 'select accountid,potentialid from ld_salesorder where salesorderid=?';

            $result = $adb->pquery($sql, array($salesorderid));
            $accountid = $adb->query_result($result, 0, 'accountid');
            $potentialid = $adb->query_result($result, 0, 'potentialid');
        }

        if ($accountid > 0) {


            $this->updateRelatedTableInfo('ld_account', array($accountid));

        }
        if ($potentialid > 0) {


            $this->updateRelatedTableInfo('ld_potential', array($potentialid));
        }
    }

    /**
     * editor  : gyq_02
     * date    : 2016 1 26
     * explain : 批量编辑保存后处理
     *          $ids : 被批量选择的记录ID数组，例如联系记录
     *          $mass_before_focus ： 保存前序时簿记录信息
     * */
    function massEdit_save_after($module, $ids)
    {

        $accountids = array();
        $potentialids = array();
        foreach ($ids as $contactrecord) {
            $ids_before = SalesOrder::$mass_before_focus[$contactrecord];
            $accountids[$ids_before['account_id']] = $ids_before['account_id'];
            $potentialids[$ids_before['potential_id']] = $ids_before['potential_id'];

        }

        if (sizeof($ids) > 0) {

            if ($_REQUEST['account_id_mass_edit_check'] != '') {
                $accountids[$_REQUEST['account_id_mass_edit_check']] = $_REQUEST['account_id_mass_edit_check'];
            }
            if ($_REQUEST['potential_id_mass_edit_check'] != '') {
                $potentialids[$_REQUEST['potential_id_mass_edit_check']] = $_REQUEST['potential_id_mass_edit_check'];
            }
            if (sizeof($accountids) > 0)
                $this->updateRelatedTableInfo('ld_account', $accountids);
            if (sizeof($potentialids) > 0)
                $this->updateRelatedTableInfo('ld_potential', $potentialids);

        }
        /**
         * 基金行业批量编辑合同订单时保存
         **/
        if (isset($_REQUEST["sostatus_mass_edit_check"])) {

            $after_sostatus = $_REQUEST['sostatus_mass_edit_check'];//批量编辑之后的订单状态值。
            $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
            $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
            if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
                require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
                $trade_class_name = $tradename . '_SalesOrder';
                if (class_exists($trade_class_name)) {
                    $trade_focus = new $trade_class_name($this);
                    if (method_exists($trade_focus, "redemption_changeStatus")) {
                        if (is_array($ids) && sizeof($ids) > 0) {
                            $trade_focus->redemption_changeStatus($ids); //订单状态改变时，生成交易记录。
                        }
                    }
                }
            }
        }
    }

    public function addComboxIntoDataBase($table_name = '')
    {
        if (!array_key_exists("sostatus", $this->column_fields)) {
            return;
        }
        global $adb;
        $history_field_array = array(

            "SalesOrder" => "sostatus"

        );

        $inventory_module = "SalesOrder";

        if ($_REQUEST['ajxaction'] == 'DETAILVIEW') {//if we use ajax edit

            $relatedname = getModuleHref('Accounts', $this->column_fields['account_id']);

            $total = $this->column_fields['hdnGrandTotal'];
        } else {//using edit button and save

            $relatedname = $_REQUEST["account_name"];

            $total = $_REQUEST['total'];
        }

        if ($this->column_fields["$history_field_array[$inventory_module]"] == $app_strings['LBL_NOT_ACCESSIBLE']) {

            //If the value in the request is Not Accessible for a picklist, the existing value will be replaced instead of Not Accessible value.
            $his_col = $history_field_array[$inventory_module];
            $his_sql = "select $his_col from  $this->table_name where " . $this->table_index . "=?";

            $his_res = $adb->pquery($his_sql, array($this->id));
            $status_value = $adb->query_result($his_res, 0, $his_col);
            $stat_value = $status_value;
        } else {
            $stat_value = $this->column_fields["$history_field_array[$inventory_module]"];
        }
        $oldvalue = getSingleFieldValue($this->table_name, $history_field_array[$inventory_module], $this->table_index, $this->id);
        if ($this->column_fields["$history_field_array[$inventory_module]"] != '' && $oldvalue != $stat_value) {
            crm_load_function_file('addInventoryHistory', 'include/utils', 'InventoryUtils');
            addInventoryHistory($inventory_module, $this->id, $relatedname, $total, $stat_value);
        }
    }


    /*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
    function setRelationTables($secmodule)
    {
        $rel_tables = array(
            "Calendar" => array("ld_seactivityrel" => array("crmid", "activityid"), "ld_salesorder" => "salesorderid"),
            "Invoice" => array("ld_invoice" => array("salesorderid", "invoiceid"), "ld_salesorder" => "salesorderid"),
            "Documents" => array("ld_senotesrel" => array("crmid", "notesid"), "ld_salesorder" => "salesorderid"),
            "CashBill" => array("ld_cashbill2paymentplan" => array("entitytypeid", "CashBillID"), "ld_salesorder" => "salesorderid"),
        );
        return $rel_tables[$secmodule];
    }

    // Function to unlink an entity with given Id from another entity
    function unlinkRelationship($id, $return_module, $return_id)
    {

        if (empty($return_module) || empty($return_id)) return;

        if ($return_module == 'Accounts') {
            $this->trash('SalesOrder', $id);
        } elseif ($return_module == 'Quotes') {
            $relation_query = 'UPDATE ld_salesorder SET quoteid=? WHERE salesorderid=?';
            $this->db->pquery($relation_query, array(null, $id));
        } elseif ($return_module == 'Potentials') {
            $relation_query = 'UPDATE ld_salesorder SET potentialid=? WHERE salesorderid=?';
            $this->db->pquery($relation_query, array(null, $id));
        } elseif ($return_module == 'Contacts') {
            $relation_query = 'UPDATE ld_salesorder SET contactid=? WHERE salesorderid=?';
            $this->db->pquery($relation_query, array(null, $id));
        } else {
            $sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
            $params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
            $this->db->pquery($sql, $params);
        }
        $this->deleteKisDataAfterApprove($id);
    }

    /*
	 * edit:diony
	 * time:2014-06-12
	 * reason:批量删除时，走这里，删除时
	 */
    function trash($module, $id)
    {
        global $adb;
        parent::trash($module, $id);

        $payment_focus = CRMEntity::getInstance("PaymentPlan");
        $payment_focus->deletePaymentPlan($id, $this);
        $this->deleteKisDataAfterApprove($id);
        //zxm 20221115 合同订单删除 客户的累计订货金额没有被更新
        $sql = 'select accountid from ld_salesorder where salesorderid=? ';
        $result = $adb->pquery($sql, array($id));
        $accountid = $adb->query_result($result, 0, "accountid");//客户id
        $this->updateAccountBalanceAmount($accountid);
        //hzx 20240530 BUG20240527-52 日程管理根据销售合同的交付日期自动生成日程记录，但是删除销售合同后，已经创建的日程记录不会同步删除
        $sql_remind = "update ld_reminds set deleted = 1 where related_to = ? and reltab = 'SalesOrder' and remindstype = 'SalesOrderDueDate'";
        $result = $adb->pquery($sql_remind, array($id));
    }
    //预收单充值  收款单创建 zxm20220217
    //收款单（预收）创建或者编辑，程序（save_module）修改客户余额与累计充值金额；--debuction预收
    //收款单（收款）创建或者编辑，程序（save_module）修改累计订货金额
    //2022-1115 合同订单删除 更新客户的累计订货金额
    public function updateAccountBalanceAmount($accountid)
    {
        global $adb;
        //获取累计订货金额
        $select_sql = " select 
                sum(ifnull(b.amount,0)) as total
                from ld_cashbill a left join ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
                left join ld_salesorder s on s.salesorderid=b.entitytypeid
                where s.accountid=?  and a.cashtype!='debuction' and b.entitytype='SalesOrder' and a.deleted=0 and s.deleted=0   ";
        $select_res = $adb->pquery($select_sql, array($accountid));
        $total = $adb->query_result($select_res, 0, 0);
        //修改累计订货金额
        $update_sql = " update ld_account set order_amount=? where accountid=?";
        $adb->pquery($update_sql, array($total, $accountid));
    }

    public function getJoinClause($tableName)
    {
        if (strtolower($tableName) == 'ld_invoice_recurring_info') {
            return 'LEFT JOIN';
        }
        return parent::getJoinClause($tableName);
    }


    function get_dividendorder($id, $cur_tab_id, $rel_tab_id, $actions = false)
    {
        global $singlepane_view, $currentModule, $current_user;
        $this_module = $currentModule;
        $related_module = 'DividendOrder';
        $other = CRMEntity::getInstance($related_module);
        if ($singlepane_view == 'true')
            $returnset = '&return_module=' . $this_module . '&return_action=DetailView&return_id=' . $id;
        else
            $returnset = '&return_module=' . $this_module . '&return_action=CallRelatedList&return_id=' . $id;

        $button = '';

        if (isPermitted('DividendOrder', "EditView", '') == 'yes') {
            $button .= '<a title="' . getFixedLabel('CREATE') . '" 
				href="javascript:;" onclick="detailbutton_click(this,\'SalesOrder\',\'dividendcreate\',' . $id . ')">
				<span>' . getFixedLabel('LBL_Creates') . ' ' . getTranstab('DividendOrder') . '</span></a>';
        }
        crm_load_function_file('GetRelatedList', 'include', 'RelatedListView');
        $return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset);

        if ($return_value == null) $return_value = array();
        $return_value['CUSTOM_BUTTON'] = $button;
        return $return_value;
    }

    /**
     * 更新操作
     * 合同订单交付日期提醒
     * edit by andrew
     * date: 20140307
     **/
    function AddReminds($RemindsContent, $datetime, $recieverid, $record)
    {
        global $adb, $current_user;
        $sql = "delete from ld_reminds where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') ='SalesOrderDueDate'";
        $result = $adb->query($sql);

        $sql = "delete from ld_reminds_accepted where related_to='{$record}' and status_rmd='未读' and ifnull(remindstype,'') ='SalesOrderDueDate'";
        $result = $adb->query($sql);

        //$smownersql = "select * from ld_crmentity where crmid = ".$record;
        //$smownerresult = $adb->query($smownersql);
        //$setype = $adb->query_result($smownerresult,0,'setype');
        $focus_rel = CRMEntity::getInstance('Reminds');
        $focus_rel->column_fields['date_time'] = $datetime;
        $focus_rel->column_fields['related_to'] = $record;
        $focus_rel->column_fields['reltab'] = "SalesOrder";

        $focus_rel->column_fields['recieverid'] = $recieverid;
        $focus_rel->column_fields['createdtime'] = date('Y-m-d H:i');
        $focus_rel->column_fields['assigned_user_id'] = $recieverid;
        $focus_rel->column_fields['status_rmd'] = '未读';
        $focus_rel->column_fields['remindstype'] = 'SalesOrderDueDate';//zxm 2021-0630 合同订单交付日期提醒增加存储提醒类型
        $focus_rel->column_fields['content'] = $RemindsContent;

        $focus_rel->mode = "create";
        $focus_rel->save('Reminds');
        return $focus_rel->id;
        /*$r_multi_content = array(
                array(
                    'userid'=>$recieverid,//注意,这是微信用户id，即用户表中的wx_userid
                    'message'=>$remindcontent,
                    'reltab'=>$this->module_name,
                    'related_to'=>$record,
                    'date_time'=>$datetime,
                    'remindtype'=>'',
                    )
            );
            $remind = new immediatelyReminds();
            $errorno = $remind->sendReminds(array($focus_rel->id),$r_multi_content);*/
    }


    function getSalesOrderList($list, $pagetype, $rowCnt, $type = '')
    {
        global $adb;
        $Rand = 0;
        if ($type == '') {
            $numb = 7;
        } else {
            $numb = $type;
        }
        if (empty($list)) return '';
        foreach ($list as $key => $var) {
            $keyVal = explode(',', $key);
            if ($keyVal[0] == $Rand) {
                $cnt = 0;
                foreach ($list[$key] as $keysec => $val) {
                    if ($cnt <= $numb) {
                        $list[$key][$keysec] = '&&';
                    }
                    $cnt++;
                }
            }
            $Rand = $keyVal[0];
        }
        return $list;
    }

    /**
     * edit:andy
     * date:2014-3-21
     * reason:合同订单 上下级关联
     **/
    function getSalesHierarchy($id)
    {
        global $log, $adb, $current_user, $currentModule;
        $log->debug("Entering getSalesorderHierarchy(" . $id . ") method ...");
        $queryGenerator = new QueryGenerator($currentModule, $current_user);
        $list_query = $queryGenerator->getQuery();
        $listview_header = array();
        $listview_entries = array();
        //获取上级ID
        $sql = "select parentid from ld_salesorder where salesorderid = ?";
        $result = $adb->pquery($sql, array($id));
        $parentid = $adb->query_result($result, 0, 'parentid');
        if (isset($parentid))
            $num = 2;
        else
            $nun = 1;
        $recordidArr = array(0 => $parentid, 1 => $id);
        //获取下级ID
        $sqlNextPartentId = "select salesorderid from ld_salesorder where parentid = ?";
        $nextResult = $adb->pquery($sqlNextPartentId, array($id));
        for ($i = 0; $i < $adb->num_rows($nextResult); $i++) {
            $recordidArr[$num + $i] = $adb->query_result($nextResult, $i, 'salesorderid');
        }
        $recordid = implode(',', $recordidArr);
        $sqlColumns = "select ld_cvcolumnlist.columnname from ld_cvcolumnlist 
                    LEFT JOIN ld_customview on ld_customview.cvid = ld_cvcolumnlist.cvid 
                    where ld_customview.entitytype = 'SalesOrder' and viewname = 'All' order by columnindex asc";
        $columnsResult = $adb->pquery($sqlColumns);
        for ($i = 0; $i < $adb->num_rows($columnsResult); $i++) {
            $columnsArr = $adb->query_result($columnsResult, $i, 'columnname');
            $fieldLabel = explode(':', $columnsArr);
            $columnsName = explode('_', $fieldLabel[3]);
            $fields[] = $fieldLabel[1];
            //得到列头
            $listview_header[] = getTranslatedString($columnsName[1]);
            //获取列头sql
            $custonviewArr[] = $fieldLabel[0] . "." . $fieldLabel[1];
        }
        $custonmViewSql = implode(',', $custonviewArr);
        $queryArr = explode('distinct', $list_query);
        $query = $queryArr[0] . ' distinct ld_salesorder.salesorderid, ' . $custonmViewSql . ' ' . $queryArr[1];
        $list_result = $adb->pquery($query . " and ld_salesorder.salesorderid in($recordid)");
        //echo $query.= " and ld_salesorder.salesorderid in($recordid)";
        for ($i = 0; $i < $adb->num_rows($list_result); $i++) {
            $row = array();
            $salesid = $adb->query_result($list_result, $i, 'salesorderid');
            foreach ($fields as $key => $fieldname) {
                $val = $adb->query_result($list_result, $i, $fieldname);
                if ($fieldname == 'accountid') {
                    $val = getModuleHref('Accounts', $adb->query_result($list_result, $i, $fieldname));
                } else if ($fieldname == 'smownerid') {
                    $val = getOwnerName($adb->query_result($list_result, $i, $fieldname));
                } else if ($fieldname == 'potentialid') {
                    $val = getModuleHref('Potentials', $adb->query_result($list_result, $i, $fieldname));
                } else if ($fieldname == 'quoteid') {
                    $val = getModuleHref('Quotes', $adb->query_result($list_result, $i, $fieldname));
                } else if ($fieldname == 'contactid') {
                    $val = getModuleHref('Contacts', $adb->query_result($list_result, $i, $fieldname));
                } else if ($fieldname == 'vendorid') {
                    $val = getModuleHref('Vendors', $adb->query_result($list_result, $i, $fieldname));
                }
                if ($fieldname == 'subject')
                    $val = "<a href='javascript:;' onclick='DetailViewReferenceLinkClick(ld(this),event)' referencemodule='SalesOrder' referencerecord='" . $salesid . "' >" . $val . "</a>";
                if ($salesid != $id && $salesid != $parentid) {   //下级合同
                    if ($key == 0)
                        $val = str_repeat(" .. ", 2) . $val;
                } else {
                    //自己
                    if (isset($parentid)) {
                        if ($salesid == $id && $key == 0)
                            $val = str_repeat(" .. ", 1) . $val;
                    }
                }
                $row[] = $val;
            }
            $listview_entries[$salesid] = $row;
        }
        $sales_hierarchy = array('header' => $listview_header, 'entries' => $listview_entries);

        return $sales_hierarchy;
    }


    function get_communicationLog($id, $cur_tab_id, $rel_tab_id, $actions = false)
    {
        global $adb;
        global $currentModule;
        global $list_max_entries_per_page_new_more;
        $sql = 'select ld_smssend.ReceiveContacts,ld_smssend.CalledNumber,
        ld_smssend.Subject, ld_smssend.SmsContent,ld_smssend.SmsBillingFee,
        case when IFNUll(SmsResult,0)=-1 then "待提交" when IFNUll(SmsResult,0)=1 
        then "发送成功" when (IFNUll(SmsResult,0)<>1 and IFNUll(SmsResult,0)<>-1) 
        then "发送失败" end smsresultname,createtime, ld_users.last_name as operator  
        from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name  
        where relatieid = ' . $id . ' order by ld_smssend.createtime desc ';
        $count_result = $adb->query(mkCountQuery($sql));
        $noofrows = $adb->query_result($count_result, 0, 'count');
        global $related_left_type;
        if ($related_left_type == 3) {//获取相关信息条数
            $related_entries = array();
            $related_entries['relcount'] = $noofrows;
            return $related_entries;
        }
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = vtlib_purify($_REQUEST['start']);
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        global $related_left_start;
        $related_left_start = $start;
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        $sql .= ' LIMIT ' . $limstart . ',' . $list_max_entries_per_page_new_more . ' ';
        //手机、主题、接收人、发送时间、发件人、内容，
        $header = array(
            '<span title="' . getFixedLabel('Mobile') . '">' . getFixedLabel('Mobile') . '</span>',
            '<span title="' . getFixedLabel('Recipient') . '">' . getFixedLabel('Recipient') . '</span>',
            '<span title="' . getFixedLabel('Delivery_time') . '">' . getFixedLabel('Delivery_time') . '</span>',
            '<span title="' . getFixedLabel('FROMMAIL') . '">' . getFixedLabel('FROMMAIL') . '</span>',
            '<span title="' . getFixedLabel('Content') . '">' . getFixedLabel('Content') . '</span>',
            '<span title="' . getFixedLabel('SENDSTATESMS') . '">' . getFixedLabel('SENDSTATESMS') . '</span>'
        );
        $result = $adb->pquery($sql, array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $listview_entrie = array();
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'callednumber') . '">' . $adb->query_result($result, $i, 'callednumber') . '</span>';
                //$listview_entrie[]= $adb->query_result($result,$i,'subject');
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'receivecontacts') . '">' . $adb->query_result($result, $i, 'receivecontacts') . '</span>';
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'createtime') . '">' . $adb->query_result($result, $i, 'createtime') . '</span>';
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'operator') . '">' . $adb->query_result($result, $i, 'operator') . '</span>';
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'smscontent') . '">' . $adb->query_result($result, $i, 'smscontent') . '</span>';
                $listview_entrie[] = '<span title="' . $adb->query_result($result, $i, 'smsresultname') . '">' . $adb->query_result($result, $i, 'smsresultname') . '</span>';
                $listview_entries[] = $listview_entrie;
            }
        }
        $navigationOutput = array();
        $url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
        $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, $currentModule, 'CommunicationLog', $id);
        //print_r($listview_entries);
        $return_value = array('header' => $header, 'entries' => $listview_entries, 'navigation' => $navigationOutput, 'noofrows' => $noofrows);
        return $return_value;
    }

    /**
     * 审批已拒绝执行操作函数
     * edit:andy
     * date:20140701
     * verson:v5.34
     */
    public function failedApproved($record)
    {
        global $adb;
        $PaymentPlanID_str = getPaymentPlanID($record);
        //删除关联回款计划
        if ($PaymentPlanID_str != '') {
            $sql = 'delete from ld_paymentplan where paymentplanid in (' . $PaymentPlanID_str . ')';
            $adb->pquery($sql);
            $PaymentPlanID_str .= ',' . $record;
        } else {
            $PaymentPlanID_str .= $record;
        }
        /*
        andrew
        0012957: 订单审批后，负责人收不到审批提醒。
        审批失败也要有提醒
        */
        //删除相关提醒
        $sql = 'delete from ld_reminds where related_to in (' . $PaymentPlanID_str . ') and ifnull(remindstype,"") != \'Approve\'';
        $adb->pquery($sql);

        //删除相关自动提醒
        //print_r($PaymentPlanID_str);exit;
        $sql_autoRemind = 'delete from ld_tmpreminder where  related_to in (' . $PaymentPlanID_str . ')';
        $adb->pquery($sql);
        $this->deleteKisDataAfterApprove($record);
    }

    public function deleteKisDataAfterApprove($record)
    {
        //判断是否启用订单接口
        global $adb;
        $using_order = getDatainterface('using_order');
        if ($using_order == '1') {
            $record = $_REQUEST['record'];
            $salesorderSql = "select salesorder_no from ld_salesorder where salesorderid=?";
            $salesorderResult = $adb->pquery($salesorderSql, array($record));
            $salesorder_no = $adb->query_result($salesorderResult, 0, "salesorder_no");

            if ($approvestatus == constant('D_A_S_REJECTED') || $approvestatus == constant('D_A_S_DISMISSED')) {
                $sa = getDatainterface('sa');
                $pwd = getDatainterface('pwd');
                $hostname = getDatainterface('hostname');
                $databasename = getDatainterface('databasename');
                require_once("mssql/SqlServer.php");
                //链接数据库
                $SqlCon = new SqlServer($sa, $pwd, $databasename, $hostname);
                $conResult = $SqlCon->Connect();

                $orderDelSql = "DELETE SEOrder WHERE FBillNo = '$salesorder_no' AND FChildren = 0 AND FCheckDate is NULL AND FMultiCheckLevel1 IS NULL ";
                $orderDelResult = $SqlCon->Query_result($orderDelSql);
                $orderDelNum = $SqlCon->num_rows($orderDelResult);

            }
        }
    }

    /**
     * Name: 管家婆相关信息方法
     * User: Dong
     * Date: 2024/9/10 15:43
     * @param $id
     * @param $cur_tab_id
     * @param $rel_tab_id
     * @param $actions
     * @return array|string
     */
    public function get_gjpbalanceofsalesorder($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        $return = [];
        if(!empty($id)){
            $focus=CRMEntity::getInstance($this->module_name);
            $focus->retrieve_entity_info($id,$this->module_name);
            $focus->id = $id;
            crm_load_class_file('cls_GJPgongmao', 'modules/SalesOrder');
            $cls_GJPgongmao = new cls_GJPgongmao();
            $return = $cls_GJPgongmao->getErpData($focus);

        }

        return $return;
    }



    /**
     * 批量修改订单状态
     *
     * */
    function massChangeOrder_before($module, $ids, $after_value)
    {
        global $adb;
        /**
         * 金融行业更改合同订单状态生成产品交易历史记录
         * ------------------------begin-----------------------------
         **/
        $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
        if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
            require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
            $trade_class_name = $tradename . '_SalesOrder';
            if (class_exists($trade_class_name)) {
                $trade_focus = new $trade_class_name($this);
                if (method_exists($trade_focus, "changeStatus")) {
                    if (is_array($ids) && sizeof($ids) > 0) {
                        for ($i = 0; $i < count($ids); $i++) {
                            $trade_focus->changeStatus($ids[$i], $after_value); //订单状态改变时，生成交易记录。
                        }
                    }
                }
            }
        }
    }

    function massChangeOrder_after($module, $ids)
    {
        global $adb;
        /**
         * 基金行业更改合同订单状态生成产品份额交易历史记录
         * ------------------------begin-----------------------------
         **/
        $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
        if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
            require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
            $trade_class_name = $tradename . '_SalesOrder';
            if (class_exists($trade_class_name)) {
                $trade_focus = new $trade_class_name($this);
                if (method_exists($trade_focus, "redemption_changeStatus")) {
                    if (is_array($ids) && sizeof($ids) > 0) {
                        $trade_focus->redemption_changeStatus($ids); //订单状态改变时，生成交易记录。
                    }
                }
            }
        }
    }

    function massEdit_save_before($module, $ids)
    {

        parent::massEdit_save_before($module, $ids);

        if (isset($_REQUEST["sostatus_mass_edit_check"])) {

            $after_sostatus = $_REQUEST['sostatus_mass_edit_check'];//批量编辑之后的订单状态值。
            $trades = getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
            $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
            if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
                require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
                $trade_class_name = $tradename . '_SalesOrder';
                if (class_exists($trade_class_name)) {
                    $trade_focus = new $trade_class_name($this);
                    if (method_exists($trade_focus, "changeStatus")) {
                        if (is_array($ids) && sizeof($ids) > 0) {
                            for ($i = 0; $i < count($ids); $i++) {
                                $trade_focus->changeStatus($ids[$i], $after_sostatus); //订单状态改变时，生成交易记录。
                            }
                        }
                    }
                }
            }

        }

        /*
        * editor : gyq_02
        * explain : 批量操作保存前，以记录ID在$mass_before_focus中存储修改前信息
        * */
        SalesOrder::$mass_before_focus[$ids[0]] = $this->column_fields;
        /* explain  end */

    }

    /**
     * 批量删除(保存以后)
     * $record:单据id的集合(数组)
     * */
    function massDelete_after($module, $record)
    {

        global $adb;
        parent::massDelete_after($module, $record);
        /**
         * 金融行业合同订单删除生成产品交易历史记录
         * ------------------------begin-----------------------------
         **/
        $trades = getVersionInfo();//获取数据库版本（了解属于什么行业）。
        $tradename = ucwords($trades['trade']);//将字符串首字母转化成大写。
        if (!empty($tradename) && file_exists('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php')) {
            require_once('include/trade/' . $tradename . '/' . $tradename . '_SalesOrder.php');
            $trade_class_name = $tradename . '_SalesOrder';
            if (class_exists($trade_class_name)) {
                $trade_focus = new $trade_class_name($this);
                if (method_exists($trade_focus, "Delete"))
                    $trade_focus->Delete($record, $module);//合同订单删除时，生成产品购买交易记录。(金融/基金行业)
            }
        }

        /*
        * editor : gyq_02
        * explain : 批量删除后处理
        * */

        $accountids = array();
        $potentialids = array();

        global $adb;
        $contactrecordids = implode(",", (array)$record);
        $sql = 'select accountid ,potentialid from ld_salesorder  where salesorderid in( ' . $contactrecordids . ' )';
        $result = $adb->pquery($sql, array());
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $accountid = $adb->query_result($result, $i, 'accountid');
            $potentid = $adb->query_result($result, $i, 'potentialid');
            if (!empty($accountid))
                $accountids[$accountid] = $accountid;
            if (!empty($potentid))
                $potentialids[$potentid] = $potentid;

        }
        if (sizeof($accountids) > 0) {
            $this->updateRelatedTableInfo('ld_account', $accountids);
        }
        if (sizeof($potentialids) > 0) {
            $this->updateRelatedTableInfo('ld_potential', $potentialids);
        }

    }

    //源美特殊控制，判断明细表体字段“暂定价价格”、“点价价格”、“点价期限/时间”是否启用
    function getOrdertypeByField()
    {
        global $currentModule;
        $ProductDetailsData = crm_load_class_obj('cls_productDetailsData', "modules/$currentModule/ProductDetails", array($currentModule));
        $productfiled = $ProductDetailsData->presenceToolField;
        $col_array = array('tempprice', 'clickprice', 'clicktime');
        $res = 'no';
        if (!empty($productfiled)) {
            $presence_num = 0;
            foreach ($productfiled as $pro_field) {
                $columnname = $pro_field->getColumnName();
                if (in_array($columnname, $col_array) && $pro_field->getPresence() <> 1) {
                    $presence_num++;
                }
            }
            if (sizeOf($col_array) == $presence_num) {
                $res = 'yes';
            }
        }
        return $res;
    }

    /**
     * @edit:cyb
     * @date:2016-06-13
     * @reason:合同订单（认购合同）相关信息下增加赎回选项；
     **/
    function get_redemption($id, $cur_tab_id, $rel_tab_id, $actions = false, $relationId = null)
    {
        global $singlepane_view, $currentModule, $current_user;

        $this_module = $currentModule;
        $redemption_id = 0;//新增时，默认赎回记录id为0；
        //列表按钮
        if ($actions) {
            if (is_string($actions)) $actions = explode(',', strtoupper($actions));

            if (in_array('ADD', $actions)) {
                $button .= '<a title="' . getFixedLabel('CREATE') . '"
				href="javascript:void(0)" onclick="showRedemptionPop(this,' . $id . ',' . $relationId . ',' . $redemption_id . ')">				
                <span>' . getFixedLabel('CREATE') . '</span></a>';
            }
        }
        //获取列头
        $rel_listheader = array();
        $rel_listheader[] = getFixedLabel('REDEMPTIONTIME');
        $rel_listheader[] = getFixedLabel('REDEMPTIONQUANTITY');
        $rel_listheader[] = getFixedLabel('REDEMPTIONISFREE');
        $rel_listheader[] = getFixedLabel('REDEMPTIONCOST');
        $rel_listheader[] = getFixedLabel('OPERATOR');
        $rel_listheader[] = getFixedLabel('OPERATTIME');
        $rel_listheader[] = getFixedLabel('OPERATING');
        //获取分页
        global $related_left_type, $adb;
        global $related_left_start;
        global $list_max_entries_per_page_new_more;
        $query_count = '';
        $query_count = 'SELECT 1 from ld_fund_redemption where salesorder_id=?';
        $count_result = $adb->pquery($query_count, array($id));
        $noofrows = $adb->num_rows($count_result);
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = vtlib_purify($_REQUEST['start']);
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        $related_left_start = $start;
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        $query = 'SELECT
                    redemption_id,
                    redemption_time,
                    redemption_quantity,
                    redemption_isfree,
                    redemption_cost,
                    last_name,
                    redemption_operatetime
                FROM
                    ld_fund_redemption
                LEFT JOIN ld_users on ld_fund_redemption.userid=ld_users.id
                WHERE salesorder_id = ?   
                order by redemption_time desc                   
                LIMIT ' . $limstart . ',' . $list_max_entries_per_page_new_more;
        //echo $query;
        $result = $adb->pquery($query, array($id));
        $num = $adb->num_rows($result);
        //按照赎回日期倒序显示
        if ($num > 0) {
            for ($i = 0; $i < $num; $i++) {
                $redemption_id = $adb->query_result($result, $i, 'redemption_id');
                $redemption_time = $adb->query_result($result, $i, 'redemption_time');
                $redemption_quantity = $adb->query_result($result, $i, 'redemption_quantity');
                $redemption_isfree = $adb->query_result($result, $i, 'redemption_isfree');
                if ($redemption_isfree == 0) {
                    $redemption_isfree = getFixedLabel('NO');
                } else {
                    $redemption_isfree = getFixedLabel('YES');
                }
                $redemption_cost = $adb->query_result($result, $i, 'redemption_cost');
                $last_name = $adb->query_result($result, $i, 'last_name');
                $redemption_operatetime = $adb->query_result($result, $i, 'redemption_operatetime');
                $editbutton = '<a class="Anu3_a" style="white-space:nowrap;" onclick="showRedemptionPop(this,' . $id . ',' . $relationId . ',' . $redemption_id . ')" href="javascript:void(0);">' . getFixedLabel('EDIT') . '</a>';
                $rel_listentries[$redemption_id] = array
                (
                    'redemption_time' => $redemption_time,
                    'redemption_quantity' => '<div align="right">' . setNumberFormat($redemption_quantity, 2) . '</div>',
                    'redemption_isfree' => $redemption_isfree,
                    'redemption_cost' => '<div align="right">' . setNumberFormat($redemption_cost, 2) . '</div>',
                    'last_name' => $last_name,
                    'redemption_operatetime' => $redemption_operatetime,
                    'operate' => $editbutton
                );
            }
        }
        if ($return_value == null) $return_value = array();
        $navigationOutput = array();
        $url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
        $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, "SalesOrder", 'Redemption', $id);
        $return_value = array('CUSTOM_BUTTON' => $button, 'header' => $rel_listheader, 'entries' => $rel_listentries, 'relcount' => $noofrows, 'navigation' => $navigationOutput, 'fieldwidth' => '');

        return $return_value;
    }

    /**
     * edit:can 2020826
     * 中孚
     * */
    public function getSostatusImage()
    {
        $focus = $this;
        if (empty($this->id)) {
            return '';
        }
        if ($focus->column_fields['sostatus'] == '已创建')//合同状态
        {
            return 'sostatus_create.png';

        } else if ($focus->column_fields['sostatus'] == '合同已签（原件）') {
            return 'sostatus_org.png';
        } else if ($focus->column_fields['sostatus'] == '合同已签（复印件）') {
            return 'sostatus_copy.png';
        } else if ($focus->column_fields['sostatus'] == '合同已签（保密办）') {
            return 'sostatus.png';
        } else if ($focus->column_fields['sostatus'] == '不签合同') {
            return 'sostatus_not.png';
        } else if ($focus->column_fields['sostatus'] == '已作废') {
            return 'sostatus_cancel.png';
        } else if ($focus->column_fields['sostatus'] == '商务已处理') {
            return 'sostatus_hanler.png';
        } else if ($focus->column_fields['sostatus'] == '商务处理完毕') {
            return 'sostatus_finished.png';
        }
    }
    public function getSostatusTag()
    {
        $focus = $this;
        if (empty($this->id)) {
            return '';
        }
        //合同状态
        if ($focus->column_fields['sostatus'] == '已创建') {
            return '<span class="ld-tags tag-green">已创建</span>';
        } else if ($focus->column_fields['sostatus'] == '合同已签（原件）') {
            return '<span class="ld-tags tag-green width120">合同已签（原件）</span>';
        } else if ($focus->column_fields['sostatus'] == '合同已签（复印件）') {
            return '<span class="ld-tags tag-green width120">合同已签（复印件）</span>';
        } else if ($focus->column_fields['sostatus'] == '合同已签（保密办）') {
            return '<span class="ld-tags tag-green width120">合同已签（保密办）</span>';
        } else if ($focus->column_fields['sostatus'] == '不签合同') {
            return '<span class="ld-tags tag-red">不签合同</span>';
        } else if ($focus->column_fields['sostatus'] == '已作废') {
            return '<span class="ld-tags tag-red">已作废</span>';
        } else if ($focus->column_fields['sostatus'] == '商务已处理') {
            return '<span class="ld-tags tag-green width90">商务已处理</span>';
        } else if ($focus->column_fields['sostatus'] == '商务处理完毕') {
            return '<span class="ld-tags tag-green width90">商务处理完毕</span>';
        }
    }

    public function geteditfieldname()//获取可编辑的字段
    {
        global $adb;
        $sql = "select ld_field.fieldname from ld_editapprovefield 
                INNER JOIN ld_field on ld_field.fieldid = ld_editapprovefield.fieldid
                where ld_field.tabid = 22";
        $result = $adb->pquery($sql, array());
        $num = $adb->num_rows($result);
        $fieldname = array();
        if ($num > 0) {
            for ($i = 0; $i < $num; $i++) {
                $fieldname[$i] = $adb->query_result($result, $i, 'fieldname');
            }
        }
        return $fieldname;
    }

    public function selecteditfield($arr)//筛选掉不可编辑的字段，使其不显示
    {
        $fieldname = $this->geteditfieldname();
        $arr_copy = array();
        $num = 0;
        $arr_len = count($arr);
        for ($j = 0; $j < $arr_len; $j++) {
            for ($i = 0; $i < 2; $i++) {
                if (in_array($arr[$j][$i]['2']['0'], $fieldname)) {
                    $arr_copy[$num - $num % 2][$num % 2] = $arr[$j][$i];
                    $num++;
                }
            }
        }
        return $arr_copy;
    }

}

SalesOrder::require_file();
?>