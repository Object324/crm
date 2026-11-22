<?php

class SinginLogic extends BaseLogic {
    
	public function getListMoreBtn() {
        global $current_user;

        $this->list_buttons['More']['list']['sign_recalculate']['label'] = getFixedLabel('RECALCULATEERROR');
        $this->list_buttons['More']['list']['sign_recalculate']['permit'] = 'yes';

		parent::getListMoreBtn();//调用父类方法

		unset($this->list_buttons['More']['list']['mass_edit']);
        unset($this->list_buttons['More']['list']['ChangeCreator']);
        unset($this->list_buttons['More']['list']['DownloadSelected']);
        unset($this->list_buttons['More']['list']['BatchBackFilling']);//wym 240322 BUG20240321-50 签到-列表设置-批量操作按钮排序，第三个显示“批量回填”，列表勾选单据，没有该功能按钮
        if(sizeof($this->list_buttons['More']['list']) <=0){
            $this->list_buttons['More']['permit'] = 'no';
        }
	}

	public function getListBasicBtn() {
        global $current_user;

        parent::getListBasicBtn();//调用父类方法
        
        
        unset($this->list_buttons['Create']);
        unset($this->list_buttons['Allocate']);
        unset($this->list_buttons['Import']);

	}

	public function getDetailBasicBtn() {
	    parent::getDetailBasicBtn();//调用父类方法
        
        unset($this->detail_buttons['Edit']);
        unset($this->detail_buttons['Allocate']);
        unset($this->detail_buttons['Copy']);
	}
    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        unset($btn['edit']);
        $btn['recalculate']['label'] = getFixedLabel('RECALCULATEERROR');
        return $btn;
    }
	public function setListViewLink($result,$record,$start,$idx) {
		global $current_user;
		parent::setListViewLink($result,$record,$start,$idx) ;
        
        unset($this->listview_link['edit']);
        //拜访签到列表增加重算按钮
        $this->listview_link['recalculate']['label'] = getFixedLabel('RECALCULATEERROR');
        $this->listview_link['recalculate']['permit'] = 'yes';
        $this->listview_link['recalculate']['click'] = 'sign_recalculate_record('.$record.',0,1)';
	}
    
    public function getDetailMoreBtn() {
		parent::getDetailMoreBtn();
        unset($this->detail_buttons['More']['list']['Print']);
        unset($this->detail_buttons['More']['list']['ChangeCreator']);
        unset($this->detail_buttons['More']['list']['DownloadSelected']);
        
        if(sizeof($this->detail_buttons['More']['list']) <=0){
            $this->detail_buttons['More']['permit'] = 'no';
        }
	}
}
?>