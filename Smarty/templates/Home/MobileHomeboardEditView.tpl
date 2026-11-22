<input type="hidden" name="boardid" id="boardid" value="{$boardid}">
<input type="hidden" name="homeboardname_label" value="{'TEMLATENAME'|@getFixedLabel}" />
<input type="hidden" name="step" id="step" value="1">
<div style="height: calc(100% - 64px);overflow: hidden auto;width: 100%;">
    <div id="step2" style="height: 100%;">
        <div id="homeboard_drawingboard" name="" class="ld_homeboard_drawingboard">
            <div id="optional-list" name="optional-list" class="ld_homeboard_drawingboard_optionlist">
                <div class="mobilehomeblock-tab" name="mobilehomeblock_tab">
                    <div class="tab">
                        <span style="width:50%;" class="tab-item tab-item-salesgoal cur " for="bascInfo">基本信息</span>
                        <span style="width:50%;" class="tab-item tab-item-salesgoal" for="stuffList">组件列表</span>
                    </div>
                </div>

                <div id="bascInfo" style="background-color: #fff;">
                    <table class="settingPopTable lasttdbordernon nowhitespace" style="width:100%;margin: auto;">
                        <tbody>
                        <tr>
                            <td align="left"><font color="red">*</font>{'TEMLATENAME'|@getFixedLabel}</td>
                        </tr>
                        <tr>
                            <td align="left"><input style="width:100%;" id="homeboardname" name="homeboardname" type="text" value="{$HOMEBOARD_CONTENT['boardname']}" class="btn-radius-system"/></td>
                        </tr>
                        <tr>
                            <td align="left">{'DESCRIPTION'|@getFixedLabel}</td>
                        </tr>
                        <tr>
                            <td align="left">
                                <textarea class="commonSelect" style="height: 75px;" id="Homeboard_description" name="Homeboard_description">{$HOMEBOARD_CONTENT['description']}</textarea>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div id="stuffList" style="display:none;">
                    <div class="ld_search_option" style="margin-top:8px;">
                        <div class="ld_search-components">
                            <input type="text" class="ld-input-inner ld-input-inner-add" id="search_stufflist" placeholder="{'INPUTSEARCHSTUFFNAME'|@getFixedLabel}" value="">
                            <b id="searchBtn" class="ld-icon-search"></b>
                        </div>
                    </div>
                    <div class="ld_homeboard_stuff" id="homeboard_stuff_list">
                    {foreach key=stufftype item=stufflistinfo from=$stufflist}
                        <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;" name="stufflist_title_{$stufflistinfo['style']}">
                            <span>{$stufflistinfo['stufflist_label']}</span>
                            <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                        </div>
                        <div class="ld_homeboard_stuff_list" name="content_stufflist_title_{$stufflistinfo['style']}">
                            <ul name="homeboard_stuff_list_ul" {if $stufflistinfo['stufflist']|@count > 0}{else}style="display: none;"{/if}>
                                {*xm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type*}
                                {foreach key=stuffid item=stuffinfo from=$stufflistinfo['stufflist']}
                                    <li class="{if $stuffinfo['chose']=='yes'}ld_listchosestuff{else}drag-handle{/if}" id="li_stuff_{$stuffinfo['stuffid']}" data-stuffid="{$stuffinfo['stuffid']}" data-stuffstyle="{$stuffinfo['stufftype']}" data-chart_type="{$stuffinfo['chart_type']}" data-stufftitle="{$stuffinfo['stufftitle']}" data-stufftitle_label="{$stuffinfo['stufftitle_label']}" data-stuffliststyle="{$stufflistinfo['style']}" title="{$stuffinfo['stufftitle']|@getFixedLabel}">
                                        <span>{$stuffinfo['stufftitle']|@getFixedLabel}</span>
                                        <span class="tag" {if $stuffinfo['chose']=='yes'}style="display: block;"{/if}><i class="check"></i></span>
                                    </li>
                                {/foreach}
                            </ul>
                            <div id="homeboard_list_notcontent" style="height: 40px;line-height: 40px;text-align: center;{if $stufflistinfo['stufflist']|@count > 0}display: none;{/if}">{'nodata'|@getFixedLabel}</div>
                        </div>
                    {/foreach}
                </div>
                </div>
            </div>
            <div class="ld_homeboard_drawingboard_content" style="overflow: auto;">
                <div id="homeboard_draw" name="homeboard_draw" class="ld_homeboard_drawingboard_draw">
                    {*筛选器*}
                    <div class="home_header_top" style="margin: 8px;border-radius: 4px;">
                        <div>
                            <div class="Showselect LdShowselect" id="showselectsearchscope" style="margin-top: 5px;max-width: 280px;margin-right: 10px;">
                                <label style="font-size: 14px;padding-top: 1px;">{'VIEWRANGE'|@getFixedLabel}:</label>
                                <div name="dv_chzn_HomeSmOwnerSearchScope" class="chzn-container chzn-container-single">
                                    <a style="width:130px;cursor: default;" class="chzn-single" name="cmb_a_HomeSmOwnerSearchScope">
                                        <div class="commonDetailedTextBox outline bgwhite" id="SmOwnerSearchScopeSenior" style="width:120px;border-style:none;margin-left: -4px;border-style: none;overflow: hidden;position: relative;white-space: nowrap;text-overflow: ellipsis;padding-right: 17px;color: #999;" picklisttype="smownerpicklist" name="cmb_span_optiontext_HomeSmOwnerSearchScope" title="{'ALL'|@getFixedLabel}" contenteditable="true">
                                            {'ALL'|@getFixedLabel}
                                        </div>
                                        <div>
                                            <b></b>
                                        </div>
                                    </a>
                                </div>
                                <a class="icon-range" style="margin-top: 2px;cursor: default;" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon"></a>
                            </div>
                        </div>
                        <div class="home_laydate_div">
                            {*txy BUG0069079 kfbcrm英文版-编辑数据看板-组件错位*}
                            <input type="text" disabled class="laydate_time" {if $LANGUAGETYPE =='en'}style="width:120px;"{/if} value="{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault_label']}{else}{'thismonth'|@getFixedLabel}{/if}">
                            <input type="hidden" id="homeboard_laydata_value" value="{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault']}{else}thismonth{/if}">
                            <div class="home_laydate_jiantou laydate_jiantou"></div>
                        </div>
                        <div style="display: inline-block;float: left;padding-top: 13px;" title="{'SETTINGS'|@getFixedLabel}"><a href="javascript:void(0);"><b class="icon-categorybtn categorymanager-set" style="margin-right: 0;"></b></a></div>
                        <div class="home-header-top-date">{'approvestatus'|@getFixedLabel}：</div>
                        <div class="home-header-approve-select approve-select select-input">
                            <input type="checkbox" name="homeboard_hear_approve" id="unapproved" value="unapproved" disabled {if $boardid>0}{else}checked{/if} {if 'unapproved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Unapproved'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="approving" value="approving" disabled {if $boardid>0}{else}checked{/if} {if 'approving'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Approvalof'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="approved" value="approved" disabled {if $boardid>0}{else}checked{/if} {if 'approved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'APPROVEDSUCCESS'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="rejected" value="rejected" disabled {if $boardid>0}{else}checked{/if} {if 'rejected'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Rejected'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="dismissed" value="dismissed" disabled {if $boardid>0}{else}checked{/if} {if 'dismissed'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0">{'Dismissed'|@getFixedLabel}</label>
                        </div>
                    </div>
                    {*拖动区域*}
                    {if $boardid > 0}
                        {foreach key=index item=plateinfo from=$HOMEBOARD_CONTENT['homeboard_plate']}
                            {if $plateinfo['platetype'] == 'whole'}
                                <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" id="homeboard_draw_layout_block_{$plateinfo['plateid']}" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">

                                    </div>
                                </div>
                            {elseif $plateinfo['platetype'] == 'left'}
                                <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">

                                    </div>
                                    {elseif $plateinfo['platetype'] == 'right'}
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">

                                    </div>
                                </div>
                            {else}
                                <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">

                                </div>
                            {/if}
                        {/foreach}
                    {else}
                        <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="whole" data-platetype="whole" style="width: 100%;">

                            </div>
                        </div>
                        <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="left" data-platetype="left" style="width: 50%;">

                            </div>
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="right" data-platetype="right" style="width: 50%;">

                            </div>
                        </div>
                    {/if}
                </div>
            </div>
            <div id="optional-setting" name="optional-setting" class="ld_homeboard_drawingboard_setting">
                <div id="optional-setting_title" class="ld_homeboard_drawingboard_setting_title">
                    <span>{'Component_Settings'|@getFixedLabel}</span>
                </div>
                <div id="optional-setting_content" style="width: 100%;overflow: hidden;background: #fff;">

                </div>
            </div>
        </div>
    </div>
</div>
