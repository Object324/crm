<div class="ld-pop-container ld-table-container ld-table-container-lines" >
    <div style="width: 100%; overflow-y: auto;" id="dv_scroll" class="divPopOverflow">
        <table class="" id="translateset_table" name="translateset_table" cellspacing="0" cellpadding="0" border="0">
            <thead>
                <tr>
                    <th style="width:40%;">{'ORIGINALNAME'|@getFixedLabel}</th>
                    <th style="width:40%;">{'NORMALNAME'|@getFixedLabel}</th>
                    <th style="width:20%;">{'DisplayColor'|@getFixedLabel}</th>
                </tr>
            </thead>
            <tbody>
            {foreach item=TMP_ARR from=$TRANSLATE_LABEL_ARR}
                <tr name="translateset_tr" data-labelbol="{$TMP_ARR.labelbol}" data-dbvalue="{$TMP_ARR.origin_label}" >
                    <td ><span name="origin_label" >{$TMP_ARR.origin_label}</span></td>
                    <td ><input name="show_label_zh" class="ld-input-inner" value='{$TMP_ARR.show_label_zh}' data-origin_label="{$TMP_ARR.origin_label}" ></td>
                    <td >
                        <div title="{'SELECTCOLOR'|@getFixedLabel}" name="value_color" data-choosecolor="{$TMP_ARR.value_color}"
                             style="width: 21px;height: 21px;border-radius: 100%;cursor: pointer;border: 1px solid #dbdbdb;background: {$TMP_ARR.value_color};left:0;top:0;" onclick="CommonChooseColor(this);">
                        </div>
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>
    <div class="padT16">
        <a id="translateset_clearbtn" name="translateset_clearbtn" href="javascript:void(0);" style="" >{'RESTORETHEDEFAULT'|@getFixedLabel}</a>
    </div>
</div>