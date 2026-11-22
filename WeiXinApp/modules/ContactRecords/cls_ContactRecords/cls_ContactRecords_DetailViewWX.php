<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_ContactRecords_DetailViewWX extends cls_DetailViewWX
{
    // @edit:dong @date:2020/07/24 @reason:  上级类中作为公共方法 不需要重载了
    //editor:gyq_81 reason:签到考勤优化 2018/9/26 16:53
    /*public function get_DetailView_Extra($r_focus)
    {
        global $adb;
        $tabid = getTabid($this->module);
        $sql = 'select longtitude,latitude,location_address,createdtime from ld_contactrecords where contactrecordID=?';
        $result = $adb->pquery($sql,array($this->record));
        $nums = $adb->num_rows($result);
        $latitude = $adb->query_result($result,0,'latitude');
        if(!empty($latitude)){
            $sign_in['latitude'] = $latitude;
            $sign_in['longitude'] = $adb->query_result($result,0,'longtitude');
            $sign_in['address'] = $adb->query_result($result,0,'location_address');
            $sign_in['signtime'] = $adb->query_result($result,0,'createdtime');
            $this->jsonArr['signData'] = $sign_in;
        }
    }*/
    // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化 tapd:ID1000705
 /*   protected function set_CreateView()
    {
        parent::set_CreateView();
        //editor:gyq_81 reason:签到考勤优化 2018/9/26 14:50
        signData  121.548359  31.247668
            this.signData.latitude = lat;
            this.signData.longitude = lng;
            this.signData.address = "定位中...";
        editor:gyq_20190207 0036555: 企业微信：客户服务单、销售机会、联系记录、项目等模块签到功能，没有根据源单类型定制-签到是否启用控制
        $modulelist = $this->getOptionModule('Singin');
        if($modulelist[getTabid($this->module)]['presence']==0){
            $sign_in = array();
            $sign_in['latitude'] = '';
            $sign_in['longitude'] = '';
            $sign_in['address'] = '点击签到';
            $this->jsonArr['signData'] = $sign_in;
        }
    }*/
    
    protected function set_CreateView()
    {
        $this->jsonArr = parent::set_CreateView();
        //泰康特殊开发，新建界面传输不受距离控制的打卡类型
        crm_load_class_file("cls_TaiKangSignin",'WeiXinApp/modules/Vendors');
        $taikangobj = new cls_TaiKangSignin();
        if($taikangobj->JudgeVersion() == 'yes'){
            $this->jsonArr['taikangNoDistanceData'] = $taikangobj->GettaikangNoDistanceData();
        }
        return $this->jsonArr;
    }
    protected function DetailLastExtra()
    {
        parent::DetailLastExtra();
        if($this->action == 'EditView'){
            //泰康特殊开发，编辑界面传输不受距离控制的打卡类型
            crm_load_class_file("cls_TaiKangSignin",'WeiXinApp/modules/Vendors');
            $taikangobj = new cls_TaiKangSignin();
            if($taikangobj->JudgeVersion() == 'yes'){
                $this->jsonArr['taikangNoDistanceData'] = $taikangobj->GettaikangNoDistanceData();
            }
        }
    }
    
}
?>