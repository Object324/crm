<?php
require_once globalStatic::$root_directory . 'Register/cls_MyCRMcrypt.php';

class CRMEntity
{

    var $detailfieldobj;
    var $column_fields;
    var $mandatory_fields;
    var $ownedby;
    var $operate_api;//判断调用是否来自于接口；
    var $moduleName;
    public $module_name;
    var $columns_uitype;
    var $Detail_table = "";//明细表名称
    public $db;
    public $id;
    public $module;
    public $mode;
    public $fieldobj;
    public $name;
    private static $_instance;//单例返回类实例  editor:gyq_27 date:20170410 reason:由private改为public,供子类赋值

    public static $_controller;//单例返回类实例

    public $order_by_idx = 0;//是否为默认排序状态
    public $order_by_session_col = 'Module_Order_By';//排序字段session默认键值
    public $desc_session_col = 'Sort_By';//排序类型session默认键值
    public $logic;
    public static $modstaticarr;//模块静态类对象
    public $modstatic;//模块静态类对象
    public static $libraryobj;//include类库中的类对象
    public $library;//include类对象
    public $orderby_tables = array();//列表查询时，排序表
    //只适合单个单据的保存
    public $before_detail_info;//合同订单产品明细保存前的值
    public $after_detail_info;//合同订单产品明细保存后的值
    public $before_field_info;//保存主前表的值
    public $after_field_info;//保存后主表的值
    public $before_sourcemodule_info;    //订单产品明细编辑前的源单值
    public $is_check_business = 'yes';    //默认进行工商信息查询
    public $savedetailfield_arr = [];//分类保存从前端的request字段
    public $aftersavedetailfieldvalue_arr = [];//保存后分录的值 主表字段公式使用
    //适合批量和单个单据的保存
    public $before_save_infos;//保存主前表的值
    public $after_save_infos;//保存后主表的值
    public $saveerrormsg;
    public $popuptype;
    public $trackId;  //修改记录id
    public $logId; //操作日志id
    public $logaction; // 操作日志用于判断列表小编辑，详情页小编辑等
    public $modTrackerIds = []; //修改日志数组
    public $list_link_field;
    public $list_mode;
    public $popup_type;
    public $lineitemIds;
    public $requestfieldname_arr = [];
    public $cls_module_advance;
    public $currency_status;
    public $refreshlistmodules = [];
    public $refreshdetailmodules = [];
    public $receivecontent;// 客户，销售机会分配时的提醒内容
    public $before_lineitem_ids;
    public $record_id;
    public $firstname;
	public $lastname;
	public $tab_name;
	public $CheckValidata;
	public $saveentityNoJudge;
	public $relatedtab;
	public $is_batchbackfill;
	public $savebyerrormsg;
	public $sortby_fields;
    protected $is_needcommonsave_attachments = 'yes';// 2024-11-29 xxy 是否需要走公共代码来保存附件，推进，列表编辑等不走公共走addFileToAttachmentSavenoJudge

    protected $reportSortType = '';
    protected $reportColumnName = '';

    /**
     * Detect if we are in bulk save mode, where some features can be turned-off
     * to improve performance.
     */
    static function isBulkSaveMode()
    {
        global $LINGDANG_BULK_SAVE_MODE;
        if (isset($LINGDANG_BULK_SAVE_MODE) && $LINGDANG_BULK_SAVE_MODE) {
            return true;
        }
        return false;
    }

    public function getSourceFieldInfo()
    {
        $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("columnname", 'source_list');
        return $fieldinfo;
    }

    /**
     * 获取模块的负责人字段
     * */
    public function getSmownerColumName()
    {

        return 'smownerid';
    }


    /**
     * 获取模块创建人字段
     * */
    public function getCreateColumnName()
    {
        return "smcreatorid";
    }

    /**
     * 获取审批状态字段
     * */
    public function getApproveStatusColumnName()
    {
        return 'approvestatus';

    }

    public function getApproveStatus_label()
    {
        crm_load_class_file('Approve', 'modules/Approve');
        //return getFixedLabel('Approved');
        return D_A_S_APPROVED;
    }

    /**
     * 关联选择单据的弹窗需要区分是单选还是多选
     * */
    public function getPopuptype()
    {
        return $this->popuptype;
    }

    public function setPopuptype($popuptype)
    {
        $this->popuptype = $popuptype;
    }

    public function setsavebyerrormsg($savebyerrormsg)
    {
        $this->savebyerrormsg = $savebyerrormsg;
    }

    /**
     * 设置当前单据关联选择的模块
     * 打印
     * */
    public function setRelatedTabs($relatetabs)
    {
        $this->relatedtab = $relatetabs;
        $this->relatedtab[strtolower($this->module_name)] = '';
    }

    public function getRelatedTabs()
    {

        return $this->relatedtab;
    }
    public function getsaveerrormsg()
    {

        return $this->saveerrormsg;
    }

    static function &getStaticVar_Instance()
    {
        return self::$_instance;

    }

    static function getInstance($module)
    {
        //$focus = new $modName();
        if ($module == 'Dashboard') {
            return '';
        }
        $modarray = array('Calendar' => '1', 'Events' => '1');
        if (isset($modarray[$module])) {
            $module = 'Calendar';
            $modName = 'Activity';
        } else {
            $modName = $module;
        }
        if ($module == 'PublicAccounts') {
            //edit:can 2020-10-26 （企业微信移动端，kfbtest）客户问题（安康金源），公海客户，公海已分配页签界面，点击搜索框后面的筛选图标后再点击查看范围中的【高级】，界面一直显示加载中（需要补丁）
            $module = 'Accounts';
            $modName = 'Accounts';
        }
        if ($module == 'PublicLeads') {
            //edit:duan 2022-6-7 （亿海蓝）http://124.70.16.104:85/crm，移动端小程序，进入公海线索模块，运力交易部公海-已分配,查看范围点击高级，报错。
            $module = 'Leads';
            $modName = 'Leads';
        }
        if ($modName == 'Assets') {
            return '';
        }
        /**
         * 单例返回当前类的实例
         * @author Tujt 2014-07-24
         */

        if (!is_array(self::$_instance) || !array_key_exists($module, self::$_instance) || !(self::$_instance[$module] instanceof self)) {//是否为当前类的实例


            if (!empty($modName)) {

                globalStatic::$arr_module_require[$modName] = $modName;

                crm_load_class_file($modName, "modules/$module");
                self::$_instance[$module] = new $modName();
                self::$_instance[$module]->moduleName = $module;
                self::$_instance[$module]->module_name = $module;
            }
        }

        return self::$_instance[$module];
    }

    public function getEntityDeletedQuery()
    {
        $tasblename = strtolower($this->table_name);
        return $tasblename . '.deleted = 0 ';
    }

    /**
     * 批量删除前
     * ids:单据id的集合(数组)
     * **/
    function massDelete_before($module, $ids)
    {

    }

    /**
     * 批量删除后
     * */
    function massDelete_after($module, $ids)
    {

    }

    /**
     * 修改订单状态
     * */
    function massChangeOrder_before($module, $ids, $after_value)
    {

    }

    function massChangeOrder_after($module, $ids)
    {

    }

    /**
     * 分配负责人，修改创建人
     * $type:操作类型:allocate,changecreator
     * */
    function massChangeUser_before($module, $ids, $type)
    {

    }

    /**
     * 分配负责人，修改创建人
     * $type:操作类型:allocate,changecreator
     * */
    function massChangeUser_after($module, $ids, $type)
    {


    }

    /**
     * 批量修改/保存(保存前)
     * ids:单据id的集合(数组)
     * **/
    function massEdit_save_before($module, $ids)
    {
        crm_load_class_file("CRMEntity_Save", 'data');
        return CRMEntity_Save::massEdit_save_before($module, $ids, $this);
    }

    /**
     * 批量修改保存(保存以后)
     * ids:单据id的集合(数组)
     * */
    function massEdit_save_after($module, $ids)
    {

    }

    /**
     *edit:can
     *date:201300603
     *reason:批量添加(合同订单创建回款计划)(付款计划采购订单创建付款计划)
     * $modules:表名称所对应的模块名称的集合,表名称=>模块
     * $columns:数组下标=>表名称=>字段名称=>字段值
     * ld_crmEntity表必须是数组的第一个元素
     **/
    function MassSave($modules, $columns)
    {
        crm_load_class_file("CRMEntity_Save", 'data');
        return CRMEntity_Save::MassSave($modules, $columns, $this);
    }

    /**
     * 获取列表界面排序字段
     */
    function initSortByField($module)
    {
        global $adb;

        $exclude_columns = array('parent_id', 'quoteid', 'vendorid', 'access_count');
        $exclude_uitypes = array();

        $tabid = getTabId($module);
        if ($module == 'Calendar') {
            $tabid = array('16');
        }
        $moduleFields = $this->fieldobj->getModuleFields();

        foreach ($moduleFields as $fieldname => $fieldinfo) {
            if (strtolower(substr($fieldname, -3)) == '_id' && $fieldname != 'assigned_user_id') {
                continue;
            }
            $columnname = $fieldinfo->getColumnName();
            $uitype = $fieldinfo->getUIType();
            if (in_array($columnname, $exclude_columns)) {
                continue;
            }
            if (in_array($uitype, $exclude_uitypes)) {
                continue;
            }
            $this->sortby_fields[] = $columnname;
        }

        if ($tabid == 21 or $tabid == 22)
            $this->sortby_fields[] = 'crmid';


    }

    public function getRelateIds($relateFun_name, $id)
    {
        return $id;
    }

    function saveentity($module, $fileid = '')
    {
        global $current_user, $adb, $currentModule; //$adb added by raju for mass mailing
        $insertion_mode = $this->mode;
        $this->saveerrormsg = '';
        $columnFields = $this->column_fields;
        //ls 2022-03-31  呼博士特殊处理后，编辑保存后 负责人没了，先特殊处理下，后面可以改成更新时不更新负责人的值
        $smownercolumnname = $this->getSmownerColumName();
        $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("columnname", $smownercolumnname);
        if ($fieldinfo && empty($this->column_fields[$fieldinfo->getFieldName()])) {

            $tmp_fieldname = $fieldinfo->getFieldName();

            if ($_REQUEST['record'] > 0) {
                $tmp_result = $adb->pquery('select ' . $smownercolumnname . ' as smowner from ' . $this->table_name
                    . ' where ' . $this->table_index . ' =? LIMIT 1 ', array($this->id));
                $this->column_fields[$tmp_fieldname] = $adb->query_result($tmp_result, 0, 'smowner');
            }
        }
        //保存时判断
        if ($this->saveentityNoJudge != 'yes') {
            if ($this->CheckValidata != 'no') {
                crm_load_class_file('cls_PageValidataSave', 'data');
                $PageValidataSaveobj = new cls_PageValidataSave($module, $this->id, $_REQUEST['rowcnt']);
                if ($this->is_batchbackfill == 'yes' || $this->savebyerrormsg == 'yes') {
                    $PageValidataSaveobj->resetobj($module, $this->id);
                }
                $PageValidataSaveobj->setAllowSave('no');

                $currency_id = $_REQUEST['currency_id'];

                if (get_file_address($module, "ProductDetails")) {
                    $currency_id = $_REQUEST['inventory_currency'];
                }
                if (empty($currency_id)) {
                    //zxm 20240506 币种传过来为空 重置下币种从字段里面去查出来
                    $PageValidataSaveobj->ResetCurrencyid();
                    $currency_id = $PageValidataSaveobj->currencyid;
                    //$currency_id=1;
                }

                $PageValidataSaveobj->setCurrencyId($currency_id);
                $PageValidataSaveobj->getValidDataInfoPhp();


                if (!empty($PageValidataSaveobj->errortip)) {
                    //edit:can 20210425 保存验证规则
                    $_REQUEST['diony'] = 'yes';
                    //savebyerrormsg验证规则判断不通过,不直接converttojsonstring
                    if ($this->is_batchbackfill == 'yes' || $this->savebyerrormsg == 'yes') {
                        $this->saveerrormsg = $PageValidataSaveobj->errortip;

                        return [
                            'code'=>-1,
                            'msg' =>$PageValidataSaveobj->errortip
                        ];
                    }

                    return ConvertTojsonString("-1", array(), $PageValidataSaveobj->errortip);

                }
            }
            //没有工商信息不允许保存设置查询及例外条件匹配
            //0047610: （81mis.com/kfbcrm）服务收费管理-工商查询设置；设置中2个条件全部勾选，另外设置条件备注等于123；新增服务收费管理单据，备注填什么都无法保存单据
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($module);
            if ($businessinformationobj->IsEnableBusiness() && $this->is_check_business == 'yes') {
                $businesssave = 'yes';
                crm_load_function_file('getSaveBusiness', 'modules/Users', 'GetTianYanSearchInfo');
                $requestvalues_arr = array();
                foreach ($this->column_fields as $fieldname => $fieldvalue) {
                    $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('fieldname', $fieldname);
                    if (!$fieldinfo) {
                        continue;
                    }
                    $columnname = $fieldinfo->getColumnName();
                    $requestvalues_arr[$columnname] = $fieldvalue;
                }

                $main_table = $this->table_name;//模块主表
                $custom_table = $this->customFieldTable[0];//自定义字段表
                $tableindex = $this->table_index;//模块表主键
                $businessqueryfield_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                if (empty($requestvalues_arr[$businessqueryfield_columnname])) {//工商查询字段无字段权限时，则到数据库中取值
                    $select_sql = "SELECT $businessqueryfield_columnname FROM " . $main_table . " LEFT JOIN " . $custom_table . " ON " . $custom_table . "." . $tableindex . " = " . $main_table . "." . $tableindex . " WHERE " . $main_table . "." . $tableindex . " = ? ";
                    $select_result = $adb->pquery($select_sql, array($_REQUEST['record']));
                    $requestvalues_arr[$businessqueryfield_columnname] = $adb->query_result($select_result, 0, $businessqueryfield_columnname);
                }

                if ($this->Imoportsave == 'yes') {
                    $businesssave = getSaveBusiness($module, $requestvalues_arr, 'import');
                } else
                    $businesssave = getSaveBusiness($module, $requestvalues_arr, 'save');
                if ($businesssave == 'no') {
                    $modulelabel = getTranstab($module);
                    //ls 20220714 BUG0053853 客户管理->客户，通过高级查找后，批量编辑1113条数据的“客户状态”字段，更改为“已成交客户”，保存后返回工商信息不存在，无法继续执行(启用工商查询后，程序exit了)
                    if ($_REQUEST['ajaxaction'] == 'MassEditSave') {
                        $this->saveerrormsg = sprintf(getFixedLabel('BUSINESSQUERYUNEXIS'), $modulelabel);
                        return;
                    } //BUG0073087  	客户/服务收费管理/供应商，工商查询设置没有工商信息不允许导入时，将报错提示信息显示在失败原因导入日志中，显示“第n行“ $客户名称$”列值工商信息不存在，导入失败！”
                    else if ($this->Imoportsave == 'yes') {
                        $this->saveerrormsg = sprintf(getFixedLabel('nobusinessimportfailed'), $modulelabel);
                        return;
                    }
                    return ConvertTojsonString("-1", array(), sprintf(getFixedLabel('BUSINESSQUERYUNEXIS'), $modulelabel));
                }
            }


            foreach ($this->fieldobj->getModuleFields() as $fieldname => $fieldinfo) {

                if ($fieldinfo->getBigType() == 'selectsource') {
                    $_REQUEST['diony'] = 'yes';
                    crm_load_class_file('cls_StrictSourceBill', 'include/OptionModule');
                    if ($this->module_name == 'SalesOrder') {
                        //edit:can 20210714 45795: （https://81mis.com/kfbcrm [^]）合同订单新增-选择源单字段，设置了报价单不可以超过源单产品数量，自定义表单11不可以超过源单合计；但设置没有生效，选择源单后，修改数量和合计保存没有提示
                        if (isset($_REQUEST['selectsource']))//手机端传的是selectsourcename
                            $_REQUEST['selectsourcename'] = $_REQUEST['selectsource'];
                    }

                    $StrictSourceBillobj = new cls_StrictSourceBill($this->module_name, $_REQUEST['selectsourcename']);
                    //$_REQUEST['inventory_currency']
                    $StrictSourceBillobj->setCurrencyId($_REQUEST['inventory_currency']);
                    $StrictSourceBillobj->setRecord($_REQUEST['record']);

                    $StrictSourceBillobj->getValueByParentLineItemID();

                    $errortip = $StrictSourceBillobj->CheckAllRowStrict();
                    if ($StrictSourceBillobj->iserror == 'yes') {
                        return ConvertTojsonString("-1", array(), $errortip);

                    }

                    break;
                }
            }

            $anyValue = false;
            foreach ($columnFields as $value) {
                if (!empty($value)) {
                    $anyValue = true;
                    break;
                }
            }
            if (!$anyValue) {
                die("<center>" . getFixedLabel('MANDORYMISSING') . "</center>");
            }
        }

        $this->db->startTransaction();
        $this->requestfieldname_arr = [];
        foreach ($this->tab_name as $table_name) {
            if (strtolower($table_name) == "ld_crmentity") {
                $this->insertIntoCrmEntity($module, $fileid);
            } else if (strtolower($table_name) == "ld_receipts") {
                $this->insertIntoReceiptsTable($module, $fieldid);
            } else {
                $this->insertIntoEntityTable($table_name, $module, $fileid);
            }
        }
        
        $sql = 'select * from ld_sortfieldmapping where tabid=? ';
        $tmpresult = $adb->pquery($sql, array(getTabid($module)));
        $updatetables = [];

        for ($i = 0; $i < $adb->num_rows($tmpresult); $i++) {
            $origin_columnname = $adb->query_result($tmpresult, $i, 'origin_columnname');
            $mapping_tablename = $adb->query_result($tmpresult, $i, 'mapping_tablename');
            $mapping_columnname = $adb->query_result($tmpresult, $i, 'mapping_columnname');
            $maxvalue = $adb->query_result($tmpresult, $i, 'maxvalue');
            if ($origin_columnname == 'createdtime' && $this->mode == 'create') {
                //创建时间


                $updatetables[$mapping_tablename][] = $mapping_tablename . '.' . $mapping_columnname . '=' . ($maxvalue + 1);

            } else if ($origin_columnname == 'modifiedtime') {
                //修改时间


                $updatetables[$mapping_tablename][] = $mapping_tablename . '.' . $mapping_columnname . '=' . ($maxvalue + 1);
            } else {
                $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("columnname", $origin_columnname);
                if ($fieldinfo && ($fieldinfo->getBigType() == 'date' || $fieldinfo->getBigType() == 'datetime')) {


                    $updatetables[$mapping_tablename][] = $mapping_tablename . '.' . $mapping_columnname . '=' . ($maxvalue + 1);
                }
            }
        }

        if ($adb->num_rows($tmpresult) > 0) {
            foreach ($updatetables as $tmptable => $tmparr) {

                $sql = ' update ' . $tmptable . ' set ' . implode(",", $tmparr) . ' where ' . $this->tab_name_index[$tmptable] . '=' . $this->id;
                $adb->pquery($sql, array());

            }

            $sql = 'update ld_sortfieldmapping set maxvalue=maxvalue+1 where tabid= ' . getTabid($module);
            $adb->pquery($sql, array());
        }

        // 保存图片
        $this->insertIntoAttachment($this->id, $module);
        // 保存附件
        $this->addFileToAttachment($this->id, $module);//edit:can BUG20241118-50;
        // 保存附件图片的修改日志
        $this->modstatic->saveAttachmentImgFieldLogs($module);

        $this->save_module($module);

        //保存均摊字段值
        $this->save_shareequally($this->id, $module);
        //新增单据，保存推进阶段值
        $this->save_advancestage($this->id, $module);


        //添加进度追踪任务判断
        $this->ModuleTaskCheck($module);
        $this->db->completeTransaction();
        $this->db->println("TRANS saveentity ends");
        $this->saveshareTab($module);//广告行业的团队成员
        // vtlib customization: Hook provide to enable generic module relation.
        if ($_REQUEST['createmode'] == 'link') {
            $for_module = vtlib_purify($_REQUEST['return_module']);
            $for_crmid = vtlib_purify($_REQUEST['return_id']);
            $with_module = $module;
            $with_crmid = $this->id;

            $on_focus = CRMEntity::getInstance($for_module);
            if ($for_module && $for_crmid && $with_module && $with_crmid) {
                relateEntities($on_focus, $for_module, $for_crmid, $with_module, $with_crmid);
            }
        }

        $this->changeModuleNumber($module, $this->id);

        //  return  ;
        if (!empty($this->module_name) && $_REQUEST['file'] != 'DetailViewAjax' &&
            $_REQUEST['file'] != 'MassEditSave' && $_REQUEST['file'] != 'ListEditSave'
            && $this->module_name != 'Reminds') {


            crm_load_class_file("cls_mainfieldformula", "include/fields");
            $mainfieldformula = new cls_mainfieldformula($this->module_name);

            //设置哪些字段 在界面上保存
            $total = "-abc9999";
            $subtotal = "-abc9999";
            $adjustment = "-abc9999";
            if ($this->module_name == 'CashBill') {
                if (isset($_REQUEST['cashbill_total'])) {
                    $total = $_REQUEST['cashbill_total'];
                }
            } else if ($this->module_name == 'SendCashBill') {
                if (isset($_REQUEST['sendcashill_total'])) {
                    $total = $_REQUEST['sendcashill_total'];
                }
            } else {
                if (isset($_REQUEST['total'])) {
                    $total = $_REQUEST['total'];
                }
            }
            if (isset($_REQUEST['subtotal'])) {
                $subtotal = $_REQUEST['subtotal'];
            }
            if (isset($_REQUEST['subtotal'])) {
                $subtotal = $_REQUEST['subtotal'];
            }
            if (isset($_REQUEST['adjustment'])) {
                $adjustment = $_REQUEST['adjustment'];
            }
            $requestfieldname_arr = $this->requestfieldname_arr;
            if ($total != '-abc9999') {
                //zkt 20220621 BUG0053074http://60.247.158.183:85/crm/ 四川中卉；采购申请单>新建>保存；单据会卡住一直转圈
                $tmpfieldobj = $this->fieldobj->getFieldInfoobjBykey("columnname", 'total');
                if (!empty($tmpfieldobj)) {
                    $fieldname = $tmpfieldobj->getFieldName();
                    $requestfieldname_arr[$fieldname] = $total;
                }

            }
            //zkt 20220621 0051627(https://81mis.com/kfbtest/index.php)报价单页面设置》设置了字段  金额A  的公式为  合计*1  ；新建报价单时，分录显示异常
            if ($subtotal != '-abc9999') {
                $tmpfieldobj = $this->fieldobj->getFieldInfoobjBykey("columnname", 'subtotal');
                if (!empty($tmpfieldobj)) {
                    $fieldname = $tmpfieldobj->getFieldName();
                    $requestfieldname_arr[$fieldname] = $subtotal;
                }
            }
            if ($adjustment != '-abc9999') {
                $tmpfieldobj = $this->fieldobj->getFieldInfoobjBykey("columnname", 'adjustment');
                if (!empty($tmpfieldobj)) {
                    $fieldname = $tmpfieldobj->getFieldName();
                    $requestfieldname_arr[$fieldname] = $subtotal;
                }
            }
            $mainfieldformula->setMainFieldHadRequest($requestfieldname_arr);
            $mainfieldformula->setRecord($this->id);
            //设置数据库字段的值
            $mainfieldformula->setColumn_fieldsValue($requestfieldname_arr);
            if ($this->detailfieldobj) {


                $mainfieldformula->setDetailFieldHadRequest($this->savedetailfield_arr);
                $mainfieldformula->setdetailColumn_fieldsValue($this->aftersavedetailfieldvalue_arr);
            }

            //重新定义已经被计算的字段
            $mainfieldformula->ResetHadcomputerfieldNameByReq($requestfieldname_arr, $this->savedetailfield_arr);

            foreach ($requestfieldname_arr as $tmpfieldname => $tmpvalue) {

                $mainfieldformula->changedfieldNameEvent($tmpfieldname);
            }

            foreach ($this->savedetailfield_arr as $tmpindex => $tmpfieldname) {

                $mainfieldformula->changedDetailfieldNameEvent($tmpfieldname);
            }

            $mainfieldformula->updateAllDbValue($this->id);

        }
        if ($module != 'Reminds' && $_REQUEST['file'] != 'DetailViewAjax' && $_REQUEST['file'] != 'MassEditSave' && $_REQUEST['file'] != 'ListEditSave') {
            //工作流程反写
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');

            $workflowreverseobj = cls_savereverse::getInstance($module);
            $workflowreverseobj->setRecord($this->id);
            $beforefieldvalue_arr = [];
            $afterfieldvalue_arr = [];

            foreach ($this->before_field_info as $fieldinfo) {
                $beforefieldvalue_arr[$fieldinfo->getFieldName()] = $fieldinfo->getColumn_Value();
            }

            $afterfieldvalue_arr = $this->after_save_infos[0];
            //zkt 20240730 BUG20240730-21 用户没有工作流设置的条件字段的权限，获取到保存后的值错误
            if (!empty($this->requestfieldname_arr) && is_array($this->requestfieldname_arr)) {
                $afterfieldvalue_arr = $this->requestfieldname_arr;
                $afterfieldvalue_arr = array_merge($beforefieldvalue_arr, $afterfieldvalue_arr);
            }

            if ($this->mode == 'edit' || $this->mode == 'mass_edit') {
                $pagemode = 'updated';
            } else {
                $pagemode = 'creation';
            }

            $workflowreverseobj->setPageMode($pagemode);
            if ($workflowreverseobj->checkCallApiPop() == 'yes')
                $workflowreverseobj->setNotCallActionType(array('API', 'Link2ERP'));//无需处理的API类型
            $workflowreverseobj->getStartComputer($beforefieldvalue_arr, $afterfieldvalue_arr, $pagemode);


        }
        //单据创建后,判断是否要重算关联客户或线索的保护结束日期
        $this->check_recount_protectdate(0);

         return ['code'=>"ok",[],'success'];
    }

    function saveshareTab($module)
    {

        global $adb, $current_user;
        //清除旧共享数据


        if (array_key_exists("team_memberid", $this->column_fields)) {
            //chj 2021/9/7 47867: （http://crm.aluksen.com/ [^]）（客户问题-李发林）系统设置-角色权限，代理商权限，将团队成员勾选为只读后，成员操作编“漏斗报告”，团队成员数据变空了
            $modulefields = $this->fieldobj->getModuleFields();
            $fieldinfo = $modulefields['team_memberid'];
            if (!empty($fieldinfo)) {
                $fieldid = $fieldinfo->getFieldid();
                $profileobj = Profile::getInstance();
                $profilefields = $profileobj->getProfileInfos($current_user->profileid);
                $profilefields = $profilefields['field'];
                if ($current_user->is_admin == 'off' && !empty($profilefields) && $profilefields[$fieldid]['readonly'] == 1) {
                    return '';
                }
            }
            $arr_selectuser = explode(",", trim($this->column_fields['team_memberid'], ','));
            $arr_selectuser = array_filter($arr_selectuser);
            if (sizeof($arr_selectuser) > 0) {
                $sql_del = 'DELETE FROM ld_tabshare WHERE crmid=? and viewuserid not in (' . trim($this->column_fields['team_memberid'], ',') . ')';

                $adb->pquery($sql_del, array($this->id));

                foreach ($arr_selectuser as $selectuser) {
                    $sql_insert = 'INSERT INTO ld_tabshare (crmid, viewuserid, Shareuserid,createdtime) select ?,?,?,? from dual 
                    where not exists (select 1 from ld_tabshare where crmid=? and viewuserid=?)';
                    $adb->pquery($sql_insert, array($this->id, $selectuser, $current_user->id, date('Y-m-d H:i:s'), $this->id, $selectuser));
                    //dump(json_encode(array($this->id, $selectuser, $current_user->id, date('Y-m-d H:i:s'),$this->id,$selectuser)));
                }
            } else {
                $sql_del = 'DELETE FROM ld_tabshare WHERE crmid=? ';
                $adb->pquery($sql_del, array($this->id));
            }


        }

    }

    /**
     *
     * 删除附件
     * */
    private function deleteFileToAttachment($id, $module, $columnnamearr)
    {
        global $adb, $weixin_user, $current_user;
        $filelocationtype = 'I';

        if (empty($columnnamearr) || sizeof($columnnamearr) <= 0) {
            return;
        }

        //zkt 20230227 XUQIU1000258  角色权限-字段权限，增加“附件”字段
        //非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
        }
        //处理字段数组，有权限才能获取到对应值
        $tmpcolumnnamearr = [];
        $modulefields = $this->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            $fieldname = $fieldinfo->getFieldName();
            $columnname = $fieldinfo->getColumnName();
            if (!in_array($columnname, $columnnamearr)) {
                continue;
            }
            $uitype = $fieldinfo->getUIType();
            $fieldid = $fieldinfo->getFieldid();
            if ($uitype == 28 || $uitype == 1109) {
                //附件字段 只读和编辑时只读（编辑） 不保存附件字段
                if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                    continue;
                }
                $tmpcolumnnamearr[] = $columnname;
                $columnname2fieldname[$columnname] = $fieldname;
            }
        }
        $columnnamearr = $tmpcolumnnamearr;
        if (empty($columnnamearr) || sizeof($columnnamearr) <= 0) {
            return;
        }
        $deletedetailsql = 'select ld_attachments.`name`,ld_attachments.attachmentsid,newfile_name,path,
                      ld_attachments.storage_location,ld_attachments.cloud_path,attachmentcolumnname,ld_attachments.watermark  from ld_attachments 
                        inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                   WHERE  ld_attachments.attachmentsid not in(
                    select ld_seattachmentsrel.attachmentsid from ld_seattachmentsrel inner join ld_crmentity on ld_crmentity.crmid=ld_seattachmentsrel.attachmentsid
                    where ld_seattachmentsrel.crmid=? and ld_crmentity.setype=? ) and ld_seattachmentsrel.crmid=?';
        $deletedetailsql .= ' AND ld_seattachmentsrel.attachmentcolumnname in (\'' . implode('\',\'', $columnnamearr) . '\');';
        $tmp_result = $adb->pquery($deletedetailsql, array($id, $module . ' Image', $id));
        $tmp_delfileid = $_REQUEST['delfileid']??'';
        $delfileids = explode(",", $tmp_delfileid);
        //关联过其他单据的附件只删除记录，不删除文件
        $related_fileids = $this->attachment_related_record($id);
        if (is_array($related_fileids) && is_array($delfileids) && sizeof($related_fileids) > 0 && sizeof($delfileids) > 0) {
            foreach ($delfileids as $key => $value) {
                if (in_array($value, $related_fileids)) {
                    unset($delfileids[$key]);
                }
            }
        }

        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];
        foreach ($columnnamearr as $tmpi => $tmpcolumnname) {
            $attachmentlogsinfo_arr[$columnname2fieldname[$tmpcolumnname]]['prevalue'] = [];
        }
        // dump($attachmentlogsinfo_arr);
        
        if ($adb->num_rows($tmp_result) > 0) {
            // $delattachmentsid=$adb->query_result($tmp_result,0,0);
            $delfileList = array();
            // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
            crm_load_class_file('FileWaterMark', 'modules/Settings');
            $fileWaterMarkobj = FileWaterMark::getInstance($module);
            for ($i = 0; $i < $adb->num_rows($tmp_result); $i++) {

                $tmp_attachmentlogsinfo_arr = [];

                $attachmentcolumnname = $adb->query_result($tmp_result, $i, 'attachmentcolumnname');

                $fieldinfo = $this->fieldobj->getFieldInfoobjBykey("columnname", $attachmentcolumnname);
                //edit:can 2020-10-30 43072: （61mis.com/kfbcrm/index.php）OA表单-加班单（需要补丁）；为例，加班单中设置了两个附件字段，其中一个只读权限；管理员在只读附件上传文件后，普通成员上传另一个读写附件，导致只读附件丢失
                if (!$fieldinfo || $fieldinfo->getReadOnly() == 1) {
                    continue;
                }

                $attachmentsid = $adb->query_result($tmp_result, $i, 'attachmentsid');
                $delattachmentsid[] = $adb->query_result($tmp_result, $i, 'attachmentsid');
                $filepath = $adb->query_result($tmp_result, $i, 'path');
                $newfile_name = $adb->query_result($tmp_result, $i, 'newfile_name');
                $storage_location = $adb->query_result($tmp_result, $i, 'storage_location');
                $cloud_path = $adb->query_result($tmp_result, $i, 'cloud_path');
                $watermark = $adb->query_result($tmp_result, $i, 'watermark');
                $watermark = $watermark == 'yes' ? 'yes' : 'no';
                $fileWaterMarkobj->setWaterMarkByNewFileName($newfile_name, $watermark);
                //如果附件还被其他单据引用 不能删除该文件
                $attach_onlyone_sql = 'select attachmentsid from ld_attachments where newfile_name=? and path=? limit 1';
                $attach_onlyone_result = $adb->pquery($attach_onlyone_sql, array($newfile_name, $filepath));
                $sameattachment_num = $adb->num_rows($attach_onlyone_result);
                if (is_array($delfileids) && in_array($attachmentsid, $delfileids) && $sameattachment_num < 1) {
                    $delfileList[$i]['storage_location'] = $storage_location;
                    $delfileList[$i]['path'] = $filepath;
                    $delfileList[$i]['cloud_path'] = $cloud_path;
                    $delfileList[$i]['newfile_name'] = $newfile_name;
                }

                // 记录附件图片修改日志
                $tmp_attachmentlogsinfo_arr['attachmentsid'] = $attachmentsid;
                $tmp_attachmentlogsinfo_arr['crmid'] = $id;
                $tmp_attachmentlogsinfo_arr['name'] = $adb->query_result($tmp_result, $i, 'name');
                $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                $tmp_attachmentlogsinfo_arr['type'] = $adb->query_result($tmp_result, $i, 'type');
                $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                $tmp_attachmentlogsinfo_arr['size'] = $adb->query_result($tmp_result, $i, 'size');
                $tmp_attachmentlogsinfo_arr['imagefromtype'] = $adb->query_result($tmp_result, $i, 'imagefromtype');
                $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                $tmp_attachmentlogsinfo_arr['upload_from'] = $adb->query_result($tmp_result, $i, 'upload_from');
                $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                $tmp_attachmentlogsinfo_arr['description'] = $adb->query_result($tmp_result, $i, 'description');
                $tmp_attachmentlogsinfo_arr['watermark'] = $watermark;
                $attachmentfieldname = $columnname2fieldname[$attachmentcolumnname];
                $attachmentlogsinfo_arr[$attachmentfieldname]['prevalue'][$attachmentsid] = $tmp_attachmentlogsinfo_arr;
            }

            //从腾讯云存储桶中删除表中存储的文件
            $this->deleteQcloudFileFromTable($delfileList);
            
            if ($adb->num_rows($tmp_result) > 0 && is_array($delattachmentsid) && $delattachmentsid[0] > 0) {
                $delattachmentsid = implode(',', $delattachmentsid);
                $sql = 'delete from  ld_attachments  where attachmentsid  in ( ' . $delattachmentsid . ' )';
                $adb->pquery($sql, array());
                $deletesql = 'delete  from ld_seattachmentsrel  where  attachmentsid in( ' . $delattachmentsid . ' )';
                $adb->pquery($deletesql, array());

            }

        }

        // 记录修改日志 - 修改前
        $this->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'prevalue');
    }

    /**
     *
     * 添加附件
     * */
    function addFileToAttachment($id, $module)
    {
        //editor:gyq date:20180816 0034754: （1.6登录）联系人模块：联系人合并，合并后的单据查看明细界面“附件”和“图片”应都保留下来
        if ($_REQUEST['mergemode'] == 'mergesave') {
            return false;
        }
        global $adb, $weixin_user, $current_user;
        $filelocationtype = 'I';
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();

        /*$fieldinfo=$this->fieldobj->getFieldInfoobjBykey("uitype",1109);
           if($module=='Documents')
           {
            $fieldinfo=$this->fieldobj->getFieldInfoobjBykey("uitype",28);
           }
			if(!$fieldinfo||$fieldinfo->getFieldName()=="")//如果没有附件字段权限
			{
				return ;
			}*/

        // 2024-11-29 xxy 是否需要走公共代码来保存附件，推进，列表编辑等不走公共走addFileToAttachmentSavenoJudge
        if($this->is_needcommonsave_attachments == 'no'){
            return false;
        }
        //群发邮件时，$_REQUEST['ajxaction']为空
        //editor:gyq_164 reason:微信端编辑暂时不保存附件信息$weixin_user->environment!='weixinh5'   2019/12/20 14:23
        // @edit:dong @date:2021/07/13 @reason: api编辑单据不删除附件
        if ($module != 'Emails' && $_REQUEST['ajxaction'] != 'DETAILVIEW' && $_REQUEST['ajxaction'] != 'fieldmergersave' && $_REQUEST['ajaxaction'] != 'MassEditSave' && $_REQUEST['apiDeleteAttach'] != 'no') {//加判断原因：小编辑任意字段，结果附件被删除
            //无论编辑、新增，先删除关联的附件明细，然后重新插入
            //连接ld_crmentity做删除，是因为图片附件也是放在ld_attachments表中，这样如果一个模块有附件和图片的保存时如果不加crmentity条件就会有bug
            $modulefields = $this->fieldobj->getSaveModuleFields($this->mode);
            $tmpcolumnnamearr = array();
            foreach ($modulefields as $fieldname => $fieldinfo) {
                $fieldname = $fieldinfo->getFieldName();    
                $columnname = $fieldinfo->getColumnName();
                $uitype = $fieldinfo->getUIType();
                if ($uitype == 1109 || $uitype == 28) {
                    $tmpcolumnnamearr[] = $columnname;
                    $columnname2fieldname[$columnname] = $fieldname;        
                }
            }
            if (!empty($tmpcolumnnamearr)) {
                $this->deleteFileToAttachment($id, $module, $tmpcolumnnamearr);
            }

        }
        /*$fieldname=$this->fieldobj->getFieldInfoBykeyValue("uitype","1109","fieldname");
           if($module=='Documents')
           {
            $fieldname=$this->fieldobj->getFieldInfoBykeyValue("uitype","28","fieldname");
           }*/

        //zkt 20230227 XUQIU1000258  角色权限-字段权限，增加“附件”字段
        //非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
        }

        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];
        foreach ($tmpcolumnnamearr as $tmpi => $tmpcolumnname) {
            $attachmentlogsinfo_arr[$columnname2fieldname[$tmpcolumnname]]['postvalue'] = [];
        }

        $modulefields = $this->fieldobj->getSaveModuleFields($this->mode);
        foreach ($modulefields as $fieldname => $fieldinfo) {
            //多附件
            $bigtype = $fieldinfo->getBigType();
            $uitype = $fieldinfo->getUIType();
            $columnname = $fieldinfo->getColumnName();
            $savedatabase = $fieldinfo->getSaveDataBase();

            if ($uitype != 1109 && $uitype != 28) {
                continue;
            }
            //附件字段不保存数据库
            if ($savedatabase == 'no') {
                continue;
            }
            $fieldid = $fieldinfo->getFieldid();
            //附件字段 只读和编辑时只读（编辑） 不保存附件字段
            if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                continue;
            }
            if ($_REQUEST[$fieldname . '-file_num'] > 0) {

                //就让小于60,不要用$_REQUEST['file_name']
                for ($i = 0; $i <= 320; $i++) {

                    $tmp_attachmentlogsinfo_arr = [];

                    $filename = $_REQUEST[$fieldname . '-file_name_' . $i];    //附件名称
                    if(is_null($filename))
                        continue;
                    
                    $filename = from_html(preg_replace('/\s+/', '_', $filename));

                    $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                    $filetype = $_REQUEST[$fieldname . '-file_type_' . $i];    //附件类型
                    $filepath = $_REQUEST[$fieldname . '-file_path_' . $i];    //附件路径
                    $filesize = $_REQUEST[$fieldname . '-file_size_' . $i];    //附件大小
                    $newfile_name = $_REQUEST[$fieldname . '-newfile_name_' . $i];    //附件名

                    //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                    $isEncrypt = $_REQUEST[$fieldname . '-isEncrypt_' . $i];    //是否加密
                    $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($filepath) : $filepath;
                    $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($newfile_name) : $newfile_name;

                    $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                    $cloud_path = $_REQUEST[$fieldname . '-cloud_path_' . $i];
                    $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($cloud_path) : $cloud_path;

                    //editor:gyq_20190326 reason:小程序附件记录上传方式
                    $imagefromtype = $_REQUEST[$fieldname . '-imagefromtype_' . $i];    //附件上传的方式
                    if (empty($imagefromtype)) $imagefromtype = 'Computer';
                    if ($filename == '' && $filesize <= 0.0001) {
                        //附件删除会有错误
                        continue;
                    }
                    //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 17:09
                    //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                    $upload_from = $_REQUEST[$fieldname . '-upload_from_' . $i];
                    if (empty($upload_from) || $upload_from == 'undefined') {
                        $upload_from = '';
                    }
                    //文件存储位置:腾讯云存储桶/本地 （cos/local）
                    $storage_location = $_REQUEST[$fieldname . '-storage_location_' . $i];
                    if (empty($storage_location) || $storage_location == 'undefined') {
                        $storage_location = 'local';
                        $cloud_path = '';
                    } elseif ($storage_location == 'cos') {
                        //给存储桶链接增加头，以便界面显示


                        $cloud_path = str_replace("http://", 'https://', $cloud_path);
                        if (stripos($cloud_path, 'https://') === false) {
                            $cloud_path = 'https://' . $cloud_path;
                        } else {
                            //$cloud_path = $filepath;
                        }
                        //$filepath = '';
                        //删除文件临时表数据
                        $this->deleteQcloudTempFile($newfile_name);
                    }
                    $binFile = sanitizeUploadFileName($filename, $upload_badext);
                    $filename = str_replace(" ", "_", $filename);
                    $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
                    $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id

                    if (!strpos($filesize, 'B')) {//Liver 只有新增的附件，才需要计算附件大小并加上單位
                        if ($filesize < 1024)
                            $filesize = $filesize . ' B';
                        elseif ($filesize > 1024 && $filesize < 1048576)
                            $filesize = round($filesize / 1024, 2) . ' KB';
                        else if ($filesize > 1048576)
                            $filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                    }
                    $size = $filesize;

                    if ($filename != '') {
                        $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                        $adb->pquery($sql1, array($current_id, 'Attachment'));

                        //插入知识管理与附件明细关联表ld_seattachmentsrel
                        $sqlInsertRel = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
                        $adb->pquery($sqlInsertRel, array($this->id, $current_id, $columnname));

                        // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
                        crm_load_class_file('FileWaterMark', 'modules/Settings');
                        $fileWaterMarkobj = FileWaterMark::getInstance($module);
                        $watermark = $fileWaterMarkobj->getWaterMarkByNewFileName($newfile_name);
                        $ishas_fileWaterMarkobj = 'yes';

                        //插入附件明细表ld_attachments
                        $sqlInsertAttachments = 'insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from,watermark) values(?,?,?, ?, ?, ?, ?,?,?,?,?,?)';//description不知道什么，暂时去掉
                        $adb->pquery($sqlInsertAttachments, array($current_id, $filename, $newfile_name, '-无-', $filetype, $filepath, $size, $imagefromtype, $cloud_path, $storage_location, $upload_from, $watermark));

                        $word_watermark = $fieldinfo->getWordWaterMark();
                        $excel_watermark = $fieldinfo->getExcelWaterMark();
                        if ($watermark == 'no' && ($word_watermark == 'yes' || $excel_watermark == 'yes') && $storage_location == 'local' && ($uitype == 1109 || $uitype == 28) && $fileWaterMarkobj->issetGD == 'yes') {
                            $info['fieldname'] = $fieldname;
                            $info['uitype'] = $uitype;
                            $info['module'] = $module;
                            $info['word_watermark'] = $word_watermark;
                            $info['excel_watermark'] = $excel_watermark;
                            $info['attachmentsid'] = $current_id;
                            $info['recordid'] = $this->id;
                            $info['storage_location'] = $storage_location;
                            $info['newfile_name'] = $newfile_name;
                            $info['watermark'] = $watermark;//是否有水印
                            $info['path'] = $filepath;
                            $fileWaterMarkobj->addWaterMark($info);
                        }

                        // 记录附件图片修改日志
                        $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                        $tmp_attachmentlogsinfo_arr['crmid'] = $id;
                        $tmp_attachmentlogsinfo_arr['name'] = $filename;
                        $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                        $tmp_attachmentlogsinfo_arr['type'] = $filetype;
                        $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                        $tmp_attachmentlogsinfo_arr['size'] = $size;
                        $tmp_attachmentlogsinfo_arr['imagefromtype'] = $imagefromtype;
                        $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                        $tmp_attachmentlogsinfo_arr['upload_from'] = $upload_from;
                        $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                        $tmp_attachmentlogsinfo_arr['description'] = '-无-';
                        $tmp_attachmentlogsinfo_arr['watermark'] = $watermark;
                        $attachmentlogsinfo_arr[$fieldname]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;

                        //if ($storage_location == 'local')
                        //$adb->pquery("update ld_attachments set path=?,storage_location=?,cloud_path=? where attachmentsid=?",array('key','awsserver','cloud_path',$current_id));

                        //TODO 百特，local则转存aws，已经是awsserver的不用处理(编辑)。
                        if (getVersionInfo()['account'] == 'baxter' && $storage_location == 'local') {
                            crm_load_class_file('AWS', 'include');
                            $aws = AWS::getInstance();
                            if (file_exists($filepath . $newfile_name)) {
                                $aws_path = 'crm/' . $aws->bucket . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
                                $cloud_path = $aws->uploadFileByPath($aws_path . $newfile_name, $filepath . $newfile_name);

                                //$adb->pquery('INSERT INTO ld_baxterfilelog(title,file_name,file_type,file_path,cloud_path,crmid,creator) VALUES(?,?,?,?,?,?,?);',array(pathinfo($newfile_name, PATHINFO_FILENAME),$newfile_name,pathinfo($newfile_name, PATHINFO_EXTENSION),$aws_path,$cloud_path,$this->id,$this->column_fields['smcreatorid']));
                                if (!empty($cloud_path)) {
                                    //成功后，删除本地文件
                                    @unlink(globalStatic::$root_directory . $filepath . $newfile_name);
                                    //更新为awsserver
                                    $adb->pquery("update ld_attachments set path=?,storage_location=?,cloud_path=? where attachmentsid=?", array($aws_path, 'awsserver', $cloud_path, $current_id));
                                }

                            }
                        }
                    }


                }
            }
        }
        // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆） 判断是否有对象
        if (!empty($ishas_fileWaterMarkobj) && $ishas_fileWaterMarkobj == 'yes') {
            $fileWaterMarkobj->deleteTextImagePath();
        }

        // 记录修改日志 - 修改后
        $this->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'postvalue');
        
    }

    /**
     *
     * 添加附件、图片，直接保存附件，没有特殊判断
     * $columnnamearr['filetoattachment']保存的附件字段columnname数组
     * $columnnamearr['imageattachment']保存的图片字段columnname数组
     * */
    function addFileToAttachmentSavenoJudge($id, $module, $columnnamearr)
    {

        global $adb, $weixin_user, $current_user;
        $filelocationtype = 'I';
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        if (empty($columnnamearr) || sizeof($columnnamearr) <= 0) {
            return;
        }

        //无论编辑、新增，先删除关联的附件明细，然后重新插入
        //连接ld_crmentity做删除，是因为图片附件也是放在ld_attachments表中，这样如果一个模块有附件和图片的保存时如果不加crmentity条件就会有bug
        if (!empty($columnnamearr['filetoattachment'])) {//附件字段保存删除
            $this->deleteFileToAttachment($id, $module, $columnnamearr['filetoattachment']);
        }
        if (!empty($columnnamearr['imageattachment'])) {
            //删除图片
            $this->deleteAttachment($id, $module, $columnnamearr['imageattachment']);
        }

        //zkt 20230227 XUQIU1000258  角色权限-字段权限，增加“附件”字段
        //非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
        }
        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];
        // $this->modstatic->initAttachmentImgLogs();
        //添加图片、附件
        $modulefields = $this->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            //多附件
            $bigtype = $fieldinfo->getBigType();
            $uitype = $fieldinfo->getUIType();
            $columnname = $fieldinfo->getColumnName();
            $savedatabase = $fieldinfo->getSaveDataBase();
            if (is_array($columnnamearr['imageattachment']) && !in_array($columnname, $columnnamearr['imageattachment']) && 
                is_array($columnnamearr['filetoattachment']) && !in_array($columnname, $columnnamearr['filetoattachment'])) {
                continue;
            }
            if ($uitype != 1109 && $uitype != 28 && $uitype != 69) {
                continue;
            }
            $fieldid = $fieldinfo->getFieldid();
            //附件字段 只读和编辑时只读（编辑） 不保存附件字段
            if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                continue;
            }
            //图片/附件字段 不保存数据库
            if ($savedatabase == 'no') {
                continue;
            }

            // 初始化附件图片日志信息数组
            $attachmentlogsinfo_arr[$fieldname]['postvalue'] = [];

            if ($uitype == 1109 || $uitype == 28) {
                //添加附件
                if ($_REQUEST[$fieldname . '-file_num'] > 0) {

                    //就让小于60,不要用$_REQUEST['file_name']
                    for ($i = 0; $i <= 220; $i++) {

                        $tmp_attachmentlogsinfo_arr = [];

                        $filename = $_REQUEST[$fieldname . '-file_name_' . $i];    //附件名称


                        $filetype = $_REQUEST[$fieldname . '-file_type_' . $i];    //附件类型
                        $filepath = $_REQUEST[$fieldname . '-file_path_' . $i];    //附件路径
                        $filesize = $_REQUEST[$fieldname . '-file_size_' . $i];    //附件大小
                        if ($filename == '' && $filesize <= 0.0001) {
                            //附件删除会有错误
                            continue;
                        }
                        $filename = from_html(preg_replace('/\s+/', '_', $filename));

                        $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $newfile_name = $_REQUEST[$fieldname . '-newfile_name_' . $i];    //附件名

                        //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                        $isEncrypt = $_REQUEST[$fieldname . '-isEncrypt_' . $i];    //是否加密
                        $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($filepath) : $filepath;
                        $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($newfile_name) : $newfile_name;

                        $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $cloud_path = $_REQUEST[$fieldname . '-cloud_path_' . $i];
                        $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($cloud_path) : $cloud_path;


                        //editor:gyq_20190326 reason:小程序附件记录上传方式
                        $imagefromtype = $_REQUEST[$fieldname . '-imagefromtype_' . $i];    //附件上传的方式
                        if (empty($imagefromtype)) $imagefromtype = 'Computer';

                        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/26 17:09
                        //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                        $upload_from = $_REQUEST[$fieldname . '-upload_from_' . $i];
                        if (empty($upload_from) || $upload_from == 'undefined') {
                            $upload_from = '';
                        }
                        //文件存储位置:腾讯云存储桶/本地 （cos/local）
                        $storage_location = $_REQUEST[$fieldname . '-storage_location_' . $i];
                        if (empty($storage_location) || $storage_location == 'undefined') {
                            $storage_location = 'local';
                            $cloud_path = '';
                        } elseif ($storage_location == 'cos') {
                            //给存储桶链接增加头，以便界面显示


                            $cloud_path = str_replace("http://", 'https://', $cloud_path);
                            if (stripos($cloud_path, 'https://') === false) {
                                $cloud_path = 'https://' . $cloud_path;
                            } else {
                                //$cloud_path = $filepath;
                            }
                            //$filepath = '';
                            //删除文件临时表数据
                            $this->deleteQcloudTempFile($newfile_name);
                        }
                        $binFile = sanitizeUploadFileName($filename, $upload_badext);
                        $filename = str_replace(" ", "_", $filename);
                        $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
                        $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id

                        if (!strpos($filesize, 'B')) {//Liver 只有新增的附件，才需要计算附件大小并加上單位
                            if ($filesize < 1024)
                                $filesize = $filesize . ' B';
                            elseif ($filesize > 1024 && $filesize < 1048576)
                                $filesize = round($filesize / 1024, 2) . ' KB';
                            else if ($filesize > 1048576)
                                $filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                        }
                        $size = $filesize;
                        
                        if ($filename != '') {
                            $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                            $adb->pquery($sql1, array($current_id, 'Attachment'));

                            //插入知识管理与附件明细关联表ld_seattachmentsrel
                            $sqlInsertRel = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
                            $adb->pquery($sqlInsertRel, array($this->id, $current_id, $columnname));
                            if (empty($filetype)) {
                                $filetype = getFileTypeByfilename($newfile_name);

                            }

                            // ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
                            crm_load_class_file('FileWaterMark', 'modules/Settings');
                            $fileWaterMarkobj = FileWaterMark::getInstance($module);
                            $watermark = $fileWaterMarkobj->getWaterMarkByNewFileName($newfile_name);
                            $ishas_fileWaterMarkobj = 'yes';

                            //插入附件明细表ld_attachments
                            $sqlInsertAttachments = 'insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,cloud_path,storage_location,upload_from,watermark) values(?,?,?, ?, ?, ?, ?,?,?,?,?,?)';//description不知道什么，暂时去掉
                            $adb->pquery($sqlInsertAttachments, array($current_id, $filename, $newfile_name, '-无-', $filetype, $filepath, $size, $imagefromtype, $cloud_path, $storage_location, $upload_from, $watermark));
                            
                            $word_watermark = $fieldinfo->getWordWaterMark();
                            $excel_watermark = $fieldinfo->getExcelWaterMark();
                            if ($watermark == 'no' && ($word_watermark == 'yes' || $excel_watermark == 'yes') && $storage_location == 'local' && ($uitype == 1109 || $uitype == 28) && $fileWaterMarkobj->issetGD == 'yes') {
                                $info['fieldname'] = $fieldname;
                                $info['uitype'] = $uitype;
                                $info['module'] = $module;
                                $info['word_watermark'] = $word_watermark;
                                $info['excel_watermark'] = $excel_watermark;
                                $info['attachmentsid'] = $current_id;
                                $info['recordid'] = $this->id;
                                $info['storage_location'] = $storage_location;
                                $info['newfile_name'] = $newfile_name;
                                $info['watermark'] = $watermark;//是否有水印
                                $info['path'] = $filepath;
                                $fileWaterMarkobj->addWaterMark($info);
                            }

                            // 记录附件图片修改日志
                            $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                            $tmp_attachmentlogsinfo_arr['crmid'] = $id;
                            $tmp_attachmentlogsinfo_arr['name'] = $filename;
                            $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                            $tmp_attachmentlogsinfo_arr['type'] = $filetype;
                            $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                            $tmp_attachmentlogsinfo_arr['size'] = $size;
                            $tmp_attachmentlogsinfo_arr['imagefromtype'] = $imagefromtype;
                            $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                            $tmp_attachmentlogsinfo_arr['upload_from'] = $upload_from;
                            $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                            $tmp_attachmentlogsinfo_arr['description'] = '-无-';
                            $tmp_attachmentlogsinfo_arr['watermark'] = $watermark;
                            $attachmentlogsinfo_arr[$fieldname]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;

                            //TODO 百特，local则转存aws，已经是awsserver的不用处理(编辑)(列表编辑等)。
                            if (getVersionInfo()['account'] == 'baxter' && $storage_location == 'local') {
                                crm_load_class_file('AWS', 'include');
                                $aws = AWS::getInstance();
                                if (file_exists($filepath . $newfile_name)) {
                                    $aws_path = 'crm/' . $aws->bucket . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
                                    $cloud_path = $aws->uploadFileByPath($aws_path . $newfile_name, $filepath . $newfile_name);

                                    //$adb->pquery('INSERT INTO ld_baxterfilelog(title,file_name,file_type,file_path,cloud_path,crmid,creator) VALUES(?,?,?,?,?,?,?);',array(pathinfo($newfile_name, PATHINFO_FILENAME),$newfile_name,pathinfo($newfile_name, PATHINFO_EXTENSION),$aws_path,$cloud_path,$this->id,$this->column_fields['smcreatorid']));
                                    if (!empty($cloud_path)) {
                                        @unlink(globalStatic::$root_directory . $filepath . $newfile_name);
                                        //更新为awsserver
                                        $adb->pquery("update ld_attachments set path=?,storage_location=?,cloud_path=? where attachmentsid=?", array($aws_path, 'awsserver', $cloud_path, $current_id));
                                    }

                                }
                            }

                        }


                    }
                }
            } else if ($uitype == 69) {
                if ($_REQUEST[$fieldname . '-file_num'] > 0) {
                    for ($i = 1; $i <= 220; $i++) {

                        $tmp_attachmentlogsinfo_arr = [];

                        $filename = $_REQUEST[$fieldname . '-file_name_' . $i];    //附件名称
                        //
                        $filename = from_html(preg_replace('/\s+/', '_', $filename));
                        $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $filetype = $_REQUEST[$fieldname . '-file_type_' . $i];    //附件类型
                        $filepath = $_REQUEST[$fieldname . '-file_path_' . $i];    //附件路径

                        $filesize = $_REQUEST[$fieldname . '-file_size_' . $i];    //附件大小
                        $newfile_name = $_REQUEST[$fieldname . '-newfile_name_' . $i];    //附件在服务器上名称

                        //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                        $isEncrypt = $_REQUEST[$fieldname . '-isEncrypt_' . $i];    //是否加密
                        $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($filepath) : $filepath;
                        $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($newfile_name) : $newfile_name;

                        $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                        $newfile_name = str_replace("&", "_", $newfile_name);
                        //editor:gyq_20190326 reason:小程序附件记录上传方式
                        $imagefromtype = $_REQUEST[$fieldname . '-imagefromtype_' . $i];    //附件上传的方式
                        if (empty($imagefromtype)) $imagefromtype = 'Computer';
                        if ($filename == '' && $filesize <= 0.0001) {
                            //附件删除会有错误
                            continue;
                        }
                        //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                        $upload_from = $_REQUEST[$fieldname . '-upload_from_' . $i];
                        if (empty($upload_from) || $upload_from == 'undefined') {
                            $upload_from = '';
                        }
                        //文件存储位置:腾讯云存储桶/本地 （cos/local）
                        $storage_location = $_REQUEST[$fieldname . '-storage_location_' . $i];
                        if (empty($storage_location) || $storage_location == 'undefined') {
                            $storage_location = 'local';
                            $cloud_path = '';
                        } elseif ($storage_location == 'cos') {
                            //给存储桶链接增加头，以便界面显示
                            $cloud_path = $_REQUEST[$fieldname . '-cloud_path_' . $i];    //附件路径
                            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($cloud_path) : $cloud_path;
                            $cloud_path = str_replace("http://", 'https://', $cloud_path);
                            if (stripos($cloud_path, 'https://') === false) {
                                $cloud_path = 'https://' . $cloud_path;
                            }
                            //else{
                            //                        $cloud_path = $filepath;
                            //                    }

                            //删除文件临时表数据
                            $this->deleteQcloudTempFile($newfile_name);
                        }

                        $binFile = sanitizeUploadFileName($filename, $upload_badext);
                        $filename = str_replace(" ", "_", $filename);
                        $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
                        $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id
                        $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                        $params1 = array($current_id, $module . " Image");
                        $adb->pquery($sql1, $params1);
                        if (empty($filetype)) {
                            $filetype = getFileTypeByfilename($newfile_name);

                        }
                        $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name, description, 
                      type, path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?, ?, ?, ?,?,?,?,?,?)";
                        $params2 = array($current_id, $filename, $newfile_name, "", $filetype, $filepath, $filesize,
                            $imagefromtype, $cloud_path, $storage_location, $upload_from);

                        $result = $adb->pquery($sql2, $params2);
                        $sql3 = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                        $adb->pquery($sql3, array($this->id, $current_id, $columnname));

                        // 记录附件图片修改日志
                        $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                        $tmp_attachmentlogsinfo_arr['crmid'] = $id;
                        $tmp_attachmentlogsinfo_arr['name'] = $filename;
                        $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                        $tmp_attachmentlogsinfo_arr['type'] = $filetype;
                        $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                        $tmp_attachmentlogsinfo_arr['size'] = $filesize;
                        $tmp_attachmentlogsinfo_arr['imagefromtype'] = $imagefromtype;
                        $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                        $tmp_attachmentlogsinfo_arr['upload_from'] = $upload_from;
                        $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                        $tmp_attachmentlogsinfo_arr['description'] = '';
                        $tmp_attachmentlogsinfo_arr['watermark'] = 'no';
                        $attachmentlogsinfo_arr[$fieldname]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;

                    }
                }
            }
        }
        if (!empty($ishas_fileWaterMarkobj) && $ishas_fileWaterMarkobj == 'yes') {
            $fileWaterMarkobj->deleteTextImagePath();
        }

        // 记录修改日志 - 修改后
        $this->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'postvalue');
        // 保存日志
        $this->modstatic->saveAttachmentImgFieldLogs($module);
        
    }

    //工作流程定制同步
    public function save_workflow($module, $focus, $workflow_tiggertime = '')
    {
        crm_load_class_file('cls_WorkFlow', 'include/Workflow');
        $cls_WorkFlow = new cls_WorkFlow($module, $focus, $workflow_tiggertime);
        $cls_WorkFlow->save();
    }

    /**
     * 删除图片附件
     *
     **/
    private function deleteAttachment($id, $module, $columnnamearr)
    {
        global $adb, $weixin_user, $current_user;
        if (empty($columnnamearr)) {
            return;
        }
        //zkt 20230227 XUQIU1000258  角色权限-字段权限，增加“附件”字段
        //非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
        }
        //处理字段数组，有权限才能获取到对应值
        $tmpcolumnnamearr = [];
        $modulefields = $this->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            $fieldname = $fieldinfo->getFieldName();
            $columnname = $fieldinfo->getColumnName();
            if (!in_array($columnname, $columnnamearr)) {
                continue;
            }
            $uitype = $fieldinfo->getUIType();
            $fieldid = $fieldinfo->getFieldid();
            if ($uitype == 69) {
                //图片字段 只读和编辑时只读（编辑） 不保存图片字段
                if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                    continue;
                }
                $tmpcolumnnamearr[] = $columnname;
                $columnname2fieldname[$columnname] = $fieldname;
            }
        }
        if (empty($tmpcolumnnamearr)) {
            return;
        }
        $columnnamearr = $tmpcolumnnamearr;
        $sql = "SELECT ld_seattachmentsrel.attachmentsid,ld_seattachmentsrel.attachmentcolumnname,
                    ld_attachments.`name`,ld_attachments.path,ld_attachments.newfile_name,ld_attachments.type,ld_attachments.size,ld_attachments.imagefromtype,
                    ld_attachments.storage_location,ld_attachments.upload_from,ld_attachments.cloud_path,ld_attachments.description,ld_attachments.watermark 
                from ld_seattachmentsrel
                inner join ld_crmentity on ld_seattachmentsrel.attachmentsid=ld_crmentity.crmid  
                inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
                where ld_seattachmentsrel.crmid=?
                and ld_crmentity.setype='$module Image' and FIND_IN_SET(ld_seattachmentsrel.attachmentcolumnname,?);";
        $deletedetailsql .= ' AND ld_seattachmentsrel.attachmentcolumnname in (\'' . implode('\',\'', $columnnamearr) . '\');';
        $imagedelfileid_str = $_REQUEST['imagedelfileid']??'';
        $imagedelfileid = explode(",", $imagedelfileid_str);
        //关联过其他单据的附件只删除记录，不删除文件
        $related_fileids = $this->attachment_related_record($id);
        if (sizeof($related_fileids) > 0 && sizeof($imagedelfileid) > 0) {
            foreach ($imagedelfileid as $key => $value) {
                if (in_array($value, $related_fileids)) {
                    unset($imagedelfileid[$key]);
                }
            }
        }
        
        $result = $adb->pquery($sql, array($id, implode(',', $columnnamearr)));
        
        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];
        foreach ($tmpcolumnnamearr as $tmpi => $tmpcolumnname) {
            $attachmentlogsinfo_arr[$columnname2fieldname[$tmpcolumnname]]['prevalue'] = [];
        }

        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $tmp_attachmentlogsinfo_arr = [];
            $attachments_id = $adb->query_result($result, $i, 'attachmentsid');
            $attachmentcolumnname = $adb->query_result($result, $i, 'attachmentcolumnname');
            $sql = 'delete from ld_crmentity where crmid=?';
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_seattachmentsrel where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_attachments  where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $newfile_name = $adb->query_result($result, $i, 'newfile_name');
            $path = $adb->query_result($result, $i, 'path');
            $storage_location = $adb->query_result($result, $i, 'storage_location');
            $cloud_path = $adb->query_result($result, $i, 'cloud_path');
            // 记录附件图片修改日志
            $tmp_attachmentlogsinfo_arr['attachmentsid'] = $attachments_id;
            $tmp_attachmentlogsinfo_arr['crmid'] = $id;
            $tmp_attachmentlogsinfo_arr['name'] = $adb->query_result($result, $i, 'name');
            $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
            $tmp_attachmentlogsinfo_arr['type'] = $adb->query_result($result, $i, 'type');
            $tmp_attachmentlogsinfo_arr['path'] = $adb->query_result($result, $i, 'path');
            $tmp_attachmentlogsinfo_arr['size'] = $adb->query_result($result, $i, 'size');
            $tmp_attachmentlogsinfo_arr['imagefromtype'] = $adb->query_result($result, $i, 'imagefromtype');
            $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
            $tmp_attachmentlogsinfo_arr['upload_from'] = $adb->query_result($result, $i, 'upload_from');
            $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
            $tmp_attachmentlogsinfo_arr['description'] = $adb->query_result($result, $i, 'description');
            $tmp_attachmentlogsinfo_arr['watermark'] = $adb->query_result($result, $i, 'watermark');
            $attachmentfieldname = $columnname2fieldname[$attachmentcolumnname];
            $attachmentlogsinfo_arr[$attachmentfieldname]['prevalue'][$attachments_id] = $tmp_attachmentlogsinfo_arr;
            //如果附件还被其他单据引用 不能删除该文件
            $attach_onlyone_sql = 'select attachmentsid from ld_attachments where newfile_name=? and path=? limit 1';
            $attach_onlyone_result = $adb->pquery($attach_onlyone_sql, array($newfile_name, $path));
            $sameattachment_num = $adb->num_rows($attach_onlyone_result);
            if (is_array($imagedelfileid) && in_array($attachments_id, $imagedelfileid) && $sameattachment_num < 1) {
                $delfileList[$i]['storage_location'] = $storage_location;
                $delfileList[$i]['path'] = $path;
                $delfileList[$i]['cloud_path'] = $cloud_path;
                $delfileList[$i]['newfile_name'] = $newfile_name;

            }
        }

        // 记录修改日志 - 修改前
        $this->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'prevalue');

        //将服务器里附件同步删除
        //zxm 2021-0903 获客文章的图片不能删除  会存在被领取的源文件封面被删除的情况
        if ($module != "Articles") {
            // $this->deleteQcloudFileFromTable($delfileList);
        }
    }

    /**
     * 添加图片附件
     *
     **/
    function insertIntoAttachment($id, $module)
    {

        global $adb, $weixin_user, $current_user;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        //editor:gyq_166 reason:钉钉模块图片上传补充,开启图片字段,且有值   2020/1/6 13:54
        //20210120
        /* if ($weixin_user->environment == 'weixinh5' ) {
              if( !empty($_REQUEST['image_save_weixin']) && $this->fieldobj->getFieldInfoobjBykey("uitype", 69))
              {
                    crm_load_class_file("cls_SaveWX", 'WeiXinApp/detail');
                    $saveObj = new cls_SaveWX(null);
                    $saveObj->saveFileFromWeiXinApi_CommonModule($id, $module, $_REQUEST['image_save_weixin']);
            }
            return false;
        }*/
        //editor:gyq date:20180810 0034754: （1.6登录）联系人模块：联系人合并，合并后的单据查看明细界面“附件”和“图片”应都保留下来
        if ($_REQUEST['mergemode'] == 'mergesave') {
            return false;
        }

        // 2024-11-29 xxy 是否需要走公共代码来保存附件，推进，列表编辑等不走公共走addFileToAttachmentSavenoJudge
        if($this->is_needcommonsave_attachments == 'no'){
            return false;
        }

        if ($_REQUEST['ajxaction'] == 'DETAILVIEW' || $_REQUEST['ajaxaction'] == 'MassEditSave' || $_REQUEST['action'] == 'ProcessDuplicates' || $_REQUEST['create_view'] == 'create_view' || $_REQUEST['apiDeleteAttach'] == 'no') {
            //34797: 新建账套-产品管理，使用小编辑功能编辑产品信息，会导致产品图片丢失
            //48350: （81mis.com/kfbcrm）产品管理》批量编辑，编辑单据保存后，产品详情中的图片消失了
            return;
        }
        //  if((get_file_address($module,"ProductDetails")||get_file_address($module,$module."DetailFieldsHtml"))&&$module!='ServiceCharge')
        //  {
        //return $this->insertIntoDetailAttachment($id,$module);

        //}
        /*$fieldinfo = $this->fieldobj->getFieldInfoobjBykey("uitype", 69);

        if (!$fieldinfo)//如果没有图片字段
        {
            return;
        }*/


        /*if($weixin_user->environment_weixin){//移动端主表图片字段暂时没做，删除动作需要处理
            return;
        }*/
//        $columnname = $fieldinfo->getColumnName();

        //zkt 20230227 XUQIU1000258  角色权限-字段权限，增加“附件”字段
        //非管理员字段权限
        if ($current_user->is_admin == 'off') {
            $profilefields = $this->getProfileFields($current_user->profileid);
        }

        $modulefields = $this->fieldobj->getSaveModuleFields($this->mode);
        $tmpcolumnnamearr = array();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            $fieldname = $fieldinfo->getFieldName();
            $columnname = $fieldinfo->getColumnName();
            $uitype = $fieldinfo->getUIType();
            $fieldid = $fieldinfo->getFieldid();
            if ($uitype == 69) {
                //图片字段 只读和编辑时只读（编辑） 不保存图片字段
                if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                    continue;
                }
                $tmpcolumnnamearr[] = $columnname;
                $columnname2fieldname[$columnname] = $fieldname;    
            }
        }
        
        if (!empty($tmpcolumnnamearr)) {
            //删除图片
            $this->deleteAttachment($id, $module, $tmpcolumnnamearr);
        }

        $fieldname = $this->fieldobj->getFieldInfoBykeyValue("uitype", "69", "fieldname");
        $file_saved = false;

        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];
        foreach ($tmpcolumnnamearr as $tmpi => $tmpcolumnname) {
            $attachmentlogsinfo_arr[$columnname2fieldname[$tmpcolumnname]]['postvalue'] = [];
        }

        //ls 2022-04-06 【1002543】页面设置，增加“图片”字段类型
        $modulefields = $this->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            $uitype = $fieldinfo->getUIType();
            $columnname = $fieldinfo->getColumnName();
            $savedatabase = $fieldinfo->getSaveDataBase();
            if ($uitype != 69) {
                continue;
            }
            //图片字段 不保存数据库
            if ($savedatabase == 'no') {
                continue;
            }
            $fieldid = $fieldinfo->getFieldid();
            //图片字段 只读和编辑时只读（编辑） 不保存图片字段
            if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || ($profilefields[$fieldid]['editreadonly'] == 1 && !($_REQUEST['Create'] == 'yes' || $this->mode == 'create')))) {
                continue;
            }
            //duan 20230212 客户模块选择的联系人字段不需要保存附件信息
            if (strpos($fieldname, '_mapping') !== false) {
                continue;
            }
            if ($_REQUEST[$fieldname . '-file_num'] > 0) {
                for ($i = 1; $i <= 220; $i++) {

                    $tmp_attachmentlogsinfo_arr = [];

                    $filename = $_REQUEST[$fieldname . '-file_name_' . $i];    //附件名称
                    //
                    $filename = !empty($filename)?from_html(preg_replace('/\s+/', '_', $filename)):'';
                    $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                    $filetype = $_REQUEST[$fieldname . '-file_type_' . $i];    //附件类型
                    $filepath = $_REQUEST[$fieldname . '-file_path_' . $i];    //附件路径

                    $filesize = $_REQUEST[$fieldname . '-file_size_' . $i];    //附件大小
                    $newfile_name = $_REQUEST[$fieldname . '-newfile_name_' . $i];    //附件在服务器上名称

                    //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                    $isEncrypt = $_REQUEST[$fieldname . '-isEncrypt_' . $i];    //是否加密
                    $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($filepath) : $filepath;
                    $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($newfile_name) : $newfile_name;

                    $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                    $newfile_name = !empty($filename)?str_replace("&", "_", $newfile_name):'';
                    //editor:gyq_20190326 reason:小程序附件记录上传方式
                    $imagefromtype = $_REQUEST[$fieldname . '-imagefromtype_' . $i];    //附件上传的方式
                    if (empty($imagefromtype)) $imagefromtype = 'Computer';
                    if ($filename == '' && $filesize <= 0.0001) {
                        //附件删除会有错误
                        continue;
                    }
                    //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                    $upload_from = $_REQUEST[$fieldname . '-upload_from_' . $i];
                    if (empty($upload_from) || $upload_from == 'undefined') {
                        $upload_from = '';
                    }
                    //文件存储位置:腾讯云存储桶/本地 （cos/local）
                    $storage_location = $_REQUEST[$fieldname . '-storage_location_' . $i];
                    if (empty($storage_location) || $storage_location == 'undefined') {
                        $storage_location = 'local';
                        $cloud_path = '';
                    } elseif ($storage_location == 'cos') {
                        //给存储桶链接增加头，以便界面显示
                        $cloud_path = $_REQUEST[$fieldname . '-cloud_path_' . $i];    //附件路径
                        $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt->decode($cloud_path) : $cloud_path;
                        $cloud_path = str_replace("http://", 'https://', $cloud_path);
                        if (stripos($cloud_path, 'https://') === false) {
                            $cloud_path = 'https://' . $cloud_path;
                        }
                        //else{
                    //     $cloud_path = $filepath;
                    // }

                        //删除文件临时表数据
                        $this->deleteQcloudTempFile($newfile_name);
                    }

                    $binFile = sanitizeUploadFileName($filename, $upload_badext);
                    $filename = str_replace(" ", "_", $filename);
                    $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters
                    $current_id = $adb->getUniqueID("ld_crmentity");//附件明细id
                    $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
                    $params1 = array($current_id, $module . " Image");
                    $adb->pquery($sql1, $params1);
                    if (empty($filetype)) {
                        $filetype = getFileTypeByfilename($newfile_name);

                    }
                    $sql2 = "insert into ld_attachments(attachmentsid, name,newfile_name, description, 
                                type, path,size,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?, ?, ?, ?,?,?,?,?,?)";
                    $params2 = array($current_id, $filename, $newfile_name, "", $filetype, $filepath, $filesize,
                        $imagefromtype, $cloud_path, $storage_location, $upload_from);

                    $result = $adb->pquery($sql2, $params2);
                    $sql3 = 'insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname) values(?,?,?)';
                    $adb->pquery($sql3, array($this->id, $current_id, $columnname));

                    // 记录附件图片修改日志
                    $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                    $tmp_attachmentlogsinfo_arr['crmid'] = $id;
                    $tmp_attachmentlogsinfo_arr['name'] = $filename;
                    $tmp_attachmentlogsinfo_arr['newfile_name'] = $newfile_name;
                    $tmp_attachmentlogsinfo_arr['type'] = $filetype;
                    $tmp_attachmentlogsinfo_arr['path'] = $filepath;
                    $tmp_attachmentlogsinfo_arr['size'] = $filesize;
                    $tmp_attachmentlogsinfo_arr['imagefromtype'] = $imagefromtype;
                    $tmp_attachmentlogsinfo_arr['storage_location'] = $storage_location;
                    $tmp_attachmentlogsinfo_arr['upload_from'] = $upload_from;
                    $tmp_attachmentlogsinfo_arr['cloud_path'] = $cloud_path;
                    $tmp_attachmentlogsinfo_arr['description'] = '';
                    $tmp_attachmentlogsinfo_arr['watermark'] = 'no';
                    $attachmentlogsinfo_arr[$fieldname]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;
                }
            }
        }

        // 记录修改日志 - 修改后
        $this->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'postvalue');

        /*

		if( $_REQUEST['del_file_list'] != '')
		{

			$del_file_list = explode("###",trim($_REQUEST['del_file_list'],"###"));
			foreach($del_file_list as $del_file_name)
			{
				$attach_res = $adb->pquery("select ld_attachments.attachmentsid from ld_attachments inner join ld_seattachmentsrel
                on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid where crmid=? and name=?", array($id,$del_file_name));
				$attachments_id = $adb->query_result($attach_res,0,'attachmentsid');

				$del_res1 = $adb->pquery("delete from ld_attachments where attachmentsid=?", array($attachments_id));
				$del_res2 = $adb->pquery("delete from ld_seattachmentsrel where attachmentsid=?", array($attachments_id));
			}
		}*/


    }

    //保存分摊字段值
    function save_shareequally($id, $module)
    {
        global $adb;
        $fieldModules = $this->fieldobj->getModuleFields();
        foreach ($fieldModules as $fieldname => $fieldinfo) {
            $uitype = $fieldinfo->getUIType();
            if ($uitype == 125) {
                $query = 'delete from ld_shareequally_value where fieldname = ? and module = ? and recordid = ?';
                $adb->pquery($query, array($fieldname, $module, $id));
                if (!empty($_REQUEST[$fieldname . '_shareequally_value_count'])) {
                    $shareequally_type = $_REQUEST[$fieldname . '_shareequally_type'];
                    $shareequally_value_count = $_REQUEST[$fieldname . '_shareequally_value_count'];
                    if ($shareequally_value_count >= 1) {
                        for ($i = 1; $i <= $shareequally_value_count; $i++) {
                            $shareequally_value = $_REQUEST[$fieldname . '_shareequally_value_' . $i];
                            $percent = 0;
                            if (!empty($shareequally_value)) {
                                $values = explode(',', $shareequally_value);
                                $query = 'insert into ld_shareequally_value(recordid,fieldname,module,entitytype,entitytypeid,percent,sequence) values (?,?,?,?,?,?,?)';
                                if ($shareequally_type == 2) {
                                    $percent = $values[2];
                                }
                                $adb->pquery($query, array($id, $fieldname, $module, $values[0], $values[1], $percent, $i));
                            }
                        }
                    }
                }
            }
        }
    }

    /*
	*edit: chj
	*date: 2020/10/12
	*reason: 单据保存时，存储销售阶段值
	*/
    function save_advancestage($record, $module)
    {
        //edit: xll 2023/08/04 BUG0070577 关联创建收款计划时需要循环，避免重复生成对象
        if (!isset($this->cls_module_advance) || empty($this->cls_module_advance)) {
            crm_load_class_file('cls_module_advance', 'modules/Settings');
            $cls_module_advance = new cls_module_advance($module);
            $this->cls_module_advance = $cls_module_advance;
        }
        $this->cls_module_advance->createModuleAdvanceStage($record);
    }

    function setRefreshListModules($refreshlistmodules)
    {
        $this->refreshlistmodules = $refreshlistmodules;
    }

    function setRefreshDetailModules($refreshdetailmodules)
    {

        $this->refreshdetailmodules = $refreshdetailmodules;
    }

    public $before_sumdetailvalues;

    function getBefore_SumDetailValues()
    {
        //40683: （http://www.51mis.com/demo/panlulu15/演示账套 [^]）客户管理->客户查看详情界面，相关信息->出库单界面，编辑单据保存后，该界面列值行错位
        return array();
        if ($this->mode != 'edit') {
            return array();
        }
        global $adb, $current_user;
        if (get_file_address($this->module_name, $this->module_name . 'DetailFieldsHtml')) {
            //  crm_load_class_file("setTabDetailFields")
            $ProductToolFields = TabDetailFields::getInstance($this->module_name);
            $ProductToolFieldsInfo = $ProductToolFields->setTabDetailFields();

        } else {
            crm_load_class_file('ProductToolFields', 'include/ProductDetails');
            $ProductToolFields = ProductToolFields::getInstance($this->module_name);
            $tabid = getTabid($this->module_name);
            $languageType = getLanguageType($current_user);
            $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid, $languageType);

        }
        $detailtable = $this->Detail_table;
        $detailtablescf = $this->Detail_table_scf;
        $Detail_table_index = $this->Detail_table_index;
        $Detail_table_id = $this->Detail_table_id;//明细表主表和自定义表关联字段
        $columns = array();
        $sumcols = array();
        foreach ($ProductToolFieldsInfo as $tmpindex => $productfieldinfo) {

            $tablename = $productfieldinfo->getTableName();
            if ($tablename == $detailtable || $tablename == $detailtablescf) {
                if ($productfieldinfo->istotalFldMoneyField() || $productfieldinfo->istotalFldNumField()) {
                    $fieldnames[] = $productfieldinfo->getFieldName();
                    $sumcols[] = "sum(ifnull( " . $productfieldinfo->getTableName() . '.' . $productfieldinfo->getColumnName() . ",0)) as " . $productfieldinfo->getFieldName();

                }
            }

        }

        $sql = 'select ' . implode(',', $sumcols) . " from $detailtable left join $detailtablescf 
             on $detailtable.$Detail_table_id=$detailtablescf.$Detail_table_id
             where $detailtable.$Detail_table_index=?";
        $result = $adb->pquery($sql, array($this->id));


        $arr = array();
        foreach ($fieldnames as $fieldname) {
            $arr[$fieldname] = $adb->query_result($result, 0, $fieldname);
        }
        $this->before_sumdetailvalues = $arr;
        return $arr;


    }

    /**
     * $before_columnfieldvalue:保存前的值
     * */
    function ReturnAfterSave($before_columnfieldvalue)
    {
        global $current_user;
        $_REQUEST['diony'] = 'yes';
        $record = $_REQUEST['record'];
        $module = $this->module_name;
        $column_fields = $this->column_fields;

        $arr['fieldhrefname'] = $this->list_link_field;
        $arr['modulebillnotip'] = $_SESSION[$module . '_modulebillnotip'];
        $arr['fieldvalue'] = $this->column_fields;
        $arr['fieldvalue']['maintable_id'] = $this->id;
        crm_load_function_file('getDataInfoAfterSave', 'include/utils', 'DetailViewUtils');
        $column_fields['record_id'] = $this->id;
        // getDataInfoAfterSave($currentModule,'',$focus->column_fields,getTabid($currentModule));
        $datainfo = array();
        if (!in_array($module, $this->refreshlistmodules) || !in_array($module, $this->refreshdetailmodules)) {
            //40710: （51mis.com/kfbtest）客户查看详情界面，编辑数据保存后，该界面没有立即刷新
            $datainfo = getDataInfoAfterSave($module, '', $column_fields, getTabid($module), 'listpage');
        }

        if ($this->fieldobj->getFieldInfoBykeyValue('bigtype', 'fileattachment', 'fieldname') != '') {


            $smarty = new lingdangCRM_Smarty();
            $smarty->assign("MODULE", $module);
            $smarty->assign("ID", $record);

            foreach ($datainfo as $tmpfieldname => $tmpvalueinfo) {

                $fileinfos = $valueinfo['value'][$record];

                $tmpfieldinfo = $this->fieldobj->getFieldInfoobjBykey("fieldname", $tmpfieldname);
                //zkt 20230620 BUG0068569  合同订单在编辑或新增的时候直接点击保存并提交审批后悔直接卡死，一直在转圈
                if (empty($tmpfieldinfo)) {
                    continue;
                }

                if ($tmpfieldinfo->getUIType() == '1109' || $tmpfieldinfo->getUIType() == 1108) {
                    $smarty->assign("keyid", $tmpfieldinfo->getUIType());
                    // dump($tmpvalueinfo);
                    if ($tmpfieldinfo->getUIType() == 1108) {
                        $smarty->assign("keyval", $tmpvalueinfo['value']);
                    } else {
                        $smarty->assign("keyval", $tmpvalueinfo['value']);
                    }
                    $strcontent = $smarty->fetch("DetailView/AttachmentField.tpl");


                    //明细界面附件字段
                    $valueinfo['DetailView_Attachmenthtml'] = ($strcontent);// $smarty->fetch("DetailView/AttachmentField.tpl");

                    $showvalue = array();
                    $showvalue['rawvalue'] = $record;
                    foreach ($fileinfos as $fileid => $fileinfo) {
                        $fileinfo['attachmentsid'] = $fileid;
                        $fileinfo['filepath'] = $fileinfo['path'];
                        $fileinfo['filename'] = $fileinfo['name'];
                        $showvalue['value'][] = $fileinfo;
                    }
                    $showvalue['parentmodule'] = '';

                    //列表附件字段html
                    $valueinfo['list_html'] = getAttachmentListViewHtml($showvalue, $module, $record);
                    $datainfo[$tmpfieldname] = $valueinfo;

                } else if ($tmpfieldinfo->getUIType() == '69') {
                    //图片
                    crm_load_class_file('DetailView_69', 'include/fields/DetailView');
                    DetailView_69::get_uitype_69($this, $tmpfieldinfo, $this->column_fields);

                    $imageinfos = DetailView_69::$imageinfos[$module][$tmpfieldname];
                    $showvalue = array();
                    $showvalue['rawvalue'] = $record;

                    foreach ($imageinfos as $tmpimginfo) {
                        $showvalue['value'][] = $httppath;//.$tmpimginfo['newfile_name'];
                    }
                    $valueinfo['list_html'] = getImageListViewHtml($showvalue, $module, $record);
                    $valueinfo['value'] = DetailView_69::$imagelist[$module][$tmpfieldname];
                    $datainfo[$tmpfieldname] = $valueinfo;

                }
            }
        }

        $arr['datainfo'] = $datainfo;
        $columnvalues = array();
        foreach ($datainfo as $tmpfieldname => $tmpvalueinfo) {
            //布局规则
            $columnvalues[$tmpvalueinfo["colname"]] = $tmpvalueinfo['value_name'];
        }

        if ($this->mode == 'edit') {
            if (get_file_address($module, "ProductDetails") && $module != 'ServiceCharge') {
                if (!in_array($module, $this->refreshlistmodules)) {

                }
                if (!in_array($module, $this->refreshdetailmodules)) {
                    //主表字段布局规则
                    crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
                    //edit:can 20200721 明细字段的布局规则（在此处获取隐藏和显示字段/必填字段）
                    crm_load_class_file('cls_detailfieldrule', 'include/fields/fieldrule');

                    $detailfieldruleobj = cls_detailfieldrule::getInstance($module);

                    $detailfieldruleobj->setColumnValues($columnvalues);
                    $fieldrulecolsproperty = $detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

                    //主表字段布局规则
                    $fieldruleobj = cls_fieldrule::getInstance($module);

                    $fieldruleobj->setColumnValues($columnvalues);
                    $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

                    $tmpmode = $this->mode;
                    $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml', "modules/$module/ProductDetails", array($module));
                    $this->mode = '';
                    $arr['DetailViewListHtml'] = $ProductDetailsHtml->getProductDetailsHtml($this, 'details');
                    $this->mode = $tmpmode;
                }
            } else if (get_file_address($module, $module . 'DetailFieldsHtml')) {
                if (!in_array($module, $this->refreshlistmodules)) {

                }
                if (!in_array($module, $this->refreshdetailmodules)) {
                    //主表字段布局规则
                    crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
                    //edit:can 20200721 明细字段的布局规则（在此处获取隐藏和显示字段/必填字段）
                    crm_load_class_file('cls_detailfieldrule', 'include/fields/fieldrule');

                    $detailfieldruleobj = cls_detailfieldrule::getInstance($module);

                    $detailfieldruleobj->setColumnValues($columnvalues);
                    $fieldrulecolsproperty = $detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

                    //主表字段布局规则
                    $fieldruleobj = cls_fieldrule::getInstance($module);

                    $fieldruleobj->setColumnValues($columnvalues);
                    $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
                    if ($module == 'CashBill') {
                        crm_load_class_file('cls_CashBill_EntityHtml', 'modules/CashBill/EntityData');
                        $isSourceModule = $_REQUEST['selectsource'];//$this->getSourceField('entitytype',$this->id);
                        $obj_entity = new cls_CashBill_EntityHtml($_REQUEST['record'], '', $isSourceModule, 'detail');

                        $arr['DetailViewListHtml'] = $obj_entity->createHtml();
                    } else if ($module == 'SendCashBill') {
                        crm_load_class_file('cls_SendCashBill_EntityHtml', 'modules/SendCashBill/EntityData');
                        $isSourceModule = $_REQUEST['selectsourcename'];//$this->getSourceField('entitytype',$this->id);
                        $obj_entity = new cls_SendCashBill_EntityHtml($_REQUEST['record'], '', $isSourceModule, 'detail');

                        $arr['DetailViewListHtml'] = $obj_entity->createHtml();//付款信息明细html
                    } else {
                        $classname = $module . 'DetailFieldsHtml';
                        crm_load_class_file("$classname", "modules/$module");
                        $mode = $this->mode;
                        $this->mode = 'Details';//佣金单
                        $detailhtmlobj = new $classname($this, $module);

                        $arr['DetailViewListHtml'] = $detailhtmlobj->getTabDetailFieldsHtml();
                        $this->mode = $mode;
                    }
                }
            }
            $beforedatainfo = array();

            if (!in_array($module, $this->refreshlistmodules) && !in_array($module, $this->refreshdetailmodules) && $focus->mode != 'edit')
                $beforedatainfo = getDataInfoAfterSave($module, '', $before_columnfieldvalue, getTabid($module), 'listpage');

            // wym 240529 BUG20240506-48 成员管理人员名称修改了之后，右上角个人信息显示名称不能自动变更
            if ($module == 'Users' && $this->id == $current_user->id) {
                $arr['aftersave_username'] = $this->column_fields['last_name'];
            }
        } else
            $beforedatainfo = array();
        $arr['beforedatainfo'] = $beforedatainfo;
        $arr['refreshdetailmodules'] = array();
        $arr['refreshlistmodules'] = array();
        $refreshdetailmodules = array();
        $refreshlistmodules = array();


        if ($this->mode != 'edit') {
            if (!is_array($this->refreshlistmodules)) {
                $this->refreshlistmodules = array();
            }
            $this->refreshlistmodules[] = $module;
            $arr['sysdeploy'] = $this->getSysDeployAftersave();

        } //zkt 20221101 BUG0058180 该参数设置后不生效，麻烦检查下，应该是通用问题，着急答复客户
        else if ($this->mode == 'edit') {
            //合同订单编辑，判断系统参数
            if ($this->module_name == 'SalesOrder') {
                $deployarray = getSys_deploy(57);//设置合同订单新增或编辑后是否立即打印
                $deployvalue = $deployarray['deploy_value'];
                if ($deployvalue == 0 && isPermitted($this->module_name, "Print", '') == 'yes') {
                    $arr['sysdeploy'] = array($this->module_name => array('deploytype' => 57, 'deployvalue' => $deployvalue, 'record' => $this->id));
                }
            }
        }
        if (is_array($this->refreshdetailmodules)) {
            $arr['refreshdetailmodules'] = $this->refreshdetailmodules;
        }
        if (is_array($this->refreshlistmodules)) {
            $this->refreshlistmodules = array_unique($this->refreshlistmodules);
            $arr['refreshlistmodules'] = $this->refreshlistmodules;
        }


        //检查是否有API调用
        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($module);
        $receive_msg = $workflowreverseobj->checkCallApiPop();
        $arr['workflow']['receive_msg'] = $receive_msg;
        if ($receive_msg == 'yes') {
            $arr['workflow']['record'] = $this->id;
            $arr['workflow']['module'] = $module;
            $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
//            $arr['workflow']['api_action_title'] = implode('、',$workflowreverseobj->api_action_title_arr);

            $arr['workflow']['before_save_infos'] = $this->before_save_infos[0];
            $arr['workflow']['after_save_infos'] = $this->after_save_infos[0];
        }
        //duan 20240827 BUG20240605-16 如果通过推进进入编辑保存，则需要额外触发推进的工作流程
        if ($_REQUEST['miniedit_fieldrule'] == 'fromadvance' ) {
            $pagemode = 'Advanced';
            $workflowreverseobj->setPageMode($pagemode);
            $receive_msg = $workflowreverseobj->checkCallApiPop();
            if ($receive_msg == 'yes')
                $workflowreverseobj->setNotCallActionType(array('API', 'Link2ERP'));//无需处理的API类型
            $workflowreverseobj->getStartComputer($this->before_save_infos[0], $this->after_save_infos[0], $pagemode);

            if ($receive_msg == 'yes'){
                //如果已有保存的工作流,则添加页面参数
                if(!empty($arr['workflow']['pagemode'])){
                    $arr['workflow']['pagemode_extra'] = $arr['workflow']['pagemode'].",".$pagemode;
                }else{
                    $arr['workflow']['record'] = $this->id;
                    $arr['workflow']['module'] = $module;
                    $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

                    $arr['workflow']['before_save_infos'] = $this->before_save_infos[0];
                    $arr['workflow']['after_save_infos'] = $this->after_save_infos[0];
                }
            }
        }


        $_SESSION[$module . '_modulebillnotip'] = 'no';
        ConvertTojsonString(1, $arr, "success");
    }

    function getSysDeployAftersave()
    {
        if ($this->module_name == 'Potentials') {
            $deployarray = getSys_deploy(54);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 0) {
                $deploytype = $this->Createreceivablesforecast($this->id);
                return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));
            } else {
                return array();
            }
        } else if ($this->module_name == 'SalesOrder') {
            $deployarray = getSys_deploy(12);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 1) {
                $deployarray = getSys_deploy(57);
                $deployvalue = $deployarray['deploy_value'];
                if ($deployvalue == 0 && isPermitted($this->module_name, "Print", '') == 'yes') {
                    return array($this->module_name => array('deploytype' => 57, 'deployvalue' => $deployvalue, 'record' => $this->id));
                }
                return array();
            } else {
                if (isPermitted("PaymentPlan", "EditView", '') == 'yes' && vtlib_isModuleActive('PaymentPlan')) {
                    return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));

                } else {
                    return array();
                }

            }

        } else if ($this->module_name == 'ServiceContracts') {
            $deployarray = getSys_deploy(58);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 1) {
                return array();
            } else {
                if (isPermitted("PaymentPlan", "EditView", '') == 'yes' && vtlib_isModuleActive('PaymentPlan')) {
                    return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));

                } else {
                    return array();
                }

            }

        } else if ($this->module_name == 'Invoice') {
            /*
					*edit: chj
					*date: 2020/7/27
					*reason: 42133: （61mis.com/kfbcrm）系统设置>系统参数设置：参数中‘销售发票保存自动创建回款计划’选了‘是’，保存销售发票的时候不会自动弹出“回款计划”创建界面。
					*/
            $deployarray = getSys_deploy(146);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 0) {
                return array();
            } else {
                if (isPermitted("PaymentPlan", "EditView", '') == 'yes' && vtlib_isModuleActive('PaymentPlan')) {
                    return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));

                } else {
                    return array();
                }

            }

        } else if ($this->module_name == 'PurchaseOrder') {
            $deployarray = getSys_deploy(15);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 1) {
                return array();
            } else {
                if (isPermitted("SendPayment", "EditView", '') == 'yes' && vtlib_isModuleActive('SendPayment')) {
                    return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));

                } else {
                    return array();
                }

            }
        } else if ($this->module_name == 'PurchaseInvoice') {
            //042885: （https://61mis.com/kfbcrm/ [^]）（邬丹华客户问题）参数里设置了保存采购发票后自动创建付款计划，但实际操作中保存单据后没有弹出付款计划的页面（需要补丁）
            $deployarray = getSys_deploy(148);
            $deployvalue = $deployarray['deploy_value'];
            if ($deployvalue == 0) {
                return array();
            } else {
                if (isPermitted("SendPayment", "EditView", '') == 'yes' && vtlib_isModuleActive('SendPayment')) {
                    return array($this->module_name => array('deploytype' => $deploytype, 'deployvalue' => $deployvalue));

                } else {
                    return array();
                }

            }
        }
    }

    /**
     *      This function is used to upload the attachment in the server and save that attachment information in db.
     * @param int $id - entity id to which the file to be uploaded
     * @param string $module - the current module name
     * @param array $file_details - array which contains the file information(name, type, size, tmp_name and error)
     *                            return void
     */
    function uploadAndSaveFile($id, $module, $file_details)
    {
        crm_load_class_file('CRMEntity_Save', 'data');
        return CRMEntity_Save::uploadAndSaveFile($id, $module, $file_details, $this);
    }
    //gyq161208 reason：删除base64图片保存方法

    /** Function to insert values in the ld_crmentity for the specified module
     * @param $module -- module:: Type varchar
     */
    function insertIntoCrmEntity($module, $fileid = '')
    {
        global $adb;
        //global $current_user;
        //
        /**
         * save保存时，编辑时不操作crmentity表
         * 新增时，只需要插入crmid、setype两个字段
         * @project PROT12 crmentity 表结构优化
         * @author  Tujt 2014-06-24
         */


        if ($this->mode == 'edit') return;
        $tmp_cnt = 0;
        $run_cnt = 0;
        $max_cnt = 10;//限制最大执行次数,避免代码错误导致死循环
        do {
            //36793: PC端：一边导入一边新增保存，crmentity的id会有重复
            $tmpcurid = $adb->getUniqueID('ld_crmentity');
            $tmpcurid = intval($tmpcurid);
            $sql = 'select max(crmid) from ld_crmentity ';
            $result = $adb->pquery($sql, array());

            if ($adb->num_rows($result) > 0) {
                $current_id = intval($adb->query_result($result, 0, 0)) + 1;
            } else
                $current_id = 1;
            $current_id = max($tmpcurid, $current_id);
            if ($current_id > $tmpcurid) {
                $update = 'update ld_crmentity_seq set id=?';
                $adb->pquery($update, array($current_id));
            }

            $_REQUEST['currentid'] = $current_id;

            $sql = 'insert into ld_crmentity (crmid,setype) values(?,?);';
            $params = array($current_id, $module);
            $adb->pquery($sql, $params);
            //duan 20230815 错误检测，判断如果id未插入成功，则重新执行插入语句
            $cnt_sql = 'select 1 from ld_crmentity where crmid = ? and setype = ?';
            $cnt_result = $adb->pquery($cnt_sql, [$current_id, $module]);
            $tmp_cnt = $adb->num_rows($cnt_result);
            //限制最大执行次数,避免代码错误导致死循环
            $run_cnt++;
            if ($run_cnt > $max_cnt) {
                break;
            }
        } while ($tmp_cnt == 0);

        $this->id = $current_id;


    }


    /** Function to insert values in the specifed table for the specified module
     * @param $table_name -- table name:: Type varchar
     * @param $module -- module:: Type varchar
     */
    function insertIntoEntityTable($table_name, $module, $fileid = '')
    {

        crm_load_class_file('CRMEntity_Save', 'data');
        return CRMEntity_Save::insertIntoEntityTable($table_name, $module, $fileid, $this);
    }


    public function changeModuleNumber($module, $record)
    {
        crm_load_class_file('CRMEntity_Save', 'data');
        return CRMEntity_Save::changeModuleNumber($module, $record, $this);
    }

    /**
     * edit:can
     * reason:记录下拉框数据历史变迁(例如销售机会的销售阶段)
     * */
    public function addComboxIntoDataBase($table_name = '')
    {
    }

    /** Function to delete a record in the specifed table
     * @param $table_name -- table name:: Type varchar
     *                    The function will delete a record .The id is obtained from the class variable $this->id and the columnname got from $this->tab_name_index[$table_name]
     */
    function deleteRelation($table_name)
    {
        global $adb;
        $check_query = "select * from $table_name where " . $this->tab_name_index[$table_name] . "=?";
        $check_result = $adb->pquery($check_query, array($this->id));
        $num_rows = $adb->num_rows($check_result);

        if ($num_rows == 1) {
            $del_query = "DELETE from $table_name where " . $this->tab_name_index[$table_name] . "=?";
            $adb->pquery($del_query, array($this->id));
        }
    }


    /** Function to retrive the information of the given recordid ,module
     * @param $record -- Id:: Type Integer
     * @param $module -- module:: Type varchar
     *                This function retrives the information from the database and sets the value in the class columnfields array
     */
    function retrieve_entity_info($record, $module)
    {
        global $adb, $app_strings, $currentModule, $weixin_user;
        static $static_retrieve_entity_info;
        global $reset_retrieve_entity_info;//修改日志需要重新获取数据
        global $uncheck_record_deleted;//不检查单据删除

        if ($reset_retrieve_entity_info != 'yes' && is_array($static_retrieve_entity_info) && $static_retrieve_entity_info[$record]) {
            $this->column_fields = $static_retrieve_entity_info[$record];
            return $static_retrieve_entity_info[$record];
        }
        /*
        if(function_exists(getHomeModule))
            $mobileModules=getHomeModule();//手机开发模块
        $ismobileModule=false;
		if(!empty($mobileModules)){
			foreach($mobileModules as $mobileky=>$mobilevalue)
			{
				if($mobilevalue['module']==$module)
				{
					$ismobileModule=true;
				}
			}
		}
        */
        $result = array();
        foreach ($this->tab_name_index as $table_name => $index) {
            if ($module == 'Reminds' && $table_name == 'ld_reminds') {
                $result[$table_name] = $adb->pquery('select * from ( select * from ' . $table_name . ' where ' . $index . ' =?
                    union all select * from ld_reminds_accepted where  remindsid=? ) as tmp   LIMIT 1 ', array($record, $record));
            } else
                $result[$table_name] = $adb->pquery('select * from ' . $table_name . ' where ' . $index . ' =? LIMIT 1 ', array($record));
            if (!isset($result[$this->table_name])) continue;
            $isRecordDeleted = $adb->query_result($result[$this->table_name], 0, 'deleted');
            if ($uncheck_record_deleted != "yes" && $isRecordDeleted !== 0 && $isRecordDeleted !== '0') {
                /*
                     andrew
                     20140917
                     项目任务关检索客户时候不进入
                     */
                //editor:gyq_20191115 reason:移动端新增界面源单被删除，无法保存，而PC端是可以保存的。故将 if($module==$currentModule){判断提前
                //0038597: 企业微信端销售订单相关创建发货通知单后，填写完毕后点击保存时提示，该单据已删除；
                if ($module == $currentModule) {
                    if ($weixin_user->environment_weixin) {
                        if ($_REQUEST['CheckFromRemind']) return false;
                        //微信端判断单据权限同时判断是否删除
                        if (isset($_REQUEST['CheckPermitted']) && $_REQUEST['CheckPermitted'] == 'yes') {
                            ConvertTojsonString('-2', array(), getFixedLabel('RECORDDELETED'));
                        }
                        ConvertTojsonString('-1', array(), getFixedLabel('RECORDDELETED'));
                    } else {
                        //die("<div id='warningTable' class='warningTable' style='height: 698px;'><div class='warningTableContent' style='margin-top: -150px;z-index:600;'>
//                             <div class='wtc_img'><img src='themes/images/icon-warning.png'></div>
//                             <div class='wtc_title'>". getFixedLabel('RECORDDELETED') ."</div></div></div>");
                        $_REQUEST['diony'] = 'yes';
                        ConvertTojsonString('-1', array(), getFixedLabel('RECORDDELETED'));
                        //die("<br><br><center>" . getFixedLabel('RECORDDELETED') . " <a href='javascript:window.history.back()'></a></center>");
                    }
                }
            }
        }

        if ('Accounts' == $module && isset($result[$this->table_name])) {
            global $static_publicaccount;//获取客户是否为公海 tujt 2014-08-06
            $static_publicaccount = $adb->query_result($result[$this->table_name], 0, 'publicaccount');
        }
        if ('Leads' == $module && isset($result[$this->table_name])) {
            global $static_publicleads;//获取客户是否为公海 tujt 2014-08-06
            $static_publicleads = $adb->query_result($result[$this->table_name], 0, 'publicaccount');
        }
        if (isset($result['ld_crmentity'])) {
            global $static_setype;
            $static_setype = $adb->query_result($result['ld_crmentity'], 0, 'setype');
        }

        /* Prasad: Fix for ticket #4595 */
        if (isset($this->table_name)) {
            $mod_index_col = $this->tab_name_index[$this->table_name];
            if ($adb->query_result($result[$this->table_name], 0, $mod_index_col) == ''){
                return [];

                if (!$ismobileModule){
                    echo $result[$this->table_name]->sql.'<br>';
                    die("<br><br><center>" . getFixedLabel('NORECORDSAREFOUND') .
                        "<a href='javascript:window.history.back()'>" . getFixedLabel('RETURN') . "</a></center>");
                }
                else
                    ConvertTojsonString('-1', array(), getFixedLabel('NORECORDSAREFOUND'));
            }
        }

        // Lookup in cache for information

        $cachedModuleFields = $this->fieldobj->getFieldInfoList();

        if ($cachedModuleFields) {
            foreach ($cachedModuleFields as $fieldname => $fieldinfo) {
                $fieldcolname = $fieldinfo['columnname'];
                $tablename = $fieldinfo['tablename'];
                $fieldname = $fieldinfo['fieldname'];
                $defaultValue = $fieldinfo['defaultvalue'];
                if (isset($result[$tablename])) {
                    $fld_value = $adb->query_result($result[$tablename], 0, strtolower($fieldcolname));
                    //bug:23801 edit:cyb date:2016-08-18 description:页面设置>付款计划>页面设置：设置自定义字段的默认值，从采购订单创建付款计划后，付款计划该字段没有值
                    //复选框字段设置默认值，编辑，保存后的值都是默认值，之前用empty判断，为空则取默认值，由于复选框字段数据库存的是0，所以一直取的都是默认值1，现在改为 ==''
                    if ($fld_value == '' && $fieldinfo['uitype'] == '56') {
                        $fld_value = $defaultValue;
                    }
                } else {
                    $adb->println("There is no entry for this entity $record ($module) in the table $tablename");
                    $fld_value = "";
                }
                // @edit:dong @date:2021/03/15 @reason:  api接口更新 特殊字符乱码
                $this->column_fields[$fieldname] = !empty($fld_value)?html_entity_decode($fld_value):$fld_value;
            }
        }

        crm_load_class_file('cls_RelateModuleField', 'include/fields');
        //zxm 2021-0603   0046018 : 复制单据时，引用字段建议重新计算
        $pageMode = 'edit';
        if (isset($_REQUEST['isDuplicate']) && ($_REQUEST['isDuplicate'] == 'true' || $_REQUEST['isDuplicate'] == 'yes')) {
            $pageMode = 'isDuplicate';
        }
        $clsReferencefieldobj = cls_RelateModuleField::getInstance($this->module_name, $record, $pageMode);
        $column_fields = $clsReferencefieldobj->getAllRelatedFieldValue();
        foreach ($column_fields as $fieldname => $value) {
            $this->column_fields[$fieldname] = $value;
        }
        $retrieve_entity_info_modules[$module][$record] = $this;
        $this->column_fields["record_id"] = $record;
        $this->column_fields["record_module"] = $module;
        $static_retrieve_entity_info[$record] = $this->column_fields;
    }

    public function before_save($record)
    {

    }

    public function after_save()
    {
    }

    /** Function to saves the values in all the tables mentioned in the class variable $tab_name for the specified module
     * @param $module -- module:: Type varchar
     */
    function save($module_name, $fileid = '')
    {
        global $current_user, $adb;
        $this->getModuleStatic('ModTracker');

        $this->modstatic->init($this, $module_name);
        //  if($this->id>0)
        $this->before_save($this->id);
        if ($this->id > 0) {

            $fieldinfo = $this->fieldobj->getFieldInfoobjBykey('columnname', $this->getSmownerColumName());
            //提醒的保存要判断$fieldinfo对象
            if ($fieldinfo && $this->column_fields[$fieldinfo->getFieldName()] != $current_user->id) {
                //防止越权保存
                crm_load_class_file('cls_CurUserDataScope', 'include/ListView');
                $datascopeobj = cls_CurUserDataScope::getInstance($module_name, 'list');
                if ($datascopeobj->isMyViewData($this->id) == 'no') {
                    return '';
                }
            }
        }
        //合并时不进行保存判断
        if ($_REQUEST['mergemode'] == 'mergesave') {
            $this->saveentityNoJudge = 'yes';
        }

        $result = $this->saveentity($module_name, $fileid);
        if (is_array($result) && !empty($result) && $result['code'] != 'ok') {
            return $result;
        }
        //保存系统操作日志
        crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
        $logcontent = $_REQUEST;
        if ($this->logaction != '') {
            $logcontent['logaction'] = $this->logaction;
        }
        if ($this->actiontype != '') {
            $actiontype = $this->actiontype;
        } else if ($this->mode != '') {
            $actiontype = $this->mode;
        }
        $this->logId = cls_OperationLogs::saveLogs($module_name, $actiontype, $this->id, $logcontent);
        //工作流程定制同步
        $this->save_workflow($module_name, $this);
        //保存数据完成后执行
        /*
		*edit: chj
		*date: 2020/9/16
		*reason: 42645: 复制单据保存后，发现记录了修改日志
		*/

        if ($_REQUEST['mode'] == 'edit') {
            $this->modstatic->triggerEvent($module_name);
        }
        cls_OperationLogs::SaveOperationLogsRelation($this);
        $this->after_save();
        /*$fieldinfo=$this->fieldobj->getFieldInfoobjBykey('uitype',73);
        $marketplateformurl=@file_get_contents(globalStatic::$root_directory.'user_privileges/marketplateforminfo.txt');
        if($fieldinfo&&$fieldinfo->getFieldName()!=''&&$this->column_fields[$fieldinfo->getFieldName()]>0&&!empty($marketplateformurl))
        {
            //推广平台
            crm_load_class_file('cls_get_setting','marketplateform/GetClass');
             $objgetsetting=new cls_get_setting();
             $settinginfos=$objgetsetting->getSettings();

             if(sizeof($objgetsetting)>0&&strpos($settinginfos['bussinessdeal_condition'],$this->module_name)!==false&&strpos($settinginfos['bussinessdeal_condition'],"Approve")===false)
             {
                    crm_load_function_file('convertWritebussiness','crmmarket','crmdata');
                    convertWritebussiness($this->module_name,$this->id,$this->column_fields[$fieldinfo->getFieldName()]);
             }
        }*/
        return ['code'=>"ok",[],'success'];
    }

    function process_list_query($query, $row_offset, $limit = -1, $max_per_page = -1)
    {
        global $list_max_entries_per_page_new;
        $this->log->debug("process_list_query: " . $query);
        if (!empty($limit) && $limit != -1) {
            $result = &$this->db->limitQuery($query, $row_offset + 0, $limit, true, "Error retrieving $this->object_name list: ");
        } else {
            $result = &$this->db->query($query, true, "Error retrieving $this->object_name list: ");
        }

        $list = array();
        if ($max_per_page == -1) {
            $max_per_page = $list_max_entries_per_page_new;
        }
        $rows_found = $this->db->getRowCount($result);

        $this->log->debug("Found $rows_found " . $this->object_name . "s");

        $previous_offset = $row_offset - $max_per_page;
        $next_offset = $row_offset + $max_per_page;

        if ($rows_found != 0) {

            // We have some data.

            for ($index = $row_offset, $row = $this->db->fetchByAssoc($result, $index); $row && ($index < $row_offset + $max_per_page || $max_per_page == -99); $index++, $row = $this->db->fetchByAssoc($result, $index)) {


                foreach ($this->list_fields as $entry) {

                    foreach ($entry as $key => $field) { // this will be cycled only once
                        if (isset($row[$field])) {
                            $this->column_fields[$this->list_fields_names[$key]] = $row[$field];


                            $this->log->debug("$this->object_name({$row['id']}): " . $field . " = " . $this->$field);
                        } else {
                            $this->column_fields[$this->list_fields_names[$key]] = "";
                        }
                    }
                }

                $list[] = clone($this); //added by Richie to support PHP5
            }
        }

        $response = array();
        $response['list'] = $list;
        $response['row_count'] = $rows_found;
        $response['next_offset'] = $next_offset;
        $response['previous_offset'] = $previous_offset;

        return $response;
    }


    /** This function should be overridden in each module.  It marks an item as deleted.
     * If it is not overridden, then marking this type of item is not allowed
     * Portions created by lingdangProductCRM are Copyright (C) lingdangProductCRM, Inc..
     * All Rights Reserved..
     * Contributor(s): ______________________________________..
     */
    function mark_deleted($id)
    {
        global $current_user;
        $date_var = date('Y-m-d H:i:s', time());

        $query = 'update ' . $this->table_name . ' set deleted=1,modifiedtime=?,modifiedby=? where ' . $this->table_index . ' = ?;';
        $this->db->pquery($query, array($this->db->formatDate($date_var, true), $current_user->id, $id));
    }


    // this method is called during an import before inserting a bean
    // define an associative array called $special_fields
    // the keys are user defined, and don't directly map to the bean's lingdang_fields
    // the value is the method name within that bean that will do extra
    // processing for that ld_field. example: 'full_name'=>'get_names_from_full_name'

    function process_special_fields()
    {
        foreach ($this->special_functions as $func_name) {
            if (method_exists($this, $func_name)) {
                $this->$func_name();
            }
        }
    }


    /**
     * Track the viewing of a detail record.  This leverages get_summary_text() which is object specific
     * params $user_id - The user that is viewing the record.
     * Portions created by lingdangProductCRM are Copyright (C) lingdangProductCRM, Inc..
     * All Rights Reserved..
     * Contributor(s): ______________________________________..
     */
    function track_view($user_id, $current_module, $id = '')
    {

        $tracker = new Tracker();
        $tracker->track_view($user_id, $current_module, $id, '');
    }

    /**
     * Function to get the column value of a field when the field value is empty ''
     * @param $columnname -- Column name for the field
     * @param $fldvalue -- Input value for the field taken from the User
     * @param $fieldname -- Name of the Field
     * @param $uitype -- UI type of the field
     * @return Column value of the field.
     */
    function get_column_value($columnname, $fldvalue, $fieldname, $uitype, $datatype = '')
    {


        // Added for the fields of uitype '57' which has datatype mismatch in crmentity table and particular entity table
        if ($uitype == 57 && $fldvalue == '') {
            return 0;
        }
        if (is_uitype($uitype, "_date_") && $fldvalue == '') {
            return null;
        }
        if ($datatype == 'I' || $datatype == 'N' || $datatype == 'NN') {
            if ($fldvalue === '') {
                //duan 20230315 BUG0062975：路总要求，货币字段保存空时，赋null值，保证数据库里为空
                return null;
            } else {
                return 0;
            }
        }

        return $fldvalue;
    }


    /**
     * Function invoked during export of module record value.
     */
    function transform_export_value($key, $value)
    {
        // NOTE: The sub-class can override this function as required.
        return $value;
    }

    /**
     *edit:can
     *date:20130523
     *reason: 处理删除数据后和该数据管理的相关业务
     * $id:删除数据的ID
     **/
    function Delete_Module($id)
    {

    }

    /** Function to delete an entity with given Id */
    function trash($module, $id)
    {
        crm_load_class_file('CRMEntity_Del_Restore', 'data');
        return CRMEntity_Del_Restore::trash($module, $id, $this);

    }

    function deleteRelatedDatas($module, $id)
    {
        //27427: 单据删除的时候，删除审批日志
        global $adb;
        //$sql='delete from ld_approvelog  where crmid=?';
        //$adb->pquery($sql,array($id));

    }

    /** Function to unlink all the dependent entities of the given Entity by Id */
    function unlinkDependencies($module, $id)
    {
        crm_load_class_file('CRMEntity_Del_Restore', 'data');
        return CRMEntity_Del_Restore::unlinkDependencies($module, $id, $this);
    }

    /** Function to unlink an entity with given Id from another entity */
    function unlinkRelationship($id, $return_module, $return_id)
    {
        crm_load_class_file('CRMEntity_Del_Restore', 'data');
        return CRMEntity_Del_Restore::unlinkRelationship($id, $return_module, $return_id, $this);
    }

    /** Function to restore a deleted record of specified module with given crmid
     * @param $module -- module name:: Type varchar
     * @param $entity_ids -- list of crmids :: Array
     */
    function restore($module, $id)
    {
        crm_load_class_file('CRMEntity_Del_Restore', 'data');
        return CRMEntity_Del_Restore::restore($module, $id, $this);


    }

    /** Function to restore all the related records of a given record by id */
    function restoreRelatedRecords($module, $record)
    {

        crm_load_class_file('CRMEntity_Del_Resotre', 'data');
        return CRMEntity_Del_Restore::restoreRelatedRecords($module, $record, $this);
    }


    function markAsViewed($userid)
    {
//        global $adb;
//        $adb->pquery("UPDATE ld_crmentity set viewedtime=? WHERE crmid=? AND smownerid=?", array(date('Y-m-d H:i:s', time()), $this->id, $userid));
    }

    /**
     * Save the related module record information. Triggered from CRMEntity->saveentity method or updateRelations.php
     * @param String This module name
     * @param Integer This module record number
     * @param String Related module name
     * @param mixed Integer or Array of related module record number
     */
    function save_related_module($module, $crmid, $with_module, $with_crmid)
    {
        global $adb;
        if (!is_array($with_crmid))
            $with_crmid = array($with_crmid);
        foreach ($with_crmid as $relcrmid) {
            if ($with_module == 'Products')
                $adb->pquery("insert into ld_seproductsrel values(?,?,?)", array($crmid, $relcrmid, $module));
            else if ($with_module == 'Documents') {
                $checkpresence = $adb->pquery("SELECT crmid FROM ld_senotesrel WHERE crmid = ? AND notesid = ?", array($crmid, $relcrmid));
                // Relation already exists? No need to add again
                if ($checkpresence && $adb->num_rows($checkpresence))
                    continue;

                $adb->pquery("INSERT INTO ld_senotesrel(crmid, notesid) VALUES(?,?)", array($crmid, $relcrmid));
            } else {
                $checkpresence = $adb->pquery("SELECT crmid FROM ld_crmentityrel WHERE
					crmid = ? AND module = ? AND relcrmid = ? AND relmodule = ?", array($crmid, $module, $relcrmid, $with_module));
                // Relation already exists? No need to add again
                if ($checkpresence && $adb->num_rows($checkpresence))
                    continue;

                $adb->pquery("INSERT INTO ld_crmentityrel(crmid, module, relcrmid, relmodule) VALUES(?,?,?,?)", array($crmid, $module, $relcrmid, $with_module));
            }
        }
    }

    /**
     * Delete the related module record information. Triggered from updateRelations.php
     * @param String This module name
     * @param Integer This module record number
     * @param String Related module name
     * @param mixed Integer or Array of related module record number
     */
    function delete_related_module($module, $crmid, $with_module, $with_crmid)
    {
        global $adb;
        if (!is_array($with_crmid))
            $with_crmid = array($with_crmid);
        foreach ($with_crmid as $relcrmid) {

            if ($with_module == 'Documents') {
                $adb->pquery("DELETE FROM ld_senotesrel WHERE crmid=? AND notesid=?", array($crmid, $relcrmid));
            } else {
                $adb->pquery("DELETE FROM ld_crmentityrel WHERE (crmid=? AND module=? AND relcrmid=? AND relmodule=?) OR (relcrmid=? AND relmodule=? AND crmid=? AND module=?)",
                    array($crmid, $module, $relcrmid, $with_module, $crmid, $module, $relcrmid, $with_module));
            }
        }
    }


    /**
     * 获取签到记录
     * @author Tujt 2015-07-22
     */
    public function get_singin($id, $cur_tab_id, $rel_tab_id, $actions = false)
    {
        global $adb, $current_user;
        global $currentModule;
        global $list_max_entries_per_page_new_more;
        //获取常用报表数据范围//zkt 20230710 BUG0068961  拜访签到，在客户相关信息中看不到其他人数据，拜访签到列表可以
        $Smownerids = getCurSmOwnerSearchScope('Singin');
        foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
            if ($userids == "") {
                $userids .= $userid;
            } else {
                $userids .= "," . $userid;
            }
        }
        $userids .= "," . $current_user->id;
        $where_sql = '  and ld_singin.userid in ( ' . $userids . ' )';
        $module = getSalesEntityType($id);
        $focus = CRMEntity::getInstance($module);
        $tabid = getTabid($module);
        $header = array(getFixedLabel('SIGNTIME'), getFixedLabel('SIGNINACCOUNT'), getFixedLabel('SINGINADDRESS'), getFixedLabel('ERRORDISTANCE'), getFixedLabel('SINGINREMARKS'), getFixedLabel('PREVIEWPICTURE'));
        $sql = "SELECT content,createdtime,userid,address,accounts_lng,accounts_lat,
		distince,longtitude,latitude,id,signid,accountid from ld_singin
							where record = ? and tabid = ? and deleted = 0 $where_sql order by createdtime desc";
        $count_result = $adb->pquery($sql, array($id, $tabid));
        $noofrows = $adb->num_rows($count_result);
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
        $result = $adb->pquery($sql, array($id, $tabid));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            crm_load_class_file('OftenUseReport', 'modules/OftenUseReport');
            for ($i = 0; $i < $num_rows; $i++) {
                $listview_entrie = array();
                $userid = $adb->query_result($result, $i, 'userid');
                $listview_entrie[] = $adb->query_result($result, $i, 'createdtime');
                $listview_entrie[] = getUserFullName($userid);
                $listview_entrie[] = $adb->query_result($result, $i, 'address');
                $sign_address = $adb->query_result($result, $i, 'address');
                $distince = $adb->query_result($result, $i, 'distince');
                $sign_latitude = $adb->query_result($result, $i, 'latitude');//签到纬度
                $sign_longtitude = $adb->query_result($result, $i, 'longtitude');//签到经度
                $signid = $adb->query_result($result, $i, 'id');
                $crmsignid = $adb->query_result($result, $i, 'signid');
                $accounts_lat = $adb->query_result($result, $i, 'accounts_lat');
                $accounts_lng = $adb->query_result($result, $i, 'accounts_lng');
                $accountid = $adb->query_result($result, $i, 'accountid');

                $obj = new OftenUseReport();
                //zkt 20240131 BUG20240129-32 1.客户相关信息-签到无图片显示
                $sign_img = $obj->getnewAttachmentsSignImage($crmsignid);

                $listview_entrie[] = $adb->query_result($result, $i, 'distince');
                $listview_entrie[] = $adb->query_result($result, $i, 'content');


                //签到记录界面增加“查看图片”列
                //@edit:wangcong,2021-12-13,reason:【ID1001187】签到记录表增加【图片】列，将操作列中的【查看图片（n）】显示在【图片】列中
                if (sizeOf($sign_img) > 0) {
                    $valtemplate .= '<a href=\'javascript:void(1)\' onclick="signimg_preview(' . $crmsignid . ')">' . getFixedLabel('PREVIEWPICTURE') . '(' . sizeof($sign_img) . ')' . '</a>';
                    $valtemplate .= '<div style="display:none;" id="signimage_' . $crmsignid . '">';
                    $valtemplate .= '<div class="ui-cont-list relation-list ">';
                    foreach ($sign_img as $imgs) {
                        $valtemplate .= '<span achmentid="' . $imgs['id'] . '">';
                        $valtemplate .= '<img class="" style="height: 67px; width: 106px; cursor: pointer;" src="' . $imgs['img'] . '" alt="">';
                        $valtemplate .= '</span>';
                    }
                    $valtemplate .= '</div></div>';
                } else {
                    $valtemplate .= "-";
                }
                $listview_entrie[] = $valtemplate;
                $listview_entries[] = $listview_entrie;

                $valtemplate = null;
                $listview_entrie[] = null;


            }
        }
        $navigationOutput = array();
        $url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
        $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, $currentModule, 'CommunicationLog', $id);
        //print_r($listview_entries);
        $return_value = array('header' => $header, 'entries' => $listview_entries, 'navigation' => $navigationOutput);
        //dump($return_value);
        //dump($return_value);
        return $return_value;
    }


    function transferRelatedRecords($module, $transferEntityIds, $entityId)
    {
        global $adb;
        foreach ($transferEntityIds as $transferId) {

            // Pick the records related to the entity to be transfered, but do not pick the once which are already related to the current entity.
            $relatedRecords = $adb->pquery("SELECT relcrmid, relmodule FROM ld_crmentityrel WHERE crmid=? AND module=?" .
                " AND relcrmid NOT IN (SELECT relcrmid FROM ld_crmentityrel WHERE crmid=? AND module=?)", array($transferId, $module, $entityId, $module));
            $numOfRecords = $adb->num_rows($relatedRecords);
            for ($i = 0; $i < $numOfRecords; $i++) {
                $relcrmid = $adb->query_result($relatedRecords, $i, 'relcrmid');
                $relmodule = $adb->query_result($relatedRecords, $i, 'relmodule');
                $adb->pquery("UPDATE ld_crmentityrel SET crmid=? WHERE relcrmid=? AND relmodule=? AND crmid=? AND module=?", array($entityId, $relcrmid, $relmodule, $transferId, $module));
            }

            // Pick the records to which the entity to be transfered is related, but do not pick the once to which current entity is already related.
            $parentRecords = $adb->pquery("SELECT crmid, module FROM ld_crmentityrel WHERE relcrmid=? AND relmodule=?" .
                " AND crmid NOT IN (SELECT crmid FROM ld_crmentityrel WHERE relcrmid=? AND relmodule=?)", array($transferId, $module, $entityId, $module));
            $numOfRecords = $adb->num_rows($parentRecords);
            for ($i = 0; $i < $numOfRecords; $i++) {
                $parcrmid = $adb->query_result($parentRecords, $i, 'crmid');
                $parmodule = $adb->query_result($parentRecords, $i, 'module');
                $adb->pquery("UPDATE ld_crmentityrel SET relcrmid=? WHERE crmid=? AND module=? AND relcrmid=? AND relmodule=?", array($entityId, $parcrmid, $parmodule, $transferId, $module));
            }
        }
        crm_load_class_file('cls_module_uitype', 'include/fields');
        $uitypes = cls_module_uitype::getModuleAllUtitype($module);
        $uitypes = implode(',', $uitypes);

        /* $sql='select columnname,tablename from ld_field
        inner join ld_tab on ld_tab.tabid=ld_field.tabid  where uitype in( '.$uitypes.' ) and ld_field.presence in(0,2)  and ld_tab.presence in(0,2)';*/
        $sql = 'select ld_field.tabid,columnname,tablename,ld_tab.presence from ld_field
                    inner join ld_tab on ld_tab.tabid=ld_field.tabid  where uitype in(  ' . $uitypes . ' ) and ld_field.presence in(0,2) ';
        $result = $adb->pquery($sql, array());
        $num_rows = $adb->num_rows($result);

        for ($i = 0; $i < $num_rows; $i++) {
            $tabid = $adb->query_result($result, $i, 'tabid');
            $columnname = $adb->query_result($result, $i, 'columnname');
            $tablename = $adb->query_result($result, $i, 'tablename');
            $presence = $adb->query_result($result, $i, 'presence');
            //0033535: 客户、联系人、服务收费管理序时簿界面：勾选2条单据合并，合并成功后，结果被删除的客户关联的日程管理没有转移到合并后的客户名下
            //日程管理受Events影响需要特殊处理！
            if ($tablename == 'ld_activity') {
                $candersql = 'SELECT presence from ld_tab WHERE name=\'Calendar\'';
                $canderresult = $adb->pquery($candersql, array());
                $presence = $adb->query_result($canderresult, 0, 'presence');
            }
            if ($presence != 0 && $presence != 2) {
                continue;
            }
            //Eidtor:gyq_65 Reason:共享,客户服务收费合并带来的联系人归集首要联系人需要特殊处理 Date:2018/3/29 0029 上午 10:02
            if ($module != 'Contacts' && $tablename == 'ld_contactdetails') {
                foreach ($transferEntityIds as $transferId) {
                    $sql = ' update ' . $tablename . ' set reference=0 where  ' . $columnname . '=' . $transferId;
                    $adb->pquery($sql, array());
                }
            }
            $sql = 'set  @disable_triggers="aa"';
            $adb->pquery($sql, array());
            foreach ($transferEntityIds as $transferId) {
                $sql = ' update ' . $tablename . ' set ' . $columnname . '=' . $entityId . ' where  ' . $columnname . '=' . $transferId;
                //echo $sql.";<br><br>";
                $adb->pquery($sql, array());
            }

            $sql = 'set  @disable_triggers=null';
            $adb->pquery($sql, array());
        }
    }

    /**
     * To keep track of action of field filtering and avoiding doing more than once.
     *
     * @var Array
     */
    public $__inactive_fields_filtered = false;

    /**
     * Filter in-active fields based on type
     *
     * @param String $module
     */
    function filterInactiveFields($module)
    {
        crm_load_class_file('CRMEntity_Special', 'data');
        CRMEntity_Special::filterInactiveFields($module, $this);

    }


    /**
     *
     * @param String $tableName
     * @return String
     */
    public function getJoinClause($tableName)
    {
        if (strripos($tableName, 'rel') === (strlen($tableName) - 3)) {
            return 'LEFT JOIN';
        } else {
            return 'INNER JOIN';
        }
    }

    /**
     *
     * @param String $module - module name for which query needs to be generated.
     * @param Users $user - user for which query needs to be generated.
     * @return String Access control Query for the user.
     */
    function getNonAdminAccessControlQuery($module, $user, $scope = '')
    {
        global $related_header, $adb;
        $focus = CRMEntity::getInstance($module);
        $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = $focus->table_name.$focus->table_index ";
        return $query;
    }

    public function listQueryNonAdminChange($query, $scope = '')
    {
        //make the module base table as left hand side table for the joins,
        //as mysql query optimizer puts crmentity on the left side and considerably slow down
        $query = preg_replace('/\s+/', ' ', $query);
        if (strripos($query, ' WHERE ') !== false) {

            $query = str_ireplace(' where ', ' WHERE ' . $this->table_name . '.' . $this->table_index . ' > 0  AND ', $query);
        }
        return $query;
    }


    function setRelationTables($secmodule)
    {
        $rel_tables = array(
            "Documents" => array("ld_senotesrel" => array("crmid", "notesid"),
                $this->table_name => $this->table_index),
        );
        return $rel_tables[$secmodule];
    }

    /**
     * Function to clear the fields which needs to be saved only once during the Save of the record
     * For eg: Comments of HelpDesk should be saved only once during one save of a Trouble Ticket
     */
    function clearSingletonSaveFields()
    {
        return;
    }

    /**
     * Function to track when a new record is linked to a given record
     */
    function trackLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        global $current_user;
        $adb = PearDatabase::getInstance();
        $currentTime = date('Y-m-d H:i:s', time());

        $adb->pquery('UPDATE ' . $this->table_name . ' SET modifiedtime = ?, modifiedby = ? WHERE ' . $this->table_index . ' = ?', array($currentTime, $current_user->id, $crmid));
    }

    /**
     * Function to get sort order
     * return string  $sorder    - sortorder string either 'ASC' or 'DESC'
     */
    function getSortOrder()
    {
        global $currentModule;
        if (!empty($this->reportSortType)){
            return $this->reportSortType;
        }
        if ($currentModule == 'Approve') {
            $sessionKey = $this->module_name . $currentModule . $this->desc_session_col;
        } else
            $sessionKey = $currentModule . $this->desc_session_col;

        if ($_REQUEST['listoperationtype'] == 'page' && $_SESSION[$sessionKey]) {
            $sorder = $_SESSION[$sessionKey];
        } else if (isset($_REQUEST['sorder'])) {//获取点击的排序类型
            $sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
        } else if (isset($_SESSION[$sessionKey])) {//获取session中的排序
            $sorder = $_SESSION[$sessionKey];
        } else {//默认排序
            $sorder = 'DESC';
        }

        $_SESSION[$sessionKey] = $sorder;
        /* if($_REQUEST['listoperationtype']=='page')
        {
             $_SESSION[$sessionKey]=$sorder;
        }
        else
        {
            unset($_SESSION[$sessionKey]);
        }*/
        return $_SESSION[$sessionKey] = $sorder;
    }

    public function setReportSortType($sortType,$reportColumnName)
    {
        $this->reportSortType = $sortType;
        $this->reportColumnName = $reportColumnName;
    }

    /**
     * 获取排序字段
     * @author Tujt 2015-04-23
     */
    public function getOrderBy()
    {
        global $currentModule, $adb;
        $this->order_by_idx = 0;
        if ($currentModule == 'Approve') {
            $sessionKey = $this->module_name . $currentModule . $this->order_by_session_col;
        } else//edit:can 20230522 客户列表，点击显示列字段的排序箭头，勾选单据点击分配后，选人界面没有显示成员
            $sessionKey = $this->module_name . $this->order_by_session_col;

        $desc = $this->getSortOrder();
        if ($desc==='DEFAULT'){
            $this->order_by_idx = 1;
            return '';
        }elseif (!empty($this->reportColumnName)){
            return $this->reportColumnName;
        }
        else if ($_REQUEST['listoperationtype'] == 'page' && $_SESSION[$sessionKey]) {
            //27068: 客户>列表：点击“最晚服务到期日”列头排序，结果：只有第一页排序了，第二页没有排序。
            $order_by = $_SESSION[$sessionKey];
        } else if (isset($_REQUEST['order_by'])) {//获取当前点击的排序字段值


            $order_by = $this->db->sql_escape_string($_REQUEST['order_by']);
        } else if (isset($_SESSION[$sessionKey])) {//从session中获取排序字段

            $order_by = $_SESSION[$sessionKey];


        } else {

            //获取数据分类默认排序
            $this->order_by_idx = 1;


            return '';
        }
        $_SESSION[$sessionKey] = $order_by;

        $orderbytables = explode('.', $order_by);
        if (sizeof($orderbytables) > 1)
            $this->orderby_tables[$orderbytables[0]] = $orderbytables[0];
        /*if($currentModule == 'Approve'){
			unset($_SESSION[$sessionKey]);
		}*/
        return $order_by;
    }

    /**
     * 符合条件，则清空排序session值
     * @reason 0015003: 71mis.com/crm,关于排序错乱的问题
     * @author Tujt 2015-05-18
     */
    public function setOrderSortInfo()
    {
        global $currentModule;
        //当点击数据分类时，清空上次排序session
        if (isset($_REQUEST['switchview']) && $_REQUEST['switchview'] > 0) {
            if ($currentModule == 'Approve') {
                $sessionKey = $this->module_name . $currentModule . $this->order_by_session_col;
            } else //edit:can 20230522 客户列表，点击显示列字段的排序箭头，勾选单据点击分配后，选人界面没有显示成员
                $sessionKey = $this->module_name . $this->order_by_session_col;

            unset($_SESSION[$sessionKey]);
            if ($currentModule == 'Approve') {
                $sessionKey = $this->module_name . $currentModule . $this->desc_session_col;
            } else
                $sessionKey = $currentModule . $this->desc_session_col;
            unset($_SESSION[$sessionKey]);
        }
    }


    /**
     * Function to track when a record is unlinked to a given record
     */
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        global $current_user;
        $adb = PearDatabase::getInstance();
        $currentTime = date('Y-m-d H:i:s', time());
        $adb->pquery('UPDATE ' . $this->table_name . ' SET modifiedtime = ?, modifiedby = ? WHERE ' . $this->table_index . ' = ?', array($currentTime, $current_user->id, $with_crmid));
    }

    /**
     * edit:Can
     * date:20130818
     * reason:获取模块下打印模板列表
     * */
    function getPrintTemplate($tabid)
    {
        crm_load_class_file('CRMEntity_Special', 'data');
        return CRMEntity_Special::getPrintTemplate($tabid, $focus);
    }

    /**
     * 审批已拒绝执行操作函数
     * edit:andy
     * date:20140701
     * verson:v5.34
     */
    public function failedApproved($record)
    {
        //global $adb;

    }

    /**
     * 审批已批准执行操作函数
     * edit:can
     * date:20140815
     */
    public function successApprove($record)
    {

    }

    /**
     * 审批已驳回执行操作函数
     * edit:can
     * date:20140815
     */
    public function rejectApproved($record)
    {

    }

    /**
     * @reason 反审批结束操作函数
     * @edit   cyb
     * @date   2016-06-23
     **/
    public function cancel_ApproveEnd($record)
    {

    }

    /**
     * edit:can
     * reason:设置非编辑字段默认值
     * other:10353: 新增客户或导入客户时，建议“最新联系日期”字段取当前系统的日期。
     * */
    public function setFieldDefaultValue($id, $module)
    {
        crm_load_class_file('CRMEntity_Save', 'data');
        return CRMEntity_Save::setFieldDefaultValue($id, $module, $this);
    }

    /**
     * 初始化权限类，调用静态类的单例方法创建
     * @author Tujt 2015-03-27
     */
    public static function getProfileClass()
    {
        if (!class_exists('staticProfile')) {
            require globalStatic::$root_directory . 'modules/Users/staticProfile.class.php';
        }
        return staticProfile::getInstance();
    }

    /**
     * 单例初始化Logic类对象
     * @author Tujt 2015-05-28
     */
    public function getModuleLogic($modules)
    {
        if (!class_exists('BaseLogic')) {
            import('data.Logic', 'class');
            import('data.BaseLogic', 'class');
            //require globalStatic::$root_directory.'data/Logic.class.php';
            //require globalStatic::$root_directory.'data/BaseLogic.class.php';
        }
        $this->logic = BaseLogic::getInstance($modules);

        $this->logic->controller = $this;
        return $this->logic;
    }

    /**
     * 单例初始化模块static类对象
     * @author Tujt 2015-05-28
     */
    public function getModuleStatic($module)
    {
        if (!isset(self::$modstaticarr[$module]) || empty(self::$modstaticarr[$module])) {
            $cls = 'static' . $module;
            if (!class_exists($cls)) import('modules.' . $module . '.' . $cls . '', 'class');
            self::$modstaticarr[$module] = new $cls();
        }
        return $this->modstatic = self::$modstaticarr[$module];
    }

    /**
     * 初始化include类库下的类对象
     * @param String $cls 类的基本信息
     * @param String $lib 类库，默认include
     * @returns Object 类对象
     *                    Library('ListView') -> 初始化include/ListView/ListView.php 类
     *                    Library('fields.fieldInfo') -> 初始化include/fields/fieldInfo.php 类
     *                    Library('fields.Field.Class') -> 初始化include/fields/Field.Class.php 类
     * @author Tujt 2015-06-30
     */
    public function Library($cls, $lib = '')
    {
        if ($lib == '') {
            $lib = 'include';
        }
        if (!isset(self::$libraryobj[$cls]) || empty(self::$libraryobj[$cls])) {
            $clsarr = explode('.', $cls);
            $cot = count($clsarr);
            switch ($cot) {
                case 1:
                    $path = $lib . '.' . $cls . '.' . $cls;
                    if (!class_exists($cls)) import($path);
                    self::$libraryobj[$cls] = new $cls();
                    break;
                case 2:
                    $path = $lib . '.' . $clsarr[0] . '.' . $clsarr[1];
                    if (!class_exists($clsarr[1])) import($path);
                    self::$libraryobj[$cls] = new $clsarr[1]();
                    break;
                case 3:
                    if (strtolower($clsarr[2]) == 'class') {
                        $path = $lib . '.' . $clsarr[0] . '.' . $clsarr[1];
                        if (!class_exists($clsarr[1])) import($path, 'class');
                        self::$libraryobj[$cls] = new $clsarr[1]();
                    }
                    break;
                default:
                    return false;
            }
        }
        return $this->library = self::$libraryobj[$cls];
    }

    /**
     *
     * 自动提醒，
     * 该代码不能删除，不能调用Addreminds,否则客户的自动提醒会调用accounts.php下的addreminds
     *
     * */
    public function automaticReminds($RemindsContent, $datetime, $recieverid, $record)
    {
        global $adb, $current_user;


        $focus_rel = CRMEntity::getInstance('Reminds');
        $focus_rel->column_fields['date_time'] = $datetime;
        $focus_rel->column_fields['related_to'] = $record;
        $focus_rel->column_fields['reltab'] = $this->moduleName;
        //BUG20240123-77 ls 240125 PC端消息列表展示的相关项目，展示的不对 展示成了产品名称(工作汇报没有关联ld_crmentity,导致related_to对象错误,需要给remindstype赋值reportCC,消息提醒列表才能显示正常)
        if ($this->moduleName == 'WorkReportList') {
            $focus_rel->column_fields['remindstype'] = 'reportCC';
        }

        $focus_rel->column_fields['recieverid'] = $recieverid;

        $focus_rel->column_fields['status_rmd'] = '未读';
        $focus_rel->column_fields['content'] = $RemindsContent;
        $focus_rel->mode = "create";
        $focus_rel->save('Reminds');
        return $focus_rel->id;
    }

    public function AddReminds($RemindsContent, $datetime, $recieverid, $record)
    {
        global $adb, $current_user;


        $focus_rel = CRMEntity::getInstance('Reminds');
        $focus_rel->column_fields['date_time'] = $datetime;
        $focus_rel->column_fields['related_to'] = $record;
        $focus_rel->column_fields['reltab'] = $this->moduleName;

        $focus_rel->column_fields['recieverid'] = $recieverid;

        $focus_rel->column_fields['status_rmd'] = '未读';
        $focus_rel->column_fields['content'] = $RemindsContent;
        $focus_rel->mode = "create";
        $focus_rel->save('Reminds');
        return $focus_rel->id;
    }

    /**
     * edit:zrz
     * reason:获取操作日志记录
     * date:2015-8-17
     */
    function getAuditTrialLog($id, $cur_tab_id, $rel_tab_id, $actions = false)
    {
        crm_load_class_file('CRMEntity_Special', 'data');
        return CRMEntity_Special::getAuditTrialLog($id, $cur_tab_id, $rel_tab_id, $focus, $actions);

    }

    /**
     * @reason:根据模块控制approve_demand(审批要求)参数取值；
     * @author:cyb
     * @date  :2016-08-05
     * @pram  :approve_demand 取值 0：无，1： 已批准；
     **/
    public function get_approve_demand_byModule($frommodule)
    {
        global $adb;
        static $static_approve_demand;
        if (empty($frommodule)) {
            //就是这样修改的，完全正确
            return 0;//无审批要求，edit:can,24297: 常见问题查看界面：相关信息-知识管理，选择界面报错
        }
        if (is_array($static_approve_demand) && array_key_exists($frommodule, $static_approve_demand)) {
            if (array_key_exists($this->module_name, $static_approve_demand[$frommodule]))
                return $static_approve_demand[$frommodule][$this->module_name];

        }

        $deployarray = getSys_Approvedeploy($this->module_name);
        if (empty($deployarray)) {
            return 0;
        }
        $deploy_value = $deployarray['deploy_value'];

        //33525: 市场活动模块关闭审批功能，市场活动明细界面，关联创建销售机会时还是判断了未批准单据没有新建权限，当审批功能关闭了时去掉该判断
        if ($deploy_value != 0) {
            return 0;
        }
        $otherfocus = CRMEntity::getInstance($frommodule);
        $table_index = $this->table_index;


        //采购订单主表主键是purchaseorderid,而其他模块关联服务单的columnname='purchaseorder_id'，所以这里处理一下;
        if ($this->module_name == 'PurchaseOrder') {
            $table_index = 'purchaseorder_id';
            $otherfieldobj = $otherfocus->fieldobj->getFieldInfoobjBykey('columnname', $table_index);
        } elseif ($this->module_name == 'Products') {
            $table_index = 'product_id';
            $otherfieldobj = $otherfocus->fieldobj->getFieldInfoobjBykey('columnname', $table_index);
        } elseif ($this->module_name == 'Vendors' && ($frommodule == 'Products' || $frommodule == 'Quotes' || $frommodule == 'ServiceContracts' || $frommodule == 'Stock')) {
            $table_index = 'vendor_id';
            $otherfieldobj = $otherfocus->fieldobj->getFieldInfoobjBykey('columnname', $table_index);
        } else if ($this->module_name == $frommodule) {
            $table_index = 'parentid';//上级合同，上级联系人，上级客户等
        } else {
            //BUG20240117-30 ls 240117 关联选择单据（多选）审批条件不生效
            if ($this->getPopuptype() == 'MultiplePopup') {
                $sql = "select ld_ws_fieldtype.* from ld_ws_multireferencetype  INNER JOIN ld_ws_fieldtype
                on ld_ws_multireferencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
                where type=?";
            } else {
                $sql = "select ld_ws_fieldtype.* from ld_ws_referencetype  INNER JOIN ld_ws_fieldtype

                on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
                where type=?";
            }

            $result = $adb->pquery($sql, array($this->module_name));
            $rows = $adb->num_rows($result);

            for ($i = 0; $i < $rows; $i++) {
                $uitype = $adb->query_result($result, $i, 'uitype');
                $otherfieldobj = $otherfocus->fieldobj->getFieldInfoobjBykey('uitype', $uitype);
                if ($otherfieldobj && $otherfieldobj->getFieldName() != '') {
                    break;
                }
            }
        }

        //echo $table_index;
        //$this->table_index 模块相关联取得是模块主表的主键。
        //$otherfieldobj=$otherfocus->fieldobj->getFieldInfoobjBykey('columnname',$table_index);
        $uitype = "";
        if (!empty($otherfieldobj)) {
            $uitype = $otherfieldobj->getUIType();
        }

        //$uitype=="" 表示是在ld_field表中fieldname字段和columnname字段没值，是某些特定的选择源单类型；
        if ($uitype == 102 || $uitype == 10 || $uitype == 200 || $uitype == 201 || $uitype == 202 || $uitype == '') {
            $otherid = getTabid($frommodule);
            $option_tabid = getTabid($this->module_name);
            $selectSql = 'Select approve_demand  from ld_option_module
            where tabid=?  and  option_tabid=?';
            $selectResult = $adb->pquery($selectSql, array($otherid, $option_tabid));
            //echo $selectResult->sql;
            $num = $adb->num_rows($selectResult);
            if ($num > 0) {
                $approve_demand = $adb->query_result($selectResult, 0, 'approve_demand');
            }
        } else {
            $approve_demand = $otherfieldobj->get_approve_demand();
        }
        $static_approve_demand[$frommodule][$this->module_name] = $approve_demand;

        return $approve_demand;
    }

    //editor:gyq_169待确认  这里要避免被循环调用多次，并且最好做成异步  reason:删除临时文件表记录;删除超过24小时的腾讯云存储桶中的文件   2020/2/26 17:25
    protected function deleteQcloudTempFile($rNewfileName)
    {
        global $adb;
        // require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        //删除临时缓存,但不需删除云端文件
        $sql = 'delete from ld_attachments_tempsave where newfile_name=?';
        $adb->pquery($sql, array($rNewfileName));
        //删除超过24小时的临时表中云端文件
        $sqlTwo = 'select newfile_name,path from ld_attachments_tempsave where create_time<DATE_SUB(NOW(),INTERVAL 1 DAY) limit 5';
        $result = $adb->pquery($sqlTwo, array());
        $num = $adb->num_rows($result);
        if ($num > 0) {
            $fileArr = array();
            for ($i = 0; $i < $num; $i++) {
                $fileArr[$i]['newfile_name'] = $adb->query_result($result, $i, 'newfile_name');
                $fileArr[$i]['path'] = $adb->query_result($result, $i, 'path');
            }
            deleteQcloudFile($fileArr);
        }
    }

    //editor:gyq_169 reason:从腾讯云存储桶中删除表中存储的文件
    protected function deleteQcloudFileFromTable($rDelfileList)
    {
        //require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $cosFileList = array();
        foreach ($rDelfileList as $i => $value) {
            $storage_location = $value['storage_location'];
            $filepath = $value['path'];
            $cloud_path = $value['cloud_path'];
            $newfile_name = $value['newfile_name'];
            if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {

            } else {
                // $newfile_name = iconv('gbk','UTF-8',$newfile_name);
                $newfile_name = iconv('utf-8', 'gbk', $newfile_name);
            }
            if ($storage_location == 'cos') {
                //edit:duan  这里的云端路径是包含文件名的，删除时可能有问题，先不改，出现问题再改
                $cosFileList[] = $cloud_path . $newfile_name;
            } else {
                //35709: 附件上传删除保存后，希望将服务器里附件同步删除
                $tmpfile = $filepath . $newfile_name;
                @unlink(globalStatic::$root_directory . $tmpfile);
            }
        }
        if (!empty($cosFileList)) {
            deleteQcloudFile($cosFileList);
        }
    }

    public function ModuleTaskCheck($module)
    {
        global $adb;
        $tabid = getTabid($module);
        $columnFields = $this->column_fields;
        $record_new = $this->id;
        crm_load_class_file('cls_module_advance', 'modules/Settings');
        crm_load_class_file('cls_module_uitype', 'include/fields');

        $uitypetypemodule_arr = cls_module_uitype::getUitypeModules();
        //因为存在必填字段任务类型的原因，单据保存后直接判断自身是否触发自动推进
        $cls_module_advance_obj = cls_module_advance::getInstance($module);
        $cls_module_advance_obj->autopush = 'yes';//保存完自动推进时不需要增加日志
        $cls_module_advance_obj->TaskCompleteCheck($this->id);
        $cls_module_advance_obj->autopush = 'no';

        $modulefields = $this->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname => $fieldinfo) {
            if ($fieldinfo->getBigType() == 'reference') {
                $uitype = $fieldinfo->getUIType();
                $modulename = $uitypetypemodule_arr[$uitype];

                $related_record = $columnFields[$fieldname];//关联模块id

                if (!empty($related_record) && !empty($modulename)) {
                    $cls_module_advance_obj = cls_module_advance::getInstance($modulename);
                    $cls_module_advance_obj->ModuleTaskCompleteCheck($this->id, $module, $related_record);

                }
            } else if ($fieldinfo->getBigType() == 'selectsource' || $fieldinfo->getUIType() == 112) {
                $uitype = $fieldinfo->getUIType();

                //$modulename=$_REQUEST['selectsourcename'];
//
//                if(empty($modulename)){
//                    if(isset($_REQUEST['entitytype'])&&$_REQUEST['entitytype']!=""){
//                        $modulename = $_REQUEST['entitytype'];
//                    }else{
//                        continue;
//                    }
//                }

                $related_record = trim($columnFields[$fieldname], ',');//关联模块id
                if (!empty($related_record)) {
                    $related_record_arr = explode(",", trim($related_record));
                    //duan 20220916 移动端服务合同关联创建收款计划时，收款计划保存时的源单类型不能从$_REQUEST获取，改为通过record获取
                    if (sizeof($related_record_arr) >= 1) {

                        $modulename = '';
                        foreach ($related_record_arr as $related_record) {
                            if (empty($modulename))
                                $modulename = getSalesEntityType($related_record);
                            if (empty($modulename))
                                continue;
                            $cls_module_advance_obj = cls_module_advance::getInstance($modulename);
                            $cls_module_advance_obj->ModuleTaskCompleteCheck($this->id, $module, $related_record);
                        }
                    }
                }
            }
        }
    }

    //edit:duan date:2021-9-30 单据删除附件之前判断，该附件是否与其他单据相关联
    public function attachment_related_record($record)
    {
        global $adb;
        if (empty($this->moduleName)) {
            $module = $this->module_name;
            if (empty($module)) {
                return array();
            }
        } else {
            $module = $this->moduleName;
        }
        $fieldjsondata = getAllFile_imageInfo($record, $module);
        $attachment_arr = array();
        foreach ($fieldjsondata as $columnname => $pathinfo_arr) {
            foreach ($pathinfo_arr as $key => $pathinfo) {
                $fileid = $pathinfo['fileid'];
                $storage_location = $pathinfo['storage_location'];
                if ($storage_location == 'cos') {
                    $cloud_path = $pathinfo['cloud_path'];
                    $sql = 'select ld_attachments.attachmentsid from ld_attachments 
                            inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                            WHERE  ld_attachments.cloud_path=? and ld_seattachmentsrel.crmid>0 limit 2';
                    $result = $adb->pquery($sql, array($cloud_path));
                    $num_row = $adb->num_rows($result);
                    if ($num_row > 1) {
                        $attachment_arr[] = $fileid;
                    }
                } else {
                    $path = $pathinfo['file_path'];
                    $newfile_name = $pathinfo['newfile_name'];
                    $sql = 'select ld_attachments.attachmentsid from ld_attachments 
                            inner join ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                            WHERE  ld_attachments.path=? and ld_attachments.newfile_name=? and ld_seattachmentsrel.crmid>0 limit 2';
                    $result = $adb->pquery($sql, array($path, $newfile_name));
                    $num_row = $adb->num_rows($result);
                    if ($num_row > 1) {
                        $attachment_arr[] = $fileid;
                    }
                }
            }
        }
        return $attachment_arr;
    }

    //edit:duan date:2021-9-30 删除单据后，删除关联的附件记录和文件
    public function delete_related_attachment($record)
    {
        global $adb;
        if (empty($this->moduleName)) {
            $module = $this->module_name;
            if (empty($module)) {
                return false;
            }
        } else {
            $module = $this->moduleName;
        }

        $sql = "select ld_seattachmentsrel.attachmentsid,path,newfile_name,ld_attachments.storage_location,
            ld_attachments.cloud_path,ld_crmentity.setype from ld_seattachmentsrel
            inner join ld_crmentity on ld_seattachmentsrel.attachmentsid=ld_crmentity.crmid  
            inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
            where ld_seattachmentsrel.crmid=?";

        $related_fileids = $this->attachment_related_record($record);
        $delfileList = array();
        $result = $adb->pquery($sql, array($record));
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $attachments_id = $adb->query_result($result, $i, 'attachmentsid');
            $sql = 'delete from ld_crmentity where crmid=?';
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_seattachmentsrel where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $sql = "delete from ld_attachments  where attachmentsid=?";
            $adb->pquery($sql, array($attachments_id));
            $newfile_name = $adb->query_result($result, $i, 'newfile_name');
            $path = $adb->query_result($result, $i, 'path');
            $storage_location = $adb->query_result($result, $i, 'storage_location');
            $cloud_path = $adb->query_result($result, $i, 'cloud_path');
            $setype = $adb->query_result($result, $i, 'setype');
            //获客文章的图片不能删除  会存在被领取的源文件封面被删除的情况
            if ($module == "Articles" && $setype = 'Articles Image') {
                continue;
            }
            //如果附件还被其他单据引用 不能删除该文件
            $attach_onlyone_sql = 'select attachmentsid from ld_attachments where newfile_name=? and path=? limit 1';
            $attach_onlyone_result = $adb->pquery($attach_onlyone_sql, array($newfile_name, $path));
            $sameattachment_num = $adb->num_rows($attach_onlyone_result);
            if (is_array($imagedelfileid) && in_array($attachments_id, $imagedelfileid) && $sameattachment_num < 1) {
                $delfileList[$i]['storage_location'] = $storage_location;
                $delfileList[$i]['path'] = $path;
                $delfileList[$i]['cloud_path'] = $cloud_path;
                $delfileList[$i]['newfile_name'] = $newfile_name;
            }
        }

        if (sizeof($delfileList) > 0) {

            $this->deleteQcloudFileFromTable($delfileList);
        }
    }

    //获取角色字段权限
    public function getProfileFields($profileid)
    {
        $profileobj = Profile::getInstance();
        $profilefields = $profileobj->getProfileInfos($profileid);
        $profilefields = $profilefields['field'];
        return $profilefields;
    }

    //获取当前模块主表字段
    public function getMainModuleFields()
    {
        $modulefields = $this->fieldobj->getSaveModuleFields($this->mode);
        return $modulefields;
    }

    //wyt 230209 XUQIU1001050 报价单和服务合同增加电子签章功能（张德广）
    //ls 2021-09-16 【ID1001956】增加“电子签章”功能
    public function getElectronicSignatureInfo()
    {
        global $adb;
        $query = "select * from ld_wx_config where name = ?";
        $result = $adb->pquery($query, array('electronic_signature'));
        $data = [];
        if ($adb->num_rows($result) >= 1) {
            $bought_count = $adb->query_result($result, 0, 'para_two');//企业购买总份数
            $used_count = $adb->query_result($result, 0, 'para_three');//企业使用份数

            $para_content = $adb->query_result($result, 0, 'para_content');//企业基本信息
            if (!empty($para_content)) {
                $para_content = Zend_Json::decode($para_content);
                $data = array(
                    "IsActivated" => $adb->query_result($result, 0, 'para_one'),//企业是否认证激活
                    "AppId" => $para_content["AppId"],
                    "ProxyAppId" => $para_content["ProxyAppId"],
                    "ProxyOrganizationOpenId" => $para_content["ProxyOrganizationOpenId"],
                    "ProxyOrganizationName" => $para_content["ProxyOrganizationName"],
                    "ProxyOperatorOpenId" => $para_content["ProxyOperatorOpenId"],
                    "bought_count" => $bought_count,
                    "used_count" => $used_count,
                    "remain_count" => $bought_count - $used_count,//企业剩余份数
                );
            }
        }

        //企业是否被灵当授权电子签
        $isauthorize = false;
//        $isauthorize = true;
        $regop = RegOp::getInstance();
        if (method_exists($regop, 'getElectronicSignature')) {
            if ($regop->getElectronicSignature() == 1) {
                $isauthorize = true;
            }
        }
        $data['isauthorize'] = $isauthorize;

        return $data;
    }

    public function getQysElectronicSignatureInfo()
    {
        //duan 20240909 列表速度优化，电子签设置增加缓存
        $cachekey = 'ld_qys_getEContract';
        $data = Cache($cachekey);
        if (!empty($data)) {
            return $data;
        }

        global $adb;
        //企业是否被灵当授权电子签
        $isauthorize = false;
//        $isauthorize = true;
        $regop = RegOp::getInstance();
        if (method_exists($regop, 'getEContract')) {
            if ($regop->getEContract() == 'qiyuesuo') {
                $isauthorize = true;
            }
        }


        $query = "select * from ld_wx_config where name = ?";
        $result = $adb->pquery($query, array('electronic_signature_qys'));
        $data = [];
        if ($adb->num_rows($result) >= 1) {
            $para_content = $adb->query_result($result, 0, 'para_content');//企业基本信息
            if (empty($para_content)) {
                $isauthorize = false;
            } else {
                $para_content = Zend_Json::decode($para_content);
                $data = array(
                    "service_url" => $para_content["service_url"],
                    "accessToken" => $para_content["accessToken"],
                    "accessSecret" => $para_content["accessSecret"],
                    "secretKey" => $para_content["secretKey"],// 签署回调解密key,有则加密，无则明文。
                    "type" => $para_content["type"],
                );
            }
        } else {
            $isauthorize = false;
        }
        $data['isauthorize'] = $isauthorize;


        //获取激活的模块
        $query = "SELECT t1.tabid,t2.name FROM ld_field t1 LEFT JOIN ld_tab t2 ON t1.tabid = t2.tabid
WHERE t2.presence = 0 AND t1.columnname='flowstatus' AND t1.presence in(0,2);";
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        $arr = array();
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $arr[] = $adb->query_result($result, $i, 'name');
            }
        }
        $data['modulename'] = $arr;
        Cache($cachekey, $data);


        return $data;
    }

    public function getFddElectronicSignatureInfo()
    {
        //duan 20240909 列表速度优化，电子签设置增加缓存
        $cachekey = 'ld_fdd_getEContract';
        $data = Cache($cachekey);
        if (!empty($data)) {
            return $data;
        }
        global $adb;
        //企业是否被灵当授权电子签
        $isauthorize = false;
//        $isauthorize = true;
        $regop = RegOp::getInstance();
        if (method_exists($regop, 'getEContract')) {
            if ($regop->getEContract() == 'fadada') {
                $isauthorize = true;
            }
        }


        $query = "select * from ld_wx_config where name = ?";
        $result = $adb->pquery($query, array('electronic_signature_fdd'));
        $data = [];
        if ($adb->num_rows($result) >= 1) {
            $para_content = $adb->query_result($result, 0, 'para_content');//企业基本信息
            if (empty($para_content)) {
                $isauthorize = false;
            } else {
                $para_content = Zend_Json::decode($para_content);
                $data = array(
                    "service_url" => $para_content["service_url"],
                    "AppId" => $para_content["AppId"],
                    "AppSecret" => $para_content["AppSecret"],
                    "openCorpId" => $para_content["openCorpId"],// 企业在法大大应用下的 openCorpId
                );
            }
        } else {
            $isauthorize = false;
        }
        $data['isauthorize'] = $isauthorize;


        //获取激活的模块
        $query = "SELECT t1.tabid,t2.name FROM ld_field t1 LEFT JOIN ld_tab t2 ON t1.tabid = t2.tabid
WHERE t2.presence = 0 AND t1.columnname='flowstatus' AND t1.presence in(0,2);";
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        $arr = array();
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $arr[] = $adb->query_result($result, $i, 'name');
            }
        }
        $data['modulename'] = $arr;
        Cache($cachekey, $data);


        return $data;
    }

    public function getPiaozoneInfo()
    {
        global $adb;
        //$isauthorize = false;
        $isauthorize = true;
        //刘总说发票云不需要授权了
        /*$regop = RegOp::getInstance();
        if (method_exists($regop, 'getPiaozone')) {
            if ($regop->getInvoiceType() == 'piaozone') {
                $isauthorize = true;
            }
        }*/


        $query = "select * from ld_wx_config where `name` = ? and ifnull(para_content,'') <> ''";
        $result = $adb->pquery($query, array('piaozone_setting'));
        $data = [];
        if ($adb->num_rows($result) >= 1) {
            $para_content = $adb->query_result($result, 0, 'para_content');//企业基本信息
            if (empty($para_content)) {
                $isauthorize = false;
            } else {
                $para_content = Zend_Json::decode(decode_html($para_content));
                if (empty($para_content["service_url"])){
                    $isauthorize = false;
                }
                $data = array(
                    "service_url" => $para_content["service_url"],
                    "appId" => $para_content["appId"],
                    "appSecret" => $para_content["appSecret"],
                    "accountId" => $para_content["accountId"],
                    "user" => $para_content["user"],
//                    "taxno" => $para_content["taxno"],
                    "orgNumber" => $para_content["orgNumber"],
                    "companyInfo" => $para_content["companyInfo"],
                );
            }
        } else {
            $isauthorize = false;
        }
        $data['isauthorize'] = $isauthorize;

        return $data;
    }

    //duan 20240815 单据保存后判断是否需要重算关联客户或线索的保护结束日期
    public function check_recount_protectdate($record)
    {
        //暂时不考虑引用字段,关联单据多选等情况
        $field_arr = ['Accounts' => 'account_id', 'Leads' => 'leads_id'];

        $fieldobj = $this->fieldobj;
        foreach ($field_arr as $tmp_module => $tmp_fieldname) {
            if ($this->moduleName == 'Singin') {
                $tmp_fieldname = 'selectlistval';
            }
            $fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname', $tmp_fieldname);
            //删除单据时column_fields没值，传$record去读数据
            if ($record > 0) {
                $tmp_focus = CRMEntity::getInstance($tmp_module);
                $tmp_focus->updateAccountInfo($this->moduleName, 0, 2, $record);
            } else {
                $related_value = $this->column_fields[$tmp_fieldname];
                if (!empty($fieldinfo) && !empty($related_value)) {
                    //判断字段值是否为空
                    $tmp_focus = CRMEntity::getInstance($tmp_module);
                    $tmp_focus->updateAccountInfo($this->moduleName, $related_value);
                }
            }
        }
    }
    //duan 20240914 获取预置字段值,字段未启用时从数据库读取字段,例如审批状态等
    public function getMainColumnFieldValue($record,$fieldname,$columnname = ''){
        if(empty($columnname))$columnname = $fieldname;

        if($record>0&&!array_key_exists($fieldname,$this->column_fields))
        {
            global $adb;
            //审批状态字段隐藏
            $sql= "select ".$columnname." from "  .$this->table_name." where "  .$this->table_index."=?";
            $result=$adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0){
                $this->column_fields[$fieldname]=$adb->query_result($result,0,0);
            }
        }else if($record>0&&empty($this->column_fields[$fieldname])){
            $this->retrieve_entity_info($record,$this->moduleName);
        }
        return $this->column_fields[$fieldname];
    }

	public function set_Is_needcommonsave_attachments($is_needcommonsave_attachments){
		$this->is_needcommonsave_attachments = $is_needcommonsave_attachments;
	}
    public function get_Is_needcommonsave_attachments(){
		return $this->is_needcommonsave_attachments;
	}

}


?>