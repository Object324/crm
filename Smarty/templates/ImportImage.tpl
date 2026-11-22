<div name="ImportImageDiv" id="ImportImageDiv" class="pop_remind_content">
    <div class="ld-description" name="description" id="description" style="display: flex;flex-direction: column">
        <i class="info-icon"></i>
        <div style="display: flex;flex-direction: column">
            {foreach key=key item=label from=$ImportImageTip}
                <div class="ld-description-content" {if $key neq 0}style="padding-top: 5px" {/if}>
                    {$label}
                </div>

            {/foreach}
        </div>
    </div>
    <div class="pop_prc_content" name="content" id="content">
        <div style="display: flex;align-items: center">
            <span tag="label" class="overflow-space" style="max-width: 200px" data-tip="{'ImportProductImageTipSelectImageField'|@getFixedLabel}" data-direction="top" data-type="position">{'ImportProductImageTipSelectImageField'|@getFixedLabel}: </span>
            <select id="imagefield" name="imagefield" class="padL8 padR8" style="max-width: 150px;height: 32px">
                {foreach key=key item=label from=$imagefield}
                    <option value="{$key}" {if $key eq $LatesdImportImageFieldName}selected{/if}>{$label}</option>
                {/foreach}
            </select>
        </div>
        <div class="padT16" style="display:flex;align-items: center">
            <div style="display: flex;align-items: center">
                <span class="overflow-space" style="max-width: 200px" tag="label" data-tip="{'ImportProductImageTipSelectNamingField'|@getFixedLabel}" data-direction="top" data-type="position">{'ImportProductImageTipSelectNamingField'|@getFixedLabel}: </span>
                <select id="nameformatfield" name="nameformatfield" class="padL8 padR8" style="width: 150px;height: 32px">
                    {foreach key=key item=label from=$NameFormatFieldName}
                        <option value="{$key}" {if $key eq $LatesdNameFormatFieldName}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
                <span class="padL8 padR8">+</span>
                <select id="nameformatexplode" name="nameformatexplode" class="padL8 padR8" style="width: 150px;height: 32px">
                    {foreach key=key item=label from=$NameFormatExplode}
                        <option value="{$key}" {if $key eq $LatesdNameFormatExplode}selected{/if}>{$label|@getVarFixedLabel:getFixedLabel('custom')}</option>
                    {/foreach}
                </select>
            </div>
            <span class="padL8 overflow-space" tag="label" style="max-width: 50px" data-tip="{'FOREXAMPLE'|@getFixedLabel}" data-direction="top" data-type="position">{'FOREXAMPLE'|@getFixedLabel}</span>
            <div id="example" class="overflow-space" style="max-width: 250px">
            </div>
        </div>
        <div class="padT16" style="display: flex;align-items: center">
            <div class="overflow-space ld-button" tag="label" data-tip="{'Uploadpictures'|@getFixedLabel}" data-direction="top" data-type="position" style="width: 100px" name="importImageBtn" id="importImageBtn">{'Uploadpictures'|@getFixedLabel}</div>
            <span class="padL8 padR8" style="color: #777">{'SupportFormat'|@getVarFixedLabel:'jpg.png.jpeg.gif'}</span>
        </div>
        <div class="padT16">
            <div name="importImageAddBtn" id="importImageAddBtn" style="height: 100px;border: 1px dashed #C0C4CC;display: flex;justify-content: center;align-items: center;flex-direction: column">
                <div style="font-size: 20px" >+</div>
                <span class="padL8 padR8" style="color: #777">{'ClickOrDrageToUpload'|@getFixedLabel}</span>
            </div>
        </div>
        <div id="importImageHiddenBtn" name="importImageHiddenBtn" class="padT16 padB16 importImageHiddenBtn" style="min-height: 20px">

        </div>
    </div>
</div>
