<?php

/**
 * @Author  XLL
 * @date  2023/10/06
 * @Description  报统计图设置信息类，用于统计图、SQL统计图新增编辑页面
 */
class cls_ChartSetInfo
{
    protected static $_instance;
    protected $ChartSetInfo;
    protected $report_id;
    protected $chart_type;
    protected $show_percent;

    protected $show_toolbox;
    protected $show_rowtotal;
    protected $show_columntotal;
    protected $show_columntotal_inchart;
    protected $show_alltotal_inchart;


    protected $can_penetrate;
    protected $yaxis_right_name;
 
 
    protected $report_name;
    protected $analysisfolder_id;
    protected $report_desc;
    protected $limit;
    protected $linkmodulecheck;
    protected $show_athome;
    protected $AxisFields;
    protected $OtherCondition;
    protected $ThemeSet;
    protected $TitleSwitch;
    protected $AlignSet;
    protected $LegendLocate;
    protected $LegendOrient;
    protected $LegendType;
    protected $xaxis_bottom_name;
    protected $xaxis_top_name;
    protected $xaxis_name_rotate;
    protected $yaxis_left_name;
    protected $ReportStyle;
    protected $mainmodule;
    protected $SeqSet;
    protected $YAxisLabelPosition;
    protected $SeriesDataLabel;
    protected $DataLabelIsRotate;
    protected $mode;
 



    public function __construct(){

    }

    public static function getInstance($report_id,$report_type){
        $className = 'cls_ChartSetInfo';
        if($report_type && $report_type === 'sqlchart')
            $className = 'cls_SqlChartSetInfo';
        if(!is_array(self::$_instance) || !array_key_exists($report_id,self::$_instance) || !
            (self::$_instance[$report_id] instanceof self)) {
            self::$_instance[$report_id] = new $className();
        }
        return self::$_instance[$report_id];
    }

    public function getChartSetInfo(){
        if(!isset($this->ChartSetInfo) && empty($this->ChartSetInfo))
            $this->ChartSetInfo = [
            'report_id' => $this->report_id,
            'report_name' => $this->report_name,
            'analysisfolder_id' => $this->analysisfolder_id,
            'report_desc' => $this->report_desc,
            'chart_type' => $this->chart_type,
            'limit' => $this->limit,
            'linkmodulecheck' => $this->linkmodulecheck,
            'show_athome' => $this->show_athome,

            'show_toolbox' => $this->show_toolbox,

            'show_rowtotal' => $this->show_rowtotal,
            'show_columntotal' => $this->show_columntotal,
            'show_columntotal_inchart' => $this->show_columntotal_inchart,
            'show_alltotal_inchart' => $this->show_alltotal_inchart,

            'show_percent' => $this->show_percent,
            'can_penetrate' => $this->can_penetrate,
            'AxisFields' => $this->AxisFields,
            'OtherCondition' => $this->OtherCondition,
            'ThemeSet' => $this->ThemeSet,
            'TitleSwitch' => $this->TitleSwitch,
            'AlignSet' => $this->AlignSet,
            'LegendLocate' => $this->LegendLocate,
            'LegendOrient' => $this->LegendOrient,
            'LegendType' => $this->LegendType,
            'xaxis_bottom_name' => $this->xaxis_bottom_name,
            'xaxis_top_name' => $this->xaxis_top_name,
            'xaxis_name_rotate' => $this->xaxis_name_rotate,
            'yaxis_left_name' => $this->yaxis_left_name,
            'yaxis_right_name' => $this->yaxis_right_name,
            'ReportStyle' => $this->ReportStyle,
            'mainmodule' => $this->mainmodule,
            'SeqSet' => $this->SeqSet,
            'YAxisLabelPosition' => $this->YAxisLabelPosition,
            'SeriesDataLabel' => $this->SeriesDataLabel,
            'DataLabelIsRotate' => $this->DataLabelIsRotate,
            'mode' => $this->mode,
        ];
        $this->ChartSetInfo['chuantouParamsName'] = [
            "XAxisName"=> "name",
            "SeriesName"=> "seriesName",
            "SeriesIndex"=> "seriesIndex"
        ];
        return $this->ChartSetInfo;
    }

    public function setChartInfo($chartInfo) {
        $this->set_report_id($chartInfo['report_id']);
        $this->set_report_name($chartInfo['report_name']);
        $this->set_FolderOptions($chartInfo['analysisfolder_id']);
        $this->set_report_desc($chartInfo['report_desc']);
        $this->set_chart_type($chartInfo['chart_type']);
        $this->set_limit($chartInfo['limit']);
        $this->set_linkmodulecheck($chartInfo['linkmodulecheck']);

        $this->set_show_athome($chartInfo['show_athome']);

        $this->set_show_toolbox($chartInfo['show_toolbox']);

        $this->set_show_rowtotal($chartInfo['show_rowtotal']);
        $this->set_show_columntotal($chartInfo['show_columntotal']);
        $this->set_show_columntotal_inchart($chartInfo['show_columntotal_inchart']);
        $this->set_show_alltotal_inchart($chartInfo['show_alltotal_inchart']);

        $this->set_show_percent($chartInfo['show_percent']);
        $this->set_can_penetrate($chartInfo['can_penetrate']);
        $this->set_AxisFields($chartInfo['groupInfo'],$chartInfo['totalColumns']);

        $this->set_OtherCondition($chartInfo['mainmodule'],$chartInfo['advance_demand'],$chartInfo['advance_demand_groups']);
        $this->set_ThemeSet($chartInfo['themename']);
        $this->set_TitleSwitch($chartInfo['title']['show']);
        $this->set_AlignSet($chartInfo['title']);
        $this->set_LegendLocate($chartInfo['legend_position']);
        $this->set_LegendOrient($chartInfo['legend']['orient']);
        $this->set_LegendType($chartInfo['legend']['type']);
        $this->set_xaxis_bottom_name($chartInfo['xaxis'][0]['name']);
        $this->set_xaxis_top_name($chartInfo['xaxis'][1]['name']);
        $this->set_xaxis_name_rotate($chartInfo['xaxis'][0]['axisLabel']['rotate']);
        $this->set_yaxis_left_name($chartInfo['yaxis'][0]['name']);
        $this->set_yaxis_right_name($chartInfo['yaxis'][1]['name']);
        $this->set_ReportStyle($chartInfo['isshow_table']);
        $this->set_MainModule($chartInfo['mainmodule']);
        $this->set_SeqSet($chartInfo['SeqSet']);
        $this->set_YAxisLabelPosition($chartInfo);
        $this->set_series_datalabel($chartInfo['series_datalabel']);
        $this->set_mode($chartInfo['mode']);
    }
    public  function set_YAxisLabelPosition($chartInfo){
        if(in_array($chartInfo['chart_type'],['simple_strip','multiple_strip','stack_strip'])){
            $this->YAxisLabelPosition = $chartInfo['yaxis'][0]['axisLabel']['inside']===true?'inside':'outside';
        }
    }
    public function set_series_datalabel($series_datalabel){
        if(empty($series_datalabel)){
            $series_datalabel = [];
        }else{
            $series_datalabel = Zend_Json::decode($series_datalabel);            
        }
        $this->SeriesDataLabel = $series_datalabel['show']===true?$series_datalabel['position']:'none';
        $this->DataLabelIsRotate = $series_datalabel['show']===true&&$series_datalabel['rotate']==90?'yes':'no';
    }
    public function set_report_id($report_id){
        $this->report_id = $report_id;
    }
    public function set_report_name($report_name){
        $this->report_name = $report_name;
    }
    public function set_FolderOptions($FolderOptions){
        $this->analysisfolder_id = $FolderOptions;
    }
    public function set_report_desc($report_desc){
        $this->report_desc = $report_desc;
    }
    public function set_chart_type($chart_type){
        $this->chart_type = $chart_type;
    }
    public function set_limit($limit){
        $this->limit = $limit;
    }
    public function set_linkmodulecheck($linkmodulecheck){
        $this->linkmodulecheck = $linkmodulecheck;
    }
    public function set_show_athome($show_athome){
        $this->show_athome = $show_athome;
    }
    public function set_show_toolbox($show_toolbox){
        $this->show_toolbox = $show_toolbox;
    }
    public function set_show_rowtotal($show_rowtotal){
        $this->show_rowtotal = $show_rowtotal;
    }
    public function set_show_columntotal($show_columntotal){
        $this->show_columntotal = $show_columntotal;
    }
    public function set_show_columntotal_inchart($show_columntotal_inchart){
        $this->show_columntotal_inchart = $show_columntotal_inchart;
    }
    public function set_show_alltotal_inchart($show_alltotal_inchart){
        $this->show_alltotal_inchart = $show_alltotal_inchart;
    }
    public function set_show_percent($show_percent){
        $this->show_percent = $show_percent;
    }
    public function set_can_penetrate($can_penetrate){
        $this->can_penetrate = $can_penetrate;
    }
    public function set_AxisFields($XAxis,$YAxis){
        $this->AxisFields = [
            'XAxis' => $XAxis,
            'YAxis' => $YAxis,
        ];
    }
    public function set_OtherCondition($computemodule,$advance_demand,$advance_demand_groups){
        crm_load_class_file('CommonView',"modules/CustomView");
        $datetimestr=CommonView::stdFilterDateTimeStr();//获取日期，时间本年，明年等下拉框字符串
        if(!empty($advance_demand)) {
            $advance_demand_arr = Zend_Json::decode($advance_demand, true);
            foreach ($advance_demand_arr as $k=>&$tmp_advance_demand_line) {
                if (!empty($tmp_advance_demand_line)) {
                    $tmpcolumnname = $tmp_advance_demand_line['columnname'];
                    $tmpcolumnname_arr = explode(':', $tmpcolumnname);
                    $tmpmodulefieldlabel = $tmpcolumnname_arr[3];
                    $tmpmodulefieldlabel_arr = explode('_',$tmpmodulefieldlabel);
                    $tmpmodulefieldlabel_arr[1] = 'fieldlabel';
                    $tmpcolumnname_arr[3] = implode('_',$tmpmodulefieldlabel_arr);
                    $tmp_advance_demand_line['columnname'] = implode(':', $tmpcolumnname_arr);
                    //如果是时间字段 需要将value重新解析一下
                    if($tmpcolumnname_arr[4]=='D'||$tmpcolumnname_arr[4]=='DT'){
                        if(array_key_exists($tmp_advance_demand_line['comparator'],$datetimestr))
                        {
                            $temp_val = $tmp_advance_demand_line['value'];
                            //如果是本年明年，n天后等
                            if($tmpcolumnname_arr[4]=='DT'){
                                $temp_date_val = [];
                                $temp_date_val[0]=$datetimestr[$tmp_advance_demand_line['comparator']][0].' 00:00:00';
                                $temp_date_val[1]=$datetimestr[$tmp_advance_demand_line['comparator']][1].' 23:59:59';
                                $temp_val = implode(',',$temp_date_val);
                            }
                            if($tmpcolumnname_arr[4]=='D'){
                                $temp_date_val = [];
                                $temp_date_val[0]=$datetimestr[$tmp_advance_demand_line['comparator']][0];
                                $temp_date_val[1]=$datetimestr[$tmp_advance_demand_line['comparator']][1];
                                $temp_val = implode(',',$temp_date_val);
                            }
                            $tmp_advance_demand_line['value'] = $temp_val;
                        }
                    }
                }
            }
            $advance_demand = html_entity_decode(Zend_Json::encode($advance_demand_arr));
        }
        $this->OtherCondition = [
            'computemodule' => $computemodule,
            'advance_demand' => $advance_demand,
            'advance_demand_groups' => $advance_demand_groups,
        ];
    }
    public function set_ThemeSet($ThemeSet){
        $this->ThemeSet = $ThemeSet;
    }
    public function set_TitleSwitch($TitleSwitch){
        $this->TitleSwitch = $TitleSwitch;
    }
    public function set_AlignSet($title){
        $AlignSet = '';
        if(isset($title['left'])){
            if($title['left'] == '10%')
                $AlignSet = 'AlignLeft';
            else
                $AlignSet = 'AlignCenter';
        } else {
            $AlignSet = 'AlignRight';
        }
        $this->AlignSet = $AlignSet;
    }
    public function set_LegendLocate($LegendLocate){
        $this->LegendLocate = $LegendLocate;
    }
    public function set_LegendOrient($LegendOrient){
        $this->LegendOrient = $LegendOrient;
    }
    public function set_LegendType($LegendType){
        $this->LegendType = $LegendType;
    }
    public function set_xaxis_bottom_name($xaxis_bottom_name){
        $this->xaxis_bottom_name = $xaxis_bottom_name;
    }
    public function set_xaxis_top_name($xaxis_top_name){
        $this->xaxis_top_name = $xaxis_top_name;
    }
    public function set_xaxis_name_rotate($xaxis_name_rotate){
        $this->xaxis_name_rotate = $xaxis_name_rotate;
    }
    public function set_yaxis_left_name($yaxis_left_name){
        $this->yaxis_left_name = $yaxis_left_name;
    }
    public function set_yaxis_right_name($yaxis_right_name){
        $this->yaxis_right_name = $yaxis_right_name;
    }
    public function set_ReportStyle($ReportStyle){
        $this->ReportStyle = $ReportStyle;
    }
    public function set_MainModule($MainModule){
        $this->mainmodule = $MainModule;
    }
    public function set_SeqSet($SeqSet){
        $this->SeqSet = $SeqSet;
    }
    public function set_mode($mode) {
        $this->mode = empty($mode) ? 'edit' : 'create';
    }
}

?>