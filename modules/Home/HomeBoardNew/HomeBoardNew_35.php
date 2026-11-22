<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_35 extends  HomeBoardNewParent
{

    public function get_stuff_content_html($stuffinfo)
    {
        global $current_user,$languageType;

        $boardid=$_REQUEST['boardid'];
        $allheight = $this->getSalesKitHeight($boardid);
        if($languageType == 'zh' && $stuffinfo['stufftitle_zh'] != ''){
            $stufftitle = $stuffinfo['stufftitle_zh'];
        }elseif ($languageType == 'en' && $stuffinfo['stufftitle_en'] != ''){
            $stufftitle = $stuffinfo['stufftitle_en'];
        }else{
            $stufftitle = $stuffinfo['stufftitle_label'];
        }

        $stuff_content_html = '<div data-boardstuffid="'.$stuffinfo['boardstuffid'].'" id="stuff_' . $stuffinfo['stuffid'] . '" class="ld_homeboard_index_layout_plate_stuff">
            <table width="100%" cellpadding="0" cellspacing="0" class="ld_homeboardstuff_E_stripe">
                <tr id="headerrow_' . $stuffinfo['stuffid'] . '" >
                    <th class="ld-stuff-tit">
                        <div class="ld-stuff-tit-name sort-tip-items" data-tip="'.$stufftitle.'" data-direction="top" data-type="position" style="float: left;">';
        $stuff_content_html .= $stufftitle;
        $stuff_content_html .= '</div>';
        if(is_admin($current_user)){
            $stuff_content_html .= '<i class="ld-fonticon ld-fonticon-set lineheight24" onclick="EditSalesKitSetReport(event,ld(this),' . $stuffinfo['stuffid'] . ',\''.$stuffinfo['stufftitle_label'].'\',\''.$boardid.'\',\'\')"></i>';
        }
        $stuff_content_html .= '
                    </th>
                    <th colspan="2" class="N_con_tit" align="right">
                    </th>
                </tr>
	        </table>
            <table width="100%" cellpadding="0" cellspacing="0" class="small">
                <tr id="maincont_row_' . $stuffinfo['stuffid'] . '">
                    <td colspan="2">
                        <div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow:hidden; width:100%;">
					    </div>
                    </td>
                </tr>
            </table>
        </div>';

        return $stuff_content_html;
    }

    public function getSalesKitHeight($boardid){
         crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
        $SalesKitEditObj=new SalesKitEditSetting($boardid);
        $SalesKitEditObj->getSelectedSalesKitList(35);
        $selected_saleskit_list = $SalesKitEditObj->selected_saleskit_list;//被选中的简报信息
        $count = sizeof($selected_saleskit_list);//选中的销售简报的数量
        //布局设置查找
        $saleskit_layout = $SalesKitEditObj->getSaleskitLayout($count);
        return ($saleskit_layout['height']+12)*$saleskit_layout['rowcount'];
    }
}

?>