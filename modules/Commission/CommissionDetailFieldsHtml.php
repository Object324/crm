<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
	Class CommissionDetailFieldsHtml extends cls_TabDetailFieldsHtml {
		
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
		}
		/**
		 * 获取佣金单明细
		 * @param $entitytypeid 源单id,相关信息、创建创建会用到
		 * @return
		 * @author Chj
		 */
		// public function getTabDetailFieldsHtml($entitytypeid=''){
		// 	if($this->focus->mode == 'Details'){
		// 		$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
		// 		$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('COMMISSIONINFO') . '</div></th>';
        //         $table .="<tr>
        //         		<td name='productsStaus' style='display:block;'>";
	                		
		// 	}
		// 	$this->entitytypeid = $entitytypeid;
            
			// $table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//当前模块空行基准字段
			// $table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//设置产品分录中最后一行选择产品后是否自动新增一个空行
			// $table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//当前模块的所有自定义字段信息
			// $table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//系统参数数量小数位控制
			// $table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//系统参数单价小数位控制
            //ls 2022-07-22 带分录的表单，单据新建/编辑/复制界面，单据表体增加众向列头固定
        //     if($this->focus->mode != 'Details'){
        //         $table .='<div class="editrelhead">';
        //         $table .='<span><b>' . getTranstab('COMMISSIONINFO') . '</b></span>';
        //         $table .='<span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span>';
        //         $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
        //         $table .='</div>';
        //     }
		// 	$table .='<div name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
		// 	$table .='<table class="ProductTab DetailContentTable" id="proTab" name="proTab" style="width:'.$this->table_width.'mm" border="0" align="center" cellpadding="0" cellspacing="0">';
		// 	$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
		// 	$table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
		// 	/*if($this->focus->mode != 'Details'){
		// 		$table .='<tr align="left">';
				// $productToolMore = count($this->tabDetailFieldData->tabPresenceDetailFields) + 2 + $this->tabDetailFieldData->sourcmodule_td;//列头合并列 +2 表示操作列、序号列 + 源单列(每一个源单占2列)
		// 		//$table .='<th colspan="'.$productToolMore.'"><div class="editrelhead" style="padding-left: 0px;">' . getTranstab('COMMISSIONINFO') . '</div></th>';
        //         $table .='<th colspan="'.$productToolMore.'"><div class="editrelhead" style="padding-left: 0px;">' . getTranstab('COMMISSIONINFO') . 
        //                 ' <span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span></div></th>';
                        
			
		// 		$table .='</tr>';
		// 	}*/
        //     $table .='<tr></tr>';
		// 	$table .=$this->getTabDetailHtmlHeader();
		// 	$table .=$this->getTabDetailHtmlContent();
		// 	$table .=$this->getTabDetailHtmlSubTotalTr();
		// 	$table .='</table>';
		// 	$table .='</div>';
		// 	if($this->tabDetailFieldData->focus->mode != 'Details'){
		// 		$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
		// 		/*$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
		// 					$table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW') .'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" /></td></tr>';
		// 					$table .='</table>';*/
		// 	}
           
		// 	$table .=$this->getTabDetailHtmlTotalTr();
		// 	if($this->focus->mode == 'Details'){
		// 		$table .='</td></tr>';
		// 		$table .='</tbody></table>';
		// 	}
		// 	return $table;
		// }
		
		//佣金单明细最后一行 合计
		public function getProductHtmlLastContent(){
			
		}	
       
	}

?>