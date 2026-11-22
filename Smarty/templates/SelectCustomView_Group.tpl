<div id="showCustomlist_new" name="showCustomlist_new">
    <div class="shujufenlei_new">
        <div class="shujufenlei_new_icon"></div>
        {foreach key=User_Key item=custom_info from=$CUSTOMVIEW_OPTION}
            {if $VIEWID eq $custom_info.cvid}
                {if $custom_info.viewnamedata == 'All'}
                    <div class="shujufenlei_new_content"><span name="showCustomlist_viewname">{$custom_info.viewname}</span></div>
                    <script>
                        var tmp_custom_viewname = ld('#showCustomlist_new').find('.shujufenlei_new_content span').html();
                        var tmp_modulelabel = ld('#pagehead').find('.detail_crumbs ul.detail_path li').html().split('<span>')[0];
                        if(ld('#pagehead').find('.detail_crumbs ul.detail_path li').length > 0){
                            ld('#showCustomlist_new').find('.shujufenlei_new_content span').html(tmp_custom_viewname+'-'+tmp_modulelabel);
                        }
                    </script>
                {else}
                    <div class="shujufenlei_new_content"><span>{$custom_info.viewname}</span></div>
                {/if}
            {/if}
        {/foreach}
        {if !$LINKMODULECUSTOM}
            <div class="ld_icon_arrowdown"></div>
            <div class="shujufenlei_new_optionlistbg" id="shujufenlei_new_optionlistbg" style="display: none;">
                <div class="shujufenlei_new_optionlist" id="shujufenlei_new_optionlistid">
                    <div class="ld-form-item-head">
                        <div class="ld-form-item-head-title"><span>{'DATACATEGORY'|@getFixedLabel}</span></div>
                        {if $CUSTOMVIEWGROUPLIST['showgroupnum'] > 1 && $MODULE|@isPermitted:"CustomView" eq 'yes'}
                        <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_management" style="margin-right:0;" onclick="createCustomViewGroupRightSetting()">
                            <i class="ld-fonticon ld-fonticon-set marR2"></i>
                            <div class="sort-tip-items" data-tip="{'MANAGEMENTGROUPING'|@getFixedLabel}" data-direction="top" data-type="position">{'MANAGEMENTGROUPING'|@getFixedLabel}</div>
                        </div>
                        {/if}
                    </div>
                    <div style="padding-bottom: 10px;">
                        <div class="ld-form-item-content ld_customview_search">
                            <input name="showCustomlist_search" id="showCustomlist_search"  class="ld-input-inner ld-customview-search" onkeyup="searchScopeSetShowOrHideClearIcon(this)" value="" placeholder="{'Searchforgroupsorcategories'|@getFixedLabel}">
                            <b style="position: absolute;right:13px;top:11px;cursor: pointer;visibility:hidden;" class="ld-icon-clearsearch" module="{$MODULE}" onclick="clearBasicSearchScope(this);"></b>
                        </div>
                        <div name="customcontent" style="overflow: auto;max-height: 360px;">
                            <div style="display: flex;">
                                <ul class="customview_oplist_cv_ul">
                                    {assign var="custom_info" value=$CUSTOMVIEWGROUPLIST['cv_all']}
                                    {if $custom_info.popup eq 'popup'}
                                        <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if}" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" data-customlabel="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" onclick="showDefaultCustomViewPopup(this,'{$CUSTOMVIEWGROUPLIST['cv_all'].module}','','{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}')" >{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}</li>
                                        {assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
                                    {elseif $CUSTOMVIEWGROUPLIST['cv_all'].popup eq 'relatedleft'}
                                        <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if}" related_cvid="{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" relateTag="{$custom_module}" relatedid="{$CUSTOMVIEWGROUPLIST['cv_all'].relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))">{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}</li>
                                        {assign var="j" value=$j+1}
                                    {else}
                                        <li class="{if $VIEWID == $CUSTOMVIEWGROUPLIST['cv_all'].cvid}activecustomview{/if}" related_cvid="{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}" relatetag="{$CUSTOMVIEWGROUPLIST['cv_all'].module}" tag="{$k}" style="position:relative;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" title="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" data-customlabel="{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}" onclick="showDefaultCustomView(this,'{$CUSTOMVIEWGROUPLIST['cv_all'].module}','','{$CUSTOMVIEWGROUPLIST['cv_all'].cvid}')">
                                            <span style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;">{$CUSTOMVIEWGROUPLIST['cv_all'].viewname}</span>
                                            <div class="customview_oplist_cv_li_btn">
                                                {if $CUSTOMVIEWGROUPLIST['cv_all'].edit_permit eq 'yes'}
                                                    <a class="2" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})" class="sort-tip-items" data-tip="{'EDITCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-edit lineheight42"></i></a>
                                                {/if}
                                                {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                                    <a class="2" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,{$CUSTOMVIEWGROUPLIST['cv_all'].cvid})" class="sort-tip-items" data-tip="{'COPYCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-copy lineheight42"></i></a>
                                                {/if}
                                            </div>
                                        </li>
                                    {/if}
                                </ul>
                                {if $CUSTOMVIEWGROUPLIST['showgroupnum'] > 1 && $MODULE|@isPermitted:"CustomView" eq 'yes'}
                                <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_create" onclick="DataCategoryListPopup.add()">
                                    <i class="customview_oplist_group_btn_content_img_add customview_oplist_group_btn_content_img"></i>
                                    <div class="sort-tip-items" data-tip="{'CREATECATEGORIES'|@getFixedLabel}" data-direction="top" data-type="position">{'CREATECATEGORIES'|@getFixedLabel}</div>
                                </div>
                                {/if}
                            </div>
                            <div style="max-width: 950px;overflow: hidden;display: flex;{if $CUSTOMVIEWGROUPLIST['showgroupnum'] > 5}width: 950px;flex-wrap: wrap;{/if}">
                                {foreach key=groupId item=customGroup_info from=$CUSTOMVIEWGROUPLIST['groupList']}
                                    {if $customGroup_info.cvCount neq 0}
                                        <ul class="customview_oplist_cv_ul">
                                            <div style="line-height: 40px;padding: 0 20px;color: #999;{if $CUSTOMVIEWGROUPLIST['showgroupnum'] <= 1}display: none;{/if}">{$customGroup_info['group_name']}</div>
                                            {foreach key=User_Key item=custom_info from=$customGroup_info.cvList}
                                                {if $custom_info.popup eq 'popup'}
                                                    <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if}" name="dv_chzn_{$i }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomViewPopup(this,'{$custom_info.module}','','{$custom_info.cvid}')" >{$custom_info.viewname}</li>
                                                    {assign var="i" value=$i+1}<!--i、j、k 需要区分开，不然同个页面2个下拉控件鼠标移上去背景会有问题-->
                                                {elseif $custom_info.popup eq 'relatedleft'}
                                                    <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if}" related_cvid="{$custom_info.cvid}" title="{$custom_info.viewname}" relateTag="{$custom_module}" relatedid="{$custom_info.relationId}" name="dv_chzn_{$j }_{$fldname}_{$custom_module}" onclick="DetailViewRelation.setRelatedListCustomView(event,ld(this))">{$custom_info.viewname}</li>
                                                    {assign var="j" value=$j+1}
                                                {else}
                                                    <li class="{if $VIEWID == $custom_info.cvid}activecustomview{/if}" related_cvid="{$custom_info.cvid}" relatetag="{$custom_info.module}" tag="{$k}" style="position:relative;" name="dv_chzn_{$k }_{$fldname}_{$custom_module}" title="{$custom_info.viewname}" data-customlabel="{$custom_info.viewname}" onclick="showDefaultCustomView(this,'{$custom_info.module}','','{$custom_info.cvid}')">
                                                        <span style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;">{$custom_info.viewname}</span>
                                                        <div class="customview_oplist_cv_li_btn">
                                                            {if $custom_info.edit_permit eq 'yes'}
                                                                <a class="3" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'EDITCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-edit lineheight42"></i></a>
                                                            {/if}
                                                            {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                                                <a class="3" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,{$custom_info.cvid})" class="sort-tip-items" data-tip="{'COPYCATEGORY'|@getFixedLabel}" data-direction="top" data-type="position"><i class="ld-fonticon ld-fonticon-copy lineheight42"></i></a>
                                                            {/if}
                                                        </div>
                                                    </li>
                                                    {assign var="k" value=$k+1}
                                                {/if}
                                            {/foreach}
                                        </ul>
                                    {/if}
                                {/foreach}
                            </div>
                        </div>
                        <div name="customresultcontent" style="overflow: auto;max-height: 360px;display: none;">
                            <div class="searchResrlt_title"></div>
                            <ul>
                                <li style="width: 100%;text-align: center; cursor:default;display: block;padding: 0;" name="nocontent">
                                    {'NOCONTENT'|@getFixedLabel}
                                </li>
                            </ul>
                            <ul class="customview_oplist_cv_ul" style="display: flex;flex-wrap: wrap;">

                            </ul>
                        </div>
                        {if $CUSTOMVIEWGROUPLIST['showgroupnum'] <= 1 && $MODULE|@isPermitted:"CustomView" eq 'yes'}
                            <div style="border-top: 1px solid #EBEDF0">
                                <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_create" onclick="DataCategoryListPopup.add()" style="margin: 0;">
                                    <i class="ld-fonticon ld-fonticon-addhover marR3"></i>
                                    <div class="sort-tip-items" data-tip="{'CREATECATEGORIES'|@getFixedLabel}" data-direction="top" data-type="position">{'CREATECATEGORIES'|@getFixedLabel}</div>
                                </div>
                                <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_management" style="margin-right:0;" onclick="createCustomViewGroupRightSetting()">
                                    <i class="ld-fonticon ld-fonticon-set marR2"></i>
                                    <div class="sort-tip-items" data-tip="{'MANAGEMENTGROUPING'|@getFixedLabel}" data-direction="top" data-type="position">{'MANAGEMENTGROUPING'|@getFixedLabel}</div>
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
        {/if}
    </div>
</div>
<script>
    {if isset($CUSTOMVIEWGROUPLIST['groupList'])}
    var groupArray = {$CUSTOMVIEWGROUPLIST['groupList']|@json_encode};
    {else}
    var groupArray=''
    {/if}
    var custom_info='{$MODULE}'
    {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
    var allowcopy = true;
    {else}
    var allowcopy = false;
    {/if}
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});

    ld('#showCustomlist_new #showCustomlist_search').unbind('click').bind('click',function (e) {
        event.stopPropagation();
    });
    //分类搜索功能
    ld('#showCustomlist_new #showCustomlist_search').unbind('keyup').bind('keyup',function (e) {
        var searchtext = ld(this).val().trim();
        var tmp_result_html = '';
        var keyCode = e.keyCode || e.which || e.charCode;
        var ctrlKey = e.ctrlKey || e.metaKey;
        if(ctrlKey && (keyCode==13||keyCode==10)){
        }
        else if(ctrlKey)
        {
        }
        else if(keyCode==13)
        {
        }
        else{
            var popupObj = CrmPopup.getPopupObj("last");
            var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
            if(searchtext!=''){
                if(customviewobj.find('[name=customcontent]').get(0).style.display == 'none'){

                }else{
                    customviewobj.find('[name=customresultcontent]').css('height',customviewobj.find('[name=customcontent]').get(0).offsetHeight+'px');
                    customviewobj.find('[name=customresultcontent]').css('width',customviewobj.find('[name=customcontent]').get(0).offsetWidth+'px');
                }
                customviewobj.find('[name=customresultcontent]').show();
                customviewobj.find('[name=customcontent]').hide();
                var insertedhtml=arrJsPopLabel['Include']+'"'+searchtext+'"'+arrJsPopLabel['SEARCHTITLE'];
                customviewobj.find('.searchResrlt_title').html(insertedhtml);

                getJsScript('include/js/multipingyin.js',function(){
                    searchtext=searchtext.replace(/<br>/ig,'');
                    var uppersearch=searchtext.toLowerCase();
                    var b=false;
                    ld.each(customviewobj.find('[name=customcontent] ul.customview_oplist_cv_ul li'),function (index,customobj) {
                        var text=ld(customobj).text().toLowerCase();
                        var arrRslt = makePy(text);
                        if(arrRslt != undefined){
                            var pingyingstr=arrRslt.join("").toLowerCase();
                            if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0)
                            {
                                b=true;
                                tmp_result_html += customobj.outerHTML;
                            }
                        }
                    });
                    if(b == false){
                        customviewobj.find('li[name=nocontent]').show();
                        customviewobj.find('[name=customresultcontent] ul.customview_oplist_cv_ul').html('');
                    }else{
                        customviewobj.find('li[name=nocontent]').hide();
                        customviewobj.find('[name=customresultcontent] ul.customview_oplist_cv_ul').html(tmp_result_html);
                    }
                });
            }
            else{
                customviewobj.find('[name=customresultcontent]').hide();
                customviewobj.find('[name=customcontent]').show();
            }
        }
        event.stopPropagation();
    });

    ld('#showCustomlist_new').unbind('click').bind('click',function(){
        event.stopPropagation();
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #showCustomlist_new');
        if(customviewobj.hasClass('activate')){
            //BUG20240703-54 清空搜索框后刷新右侧分类列表
            ld('#showCustomlist_new #showCustomlist_search').val('').trigger('keyup'); // 触发 keyup 事件
            ld('#shujufenlei_new_optionlistbg').hide();
            customviewobj.removeClass('activate')
            customviewobj.find('.ld_icon_arrowdown').css('transform','translateY(60%) rotate(135deg)');
            customviewobj.find('.ld_icon_arrowdown').css('margin','5px 2px 0px 8px');
            document.removeEventListener('click', cancelCvPopup);
        }
        else{
            ld('#shujufenlei_new_optionlistbg').show();
            customviewobj.addClass('activate')
            customviewobj.find('.ld_icon_arrowdown').css('transform','translateY(60%) rotate(-45deg)');
            customviewobj.find('.ld_icon_arrowdown').css('margin','8px 2px 0px 8px');
            document.addEventListener('click', cancelCvPopup);
        }
    })
    function cancelCvPopup(event) {
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #showCustomlist_new');
        if (customviewobj.has(event.target).length > 0) {
            if(customviewobj.hasClass('activate')){
                //BUG20240703-54 清空搜索框后刷新右侧分类列表
                ld('#showCustomlist_new #showCustomlist_search').val('').trigger('keyup'); // 触发 keyup 事件
                ld('#shujufenlei_new_optionlistbg').hide();
                customviewobj.removeClass('activate')
                customviewobj.find('.ld_icon_arrowdown').css('transform','translateY(60%) rotate(135deg)');
                customviewobj.find('.ld_icon_arrowdown').css('margin','5px 2px 0px 8px');
                document.removeEventListener('click', cancelCvPopup);
            }
        } else {
            if(customviewobj.hasClass('activate')){
                ld('#showCustomlist_new #showCustomlist_search').val('').trigger('keyup'); // 触发 keyup 事件
                ld('#shujufenlei_new_optionlistbg').hide();
                customviewobj.removeClass('activate')
                customviewobj.find('.ld_icon_arrowdown').css('transform','translateY(60%) rotate(135deg)');
                customviewobj.find('.ld_icon_arrowdown').css('margin','5px 2px 0px 8px');
                document.removeEventListener('click', cancelCvPopup);
            }
        }
    }

    //点击管理事件
    function createCustomViewGroupRightSetting(){
        var groupListObj=groupArray;
        //groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
        //groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
        // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
        groupListObj = groupListObj.reduce((acc, curr, index) => {
            acc[index] = curr;
            return acc;
        }, {});
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
        var currentModule=custom_info
        getJsScript('include/js/CustomViewGroupRightSetting.js', function () {
            CustomViewGroupRightSettingobj = new CustomViewGroupRightSetting();
            CustomViewGroupRightSettingobj.allowcopy = allowcopy;
            if(!empty(groupListObj)) {
                CustomViewGroupRightSettingobj.groupList = groupListObj;
            }
            CustomViewGroupRightSettingobj.custom_info=currentModule
            CustomViewGroupRightSettingobj.listpopupobj=customviewobj;
            CustomViewGroupRightSettingobj.showCustomViewGroupRightSetting();
        })
        event.stopPropagation();
    }
    {/literal}
</script>