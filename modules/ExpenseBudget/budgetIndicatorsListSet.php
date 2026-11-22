<?php
global $current_language, $theme;
global $adb;
//业绩指标 下拉框设置弹框
$budgetType = $_REQUEST['expensebudget_type'];
$module = $_REQUEST['modulename'];
$fieldname = $_REQUEST['fieldname'];
$focus = CRMEntity::getInstance($module);
$budgetTypePicklist = $focus->getExpenseBudgetTypePicklist($budgetType,'','',['name','translateName','isopen'],'no');
$fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
$table = '';
if(!empty($fieldinfo)){
    $fieldlabel = $fieldinfo->getFieldLabel();
}
$headtitle = getFixedLabel("EDITPICKLIST");
$table .= '<div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">';
$table .= '<table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">';
$table .= '<tr>';
$table .= '<th>'.getFixedLabel('MAILNAME').'</th>';
$table .= '<th style="width: 22%;">'.getFixedLabel('OPERATING').'</th>';
$table .= '</tr>';

foreach($budgetTypePicklist as $key=>$val){
    $table .= '<tr>';
    $table .= '<td><input tag="combox" readonly class="detailedViewTextBox" oldvalue="'.$val['translateName'].'" name="'.$val['name'].'" value="'.$val['translateName'].'" style="padding-left:3px;" type="text"><span></span></td>';
    $table .= '<td class="sort_td">';
    $table .= '<a class="icon-category category-sup marR8" style="cursor: pointer;" onclick="ComboxPopup.popupobj.moveUp(this)" title="'.getFixedLabel('MOVEUP').'"></a>';
    $table .= '<a class="icon-category category-sdown marR8" style="cursor: pointer;"onclick="ComboxPopup.popupobj.moveDown(this)" title="'.getFixedLabel('MOVEDOWN').'"></a>';
    if($val['isopen']=='yes'){
        $table .= '<a style="cursor: pointer;color:red;" isopen="yes" onclick="ExpenseBudgetObj.setIndicatorsStatus(this,\''.$val['name'].'\',\''.$budgetType.'\')">'.getFixedLabel('INACTIVATE').'</a>';
    }else{
        $table .= '<a style="cursor: pointer;" isopen="no" onclick="ExpenseBudgetObj.setIndicatorsStatus(this,\''.$val['name'].'\',\''.$budgetType.'\')">'.getFixedLabel('ACTIVATE').'</a>';
    }
    $table .= '</td>';
    $table .= '</tr>';
}
$table .= '</table>';
$table .= '</div>';
$table .= '<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">';
$table .= '</table>';

$_REQUEST['diony']='diony';
$arr['title']=$headtitle.">".$fieldlabel;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$table;
ConvertTojsonString(1,$arr,"success");