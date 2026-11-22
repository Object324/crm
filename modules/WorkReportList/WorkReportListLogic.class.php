<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class WorkReportListLogic extends BaseLogic {
    /**
     * 调用公共更多下拉列表，并添加客户相关下拉列表
     * @author Tujt 2015-05-28
     */
    public function getListMoreBtn() {
        parent::getListMoreBtn();//调用父类方法
        unset($this->list_buttons['More']['list']['Share']);
        //wym BUG0074378
        unset($this->list_buttons['More']['list']['mass_edit']);
        unset($this->list_buttons['More']['list']['ChangeCreator']);
        unset($this->list_buttons['More']['list']['DownloadSelected']);
        unset($this->list_buttons['More']['list']['Approvalsettings']);
        unset($this->list_buttons['More']['list']['ResetListWidth']);
        unset($this->list_buttons['More']['list']['ModuleTreeSettings']);
    }
    public function getListBasicBtn() {
        parent::getListBasicBtn();//调用父类方法
        $module = self::$module;
        unset($this->list_buttons['Create']);
        unset($this->list_buttons['Allocate']);
        //unset($this->list_buttons['Delete']);
        unset($this->list_buttons['More']);
        //wym BUG0074378
        unset($this->list_buttons['Import']);
        unset($this->list_buttons['submitapprove']);

        //导出
        $this->list_buttons['Export']['label'] = getFixedLabel('EXPORT');
//        $this->list_buttons['Export']['permit'] = isPermitted($module, 'Export', '');
        $this->list_buttons['Export']['permit'] = 'yes';
        $this->list_buttons['Export']['icon'] = 'icon-export';
        $this->list_buttons['Export']['btnkey'] = 'Export';


    }

    public function getallListViewLink() {
        $btn =parent::getallListViewLink();
        unset($btn['edit']);
        $btn['nowreview']['label'] = getFixedLabel('NowReview');
        return $btn;
    }
    /**
     * 初始化列表按钮结果集
     * @author Tujt 2015-06-29
     */
    public function setListViewLink($result,$record,$start,$idx) {
        parent::setListViewLink($result,$record,$start,$idx);
        global $current_user;
        $permit = 'no';
        $btn = array();
        unset($this->listview_link['edit']);
        unset($this->listview_link['nowreview']);
        $focus = CRMEntity::getInstance('WorkReportList');
        $focus->retrieve_entity_info($record,'WorkReportList');
        //未点评且当前登录用户为未点评时 显示
        if ($focus->column_fields['approved'] == 0 &&$focus->column_fields['reuser'] == $current_user->id) {
            $permit = 'yes';
        }

        //现在点评
        $btn['nowreview']['label'] = getFixedLabel('NowReview');
        $btn['nowreview']['permit'] = $permit;
        $btn['nowreview']['click'] = 'NowReview(this,\''.$record.'\')';


        $this->listview_link = f_array_insert($this->listview_link,$btn);
    }
    public function getDetailMoreBtn()
    {
        $this->detail_buttons['More']['permit'] = 'no';
    }
    public function getDetailViewButton() {
        $this->detail_buttons =parent::getDetailViewButton();
        $this->detail_buttons['Edit']['permit']='no';
        $this->detail_buttons['Allocate']['permit']='no';
        $this->detail_buttons['Copy']['permit']='no';
        $this->detail_buttons['Share']['permit']='no';
        return $this->detail_buttons;//返回列表按钮结果集
    }
}
?>