<?php
class CustomForm61Logic extends BaseLogic {
    public function getListBasicBtn() {
        parent::getListBasicBtn();
        $module = self::$module;

        $VersionInfo = getVersionInfo();
        //20230410 百特送货上门模块数据导入到中间表
        if($VersionInfo['account']=='baxter')
        {
            unset($this->list_buttons['Import']);//删除导入按钮

            if('yes' == isPermitted($module, 'Import', '')){//判断导入权限
                $is_import = 'yes';
            }
            $btn = array();
            $btn['BaxterImport']['label'] = getFixedLabel('IMPORT');
            $btn['BaxterImport']['permit'] = $is_import;
            $btn['BaxterImport']['icon'] = 'icon-ResetListWidth';
            $btn['BaxterImport']['btnkey'] = 'BaxterImport';
            $this->list_buttons = f_array_insert($this->list_buttons,$btn,count($this->list_buttons)-1);
        }

    }
}
?>