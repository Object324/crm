<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//布局规则新增和编辑界面
global $adb,$current_user;
$smarty=new lingdangCRM_Smarty();
$ruleid=$_REQUEST['ruleid'];
$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);
$modulefields=$focus->fieldobj->getModuleFields();
//获取成员管理不显示字段
$modulenoshowfields = array();
if($frommodule == 'Users'){
    $modulenoshowfields = $focus->getSearchNoshowfields();
}
$fields = array();
foreach($modulefields as $fieldname => $field){
    //zkt 20241121 BUG20241120-99 含产品分录的单据如：销售订单--触发字段中不应该有小计
    //成员管理不显示字段，不显示
    if(in_array($fieldname,$modulenoshowfields)||$fieldname== 'hdnSubTotal'){
        continue;
    }
    //wym 240529 BUG20240527-79 客户--布局规则，联系人字段可以在显示字段里选到，但是在布局规则的界面上不显示，应该显示
    $tablename=$field->getTableName();
    if(($frommodule=='Accounts'||$frommodule=='ServiceCharge') && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')){
        //客户模块的联系人字段特殊处理
    }else if(!in_array($tablename ,$focus->tab_name)&&$tablename!='ld_attachments') {
        continue;
    }else if($fieldname == 'hdnSubTotal'){
        //产品分录的小计字段不能参与布局规则，无法取值
        continue;
    }
	//布局规则 去除标签字段
	$uitype = $field->getUIType();
	//chj 2021/5/17 45929: （61mis.com/kfbcrm）系统设置-页面设置-公告页面设置-布局规则，公告的布局规则设置应去掉“内容”字段，该字段特殊加入不能生效
	//edit:can 20210806 裂变文章 的内容布局规则
    if(!in_array($uitype,array(301))){
		$fields[$fieldname] = $field;
	}
}
//$fields=(array)$modulefields;
$smarty->assign('Fields', $modulefields);
$fieldname=$fieldname;
if(!empty($ruleid))
{
    //编辑
    $sql='select ld_fieldrule.* from ld_fieldrule where id=? ';
    $result=$adb->pquery($sql,array($ruleid));
    $rulename=$adb->query_result($result,0,'rulename');
    $triggercolumnname=$adb->query_result($result,0,'columnname');
    $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$triggercolumnname,'fieldname');
    $smarty->assign("rulename",$rulename);
    $smarty->assign("columnname",$triggercolumnname);//触发字段
    $arrcondition=array();
   
    
    //触发操作信息
    $sql='select comparator,value,ld_fieldrule_operate.* from ld_fieldrulebasicsearch left join ld_fieldrule_operate 
            on ld_fieldrule_operate.basicsearchid=ld_fieldrulebasicsearch.id
            where ruleid=?
            order by ld_fieldrulebasicsearch.id asc,ld_fieldrule_operate.id asc  ';
    $result=$adb->pquery($sql,array($ruleid));
    $rows=$adb->num_rows($result);
    $j=0;
    $arrcondition_index=0;
    $arr_operate_index=0;
    $arr_condition_basicsearchid=array();//记录basicsearcid的数字位置，
    for($i=0;$i<$rows;$i++)
    {
        $comparator=$adb->query_result($result,$i,'comparator');
        $value=$adb->query_result($result,$i,'value');
        $basicsearchid=$adb->query_result($result,$i,'basicsearchid');

        $arrcondition[$arrcondition_index]['basicsearch']=array('columnname'=>$triggercolumnname, 'comparator'=>$comparator,'value'=>$value,'basicsearchid'=>$basicsearchid);
        $arr_condition_basicsearchid[$basicsearchid]=$arrcondition_index;
        $arr_operate_index=0;
         $arroperate=array();
        $arroperate[$arr_operate_index]=array('columnname'=>'','type'=>'');
        for($j=$i;$j<$rows;$j++)
        {
            $tmpbasicsearchid=$adb->query_result($result,$j,'basicsearchid');
            
            if($tmpbasicsearchid!=$basicsearchid)
            {
                
                $i=$j-1;
                break;
            }
            $columnname=$adb->query_result($result,$j,'columnname');
            $type=$adb->query_result($result,$j,'type');
            $arroperate[$arr_operate_index]=array('columnname'=>$columnname,'type'=>$type);
            $arr_operate_index++;
        }
         $arrcondition[$arrcondition_index]['triggeroperate']=$arroperate;
         $arrcondition[$arrcondition_index]['advancesearch'][]=array('groupid'=>1, 'columnname'=>'','comparator'=>'','value'=>'','columncondition'=>'');
        
         $arrcondition_index++;
         if($j>=$rows)
         {
            break;
         }
         
    }

    
    //其他条件查询
      $sql='select ld_fieldruleadvancesearch.*,ld_fieldrulebasicsearch.id as rulebasicesearchid from ld_fieldrulebasicsearch 
            left join ld_fieldruleadvancesearch 
            on ld_fieldruleadvancesearch.basicsearchid=ld_fieldrulebasicsearch.id
            where ruleid=?
            order by ld_fieldrulebasicsearch.id asc,ld_fieldruleadvancesearch.id asc  ';
    $result=$adb->pquery($sql,array($ruleid));
    $rows=$adb->num_rows($result);
    $j=0;
   
    $arr_advance_idex=0;
    for($i=0;$i<$rows;$i++)
    {
        
        $basicsearchid=$adb->query_result($result,$i,'rulebasicesearchid');
        $arr_advance_idex=0;
        $arradvance=array();
        $arradvance[$arr_advance_idex]=array('groupid'=>1, 'columnname'=>'','comparator'=>'','value'=>'','columncondition'=>'');
        for($j=$i;$j<$rows;$j++)
        {
            $tmpbasicsearchid=$adb->query_result($result,$j,'rulebasicesearchid');
            if($tmpbasicsearchid!=$basicsearchid)
            {
                $i=$j-1;
                break;
            }
            $columnname=$adb->query_result($result,$j,'columnname');
            $comparator=$adb->query_result($result,$j,'comparator');
            $value=$adb->query_result($result,$j,'value');
            $condition=$adb->query_result($result,$j,'columncondition');
            $arradvance[$arr_advance_idex]=array('groupid'=>1,'columnname'=>$columnname,'comparator'=>$comparator,'value'=>$value,'columncondition'=>$condition);
            $arr_advance_idex++;
            
        }
              
        //$arr_condition_basicsearchid[$basicsearchid]：保证其他查询是在触发字段的数组
         $arrcondition[$arr_condition_basicsearchid[$basicsearchid]]['advancesearch']=$arradvance;
         if($j>=$rows)
         {
          
                break;
          }
        
    }
            
}

  /*  echo '<pre>';

print_r($arrcondition);
echo '</pre>';
exit();*/
$_REQUEST['diony']='yes';

$content=$smarty->fetch("Settings/LayoutBlockrulePop.tpl");
$arr['content']=$content;
$arr['setrequiredlabel']=getFixedLabel('Setmandatoryfield');
$arr['displayfieldlabel']=getFixedLabel('Displayfields');
$arr['triggerfieldname']=$fieldname;
$arr['triggercolumnname']=$triggercolumnname;
$arr['title']=getFixedLabel('LayoutRules');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['editlabel']=getFixedLabel("EDIT");
$arr['deletelabel']=getFixedLabel("DELETE");
$arr['rulenamelabel']=getFixedLabel('RULENAME');
$arr['fields']=$fields;
$arr['condition']=$arrcondition;

//相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");
$arr['datetimestr']=CommonView::stdFilterDateTimeStr();//日期查询条件的下拉框
$arr['flabel']=CommonView::getComparatorLabel();//查询条件翻译
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($frommodule);
$arr['advanceFields'] = $controller->getAdvanceFields();
ConvertTojsonString(1,$arr,'success');
?>