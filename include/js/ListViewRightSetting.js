//右侧设置抽屉
var ListViewRightSetting = function(){
    this.listpopupobj=CrmPopup.getPopupObj("last");
    let that = this;
    this.is_modefied = false;//页面是否修改设置   false表示未修改
    this.oldsearchtext = '';
    this.searchfield_arr = [];

    this.resetPopupobj = function (popupobj){
        that.listpopupobj=popupobj;
        this.bindiconclick();
    }

    this.bindiconclick = function (){
        ld('#listviewrightsetting_icon').unbind('click').bind('click',function (){
            that.Show_Listview_right_Setting();
        });
    }
    //显示抽屉
    this.Show_Listview_right_Setting = function (){
        that.is_modefied = false;
        var listview_setting_html = '<div class="first-modal" id="listview_setting_cover"></div>\n' +
            '<div class="ld-listview-right-setting-drawer" id="ld-listview-right-setting-drawer">' +
            '<div class="el-loading-spinner"><svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg></div></div>';
        ld(listview_setting_html).appendTo("body");
        that.Show_Listview_drawer_content();

    }
    //显示抽屉内容
    this.Show_Listview_drawer_content = function (){
        var customview_record = ld('#'+that.listpopupobj.divid+' #viewname').val();
        var surl = 'index.php?module='+that.listpopupobj.module+'&action='+that.listpopupobj.module+'Ajax&file=ListViewRightSetting&returnModule='+that.listpopupobj.module+'&record='+customview_record;
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                ld('#rptContentLoading').hide();
                ld('#ld-listview-right-setting-drawer').html(data.result.content);
                ld('[name=listpagecount][value='+data.result.listpagecount+']').prop('checked',true);
                ld('[name=listpageheight][value='+data.result.listpageheight+']').prop('checked',true);
                this.listpagecount_value_pre = data.result.listpagecount;
                listpageheight_value_pre = data.result.listpageheight;
                that.bindshowafter();

                //@edit:ljj,2023-08-08,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块
                if(CrmPopup.getPopupObj('last').divid == 'ld-listview-right-setting-drawer'){
                    obj = CrmPopup.getPopupObj('last');
                }
                else{
                    var obj=new Object();
                    obj.divid="ld-listview-right-setting-drawer";
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.CancelEvent=function(){
                        return false;
                    }
                }
                var selectentity=ld(" .ld-listview-right-setting-entity .ld_combobox-components").find("[fieldtype=selectentityname]");
                if(selectentity.length>0&&selectentity!=undefined) {
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectentity.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectentity, 240);
                }
                // 动态赋予中间内容高度，去掉头部底部
                var content_height = ld('#ld-listview-right-setting-drawer').height() - ld('#first-drawer-header').outerHeight() - ld('#ld-listview-right-setting-bottombtn').outerHeight();
                ld('#ld-listview-right-setting-content').css('height',content_height+'px');
            }
        });
    }
    //内容绑定事件
    this.bindshowafter = function (){
        //绑定拖动
        if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").length > 0) {
            Sortable.create(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul").get(0), {
                group: 'fieldlayout',
                draggable: ".ld-category-draggable",//230706 wyt BUG0069209 列表界面，快速设置字段，改成按钮拖动事件，不要整行拖动；悬浮事件也需要优化一下
                //handle: ".drag-handle",
                animation: 150,
                sort: true,
                onEnd: function (evt) {
                    that.is_modefied = true;
                }
            });
        }
        //XUQIU1000536 zl 230706 获取操作按钮设置的按钮ul
        if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btnsettingself ul li").length > 0) {
            Sortable.create(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btnsettingself #ld-listview-right-setting-btn-self ul").get(0), {
                group: 'btnselfsetting',
                draggable: ".drag-handle",
                animation: 150,
                sort: true,
                onEnd: function (evt) {
                    that.is_modefied = true;
                }
            });
        }
         if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btnsettingrely ul li").length > 0) {
            Sortable.create(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btnsettingrely #ld-listview-right-setting-btn-rely ul").get(0), {
                group: 'btnrelysetting',
                draggable: ".drag-handle",
                animation: 150,
                sort: true,
                onEnd: function (evt) {
                    that.is_modefied = true;
                }
            });
        }
        if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").length > 0) {
            Sortable.create(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul").get(0), {
                group: 'actionlinklayout',
                draggable: ".ld-category-draggable",//230706 wyt BUG0069209 列表界面，快速设置字段，改成按钮拖动事件，不要整行拖动；悬浮事件也需要优化一下
                //handle: ".drag-handle",
                animation: 150,
                sort: true,
                onEnd: function (evt) {
                    that.is_modefied = true;
                }
            });
        }
        //绑定关闭
        ld('#ld-listview-right-setting-drawer .first-drawer-headerbtn i.ld-fonticon-close').unbind('click').bind('click',function (){
            that.Hide_Listview_right_Setting();
        });
        ld('#listview_setting_cover').unbind('click').bind('click',function (){
            that.Hide_Listview_right_Setting();
        });
        //重置
        ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-resetting').unbind('click').bind('click',function (){
            that.Show_Listview_drawer_content();
            that.is_modefied = false;
        });
        //保存
        ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-application').unbind('click').bind('click',function (){
            that.Save_Listview_right_Setting();
        });
        //开启关闭字段
        // gxj 230713 BUG0069439 kfbcrm-客户管理-列表设置-开启一个字段后，点击拖动字段顺序，没反应
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li input[type='checkbox']").change(function (){
            if(ld(this).get(0).checked == true){
                ld(this).parent().addClass('ld-category-draggable');
                ld(this).parent().find('i.ld-field_set-drog').show();
                var field_check_array = ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li input[type='checkbox']:checked");
                if(field_check_array.length >1){
                    //field_check_array.eq(field_check_array.length - 2).parent().after(ld(this).parent().get(0));
                }else{
                    ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li input[type='checkbox']").eq(0).parent().before(ld(this).parent().get(0));
                }
            }else {
                ld(this).parent().removeClass('ld-category-draggable');
                ld(this).parent().find('i.ld-field_set-drog').hide();
                var field_check_array = ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li input[type='checkbox']:checked");
                if(field_check_array.length >0){
                    //field_check_array.eq(field_check_array.length - 1).parent().after(ld(this).parent().get(0));
                }else{
                    ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li input[type='checkbox']").eq(0).parent().before(ld(this).parent().get(0));
                }
            }
            that.is_modefied = true;
        })
        //开启关闭操作列按钮
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li input[type='checkbox']").change(function (){
            if(ld(this).get(0).checked == true){
                ld(this).parent().addClass('ld-category-draggable');
                ld(this).parent().find('i.ld-field_set-drog').show();
                var link_check_array = ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li input[type='checkbox']:checked");
                if(link_check_array.length >1){
                    //link_check_array.eq(link_check_array.length - 2).parent().after(ld(this).parent().get(0));
                }else{
                    ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li input[type='checkbox']").eq(0).parent().before(ld(this).parent().get(0));
                }
            }else {
                ld(this).parent().removeClass('ld-category-draggable');
                ld(this).parent().find('i.ld-field_set-drog').hide();
                var link_check_array = ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li input[type='checkbox']:checked");
                if(link_check_array.length >0){
                    //link_check_array.eq(link_check_array.length - 1).parent().after(ld(this).parent().get(0));
                }else{
                    ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li input[type='checkbox']").eq(0).parent().before(ld(this).parent().get(0));
                }}
            that.is_modefied = true;
        })
        //@edit:ljj,2023-08-08,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块
        ld('#ld-listview-right-setting-drawer [name=entitiy-select]').change(function (){
            that.is_modefied = true;
        });
        //230704 wym BUG0068804 kfbcrm-单据列表右侧设置-表格设置两个参数，修改后点击空白区域，应弹出提示信息
        ld("#ld-listview-right-setting-drawer .el-radio-group label.el-radio-button").unbind('click').bind('click',function (){
            if(ld(this).find("input[name=listpagecount]").length>0){
                if(listpagecount_value_pre == ld('input[name=listpagecount]:checked').val()){
                    that.is_modefied = false;
                }else {
                    that.is_modefied = true;
                }
            }else if(ld(this).find("input[name=listpageheight]").length>0){
                if(listpageheight_value_pre == ld('input[name=listpageheight]:checked').val()){
                    that.is_modefied = false;
                }else {
                    that.is_modefied = true;
                }
            }
        })
        //XUQIU1000536 zl 230706 设置操作按钮个数,为"+"和"-"绑定点击事件
        // wym 230717 列表设置显示按钮个数输入值只能在0-8 且输入完后数值就得更改
        var numinput = ld('input[name=shownum]').val();
        ld('input[name=shownum]').on('change',function (){
            if(1<=ld('input[name=shownum]').val() && ld('input[name=shownum]').val()<=4){
                numinput = ld('input[name=shownum]').val();
            }else {
                ld('input[name=shownum]').val(numinput)
            }
        });
        ld('#dwbtn').click(function () {
            if(numinput >= 2){
                ld('input[name=shownum]').val(--numinput);
            }
            return false;
        });
        ld('#upbtn').click(function () {
            if(numinput <= 3){
                ld('input[name=shownum]').val(++numinput);
            }
            return false;
        });
        this.bindtopbutn = function (e){
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").eq(0).before(ld(e).parent().parent().get(0).outerHTML);
            // if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").hasClass('ld-category-draggable')){
            // }else{
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").eq(0).addClass('ld-category-draggable');
            // }
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").eq(0).find("input[type='checkbox']").get(0).checked = true;
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").eq(0).find('i.ld-field_set-drog').show();
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").eq(0).find('i.ld-field_set-top').unbind('click').bind('click',function (){
                that.bindtopbutn(this);
            });
            ld(e).parent().parent().remove();
            that.is_modefied = true;
        }
        //字段置顶
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li i.ld-field_set-top").unbind('click').bind('click',function (){
            that.bindtopbutn(this);
        });
        this.bindtoplink = function (e){
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").eq(0).before(ld(e).parent().parent().get(0).outerHTML);
            // if(ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li").hasClass('ld-category-draggable')){
            // }else{
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").eq(0).addClass('ld-category-draggable');
            // }
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").eq(0).find("input[type='checkbox']").get(0).checked = true;
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").eq(0).find('i.ld-field_set-drog').show();
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li").eq(0).find('i.ld-field_set-top').unbind('click').bind('click',function (){
                that.bindtoplink(this);
            });
            ld(e).parent().parent().remove();
            that.is_modefied = true;
        }
        //操作列按钮置顶
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li i.ld-field_set-top").unbind('click').bind('click',function (){
            that.bindtoplink(this);
        });
        //字段置顶--操作按钮设置
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-self ul li i.ld-field_set-top").unbind('click').bind('click',function (){
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-self ul li").eq(0).before(ld(this).parent().parent().get(0).outerHTML);
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-self ul li").eq(0).addClass('drag-handle');
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-self ul li").eq(0).find('i.ld-field_set-drog').show();
            ld(this).parent().parent().remove();
        });
        ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-rely ul li i.ld-field_set-top").unbind('click').bind('click',function (){
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-rely ul li").eq(0).before(ld(this).parent().parent().get(0).outerHTML);
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-rely ul li").eq(0).addClass('drag-handle');
            ld("#ld-listview-right-setting-drawer #ld-listview-right-setting-btn-rely ul li").eq(0).find('i.ld-field_set-drog').show();
            ld(this).parent().parent().remove();
        });
        //搜索绑定
        ld('#ld-listview-right-setting-drawer #search_field').unbind('input').bind('input',function (){
            that.searchField(this);
        });
        ld('#ld-listview-right-setting-drawer #search_field').unbind('keydown').bind('keydown',function (){
            var e = event || window.event;
            if(e.keyCode == 13){
                that.searchField(this);
            }
        });
        //收起展开
        ld('.DivCName').unbind('click').bind('click',function (){
            var blocktype = ld(this).data('blocktype');
            if(ld(this).find('span').get(0).className == 'On'){
                ld(this).find('span').removeClass('On');
                ld(this).removeClass('ld-shadow-first');
                ld('#ld-listview-right-setting-'+blocktype).show();
            }else{
                ld(this).find('span').addClass('On');
                ld(this).addClass('ld-shadow-first');
                ld('#ld-listview-right-setting-'+blocktype).hide();
            }
        })
        //列表工具
        ld('#ld-listview-right-setting-pagesetting').find('input[type=checked]').unbind('change').bind('change',function () {
            that.is_modefied = true;
        })
    }

    this.searchField = function (obj) {
        var search_str = ld(obj).val();
        if(search_str == ''){
            ld.each(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li p'),function (){
                if(ld(this).find('span').length>0){
                    ld(this).html(ld(this).parent().data('fieldtable'));
                }
            });
        }else{
            ld.each(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li p'),function (){
                if(ld(this).find('span').length>0){
                    ld(this).html(ld(this).parent().data('fieldtable'));
                }
            });
            // BUG20240702-13 “服务合同”右上角的“设置”->“字段设置”搜索字段应改为不区分大小写与拼音  字段名称为Test，搜索关键词为“test”，搜索不到Test字段。
            var fieldtableonbj = ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li[data-fieldtable]');
            var tmpScrollTo = 'no';
            if (fieldtableonbj.length > 0){
                var search_num = 0;
                ld.each(fieldtableonbj,function (index,tmpobj) {
                    var fieldtable_str = ld(tmpobj).data('fieldtable');
                    var fieldtable_tmp_str = fieldtable_str.toLowerCase();
                    var tmp_search_str = search_str.toLowerCase();
                    var str_location = fieldtable_tmp_str.indexOf(tmp_search_str);
                    if (str_location > -1){
                        search_str = fieldtable_str.slice(str_location,str_location+search_str.length);
                        var field_label = ld(tmpobj).find('p').html();
                        var span_html = '<span class="ld-Highlight">' + search_str + '</span>';
                        var reg = new RegExp(search_str, "g");
                        var new_field_label = field_label.replace(reg, span_html);
                        ld(tmpobj).find('p').html(new_field_label);
                        search_num++ ;

                        if (tmpScrollTo == 'no'){
                            var value = ld(tmpobj).find('input:first').data('value');
                            var isscrollTo = 'no';
                            var position = ld(tmpobj).offset();
                            var top = position.top-150;
                            var scrolltop = ld('#ld-listview-right-setting-content').scrollTop();
                            if (that.oldsearchtext == search_str){
                                if (!that.searchfield_arr.includes(value)){
                                    that.searchfield_arr.push(value);
                                    isscrollTo = 'yes'
                                }
                            }else {
                                that.searchfield_arr = [];
                                that.searchfield_arr.push(value);
                                that.oldsearchtext = search_str;
                                isscrollTo = 'yes'
                            }
                            if (isscrollTo == 'yes'){
                                ld('#ld-listview-right-setting-content').animate({scrollTop:scrolltop+top},100);
                                tmpScrollTo = 'yes';
                            }
                        }
                    }
                });
            }
            if (that.searchfield_arr.length == search_num){
                that.searchfield_arr = [];
            }

        }
    }

    //关闭弹框和弹出层
    this.Hide_Listview_right_Setting = function (){
        if(that.is_modefied == true) {
            var delete_str = arrJsPopLabel['FIELDMODIFIEDCLOSECHECk'];
            // ld('#listview_setting_cover').css('z-index',5002);
            // ld('#listview_setting_cover').unbind('click');
            RemindsMsg("", "LdPopWidth400px", "", arrJsPopLabel['SAVE'], arrJsPopLabel['CANCEL'], delete_str);
            //zkt 20230510 BUG0066145  	侧边栏通过提示的右上角关闭时出现异常 
            var popupobj = CrmPopup.getPopupObj('last');
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                popupobj.CancelEvent();
                // ld('#listview_setting_cover').css('z-index','5000');
                that.Save_Listview_right_Setting();
            })
            ld("#"+popupobj.divid+' .E_ptitc,input[tagclick="msgConfirmCancel').unbind('click').on('click', function () {
                ld('#listview_setting_cover').remove();
                ld('#ld-listview-right-setting-drawer').remove();
                //@edit:ljj,2023-08-11,reason:BUG0070909 模块超链接字段设置下拉选项设置“文本字段”为超链接字段，页面设置中，将“文本字段”取消必填，此时点击查询分类设置按钮，提示“模块未激活”
                if(CrmPopup.getPopupObj('last') && CrmPopup.getPopupObj('last').divid=="ld-listview-right-setting-drawer") {
                    CrmPopup.global_listPopupObj.pop();//把自建对象移除，移除当前弹出层
                }
            })
            ld("#"+popupobj.divid+' .ld-fonticon-close[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
                ld('#listview_setting_cover').remove();
                ld('#ld-listview-right-setting-drawer').remove();
                //@edit:ljj,2023-08-11,reason:BUG0070909 模块超链接字段设置下拉选项设置“文本字段”为超链接字段，页面设置中，将“文本字段”取消必填，此时点击查询分类设置按钮，提示“模块未激活”
                if(CrmPopup.getPopupObj('last') && CrmPopup.getPopupObj('last').divid=="ld-listview-right-setting-drawer") {
                    CrmPopup.global_listPopupObj.pop();//把自建对象移除，移除当前弹出层
                }
            })
        }else{
            //@edit:ljj,2023-08-11,reason:BUG0070909 模块超链接字段设置下拉选项设置“文本字段”为超链接字段，页面设置中，将“文本字段”取消必填，此时点击查询分类设置按钮，提示“模块未激活”
            ld('#listview_setting_cover').remove();
            ld('#ld-listview-right-setting-drawer').remove();
            //@edit:ljj,2023-08-11,reason:BUG0070909 模块超链接字段设置下拉选项设置“文本字段”为超链接字段，页面设置中，将“文本字段”取消必填，此时点击查询分类设置按钮，提示“模块未激活”
            if(CrmPopup.getPopupObj('last').divid="ld-listview-right-setting-drawer") {
                CrmPopup.global_listPopupObj.pop();//把自建对象移除，移除当前弹出层
            }
        }

    }
    //保存设置
    this.Save_Listview_right_Setting = function (){
        var ProductListView = '';
        var ProductListViewarr=new Array();
        if(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li').length > 0) {
            if (ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li').find("input[type='checkbox']:checked").length >= 3) {
                ld.each(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-field ul li').find("input[type='checkbox']:checked"),function (index, fieldobj) {
                    ProductListView += ld(this).data('value') + ',';
                    var tmparr=ld(this).data('value').split(':');
                    ProductListViewarr.push(tmparr[0]+':'+tmparr[2]);
                });
            } else {
                MessagePopup.TipOne_warning(arrJsPopLabel['COLUMNSELECTLEASTTHREE']);
                ld('input[tagclick="msgConfirm"]').bind('click', function () {
                    ld.each(ld('#ld-listview-right-setting-field').find('[checked_value=yes]:not(:checked)'),function (index,obj) {
                        ld(obj).prop('checked',true);
                        ld(obj).trigger('change');
                    })
                    ld.each(ld('#ld-listview-right-setting-field').find('[checked_value=no]:checked'),function (index,obj) {
                        ld(obj).prop('checked',false);
                        ld(obj).trigger('change');
                    })
                })
                return false;
            }
        }
        var Actionlink = '';
        if(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li').length > 0) {
             ld.each(ld('#ld-listview-right-setting-drawer #ld-listview-right-setting-actionlink ul li').find("input[type='checkbox']"),function (index, fieldobj) {
                 Actionlink += ld(this).next().data('tip') + ':'+ld(this).data('value') + ':'+ld(this).prop('checked')+',';
                });
        }
        ld('#rptContentLoading').show();
        var record = ld('#customview_record').val();
        if(ld('#ld-listview-right-setting-drawer input[name=listpagecount]:checked').length > 0) {
            var listpagecount_value = ld('#ld-listview-right-setting-drawer input[name=listpagecount]:checked').val();
        }
        if(ld('#ld-listview-right-setting-drawer input[name=listpageheight]:checked').length > 0) {
            var listpageheight_value = ld('#ld-listview-right-setting-drawer input[name=listpageheight]:checked').val();
        }
        //zl 230704 XUQIU1000536 列表按钮优化,增加传参:高级查找按钮状态、该按钮的label名(用于存储返回按钮状态)
        var highsearchbtn_status = '';
        if (ld("#ld-listview-right-setting-drawer input[name=Highersearch]").prop('checked')==true){
            highsearchbtn_status = 'yes';
        }else{
            highsearchbtn_status = 'no';
        }
        var highsearchbtn_label = ld("#ld-listview-right-setting-drawer input[name=Highersearch]").attr('name');

        //@edit:ljj,2023-08-11,reason:XUQIU1001663 单据序时簿列表界面，“操作按钮设置”区块，高级查找下方增加“平铺查找”开启、关闭参数
        var btn_url='';
        if(ld("#ld-listview-right-setting-drawer input[name=Tiledsearch]").length>0){
            if (ld("#ld-listview-right-setting-drawer input[name=Tiledsearch]").prop('checked')==true){
                tiledsearchbtn_status = 'yes';
            }else{
                tiledsearchbtn_status = 'no';
            }
            var tiledsearchbtn_label = ld("#ld-listview-right-setting-drawer input[name=Tiledsearch]").attr('name');
            btn_url+= '&tiledsearch='+tiledsearchbtn_status+'&tiledsearchbtnlabel='+tiledsearchbtn_label;
        }
        //wym BUG0076164 客户管理--将标签查找也纳入可设置隐藏
        if(ld("#ld-listview-right-setting-drawer input[name=Tagsearch]").length>0){
            if (ld("#ld-listview-right-setting-drawer input[name=Tagsearch]").prop('checked')==true){
                tagsearchbtn_status = 'yes';
            }else{
                tagsearchbtn_status = 'no';
            }
            var tagsearchbtn_label = ld("#ld-listview-right-setting-drawer input[name=Tagsearch]").attr('name');
            btn_url+= '&tagsearch='+tagsearchbtn_status+ '&tagsearchbtnlabel='+tagsearchbtn_label;
        }

        //wym BUG0076167 客户管理--地图和漏斗加入设置，可设置显示或隐藏
        if(ld("#ld-listview-right-setting-drawer input[name=Mapsearch]").length>0){
            if (ld("#ld-listview-right-setting-drawer input[name=Mapsearch]").prop('checked')==true){
                mapsearchbtn_status = 'yes';
            }else{
                mapsearchbtn_status = 'no';
            }
            var mapsearchbtn_label = ld("#ld-listview-right-setting-drawer input[name=Mapsearch]").attr('name');
            btn_url+= '&mapsearch='+mapsearchbtn_status+ '&mapsearchbtnlabel='+mapsearchbtn_label;
        }
        if(ld("#ld-listview-right-setting-drawer input[name=Chartsearch]").length>0){
            if (ld("#ld-listview-right-setting-drawer input[name=Chartsearch]").prop('checked')==true){
                chartsearchbtn_status = 'yes';
            }else{
                chartsearchbtn_status = 'no';
            }
            var chartsearchbtn_label = ld("#ld-listview-right-setting-drawer input[name=Chartsearch]").attr('name');
            btn_url+= '&chartsearch='+chartsearchbtn_status+ '&chartsearchbtnlabel='+chartsearchbtn_label;
        }

        //@edit:ljj,2023-08-09,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块
        var entity=ld('#ld-listview-right-setting-drawer [name=entitiy-select]').val();
        // ljj 20231102 BUG0074878 kfbcrm-价格表-模块超链接字段设置-不启用原超链接字段后，超链接字段应自动修改为下拉框中其他字段
        if (ProductListViewarr.indexOf(entity)==-1){
            var newentity=ld('#ld-listview-right-setting-drawer [name=entitiy-select]' ).find('option[value=""]').next();
            if (newentity.val() == entity){
                newentity=newentity.next();
            }
            entity=newentity.val();
        }
        if(empty(entity)){
            entity='';
        }
        var entity_name=entity.split(":");
        var entity_tablename=entity_name[0];
        var entity_fieldname=entity_name[1];

        url = 'index.php?module='+that.listpopupobj.module+'&action='+that.listpopupobj.module+'Ajax&file=SaveListViewRightSetting&cvmodule='+that.listpopupobj.module+
        '&record='+record+'&actionlink='+Actionlink+'&ProductListView='+ProductListView+'&listpageheight='+listpageheight_value+'&highersearch='+highsearchbtn_status+
        '&higsearchbtnlabel='+highsearchbtn_label+'&entity_tablename='+entity_tablename+'&entity_fieldname='+entity_fieldname+btn_url;
        //zl 230704 获取排序完成后的列表按钮为Listbuttonarr
        if(ld('#ld-listview-right-setting-drawer').find('#ld-listview-right-setting-btnsettingself #ld-listview-right-setting-btn-self ul li').length > 0) {
            var Listbuttonselfarr = '';
            var Listbuttonselfobj = ld('#ld-listview-right-setting-drawer').find('#ld-listview-right-setting-btnsettingself #ld-listview-right-setting-btn-self ul li');
            ld.each(Listbuttonselfobj,function (index, fieldobj) {
                Listbuttonselfarr += ld(this).find('p').data('tip') + ':';
                Listbuttonselfarr += ld(this).data('value') + ',';
            });
            url += '&Listbuttonselfarr='+Listbuttonselfarr;
        }
        if(ld('#ld-listview-right-setting-drawer').find('#ld-listview-right-setting-btnsettingrely #ld-listview-right-setting-btn-rely ul li').length > 0) {
            var Listbuttonrelyarr = '';
            var Listbuttonrelyobj = ld('#ld-listview-right-setting-drawer').find('#ld-listview-right-setting-btnsettingrely #ld-listview-right-setting-btn-rely ul li');
            ld.each(Listbuttonrelyobj,function (index, fieldobj) {
                Listbuttonrelyarr += ld(this).find('p').data('tip') + ':';
                Listbuttonrelyarr += ld(this).data('value') + ',';
            });
            url += '&Listbuttonrelyarr='+Listbuttonrelyarr;
        }
        if(ld('#ld-listview-right-setting-drawer input[name=listpagecount]:checked').length > 0) {
            url += '&listpagecount='+listpagecount_value;
        }
        //获取按钮个数
        if(ld('#ld-listview-right-setting-drawer input[name=shownum]').length>0){
            var shownum = ld('#ld-listview-right-setting-drawer input[name=shownum]').val();
            url += '&shownum='+shownum;
        }
        ldAjax(url,'',function (data){
            if(data.code == 1){
                ld('#listview_setting_cover').remove();
                ld('#ld-listview-right-setting-drawer').remove();
                //showDefaultCustomView(new Object,that.listpopupobj.module,'',ld("#selectcustomview_"+that.listpopupobj.module).val());
                //zxm BUG20240409-02 数据分类不要选择全部，列表右上角设置->保存，刷新整个页面之后，数据分类变成全部
                //getListViewEntries_js(that.listpopupobj.module, '');//刷新页面
                showDefaultCustomView(new Object,that.listpopupobj.module,'',ld("#"+that.listpopupobj.divid+" #viewname").val());
                //lmq 230615 保存后表格行高样式改变
                that.listpopupobj.TableLineHightSet = listpageheight_value;
                //wym 231225 BUG0077447 行高保存后没有刷新，要小圈转完了等2s才会刷新
                //ld('#rptContentLoading').hide();
                //@edit:ljj,2023-08-11,reason:BUG0070909 模块超链接字段设置下拉选项设置“文本字段”为超链接字段，页面设置中，将“文本字段”取消必填，此时点击查询分类设置按钮，提示“模块未激活”
                if(CrmPopup.getPopupObj('last').divid=="ld-listview-right-setting-drawer") {
                    CrmPopup.global_listPopupObj.pop();//把自建对象移除，移除当前弹出层
                }
            }
        });
    }

}
