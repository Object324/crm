{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/WorkTemplate.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="autotaskform" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="setype"/>
<input type="hidden" name="record" value="{$RECORD}"/>
<input type="hidden" name="maxindex"/>
<input type="hidden" name="groupcond"/>
<input type="hidden" name="fld_tabid" value="{$FLD_TABID}"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_WORK_TEMPLATE'|@getFixedLabel}{if $HelpHtml.WorkTemplate neq '' }{$HelpHtml.WorkTemplate}{/if}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'WorkReportSelectType'|@getFixedLabel}</span>
        <select fieldtype="select" name="type" id="type" onchange="WorkTemplate.selectChange(this);" class="btn-radius-system width150">
        {foreach key=key item=entity from=$TYPEARRAY.$ENTITYTYPE.tag}
			{if $key eq $TYPE}
				{assign var="tabselected" value="selected"}
			{else}
				{assign var="tabselected" value=""}
			{/if}
			<option value="{$key}" {$tabselected}>{$entity.label}</option>
        {/foreach}
        </select>
        <span class="ld-fonticon ld-fonticon-set" onclick="WorkTemplate.setWorkReportShow()" title="{'SETTINGS'|@getFixedLabel}"></span>
    </div>

    <div class="grid_tool">
        <div class="displayflex">
        	<input type="hidden" name="entitytype" id="entitytype" value="{$ENTITYTYPE}"/>
            <a href="javascript:;" class="ld-button ld-button-primary" name="WorkTemplate_create" onclick="WorkTemplate.create();" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" name="WorkTemplate_rulesettings" onclick="WorkTemplate.showWorkReportRule()"  title="{'RULESETTINGS'|@getFixedLabel}">{'RULESETTINGS'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
          {if $SETYPE eq 'list'}
    				{include file='Settings/WorkTemplateContents.tpl'}
    			{/if}
        </div>
    </div>
</div>
</form>

<script type="text/javascript">
var userdefinedfields = '{"LBL_WORK_TEMPLATE"|@getFixedLabel}';
var lbl_fieldname = '{"LBL_FIELDNAME"|@getFixedLabel}';
var lbl_defaultvalue = '{"LBL_DEFAULTVALUE"|@getFixedLabel}';
var lbl_defaultheight = '{"LBL_DEFAULTHEIGHT"|@getFixedLabel}';
var lbl_mandatoryfields = '{"LBL_MANDATORYFIELDS"|@getFixedLabel}';
var lbl_activate = '{"WHETHERTOENABLE"|@getFixedLabel}';
var defheightopts = '{$DEFHEIGHTOPTS}';
var issubmit = 1;
//拖拽排序 weiyannan 20231120 BUG0075320 工作汇报
function WorkTemplatemovetable(){
    ld('[name=workReportTable] tr').hover(function(){
        ld('.ld-dragicon').hide();
        ld(this).find('.ld-dragicon').show();
    });
    var dragobj = ld("table[name=workReportTable]").find("tbody").get(0);
    Sortable.create(dragobj, {
        // group: 'SelfServiceConfig',
        // animation: 150,
        draggable: ".ld-category-draggable",
        handle: ".drag-handle",
        onEnd: function (evt){
            var sortfield_arr='';
            var fieldid = '';
            tableobj = ld('table[name=workReportTable]').find("tr");
            tableobj.attr('onmouseover','');
            tableobj.attr('onmouseout','');
            tableobj.removeClass('lvtColData');
            tableobj.removeClass('lvtColDataBj');
            tableobj.removeClass('lvtColDataHover');
            ld.each(tableobj,function(index,tmpobj){
                if(index>0){
                    if(index%2==0){
                        ld(tmpobj).addClass('lvtColDataBj');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                        ld(tmpobj.childNodes[0]).html(index);
                        fieldid=ld(tmpobj).attr('tagid');
                        sortfield_arr+=fieldid+",";
                    }else{
                        ld(tmpobj).addClass('lvtColData');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                        ld(tmpobj.childNodes[0]).html(index);
                        fieldid=ld(tmpobj).attr('tagid');
                        sortfield_arr+=fieldid+",";
                    }
                }
            });
            if (sortfield_arr != '') {
                var update_url = 'index.php?module=Settings&action=SettingsAjax&file=WorkTemplate&type=saveWorkReportModuleSort&ajax=true&tagids=' + sortfield_arr;
                ldAjax(update_url, '', function (data) {
                    if (data.code == 1) {
                        DelProgressObjs();
                    }
                })
            }
        }

    })
}
WorkTemplatemovetable();
</script>
