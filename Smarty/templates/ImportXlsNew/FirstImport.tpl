<div id="importstep1" class="pop_up_content" style="display: block;width:100%;">
    <!-- 流程进度条 start -->
    <div class="pop_up_content_inner">
        {include file="ImportXlsNew/ImportStepTip.tpl"}
        <!-- 流程进度条 end -->
        <div class="pop_item pop-item-plus">
            <span>1. {$ARRLABEL.accordingimportdatalabel}</span>
            <div class="download-tem">
                <span class="js-entity_type_select" style="display: none"><select style="width:100px">
                        <option value="666969600180959">默认业务类型</option>
                    </select></span>
                <span class="js-down_template"> <a href="javascript:void(0)"
                        id="link_down">{$ARRLABEL.downloadtemplatedatalabel}</a> </span>
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
            <span>2. {$ARRLABEL.dup_setdupfields_label}</span>
            <div class="pop_item_content">
                <div name="dv_dupcondition">
                    {assign var='i' value=1}
                    {foreach from=$IMPORTCHECKDUPFIELDS item=dupcolumnname}
                        <div>
                            <span>
                                <select class="ld-select-inner gwidth30 mr50" tag='dupcolumns' {if $MODULE eq 'Users'} disabled="true"{/if}>
                                    <option value="">{'CAMCARDNONE'|getFixedLabel}</option>
                                    {foreach from=$BLOCKS item=blockinfo}
                                        <optgroup label="{$blockinfo.blocklabel}">{$blockinfo.blocklabel}
                                            {foreach from=$FIELDS item=fieldinfo}
                                                {if !empty($fieldinfo)}
                                                    {if $fieldinfo->getBlockId() eq $blockinfo.blockid}
                                                        {if $fieldinfo->getUIType() neq 69 && $fieldinfo->getUIType() neq 1109&& $fieldinfo->getUIType() neq 202}
                                                            <option value="{$fieldinfo->getFieldName()}" {if is_array($dupcolumnname) && $fieldinfo->getFieldName() eq $dupcolumnname.columns}selected=""{/if}>{$fieldinfo->getfieldLabel()}</option>
                                                        {/if}
                                                    {/if}
                                                {/if}
                                            {/foreach}
                                        </optgroup>
                                    {/foreach}
                                </select>
                            </span>
                            <!-- zxm 20230815 BUG0064194 修改建议:单一的查询条件就不需要集合条件判断了-->
                            {*wym 240509 BUG20240507-31 导入完成后再次导入,查重条件要显示出来,最后一条查重条件不显示*}
                            <span {if empty($dupcolumnname.condition) || $i==count($IMPORTCHECKDUPFIELDS)}style="display:none;"{/if}>
                                <select class="btn-radius-system" tag='dupcondition'>
                                    <option value="or"{if is_array($dupcolumnname) && $dupcolumnname.condition eq 'or'} selected=""{/if}>{'OR'|@getFixedLabel}</option>
                                        <option value="and" {if is_array($dupcolumnname) && $dupcolumnname.condition eq 'and'} selected=""{/if}>{'SEARCHAND'|@getFixedLabel}</option>
                                </select>
                            </span>

                            <span>
                                <label onclick='cls_XlsImportNew.getInstance("{$MODULE}").deleteimportdupfieldtr(ld(this),"dv_dupcondition")' class='ld-fonticon ld-fonticon-del popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>
                            </span>
                        </div>
                        {assign var="i" value=$i+1}
                    {foreachelse}

                    {/foreach}
                </div>
                <div>
                    {if $MODULE neq 'Users'}
                        <input type="button" class="ld-button" value="{'NEWCONDITIONS'|@getFixedLabel}" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_addnewcondition()" />
                    {/if}
                </div>
            </div>
        </div>

        {if $DETAILMODULE neq ''}
            <div class="pop_item">
                <span>3. {$ARRLABEL.detaildupcheckmethod}</span>
                <div class="pop_item_content">
                    <div name='dv_detail_dupcondition'>
                            {foreach from=$DETAILIMPORTCHECKDUPFIELDS item=dupcolumnname}
                                    <div>
                                        <span>
                                            <select class="ld-select-inner gwidth30 mr50" tag='detail_dupcolumns'>
                                                {if $DETAILMODULE eq 'Contacts'}
                                                    <option value="">{'NOIMPORT'|getFixedLabel}</option>
                                                {else if $DETAILMODULE neq 'Products'}
                                                    <option value="">{'CAMCARDNONE'|getFixedLabel}</option>
                                                {/if}
                                                {foreach from=$DETAILBLOCKS item=blockinfo}

                                                    <optgroup label="{$blockinfo.blocklabel}">{$blockinfo.blocklabel}
                                                        {foreach from=$DETAILFIELDS item=fieldinfo}
                                                            {if !empty($fieldinfo)}
                                                                {if $fieldinfo|@is_null eq false &&  $fieldinfo->getBlockId()|@is_null eq false &&  $fieldinfo->getBlockId() eq $blockinfo.blockid}
                                                                    {if $fieldinfo->getUIType() neq 69 && $fieldinfo->getUIType() neq 1109}
                                                                        <option value="{$fieldinfo->getFieldName()}" {if is_array($dupcolumnname) && $fieldinfo->getFieldName() eq $dupcolumnname.columns}selected=""{/if}>{$fieldinfo->getfieldLabel()}</option>
                                                                    {/if}
                                                                {/if}
                                                            {/if}
                                                        {/foreach}
                                                    </optgroup>
                                                {/foreach}
                                            </select>
                                        </span>
                                        <!-- zxm 20230815 BUG0064194 修改建议:单一的查询条件就不需要集合条件判断了-->
                                        <span style="display:none;">
                                            <select class="btn-radius-system" tag='detail_dupcondition'>
                                                <option value="or" {if is_array($dupcolumnname) && $dupcolumnname.condition eq 'or'} selected=""{/if}>{'OR'|@getFixedLabel}</option>
                                                <option value="and" {if is_array($dupcolumnname) && $dupcolumnname.condition eq 'and'} selected=""{/if}>{'SEARCHAND'|@getFixedLabel}</option>
                                            </select>
                                        </span>
                                        <span>
                                            <label onclick='cls_XlsImportNew.getInstance("{$MODULE}").deleteimportdupfieldtr(ld(this),"dv_detail_dupcondition")' class='ld-fonticon ld-fonticon-del popupselectdiv' style='margin-top:2px;cursor:pointer;'></label>
                                        </span>
                                    </div>
                            {foreachelse}

                            {/foreach}
                    </div>
                    <div>
                        <input type="button" class="ld-button addConditionRow" value="{'NEWCONDITIONS'|@getFixedLabel}" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_add_detailnewcondition()" />
                    </div>
                </div>
            </div>
        {/if}

        <div class="pop_item">
            <span>{if $DETAILMODULE neq ''}4. {else}3. {/if}{$ARRLABEL.dup_importmethod_label}</span>
            <div class="pop_item_content">
                <div>
                    <span>
                        <select class="ld-select-inner gwidth30 mr50" name="choose" onchange="cls_XlsImportNew.getInstance('{$MODULE}').chooseAlert('{'coveragemethodwillupdate'|@getFixedLabel}')">
                            <option value="Update">{'IMPORTUPDATE'|@getFixedLabel}</option>
                            {if $MODULE neq 'Users' && $MODULE neq 'Accounts' && $MODULE neq 'TimeSheet'}
                                <option value="UpdateAll">{'IMPORTUPDATEALL'|@getFixedLabel}</option>
                            {/if}
                            {if $MODULE neq 'Users'}
                                <option value="Insert">{'IMPORTADD'|@getFixedLabel}</option>
                            {/if}
                            <option value="Abort" selected="">{'IMPORTABORT'|@getFixedLabel}</option>
                        </select>
                    </span>
                </div>
            </div>
        </div>
        {if $DETAILMODULE neq ''&&($MODULE|get_file_address:'ProductDetails' ||($MODULE == 'CashBill'|| $MODULE == 'SendCashBill'))}
            <div class="pop_item">
                <span>5. {$ARRLABEL.productnotexistsmethod_label}：</span>
                <div class="pop_item_content">
                    <div>
                        <span>
                            <select class="ld-select-inner gwidth30 mr50" name="product_import_type">
                                <option value="NoImportRow">{'Ignoretheproducts'|@getFixedLabel}</option>
                                <option value="NoImportData">{'Ignoretheorder'|@getFixedLabel}</option>
                                <option value="AddProduct" selected="">{'Automaticallyaddproducts'|@getFixedlabel}</option>
                            </select>
                        </span>
                    </div>
                </div>
            </div>
        {/if}
        <div class="pop_item">
            <span>{if $DETAILMODULE eq 'Contacts'}5. {elseif $DETAILMODULE neq ''}6. {else}4. {/if}{'IMPORTCONTROL'|@getFixedLabel}</span>
            <div class="pop_item_content">
                <span>{'CHECKPICKLIST'|@getFixedLabel}</span>
                <input type="checkbox" name="checkPicklist" id="checkPicklist" value="" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_control_checkpicklist()"{if $checkPicklist neq 'no'} checked="" {/if} class="second_switch" style="margin-bottom:3px;margin-left: 200px;">
                <span> <a {if $checkPicklist eq 'no'} style="display:none" {/if} href="javascript:void(0)" name="setPicklistColumn" id="setPicklistColumn" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_control_setpicklistcolumn()" >{'CHECKPICKLISTCOLUMN'|@getFixedLabel}</a> </span>
            </div>
            <div class="pop_item_content">
                <span>{'CHECKWORKFLOW'|@getFixedLabel}</span>
                <input type="checkbox" name="checkWorkflow" id="checkWorkflow" value="" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_control_checkworkflow()"{if $checkWorkflow eq 'yes'} checked="" {/if} class="second_switch" style="margin-bottom:3px;margin-left: 200px;">
            </div>
            <div class="pop_item_content">
                <span>{'CHECKWORKFLOWTIP'|@getFixedLabel}</span>
            </div>
        </div>

        <div class="pop_item">
            <span>{if $DETAILMODULE eq 'Contacts'}6. {else if $DETAILMODULE neq ''}7. {else}5. {/if}{'USESYSIMPORTFILE'|@getFixedLabel}</span>
            <div class="pop_item_content">
                <div class="fileinput-box">
                    <span class="ld-button fileinput-button">{'ADDFILE'|@getFixedLabel}<input name="xls_file_upload" class="fileinput-input" type="file" title="选择文件" onchange="cls_XlsImportNew.getInstance('{$MODULE}').uploadxls()" /></span>
                    <span class="uploadqueue-item-filename" name='showfilename' title=""> </span>
                    <div class="xlsimportprogress" ><div></div></div>
                </div>
                <div><span>{'SUPPORTFILETYPE'|@getFixedLabel}{'wpsformatisnotsupported'|@getFixedLabel} {'HOWEVERINPORTWPS'|@getFixedLabel}</span></div>
            </div>
        </div>

    </div>
</div>
