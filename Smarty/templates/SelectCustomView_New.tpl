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
                    <div class="ld-form-item-content ld_customview_search">
                        <input  name="showCustomlist_search" id="showCustomlist_search"  class="ld-input-inner ld-customview-search" onkeyup="searchScopeSetShowOrHideClearIcon(this)" value="" placeholder="{'Searchforgroupsorcategories'|@getFixedLabel}">
                        <b style="position: absolute;right:34px;top:10px;cursor: pointer;visibility:hidden;" class="ld-icon-clearsearch" module="{$MODULE}" onclick="clearBasicSearchScope(this);"></b>
                    </div>
                </div>
                <div name="customview_oplist_div" class="customview_oplist_div">
                    <div class="customview_oplist_group">
                        <ul class="customview_oplist_group_ul">
                            <li class="customview_oplist_group_li {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq 'ALL'}activate{/if}" name="{'ALL'|@getFixedLabel}" groupid="ALL" onclick="changeCustomViewGroup(this,'ALL')"><span>{'ALL'|@getFixedLabel}</span><span>（{$CUSTOMVIEW_OPTION|@count}）</span></li>
                            {foreach key=sequence item=group_info from=$CUSTOMVIEWGROUPLIST['groupList']}
                                {if $group_info['cvCount'] neq 0 ||($group_info['cvCount'] eq 0 &&$group_info['groupid'] eq 'commonCustomView')}
                                    <li class="customview_oplist_group_li {if $CUSTOMVIEWGROUPLIST['selectedGroupid'] eq $group_info['groupid']}activate{/if}" name="{$group_info['group_name']}" groupid="{$group_info['groupid']}" onclick="changeCustomViewGroup(this,'{$group_info.groupid}')"><span>{$group_info['group_name']}</span><span>（{$group_info['cvCount']}）</span></li>
                                {/if}
                            {/foreach}
                        </ul>
                        {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                        <div class="customview_oplist_group_btn">
                            <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_create" onclick="DataCategoryListPopup.add()">
                                <i class="ld-fonticon ld-fonticon-addhover marR3"></i>
                                <div class="sort-tip-items" data-tip="{'CREATECATEGORIES'|@getFixedLabel}" data-direction="top" data-type="position">{'CREATE'|@getFixedLabel}</div>
                            </div>
                            <div class="customview_oplist_group_btn_content customview_oplist_group_btn_content_management" onclick="createCustomViewGroupRightSetting()">
                                <i class="ld-fonticon ld-fonticon-set marR2"></i>
                                <div class="sort-tip-items" data-tip="{'MANAGEMENTGROUPING'|@getFixedLabel}" data-direction="top" data-type="position">{'management'|@getFixedLabel}</div>
                            </div>
                        </div>
                        {/if}
                    </div>
                    <div class="customview_oplist_cv">
                        {include file="SelectCustomView_New_Cv.tpl"}
                    </div>
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
    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    ld('#showCustomlist_new #showCustomlist_search').unbind('focus').bind('focus',function (e) {
        ld('#showCustomlist_new').find('div[name=customview_oplist_div]').css('height',ld('#showCustomlist_new').find('div[name=customview_oplist_div]').get(0).offsetHeight+'px');
        event.stopPropagation();
    });
    ld('#showCustomlist_new #showCustomlist_search').unbind('click').bind('click',function (e) {
            event.stopPropagation();
    });
    ld('#showCustomlist_new #showCustomlist_search').unbind('keyup').bind('keyup',function (e) {
        var searchtext = ld(this).val();

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
            //zhaosk 2024/7/4 BUG20240703-54 查询分类弹出框,在全部分组下搜索隐藏分组名称
            var popupObj = CrmPopup.getPopupObj("last");
            var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
            if(customviewobj.find('.customview_oplist_group_li.activate').attr('groupid')=='ALL'&&searchtext==''){
                ld.each(customviewobj.find('.customview_all_group_title'), function (index, obj) {
                    ld(obj).show();
                })
            }
            else {
                ld.each(customviewobj.find('.customview_all_group_title'), function (index, obj) {
                    ld(obj).hide();
                })
            }
            if(searchtext!=''){
                customviewobj.find('.searchResrlt_title').show()
                var insertedhtml=arrJsPopLabel['Include']+'"'+searchtext+'"'+arrJsPopLabel['SEARCHTITLE']
                customviewobj.find('.searchResrlt_title').html(insertedhtml)
            }
            else{
                customviewobj.find('.searchResrlt_title').hide()
            }
            getJsScript('include/js/multipingyin.js',function(){
                searchtext=searchtext.replace(/<br>/ig,'');
                if(trim(searchtext)=='')
                {
                    searchtext = '';
                }
                var uppersearch=searchtext.toLowerCase();
                var b=false;
                ld.each(ld('#showCustomlist_new').find('.customview_oplist_cv_li'),function (index,customobj) {
                    if(ld(customobj).attr('name') == 'nocontent'){
                        return true;
                    }
                    var text=ld(customobj).text().toLowerCase();
                    var arrRslt = makePy(text);
                    if(arrRslt != undefined){
                        var pingyingstr=arrRslt.join("").toLowerCase();
                        if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0)
                        {
                            b=true;
                            ld(customobj).show();
                        }
                        else
                        {
                            ld(customobj).hide();
                        }
                    }
                });
                if(b == false){
                    ld('#showCustomlist_new').find('.customview_oplist_cv .customview_oplist_cv_ul li[name=nocontent]').show();
                }else{
                    ld('#showCustomlist_new').find('.customview_oplist_cv .customview_oplist_cv_ul li[name=nocontent]').hide();
                }
            });
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
            groupLocation();
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
    // @edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化-点击分组局部刷新查询分类列表
    function changeCustomViewGroup(obj,groupId){
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
        var selectedgroupid=groupId;
        var currentModule=custom_info
        var url="index.php?module="+currentModule+"&action="+currentModule+"Ajax&file=ViewOrderEditSave&selectedGroupid="+selectedgroupid;
        ldAjax(url,'',function(res) {
            DelProgressObjs()
            customviewobj.find(".customview_oplist_group").find('.activate').removeClass('activate');
            ld(obj).addClass('activate');
            customviewobj.find('.customview_oplist_cv').html(res.result);
        })
        event.stopPropagation();
    }
    //打开弹出框后,定位到打开的查询分类的分组位置
    function groupLocation(){
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #shujufenlei_new_optionlistid');
        // 获取要滚动到的li元素
        var groupActivate = ld(customviewobj).find('.customview_oplist_group_li.activate');
        //添加容错
        if(groupActivate.length>0){
            var groupList = ld('.customview_oplist_group_ul');
            var groupActivateOffset = groupActivate.position().top;
            var groupListScrollTop = groupList.scrollTop();
            var scrollAmount = groupListScrollTop + groupActivateOffset;
            // 设置ul的滚动条位置
            groupList.scrollTop(scrollAmount);
        }
    }
//点击管理事件
    function createCustomViewGroupRightSetting(){
        var groupListObj=groupArray;
        groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
        groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
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