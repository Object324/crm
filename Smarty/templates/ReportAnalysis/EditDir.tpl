<div class="ld-public-content-small" id="newDirContent">
    <div class="ld-form-item-div">
        <div class="ld-form-item-label"><font color="red">*</font>{'ZHPARENTMENUNMAE'|@getFixedLabel}</div>
        <div class="ld-form-item-content"><input id="parent_id" type="hidden" value="{$analysisfolder_info['parent_id']}" name="parent_id">
        <input id="analysisfolder_id" type="hidden" value="{$analysisfolder_info['analysisfolder_id']}" name="analysisfolder_id"><input id="folderlabel_zh" class="ld-input-inner" placeholder="{'pleaseenter'|@getFixedLabel}（{'ACTIVITYMUSTFILL'|@getFixedLabel}）" name="folderlabel_zh" value="{$analysisfolder_info['folderlabel_zh']}"></div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label"><font color="red">*</font>{'ENPARENTMENUNMAE'|@getFixedLabel}</div>
        <div class="ld-form-item-content"><input id="folderlabel_en" class="ld-input-inner" placeholder="{'pleaseenter'|@getFixedLabel}（{'ACTIVITYMUSTFILL'|@getFixedLabel}）" name="folderlabel_en" value="{$analysisfolder_info['folderlabel_en']}"></div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">{'CAMCARDCAPTION'|@getFixedLabel}</div>
        <div class="ld-form-item-content"><textarea id="description" class="ld-textarea-inner" placeholder="{'pleaseenter'|@getFixedLabel}">{$analysisfolder_info['description']}</textarea></div>
    </div>
</div>