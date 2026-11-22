/*
 * editor:ljj
 * time:20240118
 * reason:XUQIU1000599
 * content:日程管理->日历视图，可自定义单据背景色和字体颜色（杨雅媚）
 * node:自定义颜色 新建、编辑、颜色改变、状态改变、删除、拖拽js
 * */
function CalendarColorSettings(){
    var that=this;

    //新建
    this.create=function (){
        var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
        url += '&mode=create';
        var popupobj = CrmPopup.load("","","","LdPopWidth800px",'Calendar',"","","","");
        popupobj.prevshow();
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                popupobj.setParams(data.result.title,CalendarColorSettings.getInstance().save,'',"LdPopWidth800px",'Calendar',"",data.result.oktext,"",data.result.canceltext);
                //高级查找
                popupobj.advanceSearchDivid=popupobj.divid;
                popupobj.option='create';
                //日期数组
                datetimestr=data.result.datetimestr;
                //这个方法加载可以加载高级查找tpl内的js代码
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);
                ld('#'+popupobj.divid+' #'+popupobj.divid+'_scroll').css('overflow-y','hidden');
                ld('#'+popupobj.divid).find('[name=addNewConditionGroup]').parent().before(data.result.tipcontent);

                var advancefilterobj = new cls_advanceFilter();
                var params = {};
                params.columnOptionHtml = data.result.fieldnames;
                params.fLabels = data.result.fLabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.advfilterhtml;
                params.criteria_groups_arr = data.result.criteria_groups;
                params.module = 'Calendar';
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advancefilterobj.showAdvanceFilter(popupobj,params);
                DelProgressObjs();
            }
        });
    }
    //编辑
    this.edit=function (ruleid){
        var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
        url += '&mode=edit&ruleid='+ruleid;
        var popupobj = CrmPopup.load("","","","LdPopWidth800px",'Calendar',"","","","");
        popupobj.prevshow();
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                popupobj.setParams(data.result.title,CalendarColorSettings.getInstance().save,'',"LdPopWidth800px",'Calendar',"",data.result.oktext,"",data.result.canceltext);
                //高级查找
                popupobj.advanceSearchDivid=popupobj.divid;
                //日期数组
                datetimestr=data.result.datetimestr;
                popupobj.option='edit';
                //这个方法加载可以加载高级查找tpl内的js代码
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);
                ld('#'+popupobj.divid+' #'+popupobj.divid+'_scroll').css('overflow-y','hidden');
                ld('#'+popupobj.divid).find('[name=addNewConditionGroup]').parent().before(data.result.tipcontent);

                var advancefilterobj = new cls_advanceFilter();
                var params = {};
                params.columnOptionHtml = data.result.fieldnames;
                params.fLabels = data.result.fLabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.advfilterhtml;
                params.criteria_groups_arr = data.result.criteria_groups;
                params.module = 'Calendar';
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advancefilterobj.showAdvanceFilter(popupobj,params);
                DelProgressObjs();
            }
        });
    }

    //新增和编辑保存
    this.save=function (){
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var name=ld('#'+divid).find('[name=rulename]').val();
        if (empty(name)){
            ld("#"+divid).find('[name=rulename]').addClass("border_red1");
            MessagePopup.TipZero_warning(arrJsPopLabel['RULENAMECANOTEMPTY']);
            return false;
        }
        var backgroundcolor=ld('#'+divid).find('[name=backgroundcolor]').attr('color');
        var textcolor=ld('#'+divid).find('[name=textcolor]').attr('color');
        var checked=ld('#'+divid).find('[name=ruleStatus]').prop('checked');
        var status=checked==true?'yes':'no';
        if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
        var advft_criteria = popupobj.advft_criteria;
        if (advft_criteria == '[]'){//规则条件不能为空
            MessagePopup.TipZero_warning(arrJsPopLabel['RULECONDITIONSCANOTEMPTY']);
            return false;
        }
        var advft_criteria_groups = popupobj.advft_criteria_groups;
        var option=popupobj.option;
        var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings&mode=save&option='+option;
        if (option == 'edit'){
            var ruleid=ld('#'+divid).find('[name=rulename]').attr('ruleid');
            url += '&ruleid='+ruleid;
        }
        var params={'name':name,'backgroundcolor':backgroundcolor,'textcolor':textcolor,'status':status,'advft_criteria':advft_criteria,'advft_criteria_groups':advft_criteria_groups}
        ldAjax(url,params,function (data) {
            if (data.code == 1){
                DelProgressObjs();
                popupobj.CancelEvent();
                MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
                var crmpopupobj=CrmPopup.getPopupObj('last');
                ld("#"+crmpopupobj.divid).find('[name=color_rule_table]').html(data.result.content);
                that.moveTable();
            }
        })

    }
    //删除
    this.delete=function (ruleid){
        MessagePopup.TipTwo_warning(arrJsPopLabel['SUREWANTDELETE']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        var confirm_button = ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]');
        confirm_button.bind('click',function () {
            var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
            url += '&mode=delete&ruleid='+ruleid;
            ldAjax(url,'',function (data) {
                if (data.code == 1){
                    DelProgressObjs();
                    var popupobj=CrmPopup.getPopupObj('last');
                    ld("#"+popupobj.divid).find('[name=color_rule_table]').html(data.result.content);
                    that.moveTable();
                    MessagePopup.TipZero_success(arrJsPopLabel['Successfullyremoved']);
                    popupobj.center();
                }
            });
        });
    }

    //改变状态
    this.changeStatus=function (obj,ruleid){
        var checked=ld(obj).prop('checked');
        checked=checked==true?'yes':'no';
        if (ruleid == 'CalendarCustomColorStatus'){
            var url = "index.php?module=Calendar&action=CalendarAjax&file=calendarRemindSet&mode=save&option=color&status="+checked;
            ldAjax(url,'',function (data) {
                DelProgressObjs();
            });
        }else {
            var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
            url += '&mode=changeStatus&ruleid='+ruleid;
            url += '&status='+checked;
            ldAjax(url,'',function (data) {
                DelProgressObjs();
            });
        }
    }

    //选择颜色
    this.changeColor=function (obj,ruleid,type){
        var pick_color = ld(obj).attr('color');
        var css_type = pick_color == '' || pick_color == undefined ? '#F3F3FC' : pick_color;
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth400px", 'Calendar', "", "", "", "");
        crmPopupobj.prevshow();
        var url = 'index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
        var dataurl = 'selectedcolor=' + css_type;
        ldAjaxNoProgress(url, dataurl, function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title, '', "", "LdPopWidth400px", 'Settings', "", '', "", '');
                crmPopupobj.show(data.result.content);
                var divid = crmPopupobj.divid;
                crmPopupobj.colortype = type;
                //加载自定义
                that.getColPick(obj, crmPopupobj,ruleid);
                //页签点击事件
                ld("#" + divid + " #changetab").find('[name=tag]').unbind('click').bind('click', function () {
                    //隐藏之前选中的页签
                    var selected = ld("#" + divid + " #changetab").find('.ld-change-tab-active');
                    ld('#' + divid + ' #' + selected.attr('tag')).hide();
                    selected.removeClass('ld-change-tab-active');
                    //显示选中页签
                    var tag = ld(this).attr('tag');
                    ld(this).addClass('ld-change-tab-active');
                    ld('#' + divid + ' #' + tag).show();
                });
                //浅色亮色色块点击事件
                var color = ld('#' + divid + ' #preset').find('[name=presetcolor_li]');
                ld(color).unbind('click').bind('click', function () {
                    var selectedcolor = ld(this).find('[name=presetcolor]').attr('color');
                    // var rgba=that.getColorRgba(selectedcolor);
                    if (ruleid != 'create' && ruleid != 'edit'){//非新建、编辑界面
                        var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
                        url += '&mode=changeColor&type='+type+'&ruleid='+ruleid;
                        var param= {'color':selectedcolor};
                        ldAjax(url,param,function (data) {
                            if (data.code == 1){
                                DelProgressObjs();
                            }
                        });
                    }
                    crmPopupobj.CancelEvent();
                    ld(obj).css('background', selectedcolor);
                    ld(obj).attr('color', selectedcolor);
                })
            }
        });
    }

    this.getColPick=function (obj,popupobj,ruleid) {
        var pick_color = ld(obj).attr('color');
        var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
        getJsScript('include/js/colpick/colpick.js',function(){
            getJsScript('include/js/colpick/plugin.js',function(){
                var divid = popupobj.divid;
                CrmPopup.findHtmlobj(divid,'picker').colpick({
                    color:css_type,
                    flat:true,
                    layout:'RGB',
                    submitText:arrJsPopLabel['CONFIRME'],
                    onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                        var _color = '#'+hex;
                        if (ruleid != 'create' && ruleid != 'edit'){//非新建、编辑界面
                            var url='index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings';
                            url += '&mode=changeColor&type='+popupobj.colortype+'&ruleid='+ruleid;
                            var param= {'color':_color};
                            ldAjax(url,param,function (data) {
                                if (data.code == 1){
                                    DelProgressObjs();
                                }
                            });
                        }
                        popupobj.CancelEvent();
                        ld(obj).css('background',_color);
                        ld(obj).attr('color',_color);
                    }

                });
                popupobj.center();
            });
        });
    }
    //拖拽排序
     this.moveTable=function (){
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var length=ld('#'+divid+' [name=color_rule_table] tr').length;
        if (length <= 2){//无数据或者只有一行数据 不加载拖动排序
            return false;
        }
        tooltip("#"+divid+" [tag=dragsort]", {transition: true, time: 200});
        ld('#'+divid+' [name=color_rule_table] tr').hover(function(){
            ld('#'+divid+' .ld-dragicon').hide()
            ld(this).find('.ld-dragicon').show();
        });
        var dragobj = ld('#'+divid+" [name=color_rule_table]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".ld-calendar-colorsetting",//tr的class
            handle: ".drag-handle",
            onEnd: function (evt){
                var sort_arr='';
                var ruleid = '';
                var tableobj = ld('#'+divid+' [name=color_rule_table]').find("tr");
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
                            ruleid=ld(tmpobj).attr('ruleid');
                            sort_arr+=ruleid+",";
                        }else{
                            ld(tmpobj).addClass('lvtColData');
                            ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                            ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                            ld(tmpobj.childNodes[1]).html(index);
                            ruleid=ld(tmpobj).attr('ruleid');
                            sort_arr+=ruleid+",";
                        }
                    }
                });
                if (sort_arr != '') {
                    var url = 'index.php?module=Calendar&action=CalendarAjax&file=calendarColorSettings&mode=changePriority&sort_arr=' + sort_arr;
                    ldAjax(url, '', function (data) {
                        if (data.code == 1) {
                            ld("#"+popupobj.divid).find('[name=color_rule_table]').html(data.result.content);
                            that.moveTable();
                            DelProgressObjs();
                        }
                    })
                }
            }

        })
    }

}
CalendarColorSettings.curobj = '';
CalendarColorSettings.getInstance=function(){
    if (CalendarColorSettings.cur_obj == null ){
        CalendarColorSettings.cur_obj = new CalendarColorSettings();
    }
    return CalendarColorSettings.cur_obj;
}