<?php
//editor:gyq_109 reason:日程管理模块  2019/4/29 16:54
crm_load_class_file('QueryGeneratorWX','WeiXinApp/QueryGenerator');
class CalendarQueryGeneratorWX extends QueryGeneratorWX {
    public function addStdSearchContentWX($lastmodified){
        if($_REQUEST['tab_page']=='me'){
            if(!empty($lastmodified) && $lastmodified!='unlimit') {
                $modifiedtime = date('Y-m-d', strtotime($lastmodified));
                $newTime[] = $modifiedtime . ' 00:00:00';
                $newTime[] = $modifiedtime . ' 23:59:59';
                if(!empty($this->conditionals)){
                    $this->startGroup(self::$AND);
                }else{
                    $this->startGroup();
                }
                $this->addCondition('date_start', $newTime, 'BETWEEN', null);
                $this->endGroup();
            }
        }else{
            parent::addStdSearchContentWX($lastmodified);
        }

    }
    //为了应对me标签页，固定显示的三个字段：主题、开始时间、结束时间，在此处写死查询该三字段
    public function getSelectClauseColumnSQL(){
        $parent_colum = parent::getSelectClauseColumnSQL();
        $parent_colum .= ',ld_activity.subject ac_subject,ld_activity.date_start ac_start,ld_activity.due_date ac_end';
        // //zkt 20231113 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
        // crm_load_class_file("cls_fieldSensitiverule", "include/fields");
        // $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
        // $this->columns = $cls_fieldSensitiveruleobj->getlistRealtedfieldbyfield($this->columns);

        // //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
        // crm_load_class_file("fieldFileAllowed", "include/fields");
        // $fieldFileAllowedObj = fieldFileAllowed::getInstance($this->module);
        // $this->columns = $fieldFileAllowedObj->getSelectClauseColumn($this->columns);
        return $parent_colum;
    }
}