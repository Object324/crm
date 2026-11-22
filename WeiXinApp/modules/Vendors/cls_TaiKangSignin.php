<?php
/**
 * edit:duan
 * reason:泰康制药签到功能特殊开发
 * date:20221109
**/
class cls_TaiKangSignin
{
    public $taikangNoDistanceData;
    public $distancelimit;
    public $orderby;
    public $orderexist;

    public function __construct()
    {
        //定义不需要控制的打卡类型
        $this->taikangNoDistanceData = array('在途/吃饭打卡','请假','会议签到','团建活动','调休');
        $this->distancelimit = 10000; //最大范围1000米
        $this->orderby = '';
        $this->orderexist = 0;
    }
    //打卡时不需要控制签到误差的类型
    public function GettaikangNoDistanceData(){
        return $this->taikangNoDistanceData;
    }
    //判断是否为泰康的账套
    public function JudgeVersion(){
        $VersionInfo = getVersionInfo();
        $account = $VersionInfo['account'];
        if($account == 'taikang'){
            return 'yes';    
        }else{
            return 'no';
        }
    }
    //泰康特殊开发，移动端签到打卡（跟进记录）选择终端用户（供应商）时，需要限制距离不超过一千米
    public function getDistanceLimitSql($page_list_query){
        //duan 20221118 因为工商定位和实际位置差距较大，暂时停用
        //return $page_list_query;
        
        $wheresql = '';
        //$_REQUEST['longtitude'] = '121.548359';
        //$_REQUEST['latitude'] = '31.247668';
        if($_REQUEST['selectmodule']=='Vendors'&&$_REQUEST['frommodule']=='ContactRecords'){
            //从前端获取当前定位的经纬度
            if($_REQUEST['longtitude'] != '' && $_REQUEST['latitude'] != ''){
                $distance = $this->distancelimit+500; //暂定1000米
                $focus = CRMEntity::getInstance($_REQUEST['selectmodule']);
                $tablename = $focus->table_name;
                $log_columnname = $tablename.'.longtitude';
                $lat_columnname = $tablename.'.latitude';
                $r = 6371.393;
                $cirNS = $_REQUEST['latitude']*pi()/180;
                $cirWE = $_REQUEST['longtitude']*pi()/180;
                //查询符合要求的下游客户信息
                $store_query = "round($r*ACOS(COS($cirNS)*COS($lat_columnname*pi()/180)*COS($cirWE-$log_columnname*pi()/180)+SIN($cirNS)*SIN($lat_columnname*pi()/180))*1000)";
                //$wheresql .= " and ifnull($lat_columnname,'')!='' and ifnull($log_columnname,'')!='' and  $store_query  < " . $distance; 
                //$wheresql .= " and ifnull($lat_columnname,'')!='' and ifnull($log_columnname,'')!='' "; 
                
                $wheresql .= " order by if(tmp_distance_1>500,tmp_distance_1-500,tmp_distance_1) asc,ld_vendor.vendorid DESC ";
                $this->orderexist = 1;
                $this->distancefieldsql = ",if(tmp_distance_1>500,tmp_distance_1-500,tmp_distance_1) as tmp_distance " ;
                //$page_list_query = str_replace('ld_vendor.vendorid',"ld_vendor.vendorid,($store_query) as tmp_distance ",$page_list_query);
                $page_list_query_arr = explode('FROM',$page_list_query);
                $page_list_query_arr[0] .=  ",ifnull( $store_query,12756000) as tmp_distance_1 ";
                $page_list_query = implode('FROM',$page_list_query_arr);
                
                $this->orderby = " tmp_distance asc ";
                $page_list_query.= $wheresql;
            }
        }
        return $page_list_query;
    }
    
    //列表界面显示当前位置到终端用户（供应商）的距离
    public function getDistanceValueSql($list_query){
        $list_query_arr = explode('FROM',$list_query);
        $list_query_arr[0] .=  $this->distancefieldsql;
        $list_query_new = implode('FROM',$list_query_arr);
        return $list_query_new;
    }
    
    //列表界面按照当前位置到终端用户（供应商）的距离排序
    public function getDistanceOrderbySql($orderby){
        if(!empty($this->orderby)){
            if(!empty($orderby)){
                $orderby_new = $this->orderby.','.$orderby;
            }else{
                $orderby_new = $this->orderby;
            }
        }else{
            $orderby_new = $orderby;
        }
        return $orderby_new;
    }
    
    //判断签到打卡时，所在的区域，是否在日程管理规定的拉练区域内
    public function TrainingAreaRange(){
        if($this->JudgeVersion() != 'yes'){
            return '';
        }
        //判断请求中是否包含签到的经纬度
        $signData = $_REQUEST['signData'];
        if(empty($signData['latitude']) || empty($signData['longitude'])){
            return '';
        }
        //根据前端获取的经纬度获取到市级地址和区域地址
        $latitude = $signData['latitude'];
        $longitude = $signData['longitude'];
        crm_load_class_file("cls_Tencent_Map",'include\utils');
        $TencentMapobj = new cls_Tencent_Map();
        $addressinfo = $TencentMapobj->getAddressForPoint($longitude,$latitude);
        $detail_addressobj = $addressinfo['address_info'];
        $city = $detail_addressobj->city; //市级名称
        $area = $detail_addressobj->district; //区级名称
        //日程管理字段对应关系:date_start:开始时间,due_date:结束时间,cf_5633:拉练地市（市级）,cf_5634:拉练区域（区级）,assigned_user_id:负责人
        //定义需要判断的字段名称，方便测试
        $assigned_user_id = $_REQUEST['assigned_user_id'];
        $user_columnname = 'smownerid'; //负责人
        $start_columnname = 'date_start'; //开始时间
        $end_columnname = 'due_date'; //结束时间
        $city_columnname = 'cf_5633'; //拉练地市（市级）
        $area_columnname = 'cf_5634'; //拉练区域（区级）
        //测试用
        //$city_columnname = 'cf_5244';
        //$area_columnname = 'cf_5245';
        //判断签到位置是否属于日程管理规定拉练区域范围
        $area_module = 'Calendar';
        $area_focus = CRMEntity::getInstance($area_module);
        $tablename = $area_focus->table_name;
        $scftablename = $area_focus->customFieldTable[0];
        $tableindex = $area_focus->table_index;
        //如果当前负责人在当前的日期有拉练计划，则控制签到地址要在拉练区域内
        global $adb;
        
        
        $query = "
            SELECT $city_columnname,$area_columnname FROM $tablename
            INNER JOIN $scftablename on $scftablename.$tableindex = $tablename.$tableindex
            WHERE $user_columnname = $assigned_user_id and deleted = 0 and IFNULL(eventstatus,'') <> '已执行'
            AND  NOW() BETWEEN $start_columnname and $end_columnname;";
        $result = $adb->pquery($query);
        //如果用户在当前时间段内存在拉练计划，则进一步判断拉练区域限制
        if($adb->num_rows($result)>0){
            $query_address = "
                SELECT $city_columnname,$area_columnname FROM $tablename
                INNER JOIN $scftablename on $scftablename.$tableindex = $tablename.$tableindex
                WHERE $user_columnname = $assigned_user_id and deleted = 0 and IFNULL(eventstatus,'') <> '已执行'
                AND NOW() BETWEEN $start_columnname and $end_columnname 
                AND (IFNULL($city_columnname, '') = '' or LOCATE($city_columnname,'$city') > 0 )
                AND (IFNULL($area_columnname, '') = '' or LOCATE($area_columnname,'$area') > 0 )
                ;";
            $result_address = $adb->pquery($query_address);
            if($adb->num_rows($result_address)<=0){
                $msg = '您签到的位置和拉练计划不一致，请找省区经理或运营申请修改拉练计划';
                ConvertTojsonString(-1,array(),$msg);
            }
        }
    }
}

