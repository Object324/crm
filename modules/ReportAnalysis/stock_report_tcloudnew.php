<?php
global $adb, $theme, $current_user;
//删除tmp下的tmp缓存你文件
$root_directory = explode('www', globalStatic::$root_directory);


if (!file_exists(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php') && file_exists(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api_Default.php')) {
    copy(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api_Default.php', globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php');
}
require_once(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php');
$version_info = getVersionInfo();
$is_ajax = $_REQUEST['is_ajax'];
$_REQUEST['diony'] = 'yes';


if (empty($_REQUEST['from_mobile'])) {
    $smarty = new lingdangCRM_Smarty();
}
$list_field = arrayKeyToLower(Config_ERP_Api::$list_field['tcloudnew']);
$page_show = Config_ERP_Api::$page_show;
$page_number = Config_ERP_Api::$page_number;
$link2erpUrl = Config_ERP_Api::$link2erpUrl;
$crmNoField= 'product_no';
if (property_exists('Config_ERP_Api','productNoField')){
    $crmNoField = Config_ERP_Api::$productNoField;
}
//查询条件
$FieldCounts = [];
if (!empty($list_field)) {
    $i = 0;
    foreach ($list_field as $colname => $info) {
        if ($info['search'] == 'yes') {
            if (strtolower($colname) == 'warehousename') {
                if($info['options']){
                    $list_search[$colname] = array(
                        'label' => $info['label'],
                        'type' => 'select',
                        'options' => $info['options'],
                        'optionsAllShow' => $info['optionsAllShow'],
                    );
                }else{
                    $options = getErpValue($colname);
                    $list_search[$colname] = array(
                        'label' => $info['label'],
                        'type' => 'select',
                        'options' => $options,
                        'optionsAllShow' => $info['optionsAllShow'],
                    );
                }
//下拉框默认值
                if ($info['selected'] && $list_search[$colname]) {
                    $list_search[$colname]['selected'] = $info['selected'];
                }

            } else if (strpos(strtolower($colname), 'qty') === false && strpos(strtolower($colname), 'date') === false) {
                $list_search[$colname] = array(
                    'label' => $info['label'],
                    'type' => 'like',
                );
            } else {
                $list_search[$colname] = array(
                    'label' => $info['label'],
                    'type' => 'text',
                );
            }
        }
        //显列
        if ($info['list'] == 'yes') {
            //$FieldKeys_sarch   用来查询用的
            $FieldKeys[] = $colname;
            if (strtolower($colname) == 'warehousename') {
                $FieldKeys_sarch[] = 'warehouse';
            } else if (strtolower($colname) == 'inventorycode') {
                $FieldKeys_sarch[] = 'inventory';
            } else {
                $FieldKeys_sarch[] = strtolower($colname);
            }
            $FieldKeys_label[$colname] = $info['label'];
        }

        //统计数量
        if (isset($info['count']) && $info['count'] == 'yes') {
            $FieldCounts[] = array('colname'=>$colname,'subtotal'=>0,'total'=>0,'index'=>$i,'label'=>$info['label']);
        }

        $all_colnames[] = $colname;
        $i++;
    }
}


$page = $_REQUEST['page'];    //当前页数
if (empty($page)) {
    $page = 1;
}
$list1 = [];
//查询
$apiArr=[];
$crmProductNoArr=[];
if (!empty($_REQUEST['record']) && $_REQUEST['from_mobile']!='yes') {
    $query = "select $crmNoField from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where ld_products.productid = ?";
    $result = $adb->pquery($query, array($_REQUEST['record']));
    $product_no = $adb->query_result($result, 0, 0);
}
if (!empty($_REQUEST['search'])) {
    $search1 = explode('|%%|', $_REQUEST['search']);
    $crmProductNoArr1=[];
    $InventoryCode1 = false;
    $InventoryName1 = false;
    $Specification1 = false;
    $tmpApiArr1 = [];
    foreach ($search1 as $search_info) {
        $search_arr = explode('|@@|', $search_info);
        $search_arr[1] = trim($search_arr[1]);
        if (empty($search_arr)) continue;
        if ($search_arr[0] == 'warehousename' && $search_arr[1] !='全部') {
            $tmpApiArr1[$search_arr[1]] = $search_arr[1];
        } else if ($search_arr[0] == 'inventorycode' && $search_arr[1]) {
            $InventoryCode1=true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and " .$crmNoField;
            switch ($search_arr[2]){
                case 'eq':
                    $sql .= " = '" . $search_arr[1] . "' ";
                    break;
                case 'lcon':
                    $sql .= " like '" . $search_arr[1] . "%' ";
                    break;
                case 'rcon':
                    $sql .= " like '%" . $search_arr[1] . "' ";
                    break;
                default:
                    $sql .= " like '%" . $search_arr[1] . "%' ";
                    break;
            }
            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr11 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr11=[];
            }
        } else if ($search_arr[0] == 'inventoryname' && $search_arr[1]) {
            $InventoryName1 =true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and productname ";
            switch ($search_arr[2]){
                case 'eq':
                    $sql .= " = '" . $search_arr[1] . "' ";
                    break;
                case 'lcon':
                    $sql .= " like '" . $search_arr[1] . "%' ";
                    break;
                case 'rcon':
                    $sql .= " like '%" . $search_arr[1] . "' ";
                    break;
                default:
                    $sql .= " like '%" . $search_arr[1] . "%' ";
                    break;
            }
            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr12 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr12=[];
            }
        } else if ($search_arr[0] == 'specification' && $search_arr[1]) {
            $Specification1 =true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and productsheet ";
            switch ($search_arr[2]){
                case 'eq':
                    $sql .= " = '" . $search_arr[1] . "' ";
                    break;
                case 'lcon':
                    $sql .= " like '" . $search_arr[1] . "%' ";
                    break;
                case 'rcon':
                    $sql .= " like '%" . $search_arr[1] . "' ";
                    break;
                default:
                    $sql .= " like '%" . $search_arr[1] . "%' ";
                    break;
            }
            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr13 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr13=[];
            }
        }
    }
    if(
        ($InventoryCode1 && empty($tmpProductNoArr11)) &&
        ($InventoryName1 && empty($tmpProductNoArr12)) &&
        ($Specification1 && empty($tmpProductNoArr13))
    ){
        $searchApi1=false;  //是否调用api查选 三个条件里面都查找到数据就不查询api
    }else{
        $searchApi1 = true;
    }
    if($searchApi1) {
        if (!empty($tmpProductNoArr11) && !empty($tmpProductNoArr12) && !empty($tmpProductNoArr13)) {
            $crmProductNoArr1 = array_intersect(array_column($tmpProductNoArr11, $crmNoField), array_column($tmpProductNoArr12, $crmNoField), array_column($tmpProductNoArr13, $crmNoField));
        } elseif (!empty($tmpProductNoArr11) && !empty($tmpProductNoArr12)) {
            $crmProductNoArr1 = array_intersect(array_column($tmpProductNoArr11, $crmNoField), array_column($tmpProductNoArr12, $crmNoField));
        } elseif (!empty($tmpProductNoArr11) && !empty($tmpProductNoArr13)) {
            $crmProductNoArr1 = array_intersect(array_column($tmpProductNoArr11, $crmNoField), array_column($tmpProductNoArr13, $crmNoField));
        } elseif (!empty($tmpProductNoArr12) && !empty($tmpProductNoArr13)) {
            $crmProductNoArr1 = array_intersect(array_column($tmpProductNoArr12, $crmNoField), array_column($tmpProductNoArr13, $crmNoField));
        } elseif (!empty($tmpProductNoArr11)) {
            $crmProductNoArr1 = array_column($tmpProductNoArr11, $crmNoField);
        } elseif (!empty($tmpProductNoArr12)) {
            $crmProductNoArr1 = array_column($tmpProductNoArr12, $crmNoField);
        } elseif (!empty($tmpProductNoArr13)) {
            $crmProductNoArr1 = array_column($tmpProductNoArr13, $crmNoField);
        }
    }

}
//TODO:: 这里可以优化组合成sql后查询. 以后有机会在修改吧
if (!empty($_REQUEST['search_arr_List'])) {
    $InventoryCode2= false;
    $InventoryName2 = false;
    $Specification2 = false;
    $search2 = explode('|%%|', $_REQUEST['search_arr_List']);
    $crmProductNoArr2=[];
    $tmpApiArr2 = [];
    foreach ($search2 as $search_info) {
        $search_arr = explode('|@@|', $search_info);
        $search_arr[1] = trim($search_arr[1]);
        if (empty($search_arr)) continue;
        if ($search_arr[0] == 'warehousename' && $search_arr[1] !='全部') {
            if(isset($list_field['warehousename']['options'])){
                foreach ($list_field['warehousename']['options'] as $info){
                    if(strpos($info['name'],$search_arr[2]) !== false){
                        $tmpApiArr2[$search_arr[1]] = $search_arr[1];
                    }
                }
            }
        } else if ($search_arr[0] == 'inventorycode' && $search_arr[1]) {
            $InventoryCode2=true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and " .$crmNoField;
            $sql .= " like '%" . $search_arr[1] . "%' ";
            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr21 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr21=[];
            }
        } else if ($search_arr[0] == 'inventoryname' && $search_arr[1]) {
            $InventoryName2 =true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and productname ";
            $sql .= " like '%" . $search_arr[1] . "%' ";
            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr22 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr22=[];
            }
        } else if ($search_arr[0] == 'specification' && $search_arr[1]) {
            $Specification3 =true;
            $sql = "select ".$crmNoField." from ld_products left join ld_productcf on ld_products.productid = ld_productcf.productid where deleted =0 and productsheet ";
            $sql .= " like '%" . $search_arr[1] . "%' ";

            $result = $adb->pquery($sql);
            if ($adb->num_rows($result) > 0) {
                $tmpProductNoArr23 = $adb->query_result_all($result);
            }else{
                $tmpProductNoArr23=[];
            }
        }
    }

    if(
        ($InventoryCode2 && empty($tmpProductNoArr21)) ||
        ($InventoryName2 && empty($tmpProductNoArr22)) ||
        ($Specification2 && empty($tmpProductNoArr23))
    ){
        $searchApi2=true;  //是否调用api查选 三个条件里面都查找到数据就不查询api
    }else{
        $searchApi2 = false;
    }
    if($searchApi2) {
        if (!empty($tmpProductNoArr21) && !empty($tmpProductNoArr22) && !empty($tmpProductNoArr23)) {
            $crmProductNoArr2 = array_merge(array_column($tmpProductNoArr21, $crmNoField), array_column($tmpProductNoArr22, $crmNoField), array_column($tmpProductNoArr23, $crmNoField));
        } elseif (!empty($tmpProductNoArr21) && !empty($tmpProductNoArr22)) {
            $crmProductNoArr2 = array_merge(array_column($tmpProductNoArr21, $crmNoField), array_column($tmpProductNoArr22, $crmNoField));
        } elseif (!empty($tmpProductNoArr21) && !empty($tmpProductNoArr23)) {
            $crmProductNoArr2 = array_merge(array_column($tmpProductNoArr21, $crmNoField), array_column($tmpProductNoArr23, $crmNoField));
        } elseif (!empty($tmpProductNoArr22) && !empty($tmpProductNoArr23)) {
            $crmProductNoArr2 = array_merge(array_column($tmpProductNoArr22, $crmNoField), array_column($tmpProductNoArr23, $crmNoField));
        } elseif (!empty($tmpProductNoArr21)) {
            $crmProductNoArr2 = array_column($tmpProductNoArr21, $crmNoField);
        } elseif (!empty($tmpProductNoArr22)) {
            $crmProductNoArr2 = array_column($tmpProductNoArr22, $crmNoField);
        } elseif (!empty($tmpProductNoArr23)) {
            $crmProductNoArr2 = array_column($tmpProductNoArr23, $crmNoField);
        }
    }

}



$crmProductNoArr=[];
$needSearchStock = [];
if(!empty($_REQUEST['search_arr_List']) && !empty($_REQUEST['search'])){
    if(!empty($crmProductNoArr1) && !empty($crmProductNoArr2)){
        $crmProductNoArr = array_intersect($crmProductNoArr2,$crmProductNoArr1);
    }else if(count($search1)==1 && empty($crmProductNoArr1)){
        if(strpos($search1[0],'warehousename') !==false){
            $crmProductNoArr = $crmProductNoArr2;
        }
    }
    if(!empty($tmpApiArr2) && !empty($tmpApiArr1)){
        $needSearchWarehouse =array_intersect($tmpApiArr2,$tmpApiArr1);
    }elseif (!empty($tmpApiArr2)){
        $needSearchWarehouse = $tmpApiArr2;
    }elseif (!empty($tmpApiArr1)){
        $needSearchWarehouse = $tmpApiArr1;
    }
}elseif (!empty($_REQUEST['search'])){
    if(!empty($crmProductNoArr1)){
        $crmProductNoArr = $crmProductNoArr1;
    }
    if (!empty($tmpApiArr1)){
        $needSearchWarehouse = $tmpApiArr1;
    }
}elseif (!empty($_REQUEST['search_arr_List'])){
    if(!empty($crmProductNoArr2)){
        $crmProductNoArr = $crmProductNoArr2;
    }
    if (!empty($tmpApiArr2)){
        $needSearchWarehouse = $tmpApiArr2;
    }
}



foreach ($needSearchWarehouse as $key => $value) {
    $apiArr['param']['warehouse'][] = array('Code' => $value);
}
if($product_no){
    $crmProductNoArr[] = $product_no;
}
if(!empty($crmProductNoArr)){
    foreach ($crmProductNoArr as $key => $value) {
        $apiArr['param']['inventory'][] = array('Code' => $value);
    }
}else{
    $apiArr = [];
}



if($apiArr) {
    //默认仓库赋值
    if (!$apiArr['param']['warehouse'] && $list_field['warehousename']['options']) {
        foreach ($list_field['warehousename']['options'] as $info) {
            $apiArr['param']['warehouse'][] = array('Code' => $info['id']);
        }
    }
    if (!$apiArr) {
        $apiArr = array(
            'param' => new stdClass()
        );
    }
    $StartRow = 0;
    $Limit = 0;
    $prevpage = 0;

    $nextpatge = 0;
    $erpAuth = getTcloudnewToken();

    $url = 'https://openapi.chanjet.com/tplus/api/v2/currentStock/Query';
    $result = postTcloudApi($erpAuth, $url, json_encode($apiArr));


    $result = arrayKeyToLower($result);
    //循环并更新到产品库存
    if ($version_info['account'] == 'shenzhenlongyang' && $_REQUEST['record']) {
        foreach ($result as $item) {
            $countQty += $item['availablequantity'];
        }
        $sql = "update ld_products set qtyearly=$countQty,qtyinstock=$countQty where productid=" . $_REQUEST['record'];
        //echo $sql;
        $adb->pquery($sql);
        //die;
    }

    //统计合计
    foreach ($FieldCounts as $tmp_columninfo) {
        foreach ($result as $tmp_info) {

            $tmp_colname = $tmp_columninfo['colname'];
            if (isset($tmp_info[$tmp_colname])) {
                $tmp_columninfo['total'] += round($tmp_info[$tmp_colname], 2);
            }
        }
    }


    //分页
    if ($page_show == 'yes') {
        $all_rows = count($result);    //总页数
        $Limit = $page_number;
        $all_page = ceil($all_rows / $Limit);
        if ($page > 1 && $page <= $all_page) {
            $prevpage = $page - 1;
        }
        if ($page < $all_page) {
            $nextpatge = $page + 1;
        }
        $StartRow = ($page - 1) * $Limit;
        if (empty($_REQUEST['from_mobile'])) {
            $smarty->assign('ALL_PAGE', $all_page);
            $smarty->assign('PREVPAGE', $prevpage);
            $smarty->assign('NEXTPAGE', $nextpatge);
            $smarty->assign('ALL_ROWS', $all_rows);
        }
        $result = array_slice($result, $StartRow, $page_number);
    }
    $stock_pro = [];
    $locakstock_pro = [];

    //统计小计
    foreach($FieldCounts as &$tmp_columninfo){
        foreach ($result as $tmp_info) {
            $tmp_colname = $tmp_columninfo['colname'];
            if (isset($tmp_info[$tmp_colname])) {
                $tmp_columninfo['subtotal'] += round($tmp_info[$tmp_colname], 2);
            }
        }
    }

    foreach ($result as $key => $info) {
        foreach ($FieldKeys as $fld_key => $colname) {

            $list_value = $info[$colname];
            if (in_array($colname, array('availablequantity', 'existingquantity'))) {
                $list_value = round($list_value, 2);
            }
            $list[$key][$colname] = $list_value;
            $field_label = $FieldKeys_label[$colname];
            $list1[$key]['field'][] = $field_label . '：' . $list_value;
        }
    }
}






//移动端
if ($_REQUEST['from_mobile_product'] == 'yes') {
    $res['list'] = $list1;//数据
    ConvertTojsonString(1, array('entry' => $res, 'stock_view' => 'ERP'), '');
}
if (!empty($_REQUEST['from_mobile']) && $_REQUEST['from_mobile'] == 'yes') {
    $res['list1'] = $list1;//数据
    $count = sizeOf($list1);
    foreach ($list_search as $colname => $arr) {
        $fieldtype = 1;
        $option = [];
        $search_label[] = $arr['label'];
        if (!empty($arr['options'])) {
            $fieldtype = 15;
            $option[] = array(
                "select" => "yes",
                "text" => "全部",
                "value" => "全部"
            );
            foreach ($arr['options'] as $opt) {
                $option[] = array(
                    "select" => "no",
                    "text" => $opt['name'],
                    "value" => $opt['id']
                );
            }
            $res['report_high_search'][] = array(
                'fieldlabel' => $arr['label'],
                'fieldname' => $colname,
                'fieldtype' => $fieldtype,
                'text' => '全部',
                'option' => $option,
            );
        } else {
            $res['report_high_search'][] = array(
                'fieldlabel' => $arr['label'],
                'fieldname' => $colname,
                'fieldtype' => $fieldtype,
                'text' => ''
            );
        }

    }
    $res['search_reminds'] = implode('、', $search_label);//模糊搜索
    $haveprevpage = 'no';
    if ($page > 1 && $page <= $all_page) {
        $haveprevpage = 'yes';
    }
    $havenextpage = 'no';
    if ($page < $all_page) {
        $havenextpage = 'yes';
        $curpagenum = $page+1;
    }
    else{
        $curpagenum = $page;
    }
    $res['havenextpage'] = $havenextpage;
    $res['haveprevpage'] = $haveprevpage;
    $res['curpagenum'] = $curpagenum;
    $res['pagecount'] = $all_page;
    $res['totalrows'] = $all_rows;
    $res['FieldCounts'] = $FieldCounts;
    ConvertTojsonString(1, $res, '');
}
//查询列  每行显示数
$search_view_rows = Config_ERP_Api::$search_view_rows;
$search_rows = 1;
$rows = 1;
foreach ($list_search as $key => $arr) {
    if ($search_rows <= $search_view_rows) {
        $new_list_search[$rows][$key] = $arr;
        if ($search_rows == $search_view_rows) {
            $rows++;
            $search_rows = 1;
        } else {
            $search_rows++;
        }

    }
}
$smarty->assign('PAGE', $page);
$smarty->assign('search_view_rows', $search_view_rows * 2);
$smarty->assign('PRODUCTNO', $product_no);
$smarty->assign('SEARCHCOLNAME', implode(',', $all_colnames));
$smarty->assign('SEARCHLIST', $new_list_search);
$smarty->assign('LISTENTITY', $list);
//显示列、宽度计算
foreach ($list_field as $arr) {
    if ($arr['list'] == 'yes')
        $list_cnt += $arr['width'];
}
$kuandu = ceil(($_SESSION['bodywidth'] - 35) / $list_cnt);
foreach ($FieldKeys as $colname) {
    if ($colname == 'fid') continue;
    $list_header[] = array('label' => $list_field[$colname]['label'], 'width' => $kuandu * $list_field[$colname]['width']);
    $list_content[] = $colname;
}
$smarty->assign('FIELDKEYS', $list_content);
$width = 0;
foreach ($list_header as $arr) {
    $width += $arr['width'];
}
$smarty->assign('FieldCounts', $FieldCounts);
$smarty->assign('HEADERLENGTH', sizeOf($list_header));
$smarty->assign('HEADER', $list_header);
$smarty->assign('WIDTH', $width);
$smarty->assign('CURRENT_USER_ID', $current_user->id);
$_REQUEST['diony'] = 'yes';

if (!empty($_REQUEST['record'])) {
    $content = $smarty->fetch("stock_report/search.tpl");
    $arr['title'] = getFixedLabel("PRODUCTQTYINSTOCKTITLE");
    $arr['oktext'] = '';
    $arr['canceltext'] = '';
    $arr['content'] = $content;
    ConvertTojsonString(1, $arr, "success");
} else {
    if ($is_ajax == "yes") {
        $smarty->assign('PAGE', $page);
        $smarty->display('stock_report/search_content.tpl');
    } else {
        $smarty->assign('list', $list);
        $smarty->display('stock_report/search.tpl');
    }
}

function getErpValue($colname)
{
    $erpAuth = getTcloudnewToken();
//    https://openapi.chanjet.com/tplus/api/v2
    if (strtolower($colname) == 'warehousename') {
        $url = 'https://openapi.chanjet.com/tplus/api/v2/warehouse/Query';
        $result = postTcloudApi($erpAuth, $url, '{"param":{}}');
    }
    if (!empty($result)) {
        foreach ($result as $arr) {
            $options[] = array('id' => $arr->Code, 'name' => $arr->Name);
        }
    }
    return $options;
}


function getTcloudApiUrl($url)
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    // 在尝试连接时等待的秒数
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
    // 最大执行时间
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    $output = curl_exec($ch);
    curl_close($ch);
    $output = json_decode($output, true);
    return $output;
}

function postTcloudApi($erpAuth, $url, $json)
{
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    if (substr($url, 0, 5) == 'https') {
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
    }
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $json);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    // 在尝试连接时等待的秒数
    curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);
    // 最大执行时间
    //curl_setopt($curl, CURLOPT_TIMEOUT, 120);


    curl_setopt($curl, CURLOPT_HTTPHEADER, array('content-type: application/json;charset=utf-8;', 'openToken:' . $erpAuth['token'] . '', 'appKey:' . $erpAuth['appKey'] . '', 'appSecret:' . $erpAuth['appSecret'] . ''));

    $result = curl_exec($curl);
    $errno = curl_errno($curl);
    $error = curl_error($curl);
    $result = json_decode($result);
    if ($result->code == '50107') {
        $erpAuth = getTcloudnewToken(true);
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('content-type: application/json;charset=utf-8;', 'openToken:' . $erpAuth['token'] . '', 'appKey:' . $erpAuth['appKey'] . '', 'appSecret:' . $erpAuth['appSecret'] . ''));
        $result = curl_exec($curl);
        $errno = curl_errno($curl);
        $error = curl_error($curl);
        $result = json_decode($result);
        if ($result->code == '50107') {
            ConvertTojsonString(-1, array(), $result->message . ' 清理缓存后重试   Json:' . json_encode($result, 256));
        }
    }
    curl_close($curl);
    return $result;
}

function getTcloudnewToken($type = false)
{
    $url = Config_ERP_Api::$link2erpUrl;
    $key = __FILE__ . __FUNCTION__  . $url . 'token';
    $return = cache($key);
    if ($type || $return['expire'] < time()) {
        $url = $url . 'chanjet/getChanjetAuth.php';
        $result = getTcloudApiUrl($url);

        $return = $result['result'];
        cache($key, $return);
    }
    return $return;
    /**
     * {
     * "code": 1,
     * "result": {
     * "appKey": "i1KJ3yOs",
     * "appSecret": "62CA4AE63E001CF4D6BD645FA66A0FAB",
     * "appCode": "c-f82dc6192305412b9b7c151f9b20dd04",
     * "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJpc3YiLCJpc3MiOiJjaGFuamV0IiwidXNlcklkIjoiNjAwMTQ3Mzc0MDEiLCJvcmdJZCI6IjEyMzMzMTEwMjUyNDE1NjgiLCJhY2Nlc3NfdG9rZW4iOiJiay1jYmM4ZGNhNS03Yzc1LTQzZjItODQ3Zi0zZjc1NzJhNzQzZWYiLCJhdWQiOiJpc3YiLCJuYmYiOjE2OTI5NTM3ODIsImFwcElkIjoiNTgiLCJzY29wZSI6ImF1dGhfYWxsIiwiYXBwS2V5IjoiaTFLSjN5T3MiLCJpZCI6IjAwMDczNmE0LWRiMDAtNGNkZi05YTQ2LWNiNzU1ZTExOTFhMiIsImV4cCI6MTY5MzQ3MjE4MiwiaWF0IjoxNjkyOTUzNzgyLCJvcmdBY2NvdW50IjoidWZnb3hxajFobGdpIn0.E5r29S2rNPcTI-gbNkLKP2LOBSBE2vnGbaPLIra9CKY"
     * },
     * "msg": "success"
     * }
     */
}
