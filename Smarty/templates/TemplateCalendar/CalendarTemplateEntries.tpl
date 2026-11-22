{* creator:gyq_13 reason:日程模板列表内容 date:20160613 *}
<input type="hidden" id="modulename" name="modulename" value="{$MODULENAME}">
<input type="hidden" id="fieldidsetting" name="fieldidsetting" value="{$FIELDIDSETTING}">
<input type="hidden" id="blockidsetting" name="blockidsetting" value="{$blockidsetting}">

<table class="settingTable fir-center" border=0 cellspacing=0 cellpadding=0 width=100% name="scheduleTemplateTable">
    <tr>
      	<th>#</th>
        <th title="{'TEMPLATENAME'|@getFixedLabel}">{'TEMPLATENAME'|@getFixedLabel}</th>
        <th title="{'DESCRIPTION'|@getFixedLabel}">{'DESCRIPTION'|@getFixedLabel}</th>
        <th title="{'APPLICABLESCOPE'|@getFixedLabel}">{'APPLICABLESCOPE'|@getFixedLabel}</th>
        <th width="100" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        {if $LANGUAGETYPE eq 'en'}
        <th width="190">{'OPERATING'|@getFixedLabel}</th>
        {else}
        <th width="160">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
    {if $APPROVE|@count gte 1}
        {assign var="i" value=0}
        {foreach key=value item=approve from=$APPROVE}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" tagid="{$approve.templateid}" tabid="{$approve.tabid}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" tagid="{$approve.templateid}" tabid="{$approve.tabid}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
        	<td>{$value+1}</td>
            <td><a href="javascript:;" onclick="TemplateCalendar.getInstance().addNewCalendar({$approve.tabid},{$approve.templateid})"><span title="{$approve.templatename}">{$approve.templatename}</span></a></td>
         	<td><span title="{$approve.description}">{$approve.description}</span></td>
            <td><span title="{$approve.allocatetypenameLink}">{$approve.allocatetypenameLink}</span></td>
            <td>
            {if $approve.status eq 'open'}
                <input type="checkbox" onclick="TemplateCalendar.getInstance().changestatusTemplate({$approve.templateid},{$approve.tabid},this.checked,'{$BLOCKID}','{$blockidsetting}','{$FIELDIDSETTING}')" class="second_switch"  checked="" />
            {else}
                <input type="checkbox" onclick="TemplateCalendar.getInstance().changestatusTemplate({$approve.templateid},{$approve.tabid},this.checked,'{$BLOCKID}','{$blockidsetting}','{$FIELDIDSETTING}')" class="second_switch"  />
            {/if}
            </td>
            <td>
                <a class="Anu3_a" href="javascript:void(0);" onclick="TemplateCalendar.getInstance().addNewCalendar({$approve.tabid},{$approve.templateid})">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" title="{'ALLOCATE'|@getFixedLabel} {'APPLICABLESCOPE'|@getFixedLabel}" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,'{$approve.tabid}','{$approve.templateid}','{$approve.allocatetypeidLink}','{$approve.allocatetype}','CalendarTemplate');">{'ALLOCATE'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" href="javascript:void(0);" onclick="TemplateCalendar.getInstance().deleteTemplate({$approve.templateid},{$approve.tabid},'{$blockidsetting}','{$FIELDIDSETTING}')">{'DELETE'|@getFixedLabel}</a>
                <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display: none; cursor:move;margin-top:2px"></a>
            </td>
        </tr>
        {/foreach}
    {else}
        <tr class="lvtColData">
            <td colspan="6" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
        </tr>
    {/if}
</table>
<script>
    //拖拽排序 weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序 后台设置--模板设置-日程模板定制
    function approvalProcessMovetable(){
        ld('[name=scheduleTemplateTable] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=scheduleTemplateTable]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sortfield_arr='';
                var fieldid = '';
                var tabid='';
                tableobj = ld('table[name=scheduleTemplateTable]').find("tr");
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
                            tabid=ld(tmpobj).attr('tabid');
                            fieldid=ld(tmpobj).attr('tagid');
                            sortfield_arr+=fieldid+",";
                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            tabid=ld(tmpobj).attr('tabid');
                            fieldid=ld(tmpobj).attr('tagid');
                            sortfield_arr+=fieldid+",";
                        }
                    }
                });
                if (sortfield_arr != '') {

                    var update_url = 'index.php?module=Settings&parenttab=Settings&action=SettingsAjax&file=CalendarTemplate&type=saveScheduleTemplateSort&ajax=true&tagids=' + sortfield_arr + '&tabid=' + tabid;
                    ldAjax(update_url, '', function (data) {
                        if (data.code == 1) {
                            DelProgressObjs();
                        }
                    })
                }
            }

        })
    }
    approvalProcessMovetable();
</script>