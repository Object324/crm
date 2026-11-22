function CustomTablesSqlColumns () {
    //对齐方式数组
    this.alignList = {
        'left': {"value": "no", "label": arrJsPopLabel['AlignLeft']},
        'center': {"value": "no", "label": arrJsPopLabel['Centered']},
        'right': {"value": "no", "label": arrJsPopLabel['AlignRight']}
    }
    this.reportDetailHeaderObj = "";//表头
    this.popupobj = "";
    this.divid = "";
    this.mode = "init";
    this.report_id = "";
    var that = this;
    this.init = function(mode,CustomTablesSqlCreateObj){
        that.popupobj = CrmPopup.getPopupObj("last");
        if(that.popupobj){
            that.divid = that.popupobj.divid;
        }else{
            that.divid = "chartInfoForm";//链接模块
        }
        that.report_id = ld('#'+that.divid).find('#report_id').val();
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
        if(mode!=undefined){
            that.mode = mode;
        }
        that.setCreateObj(CustomTablesSqlCreateObj);
    }
    this.setCreateObj = function(CustomTablesSqlCreateObj){
        that.CustomTablesSqlCreateObj = CustomTablesSqlCreateObj;
    }
    this.setColumns = function(columns){
        that.columns = columns;
    }
    this.renderHeader = function(columnsArr){
        that.setColumns(columnsArr);
        //表头
        var headerHtml = '';
        if(columnsArr.length<=0){
            return 0;
        }
        var all_width = 0;
        ld.each(columnsArr,function(index,item){
            var th_width = item.header_width>0?item.header_width:200;
            all_width = parseInt(all_width)+parseInt(th_width);
            var sticky_class = item.issticky=='yes'?'set-sticky':'';
            headerHtml += '<th thindex="'+index+'" tag="'+item.columns+'" class="'+sticky_class+'" style="position: relative;width:'+th_width+'px;'+item.styleset_header+'">\n' +
                '<div class="thead-content">\n' +
                '    <b class="icon-homeimg icon-list-set" tag="showHideMenu"></b>\n' +
                '    <ol class="customtable-droplist droplist-show">\n';
            var is_merge_show = '';
            var is_merge_cancel_show = 'style="display:none;"';
            if(item.is_merge!='no'&&item.is_merge!='noselect'){
                //is_merge_show = 'style="display:none;"';
                is_merge_cancel_show = '';
            }
            if(item.is_merge=='no'||item.is_merge=='noselect'){
                //is_merge_show = '';
                is_merge_cancel_show = 'style="display:none;"';
            }
            var is_sticky_show = '';
            var is_sticky_cancel_show = 'style="display:none;"';
            if(item.issticky=='yes'){
                is_sticky_show = 'style="display:none;"';
                is_sticky_cancel_show = '';
            }
            if(item.issticky!='yes'){
                is_sticky_show = '';
                is_sticky_cancel_show = 'style="display:none;"';
            }
            if(index==columnsArr.length-1){
                is_sticky_show = 'style="display:none;"';
                is_sticky_cancel_show = 'style="display:none;"';
            }
            headerHtml += '<li class="canclick" tag="is_merge" '+is_merge_show+'>\n' +
                '<a title="'+arrJsPopLabel['Merge']+'">'+arrJsPopLabel['Mergemethod']+'</a>\n' +
                '</li>\n';
            headerHtml += '<li class="canclick" tag="is_merge_cancel" '+is_merge_cancel_show+'>\n' +
                '<a title="'+arrJsPopLabel['CMerge']+'">'+arrJsPopLabel['CMerge']+'</a>\n' +
                '</li>\n';
            headerHtml += '<li class="canclick" tag="is_sticky" '+is_sticky_show+'>\n' +
                '<a title="'+arrJsPopLabel['Freezetothiscolumn']+'">'+arrJsPopLabel['Freezetothiscolumn']+'</a>\n' +
                '</li>\n';
            headerHtml += '<li class="canclick" tag="is_sticky_cancel" '+is_sticky_cancel_show+'>\n' +
                '<a title="'+arrJsPopLabel['Unfreezecolumns']+'">'+arrJsPopLabel['Unfreezecolumns']+'</a>\n' +
                '</li>\n';
            headerHtml += '<li class="canclick" tag="style_set">\n' +
                '<a title="样式设置">样式设置</a>\n' +
                '</li>\n';
            var sortable = "";
            if(that.mode!=="detail"){
                sortable = "can-sortable";
            }
            var width_style="width:calc(100% - 20px);";
            if(that.mode=='detail'){
                width_style="width:calc(100% - 2px);";
            }
            headerHtml +='<li class="canclick" tag="align">\n' +
                '<a title="'+arrJsPopLabel['SetAlignment']+'">'+arrJsPopLabel['SetAlignment']+'</a>\n' +
                '</li>\n' +
                '</ol>\n' +
                '<span tag="">' +
                '<input type="hidden" name="tdheader_label[]" value="'+item.tdheader_label+'">' +
                '<input type="hidden" name="columns[]" value="'+item.columns+'">' +
                '<input type="hidden" name="is_merge[]" value="'+item.is_merge+'">' +
                '<input type="hidden" name="align[]" value="'+item.align+'">' +
                '<input type="hidden" name="header_width[]" value="'+th_width+'">' +
                '<input type="hidden" name="issticky[]" value="'+item.issticky+'">' +
                '<input type="hidden" name="styleset_header[]" value="'+item.styleset_header+'">' +
                '<input type="hidden" name="styleset_body[]" value="'+item.styleset_body+'">' +
                '</span>'+
                '<span class="'+sortable+' field-name" style="'+width_style+'text-align: '+item.align+'">'+item.tdheader_label+'</span>\n' +
                '</div>\n' +
                '</th>';
        });
        if(that.CustomTablesSqlCreateObj.mode=='detail'||frommobile=='yes') {
            //查看界面固定列头
            that.reportDetailHeaderObj.html(headerHtml);
            that.reportDetailHeaderObj.find(" b[tag=showHideMenu]").css("display",'none');//详情页隐藏设置按钮
            that.reportDetailHeaderObj.find("input[type=hidden]").remove();
        }else{
            that.reportDetailHeaderObj.html(headerHtml);
        }
        that.setReportHeaderEvent();
        return all_width;
    }
    //设置事件组
    this.setReportHeaderEvent=function(){
        ld('#'+that.divid).unbind("click").bind("click",function(){
            ld('.customtable-droplist').hide();
        });
        that.reportDetailHeaderObj.find("b[tag='showHideMenu']").unbind("click").bind("click",function(event){
            //设置分组，排序界面的显示隐藏
            event.stopPropagation();//阻止事件冒泡
            var display = ld(this).next().css('display');
            ld('#'+that.divid).find('.customtable-droplist').hide();
            var top = ld(this).offset().top;
            top = parseInt(top)+28;
            var left = ld(this).offset().left;
            ld(this).next().css('top',top+'px').css('left',left+'px');
            if(display=="none"){
                ld(this).next().show();
            }else{
                ld(this).next().hide();
            }
        });
        //合并
        that.reportDetailHeaderObj.find("li[tag='is_merge']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            that.changeMergeMethod(this);

            //var self = ld(this);
            //self.hide();
            //self.next().show();
            //取消合并 显示
            // var thcontentobj = self.parent().parent();
            // thcontentobj.find("li[tag='is_merge_cancel']").show();
            // thcontentobj.find("input[name='is_merge[]']").val("yes");
            // that.CustomTablesSqlCreateObj.saveReportInfo("no");
        });
        //取消合并
        that.reportDetailHeaderObj.find("li[tag='is_merge_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            //合并 显示
            var thcontentobj = self.parent().parent();
            //thcontentobj.find("li[tag='is_merge']").show();
            thcontentobj.find("input[name='is_merge[]']").val("no");
            that.CustomTablesSqlCreateObj.saveReportInfo("no");
        });
        //修改对齐方式
        that.reportDetailHeaderObj.find("li[tag='align']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            that.changeAlign(self);
        });
        //设置对齐方式
        this.changeAlign = function(obj){
            var alignList = that.alignList;
            var thobj=Tools.getParentobjByChild(obj,'th');
            var typeofdata = thobj.find('input[name="typeofdata[]"]').val();//获取字段类型
            var columns = thobj.find('input[name="columns[]"]').val();//获取字段值
            var align = thobj.find('input[name="align[]"]').val();//获取对齐方式的值
            var radios = '';
            ld.each(alignList,function(key,item){
                var checked = "";
                if(align==key){
                    checked = "checked='true'";
                }
                radios += '<span style="padding:0 5px;">\n' +
                    '<label><input class="j-all-checkbox" '+checked+' type="radio" border="0" value="'+key+'" name="align">\n' +
                    item.label+'</label>\n' +
                    '</span>\n' ;
            });
            var confirm_str = '<div class="pad20" style="width:600px;"><div>' +radios +
                '</div>' +
                '<input type="hidden" name="columns" value="'+columns+'"></div>';
            var tmpwidth = "600px";
            var module = 'CustomTables';
            var Popupobj = CrmPopup.load('', that.submitAlign, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            Popupobj.setParams(arrJsPopLabel['ModifyAlignment'], that.submitAlign, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(confirm_str);
        }
        //固定列
        that.reportDetailHeaderObj.find("li[tag='is_sticky']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            self.next().show();
            freezecolumnsObj.unfreezeAll();
            freezecolumnsObj.addSticky(self);
            //将前面的冻结都置为no
            ld('#'+that.divid).find("input[name='issticky[]']").val("no");
            ld('#'+that.divid).find("li[tag='is_sticky']").show();
            ld('#'+that.divid).find("li[tag='is_sticky_cancel']").hide();

            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='is_sticky']").hide();
            thcontentobj.find("li[tag='is_sticky_cancel']").show();
            thcontentobj.find("input[name='issticky[]']").val("yes");//将该列置为yes


            var width = freezecolumnsObj.freezeThColumnBeforeAll('set-sticky');
            freezecolumnsObj.freezeTdColumnBeforeAll('set-sticky',width);
            ld('#'+that.divid).find('.customtable-droplist').css('z-index','9999')
            that.CustomTablesSqlCreateObj.saveReportInfo("no");


        });
        //取消固定列
        that.reportDetailHeaderObj.find("li[tag='is_sticky_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            ld(trobj).find('th').removeClass('set-sticky');
            //合并 显示
            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='is_sticky']").show();
            ld('#'+that.divid).find("input[name='issticky[]']").val("no");//将所有的都置为no
            freezecolumnsObj.unfreezeAll();
            that.CustomTablesSqlCreateObj.saveReportInfo("no");
        });
        //样式设置
        that.reportDetailHeaderObj.find("li[tag='style_set']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var curobj = this;
            getJsScript('include/js/modules/CustomTables/styleSet.js', function () {
                var StyleSetObj = new StyleSet();
                StyleSetObj.styleSetPop(that.divid, ld(curobj), that.CustomTablesSqlCreateObj);
            });
        });
    }
    //点合并方式的方法
    this.changeMergeMethod = function(obj){
        var thobj = Tools.getParentobjByChild(obj,'th');
        var is_merge = thobj.find('input[name="is_merge[]"]').val();//获取合并方式的额值
        var columns = that.columns;
        var curcolumn = thobj.find('input[name="columns[]"]').val();
        var html = '<div class="ld-flex-start pad20" style="width:600px;"><div class="hlineheight30">'+arrJsPopLabel['Accordingtospecifiedfields']+'</div><div class="lineheight30">'+arrJsPopLabel['Merge']+'</div><div><select name="MergeMethod" class="ld-select-inner">';
        var mergecolumn = '';
        if(is_merge=='no'){
            mergecolumn='no';
        }else
        if(is_merge=='noselect'){
            mergecolumn=curcolumn;//用户从未选择过  默认选中当前列
        }else{
            mergecolumn=is_merge;
        }
        html += '<option value="no">'+arrJsPopLabel['Donotmerge']+'</option>' ;
        ld.each(columns,function(key,item){
            var selected = "";
            if(item.columns==mergecolumn){
                selected = "selected";
            }
            html += '<option '+selected+' value="'+item.columns+'">' + item.tdheader_label +'</option>' ;
        });
        html += '</select></div></div></div>';
        var tmpwidth = "600px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('', that.submitMergeMethod, "", tmpwidth, module, {'curcolumn':curcolumn}, arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.setParams(arrJsPopLabel['Mergemethod'], that.submitMergeMethod, '', tmpwidth, module, {'curcolumn':curcolumn}, arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.show(html);

    }
    //保存合并方式的代码
    this.submitMergeMethod = function(params){
        var remindobj = CrmPopup.getPopupObj('last');
        var mergeMethod =  ld('#'+remindobj.divid).find('[name=MergeMethod]').val();
        var thcontentobj = that.reportDetailHeaderObj.find('th[tag="'+params.curcolumn+'"]');
        if(mergeMethod=='no'){
            thcontentobj.find("li[tag='is_merge_cancel']").hide();
        }else{
            thcontentobj.find("li[tag='is_merge_cancel']").show();
        }
        thcontentobj.find('input[name="is_merge[]"]').val(mergeMethod);

        remindobj.CancelEvent();
        ld("#" + remindobj.divid).remove();
        ld('#'+remindobj.divid+'_olayernodeid').remove();
        that.CustomTablesSqlCreateObj.saveReportInfo("no");
    }
    //对齐方式确认按钮
    this.submitAlign = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var values = '';
        var align_input = ld('#'+popupobj.divid).find('input[name="align"]');
        var columns = ld('#'+popupobj.divid).find('input[name="columns"]').val();
        ld.each(align_input,function(){
            var checked = ld(this).prop('checked');
            var value = ld(this).val();
            if(checked==true){
                values = value;
            }
        });
        ld('#'+that.divid).find('th[tag="'+columns+'"]').find('input[name="align[]"]').val(values);
        popupobj.CancelEvent();
        ld("#" + popupobj.divid).remove();
        ld('#'+popupobj.divid+'_olayernodeid').remove();
        that.CustomTablesSqlCreateObj.saveReportInfo("no");
    }
    this.setSorSqltable = function(){
        //var sortObj = document.getElementById('reportDetailHeader');
        var sortObj = ld('#'+that.divid).find('[tag=reportDetailHeader]')[0];
        Sortable.create(ld(sortObj).get(0), {
            handle: '.can-sortable',
            filter: '.js-remove',
            onMove: function (evt, originalEvent) {
                return true;
            },
            onEnd: function (evt) {
                that.CustomTablesSqlCreateObj.saveReportInfo('no');
            }
        });
    }
}
var CustomTablesSqlColumnsObj = new CustomTablesSqlColumns();