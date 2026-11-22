{*该文件已经不使用 20240704 hzx*}

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
<!--修改编码格式:统一编码：UTF-8-->
-->*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
{assign var="i" value=0}
{foreach key=BLOCKID item=BLOCKLABEL from=$BLOCKS name=itr}
    {assign var="j" value=$i++}
    {if $BLOCKLABEL neq 'LBL_MODULE_MANAGER'}
        {assign var=count value=$smarty.foreach.itr.iteration}
        <div class="analysis-accordion-content">
            <a href="javascript:;" class="analysis-accordion-header displayblock {if ($BLOCKID eq $MENU_NUM) || ($j eq '0' && $MENU_NUM eq '')} selected{/if}" title="{$BLOCKLABEL|@getFixedLabel}"><span class="dinline-block lfloat">{$BLOCKLABEL|@getFixedLabel}</span><i class="dinline-block lfloat"></i></a>
            {if $BLOCKID eq $MENU_NUM}
            <div class="analysis-accordion" style="display: block;">
            {else if $j eq 0 && $MENU_NUM eq ''}
            <div class="analysis-accordion" style="display: block;">
            {else}
            <div class="analysis-accordion" style="display: none;">
            {/if}
                <ul class="list">
                    {if $SelfServiceConfig_Step eq ''}
                        {foreach item=data from=$FIELDS.$BLOCKID}
                           {if $data.link neq ''}

                                {assign var=label value=$data.name}
                                {if $smarty.request.action eq $data.action && $smarty.request.module eq $data.module || $data.fieldid eq $FIELDIDSELECTED}
                                    <li class="active"><a service="{$data.miniprogram_service}" tag="settingleftmenu" name="{$data.name}" link="{$data.link}" blockid="{$BLOCKID}" fieldid="{$data.fieldid}" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="{$label|@getFixedLabel}">{$label|@getFixedLabel}</a></li>
                                {else}
                                    <li><a tag="settingleftmenu" service="{$data.miniprogram_service}" name="{$data.name}" link="{$data.link}" blockid="{$BLOCKID}" fieldid="{$data.fieldid}" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="{$label|@getFixedLabel}">{$label|@getFixedLabel}</a></li>
                                {/if}
                           {/if}
                        {/foreach}
                    {else}
                        {foreach item=data from=$FIELDS.$BLOCKID}
                            {if $data.link neq ''}
                                {assign var=label value=$data.name}
                                {if $data.fieldid eq $FIELDIDSETTING}
                                    <li class="active"><a tag="settingleftmenu" name="{$data.name}" link="{$data.link}" blockid="{$BLOCKID}" fieldid="{$data.fieldid}" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))"  title="{$label|@getFixedLabel}">{$label|@getFixedLabel}</a></li>
                                {else}
                                    <li><a tag="settingleftmenu" name="{$data.name}" link="{$data.link}" blockid="{$BLOCKID}" fieldid="{$data.fieldid}" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="{$label|@getFixedLabel}">{$label|@getFixedLabel}</a></li>
                                {/if}
                            {/if}
                        {/foreach}
                    {/if}
                </ul>
            </div>
        </div>
    {/if}
{/foreach}

<script type="text/javascript">
var module='{$MODULE}';

{literal}
    //18070: 控制面板>用户管理：点击下一页或上一页后，查看用户， 结果：用户管理页签收起。
    if(module=='Users')
    {
        var obj=document.getElementById('controlTitle_1');
        showControl(obj,1);
    }
    function showControl(obj,fori){
        var inputs = $(".ControlUl");
        for(var i=0;i<inputs.length;i++){
            inputs[i].style.display = 'none';
            document.getElementById('controlTitle_'+(i+1)).className = 'Title';
        }
        document.getElementById('controlUl_'+fori).style.display = 'block';
        obj.className = 'Title TitleOn';
    }
    ld(function(){
        //加载内容中点击事件
        initContentLeftMenuClick();
    });


    function LeftMenuSettingClick(event,jqueryobj){
        var link=ld(jqueryobj).attr("link");
        var service=ld(jqueryobj).attr("miniprogram_service");
        //获取link的action参数
        var action=getSearchString("action",link);
		//控制面板-产品授权中心
		if(link == 'index.php?action=isReg'){
			window.open('index.php?action=isReg&ReportHeader=dheader');
			return false;
		}
        link+="&ReportHeader=dheader";
        if(ld(jqueryobj).attr("page_addurl")!=undefined){
            link+=ld(jqueryobj).attr("page_addurl");
        }
        ldAjaxNoProgress(link,'',function(data){
            //异地登录

            if(data.code==DataCode.logincontrol)
            {
                Tools.Relogin();
            }
            var stateObject = {};
            var href=location.href;
            // var newUrl=href+"&pageto_menufile="+action;
            var hrefArr = href.split('&pageto_menufile');
            var newUrl=hrefArr[0]+"&pageto_menufile="+action;
            history.pushState(stateObject,"",newUrl);
            ld(" [name=SettingRightContent]").html(data.result.content);

            //BUG0068281 txy 2023.06.18 kfbcrm 后台设置--登录日志查询--翻页没有浮显
            tooltip('.tip-items-list', {transition: true, time: 200});
            //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
            var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
            if(selectobj.length>0&&selectobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                CrmPopup.global_listPopupObj=[];
                var obj=new Object();
                obj.divid="SettingRightContent";
                CrmPopup.global_listPopupObj.push(obj);
                obj.CancelEvent=function(){
                    return false;
                }
                cls_resetComboxHtmlobj.setPopupObj(obj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
                var selectdivobj  =Tools.getParentobjByChild(selectobj,'div');
                ld(selectdivobj).css('width', ld(selectdivobj).width()+20+'px');
                ld(selectdivobj).find('.chzn-container').css('margin-top', '17px');
                ld(selectdivobj).find('.chzn-drop').css('margin-left', '10px');

                //
                var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
                if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,150);
                    var sourcetypedivobj  =Tools.getParentobjByChild(selecttypeobj,'div');
                    ld(sourcetypedivobj).css('width', ld(sourcetypedivobj).width()+20+'px');
                    ld(sourcetypedivobj).find('.chzn-container').css('margin-top', '17px');
                    ld(sourcetypedivobj).find('.chzn-drop').css('margin-left', '10px');
                }
            }
            //zxm 20220909 设置冻结前几列
            var selectSetStickyobj=ld(" [name=SettingRightContent] .main_grid_top").find("#selectSetStickyNums");
            if(selectSetStickyobj.length>0 && selectSetStickyobj != undefined){
                cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectSetStickyNums');
                CrmPopup.global_listPopupObj = [];
                var obj = new Object();
                obj.divid="SettingRightContent";
                CrmPopup.global_listPopupObj.push(obj);
                obj.CancelEvent=function(){
                    return false;
                }
                cls_resetComboxHtmlobj.setPopupObj(obj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectSetStickyobj,150);
                var selectSetStickyobjdivobj  =Tools.getParentobjByChild(selectSetStickyobj,'div');
                ld(selectSetStickyobjdivobj).css('width', ld(selectSetStickyobjdivobj).width()+20+'px');
                ld(' .chzn-container').css('margin-top', '17px');
                ld(' .chzn-drop').css('margin-left', '10px');
                selectSetStickyobj.unbind('change').bind('change',function(){
                    selectSetStickyNums(this);
                });
            }
            //以后不准在这个函数写特殊判断 违者罚
            initRightContentHeight();//加载右侧内容中菜单和详细内容高度
            //wyt 220819 BUG0055311 系统设置-订单小程序设置，一些字段没有标题
            if(service!='Service'){
                ld('#setting_miniprogramsecret').hide();
            }
            //审批流程定制，因为多了一行用于显示审批参数，所以高度要减去40
            if(jqueryobj.attr('name') == 'LBL_APPROVE'){
                ld('.main_grid .main_grid_box').css('height',(ld('.main_grid .main_grid_box').height()-40) + 'px');
            }
            ld('.main_grid_box').scroll(function (){
                if(ld('.main_grid_box').scrollTop() > 0){
                    //BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影
                    if(ld('.main_grid_box .clear_float table tr').length>0){
                        ld('.main_grid_box .clear_float table tr').get(0).className = 'ld-setting-tabtop-shadow';
                    }
                }else{
                    if(ld('.main_grid_box .clear_float table tr').length>0) {
                        ld('.main_grid_box .clear_float table tr').eq(0).removeClass('ld-setting-tabtop-shadow');
                    }
                }
            });
            //BUG0069796 txy 20230803 后台设置->参数设置->系统参数设置，将“设置计算已收金额时是否统计未审批通过的收款单”修改选项后，滚动条拉到最上方后，界面增加了空白行
            if(ld('.main_grid_box').length > 0){
                var totalheight = ld('.main_grid_box').get(0).clientHeight;
                var headerheight = ld('.D_Tab_div.tabHieght').outerHeight(true);
                ld('#system_div').css('height',totalheight-headerheight+'px');
                ld('#system_div').scroll(function (){
                    if(ld('#system_div').scrollTop() > 0){
                        ld('.D_Tab_div table').eq(0).addClass('ld-setting-tabtop-shadow');
                    }else{
                        ld('.D_Tab_div table').eq(0).removeClass('ld-setting-tabtop-shadow');
                    }
                });
            }
        });
    }
    //zxm 20220909 设置冻结前几列
    function selectSetStickyNums(obj){
        var value = ld(obj).val();
        var selectTabid = ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]").val();
        ld.ajax({
            url:"index.php?module=Settings&file=ProductToolField&action=SettingsAjax&ajax=yes&selectTabid="+selectTabid+'&detail_issticky='+value+'&setdetail_issticky=yes',
            dataType:"json",
            timeout:20000,
            type:"post",
            success:function(data){

            }
        });
    }

    //单据分录定制拖动排序
    function ListFieldDragSort(){//230704 wyt XUQIU1001563 PC端-单据分录定制-排序风格优化
        ld('[name=SettingRightContent] table.settingTable.fir-center tr').hover(function() {
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj=ld(" [name=SettingRightContent]").find('table tbody');
        var cur_module='';
        var fieldid='';
        ld.each(dragobj,function(index,obj){
            Sortable.create(obj, {
                // group: 'stuff',
                //animation: 150,
                draggable:".ld-category-draggable",
                handle:".drag-handle",
                sort:true,
                onEnd: function (evt){
                    var sortfield_arr='';
                    ld('[name=SettingRightContent] table.settingTable.fir-center tr').attr('onmouseover','');
                    ld('[name=SettingRightContent] table.settingTable.fir-center tr').attr('onmouseout','');
                    ld('[name=SettingRightContent] table.settingTable.fir-center tr').removeClass('lvtColData');
                    ld('[name=SettingRightContent] table.settingTable.fir-center tr').removeClass('lvtColDataBj');
                    ld('[name=SettingRightContent] table.settingTable.fir-center tr').removeClass('lvtColDataHover');
                    ld.each(ld('[name=SettingRightContent] table.settingTable.fir-center tr'),function(index,tmpobj){
                        if(index>0){
                            if(index%2==0){
                                ld(tmpobj).addClass('lvtColDataBj');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                                ld(tmpobj.childNodes[0]).html(index);
                                cur_module=ld(tmpobj).attr('cur_module');
                                fieldid=ld(tmpobj).attr('tag');
                                sortfield_arr+=fieldid+";";

                            }else{
                                ld(tmpobj).addClass('lvtColData');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                                ld(tmpobj.childNodes[0]).html(index);
                                cur_module=ld(tmpobj).attr('cur_module');
                                fieldid=ld(tmpobj).attr('tag');
                                sortfield_arr+=fieldid+";";
                            }
                        }
                    });

                    var selectsourcetype = '';
                    var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
                    if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                        selectsourcetype = ld(selecttypeobj).find("option:selected").val();
                    }
                    if(sortfield_arr !=''){
                        var update_url="index.php?module=Settings&action=SettingsAjax&file=ProductToolField&submode=UpdateFieldSort&tabid="+cur_module+"&parenttab=Settings&ajax=true&selectedFieldStr="+sortfield_arr+"&selectsourcetype="+selectsourcetype;
                        ldAjax(update_url,'',function(data){
                            if(data.code==1){

                                DelProgressObjs();
                            }
                        })
                    }
                }
            })
        });
    }

    //网页端菜单定制拖动排序
    function MenuListDragSort(){
        ld('div[name=menulistcontent] table.settingTable.fir-center tr').hover(function() {
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });

        var dragobj=ld('div[name=menulistcontent]').find('table tbody');
        var parenttabid='';

        ld.each(dragobj,function(index,obj){
            Sortable.create(obj, {
                // group: 'stuff',
                // animation: 150,
                draggable:".ld-category-draggable",
                handle:".drag-handle",
                sort:true,
                onEnd: function(evt){
                    var sortparenttab='';
                    ld('div[name=menulistcontent] table.settingTable.fir-center tr').attr('onmouseover','');
                    ld('div[name=menulistcontent] table.settingTable.fir-center tr').attr('onmouseout','');
                    ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColData');
                    ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColDataBj');
                    ld('div[name=menulistcontent] table.settingTable.fir-center tr').removeClass('lvtColDataHover');
                    ld.each(ld('div[name=menulistcontent] table.settingTable.fir-center tr'),function(index,tmpobj){
                        if(index>0){
                            if(index%2==0){
                                ld(tmpobj).addClass('lvtColDataBj');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                                ld(tmpobj.childNodes[1]).html(index);
                                parenttabid=ld(tmpobj).attr('tag');
                                sortparenttab+=parenttabid+",";


                            }else{
                                ld(tmpobj).addClass('lvtColData');
                                ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                                ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                                ld(tmpobj.childNodes[1]).html(index);
                                parenttabid=ld(tmpobj).attr('tag');
                                sortparenttab+=parenttabid+",";
                            }
                        }
                    });

                    if(sortparenttab !=''){
                        var update_url='index.php?module=Settings&action=SettingsAjax&file=MenuList&type=saveSortMenu&ajax=yes&tabids='+sortparenttab;
                        ldAjax(update_url,'',function(data){
                            if(data.code==1){
                                DelProgressObjs();
                                // window.location.reload();//刷新当前页
                            }
                        })
                    }
                }
            })
        });
    }

    //移动端功能菜单定制拖动排序
    function MobileListDragSort(){

        ld('#cfList table.settingTable.fir-center tr').hover(function() {
            ld('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });

    var dragobj=ld('#cfList').find('table tbody');
    var blockid='';

    ld.each(dragobj,function(index,obj){
        Sortable.create(obj, {
            // group: 'stuff',
            // animation: 150,
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            sort:true,
            onEnd: function(evt){
                var sortblockid='';
                ld('#cfList table.settingTable.fir-center tr').attr('onmouseover','');
                ld('#cfList table.settingTable.fir-center tr').attr('onmouseout','');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColData');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColDataBj');
                ld('#cfList table.settingTable.fir-center tr').removeClass('lvtColDataHover');
                ld.each(ld('#cfList table.settingTable.fir-center tr'),function(index,tmpobj){
                    if(index>0){
                        if(index%2==0){
                            ld(tmpobj).addClass('lvtColDataBj');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                            ld(tmpobj.childNodes[0]).html(index);
                            blockid=ld(tmpobj).attr('tag');
                            sortblockid+=blockid+",";


                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[0]).html(index);
                            blockid=ld(tmpobj).attr('tag');
                            sortblockid+=blockid+",";
                        }
                    }
                });

                if(sortblockid !=''){
                    var setting_position = ld('#setting_position').val();
                    if(setting_position === 'report'){
                        var update_url = 'index.php?module=Settings&action=SettingsAjax&file=mobileReportListOpertion&type=SaveMobileBlockSort&ajax=true&tabids='+sortblockid;
                    }else{
                        var update_url = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&type=SaveMobileBlockSort&ajax=true&tabids='+sortblockid;
                    }
                    update_url=update_url.slice(0,-1);
                    ldAjaxHtml(update_url,'',function(){

                            DelProgressObjs();
                            // window.location.reload();//刷新当前页
                    })
                }
            }
        })
    });
}

ld(document).ready(
    function() {
        ld("html").niceScroll();
    }
);


{/literal}
</script>