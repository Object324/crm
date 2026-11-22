<?php
global $current_user;
$_REQUEST['diony']='diony';

$customview=CustomView::getInstance($_REQUEST['module']);
$categorylist=$customview->getCvListByModule();
$smarty=new lingdangCRM_Smarty();
$smarty->assign("CATEGORYLIST",$categorylist);


//wyt 230628 XUQIU1001517 PC端-模块列表界面，查询分类设置优化
$tableN .='<div class="ld-category-settingboard">';
$tableN .='<div>';
    $tableN .='<div class="ld-category-prompt">';
        $tableN .='<div class="ld-datacategorylist">';
        $tableN .='<span class="ld-category-prompt-content">'.getFixedLabel('DRAGGABLESETTING');
        $tableN .='</span><a href="javascript:void(0);" class="ld-button" onclick="DataCategoryListPopup.add()">'.getFixedLabel('NEWFILTERS').'</a>';
        $tableN .='</div>';
    $tableN .='</div>';

    $tableN .='<div class="ld-category-listtable">';
        $tableN .='<div class="ld-category-listtitle">';
            $tableN .='<div class="ld-category-title-l">'.getFixedLabel('Category_Name').'</div>';
            $tableN .='<div class="ld-category-title">'.getFixedLabel('OPERATING').'</div>';
        $tableN .='</div>';

        $count=sizeof($categorylist);
        $i=0;

        $tableN .='<ul class="ld-category-detail customviewlisttable" >';
        foreach($categorylist as $key=>$val){
            if($val['viewname']=='All')
            {
                $tableN .='<li class="ld-category-l" tag='.$key.'>';
            }else{
                $tableN .='<li class="ld-category-l ld-category-draggable" tag='.$key.'>';
            }
            $viewname=$val['viewname'];
            if($val['viewname']=='All')
            {
                $viewname=getFixedLabel("ALL");
            }
            $tableN .='<div class="ld-category-name">'.$viewname.'</div>';
            $tableN .='<div class="ld-category-operate">';

            if($val['edit_permit']=='yes'){
                $tableN .= '<a onclick="DataCategoryListPopup.Edit(this,'.$key.')" title="'.getFixedLabel('EDIT').'" style="margin-right:8px;cursor: pointer;"><b class="ld-category-icon ld-category-edit"></b></a>';
            }
            $tableN .= '<a onclick="DataCategoryListPopup.Copy(this,'.$key.')" title="'.getFixedLabel('COPY').'" style="margin-right:8px;cursor: pointer;"><b class="ld-category-icon ld-category-copy"></b></a>';

            if($val['del_permit']=='yes'&&$val['viewname']!='All'){
                $tableN .= '<a class="ld-category-icon ld-category-del" style="cursor: pointer;" tag="'.$key.'_del" onclick="DataCategoryListPopup.delVal(this,'.$key.');" title="'.getFixedLabel('DELETE').'"></a>';
            }
            if($val['viewname']!='All'){
                $tableN .= '<a class="ld-category-icon ld-category-drag drag-handle"   title="'.getFixedLabel('drag').'"></a>';
            }

            $tableN .='</div>';
            $tableN .='</li>';
            $i++;


        }


        $tableN .='</ul>';
    $tableN .='</div>';
$tableN .='</div>';
$tableN .='</div>';

/*旧代码
 $table .= '<table class="settingPopTable lasttdbordernon tdwhitespace customviewlisttable"  border="0" cellpadding="0" cellspacing="0" width="100%">';
 $table .= '<tr>';

 $table .= '<th>'.getFixedLabel('Category_Name').'</th>';
 $table .= '<th style="width: 40%;">'.getFixedLabel('OPERATING').'</th>';
 $table .= '</tr>';
 $count=sizeof($categorylist);
 $i=0;
foreach($categorylist as $key=>$val){
        $table .= '<tr tag='.$key.'>';
        $viewname=$val['viewname'];
        if($val['viewname']=='All')
        {
            $viewname=getFixedLabel("ALL");
        }
        $table .= '<td>'.$viewname.'</td>';
        $table .= '<td>';

        
        if($val['edit_permit']=='yes')
            $table .= '<a onclick="DataCategoryListPopup.Edit(this,'.$key.')" title="'.getFixedLabel('EDIT').'" style="margin-right:8px;cursor: pointer;"><b class="icon-category category-pen"></b></a>';
        $table .= '<a onclick="DataCategoryListPopup.Copy(this,'.$key.')" title="'.getFixedLabel('COPY').'" style="margin-right:8px;cursor: pointer;"><b class="icon-category category-copy"></b></a>';
        if($current_user->is_admin=='on')
        {
            if(sizeof($categorylist)>2)
            {
                  if($i!=0&&$i!=1&&$val['viewname']!='All')
                    $table .= '<a class="icon-category category-sup marR8 datacategory_up" style="cursor: pointer;" tag="'.$key.'_up" onclick="DataCategoryListPopup.moveUp(this,'.$key.')" title="'.getFixedLabel('MOVEUP').'"></a>';
                else
                    $table .= '<a class="icon-category category-sup marR8 datacategory_up" style="display:none" tag="'.$key.'_up" onclick="DataCategoryListPopup.moveUp(this,'.$key.')" title="'.getFixedLabel('MOVEUP').'"></a>';
                if($i!=$count-1&&$val['viewname']!='All')
                    $table .= '<a class="icon-category category-sdown marR8 datacategory_down" style="cursor: pointer;" tag="'.$key.'_down" onclick="DataCategoryListPopup.moveDown(this,'.$key.')" title="'.getFixedLabel('MOVEDOWN').'"></a>';
                else
                    $table .= '<a class="icon-category category-sdown marR8 datacategory_down" style="display:none" tag="'.$key.'_down" onclick="DataCategoryListPopup.moveDown(this,'.$key.')" title="'.getFixedLabel('MOVEDOWN').'"></a>';
            }
            else
            {
                $table .= '<a class="icon-category category-sup marR8 datacategory_up" style="display:none" tag="'.$key.'_up" onclick="DataCategoryListPopup.moveUp(this,'.$key.')" title="'.getFixedLabel('MOVEUP').'"></a>';
                $table .= '<a class="icon-category category-sdown marR8 datacategory_down" style="display:none" tag="'.$key.'_down" onclick="DataCategoryListPopup.moveDown(this,'.$key.')" title="'.getFixedLabel('MOVEDOWN').'"></a>';
            }
        }
        if($val['del_permit']=='yes'&&$val['viewname']!='All')
            $table .= '<a class="icon-homeimg icon-sdel" style="cursor: pointer;" tag="'.$key.'_del" onclick="DataCategoryListPopup.delVal(this,'.$key.');" title="'.getFixedLabel('DELETE').'"></a>';
        $table .= '</td>';
        $table .= '</tr>';
        $i++;
}
$table .= '<tr><td colspan="2">'.'<a href="javascript:void(0);" class="pg-btn-blue dinline-block" onclick="DataCategoryListPopup.add()">'.getFixedLabel('NEWFILTERS').'</a>'.'</td></tr>';
$table .= '</table>';
$table .= '</div>';
*/

$arr['title']=getFixedLabel('managecustomview');
//$arr['content']=$table;
$arr['content']=$tableN;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>