<?php
//自定义统计图--增加表格显示功能
class cls_showTable
{
    public $html_start = '<div tag="ld_tableContent" class="ld-table-container ld-table-container-line ld-table-container-bgcolor">
<table tag="ld_table" border="0" cellspacing="0" cellpadding="0"class="fir-center" style="table-layout: fixed">';
    public $html_header = '';//表头
    public $html = '';
    public $html_end = '</table></div>';
    public $th_nums = 0;
    public $colums = [];
    public $decimal_nums = 2;
    public $decimal_currency = 2;
    public $can_penetrate = 'no';//是否允许穿透
    public $chart_type = '';//统计图类型

    private $setRowTotal = 'no';//设置行合计 会生成一列数据
    private $RowTotalDataArr = [];

    private $setColumnTotal = 'no';//设置列合计  会生成一行数据 放在最后一行
    private $ColumnTotalDataArr = [];
    private $allTotal = 0;
    private $allTotalFormat = "0";

    private $tablehtml = '';
    private $noChuantouCompareSelectArr = ['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'];//同环比  环比增长值 环比增长率 同比增长值 同比增长率 这四个不穿透

    public function __construct($colums){
        $this->colums = $colums;
        $this->decimal_nums = getSys_deploy(49)['deploy_value'];
        $this->decimal_currency = getSys_deploy(351)['deploy_value'];
    }
    //设置行合计  列合计参数
    public function setTotalParams($setRowTotal,$setColumnTotal,$RowTotalDataArr,$ColumnTotalDataArr,$allTotal){
        $this->setRowTotal =$setRowTotal;
        $this->setColumnTotal =$setColumnTotal;
        $this->RowTotalDataArr =$RowTotalDataArr;
        $this->ColumnTotalDataArr =$ColumnTotalDataArr;
        $this->allTotal =$allTotal;
    }
    //设置是否穿透
    public function setCanPenetrate($can_penetrate){
        $this->can_penetrate = $can_penetrate;
    }
    //设置统计图类型
    public function setChartType($chart_type){
        $this->chart_type = $chart_type;
    }
    //表头
    public function setHeader($group){
        //表头
        $this->html_header .= '<thead>
                    <tr><th class="locking-left shadow-left" align="right" thindex="-1" style="width:145px !important;"><span title="数据列" class="field-name">数据列</span></th>';
        foreach($group as $thindex=>$th){
            $this->html_header .= '<th width="145" align="right" thindex="'.$thindex.'">'.$th.'</th>';
        }
        //显示行合计  列头多一个
        if($this->setRowTotal=='yes'&&is_array($this->RowTotalDataArr)&&sizeof($this->RowTotalDataArr)>0){
            $this->html_header .= '<th class="locking-right shadow-right" width="145" align="right" thindex="'.($thindex+1).'">'.getFixedLabel('RowTotal').'</th>';//设置行合计
        }
        $this->html_header .= '</tr></thead>';
    }
    //表体 一个统计维度 一个或多个统计字段
    public function showContentTable($series){
        //一行
        foreach($series as $index=>$seriesline){
            $trclass = '';
            if($index%2==0){
                $trclass = 'lvtColData';
            }else{
                $trclass = 'lvtColDataBj';
            }
            $data = $seriesline['data'];
            if($seriesline['name']==getFixedLabel('ColumnTotal')){
                continue;
            }
            $this->html .= '<tr class="'.$trclass.'" rowindex="'.$index.'">';
            $this->html .= '<td class="locking-left shadow-left listHead" align="right" tdindex="-1">'.$seriesline['name'].'</td>';

            $this->th_nums = is_array($seriesline['data'])?count($seriesline['data'])+1:1;
            $column_info = $this->colums[$index];
            //一列
            foreach($data as $dk=>$d) {
                $d = $this->setFormatDataByType($d,$column_info);
                if ($this->can_penetrate == 'yes'&&!in_array($column_info['compare_select'],$this->noChuantouCompareSelectArr)) {
                    $d = '<a target="_blank" tag="gotoList" >' . $d . '</a>';
                }
                $this->html .= '<td align="right" tdindex="' . $dk . '">' . $d . '</td>';
            }

            if($this->setRowTotal=='yes'&&is_array($this->RowTotalDataArr)&&sizeof($this->RowTotalDataArr)>0){
                $tmprowtotal = $this->setFormatDataByType($this->RowTotalDataArr[$index],$column_info);
                $this->html .= '<td class="locking-right shadow-right">'.$tmprowtotal.'</td>';
            }
            $this->html .= '</tr>';
        }
        $this->allTotalFormat = $this->setFormatDataByType($this->allTotal,$column_info);
        $this->showColumnTotalLine($index+1,$column_info);
        $this->tablehtml = $this->html_start . $this->html_header . $this->html . $this->html_end;
    }
    //表体--两个统计维度
    public function showContentTableTwoGroup($series){
        $column_info = $this->colums[0];

        foreach($series as $index=>$seriesline){
            $trclass = '';
            if($index%2==0){
                $trclass = 'lvtColData';
            }else{
                $trclass = 'lvtColDataBj';
            }
            $data = $seriesline['data'];
            if($seriesline['name']==getFixedLabel('ColumnTotal')){
                continue;
            }
            $this->html .= '<tr class="'.$trclass.'" rowindex="'.$index.'">';
            $this->html .= '<td  class="locking-left shadow-left listHead" align="right" tdindex="-1">'.$seriesline['name'].'</td>';

            $this->th_nums = is_array($seriesline['data'])?count($seriesline['data'])+1:1;

            foreach($data as $dk=>$d) {
                $d = $this->setFormatDataByType($d,$column_info);
                if ($this->can_penetrate == 'yes'&&!in_array($column_info['compare_select'],$this->noChuantouCompareSelectArr)) {
                    $d = '<a target="_blank" tag="gotoList" >' . $d . '</a>';
                }
                $this->html .= '<td align="right" tdindex="' . $dk . '">' . $d . '</td>';
            }
            if($this->setRowTotal=='yes'&&is_array($this->RowTotalDataArr)&&sizeof($this->RowTotalDataArr)>0){
                $tmprowtotal = $this->setFormatDataByType($this->RowTotalDataArr[$index],$column_info);
                $this->html .= '<td class="locking-right shadow-right">'.$tmprowtotal.'</td>';
            }
            $this->html .= '</tr>';

        }
        $this->allTotalFormat = $this->setFormatDataByType($this->allTotal,$column_info);
        $this->showColumnTotalLine($index+1,$column_info);
        $this->tablehtml = $this->html_start . $this->html_header . $this->html . $this->html_end;
    }

    //嵌套饼图的表体-两个统计维度  一个统计字段 -没有列合计  只有行合计  返回2个表格
    public function showContentTableNestingPie($series,$groupbyinfo){
        $column_info = $this->colums[0];
        $this->html = '';
        foreach($series as $index=>$seriesline){
            $this->html .= '<div tag="ld_tableContent" class="marB10 ld-table-container ld-table-container-line ld-table-container-bgcolor">';
            $trclass = '';
            if($index%2==0){
                $trclass = 'lvtColData';
            }else{
                $trclass = 'lvtColDataBj';
            }
            $data = $seriesline['data'];

            $this->th_nums = count($seriesline['data'])+1;

            $groupby = $groupbyinfo[$index];

            $this->html .= '<table tag="ld_table" border="0" cellspacing="0" cellpadding="0"class="fir-center" style="table-layout: fixed">';
            $this->html .= '<thead><tr class="' . $trclass . '" rowindex="' . $index . '">';
            $this->html .= '<th class="locking-left shadow-left" width="145" style="width:145px !important;" align="right" tdindex="-1">'.$groupby['groupbyname'].'</th>';
            foreach($data as $dk=>$d1) {
                //表头
                $name = $d1['name'];
                $this->html .= '<th align="right" width="145" thindex="' . $index . '_'.$dk.'">' . $name . '</th>';
            }
            if($this->setRowTotal=='yes'&&is_array($this->RowTotalDataArr)&&sizeof($this->RowTotalDataArr)>0){
                $this->html .= '<th class="locking-right shadow-right" width="145" align="right" thindex="'.($dk+1).'">'.getFixedLabel('RowTotal').'</th>';//设置行合计
            }
            $this->html .= '</tr></thead>';
            //表体
            $this->html .= '<tbody><tr class="'.$trclass.'" rowindex="'.$index.'">';
            $this->html .= '<td class="locking-left shadow-left listHead" align="right" tdindex="-1">'.$seriesline['name'].'</td>';
            foreach($data as $dk2=>$d2) {
                $d = $d2['value'];
                $d = $this->setFormatDataByType($d,$column_info);
                if ($this->can_penetrate == 'yes'&&!in_array($column_info['compare_select'],$this->noChuantouCompareSelectArr)) {
                    $d = '<a target="_blank" data-XAxisName="'.$d2['name'].'" seriesIndex="'.$index.'" tag="gotoList" >' . $d . '</a>';
                }
                $this->html .= '<td align="right" tdindex="' . $index . '_'.$dk2.'">' . $d . '</td>';
            }
            if($this->setRowTotal=='yes'&&is_array($this->RowTotalDataArr)&&sizeof($this->RowTotalDataArr)>0){
                $tmprowtotal = $this->setFormatDataByType($this->RowTotalDataArr[$index],$column_info);
                $this->html .= '<td class="locking-right shadow-right">'.$tmprowtotal.'</td>';
            }
            $this->html .= '</tr></tbody>';
            $this->html .= '</table>';
            $this->html .= '</div>';
        }
        $this->tablehtml = $this->html;
    }
    //散点图的表体
    public function showContentTable_scatter($scatt_arr){
        //多维度散点图
        if($this->chart_type=='multiple_dimension'){
            $groupname1 = array_keys($scatt_arr);//第一位维度的值
            $groupname1count = count($groupname1);

            $groupname2 = [];//第一位维度的值
            foreach ($scatt_arr as $group1 => $line) {
                $line_key = array_keys($line);
                $groupname2 = array_merge($groupname2, $line_key);
                $groupname2 = array_unique($groupname2);
            }
            $groupname2count = count($groupname2);
            foreach($this->colums as $columkey=>$columnone) {
                if($columkey!=0){
                    $this->html .= '<tr><td colspan="'.($groupname1count+1).'"></td></tr>';
                }

                $this->html .= '<tr><td class="listHead"></td><td class="listHead" align="center" style="text-align: center;" colspan="'.($groupname1count).'">'.$columnone['chart_column_name'].'</td></tr>';
                //表头
                $this->html .= '
                        <tr><td class="listHead" align="right" style="left:0;"><span title="数据列" class="can-sortable field-name">数据列</span></td>';
                foreach ($groupname1 as $g1) {
                    $this->html .= '<td class="listHead" align="right" thindex="">' . $g1 . '</td>';
                }
                $this->html .= '</tr>';

                foreach ($groupname2 as $k2 => $g2) {
                    $trclass = '';
                    if ($k2 % 2 == 0) {
                        $trclass = 'lvtColData';
                    } else {
                        $trclass = 'lvtColDataBj';
                    }
                    $this->html .= '<tr class="' . $trclass . '" rowindex="' . $k2 . '">';
                    $this->html .= '<td class="listHead" align="right" tdindex="'.$k2.'">' . $g2 . '</td>';
                    foreach ($groupname1 as $name1) {

                        if (isset($scatt_arr[$name1][$g2])) {
                            $v = $scatt_arr[$name1][$g2];
                            $d = $v[$columkey];
                            $d = $this->setFormatDataByType($d,$columnone);
                            $this->html .= '<td align="right" tdindex="'.$k2.'">' . $d . '</td>';

                        } else {
                            $this->html .= '<td align="right" tdindex="'.$k2.'"></td>';
                        }
                    }
                    $this->html .= '</tr>';
                }

                $this->html_start .= '<tbody>';
            }
        }
        $this->tablehtml = $this->html_start . $this->html_header . $this->html . $this->html_end;
    }

    public function getTableHtml(){
        return $this->tablehtml;
    }
    public function getAllTotalFormat(){
        return $this->allTotalFormat;
    }
    //设置了列合计 但是没设置列数据显示在图上 需要循环列合计数组 生成最后一行数据  小数位数 根据最后一个统计字段的统计方式来  计数小数为0 求和类为2等判断
    public function showColumnTotalLine($index,$endcolumninfo){
        $trclass = '';
        if($index%2==0){
            $trclass = 'lvtColDataBj';
        }else{
            $trclass = 'lvtColData';
        }
        if($this->setColumnTotal=='yes'){
            $this->html .= '<tr class="'.$trclass.'" rowindex="'.($index).'">';
            $this->html .= '<td class="locking-left shadow-left listHead" align="right" tdindex="-1">'.getFixedLabel('ColumnTotal').'</td>';
            foreach($this->ColumnTotalDataArr as $columtotal_k=>$columtotal_d) {
                $columtotal_d = $this->setFormatDataByType($columtotal_d,$endcolumninfo);
                $this->html .= '<td align="right" tdindex="' . $columtotal_k . '">' . $columtotal_d . '</td>';
            }
            //行列都设合计  则最后一个格子显示总合计
            if($this->setRowTotal=='yes'){
                $this->html .= '<td class="locking-right shadow-right" align="right" tdindex="' . ($columtotal_k+1) . '">' . $this->allTotalFormat . '</td>';
            }
            $this->html .= '</tr>';
        }
    }
    //根据统计字段的统计方式 字段bigtype fieldtype格式化数据
    public function setFormatDataByType($d,$column_info){
        $bigtype = $column_info['bigtype'];//bigtype 自定义统计图
        $compare_select = $column_info['compare_select'];//同环比选项
        $typeofdata_decimal = $column_info['typeofdata_decimal'];//typeofdata_decimal
        $total_type = $column_info['total_type'];//total_type
        $fieldtype = $column_info['fieldtype'] ?? '';//fieldtype sql统计图

        //-- 自定义统计图
        if (in_array($this->chart_type, ['funnel', 'triangle', 'bowls'])) {
            $d = empty($d['num_value']) ? 0 : $d['num_value'];
        }else if(is_array($d)){
            $d = $d['value'];
        }
        //设置币种符号和千分位以及小数点--SQL统计图
        if ($fieldtype == 'currency') {
            $d = setNumberFormat($d, $this->decimal_currency);
            $d = '￥' . $d;
        }
        if ($fieldtype == 'number') {
            $d = setNumberFormat($d, $typeofdata_decimal);
        }
        if ($fieldtype == 'percent') {
            $d = setNumberFormat($d, $typeofdata_decimal);
            $d = $d . '%';
        }


        if (in_array($total_type, ['count', 'distinct_count'])) {
            //zxm @date:2024/12/4 @reason: 同比增长率  环比增长率 不要币种符号 要百分号符号
            if($compare_select=='prev_growth_percent'||$compare_select=='prev_growth_percent_lastyear'){
                $d =  setNumberFormat($d, 2).'%';
            }else{
                $d = setNumberFormat($d, 0);
            }
        }
        //设置币种符号和千分位以及小数点 -- 自定义统计图
        if (($bigtype == 'currency'||$bigtype=='amount')&& in_array($total_type, ['sum', 'max', 'min', 'avg'])) {
            if(empty($typeofdata_decimal)){
                $typeofdata_decimal = $this->decimal_currency;
            }
            $d = setNumberFormat($d, $typeofdata_decimal);
            //zxm @date:2024/12/4 @reason: 同比增长率  环比增长率 不要币种符号 要百分号符号
            if($compare_select=='prev_growth_percent'||$compare_select=='prev_growth_percent_lastyear'){
                $d =  $d.'%';
            }else{
                $d = '￥' . $d;
            }
        }
        return $d;
    }
}