<input type="hidden" name="boardid" id="boardid" value="{$boardid}">
<input type="hidden" name="homeboardname_label" value="{'TEMLATENAME'|@getFixedLabel}" />
<input type="hidden" name="step" id="step" value="1">
<div style="height: calc(100% - 64px);overflow: hidden auto;width: 100%;">
    <div id="step1" {if $boardid>0 }style="display: none"{/if}>
        <link type="text/css" href="themes/softed/CustomEchartsStyle.css" rel="stylesheet">
        <link type="text/css" href="themes/softed/CustomTable.css" rel="stylesheet">
        <div name="dvtable">
            <table class="settingPopTable lasttdbordernon nowhitespace" style="width:100%;margin: auto;">
                <tbody>
                <tr>
                    <th class="newtablethtitle" colspan="4">{'BASICINFO'|@getFixedLabel}</th>
                </tr>
                <tr>
                    <td class="newtablethtitle" width="12%" align="left"><font color="red">*</font>{'TEMLATENAME'|@getFixedLabel}</td>
                    <td ><input id="homeboardname" name="homeboardname" type="text" value="{$HOMEBOARD_CONTENT['boardname']}" class="ld-input-inner gwidth40"/></td>
                </tr>
                <tr>
                    <td class="newtablethtitle" width="12%" align="left">{'DESCRIPTION'|@getFixedLabel}</td>
                    <td width="88%" align="left">
                        <textarea class="ld-textarea-inner gwidth40"  id="Homeboard_description" name="Homeboard_description">{$HOMEBOARD_CONTENT['description']}</textarea>
                    </td>
                </tr>
                <tr {if $MODULE neq 'VisualAnalysis'} style="display: none" {/if}>
                    <td class="newtablethtitle" width="12%" align="left">{'SELECTCOVER'|@getFixedLabel}</td>
                    <td width="88%" align="left">

                        <img id="{$MODULE}_icon_image" src=" {$HOMEBOARD_CONTENT['icon_path']}" alt="" style="width:auto;height:80px;margin:8px 8px 8px 0;
                        {if ! $HOMEBOARD_CONTENT['icon_path'] }
                                display: none;
                        {/if} " >
                        <div id="editarea_{$MODULE}_action" style="display: inline-flex;">
                            <input name="active_icon_size" value="1024" type="hidden">
                            <input name="active_icon_name" value="" type="hidden">
                            <input name="active_icon" accept="image/*" value="" onchange="validateFilename(this);" type="file" style="display: initial;width: 160px;">
                            <input name="active_icon_name_hidden" value="" type="hidden">
                            <span style="color: red;font-size: 12px;display: inline-flex; align-items: center;">{$ICONMSG}</span>
                        </div>
                    </td>
                </tr>
{*                {if $from_module neq 'MobileReport'}*}
                <tr {if $boardtype == 'prmHome'}style="display: none;" {/if}>
                    <th class="newtablethtitle" colspan="4">{'APPLICABLESCOPE'|@getFixedLabel}</th>
                </tr>
                <tr {if $boardtype == 'prmHome'}style="display: none;" {/if}>
                    <td class="newtablethtitle" style="border: none;" align="left">{'APPLICABLESCOPE'|@getFixedLabel}</td>
                    <td style="border: none;" colspan="3" id="allocate_divcontent" class="select-input" width="80%" align="left">
                        <label class="padR10"><input type="radio" name="radiotype" style="margin-right: 5px;margin-top: -2px;" value="0" {if {$HOMEBOARD_CONTENT['scope']}=='all'}checked{/if} {if $boardid>0}{else}checked{/if}>{'ALLTHEUSERS'|@getFixedLabel}  </label>
                        <label class="padR10"><input type="radio" name="radiotype" style="margin-right: 5px;margin-top: -2px;" value="1" {if {$HOMEBOARD_CONTENT['scope']}=='group'}checked{/if}>{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                        <label class="padR10"><input type="radio" name="radiotype" style="margin-right: 5px;margin-top: -2px;" value="2" {if {$HOMEBOARD_CONTENT['scope']}=='user'}checked{/if}>{'SETBYUSERS'|@getFixedLabel}</label>
                        <label class="padR10"><input type="radio" name="radiotype" style="margin-right: 5px;margin-top: -2px;" value="3" {if {$HOMEBOARD_CONTENT['scope']}=='role'}checked{/if}>{'SetByRole'|@getFixedLabel}</label>
                        <input type="hidden" id="selectallocateid" name="selectallocateid" value="{$HOMEBOARD_CONTENT['scope_list_str']}">
                        <input type="hidden" id="selectallocatetype" name="selectallocatetype" value="{if $boardid>0}{$HOMEBOARD_CONTENT['scope']}{else}all{/if}">
                    </td>
                </tr>
{*                {/if}*}
                </tbody>
            </table>
            {if $from_module neq 'MobileReport' && $from_module neq 'prmMobileHome'}
            <table class="settingPopTable lasttdbordernon nowhitespace" style="width:100%;margin: auto;">
                <tbody>
                <tr>
                    <th class="newtablethtitle" colspan="4">{'homeboard_Page_layout'|@getFixedLabel}</th>
                </tr>
                <tr >
                    <td style="border: none;padding: 10px 0;">
                        <input type="hidden" id="homeboardchoselayout" name="homeboardchoselayout" value="{if $boardid>0}{$HOMEBOARD_CONTENT['boardlayout']}{else}tl1r1{/if}">
                        <div id="homeboardlayout_tl1r1" name="homeboardlayout" data-layout="tl1r1" class="ld_homeboard_layout {if $boardid>0}{else}ld_homeboard_layout_chose{/if} {if $HOMEBOARD_CONTENT['boardlayout']=='tl1r1'}ld_homeboard_layout_chose{/if}">
                            <div style="margin: 15px;height: 80px;">
                                <div style="width: 80px;height:80px;float: left;">
                                    <img style="width: 80px;height:80px;" src="{$IMAGEURL}themes/icon/homeboard_layout1-1.png?v={$GLOBALMINVERSION}"/>
                                </div>
                                <div style="width: 250px;margin-left: 20px;margin-top: 10px;float: left;">
                                    <div style="margin-bottom: 8px;font-weight: 600;color: #181c25;">{'upper_left_right_Layout'|@getFixedLabel}</div>
                                    <div style="font-size: 12px;color: #545861;line-height: 16px;">{'upper_left_right_Layout_width_ratio'|@getFixedLabel} 1：1</div>
                                </div>
                            </div>
                        </div>
                        <div id="homeboardlayout_tl2r1" name="homeboardlayout" data-layout="tl2r1" class="ld_homeboard_layout {if $HOMEBOARD_CONTENT['boardlayout']=='tl2r1'}ld_homeboard_layout_chose{/if}">
                            <div style="margin: 15px;height: 80px;">
                                <div style="width: 80px;height:80px;float: left;">
                                    <img style="width: 80px;height:80px;" src="{$IMAGEURL}themes/icon/homeboard_layout2-1.png?v={$GLOBALMINVERSION}"/>
                                </div>
                                <div style="width: 250px;margin-left: 20px;margin-top: 10px;float: left;">
                                    <div style="margin-bottom: 8px;font-weight: 600;color: #181c25;">{'upper_left_right_Layout'|@getFixedLabel}</div>
                                    <div style="font-size: 12px;color: #545861;line-height: 16px;">{'upper_left_right_Layout_width_ratio'|@getFixedLabel} 2：1</div>
                                </div>
                            </div>
                        </div>
                        <div id="homeboardlayout_tl1r2" name="homeboardlayout" data-layout="tl1r2" class="ld_homeboard_layout {if $HOMEBOARD_CONTENT['boardlayout']=='tl1r2'}ld_homeboard_layout_chose{/if}">
                            <div style="margin: 15px;height: 80px;">
                                <div style="width: 80px;height:80px;float: left;">
                                    <img style="width: 80px;height:80px;" src="{$IMAGEURL}themes/icon/homeboard_layout1-2.png?v={$GLOBALMINVERSION}"/>
                                </div>
                                <div style="width: 250px;margin-left: 20px;margin-top: 10px;float: left;">
                                    <div style="margin-bottom: 8px;font-weight: 600;color: #181c25;">{'upper_left_right_Layout'|@getFixedLabel}</div>
                                    <div style="font-size: 12px;color: #545861;line-height: 16px;">{'upper_left_right_Layout_width_ratio'|@getFixedLabel} 1：2</div>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
            {/if}
        </div>
    </div>
    <div id="step2"  style="height: 100%;{if $boardid > 0 }{else}display: none;{/if}">
        <div id="homeboard_drawingboard" name="" class="ld_homeboard_drawingboard">
            <div id="optional-list" name="optional-list" class="ld_homeboard_drawingboard_optionlist">
                <div class="ld_search_option">
                    <div class="ld_search-components">
                        <input type="text" class="ld-input-inner ld-input-inner-add" id="search_stufflist" placeholder="{'INPUTSEARCHSTUFFNAME'|@getFixedLabel}" value="">
                        <b id="searchBtn" class="ld-icon-search"></b>
                    </div>
                </div>
                <div class="ld_homeboard_stuff" id="homeboard_stuff_list">
                    <div style="display: flex;margin: 10px 0;">
                        <span style="font-size: 13px;color: #8998AC;margin-left: 16px;">{'OperationTip'|@getFixedLabel}</span>
                        <b class="icon-homeimg icon-askgrey-help tip-items-list " style="margin: 0 10px;"
                           data-tip="{$OperationTip}"
                           data-type="position" data-direction="right"></b>
                    </div>
                    <div style="height: calc(100% - 40px);width: 100%;overflow-y: auto;overflow-x: hidden">
                        {assign  var="i" value=0}
                        {foreach key=stufftype item=stufflistinfo from=$stufflist}
                            {assign  var="i" value= $i + 1}
                            <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;" name="stufflist_title_{$stufflistinfo['style']}">
                                <span>{$i}. {$stufflistinfo['stufflist_label']}</span>
                                <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                            </div>
                            <div class="ld_homeboard_stuff_list" name="content_stufflist_title_{$stufflistinfo['style']}">
                                <ul name="homeboard_stuff_list_ul" {if $stufflistinfo['stufflist']|@count > 0}{else}style="display: none;"{/if}>
                                    {*xm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type*}
                                    {foreach key=stuffid item=stuffinfo from=$stufflistinfo['stufflist']}
                                        {assign  var="stufflabel" value= $stuffinfo['stufftitle']|@getFixedLabel}
                                        <li class="{if  $stuffinfo['chose']=='yes'}ld_listchosestuff{else}drag-handle{/if}"
                                            id="li_stuff_{$stuffinfo['stuffid']}" data-stuffid="{$stuffinfo['stuffid']}" data-stuffstyle="{$stuffinfo['stufftype']}" data-chart_type="{$stuffinfo['chart_type']}"
                                            data-stufftitle="{$stuffinfo['stufftitle']}" data-stufftitle_label="{$stuffinfo['stufftitle_label']}" data-stuffliststyle="{$stufflistinfo['style']}" >
                                            <span class="tip-items-list" data-tip="{$stufflabel}" data-direction="top" data-type="position">{$stufflabel}</span>
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
                    {if $from_module neq 'MobileReport' && $from_module neq 'prmMobileHome'}
                    <div class="home_header_top" style="margin: 8px;border-radius: 4px;display: flex;align-items: center;">
                        <div style="display: flex;align-items: center;">
                            <div class="" id="showselectsearchscope" style="margin-top: 0px;padding: 0;max-width: 280px;margin-right: 10px;">
                                <div class="ld_Select-component " tabindex="99">
                                    <div class="ld_Select-lefticon" style="background-image: url(&quot;themes/icon2024/searchscope.png&quot;);"></div>
                                    <div class="ld_Select-content ">
                                        <span title="全部成员" style="max-width: 130px;">全部成员</span>
                                        <b class="ld_Select_arrowicon"></b>
                                    </div>
                                </div>
                            </div>
                            <a class="icon-range" style="margin-top: 2px;" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon"></a>
                        </div>
                        <div class="home_laydate_div" style="margin-top: 0;">
                            {*txy BUG0069079 kfbcrm英文版-编辑数据看板-组件错位*}
                            <input type="text" disabled class="laydate_time" {if $LANGUAGETYPE =='en'}style="width:120px;"{/if} value="{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault_label']}{else}{'thismonth'|@getFixedLabel}{/if}">
                            <input type="hidden" id="homeboard_laydata_value" value="{if $boardid>0}{if $HOMEBOARD_CONTENT['customDateValue'] neq ''}{$HOMEBOARD_CONTENT['customDateValue']}{else}{$HOMEBOARD_CONTENT['timesearchdefault']}{/if}{else}thismonth{/if}">
                            <div class="home_laydate_jiantou laydate_jiantou"></div>
                        </div>
                        {*<div style="display: inline-block;float: left;padding-top: 13px;" title="{'SETTINGS'|@getFixedLabel}"><a href="javascript:void(0);"><b class="icon-categorybtn categorymanager-set" style="margin-right: 0;"></b></a></div>*}
                        {*<div class="home-header-top-date">{'approvestatus'|@getFixedLabel}：</div>
                        <div class="home-header-approve-select approve-select select-input">
                            <input type="checkbox" name="homeboard_hear_approve" id="unapproved" value="unapproved" disabled {if $boardid>0}{else}checked{/if} {if 'unapproved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Unapproved'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="approving" value="approving" disabled {if $boardid>0}{else}checked{/if} {if 'approving'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Approvalof'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="approved" value="approved" disabled {if $boardid>0}{else}checked{/if} {if 'approved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'APPROVEDSUCCESS'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="rejected" value="rejected" disabled {if $boardid>0}{else}checked{/if} {if 'rejected'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Rejected'|@getFixedLabel}</label>
                            <input type="checkbox" name="homeboard_hear_approve" id="dismissed" value="dismissed" disabled {if $boardid>0}{else}checked{/if} {if 'dismissed'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0">{'Dismissed'|@getFixedLabel}</label>
                        </div>*}
                        <div class="ld_Select-component " tabindex="99">
                            <div class="ld_Select-lefticon" style="background-image: url(&quot;themes/icon2023/homeapproveselect.png&quot;);"></div>
                            <div class="ld_Select-content ">
                                <span title="审批状态" style="max-width: 90px;">{'approvestatus'|@getFixedLabel}</span>
                                <b class="ld_Select_arrowicon"></b>
                            </div>
                        </div>
                    </div>
                    {else}
                    <div class="home_header_top" style="min-width:380px;width:380px;margin: 8px auto;border-radius: 4px;box-shadow: 0 4px 10px 0 rgb(56 92 141 / 25%);">
                        <div style="display: flex;justify-content: space-between;line-height:55px;margin:0 10px;">
                            <div style="display: flex;justify-content: flex-start">
                                <div>{'VIEWRANGE'|@getFixedLabel}：{'ALL'|@getFixedLabel}</div>
                                <a class="icon-range" style="margin-top:15px;" href="javascript:void(0);"></a>
                            </div>
                            <div style="display:none;">
                                <div class="home_laydate_div">
                                    {*txy BUG0069079 kfbcrm英文版-编辑数据看板-组件错位*}
{*                                    <input type="text" disabled class="laydate_time" {if $LANGUAGETYPE =='en'}style="width:120px;"{/if} value="{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault_label']}{else}{'thismonth'|@getFixedLabel}{/if}">*}
                                    <input type="hidden" id="homeboard_laydata_value" value="{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault']}{else}thismonth{/if}">
                                </div>
                                <div style="display: inline-block;float: left;padding-top: 13px;" title="{'SETTINGS'|@getFixedLabel}"><a href="javascript:void(0);"><b class="icon-categorybtn categorymanager-set" style="margin-right: 0;"></b></a></div>
                                <div class="home-header-top-date">{'approvestatus'|@getFixedLabel}：</div>
                                <div class="home-header-approve-select approve-select select-input">
                                    <input type="checkbox" name="homeboard_hear_approve" id="unapproved" value="unapproved" disabled {if $boardid>0}{else}checked{/if} {if is_array($HOMEBOARD_CONTENT['approve_value_array']) && 'unapproved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Unapproved'|@getFixedLabel}</label>
                                    <input type="checkbox" name="homeboard_hear_approve" id="approving" value="approving" disabled {if $boardid>0}{else}checked{/if} {if is_array($HOMEBOARD_CONTENT['approve_value_array']) && 'approving'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Approvalof'|@getFixedLabel}</label>
                                    <input type="checkbox" name="homeboard_hear_approve" id="approved" value="approved" disabled {if $boardid>0}{else}checked{/if} {if is_array($HOMEBOARD_CONTENT['approve_value_array']) && 'approved'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'APPROVEDSUCCESS'|@getFixedLabel}</label>
                                    <input type="checkbox" name="homeboard_hear_approve" id="rejected" value="rejected" disabled {if $boardid>0}{else}checked{/if} {if is_array($HOMEBOARD_CONTENT['approve_value_array']) && 'rejected'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0 padR5">{'Rejected'|@getFixedLabel}</label>
                                    <input type="checkbox" name="homeboard_hear_approve" id="dismissed" value="dismissed" disabled {if $boardid>0}{else}checked{/if} {if is_array($HOMEBOARD_CONTENT['approve_value_array']) && 'dismissed'|@in_array:$HOMEBOARD_CONTENT['approve_value_array']}checked{/if}><label class="padL0">{'Dismissed'|@getFixedLabel}</label>
                                </div>
                            </div>
                            <div class="home_laydate_jiantou">{if $boardid>0}{$HOMEBOARD_CONTENT['timesearchdefault_label']}{else}{'thismonth'|@getFixedLabel}{/if}&nbsp;></div>
                        </div>
                    </div>
                    {/if}
                    {*拖动区域*}
                    {if $from_module neq 'MobileReport' && $from_module neq 'prmMobileHome'}
                    {if $boardid > 0}
                        {foreach key=index item=plateinfo from=$HOMEBOARD_CONTENT['homeboard_plate']}
                            {if $plateinfo['platetype'] == 'whole'}
                                <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" id="homeboard_draw_layout_block_{$plateinfo['plateid']}" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">
                                        <div class="empty-block-tip" style="position: relative;height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                                    </div>
                                </div>
                            {elseif $plateinfo['platetype'] == 'left'}
                                <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">
                                        <div class="empty-block-tip"  style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                                    </div>
                                    {elseif $plateinfo['platetype'] == 'right'}
                                    <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">
                                        <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                                    </div>
                                </div>
                            {else}
                                <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">
                                    <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                                </div>
                            {/if}
                        {/foreach}
                    {else}
                        <!--移动端工作台看板定制-->
                        <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="whole" data-platetype="whole" style="width: 100%;">
                                <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                            </div>
                        </div>

                        <div class="ld_homeboard_draw_layout" name="homeboard_draw_layout">
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="left" data-platetype="left" style="width: 50%;">
                                <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                            </div>
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="right" data-platetype="right" style="width: 50%;">
                                <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                            </div>
                        </div>
                    {/if}
                    {else}
                    {if $boardid > 0}
                        {foreach key=index item=plateinfo from=$HOMEBOARD_CONTENT['homeboard_plate']}
                            <div class="ld_homeboard_draw_layout_mobile" name="homeboard_draw_layout">
                                <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" id="homeboard_draw_layout_block_{$plateinfo['plateid']}" data-plateid="{$plateinfo['plateid']}" data-platetype="{$plateinfo['platetype']}" style="width: {$plateinfo['platewidth_stylewidth']};">
                                    <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                                </div>
                            </div>
                        {/foreach}
                    {else}
                        <div class="ld_homeboard_draw_layout_mobile" name="homeboard_draw_layout">
                            <div class="ld_homeboard_draw_layout_block" name="homeboard_draw_layout_block" data-plateid="whole" data-platetype="whole" style="width: 100%;">
                                <div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+{'dragstuff'|@getFixedLabel}</div>
                            </div>
                        </div>
                    {/if}
                    {/if}
                </div>

            </div>
            <div id="optional-setting" name="optional-setting" class="ld_homeboard_drawingboard_setting" style="padding: 10px 0px;">
                <div id="optional-setting_title" class="ld_homeboard_drawingboard_setting_title">
                    <span>{'Component_Settings'|@getFixedLabel}</span>
                </div>
                <div id="optional-setting_content" style="width: 100%;overflow: hidden;background: #fff;">

                </div>
            </div>
        </div>
    </div>
</div>
