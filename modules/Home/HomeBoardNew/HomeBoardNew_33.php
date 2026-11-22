<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_33 extends  HomeBoardNewParent
{

    public function isActive($tabs)
    {
        $isactive = false;
        foreach ($tabs as $tabname) {
            if (vtlib_isModuleActive($tabname)) {
                $isactive = true;
                break;
            }
        }
        return $isactive;
    }

    public function get_stuff_content_html($stuffinfo)
    {
        global $languageType;
        if($languageType == 'zh' && $stuffinfo['stufftitle_zh'] != ''){
            $stufftitle = $stuffinfo['stufftitle_zh'];
        }elseif ($languageType == 'en' && $stuffinfo['stufftitle_en'] != ''){
            $stufftitle = $stuffinfo['stufftitle_en'];
        }else{
            $stufftitle = $stuffinfo['stufftitle_label'];
        }
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
        }
        $stuff_content_html = '<div data-boardstuffid="' . $stuffinfo['boardstuffid'] . '" id="stuff_' . $stuffinfo['stuffid'] . '" class="ld_homeboard_index_layout_plate_stuff" style="height: ' . $stuffinfo['height'] . ';">
            <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
                <tr id="headerrow_' . $stuffinfo['stuffid'] . '" >
                    <th class="ld-stuff-tit">
                        <div class="ld-stuff-tit-name sort-tip-items" data-tip="'.$stufftitle.'" data-direction="top" data-type="position" style="float: left;">
                            <span class="icon-bluelt"></span>';
        $stuff_content_html .= $stufftitle;
        $stuff_content_html .= '</div>
                    </th>
                    <th colspan="2" class="N_con_tit" align="right">';
        if($stuffinfo['stuff_url']['url'] && $stuffinfo['stuff_url']['url'] != ''){
            $stuff_content_html .= '<a style="height: 25px; margin-right: 8px;float: right; font-size:12px; color:#999;font-weight: normal;"  title="'.getFixedLabel('MORE').'" onclick="home_href(\''.$stuffinfo['stuff_url']['url'].'\',\''.$stuffinfo['stuff_url']['page_addurl'].'\')" href="javascript:;" id="a_' . $stuffinfo['stuffid'] . '">
                            '.getFixedLabel('MORE').'<b class="home_next"></b>
                        </a>';
        }
        $stuff_content_html .= '
                        <div style="display:flex;justify-content: flex-end;">
                            <a style="height: 25px; margin-right: 8px; font-size:12px; color:#999;font-weight: normal;display: inline-block;"  title="'.getFixedLabel('MORE').'" href="#" id="a_' . $stuffinfo['stuffid'] . '" onclick="SalesRankings('.$stuffinfo['stuffid'].')">
                                '.getFixedLabel('MORE').'<b class="home_next"></b>
                            </a>
                        </div>
                    </th>
                </tr>
	        </table>
            <table width="100%" cellpadding="0" cellspacing="0" class="small" >
                <tr id="maincont_row_' . $stuffinfo['stuffid'] . '">
                    <td colspan="2">';
        $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-y: auto; overflow-x:hidden;width:100%;height:' . ($stuff_con_height - $this->title_height) . 'px;">';
        $stuff_content_html .= '</div>
                    </td>
                </tr>
            </table>
        </div>';

        return $stuff_content_html;
    }
}

?>