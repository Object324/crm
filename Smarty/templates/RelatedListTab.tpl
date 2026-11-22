<div class="detail-relation-box">
    <ul id="nav-relation-btn" class="detail-relation-btn">
        <li>
            <a class="current" href="javascript:;" type="DetailViewTab" relateTag="detailview" title="{'details1'|@getFixedLabel}" relatedid=0>
                <span>{'details1'|@getFixedLabel}</span>
            </a>
        </li>
		{if $IS_REL_LIST|@count > 0}
			{foreach key=rel_type item=rel_info from=$IS_REL_LIST}
                {if $rel_type eq 'list'}
				{foreach item=rel_list_info from=$rel_info}
					<li class="li-relation">
                        <a href="javascript:;" type="DetailViewTab" relateTag="{$rel_list_info.related_module}" relatedid="{$rel_list_info.related_id}">
                            <span>{$rel_list_info.related_modulelabel}</span>
                            <b class="relation-normal-b" tag="{$rel_list_info.related_module}_count" relateidtag="{$rel_list_info.related_id}" style="display:none"></b>
                        </a>

{*                        @edit:liushuai,2021-03-12,reason:【ID1001092】模块明细界面，相关信息增加可直接创建窗口*}
                        {*
                        {if $rel_list_info.related_button neq ''}
                            <ul class="detail-relation-second">
                                <li>
                                    {$rel_list_info.related_button}
                                </li>
                            </ul>
                        {/if}
                        *}

                    </li>
				{/foreach}
                {else}
                    {*ls 2021-10-22 【ID1002125】模块明细界面，相关信息显示优化*}
                    <li class="more-relation-btn" name="detail-relation-btnmore-bar">
                        <a href="javascript:;" type="DetailViewTab" text="" relateTag="more" tag='more'>
                            <span style="display: inline-block;max-width: 52px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">{'MORE'|@getFixedLabel}</span>
                            <b style="display:none" tag='detailviewmore_count'>20</b>
                            <i class="relationdown"></i>
                        </a>
                        <ul id="overflow-relation-btn" name="detail-relation-btnmore" class="detail-relation-btn-more" style="z-index: 100001;overflow:unset;">
{*                            // wsh 2024-08-05 XUQIU20240702-03 相关信息下拉框界面增加搜索框*}
                            <div class="" style="position: relative;margin: 6px;">
                                <input class="ld-input-inner-div" style="padding-left: 26px;padding-right: 30px;" type="text"  placeholder="{'SearchForRelevantInformation'|@getFixedLabel}" onkeyup="relevantInfoSearch(this)" />
                                <span class="leftmenu-fonticon" style="line-height: 34px;padding: 0 2px 0 6px;position: absolute;left: 0;opacity: 0.5;color: #3B4859;top: 0;"></span>
                                {if $CURRENT_USER neq '' && $CURRENT_USER->getHaveSetProfile("Settings")=='yes'}
                                <a href="javascript:;" class="leftmenu-fonticon" id="related-setting-btn" title="{'PROJECTSETTINGS'|@getFixedLabel}" style="position: absolute;top: 0;right: 0;padding: 0;line-height: 30px;font-size: 18px;margin: 2px;height: 28px;padding: 0 4px;" onclick="SetRelatedlist(ld(this),'{$MODULE}')"></a>
                                {/if}
                            </div>
                            <div name="search_relations" style="overflow:auto;max-height: 255px;width: 170px;">
                                {foreach item=rel_list_info from=$rel_info}
                                    <li class="li-relation" tag="more_related_liobj" related_name="{$rel_list_info.related_modulelabel}">
                                        <a href="javascript:;" type="DetailView_moremenu" relateTag="{$rel_list_info.related_module}" title="{$rel_list_info.related_modulelabel}" relatedid="{$rel_list_info.related_id}" class="more">
                                            <span name="related_span_name">{$rel_list_info.related_modulelabel}</span>
                                            <b class="relation-more-b" tag="{$rel_list_info.related_module}_count" relateidtag="{$rel_list_info.related_id}" style="display:none"></b>
                                        </a>

                                        {*
                                        {if $rel_list_info.related_button neq ''}
                                            <ul class="detail-relation-moresecond">
                                                <li>
                                                    {$rel_list_info.related_button}
                                                </li>
                                            </ul>
                                        {/if}
                                        *}

                                    </li>
                                {/foreach}
                                <li tag="no-record" style="display:none;padding:12px;margin:auto">
                                    <span>{'noRecord'|@getFixedLabel}</span>
                                </li>
                            </div>
                        </ul>
                    </li>
                        {*BUG0070581 2023-8-8 xxy 相关信息栏单据过多出现更多时----在更多最下方增加相关信息设置选项*}
                        {*BUG0074183 20240307 wym 相关信息栏，去除“相关信息设置”（邱：代码注释别删）*}
                        {*{if ''|@checkCurrentUserIsAdmin eq 'on'}
                            <ul id="overflow-relation-btn" name="detail-relation-btnmore-settings" class="detail-relation-btn-more" style="z-index: 10001;border-radius: 0px 0px 4px 4px;">
                                <li class="li-relation">
                                    <a href="javascript:;" type="DetailView_moremenu" relateTag="custom" title="{'PROJECTSETTINGS'|@getFixedLabel}" relatedid="" class="more" onclick="SetRelatedlist(ld(this),'{$MODULE}')">
                                        <span>{'PROJECTSETTINGS'|@getFixedLabel}</span>
                                        <b class="relation-more-b" tag="custom" relateidtag="custom" style="display:none"></b>
                                    </a>
                                </li>
                            </ul>
                        {/if}*}

                {/if}
			{/foreach}
		{/if}
        {*
            * @edit:diony 
            * @date:2020-08-31 
            * @reason:【单据查看详情界面增加【相关信息设置】按钮】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001001035
            * @description:去掉
        {if ''|@checkCurrentUserIsAdmin eq 'on'}
            <li>
                <a class="more" href="javascript:;" onclick="SetRelatedlist(ld(this),'{$MODULE}')" relateTag="custom" title="{'PROJECTSETTINGS'|@getFixedLabel}">{'PROJECTSETTINGS'|@getFixedLabel}</a>
            </li>
        {/if}
        *}
        {*<li class="more-relation-btn" name="detail-relation-btnmore-bar">
            <a href="javascript:;" type="DetailViewTab" text="{'MORE'|@getFixedLabel}" relateTag="more" tag='more' title="{'MORE'|@getFixedLabel}">
                <span>{'MORE'|@getFixedLabel}</span>
                <b style="display:none" tag='detailviewmore_count'>20</b>
                <i class="relationdown"></i>
            </a>
            <ul id="overflow-relation-btn" name="detail-relation-btnmore" class="detail-relation-btn-more">
            </ul>
        </li>*}
    </ul>
</div>
{*ZXM 20221123 详情页设置按钮 页面设置 单据分录设置 相关信息设置*}
{if $DETAILSETTINGS}
    <div class="detail-relation-box detail-relation-box-right" style="display: none;">
        <ul id="nav-relation-btn" class="detail-relation-btn">
            <li class="li-relation">
                <a href="javascript:;" title="{'SETTINGS'|@getFixedLabel}" >
                    <b class="icon-categorybtn categorymanager-set cursorPointer"></b>
                </a>
                <ul  class="detail-relation-second detail-setting-drop">
                    {foreach key=set_type item=setting_info from=$DETAILSETTINGS}
                        <li class="li-relation" {if $setting_info.click}{$setting_info.click}{/if}>
                            <a {if $setting_info.url} {$setting_info.url} target="_blank"{else} href="javascript:;" {/if} title="{$setting_info.label}">
                                <span>{$setting_info.label}</span>
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </li>
        </ul>
    </div>
{/if}
{*
<script>
    navigationResize();
</script>*}
