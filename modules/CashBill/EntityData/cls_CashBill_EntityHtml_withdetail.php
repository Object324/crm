<?php

class cls_CashBill_EntityHtml_withdetail
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
    public $entitythtmlobj;
    public $DetailsHtmlobj;
    public $entitytypeid;
    public $frommdouleFocus;
    public $productdetail_mode;
    public $entitytypeids;
    public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        global $adb;
        $this->record = $record;//单据id,如果record<=0则表示创建
      
        $this->sourceModule = $sourceModule;
        $this->detailView = $detailView;
        $this->sourceIds='';
        if(!empty($sourceIds))
        {
           if(is_array($sourceIds))
           {
               //编辑界面选择原单带出
               $sourceIds = array_filter(array_unique($sourceIds));
           }
           else
                  $sourceIds = explode(',', $sourceIds);

            $this->sourceIds = implode(',', $sourceIds);
        }

        
        
        if ($this->detailView == 'detail') {
            if(empty($sourceIds))
            {
                $sql='select source_list from ld_cashbill where cashbillid=? ';
                $result=$adb->pquery($sql,array($record));
                $sourceIds=array_filter(explode(",",$adb->query_result($result,0,'source_list')));
                $this->sourceIds = implode(',', $sourceIds);
            }
            
        } else if (!empty($this->sourceIds)) {
            if ($_REQUEST['relate_create']) {
                $this->pageType = 'relate_create';//相关信息创建
                $this->entitytypeid = implode(',', $sourceIds);
            } else
                $this->pageType = 'select_source';//收款信息添加行（选择原单的操作）

        } 
        else if ($this->record > 0)//编辑
        {
            if(empty($sourceIds) || !empty($sourceIds) && (sizeof($sourceIds)<=0))
            {
                $sql='select source_list from ld_cashbill where cashbillid=? ';
                $result=$adb->pquery($sql,array($record));
                $sourceIds=array_filter(explode(",",$adb->query_result($result,0,'source_list')));
                $this->sourceIds = implode(',', $sourceIds);
            }
            $this->pageType = 'edit';

        } else {
            $this->pageType = 'create';//创建界面
        }
        
    
    }
    public function setEntityHtmlObj($entityhtmobj)
    {
        $this->entitythtmlobj=$entityhtmobj;
    }
    public function setDetailsObj($module){
        $this->module=$module;
         include (globalStatic::$root_directory.'modules/CashBill/CashBillDetailFieldsHtml.php');
        $focus = CRMEntity::getInstance($this->module);
        $this->DetailsHtmlobj = new CashBillDetailFieldsHtml($focus,$this->module,$this->sourceModule);
        
    }
    
   
    public function createHtml()
    {
        global $adb;
        
        $entitytypeid = $this->entitytypeid;
        
        return $this->DetailsHtmlobj->getTabDetailFieldsHtml($entitytypeid);
    }
    
    //获取源单
    public function getTabDetailHtmlContentSelectSource($rowid)
    {
        
        $this->DetailsHtmlobj->entitytypeids = $this->entitytypeids;
        return $this->DetailsHtmlobj->getTabDetailHtmlContentSelectSource($rowid,$this->sourceModule);
        
    }
}


?>