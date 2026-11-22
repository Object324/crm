<?php
class LdMallContacts extends LdMall
{
    /**
     * 地址列表
     */
    public  function ListView(){
        $accountid = $_REQUEST['accountid'];
        $page = $_REQUEST['page'];
        $page = empty($page)?0:$page;
        $limit = $_REQUEST['limit'];
        $limit = empty($limit)?20:$limit;
        $start = $page*$limit;
        $limit_sql = " limit $start,$limit ";
        $count_sql = "select 
                count(1) as nums
                from ld_contactdetails where accountid=? and deleted=0 and ifnull(mailingstreet,'') !=''";
        $count_res = $this->adb->pquery($count_sql,array($accountid));
        $count_nums = $this->adb->query_result($count_res,0,'nums');
        $curpagenum = (int)$page;//当前页
        $totalrows = (int)$count_nums;//总数据条数
        $pagecount = ceil($count_nums/$limit);

        $havenextpage = "yes";
        if(($curpagenum+1)>=$pagecount){
            $havenextpage = "no";//是否还有下一页
        }
        $contact_sql = " select 
 contactid,
 lastname,
 ifnull(mobile,'') as mobile,
 ifnull(mailingcountry,'') as mailingcountry,
 ifnull(mailingstate,'') as mailingstate,
 ifnull(mailingcity,'') as mailingcity,
 ifnull(mailingarea,'') as mailingarea,
 ifnull(mailingstreet,'') as mailingstreet,
 reference from ld_contactdetails where accountid=? and accountid>0 and deleted=0 and ifnull(mailingstreet,'') !=''  order by reference desc $limit_sql";

        $contact_res = $this->adb->pquery($contact_sql,array($accountid));
        $contact_nums = $this->adb->num_rows($contact_res);
        $list = [];
        if($contact_nums>0){
            for($i=0;$i<$contact_nums;$i++){
                $list[$i]['contactid'] = $this->adb->query_result($contact_res,$i,'contactid');
                $list[$i]['lastname'] = $this->adb->query_result($contact_res,$i,'lastname');
                $list[$i]['mobile'] = $this->adb->query_result($contact_res,$i,'mobile');
                $list[$i]['mailingcountry'] = $this->adb->query_result($contact_res,$i,'mailingcountry');
                $list[$i]['mailingstate'] = $this->adb->query_result($contact_res,$i,'mailingstate');
                $list[$i]['mailingcity'] = $this->adb->query_result($contact_res,$i,'mailingcity');
                $list[$i]['mailingarea'] = $this->adb->query_result($contact_res,$i,'mailingarea');
                $list[$i]['mailingstreet'] = $this->adb->query_result($contact_res,$i,'mailingstreet');
                $list[$i]['reference'] = $this->adb->query_result($contact_res,$i,'reference');
                $list[$i]['isDefault'] = $list[$i]['reference']==1?'yes':'no';//是否默认
                $list[$i]['wholeAddress'] = $list[$i]['mailingstate'].' '.$list[$i]['mailingcity'].' '.$list[$i]['mailingarea'].' '.$list[$i]['mailingstreet'];
                $list[$i]['wholeAddress'] = trim($list[$i]['wholeAddress'],' ');
            }
        }
        //没有分页 ？是否要有分页？
        $res = [
            "list"=>$list,
            'curpagenum'=>$curpagenum,
            'totalrows'=>$totalrows,
            'pagecount'=>$pagecount,
            'pagename'=>'地址列表',
            'havenextpage'=>$havenextpage
        ];
        return array(1,$res,'success');
    }

    /**
     * 添加地址
     */
    public function saveContact(){
        //联系人名字  电话  是否默认 具体地址
        $accountid = $_REQUEST['accountid'];
        $isDefault = $_REQUEST['isDefault'];
        $lastname = $_REQUEST['lastname'];
        $mobile = $_REQUEST['mobile'];
        $contactid = $_REQUEST['contactid'];

        $wholeAddress = $_REQUEST['wholeAddress'];
        $contactFocus = CRMEntity::getInstance('Contacts');

        if($contactid>0){
            $_REQUEST['record']= $_REQUEST['contactid'];
			$contactFocus->retrieve_entity_info($contactid, "Contacts");
			$_REQUEST['contact_no'] = $contactFocus->column_fields['contact_no'];
            $contactFocus->mode='edit';
        }
        setObjectValuesFromRequest($contactFocus);

        $contactFocus->column_fields['lastname'] = $lastname;
        $contactFocus->column_fields['mobile'] = $mobile;
        $contactFocus->column_fields['account_id'] = $accountid;
        $contactFocus->column_fields['assigned_user_id'] = 1;
        $contactFocus->column_fields['smcreatorid'] = 1;
        $contactFocus->column_fields['createdtime'] = date('Y-m-d H:i:s');
        $contactFocus->column_fields['bill_country'] = "中国";
        $contactFocus->column_fields['mailingstreet'] = $wholeAddress;
        //解析地址
        $wholeAddressReplace = str_replace('省','省:',$wholeAddress);
        $wholeAddressReplace = str_replace('市','市:',$wholeAddressReplace);
        $wholeAddressReplace = str_replace('区','区:',$wholeAddressReplace);
        $wholeAddressReplace = explode(':',$wholeAddressReplace);
        $addressArr = [
            'mailingstate'=>'',
            'mailingcity'=>'',
            'mailingarea'=>''
        ];
        foreach($wholeAddressReplace as $k=>$v){
            if(strpos($v,'省')&&$addressArr['mailingstate']==''){
                $addressArr['mailingstate'] = $v;
                $wholeAddress = str_replace($v,'',$wholeAddress);
            }else
            if(strpos($v,'市')&&$addressArr['mailingcity']==''){
                $addressArr['mailingcity'] = $v;
                $wholeAddress = str_replace($v,'',$wholeAddress);
            }else
            if(strpos($v,'区')&&$addressArr['mailingarea']==''){
                $addressArr['mailingarea'] = $v;
                $wholeAddress = str_replace($v,'',$wholeAddress);
            }
        }
        $contactFocus->column_fields['mailingstreet'] = $wholeAddress;
        $contactFocus->column_fields['bill_state'] = $addressArr['mailingstate'];
        $contactFocus->column_fields['bill_city'] = $addressArr['mailingcity'];
        $contactFocus->column_fields['bill_area'] = $addressArr['mailingarea'];

        $contactFocus->save('Contacts');
        //默认地址
        if($isDefault=="yes"){
            $update1 = "update ld_contactdetails set reference=0 where accountid=?";
            $this->adb->pquery($update1,array($accountid));
            $update2 = "update ld_contactdetails set reference=1 where accountid=? and contactid=?";
            $this->adb->pquery($update2,array($accountid,$contactFocus->id));
        }
        return array(1,[],'success');
    }

    /**
     * 删除地址
     * 单个删除
     */
    public function delContact(){
        $contactid = $_REQUEST['contactid'];
        $delete_sql = " update ld_contactdetails set deleted=1 where contactid = ?";
        $delete_res = $this->adb->pquery($delete_sql,array($contactid));
        return array(1,[],'success');
    }
}