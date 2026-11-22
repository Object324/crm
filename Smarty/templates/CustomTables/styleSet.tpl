<div class="customtable-content" style="display:none;">
<form id="styleSetForm">
<table width="800px" border="0" cellspacing="0" cellpadding="0" align="left" id="styleSet" class="settingPopTable">
    <tbody>
    <tr>
        <td align="left" class="editrelhead" colspan="4">
            <b>{'HeaderStyleSettings'|@getFixedLabel}</b>
            <input type="hidden" name="tagname" value="">
        </td>
    </tr>
    <tr>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div>{'Backgroundcolor'|@getFixedLabel}</div>
                <div name="color_div" class="color-div" style="background: #ddd;" color=""></div>
                <input type="hidden" name="background_color_header" value="">
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div>{'FontColor'|@getFixedLabel}</div>
                <div name="color_div" class="color-div" style="background: #ddd;" color=""></div>
                <input type="hidden" name="font_color_header" value="">
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div class="marR5">{'fontsize'|@getFixedLabel}</div>
                <div class="gwidth100">
                    <!--BUG0068659 txy 2023.06.26 报表，字段设置->样式设置弹出层中，“字体大小”下拉选项值顶格了-->
                    <select name="font_size_header" class="detailedViewTextBox custom-select commonSelectPop" >
                        <option value=""></option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13">13</option>
                        <option value="14" selected>14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20">20</option>
                        <option value="22">22</option>
                        <option value="24">24</option>
                        <option value="26">26</option>
                        <option value="28">28</option>
                        <option value="30">30</option>
                        <option value="32">32</option>
                    </select>
                </div>
                <div>px</div>
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-end lineheight42 marR10">
                <label>
                    <input class="second_switch" type="checkbox" name="font_bolder_header" id="font_bolder_header" checked>&nbsp;{'BoldFont'|@getFixedLabel}
                </label>
            </div>
        </td>
    </tr>
    <tr>
        <td align="left" class="editrelhead" colspan="4">
            <b>{'TableBodyStyleSettings'|@getFixedLabel}</b>
        </td>
    </tr>
    <tr>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div>{'Backgroundcolor'|@getFixedLabel}</div>
                <div name="color_div" class="color-div" style="background: #ddd;" color=""></div>
                <input type="hidden" name="background_color_body" value="">
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div>{'FontColor'|@getFixedLabel}</div>
                <div name="color_div" class="color-div" style="background: #ddd;" color=""s></div>
                <input type="hidden" name="font_color_body" value="">
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-start lineheight42">
                <div class="marR5">{'fontsize'|@getFixedLabel}</div>
                <div class="gwidth100">
                    <!--BUG0068659 txy 2023.06.26 报表，字段设置->样式设置弹出层中，“字体大小”下拉选项值顶格了-->
                    <select name="font_size_body" class="detailedViewTextBox custom-select commonSelectPop">
                        <option value=""></option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13" selected>13</option>
                        <option value="14">14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20">20</option>
                        <option value="22">22</option>
                        <option value="24">24</option>
                        <option value="26">26</option>
                        <option value="28">28</option>
                        <option value="30">30</option>
                        <option value="32">32</option>
                    </select>
                </div>
                <div>px</div>
            </div>
        </td>
        <td width="25%">
            <div class="ld-flex-end lineheight42 marR10">
                <label>
                    <input class="second_switch" type="checkbox" name="font_bolder_body" id="font_bolder_body">&nbsp;{'BoldFont'|@getFixedLabel}
                </label>
            </div>
        </td>
    </tr>
    <tr>
        <td align="left" colspan="4">
            <div class="ld-flex-start lineheight42">
                <a title="{'RESTORETHEDEFAULT'|@getFixedLabel}" class="pg-btn-blue dinline-block lfloat" id="resetdefault" style="position: unset;">
                    <span>{'RESTORETHEDEFAULT'|@getFixedLabel}</span>
                </a>
            </div>
        </td>
    </tr>
    </tbody>
</table>
</form>
</div>