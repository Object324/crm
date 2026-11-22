<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class  cls_ListViewSpecialWX extends cls_ListViewWX{
    protected $SearchScopeModule = 'OftenUseReport';
    protected $fromcaluse_sql = '';

    public function __construct($module)
    {
        $this->module = $module;
    }

    public function get_listdetail($showtype = '',$generatorName='')
    {
        global $current_user,$adb;
        $this->setFilterRequest();//获取查询参数
        if (empty($_REQUEST['SearchScope'])) {
            $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
        }
        //$this->setreturnJson_listContent(); //初始化jsonArr中值
        $SQL = $this->getQuery();
        //wyt_XUQIU1000442_220720_增加“写跟进”操作按钮
        $SQL_relatedid = 'select relation_id from ld_relatedlists where tabid=? and related_tabid=?';
        $SQL_relatedtab = 'select GROUP_CONCAT(a.name) relatedtab from ld_tab a 
left join ld_relatedlists b on a.tabid=b.tabid 
where b.`name`="get_ContactRecords"';

        $related_tabres=$adb->pquery($SQL_relatedtab,array());
        $related_tabname=explode(',',$adb->query_result($related_tabres,0,0));
        $related_tabid = getTabid('ContactRecords');
        $module = 'ContactRecords';
        $count_result = $adb->pquery($SQL,array());
        if (!empty($count_result))
            $noofrows = $adb->num_rows($count_result);
        else
            $noofrows = null;
        $list_result = $this->page($noofrows, $SQL, $adb);
        $num_rows = $adb->num_rows($list_result);
        $detail_value = array();
        for ($i = 0; $i < $num_rows; $i++) {
            //editor:gyq_81 reason:签到考勤优化 2018/9/26 11:45
            $singal_record=$adb->query_result($list_result,$i,'record');
            $singal_modulename=$adb->query_result($list_result,$i,'modulename');
            $singal_accountid=$adb->query_result($list_result,$i,'accountid');
            $wx_userid=$adb->query_result($list_result,$i,'wx_userid');
            $last_name=$adb->query_result($list_result,$i,'last_name');//签到人员

            $related_res = $adb->pquery($SQL_relatedid,array(getTabid($singal_modulename),$related_tabid));
            $related_id = $adb->query_result($related_res,0,0);
            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$last_name;
            $last_name=getUserlastName($userobj);
            
            $id=$adb->query_result($list_result,$i,'id');
            //$relatedimage = $this->getAttachments($id);
            $signid = $adb->query_result($list_result,$i,'signid');
            $relatedimage = $this->getNewAttachments($signid);
            
            $address=$adb->query_result($list_result,$i,'address');//地址
            $createdtime=$adb->query_result($list_result,$i,'createdtime');//签到时间
            $createdtimeMulti = $last_name.' | '.$createdtime;
            $distince = $adb->query_result($list_result,$i,'distince');//距离
            $content = $adb->query_result($list_result,$i,'content');//备注
            $userid = $adb->query_result($list_result,$i,'userid');
            if($distince==getFixedLabel('INCALCULABLE')){
                if($singal_modulename=="Leads"){
                    //销售线索，显示【销售线索地址】，其他显示【客户地址】
                    $distince = sprintf(getFixedLabel('UNABLETOCALCULATE'),getTranstab($singal_modulename));
                    //$distince='无法计算，请查看【'.getTranstab($singal_modulename).'地址】是否准确录入';
                }else{
                    $distince = sprintf(getFixedLabel('UNABLETOCALCULATE'),getTranstab('Accounts'));
                    //$distince='无法计算，请查看【客户地址】是否准确录入';
                }
            }
            $address = getFixedLabel('SIGNIN').'：'.$address;
            $distince=getFixedLabel('ERRORMETRA').$distince;
            $a_arr = array();
            $b_arr = array();
            if($singal_record > 0) {
                $list_link_field = getModuleHref($singal_modulename,$singal_record);
                $a_arr = getTranstab($singal_modulename).':'.$list_link_field;
                $b_arr[] = $address;
            }else{
                $a_arr = $address;
            }
            $frommodule=$singal_modulename;
            $fromid=$singal_record;
            //BUG0054323 wyt 220802 (企业微信移动端)拜访签到中,新建签到内容时,选择拜访对象类型为跟进记录后,进入历史无法填写跟进.其他拜访对象类型没有此问题.(钉钉上也有此问题)
            $btnList = array();
            if(isPermitted($module,'Create') == 'yes'){
               if(in_array($frommodule,$related_tabname)){
                   $btnList[] = array('frommodule'=>$frommodule,'fromid'=>$fromid,'relatedid'=>$related_id,'module'=>$module,'btnname'=>getFixedLabel('WRITEFOLLOWUP'));
               }
            }
            //市场活动、产品管理，不显示误差
            if($singal_modulename!='Campaigns'&&$singal_modulename!="Products"){
                $b_arr[] = $distince;
            }

            $c_arr = array($createdtime,$last_name);
            if(!empty($content)) $b_arr[] = getFixedLabel('REMARK').'：'.$content;
            $showdel = $userid==$current_user->id?'yes':'no';
            $detail_value[$i]=array('A'=>$a_arr,'B'=>$b_arr,'C'=>$c_arr,'D'=>$relatedimage,'id'=>$id,'del'=>$showdel,'btnList'=>$btnList);
        }
        $this->jsonArr['list1'] = $detail_value;
        $this->jsonArr['search_reminds'] = getFixedLabel('SEARCHFORVISITORS');
        $this->jsonArr['modulename'] = getFixedLabel('Singin');
        return $this->jsonArr;
    }
    //editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/3 16:35
    public function page($noofrows, $list_query, $adb)
    {
        global $mobile_pagerecordcount;
        $endpagenum = $mobile_pagerecordcount;
        $endpagerecord = $mobile_pagerecordcount;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';
        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $_REQUEST['page'] = 1;
        } else {
            $_REQUEST['page']++;
        }

        $startpagenum = $_REQUEST['page'] - 1;
        if ($_REQUEST['page'] >= $totalpagecount)//是否有下一页
        {
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($_REQUEST['page'] <= 1)//是否有上一页
        {
            $haveprevpage = 'no';
            $startpagenum = 0;
        }

        $_REQUEST['start'] = $startpagenum + 1;
        $startpagerecord = $startpagenum * $mobile_pagerecordcount;

        $list_result = $adb->pquery($list_query . " LIMIT $startpagerecord, $mobile_pagerecordcount", array());

        $this->jsonArr['pagecount'] = $totalpagecount;
        $this->jsonArr['totalrows'] = $noofrows;
        $this->jsonArr['havenextpage'] = $havenextpage;
        $this->jsonArr['haveprevpage'] = $haveprevpage;
        $this->jsonArr['curpagenum'] = $startpagenum + 1;
        return $list_result;
    }

    //获取签到考勤关联图片
    protected function getAttachments($id){
        $T1 = array('从相册选择'=>'album','手机拍照'=>'camera');
        global $adb;
        $SQL='SELECT path,filename,imagefromtype,storage_location,cloud_path FROM ld_attachmentsforsign WHERE signid=?';
        $count_result = $adb->pquery($SQL,array($id));
        $num_rows = $adb->num_rows($count_result);
        $detail_value = array();
        $albumNum = 0;
        $cameraNum = 0;
        $detail_value['album']['image'] = array();
        $detail_value['album']['count'] = 0;
        $detail_value['camera']['image'] = array();
        $detail_value['camera']['count'] = 0;
        for ($i = 0; $i < $num_rows; $i++) {
            $path = $adb->query_result($count_result, $i, 'path');
            $name = $adb->query_result($count_result, $i, 'filename');
            $uploadtype = $adb->query_result($count_result, $i, 'imagefromtype');
            $storage_location=$adb->query_result($count_result, $i, 'storage_location');
            $cloud_path=$adb->query_result($count_result, $i, 'cloud_path');
            if($uploadtype == '从相册选择'){
                if($storage_location=='cos')
                {
                    $detail_value['album']['image'][$albumNum] = $cloud_path;
                }
                else
                    $detail_value['album']['image'][$albumNum] = $path.$name;
                $detail_value['album']['storage_location']=$storage_location;
                $albumNum++;
                $detail_value['album']['count'] = $albumNum;
              //  $detail_value['album']['storage_location']=$storage_location;
                //$detail_value['album']['cloud_path']=$cloud_path;
            }else{
                $detail_value['camera']['image'][$cameraNum] = $path.$name;
                
                 if($storage_location=='cos')
                {
                    $detail_value['camera']['image'][$cameraNum] = $cloud_path;
                }
                else
                    $detail_value['camera']['image'][$cameraNum] = $path.$name;
                $detail_value['camera']['storage_location']=$storage_location;
                
                $cameraNum++;
                $detail_value['camera']['count'] = $cameraNum;
                //$detail_value['camera']['storage_location']=$adb->query_result($count_result, $i, 'storage_location');
                //$detail_value['camera']['cloud_path']=$adb->query_result($count_result, $i, 'cloud_path');
            }
        }
        return $detail_value;
    }
    //获取签到考勤关联图片
    protected function getNewAttachments($id){
        crm_load_class_file('cls_MyCRMcrypt',"Register");
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $filejsondata = getAllFile_imageInfo($id,'Singin');
        $columnname = 'imagename';
        $imagefiledata = $filejsondata[$columnname];
        $albumNum = 0;
        $cameraNum = 0;
        foreach($imagefiledata as $tmp_filedata){
            $path = $tmp_filedata['file_path'];
            $name = $tmp_filedata['newfile_name'];
            $uploadtype = $tmp_filedata['imagefromtype'];
            $storage_location = $tmp_filedata['storage_location'];
            $cloud_path = $tmp_filedata['cloud_path'];
            
            //edit: xll 2023/03/23 XUQIU1001183 下载优化：newfile_name、path、cloud_path解密
            $isEncrypt = $tmp_filedata['isEncrypt'];
            $path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($path) : $path;
            $cloud_path = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($cloud_path) : $cloud_path;
            $name = ($isEncrypt == 'yes') ? $cls_MyCRMcrypt -> decode($name) : $name;
            
            if($uploadtype == 'Computer'){
                if($storage_location=='cos')
                {
                    $detail_value['album']['image'][$albumNum] = $cloud_path;
                }
                else
                    $detail_value['album']['image'][$albumNum] = $path.$name;
                $detail_value['album']['storage_location']=$storage_location;
                $albumNum++;
                $detail_value['album']['count'] = $albumNum;
              //  $detail_value['album']['storage_location']=$storage_location;
                //$detail_value['album']['cloud_path']=$cloud_path;
            }else{
                $detail_value['camera']['image'][$cameraNum] = $path.$name;
                
                 if($storage_location=='cos')
                {
                    $detail_value['camera']['image'][$cameraNum] = $cloud_path;
                }
                else
                    $detail_value['camera']['image'][$cameraNum] = $path.$name;
                $detail_value['camera']['storage_location']=$storage_location;
                
                $cameraNum++;
                $detail_value['camera']['count'] = $cameraNum;
                //$detail_value['camera']['storage_location']=$adb->query_result($count_result, $i, 'storage_location');
                //$detail_value['camera']['cloud_path']=$adb->query_result($count_result, $i, 'cloud_path');
            }
        }
        
        return $detail_value;
    }
    
    public function get_AccountsSignNum($accountid){
        global $adb,$current_user;
        $module_users = getCurSmOwnerSearchScope('OftenUseReport');
        $module_users['UserCombo'][$current_user->id] = array();
        $selectuid = implode(',', array_keys($module_users['UserCombo']));
        $sql = "select ld_singin.id from ld_singin where accountid=$accountid and userid in($selectuid) order by createdtime desc";
        $result = $adb->pquery($sql,array());
        $rowcount = $adb->num_rows($result);                
        $record = $adb->query_result($result,0,0);
                
        return array('relcount'=>$rowcount,'record'=>$record);
    }
    
    public function getRecordContentJson($record){
        global $adb;
        $sql='select ld_singin.content,ld_singin.address,ld_singin.createdtime,ld_singin.distince,
        ld_users.last_name,ld_account.accountname from ld_singin left  join ld_account
        on ld_account.accountid=ld_singin.accountid LEFT JOIN ld_users on ld_singin.userid=ld_users.id
        where ld_singin.id=?';
        $result = $adb->pquery($sql,array($record));
        $last_name=$adb->query_result($result,0,'last_name');//签到人员
        $address=$adb->query_result($result,0,'address');//地址
        $createdtime=$adb->query_result($result,0,'createdtime');//签到时间
        $distince = $adb->query_result($result,$i,'distince');//距离
        if($distince=='无法计算'){
            $distince='无法计算，请查看【客户地址】是否准确录入';
        }
        $address = '签到：'.$address;
        $distince='误差(米)：'.$distince;
        
        $content = array('title'=>$address,'field'=>array($distince,$createdtime));
        return $content;
    }
    protected function getQuery(){
        $sql='select ld_singin.id,ld_singin.signid,ld_singin.content,ld_singin.address,ld_singin.createdtime,ld_singin.distince,
        ld_users.last_name,ld_users.wx_userid,ld_singin.userid,ld_tab.name modulename,ld_singin.record,
        ld_singin.accountid from ld_singin  LEFT JOIN ld_users on ld_singin.userid=ld_users.id 
         left join ld_tab on ld_tab.tabid=ld_singin.tabid '
        .$this->getWhereClause().' order by ld_singin.createdtime desc';
        //echo $sql;exit;
        return $sql;
    }



    protected function getWhereClause(){
        global $current_user,$adb;
        $module_users = getCurSmOwnerSearchScope('OftenUseReport');
        $module_users['UserCombo'][$current_user->id] = array();
        $selectuid = implode(',', array_keys($module_users['UserCombo']));
        
        $whereFinal = '';
        $searchcontent = $_REQUEST['searchcontent'];
        if(!empty($searchcontent)){
            $where  = $this->getSearchColumn($searchcontent);
            $whereArr[] = $where;
        }
        $whereFinal .= $this->fromcaluse_sql.' ';
        //相关信息签到
        if(isset($_REQUEST['related_module'])&&!empty($_REQUEST['recordid'])){
            $whereArr[] = ' ld_singin.source_list='.$_REQUEST['recordid'];
        }
        //editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/30 15:39 
        if(isset($_REQUEST['session_search_criteria'])){
            $advft_criteria = json_decode($_REQUEST['session_search_criteria'],true)['advft_criteria'];
            $advft_criteria = json_decode($advft_criteria,true);
            $module = 'Singin';
            $focus = CRMEntity::getInstance($module);
            $selectuid = '';

            foreach ($advft_criteria as $key=>$content){
                $columnname_arr = explode(':',$content['columnname']);
                $columnname = $columnname_arr[1];
                $tabname = $columnname_arr[0];
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                $bigtype = $fieldinfo->getBigType();
                $typeofdata = $fieldinfo->getTypeOfData();
                $typeofdata_arr = explode('~',$typeofdata);
                if (in_array($bigtype,array('users','selectoneuser'))){
                   if (isKehu001ServerPc() == 'yes'){
                       $whereArr[] = ' ld_users.real_name = \''.$content['value'].'\' ';
                   }else{
                       $whereArr[] = ' ld_users.last_name = \''.$content['value'].'\' ';
                   }
                }else if (in_array($typeofdata_arr[0],array('D','DT'))){
                    $createdtime_range_arr = explode(',',$content['value']);
                    $whereArr[] = ' '.$tabname.'.'.$columnname.' between \''.$createdtime_range_arr[0].'\' and \''.$createdtime_range_arr[1].'\' ';
                }
            }
        }
        if(!empty($selectuid)){
            $whereArr[] = ' userid in('.$selectuid.')';
        }
        if(!empty($whereArr)){
            $whereFinal .= 'where '.implode(' and ',$whereArr);
        }
        
        return $whereFinal;
    }
    protected function getSearchColumn($searchcontent){
        //editor:gyq_20181018
//        $module_list = $this->get_option_modules();
        // @edit:dong @date:2020/08/14 @reason: 使用公共方法
        require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
        $module_list = cls_StaticCommonFun::getOptionModule('Singin');

        $column_href_list = array();
        $fromsql = '';
        foreach ($module_list as $key=>$value){
            //获取单据超链接字段信息
            $entityarray = getEntitynameInfo(getTabid($value['value']));
            $module_list[$key]['entityfield'] = $entityarray;
            $column_href_list[$key] = $entityarray['tablename'].'.'.$entityarray['fieldname'];
            $fromsql .= ' left join '.$entityarray['tablename'].' on '.$entityarray['tablename'].'.'.$entityarray['entityidfield'].'=ld_singin.record and ld_singin.tabid='.$entityarray['tabid'] ;
        }
        $this->fromcaluse_sql = $fromsql;
        $columns = array('ld_singin.content','ld_singin.address','ld_singin.distince',
                        'ld_users.last_name');
        $columns = array_merge($columns,$column_href_list);
        $iskehu001=isKehu001ServerPc();
      //  dump($columns);
        foreach($columns as $val){
            if($val=='ld_users.last_name'&&$iskehu001=='yes'){
                  crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
                  $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
                  $wx_userarr =$port_obj->getwxUserid('like',$searchcontent);
                   if(array_key_exists('userid',$wx_userarr))
                   {
                            $wx_userid=implode("','",$wx_userarr['userid']);
                            $wx_userid="'".$wx_userid."'";
                            
                            $sqlarr[]=' ld_users.wx_userid in( '.$wx_userid.')';
                   }
                   else{
                            $sqlarr[] = "ld_users.id<=0";
                           // break;
                   }
                         
            }
            else
            $sqlarr[] = $val." like '%$searchcontent%' ";
        }
        $sqlarr[] = " ld_singin.createdtime like binary '%$searchcontent%' ";
        $sql = '('.implode(' or ',$sqlarr).')';
        return $sql;
    }
    
    protected function addStdSearchContentWX($lastmodified){
        if(!empty($lastmodified) && $lastmodified!='unlimit') {
            include_once(globalStatic::$root_directory.'modules/CustomView/CommonView.php');
            $dateArr = CommonView::stdFilterDateTimeStr('lastmodified');
            $newTime[] = $dateArr[$lastmodified][0] . ' 00:00:00';
            $newTime[] = $dateArr[$lastmodified][1] . ' 23:59:59';
            $between = ' %s.createdtime BETWEEN \''.$newTime[0].'\' AND \''.$newTime[1].'\'';
            return $between;
        }
    }

    public function setreturnJson_listContent()
    {
        global $current_user;
        $MergeSmowner = getCurSmOwnerSearchScope($this->SearchScopeModule);
        unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
        $MergeSmowner2 = array();
        $MergeSmowner2['fieldname'] = 'SearchScope';
        $MergeSmowner2['fieldlabel'] = '查看范围';//gyqCN
        $j=0;
        foreach ($MergeSmowner as $key => $val) {
            foreach ($val as $key1 => $val1) {
                if($key == 'UserCombo' || $key == 'OtherInfo'&&($key1=='SmOwner_Search_All'||$key1=='SmOwner_Search_Me')) {
                    foreach ($val1 as $key2 => $val2) {
                        $MergeSmowner2Op[$j]['text'] = $key2;
                        $MergeSmowner2Op[$j]['value'] = $key1;
                    }
                    $j++;
                }
            }
        }
        $MergeSmowner2['text'] = $MergeSmowner2Op[0]['text'];
        $MergeSmowner2['option'] = $MergeSmowner2Op;
        $this->jsonArr['list'][] = $MergeSmowner2;  //查看范围
        $this->jsonArr['list'][] = $this->setLastmodifiedFormat(); //最新更新日期
        /*
        $this->jsonArr['listtab']['fieldname'] = 'viewname';
        $this->jsonArr['listtab']['fieldlabel'] = '查看范围';
        $this->jsonArr['listtab']['text'] = '我的';
        $this->jsonArr['listtab']['option'][] = array('text' => '我的', 'value' => 'SmOwner_Search_Me');
        $this->jsonArr['listtab']['option'][] = array('text' => '全部', 'value' => 'SmOwner_Search_All');
        $this->jsonArr['listtab']['option'][] = array('text' => '筛选', 'value' => 'filter');
        */

    }
    //editor:gyq_20181018 获取源单定制签到模块的模块列表
//    protect function get_option_modules(){
//        global $adb;
//        $tabid = getTabid('Singin');
//        $list_query = 'select op.option_tabid,ld_tab.name modulename,op.default
//                from ld_option_module as op
//				left join ld_tab on ld_tab.tabid = op.option_tabid
//                where op.tabid=? and ld_tab.presence <> 1 and op.presence<>1 order by sequence';
//        $list_result = $adb->pquery($list_query,array($tabid));
//        $num_rows =  $adb->num_rows($list_result);
//        $modulelist=  array();
//        if($num_rows){
//            $select_arr = array(0=>'',1=>'selected');
//            for($i=0;$i<$num_rows;$i++){
//                $option_tabid = $adb->query_result($list_result,$i,'option_tabid');
//                $modulename = $adb->query_result($list_result,$i,'modulename');
//                $default = $adb->query_result($list_result,$i,'default');
//                $modulename_label = getTranstab($modulename);
//                $modulelist[$i]['label']  = $modulename_label;
//                $modulelist[$i]['value']  = $modulename;
//                $modulelist[$i]['select']  = $select_arr[$default];
//            }
//        }
//        return $modulelist;
//    }

}