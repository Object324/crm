<?php
global $adb;
$mode = $_REQUEST['mode'];
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
if(isset($mode)&&$mode=='editblackkeywords')
{
    $keywordid = $_REQUEST['keywordid'];
    $blackwordkey = "";
    $title = getFixedLabel('NEW').getFixedLabel('BLACKLISTKEYWORDS');
    if(!empty($keywordid))
    {
        $blackwordkey = cls_BusinessInformation::getBlackKeyWordsById($keywordid);
        $title = getFixedLabel('EDIT').getFixedLabel('BLACKLISTKEYWORDS');
    }
    $html = '<table  width="100%"><tbody><tr>';
    $html .= '<td class="ld-form-item-label">'.getFixedLabel('SEARCHKEY').'</td>';
    $html .= '<td class="ld-form-item-content">';
    $html .= '<input type="text" fieldonly="1"  name="blackkeywords" id="blackkeywords" value="'.$blackwordkey.'" class="ld-input-inner">';
    $html .= '</td>';
    $html .= '</tr></tbody></table>';
    $arr['content'] = $html;
    $arr['title']=$title;
    $arr['oktext']= getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel('CANCEL');

    ConvertTojsonString(1,$arr,'success');
}
else if(isset($mode)&&$mode == 'saveblackkeywords')
{
    $keywordid = $_REQUEST['keywordid'];
    $keywordtext = $_REQUEST['keywordtext'];
    //查询keyword是否存在
    if(cls_BusinessInformation::IsExistBlackWordsnotid($keywordtext,$keywordid)){
        ConvertTojsonString(-1,array(),getFixedLabel('KEYWORDEXISTREENTIER'));
    }
    cls_BusinessInformation::saveBlackKeyWords($keywordtext,$keywordid);
    ConvertTojsonString(1,array(),'success');
}
else if(isset($mode)&&$mode == 'deleteblackkeywords')
{
    $keywordid = $_REQUEST['keywordid'];
    cls_BusinessInformation::deleteBlackKeyWords($keywordid);
    ConvertTojsonString(1,array(),'success');
}
?>