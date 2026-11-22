<div tag="sqltableset" style="display: flex;justify-content: space-between">
    <div id="width_left" style="vertical-align:top;width:20%;min-width: 300px;">
        {*字段选择*}
        <div id="sqlfieldListDiv" style="background: #F8F8F8;height:50%;overflow-y: auto;">
            <div class="selectPop">
                <div style="width:100%;">
                    <ul class="filetree" id="sqlfieldList">
                        <li style="padding-top:20px;">
                            <span class="file" status="open" tag="expandFields" style="position: sticky;top:0;background-color: #F8F8F8;display:block">
                                <label>SQL
                                </label>
                                <div style="display:none;" id="sqlstr">{$mainInfo['sqlstr']}</div>
                                <a>
                                    <i class="el-icon-edit-outline"  tag="editsql"></i>
                                </a>
                            </span>

                            <ul tag="fieldlists">
                                {foreach item=columnstd key=j from=$sqlColumnsArr}
                                    <li style="display: flex;justify-content: space-between;border-bottom: #fff;">
                                    <span class="user" tag="fieldline{$columnstd.id}">
                                         <label>
                                             {$columnstd.columns}
                                             <span>[{$columnstd.column_label}]</span>
                                        </label>
                                    </span>
                                        <span>
                                        <a>
                                            <i class="el-icon-edit-outline"  tag="editSqlColumns" columnid="{$columnstd.id}"></i>
                                        </a>
                                    </span>
                                    </li>
                                {/foreach}
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div id="sqlVariableDiv" class="marT20" style="background: #F8F8F8;height:50%;overflow-y: auto;">
            <div class="selectPop">
                <div style="width:100%;">
                    <ul class="filetree" id="sqlfieldList">
                        <li style="padding-top:20px;">
                                <span class="file" status="open" tag="expandFields" style="position: sticky;top:0;background-color: #F8F8F8;display:block">
                                    <label>{'VAR'|@getFixedLabel}{'list'|@getFixedLabel}
                                    </label>
                                    <a tag="newvariable" filterid="0">{'NEWSIGNAL'|@getFixedLabel}{'VAR'|@getFixedLabel}</a>
                                </span>
                            <ul tag="filterListHeader">
                                {foreach item=filterline key=j from=$sqlFilterArr}
                                    <li tag="filterlineTr" filterid="{$filterline.id}" rowindex="{$j+1}" style="display: flex;justify-content: space-between;border-bottom: #fff;">
                                        <span class="user" >
                                            <label>
                                                {$filterline.var_name}
                                                 <span>[{$filterline.display_name}]</span>
                                            </label>

                                        </span>
                                        <span>
                                            <a class="icon-category category-sup marR8" style="cursor: pointer;{if $j<=0}display:none;{/if}" title="{'MOVEUP'|@getFixedLabel}" tag="variableup"></a>
                                            <a class="icon-category category-sdown marR8" style="cursor: pointer;{if $j+1>=$mainInfo['sqlFilterArrCount']}display:none;{/if}" title="{'MOVEDOWN'|@getFixedLabel}" tag="variabledown"></a>
                                            <a class="icon-homeimg icon-sdel2 marR8" style="cursor: pointer;" title="{'DELETE'|@getFixedLabel}" tag="variabledelete"></a>
                                            <a><i class="el-icon-edit-outline" filterid="{$filterline.id}" tag="variableedit"></i></a>
                                        </span>
                                    </li>
                                {/foreach}
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div id="width_right" style="vertical-align: top;width:80%;max-width:calc(100% - 300px);">
        <div class="report-detail padL20" style="overflow-y: hidden;">
            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                <tbody>
                <tr>
                    <td colspan="4">
                        <div name="displayfields">
                            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                                <tbody>
                                {*基本信息设置  都是一样的  包含图表类型 图表名称 图表文件夹 图表描述四项*}
                                <tr>
                                    <td colspan="4" class="editrelhead">
                                        <b>{'BASICINFO'|@getFixedLabel}</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
                                        <font color="red">*</font>{'chartType'|@getFixedLabel}
                                    </td>
                                    <td width="42%" id="chart_type_label">
                                        {$chartSet['chart_type_name']}
                                    </td>
                                    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
                                        <font color="red">*</font>{'SELECT'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}
                                    </td>
                                    <td width="42%">
                                        <select name="analysisfolder_id" id="analysisfolder_id" tag="所属文件夹" class="detailedViewTextBox input-width-70" style="width:90%">
                                            {$folderOptions}
                                        </select>
                                    </td>

                                </tr>
                                <tr>
                                    <td class="DetailedTd1Label" align="right">
                                        <font color="red">*</font>{'chartName'|@getFixedLabel}
                                    </td>
                                    <td>
                                        <input type="hidden" name="report_id" id="report_id" value="{$mainInfo['report_id']}">
                                        <input type="hidden" name="report_type" id="report_type" value="sqlchart">
                                        <input type="hidden" name="chart_type" id="chart_type" value="{$chartSet['chart_type']}">
                                        <input type="text" name="report_name" id="report_name" placeholder="{'chartName'|@getFixedLabel}" value="{$mainInfo['report_name']}" class="detailedViewTextBox  input-width-70" autocomplete="off" required>
                                    </td>
                                    <td class="DetailedTd1Label" align="right">
                                        {'CAMCARDCAPTION'|@getFixedLabel}
                                    </td>
                                    <td>
                                        <textarea class="detailedViewTextBox input-width-70" name="report_desc" style="margin-top: 3px; overflow: hidden; overflow-wrap: break-word; resize: horizontal; height: 52px;" id="report_desc"  aria-label="{'CAMCARDCAPTION'|@getFixedLabel}">{$mainInfo['report_desc']}</textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
                                        选择主题
                                    </td>
                                    <td width="42%">
                                        <select name="themename" id="themename" tag="主题" class="detailedViewTextBox input-width-70">
                                            {foreach item=themeinfo key=themekey from=$themeArr}
                                                <option {if $mainInfo['themename'] == $themekey }selected{/if} value="{$themekey}">{$themeinfo.themeLabel}</option>
                                            {/foreach}
                                        </select>
                                    </td>
                                    <td width="8%"></td>
                                    <td width="42%"></td>
                                </tr>
                                {*图表参数*}
                                {*X轴（类目） 统计维度设置 *}
                                {*统计维度设置*}
                                {include file="CustomEcharts/groupBySetSql.tpl"}
                                {*Y轴（数值）-- 统计字段设置 *}
                                {*统计字段设置*}
                                {include file="CustomEcharts/columnsSetSql.tpl"}
                                {*显示设置 链接模块的设置*}
                                <tr id="show_set_title">
                                    <td colspan="4" class="editrelhead">
                                        <b>{'SHOWINGRECORDS'|@getFixedLabel}{'Setup'|@getFixedLabel}</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right" class="DetailedTd1Label select-input tdwidth150">
                                        <input type="checkbox" class="second_switch" id="linkmodulecheck" name="linkmodulecheck" {if $mainInfo['linkmodulecheck']=="yes"}checked{/if}>
                                    </td>
                                    <td align="left">
                                        <label>{'SETASLINKMODULE'|getFixedLabel}</label>
                                    </td>
                                </tr>
                                {*{显示设置 设为首页组件的设置}*}
                                <tr id="show_athome_title">
                                    <td align="right" class="DetailedTd1Label select-input tdwidth150">
                                        <input type="checkbox" class="second_switch" id="show_athome" name="show_athome" {if $mainInfo['show_athome']=="yes"}checked{/if}>
                                    </td>
                                    <td align="left">
                                        <label>{'showAtPcHome'|getFixedLabel}</label>
                                    </td>
                                </tr>
{* --zxm20230627 去掉该设置 {include file="CustomEcharts/sqlShowSet.tpl"}*}
                                </tbody>
                            </table>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>