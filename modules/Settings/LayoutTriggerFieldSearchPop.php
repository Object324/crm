<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//触发字段弹出层（基本查询）
global $adb;
$columnname=$_REQUEST['columnname'];
$frommodule=$_REQUEST['frommodule'];

$focus=CRMEntity::getInstance($frommodule);

$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
$tablename=$fieldinfo->getTableName();
$fieldlabel=$fieldinfo->getFieldLabel();
$fieldname=$fieldinfo->getFieldName();
$typeofdata=$fieldinfo->getTypeOfData();
$bigtype=$fieldinfo->getBigType();

$html="<table cellpadding='0' border='0' cellspacing='20' style='width:100%;'>";
$html.='<tr>';
//查询字段
$html.='<td>';
$typeofdatas=explode('~',$typeofdata);
$value="$tablename:$columnname:$fieldname:$frommodule_$fieldlabel:".$typeofdatas[0];

//ld_contactdetails:accountid:account_id:Contacts_客户名称:V
$html.=$fieldlabel.'<select style="display:none" name="fcol0" id="fcol0">
                    <option value="'.$value.'" selected>test</option>
                 <select>';
     
$html.='</td>';

//查询条件
$html.='<td>';
if($bigtype!='picklist')
$html.='<select name="fop0" id="fop0" class="commonSelectPop" 
                style="width:90%;" onchange="addRequiredElements(0);">'.
         '<option value="">--'.getFixedLabel('NONE').'--</option>       
        </select>';
else
{
    $html.='<select name="fop0" id="fop0" class="commonSelectPop" 
                style="width:90%;" >'.
         '<option value="">--'.getFixedLabel('NONE').'--</option>       
        </select>';
}
$html.='</td>';

//查询内容
$html.='<td>';

if(stripos($typeofdata,'d~')!==false)
{
    //edit:can 2021-01-13 044263: （https://61mis.com/kfbcrm [^]）页面设置->布局规则，触发字段选择“日期”类型字段，设置触发字段条件弹出层中“关键字”类型显示错误
    $html.='<input  class="Wdate" name="fval0" id="fval0" class="commonTextBoxPop" type="text" onclick=\''.'WdatePicker({startDate:"%y-%M-%d",dateFmt:"yyyy-MM-dd",alwaysUseStartDate:true})'.'\' value="" style="width:120px">';
    $html.='<input  class="Wdate"  name="fval_ext0" id="fval_ext0" class="commonTextBoxPop" type="text"onclick=\''.'WdatePicker({startDate:"%y-%M-%d",dateFmt:"yyyy-MM-dd",alwaysUseStartDate:true})'.'\'  style="width:120px;">';

}
else if($bigtype=='datetime')
{
    $html.='<input name="fval0" id="fval0" class="commonTextBoxPop" type="text" value="" style="width:150px">';
    $html.='<input name="fval_ext0" id="fval_ext0" class="commonTextBoxPop" type="text" value="" style="width:150px;display:none">';

}
else
{
    $html.='<input name="fval0" id="fval0" class="commonTextBoxPop" type="text" value="" style="width:150px">';
}

$html.='</td>';

$html.='</tr>';
$html.='</table>';
$_REQUEST['diony']='yes';
$arr['content']=$html;
$arr['title']=getFixedLabel('SetTriggerFieldCondition');
$arr['oktext']=getFixedLabel('SAVE');
$arr['canceltext']=getFixedLabel('CANCEL');
if($bigtype=='picklist')
{
    crm_load_class_file('cls_PickList_Ori','include/Functions/PickList');
    $picklistobj=new cls_PickList_Ori();
   $arr['picklistoptions']= $picklistobj->getPickListValues($fieldname,'ld_field');
    
}
else
{
    $arr['picklistoptions']=array();
}

ConvertTojsonString(1,$arr,'success');


?>