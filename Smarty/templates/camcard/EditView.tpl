<script language="JAVASCRIPT" type="text/javascript" src="expansion/camcard/camcard.js"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'SELECTMODULE'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'SELECTMODULE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="selectedmodule" class="ld-select-inner gwidth50" name="selectedmodule" onchange="camcard.getInstance().switchModule()">
                    {foreach item=drp key=module from=$MODULELIST}
                        <option value="{$drp.comparid}" status="{$drp.status}" {$drp.selected} >{$drp.fieldlabel}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="checkbox" class="second_switch" name="modulestatus" id="modulestatus" {if $MODULELIST_FIRSY eq 1}checked{/if} >
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'ACTIVITYFIELDSETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
    </table>
    <div id="EditViewDetail" class="ld-pop-container ld-table-container ld-table-container-lines padT0">
        {include file='camcard/EditViewDetail.tpl'}
    </div>
</form>
</div>