<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class PurchaseBackLogic extends BaseLogic {
    /**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-06-01
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();
        unset($this->list_buttons['mass_edit']);//上次做的右边设置，把原来更多里面的去掉的功能也给放出来了。。。
        unset($this->list_buttons['Import']);
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		unset($this->list_buttons['More']['list']['mass_edit']);
		unset($this->list_buttons['More']['list']['Import']);
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();//调用父类方法
		$btn = array();
		unset($this->detail_buttons['Copy']);
		/*$purchasebackstatus = $this->controller->column_fields['purchasebackstatus'];
		if('未出库' == $purchasebackstatus && 'yes' == isPermitted(self::$module,'WarehouseConfirmed',$this->controller->id)){
			//出库确认
			$btn['instockroomOperation']['label'] = getFixedLabel('DELIVERYCONFIRMATION');
			$btn['instockroomOperation']['permit'] = 'yes';
			$btn['instockroomOperation']['icon'] = 'icon-warehome';
			$btn['instockroomOperation']['tag'] = $purchasebackstatus;
		}else if('yes' == isPermitted(self::$module,'Reteacement',$this->controller->id)){//回撤
			$btn['retracementOperation']['label'] = getFixedLabel('RETRACEMENT');
			$btn['retracementOperation']['permit'] = 'yes';
			$btn['retracementOperation']['icon'] = 'icon-warehome';
			$btn['retracementOperation']['tag'] = $purchasebackstatus;
			$this->detail_buttons['moduledetailEdit']['permit']='no';
			$this->detail_buttons['More']['list']['Delete']='no';
            $this->detail_buttons['Delete']['permit']='no';
		}
		$backstatus = array('结束'=>1,'中止'=>1);
		if(!isset($backstatus[$purchasebackstatus]) && 'yes' == isPermitted(self::$module,'EndreturnGood',$this->controller->id)){
			$btn['instockroomEndOperation']['label'] = getFixedLabel('ENDRETURNGOODS');
			$btn['instockroomEndOperation']['permit'] = 'yes';
			$btn['instockroomEndOperation']['icon'] = 'icon-warehome';
			$btn['retracementOperation']['tag'] = $purchasebackstatus;
		}
		if(!empty($btn))
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,1);*/
	}
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();//调用父类方法
		unset($this->detail_buttons['More']['list']['Copy']);//删除复制按钮
	}
    	public function getListViewLink($result,$recordId,$start,$idx) {
    	   
           
    	     return   parent::getListViewLink($result,$recordId,$start,$idx);
    	   }
    /*public function setListViewLink($result,$record,$start,$idx)
     {
        
        
             global  $adb;
             $row=$adb->fetch_array($result);
              parent::setListViewLink($result,$record,$start,$idx) ;
              if(array_key_exists('purchasebackstatus',$row))
              {
                $purchasebackstatus=$adb->query_result($result,$idx,'purchasebackstatus');
               
              }
              else
              {
                  $sql="select purchasebackstatus from ld_purchaseback  where purchasebackid=$record";
                  $backstatus_result=$adb->pquery($sql,array());
                  $purchasebackstatus=$adb->query_result($backstatus_result,0,'purchasebackstatus');
                  
              }
                if($purchasebackstatus!='已出库')
                 {
                    
                 }
                 else
                 {
                    $this->listview_link['edit']['permit']='no';
                    $this->listview_link['delete']['permit']='no';
                 }
          
           
        }*/
}
?>