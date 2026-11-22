{*@edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能*}
<div style="width:100%; overflow: auto; min-height: 200px; max-height:90%;">
    <div style="height:100%;width:100%;">
        <table border=0 cellspacing=1 cellpadding="0" width="100%" class="listEntries">
            <tr>
                <th nowrap="nowrap">#</th>
                {if $module eq 'Accounts'}
                <th nowrap="nowrap">{$autoDialListHeader['accountname']}</th>
                <th nowrap="nowrap">{$autoDialListHeader['account_no']}</th>
{*                <th nowrap="nowrap">{$autoDialListHeader['lastname']}</th>*}
                {else}
                <th nowrap="nowrap">{$autoDialListHeader['lastname']}</th>
                <th nowrap="nowrap">{$autoDialListHeader['contact_no']}</th>
                <th nowrap="nowrap">{$autoDialListHeader['accountid']}</th>
                {/if}

{*                <th nowrap="nowrap">{$autoDialListHeader['mobile']}</th>*}
                <th nowrap="nowrap">{'DialStatus'|@getFixedLabel}</th>
                <th nowrap="nowrap">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            {if $autoDialList neq ''}
            {foreach key=index item=autoDialDetail from=$autoDialList}

             <tr id="record_{$autoDialDetail.record}" dialstatus="0" index="{$index}" record="{$autoDialDetail.record}" mobile="{$autoDialDetail.mobile}"  class="{if $index mod 2 eq '0'}lvtColData{else}lvtColDataBj{/if}" onmouseout="listOnMouseOut(ld(this),{if $index mod 2 eq '0'}'on'{else}'On'{/if});" onmouseover="listOnMouseOver(ld(this));" >{*dialstatus为0，表示未拨打；为1表示正在拨打；为2表示已经拨打为；为3表示已跳过*}

                 <input type="hidden" name="accountid"  value="{$autoDialDetail.accountid}"/>
                 <input type="hidden" name="contactid"  value="{$autoDialDetail.contactid}"/>
                 <td style="word-wrap:break-word;" align="left">{$index+1}</td>
                 {if $module eq 'Accounts'}
                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.accountname}</td>
                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.billno}</td>
{*                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.lastname}</td>*}
                 {else}
                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.lastname}</td>
                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.billno}</td>
                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.accountname}</td>
                 {/if}

{*                 <td style="word-wrap:break-word;" align="left">{$autoDialDetail.mobile}</td>*}
                 <td style="word-wrap:break-word;" align="left" name="dialstatus">未拨打</td>
                 <td style="word-wrap:break-word;" align="left"><a class="Anu3_a redFont" btn="addBtn" record="{$autoDialDetail.record}" onclick="cls_AutoDial.removeTr(this)">{'DELETE'|@getFixedLabel}</a></td>
            </tr>

            {/foreach}
            {else}
            {*<tr style="height: 25px;" bgcolor="white">
                <td colspan='6' align='center'><i>{'NONE'|@getFixedLabel}</i></td>
            </tr>*}
            {/if}

        </table>
    </div>
</div>