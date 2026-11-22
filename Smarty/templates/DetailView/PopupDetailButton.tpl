<table class="bgwhite" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td align='left'>
            <div class="">
                <ul class="D_btn_box a">
                    {foreach key=btn_key item=btn_item from=$DETAILBUTTON}
                        {if $btn_item.permit eq 'yes'}
                            {if $btn_key eq 'Settings'}
                                <li class="D_anu_a D_menu_hova">
                                    <a title="{$btn_item.label}" tag="DetailView_Page_Setting"
                                       href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&formodule={$MODULE}"
                                       target="_blank">
                            {elseif $btn_key eq 'RelevantSettings'}
                                <li class="D_anu_a D_menu_hova detail_menu" onclick="SetRelatedlist(ld(this),'{$MODULE}')" relateTag="custom">
                                    <a title="{$btn_item.label}" href="javascript:;">
                            {else}
                                <li class="D_anu_a D_menu_hova detail_menu" onclick="detailbutton_click(this,'{$MODULE}','{$btn_key}','{$ID}');return false;" >
                                    <a title="{$btn_item.label}" tag="{if $btn_item.tag != ''}{$btn_item.tag}{/if}" href="javascript:;">
                            {/if}
                                        <b class="icon-homeimg {$btn_item.icon}"></b>
                                        <span>{$btn_item.label}</span>
                                    </a>
                                    {if $btn_item.list != ''}
                                        <ol class="D_more_menua">
                                            {foreach key=more_key item=more_item from=$btn_item.list}
                                                {if $more_item.permit eq 'yes'}
                                                    <li onclick="detailbutton_click(this,'{$MODULE}','{$more_key}','{$ID}');return false;">
                                                        <a title="{$more_item.label}"
                                                           tag="{if $more_item.tag != ''}{$more_item.tag}{/if}">
                                                            {$more_item.label}</a>
                                                    </li>
                                                {/if}
                                            {/foreach}
                                        </ol>
                                    {/if}
                                </li>
                        {/if}
                    {/foreach}
                </ul>
                {if $CHECKOUTSTATU neq ''}
                    <div class="rfloat padT7 padR100" style="display:none;"><img
                                src="{$CHECKOUTSTATU|@lingdang_imageurl:$THEME}"/></div>
                {/if}
                {if $APPROVESTATUS neq ''}
                    {assign var=count value=1}
                    <div class="rfloat padT7 padR100" style=""><img src="{$APPROVESTATUS}"/></div>
                {/if}
                {if $PUBLICACCOUNT eq 1 }<!--未分配公海,z-index大于700会遮挡更多下拉按钮-->
                    {assign var=count value=1}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        {if $LANGUAGETYPE eq 'en'}
                            <img src='themes/images/nodistribution_en.png'/>
                        {else}
                            <img src='themes/images/nodistribution.png'/>
                        {/if}
                    </div>
                {elseif $PUBLICACCOUNT eq 2 || $PUBLICACCOUNT eq 3}<!--已分配公海,z-index大于700会遮挡更多下拉按钮-->
                    {assign var=count value=1}
                    {assign var=count value=1}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        {if $LANGUAGETYPE eq 'en'}
                            <img src='themes/images/distribution_en.png'/>
                        {else}
                            <img src='themes/images/distribution.png'/>
                        {/if}
                    </div>
                {/if}
                {if $CashBillType eq 'cashbill'}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        {if $LANGUAGETYPE eq 'en'}
                            <img src='themes/images/shoukuan.png'/>
                        {else}
                            <img src='themes/images/cashbill.png'/>
                        {/if}
                    </div>
                {else if $CashBillType eq 'debuction'}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        {if $LANGUAGETYPE eq 'en'}
                            <img src='themes/images/yushou.png'/>
                        {else}
                            <img src='themes/images/debuction.png'/>
                        {/if}
                    </div>
                {/if}
                {if $sostatusImg neq ''}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        <img src='themes/images/{$sostatusImg}'/>
                    </div>
                {else if $cf_2444_image neq ''}
                    <div class="rfloat padT7 padR100" style="z-index:650;">
                        <img src='themes/images/{$cf_2444_image}'/>
                    </div>
                          
                {/if}
            </div>
        </td>
        <td align='right'>
            {if $MODULE=='Products'}
                <a class="rfloat" href="javascript:;" style="margin-right: 20px; "
                   onclick="getLinksUrl('Module','Module','module_products');"
                   title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}
        </td>
    </tr>
</table>