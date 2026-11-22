<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center" name="printModulesTable">
  <tr>
    <th>#</th>
    {foreach key=index item=HEADERLABEL from=$LIST_HEADER}
      <th {$LIST_HEADER_STYLE[$index]} title="{$HEADERLABEL}">{$HEADERLABEL}</th>
    {/foreach}
    {if $LANGUAGETYPE eq 'en'}
    <th width="180px">{'OPERATING'|@getFixedLabel}</th>
    {else}
    <th width="160px">{'OPERATING'|@getFixedLabel}</th>
    {/if}
  </tr>
  {if $LIST_ENTRIES|@count gte 1}
    {assign var="i" value=0}
    {foreach name=printlist item=printvalues from=$LIST_ENTRIES}
      {assign var="printlistNum" value=$smarty.foreach.printlist.iteration }
      {assign var="j" value=$i++}
      {if $j mod 2 eq '0'}
        <tr id="setting_{$j}" tagid="{$printvalues.printid}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
      {else}
        <tr id="setting_{$j}" tagid="{$printvalues.printid}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
      {/if}   
        <td>{$printlistNum}</td>
        <td>
          <a href="javascript:;" onclick="TemplateprintList.view({$printvalues.printid})"><span title="{$printvalues.printname}">{$printvalues.printname}</span></a>
        </td>
        <td>
          {$printvalues.lastname}
        </td>
        <td>
          {$printvalues.templatetype}
        </td>
        <td>
            {if $printvalues.isdefault eq 1}
                <input type="checkbox" onclick="change_tablefield_presence(this,{$printvalues.printid},'templateprint_isdefault')" class="second_switch"  checked="" />
            {else}
                <input type="checkbox" onclick="change_tablefield_presence(this,{$printvalues.printid},'templateprint_isdefault')" class="second_switch"  />
            {/if}
        </td>
        <td>
            {if $printvalues.approvedallowprint eq 'yes'}
                <input type="checkbox" onclick="change_tablefield_presence(this,{$printvalues.printid},'templateprint_approvedallowprint')" class="second_switch"  checked="" />
            {else}
                <input type="checkbox" onclick="change_tablefield_presence(this,{$printvalues.printid},'templateprint_approvedallowprint')" class="second_switch"  />
            {/if}
        </td>
        <td>
          {$printvalues.modifiedby}
        </td>
        <td>
          {$printvalues.modifiedtime}
        </td>
        <td>
          <a class="Anu3_a" href="javascript:;" onclick="TemplateprintList.edit({$printvalues.printid})">{'EDIT'|@getFixedLabel}</a>  
          <a class="Anu3_a" href="javascript:;" title="{'ALLOCATE'|@getFixedLabel} {'APPLICABLEPERSONNEL'|@getFixedLabel}" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,'{$PRINTTABID}','{$printvalues.printid}','{$printvalues.allocateids}','{$printvalues.allocatetype}','TemplateprintList');">{'ALLOCATE'|@getFixedLabel}</a>
          <a class="Anu3_a redFont" href="javascript:;" onclick="TemplateprintList.deletetemplateprint(this,'{$printvalues.printid}');">{'DELETE'|@getFixedLabel}</a>
          <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:2px"></a>
        </td>
      </tr>
    {/foreach}
  {else}
    <tr class="lvtColData">
      <td colspan="9" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
    </tr>
  {/if}
</table>

<script>
    //拖拽排序 weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序）后台设置--模板设置-打印模板定制
    function printModulesMovetable(){
        ld('[name=printModulesTable] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=printModulesTable]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sortfield_arr='';
                var fieldid = '';
                var tabid='';
                tableobj = ld('table[name=printModulesTable]').find("tr");
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
                            fieldid=ld(tmpobj).attr('tagid');
                            sortfield_arr+=fieldid+",";
                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            fieldid=ld(tmpobj).attr('tagid');
                            sortfield_arr+=fieldid+",";
                        }
                        console.log(sortfield_arr)

                    }
                });
                if (sortfield_arr != '') {
                    var update_url = 'index.php?module=Settings&action=SettingsAjax&file=TemplateprintList&type=saveprintModulesSort&ajax=true&tagids=' + sortfield_arr;
                    ldAjax(update_url, '', function (data) {
                        if (data.code == 1) {
                            DelProgressObjs();
                        }
                    })
                }
            }

        })
    }
    printModulesMovetable();
</script>