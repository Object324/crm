<?php
//首页，销售机会
class cls_TotalList_showPotential extends clsTotal_List
{
    private $scopewhere;
    private $datewhere;
    public function __construct($controller,$scopewhere,$datewhere)
    {
        $this->scopewhere=$scopewhere;
        $this->datewhere=$datewhere;
        parent::__construct($controller);
    }
    public function getallTotal_pageList_query()
   {
    return  'select  distinct potentialid from ld_potential LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_potential.potentialid where deleted=0   and '.$this->scopewhere. $this->datewhere;
   }
   //审批条件 BUG0064516 zxm 20230412 首页销售漏斗，选择审批状态后，点击销售漏斗阶段，“本页合计”和“全部合计”没有跟随变化
    public function isusepagelistquery()
    {
        return 'yes';
    }
   public function getTotalFldCount($page_list_query,$result,$rows) {
	
		$totalhtml='';
		$thistotal=$this->getTotalColumnData($page_list_query,$result,$rows);
        //BUG0061672	已分派	功能BUG	正常处理	首页，销售漏斗，点击显示单据列表，下拉最下方显示两行“本页合计”
        $alltotal = $this->getAllTotalColumnData();
		if(is_array($thistotal))
		{

			$totalhtml.=$this->getTotalRow_html($thistotal,'cur');
            $totalhtml.=$this->getAllTotalRow_html($alltotal,'all');
			//合计行默认演示样式
			//$totalhtml.=$this->getTotalRow_defaulthtml();
		 }
		 return $totalhtml;
	}
    public function setShowCheckbox(){ //BUG0069799 xxy 2023-7-21 首页-销售漏斗组件-点击弹出的销售机会列表弹出层，销售线索列应设置浮显
        return 'no';
    }
}

?>