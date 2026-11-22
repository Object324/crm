<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class HomeBoardNew_customtable extends HomeBoardNewParent
{
    public function get_stuff_content_html($stuffinfo){
        global $languageType;
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
        }

        $stuff_content_html = '
            <div id="stuff_tables_'.$stuffinfo['stuffid'].'" data-boardstuffid="'.$stuffinfo['boardstuffid'].'" class="ld_homeboard_index_layout_plate_stuff" style="height: '.$stuffinfo['height'].';">
                <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
                    <tr id="headerrow_tables_'.$stuffinfo['stuffid'].'" >
                        <th class="ld-stuff-tit">
                            <div class="ld-stuff-tit-name" style="float: left;">';
        if($languageType == 'zh' && $stuffinfo['stufftitle_zh'] != ''){
            $stuff_content_html .= '<span class="icon-bluelt">'.$stuffinfo['stufftitle_zh'].'</span>';
        }elseif ($languageType == 'en' && $stuffinfo['stufftitle_en'] != ''){
            $stuff_content_html .= '<span class="icon-bluelt">'.$stuffinfo['stufftitle_en'].'</span>';
        }else{
            $stuff_content_html .= '<span class="icon-bluelt">'.$stuffinfo['stufftitle_label'].'</span>';
        }
        $stuff_content_html .= '
                            </div>
                        </th><th colspan="2" class="N_con_tit" align="right">';
        $stuff_content_html .= '<a style="height: 25px; margin-right: 8px;float: right; font-size:12px; color:#999;font-weight: normal;"  title="'.getFixedLabel('MORE').'" onclick="homestuffObj.CustomTablesChuantou_Home(\''.$stuffinfo['stuffid'].'\',\''.$stuffinfo['boardstuffid'].'\',\''.$stuffinfo['stufftype'].'\')" href="javascript:;" id="a_' . $stuffinfo['stuffid'] . '">
                            '.getFixedLabel('MORE').'<b class="home_next"></b>
                        </a>';
        $stuff_content_html .=  '</th></tr>
                </table>
                <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed !important;">
                    <tr id="maincont_row_'.$stuffinfo['stuffid'].'">
                        <td colspan="2">
                            <div id="myTable_'.$stuffinfo['stuffid'].'" class="" style="width: 100%;height:'.($stuff_con_height - $this->title_height).'px;"><div class="customtable-content"><div class="report-detail marL20 marR20" tag="div_thResizableContent">
            <table border="0" cellspacing="1" cellpadding="0" id="thResizable" class="customtable-list" style="margin:0 auto;">
                <thead style="">
                <tr tag="reportDetailHeader" style="height:40px;position:sticky;top:0;">
                   <th class="empty-field" style="width:100%;">'.getFixedLabel('PLEASESELECTFIELD').'</th>
                </tr>
                </thead>
               <tbody style="background-color: #fff;" tag="reportDetailBody">
                </tbody>
            </table>
            </div></div></div>
                        </td>
                    </tr>
                </table>
            </div>';
        return $stuff_content_html;
    }
}

?>