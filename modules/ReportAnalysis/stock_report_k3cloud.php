<?php
global $adb, $theme, $current_user;
//删除tmp下的tmp缓存你文件
$root_directory = explode('www', globalStatic::$root_directory);
$handle = opendir($root_directory[0] . '/tmp');
while (($file = readdir($handle)) != false) {
    if ($file != '.' && $file != '..') {
        if (strpos($file, '.tmp') !== false) {
            unlink($root_directory[0] . '/tmp/' . $file);
        }
    }
}

if (!file_exists(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php') && file_exists(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api_Default.php')) {
    copy(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api_Default.php', globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php');
}
require_once(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php');
$version_info = getVersionInfo();
$is_ajax = $_REQUEST['is_ajax'];
$_REQUEST['diony'] = 'yes';
$invoke_login = invokeLogin();    //参数登陆验证
if (empty($_REQUEST['from_mobile'])) {
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign('invoke_login', $invoke_login);
}
$list_field = arrayKeyToLower(Config_ERP_Api::$list_field);
$page_show = Config_ERP_Api::$page_show;
$page_number = Config_ERP_Api::$page_number;
$product_type = $productNoField = '';

if (property_exists('Config_ERP_Api','product_type')){
    $product_type = Config_ERP_Api::$product_type;
}
$productNoField= 'product_no';
if (property_exists('Config_ERP_Api','productNoField')){
    $productNoField = Config_ERP_Api::$productNoField;
}

//查询条件
if (!empty($list_field['k3cloud'])) {
    foreach ($list_field['k3cloud'] as $colname => $info) {
        if ($info['search'] == 'yes') {
            if (strtolower($colname) == 'fstockorgid' ||strtolower($colname) == 'fstockid' || strtolower($colname) == 'fstockstatusid' || strtolower($colname) == 'fbaseunitid') {
                if ($info['options']) {
                    $list_search[$colname] = array(
                        'label' => $info['label'],
                        'type' => 'select',
                        'options' => $info['options'],
                        'optionsAllShow' => $info['optionsAllShow'],
                    );
                } else {
                    $options = getErpValue($colname, 0);
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
            if (strtolower($colname) == 'flot') {
                $FieldKeys_sarch[] = 'flot.fname';
            } else if (strtolower($colname) == 'fmaterialid') {
                $FieldKeys_sarch[] = 'fmaterialid.fnumber';
            } else if (strtolower($colname) == 'fstockid') {
                $FieldKeys_sarch[] = 'fstockid.fname';
            } else if (strtolower($colname) == 'fstockunitid') {
                $FieldKeys_sarch[] = 'fstockunitid.fname';
            } else if (strtolower($colname) == 'fsecunitid') {
                $FieldKeys_sarch[] = 'fsecunitid.fname';
            } else if (strtolower($colname) == 'fstockorgid') {
                $FieldKeys_sarch[] = 'fstockorgid.fname';
            } else if (strtolower($colname) == 'fbaseunitid') {
                $FieldKeys_sarch[] = 'fbaseunitid.fname';
            } else if (strtolower($colname) == 'fstockstatusid') {
                $FieldKeys_sarch[] = 'fstockstatusid.fname as fstockstatusid_fname';
            } else if (in_array(strtolower($colname), array('ff100006', 'ff100007', 'ff100008', 'ff100009', 'ff100010'))) {
                $FieldKeys_sarch[] = 'FAuxPropId.' . $colname . '.FDataValue';
            } else {
                $FieldKeys_sarch[] = strtolower($colname);
            }

            $FieldKeys_label[$colname] = $info['label'];
        }
        $all_colnames[] = $colname;
    }
}

$FilterString_fstockorgid_str = "1=2";
if (!empty($_REQUEST['record'])) {
    $query = "select $productNoField from ld_products where productid = ?";
    $result = $adb->pquery($query, array($_REQUEST['record']));
    $product_no = $adb->query_result($result, 0, 0);
    //$product_no = '02.01.01.003';
    if (!empty($product_no)) {
        //产品编号
        $FilterString = "FNumber like '%" . $product_no . "%'";
        if (!empty($FStockOrgId)) {
            $FilterString .= " and FUseOrgId = '" . $FStockOrgId . "'";
        }
        $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID","FilterString":"' . $FilterString . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
        $result = selectApiResult($data);
        $FMATERIALID = [];
        if (!empty($result)) {
            foreach ($result as $info) {
                $FMATERIALID[] = 'FMaterialId=' . $info[0];
            }
        }
        if (!empty($FMATERIALID)) {
            $FilterString_fstockorgid[] = '(' . implode(' or ', $FMATERIALID) . ')';
        }
    }
}
$page = $_REQUEST['page'];    //当前页数
if (empty($page)) {
    $page = 1;
}
$list1 = [];


if (!empty($_REQUEST['search_arr_List'])) {
    $FilterString_OrArr = [];
    $search = explode('|%%|', $_REQUEST['search_arr_List']);
    foreach ($search as $search_info) {
        $search_arr = explode('|@@|', $search_info);
        $search_arr[1] = trim($search_arr[1]);
        if ($search_arr[1] != '') {
            $array_key = array_keys($FieldKeys, $search_arr[0]);
            if (strtolower($search_arr[0]) == 'fstockorgid' && $search_arr[1] != '全部') {
                $FilterString_OrArr['fstockorgid'] = makefilterStr('fstockorgid.fname', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fmaterialid') {//产品编号
                $FilterString_OrArr['fmaterialid'] = makefilterStr('fmaterialid.fnumber', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fmaterialname') {
                $FilterString_OrArr['fmaterialname'] = makefilterStr('FMaterialName', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fmodel') {
                $FilterString_OrArr['fmodel'] = makefilterStr('FModel', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fstockid') {
                $FilterString_OrArr['fstockid'] = makefilterStr('fstockid.fname', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fstockname') {
                $FilterString_OrArr['fstockname'] = makefilterStr('fstockname', $search_arr);
            } else {
                $FilterString_OrArr[strtolower($search_arr[0])] = makefilterStr($FieldKeys_sarch[$array_key[0]], $search_arr);
            }
        }
    }
}
//查询
if (!empty($_REQUEST['search']) || !empty($_REQUEST['record'])) {
    $FStockOrgId = 0;    //库存组织
    $search = explode('|%%|', $_REQUEST['search']);
    foreach ($search as $search_info) {
        $search_arr = explode('|@@|', $search_info);
        $search_arr[1] = trim($search_arr[1]);
        if ($search_arr[1] != '') {
            $array_key = array_keys($FieldKeys, $search_arr[0]);
            if (strtolower($search_arr[0]) == 'fstockorgid' && $search_arr[1] != '全部') {
                $FilterString_fstockorgid['fstockorgid'] = " FStockOrgId='" . $search_arr[1] . "'";
                $FStockOrgId = $search_arr[1];
            } else if (strtolower($search_arr[0]) == 'fmaterialid') {
                //产品编号
                $FilterString_fstockorgid['fmaterialid'] = makefilterStr('fmaterialid.fnumber', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fmaterialname') {
                $FilterString_fstockorgid['fmaterialname'] = makefilterStr('FMaterialName', $search_arr);
            } else if (strtolower($search_arr[0]) == 'f_trxq_baseproperty1') {
                $FilterString_fstockorgid['f_trxq_baseproperty1'] = makefilterStr('F_TRXQ_BaseProperty1', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fmodel') {
                $FilterString_fstockorgid['fmodel'] = makefilterStr('FModel', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fstockid') {
                $FilterString_fstockorgid['fstockid'] = " fstockid = '" . $search_arr[1] . "'";
            } else if (strtolower($search_arr[0]) == 'fstockname') {
                $FilterString_fstockorgid['fstockname'] = " FStockName = '" . $search_arr[1] . "'";
            } else if (strtolower($search_arr[0]) == 'flot') {
                $FilterString_fstockorgid['flot'] = makefilterStr('flot.fname', $search_arr);
            } else if (strtolower($search_arr[0]) == 'fproducedate') {
                $FilterString_fstockorgid['fproducedate'] = " FProduceDate = '" . $search_arr[1] . "' ";
            } else if (strtolower($search_arr['fbaseunitid']) == 'fbaseunitid') {
                $FilterString_fstockorgid['fbaseunitid'] = " FBaseUnitId = '" . $search_arr[1] . "' ";
            } else if (strtolower($search_arr[0]) == 'fstockstatusid' && $search_arr[1] != '全部') {
                $FilterString_fstockorgid['fstockstatusid'] = " FStockStatusId = '" . $search_arr[1] . "' ";
            } else if (strtolower($search_arr[0]) == 'fbaseqty') {
                $FilterString_fstockorgid['fbaseqty'] = " FBaseQty >= '" . $search_arr[1] . "' ";
            } else if (strtolower($search_arr[0]) == 'favbqty') {
                $FilterString_fstockorgid['favbqty'] = " FAVBQty >= '" . $search_arr[1] . "' ";
            } else if (strtolower($search_arr[0]) == 'fstocklocid') {
                //深圳市微碧半导体有限公司   特殊开发 仓位查询
                if ($version_info['account'] == 'zhangzehua') {
                    /*	$FilterString_fstockorgid[] = " (
                            FStockLocId.FF100003.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100004.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100006.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100007.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100008.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100011.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100012.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100013.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100015.fname like '%".$search_arr[1]."%' or
                            FStockLocId.FF100019.fname like '%".$search_arr[1]."%')";*/
                    $FilterString_fstockorgid['fstocklocid'] = " ( 
						" . makefilterStr('FStockLocId.FF100003.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100004.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100006.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100007.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100008.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100011.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100012.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100013.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100015.fname', $search_arr) . " or 
						" . makefilterStr('FStockLocId.FF100019.fname', $search_arr) . ")";
                } else if ($version_info['account'] == 'hetao') {
                    $FilterString_fstockorgid['fstocklocid'] = " ( 
						FStockLocId.FF100001.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100002.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100003.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100004.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100005.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100006.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100007.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100008.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100009.fname like '%" . $search_arr[1] . "%' or 
						FStockLocId.FF100010.fname like '%" . $search_arr[1] . "%')";
                } else {

                    $FilterString_fstockorgid['fstocklocid'] = makefilterStr($FieldKeys_sarch[$array_key[0]], $search_arr);
                }

            } else {
                $FilterString_fstockorgid[strtolower($search_arr[0])] = makefilterStr($FieldKeys_sarch[$array_key[0]], $search_arr);
            }
        }
    }
    //dump($FilterString_fstockorgid);
    // @edit:dong @date:2024/08/12 @reason:  $FilterString_fstockorgid2 为配置文件中的过滤条件。 比如配置的组织 仓库等
    foreach ($list_field['k3cloud'] as $field => $item) {
        if(!$FilterString_fstockorgid[strtolower($field)]){
            if ($item['selected']) { // 默认下拉框选中的值
                $FilterString_fstockorgid2[strtolower($field)] = strtolower($field) . ' = \''.$item['selected']['id'].'\'';
            } elseif ($item['options']) { //下拉框值   只查询这些选项其他不查询
                $optionids = array_column($item['options'], 'id', 'id');
                $FilterString_fstockorgid2[strtolower($field)] = strtolower($field) . ' in (' . implode(',', $optionids) . ')';
            }
        }
    }
    //dump($FilterString_fstockorgid2);
    $FilterString_fstockorgid_str = ' FBaseQty > 0 ';
    if (!empty($FilterString_fstockorgid)) {
        $FilterString_fstockorgid_str .= ' and ' . implode(' and ', $FilterString_fstockorgid);
    }
    if (!empty($FilterString_fstockorgid2)) {
        $FilterString_fstockorgid_str .= ' and ' . implode(' and ', $FilterString_fstockorgid2);
    }
    if (!empty($FilterString_OrArr)) {
        $FilterString_fstockorgid_str = "(" . $FilterString_fstockorgid_str . ") and (" . implode(' or ', $FilterString_OrArr) . ")";
    }

    if (!in_array('fmaterialid', $FieldKeys)) {
        $FieldKeys[] = 'fmaterialid';
    }

    $FieldKeys_sarch[] = 'fid';    //即时库存   实体主键ID
    $FieldKeys[] = 'fid';
    $StartRow = 0;
    $Limit = 0;
    $prevpage = 0;
    $nextpatge = 0;

    //分页
    if ($page_show == 'yes') {
        $data = '[{"FormId":"STK_Inventory","FieldKeys":"count(1)","FilterString":"' . $FilterString_fstockorgid_str . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
        $result = selectApiResult($data);

        $all_rows = $result[0][0];    //总页数

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

    }

    //最终结果
    $data = '[{"FormId":"STK_Inventory","FieldKeys":"' . implode(',', $FieldKeys_sarch) . '","FilterString":"' . $FilterString_fstockorgid_str . '","OrderString":"","TopRowCount":"0","StartRow":"' . $StartRow . '","Limit":"' . $Limit . '"}]';
    $result = selectApiResult($data);

    if (!empty($result[0][0]->Result->ResponseStatus->Errors)) {
        $info = explode('expression is', $result[0][0]->Result->ResponseStatus->Errors[0]->Message);
        echo $info[0];
        die;
    }

    $stock_pro = [];
    $locakstock_pro = [];
    //当需要查询可用量的时，在去查询库存锁库，应该数据量比较大，影响执行效率
    if (in_array('favbqty', $FieldKeys_sarch)) {
        //库存锁库
        $stock_names = getErpValue('FStockId', $FStockOrgId);
        foreach ($stock_names as $arr) {
            $stocks[$arr['id']] = $arr['name'];
        }
        $stock_name_key = array_search('FStockName', $FieldKeys);
        foreach ($result as $info) {

            $stockid = array_search($info[$stock_name_key], $stocks);
            $locakstock_pro[$stockid] = $info[$stock_name_key];
        }
        foreach ($locakstock_pro as $stockid => $stockname) {
            $data = '[{"FormId":"STK_LockStock","FieldKeys":"FBaseLockQty,FStockId,FMaterialId","FilterString":"FStockId=' . $stockid . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $lockstock_data = selectApiResult($data);
            if (sizeOf($lockstock_data) >= 1) {
                foreach ($lockstock_data as $row) {
                    $stock_pro[$stockname][$row[2]] += $row[0];
                }
            }
        }
    }
    /*echo '<pre>';
    print_r($FieldKeys);
    echo '</pre>';
    die;*/
    //$list1  移动端数据
    /*echo '<pre>';
    print_r($result);
    echo '</pre>';
    die;*/
    foreach ($result as $key => $info) {
        foreach ($FieldKeys as $fld_key => $colname) {
            if ($colname == 'fid') {
                continue;
            }
            $value = $info[$fld_key];
            if ($colname == 'FAVBQty') {
                //$stockname = $list[$key]['StockName'];
                $list_value = $list[$key]['FBaseQty'] - $value;
            } else {
                $list_value = $info[$fld_key];
            }
            $list[$key][$colname] = $list_value;
            if ($colname == 'FMaterialId') {
                $list1[$key]['title'] = $list_value;
            }
            if (strtolower($colname) == 'fstocklocid') {    //仓位(比较特殊)
                $fid = $info[sizeOf($FieldKeys) - 1];
                $value = getFStockLocIdForName($list[$key]['FStockName'], $fid, $value);
                $list[$key][$colname] = $value;
                $list_value = $value;
            }
            $field_label = $FieldKeys_label[$colname];
            $list1[$key]['field'][] = $field_label . '：' . $list_value;
        }
    }
    /*echo '<pre>';
    print_r($list);
    echo '</pre>';
    die;*/
    //FieldKeys_label[$colname]
    /*echo '<pre>';
    print_r($list1);
    echo '</pre>';
    die;*/
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
    $res['havenextpage'] = 'no';
    $res['haveprevpage'] = 'no';
    $res['curpagenum'] = 1;
    $res['pagecount'] = $count > 0 ? 1 : 0;
    $res['totalrows'] = $count;
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
foreach ($list_field['k3cloud'] as $arr) {
    if ($arr['list'] == 'yes')
        $list_cnt += $arr['width'];
}
$kuandu = ceil(($_SESSION['bodywidth'] - 35) / $list_cnt);
foreach ($FieldKeys as $colname) {
    if ($colname == 'fid') continue;
    $list_header[] = array('label' => $list_field['k3cloud'][$colname]['label'], 'width' => $kuandu * $list_field['k3cloud'][$colname]['width']);
    $list_content[] = $colname;
}
$smarty->assign('FIELDKEYS', $list_content);
$width = 0;
foreach ($list_header as $arr) {
    $width += $arr['width'];
}
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
function getFStockLocIdForName($fstockname, $fid, $value)
{
    $version_info = getVersionInfo();
    if ($version_info['account'] == 'zhangzehua') {
        if (!empty($fstockname) && !empty($fid)) {
            switch ($fstockname) {
                case '鼎诚仓':
                    $FieldKeys = "FStockLocId.FF100003.fname";
                    break;
                case '委外加工仓':
                    $FieldKeys = "FStockLocId.FF100004.fname";
                    break;
                case 'N2C068仓':
                    $FieldKeys = "FStockLocId.FF100006.fname";
                    break;
                case '陈店俊龙仓':
                    $FieldKeys = "FStockLocId.FF100007.fname";
                    break;
                case '城中仓':
                    $FieldKeys = "FStockLocId.FF100008.fname";
                    break;
                case '都会仓':
                    $FieldKeys = "FStockLocId.FF100011.fname";
                    break;
                case '惠阳仓':
                    $FieldKeys = "FStockLocId.FF100012.fname";
                    break;
                case '虚拟仓':
                    $FieldKeys = "FStockLocId.FF100013.fname";
                    break;
                case '不良品':
                    $FieldKeys = "FStockLocId.FF100015.fname";
                    break;
                case '惠州仓':
                    $FieldKeys = "FStockLocId.FF100019.fname";
                    break;
            }
            if (!empty($FieldKeys)) {
                $FilterString = "FID='" . $fid . "'";
                $data = '[{"FormId":"STK_Inventory","FieldKeys":"' . $FieldKeys . '","FilterString":"' . $FilterString . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $result = selectApiResult($data);
                return $result[0][0];
            }
        } else {
            return $value;
        }
    } elseif ($version_info['account'] == 'hetao') {
        $FieldKeys = 'FStockLocId.FF100001.fname,FStockLocId.FF100002.fname,FStockLocId.FF100003.fname,FStockLocId.FF100004.fname,FStockLocId.FF100005.fname,FStockLocId.FF100006.fname,FStockLocId.FF100007.fname,FStockLocId.FF100008.fname,FStockLocId.FF100009.fname,FStockLocId.FF100010.fname';
        $FilterString = "FID='" . $fid . "'";
        $data = '[{"FormId":"STK_Inventory","FieldKeys":"' . $FieldKeys . '","FilterString":"' . $FilterString . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
        $result = selectApiResult($data);
        foreach ($result[0] as $v) {
            if ($v) return $v;
        }
    } else {
        return $value;
    }
}

function getApiReturnData($FormId, $FieldKeys, $FilterString, $OrderString = '', $TopRowCount = 0, $StartRow = 0, $Limit = 0)
{
    $data = '[{"FormId":"' . $FormId . '","FieldKeys":"' . $FieldKeys . '","FilterString":"' . $FilterString . '","OrderString":"' . $OrderString . '","TopRowCount":"' . $TopRowCount . '","StartRow":"' . $StartRow . '","Limit":"' . $Limit . '"}]';
    $result = selectApiResult($data);
    $FieldKeys_array = explode(',', $FieldKeys);
    if (!empty($result)) {
        foreach ($result as $key => $res) {
            foreach ($res as $key1 => $value) {
                $fieldkey = $FieldKeys_array[$key1];
                $return_data[$key][$fieldkey] = $value;
            }
        }
    }
    return $return_data;
}

function makefilterStr($field, $info)
{
    $str = ' ' . $field;
    if ($info[2] != 'undefined' && $info[2]) {
        switch ($info[2]) {
            case 'eq':
                $str .= " = '" . $info[1] . "' ";
                break;
            case 'lcon':
                $str .= " like '" . $info[1] . "%' ";
                break;
            case 'rcon':
                $str .= " like '%" . $info[1] . "' ";
                break;
            default:
                $str .= " like '%" . $info[1] . "%' ";
                break;
        }
    } elseif ($info[2] == 'undefined') {
        $str .= " ='" . $info['1'] . "' ";
    } else {
        //兼容老版本 可能是手机端
        $str .= " like '%" . $info['1'] . "%' ";
    }
    return $str;
}

//Config_ERP_Api::$api_url
function invokeLogin()
{
    $stock_view = 0;
    $regopobj = RegOp::getInstance();
    if (method_exists($regopobj, "geterpstocksearch")) {
        $stock_view = $regopobj->geterpstocksearch();
    }
    if (empty($stock_view)) {
        //return '没有授权ERP库存查询，请联系供应商授权!';
    }
    if (!file_exists(globalStatic::$root_directory . 'user_privileges/Config_ERP_Api.php')) {
        return '请先前往（user_privileges/Config_ERP_Api.php）配置参数！';
    }
    $api_cert = Config_ERP_Api::$api_url;
    $api_user = Config_ERP_Api::$api_user;
    $api_pwd = Config_ERP_Api::$api_pwd;
    $api_fromid = Config_ERP_Api::$api_fromid;
    if (empty($api_cert) || empty($api_user) || empty($api_pwd) || empty($api_fromid)) {
        return '请先前往（user_privileges/Config_ERP_Api.php）配置参数！';
    }
    $cloudUrl = $api_cert;
    //登陆参数
    $login_data = array(
        $api_fromid,//帐套Id
        $api_user,//用户名
        $api_pwd,//密码
        2052//语言标识
    );

    //定义记录Cloud服务端返回的Session
    $root_directory = explode('www', globalStatic::$root_directory);
    $cookie_jar = tempnam($root_directory[0] . '/tmp', 'CloudSession');
    $post_content = create_postdata($login_data);
    $result = invoke_login($cloudUrl, $post_content, $cookie_jar);
    $result = ldcrm_json_decode($result);
    if (!empty($result['Message']) || $result['MessageCode'] !='CheckPasswordPolicy') {
        $result['Message'] = '接口配置参数：' . $result['Message'];
    }
    return $result['Message'];
}

//api查询方法
function selectApiResult($data)
{
    global $adb;
    $api_cert = Config_ERP_Api::$api_url;
    $api_user = Config_ERP_Api::$api_user;
    $api_pwd = Config_ERP_Api::$api_pwd;
    $api_fromid = Config_ERP_Api::$api_fromid;
    $cloudUrl = $api_cert;
    $dbname = $api_fromid;
    $user = $api_user;
    $pwd = $api_pwd;
    //登陆参数
    $login_data = array(
        $dbname,//帐套Id
        $user,//用户名
        $pwd,//密码
        2052//语言标识
    );

    //定义记录Cloud服务端返回的Session
    //echo globalStatic::$root_directory;die;
    $root_directory = explode('www', globalStatic::$root_directory);
    $cookie_jar = tempnam($root_directory[0] . '/tmp', 'CloudSession');
    $post_content = create_postdata($login_data);

    $a = invoke_login($cloudUrl, $post_content, $cookie_jar);
    $a = ldcrm_json_decode($a);
    if($a['MessageCode'] !='CheckPasswordPolicy') {
        return [];
    }
    //print_r($a);die;
    $post_content = create_postdata($data);
    $result = invoke_select($cloudUrl, $post_content, $cookie_jar);
    //print_r($result);die;
    $result = json_decode($result);
    return $result;
}

//K3 Cloud 登陆验证
function check_invoke_login($cloudUrl, $user, $pwd, $dbname)
{
    //登陆参数
    $data = array(
        $dbname,//帐套Id
        $user,//用户名
        $pwd,//密码
        2052//语言标识
    );
    //定义记录Cloud服务端返回的Session
    $cookie_jar = tempnam('G:\crm\ldcrm/tmp', 'CloudSession');
    $post_content = create_postdata($data);
    $loginurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
    return invoke_post($loginurl, $post_content, $cookie_jar, TRUE);
}

//K3 Cloud 登陆
function invoke_login($cloudUrl, $post_content, $cookie_jar)
{
    $loginurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
    return invoke_post($loginurl, $post_content, $cookie_jar, TRUE);
}

//K3 Cloud 保存
function invoke_save($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 审核
function invoke_audit($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 查看
function invoke_view($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.View.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 删除
function invoke_delete($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 分配
function invoke_allocate($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Allocate.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 反审核
function invoke_unaudit($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.unAudit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 提交
function invoke_submit($cloudUrl, $post_content, $cookie_jar)
{

    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 状态转换
function invoke_statusconvert($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.StatusConvert.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

function invoke_select($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

function invoke_post($url, $post_content, $cookie_jar, $isLogin)
{
    $ch = curl_init($url);

    $this_header = array(
        'Content-Type: application/json',
        'Content-Length: ' . strlen($post_content)
    );

    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $this_header);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post_content);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    if ($isLogin) {
        curl_setopt($ch, CURLOPT_COOKIEJAR, $cookie_jar);
    } else {
        curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);
    }
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
}

//构造Web API请求格式
function create_postdata($args)
{
    $postdata = array(
        'format' => 1,
        'useragent' => 'ApiClient',
        'rid' => create_guid(),
        'parameters' => $args,
        'timestamp' => date('Y-m-d'),
        'v' => '1.0'
    );
    return json_encode($postdata);
}

//生成guid
function create_guid()
{
    $charid = strtoupper(md5(uniqid(mt_rand(), true)));
    $hyphen = chr(45);// "-"
    $uuid = chr(123)// "{"
        . substr($charid, 0, 8) . $hyphen
        . substr($charid, 8, 4) . $hyphen
        . substr($charid, 12, 4) . $hyphen
        . substr($charid, 16, 4) . $hyphen
        . substr($charid, 20, 12)
        . chr(125);// "}"
    return $uuid;
}

function getErpValue($colname, $FUseOrgId)
{
    $options = [];
    if (strtolower($colname) == 'fstockorgid') {
        $data = '[{"FormId":"ORG_Organizations","FieldKeys":"FOrgID,FName","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    } else if (strtolower($colname) == 'fstockstatusid') {
        $data = '[{"FormId":"BD_StockStatus","FieldKeys":"FStockStatusId,FName","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    } else if (strtolower($colname) == 'fbaseunitid' || strtolower($colname) == 'fstockunitid') {
        $data = '[{"FormId":"BD_UNIT","FieldKeys":"FUNITID,FNAME","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    } else if (strtolower($colname) == 'fstockid') {
        if (!empty($FStockOrgId)) {
            $FilterString .= " and FUseOrgId = '" . $FStockOrgId . "'";
        }
        $data = '[{"FormId":"BD_STOCK","FieldKeys":"fstockid,fname","FilterString":"' . $FilterString . '","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    }
    $result = selectApiResult($data);
    if (!empty($result)) {
        foreach ($result as $arr) {
            $options[] = array('id' => $arr[0], 'name' => $arr[1]);
        }
    }
    return $options;
}