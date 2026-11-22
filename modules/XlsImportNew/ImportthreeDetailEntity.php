<?php

global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony']='yes';
$filename=$_REQUEST['filename'];

if(empty($filename))
{
    $frommodule=$_REQUEST['frommodule'];
    $focus=CRMEntity::getInstance($frommodule);
    $arr['modulelabel']=gettranstab($frommodule);
    $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty=new lingdangCRM_Smarty();
     $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['content']=$smarty->fetch('ImportXlsNew/ThreeImport.tpl');
    $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
    //$tmp['canceltext']=getFixedLabel("ASTEP");
    
    ConvertTojsonString(1,$tmp,'success');
    
}
require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
require_once(globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php') ;
$focus=CRMEntity::getInstance($currentModule);
$module_tablename=$focus->table_name;//单据主表
$module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
$detailtable=$focus->Detail_table;
$detailtablescf=$focus->Detail_table_scf;

$profocus=CRMEntity::getInstance('Products');

$smarty=new lingdangCRM_Smarty();
//导入数据
$allFieldOnly=array();//所有唯一字段
$error='';//错误信息
//$mapfields=$_REQUEST['mapped_fields'];
$mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
$totalcolumns=sizeof($mapfields);//导入列数
   
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
$result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id];//数组
$producttoolresult=$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id];//数组
//放在函数的最下面，等待主表更新total字段更新完成
crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
import('data.Logic','class');
import('data.BaseLogic','class');
BaseLogic::$module=$currentModule;
if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php')) {
    $btnlogic=new BaseLogic();
} else {
    require_once(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php');
    $cls=$currentModule.'Logic';
   	$btnlogic=new $cls();
}

//导入数据
$allFieldOnly=array();//所有唯一字段
$error='';//错误信息
$totalcolumns=sizeof($mapfields);
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
//产品工具自定义字段
$import_module = $_REQUEST['importmodel'];
$smarty->assign("IMPORTMODULE",$import_module);

$importcolumn=array();
//$field_tables=array();//主表导入字段
$field_tables[$module_tablename]=array();//主表导入字段
$field_columns_only=array();//唯一字段
$fieldonlyXlsIndex=0;//唯一字段在xls文件中列索引
$codeIndex=0;//编号在xls文件中列索引
$adjustmentIdex=-1;//"调整"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$ServiceContracts_discount_percentIndex=-1;//"整单折扣百分比"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$saleorder_discount_amountIndex=-1;//"整单直接降价"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$product_discount_percentIndex=-1;//产品明细中“折扣百分比"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$product_discount_amountIndex=-1;//产品明细中“直接降价"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$product_tax_amountIndex=-1;//产品明细中“价税合计"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$updateStockQty_ProductID_arr=[];//需要更新产品总库存数量的ID
$findcodenum=false;

$importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1,'currency_id'=>-1,'entitytype'=>'-1');//导入字段在excel中的列位置
$inventory_tables[$detailtable]=array();//产品明细表导入字段
$producttoolfield_tables[$detailtablescf]=array();//产品明细自定义表导入字段
$nohaveerror=true;
$fieldcolIndex=0;
$moduleImport['choose'] = $_REQUEST['choose'];
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];

$checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
$is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
$tmps=array();
foreach($is_checkimportfield as $tmpindex=>$checkimportfieldname) {
    $tmps[]= $focus->fieldobj->getFieldInfoBykeyValue("fieldname",$checkimportfieldname,'columnname');
}
$is_checkimportfield=$tmps;
$importdupfields_condition=json_decode($_REQUEST['importdupfields_condition'],true);//查重字段条件

$conditionorlabel=getFixedLabel('OR');
$conditionandlabel=getFixedLabel('SEARCHAND');
for($i=0;$i<sizeof($is_checkimportfield);$i++) {
    $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$is_checkimportfield[$i],'fieldlabel');
    if($importdupfields_condition[$i]=='or')
        $conditionlabel=$conditionorlabel;
    else
        $conditionlabel=$conditionandlabel;
    if($i==sizeof($is_checkimportfield)-1) {
        $conditionlabel='';
    }
    $main_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
}

$main_fieldlabel_dup_tip=trim($main_fieldlabel_dup_tip,$conditionlabel);
$product_checkimportfield=implode(',',json_decode($_REQUEST['product_importdupcheckfields'],true));//查重字段
$product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
$product_importdupfields_condition=json_decode($_REQUEST['product_importdupfields_condition'],true);//查重字段条件

$code_num_columnname=$focus->fieldobj->getFieldInfoBykeyValue('uitype',4,'columnname');

for($i=0;$i<sizeof($product_is_checkimportfield);$i++) {
    $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$product_is_checkimportfield[$i],'fieldlabel');
    if($product_importdupfields_condition[$i]=='or')
        $conditionlabel=$conditionorlabel;
    else
        $conditionlabel=$conditionandlabel;
    $product_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
}
$importcolumnname_index['entitytype']=array_search('entitytype-producttoolfield',$mapfields);
// wym 240423 XUQIU20240402-03 检查下拉框字段
$checkPicklist=getUsersettingByLabel($currentModule, $current_user->id,'ImportCheckPicklist');
if(!empty($checkPicklist) && $checkPicklist!='no' && $checkPicklist!='yes'){//yes代表虽然开启了检查,但没有设置检查字段
    $checkPicklistColumn=explode('##',$checkPicklist);
}
//wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
$trigger_workflow=getUsersettingByLabel($currentModule,$current_user->id,'ImportCheckWorkflow');
if($trigger_workflow=='yes') {
    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
    $workflowreverseobj = cls_savereverse::getInstance($currentModule);
}
for($i=0;$i<sizeof($result);$i++) {
    $uitype=$result[$i]['uitype'];
    $columnname=$result[$i]['columnname'];
    $tablename=$result[$i]['tablename'];
    $typeofdata=$result[$i]['typeofdata'];
    $fieldonly=$result[$i]['fieldonly'];//字段值是否唯一，1：唯一
    $fieldLabel=$result[$i]['fieldlabel'];
    $typedata=explode('~',$typeofdata);
    if(in_array($columnname.'-field',$mapfields)) {
        $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
        if($columnname=='smownerid')
        $importcolumnname_index['smownerid']=array_search($columnname.'-field',$mapfields);
        else if($uitype==4) {
            $importcolumnname_index['code_num']=array_search($columnname.'-field',$mapfields);
        } else if($columnname==$focus->getCreateColumnName()) {
            $importcolumnname_index['smcreatorid']=array_search($columnname.'-field',$mapfields);
        } else if($columnname=='currency_id') {
            $importcolumnname_index['currency_id']=array_search($columnname.'-field',$mapfields);
        }
        if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
            $selcol=$tablename.':'.$columnname;
            if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])){ //session加非空判断，避免多次获取picklist
                        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                        if($fieldinfo){
                        $fieldname=$fieldinfo->getFieldName();
                        crm_load_class_file('cls_PickList', 'modules/PickList');
                        $cls_picklistobj = cls_PickList::getInstance($fieldname,$fieldinfo);
                        $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname,$fieldinfo);
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname]=$tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                    }
                }
            }
        }
    }
}
if(in_array('discount_percent-'.$currentModule,$mapfields)) {
    $ServiceContracts_discount_percentIndex=sizeof($field_tables[$module_tablename]);
    $field_tables[$module_tablename][]=array('discount_percent',1,'N~O',array_search('discount_percent-'.$currentModule,$mapfields));
}
if(in_array('discount_amount-'.$currentModule,$mapfields)) {/*整单折扣字段被载入2次bug:0012901*/
    $saleorder_discount_amountIndex=sizeof($field_tables[$module_tablename]);
}
if(in_array('adjustment-'.$currentModule,$mapfields)) {
    $adjustmentIdex=sizeof($field_tables[$module_tablename]);
    $field_tables[$module_tablename][]=array('adjustment',1,'N~O',array_search('adjustment-'.$currentModule,$mapfields));
}

//产品字段
$product_result=$_SESSION['productfield_'.$currentModule.'_'.$current_user->id];//数组
$product_tablename['ld_products']=array();//产品表导入字段
//$productcf_tables['ld_productcf']=array();//产品自定义表导入字段
$haveproductcoumnname=array();
for($i=0;$i<sizeof($product_result);$i++){
    $uitype=$product_result[$i]['uitype'];
    $columnname=$product_result[$i]['columnname'];
    if(in_array($columnname,$haveproductcoumnname)) {
        continue;
    }
    $haveproductcoumnname[]=$columnname;
    $typeofdata=$product_result[$i]['typeofdata'];
    $fieldlabel=$product_result[$i]['fieldlabel'];
    $table_name=$product_result[$i]['tablename'];
    $typedata=explode('~',$typeofdata);

    if(in_array($columnname.'-products',$mapfields)){
        if($typedata[1]=='M'){
            $product_tablename[$table_name][]=array($columnname,$uitype,'V~M',array_search($columnname.'-products',$mapfields));
        }else{
            $product_tablename[$table_name][]=array($columnname,$uitype,'V~O',array_search($columnname.'-products',$mapfields));
        }
    }
    else
    {
        if($typedata[1]=='M')
        {
            //28113: 创彩账套（192.168.3.5:85/crm,6.6.5SP3）合同订单>导入：当导入文件中没有必填项产品列的时候，结果导入成功了
            $error.='导入文件中缺少产品信息工具\''.$fieldlabel.'\'列<br>';
        }
    }
    if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
        $selcol=$table_name.':'.$columnname;
        if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
            if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                $fieldinfo = $profocus->fieldobj->getFieldInfoobjBykey('columnname', $columnname);
                if ($fieldinfo) {
                    $fieldname = $fieldinfo->getFieldName();
                    crm_load_class_file('cls_PickList', 'modules/PickList');
                    $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                    $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                    $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$columnname] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                }
            }
        }
    }
}

$productno_index=0;//产品编号列索引(在产品明细中的索引)
$producttoolfield_tables_columns = [];//chj 2021/3/11 42205: （https://61mis.com/kfbtest/ [^]）自定义表单36->导入：导入数据成功后，没有显示产品分录明细信息  discount_amount
for($i=0;$i<sizeof($producttoolresult);$i++) {
    $uitype=$producttoolresult[$i]['uitype'];
    $columnname=$producttoolresult[$i]['columnname'];
    $fieldlabel=$producttoolresult[$i]['fieldlabel'];
    $typeofdata=$producttoolresult[$i]['typeofdata'];
    $input_type=$producttoolresult[$i]['input_type'];
    $table_name=$producttoolresult[$i]['tablename'];

    $typedata=explode('~',$typeofdata);

    if($typedata[1]=='M'||$input_type==2)
    {

    if(!in_array($columnname.'-producttoolfield',$mapfields))
    {
         $error.='导入文件中缺少产品信息工具\''.$fieldlabel.'\'列<br>';
        // break;
    }

    $fieldlabel.='*';
    }
    if(in_array($columnname.'-producttoolfield',$mapfields)) {
        if(!in_array($columnname,$producttoolfield_tables_columns)){
            $producttoolfield_tables[$table_name][]=array($columnname,$uitype,$typeofdata, array_search($columnname.'-producttoolfield',$mapfields));
        }
        $producttoolfield_tables_columns[] = $columnname;
    }
    if(!empty($checkPicklistColumn) && $uitype==60){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
        $selcol=$table_name.':'.$columnname;
        if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
            if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                if ($focus->detailfieldobj) {
                    $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $columnname);
                    if ($fieldinfo) {
                        $fieldname = $fieldinfo->getFieldName();
                        crm_load_class_file('cls_PickList', 'modules/PickList');
                        $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                        $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                        $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$columnname] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                    }
                }
            }
        }
    }
}

$Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);
$highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
$maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
$highestColumnIndex = $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex'];//总列数

if($error!='') {
    $false = true;
    $importdatainfo=$error;
    $smarty->assign('FALSE',$false);
    $smarty->assign("IMPORTINFO",$importdatainfo);
    $smarty->assign('TOTALROWS',(sizeof($highestRow)));
    $smarty->assign('SUCCESSROWS',0);
    $smarty->assign('ERRORROWS',sizeof($highestRow));
    $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
    fwrite($filehandler,str_replace('<br>',"\r\n",$error));
    fclose($filehandler);
    ConvertTojsonString('-1',array(),$error);
} else {
    if(sizeof($highestRow)<2){
        $error .='模板文件中没有数据，导入失败！'.'<br>';
        $smarty->assign("IMPORTINFO",$importdatainfo);
        ConvertTojsonString('-1',array(),$error);
    }

    $xlsRowData=array();
    $nohaveerror=true;
    $hangshu=0;
    $shijidaoruRows=0; //实际导入的单据数量，按主表计算
    //拼接主表的导入sql脚本
    $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
    $insert_columname = array();
    $insert_values = array();
    //将所有的字段拼接到一个数组里面
    $insertfield = array_merge($field_tables,$inventory_tables);
    $newInsertfield=array_merge($insertfield,$product_tablename);
    $allinsertfield = array_merge($newInsertfield,$producttoolfield_tables);
    //拼接sql插入语句
    foreach($allinsertfield as $tablename=>$colinfo) {
        if($tablename=='ld_crmentity'){
            continue;
        }
        foreach($colinfo as $ky=>$colnames) {
            $insert_columname[$tablename][] = $colnames[0];
        }
        if(strtolower($tablename)==$module_tablename){
            if(!in_array('smcreatorid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smcreatorid';
            }
            if(!in_array('smownerid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smownerid';
            }
            if(!in_array('createdtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'createdtime';
            }
            if(!in_array('modifiedtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'modifiedtime';
            }
            $insert_columname[$tablename][] = $focus->tab_name_index[$tablename];
        }
        if(strtolower($tablename)=='ld_products'){
            if(!in_array('smcreatorid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smcreatorid';
            }
            if(!in_array('smownerid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smownerid';
            }
            if(!in_array('productname',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'productname';
            }
            if(!in_array('createdtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'createdtime';
            }
            if(!in_array('modifiedtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'modifiedtime';
            }
            if(!in_array('discontinued',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'discontinued';
            }
            if(!in_array('product_no',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'product_no';
            }
            $insert_columname[$tablename][]='productid';
        }
        if(strtolower($tablename)=='ld_productcf'){
            $insert_columname[$tablename][]='productid';
        }
        if($tablename==$detailtable){
            $insert_columname[$tablename][]='productid';
            $insert_columname[$tablename][]='id';
            $insert_columname[$tablename][]='balancepurchasecount';//未采购
            $insert_columname[$tablename][]='balanceoutproductcount';//未出库
            $insert_columname[$tablename][]='balanceinvoicecount';//未开票金额
            $insert_columname[$tablename][]='sequence_no';//序号

            //$insert_columname[$tablename][]='entitytype';//关联模块单据
            // $insert_columname[$tablename][]='parent_lineitem_id';//产品源单
            if(in_array('entitytypeid',$insert_columname[$detailtable])) {
                $insert_columname[$detailtable][]='parent_lineitem_id';
            }
        }
        if($tablename==$module_tablename_scf){
            $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename];
        }
        if($tablename==$detailtablescf){ $insert_columname[$tablename][]='lineitem_id';}

        foreach($insert_columname as $tablename => $column_fields){
            if($code_num_columnname!=''&&$importcolumnname_index['code_num']<0&&$tablename==$focus->table_name) {
                $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ','.$code_num_columnname.') values (' . generateQuestionMarks($column_fields).',?)' ;
            } else
                $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;
        }
    }

    $product_detail_fields = array_merge($field_tables,$product_tablename,$producttoolfield_tables);

    /*导入定义*/
    $import_type = $_REQUEST['choose']; //获取重复时导入方式
    $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
    $smcreatorid=$current_user->id;
    $modifiedby=$smcreatorid;
    $createdtime=date("Y-m-d H:i:s");
    $modifiedtime=$createdtime;
    $sostatus='已创建';
    $successRows=0;//成功导入的合同订单数
    $updateRows=0;//成功覆盖单据数
    $sql_split=explode(',',$field_sql[$module_tablename]);
    //用于导入完成后，更新订单的合计等
    //$sqlupdate='update ld_servicecontracts set total=?,subtotal=?, discount_type=? where servicecontractsid=?';
    $sqlupdate='update '.$module_tablename.' set currency_symbol=?,total=?,subtotal=?,discount_type=? where '.$focus->tab_name_index[$module_tablename].'=?';
    /*导入定义*/
    //  $checkimportfield = $_REQUEST['select1']; //获取选中的主表查重字段
    // $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
    $_checkproductsfield=[];
    if(!is_null($_checkproducts)&&is_string($_checkproducts))
        $_checkproductsfield = explode(',',$_checkproducts);//将产品查重字段转换为数组
    else
        $_checkproductsfield=$_checkproducts;

    $tmp_cur_row_end_line='no';
    $tmp_prouctDetail_row=0;
    $product_same_salesorder='no';
    $startimporttime=date("Y-m-d H:i:s");
    $startrow=$_REQUEST['startrow'];

    $endrow=$_REQUEST['endrow'];
    $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
    $main_module_rows=0;//跨越的主表的行数
    $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
    $row=$startrow;

    while(true){
        $hangshu++;
        $nohaveerror=true;
        $yijingtishi=true;
        //如果超过xls文件行数则退出循环
        if($row>=$maxrows){
            break;
        }

        if($main_module_rows>$between_rows)
        {
            $endrow=$row;//返回到前端，用于判断下次开始导入行数的标识
            break;
        }
        $excelrow=$row+2;
        $col=0;
        if($row+1>=$maxrows)
        {
            $tmp_cur_row_end_line='yes' ;
        }

        if($product_same_salesorder=='no')
        {
            $xlsRowData=array();
            $product_xlsRowData=array();
            $new1_service_base_contractstotal=0;
            $service_base_contractstotal=0;
            $service_contracttotal=0;
            $discount_type=0;
            $tax_discount_percent=0;
            $tax_discount_amount=0;
            $tax_adjustment=0;
            $tmp_prouctDetail_row=0;
            $productid=array();
            $nohaveerror=true;
        }

        foreach($product_detail_fields as $tablename => $colinfo){
            foreach($colinfo as $ky=>$colnames){
                $columnname=$colnames[0];

                $typedata=explode('~',$colnames[2]);
                $fieldcolIndex=$colnames[3];
                $fieldLabel=$colnames[4];
                $str=trim((string)$importdatas[$row][$fieldcolIndex]);

                $next_row_str='';
                //zkt 20240913 BUG20240912-38 对账单导入，单据编号自动生成，并没有取导入文件中的单据编号
                if($importcolumnname_index['code_num']==$fieldcolIndex&&$product_same_salesorder != 'yes')
                {
                   $checkcodenum =$str;

                }

                if(in_array($columnname,$is_checkimportfield)){
                      $_checkColumn[$columnname] = $columnname;
                      $_checkValues[$columnname] = $str;
                       if($tmp_cur_row_end_line=='no'){//如果不是最后一行则获取下一行数据，
                         $next_checkValues[$columnname]=trim((string)$importdatas[$row+1][$fieldcolIndex]);
                       }
                }


                //获取用户的lastname
                $uname = getUserFullName($current_user->id);
                //为空时获取默认值
                if($str==''){
                    if(in_array($colnames[0].'-field',$mapfields)&&in_array($tablename,$focus->tab_name)){
                        $tmpcolumnindex = array_search($colnames[0].'-field',$mapfields);
                        $str=trim($defaultvalue[$tmpcolumnindex]);
                    }
                }
                if($tablename==$detailtable){
                    if($colnames[0]=='tax_amount'){
                        $product_tax_amountIndex=$product_formula_index;
                    }
                    if($colnames[0]=='discount_percent'){
                        $product_discount_percentIndex=$product_formula_index;
                    }
                    if($colnames[0]=='discount_amount'){
                        $product_discount_amountIndex=$product_formula_index;
                    }

                }

                //日期类型
                if($typedata[0]=='D'){

                   $str=NewImportCommon::operationDate($str);

                }
                if($typedata[0]=='T'){
                    if($str==''){
                        $str=NULL;
                    }else{
                        $str=date('H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));
                    }
                }
                //日期时间类型
                if($typedata[0]=='DT'){
                    $str=NewImportCommon::operationDateTime($str);

                }
                if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)){
                //	$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
                    if(!is_numeric($str)){
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
                        $nohaveerror=false;
                    }
                }
                if($typedata[0]=='N'&&$str==''){
                    $str=NULL;
                }
                if($typedata[0]=='NN'&&$str==''){
                    $str=NULL;
                }
                if($colnames[1]!=202&&$typedata[1]=='M'&&$str==''&&$fieldcolIndex!==$importcolumnname_index['code_num']&&$columnname!='currency_id'){
                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值不能为空!<br>';
                   // $row++;
                    $nohaveerror=false;
                }

                $wareid=0;
                if($colnames[1]==151||($colnames[1]==60&&$colnames[0]=='wareid') )
                {

                    if(!empty($str))
                    {

                        $tmpsql='select * from ld_warehouse  where  status=0 and name=?';

                        $tmpresult=$adb->pquery($tmpsql,array($str));
                        if($adb->num_rows($tmpresult)>0)
                        {
                            $str=$adb->query_result($tmpresult,0,"id");
                           $wareid=$str;
                            if(!is_admin($current_user))
                            {
                                $tmpresult=$adb->pquery("
                                    select id from (
                                        SELECT 
                                            ld_warehouse.id, 
                                            ld_warehouse.`name`
                                        FROM 
                                        ld_warehouse 
                                        INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all' 
                                        where `status` = 0 and ld_warehouse.id = ?
                                        GROUP BY 
                                            ld_warehouse.id
                                        UNION ALL
                                        SELECT 
                                            ld_warehouse.id, 
                                            ld_warehouse.`name`
                                        FROM 
                                        ld_warehouse 
                                        INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
                                        INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
                                        where ld_warehouse2user.userid = ? and ld_warehouse.`status` = 0  and ld_warehouse.id = ? 
                                        GROUP BY 
                                            ld_warehouse.id
                                        UNION ALL
                                        SELECT 
                                            ld_warehouse.id, 
                                            ld_warehouse.`name`
                                        FROM 
                                        ld_warehouse 
                                        INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
                                        INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
                                        LEFT JOIN ld_users2group on ld_users2group.groupid = ld_groups.groupid
                                        where ld_users2group.userid = ? and ld_warehouse.`status` = 0 and ld_warehouse.id = ? 
                                        GROUP BY 
                                            ld_warehouse.id
                                        UNION ALL
                                        SELECT 
                                             ld_warehouse.id, 
                                            ld_warehouse.`name`
                                        FROM 
                                        ld_warehouse 
                                        INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
                                        INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
                                        LEFT JOIN ld_users on ld_users.profileid = ld_profile.profileid 
                                        where ld_users.id = ? and ld_warehouse.`status` = 0  and ld_warehouse.id = ? 
                                        GROUP BY 
                                            ld_warehouse.id
                                    ) as temp ORDER BY id
                                ",array($wareid,$current_user->id,$wareid,$current_user->id,$wareid,$current_user->id,$wareid));

                                if($adb->num_rows($tmpresult)<=0)
                                {
                                     $error.='第'.$excelrow.'行的仓库："'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"，当前操作员没有该仓库权限!<br>';
                                    $str='';
                                    $wareid=0;
                                    $nohaveerror=false;
                                }
                                else
                                {
                                    //$str=$warehourseid;
                                }
                            }
                        }
                        else
                        {
                             $error.='第'.$excelrow.'行的仓库："'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"不存在!<br>';
                             $str='';
                             $wareid=0;
                             $nohaveerror=false;
                        }

                    }


                }
              if($colnames[1]==117){

                            $checkvalue=array_keys($app_currency_strings,$str);

                        if($checkvalue[0]==''){
                            $checkvalue[0]=$str;
                        }

                        if($checkvalue[0]!="")
                          {
                              $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';
                                 $fieldResult=$adb->pquery($sqlfield,array());
                           }
                           else
                           {
                            $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where id=? order by id desc limit 0,1';
                            $fieldResult=$adb->pquery($sqlfield,array(1));
                           }
                           //37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
                            if($adb->num_rows($fieldResult)>0){
                                $arraycurrency[0]['currency_id']=$adb->query_result($fieldResult,0,'id');
                                $arraycurrency[0]['currency_symbol']=$adb->query_result($fieldResult,0,'currency_symbol');
                                $arraycurrency[0]['conversion_rate']=$adb->query_result($fieldResult,0,'conversion_rate');
                            }else{
                                $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值在数据库中不存在!<br>';
                                $str='';
                                $nohaveerror=false;
                            }
                    }
                if(array_key_exists($tablename,$focus->tab_name_index)  && $str !=''){


                    if($colnames[1]==117){



                    }
                    else
                    {
                        if($colnames[1]==151&&!empty($wareid))
                        {

                        }
                        else
                        ///获取相关信息id
                        if($colnames[1]==202)
                        {
                            $tmpentitytypestr=trim((string)$importdatas[$row][$importcolumnname_index['entitytype']]);
                          //  $importcolumnname_index['entitytype']

                            $entitytypeinfo_arr=  getProducts_entitytypeid($str,$tmpentitytypestr,$currentModule);

                            if(!is_array($entitytypeinfo_arr)||!array_key_exists('id',$entitytypeinfo_arr)||$entitytypeinfo_arr['id']<=0)
                            {
                                 $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值在数据库中不存在!<br>';
                                 $nohaveerror=false;
                            }
                        }
                        else
                        {
                            $str = $Importoop->setImprtNameToId($colnames[1],$str,$HelpDeskstr);//获取相关信息id
                            //ls 20221026 BUG0058014 销售订单导入的时候有一列字段属性为货币字段（已收定金）的数据 除了填0的都可以导入填0的数据行会提示值在数据库中不存在
                            //zkt 20230214 BUG0061590kfbcrm   报价单导入---销售负责人为必填字段----模板中输入系统中不存在的账号---仍然能够导入成功，但销售负责人字段是空值
                             if(($str==='' && $typedata[1]=='M'&&$colnames[1]!=171)||($str===0 && $typedata[1]=='M'&&$colnames[1]==53)){
                                if($Importoop->haveerrormsg()){
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                                }
                                else{
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值在数据库中不存在!<br>';
                                }
                                 $nohaveerror=false;
                            }
                        }
                    }
                }
                if($colnames[1]=='1600'){ //通过用户字段值获取成员所属部门
                    $str = $Importoop->getvaluebyfields($colnames,$str,$product_detail_fields,$importdatas[$row]);
                }
                if(array_key_exists($colnames[0],$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                    if(!empty($str)  && !in_array($str,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$colnames[0]])){ //检查导入值是否是下拉框选项
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                        $nohaveerror=false;
                    }
                }
                //模块若设置了没有工商信息不允许导入，则查询工商信息是否存在
                crm_load_class_file('cls_BusinessInformation', 'modules/Users');
                $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
                if($businessinformationobj->IsEnableBusiness()){
                    if($businessinformationobj->IsNoBusinessnoimport()&&!empty($xlsRowData['maintable']))
                    {
                        $requestvalues_arr = array();
                        foreach($xlsRowData as $reqtabtype=>$reqtabtypeinfo)
                        {
                            foreach($reqtabtypeinfo as $reqtabname=>$reqtabfields)
                            {
                                foreach($reqtabfields as $reqcolumnname=>$reqcolumnvalue)
                                {
                                    $requestvalues_arr[$reqcolumnname]=$reqcolumnvalue;
                                }
                            }
                        }
                        crm_load_function_file('getSaveBusiness','modules/Users','GetTianYanSearchInfo');
                        $businesimport = getSaveBusiness($frommodule,$requestvalues_arr);
                        if($businesimport == 'no')
                        {
                            $company_name_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                            $company_name = $requestvalues_arr[$company_name_columnname];
                            $error .="第".$excelrow."行".$company_name."工商信息不存在！"."<br>";
                            $nohaveerror=false;
                        }
                    }
                }

                if(isProductTable($tablename)){//判断是否是产品明细


                    if($focus->Detail_table == $tablename){
                        $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey('columnname',$colnames[0]);
                        if(!empty($fieldinfo)){
                            $str = $Importoop->setImprtNameToId_details($fieldinfo,$str,$row);//获取相关信息id
                        }
                    }
                    $product_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]]=vtlib_purify($str);
                    //zkt 20240416 BUG20240412-23  （弘奎）带产品分录的自定义表单（161~180），导入进去，没有产品分录
                    if(!array_key_exists($focus->Detail_table,$product_xlsRowData[$tmp_prouctDetail_row])){
                        $product_xlsRowData[$tmp_prouctDetail_row][$focus->Detail_table] = array();
                    }
                }
                elseif($product_same_salesorder=='no'){//&& strtolower($typedata[0]) !='i'
                    if(is_null($str))
                        $str='';
                     $xlsRowData[0][$tablename][$colnames[0]]=vtlib_purify($str);
                }
            }
        }

        $product_same_salesorder='yes';//判断明细是否为统一单据，yes:是,no:不是

        $conditionindex=0;
        if((is_array($is_checkimportfield)&&empty($is_checkimportfield[0]))||empty($is_checkimportfield))
        {
            $product_same_salesorder='no';
        }
        foreach($_checkValues as $check_column =>$cur_value)
        {
            //比较当前行和下一行数据查重字段的值是否相同，或下一行主表查重字段是否为空

            if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='and' || empty($importdupfields_condition[$conditionindex])))
            {
                $product_same_salesorder='no';
                 break;
            }
            else if(($importdupfields_condition[$conditionindex]=='or'||empty($importdupfields_condition[$conditionindex]))&&$cur_value==$next_checkValues[$check_column]&&$next_checkValues[$check_column]!='')
            {
                $product_same_salesorder='yes';
                break;
            }
            else  if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='or'||empty($importdupfields_condition[$conditionindex])))
            {
                $product_same_salesorder='no';
            }
            $conditionindex++;
        }

        if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){
            if($nohaveerror==false){
                $row++;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']+1;
                $xlsRowData=array();
                $nohaveerror=true;
                continue;
            }
        }

        if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){//如果当前行数据和下一行数据不相同或当前行为excel最后一行
            $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_shijidaorurows']+1;
            $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;

            $main_module_rows++;
            if($tmp_cur_row_end_line=='yes')
            {
                $endrow=$maxrows;

            }
            $k=0;
            $flag = true; //主表重复，为false时，不插入明细表
            $service_base_contractstotal=0; //合同的合计(不包含调整金额、整单折扣金额)

           // $sql='update ld_modentity_num set cur_id=cur_id+1 where semodule=?';
           // $adb->pquery($sql,array($currentModule));
            $service_contracttotal=0;//总计：合计金额+调整金额+整单折扣
            $subtotal=0;
            $tax_adjustment=$xlsRowData[0][$module_tablename]['adjustment'];//获取调整金额，调整金额是放在主表中的
            $tax_discount_percent=$xlsRowData[0][$module_tablename]['discount_percent'];//获取折扣百分比
            $tax_discount_amount=$xlsRowData[0][$module_tablename]['discount_amount'];//获取折扣直接降价
            $currency_id=$xlsRowData[0][$module_tablename]['currency_id'];//获取货币id
            if($importcolumnname_index['currency_id']<0||empty($currency_id))
            {
                //37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
                $currency_id=1;
            }else{
                //chj 2021/12/1 49046: （http://124.225.200.21:85/crm [^] [^]）海南爱恩-发票单据已关联了采购合同，但在合同详情内，部分发票金额未计入“已开票金额”内  (导入的单据没有汇率)
                $checkvalue=array_keys($app_currency_strings,$currency_id);
                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array());
                $currency_id=$adb->query_result($fieldResult,0,'id');
            }
            $temp=array();
            $uniqueid=array();
            $invenValues=array();
             $_checkCondition=array();
            $_accountid=$xlsRowData[0]['ld_servicecontracts']['accountid'];
            $main_column_is_not_exit=array();
            $_checkdupValues=array();

            if($import_type!="Insert"){ //查重判断
                $_checkdupColumn=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                foreach($xlsRowData[0] as $maintable=>$infos){
                        $temp[$maintable] =$infos;

                        foreach($is_checkimportfield as $index=>$checkField)
                        {
                            if($infos[$checkField]!='')
                            {

                                $_checkdupColumn[]=$checkField;
                                $_checkdupValues[$checkField] = $infos[$checkField];

                                 if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
                                  {
                                    $importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('columnname',$is_checkimportfield[$index+1]);
                                    $importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
                                    if($xlsRowData[0][$importcolumntablename][$is_checkimportfield[$index+1]]!='')

                                        {

                                            $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                        }
                                    else
                                        break;
                                  }
                                  else
                                  {

                                     $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                  }
                            }
                        }
                    }

                     if(is_array($_checkdupColumn)&&sizeof($_checkdupColumn)>0&&$_checkdupColumn[0]!="")
                    {
                        //进行查重
                            $main_table_sql = 'SELECT ser.'.$focus->tab_name_index[$module_tablename].' as id from '.$module_tablename.' ser LEFT JOIN
                            '.$module_tablename_scf.' scf on ser.'.$focus->tab_name_index[$module_tablename] .' =scf.'.$focus->tab_name_index[$module_tablename].'';
                            $main_table_sql .=" where (";
                            $dupcheckfield_len=sizeof($_checkColumn);
                             foreach($_checkdupColumn as $tmp_dupcheckfield=>$tmp_columnname)
                            {
                                $main_table_sql.= "  $tmp_columnname= ?  ";
                                if($_checkCondition[$tmp_columnname]!=""&&$tmp_dupcheckfield!=$dupcheckfield_len-1)
                                {
                                    $main_table_sql.=$_checkCondition[$tmp_columnname];
                                }
                            }
                            $main_table_sql.=" ) ";
                            $main_table_sql.=" and deleted=0";

                            $check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
                            $num_rows = $adb->num_rows($check_result);
                    }
                    else
                    {
                        $num_rows=0;
                    }

            }

            /*product_import_type 	产品不存在时导入方式对应的处理方式
            * NoImportRow：该行不导入  NoImportData：整单不导入  AddProduct：自动添加新产品
            */
            if(!empty($_REQUEST['product_import_type']) && ($_REQUEST['product_import_type'] == 'NoImportData' || $_REQUEST['product_import_type'] == 'NoImportRow')){
            //	$db_product_num = 0;
                //$no_product_row = 0;	//产品不存在行
                 $no_product_rows=array();//产品不存在行
                $no_product_values=array();//产品不存在列值数组
                $tmpmaysaveproducts=array();//可以保存到数据库产品临时数据

                foreach($product_xlsRowData as $productData =>$productColumn){//行循环

                    foreach($productColumn as $productTablename =>$product_Values){//表循环
                        $_checkimportfieldValues=array();
                        if($productTablename=='ld_products'){//先判断产品是否存在
                            $productno = $product_Values['product_no'];
                            $productname = $product_Values['productname'];

                            if($productname==''){
                                $productname=$productno;
                            }
                            $_product_checkcolumns=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                            $product_where='';

                            if(!empty($_checkproducts)){//产品查重字段不为空的情况下
                                foreach($_checkproducts as $index=>$product_key_column )
                                {
                                    if($product_Values[$product_key_column]!='')
                                    {
                                        $_product_checkcolumns[]=$product_key_column;
                                        $_checkimportfieldColumn[$product_key_column] = $product_key_column;
                                        $_checkimportfieldValues[$product_key_column] = $product_Values[$product_key_column];
                                        $product_checkCondition[$product_key_column]=$product_importdupfields_condition[array_search($product_key_column,$product_is_checkimportfield)];
                                    }
                                }

                                //获取产品的id
                                $product_sql = 'select productid as productid from ld_products ';
                                if(is_array($_product_checkcolumns)&&sizeof($_product_checkcolumns)>0&&$_product_checkcolumns[0]!="")
                                {

                                    $dupcheckfield_len=sizeof($_product_checkcolumns);
                                    foreach($_product_checkcolumns as $index=>$tmp_columnname)
                                    {
                                        $product_tablename=$profocus->fieldobj->getFieldInfoBykeyValue('columnname',$tmp_columnname,'tablename');
                                        if($product_tablename!='ld_products')
                                        {
                                            $leftjoin_producttablename=$product_tablename;

                                        }
                                        $product_where.= "  $tmp_columnname= ?  ";
                                        if($product_checkCondition[$tmp_columnname]!=""&&$index!=$dupcheckfield_len-1)
                                        {
                                            $product_where.=$product_checkCondition[$tmp_columnname];
                                        }
                                    }
                                    if($leftjoin_producttablename!='')
                                    {
                                        $product_sql.=' left join '.$leftjoin_producttablename.' on '.$leftjoin_producttablename.'.productid=ld_products.productid';
                                    }
                                    $product_sql .=" where ( ";
                                    $product_sql.=$product_where;
                                    $product_sql.=" ) ";
                                    $product_sql.=" and deleted=0";
                                    $product_result=$adb->pquery($product_sql,array($_checkimportfieldValues));

                                    $product_num=$adb->num_rows($product_result);

                                    if($product_num >= 1){
                                        $db_product_num++;
                                        $tmpmaysaveproducts[]=$productColumn;
                                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']+1;//该行不导入，成功导入的明细数量;

                                    }else{

                                        $no_product_row = $row - sizeof($product_xlsRowData) + 1 + $productData;
                                        $no_product_rows[]=$no_product_row;
                                        $no_product_values[]=$_checkimportfieldValues;
                                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']+1;

                                    }
                                }
                                else
                                {

                                }
                            }
                        }
                    }
                }

             $product_xlsRowData= $tmpmaysaveproducts;//把不需要导入的产品数据从数组中删除

                //整单不导入,该行不导入
                if($_REQUEST['product_import_type'] == 'NoImportData'||$_REQUEST['product_import_type'] == 'NoImportRow'){


                    foreach($no_product_rows as $tmpindex=> $no_product_rowindex)
                    {
                        if(empty($no_product_rowindex) && $no_product_rowindex != 0 )
                        {
                            break;
                        }
                        $tips="";
                        foreach($no_product_values[$tmpindex] as $tmpcolumnname=>$cellvalue)
                        {

                            $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,"fieldlabel");
                            $tips.=$fieldlabel.":".$cellvalue;
                            if($product_checkCondition[$tmpcolumnname]=='and'){
                                $tips.="和";
                            }
                            else  if($product_checkCondition[$tmpcolumnname]=='or')
                            {
                                $tips.="或";
                            }
                        }
                        if($_REQUEST['product_import_type'] == 'NoImportData')
                        {
                            $error .="第".($no_product_rowindex+2)."行 $tips 在数据中不存在，已跳过整个单据!"."<br>";
                           $flag = false;
                        }
                        else
                        {
                            $error .="第".($no_product_rowindex+2)."行 $tips 产品在数据中不存在，该行单据不导入!"."<br>";
                        }

                        //unset($product_xlsRowData[$tmpindex]) ;


                    }
                }


            }

            if($num_rows>0 && ($import_type=='Update' || $import_type=='UpdateAll') && $flag == true){ //获取重复的单据id
                $updateColumn=array();
                $updateValues=array();
                foreach($temp as $infoTablename =>$info_values){ //
                    foreach($info_values as $infoKey =>$new_info_values){
                        if (in_array($infoKey,array('approvestatus','createdtime'))) {//覆盖及覆盖(全部)时， 审批状态、创建时间不允许覆盖。
                            continue;
                        }
                        //BUG0059743 20221209 合同订单->导入->创建时间和修改时间不填写导入时，导入后显示 0000-00-00 00:00:00(if条件错误)
                        if($new_info_values != '' && $infoKey != $focus->tab_name_index[$module_tablename]){//排除导入文件中为空的数据
                            $updateColumn[$infoTablename][$infoKey] = $infoKey;
                            $updateValues[$infoTablename][$infoKey] = $new_info_values;
                        }
                    }

                }

                $focus->getModuleStatic('ModTracker');
                if($num_rows>0)
                {
                   //zkt 20220511 51548（http://121.36.206.222:85/muse/index.php）合同订单》导入，查重“合同编号”“产品编号”，导入方式为覆盖；导入后，弹窗信息没显示导入成功/失败，单据信息也没被覆盖
                   //全部为覆盖且，全部导入失败时提示信息错误，没有导入失败的提示
                    //$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                }
                $uniqueid=array();
                $all_update_value=[];
                for($i=0;$i<$num_rows;$i++){
                    $_uniqueid=$adb->query_result($check_result,$i,'id');
                    $focus->id=$_uniqueid;
                    $focus->retrieve_entity_info($focus->id,$currentModule);//BUG0059744 导致提示信息“审批状态”错误（$btnlogic->controller->column_fields 非当前行的值）
                    if ($import_type=='Update') {
                        $btnlogic->controller=$focus;
                        $editbutton=$btnlogic->getEditViewBtn();

                        if($editbutton['permit']!='yes')
                        {
                            //是否有该单据的编辑权限
                            if($btnlogic->edit_errorreason['reason']=='approve')
                            {
                                $error.='第'.$excelrow.'行单据'.$btnlogic->edit_errorreason['description'].'，不允许覆盖！<br>';
                            }
                            else
                            {
                                $error.='第'.$excelrow.'行无编辑权限，不允许覆盖！<br>';
                            }
                            continue;
                        }
                    }

                    $uniqueid[]=$_uniqueid;//插入明细要用的主表id
                    $focus->modstatic->init($focus,$focus->module_name);//记录覆盖导入日志
                    foreach($updateColumn as $updateTablename => $new_pdateValues){
                        $column = implode('=?,',$new_pdateValues) . '=?';
                        $query = 'update ' . $updateTablename . ' set ' . $column . ' where ' . $focus->tab_name_index[$updateTablename] . ' ='.$_uniqueid;
                        $adb->pquery($query,array($updateValues[$updateTablename]));
                        $all_update_value=array_merge($all_update_value,$updateValues[$updateTablename]);
                        //先删除重复合同的产品明细
                        $query_delete = " DELETE $detailtable,$detailtablescf FROM $detailtable
                        LEFT JOIN $detailtablescf ON $detailtable.lineitem_id = $detailtablescf.lineitem_id
                        where $detailtable.id=".$_uniqueid;
                        $adb->pquery($query_delete,array());
                        unset($updateColumn[$keyTablename]);
                        unset($updateValues[$keyTablename]);
                    }
                    //wym 240515 BUG20240513-41 需要在触发工作流之前修改币种字段值,否则针对币种字段的工作流触发不了(工作流只能在此循环内触发)
                    foreach($arraycurrency as $key=>$currencyarr){
                        if($uniqueid!=''){
                            $updatecurrencysql = 'update '.$module_tablename.' set currency_id=?, conversion_rate=?,currency_symbol=? where '.$focus->tab_name_index[$module_tablename].' ='.$_uniqueid;
                            $adb->pquery($updatecurrencysql,array($currencyarr['currency_id'],$currencyarr['conversion_rate'],decode_html($currencyarr['currency_symbol'])));
                        }
                    }
                    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                    if($trigger_workflow=='yes'){
                        $workflowreverseobj->setRecord($_uniqueid);
                        $focus->retrieve_entity_info($_uniqueid,$currentModule);
                        $beforefieldvalue_arr=$focus->column_fields;
                        $afterfieldvalue_arr=$all_update_value;
                        $pagemode='updated';
                        if(!empty($afterfieldvalue_arr)){
                            $workflowreverseobj->setPageMode($pagemode);
                            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                        }
                    }
                    $focus->modstatic->saveOperationLog($focus->module_name,$focus->id,'IMPORT',$import_type);
                    $focus->modstatic->triggerEvent($focus->module_name);
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
                }
            }
            if((empty($num_rows) || $import_type=='Insert') && $flag ==true){
                $_uniqueid = $adb->getUniqueID('ld_crmentity');
                $uniqueid[] = $_uniqueid;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;

                $adb->pquery($sqlcrmentity,array($_uniqueid,$currentModule));
                $all_insert_value=[];
                foreach($xlsRowData[0] as $maintable=>$infos){
                    if(empty($maintable))
                    {
                        continue;
                    }
                    if($maintable==$module_tablename){
                        foreach($infos as $key =>$values){
                            $main_column_is_not_exit[]=$key;
                        }
                        if(!in_array('smcreatorid',$main_column_is_not_exit) || $infos['smcreatorid']==''){
                            $infos['smcreatorid']=$smcreatorid;
                        }
                        if(!in_array('smownerid',$main_column_is_not_exit) || $infos['smownerid']==''){
                            $infos['smownerid']=$current_user->id;
                        }
                        if(!in_array('createdtime',$main_column_is_not_exit) || $infos['createdtime']==''){
                            $infos['createdtime']=date("Y-m-d H:i:s");
                        }
                        if(!in_array('modifiedtime',$main_column_is_not_exit) || $infos['modifiedtime']==''){
                            $infos['modifiedtime']=date("Y-m-d H:i:s");
                        }
                        if(array_key_exists('approvestatus',$infos) && (!in_array('approvestatus',$main_column_is_not_exit) || $infos['approvestatus']=='')){
                            $infos['approvestatus']='未提交';
                        }

                    }
                    $infos[$currentModule.'id']=$_uniqueid;

                    if($importcolumnname_index['code_num']>=0&&$checkcodenum==''&&$maintable==$focus->table_name)
                    {

                        $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                        $focus->Library('SystemCode')->setModuleSeqNumber('increment',$focus->module_name);
                    }
                    else if($maintable==$focus->table_name&&$code_num_columnname!=''&&($importcolumnname_index['code_num']<0))
                    {
                        //如果该模块有编号字段，但是导入的excel中没有编号列，则编号应该取当前单据的ID
                        if(array_key_exists($code_num_columnname,$infos))
                        {
                            $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                            $focus->Library('SystemCode')->setModuleSeqNumber('increment',$focus->module_name);
                        }
                        else
                        {
                             $infos=array_merge($infos,array($_uniqueid));
                             //$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                        }
                    }
                    else if($maintable==$focus->table_name)
                    {
                        if($import_type=='Insert'&&$importcolumnname_index['code_num']>=0&&$checkcodenum!='')
                           {
                                $sql=" select 1 from $maintable where $code_num_columnname=? and deleted=0 limit 1 ";
                                $result=$adb->pquery($sql,array($checkcodenum));
                                if($adb->num_rows($result)>0)
                                {

                                    //edit:can 2020-10-30 43071: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），数据模板中录入的合同编号重复，合同订单单据导入时，设置合同订单重复时导入方式为“追加”，导入成功后，单据编号应该为最大编号+1（需要补丁）
                                    $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);

                                }
                           }
                        //edit:can 20200820 新增行，要修改系统编号添加1
                        $focus->Library('SystemCode')->setModuleSeqNumber('increment',$focus->module_name);
                    }
                    $adb->pquery($field_sql[$maintable],array($infos));
                    $all_insert_value = array_merge($all_insert_value, $infos);
                    $main_column_is_not_exit=array();
                    $xlsRowData=array();
                }
                foreach($arraycurrency as $key=>$currencyarr){
                    if($uniqueid!=''){
                        $updatecurrencysql = 'update '.$module_tablename.' set currency_id=?, conversion_rate=?,currency_symbol=? where '.$focus->tab_name_index[$module_tablename].' ='.$_uniqueid;
                        $adb->pquery($updatecurrencysql,array($currencyarr['currency_id'],$currencyarr['conversion_rate'],decode_html($currencyarr['currency_symbol'])));
                    }
                }
                //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                if($trigger_workflow=='yes'){
                    $workflowreverseobj->setRecord($_uniqueid);
                    $beforefieldvalue_arr=[];
                    $afterfieldvalue_arr=$all_insert_value;
                    $pagemode='creation';
                    if(!empty($afterfieldvalue_arr)){
                        $workflowreverseobj->setPageMode('creation');
                        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                    }
                }
            }

            if($num_rows>0 && $import_type=='Abort' && $flag == true){
                $xlsRowData=array();
                $product_xlsRowData=array();
                $error .="第".$excelrow."行$main_fieldlabel_dup_tip 重复，已做跳过处理!"."<br>";
                $flag = false;
            }
            if($flag==true){
                 if(($currentModule=='OutboundOrder'||$currentModule=='Stock')&&$_uniqueid>0)
                 {
                    $sql='select productid from '.$focus->Detail_table.' where id=?';
                    $tmpresult=$adb->pquery($sql,array($_uniqueid));
                    $tmprows=$adb->num_rows($tmpresult);
                    for($tmp_i=0;$tmp_i<$tmprows;$tmp_i++)
                    {
                        $updateStockQty_ProductID_arr[$adb->query_result($tmpresult,0,'productid')]=$adb->query_result($tmpresult,0,'productid');

                    }

                 }
                if($productid[0]<=0 )$productid = array();
                //开始导入产品明细表
                $o=0;
                $producttmprowindex=0;
                $tmp_entitytype="";//原单类型
                $source_listids=array();

                foreach($product_xlsRowData as $productData =>$productColumn){//行循环
                    $ishaveentity_save="yes";//如果有原单导入，是否保存该行数据
                    foreach($productColumn as $productTablename =>$product_Values){//表循环
                        $_checkimportfieldValues=array();
                        if($productTablename=='ld_products'){//先判断产品是否存在
                            $productno = $product_Values['product_no'];
                            $productname = $product_Values['productname'];

                            if($productname==''){
                                $productname=$productno;
                            }
                          $_product_checkcolumns=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                          $product_where='';
                            if(!empty($_checkproducts)){//产品查重字段不为空的情况下
                                 foreach($_checkproducts as $index=>$product_key_column )
                                {
                                    $pro_tmpfieldinfo=$profocus->fieldobj->getFieldInfoobjBykey("fieldname",$product_key_column);

                                    if($productColumn[$pro_tmpfieldinfo->getTableName()][$product_key_column]!='')
                                    {
                                        $_product_checkcolumns[]=$product_key_column;
                                        $_checkimportfieldColumn[$product_key_column] = $product_key_column;
                                        $_checkimportfieldValues[$product_key_column] = trim($productColumn[$pro_tmpfieldinfo->getTableName()][$product_key_column]);
                                        $product_checkCondition[$product_key_column]=$product_importdupfields_condition[array_search($product_key_column,$product_is_checkimportfield)];
                                    }

                                }

                                //获取产品的id
                                $product_sql = 'select ld_products.productid as productid from ld_products ';
                                 if( is_array($_product_checkcolumns)&&sizeof($_product_checkcolumns)>0&&$_product_checkcolumns[0]!="")
                                 {
                                     $dupcheckfield_len=sizeof($_product_checkcolumns);

                                         foreach($_product_checkcolumns as $index=>$tmp_columnname)
                                        {

                                            $product_tablename=$profocus->fieldobj->getFieldInfoBykeyValue('columnname',$tmp_columnname,'tablename');
                                            if($product_tablename!='ld_products')
                                            {
                                                $leftjoin_producttablename=$product_tablename;

                                            }
                                            $product_where.= "  $tmp_columnname= ?  ";
                                            if($product_checkCondition[$tmp_columnname]!=""&&$index!=$dupcheckfield_len-1)
                                            {
                                                $product_where.=$product_checkCondition[$tmp_columnname];
                                            }
                                        }
                                        if($leftjoin_producttablename!='')
                                        {
                                            $product_sql.=' left join '.$leftjoin_producttablename.' on '.$leftjoin_producttablename.'.productid=ld_products.productid';

                                        }
                                        $product_sql .=" where ( ";
                                        $product_sql.=$product_where;
                                        $product_sql.=" ) ";
                                        $product_sql.=" and deleted=0";

                                        $product_result=$adb->pquery($product_sql,array($_checkimportfieldValues));
                                        $product_num=$adb->num_rows($product_result);
                                 }
                                 else
                                 {
                                    $product_num=0;
                                 }

                            }

                          $productid=array();

                            if($product_num>0){//大于0，表示存在产品，直接获取产品id即可
                                    $productid[]=$adb->query_result($product_result,0,0);

                            }else{//导入的产品不存在，需要导入产品
                                if(!empty($_REQUEST['product_import_type']) && $_REQUEST['product_import_type'] == 'AddProduct'){
                                    $profocus->Library('SystemCode')->setModuleSeqNumber("increment", 'Products');
                                    $product_id=$adb->getUniqueID('ld_crmentity');
                                    $productid[]=$product_id;

                                    $column_is_not_exit=array();//原来获取所有的columnname，后面原来判断部分字段在导入文件中是否存在
                                    foreach($product_Values as $key =>$productslFieldValues){
                                        $products_fieldValuess[$key]=$productslFieldValues;
                                        $column_is_not_exit[]=$key;
                                    }

                                    if(!in_array('smcreatorid',$column_is_not_exit)){
                                        $products_fieldValuess['smcreatorid']=$smcreatorid;
                                    }
                                    if(!in_array('smownerid',$column_is_not_exit)){
                                        $products_fieldValuess['smownerid']=$smcreatorid;
                                    }
                                    if(!in_array('productname',$column_is_not_exit) || $products_fieldValuess['productname']==''){
                                        $products_fieldValuess['productname']=$productname;
                                    }
                                    if(!in_array('createdtime',$column_is_not_exit)){
                                        $products_fieldValuess['createdtime']=date("Y-m-d H:i:s");
                                    }
                                    if(!in_array('modifiedtime',$column_is_not_exit)){
                                        $products_fieldValuess['modifiedtime']=date("Y-m-d H:i:s");
                                    }
                                    if(!in_array('discontinued',$column_is_not_exit)){
                                        $products_fieldValuess['discontinued']=0;
                                    }
                                    if(!in_array('product_no',$column_is_not_exit)||$products_fieldValuess['product_no']==''){
                                        $products_fieldValuess['product_no']=SystemCode::getPrevStr("Products",$product_id).$product_id;
                                    }
                                    $products_fieldValuess['productid']=$product_id;
                                    $adb->pquery($sqlcrmentity,array($product_id,'Products'));

                                    $adb->pquery($field_sql[$productTablename],array($products_fieldValuess));
                                    //ld_productcf 信息导入
                                    if(!empty($product_id) && !empty($productColumn['ld_productcf']) && $field_sql['ld_productcf']){
                                        $productcfFieldValuess = array();
                                        foreach($productColumn['ld_productcf'] as $key =>$productcfFieldValues){
                                            $productcfFieldValuess[$key]=$productcfFieldValues;
                                        }
                                        $productcfFieldValuess[] = $product_id;
                                        $adb->pquery($field_sql['ld_productcf'],$productcfFieldValuess);
                                    }
                                    $sql='update ld_modentity_num set cur_id=lpad((cur_id+1),length(cur_id),"0") where semodule=?';
                                    $adb->pquery($sql,array('Products'));
                                    $products_fieldValuess=array();
                                }else if(!empty($_REQUEST['product_import_type']) && $_REQUEST['product_import_type'] == 'NoImportRow'){
                                    $successRows--;
                                    //$error .="第".($row-sizeof($product_xlsRowData)+$producttmprowindex)."行产品在数据中不存在，已做跳过处理!"."<br>";
                                }
                            }
                        }
                        if($productTablename==$detailtable){
                            $haveentityids=array();//查询有源单的单据ID的集合
                            $source_entitytype='';
                            for($i=0;$i<sizeOf($uniqueid);$i++){
                                $invenValues=$productColumn[$detailtable];
                                if($productid[0] > 0){
                                    $invenValues['productid']=$productid[0];
                                    $updateStockQty_ProductID_arr[$productid[0]]=$productid[0];
                                    $invenValues['id']=$uniqueid[$i];
                                    $invenValues['balancepurchasecount']=$invenValues['quantity'];
                                    $invenValues['balanceoutproductcount']=$invenValues['quantity'];
                                    $invenValues['balanceinvoicecount']=$invenValues['quantity'];
                                    $invenValues['sequence_no']=$producttmprowindex+1;

                                    if($invenValues['entitytypeid'])
                                    {
                                        //获取源单信息(源单id，源单name)
                                        $sourInformation=getProducts_entitytypeid($invenValues['entitytypeid'],$invenValues['entitytype'],$currentModule);
                                        if(empty($sourInformation['id'])&&empty($sourInformation['fieldname'])&&!empty($entitytype)){
                                            //excel中源单类型不为空，但是匹配失败，这种情况不导入
                                            $invenValues['entitytype']='';
                                            $invenValues['parent_lineitem_id']='';
                                        }else{
                                            $invenValues['entitytypeid']= $sourInformation['id'];
                                            $invenValues['entitytype']=$sourInformation['fieldname'];

                                            $invenValues['parent_lineitem_id']=getProducts_lineitem_id($invenValues['entitytypeid'],$productid[0]);
                                            if(empty($invenValues['parent_lineitem_id'])) {
                                                $invenValues['entitytypeid']= 0;
                                                $invenValues['entitytype']='';
                                            }
                                            $haveentityids[]=$uniqueid[$i];
                                            $source_listids[]= $sourInformation['id'];
                                            $source_entitytype=$sourInformation['fieldname'];
                                            if($tmp_entitytype!=""&&$tmp_entitytype!=$sourInformation['fieldname']) {
                                                break;//34216: （1.6登录）出库单导入：导入源单类型不一致的源单，应只导入与第一个源单类型匹配的明细
                                            }
                                            if($tmp_entitytype=="") {
                                                $tmp_entitytype=$sourInformation['fieldname'];
                                            }
                                        }
                                    }
                                    //zkt 20230626 BUG0068389 	批量导入出库单，产品规格型号为空  ---模板中分录有源单类型列但是不显示源单列，会导致sql报错(设置值没有parent_lineitemid_id,$invenValues里面有)
                                    else if(stripos($field_sql[$detailtable],'parent_lineitem_id')!==false||stripos($field_sql[$detailtable],'entitytype')!==false)
                                    {
                                        if(stripos($field_sql[$detailtable],'parent_lineitem_id')!==false){
                                            $invenValues['parent_lineitem_id']=0;
                                        }
                                        if(stripos($field_sql[$detailtable],'entitytype')!==false){
                                            $invenValues['entitytype']='';
                                        }
                                    }
                                    $kh[$o] = $invenValues['tax_amount'];

                                    $adb->pquery($field_sql[$detailtable],array($invenValues));

                                    $lineitem_id=$adb->getLastInsertID();
                                    $invenValuescf=$productColumn[$detailtablescf];

                                    if(is_array($invenValuescf)&&sizeof($invenValuescf)>0)
                                    {
                                         $adb->pquery($field_sql[$detailtablescf],array($invenValuescf,$lineitem_id));
                                    }
                                    else
                                        $adb->pquery($field_sql[$detailtablescf],array($lineitem_id));

                                    $k++;

                                    $invenValues=array();
                                }
                            }
                            $o++;
                        }
                    }
                    $producttmprowindex++;
                }
                //}
            }
            if(!$focus->modstatic) {
                $focus->getModuleStatic('ModTracker');
            }
            if($flag==true){
                //计算合计
                foreach($kh as $key =>$hejijine){
                    $service_base_contractstotal +=$hejijine;
                }
                $kh=array();

                //导入数据后，计算合计
                foreach($arraycurrency as $key=>$currencyarr){
                    if($uniqueid!=''){
                        $updatecurrencysql = 'update '.$module_tablename.' set currency_id=?, conversion_rate=?,currency_symbol=? where '.$focus->tab_name_index[$module_tablename].' in('.implode(',',$uniqueid).')';
                        $adb->pquery($updatecurrencysql,array($currencyarr['currency_id'],$currencyarr['conversion_rate'],decode_html($currencyarr['currency_symbol'])));
                    }
                }

                if(empty($tax_adjustment) || $tax_adjustment==0){
                    $tax_adjustment=0;
                }
                if(empty($tax_discount_amount) || $tax_discount_amount==0){
                    $tax_discount_amount=0;
                }

                if(empty($tax_discount_percent) || $tax_discount_percent==0){
                    $new_tax_discount_percent=0;
                    $discount_type=0;
                }else{
                    $discount_type=1;
                    $zhehoujiage = $service_base_contractstotal*($tax_discount_percent/100);
                    $new_tax_discount_percent = $service_base_contractstotal-($service_base_contractstotal/$tax_discount_percent);
                    $service_base_contractstotal =$new_tax_discount_percent;
                }
                $sql_currency_id = 'select currency_symbol,conversion_rate from ld_currency_info  where id=?;';
                $currency_id_result = $adb->pquery($sql_currency_id,array($currency_id));
                $currency_id_fuhao = $adb->query_result($currency_id_result,0,0);
                $conversion_rate=$adb->query_result($currency_id_result,0,1);
                $service_contracttotal +=$service_base_contractstotal+($tax_adjustment+$tax_discount_amount);

                if(is_array($uniqueid)){
                    foreach( $uniqueid as $tmpid) {
                        $sql='select total,subtotal from '.$focus->table_name.' where '.$focus->tab_name_index[$module_tablename].'=?';
                        $result=$adb->pquery($sql,array($tmpid));
                        $prevtotal=$adb->query_result($result,0,'total');
                        $prevsubtotal=$adb->query_result($result,0,'subtotal');

                        $new_sqlupdate='update '.$module_tablename.' set currency_symbol=?,conversion_rate=?,total=?,subtotal=?,discount_type=? where '.$focus->tab_name_index[$module_tablename].'=?';
                        $adb->pquery($new_sqlupdate,array($currency_id_fuhao,$conversion_rate,$service_contracttotal,$subtotal,$discount_type,$tmpid)); //如查重后，有多个合同的情况下，更新合同的合计金额

                        $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldname');
                        if(!empty($fieldname))
                            $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevtotal,$service_contracttotal);
                        $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'subtotal','fieldname');
                        if(!empty($fieldname))
                            $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevsubtotal,$service_contracttotal);

                        //zkt 20230801 BUG0070296  客户模块，最新订单日期字段不会根据“发货日期”系统原本的签约日期字段回填到客户模块的最新订单日期。订单有导入的情况。 导入时未反写所致，替换补丁并清除缓存即可
                        if($currentModule=='SalesOrder') {
                            //更新对应客户最新进度和最新联系日期，销售机会最新联系日期
                            $tmpupdatefocus = CRMEntity::getInstance($currentModule);
                            $tmpupdatefocus->retrieve_entity_info($tmpid,$currentModule);
                            $tmpaccountids = [];
                            $tmppotentialids = [];
                            if (!empty($tmpupdatefocus->column_fields['account_id']))
                                $tmpaccountids[$tmpupdatefocus->column_fields['account_id']] = $tmpupdatefocus->column_fields['account_id'];
                            if (sizeof($tmpaccountids) > 0) {
                                $tmpupdatefocus->updateRelatedTableInfo('ld_account', $tmpaccountids);
                            }
                            if (!empty($tmpupdatefocus->column_fields['potential_id']))
                                $tmppotentialids[$tmpupdatefocus->column_fields['potential_id']] = $tmpupdatefocus->column_fields['potential_id'];

                            if (sizeof($tmppotentialids) > 0) {
                                $tmpupdatefocus->updateRelatedTableInfo('ld_potential', $tmppotentialids);
                            }
                        }
                    }
                }else{
                    $sql='select total,subtotal from '.$focus->table_name.' where '.$focus->tab_name_index[$module_tablename].'=?';
                    $result=$adb->pquery($sql,array($uniqueid));
                    $prevtotal=$adb->query_result($result,0,'total');
                    $prevsubtotal=$adb->query_result($result,0,'subtotal');

                    $adb->pquery($sqlupdate,array($currency_id_fuhao,$conversion_rate,$service_contracttotal,$subtotal,$discount_type,$uniqueid)); //更新合同的合计金额
                    $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldname');
                    if(!empty($fieldname))
                        $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$uniqueid,$prevtotal,$service_contracttotal);
                    $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'subtotal','fieldname');
                    if(!empty($fieldname))
                         $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$uniqueid,$prevsubtotal,$service_contracttotal);
                }

                require_once(globalStatic::$root_directory."include/Stock/CommonStock.php");

                if(!empty($source_entitytype)){
                    //原单不为空
                    $source_listids=array_unique($source_listids);
                    $sourceupdatesql='update '.$module_tablename.' set entitytype=?,source_list=? where '.$focus->table_index.' in(?);';
                    $adb->pquery($sourceupdatesql,array($source_entitytype,implode(',',$source_listids), implode(',',$uniqueid)));
                }

                for($tmpsourcei=0;$tmpsourcei<sizeof($haveentityids);$tmpsourcei++)
                {
                    if($haveentityids[$tmpsourcei]=="")
                     {
                        continue;
                     }
                    //反写源单数量
                    cls_Source_InverseCompute::Source_InveverseCompute($currentModule,$haveentityids[$tmpsourcei]);
                    if($currentModule=='OutboundOrder')
                    {
                        //编辑单据反写收款单明细字段
                        $sendfocus = CRMEntity::getInstance('CashBill');
                        $sendfocus->updateSourceInfo($haveentityids[$tmpsourcei],'OutboundOrder');
                    }
                    else if($currentModule=='Stock')
                    {
                        //编辑单据反写付款单明细表字段
                        $sendfocus = CRMEntity::getInstance('SendCashBill');
                        $sendfocus->updateSourceInfo($haveentityids[$tmpsourcei],'Stock');
                    }
                }
            }
        }
        $tmp_prouctDetail_row++;
        $row++;
    }


    $endrow=$row;//明细的行数不是固定的。
    include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');

    $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
    $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
    /*if($endrow>=$maxrows&&($addimportrows>0||$updateRows>0))
    {
        $sql='update ld_modentity_num set cur_id=LPAD((cur_id+?),length(cur_id),"0") where semodule=? and active=1;';
        if(strtolower($import_type)=='insert'||strtolower($import_type)=='abort')
             $adb->pquery($sql,array($addimportrows,$currentModule));
        else
            $adb->pquery($sql,array($updateRows,$currentModule));
    }*/
    if(($currentModule=='OutboundOrder'||$currentModule=='Stock'))
    {
        //edit:can 2020-12-23 43872: （61mis.com/kfbcrm）库存管理-出库单；系统参数设置中，“设置出库和入库类库单据更新库存数量的触发点”为保存时；批量导入出库单单据，在产品详情中，库存数量没变化
        foreach($updateStockQty_ProductID_arr as $tmpproductid)
        {
            insertProductQty($tmpproductid,0,'');//更新产品的总库存数量
        }
    }

    $_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"].$error;

    $tmp['timedescription']=$time_description;
    $tmp['cur_progress_step']=$cur_progress_step;
    $tmp['endimporttime']=$endimporttime;
    $tmp['endrow']=$endrow-1;
    ConvertTojsonString(1,$tmp,'success');
}

?>