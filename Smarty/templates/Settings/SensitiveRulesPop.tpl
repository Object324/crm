{*敏感规则新增编辑弹出层*}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/cls_validatacondition.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/select2.min.js"></script><!--多选框-->
<table class="DetailContentTable" cellspacing="1" cellpadding="0" border="0" width="100%" style="table-layout: fixed;">

    <tr>
        <td class="ld-form-item-label" style="width:18%;">
            <font color="red">*</font>{'RULENAME'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" colspan="2" style="padding-right: 50px;">
            <input type="text" name="rulename" value="{$sensitivename}" class="ld-input-inner">
        </td>
    </tr>

    <tr>
        <td class="ld-form-item-label" style="">
            <font color="red">*</font>{'RULETYPE'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" style="width:30%">
            <select class="ld-select-inner commonSelectPop" name="ruletype" onclick="SensitiveRules.getInstance().changeruletype()" style="width: 150px;">
                <option value="allencrypted" {if $ruletype eq 'allencrypted'}selected{/if}>{'SensitiveAllEncrypted'|@getFixedLabel}</option>
                <option value="noneditable" {if $ruletype eq 'noneditable'}selected{/if}>{'SensitiveNonEditable'|@getFixedLabel}</option>
            </select>
        </td>

        <td class="ld-form-item-label" style="width:20%;">
            {'WHETHERTOENABLE'|@getFixedLabel}
            <input name="rulestatus" {if $rulestatus eq 'yes'}checked=""{/if} type="checkbox" class="second_switch" style="margin-left: 5px;">
        </td>
    </tr>
    <tr id="encrypty_way_tr"">
        <td class="ld-form-item-label" style="">
            <font color="red">*</font>{'EncryptionMethod'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" style="width:30%;">
            <div style="display: flex">
                <select class="ld-select-inner commonSelectPop" name="encrypty_way" onclick="SensitiveRules.getInstance().changeencrypty()" style="width: 150px;">
                    {foreach key=value item=encryptyway_label from=$encryptycontent}
                        <option value="{$value}" {if $encryptyway eq $value}selected{/if}>{$encryptyway_label}</option>
                    {/foreach}
                </select>
                <div class="encrypty_num" style="line-height: 32px;display: none;align-items: center;margin-left: 10px;{if $encryptyway neq 'all' && $encryptyway neq ''}display:flex;{/if}">
                    <span name="encrypty_started" style="display: flex;align-items: center;{if $encryptyway eq 'right'}display:none;{/if}">
                        <a class="ld-sensitiverule-leftbutton" href="javascript:;" onclick="SensitiveRules.getInstance().decrement('left')">-</a>
                        <input class="detailedViewTextBox" type="text" id="leftBox" name="sensitiverule_leftBox" value="{$started}" oninput="SensitiveRules.getInstance().updateValue('left')" style="text-align:center;width: 40px;border-radius: 0px;" onkeyup="value=value.replace(/[^0-9]/g,'')" onblur="systemSetBlur(this)">
                        <a class="ld-sensitiverule-rightbutton" href="javascript:;" onclick="SensitiveRules.getInstance().increment('left')">+</a>
                    </span>
                        <span style="font-size: 20px;{if $encryptyway neq 'part'}display:none{/if}" name="encrypty_middle"> ~ </span>
                        <span name="encrypty_end" style="display: flex;align-items: center;{if $encryptyway eq 'left'}display:none;{/if}">
                        <a class="ld-sensitiverule-leftbutton" href="javascript:;" onclick="SensitiveRules.getInstance().decrement('right')">-</a>
                        <input class="detailedViewTextBox" type="text" id="rightBox" name="sensitiverule_rightBox" value="{$end}" oninput="SensitiveRules.getInstance().updateValue('right')" style="text-align:center;width: 40px;border-radius: 0px;" onkeyup="value=value.replace(/[^0-9]/g,'')" onblur="systemSetBlur(this)">
                        <a class="ld-sensitiverule-rightbutton" href="javascript:;" onclick="SensitiveRules.getInstance().increment('right')">+</a>
                    </span>
                </div>
            </div>
        </td>
        <td class="ld-form-item-label" style="width:30%;">
        </td>
    </tr>
    <tr name="disabledscene_tr" id="disabledscene_tr" >
        <td class="ld-form-item-label" >
            {'DisabledScene'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" colspan="2" style="padding-right: 50px;">
            <select multiple="multiple" name="disabledscene" id="disabledscene" class="ld-input-inner select2 select2-offscreen select2-hidden-accessible" style="width:100%;" >
                <option value="ModuleListView">{'ModuleListView'|@getFixedLabel}</option>
                <option value="DetailView">{'DocumentDetailView'|@getFixedLabel}</option>
                <option value="RelatedModuleListView">{'RelatedModuleListView'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>

</table>
<div class="DivCName DivCNamehover">{'SensitiveConditions'|@getFixedLabel}
    <select class="ld-select-inner commonSelectPop" style="margin-left: 5px;width: 200px;" name="effectivemethod">
        {foreach key=value item=effectivemethod_label from=$effectivemethod_content}
            <option value="{$value}" {if $effectivemethod eq $value}selected{/if}>{$effectivemethod_label}</option>
        {/foreach}
    </select>
    <div style="float: right;"><input type="button" class="ld-button ld-button-primary" style="margin-right: 10px;"
        value="{'NEWCOMBINATION'|@getFixedLabel}"
        onclick="cls_validatacondition.getInstance().New_addNewConditionGroup();">
    </div>
</div>
<div name="sensitiveadvance" id="sensitiveadvance">
    <table class="settingPopTable NewApprovePopTable" cellspacing="1" cellpadding="0" border="0" width="100%">
        <tr>
            <td style="width: 13%;text-align:center"></td>
            <td style="width: 25%;text-align:center" tagname="selectfield">{'Select_field'|@getFixedLabel}</td>
            <td style="width: 15%;text-align:center">{'ComparatorRelationShip'|@getFixedLabel}</td>


            <td style="width: 13%;text-align:center"></td>
            <td style="width: 25%;text-align:center" tagname="comparefield">{'CompareFields'|@getFixedLabel}</td>
            <td style="width: 6%;text-align:center"></td>
            <td style="width: 3%;text-align:center"></td>
        </tr>

    </table>
</div>
<div>
    <div name="showsqlwildcard" style="line-height: 26px;"><b id="showsqlwildcard" style="margin:0 5px;" data-status="hidden"
            data-childid="sqlwildcard" onclick="" title="{'EXPANDCOLLAPSE'|@getFixedLabel}"
            class="icon-homeimg icon-askgrey-help"></b>{'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}</div>
    <div id="sqlwildcard" style="padding:5px;display: none;">
        <div style="line-height: 22px;">
            1.{'CURRENTDOCUMENTFIELDS'|@getFixedLabel}:{ldelim}tablename.fieldname{rdelim},{'ONLYDOCUMENTHEADERFIELD'|@getFixedLabel}
        </div>
        <div style="line-height: 22px;">
            2.{'CURRENTDOCUMENTID'|@getFixedLabel}:{ldelim}Record.ID{rdelim},{'NOVALUEWHENCREATING'|@getFixedLabel}
        </div>
        <div style="line-height: 22px;">3.{'CURROPERATOR'|@getFixedLabel}:{ldelim}uuid{rdelim}</div>
        <div style="line-height: 22px;">4.{'QUERYRESULTRENAMED'|@getFixedLabel}</div>
        <div style="line-height: 22px;">5.{'PRODUCTSENTRYFIELD'|@getFixedLabel}</div>
    </div>
</div>
<style>
    .ld-sensitiverule-leftbutton{
        width: 25px;
        height: 25px;
        background-color: white;
        border: 1px solid #ccc;
        border-radius: 5px 0px 0px 5px;
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        font-size: 16px;
        color: #333 !important;
    }
    .ld-sensitiverule-rightbutton{
        width: 25px;
        height: 25px;
        background-color: white;
        border: 1px solid #ccc;
        border-radius: 0px 5px 5px 0px;
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        font-size: 16px;
        color: #333 !important;
    }
</style>
