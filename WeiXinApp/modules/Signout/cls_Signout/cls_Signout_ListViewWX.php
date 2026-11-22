<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');//gyq_24
class  cls_Signout_ListViewWX extends cls_ListViewWX
{
    
    // public function get_page_query($showtype,$isSingle){
    //     //duan 20221209 拜访签到列表sql读取额外字段
    //     $page_Sql =  parent::get_page_query($showtype,$isSingle);
    //     // $this->obj_query->popuselectcolumn .= ',ld_singin.record,ld_singin.tabid,ld_singin.userid ';
    //     // dump($this->obj_query->popuselectcolumn);

    //     return $page_Sql;
    // }
    
    // public function getListViewEntries($adb,$list_result,$approvestatus){
    //     global $current_user;
    //     $list1 = parent::getListViewEntries($adb,$list_result,$approvestatus);
    //     // dump($list_result);
    //     //duan 判断移动端拜访签到列表页操作按钮
    //     $SQL_relatedtab = "SELECT a. NAME,b.relation_id FROM ld_tab a
    //                         LEFT JOIN ld_relatedlists b ON a.tabid = b.tabid
    //                         WHERE b.`name` = 'get_ContactRecords' and LOCATE('add',actions) >0";
    //     $related_tabres=$adb->pquery($SQL_relatedtab,array());
    //     $num_rows = $adb->num_rows($related_tabres);
    //     if($num_rows >0){
    //         $relationid_arr = array();
    //         for($i=0;$i<$num_rows;$i++){
    //             $relation_module = $adb->query_result($related_tabres,$i,'name');
    //             $relation_id = $adb->query_result($related_tabres,$i,'relation_id');
    //             $relationid_arr[$relation_module] = $relation_id;
    //         }
    //     }
    //     $related_tabid = getTabid('ContactRecords');
    //     $related_module = 'ContactRecords';
        
    //     foreach($list1 as $tmp_index => $tmp_info){
    //         $signid = $tmp_info['curid'];
            
    //         $fromid = $tmp_info['fromid'];
    //         $fromtabid = $tmp_info['fromtabid'];
    //         $frommodule = getTabname($fromtabid);
    //         $btnList = array();
    //         //BUG0054323 wyt 220802 (企业微信移动端)拜访签到中,新建签到内容时,选择拜访对象类型为跟进记录后,进入历史无法填写跟进.其他拜访对象类型没有此问题.(钉钉上也有此问题)
    //         if(isPermitted($related_module,'Create') == 'yes'){
    //            if(array_key_exists($frommodule,$relationid_arr)){
    //                 $related_id = $relationid_arr[$frommodule];
    //                 $btnList[] = array('frommodule'=>$frommodule,'fromid'=>$fromid,'relatedid'=>$related_id,'module'=>$related_module,'btnname'=>getFixedLabel('WRITEFOLLOWUP'));
    //            }
    //         }
    //         $list1[$tmp_index]['btnList'] = $btnList;
    //         //当前用户的签到记录可以删除
    //         $tmpuserid = $tmp_info['userid'];
    //         $list1[$tmp_index]['del'] = isPermitted('Signout','Delete',$signid);
    //         //获取当前单据的签到图片
            
    //         $list1[$tmp_index]['image'] = $this->getNewAttachments($signid);
            
    //     }
        
    //     return $list1;
    // }
    //获取签到考勤关联图片
    public function getNewAttachments($id){
        crm_load_class_file('cls_MyCRMcrypt',"Register");
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $filejsondata = getAllFile_imageInfo($id,'Signout');
        
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
}