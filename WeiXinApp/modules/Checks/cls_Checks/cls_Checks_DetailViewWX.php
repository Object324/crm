<?php
/**
 * User: diony
 * Date: 2019/03/01
 */
crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_Checks_DetailViewWX extends cls_ProductEntry_DetailViewWX
{
	protected function get_DetailView(){
		parent::get_DetailView();
        //盘点单不显示小计
		if(is_array($this->jsonArr['entry'])){
         	unset($this->jsonArr['entry']['p_total']);
        }
        //盘点单不显示币种
        if(isset($this->jsonArr['currency'])){
            unset($this->jsonArr['currency']);
        }
		return $this->jsonArr;
	}

	public function init_detailButton(){
        parent::init_detailButton();
        $buttonArr = $this->focus->logic->detail_buttons;
        if(isset($buttonArr['set_checks_presence'])){
            $buttoninfo = $buttonArr['set_checks_presence'];
            //盘点单特殊处理
            if($buttoninfo['mobie'] == 'confirm'){
                $wxbuttonname = 'confirminventory'; //确认盘点
            }else{
                $wxbuttonname = 'revocationinventory';//撤销盘点
            }
            if (!empty($wxbuttonname) && $buttoninfo['permit'] == 'yes') {
                $this->jsonArr['list2'][] = $wxbuttonname;
            }
        }
    }
}
?>