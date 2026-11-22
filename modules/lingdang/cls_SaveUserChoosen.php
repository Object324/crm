<?php

class cls_SaveUserChoosen
{
    public $type ;              //自定义类型
    public $value ;             //值
    public $userid ;            //用户
    public $time ;              //时间
    public $module ;            //模块
    public $tablename ;         //存入的表名
    public function __construct($module,$type='',$tablename='ld_searchhistory'){
        global $current_user;
        $this->userid = $current_user->id;
        $this->time = date('Y-m-d H:i:s');
        $this->module = $module;
        $this->tablename = $tablename;
        if($type == ''){
            //为空则需要记住
            $this->type = $this->getType();
            $this->value = $this->getValue();
        } else {
            //不为空则需要获取
            $this->type = $type;
        }
    }

    /**
     * @return string
     */
    public function setType($type)
    {
        $this->type = $type;
    }

    /**
     * 根据url参数获取记住类型
     *
     */
    public function getType()
    {
        //自定义的searchtype
        if(isset($_REQUEST['searchtype'])){
            //edit: xll 1000113 2023/05/15 首页，“审批状态”查询条件设置查询状态后，增加记住状态功能（宋清华）
            $save_type = $_REQUEST['searchtype'];
        } else if(isset($_REQUEST['save_type'])) {
            //
            $save_type = $_REQUEST['save_type'];    //后续ajax采用save_type传参
        } else {
            //xll 20221214 XUQIU1000989 保存最近一次的基本搜索框字段选项
            $save_type = 'fieldstorage';
        }
        $this->type = $save_type;
        return $this->type;
    }

    /**
     * 根据url参数获取需要记住的值
     *
     */
    public function getValue()
    {
        $type = $this->type;
        //获取基本搜索框的字段选项值
        if($type == 'ApproveStatusHistory' && isset($_REQUEST['ApproveStatusHistory'])){
            //edit: xll 1000113 2023/05/15 首页，“审批状态”查询条件设置查询状态后，增加记住状态功能（宋清华）
            $save_value = $_REQUEST['ApproveStatusHistory'];
        }else if($type == 'fieldstorage' && isset($_REQUEST['storage_value'])){
            //xll 20221214 XUQIU1000989 保存最近一次的基本搜索框字段选项
            $save_value = $_REQUEST['storage_value'];
        }else if(isset($_REQUEST['save_value'])){
            //
            $save_value = $_REQUEST['save_value'];  //后续ajax采用save_value传参
        }else {

        }
        $this->value = $save_value;
        return $this->value;
    }

    /**
     * 将需要记住的值存入表中
     *
     */
    public function saveValue()
    {
        global $adb;
        $module = $this->module;
        $smownerid = $this->userid;
        $save_type = $this->type;
        $save_value = $this->value;
        $time = $this->time;
        $sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ?';
        $result = $adb->pquery($sql,array($module,$smownerid,$save_type));
        $num_rows = $adb->num_rows($result);
//当数据条数等于零，即表中未有数据记录，则插入一条数据
        if($num_rows == 0){
            $sql = 'insert into ld_searchhistory(modulename,smownerid,searchtype,searchvalue,searchtime) values(?,?,?,?,?)';
            $adb->pquery($sql,array($module,$smownerid,$save_type,$save_value,$time));
        }else{
            $tmp_id = $adb->query_result($result,0,'id');
            $tmp_value = $adb->query_result($result,0,'searchvalue');
            //用新的字段选项值和时间覆盖
            $sql = 'update ld_searchhistory set searchtime = ?,searchvalue = ? where id = ?';
            $adb->pquery($sql,array($time,$save_value,$tmp_id));
        }

        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,array($save_value),'success');
    }

    /**
     * 根据模块和类型获取表中记住的值
     *
     */
    public function getValueByType(){
        global $adb;
        $module = $this->module;
        $smownerid = $this->userid;
        $get_type = $this->type;
        $get_value = '';
        $sql = 'select searchvalue from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ?';
        $result = $adb->pquery($sql,array($module,$smownerid,$get_type));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            $get_value = $adb->query_result($result,0,'searchvalue');
        }
        return $get_value;
    }
}