<?php
//editor:gyq_155 reason:钉钉考勤同步  2019/10/27 16:53 ID1000624 
require_once globalStatic::$root_directory.'WeiXinApp/dingtalk/model/event_model.php';
class AttendanceDingTalk extends event_model
{
    public $is_dingtalk = true;
    public $userList = array();
    //用户列
    public function setUserList($rUseridList){
        $this->userList = $rUseridList;
    }
    //依据7天限制获取打卡结果列
    public function getAttendanceList($rWorkDateFrom,$rWorkDateTo,$rAttendanceList){
        $workDateFromAddSeven = date('Y-m-d H:i:s', strtotime($rWorkDateFrom)+7*24*3600-1);
        $workDateFromAddSevenPlus = date('Y-m-d H:i:s', strtotime($rWorkDateFrom)+7*24*3600);
        $userlist=$this->userList;
        $usercount=sizeof($this->userList);
        //50:参考网站：https://developers.dingtalk.com/document/app/open-attendance-clock-in-data 的参数：userIdList 说明
        $chunks=50;
        
        $tmpuserlist_arr=array_chunk($userlist,$chunks);
		//dump($tmpuserlist_arr);
        //时间跨度没超过7天
        //zxm 20230504 之前的循环有问题   BUG0065657成员“叶殷汝”已登录了钉钉，但是月度考勤统计表里面并没有她的数据，搜索不到。
        foreach($tmpuserlist_arr as $tmpuserlistinfo)
        {
            $this->userList=$tmpuserlistinfo;
            if($workDateFromAddSeven >= $rWorkDateTo){
                $content = $this->getAttendanceListOapi($rWorkDateFrom,$workDateFromAddSeven);
                $rAttendanceList = array_merge($rAttendanceList,$content);
                //$rAttendanceList[$rWorkDateFrom] = $content;
            }else{
                //时间跨度超过7天
                $content = $this->getAttendanceListOapi($rWorkDateFrom,$workDateFromAddSeven);
                $rAttendanceList = array_merge($rAttendanceList,$content);
                //$rAttendanceList[$rWorkDateFrom] = $content;
                $this->getAttendanceList($workDateFromAddSevenPlus,$rWorkDateTo,$rAttendanceList);
            }
        }
        return $rAttendanceList;
    }
    //依据Offset递归获取打卡信息
    //该接口用于返回企业内员工的实际打卡结果。比如，企业给一个员工设定的排班是上午9点和下午6点各打一次卡，即使员工在这期间打了多次，该接口也只会返回两条记录，包括上午的打卡结果和下午的打卡结果。
    //如果要获取打卡详细数据，比如打卡位置，可使用获取打卡详情接口。
    public function getAttendanceListOapi($rWorkDateFrom,$rWorkDateTo){
        $client = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_POST , DingTalkConstant::$FORMAT_JSON);
        $req = new OapiAttendanceListRequest();
        $attendanceList = array();
        $list = $this->getAttendanceListOapiSon($rWorkDateFrom,$rWorkDateTo,0,$client,$req,$attendanceList);
        $attendanceListTwo = array();
        foreach ($list as $key=>$value){
            $attendanceListTwo = array_merge($attendanceListTwo,$value);
        }
        return $attendanceListTwo;
    }
    //依据Offset递归获取打卡信息子方法
    protected function getAttendanceListOapiSon($rWorkDateFrom,$rWorkDateTo,$rOffset,$rClient,$rReq,&$attendanceList){
        $rReq->setWorkDateFrom($rWorkDateFrom);
        $rReq->setWorkDateTo($rWorkDateTo);
        $rReq->setUserIdList($this->userList);
        $rReq->setOffset($rOffset);
        $rReq->setLimit(50);
        $checkin_data = $rClient->execute($rReq,$this->token,'https://oapi.dingtalk.com/attendance/list');
        $checkin_data_arr = object_array($checkin_data);
        $attendanceList[$rOffset] = $checkin_data_arr['recordresult'] ;
        if($checkin_data_arr['hasMore']==1){
            $this->getAttendanceListOapiSon($rWorkDateFrom,$rWorkDateTo,$rOffset+10,$rClient,$rReq,$attendanceList) ;
        }
        return $attendanceList;
    }
    //该接口用于返回企业内员工的实际打卡记录。比如，企业给一个员工设定的排班是上午9点和下午6点各打一次卡，但是员工在这期间打了多次，该接口会把所有的打卡记录都返回。
    //如果只要获取打卡结果数据，不需要详情数据，可使用获取打卡结果接口。
    public function getAttendanceListRecord($rWorkDateFrom,$rWorkDateTo){
        $client = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_POST , DingTalkConstant::$FORMAT_JSON);
        $req = new OapiAttendanceListRecordRequest();
        $req->setCheckDateFrom($rWorkDateFrom);
        $req->setCheckDateTo($rWorkDateTo);
        $req->setUserIds($this->userList);
        $checkin_data = $client->execute($req,$this->token,'https://oapi.dingtalk.com/attendance/listRecord');
        $checkin_data_arr = object_array($checkin_data);
        return $checkin_data_arr;
    }
    //批量获取企业考勤组详情
    public function getSimpleGroups(){
        $client = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_POST , DingTalkConstant::$FORMAT_JSON);
        $req = new OapiAttendanceGetsimplegroupsRequest();
        $groups = object_array($client->execute($req,$this->token,'https://oapi.dingtalk.com/topapi/attendance/getsimplegroups'));
        file_put_contents(globalStatic::$root_directory.'dataCache/weixin/dingtalk_simplegroups.txt',json_encode($groups));
        return false;
    }
    //根据休息时间，计算实际工作时长
    public function countRestTime($rBeginTime,$rEndTime){
        $simplegroups = json_decode( file_get_contents(globalStatic::$root_directory.'dataCache/weixin/dingtalk_simplegroups.txt'),true);
        $groups = $simplegroups['result']['groups'][0];
        $workDayList = $groups['work_day_list'];
        $weekNum = date("w",$rBeginTime);
        $classId = $workDayList[$weekNum];
        $restTimeList = array();
        if(isset($groups['selected_class'][0]['setting']['rest_begin_time']['check_time'])) {
            foreach ($groups['selected_class'] as $key => $value) {
                $restTimeList[$value['class_id']]['rest_begin_time'] = $value['setting']['rest_begin_time']['check_time'];
                $restTimeList[$value['class_id']]['rest_end_time'] = $value['setting']['rest_end_time']['check_time'];
            }
            $restBeginTime = strtotime( date('Y-m-d', $rBeginTime) . ' ' . date('H:i:s', strtotime($restTimeList[$classId]['rest_begin_time'])));
            $restEndTime = strtotime( date('Y-m-d', $rEndTime) . ' ' . date('H:i:s', strtotime($restTimeList[$classId]['rest_end_time'])));
            $workTime = 0;
            if ($rBeginTime <= $restBeginTime && $rEndTime <= $restBeginTime) {
                $workTime = $rEndTime - $rBeginTime;
            } elseif ($rBeginTime <= $restBeginTime && $rEndTime > $restBeginTime && $rEndTime <= $restEndTime) {
                $workTime = $restBeginTime - $rBeginTime;
            } elseif ($rBeginTime <= $restBeginTime && $rEndTime > $restEndTime) {
                $workTime = ($restBeginTime - $rBeginTime) + ($rEndTime - $restEndTime);
            } elseif ($rBeginTime > $restBeginTime && $rBeginTime < $restEndTime && $rEndTime < $restEndTime) {
                $workTime = 0;
            } elseif ($rBeginTime > $restBeginTime && $rBeginTime < $restEndTime && $rEndTime >= $restEndTime) {
                $workTime = $rEndTime - $restEndTime;
            } elseif ($rBeginTime >= $restEndTime) {
                $workTime = $rEndTime - $rBeginTime;
            }
        }else{
            $workTime = $rEndTime - $rBeginTime;
        }
        $work_hour = round(($workTime) / 3600, 2);
        if ($work_hour === 0)
            $work_hour = $workTime . '(s)';
        return $work_hour;
    }
}