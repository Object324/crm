//右侧设置抽屉
var CustomViewGroupRightSetting = function(){
    this.listpopupobj=CrmPopup.getPopupObj("last");
    let that = this;
    this.groupList=''
    this.addGroupCount=0;
    this.groupListToSave=[];
    this.custom_info=''
    this.allowcopy = false;
    this.selectedGroupid=''

    this.showCustomViewGroupRightSetting=function(){
        var listview_group_setting_html='<div class="first-modal" id="listview_setting_cover"style="z-index: 1001;"></div>\n' +
            '<div class="ld-listview-right-setting-drawer ld-listview-group-right-setting-drawer" id="ld-listview-group-right-setting-drawer">'+
            '<div class="el-loading-spinner"><svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg></div></div>';
        ld(listview_group_setting_html).appendTo("body");
        that.Show_Listview_group_drawer_content();
    }
    this.Show_Listview_group_drawer_content=function(){
        var listview_group_drawer_content_html='<div class="first-drawer-header group-first-drawer-header">\n' +
            '    <span class="first-drawer-title">'+arrJsPopLabel['MANAGEMENTGROUPING']+'</span>\n' +
            '    <div class="first-drawer-headerbtn">\n' +
            '        <button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>\n' +
            '    </div>\n' +
            '</div>'

        //查询分类分组内容部分
        listview_group_drawer_content_html+='<div class="listview_group_drawer_content_tips">\n' +
            '<span>'+arrJsPopLabel['NEWCATEGORIESTIPS']+'</span>\n'+
            '</div>';
        listview_group_drawer_content_html += '<div class="listview_group_drawer_content_add"><div name="addcustomview" class="ld-button ld-button-primary" style="margin-right: 20px;margin-left: auto;display: flex;align-items: center;padding: 7px 12px !important;"><b class="group_drawer_content_icon group_drawer_content_icon_addwhite"></b>'+arrJsPopLabel['NEWGROUPING']+'</div></div>';
        //如果查询分类分组没有内容
        if(empty(that.groupList)) {
            listview_group_drawer_content_html += '<div class="listview_group_drawer_content_no">' +
                '<div class="listview_group_drawer_content_list_img"></div>' +
                '<div class="listview_group_drawer_content_list_tips">' + arrJsPopLabel['NOGrouping'] + '</div>' +
                '<div class="listview_group_drawer_content_list_btn">' +
                '<button type="button"><div class="listview_group_drawer_content_list_btn_img"></div><span>' + arrJsPopLabel['NEWGROUPING'] + '</span></button>' +
                '</div>' +
                '</div>'
        }
        //查询分类分组有内容,显示查询分类分组列表
        else{
            listview_group_drawer_content_html += '<div class="listview_group_drawer_content"><ul class="listview_group_drawer_content_list">';
            for (let key in that.groupList) {
                if(that.groupList[key]['groupid'] != 'ungrouped'){
                    listview_group_drawer_content_html += '<li class="listview_group_drawer_content_list_li" groupid="'+that.groupList[key]['groupid']+'" groupname="'+that.groupList[key]['group_name']+'">' +
                        '<div class="group_li_content" data-groupid="'+that.groupList[key]['groupid']+'">';
                    listview_group_drawer_content_html += '<b class="ld-category-icon ld-category-drag drag-handle-group" ></b><b class="listview_group_drawer_content_list_arrowdown"></b>';
                    listview_group_drawer_content_html += '<div class="listview_group_drawer_content_list_li_name">'+that.groupList[key]['group_name']+'</div>' +
                        '<div class="listview_group_drawer_content_list_li_operation">' +
                        '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_add" onclick="event.stopPropagation();DataCategoryListPopup.groupid='+that.groupList[key]['groupid']+';DataCategoryListPopup.add();"><b class="group_drawer_content_icon group_drawer_content_icon_add"></b><span>'+arrJsPopLabel['NEWCALASSIFICATION']+'</span></div>' +
                        '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_edit"><b class="group_drawer_content_icon group_drawer_content_icon_edit"></b><span>'+arrJsPopLabel['EDIT']+'</span></div>' +
                        '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_delete"><b class="group_drawer_content_icon group_drawer_content_icon_delete"></b><span>'+arrJsPopLabel['DELETE']+'</span></div>' +
                        '</div></div>';
                }
                else {
                    listview_group_drawer_content_html += '</ul><ul class="listview_group_drawer_content_list_ungroup">';
                    listview_group_drawer_content_html += '<li class="listview_group_drawer_content_list_li_ungroup" groupid="'+that.groupList[key]['groupid']+'" groupname="'+that.groupList[key]['group_name']+'">' +
                        '<div class="group_li_content" data-groupid="'+that.groupList[key]['groupid']+'">';
                    listview_group_drawer_content_html += '<b class="ld-category-icon ld-category-drag no-drag-group" style="cursor: no-drop;"></b><b class="listview_group_drawer_content_list_arrowdown"></b>';
                    listview_group_drawer_content_html += '<div class="listview_group_drawer_content_list_li_name">'+that.groupList[key]['group_name']+'</div>' +
                        '<div class="listview_group_drawer_content_list_li_operation">' +
                        '<div class="listview_group_drawer_content_list_li_operation_add" onclick="event.stopPropagation();DataCategoryListPopup.add();">'+arrJsPopLabel['NEWCALASSIFICATION']+'</div>' +
                        '</div>'+
                        '</div>';
                }

                listview_group_drawer_content_html += '<div name="drawer_group_customiew_list" data-groupid="'+that.groupList[key]['groupid']+'" data-toggle="show">' +
                    '<ul class="listview_customeview_content_list" data-groupid="'+that.groupList[key]['groupid']+'">' +
                    '<li class="listview_customview_drawer_content_list_li" style="color: #999;"><div style="margin-left: 56px;">'+arrJsPopLabel['CATEGORYNAME']+'</div><div style="margin-left: auto;margin-right: 94px;">'+arrJsPopLabel['OPERATION']+'</div></li>'+
                    '</ul><ul name="group_vustomview_list_ul" class="listview_customeview_content_list" data-groupid="'+that.groupList[key]['groupid']+'">';
                if(that.groupList[key].cvList && that.groupList[key].cvList.length > 0){
                    for(let i = 0;i<that.groupList[key].cvList.length;i++){
                        var cvinfo = that.groupList[key].cvList[i];
                        listview_group_drawer_content_html+= '<li class="listview_customview_drawer_content_list_li" name="customview_list_li_content" drag_premit="yes" data-cvid="'+cvinfo['cvid']+'">' +
                            '<b class="ld-category-icon ld-category-drag drag-handle-custom" style="margin-left: 30px;"></b>' +
                            '<div class="listview_cv_drawer_content_list_li_name">'+cvinfo['viewname']+'</div>' +
                            '<div class="customview_oplist_cv_li_btn" style="display: flex;margin-right: 10px;">';
                        if(cvinfo.edit_permit == 'yes'){
                            listview_group_drawer_content_html+='<a class="1" onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,'+cvinfo.cvid+');" style="margin-left: 16px;margin-right: 0;">'+arrJsPopLabel['EDIT']+'</a>';
                        }
                        if(that.allowcopy){
                            listview_group_drawer_content_html+='<a class="1" onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,'+cvinfo.cvid+')" style="margin-left: 16px;margin-right: 0;">'+arrJsPopLabel['COPY']+'</a>';
                        }
                        if(cvinfo.del_permit == 'yes' && cvinfo.viewnamedata != 'All'){
                            listview_group_drawer_content_html+='<a class="1" onclick="event.stopPropagation(); DataCategoryListPopup.delVal(this,'+cvinfo.cvid+')" style="margin-left: 16px;margin-right: 0;color: #EB1746;">'+arrJsPopLabel['DELETE']+'</a>';
                        }
                        listview_group_drawer_content_html += '</div>';
                        listview_group_drawer_content_html += '</li>';
                    }
                }
                listview_group_drawer_content_html += '</ul></div>';
                listview_group_drawer_content_html += '</li>';
            }
            listview_group_drawer_content_html += '</ul>'
        }
        ld('#ld-listview-group-right-setting-drawer').html(listview_group_drawer_content_html);
        that.bindshowafter();
    }
    this.bindshowafter = function () {
        tooltip('.sort-tip-items', {transition: true, time: 200});
        //
        ld('#ld-listview-group-right-setting-drawer .group_li_content').unbind('click').bind('click',function (){
            event.stopPropagation();
            ld(this).data('groupid');
            var cvlistobj = ld('#ld-listview-group-right-setting-drawer [name=drawer_group_customiew_list][data-groupid='+ld(this).data('groupid')+']');
            if(cvlistobj.length > 0){
                cvlistobj.slideToggle();
                if(cvlistobj.data('toggle') == 'show'){
                    cvlistobj.data('toggle','hide');
                    ld(this).find('b.listview_group_drawer_content_list_arrowdown').css('transform','rotate(-90deg)');
                }
                else{
                    cvlistobj.data('toggle','show');
                    ld(this).find('b.listview_group_drawer_content_list_arrowdown').css('transform','rotate(0deg)');
                }
            }

        });

        //绑定关闭
        ld('#ld-listview-group-right-setting-drawer .first-drawer-headerbtn i.ld-fonticon-close').unbind('click').bind('click',function (){
            event.stopPropagation();
            that.Hide_Listview_right_Setting();
        });
        ld('#listview_setting_cover').unbind('click').bind('click',function (){
            event.stopPropagation();
            that.Hide_Listview_right_Setting();
        });
        //绑定点击新建分组事件
        ld('.listview_group_drawer_content_add').find('.ld-button[name=addcustomview]').unbind('click').bind('click',function () {
            event.stopPropagation();
            that.addGroup();
        });

        //绑定点击编辑分组事件
        ld('.listview_group_drawer_content_list_li_operation_edit').unbind('click').bind('click',function () {
            event.stopPropagation();
            var groupObj=ld(this).closest('.listview_group_drawer_content_list_li');
            that.editGroup(groupObj);
        });

        //绑定点击取消事件
        ld('.listview_group_drawer_content_list_li_operation_cancel').unbind('click').bind('click',function () {
            event.stopPropagation();
            var groupObj=ld(this).closest('.listview_group_drawer_content_list_li');
            var groupname=groupObj.attr('groupname')
            var groupid=groupObj.attr('groupid')
            //新增分组点击取消
            if(groupid==null){
                ld(groupObj).remove();
            }
            //已有分组点击取消
            else{
                var html='<b class="ld-category-icon ld-category-drag drag-handle-group" ></b><b class="listview_group_drawer_content_list_arrowdown"></b>' +
                    '<div class="listview_group_drawer_content_list_li_name">'+groupname+'</div>' +
                    '<div class="listview_group_drawer_content_list_li_operation">' +
                    '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_add" onclick="event.stopPropagation();DataCategoryListPopup.groupid='+groupid+';DataCategoryListPopup.add();"><b class="group_drawer_content_icon group_drawer_content_icon_add"></b><span>'+arrJsPopLabel['NEWCALASSIFICATION']+'</span></div>' +
                    '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_edit"><b class="group_drawer_content_icon group_drawer_content_icon_edit"></b><span>'+arrJsPopLabel['EDIT']+'</span></div>' +
                    '<div class="listview_group_drawer_content_list_li_operation_item listview_group_drawer_content_list_li_operation_delete"><b class="group_drawer_content_icon group_drawer_content_icon_delete"></b><span>'+arrJsPopLabel['DELETE']+'</span></div>' +
                    '</div>';
                ld('#ld-listview-group-right-setting-drawer li[groupid="'+groupid+'"] .group_li_content').html(html);
                if(ld('#ld-listview-group-right-setting-drawer li[groupid="'+groupid+'"] [name=drawer_group_customiew_list]').data('toggle') == 'hide'){
                    ld('#ld-listview-group-right-setting-drawer li[groupid="'+groupid+'"] .group_li_content b.listview_group_drawer_content_list_arrowdown').css('transform','rotate(-90deg)');
                }
            }
            event.stopPropagation();
            that.bindshowafter();
        });
        //input输入框&drag阻止冒泡
        ld('.listview_group_drawer_content .listview_group_drawer_content_list_li_input').unbind('click').bind('click',function () {
            event.stopPropagation();
        });

        //绑定点击保存事件
        ld('.listview_group_drawer_content_list_li_operation_save').unbind('click').bind('click',function () {
            that.saveGroup_dafault()
            event.stopPropagation();
        });
        ld('.listview_group_drawer_content').unbind('click').bind('click',function () {
            that.saveGroup()
        });

        //绑定没有分组时点击新建事件
        ld('.listview_group_drawer_content_list_btn').unbind('click').bind('click',function () {
            that.newGroup();
            event.stopPropagation();
        });

        //绑定点击删除事件
        ld('.listview_group_drawer_content_list_li_operation_delete').unbind('click').bind('click',function () {
            event.stopPropagation();
            that.deleteGroup(this);
        });
        //绑定输入框监听事件
        ld('#ld-listview-group-right-setting-drawer #showCustomlist_search').unbind('keyup').bind('keyup',function(){
            if(!empty(ld('#ld-listview-group-right-setting-drawer #showCustomlist_search').val())){
                ld('#ld-listview-group-right-setting-drawer #showCustomlist_search').siblings('b').show();
            }
            else{
                ld('#ld-listview-group-right-setting-drawer #showCustomlist_search').siblings('b').hide();
            }
        })
        ld('#ld-listview-group-right-setting-drawer #showCustomlist_search b').mousedown(
            function (){
                event.preventDefault();
            }
        );
        //绑定拖拽排序事件
        Sortable.create(ld('#ld-listview-group-right-setting-drawer .listview_group_drawer_content_list').get(0), {
            animation: 150,
            handle:".drag-handle-group",
            cancel: ".no-drag-group",
            filter:'',
            sort:true,
            onMove: function(evt) {
            },
            onEnd: function (evt){
                that.saveGroup('yes')
            }
        })

        ld.each(ld('#ld-listview-group-right-setting-drawer .listview_customeview_content_list[name=group_vustomview_list_ul]'),function (index,customviewlistobj) {
            Sortable.create(customviewlistobj,{
                group: 'customviewlist',
                animation: 150,
                handle:".drag-handle-custom",
                draggable: "[drag_premit=yes]",
                sort:true,
                onMove: function(evt) {
                },
                onEnd: function (evt){
                    var fromul = ld(evt.from);
                    var toul = ld(evt.to);
                    var grouplist = [];
                    if(fromul.data('groupid') === toul.data('groupid')){
                        var cvlist = [];
                        ld.each(toul.find('li[name=customview_list_li_content]'),function (tokey,customliobj) {
                            cvlist.push(ld(customliobj).data('cvid'));
                        })
                        grouplist.push({groupid:toul.data('groupid'),cvlist:cvlist,type:'to'});
                    }
                    else{
                        var cvlist = [];
                        ld.each(fromul.find('li[name=customview_list_li_content]'),function (fromkey,customliobj) {
                            cvlist.push(ld(customliobj).data('cvid'));
                        })
                        grouplist.push({groupid:fromul.data('groupid'),cvlist:cvlist,type:'from'});
                        cvlist = [];
                        ld.each(toul.find('li[name=customview_list_li_content]'),function (tokey,customliobj) {
                            cvlist.push(ld(customliobj).data('cvid'));
                        })
                        grouplist.push({groupid:toul.data('groupid'),cvlist:cvlist,type:'to'});
                    }
                    that.save_customview_group_sequence(grouplist);
                }
            });
        });
    }

    //hzx 分类拖动后排序
    this.save_customview_group_sequence =function(grouplist){
        var surl = 'index.php?module='+that.custom_info+'&action='+that.custom_info+'Ajax&file=ViewOrderEditSave';
        var param = {customviewgroupsequence:JSON.stringify(grouplist)};
        ldAjax(surl,param,function(data){
            ld('#rptContentLoading').hide();
            that.reloadCustomViewPopup();
        });
    }

    //关闭弹框和弹出层
    this.Hide_Listview_right_Setting=function(){
        ld('#listview_setting_cover').remove();
        ld('#ld-listview-group-right-setting-drawer').remove();
        this.afterClosePopup();
    }
    this.newGroup=function(){
        var listview_group_drawer_content_html='<div class="first-drawer-header group-first-drawer-header">\n' +
            '    <span class="first-drawer-title">'+arrJsPopLabel['MANAGEMENTGROUPING']+'</span>\n' +
            '    <div class="first-drawer-headerbtn">\n' +
            '        <button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>\n' +
            '    </div>\n' +
            '</div>'
        listview_group_drawer_content_html+='<div class="listview_group_drawer_content_tips">\n' +
            '<span>'+arrJsPopLabel['NEWCATEGORIESTIPS']+'</span>\n'+
            '</div>\n'+
            '<div class="listview_group_drawer_content_title">\n' +
            '<span>'+arrJsPopLabel['POPUPGROUPNAME']+'</span>' +
            '<span style="width:252px;"></span>' +
            '<span>'+arrJsPopLabel['OPERATION']+'</span>' +
            '</div>';
        listview_group_drawer_content_html += '<div class="listview_group_drawer_content"><ul class="listview_group_drawer_content_list">';
        listview_group_drawer_content_html += '</ul>'
        listview_group_drawer_content_html += '<div class="listview_group_drawer_content_add"><div class="customview_oplist_group_btn_content_img_add customview_oplist_group_btn_content_img"></div>'+arrJsPopLabel['NEWGROUPING']+'</div></div>';
        ld('#ld-listview-group-right-setting-drawer').html(listview_group_drawer_content_html);
        that.addGroup();
    }
    //点击新增分组
    this.addGroup=function (){
        that.saveGroup()
        that.addGroupCount++;
        var html='<li class="listview_group_drawer_content_list_li" addgroupcount="'+that.addGroupCount+'">'
        html+=that.editGroupContent();
        ld(".listview_group_drawer_content_list").prepend(html);
        var input=ld('li[addgroupcount="'+that.addGroupCount+'"] .ld-customview-group-search').focus();
        ld('.listview_group_drawer_content').scrollTop(0);
        input[0].setSelectionRange(input.val().length, input.val().length);
        that.bindshowafter();
    }
    //点击已有分组编辑
    this.editGroup=function(groupobj){
        that.saveGroup()
        var groupid=groupobj.attr("groupid");
        var groupname=groupobj.attr("groupname");
        var html=that.editGroupContent(groupid,groupname);
        ld('#ld-listview-group-right-setting-drawer li[groupid="'+groupid+'"] .group_li_content').html(html);
        var input=ld('#ld-listview-group-right-setting-drawer li[groupid="'+groupid+'"] .ld-customview-group-search').focus();
        input[0].setSelectionRange(input.val().length, input.val().length);
        that.bindshowafter();
    }
    //用于添加li的子元素
    this.editGroupContent=function(groupid,groupname) {
        //新建分组
        if (groupid == null) {
        var html = '<div class="group_li_content"><b class="ld-category-icon ld-category-drag drag-handle-group" ></b>' +
            '<div class="listview_group_drawer_content_list_li_input"><input name="showCustomlist_search" id="showCustomlist_search"  class="ld-input-inner ld-customview-search ld-customview-group-search" value="分组'+that.addGroupCount+'" style="width:252px;">\n' +
            '                        <b class="ld-icon-clearsearch listview_group_drawer_content_list_li_input_clearbtn" onclick="clearBasicSearchScope(this);"></b></div>' +
            '<div class="listview_group_drawer_content_list_li_operation">' +
            '<div class="listview_group_drawer_content_list_li_operation_save">' + arrJsPopLabel['SAVE'] + '</div>' +
            '<div class="listview_group_drawer_content_list_li_operation_cancel">' + arrJsPopLabel['CANCEL'] + '</div>' +
            '</div></div>';
            html+='<div><ul class="listview_customeview_content_list" data-groupid="0">' +
                '<li class="listview_customview_drawer_content_list_li" style="color: #999;"><div style="margin-left: 56px;">'+arrJsPopLabel['CATEGORYNAME']+'</div><div style="margin-left: auto;margin-right: 94px;">'+arrJsPopLabel['OPERATION']+'</div></li>'+
                '</ul><ul name="group_vustomview_list_ul" class="listview_customeview_content_list" data-groupid="0">';
        }
        //编辑分组
        else{
            var html = '<div class="group_li_content"><b class="ld-category-icon ld-category-drag drag-handle-group"></b>' +
                '<div class="listview_group_drawer_content_list_li_input"><input name="showCustomlist_search" id="showCustomlist_search"  class="ld-input-inner ld-customview-search ld-customview-group-search" value="'+groupname+'" groupid="'+groupid+'" style="width:252px;">\n' +
                '                        <b class="ld-icon-clearsearch listview_group_drawer_content_list_li_input_clearbtn" onclick="clearBasicSearchScope(this);"></b></div>' +
                '<div class="listview_group_drawer_content_list_li_operation">' +
                '<div class="listview_group_drawer_content_list_li_operation_save">' + arrJsPopLabel['SAVE'] + '</div>' +
                '<div class="listview_group_drawer_content_list_li_operation_cancel">' + arrJsPopLabel['CANCEL'] + '</div>' +
                '</div></div>'
        }
        return html;
    }

    //点击保存按钮
    this.saveGroup_dafault=function(){
        var isEmptyInput='no';
        that.groupListToSave = [];
        ld('.listview_group_drawer_content_list_li').each(function(index, element){
            //有输入框
           if(ld(element).find('input').length> 0){
               var groupname=ld(element).find('input').val()
               if(empty(groupname)){
                   MessagePopup.TipOne_warning (arrJsPopLabel['GROUPNAMENOTEMPTY'])
                   isEmptyInput='yes'
               }
               else{
                   var groupid=ld(element).attr('groupid')
                   //新建分组
                   if(empty(groupid)){
                       var groupobj={
                           groupid:0,
                           groupname: groupname
                       }
                       that.groupListToSave.push(groupobj)
                   }
                   //编辑分组
                   else{
                       var groupobj={
                           groupid:groupid,
                           groupname: groupname
                       }
                       that.groupListToSave.push(groupobj);
                   }
               }
           }
           //无输入框
            else{
                var groupname=ld(element).attr('groupname')
                var groupid=ld(element).attr('groupid')
                var groupobj={
                    groupid:groupid,
                    groupname: groupname
               }
               that.groupListToSave.push(groupobj);
           }
        })
        if(isEmptyInput=='yes')
        {
            return false;
        }
        var groupListToSaveJson=JSON.stringify(that.groupListToSave)
        var surl = 'index.php?module='+that.custom_info+'&action='+that.custom_info+'Ajax&file=ViewOrderEditSave&groupListToSave='+groupListToSaveJson;
        ldAjaxsync(surl,"",function(res){
            if(res.code==1){
                DelProgressObjs()
                MessagePopup.TipZero_success (arrJsPopLabel['SUCCESSFULLYSAVED'])
                that.groupListToSave.splice(0,that.groupListToSave.length)
                //刷新管理分组右侧抽屉
                var groupListObj=res.result.groupList;
                //groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
                //groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
                // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
                groupListObj = groupListObj.reduce((acc, curr, index) => {
                    acc[index] = curr;
                    return acc;
                }, {});
                that.groupList=groupListObj;
                that.Show_Listview_group_drawer_content();
                //刷新查询分类弹出框左侧分组列表
                that.reloadCustomViewPopup();

            }
        });
    }
    //点击其他区域保存
    this.saveGroup=function(isDrag='no'){
        var isEmptyInput='no';
        var isInput='no';
        that.groupListToSave = [];
        ld('.listview_group_drawer_content_list_li').each(function(index, element){
            //有输入框
            if(ld(element).find('input').length> 0){
                isInput='yes'
                var groupname=ld(element).find('input').val()
                if(empty(groupname)){
                    // MessagePopup.TipZero_warning (arrJsPopLabel['GROUPNAMENOTEMPTY'])
                    isEmptyInput='yes';
                    //刷新界面
                    that.Show_Listview_group_drawer_content()
                }
                else{
                    var groupid=ld(element).attr('groupid')
                    //新建分组
                    if(empty(groupid)){
                        var groupobj={
                            groupid:0,
                            groupname: groupname
                        }
                        that.groupListToSave.push(groupobj)
                    }
                    //编辑分组
                    else{
                        var groupobj={
                            groupid:groupid,
                            groupname: groupname
                        }
                        that.groupListToSave.push(groupobj);
                    }
                }
            }
            //无输入框
            else{
                var groupname=ld(element).attr('groupname')
                var groupid=ld(element).attr('groupid')
                var groupobj={
                    groupid:groupid,
                    groupname: groupname
                }
                that.groupListToSave.push(groupobj);
            }
        })
        if(isEmptyInput=='yes'||(isInput=='no'&&isDrag=='no'))
        {
            return false;
        }
        var groupListToSaveJson=JSON.stringify(that.groupListToSave)
        var surl = 'index.php?module='+that.custom_info+'&action='+that.custom_info+'Ajax&file=ViewOrderEditSave&groupListToSave='+groupListToSaveJson;
        ldAjaxsync(surl,"",function(res){
            if(res.code==1){
                DelProgressObjs()
                MessagePopup.TipZero_success (arrJsPopLabel['SUCCESSFULLYSAVED'])
                //清空待保存分组列表
                that.groupListToSave.splice(0,that.groupListToSave.length)
                //刷新管理分组右侧抽屉
                var groupListObj=res.result.groupList;
                //groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
                //groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
                // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
                groupListObj = groupListObj.reduce((acc, curr, index) => {
                    acc[index] = curr;
                    return acc;
                }, {});
                that.groupList=groupListObj;
                if(isDrag != 'yes'){
                    that.Show_Listview_group_drawer_content();
                }
                //刷新查询分类弹出框左侧分组列表
                that.reloadCustomViewPopup();

            }
        });
    }
    //保存分组后刷新左侧查询分类弹出框
    this.reloadCustomViewPopup=function(){
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewobj = ld('#'+popupObj.divid+' #customListSequence');
        var url="index.php?module="+that.custom_info+"&action="+that.custom_info+"Ajax&file=ViewOrderEditSave&reloadCustomViewPopup=yes";
        ldAjaxsync(url,'',function(res) {
            DelProgressObjs()
            customviewobj.html(res.result);
            ld(document).ready(function(){
                var customviewGroupobj = ld('#'+popupObj.divid+' #showCustomlist_new');
                if(customviewGroupobj.hasClass('activate')){
                }
                else{
                    customviewGroupobj.addClass('activate')
                    customviewGroupobj.find('.ld_icon_arrowdown').css('transform','translateY(60%) rotate(-45deg)');
                    customviewGroupobj.find('.ld_icon_arrowdown').css('margin','8px 2px 0px 8px');
                }
                ld('#'+popupObj.divid+' #customListSequence #shujufenlei_new_optionlistbg').show();
            })
        })
    }
    //点击收藏刷新左侧弹出框的分组菜单栏
    this.reloadCustomViewPopupGroupList=function(){
        var popupObj = CrmPopup.getPopupObj("last");
        var customviewGroupListobj = ld('#'+popupObj.divid+' .customview_oplist_group_ul');
        var customviewGroupActiveobj=customviewGroupListobj.find('.customview_oplist_group_li.activate').attr('groupid')
        var url="index.php?module="+that.custom_info+"&action="+that.custom_info+"Ajax&file=ViewOrderEditSave&reloadCustomViewPopupGroupList=yes&customviewGroupActiveobj="+customviewGroupActiveobj;
        ldAjaxsync(url,'',function(res) {
            DelProgressObjs()
            customviewGroupListobj.html(res.result);
        })
    }
    //点击删除事件
    this.deleteGroup=function(groupObj){
        var isContent='no'
        var groupToDelete
        var selectedGroupid=ld(groupObj).closest('.listview_group_drawer_content_list_li').attr('groupid')
        var selectedGroupName=ld(groupObj).closest('.listview_group_drawer_content_list_li').attr('groupname')
        for(let key in that.groupList){
            if (that.groupList.hasOwnProperty(key)) { // 检查对象是否具有该属性
                const group = that.groupList[key];
                if (group && group.groupid == selectedGroupid) { // 检查 group 是否存在，并检查 groupid
                    groupToDelete = group
                }
                //待删除的分组下有查询分类
                /*if (group.groupid == selectedGroupid && group.cvCount > 0) {
                    RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['CONFIRME'], arrJsPopLabel['CANCEL'], arrJsPopLabel['Blockingdeletionofgroups']);
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        var popupobj = CrmPopup.getPopupObj('last');
                        popupobj.CancelEvent();
                        that.moveGroup(groupToDelete);
                    })
                    isContent = 'yes'
                    return false;
                }*/
            }
        }
        var liobj = ld(groupObj).closest('.listview_group_drawer_content_list_li');//customview_list_li_content
        if(liobj.find('[name=customview_list_li_content]').length > 0){
            RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['CONFIRME'], arrJsPopLabel['CANCEL'], arrJsPopLabel['Blockingdeletionofgroups']);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                var popupobj = CrmPopup.getPopupObj('last');
                popupobj.CancelEvent();
                that.moveGroup(groupToDelete);
            })
            isContent = 'yes'
            return false;
        }
        if(isContent=='yes')
        {
            return false;
        }
        //待删除的分组下没有查询分类
        groupToDelete=JSON.stringify(groupToDelete)
        var RemindsMsg_content=arrJsPopLabel['DELETE']+"'"+selectedGroupName+"'"+arrJsPopLabel['deletegroup']
        RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['CONFIRME'], arrJsPopLabel['CANCEL'], RemindsMsg_content);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            var popupobj = CrmPopup.getPopupObj('last');
            popupobj.CancelEvent();
            that.deleteConfirm(groupToDelete);
        })
    }
    this.deleteConfirm=function(groupToDelete){
        var url="index.php?module="+that.custom_info+"&action="+that.custom_info+"Ajax&file=ViewOrderEditSave&groupToDelete="+groupToDelete;
        ldAjax(url,'',function(res) {
            if(res.code==1){
                DelProgressObjs()
                //刷新管理分组右侧抽屉
                var groupListObj=res.result.groupList;
                //groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
                //groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
                // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
                groupListObj = groupListObj.reduce((acc, curr, index) => {
                    acc[index] = curr;
                    return acc;
                }, {});
                that.groupList=groupListObj;
                that.Show_Listview_group_drawer_content();
                //刷新查询分类弹出框左侧分组列表
                that.reloadCustomViewPopup();

            }
        })
    }
    //如果待删除的分组下有查询分类，转移分组
    this.moveGroup=function(groupToDelete){
        var crmPopUpObj=CrmPopup.load(arrJsPopLabel['DELETEGROUPING'],"","","LdPopWidth800px",that.custom_info,"","","","");
        var popUpHtml='<div id="setUserGroupField_content" style="width:100%;">\n' +
            '    <div name="field_table_body" style="width:100%;">\n' +
            '        <table class="settingPopTable lasttdbordernon field_table_body_table" border="0" cellpadding="0" cellspacing="0" width="100%">\n' +
            '            <tr class="ld-form-item">\n' +
            '                <td class="ld-form-item-label">'+arrJsPopLabel['GROUPSTOBEDELETED']+
            '                </td>\n' +
            '                <td class="ld-form-item-content group-to-delete" groupid='+groupToDelete.groupid+'>'+groupToDelete.group_name+
            '                </td>\n' +
            '            </tr>\n' +
            '            <tr>\n' +
            '                <td class="ld-form-item-label">'+arrJsPopLabel['CONVERTCATEGORIEDTOGROUP']+
            '                </td>\n' +
            '                <td class="ld-form-item-content" style="overflow: auto;">\n' +
            '                    <select id="selectCvGroupColumns" class="selectCvGroup"  name="selectCvGroupColumns">'
        for(let key in that.groupList){
            if(that.groupList[key].groupid!=groupToDelete.groupid){
                popUpHtml+='<option value='+that.groupList[key].groupid+'>'+that.groupList[key].group_name+'</option>'
            }
        }
        popUpHtml+='<option value=ungrouped>'+arrJsPopLabel['ungrouped']+'</option>'
        popUpHtml+='                    </select>\n' +
                '                </td>\n' +
                '            </tr>\n' +
                '        </table>\n' +
                '    </div>\n' +
                '</div>'
                crmPopUpObj.setParams(arrJsPopLabel['DELETEGROUPING'],that.deletePopupConfirm,"","LdPopWidth450px",that.custom_info,groupToDelete,arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL'])
                crmPopUpObj.show(popUpHtml);
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("selectCvGroupColumns");
        cls_resetComboxHtmlobj.setComboxObjHtml();
        that.selectChange()
    }
    this.deletePopupConfirm=function (groupToDelete){
        var popupObj = CrmPopup.getPopupObj("last");
        var groupidToDelete=ld('#'+popupObj.divid+' .group-to-delete').attr('groupid')
        groupToDelete=JSON.stringify(groupToDelete)
        var url="index.php?module="+that.custom_info+"&action="+that.custom_info+"Ajax&file=ViewOrderEditSave&groupObjToDelete="+groupToDelete+"&groupidToMove="+that.selectedGroupid;
        ldAjax(url,'',function(res){
            if(res.code==1)
            {
                DelProgressObjs()
                popupobj.CancelEvent();
                //刷新管理分组右侧抽屉
                var groupListObj=res.result.groupList;
                //groupListObj = groupListObj.filter(group => group.groupid !== 'commonCustomView');
                //groupListObj = groupListObj.filter(group => group.groupid !== 'ungrouped');
                // 使用 reduce 方法将数组转换为对象，属性名从 0 开始递增
                groupListObj = groupListObj.reduce((acc, curr, index) => {
                    acc[index] = curr;
                    return acc;
                }, {});
                that.groupList=groupListObj;
                that.Show_Listview_group_drawer_content();
                //刷新查询分类弹出框左侧分组列表
                that.reloadCustomViewPopup();
            }
        })
    }
    this.selectChange=function(){
        var popupObj = CrmPopup.getPopupObj("last");
        var selectedValue = ld('#'+popupObj.divid+' select').val()
        that.selectedGroupid=selectedValue
        ld('#'+popupObj.divid+' select').on('change',function(){
            // 获取选中的 option 的值
            selectedValue = ld(this).val();
            that.selectedGroupid=selectedValue
        })
    }
    // 关闭弹出层后执行的操作,需重写
    this.afterClosePopup = function(){

    }
}