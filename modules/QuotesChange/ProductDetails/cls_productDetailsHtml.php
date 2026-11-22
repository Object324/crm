<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
/**
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_productDetailsHtml extends Parent_ProductDetailsHtml{
	private $change_type;
	public function __construct($module){
		parent::__construct($module);
		if(empty($_REQUEST['change_type'])){
			$this->change_type = 'add';
		}else{
			$this->change_type = $_REQUEST['change_type'];
		}
        
        //zkt 20220615 51738（https://81mis.com/kfbtest/index.php）报价单》详情，相关创建报价变更单，追加/修改 》分录显示异常
        //分录列总宽度
        if($this->width>255&&($this->change_type == 'add'||$this->change_type == 'edit'))
        {
            foreach($this->ProductDetailsData->presenceToolField as $columnname => &$productToolFieldInfo){
                  if(is_array($this->fieldruleHideColumn_arr)&&in_array($columnname,$this->fieldruleHideColumn_arr)){
        		      continue;
        		  }
    			if($productToolFieldInfo->getNewLine() == 0){
    				//计算明细表宽度
                    if($columnname == 'pro_id'||$columnname == 'prosheet')
                    {
                        
                        $this->width -= $productToolFieldInfo->getWidth();
                    }
    			}
                
    		}
        }

	}

	//获取明细列头
	public function getProductHtmlHeader(){
		if($this->change_type == 'replace'){
			return parent::getProductHtmlHeader();
		}else{
			$table = '<tr class="Tdhead">';
			//单据在编辑和新增的时候显示工具列宽（删除产品、上下移动按钮）
			if($this->productdetail_mode != 'details'){
				$table .='<td  style="width:0mm;display:none" align="right" ></td>';//工具列宽
			}
			$table .= $this->getRowNo_header();
			//中间行自定义字段列头
			foreach($this->productToolTr as $productToolFieldInfo){
				if($productToolFieldInfo->getNewLine() == 1)continue;
				if($productToolFieldInfo->getColumnName() == 'pro_id'){
				    //不是替换时 不需要必填
				    $typeofdata = $productToolFieldInfo->getTypeOfData();
                    $typeofdata = str_replace('M','O',$typeofdata);
                    $productToolFieldInfo->settypeOfData($typeofdata);
                    continue;}
				if($productToolFieldInfo->getColumnName() == 'prosheet')continue;
				$typeofdata = explode('~',$productToolFieldInfo->getTypeOfData());
				$width=$productToolFieldInfo->getWidth();
				$fieldlabel = $productToolFieldInfo->getFieldLabel();
				if($productToolFieldInfo->getColumnName() == 'productname'){
					//$fieldlabel = getFixedLabel('PRODUCTNAME');
				}
				if($productToolFieldInfo->getColumnName() == 'productsheet'){
					$fieldlabel = getFixedLabel('Specifications');
				}
				if($typeofdata[1] == 'M'&&$productToolFieldInfo->getinput_type()!='1'){
					$table .='<td id="productdetails_header_'.$productToolFieldInfo->getColumnName().'" head_detailfieldname="' . $productToolFieldInfo->getColumnName() . '" class="ld-form-item-content-entrytitle ld-form-item-content-entrytitle-first" style="width:'.$width.'mm"><font color="red">*</font>'.$fieldlabel.'</td>';
				}else{
					$table .='<td id="productdetails_header_'.$productToolFieldInfo->getColumnName().'" head_detailfieldname="' . $productToolFieldInfo->getColumnName() . '" class="ld-form-item-content-entrytitle ld-form-item-content-entrytitle-first" style="width:'.$width.'mm">'.$fieldlabel.'</td>';
				}
			}
			$table .='</tr>';
			return $table;
		}
	}

	/**
    * 获取对应模块编辑、新增页的html格式
    * @param $column_value,$rowid,$productinfo,$columnname
    * @return $producttooldetails
    * @author Chj 2015/5/29
    */
	public function getProductToolFieldEditTd($productinfo,$field,$showvalue){
		if($this->change_type == 'add'){
			if($productinfo['columnname'] == 'pro_id')return '';
			if($productinfo['columnname'] == 'prosheet')return '';
			return parent::getProductToolFieldEditTd($productinfo,$field,$showvalue);
		}else if($this->change_type == 'edit'){
			if($productinfo['columnname'] == 'pro_id')return '';
			if($productinfo['columnname'] == 'prosheet')return '';
			return parent::getProductToolFieldEditTd($productinfo,$field,$showvalue);
		}else{
			if($this->productdetail_mode == 'sourcemodule_create'){
				if($productinfo['columnname'] == 'productname' && $productinfo['uitype'] == 70){
					$productinfo['productid'] = 0;
					$productinfo['lineitem_id'] = 0;
					$productinfo['parent_lineitem_id'] = 0;
					$productinfo['column_value'] = 0;
					$showvalue = '';
				}
			}
            $rowid = $productinfo['rowid'];
			$parent_table = parent::getProductToolFieldEditTd($productinfo,$field,$showvalue);
			if($productinfo['columnname'] == 'pro_id'){
				
					

					if($this->productdetail_mode == 'details'){
						$data = $this->frommdouleFocus->getProductFor_Parent_lineitemid($productinfo['parent_lineitem_id']);
                        
						$table = '<td><a href="javascript:;" referencemodule="Products" referencerecord="'.$data['productid'].'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$data['productname'].'</a></td>';
						
					}else if($this->productdetail_mode == 'edit'){
						$rowid = $productinfo['rowid'];
						$data = $this->frommdouleFocus->getProductFor_Parent_lineitemid($productinfo['parent_lineitem_id']);
						$table ='<td><input type="hidden" name="hidden_lineitem_id" detailcolumnname="hidden_lineitem_id" value="'.$data['lineitem_id'].'" />';
						$table .='<input detailcolumnname="selectSourceModuleid" type="hidden" value="'.$data['id'].'" name="selectSourceModuleid">
								<input detailcolumnname="lineitem_id" type="hidden" value="'.$data['lineitem_id'].'" name="lineitem_id">
								<input type="hidden" name="entitytypeid" detailcolumnname="entitytypeid" value="'.$data['id'].'">
								<input type="hidden" detailcolumnname="pro_id" name="pro_id" value="'.$data['productid'].'">
								<span id="span_pro_name'.$rowid.'">'.$data['productname'].'</span></td>';
                        $this->productToolFieldsValues[$rowid - 1][$productinfo['columnname']] = $data['productid'];
					}else if(!empty($_REQUEST['quote_id'])){
					       $quote_id = $_REQUEST['quote_id'];
//					       @edit:liushuai,2021-02-18,reason:0044654: （https://61mis.com/kfbcrm [^]）新建报价变更单之后，‘产品名程（更换前）’字段中没有数据
//                            报价单关联创建报价变更单（更换）产品行
					$rowid = $productinfo['rowid'];
						$data = $this->frommdouleFocus->getInventoryProducts_info($quote_id);//获取报价单和报价变更单(追加)产品明细信息
						$table ='<td><input type="hidden" name="hidden_lineitem_id" detailcolumnname="hidden_lineitem_id" value="'.$data[$rowid - 1]['lineitem_id'].'" />';
						$table .='<input detailcolumnname="selectSourceModuleid" type="hidden" value="'.$quote_id.'" name="selectSourceModuleid">
										<input detailcolumnname="lineitem_id" type="hidden" value="'.$data[$rowid - 1]['lineitem_id'].'" name="lineitem_id">
										<input type="hidden" id="entitytypeid" detailcolumnname="entitytypeid" value="'.$quote_id.'">
										<input type="hidden" detailcolumnname="pro_id" name="pro_id" value="'.$data[$rowid - 1]['productid'].'">
										<span id="span_pro_name">'.$data[$rowid - 1]['productname'].'</span></td>';
                        //zkt 20230525 BUG0066983 从报价单下推报价变更单，提示无更换前产品名称，单页面上更换前产品名称存在。 
                        $this->productToolFieldsValues[$rowid - 1][$productinfo['columnname']] = $data[$rowid - 1]['productid'];
                        $this->productToolFieldsValues[$rowid - 1]['parent_lineitem_id'] = $data[$rowid - 1]['lineitem_id'];
                        $this->productToolFieldsValues[$rowid - 1]['selectSourceModuleid'] = $quote_id;
					}
				
			}else if($productinfo['columnname'] == 'prosheet'){
			     
                //date:2021-9-6  edit:duan reason: 0047810,创建报价变更单时，无法带出规格型号
                 if($productinfo['productid']==""&&!empty($_REQUEST['quote_id'])){
			         $quote_id = $_REQUEST['quote_id'];
                     $rowid = $productinfo['rowid'];
                     $data = $this->frommdouleFocus->getInventoryProducts_info($quote_id);
                     if($data[$rowid-1]['productid']>0){
                        $productinfo['productid'] = $data[$rowid-1]['productid'];
                        
                     }
			     }
                
				if($productinfo['productid'] > 0){
					
					if($this->productdetail_mode == 'details'){
						$productsheet = '';
						if($showvalue['rawvalue'] > 0){
							$pro_focus = CRMEntity::getInstance('Products');
							$pro_focus->retrieve_entity_info($showvalue['rawvalue'],'Products');
							$productsheet = $pro_focus->column_fields['productsheet'];
						}
                     
						$table = '<td>'.$productsheet.'</td>';
						
					}else if($this->productdetail_mode == 'sourcemodule_create'){
						$pro_focus = CRMEntity::getInstance('Products');
						$pro_focus->retrieve_entity_info($productinfo['productid'],'Products');
						$rowid = $productinfo['rowid'];
						$table ='<td><input type="hidden" id="prosheet'.$rowid.'" name="prosheet'.$rowid.'" value="'.$productinfo['productid'].'">
								<span id="span_prosheet'.$rowid.'">'.$pro_focus->column_fields['productsheet'].'</span></td>';
					}else{
						$productsheet = '';
						if($showvalue['rawvalue'] > 0){
							$pro_focus = CRMEntity::getInstance('Products');
							$pro_focus->retrieve_entity_info($showvalue['rawvalue'],'Products');
							$productsheet = $pro_focus->column_fields['productsheet'];
						}
						$rowid = $productinfo['rowid'];
						$table ='<td><input type="hidden" id="prosheet'.$rowid.'" detailcolumnname="prosheet" name="prosheet" value="'.$showvalue['rawvalue'].'">
								<span name="span_prosheet" detailcolumnname="span_prosheet">'.$productsheet.'</span></td>';
					}
				}else{
					$table = '<td></td>';
				}
			}else if($productinfo['columnname'] == 'quantity'){
				if('sourcemodule_create' == $this->productdetail_mode){
					$quote_id = $_REQUEST['quote_id'];
					$data = $this->frommdouleFocus->getInventoryProducts_info($quote_id);
					foreach($data as $infos){
						$quantity = $infos['quantity'];
						if($quantity == 0){
							$quantity = '';
						}
						if($productinfo['productid'] == $infos['productid']){
							$showvalue['rawvalue'] = $quantity;
							$showvalue['value'] = $infos['quantity'];
						}
					}
                    $this->productToolFieldsValues[$rowid - 1][$productinfo['columnname']] = $showvalue['value'];
					$table = parent::getProductToolFieldEditTd($productinfo,$field,$showvalue);
				}else{
					$table = $parent_table;
				}
			}else if('zhongneng_ware_qty' == $productinfo['columnname']){
				$value = 0;
				if('sourcemodule_create' == $this->productdetail_mode){
					$product_wareqty = 0;
				}else{
					if(($this->focus->mode == 'edit' || $this->focus->id > 0)){
						$wareid = $this->focus->column_fields['wareid'];
						if(!empty($wareid)){
							crm_load_function_file('getZN_ProductQty','include/utils','ListViewUtils');
							$product_wareqty = getZN_ProductQty($productinfo['productid'],$wareid);
						}
					}
				}
				$table = '<td id="productdetails_input_'.$productinfo['controlbol'].'" align="right"><input type="hidden" id="'.$productinfo['controlbol'].'" name="'.$productinfo['controlbol'].'" value="" /><span id="span_'.$productinfo['controlbol'].'">'.$product_wareqty.'</span></td>';
			}
			else{
				$table = $parent_table;
			}
		}
		return $table;
	}

	//获取明细小计行
	public function getProductHtmlSubTotalTr(){
	   
  
		if($this->change_type == 'add'||$this->change_type=='edit'){
			$colspanWdith=0;
			
			$subtotalTrKey = array_keys($this->ProductDetailsData->subtotalTrData);
            
			$productSubTotalTdColum=array();
			foreach($this->productToolTr as $key => $productToolFieldInfo){//循环行
				$columnname = $productToolFieldInfo->getColumnName();
                if('prosheet'==$columnname||$columnname=='productsheet'||$columnname=='pro_id')
                    continue;
                $tablename=$productToolFieldInfo->getTableName();
              
                  if($tablename=='ld_quoteschangedetail'&&$columnname=='discount_amount')
                {
                   
                    $productSubTotalTdColum[$key]='productdetail_discount_amount';
                }
                else
                $productSubTotalTdColum[$key]=$productToolFieldInfo->getColumnName();
				$productSubTotalTdValue[$key]['width'] = floor (($productToolFieldInfo->getWidth()/$this->width)*100);
			
				$productSubTotalTdTypedata[$key]=$productToolFieldInfo->getTypeOfData();
				if(!empty($this->ProductDetailsData->subtotalTrData)){
					$productSubTotalTdValue[$key]['value'] = $this->ProductDetailsData->subtotalTrData[$key];
				}
				if($key < $subtotalTrKey[0]){
					if($productToolFieldInfo->getColumnName() == 'pro_id')continue;
					if($productToolFieldInfo->getColumnName() == 'prosheet')continue;
					$colspanWdith = $colspanWdith + floor (($productToolFieldInfo->getWidth()/$this->width)*100);
				}
			}
			//$this->mobileSubtotalDbValue = $productSubTotalTdValue;
            if ($subtotalTrKey[0] > 0) {
                $colspan = 0;
                for($i = 0;$i<count(array_keys($productSubTotalTdValue));$i++){
                    if(array_keys($productSubTotalTdValue)[$i] < $subtotalTrKey[0]){
                        $colspan += 1;
                    }else{
                        break;
                    }
                }
                $rowColspan =  $colspan;
//            $colspan = $subtotalTrKey[0];
//            $rowColspan = $subtotalTrKey[0];
            } else {
                $colspan = $rowColspan = 1;
            }
		   // echo
            if ((empty($this->focus->id)) || (!empty($this->focus->mode) && !empty($this->focus->id))) {
                $colspanWdith = $colspanWdith + 1;
            }

			/*foreach($this->productToolTr as $key => $productToolFieldInfo){//循环行
				if(($productToolFieldInfo->getColumnName() == 'pro_id' || $productToolFieldInfo->getColumnName() == 'prosheet' || $productToolFieldInfo->getColumnName() == 'productsheet') && $key < $subtotalTrKey[0]){
					$rowColspan -= 1;
				}
			}*/
			$tableContent ='<tr>';

			for($tdi = 0; $tdi<$rowColspan+1; $tdi++){
				if($rowColspan == $tdi){
					if($this->module == 'Checks'){
						$tableContent .= "<td class='ld-form-item-content-entrytotal'>".getFixedLabel('SUM')."</td>";
					}else{
						$tableContent .= "<td class='ld-form-item-content-entrytotal'>".getFixedLabel('SUBTOTAL')."</td>";
					}
				}else{
					$tableContent .= '<td class=\'ld-form-item-content-entrytotal\'></td>';
				}
			}
            
			foreach($productSubTotalTdValue as $key=> $productValueInfo){
				if($key >= $colspan){
					if(isset($productValueInfo['value'])){
						$columnname = $productSubTotalTdColum[$key];
                        
						$fieldinfo = $this->ProductDetailsData->presenceToolField[$columnname];
                        
						$lengthdecimaldigits = $this->ProductDetailsData->getDecimalDigits($fieldinfo,$productSubTotalTdTypedata[$key]);
						$tableContent .= '<td class=\'ld-form-item-content-entrytotal\' align="right" name="subtotal_'.$productSubTotalTdColum[$key].'"  style="font-weight:bold;">' . setNumberFormat($productValueInfo['value'],$lengthdecimaldigits) . '</td>';
					}else{
						$tableContent .= '<td class=\'ld-form-item-content-entrytotal\' name="subtotal_'.$productSubTotalTdColum[$key].'" >&nbsp;</td>';
					}
				}
			}
			return $tableContent;
		}else{
		 
			return parent::getProductHtmlSubTotalTr();
		}
	}
	
	//获取明细添加行按钮
	public function getAddProductDetailBtn() {
		if($this->change_type == 'replace'){
			return '';
		}else{
			return parent::getAddProductDetailBtn();
		}
	}

	//获取明细行默认的产品显示行数
	public function getModuleProductRow(){
		
		if($this->change_type == 'add' || $this->change_type == 'edit'){
			return parent::getModuleProductRow();
		}else{
			if(!empty($_REQUEST['quote_id'])){
				$quote_id = $_REQUEST['quote_id'];
				//报价单产品行
				$data = $this->frommdouleFocus->getInventoryProducts_info($quote_id);
				if(sizeOf($data) <= 0)
					return 1;
				else
					return sizeOf($data);
			}else{
				return 1;
			}
		}
	}

}
?>