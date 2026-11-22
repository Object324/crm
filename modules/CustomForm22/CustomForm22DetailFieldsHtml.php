<?php
	/**
	 * 淇敼缂栫爜鏍煎紡:缁熶竴缂栫爜锛歎TF-8
	 * @author Chj
	 */
	crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
	Class CustomForm22DetailFieldsHtml extends cls_TabDetailFieldsHtml {
		
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
		}
		/**
		 * 鑾峰彇浣ｉ噾鍗曟槑缁?
		 * @param $entitytypeid 婧愬崟id,鐩稿叧淇℃伅銆佸垱寤哄垱寤轰細鐢ㄥ埌
		 * @return
		 * @author Chj
		 */
		// public function getTabDetailFieldsHtml($entitytypeid=''){
		// 	if($this->focus->mode == 'Details'){
		// 		$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
		// 		$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('CustomForm22') . '</div></th>';
        //         $table .="<tr>
        //         		<td name='productsStaus' style='display:block;'>";
	                		
		// 	}
		// 	$this->entitytypeid = $entitytypeid;
            
		// 	$table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//褰撳墠妯″潡绌鸿鍩哄噯瀛楁
		// 	$table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//璁剧疆浜у搧鍒嗗綍涓渶鍚庝竴琛岄€夋嫨浜у搧鍚庢槸鍚﹁嚜鍔ㄦ柊澧炰竴涓┖琛?
		// 	$table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//褰撳墠妯″潡鐨勬墍鏈夎嚜瀹氫箟瀛楁淇℃伅
		// 	$table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//绯荤粺鍙傛暟鏁伴噺灏忔暟浣嶆帶鍒?
		// 	$table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//绯荤粺鍙傛暟鍗曚环灏忔暟浣嶆帶鍒?
        //     if($this->focus->mode != 'Details'){
        //         $table .='<div class="editrelhead">';
        //         $table .='<span><b>' . getTranstab('CustomForm22') . '</b></span>';
        //         $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
        //         $table .='</div>';
        //     }
		// 	$table .='<div name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
		// 	$table .='<table class="ProductTab DetailContentTable" id="proTab" name="proTab" style="width:'.$this->table_width.'mm" border="0" align="center" cellpadding="0" cellspacing="0">';
		// 	$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
		// 	$table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
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
		
		//浣ｉ噾鍗曟槑缁嗘渶鍚庝竴琛?鍚堣
		public function getProductHtmlLastContent(){
			
		}	
	}

?>