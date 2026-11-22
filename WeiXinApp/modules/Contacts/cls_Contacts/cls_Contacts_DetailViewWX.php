<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Contacts_DetailViewWX extends cls_DetailViewWX
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
    public function get_DetailView_Extra($focus)
    {
        global $adb;
//        @edit:liushuai,2021-07-20,reason:【ID1001139】客户和联系人相关信息中的“会话存档”模块增加可隐藏功能
        $have_wechatsession = 'no';
        if(vtlib_isModuleActive($this->module) && isPermitted('WechatSession','index') == 'yes'){
            $relatedListResult = $adb->pquery('SELECT presence FROM ld_relatedlists WHERE tabid=? AND related_tabid=?', array(getTabid($this->module), getTabid("WechatSession")));
            if($adb->num_rows($relatedListResult) >0){
                $presence = $adb->query_result($relatedListResult,0,'presence');
                if($presence != 1) {
                    $have_wechatsession = 'yes';
                }
            }
        }
        $this->jsonArr['defaultSetting']['wechatsession'] = $have_wechatsession;
    }
}