<?php
/**
 * edit:zkt
 * date:2022-3-9
 * reason:列表界面小编辑
 **/
global $adb,$current_user;
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$module = $_REQUEST['frommodule'];
$fieldname = $_REQUEST['fieldname'];
$columnname = $fieldname;
$record = $_REQUEST['record'];
$tabid = getTabid($module);
$cur_detailid = $_REQUEST['detailid'];

$focus=CRMEntity::getInstance($module);
$fieldvalue = ($_REQUEST[$fieldname]);//BUG0054447 20220729 序时簿小编辑字段下拉框 10% 保存失败
$fieldobj=Field::getInstance($module,$adb);

$detailfieldobj=$focus->detailfieldobj;
$fieldinfo = $detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);

$uitype=$fieldinfo->getUIType();
$fieldid = $fieldinfo->getFieldid();
$columnname=$fieldinfo->getColumnName();
$tablename = $fieldinfo->getTableName();

$focus->id = $record;
$focus->mode = "edit";
$focus->retrieve_entity_info($record,$module);
$moduleFields=$fieldobj->getModuleFields();
$savemoduleFields=$moduleFields;

foreach($focus->column_fields as $tmpfieldname=>$value)
{
    //zkt 20230428 BUG0065762 合同订单列表界面任意一条单据，使用小编辑编辑“客户类型”保存提示合同 不允许大于合计（实际上单据是满足验证规则条件的）
	$reqfieldname = $tmpfieldname;
    if($tmpfieldname=='hdnGrandTotal'){
        $_REQUEST['total']=$value;
         if($module=='CashBill')
            {
                $reqfieldname='cashbill_total';
            }
            else if($module=="SendCashBill")
            {
                if(is_numeric($_REQUEST['sendcashbill_total']))
                {
                    $reqfieldname='sendcashbill_total';
                }
                else{
                    $reqfieldname='total';
                }
            }
            else
                $reqfieldname='total';
    }
    $_REQUEST[$reqfieldname]=$value;
    if($reqfieldname == 'selectlistval' && !empty($value))
    {

        $value_arr = explode(',',$value);
        $_REQUEST['selectsourcename'] = getSalesEntityType($value_arr[0]);
    }
}

$isProductDetail='no';
$cashbill_moudle = 'no';
if($module == 'CashBill' || $module == 'SendCashBill'){
    //选择源单
    $cashbill_moudle = 'yes';
    $isProductDetail = 'no';
    $sourcemodules=getSourceModule($module);
    if(isset($_REQUEST['selectsourcename'])){
        $selectsourceModule = $_REQUEST['selectsourcename'];
    }
    foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
    {
        if($selectsourceModule==$sourcemoduleinfo['entitytype']&&$sourcemoduleinfo['withdetail']=='yes')
        {
            $isProductDetail='yes';
            break;
        }
    }
}

//获取明细信息
$detailfieldInfo_arr=[];
$aftersavedetailfieldvalue_arr = [];
$tmp_arr = [];
$find_detailid = 'no'; //判断请求的detailid是否包含在数据库里
if(get_file_address($module,"ProductDetails") || $isProductDetail == 'yes')
{
    if($cashbill_moudle == 'yes'){
        crm_load_class_file('cls_productDetailsData',"modules/$module/ProductDetail");
        $cls_productDetailsDataobj = new cls_productDetailsData($module,$selectsourceModule);
    }else{
        crm_load_class_file('cls_productDetailsData',"modules/$module/ProductDetails");
        $cls_productDetailsDataobj = new cls_productDetailsData($module);
    }

    $detailarr = $cls_productDetailsDataobj->getProductToolFieldValue($focus,'edit');
    crm_load_class_file('ProductToolFields','include/ProductDetails');
    $detailfieldobj=ProductToolFields::getInstance($module);
    if($cashbill_moudle == 'yes'){
        $detailfieldobj->ResetBillEmpty();
        $detailfieldobj->setsourceModulesqlwhere($selectsourceModule);
    }
    $detailtype = 'product';

    //调整和整单折扣字段
    $discount = $cls_productDetailsDataobj->getInventoryDiscount($focus);
    if($discount['adjustment'] > 0){
        $_REQUEST['adjustment'] = $discount['adjustment'];
        $_REQUEST['adjustmentType'] = '+';
    }else{
        $_REQUEST['adjustment'] = ($discount['adjustment'])*(-1);
        $_REQUEST['adjustmentType'] = '-';
    }
    if($discount['discount_type'] == '0'){
        $_REQUEST['discount_amount'] = $discount['discount_amount'];
        $_REQUEST['allSingledDiscount'] = '-';
    }else if($discount['discount_type'] == '1'){
        $_REQUEST['discount_amount'] = $discount['discount_percent'];
        $_REQUEST['adjustmentType'] = '%';
    }


    $rowcount = 0;
    if(!empty($detailarr))
    {
        $rowindex = 1;

        foreach($detailarr as $index=>$tmpdetailinfo)
        {
            $detailfieldInfo_arr=$tmpdetailinfo;
            $tmp_arr = $tmpdetailinfo;
            foreach($tmpdetailinfo as $tmpdetailcolumnname=>$tmpdetailfieldvalue)
            {
                if($tmpdetailcolumnname == 'detailid'||$tmpdetailcolumnname == 'id')
                {
                    continue;
                }
                $tmpcolumnname  = $detailfieldobj->getFieldInfoBykeyValue('columnname',$tmpdetailcolumnname,'columnname');

                if(!empty($tmpcolumnname))
                {
                    if($tmpcolumnname == $columnname && $detailfieldInfo_arr['detailid'] == $cur_detailid){
                        $_REQUEST[$tmpcolumnname.$rowindex] = $fieldvalue;
                        $tmp_arr[$tmpcolumnname] = $fieldvalue;
                    }else{
                        $_REQUEST[$tmpcolumnname.$rowindex] = $tmpdetailfieldvalue;
                    }
                }
            }
            if($detailfieldInfo_arr['detailid'] == $cur_detailid){
                $find_detailid = 'yes';
            }
            $_REQUEST['lineitem_id'.$rowindex] = $tmpdetailinfo['parent_lineitem_id'];
            $_REQUEST['before_lineitem_id'.$rowindex] = $tmpdetailinfo['detailid'];
            $_REQUEST['hdnProductId'.$rowindex] = $tmpdetailinfo['productid'];
            $aftersavedetailfieldvalue_arr[] = $tmp_arr;
            $rowcount = $rowindex;
            $rowindex++;
        }
    }
    $_REQUEST['inventory_currency'] = $focus->column_fields['currency_id'];
    $_REQUEST['rowcnt'] = $rowcount;
}
else if(get_file_address($module,$module.'DetailFieldsHtml'))
{
    //获取明细数据类
    if($module == 'CashBill'){
        crm_load_class_file("CashBillTabDetailFieldsData",'modules/CashBill');
        $TabDetailFieldsDatalobj = new CashBillTabDetailFieldsData($focus,$module,$selectsourceModule);
    }elseif($module == 'SendCashBill'){
        crm_load_class_file("SendCashBillTabDetailFieldsData",'modules/SendCashBill');
        $TabDetailFieldsDatalobj = new SendCashBillTabDetailFieldsData($focus,$module,$selectsourceModule);
    }else{
        crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
        $TabDetailFieldsDatalobj = new TabDetailFieldsData($focus,$module);
    }

    $detailarr = $TabDetailFieldsDatalobj->getTabDetailHtmlContentData();
    crm_load_class_file("TabDetailFields",'include/TabDetailFields');
    $detailfieldobj = TabDetailFields::getInstance($module);
    if($cashbill_moudle == 'yes'){
        $detailfieldobj->setsourceModulesqlwhere($selectsourceModule);
    }
    $detailtype = 'normal';

    $rowcount = 0;
    if(!empty($detailarr))
    {
        $rowindex = 1;
        foreach($detailarr as $index=>$tmpdetailinfo)
        {
            $detailfieldInfo_arr=$tmpdetailinfo;
            $tmp_arr = $tmpdetailinfo;
            foreach($tmpdetailinfo as $tmpdetailcolumnname=>$tmpdetailfieldvalue)
            {
                if($tmpdetailcolumnname == strtolower($module).'detailid'||$tmpdetailcolumnname == 'detailid')
                {
                    continue;
                }
                $tmpfieldinfo  = $detailfieldobj->getFieldInfoobjBykey('columnname',$tmpdetailcolumnname);
                
                if(!empty($tmpfieldinfo))
                {
                    if($tmpdetailcolumnname == $columnname && $detailfieldInfo_arr['detailid'] == $cur_detailid){
                        $_REQUEST[$tmpdetailcolumnname.$rowindex] = $fieldvalue;
                        $tmp_arr[$tmpdetailcolumnname] = $fieldvalue;
                    }else{
                        $_REQUEST[$tmpdetailcolumnname.$rowindex] = $tmpdetailfieldvalue;
                    }
                }
            }
            if($detailfieldInfo_arr['detailid'] == $cur_detailid){
                $find_detailid = 'yes';
            }
            $aftersavedetailfieldvalue_arr[] = $tmp_arr;
            $_REQUEST[$focus->Detail_table_id.$rowindex] = $cur_detailid;
            $_REQUEST['hidden_rowid_'.$rowindex] = 0;
            $_REQUEST['deleterow'.$rowindex] = 0;
            $rowcount = $rowindex;
            $rowindex++;
        }
    }
    $_REQUEST['rowcnt'] = $rowcount;
}
//如果请求的detailid不在数据库中,则表示单据被修改过,需要刷新界面
if($find_detailid == 'no'){
    ConvertTojsonString("-1",array('refresh'=>'yes','refreshlistmodules'=>[$module]),getFixedLabel('DOCUMENTCHANGEDLISTREFRESHED'));
}
//保存前判断操作
crm_load_class_file('cls_save_operation','include/utils');
$operationobj = cls_save_operation::getInstance($module,$record);
$operationobj->setCheckValidata($_REQUEST['pagevaliddatasavetip']);

$return_arr = $operationobj->before_save($record);
if($return_arr['code'] < 0){
    ConvertTojsonString($return_arr['code'],[],$return_arr['msg']);
}

//调用save_module里的保存分录的方法
if($module == 'CashBill' || $module == 'SendCashBill'){
    $return_arr = $focus->SaveModuleDetail();
    if($module == 'CashBill'){
        $focus->updateCashbillSourceDetail($focus->id);
    }elseif($module == 'SendCashBill'){
        $focus->updateSendCashbillSourceDetail($focus->id);
    }
}else if($detailtype == 'product'){
    crm_load_class_file('saveInventory', 'include/utils');
    $saveInventoryobj = new saveInventory();
    $saveInventoryobj->save($focus, $module);
}else if($detailtype == 'normal'){
    crm_load_class_file('cls_save_moduledetail','data');
    $obj=new cls_save_moduledetail($focus->module_name,$focus->id);
    $obj->Savedetail();
}
//保存后调用方法
$arr = [];
$arr['fieldname'] = $fieldname;
$arr['aftersavedetailfieldvalue_arr'] = $aftersavedetailfieldvalue_arr;
$return_arr = $operationobj->after_save($arr);
$arr = $return_arr;

$arr['refreshlistmodules']=array($module);

ConvertTojsonString(1,$arr,"success");

?>