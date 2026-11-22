<input type=hidden id="test_{$HOME_STUFFID}" value = {$HOME_STUFFTYPE}/>
<input type=hidden id=more_{$HOME_STUFFID} value="{$HOME_STUFF.Details.ModuleName}"/>
<input type=hidden id=parent_{$HOME_STUFFID} value="{$HOME_STUFF.Details.ParentTab}"/>
{*默认是第一页  下拉加载使用*}
<input type=hidden id="stuff_{$HOME_STUFFID}_pagenum" value="1"/>
<input type=hidden id="stuff_{$HOME_STUFFID}_havenextpage" value="yes"/>

<div style="width: calc(100% - 40px);overflow: auto;margin: 0 20px;height: 100%;">
    <table class="D_home_table " width="100%" cellspacing="0" cellpadding="0" border="0" style="padding: 0;table-layout: fixed">
        {if is_array($HOME_STUFF.Details.Header) && $HOME_STUFF.Details.Header|@count > 0}
            <tr style="position: sticky; top:0px;">
            {foreach item=header from=$HOME_STUFF.Details.Header }
                <th>{$header}</th>
            {/foreach}
            </tr>
        {/if}
        {include file="Home/HomeBlockContent.tpl" }
    </table>
    {if is_array($HOME_STUFF.Details.Entries) && $HOME_STUFF.Details.Entries|@count <= 0}
        {if !$NoRecords_CONTENT || $NoRecords_CONTENT eq ''}
            {assign var = NoRecords_CONTENT value = {'NOTFOUNDANYRECORD'|@getFixedLabel}}
        {/if}
        <div style="width: 100%;height: calc(100% - 50px);display: flex;justify-content: center;align-items: center;">
            <div style="width: 30%;height: 50%;display: flex;flex-direction: column;align-items: center;">
                <div class="wtc_img" style="width: 80%;display: flex;justify-content: center;align-items: center;{if $NoRecords_IMGSTYLE && $NoRecords_IMGSTYLE neq ''}{$NoRecords_IMGSTYLE}{/if}">
                    <img src="themes/icon2023/ld-no-records.png?v={$GLOBALMINVERSION}" style="width: 180px">
                </div>
                <div style="font-size: 14px;color: #8998AC;">
                    {$NoRecords_CONTENT}
                </div>
            </div>
        </div>
    {/if}
</div>

{if $HOME_STUFF.Details|@is_array == 'true'}
  <input id='search_qry_{$HOME_STUFFID}' name='search_qry_{$HOME_STUFFID}' type='hidden' value='{$HOME_STUFF.Details.search_qry}' />
{/if}
