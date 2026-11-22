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
                                        <div class="style-set-label">{'Xaxisname'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="text" name="xaxis_bottom_name" id="xaxis_bottom_name" placeholder="{'Xaxisname'|@getFixedLabel}" value="{$chart_info['xaxis1']->bottom->name}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'UpperXaxisname'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="text" name="xaxis_top_name" id="xaxis_top_name" placeholder="{'UpperXaxisname'|@getFixedLabel}" value="{$chart_info['xaxis1']->top->name}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Yaxisname'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="text" name="yaxis_left_name" id="yaxis_left_name" placeholder="{'Yaxisname'|@getFixedLabel}" class="detailedViewTextBox input-width-70" autocomplete="off" value="{$chart_info['yaxis1']->left->name}">
                                        </div>
                                    </div>
                                    <div class="style-set-line" {if $chart_info['yaxis1']->right}{else}style="display:none"{/if}>
                                        <div class="style-set-label">{'RightYaxisname'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="text" name="yaxis_right_name" id="yaxis_right_name" value="{$chart_info['yaxis1']->right->name}" placeholder="{'RightYaxisname'|@getFixedLabel}"  class="detailedViewTextBox input-width-70" autocomplete="off">
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label"><b tag="attention" attentionkey="SqlAttention" class="icon-homeimg icon-askgrey-help sort-tip-items" data-tip="勾选第二统计维度无法限制条数" data-direction="right" data-type="position"></b>{'Displaythenumberofcategories'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="number" name="limit" id="limit" class="detailedViewTextBox input-width-70" autocomplete="off" value="{$chart_info['limit']}">
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Xaxisscaletiltangle'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <input type="number" name="xaxis_name_rotate" id="xaxis_name_rotate" placeholder="{'Xaxisscaletiltangle'|@getFixedLabel}" value="{$chart_info['xaxis1']->bottom->axisLabel->rotate}" class="detailedViewTextBox input-width-70" autocomplete="off">
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Legendorientation'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <select name="legend_orient" id="legend_orient" class="detailedViewTextBox input-width-70">
                                                {foreach item=legendOri key=legendOriKey from=$legendOrient}
                                                    <option {if $chart_info['legend1']->orient==$legendOriKey} selected  {/if }  value="{$legendOriKey}">{$legendOri}</option>
                                                {/foreach}
                                            </select>
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Legendposition'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <select name="legend_position" id="legend_position" class="detailedViewTextBox input-width-70">
                                                {foreach item=legendPos key=legendPosKey from=$legendPosition}
                                                    <option {if $chart_info['legend1']->legend_position==$legendPosKey} selected  {/if }  value="{$legendPosKey}">{$legendPos}</option>
                                                {/foreach}
                                            </select>
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'LegendType'|@getFixedLabel}</div>
                                        <div class="style-set-input">
                                            <select name="legend_type" id="legend_type" class="detailedViewTextBox input-width-70">
                                                {foreach item=legendTyp key=legendTypKey from=$legendType}
                                                    <option {if $chart_info['legend1']->type==$legendTypKey} selected {/if } value="{$legendTypKey}">{$legendTyp}</option>
                                                {/foreach}
                                            </select>
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Permissiblepenetration'|@getFixedLabel}</div>
                                        <div class="style-set-checkbox">
                                            <input type="checkbox" id="can_penetrate" name="can_penetrate" {if $chart_info['can_penetrate']=='yes'}checked{/if}>
                                        </div>
                                    </div>
                                    <div class="style-set-line">
                                        <div class="style-set-label">{'Displaypercentage'|@getFixedLabel}</div>
                                        <div class="style-set-checkbox" >
                                            <input type="checkbox" id="showPercent" name="showPercent" {if $chart_info['show_percent']=='yes'}checked{/if}>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        {*排序设置 *}
                        {include file="CustomEcharts/setReportSortingMethod.tpl"}
                        {*查询条件设置 所有的都一样*}
                        <tr>
                            <td colspan="4" class="editrelhead">
                                <b>{'ConditionSetting'|@getFixedLabel}</b>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                <div style="background-color: #transparent;">
                                    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="conditionColumnList">
                                        <thead>
                                        <tr tag="">
                                            <td align="right" colspan="5" style="border-bottom: none;">
                                                <a title="{'NEWCOMBINATION'|@getFixedLabel}" class="pg-btn-blue dinline-block rfloat" id="addNewConditionGroup" data-groupid="1">
                                                    <span>{'NEWCOMBINATION'|@getFixedLabel}</span>
                                                </a>
                                                <a style="margin-right:10px;" title="{'CLEAR'|@getFixedLabel}" class="pg-btn-blue dinline-block rfloat" onclick="conditionColumnListTableObj.removeAllRow();">
                                                    <span>{'CLEAR'|@getFixedLabel}</span>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="8%" align="right" class="DetailedTd1Label"></td>
                                            <td width="23%" align="center" class="DetailedTd1Label">{'Select_field'|@getFixedLabel}</td>
                                            <td width="23%" align="center">{'SELECTIONCRITERIA'|@getFixedLabel}</td>
                                            <td width="27%" align="center">{'key_word'|@getFixedLabel}</td>
                                            <td width="5.4%" align="center">{'SELECT'|@getFixedLabel}{'relationship'|@getFixedLabel}</td>
                                            <td width="12.6%" align="left">{'OPERATING'|@getFixedLabel}</td>
                                        </tr>
                                        </thead>
                                        <tbody id="highSearch">
                                        </tbody>
                                    </table>
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
