<div tag="sqltableset" style="display: flex;justify-content: space-between">
    <div id="width_left" style="vertical-align:top;width:20%;min-width: 300px;">
        {*字段选择*}
        <div id="sqlfieldListDiv" style="background: #F8F8F8;height:50%;overflow-y: auto;">
            <div class="selectPop">
                <div style="width:100%;">
                    <ul class="filetree padR10" id="sqlfieldList">
                        <li style="padding-top:20px;">
                            <span class="file" status="open" onclick="CustomTablesCreateObj.expandFields(this)" style="position: sticky;top:0;background-color: #F8F8F8;display:block">
                                <label>SQL
                                </label>
                                <div style="display:none;" id="sqlstr">{$report_info['sqlstr']}</div>
                                {*<input type="hidden" name="sqlstr" id="sqlstr" value="{$report_info['sqlstr']}">*}
                                <a>
                                    <i class="ld-fonticon ld-fonticon-edit"  tag="editsql"></i>
                                </a>
                            </span>

                            <ul tag="fieldlists">
                                {foreach item=columnstd key=j from=$report_info['columnsArr']}
                                    <li style="display: flex;justify-content: space-between;border-bottom: #fff;">
                                    <span class="user" tag="fieldline{$columnstd.id}">
                                         <label>
                                            <input class="second_switch" {if $columnstd.visibile=='yes'}checked{/if} type="checkbox" columnid="{$columnstd.id}" name="fieldlists[]" tag="fieldlists_check">{$columnstd.columns}
                                             <span>[{$columnstd.tdheader_label}]</span>
                                        </label>
                                    </span>
                                        <span>
                                        <a>
                                            <i class="ld-fonticon ld-fonticon-edit" tag="editSqlColumns" columnid="{$columnstd.id}"></i>
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
                        <ul class="filetree padR10" id="sqlfieldList">
                            <li style="padding-top:20px;">
                                <span class="file" status="open" onclick="CustomTablesCreateObj.expandFields(this)" style="position: sticky;top:0;background-color: #F8F8F8;display:block">
                                    <label>{'VAR'|@getFixedLabel}{'list'|@getFixedLabel}
                                    </label>
                                    <a tag="newvariable" filterid="0">{'NEWSIGNAL'|@getFixedLabel}{'VAR'|@getFixedLabel}</a>
                                </span>
                                <ul tag="filterListHeader">
                                    {foreach item=filterline key=j from=$report_info['sqlFilterArr']}
                                        <li tag="filterlineTr" filterid="{$filterline.id}" rowindex="{$j+1}" style="display: flex;justify-content: space-between;border-bottom: #fff;">
                                        <span class="user" >
                                            <label>
                                                {$filterline.var_name}
                                                 <span>[{$filterline.display_name}]</span>
                                            </label>

                                        </span>
                                            <span>
                                            <a class="icon-category category-sup marR8" style="cursor: pointer;{if $j<=0}display:none;{/if}" title="{'MOVEUP'|@getFixedLabel}" tag="variableup"></a>
                                            <a class="icon-category category-sdown marR8" style="cursor: pointer;{if $j+1>=$report_info['sqlFilterArrCount']}display:none;{/if}" title="{'MOVEDOWN'|@getFixedLabel}" tag="variabledown"></a>
                                            <a class="icon-homeimg icon-sdel2 marR8" style="cursor: pointer;" title="{'DELETE'|@getFixedLabel}" tag="variabledelete"></a>
                                            <a><i class="ld-fonticon ld-fonticon-edit" filterid="{$filterline.id}" tag="variableedit"></i></a>
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
    <div style="vertical-align: top;width:80%;max-width:calc(100% - 300px);">
        <div class="pad20 ld-flex-between" style="border-bottom: 1px solid #ddd;">
            <div style="width:45%;">
                <label>{'SetLink'|@getFixedLabel}
                    <input class="second_switch" type="checkbox" id="linkmodulecheck" name="linkmodulecheck" {if $report_info['linkmodulecheck']=='yes'}checked{/if}>
                    <input type="hidden" name="report_id" id="report_id" value="{$report_info['report_id']}">
                </label>
            </div>
            <div style="width:45%;">
                <label>{'showAtPcHome'|@getFixedLabel}
                    <input class="second_switch" type="checkbox" id="show_athome" name="show_athome" {if $report_info['show_athome']=='yes'}checked{/if}>
                </label>
            </div>
        </div>

        <!--分页-->
        <div style="display:block;height:42px;margin: 10px 0;">
            <div class="PageDiv0">
                <ul>
                    <li name='totaldescription'>{$RECORDLISTRANGMSG}</li>{*共11条记录*}
                    <li><span id="goleft" class="no-icon-prevpage"></span></li>{*左边箭头*}
                    <li class="Input" id="pageoftotalpages">1/1</li>
                    <li><span id="goright" class="no-icon-nextpage"></span></li>
                    <li>{'GoTo'|@getFixedLabel}<input class="txtBox btn-radius-system pagenum_system search_bg marLR5" value="1" id="changePageCount" name='pagenum' type="text"/>{'PAGE'|@getFixedLabel}</li>
                    <li >
                        <select class="detailedViewTextBox" name="limitrecord" id="limitrecord">
                            <option value="20" {if $LimitRecord eq '20'} selected=""{/if}>20 {'ItemPage'|@getFixedLabel}</option>
                            <option value="50" {if $LimitRecord eq '50'} selected=""{/if}>50 {'ItemPage'|@getFixedLabel}</option>
                            <option value="100" {if $LimitRecord eq '100'} selected=""{/if}>100 {'ItemPage'|@getFixedLabel}</option>
                            <option value="200" {if $LimitRecord eq '200'} selected=""{/if}>200 {'ItemPage'|@getFixedLabel}</option>
                            <option value="500" {if $LimitRecord eq '500'} selected=""{/if}>500 {'ItemPage'|@getFixedLabel}</option>
                            <option value="1000" {if $LimitRecord eq '1000'} selected=""{/if}>1000 {'ItemPage'|@getFixedLabel}</option>
                            <option value="2000" {if $LimitRecord eq '2000'} selected=""{/if}>2000 {'ItemPage'|@getFixedLabel}</option>
                        </select>
                    </li>
                </ul>
            </div>
        </div>
        <div class="report-detail" style="overflow-y: hidden;">
            {include file="CustomTables/detailtable.tpl"}
        </div>
    </div>
</div>
