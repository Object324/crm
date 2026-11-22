<div class="searchbatchtext">
    <div style="margin-bottom: 10px;">
        <span>{$Headdtitle.warehoursename}</span>
        <select name="warehouse" class="ld-select-inner" style="margin-left: 5px;width: 200px;">
            <option value=""></option>
            {foreach from=$warehouselist item=warehouseinfo}
                {if $warehouseinfo.id eq $wareid}
                    <option value="{$warehouseinfo.id}" selected="">{$warehouseinfo.name}</option>
                {else}
                    <option value="{$warehouseinfo.id}">{$warehouseinfo.name}</option>
                {/if}
            {/foreach}
        </select>
        <span style="margin-left: 10px;">{$Headdtitle.batch}</span>
        <input type="text" name="batchtext" class="ld-input-inner" style="width:240px;margin-top: -3px;margin-left: 5px;" />
        <input type="button" name="findnow" value="{'FINDNOW'|@getFixedLabel}" class="ld-button ld-button-primary" style="margin-top: -4px;margin-left: 5px;" />
    </div>
    <div name="content">
        {include file="batchlistmulticontent.tpl"}
    </div>
</div>