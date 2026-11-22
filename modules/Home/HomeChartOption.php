<?php
class HomeChartOption{
    public $platesetting;
    public function __construct()
    {
    }
    public function setPlateSetting($platesetting){
        $this->platesetting = $platesetting;
    }
    public function getLegend(){
        //图例色块大小 文字大小在default.js中有规定  这里不需要重复写了
        return array("type"=>"scroll","bottom"=>"14");
    }

    public function getTooltip(){
        return array(
            "trigger"=>'axis',
            "axisPointer"=>array("type" =>'shadow' ),
            "textStyle"=>array("align"=>'left'),
        );
    }

    public function getGrid(){
        return array(
            "left"=>'3%',
            "right"=>'4%',
            "bottom"=> '15%',
            "top"=> 40,
            "containLabel"=>true
        );
    }
    public function getDataLabel(){
        $platesetting = $this->platesetting;
        $label = array();
        if($platesetting['datalabel']=='none'){
            $label = ['show'=>false];
        }else{
            if($platesetting['datalabel'] == 'inside_radial'){
                $position = 'inside';
                $label = ['show'=>true,'position'=>$position,'rotate'=>'radial'];
            }else{
                $position = $platesetting['datalabel'];
                $label = ['show'=>true,'position'=>$position];
            }
        }
        return $label;
    }
    //最近6个月销售情况  最近6个月个人销售情况的Option 生成
    public function getSalesLastestSixOption($data){

         $option = array();
         $option['grid'] = $this->getGrid();
         $option['xAxis'] = array(
             'type'=>'category',
             'data'=>$data['title'],
         );
         //两个Y轴
        $option['yAxis'] = [
            array(
                "type"=> 'value',
                "name"=> getFixedLabel('QTY'),
                ),
            array(
                "type"=> 'value',
                "name"=> getFixedLabel('AMOUNT'),
            ),
        ];
        //图例
        $option['legend'] = $this->getLegend();
        //提示框
        $option['tooltip'] = $this->getTooltip();
        $label = $this->getDataLabel();
        $option['series'] = [
            array(
                "name"=>getFixedLabel('AMOUNT'),
                "type"=> 'bar',
                "barMaxWidth"=>18,
                "yAxisIndex"=> 1,
                "data"=> $this->setDataLabelFormatter($data['amount'],$label),
                "label"=>$label
            ),
            array(
                "name"=>getFixedLabel('QTY'),
                "type"=> 'line',
                "data"=> $data['count'],
                "label"=>$label
            ),
        ];
        return $option;
    }
    public function setDataLabelFormatter($list,$label){
        $newList = [];
        if($label['show']== false){
            return $list;
        }
        foreach($list as $k=>$value){
            $tmpformattervalue = number_format($value,2);//条形图 需要显示的label是带格式化的  20240805
            $label['formatter'] = $tmpformattervalue;
            $newList[] = [
                'value'=>$value,
                'label'=>$label
            ];
        }
        return $newList;
    }
    //同比的option 签约额月度同比 等等4个组件
    public function getCompanyNowLastAllMonthOption($data){
        $option = array();
        $option['grid'] = $this->getGrid();
        $option['xAxis'] = array(
            'type'=>'category',
            'data'=>$data['title'],
        );
        //两个Y轴
        $option['yAxis'] = [
            array(
                "type"=> 'value',
                "name"=> getFixedLabel('AMOUNT'),
                "min"=>0,
            )
        ];
        //图例
        $option['legend'] = $this->getLegend();
        //提示框
        $label = $this->getDataLabel();
        $option['tooltip'] = $this->getTooltip();
        $option['series'] = [
            array(
                "name"=>getFixedLabel('PREVYEAR'),
                "type"=> 'bar',
                "barMaxWidth"=>18,
                "data"=> $this->setDataLabelFormatter($data['lastyear'],$label),
                "label"=>$label
            ),
            array(
                "name"=>getFixedLabel('CURYEAR'),
                "type"=> 'bar',
                "barMaxWidth"=>18,
                "data"=> $this->setDataLabelFormatter($data['year'],$label),
                "label"=>$label
            ),
        ];
        return $option;
    }
    //销售漏斗的option
    public function getSALESFUNNELOption($data){
        $charReportdata=[];//漏斗图假的数据内容
        $legend_data = [];//图列
        $counts = sizeof($data['count']);
        for($i = 0; $i<$counts;$i++){
            $temp = [];
            $temp['name'] = $data['title'][$i].' : '.$data['count'][$i].'('.$data['percentage'][$i].')';
            $legend_data[$i] = $temp['name'];
            $temp['value'] = 100-100/$counts*$i;
            $charReportdata[$i] = $temp;
        }
        $option = array();
        $option['grid'] = $this->getGrid();


        $series = array(
            "type"=>'funnel',
            "left"=> '10%',
            "top"=> 0,
            "bottom"=> 10,
            "width"=> '80%',
            "min"=> 0,
            "max"=> 100,
            "minSize"=> '0',
            "maxSize"=> '100%',
            "sort"=> 'descending',
            "gap"=> 0,
            "label"=> $this->getDataLabel(),
            "labelLine"=> [
                "length"=> 10,
                "lineStyle"=> [
                    "width"=> 1,
                    "type"=> 'solid'
                ]
            ],
            "itemStyle"=> [
                "borderColor"=> '#fff',
                "borderWidth"=> 1
            ],
            "emphasis"=> [
                "label"=> [
                    "fontSize"=> 15
                ]
            ],
            "data"=> $charReportdata
        );
        if($this->platesetting['datalabel']=='left'){
            $series['left'] = '28%';
            $series['width'] = '70%';
        }
        if($this->platesetting['datalabel']=='right'){
            $series['left'] = '2%';
            $series['width'] = '70%';
        }
        $option['series'] = [
            $series
        ];
        return $option;
    }

    //44 45 商机统计图_按销售负责人和销售阶段统 商机统计图_按所属行业和销售阶段统计
    public function getPotentialsByStatisticsOption($data){
        $option = array();
        $option['grid'] = $this->getGrid();
        //提示框
        $option['tooltip'] = $this->getTooltip();
        //图例
        $option['legend'] = $this->getLegend();


        $option['xAxis'] = array(
            'type'=>'category',
            'data'=>$data['title'],
        );
        //1个Y轴
        $option['yAxis'] = [
            array(
                "type"=> 'value',
                "name"=> getFixedLabel('QTY'),
                "axisLabel"=>array("formatter"=>'{value}')
            )
        ];
        //datalabel
        foreach($data['data'] as &$tmpdata){
            $tmpdata['label'] = $this->getDataLabel();
        }
        $option['series'] = $data['data'];
        return $option;
    }

    // 饼型统计图-【客户所属行业统计】
    public function getPieChartOption($data){
        $option = array();

        //提示框
        $option['tooltip'] = $this->getTooltip();


        // 设置标签
        foreach($data['data'] as &$tmpdata){
            $tmpdata['label'] = $this->getDataLabel();
            $tmpdata['label']['formatter'] = '{b}:{c}({d}%)';
        }

        $option['series'] = $data['data'];
        return $option;
    }

}