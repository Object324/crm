<table class="settingTable fir-center" id="approvelisttable" border=0 cellspacing=0 cellpadding=0 width="100%" name="approvalProcessTable">
  <tr style="position: sticky;top: 0px;z-index: 1;">
    <th>#</th>
    <th title="{'PROCESSNAME'|@getFixedLabel}">{'PROCESSNAME'|@getFixedLabel}</th>
    <!-- <th width="150" title="{'DESCRIPTION'|@getFixedLabel}">{'DESCRIPTION'|@getFixedLabel}</th> -->
    <th width="150" title="{'APPLICABLESCOPE'|@getFixedLabel}">{'APPLICABLESCOPE'|@getFixedLabel}</th>
    <th width="80" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
    <th width="100" title="{'APPROVEDEFAULTVALUEONNEW'|@getFixedLabel}">{'APPROVEDEFAULTVALUEONNEWMINI'|@getFixedLabel}</th>
    <th width="100" title="{'APPROVEDEFAULTVALUEONSUBMIT'|@getFixedLabel}">{'APPROVEDEFAULTVALUEONSUBMITMINI'|@getFixedLabel}</th>
    {if $LANGUAGETYPE eq 'en'}
    <th width="240">{'OPERATING'|@getFixedLabel}</th>
    {else}
    <th width="200">{'OPERATING'|@getFixedLabel}</th>
    {/if}
  </tr>
  {if $APPROVE|@count gte 1}
    {assign var="i" value=0}
    {foreach key=value item=approve from=$APPROVE}
        {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
          <tr id="setting_{$i}" tagid="{$approve.id}" tabid="{$approve.tabid}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        {else}
          <tr id="setting_{$i}" tagid="{$approve.id}" tabid="{$approve.tabid}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        {/if}   
        <td>{$value+1}</td>
        {if $approve.isnewapprove eq 'yes'}
        <td><a href="javascript:;" approveid='{$approve.id}' approvetabid='{$approve.tabid}' onclick="getEditNewApprove({$approve.id},{$approve.tabid},'{$approve.name}');"><span title="{$approve.name}">{$approve.name}</span></a></td>
        {else}
        <td><a href="javascript:;" approveid='{$approve.id}' approvetabid='{$approve.tabid}' onclick="viewApprove(ld(this),event)"><span title="{$approve.name}">{$approve.name}</span></a></td>
        {/if}
        <td>{$approve.allocatetypenameLink}</td>
        <td>
            <input type="checkbox" columnname="status" onclick="changeApproveStatus(this,{$approve.id},{$approve.tabid})" class="second_switch" 
            {if $approve.status eq 0}checked=""{/if} />
        </td>
        {*editor:gyq_132 reason:审批流程默认值改进，增加default_on_new,default_on_submit  2019/7/22 15:26 ID1000479*}
        <td>
            <input type="checkbox" columnname="default_on_new" onclick="changeApproveStatus(this,{$approve.id},{$approve.tabid})" class="second_switch" 
            {if $approve.default_on_new eq 'yes'}checked=""{/if} />
        </td>
        <td>
            <input type="checkbox" columnname="default_on_submit" onclick="changeApproveStatus(this,{$approve.id},{$approve.tabid})" class="second_switch" 
            {if $approve.default_on_submit eq 'yes'}checked=""{/if} />
        </td>
        <td>
            <a class="Anu3_a" href="javascript:;" approveid='{$approve.id}' approvetabid='{$approve.tabid}' onclick="viewApprove(ld(this),event)" style="display:none">{'editingsteps'|@getFixedLabel}</a>
            {if $approve.isnewapprove eq 'yes'}
              <a class="Anu3_a" href="javascript:void(0);" onclick="getEditNewApprove({$approve.id},{$approve.tabid},'{$approve.name}');">{'EDIT'|@getFixedLabel}</a>
            {else}
            <a class="Anu3_a" href="javascript:void(0);" onclick="getEditApproveForm('',{$approve.id},{$approve.tabid},'{$approve.name}');">{'EDIT'|@getFixedLabel}</a>
            {/if}
            {if $approve.isnewapprove eq 'yes'}
              <a class="Anu3_a" href="javascript:void(0);" onclick="CopyNewApprove({$approve.id},{$approve.tabid},'{$approve.name}');">{'COPY'|@getFixedLabel}</a>
            {else}
            <a class="Anu3_a" href="javascript:void(0);" onclick="CopyApproveForm('',{$approve.id},{$approve.tabid},'{$approve.name}');">{'COPY'|@getFixedLabel}</a>
            {/if}
            <a class="Anu3_a redFont" href="javascript:void(0);" onclick="deleteApprove({$approve.id},{$approve.tabid})">{'DELETE'|@getFixedLabel}</a>
            <a class="Anu3_a" href="javascript:void(0);" title="{'ALLOCATE'|@getFixedLabel} {'APPLICABLESCOPE'|@getFixedLabel}" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,'{$approve.tabid}','{$approve.id}','{$approve.allocatetypeidLink}','{$approve.approveallocatetype}','MultiApproveList');">{'ALLOCATE'|@getFixedLabel}</a>
            <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:0px"></a>
        </td>
    </tr>
    {/foreach}
  {else}
    <tr class="lvtColData">
      <td colspan="8" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
    </tr>
  {/if}
</table>
<script>
    //拖拽排序 weiyannan 20231121 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序）后台设置--系统定制-审批流程定制
    function approvalProcessMovetable(){
        ld('[name=approvalProcessTable] tr').hover(function(){
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld("table[name=approvalProcessTable]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sortfield_arr='';
                var fieldid = '';
                var tabid='';
                tableobj = ld('table[name=approvalProcessTable]').find("tr");
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
                    var update_url = 'index.php?module=Settings&action=SettingsAjax&file=MultiApproveList&type=saveApprovalProcessSort&ajax=true&tagids=' + sortfield_arr + '&tabid=' + tabid;
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