<?php

class cls_SendCashBill_EntityHtml_withdetail
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
    public $SourceModuleWithDetailarr = [];
    public $entitythtmlobj;
    public $DetailsHtmlobj;
    public $frommdouleFocus;
    public $productdetail_mode;
    public $entitytypeid;
    public $entitytypeids;
    public $SourceInfoarr = [];
    public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        global $adb;
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
        $sourceModulewithDetail = $this->getSourceWithDetail($this->sourceModule);
        
        
        if ($this->detailView == 'detail') {
            if(sizeof($sourceIds)<=0)
            {
                $sql='select source_list from ld_sendcashbill where sendcashbillid=? ';
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

        } else if ($this->record > 0)//编辑
        {
             if(sizeof($sourceIds)<=0)
                {
                    $sql='select source_list from ld_sendcashbill where sendcashbillid=? ';
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
         include (globalStatic::$root_directory.'modules/SendCashBill/SendCashBillDetailFieldsHtml.php');
        $focus = CRMEntity::getInstance($this->module);
        $this->DetailsHtmlobj = new SendCashBillDetailFieldsHtml($focus,$this->module,$this->sourceModule);
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
        $objs=cls_OptionModule::getInstance($this->module,0);
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