
<div id="stuffcont_label_{$stuffinfo['stuffid']}" class="ld_stuffcont ld_stuffcont_label"
     style="min-height:{$DataLabelNum * $DataLabelPadding};">
    <div class="ld_stuffcont_labeltype" style="order: 1;height: {$DataLabelHeight};">
        <div class="stufflabel_type" >{'COMPLETIONVALUE'|@getFixedLabel}</div>
        <div class="stufflabel_value" id="stuffcont_complate_value" tag="done" style="color:#3B7CFF;cursor: pointer;"></div>
    </div>
    <div class="ld_stuffcont_labeltype" style="order: 2;height: {$DataLabelHeight};">
        <div class="stufflabel_type" >{'TOLOOKVALUE'|@getFixedLabel}</div>
        <div class="stufflabel_value" id="stuffcont_salesgoal_value" tag="target" style="color:#3B7CFF;cursor: pointer;"></div>
    </div>
    <div class="ld_stuffcont_labeltype" style="order: 3;height: {$DataLabelHeight};">
        <div class="stufflabel_type" >{'INCOMPLETEVALUE'|@getFixedLabel}</div>
        <div class="stufflabel_value" tag="undone"></div>
    </div>
</div>