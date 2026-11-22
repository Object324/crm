<?php
crm_load_class_file('cls_ChartSetInfo','modules/CustomEcharts');
class cls_SqlChartSetInfo extends cls_ChartSetInfo
{
    private $sqlstr_origin;
    public $className = 'cls_SqlChartSetInfo';
    public function getChartSetInfo()
    {
        if(!isset($this->ChartSetInfo) && empty($this->ChartSetInfo)){
            $this->ChartSetInfo = parent::getChartSetInfo();
            $this->ChartSetInfo = array_merge($this->ChartSetInfo,[
                'sqlstr_origin' => $this->sqlstr_origin,
            ]);
        }

        return $this->ChartSetInfo;
    }

    public function setChartInfo($chartInfo) {
        parent::setChartInfo($chartInfo);
        $this->set_sqlstr_origin($chartInfo['sqlstr']);
    }

    public function set_sqlstr_origin($sqlstr_origin){
        $this->sqlstr_origin = $sqlstr_origin;
    }

    /*
    public function set_AxisFields($XAxis,$YAxis){
        foreach ($XAxis as $index => &$XAxisInfo){
            $XAxisInfo[''] = '';
        }
        $this->AxisFields = [
            'XAxis' => $XAxis,
            'YAxis' => $YAxis,
        ];
    }
    */
}

?>