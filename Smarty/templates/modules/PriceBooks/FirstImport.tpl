<div id="importstep1" class="pop_up_content" style="display: block;width:100%;">
    <div class="pop_up_content_inner" >
        <!-- 流程进度条 start -->
        <div class="step_flow" style="left: 65%;">
            <div class="step_first {if $STEPINDEX gte 1} step_choosed {/if}">
                <p>{$ARRLABEL.fileuploadlabel}</p>
                <div class="process {if $STEPINDEX gt 1} process_finish {/if}"><span class="corner"></span></div>
            </div>
            <div class="step_middle {if $STEPINDEX gte 3} step_choosed {/if}">
                <p>{$ARRLABEL.importdatalabel}</p>
                <div class="process {if $STEPINDEX gt 3} process_finish {/if}"><span class="corner"></span></div>
            </div>
            <div class="step_last {if $STEPINDEX gte 4} step_choosed {/if}">
                <p>{$ARRLABEL.finishedlabel}</p>
                <div class="process {if $STEPINDEX gt 4} process_finish {/if}"><span class="corner"></span></div>
            </div>
        </div>
        <!-- 流程进度条 end -->
        <div class="pop_item pop-item-plus">
            <span>1. {$ARRLABEL.accordingimportdatalabel}</span>
            <div class="download-tem">
                <span class="js-entity_type_select" style="display: none"><select style="width:100px"><option value="666969600180959">默认业务类型</option></select></span>
                <span class="js-down_template"> <a href="javascript:void(0)" id="link_down">{$ARRLABEL.downloadtemplatedatalabel}</a> </span>
            </div>
            <div class="pop_item_content">
                <a href="javascript:;" class="more" onclick="showCautions()">{$ARRLABEL.viewcareitemlabel}&gt;&gt;</a>
                <div class="pop_info bothclear hidden">
                    <ul>
                    <li>1) {$ARRLABEL.notencontent_firstlabel}</li>
                    <li>2) {$ARRLABEL.notencontent_secondlabel}</li>
                    <li>3) {$ARRLABEL.notencontent_thirdlabel}</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="pop_item">
            <span>2. {$ARRLABEL.detaildupcheckmethod}</span>
            <div class="pop_item_content">
                <div name='dv_detail_dupcondition'>
                    {foreach from=$DETAILIMPORTCHECKDUPFIELDS item=dupcolumnname}
                        <div>
                            <span>
                                <select class="ld-select-inner gwidth30 mr50" tag='detail_dupcolumns'>
                                    {foreach from=$DETAILBLOCKS item=blockinfo}
                                        <optgroup label="{$blockinfo.blocklabel}">{$blockinfo.blocklabel}
                                            {foreach from=$DETAILFIELDS item=fieldinfo}
                                                {if $fieldinfo->getBlockId() eq $blockinfo.blockid}
                                                    {if $fieldinfo->getUIType() neq 69 && $fieldinfo->getUIType() neq 1109}
                                                        <option value="{$fieldinfo->getFieldName()}"
                                                                {if $fieldinfo->getFieldName() eq $dupcolumnname.columns}selected=""{/if}>{$fieldinfo->getfieldLabel()}</option>
                                                    {/if}
                                                {/if}
                                            {/foreach}
                                        </optgroup>
                                    {/foreach}
                                </select>
                            </span>
                        </div>
                    {/foreach}
                </div>
            </div>
        </div>

        <div class="pop_item">
            <span>3. 产品存在时覆盖导入价格,不存在时导入失败</span>
        </div>

        <div class="pop_item">
            <span>4. {'USESYSIMPORTFILE'|@getFixedLabel}</span>
            <div class="pop_item_content">
                <div class="fileinput-box">
                    <span class="fileinput-button">{'ADDFILE'|@getFixedLabel}
                        <input name="xls_file_upload" class="fileinput-input" type="file" title="选择文件" onchange="cls_PricebooksImportProduct.getInstance('{$MODULE}').uploadxls()"/>
                    </span>
                    <span class="uploadqueue-item-filename" name='showfilename' title=""> </span>
                    <div class="xlsimportprogress">
                        <div></div>
                    </div>
                </div>
                <div>
                    <span>{'SUPPORTFILETYPE'|@getFixedLabel}{'wpsformatisnotsupported'|@getFixedLabel} {'HOWEVERINPORTWPS'|@getFixedLabel}</span>
                </div>
            </div>
        </div>

  </div>
</div>
