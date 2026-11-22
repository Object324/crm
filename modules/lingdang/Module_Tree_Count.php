<?php
global $adb;
global $current_user;

$frommodule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($frommodule);
$customView = CustomView::getInstance($frommodule);

$cls_MyCRMcryptobj=new cls_MyCRMcrypt();;
$cls_MyCRMcryptobj->decode($_REQUEST['treewhere']);

$_REQUEST['diony']='yes';
$page_list_query=$cls_MyCRMcryptobj->decode($_REQUEST['treewhere']);
//dump($page_list_query);
if($frommodule == 'Users'){// ljj 20230908 BUG0072408 成员管理，灵当集团的记录条数和右侧列表显示的数量不一致
    $arr=[];
    $all_parentid = [];
    //duan 20231204 BUG0076571 用户管理数结构数量读取太慢 ,重复执行的sql太多,优化处理
    $groupinfo_sql = 'select groupid,parentid from ld_groups order by groupid';
    $groupinfo_result = $adb->pquery($groupinfo_sql,[]);
    $group_num_rows  =  $adb->num_rows($groupinfo_result);
    if($group_num_rows>0){
        for($i=0;$i<$group_num_rows;$i++){
            $groupid=$adb->query_result($groupinfo_result,$i,'groupid');
            $parentid=$adb->query_result($groupinfo_result,$i,'parentid');
            $all_parentid[$groupid] = $parentid;
        }
    }

    $sql='select ld_users2group.userid,count(ld_users2group.groupid) as groupcount,group_concat(ld_users2group.groupid) as groupstr from ld_users2group inner join ('.$page_list_query.') as tmp on tmp.id=ld_users2group.userid   GROUP BY userid ';
    $result=$adb->pquery($sql);
    $num_rows = $adb->num_rows($result);
    if ($num_rows>0){
        for ($i=0;$i<$num_rows;$i++){
            $groupcount = $adb->query_result($result,$i,'groupcount');
            $groupstr  =  $adb->query_result($result,$i,'groupstr');
            if ($groupcount ==1){
                //$groupidsql='select groupid  from ld_users2group where userid=?';
                //$groupidresult=$adb->pquery($groupidsql,array($adb->query_result($result,$i,'userid')));
                //if ($adb->num_rows($groupidresult)>0){
                if(!empty($groupstr)){
                    $groupid=$groupstr;
                    $arr[$groupid]=['totalcount' => $arr[$groupid]['totalcount']+1];
                    //$parentid= getUsersParent($groupid);
                    $parentid= $all_parentid[$groupid];
                    while($parentid!= -1){
                        $arr[$parentid]=['totalcount' => $arr[$parentid]['totalcount']+1];
                        //$parentid=getUsersParent($parentid);
                        if(isset($all_parentid[$parentid])){
                            $parentid= $all_parentid[$parentid];
                        }else{
                            $parentid= -1;
                        }
                    }

                }

            }
            else{
                $grouparr=[];
                //$groupidsql='select ld_users2group.groupid,ld_users2group.userid,ld_groups.parentid  from ld_users2group LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid where userid=?';
                //$groupidresult=$adb->pquery($groupidsql,array($adb->query_result($result,$i,'userid')));
                //if ($adb->num_rows($groupidresult)>0){
                if (!empty($groupstr)){
                    $tmp_groupid_arr = explode(',',$groupstr);
                    $tmp_count = sizeof($tmp_groupid_arr);
                    for ($j=0;$j<$tmp_count;$j++){
                        //$groupid=$adb->query_result($groupidresult,$j,'groupid');
                        //$tmpparentid=$adb->query_result($groupidresult,$j,'parentid');
                        $groupid = $tmp_groupid_arr[$j];
                        $tmpparentid= $all_parentid[$groupid];
                        if (!in_array($groupid,$grouparr)){
                            $arr[$groupid]=['totalcount' => $arr[$groupid]['totalcount']+1];
                            $grouparr[] = $groupid;
                        }
                        while (!in_array($tmpparentid,$grouparr) && $tmpparentid !=-1) {
                            $arr[$tmpparentid]=['totalcount' => $arr[$tmpparentid]['totalcount']+1];
                            $grouparr[] = $tmpparentid;
                            //$tmpparentid = getUsersParent($tmpparentid);
                            if(isset($all_parentid[$tmpparentid])){
                                $tmpparentid= $all_parentid[$tmpparentid];
                            }else{
                                $tmpparentid= -1;
                            }
                        }
                    }
                }
            }
        }
    }
}
else {
    $query = "select * from (select ld_module_tree.fieldname,0 as 'sequence' from ld_module_tree
where ld_module_tree.module = ?
union 
select ld_module_tree_field.fieldname,sequence from ld_module_tree_field 
INNER JOIN ld_module_tree on ld_module_tree_field.tree_id=ld_module_tree.id and ld_module_tree.deleted=0
where ld_module_tree.module = ? and ld_module_tree_field.deleted=0
 ) as tmp order by sequence asc  ";
    $result = $adb->pquery($query, array($frommodule, $frommodule));
    $rows = $adb->num_rows($result);
    $tableindex = $focus->table_index;
    $maintablename = $focus->table_name;
    $tablescfname = $focus->customFieldTable[0];
    $tablescfindex = $focus->customFieldTable[1];
    $arr_group = [];
    $sql_arr = [];
    $tables_arr = [];
    $picklisstcolumn_arr = [];
    for ($i = 0; $i < $rows; $i++) {
        $fieldname = $adb->query_result($result, $i, 'fieldname');
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
        if ($fieldinfo) {
            $arr_group[] = $fieldinfo->getTableName() . '.' . $fieldinfo->getColumnName();
            $tmptablename = $fieldinfo->getTableName();

            if (!in_array($tmptablename, $tables_arr))
                $tables_arr[] = $tmptablename;
            $tmptableindex = $focus->tab_name_index[$tmptablename];
            $picklisstcolumn_arr[] = $fieldinfo->getColumnName();
            if (sizeof($tables_arr) == 1)
                $sql_arr[] = 'select  ' . implode(',', $arr_group) . " ,count($tmptablename.$tmptableindex) as totalcount from " . $tmptablename
                    . ' inner join (' . $page_list_query . " ) as tmp  on tmp.$tableindex=" . $tmptablename . ".$tmptableindex  group by " . implode(',', $arr_group);
            else {
                $sql_arr[] = 'select  ' . implode(',', $arr_group) . " ,count($tmptablename.$tmptableindex) as totalcount from " . $maintablename
                    . ' inner join (' . $page_list_query . " ) as tmp  on tmp.$tableindex=" . $maintablename . ".$tableindex 
                  left join $tablescfname on $tablescfname.$tablescfindex=$maintablename.$tableindex  group by " . implode(',', $arr_group);
            }
        }

    }
//dump($sql_arr);
    $arr = [];
    foreach ($sql_arr as $index => $sql) {
        $result = $adb->pquery($sql, array());
        if ($adb->num_rows($result) > 0) {
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                $pickdepthvalue_arr = [];
                array_push($pickdepthvalue_arr, 0);
                for ($k = 0; $k <= $index; $k++) {
                    if ($adb->query_result($result, $i, $picklisstcolumn_arr[$k]) == '') {
                        $pickdepthvalue_arr[] = -1;
                    } else {
                        $pickdepthvalue_arr[] = $adb->query_result($result, $i, $picklisstcolumn_arr[$k]);
                    }
                }
                if (!in_array(-1, $pickdepthvalue_arr)) {
                    $arr[implode("^_^", $pickdepthvalue_arr)] = ['totalcount' => $adb->query_result($result, $i, 'totalcount')];
                }
            }
        } else {
            $arr [] = '';
        }
    }
}



ConvertTojsonString(1, $arr,'success');


function getUsersParent($groupid)
{
    global $adb;
    $parentsql = 'select parentid from ld_groups where groupid=?';
    $parentresult = $adb->pquery($parentsql, array($groupid));
    if ($adb->num_rows($parentresult) > 0) {
        $parentid=$adb->query_result($parentresult, 0, 'parentid');
    }
    else{
        $parentid=-1;
    }
    return $parentid;
}
?>