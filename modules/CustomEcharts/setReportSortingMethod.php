<?php
global $adb,$current_user;
if(!isset($adb))
{
    $adb = PearDatabase::getInstance();
}
$_REQUEST['diony'] = 'yes';
$report_id = $_REQUEST['report_id'];
//$mode = $_REQUEST['mode'];
//if($mode=="save"){
//    //保存
//    ConvertTojsonString(1,[],'success');die;
//}
//排序设置
$sorting_list = [];
$sorting_list_groupby = [];
//字段数据 ld_customreport_total_column
$columns_list = [];
$columns_sql = "select report_id,total_type,columns,chart_column_name,column_module from ld_customreport_total_column where report_id=?";
$columns_res = $adb->pquery($columns_sql,array($report_id));
$columns_nums = $adb->num_rows($columns_res);
$columns_arr = [];
$row=0;
if($columns_nums>=1) {
    for ($j = 0; $j < $columns_nums; $j++) {
        $total_type = $adb->query_result($columns_res,$j,'total_type');//统计方式
        $column_module = $adb->query_result($columns_res,$j,'column_module');//字段所属模块
        $columns_tmp = $adb->query_result($columns_res, $j, 'columns');
        $columns_tmp_arr = explode(':',$columns_tmp);
        $columns_tmp_str = $columns_tmp_arr[3];
        $columns_tmp_arr = explode('_',$columns_tmp_str);
        $chart_column_name = $adb->query_result($columns_res, $j, 'chart_column_name');//图表系列显示名称
        $columnmodule_columns_tmp = $columns_tmp.'-'.$total_type;
        $total_type_labelbol = '';//统计方式中文名称
        switch ($total_type){
            case 'count' : $total_type_labelbol = '计数';break;
            case 'distinct_count' : $total_type_labelbol = '唯一计数';break;
            case 'sum' : $total_type_labelbol = '求和';break;
            case 'avg' : $total_type_labelbol = '求均值';break;
            case 'max' : $total_type_labelbol = '最大值';break;
            case 'min' : $total_type_labelbol = '最小值';break;
        }

        $columns_list[$row]['report_id'] = $report_id;//报表ID
        $columns_list[$row]['sorttype'] = 'byresult';//按统计结果排序
        //如果显示名称为空 则显示字段名称
        if(empty($chart_column_name)){
            $columns_list[$row]['tdheader_label'] = $columns_tmp_arr[1].'-'.$total_type_labelbol;//字段名-统计方式
        }else{
            $columns_list[$row]['tdheader_label'] = $chart_column_name;//图表系列显示名称
        }
        $columns_list[$row]['columns'] = $columnmodule_columns_tmp;
        $columns_list[$row]['columnmodule'] = $column_module;
        $columns_list[$row]['total_type'] = $total_type;
        $columns_arr[] = $columns_tmp.'-'.$total_type;
        $row++;
    }

}
//分组数据
//删除不在分组数据中的排序数据
$group_sql = "select report_id,groupbytype,columns,sequence from ld_customreport_group where report_id=?";
$group_res = $adb->pquery($group_sql,array($report_id));
$group_nums = $adb->num_rows($group_res);
$groupcolumns = [];
if($group_nums>=1) {
    for ($i = 0; $i < $group_nums; $i++) {
        $columns_tmp = $adb->query_result($group_res, $i, 'columns');
        $groupbytype = $adb->query_result($group_res, $i, 'groupbytype');
        $columns_tmp_arr = explode(':',$columns_tmp);
        $columns_tmp_str = $columns_tmp_arr[3];
        $columns_tmp_arr = explode('_',$columns_tmp_str);

        $columns_list[$row]['report_id'] = $report_id;//报表ID
        $columns_list[$row]['sorttype'] = 'bycolumnname';//按字段列名排

        switch ($groupbytype){
            case 'byYear' : $total_type_labelbol = '-按年';break;
            case 'byQuarter' : $total_type_labelbol = '-按季度';break;
            case 'byMonth' : $total_type_labelbol = '-按月度';break;
            case 'byWeek' : $total_type_labelbol = '-按周';break;
            case 'byDay' : $total_type_labelbol = '-按天';break;
            case 'byField' : $total_type_labelbol = '';break;
        }
        $columns_list[$row]['tdheader_label'] = $columns_tmp_arr[1].$total_type_labelbol;//字段名-分组方式

        $columns_list[$row]['columns'] = $columns_tmp.'-'.$groupbytype;
        $groupcolumns[] = $columns_tmp.'-'.$groupbytype;
        $columns_list[$row]['columnmodule'] = "";
        $columns_list[$row]['total_type'] = $groupbytype;//分组方式  也存到这个字段吧


        $columnmodule_columns = $columns_tmp.'-'.$groupbytype;
        $sorting_list_groupby[$columnmodule_columns]['report_id'] = $report_id;
        $sorting_list_groupby[$columnmodule_columns]['sorttype'] = $groupbytype;
        $sorting_list_groupby[$columnmodule_columns]['columnmodule'] = $columnmodule_columns;
        $sorting_list_groupby[$columnmodule_columns]['columns'] = $columns_tmp;
        $sorting_list_groupby[$columnmodule_columns]['sortmethod'] = 'asc';
        $sorting_list_groupby[$columnmodule_columns]['sequence'] = $adb->query_result($group_res,$i,'sequence');
        $sorting_list_groupby[$columnmodule_columns]['is_default'] = 'yes';//是否默认
        $sorting_list_groupby[$columnmodule_columns]['columnmodule_columns'] = $columnmodule_columns;
        $row++;
    }
}
//排序设置信息
$select_sql = " select * from ld_customreport_sorting 
where report_id=? order by sequence asc ";
$select_res = $adb->pquery($select_sql,array($report_id));
$select_nums = $adb->num_rows($select_res);
if($select_nums>=1){
    for($i=0;$i<$select_nums;$i++){
        $sorttype = $adb->query_result($select_res,$i,'sorttype');
        $columnmodule = $adb->query_result($select_res,$i,'columnmodule');
        $columns = $adb->query_result($select_res,$i,'columns');
        $total_type = $adb->query_result($select_res,$i,'total_type');
        $total_type = empty($total_type)?'':'-'.$total_type;

        $columnmodule_columns = $columns.$total_type;


        if(!isset($sorting_list[$columnmodule_columns])){
            $sorting_list[$columnmodule_columns]['report_id'] = $adb->query_result($select_res,$i,'report_id');
            $sorting_list[$columnmodule_columns]['sorttype'] = $adb->query_result($select_res,$i,'sorttype');
            $sorting_list[$columnmodule_columns]['columnmodule'] = $columnmodule;
            $sorting_list[$columnmodule_columns]['columns'] = $columns;
            $sorting_list[$columnmodule_columns]['sortmethod'] = $adb->query_result($select_res,$i,'sortmethod');
            $sorting_list[$columnmodule_columns]['sequence'] = $adb->query_result($select_res,$i,'sequence');
            $sorting_list[$columnmodule_columns]['is_default'] = 'no';//是否默认
            $sorting_list[$columnmodule_columns]['columnmodule_columns'] = $columnmodule_columns;
        }
        if(isset($sorting_list[$columnmodule_columns])){
            $sorting_list[$columnmodule_columns]['sortmethod'] = $adb->query_result($select_res,$i,'sortmethod');
        }
    }
}
if(empty($sorting_list)){
    $sorting_list = $sorting_list_groupby;//排序设置为空的时候 才需要默认将分组字段设置为排序字段
}
ConvertTojsonString(1,[
    'sorting_list'=>array_values($sorting_list),
    'columns_list'=>$columns_list,
    'report_id'=>$report_id
],'success');die;

