<?php
crm_load_class_file('cls_getPenetrateModuleList','modules/lingdang/cls_Report');

/**
 * @author XLL
 * @description 穿透到子图的类
 */
class PenetrateToChildChart extends cls_getPenetrateModuleList
{
    public $ChildChartData;
    public $SearchBtnHtml = '';
    public function __construct(){
        parent::__construct();
    }

    public function getChildChartData(){

    }

    public function getChildChart()
    {
        $this->getChildChartData();
        $this->getSearchBtnHtml();
        $this->commonReturn();
    }

    public function getSearchBtnHtml(){

    }

    public function commonReturn()
    {
        global $languageType;
        $smarty = new lingdangCRM_Smarty();

        $smarty->assign('languageType',$languageType);
        $smarty->assign('scopemodule',$this->scopemodule);
        $smarty->assign('SearchBtnHtml',$this->SearchBtnHtml);
        $content = $smarty->fetch('PenetrateToChildChart.tpl');

        ConvertTojsonString(1, [
            'content'=>$content,
            'ChildChartData'=>$this->ChildChartData,
            'penetrateModule'=>$this->penetrateModule,
            'scopemodule'=>$this->scopemodule,
            'title'=>$this->popuptitle,
        ], 'success');
    }
}