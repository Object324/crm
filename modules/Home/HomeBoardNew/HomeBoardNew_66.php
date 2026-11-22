<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_66 extends  HomeBoardNewParent
{

    public function get_stuff_content_html($stuffinfo)
    {
        global $languageType,$adb;
        //获取一下服务看板在ld_usereport表的id
        $selectsql = "select usereportid from ld_usereport where name='ServiceKanban'; ";
        $selectres = $adb->pquery($selectsql);
        $usereportid = $adb->query_result($selectres,0,'usereportid');

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
        $stuff_content_html = '<div id="stuff_' . $stuffinfo['stuffid'] . '" class="ld_homeboard_index_layout_plate_stuff" style="height: ' . $stuffinfo['height'] . ';">
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
                        <a target="_blank" data-id="ServiceKanban" style="height: 25px; float: right;margin-right: 8px; font-size:12px; color:#999;font-weight: normal;"  title="'.getFixedLabel('MORE').'" href="index.php?pageto_module=ReportAnalysis&pageto_action=OftenUseReport&page_addurl=%26report_name%3DServiceKanban%26refreshUseReport%3D'.$usereportid.'%26refreshleftmenuclick%3Dyes%26frommodule%3DReportAnalysis" id="a_' . $stuffinfo['stuffid'] . '">
                            '.getFixedLabel('MORE').'<b class="home_next"></b>
                        </a>
                    </th>
                </tr>
	        </table>
            <table width="100%" cellpadding="0" cellspacing="0" class="small" >
                <tr id="maincont_row_' . $stuffinfo['stuffid'] . '">
                    <td colspan="2">';
        $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-y: auto; overflow-x:auto;width:100%;height:' . ($stuff_con_height - $this->title_height) . 'px;">';
        $stuff_content_html .= '</div>
                    </td>
                </tr>
            </table>
        </div>';

        return $stuff_content_html;
    }
}

?>