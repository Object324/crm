<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_CustomForm78_DetailViewWX extends cls_DetailViewWX
{
    //名片新增时给字段添加默认值
    protected function setDefaultValue($focus)
    {
        if(!empty($_REQUEST['cardserverId']) && !empty($_REQUEST['camcard'])){
            require_once(globalStatic::$root_directory.'expansion/camcard/cls_camcard.php');
            $camobj = new cls_camcard();
            $fieldComparison = $camobj->createViewDefaultValues($_REQUEST['camcard'],$_REQUEST['cardserverId']);
            if(!empty($fieldComparison)) {
                foreach ($focus->column_fields as $fieldname => $val) {
                    if (!empty($fieldComparison[$fieldname])) {
                        $defaultvalue = $fieldComparison[$fieldname];
                        $focus->column_fields[$fieldname] = $defaultvalue;
                        if ($fieldname == 'account_id') {
                            $_REQUEST['CamCard_RelatedCreate'] = $_REQUEST['cardcontent'];//为了在保存时分辨出客户名称的来源
                            $this->jsonArr['CamCard_RelatedCreate'] = $_REQUEST['cardcontent'];
                        }
                    }
                }
            }
        }
    }
}