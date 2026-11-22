<?php

class cls_SendCashBill_EntityHtml
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
    public $SourceInfoarr = [];
    public $SourceModuleWithDetailarr = [];
    public $Detailobj;
    public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
        $this->module = 'SendCashBill';
        // $this->sourceIds=$sourceIds;//选择单据id,如果选择的是出库单，销售发票，则$sourceIds是lineitem_id值，因为出库单和销售发票可以选择多个合同信息

        $this->sourceModule = $sourceModule;
        $this->detailView = $detailView;
        $sourceIds = explode(',', $sourceIds);
        $sourceIds = array_filter(array_unique($sourceIds));
        $this->sourceIds = implode(',', $sourceIds);
        
       
        if ($this->detailView == 'detail') {
            $this->pageType = 'detailview';
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
        
        $sourceModulewithDetail = $this->getSourceWithDetail($this->sourceModule);
        if($sourceModulewithDetail=='yes'){
           
            crm_load_class_file('cls_SendCashBill_EntityHtml_withproduct','modules/SendCashBill/EntityData');
            $this->Detailobj=new cls_SendCashBill_EntityHtml_withproduct($record, $sourceIds, $sourceModule, $detailView = '');
            $this->Detailobj->setEntityHtmlObj($this);
            $this->Detailobj->setDetailsObj($this->module);
        }
        else{
            crm_load_class_file('cls_SendCashBill_EntityHtml_withdetail','modules/SendCashBill/EntityData');
            $this->Detailobj=new cls_SendCashBill_EntityHtml_withdetail($record, $sourceIds, $sourceModule, $detailView = '');
            $this->Detailobj->setEntityHtmlObj($this);
            $this->Detailobj->setDetailsObj($this->module);
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
        $sourceModuleinfoarr=getAllSourceModule($this->module);
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

    public function createFormatDataObj()
    {
        $this->Detailobj->createFormatDataObj();
    }
    /**
     * 显示原单信息
     *
     * */
    public function showSourceHtml()
    {
        return $this->Detailobj->showSourceHtml();
        
    }
    
    public function getTableHeader()
    {
        return $this->Detailobj->getTableHeader();
        
    }
   
    public function createHtml()
    {
        if(empty($this->sourceModule)){
            $total = 0;
            $focus = CRMEntity::getInstance($this->module);
            $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
            $system_deploy_351 = 2;
            $length_amountdecimal = 2;
            if(is_numeric($system_351['deploy_value'])){
                $length_amountdecimal = $system_351['deploy_value'];    
            }
            if($focus->id>0){
                $subtotal = $focus->column_fields['hdnSubTotal'];
                $total = $focus->column_fields['hdnGrandTotal'];
                $nopayment = $total - $subtotal;
            }
            else{
                $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldname');
                $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname','total','fieldlabel');
                $total=$focus->column_fields[$fieldname];
                $subtotal = $total;
                $total = $total;
            }
            $table = '';
            //zkt 20220914 BUG0056475收款单 -预售单，少一个收款信息的区块信息
            if ($this->pageType == 'detailview')
            {
                $table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
			     $table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span  name="projuctscol" class=""></span>' . getTranstab('PAYMENTINFORMATION') . '</div></th>';
                $table .="<tr>
            		<td  name='productsStaus' style='display:block;'>";
            }
            $table .= '<table id="proTab" name="proTab" class="ProductTab DetailContentTable" width="100%" border="0" cellpadding="0" cellspacing="0">';
            $table .= '<tr style="display:none"><td ></td><td></td></tr>';//空白行用于通过切换列头及清除源单clearModuleProduct函数判断
            $table .= '<tr tag="tr_subtotaltag" style="display:none"><td tag="subtotaltag"  style="text-align:right"><strong>' . getFixedLabel('SUBTOTAL') . '</strong></td>
                        <td><input type="text" name="subtotal" value="'.setNumberFormatEmptySeperator($subtotal,$length_amountdecimal).'"><span name="span_subtotal">'.setNumberFormatEmptySeperator($subtotal,$length_amountdecimal).'</span></td></tr>';
            //zkt 20221010 BUG0057511http://60.247.158.183:85/crm   四川中卉；分配给赵克听； 付款单-“实际收款金额”字段的名字写错了，改成“实际付款金额”
            $table.='<tr tag="tr_totaltag"><td tag="totaltag" detailfieldname="total" style="text-align:right;width:90%"><strong>' . getFixedLabel('ActualPay') . '</strong></td> <td>';
           $iscurcashbilledit = 'yes';
           if ($this->pageType != 'detailview')
            {
                $table .= '<input tag="money" type="text" onchange=""   style="'.$display.'" name="total" value="' . setNumberFormatEmptySeperator($total,$length_amountdecimal). '">';
                if($iscurcashbilledit=='yes')
                    $table .= '<span style="display:none;" name="span_total">'.setNumberFormat($total,$length_amountdecimal).'</span>';
                else
                    $table .= '<span  name="span_total">'.setNumberFormat($total,$length_amountdecimal).'</span>';
                
            }
            else
            {
                $table .= '<span name="span_total">'.setNumberFormat($total,$length_amountdecimal).'</span>';
            }
            $table.="</td></tr></table>";
            if($this->pageType == 'detailview'){
    			$table .='</td></tr>';
    			$table .='</tbody></table>';
    		}
            return $table;
        }
        
        return $this->Detailobj->createHtml();
        
    }
    
}


?>