<?php

class WxOperate
{
    public $adb;
    public $rootdir;
    public function __construct($adb,$rootdir)
    {
        $this->adb = $adb;
        $this->rootdir = $rootdir;
    }
    /**
     * @return array
     * 更新用户浏览查看某文章的时长
     */
    public function updateLogTime()
    {
        $_REQUEST = SqlSearchFilter($_REQUEST);
        $log_id = $_REQUEST['log_id'];
        $duration = $_REQUEST['duration'];
        $update_sql = "update ld_wx_user_log set duration=duration+? where id=?";
        $update_res = $this->adb->pquery($update_sql,array($duration,$log_id));
        $effect_num = $this->adb->getAffectedRowCount($update_res);
        return ['res'=>$effect_num];
    }
}