<?php
global $adb,$current_user;
if(!isset($adb))
{
    $adb = PearDatabase::getInstance();
}
$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony'] = 'yes';
$report_id = $_REQUEST['report_id'];
$mode = $_REQUEST['mode'];
$show_detail = $_REQUEST['show_detail'];

if($mode=="save"){
    //保存
    $sorttype = $_REQUEST['sorttype'];
    $columns = $_REQUEST['columns'];
    $sortmethod = $_REQUEST['sortmethod'];
    $deleted_sql = "delete from ld_customtable_sorting where report_id=?";
    $adb->pquery($deleted_sql,array($report_id));
    foreach($sorttype as $k=>$sorttype_value){
        if($k>0){
            $column_arr = explode('-',$columns[$k]);
            $columnmodule = $column_arr[0];
            $column = $column_arr[1];
            $total_type= $column_arr[2];
            $insert_sql = "insert into ld_customtable_sorting (report_id,sorttype,columnmodule,`columns`,sortmethod,`sequence`,total_type) values (?,?,?,?,?,?,?)";
            $adb->pquery($insert_sql,array($report_id,$sorttype_value,$columnmodule,$column,$sortmethod[$k],$k,$total_type));
        }
    }
    ConvertTojsonString(1,[],'success');die;
}


$sorting_list = [];


//字段数据 ld_customtable_columns
$columns_sql = "select report_id,tdheader_label,columns,columnmodule,total_type,is_group from ld_customtable_columns where report_id=?";
$columns_res = $adb->pquery($columns_sql,array($report_id));
$columns_nums = $adb->num_rows($columns_res);
$columns_list = [];

$row=0;
if($columns_nums>=1) {
    for ($j = 0; $j < $columns_nums; $j++) {
        //统计方式
        $is_group = $adb->query_result($columns_res,$j,'is_group');
        $total_type = $adb->query_result($columns_res,$j,'total_type');
        $total_type = trim($total_type,',');
        $columnmodule_tmp = $adb->query_result($columns_res, $j, 'columnmodule');
        $columns_tmp = $adb->query_result($columns_res, $j, 'columns');
        $columnmodule_columns_tmp = $columnmodule_tmp . '-' . $columns_tmp;

        $columns_list[$row]['report_id'] = $adb->query_result($columns_res, $j, 'report_id');
        $columns_list[$row]['tdheader_label'] = $adb->query_result($columns_res, $j, 'tdheader_label');
        $columns_list[$row]['columns'] = $columns_tmp;
        $columns_list[$row]['columnmodule'] = $columnmodule_tmp;
        $columns_list[$row]['sorttype'] = 'bycolumnname';
        $columns_list[$row]['columnmodule_columns'] = $columnmodule_columns_tmp;


        //设置了分组  默认的排序方式
        //设置了分组的情况下    排序设置将分组字段列好 不允许删除 只允许选择降序升序
        if($is_group=='yes'){
            if(!isset($sorting_list[$columnmodule_columns_tmp])){
                $sorting_list[$columnmodule_columns_tmp]['report_id'] = $adb->query_result($columns_res, $j, 'report_id');
                $sorting_list[$columnmodule_columns_tmp]['sorttype'] = 'bycolumnname';
                $sorting_list[$columnmodule_columns_tmp]['columnmodule'] = $columnmodule_tmp;
                $sorting_list[$columnmodule_columns_tmp]['columns'] = $columns_tmp;
                $sorting_list[$columnmodule_columns_tmp]['sortmethod'] = 'asc';//默认升序
                $sorting_list[$columnmodule_columns_tmp]['sequence'] = $row;//顺序
                $sorting_list[$columnmodule_columns_tmp]['columnmodule_columns'] = $columnmodule_columns_tmp;
            }
            $sorting_list[$columnmodule_columns_tmp]['is_default'] = 'yes';//是否默认

        }

        $row++;
        if($show_detail!='yes'&&!empty($total_type)){
            //不显示明细的情况下
            $total_type_arr = explode(',',$total_type);
            foreach ($total_type_arr as $t){
                //设置了统计方式的字段
                $columns_list[$row]['report_id'] = $adb->query_result($columns_res,$j,'report_id');
                $columns_list[$row]['tdheader_label'] = $adb->query_result($columns_res,$j,'tdheader_label');
                $columns_list[$row]['columns'] = $columns_tmp;
                $columns_list[$row]['columnmodule'] = $columnmodule_tmp;
                $columns_list[$row]['sorttype'] = 'byresult';
                $columns_list[$row]['columnmodule_columns'] = $columnmodule_tmp.'-'.$columns_tmp.'-'.$t;
                $labelbol = '';
                //count,distinct_count,sum,avg,max,min
                switch ($t){
                    case 'count' : $labelbol = '计数';break;
                    case 'distinct_count' : $labelbol = '唯一计数';break;
                    case 'sum' : $labelbol = '求和';break;
                    case 'avg' : $labelbol = '求均值';break;
                    case 'max' : $labelbol = '最大值';break;
                    case 'min' : $labelbol = '最小值';break;
                }
                $labelbol = empty($labelbol)?'':'-'.$labelbol;
                $columns_list[$row]['tdheader_label'] = $columns_list[$row]['tdheader_label'].$labelbol;
                $row++;
            }

        }
    }
}
//排序设置信息
$select_sql = " select a.* from ld_customtable_sorting a left  join ld_customtable_columns b  on a.report_id=b.report_id and a.`columns`=b.`columns` 
where b.`columns` is not null and a.report_id=? order by a.sequence asc ";
$select_res = $adb->pquery($select_sql,array($report_id));
$select_nums = $adb->num_rows($select_res);

if($select_nums>=1){
    for($i=0;$i<$select_nums;$i++){
        $columnmodule = $adb->query_result($select_res,$i,'columnmodule');
        $columns = $adb->query_result($select_res,$i,'columns');
        $total_type = $adb->query_result($select_res,$i,'total_type');
        $total_type = empty($total_type)?'':'-'.$total_type;
        $columnmodule_columns = $columnmodule.'-'.$columns.$total_type;

        $sorting_list[$columnmodule_columns]['report_id'] = $adb->query_result($select_res,$i,'report_id');
        $sorting_list[$columnmodule_columns]['sorttype'] = $adb->query_result($select_res,$i,'sorttype');
        $sorting_list[$columnmodule_columns]['columnmodule'] = $columnmodule;
        $sorting_list[$columnmodule_columns]['columns'] = $columns;
        $sorting_list[$columnmodule_columns]['sortmethod'] = $adb->query_result($select_res,$i,'sortmethod');
        $sorting_list[$columnmodule_columns]['sequence'] = $adb->query_result($select_res,$i,'sequence');
        $sorting_list[$columnmodule_columns]['is_default'] = 'no';//是否默认

        $sorting_list[$columnmodule_columns]['columnmodule_columns'] = $columnmodule_columns;
    }
}
$smarty->assign('sorting_list',$sorting_list);//排序设置数据
$smarty->assign('columns_list',$columns_list);//排序设置数据
$smarty->assign('report_id',$report_id);
$smarty->assign('show_detail',$show_detail);
//print_r($sorting_list);
//dump($columns_list);

$content = $smarty->fetch('CustomTables/setReportSortingMethod.tpl');
$res['content'] = $content;
$res['title'] = getFixedLabel('Setup').getFixedLabel('Reportsortingmethod');
ConvertTojsonString(1,$res,'success');die;

