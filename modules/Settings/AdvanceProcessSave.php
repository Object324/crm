<?php
/*
 * edit:duan
 * date:20231117
 * reason:推进流程图后台保存
 * */

global $adb,$current_user;
$frommodule = $_REQUEST['frommodule'];
if($frommodule == 'Events'){
    $frommodule = 'Calendar';
}
//zxm 20230403 kfbcrm-自定义表单-页面设置-自动化进度设置-勾选“pc端启用进度跟踪”“移动端启用进度跟踪” 页面一直加载转圈
if(empty($_REQUEST['module_field'])||$_REQUEST['module_field']=="null"){
    ConvertTojsonString(-1,array(),getFixedLabel('Selecttrackingfield').getFixedLabel('APPCANNOTBEEMPTY'));
}
if(!empty($frommodule)){
    $tabid = getTabid($frommodule);
    $query = 'select method,module_field,module_period_start_field,module_period_end_field from ld_settings_advance where tabid = ? limit 1';
    $result = $adb->pquery($query,array($tabid));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $method = $adb->query_result($result,0,'method');
        $before_module_field = $adb->query_result($result,0,'module_field');
        $before_module_period_start_field = $adb->query_result($result,0,'module_period_start_field');
        $before_module_period_end_field = $adb->query_result($result,0,'module_period_end_field');
        $update = 'update ld_settings_advance set module = ?,enable = ?,method = ?,module_field = ?,module_period_start_field = ?,module_period_end_field = ?,
			showadvancelog = ?,showadvancemobile = ?,pushback = ?,operatestyle = ?,logshowstyle = ?, defaultshow =?, staytimemethod = ? where tabid = ?';
        $adb->pquery($update,array($_REQUEST['frommodule'],$_REQUEST['enable'],$_REQUEST['method'],$_REQUEST['module_field'],
            $_REQUEST['module_period_start_date_field'],$_REQUEST['module_period_end_date_field'],$_REQUEST['showadvancelog'],
            $_REQUEST['showadvancemobile'],$_REQUEST['pushback'],$_REQUEST['operatestyle'],$_REQUEST['logshowstyle'],$_REQUEST['defaultshow'],$_REQUEST['staytimemethod'],$tabid));
    }else{
        $query = 'insert into ld_settings_advance(tabid,module,enable,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile,pushback,operatestyle,logshowstyle,defaultshow,staytimemethod,use_dependency) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
        $adb->pquery($query,array($tabid,$_REQUEST['frommodule'],$_REQUEST['enable'],$_REQUEST['method'],$_REQUEST['module_field'],
            $_REQUEST['module_period_start_date_field'],$_REQUEST['module_period_end_date_field'],$_REQUEST['showadvancelog'],
            $_REQUEST['showadvancemobile'],$_REQUEST['pushback'],$_REQUEST['operatestyle'],$_REQUEST['logshowstyle'],$_REQUEST['defaultshow'],$_REQUEST['staytimemethod'],'yes'));
    }

    //指定字段
    if($_REQUEST['method'] == 'field'){
        $update = "update ld_field set presence = 1 where tabid = ? and fieldname in('advance_stage')";
        $adb->pquery($update,array($tabid,));
    }else{
        $update = "update ld_field set presence = 0 where tabid = ? and fieldname = 'advance_stage'";
        $adb->pquery($update,array($tabid,));
    }
    //zkt 20221122 BUG0058831启用进度推进，设置按“指定字段”并选择“跟踪字段”后，跟踪字段是不允许直接编辑的，但是在列表仍可编辑
    $editpage = '';
    if($_REQUEST['enable']!='yes'&&$_REQUEST['showadvancemobile']!='yes'){
        $editpage = 'listview';
    }
    if(!empty($before_module_field)&&$before_module_field != $_REQUEST['module_field']){
        $update = "update ld_field set editpage = 'listview' where tabid = ? and fieldname = ?";
        $adb->pquery($update,array($tabid,$before_module_field));
    }
    $update = "update ld_field set editpage = ? where tabid = ? and fieldname = ?";
    $adb->pquery($update,array($editpage,$tabid,$_REQUEST['module_field']));
    //duan 2022-2-7 切换进度追踪字段后，对应的推进阶段字段值没有更新，导致进度漏斗显示值为0
    if($_REQUEST['method'] == 'field' && $_REQUEST['module_field'] != $before_module_field ){
        update_advancestage_value($frommodule,$_REQUEST['module_field'],$_REQUEST['method']);
    }

    unsetCacheDirectory('fields');
    unsetCache('ld_settigs_module_advance'.$tabid);

    //保存推进流程图信息
    if($_REQUEST['method'] == 'field'){
        $stepinfo = $_REQUEST['stepinfo'];
        $module_field = $_REQUEST['module_field'];
        $length = count($stepinfo);
        $no_deleteid_arr = [0];
        $stagevalue_arr = [];
        $all_node_info = [];
        for ($i=0;$i<$length;$i++){
            $tmp_arr = $stepinfo[$i];
            $tmp_id = $tmp_arr['id'];
            $nodeid = $tmp_arr['nodeid'];
            $childid = $tmp_arr['childid'];
            $branchnodeid = $tmp_arr['branchnodeid'];
            $nodename = $tmp_arr['nodename'];
            $nodetype = $tmp_arr['nodetype'];
            $stagename = $tmp_arr['nodeinfo']['stagevalue'];
            $stagevalue_arr[$nodeid] = $stagename;
            $all_node_info[$nodeid] = $tmp_arr;
            $content = '';
            if($nodetype == 'condition' && !empty($tmp_arr['nodeinfo']['advancesearch'])){
                $adv_info = [];
                $adv_info['advancesearch'] = $tmp_arr['nodeinfo']['advancesearch'];
                $adv_info['groupcondition'] = $tmp_arr['nodeinfo']['groupcondition'];
                $content = json_encode($adv_info);
            }
            $tmp_value_arr = [$nodeid,$childid,$branchnodeid,$nodetype,$nodename,$frommodule,$module_field,$stagename,$content];
            if(!empty($tmp_id)){
                $no_deleteid_arr[] = $tmp_id;
                $tmp_sql = 'update ld_advanceprocess set nodeid = ?,childid = ?,branchnodeid = ?,nodetype = ?,nodename = ?,frommodule = ?,fieldname = ?,stagename = ?,content = ?';
                $adb->pquery($tmp_sql,$tmp_value_arr);
            }else{
                $tmp_sql = 'INSERT into ld_advanceprocess(nodeid,childid,branchnodeid,nodetype,nodename,frommodule,fieldname,stagename,content) values(?,?,?,?,?,?,?,?,?)';
                $adb->pquery($tmp_sql,$tmp_value_arr);
                $tmp_id = $adb->getLastInsertID();
                $no_deleteid_arr[] = $tmp_id;
            }
        }

        $no_deleteid_str = implode(',',$no_deleteid_arr);
        $delete_sql = 'DELETE from ld_advanceprocess where frommodule =? and fieldname = ? and stageid not in ('.$no_deleteid_str.')';

        $adb->pquery($delete_sql,[$frommodule,$module_field]);
        //默认值判断,如果当前阶段没有设置过与下一阶段的推进关系,则添加推进关系
        crm_load_class_file('cls_module_advance','modules/Settings');
        $cls_module_advance_obj =  cls_module_advance::getInstance($frommodule);
        $allAdvanceRelation = $cls_module_advance_obj->getAdvanceRelations($module_field);

        for ($i=0;$i<$length;$i++){
            $tmp_arr = $stepinfo[$i];
            $childid = $tmp_arr['childid'];
            $nodetype = $tmp_arr['nodetype'];
            if($nodetype == 'approver'){
                $stagename = $tmp_arr['nodeinfo']['stagevalue'];
                if(empty($stagename))continue;
                $new_childid_arr = [];
                if(!empty($childid)){
                    $childid_arr = explode(',',$childid);
                    foreach ($childid_arr as $tmp_id){
                        $tmp_arr = getlastchildstep($tmp_id,$all_node_info);
                        $new_childid_arr = array_merge($new_childid_arr,$tmp_arr);
                    }
                }
                if(empty($stagename))continue;
                foreach ($new_childid_arr as $tmp_id){
                    $next_stagename = $stagevalue_arr[$tmp_id];
                    if(empty($next_stagename))continue;

                    //如果未设置过当前阶段和下一阶段的推进关系，则默认添加一条
                    if(is_array($allAdvanceRelation[$stagename]) && is_array($allAdvanceRelation[$stagename][$next_stagename])){
                    }else{
                        $sql = 'insert into ld_advancepicklist(tabid,fieldname,stagename,stagename_target,presence) values(?,?,?,?,?)';
                        $adb->pquery($sql,array($tabid,$module_field,$stagename,$next_stagename,'yes'));

                        if(!is_array($allAdvanceRelation[$stagename])){
                            $allAdvanceRelation[$stagename] = [];
                        }
                        $tmp_arr = array('presence'=>'yes');
                        $allAdvanceRelation[$stagename][$next_stagename] = $tmp_arr;
                    }
                }
            }
        }

    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");

//duan 2022-2-7 切换进度追踪字段后，同步更新单据中的推进阶段字段值
function update_advancestage_value($module,$fieldname,$method){
    //duan 2022-2-7 解决按指定字段追踪的问题,按日期追踪是否需要修改有待进一步讨论
    if($method == 'field'){
        global $adb;
        $focus = CRMEntity::getInstance($module);
        $tablename = $focus->table_name;
        $table_index = $focus->table_index;
        $customFieldTable = $focus->customFieldTable;
        $fieldinfoobj = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
        $columnname = $fieldinfoobj->getColumnName();
        $field_tablename = $fieldinfoobj->getTableName();
        //duan 20230427 因为可能存在数据量过大的情况,禁用触发器
        $trigger_query = "set @disable_triggers = 'aaa';";
        $adb->pquery($trigger_query,array());
        if($field_tablename == $tablename){
            $query = "update $tablename set advance_stage = $columnname ";
            $adb->pquery($query,array());
        }if($field_tablename == $customFieldTable[0]){
            $query = "update $tablename left join $customFieldTable[0] on $customFieldTable[0].$customFieldTable[1] = $tablename.$table_index set advance_stage = $customFieldTable[0].$columnname ";
            $adb->pquery($query,array());
        }
    }
}
//获取下一个推进阶段的节点id
function getlastchildstep($nodeid,$all_node_info){
    static $count;
    if($count <=0){
        $count = 1;
    }else{
        $count ++;
    }
    if($count >1000)return '';
    $new_childid_arr = [];
    $tmp_info = $all_node_info[$nodeid];
    if($tmp_info['nodetype'] == 'approver'){
        $new_childid_arr[] = $nodeid;
    }else{
        $childid = $tmp_info['childid'];
        if(!empty($childid)){
            $childid_arr = explode(',',$childid);
            foreach ($childid_arr as $tmp_id){
                $tmp_arr = getlastchildstep($tmp_id,$all_node_info);
                $new_childid_arr = array_merge($new_childid_arr,$tmp_arr);
            }
        }
    }
    return $new_childid_arr;
}

?>