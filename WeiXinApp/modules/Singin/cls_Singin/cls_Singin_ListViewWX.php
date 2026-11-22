<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');//gyq_24
class  cls_Singin_ListViewWX extends cls_ListViewWX
{
    
    public function get_page_query($showtype,$isSingle){
        //duan 20221209 拜访签到列表sql读取额外字段
        $page_Sql =  parent::get_page_query($showtype,$isSingle);
        $this->obj_query->popuselectcolumn .= ',ld_singin.record,ld_singin.tabid,ld_singin.userid,ld_singin.signout_id ';

        return $page_Sql;
    }
    
    public function getListViewEntries($adb,$list_result,$approvestatus){
        global $current_user;
        $list1 = parent::getListViewEntries($adb,$list_result,$approvestatus);
        //duan 判断移动端拜访签到列表页操作按钮
        $SQL_relatedtab = "SELECT a. NAME,b.relation_id FROM ld_tab a
                            LEFT JOIN ld_relatedlists b ON a.tabid = b.tabid
                            WHERE b.`name` = 'get_ContactRecords' and LOCATE('add',actions) >0";
        $related_tabres=$adb->pquery($SQL_relatedtab,array());
        $num_rows = $adb->num_rows($related_tabres);
        if($num_rows >0){
            $relationid_arr = array();
            for($i=0;$i<$num_rows;$i++){
                $relation_module = $adb->query_result($related_tabres,$i,'name');
                $relation_id = $adb->query_result($related_tabres,$i,'relation_id');
                $relationid_arr[$relation_module] = $relation_id;
            }
        }
        $related_tabid = getTabid('ContactRecords');
        $related_module = 'ContactRecords';
        
        foreach($list1 as $tmp_index => $tmp_info){
            $signid = $tmp_info['curid'];
            
            $fromid = $tmp_info['fromid'];
            $fromtabid = $tmp_info['fromtabid'];
            $signedout = $tmp_info['signedout'];//是否已签退
            $frommodule = getTabname($fromtabid);
            $btnList = array();
            //BUG0054323 wyt 220802 (企业微信移动端)拜访签到中,新建签到内容时,选择拜访对象类型为跟进记录后,进入历史无法填写跟进.其他拜访对象类型没有此问题.(钉钉上也有此问题)
            if(isPermitted($related_module,'Create') == 'yes'){
                if(array_key_exists($frommodule,$relationid_arr)){
                    $related_id = $relationid_arr[$frommodule];
                    $btnList[] = array('frommodule'=>$frommodule,'fromid'=>$fromid,'relatedid'=>$related_id,'module'=>$related_module,'btnname'=>getFixedLabel('WRITEFOLLOWUP'));
                }
            }
            $list1[$tmp_index]['btnList'] = $btnList;
            //当前用户的签到记录可以删除
            $tmpuserid = $tmp_info['userid'];
            $list1[$tmp_index]['del'] = isPermitted('Singin','Delete',$signid);
            //获取当前单据的签到图片
            
            $list1[$tmp_index]['image'] = $this->getNewAttachments($signid);
            // dump($tmp_info);

            //2024-3-26 xxy 签到列表按钮传参优化
            $list1[$tmp_index]['btnListNew'] = [];
            if(vtlib_isModuleActive('Signout')){
                if($_REQUEST['listview_type'] != 'havesignedout' && $signedout == 'no' && isPermitted('Signout','DetailView','') == 'yes'){
                    //签退
                    $list1[$tmp_index]['btnListNew'][] = array('frommodule'=>'Singin','fromid'=>$signid,'relatedid'=>'','module'=>'Signout','btnname'=>getFixedLabel('SIGNOUT2'),'type' => 'signout');
                    //补签
                    if($this->isAllowSupSignout($frommodule) == 'yes'){
                        $list1[$tmp_index]['btnListNew'][] = array('frommodule'=>'Singin','fromid'=>$signid,'relatedid'=>'','module'=>'Signout','btnname'=>getFixedLabel('SUPSIGN'),'type' => 'supsignout');
                    }
                }
            }
            if(count($btnList) > 0){
                $btnList[0]['type'] = 'create';
                $list1[$tmp_index]['btnListNew'][] = $btnList[0];
            }
            if(isPermitted('Singin','Delete',$signid) == 'yes'){
                $list1[$tmp_index]['btnListNew'][] = array('frommodule'=>'Singin','fromid'=>$signid,'relatedid'=>'','module'=>'','btnname'=>getFixedLabel('DELETE'),'type' => 'delete');
            }
            
        }
        
        return $list1;
    }
    //获取签到考勤关联图片
    public function getNewAttachments($id){
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
            
            if($uploadtype != 'Takephoto'){
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
    
    //联系人模块获取查询手机号码的查询语句 gyq_32
    protected function get_phone_sql($focus,$list_query){
        /*
        $moduleFields = $focus->fieldobj->getModuleFields();
        //设置手机号码的显示样式:如果手机控制样式，则只取uitype等于11的字段值
        $sysdeploy_mobile_style = getSys_deploy(80);
        foreach ($moduleFields as $fieldname => $fieldinfo) {
            if ($sysdeploy_mobile_style['deploy_value'] >= 1 && $fieldinfo->getUIType() == 11
                || $sysdeploy_mobile_style['deploy_value'] == 0 && ($fieldinfo->getUIType() == 11 || $fieldinfo->getUIType() == 1101)
            ) {
                $tablename = $fieldinfo->getTableName();
                $columnname = $fieldinfo->getColumnName();
                if ($tablename == 'ld_contactscf') {
                    $listscf = ' FROM ld_contactdetails left join ld_contactscf on ld_contactdetails.contactid = ld_contactscf.contactid ';
                    if(stripos(str_replace(' ','', $list_query),'leftjoinld_contactscf')  === false) {
                        $list_query = str_replace('FROM ld_contactdetails', $listscf, $list_query);
                    }
                }
                $querycolumnname[] = $tablename . '.' . $columnname;
            }
        }
        if (sizeOf($querycolumnname) >= 1) {
            $querycolumnname = 'CONCAT_WS(" ",' . implode(',', $querycolumnname) . ') as mobile,';
            $list_query = str_replace("ld_contactdetails.mobile,", $querycolumnname, $list_query);
        }*/
        return $list_query;

    }
    //签退是否允许补签
    public function isAllowSupSignout($module){
        crm_load_class_file('cls_OptionModule', 'include/OptionModule');
        $cls_OptionModule = cls_OptionModule::getInstance('Singin','');
        $tabid = getTabid($module);
        $signin_tabid = getTabid('Singin');
        $frommodule_alldata = $cls_OptionModule->getCurModuleData();
        return $frommodule_alldata[$signin_tabid][$tabid]['allowsupsignout'];
    }
    public function get_listdetail($showtype='',$generatorName='')
    {
        global $adb,$viewid,$current_user;
        $listview_type = $_REQUEST['listview_type'];
        // $listview_type = 'notsignedout';
        // $listview_type = 'havesignedout';
        $this->set_listdetail("");

        $page_list_query = $this->page_list_query;//获取总条数的sql

        $list_query = $this->list_query;

        if($this->mark_tab_main == 1){
            global $customView;
            $viewid = $customView->getViewIdByName('All',$this->module);
        }
        if($listview_type == 'notsignedout'){
            $page_list_query .= " AND (ld_singin.signout_id IS NULL OR ld_singin.signout_id = 0)";
        }else if($listview_type == 'havesignedout'){
            $page_list_query .= " AND ld_singin.signout_id IS NOT NULL AND ld_singin.signout_id > 0 ";
        }
        //editor:gyq_98 reason:微信客户查重，查询方法改为继承PC端  2019/1/22 14:52
        if(empty($this->customview)){
            $page_list_query2 = $page_list_query;
            $order_by = $this->order_by;
            // @edit:dong @date:2020/08/07 @reason: 没有排序导致pc查重和手机端查重结果不一致
            $page_list_query2 .= ' order by '.$order_by;
        }else{
            list($page_list_query2, $order_by, $sorder) = $this->customview->getOrderWhere($page_list_query);
        }
        //$count_result = $adb->query(mkCounntListQuery($this->module, $page_list_query));
        // file_put_contents(globalStatic::$root_directory.'WeiXinApp/list/2.txt',$page_list_query,FILE_APPEND);
        $count_result = $adb->query($page_list_query);
        if (!empty($count_result)){
            $noofrows = $adb->num_rows($count_result);
        }
        else{
            $noofrows = null;
        }
        // dump(($page_list_query));
        $page_list_query = $this->page_list_query($noofrows, $page_list_query2, $order_by);

        $list_query = $list_query . '  inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' . 
                $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index ;
        // if($listview_type == 'notsignedout'){
        //     $list_query .= " LEFT JOIN ld_signout ON ld_signout.signin_id = ld_singin.signid
        //                                             WHERE ld_singin.deleted = 0 AND ld_signout.signin_id IS NULL ";
        // }else if($listview_type == 'havesignedout'){
        //     $list_query .= " INNER JOIN ld_signout ON ld_signout.signin_id = ld_singin.signid
        //                                                 WHERE ld_singin.deleted = 0 AND ld_signout.deleted = 0 ";
        // }
        // if($listview_type == 'notsignedout'){
        //     $list_query .= " WHERE ld_singin.signout_id IS NULL OR ld_singin.signout_id = 0";
        // }else if($listview_type == 'havesignedout'){
        //     $list_query .= " WHERE ld_singin.signout_id IS NOT NULL AND ld_singin.signout_id > 0 ";
        // }
        $list_query .= ' order by '.$order_by.' '.$sorder;
        $list_result = $adb->pquery($list_query,array());
        // dump($list_result);
        $num_rows = $adb->num_rows($list_result);
        // $this->jsonArr['totalrows'] = $num_rows;
        $_REQUEST['weixin_mark'] = 1; //微信端号码原样输出 gyqTE
        $this->jsonArr['search_reminds'] = $this->getSearchReminds();
        $list1 = $this->getListViewEntries($adb,$list_result,null);
        // dump($list_query);
        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type = 7';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'yes';
        }
        if($this->module!='SocialPromotion'&&$is_open=='yes'){
            //zxm 2021-04-01【移动端，单据列表界面增加更多中的操作按钮】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001348
            $this->getModuleRelatedList();
        }
        $this->jsonArr['list1'] = $list1;
        $this->jsonArr['high_search'] = $this->getHigheSearchField();//diony 20200528 功能完成后放开
		if($this->module=='Accounts'||$this->module=='Leads'){
			$this->getPublicAccountPool();//chj 2020/12/10 获取公海池
		}
        $this->set_outputStyle("");

		//判断电话是否隐藏显示
        $Sys_deploy_80 = getSys_deploy(80);
        $deploy_value = $Sys_deploy_80['deploy_value'];
        $this->jsonArr['listSettings'] = ['havephone'=>'no'];
        //bug zxm BUG0053046   根据用户的参数 手机显示样式控制 is_mobile_style=0 则不需要判断 $Sys_deploy_80
        if($deploy_value==0||$current_user->is_mobile_style!=1){
            //判断模块是否有电话或者手机号码字段  zxm 2021-02-24
            $tempFocus = CRMEntity::getInstance($this->module);
            $fieldArr_mobile = $tempFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'mobile');
            $fieldArr_phone = $tempFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'phone');
            $fieldArr_contactsmobile = [];
            $fieldArr_contactsphone = [];
            if($this->module=="Accounts"){
                //如果是客户模块  还可以判断联系人模块
                $contactsFocus = CRMEntity::getInstance($this->module);
                $fieldArr_contactsmobile = $contactsFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'mobile');
                $fieldArr_contactsphone = $contactsFocus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'phone');
            }
            $fieldArr = array_merge($fieldArr_mobile,$fieldArr_phone,$fieldArr_contactsmobile,$fieldArr_contactsphone);
            if(sizeof($fieldArr)>0){
                $this->jsonArr['listSettings']['havephone'] = 'yes';
            }
        }
        return $this->jsonArr;

    }
}