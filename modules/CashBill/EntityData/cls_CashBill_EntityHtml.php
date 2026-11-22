<?php

class cls_CashBill_EntityHtml
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
    public $SourceInfoarr;
    public $SourceModuleWithDetailarr;
    public $Detailobj;
    public function __construct($record, $sourceIds, $sourceModule, $detailView = '')
    {
        $this->record = $record;//单据id,如果record<=0则表示创建
        $this->module = 'CashBill';
        
        $this->sourceModule = $sourceModule;
        $this->detailView = $detailView;
        $sourceIds_arr = explode(',', $sourceIds);
        $sourceIds_arr = array_filter(array_unique($sourceIds_arr));
        $this->sourceIds = implode(',', $sourceIds_arr);
        
       
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
        $focus = CRMEntity::getInstance($this->module);
        $sourceModulewithDetail=$this->getSourceWithDetail($sourceModule);
        if($sourceModulewithDetail=='yes'){
           
            crm_load_class_file('cls_CashBill_EntityHtml_withproduct','modules/CashBill/EntityData');
            $this->Detailobj=new cls_CashBill_EntityHtml_withproduct($record, $this->sourceIds, $sourceModule, $detailView );
            $this->Detailobj->setEntityHtmlObj($this);
            $this->Detailobj->setDetailsObj($this->module);
            
        }
        else{
            crm_load_class_file('cls_CashBill_EntityHtml_withdetail','modules/CashBill/EntityData');
            $this->Detailobj=new cls_CashBill_EntityHtml_withdetail($record, $this->sourceIds, $sourceModule, $detailView );
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

   
    public function createHtml()
    {
        $focus = CRMEntity::getInstance($this->module);
        if(empty($this->sourceModule)||($focus->column_fields['cashtype']=='debuction'&&$focus->id>0)){
            $total = 0;
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
			     $table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span  name="projuctscol" class=""></span>' . getTranstab('GATHERINGINFORMATION') . '</div></th>';
                $table .="<tr>
            		<td  name='productsStaus' style='display:block;'>";
            }
            $table .= '<table id="proTab" name="proTab" class="" width="100%" border="0" cellpadding="0" cellspacing="0">';
            $table .= '<tr style="display:none"><td></td><td></td></tr>';//空白行用于通过切换列头及清除源单clearModuleProduct函数判断
            $table .= '<tr tag="tr_subtotaltag" style="display:none"><td tag="subtotaltag" class="ld-form-item-content-entrytotal" style="text-align:right"><strong>' . getFixedLabel('SUBTOTAL') . '</strong></td>
                        <td class="ld-form-item-content-entrytotal"><input class="ld-input-inner" type="text" name="subtotal" value="'.setNumberFormatEmptySeperator($subtotal,$length_amountdecimal).'"><span name="span_subtotal">'.setNumberFormatEmptySeperator($subtotal,$length_amountdecimal).'</span></td></tr>';

            //jby 20241206 XUQIU20241122-07 【收款】类型的收款单增加“预收抵扣总额”字段
            //添加预收总额字段  deductionreceived_amount
            $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname','deductionreceived_amount');
            if(!empty($tmpfieldinfo)){
                $tmpfieldlable = $tmpfieldinfo->getFieldLabel();
                $table.='<tr tag="tr_deductionreceived_amount" style="display:none;"><td class="ld-form-item-content-entrytotal" tag="deductionreceived_amounttag" detailfieldname="deductionreceived_amount" style="text-align:right;width:90%"><strong>'.$tmpfieldlable.'</strong></td><td class="ld-form-item-content-entrytotal">';
                if ($this->pageType != 'detailview'){
                    $table .= '<input tag="deduction" class="ld-input-inner" type="text"  style="display:none;" name="deductionreceived_amount" value="">';
                    $table .= '<span  name="span_deductionreceived_amount"></span>';
                }else{
                    $table .= '<span name="span_deductionreceived_amount">'.setNumberFormat($subtotal-$total,$length_amountdecimal).'</span>';
                }
                $table .= '</td></tr>';
                unset($tmpfieldlable);
            }
            unset($tmpfieldinfo);


            $table.='<tr tag="tr_totaltag"><td class="ld-form-item-content-entrytotal" tag="totaltag" detailfieldname="total" style="text-align:right;width:90%"><strong>' . getFixedLabel('ActualReceipts') . '</strong></td> <td class="ld-form-item-content-entrytotal">';
            $iscurcashbilledit = 'yes';
            if ($this->pageType != 'detailview')
            {
                //zkt 20221104 BUG0058117（http://crm.airmaster.com.cn/crm）收款单-预收款，右下角本次收款金额输入框太小，当输入位数多时，很难看到输入进去的是多少
				//zkt 20221101 BUG0058226 收款单，编辑修改金额，再编辑还是显示之前的金额（subtotal）没有修改
                $table .= '<input tag="money" class="ld-input-inner" type="text" onchange="getChooseRelateLists.getInstance(CrmPopup.getPopupObj(\'last\')).setsubtotalvalue()"   style="'.$display.'" name="total" value="' . (setNumberFormatEmptySeperator($total,$length_amountdecimal)) . '">';
                if($iscurcashbilledit=='yes')
                    $table .= '<span style="display:none;" name="span_total">'.setNumberFormat($subtotal,$length_amountdecimal).'</span>';
                else
                    $table .= '<span  name="span_total">'.setNumberFormat($subtotal,$length_amountdecimal).'</span>';
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