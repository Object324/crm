<?php
/**
 * User: Dong
 * Project: 灵当CRM
 * Date: 2020/10/14 10:38
 * Description: 克莱门特 bom清单查询

http://101.132.182.242/climaveneta/index.php?module=Customreport&action=climaveneta_bomSearch
 *
 * B100103432
 */


global $adb,$theme,$current_user;
if(@!$current_user->id){
    echo '没有权限';die;
}
$smarty = new lingdangCRM_Smarty();
$isernr = vtlib_purify($_REQUEST['search_no']);  //序列号
$idnrk = vtlib_purify($_REQUEST['search_idnrk']);   //备件号
$kmptx = vtlib_purify($_REQUEST['search_kmptx']);  //备件名称
$apiId = vtlib_purify($_REQUEST['apiId']);  //接口id

$language = $_REQUEST['language']?$_REQUEST['language']:'zh';
$langArr = array(
    'zh'=>array(
        'title'=>'备件清单查询',
        'xlh'=>'Serial Number',
        'xh'=>'型　　号',
        'bjh'=>'备 件 号',
        'bjmc'=>'备件名称',
        'cx'=>'查询',
        'cxh'=>'序号',
        'cbjh'=>'备件号',
        'cxsdj'=>'销售单价（RMB）',
        'cjgyxq'=>'价格有效期',
        'cbjmc'=>'备件名称',
        'cxqsl'=>'需求数量',
        'cdw'=>'单位',
        'cdj'=>'等级',
        'csfjy'=>'是否禁用',
        'msg1'=>'查无此号',
        'msg2'=>'请联系售后'
    ),
    'en'=>array(
        'title'=>'Spare Part List Query',
        'xlh'=>'Serial Number',
        'xh'=>'Model',
        'bjmc'=>'Spare Part Description',
        'cx'=>'Query',
        'cxh'=>'No.',
        'cbjh'=>'Spare Part',
        'cxsdj'=>'Unit Price(RMB)',
        'cjgyxq'=>'Valid Date',
        'cbjmc'=>'Spare Part Description',
        'cxqsl'=>'Quantity',
        'cdw'=>'Unit',
        'cdj'=>'Level',
        'csfjy'=>'Status',
        'msg1'=>'Not found',
        'msg2'=>'Please contact our After Sales Service hotline: 4008807575'
    )
);
$smarty->assign('LANG',$langArr[$language]);
$smarty->assign('LANGUAGE',$language);

$smarty->assign('GLOBALMINVERSION','1');
//字段权限 是否显示价格
$focus = CRMEntity::getInstance('Products');
$fields = $focus->fieldobj->getModuleFields();
$fieldPermissions='no';
foreach ($fields as $columnName =>$info){
    if($info->columnName == 'unit_price' ){
        $fieldPermissions ='yes';
        break;
    }
}

$smarty->assign('FIELDPERMISSIONS',$fieldPermissions);
//end字段权限
$_REQUEST['diony']='yes';
if($isernr !='' && isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
    $return_data = getSoapData($isernr,$language,$apiId);
    // print_r($return_data);die;
    if($return_data['ewreturn']['type'] !=''){
        $errorType = $return_data['ewreturn']['type'];
        $msg =''; //提醒消息
        if($errorType == 'A'){
            $msg = $langArr[$language]['msg1'];
        }else{
            $msg = $langArr[$language]['msg2'];
        }
    }

    $model = getProductModel($isernr);
//    机组型号不存在就直接不显示数据
    if(!$model && $msg ==''){
        $msg = $langArr[$language]['msg2'];
    }

    //有错误信息直接返回
    if($msg){
        $content = $smarty->fetch("climaveneta_bomSearch_content.tpl");
        ConvertTojsonString(-1,array('content'=>$content),$msg);
    }

    $smarty->assign('MODEL',$model);


//    过滤data
    $item = $return_data['etresult']['item'];
    $array_level = arrayLevel($item);
    if($array_level == 1){
        $data[0] = $item;
    }else{
        $data = $item;
    }
    if(!empty($data)){
        $apiDataNum = count($data);
        $apiFilterNum = count($data);
        $matnrArr = array_column($data,'idnrk'); //需要查询价格的编码
        $crmArr = getProductInfo($matnrArr); //crm中此编码的值
        //合并搜索结果
        foreach ($data as $key =>$value){
            foreach ($crmArr as $product_no =>$info){
                if($value['idnrk'] == $product_no ){
                    $data[$key] = array_merge($data[$key],$info);
                }
            }
        }
        $sparepartKey = $_REQUEST['language'] =='en'?'sparepart_E':'sparepart';
        foreach ($data as $key =>$info){
            //过滤api接口返回数组中 idnrk 不包括 $idnrk的值
            if($idnrk && strpos($info[get_variable_name($idnrk)],$idnrk) === false) {
                unset($data[$key]);
            }
            if($kmptx && strpos(strtolower($info[$sparepartKey]),strtolower($kmptx)) === false) {
                unset($data[$key]);
            }
        }
        //print_r($data);die;
        //$data按照bomposnr 排序
        $data = sortArr($data,'idnrk',SORT_ASC,SORT_STRING);
    }
    $smarty->assign('DATA',$data);
}


if (isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '') {
    $content = $smarty->fetch("climaveneta_bomSearch_content.tpl");
    $apiMsg = '查询返回'.$apiDataNum.'条，显示'.$apiFilterNum.'条';
    ConvertTojsonString(1,array('content'=>$content,'model'=>$model,'apimsg' =>$apiMsg),'success');
} else {
    $smarty->display('climaveneta_bomSearch.tpl');
}




//获取接口的数据
function getSoapData($isernr,$language='zh',$apiId='8021'){
    /*注意
    *host必须添加解析 否则报错
    *58.33.240.18 apcup1.climaveneta.com    apcup1
58.33.240.18 apcup2.climaveneta.com        apcup2
    */
    //error_reporting(0);

    ini_set("soap.wsdl_cache_enabled", "0");
    $wsd='http://101.132.182.242/8021.wsdl';
    if($apiId == '8022'){
        $wsd='http://101.132.182.242/8022.wsdl';
    }
    if($language =='zh'){
        $ISpras='1';
    }else{
        $ISpras='E';
    }
    //echo $wsd;die;
    //实例化对象
    unset($client);
    $client=new SoapClient($wsd);
//  H100000890 B100103432   B100035540

//    $isernr ='B100103432';
    $result=$client->ZmmSpinfGet(array('EtResult'=>'',"ISernr"=>$isernr,'ISpras'=>$ISpras));
    return object_array($result);

}

function arrayLevel($arr){
    $al = array(0);
    function aL($arr,&$al,$level=0){
        if(is_array($arr)){
            $level++;
            $al[] = $level;
            foreach($arr as $v){
                aL($v,$al,$level);
            }
        }
    }
    aL($arr,$al);
    return max($al);
}
/**
 * Name: 获取当前需要查询的编码产品在crm中的一些值
 * User: Dong
 * Date: 2020/10/14 16:39
 * @param $matnrArr
 * @return array
 * @throws Exception
 */
function getProductInfo($matnrArr){
    global  $adb;
    $sql = 'SELECT unit_price,product_no,cf_2901,cf_2903,cf_2904,unit_module,discontinued FROM ld_products  LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid  where deleted = 0 ';
    $tmpString ='';
    foreach ($matnrArr as $item){
        if($tmpString ==''){
            $tmpString .= "'".$item."'";
        }else{
            $tmpString .= ",'".$item."'";
        }
    }
    $sql .=' and  product_no in ('.$tmpString.')' ;
    $result = $adb->pquery($sql);
    $num_rows = $adb->num_rows($result);
    $return =array();
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $product_no = $adb->query_result($result,$i,'product_no');
            $unit_price = $adb->query_result($result,$i,'unit_price'); //价格
            $cf_2901 = $adb->query_result($result,$i,'cf_2901'); //有效期
            $cf_2903 = $adb->query_result($result,$i,'cf_2903'); //备件名中文
            $cf_2904 = $adb->query_result($result,$i,'cf_2904'); //备件名 英文
            $unit_module = $adb->query_result($result,$i,'unit_module'); //机组型号
            $discontinued = $adb->query_result($result,$i,'discontinued'); //禁用
            $return[$product_no] = array(
                'price'=>setNumberFormat($unit_price),
                'validity'=>$cf_2901,
                'sparepart'=>$cf_2903,
                'sparepart_E'=>$cf_2904,
                'unit_module'=>$unit_module,
                'discontinued'=>$discontinued
            );
        }
    }
    return $return;
}

function getProductModel($isernr){
    global  $adb;
    $sql ='select unit_module from ld_products where product_no LIKE  \'%'.$isernr.'%\' and deleted=0';
    $result = $adb->pquery($sql);
    $num_row =$adb->num_rows($result);
    if($num_row==1){
        return $adb->query_result($result,0,0);
    }
    return false;
}
//obj转array 并把大写key转为小写
//function object_array($array) {
//    if(is_object($array)) {
//        $array = (array)$array;
//    }
//    if(is_array($array)) {
//        $array = array_change_key_case($array);
//        foreach($array as $key=>$value) {
//            $array[$key] = object_array($value);
//        }
//    }
//    return $array;
//}

/**
 * @param String $var  要查找的变量
 * @param Array $scope 要搜寻的范围
 * @param String 变量名称
 * @return false|int|string
 */
function get_variable_name(&$var, $scope=null){

    $scope = $scope==null? $GLOBALS : $scope; // 如果没有范围则在globals中找寻
// 因有可能有相同值的变量,因此先将当前变量的值保存到一个临时变量中,然后再对原变量赋唯一值,以便查找出变量的名称,找到名字后,将临时变量的值重新赋值到原变量
    $tmp = $var;
    $var = 'tmp_value_'.mt_rand();
    $name = array_search($var, $scope, true); // 根据值查找变量名称
    $var = $tmp;
    return $name;
}

/**
 * @edit:dong
 * @data:2020/11/10
 * @reason:数组排序
 * $data表示二维数组，结构比如说从数据读取出来的多行表结构，'date'表示每行里面的一个字段，通过这个字段排序
 * SORT_DESC表示降序排列，SORT_STRING表示设置'date'字段的比较以字符串方式进行
 * @description:
 */
function sortArr($arrays,$sort_key,$sort_order=SORT_ASC,$sort_type=SORT_NUMERIC ){
    $key_arrays =array();
    if(is_array($arrays)){
        foreach ($arrays as $array){
            if(is_array($array)){
                $key_arrays[] = $array[$sort_key];
            }else{
                return false;
            }
        }
    }else{
        return false;
    }
    array_multisort($key_arrays,$sort_order,$sort_type,$arrays);
    return $arrays;
}