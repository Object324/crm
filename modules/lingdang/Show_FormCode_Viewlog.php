<?php
global $adb,$list_max_entries_per_page_new_more,$currentModule;
//$list_max_entries_per_page_new_more = 5;
$module = $_REQUEST['module'];
$detaillog = !empty($_REQUEST['detaillog'])?$_REQUEST['detaillog']:'no';

$smarty = new lingdangCRM_Smarty;
//三种方式获取表单码id
if(isset($_REQUEST['trackid'])&&$_REQUEST['trackid']>0){
    //单据修改日志
    $trackid = $_REQUEST['trackid'];
    $sql = "SELECT qrcodebasicid,crmid FROM ld_qrcode_operatelog WHERE trackid = ?;";
    $result = $adb->pquery($sql,array($trackid));
    $qrcodebasicid = $adb->query_result($result,0,'qrcodebasicid');
    $record = $adb->query_result($result,0,'crmid');
}else if($_REQUEST['record']>0){
    //详情页面
    $record = $_REQUEST['record'];
    $fieldid = $_REQUEST['fieldid'];
    $sql = "SELECT qrcodebasicid from ld_qrcode_creation 
        INNER JOIN ld_qrcode_template on ld_qrcode_template.qrcodetemplateid = ld_qrcode_creation.qrcodetemplateid
        where modulename = ? and record = ? and fieldid = ?;";
    $result = $adb->pquery($sql,array($module,$record,$fieldid));
    $qrcodebasicid = $adb->query_result($result,0,'qrcodebasicid');

    $smarty->assign('fieldid',$fieldid);
}else if($_REQUEST['qrcodebasicid']>0){
    //分页
    $qrcodebasicid = $_REQUEST['qrcodebasicid'];
    $sql = 'select record from ld_qrcode_creation where qrcodebasicid = ?';
    $result = $adb->pquery($sql,array($qrcodebasicid));
    $record = $adb->query_result($result,0,'record');
}
$smarty->assign('qrcodebasicid',$qrcodebasicid);

//判断当前模块是否需要显示单据分录修改日志
if($currentModule == 'ServiceCharge'){
    $showdetaillog = 'no';
}else if($currentModule == 'Potentials'){
    $deployarray=getSys_deploy(205);//销售机会是否显示产品分录明细:0是，1否
    if($deployarray['deploy_value']==0){
        $showdetaillog = 'yes';
    }else{
        $showdetaillog = 'no';
    }
}else if(get_file_address($currentModule,$currentModule."DetailFieldsHtml")||get_file_address($currentModule,"ProductDetails")){
    //有单据分录的模块显示分录修改日志
    $showdetaillog = 'yes';
}else{
    $showdetaillog = 'no';
}
$smarty->assign('SHOWDETAILLOG',$showdetaillog);//是否显示“单据分录”按钮

if($detaillog=='yes'){
    $RELATEDLISTDATA =  getDetailUpdatelog($module,$record);

    $smarty->assign('RELATEDLISTDATA',$RELATEDLISTDATA);

//    $smarty->assign('RELATED_MODULE','ViewHistory');
    $smarty->assign('RELATED_MODULE',$currentModule);
}
else{
//根据表单码id获取所有修改日志
$sql = "SELECT ld_modtracker_detail.fieldname,ld_modtracker_detail.prevalue,ld_modtracker_detail.postvalue,
            ld_wechatuser.lastname,ld_modtracker_basic.changedon from ld_qrcode_operatelog
        INNER JOIN ld_modtracker_basic on ld_qrcode_operatelog.trackid = ld_modtracker_basic.id
        INNER JOIN ld_modtracker_detail on ld_modtracker_basic.id = ld_modtracker_detail.id
        INNER JOIN ld_wechatuser on ld_wechatuser.wechatuserid = ld_qrcode_operatelog.wechatuserid
        where ld_qrcode_operatelog.qrcodebasicid = ? and ld_qrcode_operatelog.type = 'submit' 
        order by ld_modtracker_basic.changedon desc ";        
$result = $adb->pquery($sql,array($qrcodebasicid));
$noofrows = $adb->num_rows($result);
//获取分页设置
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
	$start = $_REQUEST['start'];
	if($start == 'last'){
		if($noofrows > 0){
			$start = ceil($noofrows/$list_max_entries_per_page_new_more);
		}
	}
	if(!is_numeric($start)) $start = 1;
	elseif($start < 1) $start = 1;
	$start = ceil($start);
}else{
	$start = 1;
}
$limstart=($start-1)*$list_max_entries_per_page_new_more;
$end = ceil($noofrows/$list_max_entries_per_page_new_more);
//记录分页显示
$filter['start'] = $start;
$filter['end'] = $end;
$filter['noofrows'] = $noofrows;
$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';

$result = $adb->pquery($sql,array($qrcodebasicid));
$rows = $adb->num_rows($result);
//头部标题
$header = array('fieldname'=>getFixedLabel('LBL_Field'),
			'prevalue'=>getFixedLabel('LBL_Earlier'),
			'postvalue'=>getFixedLabel('LBL_Present'),
			'whodid'=>getFixedLabel('OPERATOR').'('.getTranstab('WeChatUser').')',
			'changedon'=>getFixedLabel('OPERATTIME'));
$tmpwidth['fieldwidth']['fieldname']=200;
$tmpwidth['fieldwidth']['prevalue']=150;
$tmpwidth['fieldwidth']['postvalue']=150;
$tmpwidth['fieldwidth']['whodid']=150;
$tmpwidth['fieldwidth']['changedon']=200;

//计算总宽度
$total_width = 0;
foreach($tmpwidth['fieldwidth'] as $tmp_width){
    $total_width += $tmp_width;
}


$smarty->assign('HEADER',$header);
$smarty->assign('FILTER',$filter);
$smarty->assign('TMPWIDTH',$tmpwidth['fieldwidth']);
$smarty->assign('RELATED_MODULE',$module);
//读取日志记录
if($rows > 0){
	$fieldobj = Field::getInstance($module,$db);
	$modulefield = $fieldobj->getModuleFields();
    $showfieldvalue=new ShowFieldValue($fieldobj,$module,SHOW_POPUP);
   	$showfieldvalue->setRecorId($record);
    $showfieldvalue->result=$result;
	for ($i=0; $i < $rows; $i++) {
		$fieldname = $adb->query_result($result,$i,'fieldname');
		$prevalue = $adb->query_result($result,$i,'prevalue');
		$postvalue = $adb->query_result($result,$i,'postvalue');
		$lastname = $adb->query_result($result,$i,'lastname');
		$changedon = $adb->query_result($result,$i,'changedon');
		if(!empty($modulefield[$fieldname])){
			$fieldlabel = $modulefield[$fieldname]->getFieldLabel($module,$fieldname);
		}

        $field=$modulefield[$fieldname];
        if(!$field)
        {
          continue;
        }
        $showvalue= $showfieldvalue->getFieldValueByField($field,$prevalue,$prevalue);
        $prevalue=$showvalue['value'];
        $showvalue= $showfieldvalue->getFieldValueByField($field,$postvalue,$postvalue);
        $postvalue=$showvalue['value'];
        $username = $lastname;
        
        $entity[$i]['fieldname'] = $fieldlabel;
		$entity[$i]['prevalue'] = $prevalue;
		$entity[$i]['postvalue'] = $postvalue;
		$entity[$i]['username'] = $username;
		$entity[$i]['changedon'] = $changedon;
	}
    $smarty->assign('ENTITY',$entity);

    //表单码修改日志的分页 zxm 20230111
    $url_qry = '';
    crm_load_class_file('ListView_Page_Special', 'include/utils');
    crm_load_class_file('ListViewUtils', 'include/utils');
    $limit_start_rec = ($start-1) * $list_max_entries_per_page_new_more;
    $navigation_array =  VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
    $navigationOutput[] =  getRecordRangeMessage($result, $limit_start_rec,$noofrows);
    $navigationOutput[] = ListView_Page_Special::getBiaodanCodeHistoryHeaderNavigation($navigation_array, $url_qry,$currentModule,'',$_REQUEST['record']);
    $smarty->assign("navigationOutput", $navigationOutput);
}
}

$smarty->assign('LOGTYPE',$detaillog);//点击“单据分录”按钮返回yes
$smarty->assign('RECORDID',$record);
$_REQUEST['diony'] = 'yes';

$content = $smarty->fetch('modules/lingdang/Formcode_Viewlog.tpl');
$arr['content'] = $content;
$arr['title'] = getFixedLabel('FORMCODE').getFixedLabel('View History');
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['RELATEDLISTDATA'] = $RELATEDLISTDATA;

ConvertTojsonString(1,$arr,"success");

//读取表单码 单据分录修改日志
function getDetailUpdatelog($module,$record){
    crm_load_class_file('showProductDetailFieldValue','include/fields');
    crm_load_class_file('TabDetailFieldsHtmlTd','include/TabDetailFields');
    global $adb,$list_max_entries_per_page_new_more;
    global $current_user,$PlatformMC;
    $focus = CRMEntity::getInstance($module);
    $focus->mode = 'Details';
    $focus->id = $record;
    $focus->retrieve_entity_info($record,$module);
    $entitytype='';
    if($module == 'CashBill' || $module == 'SendCashBill'){
        $source_list = $focus->column_fields['selectlistval'];
        $source_list_arr = explode(',',$source_list);
        $entitytype = getSalesEntityType($source_list_arr[0]);
        // $focus->detailfieldobj->setsourceModulesqlwhere($sourcemodulename);
        $focus->Resetdetailfieldobj($entitytype);
    }

    $tabid = getTabid($module);
    $languageType= getLanguageType($current_user);

    //表头字段显示
    $showfieldvalue=new ShowFieldValue($focus->fieldobj,$module,SHOW_POPUP);
    $showfieldvalue->setRecorId($record);
    //产品分录字段显示
    $showfieldvalueobj=new showProductDetailFieldValue($focus->detailfieldobj,$module,SHOW_DETAILVIEW);
    $showfieldvalueobj->setadbResult('');
    $showfieldvalueobj->setRecorId($record);
    //普通分录显示
    $TabDetailFieldsHtmlTd = new TabDetailFieldsHtmlTd($focus,$module);
    //分录字段信息

    $DetailToolFiledsInfo = $focus->detailfieldobj->getModuleProductToolField($tabid,$languageType);
    $isproductentitytype='no';
    if($module == 'CashBill' || $module == 'SendCashBill')
    {
        if(array_key_exists("productname",$DetailToolFiledsInfo))
        {
            $isproductentitytype='yes';
        }
    }
    $ProductsFiled = Field::getInstance('Products',$adb);

    $Detail_table = $focus->Detail_table;
    $Detail_table_scf = $focus->Detail_table_scf;

    $total_columnname = 'total';
    $total_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$total_columnname);

//    $query = 'SELECT * from ld_detailtracker_basic where modulename =? and record = ? ';
    $query = 'SELECT * from ld_detailtracker_basic 
INNER JOIN ld_qrcode_operatelog_detail on ld_qrcode_operatelog_detail.trackid = ld_detailtracker_basic.trackid
INNER JOIN ld_wechatuser on ld_wechatuser.wechatuserid = ld_qrcode_operatelog_detail.wechatuserid 
where modulename =? and record = ? ';
    $result = $adb->pquery($query,array($module,$record));
    $noofrows = $adb->num_rows($result);

    $filter = array();
    $filter['record'] = $record;
    //order by 排序
    $order_by = 'ld_detailtracker_basic.changedon desc,ld_detailtracker_basic.trackid ';
    $sorder = 'desc';

    $filter['order_by'] = $order_by;
    $filter['sorder'] = $sorder;
    $query .= ' ORDER BY '.$order_by.' '.$sorder.' ';

    //获取当前页数
    if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
        $start = $_REQUEST['start'];
        if($start == 'last'){
            if($noofrows > 0){
                $start = ceil($noofrows/$list_max_entries_per_page_new_more);
            }
        }
        if(!is_numeric($start)) $start = 1;
        elseif($start < 1) $start = 1;
        $start = ceil($start);
    }else{
        $start = 1;
    }
    $filter['start'] = $start;
    //计算limit
    $limstart=($start-1)*$list_max_entries_per_page_new_more;
    if(!empty($PlatformMC)){
        $query .= ' limit 0,10';
    }else{
        $query .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
    }

    //读取修改日志基础信息
    $result = $adb->pquery($query,array($module,$record));
    $rows = $adb->num_rows($result);

    $detail_basic_info = array();
    $trackid_arr = array();
    for($i=0;$i<$rows;$i++){
        $trackid = $adb->query_result($result,$i,'trackid');
        $trackid_arr[] = $trackid;
        $detail_basic_info[$trackid]['version'] = $adb->query_result($result,$i,'trackid_no');
        $detail_basic_info[$trackid]['changedon'] = $adb->query_result($result,$i,'changedon');
        $detail_basic_info[$trackid]['whodid'] = getUserFullName($adb->query_result($result,$i,'whodid'));
        $total_value = $adb->query_result($result,$i,'total');
        $showvalue= $showfieldvalue->getFieldValueByField($total_fieldinfo,$total_value,$total_value);
        $detail_basic_info[$trackid]['total'] = $showvalue['value'];
        $rowspan[$trackid] = 0;
    }

    //设置列头信息
    $header = array('version'=>getFixedLabel('VERSION'),
        'changedon'=>getFixedLabel('OPERATTIME'),
        'whodid'=>getFixedLabel('OPERATOR'));
    $tmp['headername']['columnname']['version']='version';
    $tmp['headername']['columnname']['changedon']='changedon';
    $tmp['headername']['columnname']['whodid']='whodid';
    $tmp['headername']['fieldname']['version']='version';
    $tmp['headername']['fieldname']['whodid']='whodid';
    $tmp['headername']['fieldname']['changedon']='changedon';
    $tmpwidth['fieldwidth']['version'] = 60;
    $tmpwidth['fieldwidth']['changedon'] = 150;
    $tmpwidth['fieldwidth']['whodid'] = 100;
    $tdalign['version'] = 'center';
    $tdalign['changedon'] = 'left';
    $tdalign['whodid'] = 'left';

    //合计列信息读取当前模块‘total’字段
    $detailtotalinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$total_columnname);
    if(!$detailtotalinfo){
        $fieldlabel = $total_fieldinfo->getFieldLabel();
    }else{
        $fieldlabel = $detailtotalinfo->getFieldLabel();
    }
    $header[$total_columnname] = $fieldlabel;
    $tmp['headername']['columnname'][$total_columnname] = $total_columnname;
    $tmp['headername']['fieldname'][$total_columnname] = $total_fieldinfo->getFieldName();
    $tmpwidth['fieldwidth'][$total_columnname] = 100;
    $tdalign[$total_columnname] ='right' ;

    $detail_filed = array();
    $alldetail_fields = array();
    //将分录宽度中的mm与px相互转化,96px=25.4mm
    $proportion = 96/25.4;
    //获取所有开启的分录字段信息

    foreach($DetailToolFiledsInfo as $key => $detailfieldinfo){
        $columnname = $detailfieldinfo->getColumnName();

        $tablename = strtolower($detailfieldinfo->getTableName());
        $fieldname = $detailfieldinfo->getFieldName();
        $width = $detailfieldinfo->getWidth();
        $typeofdata = $detailfieldinfo->getTypeOfData();
        $fieldlabel = $detailfieldinfo->getFieldLabel();
        if(($detailfieldinfo->getSaveDataBase() == 'yes'|| $tablename == 'ld_products'||$tablename == 'ld_productcf' ) ||
            ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid'
            || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
            if(array_key_exists($columnname,$header)){
                continue;
            }
            if($tablename == 'ld_products'||$tablename == 'ld_productcf'){
                $fieldinfo = $ProductsFiled->getFieldInfoobjBykey('columnname',$columnname);
                if(empty($fieldinfo)||!$fieldinfo){
                    continue;
                }

                $header[$columnname] = $fieldlabel;
                $tmp['headername']['columnname'][$columnname] = $columnname;
                $tmp['headername']['fieldname'][$columnname] = $fieldname;
                $tmpwidth['fieldwidth'][$columnname] = $width*$proportion;
                //数字类型靠右显示，字符串靠左显示
                if(($typeofdata[0] == 'N' || $typeofdata[0] == 'NN')){
                    $tdalign[$columnname] = 'right';
                }else{
                    $tdalign[$columnname] = 'left';
                }
                $productcolumnname[] = $columnname;
                $productdetail_column_sql[] = $tablename. '.' . $columnname;
                $alldetail_fields[] = $columnname;
            }else if($tablename == $Detail_table||$tablename ==$Detail_table_scf){
                $header[$columnname] = $fieldlabel;
                $tmp['headername']['columnname'][$columnname] = $columnname;
                $tmp['headername']['fieldname'][$columnname] = $fieldname;
                if($columnname == 'entitytypeid'&&$width <=0){
                    $tmpwidth['fieldwidth'][$columnname] = 50*$proportion;
                }else{
                    $tmpwidth['fieldwidth'][$columnname] = $width*$proportion;
                }
                //数字类型靠右显示，字符串靠左显示
                if(($typeofdata[0] == 'N' || $typeofdata[0] == 'NN')){
                    $tdalign[$columnname] = 'right';
                }else{
                    $tdalign[$columnname] = 'left';
                }
                $detail_filed[] = $columnname;
                $alldetail_fields[] = $columnname;
            }
        }
    }

    $total_width = 0;
    foreach($tmpwidth['fieldwidth'] as $columnname=>$width){
        $total_width += $width;
    }

    //读取修改日志版本明细
//    $sql = "SELECT trackid,prevaluejson,postvaluejson,lineitem_id,changetype from ld_detailtracker_detail ";
//    $sql .= " where trackid in (".implode(',',$trackid_arr).") order by lineitem_id asc;";

    $sql = "SELECT detail.trackid,detail.prevaluejson,detail.postvaluejson,detail.lineitem_id,detail.changetype from ld_qrcode_operatelog_detail
INNER JOIN ld_detailtracker_detail AS detail on ld_qrcode_operatelog_detail.trackid = detail.trackid
INNER JOIN ld_wechatuser on ld_wechatuser.wechatuserid = ld_qrcode_operatelog_detail.wechatuserid ";
    $sql .= " where detail.trackid in (".implode(',',$trackid_arr).") order by detail.lineitem_id asc;";

    $result = $adb->pquery($sql,array());
    $num_row = $adb->num_rows($result);

    $change_column_arr = array();
    if($num_row>0){
        for($i=0;$i<$num_row;$i++){
            $detailinfo = array();
            $tmp_detailinfo = array();

            $trackid = $adb->query_result($result,$i,'trackid');
            $lineitem_id = $adb->query_result($result,$i,'lineitem_id');
            $changetype = $adb->query_result($result,$i,'changetype');
            $prevaluejson = $adb->query_result($result,$i,'prevaluejson');
            $postvaluejson = $adb->query_result($result,$i,'postvaluejson');
            $postvalue = ldcrm_json_decode($postvaluejson);
            if(sizeof($productdetail_column_sql)>0){
                $productid = $postvalue['productid'];
                $product_sql = "SELECT ".implode(',',$productdetail_column_sql)." from ld_products
                    INNER JOIN ld_productcf on  ld_products.productid = ld_productcf.productid 
                    where ld_products.productid = ?";
                $product_result = $adb->pquery($product_sql,array($productid));

                foreach($productcolumnname as $columnname){
                    $tmp_detailinfo[$columnname] = $adb->query_result($product_result,0,$columnname);
                }
            }

            if($prevaluejson != ''){
                $prevalue = ldcrm_json_decode($prevaluejson);
                //产品修改后按新增行处理
                if($prevalue['productid']!=$postvalue['productid']){
                    $change_column_arr[$trackid][$lineitem_id]['productname'] = 'yes';
                    foreach($productcolumnname as $columnname){
                        $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                    }
                    foreach($detail_filed as $columnname){
                        $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                        $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                    }
                }else{
                    foreach($detail_filed as $columnname){
                        $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                        //判断此版本与上个版本相比哪些字段修改过
                        if($prevaluejson != '' && $postvalue[$columnname] != $prevalue[$columnname]){
                            $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                        }else{
                            $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                        }

                    }
                }

            }else if($changetype == 'create' && $detail_basic_info[$trackid]['version'] != 'V1.0'){
                //duan 20220802 对新加行的所有字段进行标红处理
                foreach($detail_filed as $columnname){
                    $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                }
                foreach($productcolumnname as $columnname){
                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'yes';
                }
                $change_column_arr[$trackid][$lineitem_id]['productname'] = 'yes';
            }else{
                foreach($detail_filed as $columnname){
                    $tmp_detailinfo[$columnname] = $postvalue[$columnname];
                    $change_column_arr[$trackid][$lineitem_id][$columnname] = 'no';
                }
            }

            //收款单模块的合同金额和合同已收总额需要读取最新的数据
            if(!empty($tmp_detailinfo['entitytype']) && !empty($tmp_detailinfo['entitytypeid'])){
                if($module=='CashBill'){
                    $entitytype = $tmp_detailinfo['entitytype'];
                    $source_focus = CRMEntity::getInstance($entitytype);
                    $entitytypeid = $tmp_detailinfo['entitytypeid'];
                    if($entitytype == 'PaymentPlan'){
                        //回款计划收款，改为获取合同信息单据相关的收款单明细信息
                        $payment_sql = "select entitytype,entitytypeid from ld_paymentplan where paymentplanid=$entitytypeid";
                        $payment_result = $adb->pquery($payment_sql,array());
                        $sourcemodule = $adb->query_result($payment_result,0,'entitytype');
                        $sourcemodule_id = $adb->query_result($payment_result,0,'entitytypeid');
                        $source_focus = CRMEntity::getInstance($sourcemodule);

                        $query = "select total as source_total,received_amount as received_amount,currency_id,conversion_rate,currency_symbol 
                                        from $source_focus->table_name where $source_focus->table_index = $sourcemodule_id";
                    }else{
                        $query = "select total as source_total,received_amount as received_amount,currency_id,conversion_rate,currency_symbol 
                                        from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                    }
                    $tmp_result = $adb->pquery($query,array());
                    if($adb->num_rows($tmp_result)>0)
                    {
                        $tmp_detailinfo['source_total'] = $adb->query_result($tmp_result,0,'source_total');
                        $tmp_detailinfo['received_amount'] = $adb->query_result($tmp_result,0,'received_amount');
                    }

                }else if($module=='SendCashBill'){
                    $entitytype = $tmp_detailinfo['entitytype'];
                    $source_focus = CRMEntity::getInstance($entitytype);
                    $entitytypeid = $tmp_detailinfo['entitytypeid'];
                    if($entitytype == 'SendPayment'){
                        //付款计划付款，改为获取采购订单信息单据相关的明细信息
                        $sendpayment_sql = "select purchaseorder_id from ld_sendpayment where sendpaymentid=$entitytypeid";
                        $sendpayment_result = $adb->pquery($sendpayment_sql,array());
                        $entitytypeid = $adb->query_result($sendpayment_result,0,'purchaseorder_id');
                        $sourcemodule = 'PurchaseOrder';
                        $source_focus = CRMEntity::getInstance($sourcemodule);
                        $query = "select total as source_total,pay_amount as pay_amount  
                                from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                    }else{
                        $query = "select total as source_total,pay_amount as pay_amount 
                                from $source_focus->table_name where $source_focus->table_index = $entitytypeid";
                    }
                    $tmp_result = $adb->pquery($query,array());
                    $tmp_detailinfo['source_total'] = $adb->query_result($tmp_result,0,'source_total');
                    $tmp_detailinfo['pay_amount'] = $adb->query_result($tmp_result,0,'pay_amount');
                }
            }


            //通过字段类型控制显示格式
            foreach($alldetail_fields as $columnname){
                $value = $tmp_detailinfo[$columnname];
                //项目工时模块，关联类型特殊显示
                if($module == 'TimeSheet' && $columnname == 'timetype'){
                    if($value == 'Direct'){
                        $value = getFixedLabel('timesheet_direct');
                    }else if($value == 'Indirect'){
                        $value = getFixedLabel('timesheet_indirect');
                    }
                }

                if ($columnname == 'source_total'){
                    //收款单和付款单的合同金额字段增加小数位控制
                    $delopy_value = getSys_deploy(93);

                    //$value = setNumberFormat($value,$delopy_value['delopy_value']);

                }

                if(get_file_address($module,"ProductDetails")

                    ||(($module=='CashBill'||$module=='SendCashBill')&&$isproductentitytype=='yes')){
                    //产品分录显示
                    $detailfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);

                    $showvalue=$showfieldvalueobj->getFieldValueByField($detailfieldinfo,$value,$value);

                    if($detailfieldinfo->getBigType()=='multipicklist'){
                        //多选框处理
                        $showvalue['value'] =  str_replace(' |##| ',' , ',$showvalue['value']);
                        $showvalue['rawvalue'] =  str_replace(' |##| ',' , ',$showvalue['rawvalue']);
                    }else if($detailfieldinfo->getBigType() == 'reference'){
                        //日志中不需要显示超链接
                        $fld_module = $detailfieldinfo->getReferenceModule();
                        $showvalue = array();
                        $showvalue['value'] = getModuleHref($fld_module, $value);
                    }
                }else if(get_file_address($module,$module."DetailFieldsHtml")){
                    //其他分录显示
                    $detailfieldinfo = $DetailToolFiledsInfo[$columnname];

                    $showvalue=$TabDetailFieldsHtmlTd->getColumnValue($detailfieldinfo,$columnname,$value,SHOW_EDITVIEW);

                    if($detailfieldinfo->getFieldType()=='SelectComBox'){
                        //多选框处理
                        $showvalue['value'] =  str_replace(' |##| ',' , ',$showvalue['value']);
                        $showvalue['rawvalue'] =  str_replace(' |##| ',' , ',$showvalue['rawvalue']);
                    }else if($detailfieldinfo->getBigType() == 'reference'){
                        //日志中不需要显示超链接
                        $fld_module = $detailfieldinfo->getReferenceModule();
                        $showvalue = array();
                        $showvalue['value'] = getModuleHref($fld_module, $value);
                    }
                }

                if(empty($showvalue['value'])){
                    $value = $showvalue['rawvalue'];
                }else{
                    $value = $showvalue['value'];
                }
                $detailinfo[$columnname] = $value;
            }

            $detail_basic_info[$trackid]['detail'][$lineitem_id] = $detailinfo;
            $rowspan[$trackid] += 1;
        }

        //分页信息
//        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
//        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
//        $navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
//        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$module,'ModTrackerFldLog',$record);

        //zxm  分录日志分页信息
        $url_qry = '';
        crm_load_class_file('ListView_Page_Special', 'include/utils');
        crm_load_class_file('ListViewUtils', 'include/utils');
        $limit_start_rec = ($start-1) * $list_max_entries_per_page_new_more;
        $navigation_array =  VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
        $navigationOutput[] =  getRecordRangeMessage($result, $limit_start_rec,$noofrows);
        $navigationOutput[] = ListView_Page_Special::getBiaodanCodeHistoryHeaderNavigation($navigation_array, $url_qry,$module,'',$record);

    }

    $return_value = array('header'=>$header,'entries'=>$detail_basic_info,'navigation'=>$navigationOutput,
        'headername'=>$tmp['headername'],'fieldwidth'=>$tmpwidth['fieldwidth'],'total_width'=>$total_width,
        'title'=>getFixedLabel('View History'),'filter'=>$filter,'lbl_none'=>getFixedLabel('NONE'),
        'noofrows'=>$noofrows,'rowspan'=>$rowspan,'tdalign'=>$tdalign,'changedcolumn'=>$change_column_arr);
    return $return_value;
}
?>