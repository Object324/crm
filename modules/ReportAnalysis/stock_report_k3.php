<?php
global $adb,$theme,$current_user;

$root_directory = explode('www',globalStatic::$root_directory);
if(!file_exists(globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php') && file_exists(globalStatic::$root_directory.'user_privileges/Config_ERP_Api_Default.php')) {
    copy(globalStatic::$root_directory.'user_privileges/Config_ERP_Api_Default.php',globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php');
}
require_once(globalStatic::$root_directory.'user_privileges/Config_ERP_Api.php');

$version_info = getVersionInfo();
$is_ajax = $_REQUEST['is_ajax'];
$_REQUEST['diony']='yes';

$con_erp_db = setConnentErpDb(Config_ERP_Api::$db_name,Config_ERP_Api::$db_username,Config_ERP_Api::$db_password,Config_ERP_Api::$db_server);
if(!empty($con_erp_db['error_log'])){
    $msg ='错误提示：数据库连接失败， Config_ERP_Api文件中的配置信息！ '.$con_erp_db['error_log'].'【' . microDateTime() . '】';
    ConvertTojsonString(-1, '', $msg);
}
$con_erp_db = $con_erp_db['conResult'];
if(empty($_REQUEST['from_mobile'])){
    $smarty=new lingdangCRM_Smarty();
}
$list_field = arrayKeyToLower(Config_ERP_Api::$list_field);
$page_show = Config_ERP_Api::$page_show;
$page_number = Config_ERP_Api::$page_number;
$product_type = Config_ERP_Api::$product_type;
$productNoField= 'product_no';
if (property_exists('Config_ERP_Api','productNoField')){
    $productNoField = Config_ERP_Api::$productNoField;
}
//查询条件
if(!empty($list_field['k3'])){
    foreach($list_field['k3'] as $colname =>$info){
        $colname = strtolower($colname);
        if($info['search'] == 'yes'){
            if (in_array($colname, array('fstockid', 'ftockplaceid', 'funitid'))) {
                if ($info['options']) {
                    $list_search[$colname] = array(
                        'label' => $info['label'],
                        'type' => 'select',
                        'options' => $info['options'],
                        'optionsAllShow' => $info['optionsAllShow'],
                    );
                } else {
                    $options = getErpValue($colname, $info, $con_erp_db);
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
            } else if (strpos($colname, 'qty') === false && strpos($colname, 'date') === false) {
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
        if($info['list'] == 'yes'){
            //$FieldKeys_sarch   用来查询用的
            if ($info['targettablefield']) {
                $tmpField = $info['targettable'] . '.' . $info['targettablefield'] . ' as ' . $colname;
            }else{
                $tmpField = $info['table'].'.'.$colname .' as '. $colname;
            }
            $FieldKeys_sarch[] = $tmpField;
            $FieldKeys[] = $info['table'].'.'.$colname;
            $FieldKeys_label[$colname] = $info['label'];
        }
        $all_colnames[] = $colname;
    }
}


if(!empty($_REQUEST['record'])){
    $query = "select $productNoField from ld_products where productid = ?";
    $result = $adb->pquery($query,array($_REQUEST['record']));
    $product_no = $adb->query_result($result,0,0);
    if(!$product_no){
        ConvertTojsonString(-1,[],'record值'.$_REQUEST['record'].'对应的产品编码不存在');
    }
    $FilterArr[] = 't_icitem.fnumber = \''.$product_no.'\'';
}
$page = $_REQUEST['page'];	//当前页数
if(empty($page)){
    $page = 1;
}
$list1 = [];

//查询
if(!empty($_REQUEST['search']) || !empty($_REQUEST['record'])) {
    $search = explode('|%%|', $_REQUEST['search']);
    foreach ($search as $search_info) {
        $search_arr = explode('|@@|', $search_info);
        $search_arr[1] = trim($search_arr[1]);
        if ($search_arr[1] != '') {
            $array_key = array_keys($FieldKeys, $search_arr[0]);
            $FilterArr[strtolower($search_arr[0])] = makefilterStr($list_field[$product_type][$search_arr[0]], $search_arr);
        }
    }
    foreach ($list_field['k3'] as $colname => $info) {
        if (!$FilterArr[strtolower($colname)]) {
            if ($info['selected']) {
                $FilterArr[strtolower($colname)] = $info['table'] . '.' . $colname . ' = ' . $info['selected']['id'];
            } elseif ($info['options']) {
                $optionids = array_column($info['options'], 'id', 'id');
                $FilterArr[strtolower($colname)] = $info['table'] . '.' . $colname . ' in (' . implode(',', $optionids) . ')';
            }
        }
    }


    if (!empty($FilterArr)) {
        if (!empty($_REQUEST['from_mobile']) && $_REQUEST['from_mobile'] == 'yes') {
            $FilterString_str = implode(' or ', $FilterArr);
        } else {
            $FilterString_str = implode(' and ', $FilterArr);
        }
    }

    //分页
    if ($page_show == 'yes') {
        $countSql = "select count(1) num from icinventory left join t_icitem on icinventory.fitemid = t_icitem.fitemid left join t_item on icinventory.fitemid = t_item.fitemid left join t_stock on icinventory.fstockid = t_stock.fitemid left join t_stockplace on icinventory.fstockplaceid = t_stockplace.fspid left join t_measureunit on t_measureunit.fmeasureunitid = t_icitem.funitid where 1=1  ";
        if($FilterString_str){
            $countSql .=' and '.$FilterString_str;
        }
        $result = $con_erp_db->getRow($countSql);

        $all_rows = $result['num'];	//总页数
        $Limit = $page_number;
        $all_page = ceil($all_rows/$Limit);
        if($page > 1 && $page <= $all_page){
            $prevpage = $page - 1;
        }
        if($page < $all_page){
            $nextpatge = $page + 1;
        }
        $StartRow = ($page - 1)*$Limit;
        if(empty($_REQUEST['from_mobile'])) {
            $smarty->assign('ALL_PAGE', $all_page);
            $smarty->assign('PREVPAGE', $prevpage);
            $smarty->assign('NEXTPAGE', $nextpatge);
            $smarty->assign('ALL_ROWS', $all_rows);
        }

    }
    $selectSql = "select ROW_NUMBER() OVER(ORDER BY icinventory.fitemid)  as  'id' , ".implode(',',$FieldKeys_sarch) .' from  icinventory left join t_icitem on icinventory.fitemid = t_icitem.fitemid left join t_item on icinventory.fitemid = t_item.fitemid left join t_stock on icinventory.fstockid = t_stock.fitemid left join t_stockplace on icinventory.fstockplaceid = t_stockplace.fspid left join t_measureunit on t_measureunit.fmeasureunitid = t_icitem.funitid where 1=1  ';
    if($FilterString_str){
        $selectSql .=' and '.$FilterString_str;
    }

    $notGetnNm = ($page-1)*$page_number;
    //组合分页sql
    $pageSelect = "select top $page_number * from ($selectSql) tmp where tmp.id not in (select top $notGetnNm id from ($selectSql) a )";

    $result = $con_erp_db->getAll($pageSelect);

    $list1 = $result;
    $list = $result;


    //FieldKeys_label[$colname]
    /*echo '<pre>';
    print_r($list1);
    echo '</pre>';
    die;*/
}
if($_REQUEST['from_mobile_product'] == 'yes'){
    $res['list'] = $list1;//数据
    ConvertTojsonString(1,array('entry'=>$res,'stock_view'=>'ERP'),'');
}
if(!empty($_REQUEST['from_mobile']) && $_REQUEST['from_mobile'] == 'yes'){
    $res['list1'] = $list1;//数据
    $count = sizeOf($list1);
    foreach($list_search as $colname => $arr){
        $fieldtype = 1;
        $option = [];
        $search_label[] = $arr['label'];
        if(!empty($arr['options'])){
            $fieldtype = 15;
            $option[] = array(
                "select"=> "yes",
                "text"=>"全部",
                "value"=>"全部"
            );
            foreach($arr['options'] as $opt){
                $option[] = array(
                    "select"=> "no",
                    "text"=>$opt['name'],
                    "value"=>$opt['id']
                );
            }
            $res['report_high_search'][] = array(
                'fieldlabel'=>$arr['label'],
                'fieldname' => $colname,
                'fieldtype'=>$fieldtype,
                'text'=>'全部',
                'option' => $option,
            );
        }else{
            $res['report_high_search'][] = array(
                'fieldlabel'=>$arr['label'],
                'fieldname' => $colname,
                'fieldtype'=>$fieldtype,
                'text'=>''
            );
        }

    }
    $res['search_reminds'] = implode('、',$search_label);//模糊搜索
    $res['havenextpage'] = 'no';
    $res['haveprevpage'] = 'no';
    $res['curpagenum'] = 1;
    $res['pagecount'] = $count>0?1:0;
    $res['totalrows'] = $count;
    ConvertTojsonString(1,$res,'');
}
//查询列  每行显示数
$search_view_rows = Config_ERP_Api::$search_view_rows;
$search_rows = 1;
$rows = 1;
foreach($list_search as $key => $arr){
    if($search_rows <= $search_view_rows){
        $new_list_search[$rows][$key] = $arr;
        if($search_rows == $search_view_rows){
            $rows++;
            $search_rows = 1;
        }else{
            $search_rows++;
        }

    }
}
//duan 20230626 查询erp库存数量时，进行小数位处理，使用系统参数：设置单据分录明细中数量字段小数位数
$system_49 = getSys_deploy(49);
$system_deploy_49 = 2;
if(is_numeric($system_49['deploy_value'])){
    $system_deploy_49 = $system_49['deploy_value'];
}
foreach($list as $tmp_key => $tmp_value){
    if(isset($tmp_value['fqty'])){
        $list[$tmp_key]['fqty'] = number_format($tmp_value['fqty'],$system_deploy_49);
    }
    if(isset($tmp_value['fqtylock'])){
        $list[$tmp_key]['fqtylock'] = number_format($tmp_value['fqtylock'],$system_deploy_49);
    }
}
$smarty->assign('PAGE',$page);
$smarty->assign('search_view_rows',$search_view_rows*2);
$smarty->assign('PRODUCTNO',$product_no);
$smarty->assign('SEARCHCOLNAME',implode(',',$all_colnames));
$smarty->assign('SEARCHLIST',$new_list_search);
$smarty->assign('LISTENTITY',$list);
//显示列、宽度计算
//显示列、宽度计算
if (Config_ERP_Api::$product_type == 'k3') {
    $product_type = 'k3';
    foreach ($list_field['k3'] as $arr) {
        if ($arr['list'] == 'yes')
            $list_cnt += $arr['width'];
    }
}
$kuandu = ceil(($_SESSION['bodywidth']-35)/$list_cnt);
foreach($FieldKeys as $colname){
    if($colname == 'fid')continue;
    $colname = explode('.',$colname)[1];
    $list_header[] = array('label' => $list_field[$product_type][$colname]['label'],'width' => $kuandu*$list_field[$product_type][$colname]['width']);
    $list_content[] = $colname;
}


$smarty->assign('FIELDKEYS',$list_content);
$width = 0;
foreach($list_header as $arr){
    $width += $arr['width'];
}
$smarty->assign('HEADERLENGTH',sizeOf($list_header));
$smarty->assign('HEADER',$list_header);
$smarty->assign('WIDTH',$width);
$smarty->assign('CURRENT_USER_ID',$current_user->id);
$_REQUEST['diony'] = 'yes';

if(!empty($_REQUEST['record'])){
    $content=$smarty->fetch("stock_report/search.tpl");
    $arr['title']=getFixedLabel("PRODUCTQTYINSTOCKTITLE");
    $arr['oktext']='';
    $arr['canceltext']='';
    $arr['content']=$content;
    ConvertTojsonString(1,$arr,"success");
}else{
    if($is_ajax == "yes"){
        $smarty->assign('PAGE',$page);
        $smarty->display('stock_report/search_content.tpl');
    }else{
        $smarty->assign('list',$list);
        $smarty->display('stock_report/search.tpl');
    }
}











function getErpValue($colname,$info,$con_erp_db){
    $result = [];
    switch ($colname) {
        case 'fstockid':
            $sql = 'select fitemid id ,fname name from ' . $info['targettable'] . ' where fdeleted =0';
            break;
        case 'ftockplaceid':
            $sql = 'select fspid id,fname name from ' . $info['targettable'] . ' where fdeleted =0';
            break;
        case 'funitid':
            $sql = 'select fmeasureunitid id,fname name from ' . $info['targettable'] . ' where fdeleted =0';
            break;
        default:
            break;
    }
    $result =$con_erp_db->getAll($sql);
    return $result;
}
function setConnentErpDb($erp_dbname, $erp_dbuser, $erp_dbpswd, $erp_dbhost)
{
    crm_load_class_file('PdoSqlServer','include/ODBC');
    $dbConfig = array(
        'hostname' => $erp_dbhost,
        'username' => $erp_dbuser,
        'password' => $erp_dbpswd,
        'database' => $erp_dbname,
    );
    if(getOS() =='Linux'){
        $dbConfig['dsn'] = 'sqlsrv:Server=' . $erp_dbhost . ';Database=' . $erp_dbname;
    }else{
        $dbConfig['dsn']  = 'odbc:Driver={SQL Server};Server=' . $erp_dbhost . ';Database=' . $erp_dbname;  //这一条在window上可以用  linux不能用  彩色可能是微软odbc老版驱动支持的
    }
    // @edit:dong @date:2021/05/07 @reason: 多张套反写 置空前一次的数据库连接
    if ($_REQUEST['action'] == 'ExchInitialCrm') {
        $PdoSqlServer = new PdoSqlServer($dbConfig, 'new');
    } else {
        $PdoSqlServer = new PdoSqlServer($dbConfig);
    }
    $result = array(
        'error_log' => $PdoSqlServer::$error,
        'conResult' => $PdoSqlServer,
    );
    return $result;
}

function makefilterStr($field,$info){
    $str = $field['table'].'.'.$info[0];

    if($info[2] !='undefined' && $info[2]){
        switch ($info[2]){
            case 'eq':
                $str .=" = '".$info[1]."' ";
                break;
            case 'lcon':
                $str .=" like '".$info[1]."%' ";
                break;
            case 'rcon':
                $str .=" like '%".$info[1]."' ";
                break;
            default:
                $str .=" like '%".$info[1]."%' ";
                break;
        }
    }elseif($info[2]=='undefined'){
        $str .=" ='".$info['1']."' ";
    }else{
        //兼容老版本 可能是手机端
        $str .=" like '%".$info['1']."%' ";
    }
    return $str;
}

function getOS(): string
{
    if (PATH_SEPARATOR == ':') {
        return 'Linux';
    } else {
        return 'Windows';
    }
}