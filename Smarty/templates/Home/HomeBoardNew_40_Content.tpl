{assign var="SelStatu" value=false}
{foreach item=PageTabInfo key=keyid from=$PageTabList}
    {if $PageTabInfo['name'] eq 'outboundorderamount' and 'OutboundOrder'|@vtlib_isModuleActive eq false}

    {else}
        <span style="width:{$TabWidth};" class="tab-item tab-item-salesgoal tip-items-list
                {if $keyid eq $PageTabListSelKey} cur {assign var="SelStatu" value=true}{/if}"
              data-type="{$PageTabInfo['name']}" data-stuffid="{$stuffinfo['stuffid']}"
              data-tabid="{$PageTabInfo['id']}" onclick="tabChange({$stuffinfo['stuffid']},this)"
              data-tip="{$PageTabInfo['label']}" data-direction="top" data-type="position">
            {$PageTabInfo['label']}
        </span>
    {/if}
{/foreach}
{if $PageTabNum gt $TabNum }
    {if $SelStatu eq true}
        <span style="width:{$MoreTabWidth};" class="tab_more tab-item " data-stuffid="{$stuffinfo['stuffid']}">
            <span class="tab_more_text"></span>
    {else}
        <span style="width:{$MoreTabWidth};" class="tab_more tab-item cur"
              data-type="{$PageTabSelInfo['name']}" data-stuffid="{$stuffinfo['stuffid']}"
              data-tabid="{$PageTabSelInfo['id']}">
            <span class="tab_more_text">
                {$PageTabSelInfo['label']}
            </span>
    {/if}
            <i class="labelmore" >
            </i>
            <div class="tab_more_div">
                <div class="tab_more_scroll">
                {foreach item=PageTabInfo key=keyid from=$PageTabListMore}
                    <span class="tab_more_item tip-items-list" tag="more" data-stuffid="{$stuffinfo['stuffid']}"
                          data-type="{$PageTabInfo['name']}" data-tabid="{$PageTabInfo['id']}"
                          onclick="tabMoreChange(this);tabChange({$stuffinfo['stuffid']},this);"
                          data-tip="{$PageTabInfo['label']}" data-direction="top" data-type="position">
                        {$PageTabInfo['label']}
                    </span>
                {/foreach}
                </div>
            </div>
        </span>

{/if}
<script language="JavaScript" type="text/javascript">
{literal}

    tooltip('.tip-items-list', {transition: true, time: 200});

    ld('.salestarget-tab .tab_more').unbind('mouseenter').bind('mouseenter',function () {
        tabMoreHover(this,'on');
    });
    ld('.salestarget-tab .tab_more').unbind('mouseleave').bind('mouseleave',function () {
        tabMoreHover(this,'off');
    });

{/literal}
</script>
