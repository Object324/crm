<?php
//主要是图表的各项设置选项
class EchartSetting
{
    public $TitleAlignArr = [
        'AlignLeft' => 'left:10',
        'AlignRight' => 'right:10',
        'AlignCenter' => 'left:center',
    ];
    public $toolboxshow = 'yes';//显示工具栏
    public $boardstuffid;
    public $selectuid;
    public $search_date;
    public $approve_value;
    public $boardid;
    public $scopeType;
    public $params;
    public $adb, $language;
    public $smarty;
    public $current_user;

    protected $setRowTotal = 'no';//设置行合计 会生成一列数据
    protected $RowTotalDataArr = [];

    protected $setColumnTotal = 'no';//设置列合计  会生成一行数据 放在最后一行
    protected $ColumnTotalDataArr = [];
    protected $allTotal = 0;//总合计值
    protected $allTotalFormat = "0";//总合计值  格式化的
    protected $setColumnTotalInchart = 'no';
    protected $setTotalInchart = 'no';

    public function __construct($params)
    {
        $this->params = $params;//前段传过来的所有参数

        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
    }
    //默认主题的颜色
    public function getColor(){
        return ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc',
            '#005f73', '#099396', '#94d2bd', '#e9d7a5', '#ee9b00', '#ca6604', '#bb3e04', '#ae2012', '#9b2227',
            '#cb997e', '#fec5ba', '#fcd5ce', '#d7e2dc', '#48cae4', '#2a9d8e', '#ddbea9', '#6b705c', '#9b5de6'];
    }
    public function getChartTypeAll(){
        return $typeArr = [
            'line'=>["label"=>'折线图','list'=>[
                ['label'=>'单折线图','name'=>'line'],
                ['label'=>'多折线图','name'=>'multiple_line']
            ]],
            'bar'=>["label"=>'柱状图','list'=>[
                ['label'=>'单柱状图','name'=>'bar'],
                ['label'=>'多柱状图','name'=>'multiple_bar'],
                ['label'=>'柱状堆叠图','name'=>'bar_stack'],
                ['label'=>'折柱混合图','name'=>'line_bar'],
                ['label'=>'单条形图','name'=>'simple_strip'],
                ['label'=>'多条形图','name'=>'multiple_strip'],
                ['label'=>'条形堆叠图','name'=>'stack_strip'],
            ]],
            'pie'=>["label"=>'饼图','list'=>[
                ['label'=>'空心饼图','name'=>'pie'],
                ['label'=>'实心饼图','name'=>'solid_pie'],
                ['label'=>'南丁格尔玫瑰图','name'=>'rose_pie'],
                ['label'=>'嵌套饼图','name'=>'nesting_pie']
            ]],
            'funnel'=>["label"=>'漏斗图','list'=>[
                ['label'=>'梯形漏斗图','name'=>'funnel'],
                ['label'=>'三角形漏斗图','name'=>'triangle'],
                ['label'=>'碗形漏斗图','name'=>'bowls'],
            ]],
            'scatter'=>["label"=>'散点图','list'=>[
                ['label'=>'单维度散点图','name'=>'basic_scatter'],
                ['label'=>'多维度散点图','name'=>'multiple_dimension']
            ]],
            'sunburst'=>["label"=>'旭日图','list'=>[
                ['label'=>'旭日图','name'=>'simple_sunburst'],
            ]],
        ];
    }
    public function getSeriesType($name){
        switch ($name){
            case "line":
            case "multiple_line":return "line";
            case "bar":
            case "multiple_bar":
            case "bar_stack":
            case "simple_strip":
            case "multiple_strip":
            case "stack_strip":return "bar";
            case "pie":
            case "solid_pie":
            case "rose_pie":
            case "nesting_pie":return "pie";
            case "funnel":
            case "triangle":
            case "bowls":return "funnel";
            case "basic_scatter":
            case "multiple_dimension":return "scatter";
            case "simple_sunburst":return "sunburst";
            case "line_bar":return "line";//["line"=>"line","bar"=>"bar"]; 默认使用line
        }
    }
    public function getChartTypeName($name){
        $arr = [
            'line'=>'单折线图',
            'multiple_line'=>'多折线图',
            'bar'=>'单柱状图',
            'multiple_bar'=>'多柱状图',
            'bar_stack'=>'柱状堆叠图',
            'line_bar'=>'折柱混合图',
            'simple_strip'=>'单条形图',
            'multiple_strip'=>'多条形图',
            'stack_strip'=>'条形堆叠图',
            'pie'=>'空心饼图',
            'solid_pie'=>'实心饼图',
            'rose_pie'=>'南丁格尔玫瑰图',
            'nesting_pie'=>'嵌套饼图',
            'funnel'=>'梯形漏斗图',
            'triangle'=>'三角形漏斗图',
            'bowls'=>'碗形漏斗图',
            'basic_scatter'=>'单维度散点图',
            'multiple_dimension'=>'多维度散点图',
            'simple_sunburst'=>'旭日图',
        ];
        return $arr[$name];
    }
    public function getLegendType($typeId = null){
        $typeArr = [
            'plain'=>'普通图例',
            'scroll'=>'可滚动翻页的图例'
        ];
        if(empty($typeId)){
            return $typeArr;
        }
        return $typeArr[$typeId];
    }
    public function getLegendOrient($orientId = null){
        $typeArr = [
            'horizontal'=>'水平朝向',
            'vertical'=>'垂直朝向'
        ];
        if(empty($orientId)){
            return $typeArr;
        }
        return $typeArr[$orientId];
    }
    public function getLegendPosition($positionId = null){
        //正上方，正下方，左上角，左下角，右上角，右下角，
        $typeArr = [
            'righttop'=>'右上角 ',
            'rightbottom'=>'右下角',
            'lefttop'=>'左上角',
            'leftbottom'=>'左下角',
            'top'=>'正上方',
            'bottom'=>'正下方',
        ];
        if(empty($orientId)){
            return $typeArr;
        }
        return $typeArr[$orientId];
    }
    public function getAxisType($typeId = null){
        $typeArr = [
            'value'=>'数值轴',
            'category'=>'类目轴',
            'time'=>'时间轴',
            'log'=>'对数轴'
        ];
        if(empty($typeId)){
            return $typeArr;
        }
        return $typeArr[$typeId];
    }

    public function getTimeFormatType($typeId=null){
        $arr = [
            'byYear'=>'按年度',
            'byQuarter'=>'按季度',
            'byMonth'=>'按月度',
            'byWeek'=>'按周',
            'byDay'=>'按天'
        ];
        if(empty($typeId)){
            return $arr;
        }
        return $arr[$typeId];
    }
    public function getTotalType($typeId=null){
        $arr = [
//            'origin'=>'原样显示',
            'count'=>'计数',
            'sum'=>'求和',
            'avg'=>'求平均'
        ];
        if(empty($typeId)){
            return $arr;
        }
        return $arr[$typeId];
    }
    public function getChartPieType($typeId=null){
        $arr = [
            'pie'=>'计数',
            'ring'=>'求和',
            'rounded_ring'=>'求平均'
        ];
        if(empty($typeId)){
            return $arr;
        }
        return $arr[$typeId];
    }


    public function getSqlChartFieldType(){
        $arr = [
            'string'=>'字符串',
            'date'=>'日期',
            'datetime'=>'日期时间',
            'number'=>'数字',
            'currency'=>'金额',
            'percent'=>'百分比'
        ];
        return $arr;
    }

    /**
     * @param $title
     * @return mixed
     * title样式
     */
    public function title($title)
    {
        if(is_string($title))
            $title = Zend_Json::decode($title,true);


        if($this->params['fromhome']=='yes') {
            $title = null;//看板请求 不显示title
        }else{
            $title['top'] = 30;//距离顶边20像素
        }
        return $title;
    }

    /**
     * @param $toolbox
     * @return mixed
     * 工具栏设置
     */
    public function toolbox($toolbox,$title){
        if(is_string($toolbox))
            $toolbox = Zend_Json::decode($toolbox,true);
        //edit: xll 2024/03/14 XUQIU1002148 下载按钮紧跟图例
//        if($this->>$this->params['fromhome']=='yes'){
//            $toolbox['top'] = 30;
//        }
        $toolbox['feature'] = array(
            'saveAsImage'=>array(
                "name"=>$title ,
                "title"=>getFixedLabel('SAVEASIMAGE')
            )
        );
        //移动端  不要显示下载按钮
        if($this->toolboxshow=='no'){
            $toolbox = [];
        }
        return $toolbox;
    }

    public function setToolboxShow($toolboxshow){
        $this->toolboxshow = $toolboxshow;
    }

    /**
     * @param $tooltip
     * @param $echart_type 统计图类型
     * @param $show_percent 统计图tooltip 饼图是否显示百分比
     * @return mixed
     */
    public function tooltip($tooltip,$echart_type,$show_percent){
        if(is_string($tooltip))
            $tooltip = Zend_Json::decode($tooltip,true);
            //饼图显示百分比
        if(in_array($echart_type,array('pie','solid_pie','rose_pie','nesting_pie'))){

            if ($show_percent == "yes") {
                $tooltip = array(
                    "trigger"=>'item',
                    "formatter"=>'{b} : {c} ({d}%)'
                );
            }else {
                $tooltip = array(
                    "trigger"=>'item'
                );
            }
        }
        return $tooltip;
    }
    public function series ($series ){
        if(is_string($series))
            $series = Zend_Json::decode($series,true);
        return $series;
    }
    public function legend($legend,$data,$charttype,$legend_position){
        if(is_string($legend))
            $legend = Zend_Json::decode($legend,true);

        if($this->params['fromhome']=='yes'&&in_array($legend_position,array('top','lefttop','righttop'))){
            $legend['top'] = 0;
        }
        $tradeinfo = getVersionTradeInfo();
        //zxm 20230210 中兴 史文龙 分类太多隐藏图例
        if(in_array($charttype,['pie', 'solid_pie', 'rose_pie', 'nesting_pie'])&&$tradeinfo['account']=='sczhongxing'){
            $legend['show'] = false;
        }
        if(!empty($data)){
            if(empty($legend['data'])) $legend['data'] = [];
            $legend['data'] = array_merge($data,$legend['data']);
        }
        //zxm 20240709 图例色块大小改成正方形 12宽高 文字改12px BUG20240709-05
        $legend['itemWidth'] = 12;
        $legend['itemHeight'] = 12;
        $legend['textStyle'] = ['fontSize'=>12];
        return $legend;
    }
    public function xaxis($xaxis,$data){
        if(is_string($xaxis))
            $xaxis = Zend_Json::decode($xaxis,JSON_UNESCAPED_UNICODE);
 
   
        if(empty($xaxis)) $xaxis = [];
        $xaxis = array_values($xaxis);
 
        if(empty($xaxis))
            $xaxis[0] = [];

        $xaxis[0]['data'] = $data;
        return $xaxis;
    }
    public function yaxis($yaxis,$data){
        if(is_string($yaxis))
            $yaxis = Zend_Json::decode($yaxis,JSON_UNESCAPED_UNICODE);
 
        if(empty($yaxis)) $yaxis = [];
        $yaxis = array_values($yaxis);
 
        if(empty($yaxis))
            $yaxis[0] = [];
        
        $yaxis[0]['data'] = $data;
        return $yaxis;
    }
    public function grid($grid="{top:30}"){
        //edit: xll 2024/03/14 XUQIU1002148 下载按钮紧跟图例、需要空出top给图例和下载按钮
        if(is_string($grid))
            $grid = Zend_Json::decode($grid,true);
        if($this->params['fromhome']=='yes'){
            //首页的图上方距离只要留30即可 因为不显示title
            $grid['top'] = 60;
        }else{
            $grid['top'] = 90;
        }
        return $grid;
    }
    //柱状图
    public function barSeriesSet($series,$echartSet,$k){
        //支持：top / left / right / bottom / inside / insideLeft / insideRight / insideTop / insideBottom / insideTopLeft / insideBottomLeft / insideTopRight / insideBottomRight。
        //目前柱状图界面给用户可配置的项是top柱子顶部 inside柱子内部垂直居中 insideBottom柱子内部底部
        //目前折线图界面给用户可配置的项是top点上方 bottom点下方
        //数据标签设置
        $series_datalabel = Zend_Json::decode($echartSet['series_datalabel']);
        if(empty($series_datalabel)){
            $series[$k]['label']['show'] = false;
        }else{
            $series[$k]['label'] = $series_datalabel;
            //需求 只要是柱状图
        }
        //markpoint
        //$series[$k]['markPoint']=['data'=>[['type'=> 'max', 'name'=>'最大值'],['type'=> 'min', 'name'=>'最小值']]];
        //$series[$k]['markLine']=['data'=>[['type'=> 'average', 'name'=>'平均值']]];
        return $series;
    }
    //条形图
    public function stripSeriesSet($series,$echartSet,$k){
        //支持：top / left / right / bottom / inside / insideLeft / insideRight / insideTop / insideBottom / insideTopLeft / insideBottomLeft / insideTopRight / insideBottomRight。
        //目前界面给用户可配置的项是 right 柱子右侧  inside 柱子内部  insideLeft 柱子内部靠左
        $series_datalabel = Zend_Json::decode($echartSet['series_datalabel']);
        if(empty($series_datalabel)){
            $series[$k]['label']['show'] = false;
        }else{
            $series[$k]['label'] = $series_datalabel;
            $series[$k]['label']['formatter'] = '{b}';
        }
        return $series;
    }
    //漏斗图
    public function funnelSeriesSet($series,$echartSet,$k){
        $funnel_type = $echartSet['chart_type'];//漏斗图类型
        //目前界面给用户可配置的项是 right 柱子右侧  inside 柱子内部  left 左边
        $series_datalabel = Zend_Json::decode($echartSet['series_datalabel']);
        if(empty($series_datalabel)){
            $series[$k]['label']['show'] = true;//默认显示在内部
            $series[$k]['label']['position'] = 'inside';//默认显示在内部
        }else{
            $series[$k]['label'] = $series_datalabel;
        }
        //edit : xll 2023/10/19 BUG0074016 首页-“客户管理-销售管理”组件，鼠标放于文字上，只有高亮，没有像销售漏斗那种字体放大的功能。
        $series[$k]['emphasis'] = [
            'label' => [
                'fontSize' => 15,
            ],
        ];
        if($funnel_type=='bowls'){
            //碗形
            $series[$k]['minSize'] = '30%';
        }else if($funnel_type=='funnel'){
            //倒梯形
            $series[$k]['minSize'] = '30%';
        }else{
            //倒三角形
            $series[$k]['minSize'] = '0%';
        }
        return $series;
    }
    //散点图
    public function scatterSeriesSet($series,$k){
        // todo
    }
    //旭日图
    public function sunburstSeriesSet($series,$k){
        // todo
    }
    /**
     * @param $series
     * @param $echartSet
     * @param $k
     * @return array
     * 饼图的系列设置
     */
    public function pieSeriesSet($series,$echartSet,$k){
        $series[$k]['label']['show'] = true;
        //饼图的label显示位置 :inside outside
        $show_percent = $echartSet['show_percent'];
        //数据标签设置
        $series_datalabel = Zend_Json::decode($echartSet['series_datalabel']);
        if(empty($series_datalabel)){
            //饼图之前默认都是显示的  没值的情况下应该默认显示
            $series[$k]['label']['show'] = true;
            $series[$k]['label']['position'] = 'outside';
        }else if($series_datalabel['position']=='inside_radial'){
            //内部冲圆心
            $series[$k]['label']['show'] = true;
            $series[$k]['label']['position'] = 'inside';
            $series[$k]['label']['rotate'] = 'radial';//如果为 true 或 'radial'，则为径向排布。（'radial' 字面量从 v5.2.0 开始支持）
        }else{
            $series[$k]['label'] = $series_datalabel;
        }

        //是否显示百分比
        if($show_percent=='yes'){
            //$series[$k]['label']['position'] = 'outside';
            $series[$k]['label']['formatter'] = '{b}:{c}({d}%)';
            $series[$k]['label']['rich'] = '';
        }
        //饼图样式
        if($echartSet['chart_type']=='solid_pie'){
            //实心饼图
            $series[$k]['radius']='70%';
        }else if($echartSet['chart_type']=='rose_pie'){
            //南丁格尔玫瑰图 默认样式
            $series[$k]['radius']=['25%', '70%'];
            $series[$k]['center']=['50%', '50%'];
            $series[$k]['roseType']='area';
            $series[$k]['itemStyle'] = array(
                'borderRadius'=>8
            );
        }else if($echartSet['chart_type']=='nesting_pie'){
            //嵌套饼图
            $start = $k * 50;
            $end = (Int)$k * 50 + 30;
            $series[$k]['radius'] = [$start . '%', $end . '%'];
        }else{
            //空心饼图
            $series[$k]['radius']=['40%', '70%'];
        }
        return $series;
    }

    public function simple_sunburstSeriesSet($series,$echartSet){
        $series['nodeClick']=false;
        $series['itemStyle']=array(
            "borderRadius"=>7,
            "borderWidth"=> 2
        );
        $series_datalabel = Zend_Json::decode($echartSet['series_datalabel']);
        if($series_datalabel['position']=='inside_radial'){
            //内部冲圆心
            $series['label']['show'] = true;
            $series['label']['rotate'] = 'radial';
        }else if($series_datalabel['position']=='inside_tangential'){
            //内部冲圆心
            $series['label']['show'] = true;
            $series['label']['rotate'] = 'inside_tangential';
        }else{
            $series['label']['show'] = false;
        }
        // minAngle 当某个扇形块的角度小于该值（角度制）时，扇形块对应的文字不显示。该值用以隐藏过小扇形块中的文字。
        $series['label']['minAngle'] = '10';
        return $series;
    }
    public function option($echartSet){
        switch ($echartSet['chart_type']){
            case'pie':
            case'solid_pie':
            case'rose_pie':
                //饼图
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "tooltip"=> $echartSet['tooltip'],
                    "legend"=> $echartSet['legend'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];
                //zxm @date:2024/12/24 @reason: 自定义统计图 饼图 中心可以显示总合计
                if($this->setTotalInchart=='yes'&&$echartSet['chart_type']=='pie'){
                    $option['graphic'] = array(
                        "type"=>'text',
                        "left"=>'center',
                        "top"=>'center',
                        "z"=>'100',
                        "style"=> array(
                            "text"=> getFixedLabel('TOTAL').':'.$this->allTotalFormat,
                            "textAlign"=> 'center',
                            "fill"=> '#333',
                            "fontSize"=> 14
                        )
                    );
                    //$option['title']['text'] = $option['title']['text'].'('.getFixedLabel('TOTAL').':'.$this->allTotalFormat.')';
                }

                break;
            case'funnel':
            case'triangle':
            case'bowls':
                //漏斗图
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "legend"=> $echartSet['legend'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];

                break;
            case'simple_sunburst':
                //旭日图
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];
                break;
            case 'basic_scatter':
                //散点图
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "xAxis"=>$echartSet['xaxis'],
                    "yAxis"=> $echartSet['yaxis'],
                    "legend"=> $echartSet['legend'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];
                break;
            case "simple_strip":
            case "multiple_strip":
            case "stack_strip":
                //edit: xll 2024/03/14 XUQIU1002148 条形图增加标签显示在内部控制，内部则left减小
                if($echartSet['yaxis'][0]['axisLabel']['inside'])
                    $echartSet['grid'] = ["left"=>30];
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "xAxis"=>$echartSet['xaxis'],
                    "yAxis"=> $echartSet['yaxis'],
                    "legend"=> $echartSet['legend'],
                    "tooltip"=> $echartSet['tooltip'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];
                break;
            default:
                $option = [
                    "grid"=> $echartSet['grid'],
                    "title"=> $echartSet['title'],
                    "xAxis"=>$echartSet['xaxis'],
                    "yAxis"=> $echartSet['yaxis'],
                    "legend"=> $echartSet['legend'],
                    "tooltip"=> $echartSet['tooltip'],
                    "toolbox"=> $echartSet['toolbox'],
                    "series"=> $echartSet['series'],
                ];
        }
        if($echartSet["themename"]=='default')$echartSet['color'] = $this->getColor();
        $echartSet['option'] = $option;
        //edit: xll 2024/02/28 BUG20240227-34 y轴数值太大时显示不完全（超出宽度显示省略号）
        if(isset($option['yAxis'])&&!$echartSet['yaxis'][0]['axisLabel']['inside']) {
            foreach ($option['yAxis'] as $index => &$yAxis) {
                if(!isset($yAxis['axisLabel'])) {
                    $yAxis['axisLabel'] = [];
                }
                $yAxis['axisLabel']['width'] = 70;
                $yAxis['axisLabel']['overflow'] = 'truncate';
            }
        }
        return $option;
    }
    public function SetSeriesDataLabel($series_datalabel,$data_label_is_rotate,$chart_type){
        if($series_datalabel=='none'){
            $series_datalabel_arr['show'] = false;
        }else{
            $series_datalabel_arr['show'] = true;
            $series_datalabel_arr['position'] = $series_datalabel;
            //柱状图 需要判断数据标签是否旋转
            if($chart_type=='bar'||$chart_type=='multiple_bar'||$chart_type=='bar_stack'||$chart_type=='line_bar'){
                if($data_label_is_rotate===true){
                    $series_datalabel_arr['rotate'] = 90 ;
                    $series_datalabel_arr['verticalAlign'] = 'middle' ;
                    $series_datalabel_arr['align'] = 'left' ;
                }
            }
        }
        return $series_datalabel_arr;
    }
    public function setLegendPosition(&$legend,$legend_position,&$toolbox){
        //edit: xll 2024/03/21 图例位置的BUG
        switch (strtolower($legend_position)){
            case'top':
                //$legend['left'] = 'center';
                $legend['top'] = 10;
                //$legend['left'] = '60%';
                $legendRight = 50;
                break;
            case'bottom'://正下
                //$legend['left'] = 'center';
                $legend['bottom'] = 10;
                $legendRight = 50;
                break;
            case'lefttop':
                //$legend['left'] = 10;
                $legend['top'] = 10;
                if($legend['orient'] === 'horizontal')
                    $legendRight = 75;
                else
                    $legendRight = 90;
                break;
            case'leftbottom':
                //$legend['left'] = 10;
                $legend['bottom'] = 0;
                if($legend['orient'] === 'horizontal')
                    $legendRight = 75;
                else
                    $legendRight = 90;
                break;
            case'righttop'://右上角
                //$legend['right'] = 10;
                $legend['top'] = 10;
                $legendRight = 15;
                break;
            case'rightbottom':
                //$legend['right'] = 10;
                $legend['bottom'] = 0;
                $legendRight = 15;
                break;
            case'none':
                $legendRight = 90;
                $legend['show'] = false;
                break;
            default:
                $legend['bottom'] = 10;
                //$legend['left'] = 'center';
                $legendRight = 90;
                break;
        }
        //edit: xll 2024/03/14 XUQIU1002148 下载按钮紧跟图例
        if(isset($legend['bottom']) ) {
            $toolbox['bottom'] = $legend['bottom'] ;
        }
        else if(isset($legend['top']) && !empty($legend['top'])) {
            $toolbox['top'] = $legend['top'] - 4;
        }
        $legend['right'] = $legendRight.'%';
        $toolbox['left'] = (100 - $legendRight) . '%';
        $toolbox['orient'] = 'vertical';
        $show_toolbox = (isset($this->ChartSetInfo['show_toolbox']) && $this->ChartSetInfo['show_toolbox']) ? 'yes' : 'no';//是否显示下载按钮
        if($show_toolbox=='no'){
            $toolbox['show'] = false;
        }else{
            $toolbox['show'] = true;
        }

    }
    public function getChartSetArrOptionMsg(&$ChartSetArrOption){

        $ChartSetArrOption['SeqType'] = [
            ['Value'=>'bycolumnname','Label'=>'','labelbol'=>'Groupfieldsby'],
            ['Value'=>'byresult','Label'=>'','labelbol'=>'Bystatisticalresult'],
        ];
        $ChartSetArrOption['SeqField'] = [];
        $ChartSetArrOption['SeqMethod'] = [
            ['Value'=>'asc','Label'=> getFixedLabel("ASCENDINGORDER")],
            ['Value'=>'desc','Label'=> getFixedLabel("DESCENDINGORDER")],
        ];
        $ChartSetArrOption['LegendType'] = [
            ['Value'=>'plain','Label'=>'普通图例','labelbol'=>'NORMALLEGEND'],
            ['Value'=>'scroll','Label'=>'可滚动图例','labelbol'=>'SRROLLABLELEGEND'],
        ];
        $ChartSetArrOption['TimeMethod'] = [
            ['Value'=>'byYear','Label'=>'年','labelbol'=>'ANNUALLY'],
            ['Value'=>'byQuarter','Label'=>'季','labelbol'=>'QUARTERLY'],
            ['Value'=>'byMonth','Label'=>'月','labelbol'=>'MONTHLY'],
            ['Value'=>'byWeek','Label'=>'周','labelbol'=>'WEEKLY'],
            ['Value'=>'byDay','Label'=>'天','labelbol'=>'DAILY'],
        ];
        $ChartSetArrOption['YAxisIndex'] = [
            ['Value'=>'0','Label'=>'左Y轴','labelbol'=>'LEFTYAXIS'],
            ['Value'=>'1','Label'=>'右Y轴','labelbol'=>'RIGHTYAXIS'],
        ];
        $ChartSetArrOption['LegendOrient'] = [
            ['Value'=>'horizontal','Label'=>'水平朝向','labelbol'=>'HORIZONTAL'],
            ['Value'=>'vertical','Label'=>'垂直朝向','labelbol'=>'VERTICAL'],
        ];
        $ChartSetArrOption['SeriesType'] = [
            ['Value'=>'bar','Label'=>'柱状','labelbol'=>'SeriesTypeBar'],
            ['Value'=>'line','Label'=>'折线','labelbol'=>'SeriesTypeLine'],
        ];
        //edit: xll 2024/03/14 XUQIU1002148 条形图y轴标签增加位置控制
        $ChartSetArrOption['YAxisLabelPosition'] = [
            ['Value'=>'outside','Label'=>getFixedLabel("EXTERNAL")],   //外部
            ['Value'=>'inside','Label'=>getFixedLabel("INTERNAL")],    //内部
        ];
        //zxm 202407011 自定义统计图增加数据标签显示设置 XUQIU20240223-02 统计图可以设置参数，让数值显示（Echart有现成参数）
        $ChartSetArrOption['SeriesDataLabel'] = [
            ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'line'],   //不显示
            ['Value'=>'top','Label'=>getFixedLabel("Externallyabove"),'filter'=>'line'],    //外部上方--折线图
            ['Value'=>'bottom','Label'=>getFixedLabel("Belowtheexterior"),'filter'=>'line'],    //外部下方--折线图

            //柱状图--增加一个参数，可以设置是否让数字垂直显示
            ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'bar'],   //不显示
            ['Value'=>'top','Label'=>getFixedLabel("EXTERNAL"),'filter'=>'bar'],    //外部--柱状图
            ['Value'=>'insideBottom','Label'=>getFixedLabel("Internalbacking"),'filter'=>'bar'],    //内部贴底--柱状图
            ['Value'=>'inside','Label'=>getFixedLabel("InternalCenter"),'filter'=>'bar'],    //内部中心--柱状图

            ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'strip'],   //不显示
            ['Value'=>'right','Label'=>getFixedLabel("EXTERNAL"),'filter'=>'strip'],    //外部--条形图
            ['Value'=>'insideLeft','Label'=>getFixedLabel("Internalbacking"),'filter'=>'strip'],    //内部贴底--条形图
            ['Value'=>'inside','Label'=>getFixedLabel("InternalCenter"),'filter'=>'strip'],    //内部中心--条形图

            ['Value'=>'outside','Label'=>getFixedLabel("EXTERNAL"),'filter'=>'pie'],    //外部-饼图
            ['Value'=>'inside','Label'=>getFixedLabel("INTERNAL"),'filter'=>'pie'],    //内部 -饼图
            ['Value'=>'inside_radial','Label'=>getFixedLabel("inside_radial"),'filter'=>'pie'],    //内部-冲圆心 -饼图
            ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'pie'],   //不显示


            ['Value'=>'inside','Label'=>getFixedLabel("INTERNAL"),'filter'=>'funnel'],    //不显示 -漏斗图
            ['Value'=>'left','Label'=>getFixedLabel("theleftside"),'filter'=>'funnel'],    //左侧 -漏斗图
            ['Value'=>'right','Label'=>getFixedLabel("therightside"),'filter'=>'funnel'],    //右侧 -漏斗图
            ['Value'=>'none','Label'=>getFixedLabel("HIDE"),'filter'=>'funnel'],   //不显示

        ];


    }

    //设置参数（目前主要用于设置首页参数，用于移动端新看板和pc端看板）
    public function setHomeParams($params) {
        if(!$params)
            $params = $this->params;
        $this->boardid = $params['boardid'];
        $this->boardstuffid = $params['boardstuffid'];
        $this->scopeType = $params['scopeType'];
        if($params['scopeType'] === 'SmOwner_Search_All'){
            global $adb;
            crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
            $scopeobj = new cls_ScopOfAuthority($adb, 'Home');
            $params['selectuid'] = $scopeobj->getHomeScopeUser();
        }
        $this->selectuid = $params['selectuid'];
        if(empty($this->scopeType) && !empty($this->selectuid)) {
            $this->scopeType = 'smowner_search_senior';
        }
        $this->approve_value = $params['approve_value'];
        if($params['search_date'] === 'custom'){
            $this->search_date = $params['date_custom'];
        }else{
            $this->search_date = $params['search_date'];
        }
    }
    /**
     * @param $columns array 统计图字段信息
     * @param $sqlData object RESULT
     * @param $chartSet array 图表样式设置信息
     * @param $groupcolumnname string 第一个分组字段 字段名
     * @return array
     * 常规数据处理 例如基础柱状图、基础折线图、基础折柱状混合图
     * 入参：数据集、数据列
     * 出参：主要处理的几个数据 1.series数据  2.legend数据 3.xaxis轴数据
     * legend数据只对应统计字段的名称
     * xaxis轴数据对应统计维度的字段的名称
     * SQL统计图 自定义统计图  公共代码合并
     */
    public function normalData($columns, $sqlData, $chartSet, $groupcolumnname)
    {
        $chart_type = $chartSet['chart_type'];
        $nums = $this->adb->num_rows($sqlData);
        $series = [];//series数据
        $xdatas = [];//xaxis轴数据
        $legendData = [];//legend数据
        $label = array();
        $series_datalabel = Zend_Json::decode($chartSet['series_datalabel']);
        if(empty($series_datalabel)){
            $label['show'] = false;
            $series_datalabel = [];
        }else{
            $label = $series_datalabel;
        }
        $this->RowTotalDataArr = [];//设置行合计 循环列的时候求和  会生成一列数据
        $this->ColumnTotalDataArr = [];//设置列合计 循环行的时候求和  会生成一行数据 放在最后一行
        $seriesColumnTotalData = [];
        $this->allTotal = 0;//总合计

        for($jj=0;$jj<$nums;$jj++){
            $seriesColumnTotalData[$jj]['value'] = 0;
        }
        $k = 0;
        foreach($columns as $k=>$c){
            if(empty($c)){
                continue;
            }
            $this->RowTotalDataArr[$k] = 0;
            $data = [];
            $series[$k] = [];
            $series[$k]['name'] = $c['chart_column_name'];//图例
            $legendData[] = $c['chart_column_name'];
            $series[$k]['type'] = $c['chart_column_type'];
            //设置柱状图的柱子的最大宽度
            if($c['chart_column_type']=='bar'){
                $series[$k]['barMaxWidth'] = 18;
            }
            //柱状堆叠 设置堆叠属性
            if($chart_type=='bar_stack'){
                $series[$k]['stack'] = "barstack";
            }
            //柱状堆叠 设置堆叠属性
            if($chart_type=='stack_strip'){
                $series[$k]['stack'] = "barstack";
            }

            $typeofdata_decimal = $c['typeofdata_decimal'];
            $j =0;
            for($j=0;$j<$nums;$j++){
                $tmpcolumname = $c['realcolumns'];
                $tmpco = $this->adb->query_result($sqlData,$j,$tmpcolumname);
                $tmpco = empty($tmpco)?0:$tmpco;

                $this->RowTotalDataArr[$k] += $tmpco;
                $seriesColumnTotalData[$j]['value'] += $tmpco;
                $this->allTotal += $tmpco;

                $data[$j]['value'] = round((float)$tmpco,$typeofdata_decimal);
                if($series_datalabel['show']&&$series_datalabel['show']==true){
                    $tmpformattervalue = number_format($data[$j]['value'],$typeofdata_decimal);//条形图 需要显示的label是带格式化的  20240805
                    $label['formatter'] = $tmpformattervalue;
                    $data[$j]['label'] = $label;
                    $seriesColumnTotalData[$j]['label'] = $label;
                }
                $xdatas[$j] = $this->adb->query_result($sqlData,$j,$groupcolumnname);
                $xdatas[$j] = empty($xdatas[$j])?'无':$xdatas[$j];
            }
            //条形图
            if(in_array($chart_type,['simple_strip','multiple_strip','stack_strip'])){
                $data = array_reverse($data);
                $xdatas = array_reverse($xdatas);
                //判断是否多Y轴 如果是多Y轴 需要指定Y轴index  条形图
                if($c['yaxisindex']>0) {
                    $series[$k]['xAxisIndex'] = (int)$c['yaxisindex'];
                }
            }else{
                //判断是否多Y轴 如果是多Y轴 需要指定Y轴index
                if($c['yaxisindex']>0) {
                    $series[$k]['yAxisIndex'] = (int)$c['yaxisindex'];
                }
            }

            $series[$k]['data'] = $data;
            $series = $this->barSeriesSet($series,$chartSet,$k);
        }

        $this->ColumnTotalDataArr = array_column($seriesColumnTotalData,'value');//列合计 生成的一行数据
        //如果放统计图中显示的话

        if($this->setColumnTotalInchart=='yes'){
            ++$k;
            $legendData[] = getFixedLabel('ColumnTotal');
            $series[$k]['name'] = getFixedLabel('ColumnTotal');//图例
            $series[$k]['type'] = 'bar';
            $series[$k]['barMaxWidth'] = 18;
            $series[$k]['data'] = $seriesColumnTotalData;
        }
        return ['series'=>$series,'xdatas'=>$xdatas,'legendData'=>$legendData];
    }
    /**
     * @param $columns
     * @param $sqlData
     * @param $chartSet
     * @param $groupbykey
     * @return array
     * 饼图数据处理 -- 统计维度1个或者2个(嵌套饼图会有2个统计维度)  统计字段1个
     * 入参：数据集、数据列
     * 出参：主要处理的几个数据 1.series数据  2.legend数据
     * legend数据对应统计维度字段值
     */
    public function pieData($columns,$sqlData,$chartSet,$groupbykey)
    {
        $this->RowTotalDataArr = [];//设置行合计 循环列的时候求和  会生成一列数据 根据有几个分组字段 有几个值
        $this->allTotal = 0;//总合计

        $nums = $this->adb->num_rows($sqlData);
        $series = [];//series数据
        $legendData = [];//legend数据
        $groupbykey = explode(',',$groupbykey);
        $c = $columns[0];//统计字段1个
        $tmpcolumname = $c['realcolumns'];
        foreach ($groupbykey as $k => $g) {
            $this->RowTotalDataArr[$k] = 0;
            $series[$k]['name'] = $c['chart_column_name'];
            $series[$k]['type'] = $c['chart_column_type'];
            $data = [];
            $typeofdata_decimal = $c['typeofdata_decimal'];
            for($j=0;$j<$nums;$j++){
                $temp_name = $this->adb->query_result($sqlData, $j, $g);
                $temp_name = empty($temp_name) ? '无' : $temp_name;
                $temp_value = $this->adb->query_result($sqlData, $j, $tmpcolumname);
                $temp_value = empty($temp_value) ? 0 : round($temp_value, $typeofdata_decimal);
                if (!isset($data[$temp_name])) {
                    $data[$temp_name]['name'] = $temp_name;
                    $legendData[] = $temp_name;
                    $data[$temp_name]['value'] = $temp_value;
                } else {
                    $data[$temp_name]['value'] += $temp_value;
                }
                $this->RowTotalDataArr[$k] += $temp_value;
                $this->allTotal += $temp_value;
            }
            $series[$k]['data'] = $data;
            $series = $this->pieSeriesSet($series,$chartSet,$k);
            $series[$k]['data'] = array_values($data);
        }
        return ['series'=>$series,'legendData'=>$legendData];
    }
    /**
     * @param $report_id
     * @return array
     * @throws Exception
     * 获取统计图echarts的配置项信息
     */
    /**
     * @param $columns
     * @param $sqlData
     * @param $funnel_type
     * @return array[]
     * @throws Exception
     * 漏斗图数据处理 --目前限制一列数据
     * 入参：数据集、数据列
     * 出参：主要处理的几个数据 1.series数据  2.legend数据
     * legend数据对应统计维度字段值  要把picklist类型都列出来 -- todo--
     * 特殊处理：picklist数据都列出来 没有值的赋值为0
     */
    public function funnelData($columns,$sqlData,$echartSet,$groupbykey)
    {
        global $adb;
        $this->RowTotalDataArr = [];//设置行合计 循环列的时候求和  会生成一列数据 根据有几个分组字段 有几个值
        $this->allTotal = 0;//总合计

        $groupInfoArr = $this->groupInfo;
        $funnel_type=$echartSet['chart_type'];
        $legendData = [];//legend数据
        $nums = $this->adb->num_rows($sqlData);
        $groupInfo = $groupInfoArr[0];

        $this->RowTotalDataArr[0]['num_value'] = 0;

        if($groupInfo['bigtype']=='picklist'){
            $legendData = $this->getPicklistValuesArrByGroupInfo($groupInfo);
        }
        else{
            for($i=0;$i<$nums;$i++)
            {
                $legendData[]=$adb->query_result($sqlData,$i,$groupbykey);
            }
        }

        $series = [];//series数据
        foreach($columns as $k=>$c){

            $series[$k]['name'] = $c['chart_column_name'];
            $series[$k]['type'] = $c['chart_column_type'];

            $tmpcolumname = $c['realcolumns'];
            $total_type = $c['total_type'];
            $data = [];
            $legendDataCount = count($legendData);
            $total = 0;
            for($i=0;$i<$legendDataCount;$i++){
                $total += 100-100/$legendDataCount*$i;
            }
            $typeofdata_decimal = $c['typeofdata_decimal'];
            foreach($legendData as $key=>$val){
                $data[$key]["name"] = $val;
                $data[$key]["value"] = 100-100/$legendDataCount*$key;
                if($funnel_type=='bowls'){
                    $height = $data[$key]["value"]*100/$total;
                    $data[$key]['itemStyle'] = ['height'=>$height.'%'];
                }
                $data[$key]["name"] = $val;
                $data[$key]["actual_value"] = 0;
                $data[$key]["num_value"] = 0;
                $label['formatter'] = $val.'(0)';
                $data[$key]['label'] = $label;

                for($j=0;$j<$nums;$j++){
                    $value = $this->adb->query_result($sqlData,$j,$tmpcolumname);
                    $value = empty($value)?"0":$value;
                    $num_value = $value;
                    $value_format = $value;
                    //edit: xll 2024/03/07 BUG20240305-54 计数、唯一计数，都不显示小数位数
                    if($total_type !== 'count' && $total_type !== 'distinct_count') {
                        $value = round($value,$typeofdata_decimal);
                        $value_format = setNumberFormat($value,$typeofdata_decimal);
                    }
                    $name = $this->adb->query_result($sqlData,$j,$groupbykey);
                    if($val == $name){
                        $data[$key]["actual_value"] = $value;
                        $data[$key]["num_value"] = $num_value;
                        $label['formatter'] = $val.'('.$value_format.')';
                        $data[$key]['label'] = $label;
                        $this->RowTotalDataArr[0]['num_value'] += $value;
                        $this->allTotal += $value;
                    }
                }
            }
            $series[$k]['label']['show'] = true;
            $series[$k]['label']['position'] = 'inside';
            $series[$k]['data'] = $data;
            $series = $this->funnelSeriesSet($series,$echartSet,$k);
        }
        return ['series'=>$series,'legendData'=>$legendData];
    }
    //两个统计维度的数据--堆叠图共用
    //两个统计维度的时候  统计字段必然只能有一个 但是现在还没做限制---感觉多个统计字段也能行啊 两个维度一个统计字段做一个图  几个统计字段就出多少个图显示在界面上--思考
    public function twoGroupData($column,$sqlData,$echartSet,$groupInfoArr,$groupbykey)
    {
        $is_stack = ($echartSet['chart_type']=="bar_stack"|| $echartSet['chart_type']=='stack_strip')?'yes':'no';//是否堆叠
        $groupInfo = [];
        $chart_type = $echartSet['chart_type'];
        foreach($groupInfoArr as $k=>$v){
            if($v['bigtype']=='picklist'){
                $groupInfo[$k] = $this->getPicklistValuesArrByGroupInfo($v);
            }else{
                $groupInfo[$k] = [];
            }
        }

        $groupbykey_arr = explode(',',$groupbykey);
        $nums = $this->adb->num_rows($sqlData);

        $this->RowTotalDataArr = [];//设置行合计 循环列的时候求和  会生成一列数据
        $this->ColumnTotalDataArr = [];//设置列合计 循环行的时候求和  会生成一行数据 放在最后一行
        $seriesColumnTotalData = [];
        $this->allTotal = 0;//总合计

        $series = [];//series数据
        $xdatas = [];
        $legendData = [];//legend数据
        $data = [];
        $typeofdata_decimal = $column['typeofdata_decimal'];
        for($j=0;$j<$nums;$j++){
            $tmpcolumname = $column['realcolumns'];
            $co0 = $this->adb->query_result($sqlData,$j,$tmpcolumname);
            $co0 = empty($co0)?0:round($co0,$typeofdata_decimal);

            $groupcolumn0 = $this->adb->query_result($sqlData,$j,$groupbykey_arr[0]);
            $groupcolumn0 = empty($groupcolumn0)?'无':$groupcolumn0;
            if(!in_array($groupcolumn0,$xdatas)){
                $xdatas[] = $groupcolumn0;
            }
            $groupcolumn1 = $this->adb->query_result($sqlData,$j,$groupbykey_arr[1]);
            $groupcolumn1 = empty($groupcolumn1)?'无':$groupcolumn1;
            if(!in_array($groupcolumn1,$legendData)){
                $legendData[] = $groupcolumn1;
            }
            $data[$groupcolumn0][$groupcolumn1] = $co0;
        }

        $xdatas = empty($groupInfo[0])?$xdatas:$groupInfo[0];
        $legendData = empty($groupInfo[1])?$legendData:$groupInfo[1];
        $typeofdata_decimal = $column['typeofdata_decimal'];

        $key = 0;
        foreach($legendData as $key =>$val){
            $this->RowTotalDataArr[$key] = 0;
            foreach($xdatas as $kk=>$vv){
                $series[$key]['name'] = $val;
                $series[$key]['type'] = 'bar';
                if($is_stack=="yes"){
                    $series[$key]['stack'] = 'barstack';
                }
                $series[$key]['barMaxWidth'] = 18;//设置柱子的最大宽度
                //判断是否多Y轴 如果是多Y轴 需要指定Y轴index
                if($column['yaxisindex']>0&&in_array($chart_type,["stack_strip","simple_strip","multiple_strip"])) {
                    $series[$key]['xAxisIndex'] = (int)$column['yaxisindex'];
                }else{
                    $series[$key]['yAxisIndex'] = $column['yaxisindex'];
                }
                $series[$key]['data'][$kk] = empty($data[$vv][$val])?0:round($data[$vv][$val],$typeofdata_decimal);

                $this->RowTotalDataArr[$key] += $series[$key]['data'][$kk];
                if(!isset($seriesColumnTotalData[$kk]))$seriesColumnTotalData[$kk]=0;
                $seriesColumnTotalData[$kk] += $series[$key]['data'][$kk];
                $this->allTotal += $series[$key]['data'][$kk];
            }

            $series = $this->barSeriesSet($series,$echartSet,$key);

        }
        $this->ColumnTotalDataArr = $seriesColumnTotalData;//列合计 生成的一行数据
        //如果放统计图中显示的话
        if($this->setColumnTotalInchart=='yes'){
            ++$key;
            $legendData[] = getFixedLabel('ColumnTotal');
            $series[$key]['name'] = getFixedLabel('ColumnTotal');//图例
            $series[$key]['type'] = 'bar';
            $series[$key]['barMaxWidth'] = 18;
            $series[$key]['data'] = $seriesColumnTotalData;
        }
        return ['series'=>$series,'legendData'=>$legendData,'xdatas'=>$xdatas];
    }
    //散点图的数据处理
    public function scatterData($columns,$sqlData,$groupbykey,$rowindex,&$arr,&$legend){
        $groupbykey_arr = explode(',',$groupbykey);
        $column = $columns[$rowindex];
        $tmpcolumname = $column['realcolumns'];
        $nums = $this->adb->num_rows($sqlData);
        $series = [];
        //如果有第二维统计维度 根据第二位再分组
        for($j=0;$j<$nums;$j++) {
            $tempdatagroup = [];

            $co = $this->adb->query_result($sqlData, $j, $tmpcolumname);
            foreach($groupbykey_arr as $gk=>$gv) {
                $tempdatagroup[] = $this->adb->query_result($sqlData, $j, $gv);
            }
            if(sizeof($tempdatagroup)==1)
            {
                $value=$tempdatagroup[0];
                if(!array_key_exists($value,$arr))
                {
                    $arr[$value]=[];
                }
                $arr[$value][]=$co+0.00;
            }
            else if(sizeof($tempdatagroup)==2)
            {
                $value=$tempdatagroup[1];
                $legend[]=$tempdatagroup[1];
                if(!array_key_exists($value,$arr))
                {
                    $arr[$value]=[];
                }
                $second_value=$tempdatagroup[0];
                if(!array_key_exists($second_value,$arr[$value]))
                {
                    $arr[$value][$second_value]=[];
                }
                $arr[$value][$second_value][]=$co+0.00;
            }


        }
        return ['series'=>array_values($series)];
    }
    public function ResetScatter($groupby,$scatt_arr)
    {
        $series_arr=[];
        $rowindex=0;
        if( sizeof($groupby)==2)
        {

            foreach($scatt_arr as $groupone=>$one_arr)
            {
                foreach($one_arr as $grouptwo=>$two_arr)
                {
                    $legend[] = (string)$groupone;
                    $two_arr[]=$grouptwo;
                    $two_arr[]=$groupone;
                    $series_arr[$rowindex]['data'][]=$two_arr;
                }
                $series_arr[$rowindex]['type']='scatter';

                $rowindex++;
            }
        }
        else{
            $series_arr['type']='scatter';
            foreach($scatt_arr as $groupone=>$one_arr)
            {
                $one_arr[]=$groupone;
                $series_arr['data'][]=$one_arr;

                $rowindex++;
            }
            $tmp_arr[]=$series_arr;
            $series_arr=$tmp_arr;
        }
        return $series_arr;
    }

    public function getEchartSet($report_id)
    {
        $chartSet = [];
        if(empty($report_id)){
            return $chartSet;
        }
        $chart_sql = "select * from ld_customreport_chartset where report_id=? ";
        $chart_res = $this->adb->pquery($chart_sql,array($report_id));
        $nums = $this->adb->num_rows($chart_res);
        if($nums>0){
            $chartSet['report_id'] = $this->adb->query_result($chart_res,0,'report_id');
            $chartSet['title'] = $this->adb->query_result($chart_res,0,'title');
            $chartSet['xaxis'] = $this->adb->query_result($chart_res,0,'xaxis');
            $chartSet['yaxis'] = $this->adb->query_result($chart_res,0,'yaxis');
            $chartSet['legend'] = $this->adb->query_result($chart_res,0,'legend');
            $chartSet['tooltip'] = $this->adb->query_result($chart_res,0,'tooltip');
            $chartSet['toolbox'] = $this->adb->query_result($chart_res,0,'toolbox');
            $chartSet['chart_type'] = $this->adb->query_result($chart_res,0,'chart_type');//统计图类型
            $chartSet['show_percent'] = $this->adb->query_result($chart_res,0,'show_percent');

            $chartSet['show_rowtotal'] = $this->adb->query_result($chart_res,0,'show_rowtotal');
            $chartSet['show_columntotal'] = $this->adb->query_result($chart_res,0,'show_columntotal');
            $chartSet['show_columntotal_inchart'] = $this->adb->query_result($chart_res,0,'show_columntotal_inchart');
            $chartSet['show_alltotal_inchart'] = $this->adb->query_result($chart_res,0,'show_alltotal_inchart');
            $this->setRowTotal = $chartSet['show_rowtotal']=='yes'?'yes':'no';//设置行合计
            $this->setColumnTotal = $chartSet['show_columntotal']=='yes'?'yes':'no';//设置列合计
            $this->setColumnTotalInchart = $chartSet['show_columntotal_inchart']=='yes'?'yes':'no';//设置列合计显示在统计图上
            $this->setTotalInchart = $chartSet['show_alltotal_inchart']=='yes'?'yes':'no';//设置列合计显示在统计图上--饼图

            $chartSet['funnel_type'] = $this->adb->query_result($chart_res,0,'funnel_type');
            $chartSet['legend_position'] = $this->adb->query_result($chart_res,0,'legend_position');
            $chartSet['series_datalabel'] = $this->adb->query_result($chart_res,0,'series_datalabel');

            $chartSet['chart_type_name'] = $this->getChartTypeName($chartSet['chart_type']);//统计图类型中文名称

            $chartSet['title1'] = Zend_Json::decode($chartSet['title'],true);
            $chartSet['xaxis1'] = Zend_Json::decode($chartSet['xaxis'],true);
            $chartSet['yaxis1'] = Zend_Json::decode($chartSet['yaxis'],true);

            $chartSet['legend1'] = Zend_Json::decode($chartSet['legend'],true);
            $chartSet['legend1']['legend_position'] = $chartSet['legend_position'];
            $chartSet['tooltip1'] = Zend_Json::decode($chartSet['tooltip'],true);
            $chartSet['toolbox1'] = Zend_Json::decode($chartSet['toolbox'],true);

            $chartSet['title'] = $this->title($chartSet['title']);
            $chartSet['xaxis'] = $this->xaxis($chartSet['xaxis'],'');

            $chartSet['yaxis'] = $this->yaxis($chartSet['yaxis'],'');

            $chartSet['grid'] = $this->grid();
            $chartSet['legend'] = $this->legend($chartSet['legend'],'',$chartSet['chart_type'],$chartSet['legend_position']);
            $chartSet['tooltip'] = $this->tooltip($chartSet['tooltip'],$chartSet['chart_type'],$chartSet['show_percent']);

            $chartSet['toolbox'] = $this->toolbox($chartSet['toolbox'],$chartSet['title']);

        }
        if(isset($chartSet['toolbox']['show'])&&$chartSet['toolbox']['show']){
            $chartSet['show_toolbox'] = 'yes';
        }else{
            $chartSet['show_toolbox'] = 'no';
        }
        return $chartSet;
    }
    //edit: xll 2024/03/14 XUQIU1002148 合并sql统计图、统计图的公共代码
    public function setChartSet() {
        global $adb;
        $ChartSetInfo = $this->ChartSetInfo;

        $chart_type = $ChartSetInfo['chart_type'];
        //标题title
        $title['text'] = $ChartSetInfo['report_name'];
        //标题是否开启
        $title['show'] = (bool)$ChartSetInfo['TitleSwitch'];

        if(isset($ChartSetInfo['AlignSet'])&&isset($this->TitleAlignArr[$ChartSetInfo['AlignSet']])){
            $AlignSetArr = explode(':',$this->TitleAlignArr[$ChartSetInfo['AlignSet']]);
            $title[$AlignSetArr[0]] = $AlignSetArr[1];
        }
        $title = json_encode($title,JSON_UNESCAPED_UNICODE);
        //X轴设置  类目轴：折线图、柱状图 数值轴：条形图、散点图   不需要X轴：饼图、漏斗图、旭日图

        $yaxis = [];//Y轴设置
        $yaxisindex = $ChartSetInfo['yaxisindex'];//Y轴或X轴索引
        $yaxisarr = [];
        if(in_array($chart_type,['line','multiple_line','bar','multiple_bar','bar_stack','line_bar',"basic_scatter","multiple_dimension"])){
            //X轴为类目轴：折线图、柱状图
            //Y轴为数值轴
            $xaxis_bottom_name = $ChartSetInfo['xaxis_bottom_name'];//默认下X轴
            $xaxis_name_bottom_rotate = $ChartSetInfo['xaxis_name_rotate'];
            $xaxis_name_bottom_rotate = empty($xaxis_name_bottom_rotate)?0:$xaxis_name_bottom_rotate;
            $xaxis_name_bottom_rotate = (int)$xaxis_name_bottom_rotate;
            $xaxis = json_encode([
                "bottom" => [
                    "type" => "category",
                    "position" => "bottom",
                    "name" => $xaxis_bottom_name,
                    "axisLabel" => [
                        "rotate" => $xaxis_name_bottom_rotate,
                    ],
                ],
            ],JSON_UNESCAPED_UNICODE);
            //$xaxis = '{"bottom":{"type":"category","position":"bottom","name":"'.$xaxis_bottom_name.'","axisLabel":{"rotate":'.$xaxis_name_bottom_rotate.'}}}';

            $yaxis_left_name = $ChartSetInfo['yaxis_left_name'];
            $yaxis['left'] = [];
            $yaxis['left']['type'] = "value";
            $yaxis['left']['position'] = 'left';
            $yaxis['left']['name'] = $yaxis_left_name;
            array_push($yaxisarr,'left');

            $yaxis_right_name = $ChartSetInfo['yaxis_right_name'];
            $yaxis['right'] = [];
            $yaxis['right']['type'] = "value";
            $yaxis['right']['position'] = 'right';
            $yaxis['right']['name'] = $yaxis_right_name;
            array_push($yaxisarr,'right');

            //默认情况下显示左Y轴 zxm 20220721
            $yaxis = json_encode($yaxis,JSON_UNESCAPED_UNICODE);
            //Y轴为空则必须给一个默认值
            //'{"left":{"type":"value","position":"left","name":"'.$ChartSetInfo['yaxis_left_name'].'"}}'
        }
        else if(in_array($chart_type,["simple_strip","multiple_strip","stack_strip","basic_scatter","multiple_dimension"])){
            //X轴数值轴：条形图、散点图
            //Y轴为类目轴

            $xaxis_bottom_name = $ChartSetInfo['xaxis_bottom_name'];
            $yaxis['bottom'] = [];
            $yaxis['bottom']['type'] = "value";
            $yaxis['bottom']['position'] = 'bottom';
            $yaxis['bottom']['name'] = $xaxis_bottom_name;
            array_push($yaxisarr,'bottom');

            $xaxis_top_name = $ChartSetInfo['xaxis_top_name'];
            $yaxis['top'] = [];
            $yaxis['top']['type'] = "value";
            $yaxis['top']['position'] = 'top';
            $yaxis['top']['name'] = $xaxis_top_name;
            array_push($yaxisarr,'top');

            $xaxis = json_encode($yaxis,JSON_UNESCAPED_UNICODE);
            //Y轴为空则必须给一个默认值
            //'{"bottom":{"type":"value","position":"bottom","name":"'.$xaxis_bottom_name.'"},"top":{"type":"value","position":"top","name":"'.$xaxis_top_name.'"}}'
            $yaxis_left_name = $ChartSetInfo['yaxis_left_name'];//默认左Y轴
            $yaxis_name_left_rotate = $ChartSetInfo['yaxis_name_rotate'];
            $yaxis_name_left_rotate = empty($yaxis_name_left_rotate)?0:(int)$yaxis_name_left_rotate;
            $yaxis = [
                "left" => [
                    "type" => "category",
                    "position" => "left",
                    "name" => $yaxis_left_name,
                    "axisLabel" => [
                        "rotate" => $yaxis_name_left_rotate,
                    ],
                ],
            ];
            if(in_array($chart_type,["simple_strip","multiple_strip","stack_strip"])){
                //条形图 特殊样式
                $yaxis['left']['axisLabel']['inside'] = ($ChartSetInfo['YAxisLabelPosition'] === "inside");
                $yaxis['left']['axisLabel']['color'] = "#000";
                $yaxis['left']['z'] = 999;  //之前是zlevel 小程序报错 所以改成了z
            }
            $yaxis = json_encode($yaxis,JSON_UNESCAPED_UNICODE);
            //$yaxis = '{"left":{"type":"category","position":"left","name":"'.$yaxis_left_name.'","axisLabel":{"rotate":'.$yaxis_name_left_rotate.'}}}';
        }
        else{
            $xaxis = null;
            $yaxis = null;
        }
        $legend = [
            "type" => $ChartSetInfo['LegendType'],
            "orient" => $ChartSetInfo['LegendOrient'],
        ];
        $toolbox = [
            //'right' => 30,
        ];
        //图例朝向 --zxm 20220923
        $legend_position = $ChartSetInfo['LegendLocate'];
        $legend_position = empty($legend_position)?'horizontal':$legend_position;//为空给默认值
        $this->setLegendPosition($legend,strtolower($legend_position),$toolbox);
        $legend = json_encode($legend,JSON_UNESCAPED_UNICODE);
        $toolbox = json_encode($toolbox,JSON_UNESCAPED_UNICODE);
        $tooltip['trigger'] = 'axis';
        $tooltip = json_encode($tooltip,JSON_UNESCAPED_UNICODE);
        if($chart_type=="bowls"){
            $funnel_type = "bowls";
        }else if ($chart_type=="triangle"){
            $funnel_type = "triangle";
        }elseif ($chart_type=="funnel"){
            $funnel_type = "funnel";
        }
        $report_id = $ChartSetInfo['report_id'];
        $show_percent = $ChartSetInfo['show_percent'] ? 'yes' : 'no';
        //数据标签显示设置
        $series_datalabel = $ChartSetInfo['SeriesDataLabel'];
        $data_label_is_rotate = $ChartSetInfo['DataLabelIsRotate'];
        $series_datalabel_arr = $this->SetSeriesDataLabel($series_datalabel,$data_label_is_rotate,$chart_type);
        $series_datalabel_json = json_encode($series_datalabel_arr,JSON_UNESCAPED_UNICODE);
        //显示行列合计等四个参数
        $show_rowtotal=(isset($ChartSetInfo['show_rowtotal'])&&$ChartSetInfo['show_rowtotal']=='yes')?'yes':'no';
        $show_columntotal=(isset($ChartSetInfo['show_columntotal'])&&$ChartSetInfo['show_columntotal']=='yes')?'yes':'no';
        $show_columntotal_inchart=(isset($ChartSetInfo['show_columntotal_inchart'])&&$ChartSetInfo['show_columntotal_inchart']=='yes')?'yes':'no';
        $show_alltotal_inchart=(isset($ChartSetInfo['show_alltotal_inchart'])&&$ChartSetInfo['show_alltotal_inchart']=='yes')?'yes':'no';
        //先删除
        $deleteSql = "delete from ld_customreport_chartset where report_id=?";
        $adb->pquery($deleteSql,[$report_id]);
        $sql = "insert into ld_customreport_chartset (report_id,title,xaxis,yaxis,legend,tooltip,toolbox,chart_type,show_percent,funnel_type,legend_position,series_datalabel,show_rowtotal,show_columntotal,show_columntotal_inchart,show_alltotal_inchart) 
values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE title=?,xaxis=?,yaxis=?,legend=?,tooltip=?,toolbox=?,chart_type=?,show_percent=?,funnel_type=?,legend_position=?,series_datalabel=?,show_rowtotal=?,show_columntotal=?,show_columntotal_inchart=?,show_alltotal_inchart=?";

        $adb->pquery($sql,[$report_id,$title,$xaxis,$yaxis,$legend,$tooltip,$toolbox,$chart_type,$show_percent,$funnel_type,$legend_position,$series_datalabel_json,$show_rowtotal,$show_columntotal,$show_columntotal_inchart,$show_alltotal_inchart,$title,$xaxis,$yaxis,$legend,$tooltip,$toolbox,$chart_type,$show_percent,$funnel_type,$legend_position,$series_datalabel_json,$show_rowtotal,$show_columntotal,$show_columntotal_inchart,$show_alltotal_inchart]);


    }

    public static function prvinceNameChange($bill_state) {
        if(strpos($bill_state,'省') !== false){
            $bill_state=str_replace('省','',$bill_state);
        }
        if(strpos($bill_state,'市') !== false){
            $bill_state=str_replace('市','',$bill_state);
        }
        if($bill_state == '广西壮族自治区'){
            $bill_state = '广西';
        }
        else if($bill_state == '内蒙古自治区'){
            $bill_state = '内蒙古';
        }
        else if($bill_state == '西藏自治区'){
            $bill_state = '西藏';
        }
        else if($bill_state == '宁夏回族自治区'){
            $bill_state = '宁夏';
        }
        else if($bill_state == '新疆维吾尔自治区'){
            $bill_state = '新疆';
        }
        else if($bill_state == '昌吉回族自治州'){
            $bill_state = '昌吉';
        }
        else if($bill_state == '阿克苏地区'){
            $bill_state = '阿克苏';
        }
        else if($bill_state == '和田地区'){
            $bill_state = '和田';
        }
        else if($bill_state == '喀什地区'){
            $bill_state = '喀什';
        }
        else if($bill_state == '塔城地区'){
            $bill_state = '塔城';
        }
        else if($bill_state == '阿勒泰地区'){
            $bill_state = '阿勒区';
        }
        else if($bill_state == '伊犁哈萨克自治州'){
            $bill_state = '伊犁';
        }
        else if($bill_state == '大理白族自治州'){
            $bill_state = '大理';
        }
        else if($bill_state == '德宏傣族景颇族自治州'){
            $bill_state = '德宏';
        }
        else if($bill_state == '怒江傈僳族自治州'){
            $bill_state = '怒江';
        }
        else if($bill_state == '文山壮族苗族自治州'){
            $bill_state = '文山';
        }
        else if($bill_state == '红河哈尼族彝族自治州'){
            $bill_state = '红河';
        }
        else if($bill_state == '西双版纳傣族自治州'){
            $bill_state = '西双版纳';
        }
        else if($bill_state == '迪庆藏族自治州'){
            $bill_state = '迪庆';
        }
        return $bill_state;
    }
}