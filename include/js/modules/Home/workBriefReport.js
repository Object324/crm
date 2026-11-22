function workBriefReport(){
    var that=this;
    var popupobj = CrmPopup.getPopupObj("last");
    var popupJqObj = ld('#'+popupobj.divid);
    that.setobj=popupJqObj.find('#saleskitset_stuff');
    var leftNoContentTip = that.setobj.html();
    that.emptyLabelLength = 0 ;
    that.emptyLabelContent = arrJsPopLabel['BRIEFREPORTCUSTOMIZATIONNAME']+arrJsPopLabel['CANOTEMPTY'];

    this.setEvent = function (){
        that.setCancelEvent();

        tooltip(popupJqObj.find('.sort-tip-report'), {transition: true, time: 200});
        //左侧
        //搜索框
        that.searchEvent();
        //展开收起
        that.listItemEvent();
        //新建自定义
        that.createCustom();
        //删除自定义
        that.deleteCustom('');
        //拖拽
        ld.each(popupJqObj.find(" #saleskitlist_all").find('ul'),function(index,obj){
            that.leftDragEvent(this);
        });
        //双击
        popupJqObj.find('#saleskitlist_all').find('li').unbind('dblclick').bind('dblclick',function (){
            that.listDblclick(this);
        });
        //中间
        //绑定拖动
        ld.each(popupJqObj.find(" #saleskitview .ld_saleskitview_block .ld_saleskitview_row div.ld_saleskitview_stuff"),function(index,obj){
            that.middleDragEvent(this);
        });
        var listdivobj=popupJqObj.find('#saleskitview [id^=saleskitstuff_]');
        //删除
        popupJqObj.find('#saleskitview  [name^=middle_close_]').unbind('click').bind('click',function () {
            that.listDelete(this);
        });
        //选中
        listdivobj.unbind('click').bind('click',function () {
            that.middleClickEvent(this);
        });

        //保存
        popupJqObj.find('#save').unbind('click').bind('click',function () {
            if (that.checkUpdate()){
                MessagePopup.TipTwo_warning(arrJsPopLabel['WorkBriefReportSaveTip']);
                var messagePopupobj = CrmPopup.getPopupObj("last");
                ld('#'+messagePopupobj.divid +' input[tagclick="msgConfirm"]').off('click').on('click', function () {
                    that.saveWorkBriefReport();
                });
            }else {
                that.saveWorkBriefReport();
            }
        });
        popupJqObj.find('[tag=style]').off('click').on('click',function () {
            popupJqObj.find('[tag=style]').addClass('CurSetType');
            popupJqObj.find('[tag=setting]').removeClass('CurSetType');
            popupJqObj.find('#saleskitset_style').css('display','');
            popupJqObj.find('#saleskitset_stuff').css('display','none');
        });
        popupJqObj.find('[tag=setting]').off('click').on('click',function () {
            popupJqObj.find('[tag=setting]').addClass('CurSetType');
            popupJqObj.find('[tag=style]').removeClass('CurSetType');
            popupJqObj.find('#saleskitset_style').css('display','none');
            popupJqObj.find('#saleskitset_stuff').css('display','flex');
        })
    }

    this.setCancelEvent = function (){
        that.showtype = popupJqObj.find('#showtype').val();
        //重写右上角关闭按钮
        popupobj.canceledit = popupobj.CancelEvent;
        popupobj.CancelEvent = function (){
            if (that.checkUpdate()){
                MessagePopup.TipTwo_warning(arrJsPopLabel['CANCELSALESKITSETCHECK'])
                var messagePopupobj = CrmPopup.getPopupObj("last");
                ld('#'+messagePopupobj.divid +' input[tagclick="msgConfirm"]').off('click').on('click', function () {
                    popupobj.canceledit();
                })
            }else {
                popupobj.canceledit();
            }
        }
    }

    this.checkUpdate = function (){
        var update = false;
        var delete_list = popupobj.delete_list;
        var create_list= popupobj.create_list;
        var newshowtype = popupJqObj.find('#showtype').val();
        if (newshowtype !== that.showtype){
            update = true;
        }
        else if (Object.keys(create_list).length > 0 || Object.keys(delete_list).length > 0){
            update = true;
        }
        else {
            var select_list = JSON.stringify(popupobj.select_list);
            var old_select_list= JSON.stringify(popupobj.old_select_list);
            if (select_list != old_select_list){
                update = true;
            }
        }
        return update;
    }

    this.searchEvent = function (){
        var searchinputobj=popupJqObj.find('#search_saleskitlist');
        //输入框有值显示清除按钮
        searchinputobj.unbind('input propertychange').bind('input propertychange',function () {
            var search_value=searchinputobj.val();
            // that.search(search_value);
            var inputclearobj=popupJqObj.find('#clearsearchBtn');
            search_value != ''?inputclearobj.css('display','block'):inputclearobj.css('display','none');
        });
        searchinputobj.unbind('keydown').bind('keydown',function (event) {
            var e = event || window.event;
            e.keyCode == 13 && that.search(searchinputobj.val());
        });
        //搜索按钮
        popupJqObj.find('#searchBtn').unbind('click').bind('click',function () {
            var search_value=searchinputobj.val();
            that.search(search_value);
        })
        //清除按钮
        popupJqObj.find('#clearsearchBtn').unbind('click').bind('click',function () {
            searchinputobj.val('');
            searchinputobj.focus();
            ld(this).css('display','none');
        })

    }
    this.search = function (search_str) {
        that.workBriefReportListObj = popupJqObj.find('#saleskitlist_all');
        var AllLiObj = that.workBriefReportListObj.find('li');
        if (search_str === '') {
            AllLiObj.show();
        } else {
            AllLiObj.hide();
            var searchObj = AllLiObj.find('.sort-tip-report[data-tip*=' + search_str + ']')
            searchObj.length > 0 && searchObj.parent().show();
        }
        popupJqObj.find(" .saleskitlist").css('height','unset');
        var notcontent_customobj=that.workBriefReportListObj.find("#saleskit_list_notcontent_custom");
        that.workBriefReportListObj.find("ul").find('li:visible').length > 0 ? notcontent_customobj.hide() : notcontent_customobj.show();
    }
    this.listItemEvent = function (){
        var listItemobj=popupJqObj.find('[name=stufflist_title_default],[name=stufflist_title_custom]');
        listItemobj.unbind('click').bind('click',function(){
            var datatype=ld(this).data('type');
            var listtypeObj = popupJqObj.find(" [name=saleskitlist_"+datatype+"]");
            if(ld(this).find('.icon-develop_active').length > 0){
                ld(this).find('.icon-develop_active').removeClass('icon-develop_active');
                listtypeObj.animate({ height: 0},200);
                listtypeObj.css('height','0px');
            }else{
                ld(this).find('.icon-develop').addClass('icon-develop_active');
                listtypeObj.css('height',listtypeObj.get(0).scrollHeight + 'px');
            }
        });
    }
    this.leftDragEvent = function (obj){
        Sortable.create(obj, {
            group: {name: 'report',pull:'clone',put:false},
            animation: 0,
            sort:false,
            draggable:".drag-handle",
            onMove: function (evt) {
                if (that.emptyLabelLength != 0){
                    return false;
                }
                ld(evt.to).find('[name=blankstuff_new]').length > 0 && ld(evt.to).find('[name=blankstuff_new]').html('');
            },
            onEnd: function (evt){
                if (that.emptyLabelLength != 0){
            MessagePopup.TipOne_warning(that.emptyLabelContent);
            return false;
        }
                that.leftDragOnEnd(evt);
            }
        });
    }
    //右侧简报区块的拖动
    this.middleDragEvent = function(obj){
        Sortable.create(obj, {
            group: 'report',
            animation: 150,
            sort:true,
            filter: '.ld_saleskitview_stuff_new',
            onMove: function (evt){
                ld(evt.dragged).css('display','none');
                if(ld(evt.to).hasClass('ld_saleskitview_stuff_new')){
                    return false;
                }
            },
            onEnd: function (evt){
                if(ld(evt.to).hasClass('ld_saleskitview_stuff_new')){
                    return false;
                }
                var move_stuff=ld(evt.to).children("div:not([id='"+evt.item.id+"'])");
                evt.from != evt.to && ld(evt.from).html(move_stuff);
                ld(evt.item).css('display','block');
            }
        })
    }
    this.createCustom = function () {
        popupJqObj.find("#addCustomSaleskit").unbind('click').bind('click',function (){
            var new_id = popupobj.custom_maxid = (parseInt(popupobj.custom_maxid) + 1);
            var new_count =popupobj.custom_count = (parseInt(popupobj.custom_count) + 1);
            var tmplabel = arrJsPopLabel['CustomSaleskit'] + new_count;
            var tmp_name = 'CustomReport_' + new_id;
            var customlist = ld(this).siblings('ul');
            var custom_html=' <li class="ld_saleskitlist_stuff drag-handle" id="reportlist_'+tmp_name+'" data-tag="new" data-type="custom" data-name="'+tmp_name+'" data-new_id="'+new_id+'">' +
                '     <span class="tip-items-newreport" name="label" style="cursor: pointer" data-tip="'+tmplabel+'" data-direction="top"' +
                '           data-type="position" >' + tmplabel +
                '     </span>' +
                '     <span class="tag" name="checked_tag""><i class="check"></i></span>' +
                '     <span class="ld-saleskitview-block-stuff-delete" name="saleskit_delete" data-name="'+tmp_name+'">' +
                '         <i class="icon-deleted"></i>' +
                '     </span>' +
                '     <div class="ld_saleskitview_block_stuff_close" data-name="'+tmp_name+'"><i class="icon_del"></i></div>' +
                '</li>';
            customlist.append(custom_html);
            new_count != 0 && popupJqObj.find('#saleskit_list_notcontent_custom').css('display','none');
            //添加创建后的事件
            that.addCreateEvent(tmp_name);
        });
    }
    //新建自定义简报后的事件
    this.addCreateEvent = function (name){
        var newReportObj=popupJqObj.find('li[data-name='+name+']');
        tooltip(newReportObj.find('.tip-items-newreport'), {transition: true, time: 200});
        newReportObj.get(0).scrollIntoView({ behavior: "smooth" , block : "end"});
        that.listDblclick(newReportObj.get(0));
        //双击事件
        newReportObj.unbind('dblclick').bind('dblclick',function () {
            that.listDblclick(this);
        });
        //右侧自定义删除事件
        that.deleteCustom(newReportObj);

    }
    this.deleteCustom = function (obj='') {
        if (!empty(obj)){
            var newReportObj=ld(obj);
        }else {
            var newReportObj=popupJqObj.find("#saleskitlist_custom").find('[data-type=custom]');
        }
        newReportObj.find('[name=saleskit_delete]').bind('click',function () {
            MessagePopup.TipOne_warning(arrJsPopLabel['COMFIRMTODELETE']);
            var remove_liobj =ld(this).parent();
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').bind('click', function () {
                var remove_tag=remove_liobj.data('tag');
                var remove_name = remove_liobj.data('name');
                if (remove_tag == 'old'){
                    popupobj.delete_list['name'] = remove_name;
                }else {
                    popupobj.custom_maxid =parseInt(popupobj.custom_maxid) - 1;
                    delete popupobj.create_list[remove_name];
                }
                ld(remove_liobj).remove();
                popupobj.custom_count = parseInt(popupobj.custom_count)-1;
                parseInt(popupobj.custom_count) == 0 && popupJqObj.find('#saleskit_list_notcontent_custom').css('display','block');
            });
        });
    }
    this.listDblclick = function (obj){
        if (that.emptyLabelLength != 0){
            MessagePopup.TipOne_warning(that.emptyLabelContent);
            return false;
        }
        if(ld(obj).hasClass("drag-handle")) {
            var toObj = popupJqObj.find('#saleskitview .ld_saleskitview_stuff_new').get(0);
            var cloneObj = obj;
            var itemObj = obj.cloneNode(true);
            var fromObj = obj.parentNode;
            toObj.append(itemObj);
            var Evt = {
                to : toObj,
                clone : cloneObj,
                item : itemObj,
                from : fromObj,
            };
            that.leftDragOnEnd(Evt);

        }
        else{//已选中的双击后取消选中
            var name = ld(obj).data('name');
            var reportObj = popupJqObj.find('[name=middle_close_'+name+']');
            reportObj.length>0 && reportObj.trigger('click');
        }
    }
    this.leftDragOnEnd = function (Evt){
        if(ld('[name=blankstuff_new]').text() == ''){
            ld('[name=blankstuff_new]').html('+'+arrJsPopLabel['dragmodule']);
        }
        var liobj = ld(Evt.item);
        var toObj = Evt.to;
        var name = liobj.data('name');//简报的name
        var tag = liobj.data('tag');
        popupJqObj.find(' [name=saleskit_delete][data-name='+name+']').removeClass('ld-saleskitview-block-stuff-delete');
        if(toObj.tagName !== 'UL') {
            Evt.clone.className = 'ld_saleskitlist_stuff ld_listchosestuff';
            ld(Evt.clone).find('.tag').css('display','block');
            if(tag == 'old'){//非新建自定义简报
                //将这个拖动的那个简报信息给选中的数组
                popupobj.select_list[name] = popupobj.all_list[name];
            }else if(tag == 'new'){
                //新建简报
                var NewStuffInfoArr = that.getNewStuffInfoArr();
                NewStuffInfoArr.name = name;
                NewStuffInfoArr.label_zh = NewStuffInfoArr.label_zh+popupobj.custom_count;
                NewStuffInfoArr.label_en = NewStuffInfoArr.label_en+' '+popupobj.custom_count;
                NewStuffInfoArr.label = popupobj.languageType == 'zh'?NewStuffInfoArr.label_zh:NewStuffInfoArr.label_en;
                NewStuffInfoArr.sequence = popupobj.custom_count;
                popupobj.select_list[name]=NewStuffInfoArr;
                popupobj.create_list[name]=NewStuffInfoArr;
            }
            popupobj.select_list[name].presence = 'yes';
            var SalesKitStuff_html = that.getReportHtml(popupobj.select_list[name]);
            var colcount=popupobj.briefReportLayout.colcount;//每行多少个简报
            var curheight=popupobj.briefReportLayout.height;//每行简报高度
            toObj = ld(toObj);
            toObj.before('<div class="ld_saleskitview_stuff ld_saleskitview_block_stuff" data-tag="'+tag+'" style="width:calc(100% / '+colcount+' - 10px);height:'+curheight+'px;margin:5px;overflow: hidden;">'+SalesKitStuff_html+'</div>');
            toObj.find('li').remove();
            that.middleDragEvent(toObj.prev().get(0));
            toObj.prev().get(0).scrollIntoView({ behavior: "smooth" , block : "center"});
            tooltip('#'+popupobj.divid+' #saleskitlist_all [data-name="'+name+'"] .sort-tip-report', {transition: true, time: 200});
            tooltip('#'+popupobj.divid+' #saleskitstuff_'+name, {transition: true, time: 200});
            that.middleClickEvent(popupJqObj.find('#saleskitview #saleskitstuff_'+name));
            popupJqObj.find('#saleskitview #saleskitstuff_'+name).unbind('click').bind('click',function () {
                that.middleClickEvent(this);
            });
            popupJqObj.find('#saleskitview [name=middle_close_'+name+']').unbind('click').bind('click',function () {
                that.listDelete(this);
            })
        }
    }
    this.getNewStuffInfoArr = function () {
        var arr = {
            'name' : 'CustomBriefReport_',
            'sequence' : 0,
            'presence': 'no',
            'is_default' : 'no',
            'label' : '',
            'label_zh' : '自定义简报',
            'label_en' : 'New Brief Report',
            'count_module' : 'Accounts',
            'count_type' : 'count',
            'count_columnname' : 'ld_account.accountid',
            'count_datarange' : '',
            'count_timerange' : '',
            'advft_criteria' : 'null',
            'advft_criteria_groups' : 'null',
            'content_value' : ''
        }
        return arr;
    }
    this.getReportHtml = function (selectArr) {
        var label = selectArr.label;
        var name = selectArr.name;
        var tmphtml='' +
            '<div class="ld_saleskitstuff hover drag-handle j-toBiSale sort-tip-report" style="overflow: hidden;height: 90%;width: 95%;top: 5%;left: 0%;position: relative;cursor: pointer" data-tip="'+label+'" data-direction="top" data-type="position" id="saleskitstuff_'+name+'" data-name="'+name+'">' +
            '   <div class="ld-saleskitview-block-stuff-close" data-name="'+name+'">' +
            '       <i class="icon-close"></i>' +
            '   </div>' +
            '   <div class="ld-stuff-item-header">' +
            '       <div class="ld-stuff-item-header-icon"></div>' +
            '       <div class="ld-stuff-item-header-title" name="label" style="line-height: 50px">'+label +'</div>' +
            '   </div>' +
            '   <div class="ld-stuff-item-content">' +
            '       <div class="ld-stuff-item-content-l">' +
            '           <div class="ld-stuff-item-c-l-t" style="height: 100%">' +
            '               <div class="ld-stuff-item-c-label">' +
            '                   <span class="ld-stuff-item-c-data" style="padding-left: 0px">0</span>' +
            '               </div>' +
            '           </div>' +
            '       </div>' +
            '   </div>' +
            '   <div class="ld-saleskitview-block-stuff-close" name="middle_close_'+name+'" data-name="'+name+'">' +
            '        <i class="icon-close"></i>' +
            '   </div>' +
            '</div>';
        return tmphtml;
    }
    this.listDelete = function (obj){
        event.stopPropagation();
        if (that.emptyLabelLength != 0){
            MessagePopup.TipOne_warning(that.emptyLabelContent);
            return false;
        }
        var remove_name=ld(obj).data('name');
        var remove_tag=ld(obj).parent().data('tag');
        remove_tag == 'new' && (popupobj.create_list[remove_name] = popupobj.select_list[remove_name]);
        popupobj.select_list[remove_name].presence = 'no';
        popupJqObj.find(' #saleskitstuff_'+remove_name).parent().remove();
        popupJqObj.find(' .ld_saleskitlist_stuff[data-name='+remove_name+']').find('[name=checked_tag]').css('display','none');
        popupJqObj.find(' .ld_saleskitlist_stuff[data-name='+remove_name+']').removeClass('ld_listchosestuff').addClass('drag-handle');
        if(popupobj.select_list[remove_name].is_default !== 'yes'){
            popupJqObj.find(' [name=saleskit_delete][data-name='+remove_name+']').addClass('ld-saleskitview-block-stuff-delete');
        }
        // popupJqObj.find(' #saleskitset_stuff').show();
        popupJqObj.find(' #saleskitset_stuff').html(leftNoContentTip);
    }
    this.middleClickEvent = function(obj){
        if (that.emptyLabelLength != 0){
            MessagePopup.TipOne_warning(that.emptyLabelContent);
            return false;
        }
        //选中样式
        popupJqObj.find('[tag=style]').removeClass('CurSetType');
        popupJqObj.find('[tag=setting]').addClass('CurSetType');
        popupJqObj.find('#saleskitset_style').css('display','none');
        popupJqObj.find('#saleskitset_stuff').css('display','flex');
        popupJqObj.find(' .ld_saleskitstuff').attr('cur_selected','').css('border','1px solid rgb(230, 230, 230)');
        ld(obj).attr('cur_selected','yes');
        ld(obj).css('border','1px dashed #3B7CFF');
        that.name=ld(obj).data('name');
        that.tag = ld(obj).parent().data('tag');
        that.dataObj = that.tag == 'old'?popupobj.select_list[that.name]:popupobj.create_list[that.name];
        that.getDetailSetDetail();
    }
    //选中简报之后生成右侧的html
    this.getDetailSetDetail = function(){
        that.setobj.empty();
        var moduleoptionHtml = '';
        ld.each(popupobj.moduleArr,function(index,module){
            var selectdcss = that.dataObj.count_module==module.modulename?'selected':'';
            moduleoptionHtml += '<option '+selectdcss+' value="'+module.modulename+'">'+module.name+'</option>';
        });
        var sumhtml= that.dataObj.count_type == 'sum'?'selected':'';
        var counthtml= that.dataObj.count_type == 'count'?'selected':'';
        var inputcss = 'background：#F0F3F7;cursor:pointer;';//直接把默认的组件设置也放开
        var disabledcss = '';
        //中英文名称 设置图标
        var html = '<div class="FieldBlock">'+
            '<div class="marT10 FieldLabel Mandatory justifynormal">' +
            '    <font color="red">*</font>' +
            '    <span>'+arrJsPopLabel['SALESKITZHNAME']+'</span>' +
            '</div>' +
            '<div class="marT5 marB15 FieldCon">' +
            '    <input type="text" id="label_zh" data-name="'+that.name+'" class="detailedViewTextBox FieldConText" style="width: 100%; background:#F5F8FC; " value="'+that.dataObj.label_zh+'">' +
            '</div>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div class="FieldLabel Mandatory justifynormal">' +
            '    <font color="red">*</font>' +
            '    <span>'+arrJsPopLabel['SALESKITENNAME']+'</span>' +
            '</div>' +
            '<div class="marT5 marB15 FieldCon">' +
            '    <input type="text" id="label_en" data-name="'+that.name+'" class="detailedViewTextBox FieldConText" style="width: 100%;background:#F5F8FC;" value="'+that.dataObj.label_en+'">' +
            '</div>' +
            '</div>' +
            '<div class="filtersetcard filtersetcarddash">'+
            '<div class="FieldBlock">'+
            '<div class="marT20 FieldLabel Mandatory justifynormal">' +
            '    <span>'+arrJsPopLabel['StatisticsModule']+'</span>' +
            '</div>' +
            '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
            '    <select '+disabledcss+' fieldtype="selecttype" name="count_module_'+that.name+'" id="count_module" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+'">' +
            moduleoptionHtml +
            '    </select>' +
            '</div>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div class="marT20 FieldLabel Mandatory justifynormal">' +
            '    <span>'+arrJsPopLabel['COMPUTINGMETHOD']+'</span>' +
            '</div>' +
            '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
            '    <select '+disabledcss+' fieldtype="selecttype" name="count_type_'+that.name+'" id="count_type" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+'">' +
            '        <option value="sum" '+sumhtml+'>'+arrJsPopLabel['Sum']+'</option>' +
            '        <option value="count" '+counthtml+'>'+arrJsPopLabel['Count']+'</option>' +
            '    </select>' +
            '</div>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div class="marT20 FieldLabel Mandatory justifynormal">' +
            '    <span>'+arrJsPopLabel['STATISTICALFIELD']+'</span>' +
            '</div>' +
            '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
            '    <select '+disabledcss+' fieldtype="selecttype" name="count_columnname_'+that.name+'" id="count_columnname" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+'"></select>' +
            '</div>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div class="marT20 FieldLabel Mandatory justifynormal">' +
            '    <span>'+arrJsPopLabel['FILTERSVIEWSCOPEMAPPINGFIELDS']+'</span>' +
            '</div>' +
            '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
            '   <select '+disabledcss+' name="count_datarange_'+that.name+'" id="count_datarange" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+';"></select>' +
            '</div>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div  class="marT20 FieldLabel Mandatory justifynormal">' +
            '    <span>'+arrJsPopLabel['FILTERTIMERANGEMAPPINGFIELD']+'</span>' +
            '</div>' +
            '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
            '   <select '+disabledcss+' name="count_timerange_'+that.name+'" id="count_timerange" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+';"></select>' +
            '</div>' +
            '</div>' +
            '<div id="conditions_'+that.name+'" class="ld_saleskitset_detail" style="margin-top: 15px">' +
            '   <span class="marT20 FieldLabel Mandatory justifynormal blueFont">'+arrJsPopLabel['SETSEARCHCONDITIONS']+'</span>' +
            '</div>' +
            '<div class="FieldBlock">'+
            '<div class="marT20 FieldLabel Mandatory justifynormal">' +
            '   <span>'+arrJsPopLabel['ReportContentSetting']+'</span>' +
            '   <a class="ld-category-icon ld-category-edit" href="javascript:void(0);" id="btn_edit_reportcontent" style="left: 10px" title="编辑"></a>' +
            '</div>' +
            '<div id="reportContentSet_'+that.name+'" class="marT20 FieldLabel Mandatory justifynormal" style="position: relative">' +
            '   <textarea name="content_'+that.name+'" class="ld-textarea-inner" id="content_value" readonly style="min-height: 100px;white-space: pre">'+that.dataObj.content_value+'</textarea>'+
            // '   <a class="ld-category-icon ld-category-edit" href="javascript:void(0);" name="btn_edit_reportcontent" style="position: absolute;right: 15px;bottom: 10px;" title="编辑"></a>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '</div>';
        that.setobj.append(html);
        that.setRightEvent();
    }
    this.setRightEvent = function () {
        that.getModuleFields(that.dataObj.count_module);
        var databindArr = {
            'label_zh':'label_zh',
            'label_en':'label_en',
            'count_module':'count_module',
            'count_type':'count_type'
        }
        ld.each(databindArr,function(indexname,keyname){
            if (indexname == 'count_module' || indexname == 'count_type'){
                var tmpobj = popupJqObj.find('#'+indexname);
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,'235');
            }
            var DataHtmlBindobj =new DataHtmlBind();
            DataHtmlBindobj.setJqueryObj(popupJqObj.find('#'+indexname));
            DataHtmlBindobj.setDataBindByJqueryObj(that.dataObj,keyname);
        });
        //更改中英文事件
        var labelobj=popupobj.languageType == 'zh'?that.setobj.find('#label_zh'):that.setobj.find('#label_en');
        var otherlabelobj=popupobj.languageType == 'zh'?that.setobj.find('#label_en'):that.setobj.find('#label_zh')
        labelobj.unbind('change').bind('change',function () {
            var text=ld(this).val();
            popupJqObj.find('[id=saleskitstuff_'+that.name+'] [name=label]').html(text);
            popupJqObj.find('[id=saleskitstuff_'+that.name+']').attr('data-tip',text);
            popupJqObj.find('[id=reportlist_'+that.name+'] [name=label]').html(text);
            popupJqObj.find('[id=reportlist_'+that.name+']').attr('data-tip',text);
            that.emptyLabelEvent(ld(this));
        });
        otherlabelobj.unbind('change').bind('change',function () {
            that.emptyLabelEvent(ld(this));
        });
        //更改模块
        that.setobj.find('#count_module').unbind('change').bind('change',function () {
            var module=ld(this).val();
            that.getModuleFields(module);
        });
        that.setobj.find('#count_type').unbind('change').bind('change',function () {
            var module=that.setobj.find('#count_module').val();
            that.getModuleFields(module);
        })
        //查询条件
        popupJqObj.find('#conditions_'+that.name).unbind('click').bind('click',function (){
            getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
                var SetOtherConditionsObj = new SetOtherConditions();
                SetOtherConditionsObj.setTypeAndDataObj('WorkBriefReport',that.dataObj);
                SetOtherConditionsObj.fun_other_conditions();
            });
        });
        //简报详情设置
        popupJqObj.find('#btn_edit_reportcontent').unbind('click').bind('click',function(){
            that.editReportContent();
        });


    }
    this.emptyLabelEvent=function (obj){
        var text=ld(obj).val();
        if (empty(text)){
            MessagePopup.TipZero_warning(that.emptyLabelContent);
            ld(obj).addClass('border_red1');
            ld(obj).focus();
            that.emptyLabelLength +=1;
        }else {
            if (that.emptyLabelLength != 0){
                that.emptyLabelLength -=1;
                ld(obj).removeClass('border_red1');
            }
        }
    }
    this.getModuleFields = function (module) {
        var url='index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkBriefReport&mode=field&count_module='+module;
        ldAjaxNoProgress(url,'',function (data) {
            if (data.code == 1){
                that.moduleField=data.result.field;
                var count_type=that.setobj.find('#count_type').val();
                var totalFieldOption=count_type == 'sum'?that.moduleField.sumFieldOption:that.moduleField.countFieldOption;
                var totalField=count_type == 'sum'?that.moduleField.sumField:that.moduleField.countField;
                that.setobj.find('#count_columnname').html(totalFieldOption);
                that.setobj.find('#count_datarange').html(that.moduleField.smowneridFieldOption);
                that.setobj.find('#count_timerange').html(that.moduleField.timeFieldOption);
                if (popupobj.all_list.hasOwnProperty(that.name) && module == popupobj.all_list[that.name].count_module && count_type == popupobj.all_list[that.name].count_type){
                    var dataArr = {
                        0:'advft_criteria',
                        1:'advft_criteria_groups',
                        2:'count_type',
                        3:'content_value',
                        4:'count_columnname',
                        5:'count_datarange',
                        6:'count_timerange'
                    }
                    ld.each(dataArr,function(indexname,keyname){
                        popupobj.select_list[that.name][keyname] = popupobj.all_list[that.name][keyname];
                    });
                    popupJqObj.find('#content_value').val(popupobj.select_list[that.name].content_value);
                }else {
                    //重置查询条件和详情设置
                    that.dataObj.content_value = '';
                    that.dataObj.advft_criteria = null;
                    that.dataObj.advft_criteria_groups = null;
                    that.dataObj.count_columnname = totalField['0'].compute_column;
                    that.dataObj.count_datarange = that.moduleField['smowneridField']['0'].column;
                    that.dataObj.count_timerange = that.moduleField['timeField']['0'].column;
                    popupJqObj.find('#content_value').val(that.dataObj.content_value);
                }
                //双向绑定
                var databindArr = {
                    'count_columnname':'count_columnname',
                    'count_datarange':'count_datarange',
                    'count_timerange':'count_timerange'
                }
                ld.each(databindArr,function(indexname,keyname){
                    that.setobj.find('#'+indexname).val(that.dataObj[keyname]);
                    var tmpobj = popupJqObj.find('#'+indexname);
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,'235');
                    var DataHtmlBindobj =new DataHtmlBind();
                    DataHtmlBindobj.setJqueryObj(popupJqObj.find('#'+indexname));
                    DataHtmlBindobj.setDataBindByJqueryObj(that.dataObj,keyname);
                });
            }
        })
    }
    this.editReportContent = function(){
        var module = that.dataObj.count_module;
        var tabid = popupobj.moduleArr[module].tabid;
        var url = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField&tabid='+tabid+'&printtabid='+tabid+'&mode=WorkReportContent';
        ldAjaxNoProgress(url,'',function(dataHtml){
            if (dataHtml.code == 1){
                var fieldsel=dataHtml.result.fieldsel;
                var content = that.dataObj.content_value;
                var urlsting='index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkBriefReport&mode=content&count_module='+module;
                var crmpopupobj=CrmPopup.load("","","",'LdPopWidth800px','CooperativeWork',"","","","");
                crmpopupobj.prevshow();
                ldAjax(urlsting, {'fieldsel':fieldsel,'content':content},function (data) {
                    if (data.code == 1){
                        crmpopupobj.setParams(arrJsPopLabel['ReportContentSetting'],that.saveReportContent,"",'LdPopWidth800px','CooperativeWork',"",data.result.oktext,"",data.result.canceltext);
                        crmpopupobj.show(data.result.content);
                    }
                })
            }
        });
    }
    this.saveReportContent = function (){
        var crmpopupobj=CrmPopup.getPopupObj('last');
        var content = ld("#"+crmpopupobj.divid+" [name=CKcontent]").val();
        that.dataObj.content_value = content;
        crmpopupobj.CancelEvent();
        popupJqObj.find('#content_value').val(content);
    }
    this.saveWorkBriefReport = function () {
        if (that.emptyLabelLength != 0){
            MessagePopup.TipOne_warning(that.emptyLabelContent);
            return false;
        }
        var selected_list=popupJqObj.find('#saleskitview [id^=saleskitstuff_]');
        selected_list.each(function (index,obj) {
            var name=ld(obj).data('name');
            popupobj.select_list[name].sequence = (index+1);
        });
        var select_list=JSON.stringify(popupobj.select_list);
        var delete_list=JSON.stringify(popupobj.delete_list);
        var create_list=JSON.stringify(popupobj.create_list);
        var showtype = popupJqObj.find('#showtype').val();
        var params = {'select_list':select_list,'delete_list':delete_list,'create_list':create_list,'showtype':showtype};
        var url='index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=WorkBriefReport&mode=save';
        ldAjax(url,params,function (data) {
            if (data.code == 1){
                //保存的时候避免数字为0
                ld('[name=Salesbriefing]').html(data.result.content);
                if(ld('#sendlog_saleskit_date').length>0){
                    var sendlog_date=ld('#sendlog_saleskit_date').html();
                }else{
                    var sendlog_date=ld('#span_saleskit_date').html();
                }
                popupobj.canceledit();
                getSendLog_SalesKit(sendlog_date);
                DelProgressObjs();
            }
        });
    }


}