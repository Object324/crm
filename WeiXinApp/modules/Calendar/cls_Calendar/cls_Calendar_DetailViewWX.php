<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Calendar_DetailViewWX extends cls_DetailViewWX
{
    public $detailContent;

    //editor:gyq_109 reason:日程管理模块  2019/4/30 17:08
    protected function DetailLastExtra()
    {
        $detail = parent::DetailLastExtra();
        $this->detailContent = $this->focus->detail_block_news(array());
        $this->jsonArr['list'][] = $this->detail_block_recurrent();//循环日程
        $this->jsonArr['list'][] = $this->detail_block_news();
        return $detail;
    }
    //editor:gyq_109 reason:由于PC端是在前端tpl中特殊加入了消息邀请区块，故企业微信伪造消息-邀请区块  2019/5/7 11:55
    public function detail_block_news(){
        $content = $this->detailContent;
        $data= array();
        $data['blocklabel'] = getFixedLabel('REMINDS').'-'.getFixedLabel('INVITE');
        $data['display_status'] = 1;
        if(empty($content['reminder_str'])) {
            $set_reminder = 0 ;
            //新增编辑界面，当选项为“否”，则需要将值覆盖为空
            if($this->action=='DetailView')
                $set_reminder_con = $content['set_reminder'];
            else
                $set_reminder_con = '';
        }else{
            $set_reminder = 1;
            $set_reminder_con = $content['set_reminder'];
        }
        if(empty($content['date_str'])) {
            $pop_reminds = 0;
            //新增编辑界面，当选项为“否”，则需要将值覆盖为空
            if($this->action=='DetailView')
                $set_reminder_con = $content['set_reminder'];
            else
                $pop_reminds_con = '';
        }else{
            $pop_reminds=1;
            $pop_reminds_con = $content['date_time'];
        }

        $f_index = 0;
        $fieldinfo[$f_index]['fieldlabel'] = getFixedLabel('SENDEMAILREMINDER');
        $fieldinfo[$f_index]['fieldname'] = 'set_remind';
        $fieldinfo[$f_index]['text'] = $set_reminder_con;
        $fieldinfo[$f_index]['type'] = 2;
        $fieldinfo[$f_index]['uitype'] = 86;
        $fieldinfo[$f_index]['value'] = $set_reminder;
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['cellclass'] = ' weui-cell_switch';

        //选项为“是“或者是新增/编辑界面需要显示时间字段
        if($set_reminder > 0 || $this->action!='DetailView') {
            $f_index++;
            $fieldinfo[$f_index]['fieldlabel'] = getFixedLabel('SENDEMAILREMINDERTIME');
            $fieldinfo[$f_index]['fieldname'] = 'email_date_only';
            $fieldinfo[$f_index]['text'] = $content['reminder_str']?$content['reminder_str']:'';
            $fieldinfo[$f_index]['type'] = 7;
            $fieldinfo[$f_index]['uitype'] = 56;
            $fieldinfo[$f_index]['value'] = 'Y-m-d H:i:s';
            $fieldinfo[$f_index]['fieldonly'] = "0";
            $fieldinfo[$f_index]['fieldtype'] = "O";
            $fieldinfo[$f_index]['quickcreate'] = "no";
        }

        $f_index++;
        $fieldinfo[$f_index]['fieldlabel'] = getFixedLabel('POPMESSAGENOTICE');
        $fieldinfo[$f_index]['fieldname'] = 'pop_reminds';
        $fieldinfo[$f_index]['text'] = $pop_reminds_con;
        $fieldinfo[$f_index]['type'] = 2;
        $fieldinfo[$f_index]['uitype'] = 86;
        $fieldinfo[$f_index]['value'] = $pop_reminds;
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['cellclass'] = ' weui-cell_switch';

        if($pop_reminds > 0 || $this->action!='DetailView'){
            $f_index++;
            $fieldinfo[$f_index]['fieldlabel'] = getFixedLabel('POPMESSAGENOTICETIME');
            $fieldinfo[$f_index]['fieldname'] = 'date_time';
            $fieldinfo[$f_index]['text'] = $content['date_str']?$content['date_str']:'';
            $fieldinfo[$f_index]['type'] = 7;
            $fieldinfo[$f_index]['uitype'] = 56;
            $fieldinfo[$f_index]['value'] =  'Y-m-d H:i:s';
            $fieldinfo[$f_index]['fieldonly'] = "0";
            $fieldinfo[$f_index]['fieldtype'] = "O";
            $fieldinfo[$f_index]['quickcreate'] = "no";
        }

        $f_index++;
        $fieldinfo[$f_index]['fieldlabel'] = getFixedLabel('LBL_USERS');
        $fieldinfo[$f_index]['fieldname'] = 'inviteesid';
        $fieldinfo[$f_index]['text'] =  implode(',',array_values($content['invited_users']))   ;
        $fieldinfo[$f_index]['type'] = 154;
        $fieldinfo[$f_index]['uitype'] = 242;
        $fieldinfo[$f_index]['value'] =  implode(',',array_keys($content['invited_users']));
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $data['fieldinfo'] = $fieldinfo;
        return $data;
    }

    //editor:diony reason:循环日程
    public function detail_block_recurrent(){
        $content = $this->detailContent['loop_setting_info'];
        // dump($content);
        if(empty($content['loop_type']) || $content['loop_type'] == 'norepeat') {
            $type_class = '';
            $dayvalue_class = ' ui-hide';
            $month_class = ' ui-hide';
            $dayvalue_month_class = ' ui-hide';
            $reminder_setting_class = '';
            $expiredate_class = ' ui-hide';
        }
        else if($content['loop_type'] == 'daily') {
            $type_class = '';
            $dayvalue_class = ' ui-hide';
            $month_class = ' ui-hide';
            $dayvalue_month_class = ' ui-hide';
            $reminder_setting_class = '';
            $expiredate_class = '';
        }
        else if($content['loop_type'] == 'weekly') {
            $type_class = '';
            $dayvalue_class = '';
            $month_class = ' ui-hide';
            $dayvalue_month_class = ' ui-hide';
            $reminder_setting_class = '';
            $expiredate_class = '';
        }
        else if($content['loop_type'] == 'monthly') {
            $type_class = '';
            $dayvalue_class = ' ui-hide'; 
            $month_class = '';
            $dayvalue_month_class = '';
            $reminder_setting_class = '';
            $expiredate_class = '';
        }

        $data= array();
        $data['blocklabel'] = '循环日程';
        $data['display_status'] = 1;
        $f_index = 0;
        $fieldinfo[$f_index]['bigtype'] = 'picklist';
        $fieldinfo[$f_index]['cellclass'] = $type_class;
        $fieldinfo[$f_index]['columnname'] = 'loop_type';
        $fieldinfo[$f_index]['fieldlabel'] = '循环日程';
        $fieldinfo[$f_index]['fieldname'] = 'loop_type';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $loop_typeArr = [];
        $loop_typeArr[1] = array("text"=>'不重复',"value"=>'norepeat',"color"=>'#666');
        $loop_typeArr[2] = array("text"=>'每天',"value"=>'daily',"color"=>'#666');
        $loop_typeArr[3] = array("text"=>'每周',"value"=>'weekly',"color"=>'#666');
        $loop_typeArr[4] = array("text"=>'每月',"value"=>'monthly',"color"=>'#666');
        $fieldinfo[$f_index]['option'] = $loop_typeArr;
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['special'] = "save_to_value";
        $fieldinfo[$f_index]['type'] = 4;
        $fieldinfo[$f_index]['uitype'] = 15;
        if(empty($content['loop_type'])) {
            $fieldinfo[$f_index]['text'] = '不重复';
            $fieldinfo[$f_index]['value'] = 'norepeat';
            $fieldinfo[$f_index]['value_name'] = 'norepeat';
        }
        else{
            $loop_type = $content['loop_type'];
            foreach ($loop_typeArr as $key=>$tmpValue){
                if($tmpValue['value'] == $loop_type){
                    $fieldinfo[$f_index]['text'] = $tmpValue['text'];
                }
            }
            $fieldinfo[$f_index]['value'] = $loop_type;
            $fieldinfo[$f_index]['value_name'] = $loop_type;
        }
        $fieldinfo[$f_index]['aaaaa'] = $content;

        $f_index++;
        $fieldinfo[$f_index]['bigtype'] = 'multipicklist';
        $fieldinfo[$f_index]['cellclass'] = $dayvalue_class;
        $fieldinfo[$f_index]['columnname'] = 'loop_dayvalue';
        $fieldinfo[$f_index]['fieldlabel'] = '周';
        $fieldinfo[$f_index]['fieldname'] = 'loop_dayvalue';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $loop_dayvalueArr = [];
        $loop_dayvalueArr[] = array("text"=>'周一',"value"=>'1',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周二',"value"=>'2',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周三',"value"=>'3',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周四',"value"=>'4',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周五',"value"=>'5',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周六',"value"=>'6',"color"=>'#666');
        $loop_dayvalueArr[] = array("text"=>'周日',"value"=>'7',"color"=>'#666');
        $fieldinfo[$f_index]['option'] = $loop_dayvalueArr;
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['special'] = "save_to_value";
        $fieldinfo[$f_index]['type'] = 21;
        $fieldinfo[$f_index]['uitype'] = 33;
        if(empty($content['loop_dayvalue'])) {
            $fieldinfo[$f_index]['text'] = '';
            $fieldinfo[$f_index]['value'] = '';
            $fieldinfo[$f_index]['value_name'] = '';
        }
        else{
            $loop_dayvalue_str_arr = [];
            $loop_dayvalue_arr = explode(',',$content['loop_dayvalue']);
            for($i=0;$i<count($loop_dayvalueArr);$i++){
                for($j=0;$j<count($loop_dayvalue_arr);$j++){
                    if($loop_dayvalueArr[$i]['value'] == $loop_dayvalue_arr[$j]){
                        $loop_dayvalue_str_arr[] = $loop_dayvalueArr[$i]['text'];
                    }
                }
            }
            $fieldinfo[$f_index]['text'] = implode(', ', $loop_dayvalue_str_arr);
            $fieldinfo[$f_index]['value'] = $content['loop_dayvalue'];
            $fieldinfo[$f_index]['value_name'] = $content['loop_dayvalue_value'];
        }

        $f_index++;
        $fieldinfo[$f_index]['bigtype'] = 'multipicklist';
        $fieldinfo[$f_index]['cellclass'] = $month_class;
        $fieldinfo[$f_index]['columnname'] = 'loop_month';
        $fieldinfo[$f_index]['fieldlabel'] = '月份';
        $fieldinfo[$f_index]['fieldname'] = 'loop_month';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $loop_monthArr = [];
        $loop_monthArr[] = array("text"=>'一月',"value"=>'1',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'二月',"value"=>'2',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'三月',"value"=>'3',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'四月',"value"=>'4',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'五月',"value"=>'5',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'六月',"value"=>'6',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'七月',"value"=>'7',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'八月',"value"=>'8',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'九月',"value"=>'9',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'十月',"value"=>'10',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'十一月',"value"=>'11',"color"=>'#666');
        $loop_monthArr[] = array("text"=>'十二月',"value"=>'12',"color"=>'#666');
        $fieldinfo[$f_index]['option'] = $loop_monthArr;
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['special'] = "save_to_value";
        $fieldinfo[$f_index]['type'] = 21;
        $fieldinfo[$f_index]['uitype'] = 33;
        if(empty($content['loop_month'])) {
            $fieldinfo[$f_index]['text'] = '';
            $fieldinfo[$f_index]['value'] = '';
            $fieldinfo[$f_index]['value_name'] = '';
        }
        else{
            $loop_month_str_arr = [];
            $loop_month_arr = explode(',',$content['loop_month']);
            for($i=0;$i<count($loop_monthArr);$i++){
                for($j=0;$j<count($loop_month_arr);$j++){
                    if($loop_monthArr[$i]['value'] == $loop_month_arr[$j]){
                        $loop_month_str_arr[] = $loop_monthArr[$i]['text'];
                    }
                }
            }
            $fieldinfo[$f_index]['text'] = implode(', ', $loop_month_str_arr);
            $fieldinfo[$f_index]['value'] = $content['loop_month'];
            $fieldinfo[$f_index]['value_name'] = $content['loop_month_value'];
        }

        $f_index++;
        $fieldinfo[$f_index]['bigtype'] = 'multipicklist';
        $fieldinfo[$f_index]['cellclass'] = $dayvalue_month_class;
        $fieldinfo[$f_index]['columnname'] = 'loop_dayvalue_month';
        $fieldinfo[$f_index]['fieldlabel'] = '号';
        $fieldinfo[$f_index]['fieldname'] = 'loop_dayvalue_month';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $loop_dayvalue_monthArr = [];
        $loop_dayvalue_month_options = [];
        for($i = 1; $i <= 31; $i++){
            $loop_dayvalue_monthArr[] = array("text"=>$i.'号',"value"=>$i,"color"=>'#666');
        }
        $loop_dayvalue_monthArr[] = array("text"=>'最后一天',"value"=>'lastday',"color"=>'#666');
        $fieldinfo[$f_index]['option'] = $loop_dayvalue_monthArr;
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['special'] = "save_to_value";
        $fieldinfo[$f_index]['type'] = 21;
        $fieldinfo[$f_index]['uitype'] = 33;
        if(empty($content['loop_dayvalue'])) {
            $fieldinfo[$f_index]['text'] = '';
            $fieldinfo[$f_index]['value'] = '';
            $fieldinfo[$f_index]['value_name'] = '';
        }
        else{
            $loop_dayvalue_str_arr = [];
            $loop_dayvalue_arr = explode(',',$content['loop_dayvalue']);
            for($i=0;$i<count($loop_dayvalue_monthArr);$i++){
                for($j=0;$j<count($loop_dayvalue_arr);$j++){
                    if($loop_dayvalue_monthArr[$i]['value'] == $loop_dayvalue_arr[$j]){
                        $loop_dayvalue_str_arr[] = $loop_dayvalue_monthArr[$i]['text'];
                    }
                }
            }
            $fieldinfo[$f_index]['text'] = implode(', ', $loop_dayvalue_str_arr);
            $fieldinfo[$f_index]['value'] = $content['loop_dayvalue'];
            $fieldinfo[$f_index]['value_name'] = $content['loop_dayvalue_value'];
        }

        $f_index++;
        $fieldinfo[$f_index]['bigtype'] = 'multipicklist';
        $fieldinfo[$f_index]['cellclass'] = $reminder_setting_class;
        $fieldinfo[$f_index]['columnname'] = 'reminder_setting';
        $fieldinfo[$f_index]['fieldlabel'] = '提醒设置';
        $fieldinfo[$f_index]['fieldname'] = 'reminder_setting';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $reminder_settingArr = [];
        $reminder_settingArr[] = array("text"=>'开始时',"value"=>'0',"color"=>'#666');
        $reminder_settingArr[] = array("text"=>'5分钟前',"value"=>'5',"color"=>'#666');
        $reminder_settingArr[] = array("text"=>'15分钟前',"value"=>'15',"color"=>'#666');
        $reminder_settingArr[] = array("text"=>'30分钟前',"value"=>'30',"color"=>'#666');
        $reminder_settingArr[] = array("text"=>'1小时前',"value"=>'60',"color"=>'#666');
        $reminder_settingArr[] = array("text"=>'2小时前',"value"=>'120',"color"=>'#666');
        $fieldinfo[$f_index]['option'] = $reminder_settingArr;
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['special'] = "save_to_value";
        $fieldinfo[$f_index]['type'] = 21;
        $fieldinfo[$f_index]['uitype'] = 33;
        if(empty($content['reminder_setting']) && $content['reminder_setting'] !=='0') {
            $fieldinfo[$f_index]['text'] = '';
            $fieldinfo[$f_index]['value'] = '';
            $fieldinfo[$f_index]['value_name'] = '';
        }
        else{
            $reminder_setting_str_arr = [];
            $reminder_setting_arr = explode(',',$content['reminder_setting']);
            for($i=0;$i<count($reminder_settingArr);$i++){
                for($j=0;$j<count($reminder_setting_arr);$j++){
                    if($reminder_settingArr[$i]['value'] == $reminder_setting_arr[$j]){
                        $reminder_setting_str_arr[] = $reminder_settingArr[$i]['text'];
                    }
                }
            }
            $fieldinfo[$f_index]['text'] = implode(', ', $reminder_setting_str_arr);
            $fieldinfo[$f_index]['value'] = $content['reminder_setting'];
            $fieldinfo[$f_index]['value_name'] = $content['reminder_setting_value'];
        }

        $f_index++;
        $fieldinfo[$f_index]['bigtype'] = 'date';
        $fieldinfo[$f_index]['cellclass'] = $expiredate_class;
        $fieldinfo[$f_index]['columnname'] = 'expiredate';
        $fieldinfo[$f_index]['fieldlabel'] = '到期日期';
        $fieldinfo[$f_index]['fieldname'] = 'expiredate';
        $fieldinfo[$f_index]['fieldonly'] = "0";
        $fieldinfo[$f_index]['fieldtype'] = "O";
        $fieldinfo[$f_index]['quickcreate'] = "no";
        $fieldinfo[$f_index]['type'] = 7;
        $fieldinfo[$f_index]['uitype'] = 5;
        if(empty($content['expiredate'])) {
            $fieldinfo[$f_index]['text'] = '';
        }
        else{
            $fieldinfo[$f_index]['text'] = $content['expiredate'];
        }
        $fieldinfo[$f_index]['value'] = 'Y-m-d';
        $fieldinfo[$f_index]['value_name'] = '';
        
        $data['fieldinfo'] = $fieldinfo;
        return $data;
    }
}
?>