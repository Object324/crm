//右侧设置抽屉，不带分组，只有分类
var CustomViewCategoryRightSetting = function(){
    // 调用父类构造函数
    CustomViewGroupRightSetting.call(this);
    let that = this;
    this.prevpopup_zindex = 0;// 上一级弹出层的z-index
    var parent_showCustomViewGroupRightSetting = this.showCustomViewGroupRightSetting;
    this.showCustomViewGroupRightSetting=function(){
        parent_showCustomViewGroupRightSetting.call(this);// 调用父类函数
        if(this.prevpopup_zindex != 0){
            // 根据上一级弹出层z-index，调整弹出层层级
            ld('#listview_setting_cover').css('z-index',(this.prevpopup_zindex+1));
            ld('#ld-listview-group-right-setting-drawer').css('z-index',(this.prevpopup_zindex+2));
            CrmPopup.zIndex = this.prevpopup_zindex+3;
        }
    }
    this.Show_Listview_group_drawer_content=function(){
        var listview_group_drawer_content_html='<div class="first-drawer-header group-first-drawer-header">\n' +
            '    <span class="first-drawer-title">'+arrJsPopLabel['ClassificationSettings']+'</span>\n' +
            '    <div class="first-drawer-headerbtn">\n' +
            '        <button type="button"><i class="ld-fonticon ld-fonticon-close"></i></button>\n' +
            '    </div>\n' +
            '</div>'

        //查询分类分组内容部分
        listview_group_drawer_content_html+='<div class="">\n' +
            '<span></span>\n'+
            '</div>';
        listview_group_drawer_content_html += '<div class="listview_group_drawer_content_add" style="margin: 7px 0px 3px 0px;">'
                                                +'<div name="addcustomview" class="ld-button ld-button-primary"  onclick="event.stopPropagation();DataCategoryListPopup.add();" style="margin-right: 20px;margin-left: auto;display: flex;align-items: center;padding: 7px 12px !important;">'
                                                    +'<b class="group_drawer_content_icon group_drawer_content_icon_addwhite"></b>'+arrJsPopLabel['NEWCALASSIFICATION']
                                                +'</div></div>';
        //如果查询分类分组没有内容
        if(empty(that.groupList)) {
            listview_group_drawer_content_html += '<div class="listview_group_drawer_content_no">' +
                '<div class="listview_group_drawer_content_list_img"></div>' +
                '<div class="listview_group_drawer_content_list_tips">' + arrJsPopLabel['NOGrouping'] + '</div>' +
                '<div class="listview_group_drawer_content_list_btn">' +
                '<button type="button"><div class="listview_group_drawer_content_list_btn_img"></div><span>' + arrJsPopLabel['NEWCALASSIFICATION'] + '</span></button>' +
                '</div>' +
                '</div>'
        }
        //查询分类分组有内容,显示查询分类分组列表
        else{
            listview_group_drawer_content_html += '<div class="listview_group_drawer_content"><ul class="listview_group_drawer_content_list">';
            for (let key in that.groupList) {
                
                listview_group_drawer_content_html += '</ul><ul class="listview_group_drawer_content_list_ungroup">';
                listview_group_drawer_content_html += '<li class="listview_group_drawer_content_list_li_ungroup" groupid="'+that.groupList[key]['groupid']+'" groupname="'+that.groupList[key]['group_name']+'">';

                listview_group_drawer_content_html += '<div name="drawer_group_customiew_list" data-groupid="'+that.groupList[key]['groupid']+'" data-toggle="show">' +
                    '<ul class="listview_customeview_content_list" data-groupid="'+that.groupList[key]['groupid']+'">' +
                    '<li class="listview_customview_drawer_content_list_li" style="color: #999;"><div style="margin-left: 16px;">'+arrJsPopLabel['CATEGORYNAME']+'</div><div style="margin-left: auto;margin-right: 94px;">'+arrJsPopLabel['OPERATION']+'</div></li>'+
                    '</ul><ul name="group_vustomview_list_ul" class="listview_customeview_content_list listview_customeview_onlycategory_content_list" data-groupid="'+that.groupList[key]['groupid']+'">';
                if(that.groupList[key].cvList && that.groupList[key].cvList.length > 0){
                    for(let i = 0;i<that.groupList[key].cvList.length;i++){
                        var cvinfo = that.groupList[key].cvList[i];
                        if(cvinfo.drag_permit != 'no'){
                            if (i == that.groupList[key].cvList.length - 1) {
                                listview_group_drawer_content_html += '<li class="listview_customview_drawer_content_list_li last-child" name="customview_list_li_content" drag_premit="yes" data-cvid="' + cvinfo['cvid'] + '">'
                            } else {
                                listview_group_drawer_content_html += '<li class="listview_customview_drawer_content_list_li" name="customview_list_li_content" drag_premit="yes" data-cvid="' + cvinfo['cvid'] + '">'
                            }
                            listview_group_drawer_content_html += '<b class="ld-category-icon ld-category-drag drag-handle-custom" style="margin-left: 8px;"></b>';
                            
                        }else{
                            listview_group_drawer_content_html+= '<li class="listview_customview_drawer_content_list_li" name="customview_list_li_content" drag_premit="no" data-cvid="'+cvinfo['cvid']+'">'
                                + '<b class="" style="width: 17px;margin-left: 8px;"></b>';
                        }
                        listview_group_drawer_content_html+= '<div class="listview_cv_drawer_content_list_li_name">'+cvinfo['viewname']+'</div>' +
                            '<div class="customview_oplist_cv_li_btn" style="display: flex;margin-right: 10px;">';
                        if(cvinfo.edit_permit == 'yes'){
                            listview_group_drawer_content_html+='<a onclick="event.stopPropagation(); DataCategoryListPopup.Edit(this,'+cvinfo.cvid+');" style="margin-left: 16px;margin-right: 0;">'+arrJsPopLabel['EDIT']+'</a>';
                        }
                        if(that.allowcopy){
                            listview_group_drawer_content_html+='<a onclick="event.stopPropagation(); DataCategoryListPopup.Copy(this,'+cvinfo.cvid+')" style="margin-left: 16px;margin-right: 0;">'+arrJsPopLabel['COPY']+'</a>';
                        }
                        if(cvinfo.del_permit == 'yes' && cvinfo.viewnamedata != 'All'){
                            listview_group_drawer_content_html+='<a onclick="event.stopPropagation(); DataCategoryListPopup.delVal(this,'+cvinfo.cvid+')" style="margin-left: 16px;margin-right: 0;color: #EB1746;">'+arrJsPopLabel['DELETE']+'</a>';
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
    var parent_showCustomVibindshowafter = this.bindshowafter;
    this.bindshowafter = function () {
        parent_showCustomVibindshowafter.call(this);// 调用父类函数
        //绑定点击新建分组事件
        ld('.listview_group_drawer_content_add').find('.ld-button[name=addcustomview]').unbind('click');
    }
}