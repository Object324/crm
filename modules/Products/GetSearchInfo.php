<?php
/**
 * edit:chj
 * date:2014-9-1
 * reason:获取模块模糊查询信息
 **/
global $adb,$current_user,$currentModule;
//require_once('modules/Products/Products.php');
crm_load_class_file('Products','modules/Products');
crm_load_class_file('cls_module_api','include/Module_Api');
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');


//海格 edit:duan  通过缓存控制报价单不允许选择已选择的产品，选择之后清除缓存
unset($_SESSION['haige'][$currentModule][$current_user->id]['productid_str']);
//获取产品的供应商
if(!empty($_REQUEST['productid']) && !empty($_REQUEST['getVendorName'])){
    $focus = CRMEntity::getInstance('Products');
    $fieldObj = Field::getInstance('Products',$adb);
    $moduleFields = $fieldObj->getModuleFields();
    $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'Products',SHOW_EDITVIEW);
    $showfieldvalueobj->setRecorId($_REQUEST['productid']);
    $field = $moduleFields['vendor_id'];
    $focus->retrieve_entity_info($_REQUEST['productid'], "Products");
    if(!empty($field)){
        $showvalue=$showfieldvalueobj->getFieldValueByField($field,$focus->column_fields['vendor_id'],$focus->column_fields['vendor_id']);
        $json['vendor_id'] = $showvalue['rawvalue'];
        $json['vendorname'] = $showvalue['value'];
    }
    echo $str=json_encode($json);//将数组进行json编码
    exit();
}
//产品单价自动根据客户最近一次购买的产品价格带出。

if(isset($_REQUEST['setProductValue']) &&$_REQUEST['setProductValue']=='yes'){
    $entity = array();
    $module = $_REQUEST['frommodule'];
    $productid = $_REQUEST['productid'];
    $account_id = $_REQUEST['account_id'];
    $now_currency_id = $_REQUEST['currency_id'];
    $deploy_values=getSys_deploy(79);

    if(($module == 'SalesOrder'||$module == 'Quotes')&&$deploy_values['deploy_value']==0){
        crm_load_function_file('getPricesForProducts','include/utils','InventoryUtils');
        $entity = getAccountBuyProductsPirce($module,$productid,$account_id,$now_currency_id);
    }
    @ob_clean();
    @ob_flush();
    $jarr['entity']=$entity;
    echo $str=json_encode($jarr);//将数组进行json编码
    exit();
}

//获取产品关联信息
if(isset($_REQUEST['getProductinfo']) && $_REQUEST['getProductinfo'] == 'yes'){
    $productid = $_REQUEST['productid'];
    crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
    $product_ids = explode(';',$productid);

    $frommodule=$_REQUEST['frommodule'];
    $fromfocus=CRMEntity::getInstance($frommodule);
    $version_info = getVersionInfo();

    /**
     * 判断选择源单客户是否为同一客户
     * 判断选择源单供应商是否同一供应商
     * */
    if(!empty($_REQUEST['source_idstr']) && !empty($_REQUEST['agian']) && !empty($_REQUEST['selectmodule'])){
        crm_load_class_file('cls_SourceSame','include/OptionModule');
        $selectentitytpeids=$_REQUEST['selectentitytypeids'];
        $selectfocus=CRMEntity::getInstance($_REQUEST['selectmodule']);
        $detailtable=$selectfocus->Detail_table;
        if(trim($selectentitytpeids,',')!='')
        {
            $tmpselectentitytpeids=array_filter(explode(",",$selectentitytpeids));
            //35795: （1.6）出库单新增、编辑界面>选择入库单为源单弹出层>选择一条源单，点击选择源单弹出层>在选择一条跟刚才不是一个供应商的源单>结果：没有弹出提示“您选择的记录包含多个供应商的单据，只允许选择同一个供应商的单据！”（需要补丁）
            $selectentitytpeids=trim(implode(',',$tmpselectentitytpeids),',');
            $sql=" select group_concat(lineitem_id) from $detailtable where id in(  ".$selectentitytpeids.')';

            $tmpresult=$adb->pquery($sql,array());

            $tmpsourcelineitemid=$adb->query_result($tmpresult,0,0);

        }

        $idstring=$_REQUEST['source_idstr'].','.$tmpsourcelineitemid;

        $obj=new cls_SourceSame($_REQUEST['selectmodule'],$idstring);
        if($obj->existsSameBill() != 'success'){
            echo $obj->existsSameBill();
            exit();
        }
    }

    $accountfocus=CRMEntity::getInstance("Accounts");
    $productselectlen=count($product_ids);
    $pricebookproductprice=array();
    if($_REQUEST['pricebooksid']>0)
    {
        //海格

        $sql='select * from ld_pricebookproductrel
        where pricebookid=? and productid in(  '.trim(implode(',',$product_ids),',').')';
        $result=$adb->pquery($sql,array($_REQUEST['pricebooksid']));
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $productid=$adb->query_result($result,$i,'productid');
            $usedcurrency=$adb->query_result($result,$i,'usedcurrency');
            $listprice=$adb->query_result($result,$i,'listprice');
            if($usedcurrency==$_REQUEST['currencyid'])
            {
            }
            else
            {
                $currencyobj=Currency::getInstance($adb,$_REQUEST['currencyid']);
                $changedcurrencyobj=new Currency($adb,$usedcurrency);

                $listprice=$currencyobj->ConvertTothisobj_money($changedcurrencyobj,$listprice);

            }
            $pricebookproductprice[$productid]=$listprice;
        }
    }
    $cls_module_api = new cls_module_api($_REQUEST['frommodule']);
    for($i = 0; $i<$productselectlen; $i++){
        if(!empty($product_ids[$i])){
            $ids = explode(',',$product_ids[$i]);
            if(sizeOf($ids) >= 2){
                foreach($ids as $lineitem_id){
                    $tmp=setProductsInfo($_REQUEST['frommodule'],$lineitem_id,$_REQUEST['currencyid'],$_REQUEST['wareid'],$_REQUEST['rowid'],'yes');;
                    if (!empty($_REQUEST['popup_selectsource']) && $_REQUEST['popup_selectsource'] == 'true') {
                        //原单产品名称带‘%’
                        $tmp['productname'] = str_replace('+', '%20', urlencode(vtlib_purify($tmp['productname'])));
                    }
                    $prod_arr[$lineitem_id]=$tmp;

                }
            }else{
                //editor:gyq_112 reason:PC参考-有分录单据选择源单自动带出值  2019/5/16 17:33
                //wym 原先$_request['rowid']无值 这里循环的$i正好充当rowid 如果有冲突还是需要前端传值$_request['rowid']
                if($_REQUEST['frommodule'] == 'WorkSheet' && $_REQUEST['withproductdetail'] == 'yes'){
                    $tmp= setProductsInfo($_REQUEST['selectmodule'],$product_ids[$i],$_REQUEST['currencyid'],$_REQUEST['wareid'],$i+1,'yes');
                }else{
                    $tmp= setProductsInfo($_REQUEST['frommodule'],$product_ids[$i],$_REQUEST['currencyid'],$_REQUEST['wareid'],$i+1,'yes');
                }
                if (!empty($_REQUEST['popup_selectsource']) && $_REQUEST['popup_selectsource'] == 'true') {
                    //原单产品名称带’%‘
                    $tmp['productname'] = str_replace('+', '%20', urlencode(vtlib_purify($tmp['productname'])));
                }


                /* else*/
                if($_REQUEST['pricebooksid']>0)
                {
                    //海格
                    $tmp['taxprice']=$pricebookproductprice[$product_ids[$i]];
                    $tmp['listprice']=$pricebookproductprice[$product_ids[$i]];
                }
                //东贸特殊开发：商户退铺请示单 选择订单后，表体的  退租日期 = 合同截止日期
                if($version_info['account'] == 'dongmao'){
                    $tmp['sf9334'] = $tmp['servicecontracts_end_date'];
                }
                //贺桃特殊开发
                if($version_info['account'] == 'hetao' && ($_REQUEST['frommodule'] == 'CustomForm17'||$_REQUEST['frommodule'] == 'CustomForm13')){
                    $focus = CRMEntity::getInstance('Products');
                    $focus->retrieve_entity_info($tmp['hdnProductId'], 'Products');
                    $tmp['baoyang_zhouqi'] = $focus->column_fields['cf_4568'];
                }
                //接口调用
                $_REQUEST['product_no'] = $tmp['product_no'];

                $cls_module_api->setProductInfo($tmp);
                $api_data = $cls_module_api->get();
                if(!empty($api_data)){
                    foreach($api_data as $colname => $value){
                        $tmp[$colname] = $value;
                    }
                }
                $prod_arr[$product_ids[$i].'aa']=$tmp;
            }


            if(array_key_exists("discount_percent",$prod_arr[$product_ids[$i].'aa']))
            {
                if(array_key_exists("account_id",$fromfocus->column_fields)&&$_REQUEST['accvenid']>0)
                {
                    //edit:can 54732 如图设置了产品扣率不生效
                    if(array_key_exists("discount_rate",$accountfocus->column_fields))
                    {
                        if($i==0)
                        {
                            //客户扣率
                            $sql='select discount_rate from ld_account where accountid=? ';
                            $result=$adb->pquery($sql,array($_REQUEST['accvenid']));
                            if($adb->num_rows($result)>0)
                            {
                                $account_discount_rate=$adb->query_result($result,0,0);

                            }
                        }

                        $prod_arr[$product_ids[$i].'aa']['discount_percent']=$account_discount_rate;

                    }
                }

            }

        }
    }


    $len=sizeof($prod_arr);

    $tmparr['data']=$prod_arr;
    $tmparr['datalen']=$len;

    @ob_clean();
    @ob_flush();
    $version_info = getVersionInfo();
    if($version_info['account']=='huacanguangdian' && $_REQUEST['frommodule'] == 'CustomForm37') {
        foreach ($prod_arr as $product_id => &$valueinfo){
            $month = date('m');
            $valueinfo['sf5728'] = $month + $_REQUEST['rowid'] - 1;
            if($valueinfo['sf5728'] > 12){
                $valueinfo['sf5728'] = $valueinfo['sf5728'] - 12;
            }
        }
    }
    $jsonentity = Zend_Json::encode($prod_arr);

    echo $jsonentity;exit();
}
//价格信息 date:2017-03-14
if(isset($_REQUEST['getPriceBooksinfo']) && $_REQUEST['getPriceBooksinfo'] == 'yes'){
    //入库单产品明细中“不含税单价”后面的书本图标点击需求
    if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] =='Stock'&&$_REQUEST['pricebooklist']!='yes'){
        $focus = CRMEntity::getInstance('Stock');
        $html = $focus->getPriceBooksinfo($_REQUEST['frommodule'],$_REQUEST['productid'],$_REQUEST['currencyid'],$_REQUEST['accvenid'],$_REQUEST['checkaccven'],$focus);
    }else{

        //crm_load_function_file('getPriceBooksinfo','include/utils','ListViewUtils');
        $html = getPriceBooksinfo($_REQUEST['frommodule'],$_REQUEST['productid'],$_REQUEST['currencyid'],$_REQUEST['accvenid'],$_REQUEST['checkaccven']);
    }
    echo $html;exit();
}
$module = 'Products';
$focus=new $module();
//关键字
if(isset($_REQUEST['keywords']))
    $keywords = trim($_REQUEST['keywords']);
else
    $keywords = '';
//获取模糊查询的显示列头
$tmp_field_obj=Field::getInstance($module,$adb);
$searchInfo['header'] = $tmp_field_obj->getSearchHeader();
//获取模糊查询的可见字段、拼接字段
$searchFieldArr = $tmp_field_obj->getSearchKeyField($module);
for($i = 0; $i<count($searchFieldArr); $i++)
{
    $columnname[$i] = $searchFieldArr[$i]['columnname'];
}
$searchInfo['entries'] = getSearchEntries($searchFieldArr,$module,$keywords);
//判断模糊查询内容是否为空
if(isset($searchInfo['entries']))
    $searchInfo['columnname'] = $columnname;
else
    $searchInfo['columnname'] = '';
$jsonentity = json_encode($searchInfo);
echo $jsonentity;exit();

/**
 * edit:chj
 * date:2014-9-11
 * reason:获取模块的模糊查询关联内容信息
 * */
function getSearchEntries($searchFieldArr,$module,$keywords)
{
    global $adb,$list_max_entries_per_page_new,$current_user,$default_charset;

    $moduleObj = new $module();
    $tabid = getTabid($module);
    $table_name = $moduleObj->table_name;
    $table_index = $moduleObj->table_index;
    $tab_name_index = $moduleObj->tab_name_index;
    $innertable = '';//表连接
    $wheretable = '  where ';//模糊匹配条件
    $fieldobj=Field::getInstance($module,$adb);
    $modulefields=$fieldobj->getModuleFields();
    $table_array = array();
    if($_REQUEST['pricebooksid']>0)
    {
        $innertable.=' inner join ld_pricebookproductrel on ld_pricebookproductrel.productid=ld_products.productid
        and ld_pricebookproductrel.pricebookid= '.$_REQUEST['pricebooksid'];

    }
    $orderbyfiled = [];
    for($i = 0; $i<count($searchFieldArr); $i++)
    {
        $columnname[$i] = $searchFieldArr[$i]['tablename'] . '.' . $searchFieldArr[$i]['columnname'];
        //inner 表关联
        if($searchFieldArr[$i]['tablename'] != $table_name && !in_array($searchFieldArr[$i]['tablename'],$table_array))
        {
            $table_array[$searchFieldArr[$i]['tablename']] = $searchFieldArr[$i]['tablename'];
            $innertable .= ' LEFT JOIN ' . $searchFieldArr[$i]['tablename'] . ' ON ' . $searchFieldArr[$i]['tablename'] . '.' .$tab_name_index[$searchFieldArr[$i]['tablename']] .
                ' = ' . $table_name.'.'.$table_index;
        }
        //模糊匹配条件
        if($keywords)
        {
            $field = $modulefields[$searchFieldArr[$i]['columnname']];
            if(!empty($field)){
                if($field->getFieldDataType() == 'datetime' || $field->getFieldDataType() == 'date' || $field->getFieldDataType() == 'time'){
                    $wherefiled[$i]= $searchFieldArr[$i]['tablename'] . '.' . $searchFieldArr[$i]['columnname'] . ' like binary ' . '"%'.$keywords.'%"';
                }else{
                    $wherefiled[$i]= $searchFieldArr[$i]['tablename'] . '.' . $searchFieldArr[$i]['columnname'] . ' like ' . '"%'.$keywords.'%"';
                    $orderbyfiled[$i]= $searchFieldArr[$i]['tablename'] . '.' . $searchFieldArr[$i]['columnname'] . ' = ' . '"'.$keywords.'"';
                }
            }
        }
    }
    $columnname[$i]='ld_products.havepricestrategy';

    if($current_user->is_admin != 'on'){
        $innertable.=$moduleObj->getNonAdminAccessControlQuery($module,$current_user,"");
    }
    if($keywords){

        $wheretable .= '(' . implode(' or ',$wherefiled) . ') ';
    }
    $wheretable .=  ' AND ' . $table_name . '.deleted = 0 and ' . $table_name . '.' . $table_index . ' >0 ';
    /**
     * @author andrew
     * @data 2015-7-7
     * @param 选择产品时，是否判断已经审批
     */
    $deployarray=getSys_deploy(71);//选择产品是否判断审批
    $deployarray_select=getSys_deploy(70);//产品模块审批是否开启
    if($deployarray['deploy_value']==='0'&&$module=='Products'&&$deployarray_select['deploy_value']=='0'){
        $wheretable .= " and ld_products.approvestatus='".constant('D_A_S_APPROVED')."' ";
    }

    if(isset($_REQUEST['wareid']) && $_REQUEST['wareid'] > 0)
        $wheretable .= ' AND ld_warehouse2products.warehouseid = ' . $_REQUEST['wareid'];
    //产品模块特殊，得带出产品更多相关信息如：产品关联信息，产品自定义字段
    if($module == 'Products')
    {
        if(isset($_REQUEST['currencyid']) && $_REQUEST['currencyid'] != 1)
        {
            $sql = 'select DISTINCT productname,IFNULL(ld_productcurrencyrel.actual_price ,0) as unit_price,qtyinstock,costprice,
        ' . $table_name . '.' . $table_index . ',' . implode(',',$columnname) . ' from ' . $table_name;
            $sql .= ' left join ld_productcurrencyrel on ld_productcurrencyrel.' . $table_index . ' = ' . $table_name . '.' . $table_index . ' ';
            $sql .=  ' and ld_productcurrencyrel.currencyid = '.$_REQUEST['currencyid'].' ';
            if(!empty($_REQUEST['frommodule']) && in_array($_REQUEST['frommodule'],array('PurchaseOrder','PurchaseBack','Stock'))){
                $sql .= " and ld_productcurrencyrel.price_type = 'procostprice'";
            }else{
                $sql .= " and ld_productcurrencyrel.price_type = 'unit_price'";
            }
        }
        else
        {
            $sql = 'select DISTINCT productname,IFNULL(unit_price ,0) as unit_price,qtyinstock,costprice, ' . $table_name . '.' . $table_index . ',' . implode(',',$columnname) . ' from ' . $table_name;
        }
    }
    else
    {
        $sql = 'select DISTINCT ' . $table_name . '.' . $table_index . ',' . implode(',',$columnname) . ' from ' . $table_name;
    }
    crm_load_class_file('cls_RelateCreateCondition','include');
    $relatecreateconditionobj=cls_RelateCreateCondition::getInstance('Products',$_REQUEST['frommodule']);
    $columnvalues=ldcrm_json_decode($_REQUEST['requestvalues']);
    $relatecreateconditioninfos=  $relatecreateconditionobj->getChooseDataWhere($columnvalues);
    //zkt 20240402 XUQIU20240122-01 带产品分录的表单，分录明细“产品名称”输入关键字搜索时，搜索出来的列表数据排列顺序应该是精确查找出来的数据排列显示在最上方（黄小俊）
    $orderby = ' order by ';
    if($keywords&&!empty($orderbyfiled)){
        $orderby .= ' if(' . implode(' or ',$orderbyfiled) . ',1,2), ';
    }
    $orderby .= '  convert(productname using gbk) asc ';
    $deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
    $wheretable.=' and ld_products.deleted =0 ';
    $wheretable.=$relatecreateconditioninfos['where'];
    $jointable = is_array($relatecreateconditioninfos['tables'])?$relatecreateconditioninfos['tables']:[];

    if($module=='Products'&&$deployarray_82['deploy_value']=='0'&&!empty($_REQUEST['frommodule'])&&get_file_address($_REQUEST['frommodule'],'ProductDetails')){

        if($moduleObj->fieldobj->getFieldInfoBykeyValue('columnname','discontinued','presence')!=1)
            $wheretable.= ' and ld_products.discontinued = 0 ';//1禁用 0启用
    }
    $ScopOfAuthority = ScopOfAuthority::getInstance($adb, $module);
    $sec_parameter_where = $ScopOfAuthority->getSmOwnerSearchSql(); //为空：全部权限
    if(!empty($sec_parameter_where)){
        $wheretable .= $sec_parameter_where;
    }
    $sharewhereFieldTables = $ScopOfAuthority->getsharewhereFieldTables();
    //0032009: 系统设置>模块共享规则：产品管理设置为私有时，普通用户，合同订单新建时，产品名称，录入产品名称，还是会显示模糊匹配的列表
    if($current_user->is_admin=='off'&&$current_user->accountallview==0){
        $scopeobj = new ScopOfAuthority($adb,'Products');
        $getSmOwnerSearchSql =$scopeobj->getSmOwnerSearchSql();
        if(!empty($getSmOwnerSearchSql)){
            $wheretable .= $getSmOwnerSearchSql;
        }
        $sharewhereFieldTables = $scopeobj->getsharewhereFieldTables();
    }
    if(is_array($sharewhereFieldTables)){
        $jointable = array_merge($jointable,$sharewhereFieldTables);
    }
    foreach($jointable as $tmptable=>$leftjoin)
    {
        $innertable.=' left join '.$leftjoin;
    }
    unset($jointable,$sharewhereFieldTables);
    $sql .= $innertable . $wheretable . $orderby . ' limit 0,' . $list_max_entries_per_page_new;
    $query = $adb->pquery($sql);
    $num_rows = $adb->num_rows($query);
    /**
     * 获取系统参数 表体录入样式配置信息 1:外贸行业
     * @project PROT99 奥特林：产品明细录入改进
     * @author Tujt 2014-10-15
     */
    $deployarray_52 = getSys_deploy(52);
    global $isrmbproduct;
    $isrmbproduct = 1;
    if($deployarray_52['deploy_value'] == '1'){
        $isrmbproduct =	getRMBProductInfo();
    }
    for($i = 0; $i<$num_rows; $i++)
    {
        $id = $adb->query_result($query,$i,$table_index);
        foreach($searchFieldArr as $key => $val)
        {
            $columnname = $val['columnname'];
            $res = $adb->query_result($query,$i,$columnname);
            if($res == null)
                $res = '';
            //wym 240326 BUG20240325-35 服务合同分录明细中，'产品名称“字段模糊查询下拉选项中“负责人”列显示数字
            if($val['columnname']=='smownerid'){
                $tmpsql='select last_name from ld_users where id=?';
                $tmpresult = $adb->pquery($tmpsql,array($res));
                $last_name=$adb->query_result($tmpresult,0,0);
                $userobj=new Users();
                $userobj->wx_userid=$res;
                $userobj->last_name=$last_name;
                $listviewentity[$id][$columnname] = getUserlastName($userobj);
            }else{
                $listviewentity[$id][$columnname] = $res;
            }
        }
        //产品关联信息
        if($module == 'Products')
        {
            //  crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
            //$tmp_arr=setProductsInfo($_REQUEST['frommodule'],$id,$_REQUEST['currencyid'],$_REQUEST['wareid'],$_REQUEST['rowid']);
            $listviewentity[$id]['vt_prod_arr'] = $tmp_arr;
        }
    }

    return $listviewentity;
}

//选择价格表
function getPriceBooksinfo($module, $productid, $currencyid, $accvenid, $checkaccven)
{
    global $adb,$global_minversin;
    $price_sysdeploy = getSys_deploy(93);//单价小数位控制
    if (isset($price_sysdeploy['deploy_value']))
        $price_lengthdecimaldigits = $price_sysdeploy['deploy_value'];
    else
        $price_lengthdecimaldigits = 2;

    $rowid = $_REQUEST['rowid'];
    $fldname = $_REQUEST['fldname'];
    $In_Modules = array('PurchaseOrder', 'PurchaseBack', 'PurchaseInvoice', 'PurchaseCashBack', 'Stock', 'PurchaseInquiryOrder');
    $focus = CRMEntity::getInstance($module);

    $query = "select (select productname from ld_products where productid = $productid) as productname,
            listprice/(conversion_rate/(select conversion_rate from ld_currency_info where id = $currencyid)) as trans_listprice,
            signed_data,listprice,currency_symbol from $focus->Detail_table %s ";
    $query .= " where productid = $productid %s group by listprice ";
    $query .= " ORDER BY signed_data desc,createdtime desc limit 5";

    if (in_array($module, $In_Modules)) {//采购流程
        $join_sql = " inner join ld_purchaseorder on ld_purchaseorder.purchaseorderid=ld_purchaseorderdetail.id";
        $status_sql = " and postatus <> '已作废' and approvestatus <> '已拒绝' and deleted = 0 ";
        $accven_con = " and vendorid = $accvenid ";
        $basemodule = 'PurchaseOrder';
        $relatemodule = 'Vendors';
    } else {//销售流程
        $join_sql = " inner join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id";
        $status_sql = " and sostatus <> '已作废' and approvestatus <> '已拒绝' and deleted = 0 ";
        $accven_con = " and accountid = $accvenid ";
        $basemodule = 'SalesOrder';
        $relatemodule = 'Accounts';
    }
    if (!empty($accvenid) && $checkaccven != 'false') {
        $sql = sprintf($query, $join_sql, $status_sql . $accven_con);
    } else {
        $sql = sprintf($query, $join_sql, $status_sql);
    }
    //echo $sql;
    $result = $adb->pquery($sql, array());
    $num_rows = $adb->num_rows($result);

    $table = "";
    //title
    $table .= '<div class="D_pop_tit">';
    $table .= '<strong class="D_ptita">' . getFixedLabel('PRICEINFORMATION') . '</strong>';
    $table .= '<a href="javascript:fninvshnew(\'selectpricebokksdiv\');" class="D_ptitc">';
    $table .= '<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="' . getFixedLabel('CLOSE') . '" title="' . getFixedLabel('CLOSE') . '"/>';
    $table .= '</a></div>';

    $table .= '<div class="D_pop_content">';
    //1.
    $table .= '<p style="margin-bottom:10px;"><b>1.' . getFixedLabel('SELECTHISTORICALPRICE') . '</b></p><p></p>';

    if (!empty($accvenid)) {//复选框
        $check = $checkaccven == 'true' ? 'checked' : '';
        $table .= '<div style="margin-bottom:10px">';
        $table .= sprintf(getFixedLabel('SHOWDOCUMENTSASSOCIATEDS'), strtolower(getTranstab($relatemodule)));
        $table .= '<input ' . $check . ' type="checkbox" onchange="showPopupPriceBook(' . $productid . ',' . $rowid . ',this.checked)">';
        $table .= '</div>';
    }

    //table
    $table .= '<table align="center" class="listdata" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr style="background:red">';
    crm_load_class_file('ProductToolFields', 'include/ProductDetails');
    $productToolFields = new ProductToolFields($module);
    //列头：产品名称，不含税单价，签约日期
    $headers = array(gettranslabelfields('Products', 'productname'), $productToolFields->getModuleProductDetail_ColumnFieldlabel(getTabid($basemodule), 'listprice'), gettranslabelfields($basemodule, 'signed_data'));
    foreach ($headers as $header) {
        $table .= '<th style="background-color:#efefef"><span title="' . $header . '">' . $header . '</span></th>';
    }
    $table .= '</tr>';

    //content
    if ($num_rows > 0) {
        for ($i = 0; $i < $num_rows; $i++) {
            $productname = $adb->query_result($result, $i, 'productname');
            $translistprice = $adb->query_result($result, $i, 'trans_listprice');    //币种转换后的价格
            $signdata = $adb->query_result($result, $i, 'signed_data');
            $listprice = $adb->query_result($result, $i, 'listprice');
            $currencysymbol = $adb->query_result($result, $i, 'currency_symbol');
            $trans_input = '<input type="hidden" value="' . sprintf('%.' . $price_lengthdecimaldigits . 'f', $translistprice) . '">';
            $table .= '<tr class="lvtColData">';
            $table .= '<td>' . $productname . '</td>';
            $table .= '<td align="right"> <a onclick="fillRowListPrice(this,\'' . $fldname . '\')" style="cursor:pointer;">' . $currencysymbol . sprintf('%.' . $price_lengthdecimaldigits . 'f', $listprice) . '</a>' . $trans_input . '</td>';
            $table .= '<td>' . $signdata . '</td>';
            $table .= '</tr>';
        }
    } else {
        if (!empty($checkaccven) && $checkaccven != 'false') {
            $table .= '<tr align="center">';
            $table .= '<td colspan="3" bgcolor="#efefef">';
            $table .= '<div class="warningTableContent" style="z-index:600;width: 50%;margin: 10px auto;">';
            $table .= '<div class="wtc_img" style="width:255px"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'">';
            $table .= '</div>';
            $table .= '<div class="wtc_content">' . getFixedLabel('NOTFOUNDANYRECORD') . '</div>';
            $table .= '<div class="wtc_btn"></div>';
            $table .= '<div></div>';
            $table .= '</div>';
            $table .= '</td></tr>';
        } else {
            return '$#NONERECORD#$';
        }
    }
    $table .= '</tbody></tbody></table>';
    if (vtlib_isModuleActive('PriceBooks')) {
        //2.
        $clickopen = 'fninvshnew(\'selectpricebokksdiv\');showOtherPopupPriceBook(' . $rowid . ',\'' . $fldname . '\',' . $productid . ',' . $currencyid . ');';
        $table .= '<p style="margin-top:10px"><b>2.' . getFixedLabel('SELECTPRICEBOOKS') . '</b><a onclick=' . $clickopen . ' style="cursor:pointer;">' . getFixedLabel('VIEWPRICEBOOKS') . '</a>' . '</p>';
    }
    $table .= '</div>';
    return $table;
}

?>