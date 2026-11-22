<div class="template-type-content">
    <input type="hidden" name="selecttemplateid" id="selecttemplateid" value="{$report_info['templateid']}">
    <div class="template-type-names">
        <ul id="left_template_nav">
            {foreach item=parenttype key=parentkey from=$templateTypeArr}
                <li class="{if $parentkey=='line'}active{/if}">
                    <a id="left-template-nav-{$parentkey}" href="#template-type-{$parentkey}" class="left-template-nav-link">
                        <div class="template-name">{$parenttype['label']}</div>
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>
    <div class="template-type-icons" id="template_type_lists">
        {foreach item=parenttype key=parentkey from=$templateTypeArr}
            <div>
                <div id="template-type-{$parentkey}" class="template-type-head">
                    {$parenttype['label']}
                </div>
                <div class="template-type-list">
                    {foreach item=item key=key from=$parenttype['list']}
                            <div class="template-type-one" data-name="{$item['name']}" data-label="{$item['label']}">
                                <div style="{if $key!=-1}display:none;{/if}" class="icon-choosed"></div>
                                <div class="template-img {if $key==-1}selected{else}unselected{/if}">
                                    {if $key==-1}
                                    {*空白模板*}
                                    <div><img src="{$IMAGEURL}themes/chartimg/emptytable.png?v={$GLOBALMINVERSION}"></div>
                                    {else}
                                    {foreach item=module key=mk from=$item['modules']}
                                    <div class="template-line" {if $mk==0}style="display:none;"{/if}></div>
                                    <div class="template-module" title="{$module}">{$module}</div>
                                    {/foreach}
                                    {/if}
                                </div>
                                <div class="template-name">{$item['label']}</div>
                            </div>

                    {/foreach}
                </div>
            </div>
        {/foreach}
    </div>
</div>