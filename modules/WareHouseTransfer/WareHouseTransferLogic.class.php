<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
  function getWareHouseTransferInfo($id)
 {
    global $adb;
    $sql = "SELECT transferstatus,inwarehouse,outwarehouse,transfersmownerid from ld_warehousetransfer  where warehousetransferid= ?";
    $result = $adb->pquery($sql,array($id));
    $transfer['transferstatus'] = $adb->query_result($result, 0, "transferstatus");
    $transfer['inwarehouse'] = $adb->query_result($result, 0, "inwarehouse");
    $transfer['outwarehouse'] = $adb->query_result($result, 0, "outwarehouse");
    $transfer['transfersmownerid'] = $adb->query_result($result, 0, "transfersmownerid");
    return $transfer;
 }
class WareHouseTransferLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);//删除导入按钮
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$btn = array();//
		$mbtn=0;
        //ls 20221201 XUQIU1000685  增加审批功能(调拨单，未开启审批时保持原有逻辑，即显示审核和反审核)
        $deployarray = getSys_deploy(356);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1) {
            $transferstatus = $this->controller->column_fields['transferstatus'];
            $outwarehouse = $this->controller->column_fields['outwarehouse'];
            $inwarehouse = $this->controller->column_fields['inwarehouse'];
            $tag = $outwarehouse . '-' . $inwarehouse;
            if ('已审核' == $transferstatus) {
                //22100: （普通用户，没有【反审核】权限）库间调拨序明细界面：不应该显示【反审核】按钮
                $btn['submit_warehousetransfer']['label'] = getFixedLabel('ACheckout');
                $btn['submit_warehousetransfer']['permit'] = isPermitted(self::$module, 'ACheckout', $this->controller->id);
                $btn['submit_warehousetransfer']['icon'] = 'icon-aCheckout';
                $tag .= '-Concel';
                $btn['submit_warehousetransfer']['tag'] = $tag;
                $this->detail_buttons['moduledetailEdit']['permit'] = 'no';//已审核，不允许编辑
                $this->detail_buttons['Delete']['permit'] = 'no';//已审核，不允许删除
            } else {
                $btn['submit_warehousetransfer']['label'] = getFixedLabel('Checkout');
                if (isPermitted(self::$module, 'Checkout', $this->controller->id) == 'yes') {
                    $btn['submit_warehousetransfer']['permit'] = 'yes';
                }
                $btn['submit_warehousetransfer']['icon'] = 'icon-check';
                $tag .= '-Confirm';
                $btn['submit_warehousetransfer']['tag'] = $tag;
                if (isPermitted(self::$module, 'EditView', $this->controller->id) == 'yes') {
                    $this->detail_buttons['moduledetailEdit']['permit'] = 'yes';
                }
            }
            if (!empty($btn)) {
                $this->detail_buttons = f_array_insert($this->detail_buttons, $btn, 4);
            }
        }

	}
    public function getEditViewBtn()
    {
        $transferstatus = $this->controller->column_fields['transferstatus'];
       $buttons=parent::getEditViewBtn();
        $deployarray = getSys_deploy(356);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1) {
            if('已审核' == $transferstatus)
            {
                $buttons['permit']='no';
            }
        }
       return $buttons;
    }
    public function getDeleteBtn()
    {
       $transferstatus = $this->controller->column_fields['transferstatus'];
       $buttons=parent::getDeleteBtn();
        if('已审核' == $transferstatus)
        {
            $buttons['permit']='no';
        }

       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
		foreach($this->detail_buttons['More']['list'] as $key => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$mbtn = 1;
				break;
				
			}
 		if($mbtn == 0){
			$this->detail_buttons['More']['list']['permit']='no';
		}	
		}
	}
    public function getallListViewLink() {
        $btn =array();
        $deployarray = getSys_deploy(356);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1) {
            $btn['checkout']['label'] = getFixedLabel('Checkout');
            $btn['acheckout']['label'] = getFixedLabel('ACheckout');
        }
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes') {
            $btn['print']['label'] = getFixedLabel('PRINT');
        }
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$btn = array();
		unset($this->listview_link['checkout']);//审核
		unset($this->listview_link['acheckout']);//反审核
		unset($this->listview_link['print']);//打印

        $deployarray = getSys_deploy(356);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1) {
            $warehousetransfer = getWareHouseTransferInfo($record);
            $inwarehouse = $warehousetransfer['inwarehouse'];
            $outwarehouse = $warehousetransfer['outwarehouse'];
            if(empty($warehousetransfer['transfersmownerid']) && isPermitted(self::$module,'Checkout',$record) == 'yes'){
                $btn['checkout']['label'] = getFixedLabel('Checkout');
                $btn['checkout']['permit'] = 'yes';
                $btn['checkout']['click'] = 'submit_warehousetransfer('.$outwarehouse.','.$inwarehouse.','.$record.','.'\'Confirm\');';
            }else if($warehousetransfer['transfersmownerid'] > 0 && isPermitted(self::$module,'ACheckout',$record) == 'yes'){
                $btn['acheckout']['label'] = getFixedLabel('ACheckout');
                $btn['acheckout']['permit'] = 'yes';
                $btn['acheckout']['click'] = 'submit_warehousetransfer(\''.$outwarehouse.'\',\''.$inwarehouse.'\',\''.$record.'\',\'Concel\')';
                $this->listview_link['edit']['permit']='no';
            }
            if('已审核' == $warehousetransfer['transferstatus'])
            {
                $this->listview_link['edit']['permit']='no';
                // chj 2022-04-18 （http://120.79.93.255/crm/）（贺桃）维保管理->领料单（原调拨单），与领料单关联的单据中，单据详情（例如：客户服务卡）的相关信息中，领料单的“操作”列显示了“删除”按钮。（通用问题）
                $this->listview_link['delete']['permit']='no';
            }
        }

		//打印
        // ljj 20240130 BUG20240129-72 无管理员权限或打印权限 应该没有打印操作按钮
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            $btn['print']['label'] = getFixedLabel('PRINT');
            $btn['print']['permit'] = 'yes';
            $btn['print']['click'] = 'set_print_view(\''.self::$module.'\',this,\'printview\','.$record.')';
        }
        //BUG20240820-15 ls 240820 调拨单单据列表界面，普通成员操作列没有显示“审核”按钮
        $this->listview_link = f_array_insert($this->listview_link,$btn);
	}
}
?>