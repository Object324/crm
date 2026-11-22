<div class="searchResrlt_title"></div>
<ul class="customview_oplist_cv_ul">
    {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq 'ALL'}
        {if $CUSTOMVIEW_OPTION|@count eq 0}
            <li style="width: 100%;text-align: center; padding-top: 85px; cursor:default;" name="nocontent">
                <div class="listview_group_drawer_content_no">
                    <div class="listview_group_drawer_content_list_img"></div>
                    <div class="listview_group_drawer_content_list_tips">{'NOCONTENT'|@getFixedLabel}</div>
                </div>
            </li>
        {/if}
        {assign var="custom_info" value=$CUSTOMVIEWGROUPLIST['cv_all']}
        {if $custom_info.popup eq 'popup'}
            <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if} customview_oplist_cv_li" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" data-customlabel="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" onclick="showDefaultCustomViewPopup(this,'{$CUSTOMVIEWGROUPLIST['cv_all'].module}','','{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}')" >{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}</li>
            {assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
        {elseif $CUSTOMVIEWGROUPLIST['cv_all'].popup eq 'relatedleft'}
            <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" relateTag="{$custom_module}" relatedid="{$CUSTOMVIEWGROUPLIST['cv_all'].relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))">{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}</li>
            {assign var="j" value=$j+1}
        {else}
            <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}" relatetag="{$CUSTOMVIEWGROUPLIST['cv_all'].module}" tag="{$k}" style="position:relative;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" data-customlabel="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" onclick="showDefaultCustomView(this,'{$CUSTOMVIEWGROUPLIST['cv_all'].module}','','{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}')">
                {$CUSTOMVIEWGROUPLIST['cv_all'].viewname}
                <div class="customview_oplist_cv_li_btn">
                    {if $CUSTOMVIEWGROUPLIST['cv_all'].edit_permit eq 'yes'}
                        <a class="4" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})" class="sort-tip-items" data-tip="{'EDITCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-edit lineheight42"></i></a>
                    {/if}
                    {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                        <a class="4" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})" class="sort-tip-items" data-tip="{'COPYCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-copy lineheight42"></i></a>
                    {/if}
                    {if $CUSTOMVIEWGROUPLIST['cv_all'].del_permit eq 'yes' && $CUSTOMVIEWGROUPLIST['cv_all'].viewnamedata neq 'All'}
                        <a class="4" onclick="event.stopPropagation(); DataCategoryListPopup.delVal(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})" class="sort-tip-items" data-tip="{'DeleteCategory'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-del lineheight42"></i></a>
                    {/if}
                    <a class="4" onclick="event.stopPropagation(); DataCategoryListPopup.addToCommon(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})"  {if $CUSTOMVIEWGROUPLIST['cv_all'].isCommon eq 'no'} class="sort-tip-items" data-tip="{'ADDTOCOMMON'|@getFixedLabel}" data-direction="top" data-type="position" {else}class="sort-tip-items" data-tip="{'UNCOLLET'|@getFixedLabel}" data-direction="top" data-type="position" {/if}><b class="ld-category-icon {if $CUSTOMVIEWGROUPLIST['cv_all'].isCommon eq 'no'}ld-category-addToCommon{else}ld-category-deleteFromCommon{/if}"></b></a>
                </div>
            </li>
            {assign var="k" value=$k+1}
        {/if}
        {foreach key=groupId item=customGroup_info from=$CUSTOMVIEWGROUPLIST['groupList']}
            {if $customGroup_info.cvCount neq 0}
            {if $customGroup_info.groupid neq 'commonCustomView'}
                <li class="customview_all_group">
                    <div class="customview_all_group_title">
                        <div class="customview_all_group_title_container"></div>
                        <div class="customview_all_group_title_container_container">{$customGroup_info.group_name}</div>
                    </div>
                    <ul>
                        {foreach key=User_Key item=custom_info from=$customGroup_info.cvList}
                            {if $custom_info.popup eq 'popup'}
                                <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomViewPopup(this,'{$custom_info.module}','','{$custom_info.cvid}')" >{$custom_info.viewname}</li>
                                {assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
                            {elseif $custom_info.popup eq 'relatedleft'}
                                <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$custom_info.cvid}" title="{$custom_info.viewname}" relateTag="{$custom_module}" relatedid="{$custom_info.relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))">{$custom_info.viewname}</li>
                                {assign var="j" value=$j+1}
                            {else}
                            <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$custom_info.cvid}" relatetag="{$custom_info.module}" tag="{$k}" style="position:relative;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomView(this,'{$custom_info.module}','','{$custom_info.cvid}')">
                                {$custom_info.viewname}
                                <div class="customview_oplist_cv_li_btn">
                                    {if $custom_info.edit_permit eq 'yes'}
                                        <a class="5" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'EDITCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-edit lineheight42"></i></a>
                                    {/if}
                                    {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                        <a class="5" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'COPYCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-copy lineheight42"></i></a>
                                    {/if}
                                    {if $custom_info.del_permit eq 'yes' && $custom_info.viewnamedata neq 'All'}
                                        <a class="5" onclick="event.stopPropagation(); DataCategoryListPopup.delVal(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'DeleteCategory'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-del lineheight42"></i></a>
                                    {/if}
                                    <a class="5" onclick="event.stopPropagation(); DataCategoryListPopup.addToCommon(this,{$custom_info.cvid})"  {if $custom_info.isCommon eq 'no'} class="sort-tip-items" data-tip="{'ADDTOCOMMON'|@getFixedLabel}" data-direction="top" data-type="position" {else}class="sort-tip-items" data-tip="{'UNCOLLET'|@getFixedLabel}" data-direction="top" data-type="position" {/if}><b class="ld-category-icon {if $custom_info.isCommon eq 'no'}ld-category-addToCommon{else}ld-category-deleteFromCommon{/if}"></b></a>
                                </div>
                            </li>
                            {assign var="k" value=$k+1}
                            {/if}
                        {/foreach}
                    </ul>
                </li>
            {/if}
            {/if}
        {/foreach}
    {else}
        {foreach key=User_Key item=group_info from=$CUSTOMVIEWGROUPLIST['groupList']}
            {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq $group_info['groupid']}
                {if $group_info['cvList']|@count eq 0}
                    <li style="width: 100%;text-align: center; padding-top: 85px; cursor:default;" name="nocontent">
                        <div class="listview_group_drawer_content_no">
                            <div class="listview_group_drawer_content_list_img"></div>
                            <div class="listview_group_drawer_content_list_tips">{'NOCONTENT'|@getFixedLabel}</div>
                        </div>
                    </li>
                {/if}
                {foreach key=User_Key item=custom_info from=$group_info['cvList']}
                    {if $custom_info.popup eq 'popup'}
                        <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomViewPopup(this,'{$custom_info.module}','','{$custom_info.cvid}')" >{$custom_info.viewname}</li>
                        {assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
                    {elseif $custom_info.popup eq 'relatedleft'}
                        <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$custom_info.cvid}" title="{$custom_info.viewname}" relateTag="{$custom_module}" relatedid="{$custom_info.relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))">{$custom_info.viewname}</li>
                        {assign var="j" value=$j+1}
                    {else}
                        <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if} customview_oplist_cv_li" related_cvid="{$custom_info.cvid}" relatetag="{$custom_info.module}" tag="{$k}" style="position:relative;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomView(this,'{$custom_info.module}','','{$custom_info.cvid}')">
                            {if $custom_info.edit_permit eq 'yes'}
                                <b class="ld-category-icon ld-category-drag drag-handle" ></b>
                            {/if}
                            {$custom_info.viewname}
                            <div class="customview_oplist_cv_li_btn">
                                {if $custom_info.edit_permit eq 'yes'}
                                    <a class="6" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'EDITCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-edit lineheight42"></i></a>
                                {/if}
                                {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                    <a class="6" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'COPYCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-copy lineheight42"></i></a>
                                {/if}
                                {if $custom_info.del_permit eq 'yes' && $custom_info.viewnamedata neq 'All'}
                                    <a class="6" onclick="event.stopPropagation(); DataCategoryListPopup.delVal(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'DeleteCategory'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-del lineheight42"></i></a>
                                {/if}
                                <a class="6" onclick="event.stopPropagation(); DataCategoryListPopup.addToCommon(this,{$custom_info.cvid})"{if $custom_info.isCommon eq 'no'} class="sort-tip-items" data-tip="{'ADDTOCOMMON'|@getFixedLabel}" data-direction="top" data-type="position" {else}class="sort-tip-items" data-tip="{'UNCOLLET'|@getFixedLabel}" data-direction="top" data-type="position" {/if}><b class="ld-category-icon {if $custom_info.isCommon eq 'no'}ld-category-addToCommon{else}ld-category-deleteFromCommon{/if}"></b></a>
                            </div>
                        </li>
                        {assign var="k" value=$k+1}
                    {/if}
                {/foreach}
            {/if}
        {/foreach}
    {/if}
</ul>


<script>
    var custom_info='{$MODULE}'
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    //绑定拖拽排序事件
    ld.each(ld('#shujufenlei_new_optionlistid .customview_oplist_cv_ul'),function(index,obj){
        Sortable.create(obj, {
            animation: 150,
            handle:".drag-handle",
            filter:'',
            sort:true,
            onMove: function(evt) {
            },
            onEnd: function (evt){
                commonCvSort()
            }
        })
    })
    //拖拽查询分类排序回调函数
    function commonCvSort(){
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
        var groupActivated=customviewobj.find('.customview_oplist_group_li.activate').attr('groupid')
        var selectedColumnsString="";
        ld('#shujufenlei_new_optionlistid .customview_oplist_cv_ul').find('li').each(function(){
            if(ld(this).attr("related_cvid")!=undefined)
                selectedColumnsString+=ld(this).attr("related_cvid")+";";
        })
        var currentModule=custom_info
        selectedColumnsString=selectedColumnsString.substr(0, selectedColumnsString.length - 1);
        if(groupActivated=='commonCustomView'){
            var url="index.php?module="+currentModule+"&action="+currentModule+"Ajax&file=ViewOrderEditSave&selectedColumnsString="+selectedColumnsString+"&isCommon=yes";
            ldAjaxNoProgress(url,'',function(data) {
                if(res.code==1) {
                    DelProgressObjs()
                }
            })
        }
        else{
            var url="index.php?module="+currentModule+"&action="+currentModule+"Ajax&file=ViewOrderEditSave&selectedColumnsString="+selectedColumnsString+"&isCommon=no";
            ldAjaxNoProgress(url,'',function(data) {
                if(res.code==1) {
                    DelProgressObjs()
                }
            })
        }

    }
    {/literal}
</script>