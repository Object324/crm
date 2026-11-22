function CustomTablesColumns (){
    //对齐方式数组
    this.alignList = {
        'left':{"value":"no","label":arrJsPopLabel['AlignLeft']},
        'center':{"value":"no","label":arrJsPopLabel['Centered']},
        'right':{"value":"no","label":arrJsPopLabel['AlignRight']}
    }
    //非数值型字段统计方式
    this.headerUnNumsTotalType = {
        'count':{"value":"no","label":arrJsPopLabel['Count']},
        'distinct_count':{"value":"no","label":arrJsPopLabel['UCount']}
    }
    //数值型字段统计方式
    this.headerNumsTotalType = {
        'count':{"value":"no","label":arrJsPopLabel['Count']},
        'distinct_count':{"value":"no","label":arrJsPopLabel['UCount']},
        'sum':{"value":"no","label":arrJsPopLabel['Sum']},
        'avg':{"value":"no","label":arrJsPopLabel['Mean']},
        'max':{"value":"no","label":arrJsPopLabel['MaximumValue']},
        'min':{"value":"no","label":arrJsPopLabel['MinimumValue']},
    }
    //非数值型字段下拉框属性设置--input-hidden
    this.headerUnNumsAttrValue = {
        'columns':{"value":""},
        'columnmodule':{"value":""},
        'modulelabel':{"value":""},
        'fieldlabel':{"value":""},
        'bigtype':{"value":""},
        'typeofdata':{"value":""},
        //以下是设置属性
        'is_group':{"value":"no"},
        'order_by':{"value":"no"},
        'is_merge':{"value":"noselect"},
        'total_type':{"value":""},
        'align':{"value":"left"},
        'alias':{"value":""},
        //中英文统计字段名称
        "tdheader_label":{"value":""},//中文
        "tdheader_label_en":{"value":""},//英文
        "prefix":{"value":""},
        "suffix":{"value":""},
        "decimal_places":{"value":""},
        "header_width":{"value":"200"},
        "issticky":{"value":"no"},
        "styleset_header":{"value":""},
        "styleset_body":{"value":""}
    };
    //数值型字段下拉框属性设置--input-hidden
    this.headerNumsAttrValue = {
        'columns':{"value":""},
        'columnmodule':{"value":""},
        'modulelabel':{"value":""},
        'fieldlabel':{"value":""},
        'bigtype':{"value":""},
        'typeofdata':{"value":""},
        //以下是设置属性
        'is_group':{"value":"no"},//方便拖动判断
        'order_by':{"value":"no"},
        'is_merge':{"value":"noselect"},//方便拖动判断
        'total_type':{"value":"sum"},
        'align':{"value":"right"},
        'alias':{"value":""},
        //中英文统计字段名称
        "tdheader_label":{"value":""},//中文
        "tdheader_label_en":{"value":""},//英文
        "prefix":{"value":""},
        "suffix":{"value":""},
        "decimal_places":{"value":""},
        "header_width":{"value":"200"},
        "issticky":{"value":"no"},
        "styleset_header":{"value":""},
        "styleset_body":{"value":""}
    };
    //计算公式型字段下拉框属性设置--input-hidden
    this.headerFormulaAttrValue = {
        'columns':{"value":""},//公式的值
        'columnmodule':{"value":""},//模块名称
        'modulelabel':{"value":""},
        'fieldlabel':{"value":""},
        'bigtype':{"value":""},
        'typeofdata':{"value":""},
        //以下是设置属性
        'is_group':{"value":"no"},//方便拖动判断
        'order_by':{"value":"no"},
        'is_merge':{"value":"noselect"},//方便拖动判断
        'total_type':{"value":"formula"},
        'align':{"value":"right"},
        'alias':{"value":""},
        //中英文统计字段名称
        "tdheader_label":{"value":""},//中文
        "tdheader_label_en":{"value":""},//
        "prefix":{"value":""},
        "suffix":{"value":""},
        "decimal_places":{"value":""},
        "header_width":{"value":"200"},
        "issticky":{"value":"no"},
        "styleset_header":{"value":""},
        "styleset_body":{"value":""}
    };
    //非数值型字段下拉框属性设置
    this.headerUnNumsAttr = {
        'edittdheader_label':{'label':arrJsPopLabel['ECN'],'isShow':'yes'},
        'is_group':{'label':arrJsPopLabel['Grouping'],'isShow':'yes'},
        'is_group_cancel':{'label':arrJsPopLabel['Ungroup'],'isShow':'no'},
        'order_by_asc':{'label':arrJsPopLabel['Ascending'],'isShow':'no'},
        'order_by_asc_cancel':{'label':arrJsPopLabel['CAscending'],'isShow':'no'},
        'order_by_desc':{'label':arrJsPopLabel['Descending'],'isShow':'no'},
        'order_by_desc_cancel':{'label':arrJsPopLabel['CDescending'],'isShow':'no'},
        'is_merge':{'label':arrJsPopLabel['Mergemethod'],'isShow':'yes'},
        'is_merge_cancel':{'label':arrJsPopLabel['CMerge'],'isShow':'yes'},
        'is_sticky':{'label':arrJsPopLabel['Freezetothiscolumn'],'isShow':'yes'},
        'is_sticky_cancel':{'label':arrJsPopLabel['Unfreezecolumns'],'isShow':'no'},
        'style_set':{'label':arrJsPopLabel['StyleSettings'],'isShow':'yes'},
        //'total_type':{'label':'统计','isShow':'yes'},
        'total_type_change':{'label':arrJsPopLabel['SMethods'],'isShow':'yes'},
        'total_type_cancel':{'label':arrJsPopLabel['CancelStatistics'],'isShow':'yes'},
        'delete':{'label':arrJsPopLabel['DeleteField'],'isShow':'yes'},
        'align':{'label':arrJsPopLabel['SetAlignment'],'isShow':'yes'}
    };
    //数值型字段下拉框属性设置
    this.headerNumsAttr = {
        'edittdheader_label':{'label':arrJsPopLabel['ECN'],'isShow':'yes'},
        'order_by_asc':{'label':arrJsPopLabel['Ascending'],'isShow':'no'},
        'order_by_asc_cancel':{'label':arrJsPopLabel['CAscending'],'isShow':'no'},
        'order_by_desc':{'label':arrJsPopLabel['Descending'],'isShow':'no'},
        'order_by_desc_cancel':{'label':arrJsPopLabel['CDescending'],'isShow':'no'},
        'is_merge':{'label':arrJsPopLabel['Mergemethod'],'isShow':'yes'},
        'is_merge_cancel':{'label':arrJsPopLabel['CMerge'],'isShow':'yes'},
        'is_sticky':{'label':arrJsPopLabel['Freezetothiscolumn'],'isShow':'yes'},
        'is_sticky_cancel':{'label':arrJsPopLabel['Unfreezecolumns'],'isShow':'no'},
        'style_set':{'label':arrJsPopLabel['StyleSettings'],'isShow':'yes'},
        //'total_type':{'label':'统计','isShow':'yes'},
        'total_type_change':{'label':arrJsPopLabel['SMethods'],'isShow':'yes'},
        'total_type_cancel':{'label':arrJsPopLabel['CancelStatistics'],'isShow':'yes'},
        'delete':{'label':arrJsPopLabel['DeleteField'],'isShow':'yes'},
        'align':{'label':arrJsPopLabel['SetAlignment'],'isShow':'yes'}
    };

    //计算公式型字段下拉框属性设置
    this.headerFormulaAttr = {
        // 'edittdheader_label':{'label':'编辑列名称','isShow':'yes'},
        'editformula':{'label':arrJsPopLabel['EditFormula'],'isShow':'yes'},
        'order_by_asc':{'label':arrJsPopLabel['Ascending'],'isShow':'no'},
        'order_by_asc_cancel':{'label':arrJsPopLabel['CAscending'],'isShow':'no'},
        'order_by_desc':{'label':arrJsPopLabel['Descending'],'isShow':'no'},
        'order_by_desc_cancel':{'label':arrJsPopLabel['CDescending'],'isShow':'no'},
        'is_sticky':{'label':arrJsPopLabel['Freezetothiscolumn'],'isShow':'yes'},
        'is_sticky_cancel':{'label':arrJsPopLabel['Unfreezecolumns'],'isShow':'no'},
        'delete':{'label':arrJsPopLabel['DeleteField'],'isShow':'yes'},
        'style_set':{'label':arrJsPopLabel['StyleSettings'],'isShow':'yes'},
        'align':{'label':arrJsPopLabel['SetAlignment'],'isShow':'yes'}
    };
    //被设置分组字段
    this.setGroupByFields = {};
    //设置分组字段限制长度
    this.setGroupByFieldsLength = 5;
    this.reportDetailHeaderObj = "";//表头
    this.popupobj = "";
    this.divid = "";
    this.mode = "init";
    this.report_id = "";
    this.moduleHaveSelected = [];
    this.columns = [];
    var that = this;
    this.pageto_module = getSearchString('pageto_module',location.href);
    this.init = function(mode,CustomTablesCreateObj){
        var curmodule = getSearchString('module',location.href);
        that.pageto_module = that.pageto_module?that.pageto_module:curmodule;
        that.pageto_module = (that.pageto_module!='ReportAnalysis'&&that.pageto_module!='CustomTables')?'ReportAnalysis':that.pageto_module;

        that.popupobj = CrmPopup.getPopupObj("last");
        if(that.popupobj){
            that.divid = that.popupobj.divid;
        }else{
            that.divid = "customtable_content";//链接模块
        }
        that.report_id = ld('#'+that.divid).find('#report_id').val();
        that.moduleHaveSelected = ld('#'+that.divid).find('#selectedModules').val();
        that.moduleHaveSelected = that.moduleHaveSelected.split(',');
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
        if(mode!=undefined){
            that.mode = mode;
        }
        that.setCreateObj(CustomTablesCreateObj);
    }
    this.setCreateObj = function(CustomTablesCreateObj){
        that.CustomTablesCreateObj = CustomTablesCreateObj;
    }
    this.setColumns = function(columns){
        that.columns = columns;
    }
    //添加一个TH
    this.addTh = function(param,afterTh){
        ld('#'+that.divid+' .empty-field').remove();
        var reportDetailHeader = that.reportDetailHeaderObj;
        var th = '';
        //字段公式字段
        var remarks;
        if(param.total_type=="formula"){
            remarks = arrJsPopLabel['Formula']+param.columns;
        }else{
            remarks = param.modulelabel+'->'+param.fieldlabel;
        }
        var temp_columns = param.columns.split(':');
        var th_width = param.header_width>0?param.header_width:200;
        var sticky_class = param.issticky=='yes'?'set-sticky':'';
        param.styleset_header = param.styleset_header==''?'font-weight:normal;':param.styleset_header;
        th += '<th tag="'+param.columns+'" style="width:'+th_width+'px;position:relative;'+param.styleset_header+'" class="'+sticky_class+'" headermodule="CustomTables" headername="'+temp_columns[2]+'">\n' +
            '<div class="thead-content">\n' +
            '   <b class="icon-homeimg icon-list-set" title="设置" tag="showHideMenu"></b>\n' +
            '   <ol class="customtable-droplist">' +
            '   <li class="unclick" onclick="">' +
            '   <a class="module-label">'+arrJsPopLabel['FROM']+remarks+'</a>'+
            '   </li>';

        if(that.mode!=="detail")
        {
            var droplist_li = that.renderHeaderMenu(param);//增加设置界面
            th += droplist_li;
        }
        th += '</ol>\n';
        //隐藏的input
        var inputs = that.renderHeaderInput(param);//添加th的input
        th += inputs;
        
        var sortable = "";
        if(that.mode!=="detail"){
            sortable = "can-sortable";
        }
        var label = param.fieldlabel;
        if(param.tdheader_label){
            label = param.tdheader_label;
        }
        var width_style="width:calc(100% - 20px);";
        if(that.mode=='detail'){
            width_style="width:calc(100% - 2px);";
        }
        th += '<span class="'+sortable+' field-name" style="'+width_style+'text-align: '+param.align+'">'+label+'</span>';
        //arrow_up.png  arrow_down.png  arrow_off.png
        //获取排序
        var order_by_curr = "no";
        var iconname = "arrow_off";
        if(param.order_by!=undefined){
            order_by_curr = param.order_by;
            if(order_by_curr=="asc"){
                iconname = "arrow_up";
            }else if(order_by_curr=="desc"){
                iconname = "arrow_down";
            }
        }
        //--暂时设置只能分组字段拥有排序设置
        var set_orderby_dislpay = "";
        if(param.is_group!="yes"){
            set_orderby_dislpay = "style='display:none;'"
        }
        // if(that.mode!=="detail")
        //         th += '<img '+set_orderby_dislpay+' class="set-orderby '+iconname+'" src="themes/softed/images/'+iconname+'.png" border="0" style="cursor: default;">';
        //reportDetailHeader.append(th);
        if(afterTh!=undefined&&afterTh!=''){
            afterTh.after(th);
        }else{
             reportDetailHeader.append(th);
            if(that.mode=='detail'||that.CustomTablesCreateObj.frompage=='detail')
            {
                //查看界面固定列头
                that.reportDetailHeaderObj.find(" b[tag=showHideMenu]").css("display",'none');
            }
        }
        that.resetthindex();
        that.setReportHeaderEvent();
    }
    this.resetthindex=function(){
        var thobjs=that.reportDetailHeaderObj.find("th");
        ld.each(thobjs,function(tmpindex,thobj){
            var thindex=parseInt(tmpindex);
            ld(thobj).attr("thindex",thindex);
        });
    }

    //删除一个TH
    this.removeTh = function(param){
        that.reportDetailHeaderObj.find('th[tag="'+param.columns+'"]').remove();
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
            top = parseInt(top)+35;
            var left = ld(this).offset().left;
            ld(this).next().css('top',top+'px').css('left',left+'px');
            if(display=="none"){
                ld(this).next().show();
            }else{
                ld(this).next().hide();
            }
        });
        //升序图标点击
        that.reportDetailHeaderObj.find(".set-orderby").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            var thcontentobj = self.parent();
            var value = thcontentobj.find("input[name='order_by[]']").val();
            if(value=="no"||value=="asc"){
                self.removeClass("arrow_up").addClass("arrow_down");
                self.attr('src',"themes/softed/images/arrow_down.png");
                //改为降序
                //改变input
                //改变菜单
                thcontentobj.find("li[tag='order_by_desc']").hide();
                thcontentobj.find("li[tag='order_by_desc_cancel']").show();
                thcontentobj.find("li[tag='order_by_asc']").hide();
                thcontentobj.find("li[tag='order_by_asc_cancel']").hide();
                thcontentobj.find("input[name='order_by[]']").val("desc");
            }else{
                self.removeClass("arrow_down").addClass("arrow_up");
                self.attr('src',"themes/softed/images/arrow_up.png");
                //改为升序
                //改变input
                //改变菜单
                thcontentobj.find("li[tag='order_by_asc']").hide();
                thcontentobj.find("li[tag='order_by_asc_cancel']").show();
                thcontentobj.find("li[tag='order_by_desc']").hide();
                thcontentobj.find("li[tag='order_by_desc_cancel']").hide();
                thcontentobj.find("input[name='order_by[]']").val("asc");
            }
            that.CustomTablesCreateObj.saveReportInfo("no");
            that.CustomTablesCreateObj.renderReportTable();
        });

        //分组
        that.reportDetailHeaderObj.find("li[tag='is_group']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var thobj = Tools.getParentobjByChild(ld(this),'th');
            var thcontentobj = self.parent().parent();
            //数字型字段不允许设置分组
            var typeofdata = thcontentobj.find("input[name='typeofdata[]']").val();
            var typeofdataArr = typeofdata.split('~');
            if(typeofdataArr[0]=="N"||typeofdataArr[0]=="NN"){
                alert("该字段不允许设置分组！");return;
            }
            //判断分组字段数量是否>5
            var isgroupobj = thcontentobj.parent().parent().find("input[name='is_group[]']");
            var grouplength = 0;
            isgroupobj.each(function(){
                var temp_val = ld(this).val();
                if(temp_val=="yes"){
                    grouplength += 1;
                }
            });
            if(grouplength>=that.setGroupByFieldsLength){
                alert("分组字段不能超过"+that.setGroupByFieldsLength+"个");return;
            }
            self.hide();
            self.parent().find("li[tag='is_group_cancel']").show();
            //修改输入框的值
            thcontentobj.find("input[name='is_group[]']").val("yes");
            //设置分组 升序降序按钮可显示
            thcontentobj.find('.set-orderby').show();
            //字段设置完分组  把它挪动到分组字段的最后一个
            var currThHtml = ld(thobj)[0];
            if(grouplength>0){
                var lastTh = trobj.find('th:nth-child('+grouplength+')');
                lastTh.after(currThHtml);
            }else{
                //没有分组字段 则放到第一个
                var firstTh = trobj.find('th:first-child');
                firstTh.before(currThHtml);
            }
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //取消分组
        that.reportDetailHeaderObj.find("li[tag='is_group_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            self.parent().find("li[tag='is_group']").show();
            //修改输入框的值
            var thcontentobj = self.parent().parent();
            thcontentobj.find("input[name='is_group[]']").val("no");
            //设置分组 升序降序按钮可显示
            thcontentobj.find('.set-orderby').hide();
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //升序
        that.reportDetailHeaderObj.find("li[tag='order_by_asc']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            //降序 隐藏
            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='order_by_asc_cancel']").show();
            thcontentobj.find("li[tag='order_by_desc']").hide();
            thcontentobj.find("li[tag='order_by_desc_cancel']").hide();
            thcontentobj.find("input[name='order_by[]']").val("asc");
            var imgObj = thcontentobj.find(".set-orderby")
            imgObj.removeClass("arrow_down").removeClass("arrow_off").addClass("arrow_up");
            imgObj.attr('src',"themes/softed/images/arrow_up.png");
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //取消升序
        that.reportDetailHeaderObj.find("li[tag='order_by_asc_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            self.prev().show();
            //降序 显示
            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='order_by_asc']").show();
            thcontentobj.find("li[tag='order_by_desc']").show();
            thcontentobj.find("li[tag='order_by_desc_cancel']").hide();
            thcontentobj.find("input[name='order_by[]']").val("no");

            var imgObj = thcontentobj.find(".set-orderby")
            imgObj.removeClass("arrow_up").removeClass("arrow_down").addClass("arrow_off");
            imgObj.attr('src',"themes/softed/images/arrow_off.png");
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //降序
        that.reportDetailHeaderObj.find("li[tag='order_by_desc']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            //升序 隐藏
            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='order_by_desc_cancel']").show();
            thcontentobj.find("li[tag='order_by_asc']").hide();
            thcontentobj.find("li[tag='order_by_asc_cancel']").hide();
            thcontentobj.find("input[name='order_by[]']").val("desc");

            var imgObj = thcontentobj.find(".set-orderby")
            imgObj.removeClass("arrow_up").removeClass("arrow_off").addClass("arrow_down");
            imgObj.attr('src',"themes/softed/images/arrow_down.png");
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //取消降序
        that.reportDetailHeaderObj.find("li[tag='order_by_desc_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            //升序 显示
            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='order_by_desc']").show();
            thcontentobj.find("li[tag='order_by_desc_cancel']").hide();
            thcontentobj.find("li[tag='order_by_asc']").show();
            thcontentobj.find("li[tag='order_by_asc_cancel']").hide();
            thcontentobj.find("input[name='order_by[]']").val("no");

            var imgObj = thcontentobj.find(".set-orderby")
            imgObj.removeClass("arrow_down").removeClass("arrow_up").addClass("arrow_off");
            imgObj.attr('src',"themes/softed/images/arrow_off.png");
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //合并方式
        that.reportDetailHeaderObj.find("li[tag='is_merge']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            //var self = ld(this);
            //self.hide();
            //self.next().show();
            that.changeMergeMethod(this);
            //取消合并 显示
            //var thcontentobj = self.parent().parent();
            //thcontentobj.find("li[tag='is_merge_cancel']").show();
            //thcontentobj.find("input[name='is_merge[]']").val("yes");
            //that.CustomTablesCreateObj.saveReportInfo("no");
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
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
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
            that.CustomTablesCreateObj.saveReportInfo("no");

        });
        //取消固定列
        that.reportDetailHeaderObj.find("li[tag='is_sticky_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            self.hide();
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            ld(trobj).find('th').removeClass('set-sticky');

            var thcontentobj = self.parent().parent();
            thcontentobj.find("li[tag='is_sticky']").show();
            ld('#'+that.divid).find("input[name='issticky[]']").val("no");//将所有的都置为no
            freezecolumnsObj.unfreezeAll();
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //样式设置
        that.reportDetailHeaderObj.find("li[tag='style_set']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var curobj = this;
            getJsScript('include/js/modules/CustomTables/styleSet.js', function () {
                var StyleSetObj = new StyleSet();
                StyleSetObj.styleSetPop(that.divid, ld(curobj), that.CustomTablesCreateObj);
            });
        });
        // //统计方式
        // that.reportDetailHeaderObj.find("li[tag='total_type']").unbind("click").bind("click",function(){
        //     var self = ld(this);
        //     that.changeTotalType(self);
        // });
        //修改统计方式
        that.reportDetailHeaderObj.find("li[tag='total_type_change']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            that.changeTotalType(self);

        });
        //修改表头名称
        that.reportDetailHeaderObj.find("li[tag='edittdheader_label']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            that.editTdheaderLabel(self);
        });
        //修改公式
        that.reportDetailHeaderObj.find("li[tag='editformula']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            that.editFormula(self);
        });

        //取消统计方式
        that.reportDetailHeaderObj.find("li[tag='total_type_cancel']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            var thcontentobj = self.parent().parent();
            thcontentobj.find('input[name="total_type[]"]').val("");
            that.CustomTablesCreateObj.saveReportInfo("no");
        });
        //删除字段
        that.reportDetailHeaderObj.find("li[tag='delete']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var deleteobj = this;
            // 弹框确认是否删除
            RemindsMsg("温馨提示", "LdPopWidth400px", "", "yes", "yes","确认删除吗？");
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                var thobj = Tools.getParentobjByChild(ld(deleteobj), 'th');
                var columns = thobj.find('input[name="columns[]"]').val();
                var tmpwidth = parseInt(ld(thobj).css("width"));
                ld('#' + that.divid).find('#fieldList input[columns="' + columns + '"]').prop('checked', false);
                thobj.remove();
                that.CustomTablesCreateObj.th_width = that.CustomTablesCreateObj.th_width-tmpwidth;
                //不正确的 注释
                // var old_reportid=that.CustomTablesCreateObj.report_id;
                // that.CustomTablesCreateObj.report_id=0;
                that.CustomTablesCreateObj.saveReportInfo("no");
                // that.CustomTablesCreateObj.renderReportTable();
                // that.CustomTablesCreateObj.report_id=old_reportid;
            });
        });
        //修改对齐方式
        that.reportDetailHeaderObj.find("li[tag='align']").unbind("click").bind("click",function(event){
            event.stopPropagation();//阻止事件冒泡
            var self = ld(this);
            that.changeAlign(self);
        });
    }
    //点合并方式的方法
    this.changeMergeMethod = function(obj){
        var thobj = Tools.getParentobjByChild(obj,'th');
        var is_merge = thobj.find('input[name="is_merge[]"]').val();//获取合并方式的额值
        var columns = that.columns;
        var curcolumn = thobj.find('input[name="columns[]"]').val();
        var html = '<div class="ld-flex-start pad20" style="width:600px;"><div class="hlineheight30">'+arrJsPopLabel['Accordingtospecifiedfields']+'</div><div class="hlineheight30">'+arrJsPopLabel['Merge']+'</div><div><select name="MergeMethod" class="ld-select-inner">';
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
            html += '<option '+selected+' value="'+item.columns+'">' + item.fieldlabel +'</option>' ;
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
        that.CustomTablesCreateObj.saveReportInfo("no");
    }
    //统计方式
    this.changeTotalType = function(obj){
        var totalTypeList ;
        var thobj = Tools.getParentobjByChild(obj,'th');

        var typeofdata = thobj.find('input[name="typeofdata[]"]').val();//获取字段类型
        var columns = thobj.find('input[name="columns[]"]').val();//获取字段值
        var total_type = thobj.find('input[name="total_type[]"]').val();//获取统计方式的额值
        total_type = total_type.split(',');
        var typeofdataArr = typeofdata.split('~');
        if(typeofdata[0]=="N"||typeofdata[0]=="NN"){
            totalTypeList = that.headerNumsTotalType;
        }else{
            totalTypeList = that.headerUnNumsTotalType;
        }
        var checkBoxs = '';
        ld.each(totalTypeList,function(key,item){
            var checked = "";
            if(total_type.indexOf(key)!=-1){
                checked = "checked='true'";
            }
            checkBoxs += '<span style="padding:0 5px;">\n' +
                '<label><input class="j-all-checkbox" '+checked+' type="checkbox" border="0" value="'+key+'" name="total_type[]">\n' +
                item.label+'</label>\n' +
                '</span>\n' ;
        });
        var confirm_str = '<div class="pad20" style="width:600px;"><div>' +checkBoxs +
            '</div><div class="btn-group"><input type="hidden" name="columns" value="'+columns+'"></div></div>';
        var tmpwidth = "600px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('', that.submitTotalType, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.setParams(arrJsPopLabel['MStatistics'], that.submitTotalType, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.show(confirm_str);
    }
    //统计方式确认按钮
    this.submitTotalType = function(columns){
        var remindobj = CrmPopup.getPopupObj('last');
        var values = [];
        var total_type_input = ld('#'+remindobj.divid).find('input[name="total_type[]"]');
        var columns = ld('#'+popupobj.divid).find('input[name="columns"]').val();
        ld.each(total_type_input,function(){
            var checked = ld(this).prop('checked');
            var value = ld(this).val();
            if(checked==true){
                values.push(value);
            }
        });
        values = values.join(',');
        ld('#'+that.divid).find('th[tag="'+columns+'"]').find('input[name="total_type[]"]').val(values);
        remindobj.CancelEvent();
        ld("#" + remindobj.divid).remove();
        ld('#'+remindobj.divid+'_olayernodeid').remove();
        that.CustomTablesCreateObj.saveReportInfo("no");
    }
    //编辑表头名称
    this.editTdheaderLabel = function(obj){
        var thobj = Tools.getParentobjByChild(obj,'th');
        var columns = thobj.find('input[name="columns[]"]').val();//获取字段值
        var tdheader_label = thobj.find('input[name="tdheader_label[]"]').val();
        var tdheader_label_en = thobj.find('input[name="tdheader_label_en[]"]').val();
        var inputs = '<div style="display: flex;justify-content: start;padding:10px 0;">' +
            '<div style="padding:0 10px;line-height: 25px;">'+ arrJsPopLabel['ChineseName'] +'</div><div style="width:calc(100% - 80px)"><input class="detailedViewTextBox" type="text" border="0" name="tdheader_label" value="'+tdheader_label+'"></div>\n' +
            '</div>\n'+
            '<div style="display: flex;justify-content: start;">\n' +
            '<div style="padding:0 10px;line-height: 25px;">'+arrJsPopLabel['EnglishName']+'</div><div style="width:calc(100% - 80px)"><input class="detailedViewTextBox" type="text" border="0" name="tdheader_label_en" value="'+tdheader_label_en+'"></div>\n' +
            '</div>\n';
        var confirm_str = '<div>' +inputs +
            '<div class="btn-group" style="margin-bottom: 20px;"><input type="hidden" name="columns" value="'+columns+'"></div></div>';

        var tmpwidth = "600";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load(arrJsPopLabel['MCName'], that.submitTdheaderLabel, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.setParams(arrJsPopLabel['MCName'], that.submitTdheaderLabel, '', tmpwidth, module, '', arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.setHeadTitle(arrJsPopLabel['MCName']);
        Popupobj.show(confirm_str);
    }
    //保存编辑表头名称
    this.submitTdheaderLabel = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var tdheader_label = ld('#'+popupobj.divid).find('input[name="tdheader_label"]').val();
        var tdheader_label_en = ld('#'+popupobj.divid).find('input[name="tdheader_label_en"]').val();
        if(empty(tdheader_label)||empty(tdheader_label_en)){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['Columnnamecannotbeempty']);return;
        }
        var columns = ld('#'+popupobj.divid).find('input[name="columns"]').val();
        ld('#'+that.divid).find('th[tag="'+columns+'"]').find('input[name="tdheader_label[]"]').val(tdheader_label);
        ld('#'+that.divid).find('th[tag="'+columns+'"]').find('input[name="tdheader_label_en[]"]').val(tdheader_label_en);
        ld('#'+that.divid).find('th[tag="'+columns+'"]').find('.can-sortable').text(tdheader_label);
        popupobj.CancelEvent();

        that.CustomTablesCreateObj.saveReportInfo("no");
        ld("#" + popupobj.divid).remove();
        ld('#'+popupobj.divid+'_olayernodeid').remove();
    }
    //修改公式
    this.editFormula = function(obj){
        var thobj = Tools.getParentobjByChild(obj,'th');
        var tdheader_label = thobj.find('input[name="tdheader_label[]"]').val();
        var tdheader_label_en = thobj.find('input[name="tdheader_label_en[]"]').val();

        var columns = thobj.find('input[name="columns[]"]').val();//获取公式值
        var prefix = thobj.find('input[name="prefix[]"]').val();
        var suffix = thobj.find('input[name="suffix[]"]').val();
        var decimal_places = thobj.find('input[name="decimal_places[]"]').val();
        var report_id = that.report_id;
        var tmpwidth = "600px";
        var module = 'CustomTables';
        //找当前报表设置好统计方式的字段们 条件total_type不为空且total_type!=formula
        var mainmodule = that.moduleHaveSelected[0];
        var relatedmodule = that.moduleHaveSelected.join(',');
        var params = '&mainmodule='+mainmodule+'&relatedmodule='+relatedmodule+'&report_id='+report_id;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=ModuleInfo&function_name=getModuleFields';
        ldAjaxNoProgress(url,params,function(ajaxdata) {
            var columnsAlias = ajaxdata.result.columns_alias;//取过别名的字段
            var allCurrencies = ajaxdata.result.allCurrencies;//币种列表
            if (!columnsAlias) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NoFiled']);
                return;
            }
            var Popupobj = CrmPopup.load(arrJsPopLabel['EditFields'], that.saveColumnsAlias, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.setParams(arrJsPopLabel['EditFields'], that.saveColumnsAlias, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            var html = '<table width="600px" border="0" cellspacing="0" cellpadding="0" align="left" id="toolfieldFormula" class="settingPopTable">\n' +
                '      <tbody>';
            html += '<tr><td align="left" class="editrelhead" colspan="2">\n' +
                '      <b>'+arrJsPopLabel['DisplaySetting']+'</b>\n' +
                '      </td></tr>';
            html += '<tr><td><font color="red">*</font>'+arrJsPopLabel['ChineseName']+'</td><td><input type="text" id="tdheader_label" style="margin-top: 3px;" value="'+tdheader_label+'" class="commonTextBoxPop"></td></tr>';
            html += '<tr><td><font color="red">*</font>'+arrJsPopLabel['EnglishName']+'</td><td><input type="text" style="margin-top: 3px;" id="tdheader_label_en" value="'+tdheader_label_en+'" class="commonTextBoxPop"></td></tr>';
            html += '<tr><td>'+arrJsPopLabel['Decimal']+'</td><td><input type="number" id="decimal_places" style="margin-top: 3px;" value="'+decimal_places+'" class="commonTextBoxPop"></td></tr>';
            html += '<tr><td>'+arrJsPopLabel['Prefix']+'</td><td><select class="commonTextBoxPop" id="prefix"><option value="">'+arrJsPopLabel['NONE']+'</option>';
            ld.each(allCurrencies, function (i, currency) {
                var selected = "";
                if(prefix==currency.currencysymbol){
                    selected = "selected";
                }
                html += '<option '+selected+' value="'+currency.currencysymbol+'">'+currency.currencysymbol+'</option>';
            });
            html += '</select></td></tr>';
            html += '<tr><td>'+arrJsPopLabel['Suffix']+'</td><td><input type="text" id="suffix" style="margin-top: 3px;" class="commonTextBoxPop" value="'+suffix+'"><span style="line-height:20px;height:20px;display:block">'+arrJsPopLabel['Example']+'</span></td></tr>';
            html += '<tr><td align="left" class="editrelhead" colspan="2">\n' +
                '      <b>'+arrJsPopLabel['DefineVariable']+'</b></br>' +
                '      </td></tr>';
            html += '    <tr><td width="40%" align="left" height="34px">'+arrJsPopLabel['LBL_Field']+'</td><td width="60%" align="left">'+arrJsPopLabel['VariableName']+'</td></tr>';
            ld.each(columnsAlias, function (idx, aliasColumns) {
                //html += '<tr id="formual_row_' + idx + '"><td>' + aliasColumns.modulelabel + '->' + aliasColumns.fieldlabel;
                html += '<tr id="formual_row_' + idx + '"><td>' + aliasColumns.tdheader_label ;
                html += '</td>' +
                    '<td>{' + aliasColumns.alias + '}</td>' +
                    '</tr>';
            });
            html += '<tr><td align="left" class="editrelhead" colspan="2">\n' +
                '      <font color="red">*</font><b>'+arrJsPopLabel['DefinitionFormula']+'</b></br>' +
                '      </td></tr>';
            html += '<tr><td colspan="2">' +
                '      <input type="text" style="margin-top:3px;" id="definitionformula" name="definitionformula" class="commonTextBoxPop" value="'+columns+'">' +
                '      <input type="hidden" id="tagname" name="tagname" class="commonTextBoxPop" value="'+columns+'">' +
                '      <span style="line-height:20px;height:20px;display:block">' +
                '      '+arrJsPopLabel['Sentence']+'</span>' +
                '      <span style="line-height:20px;height:20px;display:block">'+arrJsPopLabel['Sentence2']+'</span>\n' +
                '      <span style="line-height:20px;height:20px;display:block">'+arrJsPopLabel['Sentence3']+'</span>\n' +
                '</td></tr>';
            html += '</tbody></table>';

            Popupobj.setHeadTitle(arrJsPopLabel['EditFields']);
            Popupobj.show(html);
        });
    }
    //保存编辑公式
    this.saveColumnsAlias = function(){
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var tdheader_label = ld('#'+divid).find('#tdheader_label').val();
        var tdheader_label_en = ld('#'+divid).find('#tdheader_label_en').val();
        var definitionformula = ld('#'+divid).find('#definitionformula').val();
        var tagname = ld('#'+divid).find('#tagname').val();
        var prefix = ld('#'+divid).find('#prefix').val();
        var suffix = ld('#'+divid).find('#suffix').val();
        var decimal_places = ld('#'+divid).find('#decimal_places').val();
        if(empty(definitionformula)){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['FNoEmpty']);return;
        }
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="tdheader_label[]"]').val(tdheader_label);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="tdheader_label_en[]"]').val(tdheader_label_en);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="columns[]"]').val(definitionformula);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="prefix[]"]').val(prefix);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="suffix[]"]').val(suffix);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').find('input[name="decimal_places[]"]').val(decimal_places);
        ld('#'+that.divid).find('th[tag="'+tagname+'"]').attr('tag',definitionformula);
        popupobj.CancelEvent();
        that.CustomTablesCreateObj.saveReportInfo("no");
    }
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
            '</div><input type="hidden" name="columns" value="'+columns+'"></div>';
        var tmpwidth = "600px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load('', that.submitAlign, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.setParams(arrJsPopLabel['ModifyAlignment'], that.submitAlign, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.show(confirm_str);
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
        that.CustomTablesCreateObj.saveReportInfo("no");
    }

    this.getAllGroupTh=function(){
        var reportDetailHeader =that.reportDetailHeaderobj;
        ld.each(reportDetailHeader.find("th"),function(){
            if(ld(this).find("[name=is_group[]").val()=='yes')
            {

            }
        })
    }

    //表头隐藏输入框组
    this.renderHeaderInput = function(param){
        var arr;
        var typeofdataArr = param.typeofdata.split('~');
        if(param.total_type=='formula'){
            //计算公式类型
            arr = that.headerFormulaAttrValue;
        }else if(typeofdataArr[0]=="N"||typeofdataArr[0]=="NN"){
            //数值型
            arr = that.headerNumsAttrValue;
        }else{
            //非数值型
            arr = that.headerUnNumsAttrValue;
        }
        var inputs = '<span tag="">';

        ld.each(arr,function(key,item){
            if(param[key] != "undefined"&&param[key] != undefined&&param[key]!=null){
                item.value = param[key];
            }else{
                item.value = '';
            }
            //分录字段不可设置分组
            //if(param.detailField=="yes"&&(key=="is_group"||key=="is_group_cancel")){
                //item.value = "nono";
            //}

            inputs += '<input type="hidden" name="'+key+'[]" value="'+item.value+'"/>'
        });
        inputs += '</span>';
        return inputs;
    }
    //表头菜单组
    this.renderHeaderMenu = function(param){
        var arr;
        var typeofdataArr = param.typeofdata.split('~');
        if((typeofdataArr[0]=="N"||typeofdataArr[0]=="NN")&&param.total_type!='formula'){
            arr = that.headerNumsAttr;
        }else if(param.total_type=='formula'){
            arr = that.headerFormulaAttr;

        }else{
            arr = that.headerUnNumsAttr;
            //编辑的时候 根据值判断配置项的显示隐藏  其他情况使用默认值
            if(arr.is_group!=undefined&&param.is_group=="yes"){
                arr.is_group.isShow = 'no';
                arr.is_group_cancel.isShow = 'yes';
            }else{
                arr.is_group.isShow = 'yes';
                arr.is_group_cancel.isShow = 'no';
            }
            //分录字段不可设置分组
            //if(param.detailField=="yes"){
                //arr.is_group.isShow = 'no';
                //arr.is_group_cancel.isShow = 'no';
            //}
            if(arr.is_merge!=undefined&&param.is_merge!="no"&&param.is_merge!="noselect"){
                arr.is_merge.isShow = 'yes';
                arr.is_merge_cancel.isShow = 'yes';
            }else{
                arr.is_merge.isShow = 'yes';
                arr.is_merge_cancel.isShow = 'no';
            }
            if(arr.is_sticky!=undefined&&param.issticky=="yes"){
                arr.is_sticky.isShow = 'no';
                arr.is_sticky_cancel.isShow = 'yes';
            }else{
                arr.is_sticky.isShow = 'yes';
                arr.is_sticky_cancel.isShow = 'no';
            }
            if(that.mode=="detail") {
                //查看页面  降序升序，取消升序取消降序四个按钮可显示
                arr.is_group.isShow = 'no';
                arr.is_group_cancel.isShow = 'no';
                arr.is_merge.isShow = 'no';
                arr.is_merge_cancel.isShow = 'no';
            }
        }
        /** 升序降序 取消升序 取消降序去掉 20220718 zxm
        if(arr.order_by_asc!=undefined&&param.order_by=="asc"){
            arr.order_by_asc.isShow = 'no';
            arr.order_by_asc_cancel.isShow = 'yes';
            arr.order_by_desc.isShow = 'no';
            arr.order_by_desc_cancel.isShow = 'no';
        }else
        if(arr.order_by_desc!=undefined&&param.order_by=="desc"){
            arr.order_by_asc.isShow = 'no';
            arr.order_by_asc_cancel.isShow = 'no';
            arr.order_by_desc.isShow = 'no';
            arr.order_by_desc_cancel.isShow = 'yes';
        }else{
            arr.order_by_asc.isShow = 'yes';
            arr.order_by_asc_cancel.isShow = 'no';
            arr.order_by_desc.isShow = 'yes';
            arr.order_by_desc_cancel.isShow = 'no';
        }
         **/
        if(that.mode=="detail"){
            //查看页面  降序升序，取消升序取消降序四个按钮可显示
            arr.total_type_change.isShow = 'no';
            arr.total_type_cancel.isShow = 'no';
            arr.delete.isShow = 'no';
            arr.align.isShow = 'no';
        }
        var droplist_li = '';
        ld.each(arr,function(key,item){
            var isShow = item.isShow=="no"?'style="display:none;"':'';
            var classname = "canclick";
            // if(param.detailField=="yes"&&(key=="is_group"||key=="is_group_cancel")){
            //     classname = "unclick";//分录字段不能点击分组
            // }
            droplist_li += '<li '+isShow+' class="'+classname+'" tag="'+key+'" onclick="">\n' +
                '<a title="'+item.label+'" style="font-weight: normal;">'+item.label+'</a>\n' +
                '</li>';
        });
        return droplist_li;
    }
    //设置表头拖动
    //表头字段拖动调换顺序
    //分组字段 与非分组字段不能相互调换
    this.setSortable = function(){
        // var sortObj = document.getElementById('reportDetailHeader');
        var sortObj = ld('#'+that.divid).find('[tag=reportDetailHeader]')[0];
        Sortable.create(ld(sortObj).get(0), {
            handle: '.can-sortable',
            filter: '.js-remove',
            onMove: function (evt, originalEvent) {
                //如果是分组字段与未分组字段  不能相互调换
                var dragged_isgroup = ld(evt.dragged.childNodes).find('input[name="is_group[]"]').val();
                var related_isgroup = ld(evt.related.childNodes).find('input[name="is_group[]"]').val();
                if(dragged_isgroup=="nono"||dragged_isgroup==""){
                    dragged_isgroup = 'no';
                }
                if(related_isgroup=="nono"||related_isgroup==""){
                    related_isgroup = 'no';
                }
                if(dragged_isgroup!=related_isgroup){
                    //alert("分组字段与未分组字段,不能相互调换!");--加了之后页面无法操作
                    return false;
                }
                return true;
            },
            onEnd: function (evt) {
                that.CustomTablesCreateObj.saveReportInfo('no');
            }
        });
    }
}
var CustomTablesColumnsObj = new CustomTablesColumns();