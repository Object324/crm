{*//editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/12/3 16:07*}
<table class=" D_pop_bod listEntries " border="0" cellpadding="0" cellspacing="1">
    <tr>
        <th width="5%">#</th>
        <th><span title="{'BillType'|@getFixedLabel}">{'BillType'|@getFixedLabel}</span></th>
        <th><span title="{'DocumentNumber'|@getFixedLabel}">{'DocumentNumber'|@getFixedLabel}</span></th>
        <th><span title="{if $TYPE == 1}{'WHENTHENUMBEROFSTORAGE'|@getFixedLabel}{else}{'THENUMBEROFTHELIBRARY'|@getFixedLabel}{/if}">{if $TYPE == 1}{'WHENTHENUMBEROFSTORAGE'|@getFixedLabel}{else}{'THENUMBEROFTHELIBRARY'|@getFixedLabel}{/if}</span></th>
        <th><span title="{'STATUS'|@getFixedLabel}">{'STATUS'|@getFixedLabel}</span></th>
        <th><span title="{if $TYPE == 1}{'DATEOFWAREHOUSE'|@getFixedLabel}{else}{'OUTOFDATE'|@getFixedLabel}{/if}">{if $TYPE == 1}{'DATEOFWAREHOUSE'|@getFixedLabel}{else}{'OUTOFDATE'|@getFixedLabel}{/if}</span></th>
        <th><span title="{'Person_in_charge'|@getFixedLabel}">{'Person_in_charge'|@getFixedLabel}</span></th>
        <th width="18%"><span title="{'TIMEOFLASTMOD'|@getFixedLabel}">{'TIMEOFLASTMOD'|@getFixedLabel}</span></th>
    </tr>
    {foreach item=value from=$NATIONINFO}
    <tr>
        <td title="{$value.id}">{$value.id}</td>
        <td><span title="{$value.ware_no}">{$value.ware_no}</span></td>
        <td><span>{$value.bill_no}</span></td>
        <td><span title="{$value.quantity}">{$value.quantity}</span></td>
        <td><span title="{$value.presence}">{$value.presence}</span></td>
        <td><span title="{$value.createdtime}">{$value.createdtime}</span></td>
        <td><span title="{$value.smownerid}">{$value.smownerid}</span></td>
        <td><span title="{$value.modifiedtime}">{$value.modifiedtime}</span></td>
    </tr>
    {/foreach}
</table>

