<?php
/**
 * 特殊备注，朗捷服务器GBK，文件名需要特殊转换
 */
/**
 * 导出流程
 * 每次生成新的文件保存在$returnFileArr中。 在js保存在 js数组中
 * 1.列表导出
 *  1-1 单个导出
 *      a.导出云报关模板
 *      b.导出核对模板
 *  1-2 选择的多个导出并打包 每次仅导出一种类型（1-1-a或1-1-b）*
 * 2.详情页导出并发送邮件
 *  2-1 每次生成两个xlsx文件 1-1-a和1-1-b
 *  2-2  后续打包zip
 *
 */
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

set_time_limit(0);
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

$_REQUEST['diony']='yes';
if($_REQUEST['getprogress']=='yes')
{
    crm_load_class_file("LoginHistory",'modules/Users');
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export',$currentModule);
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');

}

require_once("modules/$currentModule/$currentModule.php");
require_once('user_privileges/user_privileges_'.$current_user->id.'.php');
require_once('include/ListView/ListViewSession.php');
require_once('PHPExcel/PHPExcel.php');

$zipSuffix='.zip';
$fileNameStr1 = '_云报关模板';
$fileNameStr2 = '_报关单草单';
//模板文件
if($_REQUEST['setype'] && $_REQUEST['setype'] =='ExportCustomsOrder'){
    $eco_lastFilePart = $fileNameStr1;
    $eco_templatePath = 'storage/file_material_tmp/langjieCustomsdeclaration.xlsx';

}else{
    $ect_lastFilePart = $fileNameStr2;
    $ect_templatePathImport = 'storage/file_material_tmp/langjieExportCheckTemplateImport.xlsx';
    $ect_templatePathExit = 'storage/file_material_tmp/langjieExportCheckTemplateExit.xlsx';

}

//发送邮件同时导出两个xlsx
if($_REQUEST['setype'] =='ExportCustomsOrderEmail'){
    $eco_lastFilePart = $fileNameStr1;
    $eco_templatePath = 'storage/file_material_tmp/langjieCustomsdeclaration.xlsx';
    $ect_lastFilePart = $fileNameStr2;
    $ect_templatePathImport = 'storage/file_material_tmp/langjieExportCheckTemplateImport.xlsx';
    $ect_templatePathExit = 'storage/file_material_tmp/langjieExportCheckTemplateExit.xlsx';
}

$pathnameTmp = 'storage/downCacheFile/';
if(!file_exists($pathnameTmp)){
    mkdirs($pathnameTmp,0777);
    chmod($pathnameTmp,0777);
}
$suffix = '.xlsx';

$eachExportNum = intval($_REQUEST['eachExportNum']);
$times = intval($_REQUEST['times']);
//if($times ==1){
//    unset($_SESSION[$currentModule][$current_user->id]['export']);
//}

$focus = CRMEntity::getInstance($currentModule);
// Custom View
$customView = new CustomView($currentModule);
$viewid = $customView->getViewId($currentModule);

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);

$page_list_query = $queryGenerator->getQuery("",1);
$list_query = $queryGenerator->getQuery("",2); //所有数据查询

$where = $queryGenerator->getConditionalWhere();

$params = array();
$search_type = $_REQUEST['search_type'];

$where=' where  '.$focus->table_name.'.deleted=0';
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata' ){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';
    $listcounts = count($idstring)-1;
}else{
    $listcounts = 0;
}
$detailcounts = $listcounts;
$chart_owner=$queryGenerator->getSmOwnerSearchSql();
$page_list_query=$page_list_query.$chart_owner.$querywhere;
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);


$where=$queryGenerator->getWhereClause();

$prev_totalrows = $times * $eachExportNum;

crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
$fileList =array(); //本次请求
$singleFileName = '';  //用于导出后发送邮件

$start =($times-1)*$eachExportNum;
$queryLIMIT = ' LIMIT ' . $start . ',' . $eachExportNum;
$ids = array(); //结果的所有id
$listArr = array(); //结果的数组
$listDetailArr = array(); //结果的分录信息集合
$accountArr = array(); //关联的客户信息
$returnFileArr=array();  //结果文件的数组 每次生成的文件保存在数组中
$tmplist_query = "$page_list_query  $queryLIMIT";
$list_result = $adb->pquery($tmplist_query);
$rows_num = $adb->num_rows($list_result);
//if ($rows_num <= 0) {
//    ConvertTojsonString(0,'导出数据不存在','fail');
//}
for ($i = 0; $i < $rows_num; $i++) {
    $row = $adb->fetch_array($list_result);
    $ids[] = $row[0];
}
global $reset_retrieve_entity_info;//修改日志需要重新获取数据
if (!empty($ids)) {
    foreach ($ids as $id) {
        $focus->id = $id;
        $reset_retrieve_entity_info = 'no';
        $focus->retrieve_entity_info($focus->id, $currentModule);
        $listArr[$id] = $focus->column_fields;
        //获取明细数据类
        $tabDetailFieldsData = new TabDetailFieldsData($focus, $currentModule);
        $listDetailArr[$id] = $tabDetailFieldsData->getTabDetailHtmlContentData();
        unset($tabDetailFieldsData);
    }
}
if (!empty($listArr)) {
    foreach ($listArr as $id => $arr) {
        $accountmodule = 'Accounts';
        $account_focus = CRMEntity::getInstance($accountmodule);
        $account_focus->id = $arr['account_id'];
        $account_focus->retrieve_entity_info($account_focus->id, $accountmodule);
        $accountArr[$id] = $account_focus->column_fields;
        unset($account_focus);
    }
}

//导出导出云报关模板
if ($_REQUEST['setype'] == 'ExportCustomsOrder' || $_REQUEST['setype'] == 'ExportCustomsOrderEmail') {
    foreach ($listArr as $id => $listValue) {
        $objPHPExcel = PHPExcel_IOFactory::load($eco_templatePath);
//加载模板 默认两个工作sheet 0 为导入的模板 1为当前工作表 保存后 为1个sheet 0不输出

        $activeSheet = $objPHPExcel->getActiveSheet();//获取当前的sheet
        $activeSheet->setTitle('1'); //sheet名必须为1 客户要求
        $colTitle = '中华人民共和国海关' . $listValue['declare_type'] . '货物报关单';
        $activeSheet->setCellValueExplicit('A1', $colTitle, PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('H2', $listValue['records_no'], PHPExcel_Cell_DataType::TYPE_STRING) //备案号
            ->setCellValueExplicit('K2', $listValue['cabin_no'], PHPExcel_Cell_DataType::TYPE_STRING) //提运单号
//                    报关单草单导出模板，增加一个字段“业务号”，内容调取CRM报关单“单据编号”
            ->setCellValueExplicit('S2', $listValue['customform22_no'], PHPExcel_Cell_DataType::TYPE_STRING) //业务号

            ->setCellValueExplicit('F3', $listValue['transmode'], PHPExcel_Cell_DataType::TYPE_STRING) //运输方式
            ->setCellValueExplicit('H3', $listValue['trans_name'], PHPExcel_Cell_DataType::TYPE_STRING) //运输工具
            ->setCellValueExplicit('K3', $listValue['cf_3017'], PHPExcel_Cell_DataType::TYPE_STRING)   //航班次号
            ->setCellValueExplicit('B4', $listValue['aeo_no'], PHPExcel_Cell_DataType::TYPE_STRING) //AEO
            ->setCellValueExplicit('F4', $listValue['trademode'], PHPExcel_Cell_DataType::TYPE_STRING)   //监管方式
            ->setCellValueExplicit('H4', $listValue['imposemode'], PHPExcel_Cell_DataType::TYPE_STRING) //免征性质
            ->setCellValueExplicit('K4', $listValue['licence_no'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('C6', $listValue['trade_country'], PHPExcel_Cell_DataType::TYPE_STRING) //贸易国
            ->setCellValueExplicit('F6', $listValue['cf_2818'], PHPExcel_Cell_DataType::TYPE_STRING) //成交方式
//                    报关单草单导出模板时，“运费”，”保费”“杂费”“法定数量”“第二数量”字段录入为0时，导出模板为空值；
            ->setCellValueExplicit('H6', $listValue['freight'] == '0' ? '' : $listValue['freight'], PHPExcel_Cell_DataType::TYPE_STRING) //运费
            ->setCellValueExplicit('K6', $listValue['subscribe'] == '0' ? '' : $listValue['subscribe'], PHPExcel_Cell_DataType::TYPE_STRING) //保费
            ->setCellValueExplicit('M6', $listValue['incidental'] == '0' ? '' : $listValue['incidental'], PHPExcel_Cell_DataType::TYPE_STRING) //杂费
            ->setCellValueExplicit('C7', $listValue['contract_no'], PHPExcel_Cell_DataType::TYPE_STRING) //合同协议号
            ->setCellValueExplicit('F7', $listValue['piece'], PHPExcel_Cell_DataType::TYPE_STRING) //件数
            ->setCellValueExplicit('H7', $listValue['pack_type'], PHPExcel_Cell_DataType::TYPE_STRING) //包装类型
            ->setCellValueExplicit('K7', $listValue['gross_weight'], PHPExcel_Cell_DataType::TYPE_STRING)  //毛重
            ->setCellValueExplicit('M7', $listValue['net_weight'],PHPExcel_Cell_DataType::TYPE_STRING) //净重
            ->setCellValueExplicit('B8', $listValue['description'], PHPExcel_Cell_DataType::TYPE_STRING) //备注
            ->setCellValueExplicit('H8', $listValue['cf_3021'], PHPExcel_Cell_DataType::TYPE_STRING) //标记唛码
            ->setCellValueExplicit('K8', $listValue['cf_2820'], PHPExcel_Cell_DataType::TYPE_STRING) //价格影响
            ->setCellValueExplicit('H9', $listValue['cf_2819'], PHPExcel_Cell_DataType::TYPE_STRING) //特殊关系
            ->setCellValueExplicit('K9', $listValue['cf_2821'], PHPExcel_Cell_DataType::TYPE_STRING); //支付特权

        if ($listValue['declare_type'] == '进口') {
            $activeSheet->setCellValueExplicit('B2', $listValue['entry_customs'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('D2', $listValue['port_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('F2', $listValue['entry_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('B3', $listValue['cf_3035'], PHPExcel_Cell_DataType::TYPE_STRING) //收货人10位
                ->setCellValueExplicit('C3', $listValue['domestic_buyerno'], PHPExcel_Cell_DataType::TYPE_STRING) //收货人18位
                ->setCellValueExplicit('D3', $listValue['domestic_buyer'], PHPExcel_Cell_DataType::TYPE_STRING) //收货人
                ->setCellValueExplicit('B4', $listValue['aeo_no'], PHPExcel_Cell_DataType::TYPE_STRING) //AEO
                ->setCellValueExplicit('D4', $listValue['abroad_shipper'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('M4', $listValue['cf_2826'], PHPExcel_Cell_DataType::TYPE_STRING)  //经停港

                ->setCellValueExplicit('B5', $listValue['cf_3020'], PHPExcel_Cell_DataType::TYPE_STRING) //进口10位编码
                ->setCellValueExplicit('C5', $listValue['consignee_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('D5', $listValue['consignee_name'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('F5', $listValue['from_country'],PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('H5', $listValue['start_port'],PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('K5', $listValue['goodsplace'], PHPExcel_Cell_DataType::TYPE_STRING);

        } else {  //出口
            $activeSheet->setCellValueExplicit('B2', $listValue['exit_customs'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('D2', $listValue['port_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('F2', $listValue['departure_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('B3', $listValue['cf_3036'], PHPExcel_Cell_DataType::TYPE_STRING) //发货人10位编码 不存在
                ->setCellValueExplicit('C3', $listValue['domestic_shipperno'], PHPExcel_Cell_DataType::TYPE_STRING) //发货人18位
                ->setCellValueExplicit('D3', $listValue['domestic_shipper'], PHPExcel_Cell_DataType::TYPE_STRING) //发货人

                ->setCellValueExplicit('D4', $listValue['abroad_buyer'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('M4', '', PHPExcel_Cell_DataType::TYPE_STRING) //经停港

                ->setCellValueExplicit('B5', $listValue['cf_3019'], PHPExcel_Cell_DataType::TYPE_STRING) //10位编码
                ->setCellValueExplicit('C5', $listValue['domestic_shipperno'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('D5', $listValue['domestic_shipper'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('F5', $listValue['to_country'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('H5', $listValue['to_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('K5', '', PHPExcel_Cell_DataType::TYPE_STRING); //货物存放地

        }

        $num = 1;   //分录信息 自动标号
        $line = 11;  //自增行号
        if (!empty($listDetailArr[$id])) {
            foreach ($listDetailArr[$id] as $detail) {
                if ($listValue['declare_type'] == '进口') {
                    $activeSheet->setCellValueExplicit('O' . $line, $detail['sf146'], PHPExcel_Cell_DataType::TYPE_STRING);
                } else {
                    $activeSheet->setCellValueExplicit('O' . $line, $detail['sf145'], PHPExcel_Cell_DataType::TYPE_STRING);
                }
                $activeSheet->setCellValueExplicit('A' . $line, $num, PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('B' . $line, $detail['sf191'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('C' . $line, $detail['sf137'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('D' . $line, $detail['sf196'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('E' . $line, $detail['sf197'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('F' . $line, $detail['sf138'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('G' . $line, '', PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('H' . $line, number_format($detail['sf140'],5), PHPExcel_Cell_DataType::TYPE_STRING) //数量
                    ->setCellValueExplicit('I' . $line, $detail['sf141'], PHPExcel_Cell_DataType::TYPE_STRING) //单位
                    //6-15报关单草单导出模板时，“运费”，”保费”“杂费”“法定数量”“第二数量”字段录入为0时，导出模板为空值；
                    ->setCellValueExplicit('J' . $line, $detail['sf198'] == 0 ? '' : number_format($detail['sf198'],4), PHPExcel_Cell_DataType::TYPE_STRING)//法定数量
                    ->setCellValueExplicit('K' . $line, $detail['sf199'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('L' . $line, $detail['sf200'] == 0 ? '' : number_format($detail['sf200'],4), PHPExcel_Cell_DataType::TYPE_STRING)//第二数量
                    ->setCellValueExplicit('M' . $line, $detail['sf201'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('N' . $line, $detail['sf143'] . '/' . $detail['sf144'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('P' . $line, $detail['sf195'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('Q' . $line, number_format($detail['sf194'],4), PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('R' . $line, number_format($detail['sf193'],4), PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('S' . $line, $detail['sf192'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('T' . $line, $detail['sf147'], PHPExcel_Cell_DataType::TYPE_STRING)
                    //报关单上的“版本号”字段抓取问题，如果填的是“*”号，调取内容就为空，填写其他值直接带值导出即可
                    ->setCellValueExplicit('U' . $line, $detail['sf153'] == '*' ? '' : $detail['sf153'], PHPExcel_Cell_DataType::TYPE_STRING);

                $line++;
                $num++;
            }
        }

        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
        $filePath = $pathnameTmp . $listValue['customform22_no'] . $eco_lastFilePart . $suffix;
//        dump(mb_detect_encoding($filePath, array("ASCII",'UTF-8',"GB2312","GBK",'BIG5')));
        $filePath = iconv('UTF-8','gbk',$filePath);
        $fileName = $listValue['customform22_no'] . $eco_lastFilePart . $suffix;
        $returnFileArr[] = array(
            'filename' => $fileName,
            'filepath'=>$filePath,
            'customform22_no' => $listValue['customform22_no'],
            'port_no' =>$listValue['port_no'],//申报口岸
            'accountName'=>$accountArr[$id]['short_name'],//客户简称
            'declareDate'=> $listValue['cf_2823'],//申报日期
            'declareType'=>$listValue['declare_type'],//申报类型
        );

        $objWriter->save($filePath);
        $fileList[] = $filePath;
        unset($objPHPExcel);
        unset($objWriter);
    }
}

//导出核对模板
if ($_REQUEST['setype'] == 'ExportCheckTemplate' || $_REQUEST['setype'] == 'ExportCustomsOrderEmail') {
    foreach ($listArr as $id => $listValue) {
        if ($listValue['declare_type'] == '进口') {
            $objPHPExcel = PHPExcel_IOFactory::load($ect_templatePathImport);
        } else {
            $objPHPExcel = PHPExcel_IOFactory::load($ect_templatePathExit);
        }
//加载模板 默认两个工作sheet 0 为导入的模板 1为当前工作表 保存后 为1个sheet 0不输出

        $activeSheet = $objPHPExcel->getActiveSheet();//获取当前的sheet
        $colTitle = '中华人民共和国海关' . $listValue['declare_type'] . '货物报关单';
        $activeSheet->setCellValueExplicit('A1', $colTitle, PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('G2', $listValue['port_no'], PHPExcel_Cell_DataType::TYPE_STRING) //申报口岸
            ->setCellValueExplicit('P2', $listValue['customform22_no'], PHPExcel_Cell_DataType::TYPE_STRING) //草单号码
            ->setCellValueExplicit('K4', $listValue['apply_date'], PHPExcel_Cell_DataType::TYPE_STRING) //申报日期
            ->setCellValueExplicit('O4', $listValue['records_no'], PHPExcel_Cell_DataType::TYPE_STRING) //备案号
            ->setCellValueExplicit('D5', $listValue['aeo_no'], PHPExcel_Cell_DataType::TYPE_STRING) //AEO
            ->setCellValueExplicit('E6', $listValue['transmode'], PHPExcel_Cell_DataType::TYPE_STRING) //运输方式
            ->setCellValueExplicit('G6', $listValue['trans_name'] . $listValue['cf_3017'], PHPExcel_Cell_DataType::TYPE_STRING) //运输工具名称及航次号
            ->setCellValueExplicit('K6', $listValue['cabin_no'], PHPExcel_Cell_DataType::TYPE_STRING) //提运单号
            ->setCellValueExplicit('E8', $listValue['trademode'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('G8', $listValue['imposemode'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('K8', $listValue['licence_no'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('A10', $listValue['contract_no'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('E10', $listValue['trade_country'], PHPExcel_Cell_DataType::TYPE_STRING) //贸易国
            ->setCellValueExplicit('A12', $listValue['pack_type'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('E12', $listValue['piece'], PHPExcel_Cell_DataType::TYPE_STRING)
//            ->setCellValueExplicit('F12', $listValue['gross_weight'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('F12', $listValue['gross_weight'],PHPExcel_Cell_DataType::TYPE_STRING) //净重
            ->setCellValueExplicit('G12', $listValue['net_weight'],PHPExcel_Cell_DataType::TYPE_STRING) //净重

            ->setCellValueExplicit('I12', $listValue['cf_2818'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('K12', $listValue['freight'] == '0' ? '' : $listValue['freight'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('N12', $listValue['subscribe'] == '0' ? '' : $listValue['subscribe'], PHPExcel_Cell_DataType::TYPE_STRING)
            ->setCellValueExplicit('Q12', $listValue['incidental'] == '0' ? '' : $listValue['incidental'], PHPExcel_Cell_DataType::TYPE_STRING);


        if ($listValue['declare_type'] == '进口') {
            $activeSheet->setCellValueExplicit('C3', $listValue['domestic_buyerno'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A4', $listValue['domestic_buyer'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('E4', $listValue['entry_customs'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('G4', $listValue['import_date'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A6', $listValue['abroad_shipper'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('O6', $listValue['goodsplace'], PHPExcel_Cell_DataType::TYPE_STRING) //货物存放地点
                ->setCellValueExplicit('C7', $listValue['consignee_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A8', $listValue['consignee_name'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('O8', $listValue['start_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('G10', $listValue['from_country'], PHPExcel_Cell_DataType::TYPE_STRING)//启运国
                ->setCellValueExplicit('K10', $listValue['stop_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('O10', $listValue['entry_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C16', $listValue['cf_3021'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('B17', $listValue['description'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C19', $listValue['cf_2819'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('E19', $listValue['cf_2820'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('H19', $listValue['cf_2821'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C13', $listValue['cf_3040'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('K19', $listValue['cf_2822'], PHPExcel_Cell_DataType::TYPE_STRING);

            $line = 21;  //自增行号
        } else {  //出口
		
		$activeSheet->setCellValueExplicit('C3', $listValue['domestic_shipperno'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A4', $listValue['domestic_shipper'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('E4', $listValue['exit_customs'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('G4', $listValue['export_date'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A6', $listValue['abroad_buyer'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C7', $listValue['productor_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('A8', $listValue['productor_name'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('G10', $listValue['to_country'], PHPExcel_Cell_DataType::TYPE_STRING)//抵运国
                ->setCellValueExplicit('K10', $listValue['to_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('O10', $listValue['departure_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C14', $listValue['cf_3021'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('B15', $listValue['description'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('C17', $listValue['cf_2819'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('E17', $listValue['cf_2820'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('H17', $listValue['cf_2821'], PHPExcel_Cell_DataType::TYPE_STRING)
                ->setCellValueExplicit('K17', $listValue['cf_2822'], PHPExcel_Cell_DataType::TYPE_STRING);
				
            // $activeSheet->setCellValueExplicit('C3', $listValue['domestic_shipperno'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('A4', $listValue['domestic_shipper'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('E4', $listValue['exit_customs'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('G4', $listValue['export_date'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('A6', $listValue['abroad_buyer'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('C7', $listValue['productor_no'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('A8', $listValue['productor_name'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('G10', $listValue['to_country'], PHPExcel_Cell_DataType::TYPE_STRING)//抵运国
                // ->setCellValueExplicit('K10', $listValue['to_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('O10', $listValue['departure_port'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('C14', $listValue['cf_3021'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('B15', $listValue['description'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('C36', $listValue['cf_2819'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('E36', $listValue['cf_2820'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('H36', $listValue['cf_2821'], PHPExcel_Cell_DataType::TYPE_STRING)
                // ->setCellValueExplicit('K36', $listValue['cf_2822'], PHPExcel_Cell_DataType::TYPE_STRING);
            $line = 19;  //自增行号
        }


        if (!empty($listDetailArr[$id])) {
            foreach ($listDetailArr[$id] as $detail) {
                $activeSheet->setCellValueExplicit('A' . $line, $detail['sf191'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('B' . $line, $detail['sf137'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('D' . $line, $detail['sf138'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('D' . ($line + 1), $detail['sf139'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('G' . $line, number_format($detail['sf140'],5), PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('H' . $line, $detail['sf141'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('I' . $line, number_format($detail['sf194'],4), PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('I' . ($line + 1), number_format($detail['sf193'],4), PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('I' . ($line + 2), $detail['sf192'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('K' . $line, $detail['sf143'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('M' . $line, $detail['sf144'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('R' . $line, $detail['sf147'], PHPExcel_Cell_DataType::TYPE_STRING)
                    ->setCellValueExplicit('S' . $line, $detail['sf153'] == '*' ? '' : $detail['sf153'], PHPExcel_Cell_DataType::TYPE_STRING); //版本号

                if ($listValue['declare_type'] == '进口') {
                    $activeSheet->setCellValueExplicit('P' . $line, $detail['sf146'], PHPExcel_Cell_DataType::TYPE_STRING)
                        ->setCellValueExplicit('P' . ($line + 1), $detail['sf195'], PHPExcel_Cell_DataType::TYPE_STRING)
                        ->setCellValueExplicit('B' . ($line + 1), $detail['sf196'], PHPExcel_Cell_DataType::TYPE_STRING)
                        //生产日期为空 数据存储为'0000-00-00'
                        ->setCellValueExplicit('B' . ($line + 2), $detail['sf206'] == '0000-00-00' ? '' : $detail['sf206'], PHPExcel_Cell_DataType::TYPE_STRING);
                } else {
                    $activeSheet->setCellValueExplicit('P' . $line, $detail['sf145'], PHPExcel_Cell_DataType::TYPE_STRING)
                        ->setCellValueExplicit('P' . ($line + 1), $detail['sf195'], PHPExcel_Cell_DataType::TYPE_STRING);
                }
                $line += 3;

            }
        }
        // 设置密码保护不能编辑sheet
//                $objPHPExcel->getSecurity()->setLockWindows(true);
//                $objPHPExcel->getSecurity()->setLockStructure(true);
//                $objPHPExcel->getSecurity()->setWorkbookPassword("langjie");
//
//                // Set password for readonly data
//                $objPHPExcel->getActiveSheet()->getProtection()->setSheet(true);
//                $objPHPExcel->getActiveSheet()->getProtection()->setPassword("langjie");
//
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
        $filePath = $pathnameTmp . $listValue['customform22_no'] . $ect_lastFilePart . $suffix;
        $filePath = iconv('UTF-8','gbk',$filePath);
        $fileName = $listValue['customform22_no'] . $ect_lastFilePart . $suffix;
        $returnFileArr[] = array(
            'filename' => $fileName,
            'filepath'=>$filePath,
            'customform22_no' => $listValue['customform22_no'],
            'port_no' =>$listValue['port_no'],
            'accountName'=>$accountArr[$id]['short_name'],
            'declareDate'=> $listValue['cf_2823'],
            'declareType'=>$listValue['declare_type'],
        );


        $objWriter->save($filePath);
//                @chmod($filePath,0555); 只读
        $fileList[] = $filePath;
        unset($objPHPExcel);
        unset($objWriter);
    }
}

$_REQUEST['frommodule']=$currentModule;


$ret_arr['files'] = $returnFileArr;

//进度条
if($_REQUEST['getprogress']=='yes') {
    include(globalStatic::$root_directory . 'modules/lingdang/Export/ExportProgressDescription.php');
    $ret_arr['timedescription'] = $time_description;  //进度条框的文字
    $ret_arr['content']=$progresshtml;  //进度条框的html
}
$ret_arr['times'] =$times+1;
//导出完成
if($listcounts <= $prev_totalrows){
    $ret_arr['complete'] ='yes';
   // unset($_SESSION[$currentModule][$current_user->id]['export']);
}else{
    $ret_arr['complete'] ='no';
}
$ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');

ConvertTojsonString(1,$ret_arr,'success');

?>