<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td class="ld-form-item-label">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <div class="lfloat ModuleFielddiv">
                <select class="ld-select-inner" disabled>
                    <option value="" selected>{$TABLABEL}</option>
                </select>
            </div>
            <div id="tabField" class="lfloat padL10 ModuleFielddiv">
                {if $type eq 'WorkBriefReport'}
                    <input type="hidden" name="1">
                    {$FIELDSEL}
                {else}
                    <select onchange="fieldSel(this)" class="ld-select-inner">
                        <option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>
                    </select>
                {/if}
            </div>
            <div class="lfloat padLR10">
                <input type="text" class="ld-input-inner" name="selField" id="selField" class="detailedViewTextBox" />
            </div>
            <input type="button" class="ld-button ld-button-primary" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertField(this)"/>
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <textarea class="ld-textarea-inner" cols="90" rows="6" name="CKcontent" style="resize:vertical;white-space: pre">{$CONTENT}</textarea>
        </td>
    </tr>
</table>