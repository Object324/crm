<?php
/*
edit:diony
time:2015-01-06
reason:合同订单发送短信设置时，各种判断
*/ 

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
require('user_privileges/user_language_'.$current_user->id.'.php');


if(isset($_REQUEST['contenttype']) && $_REQUEST['contenttype'] != '' && 
   isset($_REQUEST['smstype']) && $_REQUEST['smstype'] != '' &&
   isset($_REQUEST['salesbackid']) && $_REQUEST['salesbackid'] != '')
{
    $contenttype = $_REQUEST['contenttype'];//phone,time,content
    $smstype = $_REQUEST['smstype'];    
    $salesbackid = $_REQUEST['salesbackid'];
    
    if($contenttype=='phone')
    {
        //根据不同的smstype的值，来确定查找条件
        if($smstype=='smsFirst')
        {  
            $type = 4;
            $tabid = 14;//产品模块id
        }
        else if($smstype=='smsSecond')
        {
            $type = 5;
            $tabid = '4,6';//联系人，客户模块id
        }
        
        //确定需要发送的手机字段查找出来
        $SqlFieldCheck = "select id,fieldids,type from ld_sendphoneset where type = ?";
        $resultCheck = $adb->pquery($SqlFieldCheck,array($type));
        $countCheck = $adb->num_rows($resultCheck);
        
        //所有手机字段查找出来
        $SqlField = "select ld_field.tabid, ld_field.fieldid,ld_field.tablename,ld_field.fieldname,ld_tranlabel.fieldlabel  
                    from ld_field 
                    left join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                    where ld_field.tabid in ($tabid) and ld_field.uitype = 1101
                    and ld_field.presence in(0,2) 
                    and ld_tranlabel.languagetype = ? and ld_tranlabel.trantable = ?
                    order by ld_field.tabid,ld_field.fieldid";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $tabid = $adb->query_result($result,$i,'tabid');
            $fieldid = $adb->query_result($result,$i,'fieldid');
            $fieldname = $adb->query_result($result,$i,'fieldname');
            $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
            
            if($tabid =='4'){$tabname = getTranstab('Contacts');}
            elseif($tabid =='6'){$tabname = getTranstab('Accounts');}
            elseif($tabid == '14'){$tabname = getTranstab('Products');}
            
            $htmlPhone .= "<tr><td>";
            if($countCheck>0)
            {                
                //判断如果是已经选择的字段，那么应该显示选中状态
                $checkfields = $adb->query_result($resultCheck,$j,'fieldids');
                $arrCheck = explode(",",$checkfields);
                if(in_array($fieldid,$arrCheck))
                {
                    $htmlPhone .= "<input type='checkbox' id='$fieldid' checked='checked' name='phoneSMS' />".$tabname.":&nbsp;$fieldlabel";
                }
                else
                {
                    $htmlPhone .= "<input type='checkbox' id='$fieldid' name='phoneSMS' />".$tabname.":&nbsp;$fieldlabel";
                }                
            }
            else
            {
                $htmlPhone .= "<input type='checkbox' id='$fieldid' name='phoneSMS' />".$tabname.":&nbsp;$fieldlabel";   
            }
            $htmlPhone .= "</td></tr>";
        }
        
        $smarty->assign("SMSTYPE",$smstype);
        $smarty->assign("HTMLPHONE",$htmlPhone);
        $smarty->assign("SALESBACKID",$salesbackid);
        echo "####:###";
        $smarty->display("modules/MassSMS/SendSMSSalesBackPhone.tpl");
        
    }
    
    if($contenttype=='content')
    {
        //这里的type和上面两个不一样的原因是不同的表
        if($smstype=='smsFirst')
        {  
            $type = 5;
        }
        else if($smstype=='smsSecond')
        {
            $type = 6;
        }
        
        //变量信息
        $sql="select tabid,name,tablabel from ld_tab where name in ('Products','SalesBack') and presence in(0,2) order by tabid ";
        $result=$adb->pquery($sql,array());
        $printtabs=array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $tabid = $adb->query_result($result,$i,'tabid');
            $tablabel = $adb->query_result($result,$i,'tablabel');
            $printtabs[$tabid]=getTranstab($tablabel);
        }
        
        //确定是否已经设置过了内容模板
        $contentSql = "select id,content,type,description from ld_sendinformcontent where type = ? ";
        $contentResult = $adb->pquery($contentSql,array($type));
        $countResult = $adb->num_rows($contentResult);
        if($countResult > 0)
        {
            for($i=0;$i<$countResult;$i++)
            {
                $content = $adb->query_result($contentResult,$i,'content');
            }
        }
        
        $smarty->assign("PRINTTABS",$printtabs);
        
        $smarty->assign("CONTENT",$content);
        
        $smarty->assign("SMSTYPE",$smstype);
        $smarty->assign("SALESBACKID",$salesbackid);
        echo "####:###";
        $smarty->display("modules/MassSMS/SendSMSSalesBackContent.tpl");
    }
}
exit();

?>