<?php

class WxAmbassador
{
    public $adb;
    public $rootdir;

    public function __construct($adb,$rootdir)
    {
        $this->adb = $adb;
        $this->rootdir = $rootdir;
    }
    public function applyAmbassador()
    {
        $_REQUEST = sqlSearchFilter($_REQUEST);
        $userid = $_REQUEST['userid'];
        $smownerid = $_REQUEST['smownerid'];//h5页面的情况下 直接传销售负责人的crm的用户id

        if(empty($smownerid)){
            $charger = 1;
        }else{
            $charger = $smownerid;
        }
        $_REQUEST['assigned_user_id'] = $charger;
        $_REQUEST['smcreatorid'] = $charger;
        // 生成推广大使编号
        require_once (globalStatic::$root_directory."Register/RegOp.php");
        $focus_ambassador = CRMEntity::getInstance("Ambassador");
        $_REQUEST['ambassador_no'] = $focus_ambassador->Library("SystemCode")->setModuleSeqNumber("increment","Ambassador");
        // 生成推广大使信息数据
        setObjectValuesFromRequest($focus_ambassador);
        $focus_ambassador->mode='create';
        $focus_ambassador->save("Ambassador");
        $ambassadorid = $focus_ambassador->id;
        $update_sql = "update ld_ambassador set wx_user_id=? where ambassadorid=?";
        $this->adb->pquery($update_sql,[$userid,$ambassadorid]);
        // 提交到审批流程
        //crm_load_class_file('Approve','module/Approve');
        //$approve = new Approve();
        //$approve->ApproveSubmit("Ambassador",$ambassadorid,?);
        return ['code'=>$ambassadorid>0?1:-1,'data'=>$ambassadorid];
    }

    /**
     * 获取我发展的推广大使
     */
    public function getMyAmbassador()
    {
       /*
        $_REQUEST = sqlSearchFilter($_REQUEST);
        $userid = $_REQUEST['userid'];
        $crm_user_id = $_REQUEST['logincrm_userid'];//非空？
        $page = $_REQUEST['page'];
        $num = 10;
        $start = $page*$num;
        $where_user = "where a.approvestatus='".D_A_S_APPROVED."' and a.smownerid=? and u.id is not null";
        $query_param = [$crm_user_id];
        if(isset($_REQUEST['keyWords'])&&!empty($_REQUEST['keyWords'])){
            $keyWords = $_REQUEST['keyWords'];
            $where_user .= " and (locate(trim(?),u.last_name)>0 or locate(trim(?),u.phone_mobile)>0)";
            $query_param[] = $keyWords;
            $query_param[] = $keyWords;
        }
        $select_sql = "select u.last_name,u.phone_mobile,u.id from ld_ambassador a left join ld_users u on a.crm_user_id=u.id $where_user order by u.id desc limit $start,$num";
        $count_sql = "select u.id from ld_ambassador a left join ld_users u on a.crm_user_id=u.id $where_user";
        $select_res = $this->adb->pquery($select_sql,$query_param);
        $count_res = $this->adb->pquery($count_sql,$query_param);
        $select_nums = $this->adb->num_rows($select_res);
        $count_nums = $this->adb->num_rows($count_res);
        $list = [];
        if($select_nums>0){
           for($i=0;$i<$select_nums;$i++){
               $list[$i]["last_name"] = $this->adb->query_result($select_res,$i,'last_name');
               $list[$i]["phone_mobile"] = $this->adb->query_result($select_res,$i,'phone_mobile');
               //成交订单数量
               $list[$i]["crm_user_id"] = $this->adb->query_result($select_res,$i,'id');
               $count_order_sql = "SELECT count(1) as counts FROM ld_wx_users a
                LEFT JOIN ld_account b ON b.report_wx_userid=a.id
                INNER JOIN ld_salesorder d ON d.accountid=b.accountid where b.deleted=0 and d.deleted=0 and b.report_type = 3 and a.crm_user_id=";//获客文章报备客户类型固定为3
               $count_order_res = $this->adb->pquery($count_order_sql,array($list[$i]["crm_user_id"]));
               $list[$i]["order_nums"] = $this->adb->query_result($count_order_res,0,"counts");
               //报备客户数量
               $count_report_sql = "select count(1) as `rows` from ld_wx_users as u left join ld_account as a on u.id=a.report_wx_userid  where a.deleted=0 and u.crm_user_id=";
               $count_report_res = $this->adb->pquery($count_report_sql,array($list[$i]["crm_user_id"]));
               $list[$i]["report_nums"] = $this->adb->query_result($count_report_res,0,"rows");
           }
        }
        $all_pages = ceil($count_nums/$num);
        $havenextpage = ($page+1)<$all_pages?"yes":"no";
        $arr['search_reminds'] = '搜索手机号、姓名';
        $arr['havenextpage'] = $havenextpage;
        $arr['pagecount'] = $all_pages;
        $arr['totalrows'] = $count_nums;
        $arr['code'] = 1;
        $arr['list'] = $list;
        return $arr;*/

    }
}