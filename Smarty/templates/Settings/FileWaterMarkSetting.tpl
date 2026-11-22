<table class="ld-public-content padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tbody>
    <tr>
        <td class="ld-form-item-label">
            <label for="image_watermark">{'PICTUREWATERMARK'|@getFixedLabel}</label>
        </td>
        <td class="ld-form-item-content">
            <input id="image_watermark" type="checkbox" class="second_switch" {if $image_watermark eq 'yes'}checked {/if}>
        </td>
    </tr>
    <tr name="image_watermark_content_tr" {if $image_watermark neq 'yes'}style="display: none" {/if}>
        <td class="ld-form-item-label">{'PICTURE'|@getFixedLabel}</td>
        <td class="ld-form-item-content" name="image_watermark_content">
            <div class="ld-button-primary ld-button" name="image_buttom">{'Choosepictures'|@getFixedLabel}</div>
            <label href="javascript:;">({'ONEIMAGECANBEUPLOADED'|@getFixedLabel})</label>
            <div name="image_buttom_hidden" style="display: none"></div>
            <div class="ld-file-watermark-image-show" name="image_show" id="image_show" style="display:none;"></div>
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            <label for="text_watermark">{'TEXTWATERMARK'|@getFixedLabel}</label>
        </td>
        <td class="ld-form-item-content">
            <input type="checkbox" id="text_watermark" class="second_switch inputBornone" {if $text_watermark eq 'yes'}checked{/if}>
        </td>
    </tr>
    <tr  name="text_watermark_content_tr" {if $text_watermark neq 'yes'}style="display: none" {/if}>
        <td class="ld-form-item-label">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
        <td class="ld-form-item-content" name="text_watermark_content">
            <div class="lfloat ModuleFielddiv">
                <select class="ld-select-inner" disabled>
                    <option value="" selected>{$TABLABEL}</option>
                </select>
            </div>
            <div id="tabField" class="lfloat padL10 ModuleFielddiv">
                <select onchange="fieldSel(this)" class="ld-select-inner">
                    <option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>
                </select>
            </div>
            <div class="lfloat padLR10">
                <input type="text" class="ld-input-inner" name="selField" id="selField" class="detailedViewTextBox" />
            </div>
            <input type="button" class="ld-button ld-button-primary" value="{'insert'|@getFixedLabel}" onclick="InsertField(this)"/>
        </td>
    </tr>
    <tr  name="text_watermark_content_tr" {if $text_watermark neq 'yes'}style="display: none" {/if}>
        <td class="ld-form-item-label">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
        <td class="ld-form-item-content" name="text_watermark_content">
            <textarea class="ld-textarea-inner" cols="90" rows="6" name="CKcontent" style="resize:vertical;white-space: pre">{$CONTENT}</textarea>
            <label class="padL5">{'WILDCARD'|@getFixedLabel} : {'CURRENTDATE'|@getFixedLabel} {literal}{currentdate}{/literal}</label>
        </td>
    </tr>
    </tbody>
</table>
{if $type eq 'excel'}
    <div class="greyFont9" style="padding:10px 15px 20px 10px">
        <span style="color:red">*{'EXPLAIN'|@getFixedLabel} : {'EXCELADDWATERMARKTIP'|@getFixedLabel}</span>
    </div>
    <div class="greyFont9" style="padding:10px 15px 20px 10px">
        <span style="color:red">*{'EXPLAIN'|@getFixedLabel} : {'EXCELWATERMARKDOWNLOADTIP'|@getFixedLabel}</span>
    </div>
{else}
    <div class="greyFont9" style="padding:10px 15px 20px 10px">
        <span style="color:red">*{'EXPLAIN'|@getFixedLabel} : {'WORDADDWATERMARKTIP'|@getFixedLabel}</span>
    </div>
{/if}
