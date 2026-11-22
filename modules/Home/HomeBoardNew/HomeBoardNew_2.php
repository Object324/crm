<?php
crm_load_class_file('HomeBoardNewParent','modules/Home/HomeBoardNew');
class  HomeBoardNew_2 extends  HomeBoardNewParent
{

    public function get_stuff_content_html($stuffinfo)
    {
        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
        }
        $stuff_content_html = '<div id="stuff_' . $stuffinfo['stuffid'] . '" class="ld_homeboard_index_layout_plate_stuff" style="height: ' . $stuffinfo['height'] . ';">
            <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
                <tr id="headerrow_' . $stuffinfo['stuffid'] . '" >
                    <th class="ld-stuff-tit">
                        <div class="ld-stuff-tit-name" style="float: left;">
                            <span class="icon-bluelt"></span>
                            ' . date('Y').$stuffinfo['stufftitle_label'].'
                        </div>
                        <div style="margin-top:3px;">
                            <span id="refresh_' . $stuffinfo['stuffid'] . '" style="position:relative;">&nbsp;&nbsp;</span>
                        </div>
                    </th>
                    <th colspan="2" class="N_con_tit" align="right">
                    </th>
                </tr>
	        </table>
            <table width="100%" cellpadding="0" cellspacing="0" class="small" >
                <tr id="maincont_row_' . $stuffinfo['stuffid'] . '">
                    <td colspan="2">
                        <div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-y: auto; overflow-x:hidden;width:100%;height:' . ($stuff_con_height - $this->title_height) . 'px;">
					    </div>
                    </td>
                </tr>
            </table>
        </div>';

        return $stuff_content_html;
    }
}

?>