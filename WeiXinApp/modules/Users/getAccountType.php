<?php
/**
 * 
 * date: 2018/1/12
 * reason：选择公海类型带出分类
 */

if(empty($_REQUEST['accounttype'])) 
ConvertTojsonString(-1,null,'');
crm_load_class_file('cls_CustomViewWX', 'WeiXinApp/WeiXin_CustomView');
$customView = new cls_CustomViewWX('Accounts');
$viewid = $customView->getViewId('Accounts');

$customview_html = $customView->jsongetCustomViewCombo2($viewid, 'Accounts');
array_shift($customview_html);

foreach($customview_html as $key=>$val){
    $customview_htmlNeOp[$key]['text'] = $val['title'];
    $customview_htmlNeOp[$key]['value'] = $val['viewname'];
    $customview_htmlNeOp[$key]['select'] = $key==0?'yes':'no';
    if($viewid==$val['viewname']){
        $customview_htmlNeOp[$key]['select'] = 'yes';
        $select = true;
    }else{
        $customview_htmlNeOp[$key]['select'] = 'no';
    }
}
if(!$select) $customview_htmlNeOp[0]['select']='yes';
$customview_htmlNe['option'] = $customview_htmlNeOp;
ConvertTojsonString(1,$customview_htmlNe,'success');
?>
