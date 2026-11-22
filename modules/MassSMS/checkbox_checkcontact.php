<?php
global $adb;

$num_rows_info = count($info);
$value_all = "";
//根据字段和表查询
$num_rows_info = count($info);

$info1 = "";
$info2 = "";
$sql = '';

$mobilearray = array();

if($_REQUEST['fieldname']){
          $focus=CRMEntity::getInstance('Contacts');
        $fieldobj=$focus->fieldobj;
        if(isset($_REQUEST['fieldname']))
        {
            $contact_fieldname = trim(trim($_REQUEST['fieldname'],','));
        }
        
        if(isset($_REQUEST['allids']))
        {
            $contactid = $_REQUEST['allids'];
        }
        $contact_fieldname = explode(",",$contact_fieldname);
        $num=sizeof($contact_fieldname);
        $leftjoin=' from ld_contactdetails ';
        $info = array();
    
        for($i=0;$i<$num;$i++)
        {
            $fieldinfo=$fieldobj->getFieldInfoobjBykey('fieldname',$contact_fieldname[$i]);
            $sql.=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName().',';
            $tables[]=$fieldinfo->getTableName();
            $columns[]=$fieldinfo->getColumnName();
        }
        if(in_array('ld_contactscf',$tables))
        {
            $leftjoin=' from ld_contactdetails left join ld_contactscf  on ld_contactscf.contactid=ld_contactdetails.contactid ';
        }
        
        if($contactid=='all')
        { 
            //edit:duan reason:群发短信，选择联系人全选所有单据时没有带出高级查询条件
            if(isset($_SESSION['PopupViewSearch']['Contacts']['input'])){
                $input = $_SESSION['PopupViewSearch']['Contacts']['input'];
            }else{
                $input = $_REQUEST;
            }
            $tm_where = getSelectQuery($input,'Contacts','where');
            $leftjoin = getSelectQuery($input,'Contacts','from');
            $query='select '.$sql.' ld_contactdetails.contactid,lastname '.$leftjoin .$tm_where;
        }
        else
        $query='select '.$sql.' ld_contactdetails.contactid,lastname '.$leftjoin .' 
            where ld_contactdetails.contactid in( '.$contactid.')';

        $result=$adb->pquery($query,array());
        
         $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'Contacts',SHOW_LISTVIEW);
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $record=$adb->query_result($result,$i,'contactid');
            $showfieldvalueobj->setRecorId($record);
            foreach($columns as $columnname)
            {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                 $mobile= $adb->query_result($result,$i,$columnname);
                 $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,$mobile,$mobile);
                 if($mobile!=''&&!array_key_exists($mobile,$mobiles))
                 {
                    if(preg_match(globalStatic::$reg_mobile_digit,$mobile))
                     {
                         $mobiles[$mobile]=$showvalue['value'];
                         $accepter .=$showvalue['value'].'<'.$adb->query_result($result,$i,'lastname').'>'."\r\n";  
                         $hiddenaccepter .=base64_encode($mobile)."\r\n";
                     }
                 }
            }
        }
        
}else{
    /**
    更新操作
    edit:andrew
    date:20131230
    reason:用户多选搜索电话
    **/
    $sql_value = "SELECT last_name,phone_mobile
				 	FROM ld_users
					WHERE id in(".$contactid.") and phone_mobile<>''";
        $result_info_select = $adb->pquery($sql_value,array());
        $num_rows_infomation = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($num_rows_infomation);
        if($num_rows_infomation)
        {
            for($j=0;$j<$num_rows_infomation;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'last_name'),
                '1'=>$adb->query_result($result_info_select,$j,'phone_mobile')
                );
                $infoall = $info_select_detial[$j];
                
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1']))
                {
				  if(isset($mobilearray[$infoall['1']])) continue;
					$mobilearray[$infoall['1']] = $infoall['0'];
                    $hddMobileValue=base64_encode($infoall['1']); 
                    $contactid=explode(',',$contactid);
                  for($i=0;$i<count($contactid);$i++){                                           
                    $infoall['1']=fieldValueUitype::SetMobileStyle($contactid[$i],$infoall['1'],'Contacts');//显示手机样式。                                        
                   }                                   
                    $info2 .= $infoall['1']."<".$infoall['0'].">\r"."|".$hddMobileValue."|";  
                }  
            }        
        }
}
$value_all.= $info1;
$value_all.= $info2;
$information_all = $value_all;

// @edit:dong @date:2020/09/23 @reason: bug0042714营销>群发短信：接收人手机选择“联系人”，勾选单据点击“选择”按钮，弹出框点击“选择”按钮没有反应
//echo "#####SUCCESS#####".$accepter."#####SUCCESS#####".htmlspecialchars($hiddenaccepter);
//exit();
$_REQUEST['diony']='diony';
$arr['content']=$accepter;
ConvertTojsonString(1,$arr,"success");
?>