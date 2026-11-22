
<table class="" border="0" cellspacing="0" cellpadding="0" width="100%">
    <tbody>
    <tr>
        <td colspan="4">
            <div name="displayfields">
                <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                    <tbody>
                    <tr>
                        <td colspan="4" class="editrelhead">
                            <b id="yangshi_set">{'StyleSettings'|@getFixedLabel}</b>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <div class="style-set-list" id="style_set_list">
                                <div class="style-set-line">
                                    {*X轴名称*}
                                    <div class="style-set-label">{'Xaxisname'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <input type="text" name="xaxis_bottom_name" id="xaxis_bottom_name" placeholder="{'Xaxisname'|@getFixedLabel}" value="{$chartSet['xaxis1']->bottom->name}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*上X轴名称*}
                                    <div class="style-set-label">{'UpperXaxisname'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <input type="text" name="xaxis_top_name" id="xaxis_top_name" placeholder="{'UpperXaxisname'|@getFixedLabel}" value="{$chartSet['xaxis1']->top->name}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*Y轴名称*}
                                    <div class="style-set-label">{'Yaxisname'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <input type="text" name="yaxis_left_name" id="yaxis_left_name" placeholder="{'Yaxisname'|@getFixedLabel}" class="detailedViewTextBox input-width-70" autocomplete="off" value="{$chartSet['yaxis1']->left->name}">
                                    </div>
                                </div>
                                <div class="style-set-line" {if $chartSet['yaxis1']->right}{else}style="display:none"{/if}>
                                    {*右Y轴名称*}
                                    <div class="style-set-label">{'RightYaxisname'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <input type="text" name="yaxis_right_name" id="yaxis_right_name" value="{$chartSet['yaxis1']->right->name}" placeholder="{'RightYaxisname'|@getFixedLabel}"  class="detailedViewTextBox input-width-70" autocomplete="off">
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*X轴名称倾斜角度*}
                                    <div class="style-set-label">{'Xaxisscaletiltangle'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <input type="number" name="xaxis_name_rotate" id="xaxis_name_rotate" placeholder="{'Xaxisscaletiltangle'|@getFixedLabel}" value="{$chartSet['xaxis1']->bottom->axisLabel->rotate}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*图例朝向*}
                                    <div class="style-set-label">{'Legendorientation'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <select name="legend_orient" id="legend_orient" class="detailedViewTextBox input-width-70">
                                            {foreach item=legendOri key=legendOriKey from=$legendOrient}
                                                <option {if $chartSet['legend1']->orient==$legendOriKey} selected  {/if }  value="{$legendOriKey}">{$legendOri}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*图例位置*}
                                    <div class="style-set-label">{'Legendposition'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <select name="legend_position" id="legend_position" class="detailedViewTextBox input-width-70">
                                            {foreach item=legendPos key=legendPosKey from=$legendPosition}
                                                <option {if $chartSet['legend1']->legend_position==$legendPosKey} selected  {/if }  value="{$legendPosKey}">{$legendPos}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*图例类型*}
                                    <div class="style-set-label">{'LegendType'|@getFixedLabel}</div>
                                    <div class="style-set-input">
                                        <select name="legend_type" id="legend_type" class="detailedViewTextBox input-width-70">
                                            {foreach item=legendTyp key=legendTypKey from=$legendType}
                                                <option {if $chartSet['legend1']->type==$legendTypKey} selected {/if } value="{$legendTypKey}">{$legendTyp}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                </div>
                                <div class="style-set-line">
                                    {*显示百分比 仅饼图有*}
                                    <div class="style-set-label">{'Displaypercentage'|@getFixedLabel}</div>
                                    <div class="style-set-checkbox" >
                                        <input type="checkbox" id="showPercent" name="showPercent" {if $chartSet['show_percent']=='yes'}checked{/if}>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </td>
    </tr>
    </tbody>
</table>
