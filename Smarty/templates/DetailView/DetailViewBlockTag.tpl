<!--修改编码格式:统一编码：UTF-8-->
<!-- XUQIU1001374 xxy 2023-5-18 将标签的代码加入评论模块上方 -->
{if $labelinfo.tagdisplayright eq 'yes'}
    {if $labelinfo.display_status eq 1 || $labelinfo.display_status eq 3 || $BLOCKSTYLE == 1}
            {assign var='arrawcls' value=''}
    {else}
            {assign var='arrawcls' value='On'}
    {/if}
        {if $HIDDENSTYLE eq 1}
            <div class="DivCName">
                {if !empty($labelinfo.labeldblockid)}
                    <span class="{$arrawcls}" id="aid{$labelinfo.labeldblockid}" name="aid{$labelinfo.labeldblockid}"></span>{$labelinfo.labelname}
                {else}
                    <span class="{$arrawcls}" id="aid{$labelinfo.labelname|@str_replace:' ':''}" name="aid{$labelinfo.labelname|@str_replace:' ':''}"></span>{$labelinfo.labelname}
                {/if}
            </div>
        {else}
            {if !empty($labelinfo.labeldblockid)}
                {if $arrawcls == 'On'}
                    <div class="DivCName DivCNamehover ld-shadow-first tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$labelinfo.labeldblockid|@replace:' ':''}','aid{$labelinfo.labeldblockid|@replace:' ':''}');">
                {else}
                    <div class="DivCName DivCNamehover tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$labelinfo.labeldblockid|@replace:' ':''}','aid{$labelinfo.labeldblockid|@replace:' ':''}');">
                {/if}
            <span class="{$arrawcls}" id="aid{$labelinfo.labeldblockid|@replace:' ':''}" name="aid{$labelinfo.labeldblockid|@replace:' ':''}"></span>{$labelinfo.labelname}
            {else}
                <div class="DivCName DivCNamehover tip-items-list" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tbl{$labelinfo.labelname|@replace:' ':''}','aid{$labelinfo.labelname|@replace:' ':''}');">
                <span class="{$arrawcls}" id="aid{$labelinfo.labelname|@replace:' ':''}" name="aid{$labelinfo.labelname|@replace:' ':''}"></span>{$labelinfo.labelname}
            {/if}
            </div>
        {/if}
        {if $labelinfo.display_status eq 1 || $labelinfo.display_status eq 3 || $BLOCKSTYLE == 1} {*判断是否展开*}
        
            {if !empty($labelinfo.labeldblockid)}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" istag="yes" id="tbl{$labelinfo.labeldblockid|replace:' ':''}" name="tbl{$labelinfo.labeldblockid|replace:' ':''}" >
            {else}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:block;" istag="yes" id="tbl{$labelinfo.labelname|replace:' ':''}" name="tbl{$labelinfo.labelname|replace:' ':''}" >
            {/if}
        {else}
            {if !empty($labelinfo.labeldblockid)}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" istag="yes" id="tbl{$labelinfo.labeldblockid|replace:' ':''}" name="tbl{$labelinfo.labeldblockid|replace:' ':''}" >
            {else}
                <div class="DivCNotice ld-shadow-first" style="width:auto;display:none;" istag="yes" id="tbl{$labelinfo.labelname|replace:' ':''}" name="tbl{$labelinfo.labelname|replace:' ':''}" >
            {/if}
        {/if}
        <table border=0 cellspacing="1" cellpadding=0 width="100%" class="DetailContentTable" style="margin-top: 10px;margin-bottom: 10px;">
            <tr>
                <td class="DetailedTd1Label" width="100%" align="left" colspan="4">
                    <input type="hidden" name="detail_tagger_search" value="{$labelinfo.tag_name}" tag_id="" tag_type="{$labelinfo.tag_type}" id="detail_tagger_search" />
                        <script type="text/javascript">
                            {literal}
                                ld(document).ready(function(){
                                    ListTagDetailShow('detail_tagger_search');
                                });
                            {/literal}
                        </script>
                    <input name="add_moduledata_tag" style="margin:4px; display: block;" module="{$MODULE}" onclick="detailbutton_click(this,'{$MODULE}','add_moduledata_tag','{$ID}');return false;" class="ld-button" value="{'Tagging'|@getFixedLabel}" type="button">
                </td>
            </tr>
        </table>
    </div>
{/if}
<script type="text/javascript">
{literal}
//tooltip('.tip-items-list', {transition: true, time: 200});
{/literal}
</script>