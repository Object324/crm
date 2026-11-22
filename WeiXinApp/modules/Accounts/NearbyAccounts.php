<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb,$MobileLanguageType;
$module = 'Accounts';
$jsonArray=array();
$listview_entries = array();
if($_REQUEST['getphone']=='yes')
{
    ConvertTojsonString(1,['list_phone'=>get_phone_list($_REQUEST['record'],$module)],'success');
}
//editor:gyq_82 reason:附件客户优化 2018/10/12 10:58
$mobj = cls_Instance::get_moduleAction_Instance($module,'ListView');
/**********AJAX事件:公海类型切换****begin********/
if(!empty($_REQUEST['switch_accounttype'])){
    $_REQUEST['pagepublicaccounttype'] = $_REQUEST['switch_accounttype'];
    $customview_html = $mobj->init_custom();
    $output = json_encode($customview_html);
    echo $output;exit;
}
/**********AJAX事件:公海类型切换****end********/
global $EARTH_RADIUS;
$r = 6371.393;
$EARTH_RADIUS=$r;
/**
 * 获取当前位置的周围最大最小经纬度
 * $distance：单位为：千米
 */
function returnSquarePoint($lng, $lat,$distance = 1){
        global $EARTH_RADIUS;
        $dlng =  2 * asin(sin($distance / (2 * $EARTH_RADIUS)) / cos(deg2rad($lat)));

        $dlng = rad2deg($dlng);

        $dlat = $distance/$EARTH_RADIUS;

        $dlat = rad2deg($dlat);

        return array(

            'left-top'=>array('lat'=>$lat + $dlat,'lng'=>$lng-$dlng),

            'right-top'=>array('lat'=>$lat + $dlat, 'lng'=>$lng + $dlng),

            'left-bottom'=>array('lat'=>$lat - $dlat, 'lng'=>$lng - $dlng),

            'right-bottom'=>array('lat'=>$lat - $dlat, 'lng'=>$lng + $dlng)

        );

}

/*
function getLocation($myLng,$myLat,$distance)
{
global $EARTH_RADIUS;
    //以下为核心代码
    $range = 180 / pi() * $distance /$EARTH_RADIUS;     //里面的 $distance 就代表搜索  $distance  km 之内，单位km
    $lngR = $range / cos($myLat * pi() / 180);
    $maxLat = $myLat + $range;//最大纬度
    $minLat = $myLat - $range;//最小纬度
    $maxLng = $myLng + $lngR;//最大经度
    $minLng = $myLng - $lngR;//最小经度
    //得出这四个值以后，就可以根据你数据库里存的经纬度信息查找记录了~

}*/
if(!isset($_REQUEST['showlistpage'])){
    $showlistpage='yes';//
}
else{
    $showlistpage=$_REQUEST['showlistpage'];//
}
if($showlistpage=='yes')
{
    if($_REQUEST['page']==0)
        $_REQUEST['page']=1;
    $list_max_entries_per_page_new=getUsersettingByLabel($module,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($module,1,'MaxEntriesPerPage');
    $list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;


}


if(!empty($_REQUEST['cuurlatitude']) && !empty($_REQUEST['cuurlongitude']) && !empty($_REQUEST['distance'])){
    /********获取当前用户设置距离********/
    $distanceVisible = $_REQUEST['distance'];
    $userid = $current_user->id;
    $sql_14 = 'select userid,deploy_value,is_open from ld_appsystem where userid= ? and deploy_type = ?';
    $result_14=$adb->pquery($sql_14,array($userid, 14));
    if($adb->num_rows($result_14)>0){
        $distanceVisible = $adb->query_result($result_14,0,'deploy_value');
        $distanceVisible = (int)$distanceVisible*1000;
    }
    else{
        $distanceVisible = 5000;
    }
    // dump($distanceVisible);
/**********Step01********** 生成携带where条件的page_list_query*****begin********************/
    if(!isset($_REQUEST['filter']['SearchScope'])){
        $_REQUEST['filter']['SearchScope']= 'SmOwner_Search_All';
    }
    $page_list_query = $mobj->get_page_query('','yes');
/******************** 生成携带where条件的page_list_query*****end********************/

    /*由于系统保存为百度地图api对应的经纬度，与腾讯地图api稍有误差，这里将误差尽量消除。 xxs 20180323
    阳光世界大厦的经纬度
    121.55512432945  31.253803667615 百度地图   .
    121.54901        31.24753        腾讯地图 .
    $littlelong = 0.00611432945;//经度误差
    $littlelati = 0.006273667615;//纬度误差
    S=R·arc cos[cosβ1cosβ2cos（α1-α2）+sinβ1sinβ2] 球面距离公式
    $store_query = "round(6378.138*2*asin(sqrt(pow(sin(($cuurlatitude*pi()/180-latitude*pi()/180)/2),2)+cos($cuurlatitude*pi()/180)*cos(latitude*pi()/180)*pow(sin(($cuurlongitude*pi()/180-longtitude*pi()/180)/2),2)))*1000)";*/
	$cuurlongitude = $_REQUEST['cuurlongitude'];//+$littlelong;
	$cuurlatitude = $_REQUEST['cuurlatitude'];//+$littlelati;

    $cirWE = $cuurlongitude*pi()/180;
    $cirNS = $cuurlatitude*pi()/180;
    $store_query = "round($r*ACOS(COS($cirNS)*COS(ld_account.latitude*pi()/180)*COS($cirWE-ld_account.longtitude*pi()/180)+SIN($cirNS)*SIN(ld_account.latitude*pi()/180))*1000)";
    $order_by = " order by distance asc";

/*********Step02*********** page_list_query增加球面两点距离条件*****begin********************/
    $page_list_query =str_replace('FROM
            		ld_account',','.$store_query.' as distance FROM ld_account ',$page_list_query);
    //editor:gyq_20190920 reason:从SQL中剔除publicaccount条件
    //0038136: 移动端，附近客户有数据时，搜索不到客户
    $page_list_query =str_replace('ld_account.publicaccount = 0','1=1',$page_list_query);
    $page_list_query =str_replace('ld_account.publicaccount=0','1=1',$page_list_query);
   $arrinfo= returnSquarePoint($cuurlongitude,$cuurlatitude,$distanceVisible/1000);
    $lefttoplng=$arrinfo['left-top']['lng'];
    $lefttoplat=$arrinfo['left-top']['lat'];
    $leftbottomlng=$arrinfo['left-bottom']['lng'];
    $leftbottomlat=$arrinfo['left-bottom']['lat'];
    $righttoplng=$arrinfo['right-top']['lng'];
    $righttoplat=$arrinfo['right-top']['lat'];
    $rightbottomlng=$arrinfo['right-bottom']['lng'];
    $rightbottomlat=$arrinfo['right-bottom']['lat'];

    $page_list_query  .= " and ld_account.latitude between    $leftbottomlat  and $righttoplat     
      and   ld_account.longtitude between    $leftbottomlng  and $righttoplng    and   $store_query  < " . $distanceVisible;
    if($showlistpage=='yes')
    {
        $num_rows=$adb->num_rows($adb->pquery($page_list_query));
        $page_list_query.=$order_by." limit ".($_REQUEST['page']-1)*$list_max_entries_per_page_new.','.$list_max_entries_per_page_new;
        $pagecount=$num_rows/$list_max_entries_per_page_new;
        if( $num_rows%$list_max_entries_per_page_new!=0)
        {
            $pagecount+=1;

        }
        $jsonArray['pagecount']=$pagecount;
        $jsonArray['numrows']=$num_rows;
    }
    else
            $page_list_query  .= $order_by;
/******************** page_list_query增加球面两点距离条件*****end********************/
    $list_query = "select distinct ld_account.accountid,ifnull(ld_account.rating,''),ld_account.accountname,ld_account.location_address,ld_account.longtitude,ld_account.latitude,ld_account.publicaccount,ld_account.pool_id,$store_query as distance";
    $list_query .= $mobj->obj_query->getFromClause();
    $list_query = $list_query . '  inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' .
        $mobj->focus->table_index . '=' . $mobj->focus->table_name . '.' . $mobj->focus->table_index;
    $list_query .= $order_by;
   // dump($list_query);
	$list_result = $adb->pquery($list_query, array());
    // echo $list_result->sql;die;
	$num_rows = $adb->num_rows($list_result);
    //duan 20230920 附近客户列表需要动态读取字段信息
   // file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Accounts/bb.txt",$list_query);
    if($showlistpage=='yes')
    {


        $list_map_account = $mobj->getNearbyAccountList($page_list_query);
    }

    $map_account_info = ['hiddentitle','newfield','title','title_color'];
    // dump($num_rows);
	for($i = 0; $i<$num_rows; $i++){
		$accountid = $adb->query_result($list_result,$i,'accountid');
		$accountname = $adb->query_result($list_result,$i,'accountname');
		$address = $adb->query_result($list_result,$i,'location_address');
		$distance = $adb->query_result($list_result,$i,'distance');
        $longtitude = $adb->query_result($list_result,$i,'longtitude');
        $latitude = $adb->query_result($list_result,$i,'latitude');
        $rating = $adb->query_result($list_result,$i,'rating');
        $publicaccount = $adb->query_result($list_result,$i,'publicaccount');
        $pool_id = $adb->query_result($list_result,$i,'pool_id');
        $receivepermit = 'no';
        if($pool_id >0 && $publicaccount ==1){
            $receivepermit = 'yes';
        }
        if($showlistpage=='yes')
            $viewdetail = isPermitted('Accounts', 'DetailView', $accountid);
		$listview_entries[$i] = array(
			'accountid' => $accountid,
			'accountname' => $accountname,
			'address' => $address,
			'distance' => $distance,
            'longtitude' => $longtitude,
            'latitude' => $latitude,
            'viewdetail' => $viewdetail,
            'rating' => $rating,
            /**********打电话_获取电话列表************/
			'list_phone' =>[123], //为了给前端使用，前端需要点击获取电话(为了能点击)，现在获取电话号码，是在点击marker 获取// get_phone_list($accountid,$module),
            'receivepermit'=>$receivepermit
		);
        if($showlistpage=='yes')
            foreach ($map_account_info as $tmp_value) {
                $listview_entries[$i][$tmp_value] = $list_map_account[$accountid][$tmp_value];
            }
	}
}
/***********增加筛选内容***begin*********/

$mobj->setreturnJson_listContent();
    $jsonArray['list']=$mobj->jsonArr['list'];


    $jsonArray['list1']=$listview_entries;//查询数据内容


// dump($listview_entries);
/***********增加筛选内容***end*********/

//$jsonArray['list_map_account']=$list_map_account;
//editor:gyq_20190428  reason:只判断了新增权限却没有判断模块是否激活0036973: 企业微信>灵当CRM>附近客户>点击客户名称：当跟进记录模块被关闭时，跟进功能应该不显示出来。
if(vtlib_isModuleActive('ContactRecords')){
    $relatecreate = isPermitted('ContactRecords','Create');
}else{
    $relatecreate = 'no';
}
$jsonArray['relatecreate'] = $relatecreate;
$jsonArray['receivepermit'] = 'no';
$jsonArray['publicnum'] = $publicnum;
$jsonArray['mapphone']="no";//主要是版本控制，客户前端升级，后台没有升级，以前版本没有这个参数
$jsonArray['page_title'] = getFixedLabel('NearbyAccounts');
//if(cls_StaticCommonFun::isPublicAccountUser()&&getAccount_Set('getprofile')==1){
    $jsonArray['receivepermit'] = 'yes';
//}
//duan 移动端增加字符串翻译返回
$label_arr=array(
    'list',//列表
    'SEARCHNEW',//搜索
    'PLEASEENTERTHEADDRESS',//请输入地址
    'FINDTHEFOLLOWINGADDRESS',//查找以下地址
    'UNABLETOOBTAINLONGITUDE',//无法获取经纬度，请输入更详细的地址
    'DISTANCE',//距离
    'GOHERE',//到这去
    'metre',//米
    'SINGINADDRESS',//签到地址
    'CALL2',//打电话
    'SEARCHLOCATION',//搜索地点
    'RECORDSINTOTAL',//共%d条记录
);
$fixedlabel_arr = TransFieldlabel($label_arr);
$fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);

$focus = CRMEntity::getInstance('Accounts');
$fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname','accountname');
if($fieldinfo){
    $fieldlabel = $fieldinfo->getFieldLabelKey();
}else{
    $fieldlabel = '';
}
$fixedlabel_arr['SEARCHLOCATION'] = getFixedLabel('SEARCHNEW').$fieldlabel;

$jsonArray['arrFixedLabel']=$fixedlabel_arr;

ConvertTojsonString(1,$jsonArray,'');

/**********打电话_获取电话列表************/
function get_phone_list($record,$module){
    global $adb;
    $arr_phone = array();
    $focus = cls_Instance::get_module_Instance($module);
    if (!empty($record)) {
        $focus->retrieve_entity_info($record, $module);
        $focus->id = $record;
    }
    crm_load_class_file('Detail_Edit_View','include/utils');
    Detail_Edit_View::getAccountPrimaryContactInfo($focus);//gyq_26 关系信息新增
    $tabid = getTabid($module);
    $fieldobj = Field::getInstance($module, $adb);
    $moduleFields = $fieldobj->getModuleFields();
    foreach ($moduleFields as $fieldname => $fieldinfo) {
        $generatedtype = $fieldinfo->getGeneratedtype();
        $uitype =$fieldinfo->getUIType();
        if ($uitype == 11||$uitype==1101) {
            crm_load_class_file("cls_DetailViewOutPutWX", 'WeiXinApp/detail');
            $detailView_htmlobj = new cls_DetailViewOutPutWX();
            $detailView_htmlobj->record = $focus->record;
            $custfld = $detailView_htmlobj->getDetailViewOutputHtml($fieldinfo, $focus->column_fields, $generatedtype, $tabid, $module);
            if(!empty($custfld['phonetext'])){
                $arr_phone[] = $custfld['phonetext'];
            }
        }
    }
    $arr_phone = array_unique($arr_phone);
    if(empty($arr_phone)) $arr_phone = '';
    return $arr_phone;
}
?>
