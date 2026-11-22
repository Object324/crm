<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_VendorContact_SaveWX extends cls_SaveWX
{
    public function common_save()
    {
        //duan 20240125 留空方法重写
        $this->before_save();

        global $adb;
        //reason:供应商联系人拍名片创建关联创建供应商 editor:gyq_20 date:20170111
        $cache_record = $_REQUEST['record'];

        require_once globalStatic::$root_directory.'appCommon/include/piecesFunctionMC.php';
        $_REQUEST['vendor_id'] = set_camcard_related_create_mc($_REQUEST['CamCard_RelatedCreate'],'Vendors','vendor_id');
        
        $_REQUEST['record'] = $cache_record;

        $focus = $this->focus;
        //0025802: （微信端-安卓）联系人：新增自定义的多选框字段，新增联系人选择多选框信息，出现代码
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        setObjectValuesFromRequest($focus);
        $focus->save($this->module);
        
        $relatedCreationInfo = $_REQUEST['relatedCreationInfo'];
        $relatedCreationArr = json_decode($relatedCreationInfo,true);
        if(!empty($relatedCreationArr)){
            $frommodule = $relatedCreationArr['frommodule'];
            $fromid = $relatedCreationArr['fromid'];
        }
        
        if(!empty($_REQUEST['file_save_weixin'])){
            $this->saveAttachmentFromWeiXinApi_CommonModule($focus->id,$this->module,$_REQUEST['file_save_weixin']);
        }

        //duan 20240125 将签到以及审批必填字段的保存合并到一起
        $this->after_save();
    }
}