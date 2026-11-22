<?php
//陌远销售机会个性化开发 zxm 20201228

class MoyuanUtils
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
     * @param $smownerid
     * @param string $potentials_id
     * @return array
     * @throws Exception
     * 新增、分配销售机会时
     * ld_usersscf:cf_3375:cf_3375:Users_有效商机数量:NN  不超过有限销售机会限制  销售机会-有效商机状态：审核通过、冲突已通过
     * 查重  客户名称+产品线  历史冲突未通过的商机不参与查重判定
     * 保存后不重复  则更新商机状态为：审批通过；
     * 保存后重复   则更新重复的多个商机状态：冲突待处理；（历史冲突未通过的商机不再更新商机状态）
     */
    public function judgePotentials($mode,$smownerid,$potentials_id='')
    {
        //查询用户表设置的有效商机数量 b.cf_3375
        //查询当前的销售机会表有效商机总数量
        //ld_potentialscf:cf_3329:cf_3329:Potentials_商机状态:V
        if($mode == "create"||$mode == "Allocate") {
            $potentials_sql = "select count_potentials,cf_3375 from (select b.cf_3375,a.id from ld_users a left join ld_usersscf b on a.id=b.id where a.id=?) a left join (select count(a.potentialid) as count_potentials,a.smownerid from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid where a.deleted=0 and b.cf_3329 in ('审核通过','冲突已通过') and a.smownerid=?) b on a.id=b.smownerid";
            $potentials_res = $this->adb->pquery($potentials_sql, [$smownerid, $smownerid]);
            $nums = $this->adb->num_rows($potentials_res);
            if ($nums) {
                $cf_3375 = $this->adb->query_result($potentials_res, 0, "cf_3375");
                $count_potentials = $this->adb->query_result($potentials_res, 0, "count_potentials");
            }
            $cf_3375 = empty($cf_3375) ? 0 : $cf_3375;
            $count_potentials = empty($count_potentials) ? 0 : $count_potentials;
            if ($cf_3375 <= $count_potentials) {
                return ['code'=>-1,'msg'=>'已超出有限销售机会限制!'];
            }
        }
        //查重 -- 更新状态 仅考虑新增
        //ld_potential:accountid:account_id:Potentials_客户名称:V
        //ld_potentialscf:cf_3330:cf_3330:Potentials_产品线:V
        $name = $_REQUEST['account_id'];
        $cf_3330 = $_REQUEST['cf_3330'];
        if($mode == "create"||$mode == "Allocate") {
            $repeat_sql = " select a.potentialid from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid where b.cf_3329 in ('审核通过','冲突已通过','冲突待处理') and a.deleted=0 and a.accountid=? and b.cf_3330=? and a.smownerid=?";
            $repeat_res = $this->adb->pquery($repeat_sql, [$name, $cf_3330,$smownerid]);
            $nums = $this->adb->num_rows($repeat_res);
            //有重复 将重复的数据的多个商机状态：冲突待处理
            //ld_potentialscf:cf_3379:cf_3379:Potentials_冲突处理说明:V
            //出现上述销售机会保存后重复的情况，像更新商机状态一样，把当前编辑的销售机会的 冲突处理说明 的值更新到历史重复的销售机会对应字段中
            if ($nums > 0) {
                $_REQUEST['cf_3329'] = "冲突待处理";
                $update_sql = " update ld_potentialscf set cf_3329='冲突待处理',cf_3379='".$_REQUEST['cf_3379']."' where potentialid in (select potentialid from ($repeat_sql) a )";
                $this->adb->pquery($update_sql, [$name, $cf_3330,$smownerid]);
            } else {
                //没有重复 直接将状态改成:审核通过
                $_REQUEST['cf_3329'] = "审核通过";
            }
        }else if($mode == "edit" && ($_REQUEST['cf_3329'] == "审核通过"||$_REQUEST['cf_3329'] == "冲突已通过")){
            $repeat_sql = " select a.potentialid from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid where b.cf_3329 in ('审核通过','冲突已通过','冲突待处理') and a.deleted=0 and a.accountid=? and b.cf_3330=? and a.potentialid<>? and a.smownerid=?";
            //有重复 将重复的数据的多个商机状态：冲突未通过
            $update_sql = " update ld_potentialscf set cf_3329='冲突未通过' where potentialid in (select potentialid from ($repeat_sql) a )";
            $this->adb->pquery($update_sql,[$name, $cf_3330,$potentials_id,$smownerid]);

        }
    }

    /**
     * @param $mode
     * @param $leads_id
     * @return false
     * @throws Exception
     * 提醒内容：客户名称$_REQUEST['accountname']，线索/需求描述cf_3417，联系人姓名contactname，手机号码mobile
     * 新建保存  提醒销管部所有用户  分配
     * 判断是创建还是分派select_id
     * 创建
     */
    public function emailLeadsForSave($mode,$leads_id)
    {
        $leads_id = str_replace(';',',',$leads_id);
        $leads_id = trim($leads_id,',');
        if($mode=="create"){
            $user_sql = "select email1 from ld_users LEFT JOIN ld_users2group 
on ld_users.id=ld_users2group.userid
left join ld_groups on ld_groups.groupid=ld_users2group.groupid
where ld_groups.groupname='销管部'";
            //$user_sql = "select email1 from ld_users u left join ld_groups g on g.groupid=u.groupid where u.status='Active' and g.groupname='销管部'";
            $title = "您有新的销售线索生成，请注意查收！";
            $subject = "销售线索【新建】提醒";
        }else if($mode=="Allocate"){
            $user_sql = "select email1 from ld_users where id=".$_REQUEST['caterorid'];
            //分配
            $title = "有新的销售线索分配给您，请尽快跟进！";
            $subject = "销售线索【分配】提醒";
        }else{
            return false;
        }
        $user_res = $this->adb->pquery($user_sql);
        $user_nums = $this->adb->num_rows($user_res);
        $emails_str = '';
        if($user_nums>0){
            for($i=0;$i<$user_nums;$i++){
                $emails_str .= $this->adb->query_result($user_res,$i,'email1');
                $emails_str .=',';
            }
        }
        //查询数据
        $leads_sql = "select a.accountname,b.cf_3417,a.contactname,a.mobile from ld_leads a left join ld_leadscf b on a.leadsid=b.leadsid where a.leadsid in ($leads_id)";

        $leads_res = $this->adb->pquery($leads_sql);
        $leads_nums = $this->adb->num_rows($leads_res);
        $content = '<h2 style="text-align: center;">'.$title.'</h2><table width="100%" border="1" cellspacing="0">
<tr><th width="25%">客户名称</th><th width="25%">线索/需求描述</th><th width="25%">联系人姓名</th><th width="25%">手机号码</th>';
        if($leads_nums>0){
            for($i=0;$i<$leads_nums;$i++){
                $content .= '<tr>';
                $content .= '<td>'.$this->adb->query_result($leads_res,$i,'accountname') .'</td>';
                $content .= '<td>'.$this->adb->query_result($leads_res,$i,'cf_3417') .'</td>';
                $content .= '<td>'.$this->adb->query_result($leads_res,$i,'contactname') .'</td>';
                $content .= '<td>'.$this->adb->query_result($leads_res,$i,'mobile') .'</td>';
                $content .= '</tr>';
            }
        }
        $content .= '</table>';
        $this->SendEmail($emails_str, $content,$subject);
    }
    public function SendEmail($emails, $remindcontent,$subjecttitle)
    {
        $emails = trim($emails, ',');
        if (empty($emails)) {
            return;
        }
        global $adb, $current_user, $server_username;
        //parent_name:收件人  from_email:发送者 ccmail:抄送  bccmail:密送  subject:主题  description1：内容
        if ($emails) {
            if (empty($server_username)) {
                require_once(globalStatic::$root_directory . 'modules/Emails/mail.php');//gyq_122
                $sql = "select server_username from ld_systems where server_type = 'email'";
                $result = $adb->pquery($sql);
                $server_username = $adb->query_result($result, 0, 'server_username');
            }

            if (empty($server_username)) {
                return;
            }
            if (!class_exists('Emails')) {
                include(globalStatic::$root_directory . 'modules/Emails/Emails.php');
            }
            $arr = explode(",", $emails);
            for ($i = 0; $i < sizeof($arr); $i++) {
                if (stripos($arr[$i], '@') === false || stripos($arr[$i], '.') === false) {
                    //简单email字段判断
                    continue;
                }
                if (stripos($arr[$i], '@') >= strripos($arr[$i], '.')) {
                    //简单email字段判断
                    continue;
                }
                $focus = new Emails();
                $focus->filename = $_REQUEST['file_name'];
                $focus->column_fields["assigned_user_id"] = $current_user->id;
                $focus->column_fields["subject"] = $subjecttitle;
                $focus->column_fields["activitytype"] = "Emails";
                include_once globalStatic::$root_directory . 'include/fields/DateTimeField.php';
                $date_start = new DateTimeField('');
                $focus->column_fields["date_start"] = date($date_start->getDBInsertDateTimeValue());
                $email = $arr[$i];
                $focus->column_fields['saved_toid'] = $email;
                $focus->column_fields['contactid'] = 0;
                $from_email = $server_username;
                $ccmail = $email;
                $bccmail = $email;
                $subject = $subjecttitle;
                $content = $remindcontent;
                if (array_key_exists('description', $focus->column_fields)) {
                    $focus->column_fields['description'] = '<p>' . $content . '</p>';
                }
                if (!empty($email)) {
                    $focus->save("Emails");
                    $content=str_replace("\r\n","<br>",$content);
                    $content=str_replace("\n","<br>",$content);
                    send_mail('Emails', $focus->column_fields['saved_toid'], '', $from_email, $subject, $content, $ccmail, $bccmail, 'all', $focus->id, '', $server_username);
                }
            }
        }
    }
}