<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_HelpDesk_DetailViewWX extends cls_DetailViewWX
{
    // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化 tapd:ID1000705
//    //editor:gyq_96 reason:企业微信客户服务单增加签到  2019/1/8 16:48
//    public function get_DetailView_Extra($r_focus)
//    {
//        global $adb;
//        $tabid = getTabid($this->module);
//        $sql = 'select longtitude,latitude,location_address,createdtime from ld_troubletickets where ticketid=?';
//        $result = $adb->pquery($sql,array($this->record));
//        $nums = $adb->num_rows($result);
//        $latitude = $adb->query_result($result,0,'latitude');
//        if(!empty($latitude)){
//            $sign_in['latitude'] = $latitude;
//            $sign_in['longitude'] = $adb->query_result($result,0,'longtitude');
//            $sign_in['address'] = $adb->query_result($result,0,'location_address');
//            //editor:gyq_20190327 0036639: （落落计划）企业微信>灵当CRM>客户服务单：在新增界面有点击签到功能，编辑界面却没有这个功能。（需要补丁）
//        }elseif($this->action == 'EditView'){
//            $sign_in['latitude'] = '';
//            $sign_in['longitude'] ='';
//            $sign_in['address'] = '点击签到';
//        }
//        $sign_in['signtime'] = $adb->query_result($result,0,'createdtime');
//        $this->jsonArr['signData'] = $sign_in;
//    }
    //editor:gyq_127 reason:服务小程序增加评价  2019/6/26 17:07 ID1000419
    public function DetailLastExtra(){
         crm_load_class_file('evaluate_model','modules/HelpDesk/evaluate');
         parent::DetailLastExtra();
         $model = new evaluate_model();
         //BUG0067347 hzx 表单码不需要评价区块
         if($model->detail_show_judge() && empty($_REQUEST['qrcodeid']) && $this->action == 'DetailView'){
             $this->jsonArr['list'][]  = $model->get_detail();
         }
    }

    // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化 tapd:ID1000705
/*    protected function set_CreateView()
    {
        parent::set_CreateView();
        //editor:gyq_20190207 0036555: 企业微信：客户服务单、销售机会、联系记录、项目等模块签到功能，没有根据源单类型定制-签到是否启用控制
        $modulelist = $this->getOptionModule('Singin');
        if($modulelist[getTabid($this->module)]['presence']==0){
            $sign_in = array();
            $sign_in['latitude'] = '';
            $sign_in['longitude'] = '';
            $sign_in['address'] = '点击签到';
            $this->jsonArr['signData'] = $sign_in;
        }
    }*/
}