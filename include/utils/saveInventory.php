<?php

require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
class saveInventory
{


    public function save(&$focus, $module, $update_prod_stock='false', $updateDemand='')
    {






        global  $adb, $current_user;
        $Detail_table_index=$focus->Detail_table_index;
        $inventoryProductValue[$Detail_table_index] = $focus->id;//产品明细表：ld_inventoryproductrel的ID
        require_once(globalStatic::$root_directory.'include/ProductDetails/ProductToolFields.php');
        $languageType= getLanguageType($current_user);
        $tabid = getTabid($module);

        $Detail_table=$focus->Detail_table;
        $Detail_table_scf=$focus->Detail_table_scf;
        $Detail_table_id=$focus->Detail_table_id;
        $Detail_table_index=$focus->Detail_table_index;

        $entitytype='';//源单模块
        if(isset($_REQUEST['convert_from']) && $_REQUEST['convert_from'] !='')
        {
            $inventoryProductValue[$Detail_table_index]=$_REQUEST['return_id'];
        }
        else if(isset($_REQUEST['duplicate_from']) && $_REQUEST['duplicate_from'] !='')
        {
            $inventoryProductValue[$Detail_table_index]=$_REQUEST['duplicate_from'];
        }

        //记录保存前的分录信息
        $before_db_value =$this->getbeforedetail($focus);

        //获取当前有权限查看到当前模块的所有自定义字段
        $ProductToolFields = ProductToolFields::getInstance($module);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
        $user_noprofile_fields = $ProductToolFields->user_noprofile_fields;
        //灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点
        $deployarray=getSys_deploy(48);
        global $isupdateware;//是否修改仓库，在save.php判断 tujt 2014-08-25
        $sql = "select $Detail_table.productid,quantity,entitytypeid,balanceoutproductcount,
							haveoutproductcount,entitytype,batchtext,batchmanagement,
							balancepurchasecount,havepurchasecount,parent_lineitem_id,
							lineitem_id,tax_amount from $Detail_table
							inner join ld_products  on $Detail_table.productid=ld_products.productid
							 where $Detail_table_index = ? ";
        if($module == 'CashBill'||$module == 'SendCashBill'){
            //收付款明细表没有quantity,batchtext字段
            $sql = "select $Detail_table.productid,entitytypeid,balanceoutproductcount,
								haveoutproductcount,entitytype,batchmanagement,
								balancepurchasecount,havepurchasecount,parent_lineitem_id,
								lineitem_id,tax_amount from $Detail_table
								inner join ld_products  on $Detail_table.productid=ld_products.productid
								 where $Detail_table_index = ? ";
        }

        $query = $adb->pquery($sql,array($inventoryProductValue[$Detail_table_index]));
        $num_rows = $adb->num_rows($query);

        $columns=array('productid','tax_amount','quantity','entitytypeid','lineitem_id','entitytype','batchtext','batchmanagement');
        crm_load_class_file("ProductFields",'include/ProductDetails');
        for($i = 0; $i<$num_rows; $i++){
            //获取变更之前的对应产品的已出库数量
            foreach($columns as $columnname)
            {

                $FieldInfo=new ProductFields();
                $FieldInfo->setcolumnName($columnname);
                $FieldInfo->setColumn_Value($adb->query_result($query,$i,$columnname));
                $focus->before_detail_info[$i][$columnname]=$FieldInfo;
            }
            $batchmanagement=$adb->query_result($query,$i,'batchmanagement');//是否启用批次管理
            $batchtext = (string)$adb->query_result($query,$i,'batchtext');//批次
            if(trim($batchtext)=='')
            {
                $batchtext=DEFAULTBATCHTEXT;

            }
            
            if(($module == 'Stock' || $module == 'OutboundOrder') && $deployarray['deploy_value'] == 1){

                $beforeproductdetail[$adb->query_result($query,$i,'productid')][$batchtext] += $adb->query_result($query,$i,'quantity');
                $beforeproduct[$adb->query_result($query,$i,'lineitem_id')] = $adb->query_result($query,$i,'productid');

            }

            else{
                $beforeproduct[$adb->query_result($query,$i,'lineitem_id')] = $adb->query_result($query,$i,'productid');
            }

            $beforelineitem_id[$adb->query_result($query,$i,'lineitem_id')]=$adb->query_result($query,$i,'lineitem_id');
            $beforelineitem_parentid[$adb->query_result($query,$i,'lineitem_id')]=$adb->query_result($query,$i,'parent_lineitem_id');
            if($adb->query_result($query,$i,'parent_lineitem_id')>0)
                $beforeparentlineid[$adb->query_result($query,$i,'parent_lineitem_id')] =$adb->query_result($query,$i,'productid');
            $entitytypeid = $adb->query_result($query,$i,'entitytypeid');
            $entitytype = $adb->query_result($query,$i,'entitytype');
            $beforeentitytypeid[$entitytypeid] = $entitytypeid;
            $focus->before_sourcemodule_info[] = array(
                'entitytypeid' => $entitytypeid,
                'entitytype' => $entitytype
            );
            $focus->before_lineitem_ids[]=$adb->query_result($query,$i,'lineitem_id');

        }

        if(get_versiontrade() == 'yangduan'){

            if($module == 'SalesOrder'){
                foreach($ProductToolFieldsInfo as $columnname => $columnInfo){
                    if($columnname == 'productname')$columnname = 'productid';
                    $productdetail_columns[] = $columnname;
                    $productdetail_column_sql[] = $columnInfo->getTableName() . '.' . $columnname;
                }
                if(!empty($productdetail_column_sql) && !empty($inventoryProductValue['id'])){
                    $productdetail_column_sql[] = $Detail_table.'.'.$Detail_table_id;
                    $query = 'select ' . implode(',',$productdetail_column_sql) . ' from '.$Detail_table." 
								LEFT JOIN $Detail_table_scf on $Detail_table_scf.$Detail_table_id = $Detail_table.$Detail_table_id 
								LEFT JOIN ld_products on ld_products.productid = $Detail_table.productid 
								LEFT JOIN ld_productcf on ld_productcf.productid = ld_products.productid 
								LEFT JOIN ".$focus->table_name.' on '.$focus->table_name.'.'.$focus->table_index." = $Detail_table.$Detail_table_index
								where $Detail_table.$Detail_table_index = ?";
                    $result = $adb->pquery($query,array($inventoryProductValue['id']));
                    $num_rows = $adb->num_rows($result);
                    for($i = 0; $i<$num_rows; $i++){
                        $lineitem_id = $adb->query_result($result,$i,'lineitem_id');
                        foreach($productdetail_columns as $fieldname){
                            $before_db_value[$lineitem_id][$fieldname] = $adb->query_result($result,$i,$fieldname);
                        }
                    }

                }
            }
            $query = "select sf1105,$Detail_table.lineitem_id from $Detail_table
						LEFT JOIN $Detail_table_scf on $Detail_table_scf.lineitem_id = $Detail_table.lineitem_id 
						where $Detail_table.id = ?";
            $query = $adb->pquery($query,array($inventoryProductValue['id']));
            $num_rows = $adb->num_rows($query);
            if($num_rows > 0){
                for($i = 0; $i<$num_rows; $i++){
                    $sf1105 = $adb->query_result($query,$i,'sf1105');
                    $lineitem_id = $adb->query_result($query,$i,'lineitem_id');
                    $yd_before[$lineitem_id] = $sf1105;
                }
            }
        }

        $batch_productid_arr = [];
        if($focus->mode == 'edit'){

            if(!empty($user_noprofile_fields) && $current_user->is_admin != 'on'){
                crm_load_function_file('getUserNoProfileFields_DbValue','include/utils','InventoryUtils');
                $user_noprofile_fields_dbvalue = getUserNoProfileFields_DbValue($user_noprofile_fields,$focus);
            }
            //  dump($user_noprofile_fields);
            //chj:0014236: 销售退款单--明细：分配负责人后，产品信息区块，产品信息，空白。
            // editor:gyqX160802 Bug:0022129
            $this->deleteInventoryProductDetails($focus,$module);
            if( ($module == 'OutboundOrder' || $module == 'Stock'||$module=="SalesBack"||$module=="Checks")){
                //edit: can BUG20240118-48  销售退货单模块，THD20240118-277的单据已经状态显示“已入库”，但是在产品里面的库存数量还是0，如图。库存台账里面已经显示20了。如果我重新点击一下保存他就会有更新
                $deployarray=getSys_deploy(48);//灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
                if($deployarray['deploy_value']== 1){
                    /**
                     * 编辑仓库后，原仓库产品全部退货
                     * 出库单：入库，入库单：出库
                     * @project PROT89 库存流水账逻辑修改
                     * @author Tujt 2014-08-25
                     */
                    crm_load_function_file('insertCondtion','include/Stock','CommonStock');
                    foreach($beforeproductdetail as $key => $val){


                        foreach($val as $batchtext=>$tmpquantity)
                        {
                            $batch_productid_arr[] = $key;
                            /*
                                if($isupdateware > 0){
                                    insertCondtion($batchtext,$inventoryProductValue['id'],$var,$isupdateware,$key,$module,$focus->column_fields['assigned_user_id'],0,$tmpquantity,0,0);
                                }else{
                                    insertCondtion($batchtext,$inventoryProductValue['id'],$var,$focus->column_fields['wareid'],$key,$module,$focus->column_fields['assigned_user_id'],0,$tmpquantity,0,0);
                                }
                            */
                        }

                    }
                }
            }
        }

        //获取模块的原单是当前编辑保存的模块(数组)

        if($focus->mode=='edit')
        {
            $havecursourcemodules= getHaveSourceProductDetailModulebyModule($focus->module_name);
            if($focus->module_name=='Quotes'&&!in_array('SalesOrder',$havecursourcemodules))
            {
                $havecursourcemodules[]='SalesOrder';
            }
            if($focus->module_name=='CustomForm14'&&!in_array('BudgetChange',$havecursourcemodules))
            {
                $havecursourcemodules[]='BudgetChange';

            }
            $module_count_arr = [];
            foreach($havecursourcemodules as $tmphavesourcemodule)
            {
                $tmphavesourcefocus=CRMEntity::getInstance($tmphavesourcemodule);
                $count_sql = "SELECT COUNT(*) as cnt from ".$tmphavesourcefocus->Detail_table ." where entitytypeid = ?";
                $result = $adb->pquery($count_sql,[$focus->id]);
                $cnt = 0;
                if($adb->num_rows($result)>0){
                    $cnt = $adb->query_result($result,0,'cnt');
                }
                $module_count_arr[$tmphavesourcemodule] = $cnt;
            }


        }

        $rowid = 1;	//产品明细每次都时从第一行开始计算
        $sequence_no = 1;
        $moduleTableName = $focus->table_name;	//模块主表
        $moduleTableId = $focus->table_index;	//模块主表ID
        $total = 0;
        crm_load_function_file('getLineitemModuleInfo','include/Stock','CommonStock');
        crm_load_class_file('ProductFields','include/ProductDetails');
        $rowcnt = $_REQUEST['rowcnt'];
        $tmpsource_contractids=array();
        $aftersavedetailfieldvalue_arr=[];

        $presentRowInfo = [];
        $inventoryProductsKeys = [];
        
        do{
            if(!empty($_REQUEST['hdnProductId'.$rowid]) && $_REQUEST['hidden_rowid_'.$rowid] == 0){
                if(isset($_REQUEST['lineitem_id'.$rowid]) && $_REQUEST['lineitem_id'.$rowid] > 0){
                    $inventoryProductValue['parent_lineitem_id'] = $_REQUEST['lineitem_id'.$rowid];
                }else{
                    $inventoryProductValue['parent_lineitem_id'] = 0;	//产品明细 源单产品行的lineitem_id
                }

                //获取模块的源单ID（销售退货、采购退货、销售退款、采购退款：产品明细没有源单列，所有在这只能获取表单的原单ID）
                //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(salesorder_id废掉了，使用标准的源单)
                /*if(($module == 'SalesBack' || $module == 'CashBack') && isset( $_REQUEST['salesorder_id']))
                {
                     $inventoryProductValue['entitytypeid'] = $_REQUEST['salesorder_id'];
                    $_REQUEST['entitytype'.$rowid]='SalesOrder';
                }
                else*/ if($module=='SalesOrder'&&$inventoryProductValue['parent_lineitem_id']>0&&empty($_REQUEST['selectlistval']))
                {

                    //用于计算报价单的未下单数量和已下单数量
                    $_REQUEST['entitytype'.$rowid]=$_REQUEST['selectsource'];
                    $inventoryProductValue['entitytypeid']=$_REQUEST['quote_id'];
                }
                /*else if(($module == 'PurchaseBack' || $module == 'PurchaseCashBack') && isset( $_REQUEST['purchaseorder_id']))
                {
                     $inventoryProductValue['entitytypeid'] = $_REQUEST['purchaseorder_id'];
                     $_REQUEST['entitytype'.$rowid]='PurchaseOrder';
                }*/
                else if(isset( $_REQUEST['selectSourceModuleid'.$rowid]) && $_REQUEST['selectSourceModuleid'.$rowid] > 0)
                    $inventoryProductValue['entitytypeid'] = $_REQUEST['selectSourceModuleid'.$rowid];

                else
                    $inventoryProductValue['entitytypeid'] = 0;	//产品明细 源单的recordid
                //源单模块
                if($_REQUEST['lineitem_id'.$rowid]&&!empty($inventoryProductValue['entitytypeid'])){

                    //	$info = getLineitemModuleInfo($_REQUEST['lineitem_id'.$rowid]);
                    $inventoryProductValue['entitytype'] = $_REQUEST['entitytype'.$rowid];
                    if($inventoryProductValue['entitytype']=='undefined'||$inventoryProductValue['entitytype']=='')
                    {
                        //edit:can 20210208 原单显示，原单类型隐藏
                        //echo $inventoryProductValue['entitytypeid'] . '===';echo '<br><br>';
                        $inventoryProductValue['entitytype']=getSalesEntityType($inventoryProductValue['entitytypeid']);

                    }
                }else{
                    $inventoryProductValue['entitytype']='';	//源单模块
                }

                if(is_numeric($_REQUEST['tax_amount'.$rowid])){
                    $total += $_REQUEST['tax_amount'.$rowid];
                }

                if($module == 'CashBill'||$module == 'SendCashBill'){
                    $subtotal += $_REQUEST['amount'.$rowid];
                }
                /**
                 * diony
                 * 2014-11-26
                 * 判断如果是合同订单保存后自动创建出库单，读取更改
                 */
                if($focus->column_fields['autocreateoutorder']=='yes')
                {
                    $inventoryProductValue['entitytypeid'] = $focus->column_fields['selectSourceModuleid'.$rowid];
                    $inventoryProductValue['parent_lineitem_id'] = $focus->column_fields['lineitem_id'.$rowid];
                }
                if($inventoryProductValue['entitytypeid']>0)//获取原单集合
                    $entitytypeids[]=$inventoryProductValue['entitytypeid'] ;
                if($module=='WorkSheet'){
                    //配件关联原产品id
                    $inventoryProductValue['related_productid'] = $_REQUEST['related_productid'.$rowid];;
                }
                $inventoryProductValue['sequence_no'] = $sequence_no;//产品显示顺序
                $inventoryProductValue['productbomid']=$_REQUEST['productbomid'.$rowid];//产品套餐id
                $inventoryProductValue['productbomquantity']=$_REQUEST['productbomquantity'.$rowid];//产品套餐份数
                $inventoryscfProductValue = [];
                foreach($ProductToolFieldsInfo as $fieldInfo){

                    $columnname = $fieldInfo->getColumnName();
                    $tablename = $fieldInfo->getTableName();
                    //uitype = 70产品名称

                    if($fieldInfo->getUIType() == 70){
                        $inventoryProductValue['productid'] = $_REQUEST['hdnProductId'.$rowid];
                    }

                    //ls 2022-01-13 0049511:移动端，进入销售发票模块，选择源单并填写数据保存单据。再进入详情页面，发现“选择源单”分录没有数据。影响了合同统计表的发票统计数据。(表ld_invoicedetail的值entitytypeid被下方循环体重新赋值了，导致错误（选择源单的entitytypeid被产品的的entitytypeid1覆盖）,重名了，先这样)
                    if ($columnname == 'entitytypeid' && !empty($inventoryProductValue[$columnname])) {
                        continue;
                    }

                    $typeofdata = explode('~',$fieldInfo->getTypeOfData());
                    //允许编辑和有字段公式的自定义字段都可以保存到数据库里
                    if($fieldInfo->getSaveDataBase() == 'yes' || ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid' || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
                        if($fieldInfo->getUIType() == 63){

                            $columnnameValue = setsaveMutliPickListValue($_REQUEST[$columnname.$rowid]);
                            // implode(' |##| ',$_REQUEST[$columnname.$rowid]);

                        }else{
                            $columnnameValue = isset($_REQUEST[$columnname.$rowid])?trim($_REQUEST[$columnname.$rowid]):$_REQUEST[$columnname.$rowid];
                        }


                        if(($typeofdata[0] == 'N' || $typeofdata[0] == 'NN')){
                            if(empty($_REQUEST[$columnname.$rowid])){
                                $columnnameValue = 0.00;
                            }else{
                                $columnnameValue = str_replace(' ','',$_REQUEST[$columnname.$rowid]);
                            }
                        }
                        // duan 20230620 日期字段不填写时，在数据库中保存为null
                        if(in_array($fieldInfo->getUIType(),[51,52])){
                            if (empty($_REQUEST[$columnname.$rowid])) {
                                //日期，时间字段为空赋值为NULL
                                $columnnameValue = null;
                            } else {
                                $columnnameValue = $_REQUEST[$columnname.$rowid];
                            }
                        }


                        if(strtolower($fieldInfo->getTableName()) == $Detail_table){
                            $inventoryProductValue[$columnname] = $columnnameValue;

                        }else if(strtolower($fieldInfo->getTableName()) ==$Detail_table_scf){
                            $inventoryscfProductValue[$columnname] = $columnnameValue;
                        }
                    }
                }

                //采购订单编辑：反写源单合同订单的已采购数量和未采购数量
                if($module == 'PurchaseOrder' && $inventoryProductValue['entitytype'] == 'SalesOrder' && $inventoryProductValue['entitytypeid'] > 0){
                    //更新产品库存数量
                    if($update_prod_stock == 'true'){
                        addToProductStock($inventoryProductValue['productid'],$inventoryProductValue['quantity']);
                    }

                }
                $version_info = getVersionInfo();
                //if(in_array($version_info['account'],array('yuwang',''))){
                if(!empty($_REQUEST['erpentryid'.$rowid])){

                    $inventoryProductValue['erpentryid'] = $_REQUEST['erpentryid'.$rowid];
                }else{
                    // @edit:dong @date:2023/05/15 @reason: 通过before_lineitem_id 的值获取保存前的erp分录id
                    $inventoryProductValue['erpentryid'] = $before_db_value[$_REQUEST['before_lineitem_id'.$rowid]]['erpentryid'];
                }
                //}
                //插入产品明细表


                $inventoryProductsKeys = !empty($inventoryProductValue)?array_keys($inventoryProductValue):[];	//返回所有键名
                $inventoryProductsValues = array_values($inventoryProductValue);	//返回所有键值
                $inventoryValueArr=array();//重新初始化数组
                foreach($inventoryProductsValues as $key => $value){
                    $inventoryValueArr[$key]= $value;

                    $FieldInfo=new ProductFields();
                    $FieldInfo->setcolumnName($inventoryProductsKeys[$key]);
                    $FieldInfo->setColumn_Value($value);
                    $focus->after_detail_info[0][$inventoryProductsKeys[$key]]=$FieldInfo;//获取保存后产品明细的值
                    //print_r($focus->after_detail_info);die;
                }

                $query='insert into '. $Detail_table.' ('.implode(',', $inventoryProductsKeys).') values ('.generateQuestionMarks($inventoryValueArr).')';
                $adb->pquery($query,array($inventoryProductValue));
                $lineitem_id = $adb->getLastInsertID();
                if($inventoryProductValue['is_present'] === 'yes') {
                    $presentRowInfo[$lineitem_id] = $_REQUEST['present'.$rowid];
                }
                if($module == 'CashBill'||$module == 'SendCashBill'){
                    $query = "update $Detail_table set lineitem_id =? where ".$focus->Detail_table_id."=$lineitem_id";
                    $adb->pquery($query,array($lineitem_id));
                }
                // }
                //记录新旧lineitem_id用于保存修改日志
                if($_REQUEST['before_lineitem_id'.$rowid]>0){
                    $detail_id = $_REQUEST['before_lineitem_id'.$rowid];
                    $new_lineitemid_arr[$detail_id] = $lineitem_id;
                }else{
                    $new_lineitemid_arr[$lineitem_id] = $lineitem_id;
                    $detail_id = $lineitem_id;
                }
                if(is_array($inventoryscfProductValue)&&sizeof($inventoryscfProductValue)>0){
                    $all_detailvalue[$detail_id] = array_merge($inventoryProductValue,$inventoryscfProductValue);
                }else{
                    $all_detailvalue[$detail_id] = $inventoryProductValue;
                }
                //插入产品自定义表
                $tmparr=$inventoryProductValue;

                foreach($inventoryscfProductValue  as $tmpkey=>$tmpvalue)
                {
                    $tmparr[$tmpkey]=$tmpvalue;
                }

                $aftersavedetailfieldvalue_arr[]=$tmparr;

                $inventoryscfProductsKeys = array_keys($inventoryscfProductValue);	//返回所有键名
                $inventoryscfProductsValues = array_values($inventoryscfProductValue);	//返回所有键值
                $inventoryscfValueArr = array();
                $inventoryscfValueArr[] = $lineitem_id;
                $inventoryscfValueArr[] = $rowid;
                foreach($inventoryscfProductsValues as $key => $value){
                    $inventoryscfValueArr[] = $value;

                }
                $ld_inventoryproductrelscf_field = array();
                $ld_inventoryproductrelscf_field[]=(empty($focus->Detail_table_id))?'lineitem_id':$focus->Detail_table_id;
                $ld_inventoryproductrelscf_field[]='sequence';
                if(!empty($inventoryscfProductsKeys)){
                    foreach($inventoryscfProductsKeys as $field_name){
                        $ld_inventoryproductrelscf_field[] = $field_name;
                    }
                }
                $query=' insert into '.$Detail_table_scf.'('.implode(',', $ld_inventoryproductrelscf_field).') 
							values ('.generateQuestionMarks($inventoryscfValueArr).')';
                $adb->pquery($query,array($inventoryscfValueArr));
                if($module == 'CashBill'||$module == 'SendCashBill'){
                    $query = "update ".$Detail_table_scf." set lineitem_id =$lineitem_id where ".$focus->Detail_table_id."=$lineitem_id";
                    $adb->pquery($query,array());
                }

                //echo $query;echo '<br><br>';die;

                //记录行数与lineitem_id的关系
                $new_lineitemid[$rowid] = array('new_lineitemid'=>$lineitem_id,'old_lineitemid'=>$_REQUEST['before_lineitem_id'.$rowid]);
                /**
                 * @edit:chj
                 * @date:2014-10-9
                 * @reason:更改与当前由于关联的源单模块对应产品的parent_lineitem_id的值
                 * @description:因为编辑修改产品适，当行产品的line_item_id会改变，这样会导致以前与该有关联的原单的parent_lineitem_id对应不上
                 */

                if(isset($beforeproduct)){

                    if(isset($_REQUEST['before_lineitem_id'.$rowid])){
                        foreach($beforeproduct as $before_lineitem_id => $before_productid){
                            if(($_REQUEST['before_lineitem_id'.$rowid] == $before_lineitem_id && $_REQUEST['hdnProductId'.$rowid] == $before_productid)
                                ||( get_versiontrade() == 'construction' && $focus->table_name=='CustomForm14' &&$_REQUEST['before_lineitem_id'.$rowid] == $before_lineitem_id))
                            {

                                if(is_array($havecursourcemodules)&&!empty($havecursourcemodules))
                                {

                                    foreach($havecursourcemodules as $tmphavesourcemodule)
                                    {
                                        if($module_count_arr[$tmphavesourcemodule] <=0){
                                            continue;
                                        }
                                        $tmphavesourcefocus=CRMEntity::getInstance($tmphavesourcemodule);

                                        $adb->pquery('update '.$tmphavesourcefocus->Detail_table .'
													  set parent_lineitem_id = ? where parent_lineitem_id = ? and entitytypeid = ?',array($lineitem_id,$_REQUEST['before_lineitem_id'.$rowid],$focus->id));
                                        //工单管理模块需要更新特殊分录的lineitem_id
                                        if($tmphavesourcemodule=='WorkSheet'){
                                            $adb->pquery('update '.$tmphavesourcefocus->SpecialDetailTable .'
														  set parent_lineitem_id = ? where parent_lineitem_id = ? and entitytypeid = ?',array($lineitem_id,$_REQUEST['before_lineitem_id'.$rowid],$focus->id));
                                        }
                                    }
                                }
                                break;
                            }
                        }
                    }
                }

                //反写单据的contractid 合同信息
                $tmpsource_contractid=0;
                if(!empty($inventoryProductValue['entitytype']) && !empty($inventoryProductValue['entitytypeid'])){
                    if($inventoryProductValue['entitytype'] == 'PurchaseOrder' || $inventoryProductValue['entitytype'] == 'ServiceContracts' || $inventoryProductValue['entitytype'] == 'SalesOrder'){

                        $tmpsource_contractid=$inventoryProductValue['entitytypeid'];

                    }
                    else
                    {
                        $sourceentityfocus=CRMEntity::getInstance($inventoryProductValue['entitytype']);

                        if(!in_array($inventoryProductValue['entitytypeid'],$tmpsource_contractids))
                        {
                            //0041669: （61mis.com/kfbcrm）销售发票模块>选择单据编号为“INV125 ”进入明细界面：产品分录“合同信息”字段，只带出一个源单信息，（源单“出库单”关联三个合同）
                            //20200703 ls  解决：ld_invoicedetail表的parent_lineitem_id关联ld_outboundorderdetail表的lineitem_id，所以添加 and lineitem_id = 条件查询才对。
                            $tmpsourcesql='select parent_lineitem_id,lineitem_id,entitytype,entitytypeid from '.$sourceentityfocus->Detail_table.' where id ='.$inventoryProductValue['entitytypeid'].' and (entitytype="SalesOrder" or entitytype="ServiceContracts" or entitytype="PurchaseOrder") and lineitem_id = ?';
                            $tmpsourceresult=$adb->pquery($tmpsourcesql,array($_REQUEST['lineitem_id'.$rowid]));
                            if($adb->num_rows($tmpsourceresult)>0)
                            {
                                $tmpsource_contractid=$adb->query_result($tmpsourceresult,0,'entitytypeid');
                            }
                        }
                        else
                        {
                            $tmpsource_contractid=$tmpsource_contractids[$inventoryProductValue['entitytypeid']];
                        }

                    }
                }
                if($Detail_table!='ld_salesorderdetail')
                    $adb->pquery('update '. $Detail_table.' set contractid = ? where '. $Detail_table_id.' = ? ',array($tmpsource_contractid,$lineitem_id));
                //单据分录字段权限控制问题
                if(!empty($user_noprofile_fields_dbvalue) && $beforeproduct){
                    $update_fields = array();
                    if(isset($_REQUEST['before_lineitem_id'.$rowid])){

                        $before_lineitem_id = $_REQUEST['before_lineitem_id'.$rowid];
                        if(!empty($user_noprofile_fields_dbvalue[$before_lineitem_id]) && isset($beforeproduct[$before_lineitem_id])){

                            foreach($user_noprofile_fields_dbvalue[$before_lineitem_id]['fields'] as $columnanme => $value){
                                if(!empty($value)){
                                    $update_fields[]= $columnanme .'="'.$value . '"';
                                }
                            }
                            if($user_noprofile_fields_dbvalue[$before_lineitem_id]['productid'] == $beforeproduct[$before_lineitem_id]){

                                $adb->pquery('update '.$Detail_table .'
												LEFT JOIN '.$Detail_table_scf." on $Detail_table.$Detail_table_id = $Detail_table_scf.$Detail_table_id 
												set " . implode(',',$update_fields) . " 
												where $Detail_table.$Detail_table_index = ? and $Detail_table.$Detail_table_id = ? and $Detail_table.productid = ?",array($focus->id,$lineitem_id,$user_noprofile_fields_dbvalue[$before_lineitem_id]['productid']));
                            }
                        }
                    }
                }
                //销售内勤修改订单,将订单产品分录中对应产品的"出厂编号"赋值,保存后需要将这个"出厂编号"传到产品管理模块对应的产品基础信息的"出厂编号"字段中.
                if($module == 'SalesOrder' && get_versiontrade() == 'yangduan'){
                    if(!empty($_REQUEST['out_number' . $rowid]) && !empty($inventoryProductValue['productid'])){
                        $update_products_out_numbser = 'update ld_products set out_number = ? where productid = ?';
                        $adb->pquery($update_products_out_numbser,array($_REQUEST['out_number' . $rowid],$inventoryProductValue['productid']));
                    }
                }
                $batchtext=$_REQUEST['batchtext'.$rowid];
                if(!empty($batchtext) && trim($batchtext)=='')
                {
                    $batchtext=DEFAULTBATCHTEXT;
                }
                /**
                 * edit:chj
                 * date:2014-7-28
                 * reason:灵当CRM详细需求-参数控制出入库单更新库存流水记录触发点  0：审核  1：保存
                 **/
                if($module == 'OutboundOrder' || $module == 'Stock'||$module=='Checks'||$module=="SalesBack"){
                    $deployarray=getSys_deploy(48);
                    if($deployarray['deploy_value']== 1){	//保存
                        $batch_productid_arr[] = $inventoryProductValue['productid'];
                        if($num_rows <=0 || isset($_REQUEST['duplicate_from'])){	//新增

                            //insertCondtion($batchtext,$inventoryProductValue['id'],$var,$focus->column_fields['wareid'],$inventoryProductValue['productid'],$module,$focus->column_fields['assigned_user_id'],$inventoryProductValue['quantity'],0,$inventoryProductValue['parent_lineitem_id'],$lineitem_id);
                        }
                        else	//编辑
                        {
                            /**
                             * 编辑单据时修改仓库做出处理
                             * 出库单：产品出库、入库单：产品入库
                             * 原单据产品在下面代码中处理，全部退货
                             * @project PROT89 库存流水账逻辑修改
                             * @author Tujt 2014-08-25
                             */
                            if($isupdateware > 0){//$isupdateware即原仓库ID

                                //insertCondtion($batchtext,$inventoryProductValue['id'],$var,$focus->column_fields['wareid'],$inventoryProductValue['productid'],$module,$focus->column_fields['assigned_user_id'],$inventoryProductValue['quantity'],0,$inventoryProductValue['parent_lineitem_id'],$lineitem_id);
                            }else{//未修改仓库情况
                                if(isset($beforeproductdetail[$inventoryProductValue['productid']])
                                    &&isset($beforeproductdetail[$inventoryProductValue['productid']][$batchtext])&&$_REQUEST['hidden_lineitem_id'.$rowid]>0){

                                    //insertCondtion($batchtext,$inventoryProductValue['id'],$var,$focus->column_fields['wareid'],$inventoryProductValue['productid'],$module,$focus->column_fields['assigned_user_id'],$inventoryProductValue['quantity'],$beforeproductdetail[$inventoryProductValue['productid']],$inventoryProductValue['parent_lineitem_id'],$lineitem_id);
                                }else{//如果$beforeproductdetail不存在这个产品

                                    //insertCondtion($batchtext,$inventoryProductValue['id'],$var,$focus->column_fields['wareid'],$inventoryProductValue['productid'],$module,$focus->column_fields['assigned_user_id'],$inventoryProductValue['quantity'],0,$inventoryProductValue['parent_lineitem_id'],$lineitem_id);
                                }
                            }
                        }

                    }
                }
                $nowproductdetail[$_REQUEST['hidden_lineitem_id'.$rowid]] = $qty;

                /*if($module=='SalesOrder'&&$_REQUEST['before_lineitem_id'.$rowid]>0){//编辑

                    //已退货数量
                    $salesbacksql = "select ifnull(sum(quantity),0) as quantity from ld_salesbackdetail
                    inner join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id
                    where ld_salesback.deleted = 0 and ld_salesback.salesorderid = ? and ld_salesbackdetail.productid = ? and ld_salesback.salesbackstatus not in ('未入库','中止')";
                    $result = $adb->pquery($salesbacksql,array($focus->id,$inventoryProductValue['productid']));
                    $salesbacknum = $adb->query_result($result,0,0);
                    $sql=" select sum(ifnull(quantity,0)) from ld_outboundorderdetail
                    inner join ld_outboundorder on  ld_outboundorder.out_id=ld_outboundorderdetail.id
                    where entitytypeid=? and parent_lineitem_id=? and ld_outboundorder.deleted=0
                    group by entitytypeid,parent_lineitem_id ";
                    $salesqtyresult=$adb->pquery($sql,array($focus->id,$lineitem_id));
                    if($adb->num_rows($salesqtyresult)>0){
                        $totalhaveoutbound=$adb->query_result($salesqtyresult,0,0);
                        $sql='update ld_salesorderdetail  set haveoutproductcount=?,balanceoutproductcount=? where id=? and lineitem_id=?';
                        $adb->pquery($sql,array($totalhaveoutbound,$inventoryProductValue['quantity']-$totalhaveoutbound+$salesbacknum,$focus->id,$lineitem_id));
                    }

                }*/
                //机床状态自动取值：订单保存时，产品分录字段"入库日期"第一次有值时，自动变更产品分录的字段"机床状态"为“已入库”，后期订单保存时不再更新；
                if(get_versiontrade() == 'yangduan'){
                    if($_REQUEST['before_lineitem_id'.$rowid] > 0){	//编辑
                        $yd_before_lineitem_id = $_REQUEST['before_lineitem_id'.$rowid];
                        $sf1105 = $yd_before[$yd_before_lineitem_id];
                        if(($sf1105 == '' || $sf1105 == '0000-00-00') && !empty($_REQUEST['sf1105'.$rowid]) && $_REQUEST['sf4650'.$rowid] == '在制'){
                            $query = " update $Detail_table_scf set sf4650 = '已入库' where lineitem_id = ?";
                            $adb->pquery($query,array($lineitem_id));
                        }
                    }else{
                        if(!empty($_REQUEST['sf1105'.$rowid]) && $_REQUEST['sf4650'.$rowid] == '在制'){
                            $query = "update $Detail_table_scf set sf4650 = '已入库' where lineitem_id = ?";
                            $adb->pquery($query,array($lineitem_id));
                        }
                    }
                }

                if($module == 'SalesOrder' && get_versiontrade() == 'yangduan'){
                    foreach($ProductToolFieldsInfo as $columnname => $fieldInfo){
                        //uitype = 70产品名称

                        if($fieldInfo->getUIType() == 70){
                            $new_values['productid'] = $_REQUEST['hdnProductId'.$rowid];
                        }else{
                            $new_values[$columnname] = $_REQUEST[$columnname.$rowid];
                        }
                    }
                    $before_lineitem_id = $_REQUEST['before_lineitem_id'.$rowid];
                    if($before_lineitem_id > 0 && !empty($before_db_value[$before_lineitem_id])){
                        foreach($ProductToolFieldsInfo as $columnname => $fieldInfo){
                            if($fieldInfo->getUIType() == 70){
                                $columnname = 'productid';
                            }

                            if($before_db_value[$before_lineitem_id][$columnname] != $new_values[$columnname]){
                                $insert_log = 'insert into ld_productdetail_log(record,lineitem_id,columnname,old_value,new_value,creator,createdtime) value (?,?,?,?,?,?,?)';
                                $adb->pquery($insert_log,array($focus->id,$lineitem_id,$columnname,$before_db_value[$before_lineitem_id][$columnname],$new_values[$columnname],$current_user->id,date('Y-m-d h:i:s')));
                            }
                        }
                    }else{
                        foreach($ProductToolFieldsInfo as $columnname => $fieldInfo){
                            if($fieldInfo->getUIType() == 70){
                                $columnname = 'productid';
                            }
                            $insert_log = 'insert into ld_productdetail_log(record,lineitem_id,columnname,old_value,new_value,creator,createdtime) value (?,?,?,?,?,?,?)';
                            $adb->pquery($insert_log,array($focus->id,$lineitem_id,$columnname,'',$new_values[$columnname],$current_user->id,date('Y-m-d h:i:s')));
                        }
                    }
                }
                $sequence_no++;
            }
            $rowid++;
        }while($rowid <= $rowcnt);
        $focus->savedetailfield_arr=[];//前端request的字段，目前是供主表字段公式使用
        $focus->savedetailfield_arr= array_merge($focus->savedetailfield_arr,$inventoryProductsKeys);
        if(is_array($inventoryscfProductsKeys))
        {
            $focus->savedetailfield_arr= array_merge($focus->savedetailfield_arr,$inventoryscfProductsKeys);
        }
        $focus->aftersavedetailfieldvalue_arr=$aftersavedetailfieldvalue_arr;

        //   dump($focus->savedetailfield_arr);
        //采购订单编辑   更新编辑前的源单的已采购状态-已采购、未采购数量
        if($module == 'PurchaseOrder' && $focus->mode == 'edit'){
            crm_load_class_file('cls_InPurchase_InverseCompute','include/OptionModule');
            foreach($beforeentitytypeid as $entitytypeid){
                cls_InPurchase_InverseCompute::updateSalesOrder_purchasestatus($entitytypeid);
            }
        }
        else if($focus->mode == 'edit') {
            //放在函数的最下面，等待主表更新total字段更新完成
            crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');

            foreach($focus->before_sourcemodule_info as $index=>$info)
            {
                if($info['entitytypeid']<=0)
                    continue;
                if(is_array($entitytypeids) && in_array($info['entitytypeid'],$entitytypeids))
                    continue;
                //编辑界面更改原单
                //37541: （1.6）合同订单、服务合同、出库单、入库单模块、采购订单：关联创建销售发票保存后，修改发票的源单后保存会导致关联的合同已开票金额不对。（需要补丁
                cls_Source_InverseCompute::Source_InveverseCompute($info['entitytype'],$info['entitytypeid'],$focus);
            }
        }

        if(vtlib_isModuleActive('PricePolicy') && $module !== 'Productbom') {
            crm_load_class_file('PricePolicyBlock','modules/PricePolicy');
            $policyBlockObj = new PricePolicyBlock($module);
            $policyBlockObj->saveSelectedPolicy($_REQUEST['selectedPolicy'], $presentRowInfo);
        }

        //保存图片
        $this->insertIntoImage($focus,$module,$new_lineitemid);
        
        //保存单据修改日志
        $this->saveProductDetailslog($focus,$before_db_value,$new_lineitemid_arr,$all_detailvalue);

        //duan 20240408 把重算库存数量移到保存之后
        if(count($batch_productid_arr)>0){
            $batch_productid_arr = array_unique($batch_productid_arr);
            foreach ($batch_productid_arr as $tmp_productid){
                insertProductQty($tmp_productid,0,1);
            }
        }


        //济凡生物科技：产品最低售价
        if($module == 'SalesOrder' && get_versionaccount()=='jifan'){
            $focus->updateSalesOrderFDownPrice($focus->id);
        }
        //更新主表

        foreach($ProductToolFieldsInfo as $FieldInfo){
            $columnname = $FieldInfo->getColumnName();
            $columnname_value = $_REQUEST[$columnname] ?? '';
            if($FieldInfo->getTableName() == $moduleTableName){
                //整单折扣
                if($FieldInfo->getUIType() == 37){
                    if($_REQUEST['allSingledDiscount'] == '-'||$_REQUEST['allSingledDiscount'] == '+'){
                        $discount_type=0;
                        $discount_amount=$columnname_value;
                        if($_REQUEST['subtotal']==0)
                        {
                            $discount_percent=0;
                        }
                        else
                            $discount_percent=$discount_amount/$_REQUEST['subtotal']*100;
                        $moduleFieldValue[$columnname]=$discount_amount;
                        $moduleFieldValue['discount_type']=$discount_type;
                        $moduleFieldValue['discount_percent']=$discount_percent;
                    }
                    else{
                        $discount_type=1;
                        $discount_percent=$columnname_value;
                        $discount_amount=$_REQUEST['subtotal']*($discount_percent/100);
                        $moduleFieldValue[$columnname]=$discount_amount;
                        $moduleFieldValue['discount_type']=$discount_type;
                        $moduleFieldValue['discount_percent']=$discount_percent;
                    }
                }
                //调整
                elseif($FieldInfo->getUIType() == 35 && $_REQUEST['adjustmentType'] == '-'){
                    $moduleFieldValue[$columnname] = 0-$columnname_value;
                }
                else{
                    $moduleFieldValue[$columnname]=$columnname_value;
                }
            }
        }

        // print_r($moduleFieldValue);
        $moduleFieldKeys = [];
        foreach($moduleFieldValue as $key => $fieldvalue){
            if($fieldvalue=='' || $fieldvalue == 'undefined' || $fieldvalue == 'NaN')
            {
                //edit:can 2020-11-06 43147: (120.76.102.171:86/crm)销售管理-合同订单（顺通达客户问题）；选择任意一个单据，编辑；将单据分录下的调整方式改为减少，输入减少的金额保存后，单据列表中合计没有变化。
                $fieldvalue=0;
            }
            $moduleFieldKeys[$key] = $key .'='.$fieldvalue;
        }
        /*
        *edit: chj
        *date: 2020/8/4
        *reason: 当个人用户没有单据主表字段权限的时候，update失效
        *
        */

        //edit:can 2020-10-16 没有合计字段的权限	//if(empty($moduleFieldKeys)&&array_key_exists("total",$ProductToolFieldsInfo)){
        //edit:chj 带分录的表单“合计”字段增加隐藏功能（苏宁）
        if(empty($moduleFieldKeys['total'])&&!array_key_exists('tax_amount',$user_noprofile_fields)){
            $AllProductToolFieldsInfo = $ProductToolFields->getAllToolFields($tabid,$languageType);
            if(!empty($AllProductToolFieldsInfo) && array_key_exists("total",$AllProductToolFieldsInfo)){
                $moduleFieldKeys['total'] = 'total='.$total;
            }
        }
        //echo $focus->id;
        //  echo 'update '.$moduleTableName.' set '.implode(',',$moduleFieldKeys).' where '.$moduleTableId;die;
//        dump('update '.$moduleTableName.' set '.implode(',',$moduleFieldKeys).' where '.$moduleTableId.' = ?');
        if(sizeof($moduleFieldKeys)>0)
            $adb->pquery('update '.$moduleTableName.' set '.implode(',',$moduleFieldKeys).' where '.$moduleTableId.' = ?',
                array($focus->id));
        // dump($moduleFieldKeys);
        //dump('update '.$moduleTableName.' set '.implode(',',$moduleFieldKeys).' where '.$moduleTableId.' = ?');
        //zkt 20240625 BUG20240625-17  收款计划二次编辑后，应收余额不变，需要二次进行编辑保存
        if($module == 'CashBill'||$module == 'SendCashBill'){
            //收付款单反写源单产品已收总额、已付总额
            if(!empty($entitytypeids)){
                $before_sourcemodule_info_arr = $focus->before_sourcemodule_info;
                $before_entitytypeid_arr = [];
                foreach($before_sourcemodule_info_arr as $tmp_before_sourcemodule_info){
                    $before_entitytypeid_arr[] = $tmp_before_sourcemodule_info['entitytypeid'];
                }
                $sourcemdoulename = getSalesEntityType($entitytypeids[0]);
                $focus->updateSourceInfo($entitytypeids,$sourcemdoulename);
                $tmp_entitytypeid_arr = array_unique(array_merge($before_entitytypeid_arr,$entitytypeids));//保存前后所有的entitytypeid的值

                if($before_sourcemodule_info_arr[0] != $sourcemdoulename&&!empty($before_entitytypeid_arr)){
                    $focus->updateSourceDetailamout($tmp_entitytypeid_arr,$before_sourcemodule_info_arr[0]['entitytype']);
                    $focus->updateSourceMainamount($tmp_entitytypeid_arr,$before_sourcemodule_info_arr[0]['entitytype']);
                }
                $focus->updateSourceDetailamout($tmp_entitytypeid_arr,$sourcemdoulename);
                $focus->updateSourceMainamount($tmp_entitytypeid_arr,$sourcemdoulename);
            }

        }
        else {
            //计算当前模块应收应付金额


            $cashbill_focus = CRMEntity::getInstance('CashBill');
            $cashbill_focus->updateSourceDetailamout(array($focus->id),$focus->module_name);
            $cashbill_focus->updateSourceMainamount(array($focus->id),$focus->module_name);
            $sendcashbill_focus = CRMEntity::getInstance('SendCashBill');
            $sendcashbill_focus->updateSourceDetailamout(array($focus->id),$focus->module_name);
            $sendcashbill_focus->updateSourceMainamount(array($focus->id),$focus->module_name);

        }
        
        return ['subtotal'=>$subtotal];
    }






    //保存产品分录修改日志
    public  function saveProductDetailslog($focus,$before_db_value,$new_lineitem_arr,$after_request_value){
        global $adb,$current_user,$weixin_user;

        $record = $focus->id;
        $module = $focus->module_name;
        $tabid = getTabid($module);
        $languageType= getLanguageType($current_user);
        $char = 'V';
        //分录表名和主键
        $Detail_table=$focus->Detail_table;
        $Detail_table_scf=$focus->Detail_table_scf;
        $Detail_table_id=$focus->Detail_table_id;
        $Detail_table_index=$focus->Detail_table_index;
        //分录字段信息
        $ProductToolFields = ProductToolFields::getInstance($module);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);

        $rowcnt = $_REQUEST['rowcnt'];
        $lineitem_arr = array();
        $changetype_arr = array();
        $save_newlog = 'no';

        foreach($ProductToolFieldsInfo as $fieldInfo){
            $columnname = $fieldInfo->getColumnName();
            $tablename = $fieldInfo->getTableName();

            //uitype = 70产品名称
            if($fieldInfo->getUIType() == 70){
                $productdetail_columns[] = 'productid';
            }

            //允许编辑和有字段公式的自定义字段都可以保存到数据库里
            if($fieldInfo->getSaveDataBase() == 'yes' || ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid' || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
                if(strtolower($tablename) == $Detail_table||strtolower($tablename) ==$Detail_table_scf){
                    $productdetail_columns[] = $columnname;
                    $productdetail_column_sql[] =  $tablename. '.' . $columnname;
                }
            }
        }




        if($focus->mode == 'edit'){
            $rowid = 1;
            $before_db_key_arr = array_keys($before_db_value);
            foreach($after_request_value as $lineitem_id => $request_detailinfo){
                $type = 'same';
                if(isset($before_db_value[$lineitem_id])){
                    $db_detailinfo = $before_db_value[$lineitem_id];
                }else{
                    if(isset($before_db_key_arr[$rowid-1])&&isset($before_db_value[$before_db_key_arr[$rowid-1]])){
                        $db_detailinfo = $before_db_value[$before_db_key_arr[$rowid-1]];
                    }else{
                        $db_detailinfo = array();
                    }
                }

                $row_change = 'no';
                if(is_array($db_detailinfo)&&sizeof($db_detailinfo)>0){
                    $is_arr = 'yes';
                }else{
                    $is_arr = 'no';
                }

                //移动端返回值中缺少entitytypeid
                if(!empty($weixin_user)&&$_REQUEST['lineitem_id'.$rowid]&&!empty($request_detailinfo['entitytype'])){
                    $info = getLineitemModuleInfo($_REQUEST['lineitem_id'.$rowid],$request_detailinfo['entitytype']);
                    $after_request_value[$lineitem_id]['entitytypeid'] = $info['id'];
                }else{
                    if(!isset($after_request_value[$lineitem_id]['entitytype'])||empty($after_request_value[$lineitem_id]['entitytype']))
                        $after_request_value[$lineitem_id]['entitytype']='';
                    if(!isset($after_request_value[$lineitem_id]['entitytypeid'])||empty($after_request_value[$lineitem_id]['entitytypeid']))
                        $after_request_value[$lineitem_id]['entitytypeid']='';
                }

                foreach($request_detailinfo as $columnname=>$commonvalue){
                    if(!in_array($columnname,$productdetail_columns)){
                        unset($after_request_value[$lineitem_id][$columnname]);
                        continue;
                    }
                    //产品id字段保存的是productname需要特殊判断
                    if($columnname == 'productid' && $commonvalue != $db_detailinfo[$columnname]){
                        $save_newlog = 'yes';
                        $row_change = 'yes';
                        $type = 'change';
                    }
                    //将每一行的值与数据库中的值相比较
                    $fieldinfo = $ProductToolFields->getFieldInfoobjBykey('columnname',$columnname);
                    if(empty($fieldinfo)){
                        continue;
                    }
                    $bigtype = $fieldinfo->getBigType();
                    //移动端分录单选框特殊处理
                    if(!empty($weixin_user)&&$bigtype =='boolean'){
                        if($commonvalue=='否'||$commonvalue==''||$commonvalue==0){
                            $commonvalue = 0;
                        }else{
                            $commonvalue = 1;
                        }
                        $after_request_value[$lineitem_id][$columnname] = $commonvalue;
                    }

                    //关联选择单据特殊处理
                    if($bigtype == 'reference'){
                        if(empty($commonvalue)){
                            $commonvalue = 0;
                        }
                    }
                    //BUG0068689 xxy 2023-9-28 报价单-修改单据，单据分录的修改日志不论修不修改都会被保存
                    if($columnname == 'entitytypeid'){//entitytypeid的commonvalue为0，但数据库里是空，导致一直判定为修改过分录
                        if($commonvalue == 0){
                            $commonvalue = '';
                        }
                    }

                    // 附件图片修改日志
                    if($bigtype == 'fileattachment' || $bigtype == 'image'){
                        $commonvalue = '';
                        $fieldname = $fieldinfo->getFieldName();
                        $cur_new_lineitem_id = $new_lineitem_arr[$lineitem_id];// 当前行新的lineitem_id
                        $all_attachment_img_logs_arr = $focus->modstatic->getAttachmentImgLogs();
                        if(!empty($all_attachment_img_logs_arr)){
                            $cur_attachment_img_logs_arr = $all_attachment_img_logs_arr['detail'][$fieldname.'_'.$cur_new_lineitem_id];
                            if(!empty($cur_attachment_img_logs_arr)){
                                if(!empty($cur_attachment_img_logs_arr['prevalue']) && !empty($cur_attachment_img_logs_arr['postvalue'])){
                                    $attachment_prevalue_arr = $cur_attachment_img_logs_arr['prevalue']['attachmentsid_arr']??[];
                                    $attachment_postvalue_arr = $cur_attachment_img_logs_arr['postvalue']['attachmentsid_arr']??[];
                                    $attachment_prevalue_str = implode(',',$attachment_prevalue_arr);
                                    $attachment_postvalue_str = implode(',',$attachment_postvalue_arr);
                                    $before_db_value[$lineitem_id][$columnname] = $attachment_prevalue_str;
                                    $after_request_value[$lineitem_id][$columnname] = $attachment_postvalue_str;
                                    // getAttachmentImgLogs 函数获取的附件日志信息是已经判断过是否编辑过的
                                    if($cur_attachment_img_logs_arr['postvalue']['save_newlog'] == 'yes'){
                                        $save_newlog = 'yes';
                                        $row_change = 'yes';
                                        $type = 'change';
                                    }
                                }
                            }
                        }
                    }

                    if($row_change == 'yes'){
                        continue;
                    }else if($is_arr == 'yes'){
                        //将每一行的值与数据库中的值相比较
                        if($commonvalue != $db_detailinfo[$columnname]){
                            $save_newlog = 'yes';
                            $row_change = 'yes';
                            $type = 'change';
                        }
                    }else{
                        $save_newlog = 'yes';
                        $row_change = 'yes';
                        $type = 'create';
                    }
                }
                $rowid ++;
                $changetype_arr[$lineitem_id] = $type;
            }

            if(is_array($after_request_value) && sizeof($after_request_value)!=sizeof($before_db_value)){
                $save_newlog = 'yes';
            }
        }else{
            $save_newlog = 'yes';
        }

        //如果需要增加新版本
        if($save_newlog == 'yes'){
            //获取版本号
            $sql = 'select trackid_no from ld_detailtracker_basic where record = ?';
            $result = $adb->pquery($sql,array($record));
            $num_rows = $adb->num_rows($result);
            $trackid_no = $char.sprintf("%.1f",$num_rows+1);
            $datetime = date('Y-m-d H:i:s');
            if(isset($_REQUEST['total'])&&$_REQUEST['total']>0){
                $total = $_REQUEST['total'];
            }else if($module == 'CashBill'&&isset($_REQUEST['cashbill_total'])&&$_REQUEST['cashbill_total']>0){
                $total = $_REQUEST['cashbill_total'];
            }else if($module == 'SendCashBill'&&isset($_REQUEST['sendcashbill_total'])&&$_REQUEST['sendcashbill_total']>0){
                $total = $_REQUEST['sendcashbill_total'];
            }else{
                $total = 0;
            }
            //增加新版本
            $sql = 'insert into ld_detailtracker_basic(trackid_no,modulename,record,whodid,changedon,total) values(?,?,?,?,?,?)';
            $adb->pquery($sql,array($trackid_no,$module,$record,$current_user->id,$datetime,$total));
            //获取新增加的日志id
            $sql = 'select max(trackid) as trackid from ld_detailtracker_basic';
            $result = $adb->pquery($sql,array());
            $trackid = $adb->query_result($result,0,'trackid');
            $focus->trackId = $trackid;
            $rowid = 1;
            $before_db_key_arr = array_keys($before_db_value);

            foreach($new_lineitem_arr as $lineitem_id => $new_lineitem_id){
                if(sizeof($after_request_value[$lineitem_id])>0){
                    $after_json_info = ldcrm_json_encode($after_request_value[$lineitem_id]);
                }else{
                    $after_json_info = '';
                }

                if(isset($before_db_value[$lineitem_id])){
                    $db_detailinfo = $before_db_value[$lineitem_id];
                }else{
                    if(isset($before_db_key_arr[$rowid-1])&&isset($before_db_value[$before_db_key_arr[$rowid-1]])){
                        $db_detailinfo = $before_db_value[$before_db_key_arr[$rowid-1]];
                    }else{
                        $db_detailinfo = array();
                    }
                }
                if(is_array($db_detailinfo)&&sizeof($db_detailinfo)>0){
                    $before_json_info = ldcrm_json_encode($db_detailinfo);
                }else{
                    $before_json_info = '';
                }

                if($after_json_info==''){
                    continue;
                }
                if(empty($changetype_arr[$lineitem_id])){
                    $type = 'create';
                }else{
                    $type = $changetype_arr[$lineitem_id];
                }
                $rowid++;
                $sql = 'insert into ld_detailtracker_detail(trackid,crmid,lineitem_id,prevaluejson,postvaluejson,changetype) values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($trackid,$record,$new_lineitem_id,$before_json_info,$after_json_info,$type));

                //ls 20221231  XUQIU1000922：表单码-分录可编辑（产品分录日志）
                if ($_REQUEST['is_qrcode_expand'] == 'yes') {
                    $qrcodeid = $_REQUEST['qrcodeid'];
                    $wechatuserid = $_REQUEST['wechatuserid'];
                    //表单码分录修改日志
                    $query = 'insert into ld_qrcode_operatelog_detail(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
                    $adb->pquery($query,array($qrcodeid,$wechatuserid,$datetime,'submit',$trackid,$record));
                }

            }
        }else{
            foreach($new_lineitem_arr as $pre_lineitem=>$post_lineitem){
                if($pre_lineitem != $post_lineitem){
                    $sql = 'update ld_detailtracker_detail INNER JOIN ld_detailtracker_basic ON ld_detailtracker_basic.trackid = ld_detailtracker_detail.trackid
                             set lineitem_id = ? where modulename = ? and record = ? and lineitem_id=?';
                    $adb->pquery($sql,array($post_lineitem,$module,$record,$pre_lineitem));
                }
            }
        }
    }

    // ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型（保存产品分录明细“图片”字段）
    function insertIntoImage($focus,$module,$new_lineitemid=array())
    {
        global $adb,$current_user,$weixin_user,$upload_badext;
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        if (empty($new_lineitemid)) {
            return;
        }else if($_REQUEST['file'] == 'ListDetailEditSave'){
            foreach($new_lineitemid as $tmp_info){
                $sql = 'update ld_detailattachments set lineitem_id = ? where lineitem_id = ? and crmid = ?';
                $adb->pquery($sql,[$tmp_info['new_lineitemid'],$tmp_info['old_lineitemid'],$focus->id]);
            }
            return;
        }
        require_once(globalStatic::$root_directory.'include/ProductDetails/ProductToolFields.php');
        $languageType= getLanguageType($current_user);
        $tabid = getTabid($module);
        $ProductToolFields = ProductToolFields::getInstance($module);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);


        //    $detailfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey("uitype", 69);
        $detailfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",'image');
        //edit: xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（保存产品分录明细“附件”字段）
        $detailfieldinfo_file = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", 'fileattachment');
        if (!$detailfieldinfo && !$detailfieldinfo_file)//如果没有图片字段
        {
            return;
        }

        //hzx 移动端分录图片、附件字段
        // if($weixin_user->environment_weixin){//移动端分录图片字段暂时没做，删除动作需要处理
        //     foreach ($new_lineitemid as $lineitemid_arr) {//更新图片字段的lineitem_id
        //         $adb->pquery("update ld_detailattachments set lineitem_id=? where lineitem_id=?", array($lineitemid_arr['new_lineitemid'],$lineitemid_arr['old_lineitemid']));
        //     }
        //     return;
        // }

        if($focus->mode == 'edit'){
            // 记录编辑前的附件信息
            $att_select_sql = "SELECT id,lineitem_id,newfile_name,columnname from ld_detailattachments where crmid = ? ";
            $att_select_result = $adb->pquery($att_select_sql,array($focus->id));
            $num_rows = $adb->num_rows($att_select_result);
            $prevalue_attachmentlogsinfo_arr = [];
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $attachmentsid = $adb->query_result($att_select_result, $i, 'id');
                    $lineitem_id = $adb->query_result($att_select_result, $i, 'lineitem_id');
                    $newfile_name = $adb->query_result($att_select_result, $i, 'newfile_name');
                    $columnname = $adb->query_result($att_select_result, $i, 'columnname');

                    $tabdetail_fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);

                    if(!empty($tabdetail_fieldinfo)){
                        $fieldname = $tabdetail_fieldinfo->getFieldName();
                        // $cur_new_lineitem_id = $new_detailid_arr[$lineitem_id];
                        $prevalue_attachmentlogsinfo_arr[$fieldname][$lineitem_id][$attachmentsid] = [
                            'attachmentsid' => $attachmentsid,
                            'newfile_name' => $newfile_name,
                        ];
                    }
                }
            }

            //编辑保存时，先删除分录明细表数据
            $adb->pquery("delete from ld_detailattachments where crmid=?", array($focus->id));
        }

        // 初始化附件图片日志信息数组
        $attachmentlogsinfo_arr = [];

        $rowid = 1;
        $rowcnt = $_REQUEST['rowcnt'];
        do {
            if (!empty($_REQUEST['hdnProductId' . $rowid]) && $_REQUEST['hidden_rowid_' . $rowid] == 0) {

                foreach ($ProductToolFieldsInfo as $columnname=>$fieldInfo) {
                    //                $columnname = $fieldInfo->getColumnName();
                    $tablename = $fieldInfo->getTableName();
                    $uitype = $fieldInfo->getUIType();
                    if (!($uitype == 69 || $uitype == 1109)) {
                        continue;
                    }
                    $fieldname = $fieldInfo->getFieldName();
                    $savedatabase = $fieldInfo->getSaveDataBase();
                    //wym XUQIU1002029 不保存数据库的分录引用附件字段跳过
                    if ($savedatabase=='no') {
                        continue;
                    }
                    // 附件图片prevalue初始化
                    $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['prevalue'] = [];
                    if($_REQUEST['mode'] == 'edit'){
                        if(!empty($prevalue_attachmentlogsinfo_arr) && !empty($prevalue_attachmentlogsinfo_arr[$fieldname][$new_lineitemid[$rowid]['old_lineitemid']])){
                            $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['prevalue'] = $prevalue_attachmentlogsinfo_arr[$fieldname][$new_lineitemid[$rowid]['old_lineitemid']];
                        }
                    }
                    $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['postvalue'] = [];
                    if ($_REQUEST[$fieldname.$rowid . '-file_num'] > 0) {
                        for ($i = 1; $i <= 220; $i++) {

                            $tmp_attachmentlogsinfo_arr = [];

                            $filename = $_REQUEST[$fieldname.$rowid . '-file_name_' . $i];    //附件名称
                            //
                            $filename = from_html(preg_replace('/\s+/', '_', (string)$filename));
                            $filename = FileFileterString($filename);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                            $filetype = $_REQUEST[$fieldname.$rowid . '-file_type_' . $i];    //附件类型
                            $filepath = $_REQUEST[$fieldname.$rowid . '-file_path_' . $i];    //附件路径

                            $filesize = $_REQUEST[$fieldname.$rowid . '-file_size_' . $i];    //附件大小
                            $newfile_name = $_REQUEST[$fieldname.$rowid . '-newfile_name_' . $i];    //附件在服务器上名称

                            //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
                            $isEncrypt = $_REQUEST[$fieldname.$rowid. '-isEncrypt_'.$i];	//是否加密
                            $filepath = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($filepath) : $filepath;
                            $newfile_name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($newfile_name) : $newfile_name;

                            $newfile_name = FileFileterString($newfile_name);//edit:can 20200824 上传文件的特殊字符过滤和安全性检测
                            $newfile_name = str_replace("&", "_", (string)$newfile_name);

                            $cloud_path = $_REQUEST[$fieldname.$rowid . '-cloud_path_' . $i];    //附件路径
                            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;

                            //editor:gyq_20190326 reason:小程序附件记录上传方式
                            $imagefromtype = $_REQUEST[$fieldname.$rowid . '-imagefromtype_' . $i];    //附件上传的方式
                            if (empty($imagefromtype)) $imagefromtype = 'Computer';
                            if ($filename == '' && $filesize <= 0.0001) {
                                //附件删除会有错误
                                continue;
                            }
                            //上传来源：PC端/小程序/企业微信/钉钉（pc/miniweixin/workweixin/dingtalk）
                            $upload_from = $_REQUEST[$fieldname .$rowid. '-upload_from_' . $i];
                            if (empty($upload_from) || $upload_from == 'undefined') {
                                $upload_from = '';
                            }
                            //文件存储位置:腾讯云存储桶/本地 （cos/local）
                            $storage_location = $_REQUEST[$fieldname.$rowid . '-storage_location_' . $i];
                            if (empty($storage_location) || $storage_location == 'undefined') {
                                $storage_location = 'local';
                                $cloud_path = '';
                            } elseif ($storage_location == 'cos') {
                                //给存储桶链接增加头，以便界面显示

                                $cloud_path = str_replace("http://", 'https://', $cloud_path);
                                if (stripos($cloud_path, 'https://') === false) {
                                    $cloud_path = 'https://' . $cloud_path;
                                }
                                //else{
                                //                        $cloud_path = $filepath;
                                //                    }

                                //删除文件临时表数据
                                //                            $this->deleteQcloudTempFile($newfile_name);
                            }

                            $binFile = sanitizeUploadFileName($filename, $upload_badext);
                            $filename = str_replace(" ", "_", $filename);
                            $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters

                            $sql1 = "insert into ld_detailattachments(crmid,lineitem_id,columnname,`name`,newfile_name, description, 
              `type`, path,`size`,imagefromtype,cloud_path,storage_location,upload_from) values(?,?, ?,?, ?, ?,?,?,?,?,?,?,?)";
                            $params1 = array($focus->id, $new_lineitemid[$rowid]['new_lineitemid'],$columnname,$filename, $newfile_name, "", $filetype, $filepath, $filesize,
                                $imagefromtype, $cloud_path, $storage_location, $upload_from);


                            $result = $adb->pquery($sql1, $params1);
                            $current_id=$adb->getLastInsertID();

                            //edit: xll 2023/06/26
                            $lineitemid_arr[$rowid]['old_lineitemid'] = $_REQUEST['before_lineitem_id'.$rowid];
                            $updateLog_sql = "update ld_fileoperationlog set lineitem_id=? where crmid=? and lineitem_id=? and newfile_name=?";
                            $adb->pquery($updateLog_sql, array($new_lineitemid[$rowid]['new_lineitemid'], $focus->id,$lineitemid_arr[$rowid]['old_lineitemid'], $newfile_name));

                            // 记录附件图片修改日志
                            $tmp_attachmentlogsinfo_arr['attachmentsid'] = $current_id;
                            $tmp_attachmentlogsinfo_arr['crmid'] = $focus->id;
                            $tmp_attachmentlogsinfo_arr['lineitem_id'] = $new_lineitemid[$rowid]['new_lineitemid'];
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
                            // 分录用 $fieldname_$lineitemid 来区分不同行同一个字段的内容
                            $attachmentlogsinfo_arr[$fieldname.'_'.$new_lineitemid[$rowid]['new_lineitemid']]['postvalue'][$current_id] = $tmp_attachmentlogsinfo_arr;

                            //百特，local则转存aws，已经是awsserver的不用处理。
                            if(getVersionInfo()['account']=='baxter' && $storage_location == 'local'){
                                crm_load_class_file('AWS', 'include');
                                $aws = AWS::getInstance();
                                if (file_exists($filepath.$newfile_name)) {
                                    $aws_path = 'crm/'.$aws->bucket . '/' . date('Y', time()) . '/' . date('m', time()) . '/';
                                    $cloud_path = $aws->uploadFileByPath($aws_path.$newfile_name,$filepath.$newfile_name);
                                    if (!empty($cloud_path)) {
                                        @unlink(globalStatic::$root_directory . $filepath . $newfile_name);
                                        $adb->pquery("update ld_detailattachments set path=?,storage_location=?,cloud_path=? where id=?",array($aws_path,'awsserver',$cloud_path,$current_id));
                                    }

                                }
                            }
                        }
                    }

                }
            }
            $rowid++;
        } while ($rowid <= $rowcnt);

        // 记录修改日志
        $focus->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'prevalue','detail');
        $focus->modstatic->saveAttachmentImgLogs($attachmentlogsinfo_arr,'postvalue','detail');

        if(!empty($focus->modstatic->getAttachmentImgLogs())){
			$focus->modstatic->insertAttachmentImgLogs('detail');
		}
    }


    //获取保存前的数据
    public function getbeforedetail($focus){
        global $adb,$current_user,$weixin_user;

        if($focus->mode !='edit'){
            return array();
        }

        $record = $focus->id;
        $module = $focus->module_name;
        $tabid = getTabid($module);
        $languageType= getLanguageType($current_user);
        $char = 'V';
        //分录表名和主键
        $Detail_table=$focus->Detail_table;
        $Detail_table_scf=$focus->Detail_table_scf;
        $Detail_table_id=$focus->Detail_table_id;
        $Detail_table_index=$focus->Detail_table_index;
        //分录字段信息
        $ProductToolFields = ProductToolFields::getInstance($module);
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);

        $before_db_value = array();
        $productdetail_column_sql = [];
        
        foreach($ProductToolFieldsInfo as $fieldInfo){
            $columnname = $fieldInfo->getColumnName();
            $tablename = $fieldInfo->getTableName();

            //uitype = 70产品名称
            if($fieldInfo->getUIType() == 70){
                $productdetail_columns[] = 'productid';
                $productdetail_column_sql[] =  'ld_products.productid';
            }

            $typeofdata = explode('~',$fieldInfo->getTypeOfData());
            //允许编辑和有字段公式的自定义字段都可以保存到数据库里
            if($fieldInfo->getSaveDataBase() == 'yes' || ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid' || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
                if(strtolower($tablename) == $Detail_table||strtolower($tablename) ==$Detail_table_scf){
                    $productdetail_columns[] = $columnname;
                    $productdetail_column_sql[] =  $tablename. '.' . $columnname;
                }
            }
        }

        //读取上一版本的数据
        $AllProductToolFieldsInfo = $ProductToolFields->getAllToolFields($tabid,$languageType);
        if(!empty($AllProductToolFieldsInfo) && array_key_exists("total",$AllProductToolFieldsInfo)){
            $productdetail_column_sql[] = $focus->table_name.'.total';
        }
        if(!empty($productdetail_column_sql) && $record>0){
            $productdetail_column_sql[] = $Detail_table.'.'.$Detail_table_id;
            $productdetail_column_sql[] = $Detail_table.'.parent_lineitem_id';
            $productdetail_column_sql[] = $Detail_table.'.erpentryid';
            $query = 'select ' . implode(',',$productdetail_column_sql) . ' from '.$Detail_table." 
    		LEFT JOIN $Detail_table_scf on $Detail_table_scf.$Detail_table_id = $Detail_table.$Detail_table_id 
    		LEFT JOIN ld_products on ld_products.productid = $Detail_table.productid 
    		LEFT JOIN ld_productcf on ld_productcf.productid = ld_products.productid 
    		LEFT JOIN ".$focus->table_name.' on '.$focus->table_name.'.'.$focus->table_index." = $Detail_table.$Detail_table_index
    		where $Detail_table.$Detail_table_index = ?";
            $result = $adb->pquery($query,array($record));

            $data_num = $adb->num_rows($result);
            $total = 0;
            for($i = 0; $i<$data_num; $i++){
                $lineitem_id = $adb->query_result($result,$i,$Detail_table_id);
                $parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
                // @edit:dong @date:2023/05/15 @reason: 获取数据保存前的的erp分录内码
                $erpentryid = $adb->query_result($result,$i,'erpentryid');
                if($erpentryid){
                    $before_db_value[$lineitem_id]['erpentryid'] = $erpentryid;
                }
                foreach($productdetail_columns as $columnname){
                    $value = $adb->query_result($result,$i,$columnname);
                    if($value==0 && $columnname=='entitytypeid'){
                        $value = '';
                    }
                    if($columnname == 'tax_amount'){
                        $total += $value;
                    }
                    $value = is_null($value) ? '' : $value;
                    $before_db_value[$lineitem_id][$columnname] = html_entity_decode($value);
                }
                //移动端返回值中缺少entitytypeid,从parent_lineitem_id获取
                if(!empty($weixin_user)&&$parent_lineitem_id>0&&!empty($before_db_value[$lineitem_id]['entitytype'])){
                    $info = getLineitemModuleInfo($parent_lineitem_id,$before_db_value[$lineitem_id]['entitytype']);
                    $before_db_value[$lineitem_id]['entitytypeid'] = $info['id'];
                }else{
                    //zkt 20230705 BUG0068667  单据审批通过后，再编辑会是“源单”信息丢失。（发货申请单）
                    if(!isset($before_db_value[$lineitem_id]['entitytype'])||empty($before_db_value[$lineitem_id]['entitytype']))
                        $before_db_value[$lineitem_id]['entitytype']='';
                    if(!isset($before_db_value[$lineitem_id]['entitytypeid'])||empty($before_db_value[$lineitem_id]['entitytypeid']))
                        $before_db_value[$lineitem_id]['entitytypeid']='';
                }
            }

            //考虑到历史数据不存在V1.0版本的情况
            if($data_num>0){
                $sql = 'select trackid_no from ld_detailtracker_basic where record = ?';
                $result = $adb->pquery($sql,array($record));
                $num_rows = $adb->num_rows($result);
                //为没有版本的已创建单据增加1.0版本
                if($num_rows==0){
                    $trackid_no = $char.sprintf("%.1f",$num_rows+1);
                    $datetime = date('Y-m-d H:i:s');
                    //增加新版本
                    $sql = 'insert into ld_detailtracker_basic(trackid_no,modulename,record,whodid,changedon,total) values(?,?,?,?,?,?)';
                    $adb->pquery($sql,array($trackid_no,$module,$record,$current_user->id,$datetime,$total));

                    //获取新增加的日志id
                    $sql = 'select max(trackid) as trackid from ld_detailtracker_basic';
                    $result = $adb->pquery($sql,array());
                    $trackid = $adb->query_result($result,0,'trackid');

                    foreach($before_db_value as $lineitem_id =>$before_detailinfo ){
                        $before_json_info = '';
                        if(sizeof($before_detailinfo)>0){
                            $after_json_info = ldcrm_json_encode($before_detailinfo);
                        }else{
                            $after_json_info = '';
                        }
                        $type = 'create';
                        $sql = 'insert into ld_detailtracker_detail(trackid,crmid,lineitem_id,prevaluejson,postvaluejson,changetype) values(?,?,?,?,?,?)';
                        $adb->pquery($sql,array($trackid,$record,$lineitem_id,$before_json_info,$after_json_info,$type));
                    }

                    if ($_REQUEST['is_qrcode_expand'] == 'yes') {
                        $qrcodeid = $_REQUEST['qrcodeid'];
                        $wechatuserid = $_REQUEST['wechatuserid'];
                        //表单码分录修改日志
                        $query = 'insert into ld_qrcode_operatelog_detail(qrcodebasicid,wechatuserid,viewtime,type,trackid,crmid) values(?,?,?,?,?,?);';
                        $adb->pquery($query,array($qrcodeid,$wechatuserid,$datetime,'submit',$trackid,$record));
                    }

                }
            }
        }

        return $before_db_value;
    }



    /**
     * edit:Chj
     * reason:删除产品明细
     * date:2014-1-16
     **/
    function deleteInventoryProductDetails($focus,$module='')
    {

        global  $adb,$updateInventoryProductRel_update_product_array, $current_user,$currentModule;


        $updateInventoryProductRel_update_product_array = $focus->update_product_array;
        $Detail_table=$focus->Detail_table;
        $Detail_table_scf=$focus->Detail_table_scf;
        $Detail_table_index=$focus->Detail_table_index;
        $Detail_table_id=$focus->Detail_table_id;
        if(is_array($focus->before_lineitem_ids)&&$focus->before_lineitem_ids[0]>0)
        {
            $lineitemids=implode(",",$focus->before_lineitem_ids);

            $adb->pquery("delete from $Detail_table_scf where $Detail_table_id in( $lineitemids)",array());

        }
        $adb->pquery("delete from $Detail_table where $Detail_table_index=?", array($focus->id));
        //  $adb->pquery("delete from $Detail_table_scf where $Detail_table_index=?", array($focus->id));
        //$adb->pquery("delete from ld_inventoryshippingrel where id=?", array($focus->id));


    }
}
?>