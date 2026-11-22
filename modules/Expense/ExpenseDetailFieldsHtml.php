<?php
//editor:gyq_161 reason:清除该文件所有id="   2019/12/2 15:10
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	require_once($root_directory.'include/TabDetailFields/cls_TabDetailFieldsHtml.php');
	Class ExpenseDetailFieldsHtml extends cls_TabDetailFieldsHtml {
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
		}

		//获取费用报销明细
		public function getTabDetailFieldsHtml($entitytypeid=''){
			$versioninfo = getVersionInfo();
			if($versioninfo['account'] == 'utrc'){
				crm_load_function_file('getNoneDetailColumn','modules/Expense','changeDetailColumn');
				$utrc_type = strtolower($this->getDetailRowExpenseType());
				if(!empty($utrc_type)){
					$select_columns = getNoneDetailColumn($utrc_type);
				}
			}

			return parent:: getTabDetailFieldsHtml($entitytypeid);
			// $table_fixed_style = '';
			// //editor:gyq_161 reason:赋值元素id的镜像name   2019/11/27 16:18
			// if($this->focus->mode == 'Details'){
			// 	$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
			// 	$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span  name="projuctscol" class=""></span>' . getTranstab('FEEDETAIL') . '</div></th>';
            //     $table .="<tr>
            //     		<td  name='productsStaus' style='display:block;'>";
            //     $table_fixed_style = 'table-layout:fixed;word-break: break-all; word-wrap: break-word;';//xxy 2023-11-16 表格固定
			// }
           
			// $this->entitytypeid = $entitytypeid;
			// $table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//当前模块空行基准字段
			// $table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//设置产品分录中最后一行选择产品后是否自动新增一个空行
			// $table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//当前模块的所有自定义字段信息
			// $table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//系统参数数量小数位控制
			// $table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//系统参数单价小数位控制
            // //ls 2022-07-22 带分录的表单，单据新建/编辑/复制界面，单据表体增加众向列头固定
            // if($this->focus->mode != 'Details'){
            //     $table .='<div class="editrelhead">';
            //     $table .='<span><b>' . getTranstab('FEEDETAIL') . '</b></span>';
            //     $table .='<span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span>';
            //     $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
            //     $table .='</div>';
            // }

            // $table .='<div  name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
			// $table .='<table tablewidth="'.$this->table_width.'" class="ProductTab DetailContentTable"  id="proTab" name="proTab" style="width:'.$this->table_width.'mm;'.$table_fixed_style.'" border="0" align="center" cellpadding="0" cellspacing="0">';
			// $table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
			// $table .='<input type="hidden"  name="select_columns" value="'.$select_columns.'" />';
			// $table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
			// /*if($this->focus->mode != 'Details'){
			// 	$table .='<tr align="left">';
			// 	$productToolMore = count($this->tabDetailFieldData->tabPresenceDetailFields) + 2;//列头合并列 +1 表示操作列
			// 	$table .='<th colspan="'.$productToolMore.'"><div class="editrelhead" style="padding-left: 0px;">' . getTranstab('FEEDETAIL') . 
            //             ' <span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span></div></th>';
                        

			// 	$table .='</tr>';
			// }*/
			// if($this->focus->mode != 'Details'){
            // 	$table .='<tr></tr>';
			// }
			// $table .=$this->getTabDetailHtmlHeader();
			// $table .=$this->getTabDetailHtmlContent();
			// $table .=$this->getTabDetailHtmlSubTotalTr();
			// $table .='</table>';
			// $table .='</div>';
			// if($this->tabDetailFieldData->focus->mode != 'Details'){
			// 	if($versioninfo['account'] == 'utrc'){
			// 		$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
			// 				$table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW') . getFixedLabel('DETAIL').'" onclick="fnAddExpenseRow(\''.$this->tabDetailFieldData->module.'\');getDetailExpenseType(\'expensetype\',1);" /></td></tr>';
			// 				$table .='</table>';
			// 	}else{
			// 		$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
			// 		/*$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
			// 				$table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW') .'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" /></td></tr>';
			// 				$table .='</table>';*/
			// 	}
				
			// }
			
			// $table .=$this->getTabDetailHtmlTotalTr();
			// if($this->focus->mode == 'Details'){
			// 	$table .='</td></tr>';
			// 	$table .='</tbody></table>';
			// }
			// return $table;
		}
		
		//费用报销明细最后一行 合计
		public function getProductHtmlLastContent(){
			
		}

		public function getDetailRowExpenseType(){
			global $adb;
			//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 4:08
			$query = 'select ld_expensetype.utrc_type from ld_expensedetail 
			LEFT JOIN ld_expense on ld_expense.expenseid = ld_expensedetail.expenseid

			LEFT JOIN (
              SELECT
                id ,listvalue,utrc_type
              FROM ld_picklist_values
                LEFT JOIN ld_picklist_set
                  ON ld_picklist_set.listid = ld_picklist_values.listid
              WHERE listname = \'expensetype\' AND relatetable = \'ld_tabdetailfield\')
    AS ld_expensetype ON ld_expensetype.listvalue = ld_expensedetail.expensetype

			where ld_expense.expenseid = ? ORDER BY expensedetailid asc limit 1';
			$result = $adb->pquery($query,array($this->focus->id));
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0){
				$expensetype = $adb->query_result($result,0,0);
			}
			return $expensetype;
		}

        public function getEntryBtn($module){
            $table ='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
            $table .='<tr><td><input type="button" name="Button" class="ld-button ld-button-primary" value="'.getFixedLabel('NEW').'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" />&nbsp;<input type="button"  name="Button" class="ld-button ld-button-primary" value="'.getFixedLabel('EMPTY').'" onclick="fnEmptyTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" />';
            //ls 240827  XUQIU20240815-01 对接发票云的API接口
            crm_load_class_file('PiaozoneClass', 'modules/lingdang');
            $piaozoneObj = PiaozoneClass::getInstance($this->tabDetailFieldData->module);
            if($piaozoneObj->isauthorize){
                $table .='&nbsp;<input type="button"  name="Button" class="ld-button ld-button-primary" value="'.getFixedLabel('ImportInvoice').'" onclick="PiaozoneObj.ImportInvoice(\''.$this->tabDetailFieldData->module.'\');" />';
            }

            $table .='</td></tr></table>';
            return $table;
        }
	}

?>