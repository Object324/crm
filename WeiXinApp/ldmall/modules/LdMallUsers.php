<?php
class LdMallUsers extends LdMall
{
    public function ListView(){
        //zxm 20230411 bug BUG0064426
        $extraWhere = '';
        if($this->tradeInfo['account']=='jielikang'){
            $extraWhere= " and ld_users.last_name in('林晓娜','林彩微','李文链') ";
        }
        return $this->kefuListView();

        $accountid = $_REQUEST['accountid'];
        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = $page*$limit;
        $limit_sql = " limit $start,$limit ";
        $count_sql = "select count(distinct ld_users.id) as nums from ld_groups right join ld_users2group on ld_groups.groupid=ld_users2group.groupid
right join ld_users on ld_users.id=ld_users2group.userid
where ld_users.deleted=0  and ld_users.phone_mobile is not null and ld_users.phone_mobile!=''".$extraWhere;
        $count_res = $this->adb->pquery($count_sql,array());
        $count_nums = $this->adb->query_result($count_res,0,'nums');
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if(($curpagenum+1)>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }
        $user_sql = " select ld_users.id,ld_users.last_name,ld_users.phone_mobile from ld_groups right join ld_users2group on ld_groups.groupid=ld_users2group.groupid
right join ld_users on ld_users.id=ld_users2group.userid
where ld_users.deleted=0 and ld_users.phone_mobile is not null and ld_users.phone_mobile!=''".$extraWhere." group by ld_users.id";
        $user_res = $this->adb->pquery($user_sql,array());
        $user_nums = $this->adb->num_rows($user_res);
        $list = [];
        if($user_nums>0){
            for($i=0;$i<$user_nums;$i++){
                $list[$i]['id'] = $this->adb->query_result($user_res,$i,'id');
                $list[$i]['last_name'] = $this->adb->query_result($user_res,$i,'last_name');
                $list[$i]['mobile'] = $this->adb->query_result($user_res,$i,'phone_mobile');
            }
        }
        //没有分页
        $res = [
            "list"=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'pagename'=>'联系我们',
            'havenextpage'=>'no'
        ];
        return array(1,$res,'success');
    }
    //获取所有客服电话给详情列表
    private function kefuListView(){
        $list = [];
        $accountid = $_REQUEST['accountid'];
        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = $page*$limit;
        $sql = 'select * from ld_shop_phones where status = \'yes\' order by phoneseq asc';
        $results = $this->adb->pquery($sql);
        $phone_nums = $this->adb->num_rows($results);
        $curpagenum = (int)$page;
        $pagecount = ceil($phone_nums/$limit);
        for($i = 0;$i < $phone_nums;$i++){
            $list[$i]['mobile'] = $this->adb->query_result($results,$i,'phone');
            $list[$i]['last_name'] = $this->adb->query_result($results,$i,'name');
            $list[$i]['id'] = $this->adb->query_result($results,$i,'phoneid');
        }
        $havenextpage = "yes";
        if(($curpagenum+1)>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }
        $res = [
            "list"=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$phone_nums,
            'pagecount'=>$pagecount,
            'pagename'=>'联系我们',
            'havenextpage'=>$havenextpage
        ];
        return array(1,$res,'success');
    }

}