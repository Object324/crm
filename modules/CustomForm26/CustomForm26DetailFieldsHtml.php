<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
	Class CustomForm26DetailFieldsHtml extends cls_TabDetailFieldsHtml {
		
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
		}
		/**
		 * 获取佣金单明�?
		 * @param $entitytypeid 源单id,相关信息、创建创建会用到
		 * @return
		 * @author Chj
		 */
		// public function getTabDetailFieldsHtml($entitytypeid=''){
		// 	if($this->focus->mode == 'Details'){
		// 		$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
		// 		$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('CustomForm26') . '</div></th>';
        //         $table .="<tr>
        //         		<td name='productsStaus' style='display:block;'>";
	                		
		// 	}
		// 	$this->entitytypeid = $entitytypeid;
            
		// 	$table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//当前模块空行基准字段
		// 	$table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//设置产品分录中最后一行选择产品后是否自动新增一个空�?
		// 	$table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//当前模块的所有自定义字段信息
		// 	$table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//系统参数数量小数位控�?
		// 	$table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//系统参数单价小数位控�?
        //     if($this->focus->mode != 'Details'){
        //         $table .='<div class="editrelhead">';
        //         $table .='<span><b>' . getTranstab('CustomForm26') . '</b></span>';
        //         $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
        //         $table .='</div>';
        //     }
        //     $table .='<div name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
		// 	$table .='<table class="ProductTab DetailContentTable" id="proTab" name="proTab" style="width:'.$this->table_width.'mm" border="0" align="center" cellpadding="0" cellspacing="0">';
		// 	$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
        //     $table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
        //     $table .='<tr></tr>';
		// 	$table .=$this->getTabDetailHtmlHeader();
		// 	$table .=$this->getTabDetailHtmlContent();
		// 	$table .=$this->getTabDetailHtmlSubTotalTr();

		// 	$table .='</table>';
		// 	$table .='</div>';
		// 	if($this->tabDetailFieldData->focus->mode != 'Details'){
		// 		$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
		// 	    /*$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
		// 	    $table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW') .'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" /></td></tr>';
		// 	    $table .='</table>';*/

		// 	}
		// 	$table .=$this->getTabDetailHtmlTotalTr();
        
		// 	if($this->focus->mode == 'Details'){
		// 		$table .='</td></tr>';
		// 		$table .='</tbody></table>';
		// 	}
		// 	return $table;
		// }
		
		//佣金单明细最后一�?合计
		public function getProductHtmlLastContent(){
			
		}

        public function getTabDetailHtmlContent($jsAddRowid="")
        {
            $versioninfo=getVersionInfo();
            if($versioninfo['account']=='baxter' && $_REQUEST["frommodule"] == 'CustomForm23' && $this->tabDetailFieldData->row_mode=='related_create')
            {
                global $adb;
                //XUQIU1001245 ls 20230324 【百特】customform26(疑似重复病人拜访模块) 关联 customform23（新病人管理） 新建时，把分录带过来，分录字段映射关系见附件

                $this->tabDetailFieldData->setEntityTypeId($this->entitytypeid);
                $columnvalue = $this->tabDetailFieldData->getTabDetailHtmlContentData($jsAddRowid);

                $sql = "SELECT
	ld_customform23detailscf.sf408 AS sf476,
	ld_customform23detail.line_accounts_id,
	ld_customform23detailscf.sf411 AS sf465,
	IF(ld_customform23detailscf.sf412='0000-00-00', '', ld_customform23detailscf.sf412) AS sf466,
	ld_customform23detailscf.sf409 AS sf479,
	ld_customform23detailscf.sf413 AS sf468,
	ld_customform23detailscf.sf422 AS line_customform02_id,
	IF(ld_customform23detailscf.sf415='0000-00-00', '', ld_customform23detailscf.sf415) AS sf470,
	IF(ld_customform23detailscf.sf416='0000-00-00', '', ld_customform23detailscf.sf416) AS sf472,
	ld_customform23detailscf.sf417 AS sf477,
	ld_customform23detailscf.sf418 AS sf473,
	IF(ld_customform23detailscf.sf419='0000-00-00', '', ld_customform23detailscf.sf419) AS sf471,
	ld_customform23detailscf.sf420 AS sf474,
	ld_customform23detailscf.sf421 AS sf475
FROM ld_customform23
LEFT JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
LEFT JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
WHERE ld_customform23detail.id = ?";
                $result = $adb->pquery($sql,array($_REQUEST['fromid']));
                $num_rows = $adb->num_rows($result);

                if ($num_rows >= 1) {
                    $tmp_columnvalue = [];
                    for($i = 0; $i<$num_rows; $i++){
                        $entry_relationship = array(
                            'sf476'=>$adb->query_result($result, $i, 'sf476'),
                            'line_accounts_id'=>$adb->query_result($result, $i, 'line_accounts_id'),
                            'sf465'=>$adb->query_result($result, $i, 'sf465'),
                            'sf466'=>$adb->query_result($result, $i, 'sf466'),
                            'sf479'=>$adb->query_result($result, $i, 'sf479'),
                            'sf468'=>$adb->query_result($result, $i, 'sf468'),
                            'line_customform02_id'=>$adb->query_result($result, $i, 'line_customform02_id'),
                            'sf470'=>$adb->query_result($result, $i, 'sf470'),
                            'sf472'=>$adb->query_result($result, $i, 'sf472'),
                            'sf477'=>$adb->query_result($result, $i, 'sf477'),
                            'sf473'=>$adb->query_result($result, $i, 'sf473'),
                            'sf471'=>$adb->query_result($result, $i, 'sf471'),
                            'sf474'=>$adb->query_result($result, $i, 'sf474'),
                            'sf475'=>$adb->query_result($result, $i, 'sf475'),
                        );
                        $tmp_columnvalue[] = array_replace($columnvalue[0],$entry_relationship);
                    }
                    $columnvalue = $tmp_columnvalue;

                    $this->tabDetailFieldData->productrows = count($columnvalue);//分录行数
                }


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
//			if($this->focus->mode !='Details' && $this->operation_row === 0){//查看界面没有“删除”或者上下移动的按钮
                    $tableContent .='<td style="display:none;width:0mm"></td>';//隐藏操作列
//			}
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
            else{
                return  parent::getTabDetailHtmlContent($jsAddRowid);
            }
        }
	}

?>