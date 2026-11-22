<?php
//editor:gyq_162 reason:产品明细导入   2019/12/9 17:01
global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony'] = 'yes';
$filename = $_REQUEST['filename'];
if (empty($filename)) {
    $frommodule = $_REQUEST['frommodule'];
    $focus = CRMEntity::getInstance($frommodule);
    $arr['modulelabel'] = gettranstab($frommodule);
    $arr['dupfieldlabel'] = getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel'] = getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel'] = getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel'] = getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel'] = getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("STEPINDEX", $_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL", $arr);
    $tmp['content'] = $smarty->fetch('ImportXlsNew/ThreeImport.tpl');
    $tmp['title'] = getFixedLabel("IMPORT") . $arr['modulelabel'];
    ConvertTojsonString(1, $tmp, 'success');
}
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
  require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
include(globalStatic::$root_directory . 'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory . 'modules/XlsImportNew/NewImportCommon.php');
require_once globalStatic::$root_directory . 'PHPExcel/PHPExcel/IOFactory.php';
unset($_SESSION['cls_productDetailsHtml_obj']);
crm_load_class_file('ProductToolFields','include/ProductDetails');
$detailfieldobj=ProductToolFields::getInstance($currentModule);
$focus = CRMEntity::getInstance($currentModule);
$profocus = CRMEntity::getInstance('Products');
$smarty = new lingdangCRM_Smarty();
$detailtable = $focus->Detail_table;
$detailtablescf = $focus->Detail_table_scf;
//产品表
$producttable = $profocus->tab_name;
//查重字段和条件
$product_checkimportfield = implode(',', json_decode($_REQUEST['detail_importdupcheckfields'], true));
$product_importdupfields_condition = json_decode($_REQUEST['detail_importdupfields_condition'], true);//查重字段条件

//导入字段
$mapfields = json_decode($_REQUEST['mapped_fields']);
//导入的字段名称对应值
$defaultvalue = json_decode($_REQUEST['defaultvalue']);
//产品分录字段数组
$producttoolresult = $_SESSION['detailfield_' . $currentModule . '_' . $current_user->id];
//产品字段
$product_result = $_SESSION['productfield_' . $currentModule . '_' . $current_user->id];
//拼接主表的导入sql脚本
$sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
//导入特殊字段
$importcolumnname_index = array('smownerid' => -1, 'smcreatorid' => '-1', 'code_num' => -1, 'total' => -1
, 'currency_id' => -1, 'servicecontracts_start_date' => -1
, 'servicecontracts_end_date' => -1, 'entitytype' => -1, 'entitytypeid' => -1);//导入字段在excel中的列位置,entitytype:目前是合同订单
//产品明细自定义表导入字段
$producttoolfield_tables[$detailtablescf] = array();
//是否有导入错误
$nohaveerror = true;
//字段对应Excel中的列数
$fieldcolIndex = 0;
//错误信息
$error = '';
//查重条件翻译
$conditionorlabel = getFixedLabel('OR');
$conditionandlabel = getFixedLabel('SEARCHAND');
//将选中的产品查重字段转为数组
$product_is_checkimportfield = explode(',', $product_checkimportfield);

//产品表导入字段
$product_tablename['ld_products'] = array();
//产品自定义表导入字段
$product_tablename['ld_productcf']=array();
$havecolums = array();
// wym 240423 XUQIU20240402-03 检查下拉框字段
$checkPicklist=getUsersettingByLabel($currentModule, $current_user->id,'ImportDetailCheckPicklist');
if(!empty($checkPicklist) && $checkPicklist!='no' && $checkPicklist!='yes'){//yes代表虽然开启了检查,但没有设置检查字段
    $checkPicklistColumn=explode('##',$checkPicklist);
}

for ($i = 0; $i < sizeof($product_result); $i++) {
    $uitype = $product_result[$i]['uitype'];
    $columnname = $product_result[$i]['columnname'];
    if (in_array($columnname, $havecolums)) {
        continue;
    }
    $havecolums[] = $columnname;
    $typeofdata = $product_result[$i]['typeofdata'];
    $fieldlabel = $product_result[$i]['fieldlabel'];
    $table_name = $product_result[$i]['tablename'];
    $typedata = explode('~', $typeofdata);

    if (in_array($columnname . '-products', $mapfields)) {
        if ($typedata[1] == 'M') {
            $product_tablename[$table_name][] = array($columnname, $uitype, 'V~M', array_search($columnname . '-products', $mapfields), $fieldlabel);
        } else {
            $product_tablename[$table_name][] = array($columnname, $uitype, 'V~O', array_search($columnname . '-products', $mapfields), $fieldlabel);
        }
    } else {
        //editor:gyq_20191223 reason:必填字段只限于查重字段
        /*if ($typedata[1] == 'M') {
            //28113: 创彩账套（192.168.3.5:85/crm,6.6.5SP3）合同订单>导入：当导入文件中没有必填项产品列的时候，结果导入成功了
            $error .= '导入文件中缺少产品信息工具\'' . $fieldlabel . '\'列<br>';
        }*/
    }
    $importcolumnname_index[$columnname] = array_search($columnname . '-producttoolfield', $mapfields);
    if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
        $selcol=$table_name.':'.$columnname;
        if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
            if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                $fieldinfo = $profocus->fieldobj->getFieldInfoobjBykey("columnname", $columnname);
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

$allinsertfield  = $product_tablename;

//拼接sql插入语句 //zxm  2021-1202 导入的时候  产品不存在 则新增产品--start
foreach($allinsertfield as $tablename=>$colinfo)
{
    if($tablename=='ld_crmentity'){
        continue;
    }
    foreach($colinfo as $ky=>$colnames)
    {
        $insert_columname[$tablename][] = $colnames[0];
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
    foreach($insert_columname as $tablename => $column_fields){
        $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;
        if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
            $selcol=$table_name.':'.$columnname;
            if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $columnname);
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
$importcolumnname_index['servicecontracts_start_date'] = array_search('servicecontracts_start_date-producttoolfield', $mapfields);
$importcolumnname_index['servicecontracts_end_date'] = array_search('servicecontracts_end_date-producttoolfield', $mapfields);


$productno_index = 0;//产品编号列索引(在产品明细中的索引)


for ($i = 0; $i < sizeof($producttoolresult); $i++) {

    $uitype = $producttoolresult[$i]['uitype'];
    $columnname = $producttoolresult[$i]['columnname'];
    $fieldlabel = $producttoolresult[$i]['fieldlabel'];
    $typeofdata = $producttoolresult[$i]['typeofdata'];
    $input_type = $producttoolresult[$i]['input_type'];
    $table_name = $producttoolresult[$i]['tablename'];
    $typedata = explode('~', $typeofdata);
    //editor:gyq_20191223 reason:必填字段只限于查重字段
    /*if ($typedata[1] == 'M' || $input_type == 2) {

        if (!in_array($columnname . '-producttoolfield', $mapfields)) {
            $error .= '导入文件中缺少产品信息工具\'' . $fieldlabel . '\'列<br>';
        }
        $fieldlabel .= '*';
    }*/
    if (in_array($columnname . '-producttoolfield', $mapfields)) {

        $producttoolfield_tables[$table_name][] = array($columnname, $uitype, $typeofdata, array_search($columnname . '-producttoolfield', $mapfields), $fieldlabel);
        if(!empty($checkPicklistColumn) && $uitype==60){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
            $selcol=$table_name.':'.$columnname;
            if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                    $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey("columnname", $columnname);
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
$highestRow = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_highestrow'];//获取行号数组
$maxrows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_maxrows'];
$highestColumnIndex = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_highestColumnIndex'];//总列数
$failuredetailscount = 0;//该行不导入，失败导入的明细数量
//`````导入成功判断,错误给出提示
if ($error != '') {
    $false = true;
    $importdatainfo = $error;
    $smarty->assign('FALSE', $false);
    $smarty->assign("IMPORTINFO", $importdatainfo);
    $smarty->assign('TOTALROWS', (sizeof($highestRow)));
    $smarty->assign('SUCCESSROWS', 0);
    $smarty->assign('ERRORROWS', sizeof($highestRow));
    $filehandler = fopen('storage/importlog_' . $currentModule . '_' . $current_user->id . '.txt', 'w+');
    fwrite($filehandler, str_replace('<br>', "\r\n", $error));
    fclose($filehandler);
    ConvertTojsonString('-1', array(), $error);

} else {
    if (sizeof($highestRow) < 2) {
        $error .= '模板文件中没有数据，导入失败！' . '<br>';

        $importdatainfo = $error;
        $false = true;
        $smarty->assign('FALSE', $false);
        $smarty->assign("IMPORTINFO", $importdatainfo);
        ConvertTojsonString('-1', array(), $error);

    }

    $xlsRowData = array();

    $nohaveerror = true;

    $hangshu = 0;
    $product_detail_fields = array_merge($product_tablename, $producttoolfield_tables);
    /*导入定义*/
    $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
   
    $smcreatorid = $current_user->id;
    $modifiedby = $smcreatorid;
    $createdtime = date("Y-m-d H:i:s");
    $modifiedtime = $createdtime;

    $_checkproductsfield = $product_is_checkimportfield;
    $_checkproducts=$_checkproductsfield;//edit:can 53169:http://120.78.122.113/crm/，设计管理——成本预算清单，完善表头信息然后导入明细（表格见附件），查重条件选择产品名称且规格型号，导入完成后保存，保存之后发现所有的明细都变成一样的了，详情见视频
    $tmp_cur_row_end_line = 'no';
    $tmp_prouctDetail_row = 0;
    $product_same_salesorder = 'no';

    $startrow = $_REQUEST['startrow'];//0
    $endrow = $_REQUEST['endrow'];//4
    $between_rows = $endrow - $startrow;//每次导入的行数（目前是5条,(0-4))
    $main_module_rows = 0;//跨越的主表的行数
    $VersionInfo = getVersionInfo();
    if($VersionInfo['account'] == 'haige' && $frommodule == 'Quotes'){
        //海格报价单界面产品分录信息
        $haigedetails=$_SESSION['import_' . $currentModule . '_' . $current_user->id . 'haigedetails'];
        $haigeproductdetails=$haigedetails['productdetails'];
        $haigegroupnames_arr = $haigedetails['groupnames_arr'];
        $haigechangequantity=array();
        $discountnoeditarr = array();
        
    }
    elseif($VersionInfo['account'] == 'haige' &&$frommodule == 'SalesOrder'&& !empty($_REQUEST['haigequoteid'])){
        $haigeproduct_to_info = array();
        $tmpsql = 'select lineitem_id,productid,pricefactor,standardprice,taxprice,discount_percent from ld_quotesdetail where id = ?';
        $tmpresult = $adb->pquery($tmpsql,array($_REQUEST['haigequoteid']));
        $rows=$adb->num_rows($tmpresult);
        if($rows>0){
            for($tmpi=0;$tmpi<$rows;$tmpi++){
                $tmplineitem_id = $adb->query_result($tmpresult,$tmpi,'lineitem_id');
                $tmpproductid = $adb->query_result($tmpresult,$tmpi,'productid');
				$tmppricefactor = $adb->query_result($tmpresult,$tmpi,'pricefactor');
				$tmpstandardprice = $adb->query_result($tmpresult,$tmpi,'standardprice');
				$tmptaxprice = $adb->query_result($tmpresult,$tmpi,'taxprice');
				$tmpdiscount_percent = $adb->query_result($tmpresult,$tmpi,'discount_percent');
				
                $haigeproduct_to_info[$tmpproductid]['lineitem_id'] = $tmplineitem_id;
				$haigeproduct_to_info[$tmpproductid]['pricefactor'] = $tmppricefactor;
				$haigeproduct_to_info[$tmpproductid]['standardprice'] = $tmpstandardprice;
				$haigeproduct_to_info[$tmpproductid]['taxprice'] = $tmptaxprice;
				$haigeproduct_to_info[$tmpproductid]['discount_percent'] = $tmpdiscount_percent;
            }
        }
    }
    //````````````需要导入的Excel表中数据
    $importdatas = $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_data"];
    $row = $startrow;
    $Importoop = new NewImport_Xls($importcolumnname_index, $currentModule);
    //$importdatas对应的格式化产品导入数组
    $productList = array();
    while (true) {
        $hangshu++;//行数
        $nohaveerror = true;//没有错误
        $yijingtishi = true;//已经提示
        //如果超过xls文件行数则退出循环
        if ($row >= $maxrows) {
            break;
        }
        if ($main_module_rows > $between_rows) {
            $endrow = $row;//返回到前端，用于判断下次开始导入行数的标识
            break;
        }
        $excelrow = $row + 2;//excel行从第二行开始
        if ($product_same_salesorder == 'no') {
            //一定要这样做，只有不为同一条单据才可以重新初始一下变量
            $xlsRowData = array();
            $product_xlsRowData = array();
            $productid = array();
            $nohaveerror = true;
            $new1_service_base_contractstotal = 0;
            $discount_type = 0;
            $tmp_prouctDetail_row = 0;
        }

        $col = 0;
        if ($row + 1 >= $maxrows) {

            $tmp_cur_row_end_line = 'yes';
        }
        //```````````循环$product_detail_fields产品表字段和合同订单分录字段
        foreach ($product_detail_fields as $tablename => $colinfo) {
            $startdate = "";
            $enddate = "";
            foreach ($colinfo as $ky => $colnames) {
                $columnname = $colnames[0];

                $typedata = explode('~', $colnames[2]);
                //字段对应Excel中的列数
                $fieldcolIndex = $colnames[3];
                $fieldLabel = $colnames[4];
                //导入的字段值
                $str = trim((string)$importdatas[$row][$fieldcolIndex]);
                $next_row_str = '';
                if ($fieldcolIndex == $importcolumnname_index['code_num']) {
                    $checkcodenum = $str;
                }
                //获取用户的lastname
                $uname = $current_user->last_name;
                //为空时获取默认值
                if ($str == '') {
                    //$str = trim($defaultvalue[$colnames[0] . '-field-defaultvalue']);
                    $str = trim($defaultvalue[$colnames[3]]);

                }
                //``````````导入的字段，特定类型额外处理Begin
                //editor:gyq_20191226 reason:去除原导入时的录入值诸多判断
                //0038951: （51mis.com/kfbcrm）合同订单>产品分录导入： 1.查重字段选择“产品名称”，添加数据文件 ，点击下一步，导入失败 2.合同订单导入日志提示“"最近价格(含税)"列内容为非法数字!” 3.导入数据模板中"最近价格(含税)"列非必填项并没有录入
                //日期类型
                if ($typedata[0] == 'D') {

                    if ($str == '') {
                        $str = NULL;
                    } else {

                        if (sizeof(explode('/', $str)) < 2 && sizeof(explode('-', $str)) < 2) {
                            if (sizeof(explode('.', $str)) == 3) {
                                $datastrs = explode('.', $str);
                                if (strlen($datastrs[0]) < 4) {
                                    $datastrs[0] = "20" . $datastrs[0];
                                }
                                $str = $datastrs[0] . '-' . $datastrs[1] . '-' . $datastrs[2];

                            } else
                                $str = date('Y-m-d', (PHPExcel_Shared_Date::ExcelToPHP($str)));
                        } else if (sizeof(explode('/', $str)) == 3) {
                            $datastrs = explode('/', $str);
                            if (strlen($datastrs[2]) == 4) {
                                $str = $datastrs[2] . '-' . $datastrs[1] . '-' . $datastrs[0];

                            }
                        }

                    }
                }
                if ($typedata[0] == 'T') {
                    if ($str == '') {
                        $str = NULL;
                    } else {
                        $str = date('H:i:s', PHPExcel_Shared_Date::ExcelToPHP($str));
                    }
                }
                //日期时间类型
                if ($typedata[0] == 'DT') {
                    if ($str == '') {
                        $str = NULL;
                    } else {
                        if (sizeof(explode('/', $str)) < 2 && sizeof(explode('-', $str)) < 2) {
                            if (sizeof(explode('.', $str)) == 3) {
                                $datastrs = explode('.', $str);
                                if (strlen($datastrs[0]) < 4) {
                                    $datastrs[0] = "20" . $datastrs[0];
                                }
                                $str = $datastrs[0] . '-' . $datastrs[1] . '-' . $datastrs[2];

                            } else
                                $str = date('Y-m-d H:i:s', (PHPExcel_Shared_Date::ExcelToPHP($str)));
                        } else if (sizeof(explode('/', $str)) == 3) {
                            $datastrs = explode('/', $str);
                            if (strlen($datastrs[2]) == 4) {
                                $str = $datastrs[2] . '-' . $datastrs[1] . '-' . $datastrs[0];

                            }
                        }
                    }
                }

                if ($typedata[0] == 'N' && $str == '') {
                    $str = NULL;
                }
                if ($typedata[0] == 'NN' && $str == '') {
                    $str = NULL;
                }
                //zkt 20240511 BUG20240507-45  销售订单在 导入明细 时，若导入内容有 关联选择单据 类型的字段，就算该列的导入内容并不存在，也能保存进系统（保存后为空）。能否进行限制，关联不上不允许保存。（华：导入如果关联选择单据为必填，那么导入错误的编号（超链接字段）就是无法导入；如果不是必填，就是导入这个分录，但是这个关联选择单据值为空）
                if($typedata[1] == "M"){
                    $tmpuitype = $colnames[1];
                    if($tmpuitype!=70 && $tmpuitype == 100){
                        $tmpfieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$columnname);
                        if(!empty($tmpfieldinfo) && $tmpfieldinfo->getBigType() == 'reference'){
                            $tmpreferencevalue = $Importoop->setImprtNameToId_details($tmpfieldinfo,$str,0);
                            if(empty($tmpreferencevalue)){
                                $tmpreferencefieldlabel = $tmpfieldinfo->getFieldLabel();
                                $error.='第'.($tmp_prouctDetail_row+2).'行"'.$tmpreferencefieldlabel.'"列值不能为空!<br>';
                                $nohaveerror=false;
                            }
                        }
                    }
                }
                //``````````导入的字段，特定类型额外处理End
                //判断是否是产品明细
                if (isProductTable($tablename)) {
                    //``````````````获取到当前的产品内容数组
                    $product_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]] = vtlib_purify($str);
                }
            }
        }
        $product_same_salesorder = 'no';//判断明细是否为统一单据，yes:是,no:不是
        //比较当前行和下一行数据查重字段的值是否相同，或下一行主表查重字段是否为空
        $conditionindex = 0;
        //```````````不是同一条单据,更新总行数
        $main_module_rows++;
        if ($tmp_cur_row_end_line == 'yes') {
            $endrow = $maxrows;
        }
        //有错误
        if ($nohaveerror == false) {
            $row++;
            $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] + 1;
            $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'] + 1;
            $xlsRowData = array();
            $nohaveerror = true;
            continue;
        }
        //如果当前行数据和下一行数据不相同或当前行为excel最后一行
        $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] + 1;
        $k = 0;
        $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_totalrows'] + 1;
        $temp = array();
        $uniqueid = array();
        $invenValues = array();
        $_checkCondition = array();
        $_accountid = $xlsRowData[0]['ld_servicecontracts']['accountid'];
        $main_column_is_not_exit = array();
        $_checkdupValues = array();
        if ($_REQUEST['product_import_type'] == 'NoImportRow'||$_REQUEST['product_import_type'] == 'AddProduct') {
            $no_product_rows = array();//产品不存在行
            $no_product_values = array();//产品不存在列值数组
            $tmpmaysaveproducts = array();//可以保存到数据库产品临时数据
            $discount_repeat_rows = array();//海格折扣信息重复行
            foreach ($product_xlsRowData as $productData => $productColumn) {//行循环
                $importaddcolumn = 'yes';
                if(!empty($checkPicklistColumn)){ //wym 240430 BUG20240430-16 先检查该行所有下拉框字段是否存在,否则进循环后会只看产品属性字段
                    foreach ($productColumn as $productTablename => $product_Values) {
                        foreach($product_Values as $key =>$productslFieldValues){
                            if(array_key_exists($key,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                                if(!empty($productslFieldValues)  && !in_array($productslFieldValues,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$key])){ //检查导入值是否是下拉框选项
                                    $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey("columnname", $key);
                                    if($fieldinfo) {
                                        $tmpfieldlable=$fieldinfo->getFieldLabel();
                                    }
                                    $no_product_error = '第'.$excelrow.'行'.$tmpfieldlable.'列值为空或在数据库中不存在!<br>';
                                    $no_product_param = array($row+$productData+2,$tmpfieldlable);
                                    $no_product_rows[] = array('param'=>$no_product_param, 'error'=>$no_product_error);
                                    $importaddcolumn = 'no';
                                }
                            }
                        }
                    }
                }
                foreach ($productColumn as $productTablename => $product_Values) {//表循环
                    $_checkimportfieldValues = array();
                    $_checkimportemptyfield = array();//查重字段为空的数据
                    if ($productTablename == 'ld_products') {//先判断产品是否存在
                        $productno = $product_Values['product_no'];
                        $productname = $product_Values['productname'];

                        if ($productname == '') {
                            $productname = $productno;
                        }
                        $_product_checkcolumns = array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                        $product_where = '';
                        if (!empty($_checkproducts)) {//产品查重字段不为空的情况下
                            //循环查重字段，若有值，则赋值给$_product_checkcolumns
                            $tmpproductTablename=$productTablename;
                            foreach ($_checkproducts as $index => $product_key_column) {
                                $product_keyfieldinfo=$profocus->fieldobj->getFieldInfoobjBykey("columnname",$product_key_column);
                                if($product_keyfieldinfo)
                                {
                                    $tmpproductTablename=$product_keyfieldinfo->getTableName();
                                    $tmpproductfieldlable=$product_keyfieldinfo->getFieldLabel();
                                }
                                if ($productColumn[$tmpproductTablename][$product_key_column] != '') {
                                    $_product_checkcolumns[] = $product_key_column;
                                    $_checkimportfieldColumn[$product_key_column] = $product_key_column;
                                    $_checkimportfieldValues[$product_key_column] = $productColumn[$tmpproductTablename][$product_key_column];
                                    $product_checkCondition[$product_key_column] = $product_importdupfields_condition[array_search($product_key_column, $product_is_checkimportfield)];
                                }
                                else
                                {

                                    $_checkimportemptyfield[$product_key_column] = $tmpproductfieldlable;
                                }
                            }
                            $dupcheckfield_len = sizeof($_product_checkcolumns);
                            //获取产品的id

                            $product_sql = 'select ld_products.productid as productid from ld_products ';
                            if (sizeof($dupcheckfield_len) > 0 && is_array($_product_checkcolumns) && $_product_checkcolumns[0] != "") {
                                foreach ($_product_checkcolumns as $index => $tmp_columnname) {
                                    $product_tablename = $profocus->fieldobj->getFieldInfoBykeyValue('columnname', $tmp_columnname, 'tablename');

                                    if ($product_tablename != 'ld_products') {
                                        $leftjoin_producttablename = $product_tablename;

                                    }
                                    $product_where .= "  $tmp_columnname= ?  ";
                                    if ($product_checkCondition[$tmp_columnname] != "" && $index != $dupcheckfield_len - 1) {
                                        $product_where .= $product_checkCondition[$tmp_columnname];
                                    }
                                }
                                if ($leftjoin_producttablename != '') {
                                    $product_sql .= ' left join ' . $leftjoin_producttablename . ' on ' . $leftjoin_producttablename . '.productid=ld_products.productid';
                                }
                                $product_sql .= " where ( ";
                                $product_sql .= $product_where;
                                $product_sql .= " ) ";
                                $product_sql .= " and deleted=0 ";
                                //取最新创建时间的产品
                                $product_sql .= " order by  ld_products.createdtime desc ";

                                $product_result = $adb->pquery($product_sql, array($_checkimportfieldValues));
                                $product_num = $adb->num_rows($product_result);

                                if ($product_num >= 1) {
                                    //haige报价单导入产品分录判断产品型号是否已在产品分录列表中：
                                    //若已在列表中且折扣相同则更改数量，不在列表中则需判断产品组信息并赋予折扣信息

                                    if($frommodule == 'Quotes' &&isset($haigeproductdetails)){
                                        $tmpproductid = $adb->query_result($product_result, 0, 0);
                                        if(isset($haigeproductdetails[$tmpproductid]))
                                        {
                                            $importaddcolumn = 'no';
                                            //判断折扣与经销商折扣信息是否相同
                                            if((float)$productColumn['ld_quotesdetail']['discount_percent']==$haigeproductdetails[$tmpproductid]['discount_percent']
                                                &&(float)$productColumn['ld_quotesdetail']['agent_discount']==$haigeproductdetails[$tmpproductid]['agent_discount'])
                                            {
                                                //商品存在与原界面数量合并，成功导入数量+1
                                                $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] + 1;
                                                $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'] + 1;
                                                $haigechangequantity[] = array('rowindex'=>$haigeproductdetails[$tmpproductid]['rowindex'],
                                                    'hdnProductId'=>$haigeproductdetails[$tmpproductid]['hdnProductId'],
                                                    'changequantity'=>$productColumn['ld_quotesdetail']['quantity']);
                                            }
                                            else
                                            {
                                                //折扣信息不相同不导入且产生提示信息
                                                $no_product_error = "第%s行 %s产品折扣与原有第%s行产品折扣不相同，无法合并<br>";
                                                $no_product_param = array($row+$productData+2,$productname,$haigeproductdetails[$tmpproductid]['rowindex']);
                                                $no_product_rows[] = array('param'=>$no_product_param,
                                                    'error'=>$no_product_error);
                                            }
                                        }else {
                                            $productgroup_name = $product_Values['productgroup_name'];
                                            if(empty($productgroup_name)){
                                                $productresult = $adb->pquery('select productgroup_name from ld_products where productid='.$tmpproductid);
                                                $productgroup_name = $adb->query_result($productresult,0,'productgroup_name');
                                            }
                                            $detailrowindex = count($haigeproductdetails)+1;
                                            //产品组存在时，取最优折扣，且折扣不可修改
                                            if(array_key_exists($productgroup_name,$haigegroupnames_arr))
                                            {
                                                $productColumn['ld_quotesdetail']['discount_percent'] = $haigegroupnames_arr[$productgroup_name]['discount_percent'];
                                                $productColumn['ld_quotesdetail']['agent_discount'] = $haigegroupnames_arr[$productgroup_name]['agent_discount'];
                                                $discountnoeditarr[] = array('rowindex'=>$detailrowindex,'hdnProductId'=>$tmpproductid);
                                            }
                                            else
                                            {
                                                //产品组不存在时，直接导入。
                                            }
                                            //更新SESSION及$haigeproductdetails信息

                                            $haigeproductdetails[$tmpproductid]=array('rowindex'=>$detailrowindex,'procuctname'=>$procuctname,
                                                'hdnProductId'=>$tmpproductid,'productgroup_name'=>$productgroup_name,
                                                'discount_percent'=>$productColumn['ld_quotesdetail']['discount_percent'],
                                                'agent_discount'=>$productColumn['ld_quotesdetail']['agent_discount']);
                                            $_SESSION['import_' . $currentModule . '_' . $current_user->id . 'haigedetails']['productdetails'] = $haigeproductdetails;
                                        }
                                    }
                                    elseif($VersionInfo['account'] == 'haige' &&$frommodule == 'SalesOrder' ){
                                        $tmpproductid = $adb->query_result($product_result, 0, 0);
                                        if(isset($haigeproduct_to_info[$tmpproductid])){
                                            //判断折扣报价单中是否相同
                                            if(abs((float)$productColumn['ld_salesorderdetail']['discount_percent']-$haigeproduct_to_info[$tmpproductid]['discount_percent'])<0.00000001)
                                            {

                                            }
                                            else
                                            {
                                                $importaddcolumn = 'no';
                                                //折扣信息不相同不导入且产生提示信息
                                                $no_product_error = "第%s行 %s产品折扣与报价单中产品折扣不相同，不导入改行<br>";
                                                $no_product_param = array($row+$productData+2,$productname);
                                                $no_product_rows[] = array('param'=>$no_product_param,
                                                    'error'=>$no_product_error);
                                            }
                                        }
                                    }
                                    if($importaddcolumn == 'yes')
                                    {
                                        //该行不导入，成功导入的明细数量;
                                        $db_product_num++;
                                        $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] + 1;
                                        $tmpmaysaveproducts[] = $productColumn;
                                        $tmpproductid = $adb->query_result($product_result, 0, 0);
                                        $productid[] = $tmpproductid;
                                    }

                                } else {
                                    //zxm  2021-1202 导入的时候  产品不存在 则新增产品--start
                                    if($importaddcolumn!='no') {//wym 240514 BUG20240514-10 校验下拉框不通过则不插入新产品，已经有对应提醒，不要再生成一条
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
                                            //-- zxm  2021-1202 导入的时候  产品不存在 则新增产品--end
                                            //新增产品，成功导入的明细数量;
                                            $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] + 1;
                                            //$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
                                            $tmpmaysaveproducts[] = $productColumn;
                                        }else{
                                            //editor:gyq_20191218 reason:导入错误日志内容修改 0038904: （51mis.com/kfbcrm）报价单>产品分录导入：映射字段界面点击“下一步”报错。
                                            //$no_product_row = $row - sizeOf($product_xlsRowData) + 1 +  $productData;
                                            $no_product_rows[] = $row+$productData;
                                            $no_product_values[] = $_checkimportfieldValues;
                                        }
                                    }
                                }
                            } else if(empty($_product_checkcolumns)&&!empty($_checkimportemptyfield)){
                                $tmpfieldlabels = '';
                                foreach($_checkimportemptyfield as $tmpfieldname =>$tmpfieldlabel){
                                    $tmpfieldlabels .= $tmpfieldlabel.',';
                                }
                                $tmpfieldlabels = trim($tmpfieldlabels,',');
                                $no_product_error = "第%s行 模板中%s等查重字段值为空，该行不导入。<br>";
                                $no_product_param = array($row+$productData+2,$tmpfieldlabels);
                                $no_product_rows[] = array('param'=>$no_product_param,
                                    'error'=>$no_product_error);
                            } else {
                                //editor:gyq_20191223 reason:0038952: （51mis.com/kfbcrm）报价单>产品分录导入：报价单导入日志中没有提示失败原因。
                                $no_product_rows[] = $row+$productData;
                                $no_product_values[] = $_checkimportfieldValues;
                            }
                        }
                    }
                }
            }

            //由于产品不存时，固定整行不导入。故经过上文判断，对$product_xlsRowData重新赋值
            $product_xlsRowData = $tmpmaysaveproducts;
            //整单不导入,该行不导入
            foreach ($no_product_rows as $tmpindex => $no_product_rowindex) {
                if(!is_array($no_product_rowindex))
                {
                    $tips = "";
                    foreach ($no_product_values[$tmpindex] as $tmpcolumnname => $cellvalue) {
                        $fieldlabel = $profocus->fieldobj->getFieldInfoBykeyValue("columnname", $tmpcolumnname, "fieldlabel");
                        $tips .= $fieldlabel . ":" . $cellvalue;
                        if(isset($no_product_values[$tmpindex+1])){
                            if ($product_checkCondition[$tmpcolumnname] == 'and') {
                                $tips .= "和";
                            } else if ($product_checkCondition[$tmpcolumnname] == 'or') {
                                $tips .= "或";
                            }
                        }
                    }
                    $error .= "第" . ($no_product_rowindex + 2) . "行 $tips 在数据中不存在，该行单据不导入!" . "<br>";
                }
                else
                {
                    //错误信息
                    $error .= vsprintf($no_product_rowindex['error'],$no_product_rowindex['param']);
                }
                
            }
        }
        if (sizeOf($productid) <= 0) $productid = '';
        $productList[$row] = $product_xlsRowData[0];
        if(!empty($productid[0]))
            $productidList[$row] = $productid[0];
        $tmp_prouctDetail_row++;
        $row++;
    }
    $endrow = $row;//明细的行数不是固定的。
    include(globalStatic::$root_directory . 'modules/XlsImportNew/documentEntry/ImportProgress.php');
    $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_addimportrows'] + count($productidList);
    $updateRows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_updaterows'];
    $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_error"] = $_SESSION['import_' . $currentModule . '_' . $current_user->id . "_error"] . $error;
    $smarty->assign("PRODUCTIMPORTYPE", $_REQUEST['product_import_type']);
    $smarty->assign("SUCCESSDETAILSCOUNT", $successdetailscount);
    $smarty->assign("FAILUREDETAILSCOUNT", $failuredetailscount);
    $tmp['timedescription'] = $time_description;
    $tmp['cur_progress_step'] = $cur_progress_step;
    $tmp['endimporttime'] = $endimporttime;
    $tmp['endrow'] = $endrow - 1;
    
    if($VersionInfo['account']=='haige'){
        //海格--报价单，界面存在产品则改变数量信息，$haigechangequantity改变数量信息
        if($frommodule == 'Quotes'){
            $tmp['haigechangequantity'] = $haigechangequantity;
            $tmp['discountnoeditarr'] = $discountnoeditarr;
        }
		//zkt 20230601 BUG0067248  	海格：创建合同时，若是采取批量导入明细的方式，无法显示面价等数据。 
        //海格--合同订单，选择报价单后产品分录带入，可以设置产品lineitemid
        elseif($frommodule == 'SalesOrder'&& !empty($_REQUEST['haigequoteid'])&&empty($haigeproduct_to_info)){
            $haigeproduct_to_info = array();
            $tmpsql = 'select lineitem_id,productid,pricefactor,standardprice,taxprice,discount_percent from ld_quotesdetail where id = ?';
            $tmpresult = $adb->pquery($tmpsql,array($_REQUEST['haigequoteid']));
            $rows=$adb->num_rows($tmpresult);
            if($rows>0){
                for($tmpi=0;$tmpi<$rows;$tmpi++){
                    $tmplineitem_id = $adb->query_result($tmpresult,$tmpi,'lineitem_id');
                    $tmpproductid = $adb->query_result($tmpresult,$tmpi,'productid');
					$tmppricefactor = $adb->query_result($tmpresult,$tmpi,'pricefactor');
					$tmpstandardprice = $adb->query_result($tmpresult,$tmpi,'standardprice');
					$tmptaxprice = $adb->query_result($tmpresult,$tmpi,'taxprice');
					$tmpdiscount_percent = $adb->query_result($tmpresult,$tmpi,'discount_percent');
					
                    $haigeproduct_to_info[$tmpproductid]['lineitem_id'] = $tmplineitem_id;
					$haigeproduct_to_info[$tmpproductid]['pricefactor'] = $tmppricefactor;
					$haigeproduct_to_info[$tmpproductid]['standardprice'] = $tmpstandardprice;
					$haigeproduct_to_info[$tmpproductid]['taxprice'] = $tmptaxprice;
					$haigeproduct_to_info[$tmpproductid]['discount_percent'] = $tmpdiscount_percent;
                }
            }
        }
    }
    
    
    //editor:gyq_162 reason:海格产品分录导入   2019/12/10 19:05
    crm_load_function_file('setProductsInfo', 'include/utils', 'ListViewUtils');
    $newProductList = array();
    $productFieldList = array();
    foreach ($productList as $rowNumber => $fieldContent) {
        $newProduct = array();
        foreach ($fieldContent as $tableName => $fieldCell) {
            $newProduct = array_merge($newProduct, $fieldCell);
        }
        $productFieldList[$rowNumber] = $newProduct;
    }
  
    foreach ($productidList as $key => $productid) {
        if(empty($productid))
            continue;
        $newProduct = array();
      
        $newProduct = setProductsInfo($currentModule, $productid, '', '', 1, 1);
        
        foreach ($newProduct as $keyTwo => $valueTwo) {
            $fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$keyTwo);
            
            if ($productFieldList[$key][$keyTwo] != '') {
                //chj 20220520 （https://www.51mis.com/hy/TY25/index.php）合同订单》新增，进行导入产品分录，分录中关联单选字段，值导入不进去；而操作导入整个订单时，分录是可以导入的
				$fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$keyTwo);
				if(!empty($fieldinfo) && $fieldinfo->getBigType() == 'reference'){
                    $tmpreferencevalue = $Importoop->setImprtNameToId_details($fieldinfo,$productFieldList[$key][$keyTwo],0);
                    $newProduct[$keyTwo] = $tmpreferencevalue;//获取相关信息id
                    $tmpreferencevalue_name = $productFieldList[$key][$keyTwo];
                    if(empty($tmpreferencevalue)){
                        $tmpreferencevalue_name = '';
                    }
                    $newProduct[$keyTwo.'_name'] = $tmpreferencevalue_name;
				}
   	            else if(!empty($fieldinfo) && $fieldinfo->getUIType() == 60&&$fieldinfo->getColumnName()=='wareid'){
   	                require_once(globalStatic::$root_directory. "include/Stock/CommonStock.php");
   	               $wareArray= getWareAllInfo($current_user);
                   foreach($wareArray as $tmpindex=>$tmpwareinfo)
                   {
                        if($tmpwareinfo['name']==$productFieldList[$key][$keyTwo])
                        {
                            $newProduct[$keyTwo]=$tmpwareinfo['id'];
                            $newProduct[$keyTwo.'_name'] = $productFieldList[$key][$keyTwo];
                            break;
                        }
                   }
                    
                }
                //根据查重字段获取到的产品id 对应的产品名称和模板中的产品名称不同
                else if(($fieldinfo->getTableName() == 'ld_products' ||$fieldinfo->getTableName() == 'ld_productscf')&&!empty($newProduct[$keyTwo])&&($newProduct[$keyTwo]!=$productFieldList[$key][$keyTwo])){
                    $newProduct[$keyTwo] = $valueTwo;
                }
                else{
					$newProduct[$keyTwo] = $productFieldList[$key][$keyTwo];
				}
                
                
            }
			if($VersionInfo['account']=='haige'&&$frommodule == 'SalesOrder'&& !empty($haigeproduct_to_info)&&$keyTwo=='productname'){
				$newProduct['parent_lineitem_id'] = $haigeproduct_to_info[$newProduct['hdnProductId']]['lineitem_id'];
			}
			else if($VersionInfo['account']=='haige'&&$frommodule == 'SalesOrder'&& !empty($haigeproduct_to_info)&&$keyTwo=='pricefactor'){
				$newProduct['pricefactor'] = $haigeproduct_to_info[$newProduct['hdnProductId']]['pricefactor'];
			}
			else if($VersionInfo['account']=='haige'&&$frommodule == 'SalesOrder'&& !empty($haigeproduct_to_info)&&$keyTwo=='standardprice'){
				$newProduct['standardprice'] = $haigeproduct_to_info[$newProduct['hdnProductId']]['standardprice'];
			}
			else if($VersionInfo['account']=='haige'&&$frommodule == 'SalesOrder'&& !empty($haigeproduct_to_info)&&$keyTwo=='taxprice'){
				$newProduct['taxprice'] = $haigeproduct_to_info[$newProduct['hdnProductId']]['taxprice'];
			}
			else if($VersionInfo['account']=='haige'&&$frommodule == 'SalesOrder'&& !empty($haigeproduct_to_info)&&$keyTwo=='discount_percent'){
				//$newProduct['discount_percent'] = $haigeproduct_to_info[$newProduct['hdnProductId']]['discount_percent'];
			}
        }
        foreach ($productFieldList[$key] as $keyThree => $valueThree) {
            if(!isset($newProduct[$keyThree])){
                $newProduct[$keyThree] = $valueThree;
            }
        }
        $newProductList[$key] = $newProduct;
       
    }
      
    
    $tmp['product_list'] = $newProductList;
    $tmp['row_amount'] = count($newProductList);
    ConvertTojsonString(1, $tmp, 'success');

}
?>