<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ChecksLogic extends BaseLogic {
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
        unset($this->list_buttons['ChangeCreator']);
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$btn = array();//
		$mbtn = 0;
        unset($this->detail_buttons['ChangeCreator']);
        //ls 20221201 XUQIU1000685  增加审批功能(盘点单，未开启审批时保持原有逻辑，即显示确认盘点和撤销)
        $deployarray = getSys_deploy(355);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1){
            $presence = $this->controller->column_fields['presence'];
            $checkout = isPermitted(self::$module,'Confirminventory',$this->controller->id);
            $acheckout = isPermitted(self::$module,'RevocationInventory',$this->controller->id);
            $curr_power = UserNationPower('Checks',$this->id);

            if(CHECKING == $presence && 'yes' == $checkout){
                $btn['set_checks_presence']['label'] = getFixedLabel('CONFIRMINVENTORY');
                $btn['set_checks_presence']['permit'] = 'yes';
                $btn['set_checks_presence']['icon'] = 'icon-check';
                $btn['set_checks_presence']['tag'] = $curr_power.'-1';
                $btn['set_checks_presence']['mobie'] = 'confirm'; //移动端不能使用同样的按钮名称，加个参数判断
            }else if(CHECKEND== $presence && 'yes' == $acheckout){
                $btn['set_checks_presence']['label'] = getFixedLabel('REVOCATIONINVENTORY');
                $btn['set_checks_presence']['permit'] = 'yes';
                $btn['set_checks_presence']['icon'] = 'icon-aCheckout';
                $btn['set_checks_presence']['tag'] = $curr_power.'-2';
                $btn['set_checks_presence']['mobie'] = 'revocation'; //移动端不能使用同样的按钮名称，加个参数判断
                $this->detail_buttons['moduledetailEdit']['permit'] = 'no';//已审核，不允许编辑
                $this->detail_buttons['Delete']['permit'] = 'no';//已审核，不允许编辑
            }
            if(!empty($btn)){
                $this->detail_buttons = f_array_insert($this->detail_buttons,$btn,4);
            }
        }

        unset($this->detail_buttons['Copy']);
		foreach($this->detail_buttons['More']['list'] as $key => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$mbtn = 1;
				break;
				
			}
		}
		if($mbtn == 0){
			$this->detail_buttons['More']['permit']='no';
		}
	}
     public function getEditViewBtn()
    {
        $presence = $this->controller->column_fields['presence'];
       $buttons=  parent::getEditViewBtn();
        $deployarray = getSys_deploy(355);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1){
            if('盘点结束' == $presence)
            {
                $buttons['permit']='no';//已出库的单据不允许编辑
            }
        }

       return $buttons;
    }
    public function getDeleteBtn()
    {
        $presence = $this->controller->column_fields['presence'];
        $buttons=  parent::getDeleteBtn();
        if('盘点结束' == $presence)
        {
            $buttons['permit']='no';//已出库的单据不允许删除
        }

       return $buttons;
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
		$this->detail_buttons['More']['permit']='yes';
		foreach($this->detail_buttons['More']['list'] as $key => $btninfo){
			if($btninfo['permit'] == 'yes'){
				$mbtn = 1;
				break;
				
			}
		}
		if($mbtn == 0){
			$this->detail_buttons['More']['permit']='no';
		}
	}
    public function getallListViewLink() {
        $btn =array();
        $deployarray = getSys_deploy(355);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1){
            $btn['Confirminventory']['label'] = getFixedLabel('CONFIRMINVENTORY');
            $btn['RevocationInventory']['label'] = getFixedLabel('REVOCATIONINVENTORY');
        }
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes') {
            $btn['print']['label'] = getFixedLabel('PRINT');
        }
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$btn = array();
		unset($this->listview_link['Confirminventory']);//盘点
		unset($this->listview_link['RevocationInventory']);//撤销
		unset($this->listview_link['print']);//打印
        crm_load_function_file('selCheckInfo','include/Stock','CommonStock');
        $deployarray = getSys_deploy(355);//是否开启审批  0是 1否
        if($deployarray['deploy_value'] == 1){
            if(selCheckInfo($record,1) == CHECKING && isPermitted(self::$module,'Confirminventory',$record) == 'yes'){
                $btn['Confirminventory']['label'] = getFixedLabel('CONFIRMINVENTORY');
                $btn['Confirminventory']['permit'] = 'yes';
                //$btn['Confirminventory']['click'] = 'redirect(\'module='.self::$module.'&action=DetailView&record='.$record.'\')';
                //edit:can 20200207 043286: (61mis.com/kfbcrm/index.php)库存管理-盘点单（需要补丁）；在盘点单的最右侧操作栏，点击确认盘点，没有直接弹出确认盘点窗口，而是进入到单据详情，还需在单据详情界面再点击确认盘点
                //edit:can 20210409 45403: （https://61mis.com/kfbcrm [^]）盘点单的列表界面中点击确认盘点会弹出撤销盘点的提示
                $btn['Confirminventory']['click'] = 'set_checks_presence(\''.$record.'\',1,1)';
                //

            }else if(selCheckInfo($record,1) == CHECKEND && isPermitted(self::$module,'RevocationInventory',$record) == 'yes'){
                $btn['RevocationInventory']['label'] = getFixedLabel('REVOCATIONINVENTORY');
                $btn['RevocationInventory']['permit'] = 'yes';
                $btn['RevocationInventory']['click'] = 'set_checks_presence(\''.$record.'\',2,1)';

            }
            //chj 2020/12/24 43905: （https://61mis.com/kfbcrm [^]）盘点单中ASD这个成员在系统管理员确认盘点之后，依旧可以对盘点单进行编辑
            if(selCheckInfo($record,1) == CHECKEND){
                $this->listview_link['edit']['permit']='no';//历史数据（盘点结束的单据审批状态为未提交），开启审批可以编辑
            }
        }

		//打印
        // ljj 20240130 BUG20240129-72 无管理员权限或打印权限 应该没有打印操作按钮
        $printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            $btn['print']['label'] = getFixedLabel('PRINT');
            $btn['print']['permit'] = 'yes';
            $btn['print']['click'] = 'set_print_view(\''.self::$module.'\',this,\'printview\','.$record.')';
            $this->listview_link = f_array_insert($this->listview_link,$btn);
        }
	}
}
?>