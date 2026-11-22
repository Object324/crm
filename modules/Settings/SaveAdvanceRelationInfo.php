<?php
/*
edit:duan
date:2022-5-16
reason:保存推进关系界面的权限和任务信息
*/
global $adb;
//获取基本参数
$frommodule = $_REQUEST['frommodule'];//当前模块
if($frommodule == 'Events'){
    $frommodule = 'Calendar';
}
$module_field = $_REQUEST['module_field'];//追踪字段名称
$advanceid = $_REQUEST['advanceid'];//推进关系id
$profileid = $_REQUEST['profileid'];//角色权限id
$userid = $_REQUEST['userid'];//选中的用户id
$userfieldid_str = $_REQUEST['userfieldid_str'];//选中的用户字段id
$autopush = $_REQUEST['autopush'];//'yes','no'
$taskdescription = $_REQUEST['taskdescription'];// 任务描述
//更新基本权限设置
$sql = "update ld_advancepicklist set autopush=?,profileid=?,userid=?,userfieldid=?,taskdescription=? where advanceid = ?";
$adb->pquery($sql,array($autopush,$profileid,$userid,$userfieldid_str,$taskdescription,$advanceid));

//获取新任务信息
$all_taskinfo_arr = $_REQUEST['all_taskinfo'];
// 没有任务信息全部删除
if(empty($all_taskinfo_arr)){
    $select_sql = "SELECT taskid from ld_advancepicklisttask where advanceid = ?";
    $select_result = $adb->pquery($select_sql,array($advanceid));
    $num_rows=$adb->num_rows($select_result);
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $del_taskid[] = $adb->query_result($select_result,$i,'taskid');
        }
    }
    delete_Taskinfo('ld_advancepicklisttask','advanceid',$advanceid);
    $del_sql = "DELETE from ld_advancepicklistlog where FIND_IN_SET(taskid, ?)";
    $adb->pquery($del_sql,array(implode(',',$del_taskid)));
}

//获取旧任务信息
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance_obj =  cls_module_advance::getInstance($frommodule);
$taskinfo_old_arr = $cls_module_advance_obj->getadvancetaskbyfield($module_field);//旧任务信息

$allmodulearr = [];
$allfieldarr = [];
$all_validataid_arr = [];
$modulearr_old = [];
$selectarr_old = [];
$fieldarr = $fieldarr_old = [];
//遍历新任务信息
foreach($all_taskinfo_arr as $index => $taskinfo){
    $tasktype = $taskinfo['tasktype'];
    $alltasktype[] = $tasktype;// 储存所有设置的类型，后续需要统一删除没有设置的任务类型数据
    //根据任务类型获取旧任务信息
    $taskvalue_old_arr = $taskinfo_old_arr[$advanceid]['taskvalue'][$tasktype];

    $ori_tasklabelinfo = $taskinfo['tasklabelinfo'];// 页面上传来的每个tasklabel对应的taskid

    //单据模块任务内容
    if($tasktype=='module'){
        $modulearr = explode('##',$taskinfo['modulestr']);
        $effect_range = $taskinfo['effect_range'];
        $approve_demand = $taskinfo['approve_demand'];

        $modulearr = array_map('getTabname', $modulearr);
        $allmodulearr = array_merge($allmodulearr , $modulearr);// 记录页面传的所有模块
        
        $module_taskvalue_old_arr = $taskvalue_old_arr;
        foreach($taskvalue_old_arr as $key_old=>$value_old){
            $modulearr_old[$key_old] = $value_old['tasklabel'];
        }
        
        $common_module = array_intersect($modulearr,$modulearr_old);
        //插入新增加的任务内容
        if(sizeof($modulearr)>0 && !empty($modulearr[0])){
            foreach($modulearr as $key=>$value){
                if(empty($value))
                    continue;

                $ori_taskid = $ori_tasklabelinfo[$value];// 是否有对应taskid

                if(!in_array($value,$common_module) && empty($ori_taskid)){
                   $insert_sql_task = 'insert into ld_advancepicklisttask(advanceid,type,tasklabel,sequence,completerequest,presence,task_sequence,effect_range,approve_demand) values(?,?,?,?,?,?,?,?,?)';
                   $adb->pquery($insert_sql_task,array($advanceid,$tasktype,$value,$key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$effect_range,$approve_demand));
                }
                else if(in_array($value,$common_module)){//更新顺序
                    $update_sql_task = "update ld_advancepicklisttask set sequence = ?,completerequest=?,presence=?,task_sequence=?,effect_range=?,approve_demand=?  where tasklabel = ? and advanceid =?";
                    $adb->pquery($update_sql_task,array($key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$effect_range,$approve_demand,$value,$advanceid));
                }
            }
        }
        
        //复选框内容
    }else if($tasktype=='checkbox'){
        $checkboxarr = explode('##',trim($taskinfo['alltext']));

        $checkbox_taskvalue_old_arr = $taskvalue_old_arr;
        foreach($taskvalue_old_arr as $key_old=>$value_old){
            $checkboxarr_old[$key_old] = $value_old['tasklabel'];
            $checkboxtaskidarr_old[$key_old] = $value_old['taskid'];
        }
        // dump($taskvalue_old_arr);
        //判断新旧任务类型是否相同
        $common_checkbox = array_intersect($checkboxarr,$checkboxarr_old);
        //插入新增加的任务内容
        if(sizeof($checkboxarr)>0 && !empty($checkboxarr[0])){
            foreach($checkboxarr as $key=>$value){
                if(empty($value))
                    continue;
                // 获取是否有taskid
                $ori_taskid = '';
                foreach ($ori_tasklabelinfo as $ori_info) {
                    if ($ori_info['tasklabel'] == $value) {
                        $ori_taskid = $ori_info['taskid'];
                        $ori_checkboxtaskid_arr[] = $ori_taskid;// 记录传的所有taskid
                        break;
                    }
                }
                // 只要没有taskid就是新增的，需要插入
                if(empty($ori_taskid)){
                    $insert_sql_task = 'insert into ld_advancepicklisttask(advanceid,type,tasklabel,sequence,completerequest,presence,task_sequence) values(?,?,?,?,?,?,?)';
                    $adb->pquery($insert_sql_task,array($advanceid,$tasktype,$value,$key,$taskinfo['completerequest'],$taskinfo['presence'],$index));
                }
                else if(in_array($value,$common_checkbox) && !empty($ori_taskid)){//更新顺序
                    $update_sql_task = "update ld_advancepicklisttask set sequence = ?,completerequest=?,presence=?,task_sequence=?  where taskid = ? and advanceid =?";
                    $adb->pquery($update_sql_task,array($key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$ori_taskid,$advanceid));
                }
            }
        }

        //下拉框任务内容
    }else if($tasktype=='select'){
        $selectarr = explode('##',$taskinfo['allselect']);
        $selectname = $taskinfo['selecttaskname'];

        $taskid = $ori_tasklabelinfo;
        $ori_selecttaskid_arr[] = $taskid;// 记录传的所有taskid

        foreach ($taskvalue_old_arr as $j => $old_arr) {
            $selecttaskidarr_old[] = $old_arr['taskid'];
            if($old_arr['taskid'] == $taskid){
                $selectarr_old = $taskvalue_old_arr[$j]['selectinfo'];// $selectarr_old取当前taskid下的旧选项
            }
        }
        if(!empty($selectname)){
            if(empty($taskid)){//如果记录不存在则新加记录
                $insert_sql_task = 'insert into ld_advancepicklisttask(advanceid,type,tasklabel,completerequest,presence,task_sequence) values(?,?,?,?,?,?)';
                $adb->pquery($insert_sql_task,array($advanceid,$tasktype,$selectname,$taskinfo['completerequest'],$taskinfo['presence'],$index));
                $taskid = $adb->getLastInsertID();
            }else{//否则更新信息
                $update_sql_task = "update ld_advancepicklisttask set tasklabel=?,completerequest=?,presence=?,task_sequence=? where taskid = ?";
                $adb->pquery($update_sql_task,array($selectname,$taskinfo['completerequest'],$taskinfo['presence'],$index,$taskid));
            }
        }else{
            if($taskid >0){
                $delete_sql = "delete from ld_advancepicklisttask where taskid = ?";
                $adb->pquery($delete_sql,array($taskid));
            }
        }
        
        //获取下拉框选项的交集
        $common_select = array_intersect($selectarr_old,$selectarr);
        //删除多余记录
        if(sizeof($selectarr_old)>0&&!empty($selectarr_old[0])){
            foreach($selectarr_old as $key=>$value){
                if(!in_array($value,$common_select)){
                    $delete_sql = "delete from ld_advancepicklist_selectinfo where taskid = ? and selectinfo = ?";
                    $adb->pquery($delete_sql,array($taskid,$value));
                }
            }
        }
        //插入新记录并排序
        if(sizeof($selectarr)>0&&!empty($selectarr[0])){
            foreach($selectarr as $key=>$value){
                if(!in_array($value,$common_select)){
                    $insert_sql_selectinfo = "insert into ld_advancepicklist_selectinfo(taskid,selectinfo,sequence) values(?,?,?)";
                    $adb->pquery($insert_sql_selectinfo,array($taskid,$value,$key));
                }else{//更新顺序
                    $update_sql_selectinfo = "update ld_advancepicklist_selectinfo set sequence = ? where where taskid = ? and selectinfo = ?";
                    $adb->pquery($update_sql_selectinfo,array($key,$taskid,$value));
                }
            }
        }
    }else if($tasktype=='field'){//必填字段任务
        $fieldarr = explode('##',$taskinfo['fieldnamestr']);
        $allfieldarr = array_merge($allfieldarr , $fieldarr);// 记录页面传的所有字段
        $effect_range = $taskinfo['effect_range'];
        $field_taskvalue_old_arr = $taskvalue_old_arr;
        foreach($taskvalue_old_arr as $key_old=>$value_old){
            $fieldarr_old[$key_old] = $value_old['tasklabel'];
        }

        $common_field = array_intersect($fieldarr,$fieldarr_old);

        //插入新增加的任务内容
        foreach($fieldarr as $key=>$value){
            if(empty($value))
                continue;

            $ori_taskid = $ori_tasklabelinfo[$value];
            if(empty($value)){
                continue;
            }
            if(!in_array($value,$common_field) && empty($ori_taskid)){
                $insert_sql_task = 'insert into ld_advancepicklisttask(advanceid,type,tasklabel,sequence,completerequest,presence,task_sequence,effect_range) values(?,?,?,?,?,?,?,?)';
                $adb->pquery($insert_sql_task,array($advanceid,$tasktype,$value,$key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$effect_range));
            }
            else if(in_array($value,$common_field)){//
                $update_sql_task = "update ld_advancepicklisttask set sequence = ?,completerequest=?,presence=?,task_sequence=?,effect_range=?  where tasklabel = ? and advanceid =?";
                $adb->pquery($update_sql_task,array($key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$effect_range,$value,$advanceid));
            }
        }

    }else if($tasktype=='validata'){//必填字段任务
        $validataid = $taskinfo['validataid'];
        $all_validataid_arr[] = $validataid;

        $validata_taskvalue_old_arr = $taskvalue_old_arr;
        foreach($taskvalue_old_arr as $key_old=>$value_old){
            $validataskidarr_old[] = $value_old['taskid'];
            $validata_old[$key_old] = $value_old['tasklabel'];
        }

        $common_arr = is_array($all_validataid_arr)&&is_array($validata_old)?array_intersect($all_validataid_arr,$validata_old):[];
        if($validataid > 0 ){
            //插入新增加的任务内容
            if(!in_array($validataid,$common_arr) ){
                $insert_sql_task = 'insert into ld_advancepicklisttask(advanceid,type,tasklabel,sequence,completerequest,presence,task_sequence) values(?,?,?,?,?,?,?)';
                $adb->pquery($insert_sql_task,array($advanceid,$tasktype,$validataid,$key,$taskinfo['completerequest'],$taskinfo['presence'],$index));
            }
            else if(in_array($validataid,$common_arr)){//
                $update_sql_task = "update ld_advancepicklisttask set sequence = ?,completerequest=?,presence=?,task_sequence=?  where tasklabel = ? and advanceid =?";
                $adb->pquery($update_sql_task,array($key,$taskinfo['completerequest'],$taskinfo['presence'],$index,$validataid,$advanceid));
            }

            $status = ($taskinfo['presence'] == 'yes'?'active':'inactive');
            $update_sql_validata = "update ld_validatasavemain set `status` = ? where id = ? ";
            $adb->pquery($update_sql_validata,array($status,$validataid));
        }
    }
}
// 统一删除任务及对应的记录
// 模块和字段一致，以前有的模块(字段)现在没有就删除，因为模块(字段)可以在另一个同类型任务中被重新选择，所以不能在循环中删除
if(is_array($modulearr_old) && sizeof($modulearr_old)>0 && !empty($modulearr_old[0])){// 模块
    foreach($modulearr_old as $key=>$value){
        $tmp_taskid = $module_taskvalue_old_arr[$key]['taskid'];
        if(!in_array($value,$allmodulearr)){
            delete_Taskinfo('ld_advancepicklisttask','taskid',$tmp_taskid);
            delete_Taskinfo('ld_advancepicklistlog','taskid',$tmp_taskid);
        }
    }
}
if(is_array($fieldarr_old) && sizeof($fieldarr_old)>0 && !empty($fieldarr_old[0])){// 字段
    foreach($fieldarr_old as $key=>$value){
        $tmp_taskid = $field_taskvalue_old_arr[$key]['taskid'];
        if(!in_array($value,$allfieldarr)){
            delete_Taskinfo('ld_advancepicklisttask','taskid',$tmp_taskid);
            delete_Taskinfo('ld_advancepicklistlog','taskid',$tmp_taskid);
        }
    }
}
if(is_array($checkboxtaskidarr_old) && sizeof($checkboxtaskidarr_old)>0){// 复选框，获取到以前所有taskid，和页面传过来的taskid，以前有现在没有就删除，选项名可以重复，所以只用taskid判断
    foreach($checkboxtaskidarr_old as $key=>$taskid_old){
        if(!in_array($taskid_old,$ori_checkboxtaskid_arr)){
            delete_Taskinfo('ld_advancepicklisttask','taskid',$taskid_old);
            delete_Taskinfo('ld_advancepicklistlog','taskid',$taskid_old);
        }
    }
}
if(is_array($selecttaskidarr_old) && sizeof($selecttaskidarr_old)>0){// 下拉框，删除选项名和对应选项
    foreach($selecttaskidarr_old as $key=>$taskid_old){
        if(!in_array($taskid_old,$ori_selecttaskid_arr)){
            delete_Taskinfo('ld_advancepicklisttask','taskid',$taskid_old);
            delete_Taskinfo('ld_advancepicklist_selectinfo','taskid',$taskid_old);
        }
    }
}
if(is_array($validata_taskvalue_old_arr) &&  sizeof($validata_taskvalue_old_arr)>0){// 复选框，获取到以前所有taskid，和页面传过来的taskid，以前有现在没有就删除，选项名可以重复，所以只用taskid判断
    foreach($validata_taskvalue_old_arr as $key=>$taskinfo_arr){
        $tmpid = $taskinfo_arr['tasklabel'];
        if(!in_array($tmpid,$all_validataid_arr)){
            delete_Taskinfo('ld_advancepicklisttask','taskid',$taskinfo_arr['taskid']);
            delete_Taskinfo('ld_advancepicklistlog','taskid',$taskinfo_arr['taskid']);
            //删除任务时，同时清空验证规则相关表
            $sql='DELETE from ld_validatasavedetail  where  relateid in (select id from ld_validatasave where validatasavemainid = ?)';
            $adb->pquery($sql,array($tmpid));
            $sql='DELETE from ld_validatasave where validatasavemainid = ?';
            $adb->pquery($sql,array($tmpid));
            $sql='DELETE from ld_validatasavemain where  id=? ';
            $adb->pquery($sql,array($tmpid));
        }
    }
}

// 统一删除没有设置的任务类型数据
if(!empty($alltasktype)){
    $alltasktype = array_unique($alltasktype);// 去重
    $del_tasktype = array_diff(array('field','module','select','checkbox','validata'), $alltasktype);

    $select_sql = "SELECT taskid from ld_advancepicklisttask where advanceid = ? and FIND_IN_SET(`type`, ?)";
    $select_result = $adb->pquery($select_sql,array($advanceid,implode(',',$del_tasktype)));
    $num_rows=$adb->num_rows($select_result);
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $del_taskid[] = $adb->query_result($select_result,$i,'taskid');
        }
    }
    if (is_array($del_taskid) && count($del_taskid)>0) {
        $del_sql1 = "DELETE from ld_advancepicklistlog where FIND_IN_SET(taskid, ?)";
        $adb->pquery($del_sql1,array(implode(',',$del_taskid)));
    }
    $del_sql2 = "DELETE from ld_advancepicklisttask where advanceid = ? and FIND_IN_SET(`type`, ?)";
    $adb->pquery($del_sql2,array($advanceid,implode(',',$del_tasktype)));
    
}

unsetCache('cache_alladvancetask');//删除原缓存

$sql = "
	select ( CASE 
	WHEN profileid != '' && profileid IS NOT NULL then 'yes'
	WHEN userid != '' && userid IS NOT NULL then 'yes'
	WHEN userfieldid != '' && userfieldid IS NOT NULL then 'yes'
	WHEN tmp.advanceid != '' && tmp.advanceid IS NOT NULL then 'yes'
	ELSE 'no' END )AS hascontent
     from ld_advancepicklist LEFT JOIN 
     (SELECT DISTINCT advanceid from ld_advancepicklisttask where advanceid =? AND IFNULL(tasklabel,'')!='' )
    as tmp on ld_advancepicklist.advanceid = tmp.advanceid where ld_advancepicklist.advanceid =? ;";
$result = $adb->pquery($sql,array($advanceid,$advanceid));
if($adb->num_rows($result)>0){
    $hascontent = $adb->query_result($result,0,'hascontent');
}else{
    $hascontent = 'no';
}
$arr['hascontent'] = $hascontent;
$_REQUEST['diony'] = 'diony';
ConvertTojsonString(1,$arr,"success");

//删除符合条件的记录
function delete_taskinfo($tablename,$fieldname,$value){
    global $adb;
    $delete_sql = "delete from $tablename where $fieldname = '$value'";
    $adb->pquery($delete_sql,array());
}
?>