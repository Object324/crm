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

<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/showDocTemplateindex.js?v={$GLOBALMINVERSION}"></script>
<form  name="massdelete" method="POST" onsubmit="puyoungJS_DialogBox.block();">
<input name="idlist" type="hidden"/>
<input name="module" type="hidden" value="Documents"/>
<input id="documentsmodulelabel" name="documentsmodulelabel" type="hidden" value="{$DOCUMNETSMODULELABEL}"/>
<input name="action" type="hidden" value="deleteemailtemplate"/>
<input name="allselectedboxes" type="hidden"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'THEDOCUMENTTEMPLATE'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="Createdocumenttemplate()" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
          <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable fir-center" name="docModuleTable" style="table-layout: fixed;">
            <tr>
              <th>#</th>
              <th width="250" align="left" align="left" title="{'TEMPLATENAME'|@getFixedLabel}">{'TEMPLATENAME'|@getFixedLabel}</th>
              <th align="left" align="left" title="{'DESCRIPTION'|@getFixedLabel}">{'DESCRIPTION'|@getFixedLabel}</th>
              <th width="115">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            {if $TEMPLATES|@count gte 1}
              {assign var="i" value=0}
              {foreach name=emailtemplate item=template from=$TEMPLATES}
              {assign var="j" value=$i++}
              {if $j mod 2 eq '0'}
                  <tr id="setting_{$j}" templateid="{$template.templateid}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              {else}
                  <tr id="setting_{$j}" templateid="{$template.templateid}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              {/if}   
                <td class="Blackbj">{$smarty.foreach.emailtemplate.iteration}</td>                    
                <td> 
                  <a href="javascript:;" onclick="detaildocumenttemplate({$template.templateid})" ><span title="{$template.templatename}">{$template.templatename}</span></a>
                </td>
                <td><span title="{$template.description}" class="attachments-padL11">{$template.description}</span>&nbsp;</td>
                <td>
                  <a class="Anu3_a" href="javascript:;" onclick="editdocumenttemplate({$template.templateid})">{'EDIT'|@getFixedLabel}</a>
                  <a class="Anu3_a redFont" href="javascript:void(0);" onclick="deletedocumenttemplate({$template.templateid})">{'DELETE'|@getFixedLabel}</a>
                  <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:2px"></a>
                </td>
              </tr>
              {/foreach}
            {else}
              <tr class="lvtColData">
                <td colspan="4" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
              </tr>
            {/if}
          </table>
        </div>
    </div>
</div>
</form>
<script>
    //拖拽排序 weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序）
    function docModuleMovetable(){
        ld('[name=docModuleTable] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=docModuleTable]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sortfield_arr='';
                var fieldid = '';
                var tabid='';
                tableobj = ld('table[name=docModuleTable]').find("tr");
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
                            ld(tmpobj.childNodes[1]).html(index);
                            fieldid=ld(tmpobj).attr('templateid');
                            sortfield_arr+=fieldid+",";
                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            fieldid=ld(tmpobj).attr('templateid');
                            sortfield_arr+=fieldid+",";
                        }
                        console.log(sortfield_arr)
                    }
                });
                if (sortfield_arr != '') {
                    var update_url = 'index.php?module=Documents&action=DocumentsAjax&file=showindex&type=savedocModuleTableSort&ajax=true&tagids=' + sortfield_arr;
                    ldAjax(update_url, '', function (data) {
                        if (data.code == 1) {
                            DelProgressObjs();
                        }
                    })
                }
            }

        })
    }
    docModuleMovetable();
</script>