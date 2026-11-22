<?php
	/**
	 * �޸ı����ʽ:ͳһ���룺UTF-8
	 * @author Chj
	 */
	require_once($root_directory.'include/TabDetailFields/cls_TabDetailFieldsHtml.php');
	Class AddJobBillDetailFieldsHtml extends cls_TabDetailFieldsHtml {
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
		}

		//��ȡ�Ӱ൥��ϸ
		// public function getTabDetailFieldsHtml($entitytypeid=''){
			
			
		// 	if($this->focus->mode == 'Details'){
		// 		$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
		// 		$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('ADDJOBBILLDETAIL') . '</div></th>';
        //         $table .="<tr>
        //         		<td name='productsStaus' style='display:block;'>";
	                		
		// 	}
		// 	$this->entitytypeid = $entitytypeid;
		// 	$table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//��ǰģ����л�׼�ֶ�
		// 	$table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//���ò�Ʒ��¼�����һ��ѡ���Ʒ���Ƿ��Զ�����һ������
		// 	$table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//��ǰģ��������Զ����ֶ���Ϣ
		// 	$table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//ϵͳ��������С��λ����
		// 	$table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//ϵͳ��������С��λ����
        //     $table_fixed_style = '';
		// 	//ls 2022-07-22 带分录的表单，单据新建/编辑/复制界面，单据表体增加众向列头固定
        //     if($this->focus->mode != 'Details'){
        //         $table .='<div class="editrelhead">';
        //         $table .='<span><b>'. getTranstab('ADDJOBBILLDETAIL') .'</b></span>'.
        //             ' <span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span>';
        //         $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
        //         $table .='</div>';
				
        //     }

		// 	$table .='<div name="productDiv" style="overflow: auto; max-height: 500px;min-height:0%;">';
		// 	$table .='<table class="ProductTab DetailContentTable" id="proTab" name="proTab" style="width:'.$this->table_width.'mm;'.$table_fixed_style.'" border="0" align="center" cellpadding="0" cellspacing="0">';
		// 	$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
		// 	$table .='<input type="hidden"  name="select_columns" value="'.$select_columns.'" />';
		// 	$table .='<input type="hidden" name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
		// 	/*if($this->focus->mode=="Details")
		// 		 $productToolMore = count($this->tabDetailFieldData->tabPresenceDetailFields) ;//��ͷ�ϲ��� +1 ��ʾ������
		// 	else
		// 		 $productToolMore = count($this->tabDetailFieldData->tabPresenceDetailFields) + 2;//��ͷ�ϲ��� +1 ��ʾ������
		// 	if($this->focus->mode != 'Details'){
		// 		$table .='<tr align="left">';
		// 		//$table .='<th colspan="'.$productToolMore.'">
        //           //  <div class="editrelhead" style="padding-left: 0px;">' . getTranstab('ADDJOBBILLDETAIL') . '</div></th>';
        //        $table .='<th colspan="'.$productToolMore.'"><div class="editrelhead" style="padding-left: 0px;">' . getTranstab('ADDJOBBILLDETAIL') . 
        //                 ' <span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span></div></th>';
                        
		// 		$table .='</tr>';
		// 	}*/
		// 	if($this->focus->mode != 'Details'){
        //     	$table .='<tr></tr>';
		// 	}
		// 	$table .=$this->getTabDetailHtmlHeader();
		// 	$table .=$this->getTabDetailHtmlContent();
		// 	$table .=$this->getTabDetailHtmlSubTotalTr();
		// 	$table .='</table>';
		// 	$table .='</div>';
		// 	if($this->tabDetailFieldData->focus->mode != 'Details'){
		// 		$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
		// 		/*$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
		// 		$table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW').'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" /></td></tr>';
		// 		$table .='</table>';*/

				
		// 	}

		// 	$table .=$this->getTabDetailHtmlTotalTr();
		// 	if($this->focus->mode == 'Details'){
		// 		$table .='</td></tr>';
		// 		$table .='</tbody></table>';
		// 	}
			
		// 	return $table;
		// }
		
		//���ñ�����ϸ���һ�� �ϼ�
		public function getProductHtmlLastContent(){
			
		}

		
	}

?>