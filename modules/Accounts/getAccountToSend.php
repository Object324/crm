<?php
/************************************************************
*{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130410
**DESPRITION:获取分组中的联系人，及客户的邮件地址
************************************************************/
global $adb,$currentModule,$current_user;
$viewid=vtlib_purify($_REQUEST['viewname']);

$queryGenerator = new QueryGenerator($currentModule, $current_user);
$queryGenerator->initForCustomViewById($viewid);
$list_query = $queryGenerator->getQuery();//分组查询条件

//$toemail=array();
$toemailstr='';
//客户邮件地址
$cusquery="select T1.email1,T1.accountname from (select email1,accountid,accountname from ld_account where ld_account.email1<>'' and
        ld_account.emailoptout=0 )as T1 right outer join (".$list_query.") as T2 on T1.accountid=T2.accountid where T1.email1<>''";
$cusresult=$adb->query($cusquery);
for($i=0;$i<$adb->num_rows($cusresult);$i++){   
    /*$toemail[]=array('email'=>$adb->query_result($cusresult,$i,'email1'),
    'accountname'=>$adb->query_result($cusresult,$i,'accountname'),
    ); */
    $toemailstr .=$adb->query_result($cusresult,$i,'email1').'<'.$adb->query_result($cusresult,$i,'accountname').'>'."\r\n";
}

$toemail=array();
//联系人邮件地址
$conquery="select T1.email,T1.lastname from 
           (select email,accountid,lastname from ld_contactdetails where email<>'' and ld_contactdetails.emailoptout=0
           ) as T1 left outer join (".$list_query.") as T2 on T1.accountid=T2.accountid where T1.email<>''";
$conresult=$adb->query($conquery);
for($i=0;$i<$adb->num_rows($conresult);$i++){
     /*$toemail[]=array('email'=>$adb->query_result($conresult,$i,'email'),
    'lastname'=>$adb->query_result($conresult,$i,'lastname'),
    );*/  
    $toemailstr .=$adb->query_result($conresult,$i,'email').'<'.$adb->query_result($conresult,$i,'lastname').'>'."\r\n";
}
//从session获取选中的字段columnname
$selected_fieldid = $_SESSION['email_field'][$viewid]['selected_fieldid'];
// @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块(选择分组的弹框)
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'true'){
    $smarty=new lingdangCRM_Smarty;
    $_REQUEST['diony']='diony';

    $sql_accounttype_SMS = "";
    $sql_accounttype_SMS .= " select ld_field.tabid,ld_field.fieldid,ld_tranlabel.fieldlabel,ld_field.tablename ";
    $sql_accounttype_SMS .= " from ld_field inner join ld_tranlabel  ";
    $sql_accounttype_SMS .= " on ld_field.fieldid = ld_tranlabel.relateid ";
    $sql_accounttype_SMS .= " where ld_tranlabel.languagetype=? and trantable=? and  (ld_tranlabel.tabid=6 or ld_tranlabel.tabid=4) and uitype = 13 and ld_field.presence<>1 order by tabid desc ";
    $accounttype_SMS_result = $adb->pquery($sql_accounttype_SMS,array($languageType,'ld_field'));
    $num_rows=$adb->num_rows($accounttype_SMS_result);
    $accounttype_SMS = array();
    for($i=0;$i<$num_rows;$i++)
    {
        $tabname=$adb->query_result($accounttype_SMS_result,$i,'name');

        $accounttype_SMS[]=array(
            'tabid'=>$adb->query_result($accounttype_SMS_result,$i,'tabid'),
            'fieldlabel'=>$adb->query_result($accounttype_SMS_result,$i,'fieldlabel'),
            'tablename'=>$adb->query_result($accounttype_SMS_result,$i,'tablename'),
            'fieldid'=>$adb->query_result($accounttype_SMS_result,$i,'fieldid'),
            'newchinesename'=>$adb->query_result($accounttype_SMS_result,$i,'newchinesename')

        );
    }
    $html_accounttype_SMS = "";
    for($i=0;$i<$num_rows;$i++)
    {
        // $account_SMS[$i]['fieldlabel']
        /**
         * 从tabid中获取模块名
         * @reason 0012762: 群发邮件界面：请选择Email弹出层中，"联系人：公司email"标签不正确，应该是“客户：公司Email”
         * @author Tujt 2014-12-03
         */
        $emailmodule = 'Accounts';
        if($accounttype_SMS[$i]['tabid'] > 0){
            $emailmodule = getTabname($accounttype_SMS[$i]['tabid']);
        }
        
        
        if(is_array($selected_fieldid)&&sizeof($selected_fieldid)>0){
            if(in_array($accounttype_SMS[$i]['fieldid'],$selected_fieldid)){
                $html_accounttype_SMS .= "<tr>";
                $html_accounttype_SMS .= "<td>";
                $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' checked='checked' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
                $html_accounttype_SMS .= "</td>";
                $html_accounttype_SMS .= "</tr>";
            }else{
                $html_accounttype_SMS .= "<tr>";
                $html_accounttype_SMS .= "<td>";
                $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
                $html_accounttype_SMS .= "</td>";
                $html_accounttype_SMS .= "</tr>";
            }
        }
        else if($i==0)
        {
            $html_accounttype_SMS .= "<tr>";
            $html_accounttype_SMS .= "<td>";
            $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' checked='checked' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
            $html_accounttype_SMS .= "</td>";
            $html_accounttype_SMS .= "</tr>";
        }
        else
        {
            $html_accounttype_SMS .= "<tr>";
            $html_accounttype_SMS .= "<td>";
            $html_accounttype_SMS .= "<input type='checkbox' id='".$i."_checkbox_groupemail_account' onclick='isselect_checkbox_groupemail()' value='".$accounttype_SMS[$i]['tabid']."_".$accounttype_SMS[$i]['fieldlabel']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".getTranstab($emailmodule).":&nbsp".$accounttype_SMS[$i]['fieldlabel']."";
            $html_accounttype_SMS .= "</td>";
            $html_accounttype_SMS .= "</tr>";
        }
    }
    $smarty->assign("html_accounttype_SMS",$html_accounttype_SMS);

    $arr['title']=getFixedLabel("PLEASESELECTEMAIL");
    $arr['oktext']=getFixedLabel("SELECT");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content'] = $smarty->fetch("SelectSendEmail.tpl");
    ConvertTojsonString(1,$arr,"success");
}

echo '&#&#&#'.$toemailstr.'&#&#&#$';


?>