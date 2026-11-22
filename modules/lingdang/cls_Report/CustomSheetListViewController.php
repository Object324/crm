<?php
//首页组件  可设置显示字段的组件 (10,11,12,13,14,15,16,17,25,26,27,28,29,30)


class CustomSheetListViewController extends ListViewController{
    public $stuffid;
    public function setstuffid($stuffid){
        $this->stuffid = $stuffid;
    }
    /**
     * 列头字段是否可以排序
     * yes:可以排序
     * */
    public function HeaderFieldIsSorted($focus, $module, $fieldinfo, $fieldmoduleskey)
    {
        return 'no';
    }

    /*public function getListViewFields($module){
//        return [
//            'subject',
//            'activitytype',
//            'smownerid'
//        ];
        return [
            'potentialname',
            'account_id',
            'sales_stage'
        ];
    }*/
}