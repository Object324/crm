<?php
class cls_CashBill_EntityHtml_withproduct
{
    /**
     * $detailView=detail表示查看界面
     * $cashbillEntityDetail:收款明细信息数据
     * */
    var $record;
    var $module;
    var $sourceIds;
    var $sourceModule;
    var $detailView;
    var $pageType;
    var $table_header;
   var $formatDataobj;
   public  $frommdouleFocus;
    public  $productdetail_mode;
    public  $entitythtmlobj;
    public  $DetailsHtmlobj;
    public  $DetailsDataobj;
    public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
       
       
        $this->sourceModule = $sourceModule;
        $this->detailView = $detailView;
        $sourceIds = explode(',', $sourceIds);
        $sourceIds = array_filter(array_unique($sourceIds));
        $this->sourceIds = implode(',', $sourceIds);
       
        if ($this->detailView == 'detail') {
            $this->pageType = 'detail';
        } else if (!empty($this->sourceIds)) {
            if ($_REQUEST['relate_create']) {
                $this->pageType = 'relate_create';//相关信息创建
            } else
                $this->pageType = 'select_source';//收款信息添加行（选择原单的操作）

        } else if ($this->record > 0)//编辑
        {

            $this->pageType = 'edit';

        } else {
            $this->pageType = 'create';//创建界面
        }
        //dump($this->pageType);
        if($this->pageType=='create'||$this->pageType=='select_source'||$this->pageType=='relate_create')
        {
            $this->productdetail_mode='sourcemodule_create';
        }
    
    }
    public function setEntityHtmlObj($entityhtmobj)
    {
        $this->entitythtmlobj=$entityhtmobj;
    }
    public function setDetailsObj($module){
        $this->module=$module;
        $sourceModule=$this->sourceModule;
        
        $this->DetailsHtmlobj = crm_load_class_obj('cls_productDetailsHtml',"modules/$module/productDetail",array($module,$sourceModule));
        $this->DetailsDataobj = crm_load_class_obj('cls_productDetailsData',"modules/$module/productDetail",array($module,$sourceModule));
      
        $this->DetailsHtmlobj->productdetail_mode = $this->productdetail_mode;
        $record=$this->record;
        if((empty($record)&&!empty($ids))||(empty($record)&&empty($ids)&&!empty($sourceModule))){
            $frommdoulefocus=CRMEntity::getInstance($sourceModule);
           
            $frommdoulefocus->id=$this->sourceIds ;
            $this->DetailsHtmlobj->productdetail_mode = $this->productdetail_mode;
            
    		$this->DetailsHtmlobj->frommdouleFocus = $frommdoulefocus;
        }
    }
    
    
    //获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$table =$this->DetailsHtmlobj->getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
		return $table;
	}
	
    
   
    public function createHtml()
    {
        $productdetail_mode = $this->pageType;
        $frommdoulefocus=$this->frommdouleFocus;
      
        $productdetail_mode = $this->productdetail_mode;
        return $this->DetailsHtmlobj->getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
        
    }
}


?>