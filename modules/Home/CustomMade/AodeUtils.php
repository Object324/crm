<?php

//【奥德客户报备个性化开发需求（施明程）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002406
//奥德特殊开发
class AodeUtils
{
    public $current_user;
    public $adb;
    public function __construct()
    {
        global $current_user,$adb;
        $this->current_user = $current_user;
        $this->adb = $adb;
    }

    /**
     * @param $mode
     * @param $account_id
     * @param $cf_4191
     * @param $record
     * @return array
     * @throws Exception
     * 1）销售机会模块实现根据‘客户名称+产品线’两个字段报备查重，如出现重复，则【保存】不成功，提示：机会名称不允许重复
     * 2）销售机会“机会名称”字段根据‘客户名称+产品线’两个字段【保存】后自动生成，“机会名称”字段在新建或编辑界面可见，保持原有的业务逻辑
     * cf_4191 产品线  cf_3951先用来测试
     * account_id 客户名称
     * 该方法不用了
     */
    public function judgePotentials($mode,$account_id,$cf_4191,$record){
        if($mode == "create"||$mode == "edit"){
            $select_sql = "select 1 from ld_potential 
left join ld_potentialscf on ld_potential.potentialid=ld_potentialscf.potentialid
where ld_potential.deleted=0 and ld_potential.accountid=? and ld_potentialscf.cf_4191=? ";
            if($mode == "edit"){
                //编辑的话 排除自己
                $select_sql .= " and ld_potential.potentialid!=$record ";
            }
            $select_res = $this->adb->pquery($select_sql,array($account_id,$cf_4191));
            $select_nums = $this->adb->num_rows($select_res);
            //如果数量>0 则说明有重复 不允许保存 直接报提示
            if($select_nums>0){
                return ['code'=>-1,'msg'=>'机会名称不允许重复!'];
            }else{
                //没有重复的 将客户名称+产品线  作为商机名称保存
                $select_accountname_sql =  "select accountname  from ld_account where accountid=?";
                $select_accountname_res = $this->adb->pquery($select_accountname_sql,array($account_id));
                $accountname = $this->adb->query_result($select_accountname_res,0,'accountname');
                $_REQUEST['potentialname'] = $accountname.'+'.$cf_4191;
                return ['code'=>1,'msg'=>''];
            }
        }
    }

    /**
     * @param $fieldvalue //客户名称 字段的值
     * @throws Exception
     * zxm 20210110 【奥德客户报备个性化开发需求（施明程）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002406 客户报备重复，【保存】时自动共享客户信息给当前报备人
     */
    public function to_share($fieldvalue){
        $select_sql = "select accountid,team_memberid from ld_account where accountname=?";
        $select_res = $this->adb->pquery($select_sql,array($fieldvalue));
        $select_nums = $this->adb->num_rows($select_res);
        for($j=0;$j<$select_nums;$j++){
            $accountid= $this->adb->query_result($select_res,$j,'accountid');
            $team_memberid= $this->adb->query_result($select_res,$j,'team_memberid');
            if(empty($team_memberid)){
                $arr_selectuser[] = $this->current_user->id;
            }else{
                $arr_selectuser = explode(',',$team_memberid);
                if(!in_array($this->current_user->id,$arr_selectuser)){
                    $arr_selectuser[] = $this->current_user->id;
                }
            }
            $str_selectuser = implode(',',$arr_selectuser);
            $update_sql = "update ld_account set team_memberid=? where accountid=?";
            $this->adb->pquery($update_sql,array($str_selectuser,$accountid));
            $sql = 'SELECT group_concat(viewuserid) AS viewusers FROM ld_tabshare WHERE crmid=' . $accountid;
            $result = $this->adb->pquery($sql, array());
            if ($this->adb->num_rows($result) > 0) {
                $arr_viewusers = explode(',', $this->adb->query_result($result, 0, 'viewusers'));
                //获取新分配的用户，且排除空值
                $arr_new_users = array_filter(array_diff($arr_selectuser, $arr_viewusers));
                foreach ($arr_new_users as $selectuser) {
                    $sql_insert = 'INSERT INTO ld_tabshare (crmid, viewuserid, Shareuserid,createdtime) VALUE (?,?,?,?)';
                    $this->adb->pquery($sql_insert, array($accountid, $selectuser, $this->current_user->id, date('Y-m-d H:i:s')));
                }
            }
        }
    }

}