{*editor:gyq_162 reason:海格产品分录导入   2019/12/5 15:18 *}
<div id="importstep1" class="pop_up_content" style="display: block;width:100%;">
    <!-- 流程进度条 start -->
    <div class="pop_up_content_inner">
        {include file="ImportXlsNew/ImportStepTip.tpl"}
        <!-- 流程进度条 end -->
        <div class="pop_item pop-item-plus">
            <span>1. {$ARRLABEL.accordingimportdatalabel}</span>
            <div class="download-tem">
                <span class="js-entity_type_select" style="display: none"><select style="width:100px"><option
                                value="666969600180959">默认业务类型</option></select></span>
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

            <span>2. {$ARRLABEL.detaildupcheckmethod}</span>
            <div class="pop_item_content">
                <div name='dv_detail_dupcondition'>
                    {foreach from=$DETAILIMPORTCHECKDUPFIELDS item=dupcolumnname}
                        <div>
                                   <span>
                                        <select class="ld-select-inner gwidth30 mr50" tag='detail_dupcolumns'>
                                            {if $DETAILMODULE neq 'Products'}
                                                <option value="">{'CAMCARDNONE'|getFixedLabel}</option>
                                            {/if}
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
                            <span>
                                        <select class="btn-radius-system" tag='detail_dupcondition'>
                                            <option value="or">{'OR'|@getFixedLabel}</option>
                                             <option value="and">{'SEARCHAND'|@getFixedLabel}</option>
                                        </select>
                                   </span>
                            <span>
                                        <label onclick='cls_XlsImportDocumentEntry.getInstance("{$MODULE}").deleteimportdupfieldtr(ld(this),"dv_detail_dupcondition")'
                                               class='icon-homeimg icon-sdel popupselectdiv'
                                               style='margin-top:2px;cursor:pointer;'></label>
                                    </span>
                        </div>
                    {/foreach}
                </div>
                <div>
                    <input type="button" class="editauto addConditionRow" value="{'NEWCONDITIONS'|@getFixedLabel}"
                           onclick="cls_XlsImportDocumentEntry.getInstance('{$MODULE}').btn_add_detailnewcondition()"/>
                </div>
            </div>
        </div>

        <div class="pop_item">
            <span>3. {$ARRLABEL.productnotexistsmethod_label}：</span>
            <div class="pop_item_content">
            {assign var='createpermit' value="Products"|@isPermitted:"Create"}
                <div>
                       <span>
                            <select class="ld-select-inner gwidth30 mr50" name="product_import_type">
                                <option value="NoImportRow"  selected="selected">{'Ignoretheproducts'|@getFixedLabel}</option>
                                {if $createpermit eq 'yes' || $IS_ADMIN}
                                    {*zkt 20230608  XUQIU1001520 带产品分录的表单，“导入明细”弹出层“设置产品不存在时导入方式”增加“自动添加新产品”选项*}
                                    <option value="AddProduct">{'Automaticallyaddproducts'|@getFixedlabel}</option>
                                {/if}
                            </select>
                        </span>
                </div>
            </div>
        </div>
        <div class="pop_item">
            <span>4.{'IMPORTCONTROL'|@getFixedLabel}</span>
            <div class="pop_item_content">
                <span>{'CHECKPICKLIST'|@getFixedLabel}</span>
                <input type="checkbox" name="checkPicklist" id="checkPicklist" value="" tag="details" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_control_checkpicklist(this)"{if $checkPicklist neq 'no'} checked="" {/if} class="second_switch" style="margin-bottom:3px;margin-left: 200px;">
                <span> <a {if $checkPicklist eq 'no'} style="display:none" {/if} href="javascript:void(0)" name="setPicklistColumn" id="setPicklistColumn" tag="details" onclick="cls_XlsImportNew.getInstance('{$MODULE}').btn_control_setpicklistcolumn(this)" >{'CHECKPICKLISTCOLUMN'|@getFixedLabel}</a> </span>
            </div>
        </div>

        <div class="pop_item">
            <span>5. {'USESYSIMPORTFILE'|@getFixedLabel}</span>
            <div class="pop_item_content">
                <div class="fileinput-box">
                    <span class="fileinput-button">{'ADDFILE'|@getFixedLabel}<input name="xls_file_upload"
                                                                                    class="fileinput-input" type="file"
                                                                                    title="选择文件"
                                                                                    onchange="cls_XlsImportDocumentEntry.getInstance('{$MODULE}').uploadxls()"/></span>
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
  