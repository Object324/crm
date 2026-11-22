<?php
//editor:gyq_161 reason:清除该文件所有id="   2022/08/08 18:54
/**
 * 修改编码格式:统一编码：UTF-8
 * @author zkt
 */
require_once($root_directory.'include/TabDetailFields/cls_TabDetailFieldsHtml.php');
Class SendCashBillDetailFieldsHtml extends cls_TabDetailFieldsHtml {
	function __construct($focus,$module,$sourceModule){
		 $this->detailfieldruleobj=cls_detailfieldrule::getInstance($module);
        //setColumnValues:在新增或编辑/查看的的getBlockInformation中已赋值
        //edit:can 20200721 明细字段的布局规则
         $fieldruleproperty= $this->detailfieldruleobj->getFieldRuleProperty();
         $this->fieldruleHideColumn_arr=$fieldruleproperty['hidecolumns'];
         
		//获取明细数据类
		crm_load_class_file("SendCashBillTabDetailFieldsData",'modules/SendCashBill');
		//获取明细自定义字段对应控件标签类
		crm_load_class_file('TabDetailFieldsHtmlTd','include/TabDetailFields');
		$this->tabDetailFieldData = new SendCashBillTabDetailFieldsData($focus,$module,$sourceModule);
		$this->TabDetailFieldsHtmlTd = new TabDetailFieldsHtmlTd($focus,$module);
        $this->TabDetailFieldsHtmlTd->setFieldruleHideColumn_arr($this->fieldruleHideColumn_arr);
		$this->focus = $focus;
		$this->setTabDetailFieldsAttribute();
		$this->module = $module;
        $this->getPageType();
	}

	//获取付款单明细
	public function getTabDetailFieldsHtml($entitytypeid=''){
		$table_fixed_style = '';
		//editor:gyq_161 reason:赋值元素id的镜像name   2019/11/27 16:18
		if($this->focus->mode == 'Details'){
			$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
			$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span  name="projuctscol" class=""></span>' . getTranstab('PAYMENTINFORMATION') . '</div></th>';
            $table .="<tr>
            		<td  name='productsStaus' style='display:block;'>";
			$table_fixed_style = 'table-layout:fixed;word-break: break-all; word-wrap: break-word;';//xxy 2023-11-16 表格固定	
		}
       
		$this->entitytypeid = $entitytypeid;
        $nullfield='';
        if(is_array($this->tabDetailFieldData->module_nullfield))
              $nullfield=implode('##',$this->tabDetailFieldData->module_nullfield);

		$table .='<input  type="hidden" name="nullfield" value="'.$nullfield.'">';//当前模块空行基准字段
		$table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//设置产品分录中最后一行选择产品后是否自动新增一个空行
		$table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//当前模块的所有自定义字段信息
		$table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//系统参数数量小数位控制
		$table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//系统参数单价小数位控制
        

        $table .='<div  name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
		$table .='<table tablewidth="'.$this->table_width.'" class="" id="proTab" name="proTab" style="width:'.$this->table_width.'mm;'.$table_fixed_style.'" border="0" align="center" cellpadding="0" cellspacing="0">';
		$table .='<input type="hidden" name="table_width" value="'.$this->table_width.'">';
		$table .='<input type="hidden" name="select_columns" value="'.$select_columns.'" />';
		$table .='<input type="hidden" name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
        if($this->focus->mode != 'Details'){
			$table .='<tr></tr>';
		}
		$table .=$this->getTabDetailHtmlHeader();
		$table .=$this->getTabDetailHtmlContent();
		$table .=$this->getTabDetailHtmlSubTotalTr();
		$table .='</table>';
		$table .='</div>';
		if($this->tabDetailFieldData->focus->mode != 'Details'){
			
				$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
				
			
		}
		
		$table .=$this->getTabDetailHtmlTotalTr();
		if($this->focus->mode == 'Details'){
			$table .='</td></tr>';
			$table .='</tbody></table>';
		}
		return $table;
	}
    
    //选择源单行
	public function getTabDetailHtmlContentSelectSource($jsAddRowid='',$sourceModule=''){
		//$columnvalue = $this->tabDetailFieldData->getTabDetailHtmlContentDataSelectSource($jsAddRowid,$this->entitytypeids,$sourceModule);
		for($i = 0; $i<$this->tabDetailFieldData->productrows; $i++){
			if(!empty($jsAddRowid)){//增加行
				$rowid = $jsAddRowid;
			}else{
				$rowid = $i+1;
			}
            if($rowid%2 ==0) {
                $tableContent .='<tr valign="top" detaildeleted="no" rowindex="'.$rowid.'" class="lvtColDataBj dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'On\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
            }
            else{
                $tableContent .='<tr valign="top"  detaildeleted="no" rowindex="'.$rowid.'" class="lvtColData dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'on\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
            }
                     
            $tableContent .= '<input type="hidden"  name="hidden_rowid_'.$rowid.'" value = "0" />';//产品明细中间行内容
			if($this->focus->mode != 'create' && empty($jsAddRowid) && vtlib_purify($_REQUEST['isDuplicate']) !='true'){
				$tableContent .='<input type="hidden"  name="'.$this->focus->Detail_table_id.'" value="'.$columnvalue[$i][$this->focus->Detail_table_id].'" />';
			}
            $tableContent .= '<input type="hidden"  name="parent_lineitem_id" value = "'.$columnvalue[$i]['parent_lineitem_id'].'" />';//产品明细中间行内容
			if($this->focus->mode !='Details' && $this->operation_row === 0){//查看界面没有“删除”或者上下移动的按钮
				$tableContent .='<td style="display:none;width:0mm"></td>';//隐藏操作列
			}
            $tableContent .='<td seqno="yes" style="text-align:center;width:25mm">'.$rowid.'</td>';            
			//获取字段自动带出值信息
           
            
			$relatedData = $this->tabDetailFieldData->getFieldsRelatedData($columnvalue[$i],$this->entitytypeid);
           
			foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnanme => $field){
				$column_value = $columnvalue[$i][$columnanme];
				if($field->getNewLine() == 0){
					//获取自定义字段对应的文本类型
                   
					$tableContent .= $this->TabDetailFieldsHtmlTd->getTabDetailsHtmlTd($this->tabDetailFieldData->module,$field,$column_value,$rowid,$jsAddRowid,$relatedData,$columnvalue[$i]);
				}

			}	
			$tableContent .= '</tr>';
		}
		return $tableContent;
	}
	
	
}

?>