<style type="text/css">@import url("themes/softed/common.css?v={$GLOBALMINVERSION}");</style>
<input type="hidden" name="option" value="{$option}">
{if $option eq 'notice'}
    <div id="remindset_divcontent">
        <form id="remindset_form">
            <table class="ld-public-content-small" cellspacing="0" cellpadding="0" border="0" width="100%">
                <tbody>
                {foreach key=key item=item from=$remindSetArr}
                    <tr>
                        <td class="ld-form-item-label">{$item.name}</td>
                        <td class="ld-form-item-content select-input">
                            <input class="second_switch" type="checkbox" name="{$key}" {if $item.is_open eq "yes"}checked{/if}>
                        </td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
        </form>
    </div>
{elseif $option eq 'default'}
    <div class="ld-public-content-small" name="default_value_setting">
        <div class="ld-form-item-div">
            <div class="ld-form-item-label">
                <label>{'CalendarDefaultDisplay'|@getFixedLabel}</label>
            </div>
            <div class="ld-form-item-content">
                <select name="default_display" class="ld-select-inner">
                    {foreach key=value item=arr from=$DEFAULTDISPLAYARR}
                        <option value="{$value}" {if $arr.selected eq 'yes'}selected{/if}>{$arr.label}</option>
                    {/foreach}
                </select>
            </div>
        </div>

        <div class="ld-form-item-div">
            <div class="ld-form-item-label">
                <label>{'DefaultStartTime'|@getFixedLabel}</label>
            </div>
            <div class="ld-form-item-content">
                <select name="default_start_time" class="ld-select-inner">
                    {foreach key=value item=arr from=$DEFAULTSTARTTIMEARR}
                        <option value="{$value}" {if $arr.selected eq 'yes'}selected{/if}>{$arr.label}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="ld-form-item-div">
            <div class="ld-form-item-label">
                <label>{'TimeSlotDurationDefault'|@getFixedLabel}</label>
            </div>
            <div class="ld-form-item-content">
                <select name="default_time_slot" class="ld-select-inner">
                    {foreach key=value item=arr from=$DEFAULTTIMESLOTARR}
                        <option value="{$value}" {if $arr.selected eq 'yes'}selected{/if}>{$arr.label}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </div>
{elseif $option eq 'color'}
    <div class="ld-pop-container">
        <div>
            <div>
                <label>{'EnableCustomColorRules'|@getFixedLabel}</label>
                <input class="second_switch" style="margin-bottom: 3px" type="checkbox" name="customColorStatus" {if $customColorStatus=="yes"}checked{/if} onclick="CalendarColorSettings.getInstance().changeStatus(this,'CalendarCustomColorStatus')">
            </div>
            <div class="padB16 rfloat">
                <a class="ld-button ld-button-primary" href="javascript:void(0);" name="rulecreate" tag="create" onclick="CalendarColorSettings.getInstance().create()">{'ADDRULES'|@getFixedLabel}</a>
            </div>
        </div>
        <div name="color_rule_table">
            {include file='modules/Calendar/CalendarColorSetting_ListView.tpl'}
        </div>
    </div>
{elseif $option eq 'field'}
    {include file='ContentTemplates.tpl'}
{/if}


