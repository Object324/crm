<?php
class cls_SendCashBill_EntityHtml_withproduct
{
    /**
     * $detailView=detail表示查看界面
     * $SendCashBillEntityDetail:收款明细信息数据
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
     public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
       
       
        $this->sourceModule = $sourceModule;
        $this->detailView = $detailView;
        if(is_array($sourceIds)){
        }else{
            if(is_string($sourceIds) && !empty($sourceIds)){
                $sourceIds = explode(',', $sourceIds);
            }else{
                $sourceIds = [];
            }
        }

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
            $this->DetailsHtmlobj->productdetail_mode = $productdetail_mode;
            
    		$this->DetailsHtmlobj->frommdouleFocus = $frommdoulefocus;
        }
    }
    
    //获取收款单对应源单的withdetail属性（yes:显示产品分录。no：显示非产品分录）
    public function getSourceWithDetail($sourceModule){
        if(empty($sourceModule)){
            return 'no';
        }
        if(!empty($this->SourceModuleWithDetailarr[$sourceModule])){
            return $this->SourceModuleWithDetailarr[$sourceModule];
        }
        $moduleSourceInfo = $this->getSourceInfo($sourceModule);
        $this->SourceModuleWithDetailarr[$sourceModule] = $moduleSourceInfo['withdetail'];
        return $this->SourceModuleWithDetailarr[$sourceModule];
    }
    
    
    //获取收款单对应源单相关设置信息
    public function getSourceInfo($sourceModule){
        if(!empty($this->SourceInfoarr[$sourceModule])){
            return $this->SourceInfoarr[$sourceModule];
        }
        //获取收款单对应的源单类型
        crm_load_class_file('cls_OptionModule','include/OptionModule');
        $objs=  cls_OptionModule::getInstance($this->module,0);
        $sourceModuleinfoarr=$objs->getSourceModule($this->module);
        foreach($sourceModuleinfoarr as $tmpindex=>$SourceInfo){
            $tmpSourceModulename = $SourceInfo['entitytype'];
            $this->SourceInfoarr[$tmpSourceModulename] = $SourceInfo;
        }
        if(!empty($this->SourceInfoarr[$sourceModule])){
            return $this->SourceInfoarr[$sourceModule];
        }
        else{
            return array();
        }
    }
    
    //获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$table =$this->DetailsHtmlobj->getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
		return $table;
	}
	
    public function lineitemid_html($productToolFieldsValues,$rowid){
       
		if($this->DetailsHtmlobj->focus->id > 0){
			return '<input type="hidden" name="lineitem_id" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['parent_lineitem_id'].'" />';
		}else{
			return '<input type="hidden" name="lineitem_id" detailcolumnname="lineitem_id" value="'.$productToolFieldsValues['lineitem_id'].'" />';
		}
	}

    public function createFormatDataObj()
    {
        
        $pagetype=$this->pageType;
        $id=$this->record;
          
        if($this->pageType=='select_source'||$this->pageType=='relate_create')
        {
            $pagetype='sourcemodule_create';
            
            $id=$this->sourceIds;
            
        }
        crm_load_class_file('cls_SendCashBillDetail_PageRecordValue_withProduct','modules/SendCashBill/EntityData');
        $this->formatDataobj=new cls_SendCashBillDetail_PageRecordValue_withProduct('SendCashBill',$pagetype,$id,$this->sourceModule,$_REQUEST['cashbill_currency_id']);
        
        
    }
    /**
     * 显示原单信息
     *
     * */
    public function showSourceHtml()
    {
        global $adb;
        crm_load_class_file("Detail_Edit_View_finance", 'include/utils');
        $entitytypeids = $this->sourceIds;

        if (($this->pageType == 'select_source' && ($this->sourceModule == 'OutboundOrder' || $this->sourceModule == 'Invoice')) && isset($_REQUEST['cashbill_no'])) {
            $source_focus=CRMEntity::getInstance($this->sourceModule);
            
            $query = 'select id  from '.$source_focus->Detail_table.' where lineitem_id in ( ' . $this->sourceIds . " )";
            $result = $adb->pquery($query, array());
            $num_rows = $adb->num_rows($result);
            for ($i = 0; $i < $num_rows; $i++) {
                $sourceids[] = $adb->query_result($result, $i, 0);
            }
            $entitytypeids = implode(',', $sourceids);

        } else if ($this->pageType == 'edit') {
            $entitytypeids = implode(',', $this->data_sourceids);

        }

        
        return $relatedinformations;
    }
    
    public function getTableHeader()
    {
        
        return $this->DetailsHtmlobj->getProductHtmlHeaderNotr();
        
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