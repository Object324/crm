<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class QuestionnaireLogic extends BaseLogic {
    /**
     * 初始化更多按钮关联下拉列表
     * @author Tujt 2015-06-01
     */
    public function getListMoreBtn() {
        parent::getListMoreBtn();
        unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
        unset($this->list_buttons['More']['list']['mass_edit']);//删除导入按钮
        unset($this->list_buttons['ChangeCreator']);
    }
    /**
     * 获取详情页按钮对象
     * @author Tujt 2015-06-03
     */
    public function getDetailBasicBtn() {
        parent::getDetailBasicBtn();
        //问卷调查模块没有页面设置  0045853
        unset($this->detail_buttons['Settings']);
    }

    public function getDetailBasicSet(){
        //parent::getDetailBasicBtn();
        //问卷调查模块没有页面设置  0045853
        unset($this->detail_settings['Settings']);
        unset($this->detail_settings['DetailsSettings']);
        unset($this->detail_settings['RelevantSettings']);
    }

    /*public function getEditViewBtn()
    {
        $presence = $this->controller->column_fields['presence'];
        $buttons=  parent::getEditViewBtn();
        if(CHECKEND == $presence)
        {
            $buttons['permit']='no';//已出库的单据不允许编辑
        }
        return $buttons;
    }*/
    /*public function getDeleteBtn()
    {
        $presence = $this->controller->column_fields['presence'];
        $buttons=  parent::getDeleteBtn();
        if(CHECKEND == $presence)
        {
            $buttons['permit']='no';//已出库的单据不允许删除
        }
        return $buttons;
    }*/
    public function getallListViewLink() {
        $btn =array();
        $btn['suspend']['label'] = getFixedLabel("SuspendRecycling");
        $btn['recycling']['label'] = getFixedLabel("StartRecycling");
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
        unset($this->listview_link['suspend']);//盘点
        unset($this->listview_link['recycling']);


//        if(selCheckInfo($record,1) == CHECKING && isPermitted(self::$module,'Confirminventory',$record) == 'yes'){
        if($this->CheckStatus($record) == '正在回收'){
            $btn['suspend']['label'] = getFixedLabel("SuspendRecycling");
            $btn['suspend']['permit'] = 'yes';
            $btn['suspend']['click'] = 'set_questionnaire_status(\''.$record.'\',\'正在回收\')';

        }else if($this->CheckStatus($record) == '暂停'){
            $btn['recycling']['label'] = getFixedLabel("StartRecycling");
            $btn['recycling']['permit'] = 'yes';
            $btn['recycling']['click'] = 'set_questionnaire_status(\''.$record.'\',\'暂停\')';
        }

        $this->listview_link = f_array_insert($this->listview_link,$btn);

    }

    function CheckStatus($record)
    {
        global $adb;
        $sql = "select status from ld_questionnaire where questionnaireid = ?";
        $result = $adb->pquery($sql,array($record));

        return $adb->query_result($result, 0, "status");

    }
}
?>