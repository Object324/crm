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
   isset($_REQUEST['salesorderid']) && $_REQUEST['salesorderid'] != '')
{
    $contenttype = $_REQUEST['contenttype'];//phone,time,content
    $smstype = $_REQUEST['smstype'];    
    $salesorderid = $_REQUEST['salesorderid'];
    
    if($contenttype=='phone')
    {
        //根据不同的smstype的值，来确定查找条件
        if($smstype=='smsFirst')
        {  
            $type = 1;
            $tabids = "14";
        }
        else if($smstype=='smsSecond')
        {
            $type = 2;
            $tabids = "14";
        }
        else if($smstype=='smsThird')
        {
            $type = 3;
            $tabids = "4,6";
        }
        
        //确定需要发送的手机字段查找出来
        $SqlFieldCheck = "select id,fieldids,type from ld_sendphoneset where type = ?";
        $resultCheck = $adb->pquery($SqlFieldCheck,array($type));
        $countCheck = $adb->num_rows($resultCheck);
        
        //所有手机字段查找出来
        $SqlField = "select ld_field.tabid,ld_field.fieldid,ld_field.tablename,ld_field.fieldname,ld_tranlabel.fieldlabel  
                    from ld_field 
                    left join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                    where ld_field.tabid in ($tabids) and ld_field.uitype = 1101
                    and ld_field.presence in(0,2) 
                    and ld_tranlabel.languagetype = ? and ld_tranlabel.trantable = ?
                    order by ld_field.fieldid";
        
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $tabid = $adb->query_result($result,$i,'tabid');
            $tabname = getTabname($tabid);
            $fieldid = $adb->query_result($result,$i,'fieldid');
            $fieldname = $adb->query_result($result,$i,'fieldname');
            $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
            
            $htmlPhone .= "<tr><td>";
            if($countCheck>0)
            {                
                //判断如果是已经选择的字段，那么应该显示选中状态
                $checkfields = $adb->query_result($resultCheck,0,'fieldids');
                $arrCheck = explode(",",$checkfields);
                if(in_array($fieldid,$arrCheck))
                {
                    $htmlPhone .= "<input type='checkbox' id='$fieldid' checked='checked' name='phoneSMS' />".getTranstab($tabname).":&nbsp;$fieldlabel";
                }
                else
                {
                    $htmlPhone .= "<input type='checkbox' id='$fieldid' name='phoneSMS' />".getTranstab($tabname).":&nbsp;$fieldlabel";
                }                
            }
            else
            {
                $htmlPhone .= "<input type='checkbox' id='$fieldid' name='phoneSMS' />".getTranstab($tabname).":&nbsp;$fieldlabel";   
            }
            $htmlPhone .= "</td></tr>";
        }
        
        $smarty->assign("SMSTYPE",$smstype);
        $smarty->assign("HTMLPHONE",$htmlPhone);
        $smarty->assign("SALESORDERID",$salesorderid);
        echo "####:###";
        $smarty->display("modules/MassSMS/SendSMSSalesOrderPhone.tpl");
        
    }
    
    
    if($contenttype=='time')
    {
        //根据不同的smstype的值，来确定查找条件
        if($smstype=='smsSecond')
        {
            $type = 2;
        }
        else if($smstype=='smsThird')
        {
            $type = 3;
        }
        
        //所有自定义的日期字段查找出来
        $SqlField = "select ld_producttoolfield.producttoolfieldid,ld_producttoolfield.columnname,
                    ld_tranlabel.fieldlabel,ld_producttoolfield.uitype 
                    from ld_producttoolfield 
                    left JOIN ld_tranlabel on ld_producttoolfield.producttoolfieldid = ld_tranlabel.relateid
                    where presence in (0,2) and uitype in (51,52,53,54) and ld_producttoolfield.input_type !=1 
                    and ld_tranlabel.languagetype = ? and ld_tranlabel.trantable = ? and ld_producttoolfield.tablename = ? and ld_producttoolfield.tabid=?
                    order by ld_producttoolfield.producttoolfieldid";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_producttoolfield','ld_inventoryproductrelscf',getTabid('SalesOrder')));
        $arrDate = array();
        $arrTime = array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $producttoolfieldid = $adb->query_result($result,$i,'producttoolfieldid');
            $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
            $uitype = $adb->query_result($result,$i,'uitype');
            
            if($uitype == '51'||$uitype == '52')
            {
                $arrDate[$producttoolfieldid]= $fieldlabel;
            }
            else if($uitype == '53'||$uitype == '54')
            {
                $arrTime[$producttoolfieldid]= $fieldlabel;
            }
        }
        
        //确定是否已经设置过了定时规则
        $timeSql = "select id,fieldid1,fieldid2,day,hours,minutes,type from ld_sendtimeset where type = ? ";
        $timeResult = $adb->pquery($timeSql,array($type));
        $countResult = $adb->num_rows($timeResult);
        if($countResult > 0)
        {
            $fieldid1 = $adb->query_result($timeResult,0,'fieldid1');
            $fieldid2 = $adb->query_result($timeResult,0,'fieldid2');
            $day = $adb->query_result($timeResult,0,'day');
            $hours = $adb->query_result($timeResult,0,'hours');
            $minutes = $adb->query_result($timeResult,0,'minutes');
        }
        
        $smarty->assign("FIELDIDDATE",$fieldid1);
        $smarty->assign("FIELDIDTIME",$fieldid2);
        $smarty->assign("DAY",$day);
        $smarty->assign("HOURS",$hours);
        $smarty->assign("MINUTES",$minutes);
        
        $smarty->assign("SMSTYPE",$smstype);
        $smarty->assign("SALESORDERID",$salesorderid);
        
        $smarty->assign("SELECTDATE",$arrDate);
        $smarty->assign("SELECTTIME",$arrTime);
        
        echo "####:###";
        $smarty->display("modules/MassSMS/SendSMSSalesOrderTime.tpl");
    }
    
    if($contenttype=='content')
    {
        //这里的type和上面两个不一样的原因是不同的表
        if($smstype=='smsFirst')
        {  
            $type = 2;
        }
        else if($smstype=='smsSecond')
        {
            $type = 3;
        }
        else if($smstype=='smsThird')
        {
            $type = 4;
        }
        
        //变量信息
        $sql="select tabid,name,tablabel from ld_tab where name in ('Products','SalesOrder') and presence in(0,2) order by tabid ";
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
            $content = $adb->query_result($contentResult,0,'content');
        }
        
        $smarty->assign("PRINTTABS",$printtabs);
        
        $smarty->assign("CONTENT",$content);
        
        $smarty->assign("SMSTYPE",$smstype);
        $smarty->assign("SALESORDERID",$salesorderid);
        echo "####:###";
        $smarty->display("modules/MassSMS/SendSMSSalesOrderContent.tpl");
    }
}
exit();

?>