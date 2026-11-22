<?php
/*
edit:wangcong;
date:2021-11-23
reason:
*/

global $adb;
$module = 'ServiceCharge';
$focus = CRMEntity::getInstance($module);
$tablename = $focus->table_name;
$tablename_index = $focus->table_index;
$tablenamescf = $focus->customFieldTable[0];
$tablenamescf_index = $focus->customFieldTable[1];

$columnname_product = "cf_4643"; //东贸-主营品类
$type_id_product="下游客户";//东贸-下游客户

$columnname_bus= "cf_5108"; //东贸-大巴车类
$type_id_bus="大巴车";//东贸-大巴车

//用户点击搜索时触发
if($_REQUEST['mode']=='search'){
    //接收用户选择的主营品类型
    $listvalue_product_str=$_REQUEST['listvalue_product_str'];
    $typesql_product = '';
    if($listvalue_product_str != 'All'){
        $listvalue_product_str_new=rtrim($listvalue_product_str, ',');
        if(!empty($listvalue_product_str_new)&&$listvalue_product_str_new != ""){
            $listvalue_product_str = explode(',',$listvalue_product_str_new);
            $str = "";
            for($i=0;$i<sizeof($listvalue_product_str);$i++){
                $str .= 'cf_4643'.' = '.' "'.$listvalue_product_str[$i].'" ';
                //$str .= "cf_4643"  .  " = "   .  " ' "  .$listvalue_product_str[$i].  " ' ";
                if($i != sizeof($listvalue_product_str)-1){
                    $str .= ' or ';
                }
            }
            $typesql_product = " and ($str)";
        }else{
            $typesql_product = " and 1=2";
        }
        
    }
    
    //接收用户选择的大巴车类型
    $listvalue_bus_str=$_REQUEST['listvalue_bus_str'];
    $typesql_bus = '';
    if($listvalue_bus_str != 'All'){
        $listvalue_bus_str_new=rtrim($listvalue_bus_str, ','); 
        if(!empty($listvalue_bus_str_new)&&$listvalue_bus_str_new != ""){
            $listvalue_bus_str = explode(',',$listvalue_bus_str_new);
            $str = "";
            for($i=0;$i<sizeof($listvalue_bus_str);$i++){
                $str .= 'cf_5108'.' = '.' "'.$listvalue_bus_str[$i].'" ';
                //$str .= "cf_4643"  .  " = "   .  " ' "  .$listvalue_product_str[$i].  " ' ";
                if($i != sizeof($listvalue_bus_str)-1){
                    $str .= ' or ';
                }
            }
            $typesql_bus = " and ($str)";
        }else{
            $typesql_bus = " and 1=2";
        }
        
    }
    
    $distance = $_REQUEST['distance_str'];
    $address = $_REQUEST['address_str'];
    $addressinfo = getCoordinateByTecentApi($address);
    $first_map_lat = $addressinfo['result']['location']['lat'];
    $first_map_lng = $addressinfo['result']['location']['lng'];
    
    $r = 6371.393;
    $cirNS = $first_map_lat*pi()/180;
    $cirWE = $first_map_lng*pi()/180;
    
    
    //查询符合要求的下游客户信息
    $store_query = "round($r*ACOS(COS($cirNS)*COS(latitude*pi()/180)*COS($cirWE-longtitude*pi()/180)+SIN($cirNS)*SIN(latitude*pi()/180))*1000)";
    $page_list_query  = " and $store_query  < " . $distance;    
    $sql = "SELECT longtitude,latitude,location_address,accountname,$columnname_product,$columnname_bus,cf_4662,customform10_id,ld_customform10.form10_type from $tablename 
            inner join $tablenamescf on $tablename.$tablename_index=$tablenamescf.$tablenamescf_index  
            INNER JOIN ld_customform10 on $tablename.customform10_id = ld_customform10.customform10id
            where $tablename.deleted = 0 and ((ld_customform10.form10_type=? $typesql_product) or (ld_customform10.form10_type=? $typesql_bus) ) and (ifnull(longtitude,0)>0 and ifnull(latitude,0)>0 )  $page_list_query";
    //dump($sql);
    $result = $adb->pquery($sql,array($type_id_product,$type_id_bus));
    $num_rows = $adb->num_rows($result);
    $point_arr=array();
    $product_count=0;
    $bus_count=0;
    $all_location = array();
    $all_accountinfo = array();
    $count = 0;
    for($i = 0;$i<$num_rows;$i++){
        $longtitude = $adb->query_result($result,$i,'longtitude');
        $latitude = $adb->query_result($result,$i,'latitude');
        $locationaddress = $adb->query_result($result,$i,'location_address');
        $accountname = $adb->query_result($result,$i,'accountname');
        $customform10_id = $adb->query_result($result,$i,'customform10_id');
        $product_type = $adb->query_result($result,$i,$columnname_product);
        $bus_type = $adb->query_result($result,$i,$columnname_bus);
        $bus_number = $adb->query_result($result,$i,'cf_4662');
        $form10_type = $adb->query_result($result,$i,'form10_type');
        if(($product_type !== '' && !empty($product_type))|| ($bus_type !== '' && !empty($bus_type))){
            if($form10_type == $type_id_product){
                $product_count+=1;
            };
            if($form10_type == $type_id_bus){
                $bus_count+=1;
            };
                
            $tmp_location = array('longtitude'=>$longtitude,'latitude'=>$latitude);
            $in_arr = false;
            foreach($all_location as $key =>$location){
                if($location['longtitude'] ==$longtitude && $location['latitude'] ==$latitude){
                    $index = $key;
                    $in_arr = true;
                    break;
                }else{
                    $in_arr = false;
                }
            }
            if(!$in_arr){
                $all_location[] = $tmp_location;
            }
            $info = array('longtitude'=>$longtitude,'latitude'=>$latitude,'locationaddress'=>$locationaddress,'accountname'=>$accountname,'type'=>$form10_type,'product_type'=>$product_type,'bus_type'=>$bus_type,'bus_number'=>$bus_number);
            $columnnamea_arr = array('accountname','type','product_type','bus_type','bus_number','locationaddress','latitude','longtitude');
            
            foreach($columnnamea_arr as $tmp_columnname){
                if($in_arr){
                    $tmp_accountinfo = $all_accountinfo[$index][$tmp_columnname];
                    $tmp_accountinfo[] = $info[$tmp_columnname];
                    $all_accountinfo[$index][$tmp_columnname] = $tmp_accountinfo;
                }else{
                    $tmp_accountinfo = array();
                    $tmp_accountinfo[] = $info[$tmp_columnname];
                    $tmp_key = sizeof($all_location)-1;
                    $all_accountinfo[$tmp_key][$tmp_columnname] = $tmp_accountinfo;
                }
            }
            

            $point_arr[] =$info;   
        }

    }
    //返回中心点的经纬度
    $arr['first_map_lat'] = $first_map_lat;
    $arr['first_map_lng'] = $first_map_lng;
    $arr['distance'] = $distance;
    $arr['address'] = $address;
    $arr['all_count'] = $num_rows;
    $arr['product_count'] = $product_count;
    $arr['bus_count'] = $bus_count;
    $arr['point_arr'] = ldcrm_json_encode($point_arr);
    $arr['all_accountinfo'] = ldcrm_json_encode($all_accountinfo);
    //dump($all_accountinfo);
    ConvertTojsonString(1,$arr,'success');
}





//当用户拖拽中心标记点时触发
if($_REQUEST['mode']=='drag'){
    //接收用户输入的中心点地址
    $first_map_lat=$_REQUEST['account_center_drag_lat'];
    $first_map_lng=$_REQUEST['account_center_drag_lng'];
    $distance = $_REQUEST['distance_str'];
    
    //调用腾讯地图API接口，实现逆地址解析，即把经纬坐标转换为文字地址
    $url = 'https://apis.map.qq.com/ws/geocoder/v1/?location='.$first_map_lat.','.$first_map_lng.'&key=T3CBZ-INP3X-5TD4Z-TZ3YE-AXBC5-6RBAU&get_poi=1';
    $address = file_get_contents($url);
    
    //接收用户选择的主营品类型
    $listvalue_product_str=$_REQUEST['listvalue_product_str'];
    $typesql_product = '';
    if($listvalue_product_str != 'All'){
        $listvalue_product_str_new=rtrim($listvalue_product_str, ',');
        if(!empty($listvalue_bus_str_new)&&$listvalue_bus_str_new != ""){
            $listvalue_product_str = explode(',',$listvalue_product_str_new);
            $str = "";
            for($i=0;$i<sizeof($listvalue_product_str);$i++){
                $str .= 'cf_4643'.' = '.' "'.$listvalue_product_str[$i].'" ';
                if($i != sizeof($listvalue_product_str)-1){
                    $str .= ' or ';
                }
            } 
            $typesql_product = " and ($str)";
        }else{
            $typesql_product = " and 1=2";
        }
        
    }
    
    
    
    //接收用户选择的大巴车类型
    $listvalue_bus_str=$_REQUEST['listvalue_bus_str'];
    $typesql_bus = '';
    if($listvalue_bus_str != 'All'){
        $listvalue_bus_str_new=rtrim($listvalue_bus_str, ','); 
        if(!empty($listvalue_bus_str_new)&&$listvalue_bus_str_new != ""){
            $listvalue_bus_str = explode(',',$listvalue_bus_str_new);
            $str = "";
            for($i=0;$i<sizeof($listvalue_bus_str);$i++){
                $str .= 'cf_5108'.' = '.' "'.$listvalue_bus_str[$i].'" ';
                if($i != sizeof($listvalue_bus_str)-1){
                    $str .= ' or ';
                }
            } 
            $typesql_bus = " and ($str)";
        }else{
            $typesql_bus = " and 1=2";
        }
    }
    
    $r = 6371.393;
    $cirNS = $first_map_lat*pi()/180;
    $cirWE = $first_map_lng*pi()/180;
    
    //查询符合要求的下游客户信息
    $store_query = "round($r*ACOS(COS($cirNS)*COS(latitude*pi()/180)*COS($cirWE-longtitude*pi()/180)+SIN($cirNS)*SIN(latitude*pi()/180))*1000)";
    $page_list_query  = " and $store_query  < " . $distance;    
    $sql = "SELECT longtitude,latitude,location_address,accountname,$columnname_product,$columnname_bus,cf_4662,customform10_id,ld_customform10.form10_type from $tablename 
            inner join $tablenamescf on $tablename.$tablename_index=$tablenamescf.$tablenamescf_index  
            INNER JOIN ld_customform10 on $tablename.customform10_id = ld_customform10.customform10id
            where $tablename.deleted = 0 and ((ld_customform10.form10_type=? $typesql_product) or (ld_customform10.form10_type=? $typesql_bus) ) and (ifnull(longtitude,0)>0 and ifnull(latitude,0)>0 )  $page_list_query";
            
    $result = $adb->pquery($sql,array($type_id_product,$type_id_bus));
    $num_rows = $adb->num_rows($result);
    $point_arr=array();
    $product_count=0;
    $bus_count=0;
    $all_location = array();
    $all_accountinfo = array();
    $count = 0;
    for($i = 0;$i<$num_rows;$i++){
        $longtitude = $adb->query_result($result,$i,'longtitude');
        $latitude = $adb->query_result($result,$i,'latitude');
        $locationaddress = $adb->query_result($result,$i,'location_address');
        $accountname = $adb->query_result($result,$i,'accountname');
        $customform10_id = $adb->query_result($result,$i,'customform10_id');
        $product_type = $adb->query_result($result,$i,$columnname_product);
        $bus_type = $adb->query_result($result,$i,$columnname_bus);
        $bus_number = $adb->query_result($result,$i,'cf_4662');
        $form10_type = $adb->query_result($result,$i,'form10_type');
        if(($product_type !== '' && !empty($product_type))|| ($bus_type !== '' && !empty($bus_type)) ){
            if($form10_type == $type_id_product){
                $product_count+=1;
            };
            if($form10_type == $type_id_bus){
                $bus_count+=1;
            };
            
            $tmp_location = array('longtitude'=>$longtitude,'latitude'=>$latitude);
            $in_arr = false;
            foreach($all_location as $key =>$location){
                if($location['longtitude'] ==$longtitude && $location['latitude'] ==$latitude){
                    $index = $key;
                    $in_arr = true;
                    break;
                }else{
                    $in_arr = false;
                }
            }
            if(!$in_arr){
                $all_location[] = $tmp_location;
            }
            $info = array('longtitude'=>$longtitude,'latitude'=>$latitude,'locationaddress'=>$locationaddress,'accountname'=>$accountname,'type'=>$form10_type,'product_type'=>$product_type,'bus_type'=>$bus_type,'bus_number'=>$bus_number);
            $columnnamea_arr = array('accountname','type','product_type','bus_type','bus_number','locationaddress','latitude','longtitude');
            
            foreach($columnnamea_arr as $tmp_columnname){
                if($in_arr){
                    $tmp_accountinfo = $all_accountinfo[$index][$tmp_columnname];
                    $tmp_accountinfo[] = $info[$tmp_columnname];
                    $all_accountinfo[$index][$tmp_columnname] = $tmp_accountinfo;
                }else{
                    $tmp_accountinfo = array();
                    $tmp_accountinfo[] = $info[$tmp_columnname];
                    $tmp_key = sizeof($all_location)-1;
                    $all_accountinfo[$tmp_key][$tmp_columnname] = $tmp_accountinfo;
                }
            }
            

            $point_arr[] =$info;   
        }

    }
    //返回中心点的经纬度
    $arr['first_map_lat'] = $first_map_lat;
    $arr['first_map_lng'] = $first_map_lng;
    $arr['distance'] = $distance;
    $arr['address'] = $address;
    $arr['all_count'] = $num_rows;
    $arr['product_count'] = $product_count;
    $arr['bus_count'] = $bus_count;
    $arr['point_arr'] = ldcrm_json_encode($point_arr);
    $arr['all_accountinfo'] = ldcrm_json_encode($all_accountinfo);
    ConvertTojsonString(1,$arr,'success');       
}


    
//设置默认中心点
$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'dongmao' && $VersionInfo['trade'] == 'dongmao'){
    $address = "河北省廊坊市三河市东贸国际";    
}else if($VersionInfo['trade'] == 'yongdingcheng'){
    $address = "河北省廊坊市固安县永定城京津冀国际商贸城";    
}else{
    $address = "上海市浦东新区浦东大道2000号";
}
//设置默认距离
$distance = 100000;
//接收用户输入的距离
$addressinfo = getCoordinateByTecentApi($address);
$first_map_lat = $addressinfo['result']['location']['lat'];
$first_map_lng = $addressinfo['result']['location']['lng'];

$r = 6371.393;
$cirNS = $first_map_lat*pi()/180;
$cirWE = $first_map_lng*pi()/180;
//查询符合要求的下游客户信息
$store_query = "round($r*ACOS(COS($cirNS)*COS(latitude*pi()/180)*COS($cirWE-longtitude*pi()/180)+SIN($cirNS)*SIN(latitude*pi()/180))*1000)";
$page_list_query  = " and $store_query  < " . $distance;    

$sql = "SELECT longtitude,latitude,location_address,accountname,$columnname_product,$columnname_bus,cf_4662,customform10_id,ld_customform10.form10_type from $tablename 
            inner join $tablenamescf on $tablename.$tablename_index=$tablenamescf.$tablenamescf_index  
            INNER JOIN ld_customform10 on $tablename.customform10_id = ld_customform10.customform10id
            where $tablename.deleted = 0 and ((ld_customform10.form10_type=? ) or (ld_customform10.form10_type=? ) ) and (ifnull(longtitude,0)>0 and ifnull(latitude,0)>0 )  $page_list_query";

$result = $adb->pquery($sql,array($type_id_product,$type_id_bus));
$num_rows = $adb->num_rows($result);
$point_arr=array();
$product_count=0;
$bus_count=0;
$all_location = array();
$all_accountinfo = array();
$count = 0;
for($i = 0;$i<$num_rows;$i++){
    $longtitude = $adb->query_result($result,$i,'longtitude');
    $latitude = $adb->query_result($result,$i,'latitude');
    $locationaddress = $adb->query_result($result,$i,'location_address');
    $accountname = $adb->query_result($result,$i,'accountname');
    $customform10_id = $adb->query_result($result,$i,'customform10_id');
    $product_type = $adb->query_result($result,$i,$columnname_product);
    $bus_type = $adb->query_result($result,$i,$columnname_bus);
    $bus_number = $adb->query_result($result,$i,'cf_4662');
    $form10_type = $adb->query_result($result,$i,'form10_type');
    
    if(($product_type !== '' && !empty($product_type))|| ($bus_type !== '' && !empty($bus_type))){
        if($form10_type == $type_id_product){
            $product_count+=1;
        };
        if($form10_type == $type_id_bus ){
            $bus_count+=1;
        };
        
        $tmp_location = array('longtitude'=>$longtitude,'latitude'=>$latitude);
        $in_arr = false;
        foreach($all_location as $key =>$location){
            if($location['longtitude'] ==$longtitude && $location['latitude'] ==$latitude){
                $index = $key;
                $in_arr = true;
                break;
            }else{
                $in_arr = false;
            }
        }
        if(!$in_arr){
            $all_location[] = $tmp_location;
        }
        $info = array('longtitude'=>$longtitude,'latitude'=>$latitude,'locationaddress'=>$locationaddress,'accountname'=>$accountname,'type'=>$form10_type,'product_type'=>$product_type,'bus_type'=>$bus_type,'bus_number'=>$bus_number);
        $columnnamea_arr = array('accountname','type','product_type','bus_type','bus_number','locationaddress','latitude','longtitude');
        
        foreach($columnnamea_arr as $tmp_columnname){
            if($in_arr){
                $tmp_accountinfo = $all_accountinfo[$index][$tmp_columnname];
                $tmp_accountinfo[] = $info[$tmp_columnname];
                $all_accountinfo[$index][$tmp_columnname] = $tmp_accountinfo;
            }else{
                $tmp_accountinfo = array();
                $tmp_accountinfo[] = $info[$tmp_columnname];
                $tmp_key = sizeof($all_location)-1;
                $all_accountinfo[$tmp_key][$tmp_columnname] = $tmp_accountinfo;
            }
        }
        

        $point_arr[] =$info;   
    }
}

//返回中心点的经纬度
$arr['first_map_lat'] = $first_map_lat;
$arr['first_map_lng'] = $first_map_lng;
$arr['distance'] = $distance;
$arr['address'] = $address;
$arr['all_count'] = $num_rows;
$arr['product_count'] = $product_count;
$arr['bus_count'] = $bus_count;
$arr['point_arr'] = ldcrm_json_encode($point_arr);
$arr['all_accountinfo'] = ldcrm_json_encode($all_accountinfo);    
    




//获得所有的主营品类型返回给多选框
$fieldinfo_product = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname_product);
$fieldname_product = $fieldinfo_product->fieldName;
//$filedlabel_product = $fieldinfo_product->getFieldLabel();
$sql_product = "SELECT
    ld_picklist_values.*
FROM
    ld_picklist_set
INNER JOIN ld_picklist_values ON ld_picklist_set.listid = ld_picklist_values.listid
WHERE
    listname = ? ORDER BY sequence ;";
$result_product = $adb->pquery($sql_product,array($fieldname_product));
$num_rows_product = $adb->num_rows($result_product);
$product_listvalue_arr=array();
for($i = 0;$i<$num_rows_product;$i++){
    $listvalue_product = $adb->query_result($result_product,$i,'listvalue');
    $product_listvalue_arr[] = $listvalue_product;
}
$arr['product_listvalue_arr'] = $product_listvalue_arr;
$arr['product_listvalue_arr_forjs'] = ldcrm_json_encode($product_listvalue_arr);


//获得所有的大巴车类型返回给多选框
$fieldinfo_bus = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname_bus);
$fieldname_bus = $fieldinfo_bus->fieldName;
//$filedlabel_bus = $fieldname_bus->getFieldLabel();
$sql_bus = "SELECT
    ld_picklist_values.*
FROM
    ld_picklist_set
INNER JOIN ld_picklist_values ON ld_picklist_set.listid = ld_picklist_values.listid
WHERE
    listname = ? ORDER BY sequence ;";
$result_bus = $adb->pquery($sql_bus,array($fieldname_bus));
$num_rows_bus = $adb->num_rows($result_bus);
$bus_listvalue_arr=array();
for($i = 0;$i<$num_rows_bus;$i++){
    $listvalue_bus = $adb->query_result($result_bus,$i,'listvalue');
    $bus_listvalue_arr[] = $listvalue_bus;
}
$arr['bus_listvalue_arr'] = $bus_listvalue_arr;
$arr['bus_listvalue_arr_forjs'] = ldcrm_json_encode($bus_listvalue_arr);



$smarty = new lingdangCRM_Smarty();

//将主营品、大巴车类型的值返回给前端的多选框
$smarty->assign('product_listvalue_arr',$arr['product_listvalue_arr']);
$smarty->assign('bus_listvalue_arr',$arr['bus_listvalue_arr']);
$smarty->assign('product_listvalue_arr_forjs',$arr['product_listvalue_arr_forjs']);
$smarty->assign('bus_listvalue_arr_forjs',$arr['bus_listvalue_arr_forjs']);

//返回客户地址
$smarty->assign('point_arr',$arr['point_arr']);
$smarty->assign('all_accountinfo',$arr['all_accountinfo']);
//dump($all_accountinfo);

//返回中心点地址
$smarty->assign('distance',$arr['distance']);
$smarty->assign('first_map_lat',$arr['first_map_lat']);
$smarty->assign('first_map_lng',$arr['first_map_lng']);
$smarty->assign('address',$arr['address']);
$smarty->assign('all_count',$arr['all_count']);
$smarty->assign('product_count',$arr['product_count']);
$smarty->assign('bus_count',$arr['bus_count']);
$smarty->display("Accounts/map_distribution.tpl");
?>
