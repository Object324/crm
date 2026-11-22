<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class MinusJobBillLogic extends BaseLogic {
    public function getDetailMoreBtn()
    {
        parent::getDetailMoreBtn();
        //$this->detail_buttons['More']['list']['Copy']['permit'] = 'no';
        $btn['oahistory']['label'] = getFixedLabel('VIEWADDJOBBILLHISTORY');
        $btn['oahistory']['permit'] = 'yes';
        $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn);
    }
}
?>