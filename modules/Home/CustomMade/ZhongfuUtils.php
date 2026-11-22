<?php

include globalStatic::$root_directory."modules/Home/CustomMade/CustomMadeUtils.php";

class ZhongfuUtils extends CustomMadeUtils
{

    /**
     * 获取商机预警数据 预计成交日期（5天内过期）预警
     * 商机编号、签约客户名称、最终用户名称、预计采购产品、预计合同金额、预计成交日期
     */
    public function getPotentialsWarning($calCnt,$scope,$senioruserid=0){
        crm_load_class_file('Potentials','modules/Potentials');
        $focus = new Potentials();
        global $adb;
        global $current_user,$default_charset;
        if(!empty($_REQUEST['approve_value'])){
            $account_approvestatus = $this->getApproveQuery('ld_potential');
        }
        //时间条件 0＜预计成交日期-当前日期≤5
        //时间条件 预计成交日期-当前日期≤5  2021-0806修改
        $list_query = "select $focus->list_link_field,ld_potential.potentialid,ld_potential.closingdate,a.accountid, a.accountname,ld_potential.realaccountid,actual.accountname as actualaccountname,
            ifnull(ld_potential.amount,0) as amount,ld_potential.currency_symbol,ld_potential.createdtime,scf.cf_2299 as product  from ld_potential 
            left  join ld_account a on (ld_potential.accountid=a.accountid) 
            left join ld_account actual on ld_potential.realaccountid=actual.accountid
            left  join ld_potentialscf scf on (ld_potential.potentialid=scf.potentialid) 
            LEFT JOIN ld_tabshare ON (ld_tabshare.crmid = ld_potential.potentialid)";
        //$list_query .= " WHERE ld_potential.potentialid>0 $account_approvestatus AND ifnull(ld_potential.sales_stage,'') not like '%成功%' AND ifnull(ld_potential.sales_stage,'') not like '%失败%' AND ld_potential.deleted =0 and TIMESTAMPDIFF(DAY,date_format(now(),'%Y-%m-%d'),ld_potential.closingdate)>0 and TIMESTAMPDIFF(DAY,date_format(now(),'%Y-%m-%d'),ld_potential.closingdate)<=5 ";
        $list_query .= " WHERE ld_potential.potentialid>0 $account_approvestatus AND ifnull(ld_potential.sales_stage,'') not like '%成功%' AND ifnull(ld_potential.sales_stage,'') not like '%失败%' AND ld_potential.deleted =0 and TIMESTAMPDIFF(DAY,date_format(now(),'%Y-%m-%d'),ld_potential.closingdate)<=5 ";
        $queryGenerator = new QueryGenerator('Potentials', $current_user);
        $arrFieldLabel=$queryGenerator->getFieldLables();
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'Home');
        $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scope,$senioruserid);
        $query = '';
        if(!empty($scopesql)){
            if('SmOwner_Search_All' == $scope){
                $query .= 'and (ld_tabshare.viewuserid= '.$current_user->id .' or ld_potential.'.$scopesql.')';
            }
            else{
                $query .=' and ld_potential.'.$scopesql;
            }
        }

        $list_query .= " $query  order by createdtime desc";
        
        $list_result = $adb->query($list_query);
        $open_accounts_list = array();
        $noofrows = $adb->num_rows($list_result);

        if ($noofrows) {
            for($i=0;$i<$noofrows;$i++)
            {
                $open_accounts_list[] = Array(
                    'potentialid'=>$adb->query_result($list_result,$i,'potentialid'),
                    'currency_symbol' => $adb->query_result($list_result,$i,'currency_symbol'),
                    'amount' => $adb->query_result($list_result,$i,'amount'),
                    'tickersymbol' => $adb->query_result($list_result,$i,$focus->list_link_field),
                    'accountid' => $adb->query_result($list_result,$i,'accountid'),
                    'accountname' => $adb->query_result($list_result,$i,'accountname'),
                    'realaccountid' => $adb->query_result($list_result,$i,'realaccountid'),
                    'actualaccountname'=>$adb->query_result($list_result,$i,'actualaccountname'),
                    //'product' => $adb->query_result($list_result,$i,'product'),
                    'closingdate' => $adb->query_result($list_result,$i,'closingdate')
                );
            }
        }
        //商机编号、签约客户名称、最终用户名称、预计采购产品、预计合同金额、预计成交日期
        $header = array();
        $header[] = '<span title="'.$arrFieldLabel[$focus->list_link_field].'">' .$arrFieldLabel[$focus->list_link_field] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['account_id'].'">' .$arrFieldLabel['account_id'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['realaccountid'].'">' .$arrFieldLabel['realaccountid'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['amount'].'">' .$arrFieldLabel['amount'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['closingdate'].'">' .$arrFieldLabel['closingdate'] . '</span>';

        $entries=array();
        foreach($open_accounts_list as $account)
        {
            $value=array();
            $Top_Accounts = (mb_strlen($account['accountname'],'utf-8') > 10) ? (mb_substr($account['accountname'],0,10,$default_charset).'...') : $account['accountname'];
            $realAccounts = (mb_strlen($account['actualaccountname'],'utf-8') > 10) ? (mb_substr($account['actualaccountname'],0,10,$default_charset).'...') : $account['actualaccountname'];
            $value[] = '<a href="javascript:;" referencemodule="Potentials" referencerecord="'.$account["potentialid"].'" onclick="ListReferenceLinkClick(ld(this),event)"  title="'.$account['tickersymbol'].'">'.$account['tickersymbol'].'</a>';
            $value[] = '<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$account["accountid"].'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$Top_Accounts.'"> '.$Top_Accounts.'</a>';
            $value[] = '<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$account["realaccountid"].'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$realAccounts.'"> '.$realAccounts.'</a>';
            $value[] = '<span title="'.$account['currency_symbol'] . setNumberFormat($account['amount']).'">' .$account['currency_symbol'] . setNumberFormat($account['amount']) . '</span>';
            $value[] = '<span style="color:red;">' .$account['closingdate']. '</span>';
            $entries[$account['potentialid']]=$value;
        }

        $values = Array('ModuleName'=>'Potentials','Header'=>$header,'Entries'=>$entries);
        return $values;
    }

    /**
     * 跟进记录预警
     * 商机编号、签约客户名称、最终用户名称、预计采购产品、预计合同金额、本月跟进记录条数
     */
    public function getContactRecordsWarning($calCnt,$scope,$senioruserid=0){
        crm_load_class_file('Potentials','modules/Potentials');
        $focus = new Potentials();
        global $adb;
        global $current_user,$default_charset;
        crm_load_function_file('getApproveQuery','modules/Home','HomeUtils');
        if(!empty($_REQUEST['approve_value'])){
            $account_approvestatus = $this->getApproveQuery('ld_potential');
        }
        $centerDay = date('Y-m-15 00:00:00',time());
        $currMon = date('Y-m',time());
        //时间条件 0＜预计成交日期-当前日期≤5
        $list_query = "select $focus->list_link_field,ld_potential.potentialid,a.accountid, a.accountname,ld_potential.realaccountid,actual.accountname as actualaccountname,
            ifnull(ld_potential.amount,0) as amount,ld_potential.currency_symbol,ld_potential.createdtime,scf.cf_2299 as product,ifnull(c.contact_nums,0) as contact_nums  from ld_potential 
            left  join ld_account a on ld_potential.accountid=a.accountid
            left join ld_account actual on ld_potential.realaccountid=actual.accountid
            left  join ld_potentialscf scf on ld_potential.potentialid=scf.potentialid
            left  join (select count(ld_contactrecords.contactrecordID)as contact_nums,potentialid from ld_contactrecords  where contactdate like '%$currMon%' group by potentialid ) c on ld_potential.potentialid=c.potentialid
            LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_potential.potentialid";
        $list_query .= " WHERE ld_potential.potentialid>0 $account_approvestatus AND ifnull(ld_potential.sales_stage,'') not like '%成功%' AND ifnull(ld_potential.sales_stage,'') not like '%失败%' AND ld_potential.deleted =0 and (ld_potential.potentialtype like '%直销%' or ld_potential.potentialtype like '%分销%') and ld_potential.amount>=500000 and ((ld_potential.createdtime<'$centerDay' and ifnull(c.contact_nums,0)<2) or (ld_potential.createdtime>='$centerDay' and ifnull(c.contact_nums,0)<1))";
        $queryGenerator = new QueryGenerator('Potentials', $current_user);
        $arrFieldLabel=$queryGenerator->getFieldLables();
        //查看范围sql
        $scopeobj = new ScopOfAuthority($adb,'Home');
        $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scope,$senioruserid);
        $query = '';
        if(!empty($scopesql)){
            if('SmOwner_Search_All' == $scope){
                $query .= 'and (ld_tabshare.viewuserid= '.$current_user->id .' or ld_potential.'.$scopesql.')';
            }
            else{
                $query .=' and ld_potential.'.$scopesql;
            }
        }

        $list_query .= " $query  order by ld_potential.createdtime desc";
        $list_result = $adb->query($list_query);
        $open_accounts_list = array();

        $noofrows = $adb->num_rows($list_result); //商机编号、签约客户名称、最终用户名称、预计采购产品、预计合同金额、预计成交日期
        if ($noofrows) {
            for($i=0;$i<$noofrows;$i++)
            {
                $open_accounts_list[] = Array(
                    'potentialid'=>$adb->query_result($list_result,$i,'potentialid'),
                    'currency_symbol' => $adb->query_result($list_result,$i,'currency_symbol'),
                    'amount' => $adb->query_result($list_result,$i,'amount'),
                    'tickersymbol' => $adb->query_result($list_result,$i,$focus->list_link_field),
                    'accountid' => $adb->query_result($list_result,$i,'accountid'),
                    'accountname' => $adb->query_result($list_result,$i,'accountname'),
                    'realaccountid' => $adb->query_result($list_result,$i,'realaccountid'),
                    'actualaccountname'=>$adb->query_result($list_result,$i,'actualaccountname'),
                    //'product' => $adb->query_result($list_result,$i,'product'),
                    'contact_nums' => $adb->query_result($list_result,$i,'contact_nums')
                );
            }
        }
       
        $header = array();
        $header[] = '<span title="'.$arrFieldLabel[$focus->list_link_field].'">' .$arrFieldLabel[$focus->list_link_field] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['account_id'].'">' .$arrFieldLabel['account_id'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['realaccountid'].'">' .$arrFieldLabel['realaccountid'] . '</span>';
        $header[] = '<span title="'.$arrFieldLabel['amount'].'">' .$arrFieldLabel['amount'] . '</span>';
        $header[] = '<span title="本月跟进记录条数">本月跟进记录条数</span>';

        $entries=array();
        foreach($open_accounts_list as $account)
        {
            $value=array();
            $Top_Accounts = (mb_strlen($account['accountname'],'utf-8') > 10) ? (mb_substr($account['accountname'],0,10,$default_charset).'...') : $account['accountname'];
            $realAccounts = (mb_strlen($account['actualaccountname'],'utf-8') > 10) ? (mb_substr($account['actualaccountname'],0,10,$default_charset).'...') : $account['actualaccountname'];
            $value[] = '<a href="javascript:;" referencemodule="Potentials" referencerecord="'.$account["potentialid"].'" onclick="ListReferenceLinkClick(ld(this),event)"  title="'.$account['tickersymbol'].'">'.$account['tickersymbol'].'</a>';
            $value[] = '<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$account["accountid"].'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$Top_Accounts.'"> '.$Top_Accounts.'</a>';
            $value[] = '<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$account["realaccountid"].'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$realAccounts.'"> '.$realAccounts.'</a>';
            $value[] = '<span title="'.$account['currency_symbol'] . setNumberFormat($account['amount']).'">' .$account['currency_symbol'] . setNumberFormat($account['amount']) . '</span>';
            $value[] = '<span style="color:red;">' .$account['contact_nums']. '</span>';
            $entries[$account['potentialid']]=$value;
        }

        $values = Array('ModuleName'=>'Potentials','Header'=>$header,'Entries'=>$entries);
        return $values;
    }
}