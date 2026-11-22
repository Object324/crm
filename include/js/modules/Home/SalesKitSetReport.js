function SalesKitSetReport(){
    var that=this;

    this.mainfield_arr = [];
    this.detailfield_arr = [];
    this.Stuffdetail_arr=[];
    /** 新建简报计数 */
    this.saleskit_new_count = 0;
    var popupobj = CrmPopup.getPopupObj("last");
    var PopupJqObj = ld('#'+popupobj.divid);
    this.init=function (){

    }
    //设置弹窗打开之后的事件
    this.setEvent=function (){
        var saleskitListObj = that.saleskitListObj = PopupJqObj.find(" #saleskitlist_all");
        //提示信息
        tooltip(PopupJqObj.find('.sort-tip-items'), {transition: true, time: 200});
        //销售简报搜索
        PopupJqObj.find('#search_saleskitlist').on('keydown',function (){
            var search_str = ld(this).val();
            if(window.event.keyCode === 13 || search_str === '') {
                that.searchSalesKit(search_str);
            }
        })

        //销售简报搜索
        PopupJqObj.find('#searchBtn').on('click',function (){
            var search_str = ld(this).siblings('input').val();
            that.searchSalesKit(search_str);
        })

        //删除自定义简报
        PopupJqObj.find(' [name=saleskit_delete]').unbind('click').bind('click',function(){
            var del_stufflabel=ld(this).data('stufflabel');
            var alert_str=arrJsPopLabel['COMFIRMTODELETE'];
            RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                var surl='index.php?module=Home&action=HomeAjax&file=SalesKitSet&mode=delsaleskit&del_stufflabel='+del_stufflabel;
                ldAjax(surl,'',function (data){
                    if (data.code == 1) {
                        PopupJqObj.find('#saleskitlist_all ul li[data-stufflabel='+del_stufflabel+']').remove();
                        DelProgressObjs();
                    }
                })
            });
        })

        //销售简报拖动绑定事件
        ld.each(saleskitListObj.find('ul'),function(index,obj){
            that.dragEvent_list(this);
        });

        //绑定拖动
        ld.each(PopupJqObj.find(" #saleskitview .ld_saleskitview_block .ld_saleskitview_row div.ld_saleskitview_stuff"),function(index,obj){
            that.dragEvent_layout(this);
        });

        //切换布局设置和全局设置事件
        PopupJqObj.find(' .ld_saleskit_settingdetail').unbind('click').bind('click',function(){
            var tag=ld(this).attr('tag');//0布局设置 1全局设置
            if(tag==0){
                PopupJqObj.find(' .ld_saleskit_settingdetail[tag=0]').addClass('CurSetType');
                PopupJqObj.find(' .ld_saleskit_settingdetail[tag=1]').removeClass('CurSetType');
                PopupJqObj.find(' #saleskitset_layout').show();
                PopupJqObj.find(' #saleskitset_stuff').hide();
            }else if(tag==1){
                PopupJqObj.find('.ld_saleskit_settingdetail[tag=1]').addClass('CurSetType');
                PopupJqObj.find('.ld_saleskit_settingdetail[tag=0]').removeClass('CurSetType');
                PopupJqObj.find('#saleskitset_layout').hide();
                PopupJqObj.find('#saleskitset_stuff').show();
            }
        });

        //布局设置选择列数事件
        PopupJqObj.find('#saleskitset_layout_col').unbind('change').bind('change',function(){
            PopupJqObj.find('#saleskitview .ld_saleskitview_row').children().css('width','calc(100% / '+that.saleskit_layout.colcount+' - 10px)');
            PopupJqObj.find('#saleskitview .ld_saleskitview_row').children().css('margin','5px');
        });

        //布局设置改变高度事件
        PopupJqObj.find('#saleskitset_layout_height').unbind('change').bind('change',function(){
            PopupJqObj.find('.ld_saleskitview_stuff ').css('height',that.saleskit_layout.height+'px');
        });

        //是否显示上期数据
        PopupJqObj.find('#isshowprevious').unbind('change').bind('change',function(){
            if(that.saleskit_layout.isshowprevious===true){
                if(popupobj.isshowprev=='yes') {
                    //是否显示上期   全部时间和自定义时间直接不显示上期
                    PopupJqObj.find('.ld-stuff-item-content-b').show();
                    PopupJqObj.find('[name=blankstuff_new_block]').css('min-height', '125px');
                }
                PopupJqObj.find('#EqualDuration').parents('.FieldBlock').show();
                PopupJqObj.find('#ShowPercent').parents('.FieldBlock').show();
            }else{
                PopupJqObj.find('.ld-stuff-item-content-b').hide();
                PopupJqObj.find('[name=blankstuff_new_block]').css('min-height','99px');

                PopupJqObj.find('#EqualDuration').parents('.FieldBlock').hide();
                PopupJqObj.find('#ShowPercent').parents('.FieldBlock').hide();
            }
        });

        //选中简报事件
        PopupJqObj.find(' .ld_saleskitview_stuff .ld_saleskitstuff').unbind('click').bind('click',function (){
            that.SelectSalesKit_Setting(this);
        });

        //保存事件
        PopupJqObj.find(' #save').unbind('click').bind('click',function(){
            that.SaveSalesKitSetReport();
        });

        //txy 20231012 input[type=number] 上下箭头绑定
        PopupJqObj.find(" .height-arrow-up").unbind('click').bind('click',function(){
            var inputElement1 = ld(this).parents('.FieldCon').find("input");
            var newheight = inputElement1.val();
            newheight = parseInt(newheight, 10) + 1;
            inputElement1.get(0).value = newheight;
        });
        PopupJqObj.find(" .height-arrow-down").unbind('click').bind('click',function(){
            var inputElement2 = ld(this).parents('.FieldCon').find("input");
            var newheight = inputElement2.val();
            newheight = parseInt(newheight, 10) - 1;
            inputElement2.get(0).value = newheight;
        });

        //删除选中简报事件
        PopupJqObj.find(' .ld-saleskitview-block-stuff-close').unbind('click').bind('click',function(event){
            that.removeSalesKitStuff(this);
        });

        //edit: xll 2023/12/04 XUQIU1002171 简报优化，划分为两个区块
        //区块展开收起
        saleskitListObj.find(" [name^=stufflist_title_]").unbind('click').bind('click',function (){
            var saleskit_type = ld(this).data('type');
            var ListTypeObj = saleskitListObj.find(" [name=saleskitlist_"+saleskit_type+"]");
            var scollheight = ListTypeObj.get(0).scrollHeight;
            ListTypeObj.css('height',scollheight+'px');
            if(ld(this).find('.icon-develop_active').length > 0){
                ld(this).find('.icon-develop_active').removeClass('icon-develop_active');
                ListTypeObj.animate({ height: 0},200);
                ListTypeObj.css('height','0px');
            }else{
                ld(this).find('.icon-develop').addClass('icon-develop_active');
            }
        });
        //新增自定义简报
        saleskitListObj.find("#addCustomSaleskit").unbind('click').bind('click',function (){
            var new_count = that.saleskit_new_count = that.saleskit_new_count + 1;
            var tmplabel = arrJsPopLabel['CustomSaleskit'] + new_count;
            var tmp_stufflabel = 'NEW_' + new_count;
            var customSaleskitList = ld(this).siblings('ul');
            //增加li标签
            customSaleskitList.append('' +
                ' <li class="ld_saleskitlist_stuff drag-handle newCreate" data-stufflabel="'+tmp_stufflabel+'" data-new_count="'+new_count+'">' +
                '     <span class="tip-items-list" style="cursor: pointer" data-tip="'+tmplabel+'" data-direction="top"' +
                '           data-type="position" >' +
                          tmplabel +
                '     </span>' +
                '     <span class="tag""><i class="check"></i></span>' +
                '     <span class="ld-saleskitview-block-stuff-delete" name="saleskit_delete" data-stufflabel="'+tmp_stufflabel+'">' +
                '         <i class="icon-deleted"></i>' +
                '     </span>' +
                '     <div class="ld_saleskitview_block_stuff_close" data-stufflabel="'+tmp_stufflabel+'"><i class="icon_del"></i></div>' +
                '</li>');

            var newSaleskitObj = customSaleskitList.children('.newCreate').last();
            //删除事件，未保存的简报仅需删除li标签即可
            newSaleskitObj.find('[name=saleskit_delete]').bind('click',function () {
                var alert_str = arrJsPopLabel['COMFIRMTODELETE'];
                RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    var remove_stufflabel = newSaleskitObj.data('stufflabel');
                    delete popupobj.selected_saleskit_list[remove_stufflabel];
                    newSaleskitObj.remove();
                    var newSaleskitList = customSaleskitList.children('.newCreate');
                    if(newSaleskitList.length > 0){
                        that.saleskit_new_count = parseInt(newSaleskitList.last().data('new_count'));
                    }
                    else {
                        that.saleskit_new_count = 0;
                    }
                });
            });
            //滚动到可视区域
            newSaleskitObj.get(0).scrollIntoView({ behavior: "smooth" , block : "end"});
            //新增后默认选中
            that.ListDblclick(newSaleskitObj.get(0));
            newSaleskitObj.unbind('dblclick').bind('dblclick',function () {
                event.preventDefault();
                that.ListDblclick(this);
            });
            newSaleskitObj.find('.tip-items-list').bind('mousedown',function (){
                if(event.detail > 1){
                    event.preventDefault();
                }
            });
        });

        var saleskitList = saleskitListObj.find(".ld_saleskitlist_stuff");
        //双击加入最后
        saleskitList.unbind('dblclick').bind('dblclick',function () {
            event.preventDefault();
            that.ListDblclick(this);
        });
        saleskitList.find('.tip-items-list').bind('mousedown',function (){
            if(event.detail > 1){
                event.preventDefault();
            }
        });

        PopupJqObj.find('#ShowPercent').bind('change',function () {
            if(that.saleskit_layout.isshowprevious && ld(this).prop('checked')) {
                // PopupJqObj.find('.ld-stuff-item-content-r').show();
                PopupJqObj.find('.ld-stuff-item-content-b-r').show();
                PopupJqObj.find('b[name=ld-saleskit-updown-icon]').show();
            }
            else {
                // PopupJqObj.find('.ld-stuff-item-content-r').hide();
                PopupJqObj.find('.ld-stuff-item-content-b-r').hide();
                PopupJqObj.find('b[name=ld-saleskit-updown-icon]').hide();
            }
        })
    }
    
    this.searchSalesKit = function (search_str) {
        var AllLiObj = that.saleskitListObj.find('li');
        if (search_str === '') {
            AllLiObj.show();
        } else {
            AllLiObj.hide();
            var searchObj = AllLiObj.find('.sort-tip-items[data-tip*=' + search_str + ']')
            if(searchObj.length > 0){
                searchObj.parent().show();
            }
        }
        PopupJqObj.find(" .saleskitlist").css('height','unset');
        //230620 wyt BUG0068459 kfbcrm-销售简报-搜索简报，没有内容的话应有提示信息
        if(that.saleskitListObj.find("ul").find('li:visible').length > 0){
            that.saleskitListObj.find("#saleskit_list_notcontent").hide();
        }else{
            that.saleskitListObj.find("#saleskit_list_notcontent").show();
        }
    }
    
    /** 双击简报选中事件
     * @param {HTMLElement} LiObj Li标签的JS对象
     */
    this.ListDblclick = function (LiObj) {
        //未选中的双击后选中，即包含类drag-handle
        if(LiObj.classList.contains("drag-handle")) {
            var toObj = PopupJqObj.find('#saleskitview .ld_saleskitview_stuff').last().get(0);
            var cloneObj = LiObj;
            var itemObj = LiObj.cloneNode(true);
            var fromObj = LiObj.parentNode;
            //目标DOM对象末尾追加li标签以供定位
            toObj.append(itemObj);
            var SorTableEvent = {
                to : toObj,
                clone : cloneObj,
                item : itemObj,
                from : fromObj,
            };
            that.DragListOnEnd(SorTableEvent);
        }
        //已选中的双击后取消选中
        else{
            var stufflabel = ld(LiObj).data('stufflabel');
            var saleskitObj = PopupJqObj.find('#saleskitstuff_'+stufflabel);
            saleskitObj.length > 0 ? saleskitObj.find('.ld-saleskitview-block-stuff-close').trigger('click') : null ;
        }
    }

    //设置选中简报之后的事件---简报信息改变的事件
    this.setSelectedSalesKitEvent = function(stufflabel){
        var stuffdetailInfo = popupobj.selected_saleskit_list[stufflabel];
        //小图标选择按钮点击事件
        PopupJqObj.find(' #sel_icon_pop').unbind('click').bind('click',function (){
            var cur_iconcss = stuffdetailInfo.css;
            var iconPopupobj = CrmPopup.load("", "", "", "LdPopWidth650px", "Home", "", "", "", "");
            iconPopupobj.prevshow();
            iconPopupobj.createScrollDiv();//创建滚动条
            iconPopupobj.setParams(arrJsPopLabel['SelectIcon'], '', "", "LdPopWidth950px", "Home", "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
            var html = "<div class='ld-saleskit-icon'>" +
                "<div class=\" item-ico-amount_one ld-saleskit-selicon\" tag='item-ico-amount_one'></div>" +
                "<div class=\" item-ico-amount_two ld-saleskit-selicon\" tag='item-ico-amount_two'></div>" +
                "<div class=\" item-ico-amount_three ld-saleskit-selicon\" tag='item-ico-amount_three'></div>" +
                "<div class=\" item-ico-amount_four ld-saleskit-selicon\" tag='item-ico-amount_four'></div>" +
                "<div class=\" item-ico-amount_five ld-saleskit-selicon\" tag='item-ico-amount_five'></div>" +
                "<div class=\" item-ico-amount_six ld-saleskit-selicon\" tag='item-ico-amount_six'></div>" +
                "<div class=\" item-ico-money_one ld-saleskit-selicon \" tag='item-ico-money_one'></div>" +
                "<div class=\" item-ico-money_two ld-saleskit-selicon\" tag='item-ico-money_two'></div>" +
                "<div class=\" item-ico-money_three ld-saleskit-selicon\" tag='item-ico-money_three'></div>" +
                "<div class=\" item-ico-money_four ld-saleskit-selicon\" tag='item-ico-money_four'></div>" +
                "<div class=\" item-ico-money_five ld-saleskit-selicon\" tag='item-ico-money_five'></div>" +
                "<div class=\" item-ico-money_six ld-saleskit-selicon\" tag='item-ico-money_six'></div>" +
                "<div class=\" item-ico-money_seven ld-saleskit-selicon\" tag='item-ico-money_seven'></div>" +
                "</div>";
            iconPopupobj.show(html);
            var iconPopupJqObj = ld('#'+iconPopupobj.divid);
            var iconListObj = iconPopupJqObj.find('.ld-saleskit-icon');
            if(cur_iconcss !== ''){
                var curIcon = iconListObj.find('[tag='+cur_iconcss+']');
                if(curIcon.length > 0){
                    curIcon.addClass('ld-saleskit-selectedicon');
                }
            }
            iconPopupJqObj.find(' .ld-saleskit-selicon').unbind('click').bind('click',function(){
                iconPopupJqObj.find('.ld-saleskit-selicon').removeClass('ld-saleskit-selectedicon');
                ld(this).addClass('ld-saleskit-selectedicon');
                //230705 wyt BUG0069137 首页看板-数据简报选择图标设置效果
                var selicon=iconPopupJqObj.find(' .ld-saleskit-icon .ld-saleskit-selectedicon').attr('tag');
                var iconobj=PopupJqObj.find(' #saleskitstuff_'+stufflabel).find('.ld-stuff-item-header-icon');
                iconobj.removeClass();
                iconobj.addClass('ld-stuff-item-header-icon').addClass(selicon);
            })

            iconPopupJqObj.find('#'+iconPopupobj.divid+'_btnok').unbind('click').bind('click',function(){
                var selicon=iconPopupJqObj.find(' .ld-saleskit-icon .ld-saleskit-selectedicon').attr('tag');
                popupobj.selected_saleskit_list[stufflabel].css = selicon;
                iconPopupobj.CancelEvent();
                var iconobj=PopupJqObj.find(' #saleskitstuff_'+stufflabel).find('.ld-stuff-item-header-icon');
                iconobj.removeClass();
                iconobj.addClass('ld-stuff-item-header-icon').addClass(selicon);
            })

            //wyt 230707 BUG0069202 首页看板-点击数据简报设置-界面右边选择图标设置编辑图标界面选择图标，点击取消后图标样式不会恢复成原来的样式。
            iconPopupJqObj.find('#'+iconPopupobj.divid+'_btncancel').unbind('click').bind('click',function(){
                var iconobj=PopupJqObj.find(' #saleskitstuff_'+stufflabel).find('.ld-stuff-item-header-icon');
                iconobj.removeClass();
                iconobj.addClass('ld-stuff-item-header-icon').addClass(cur_iconcss);
                iconPopupobj.CancelEvent();
            })
        })
        //中文改变
        PopupJqObj.find(' #saleskit_zh').unbind('change').bind('change',function(){
            PopupJqObj.find(' #saleskitstuff_'+stufflabel).find('.ld-stuff-item-header-title').html(stuffdetailInfo.zh);
            PopupJqObj.find(' #saleskitstuff_'+stufflabel).attr('data-tip',stuffdetailInfo.zh);
            //左侧列表的简报的名称的变化
            PopupJqObj.find(' #saleskitlist_all').find('li[data-stufflabel='+stufflabel+']').find('.sort-tip-items').attr('data-tip',stuffdetailInfo.zh).html(stuffdetailInfo.zh);
        });
        //英文改变
        PopupJqObj.find(' #saleskit_en').unbind('change').bind('change',function(){
            //啥也没干呢 --todo--
        });
        //删除选中简报事件
        /*PopupJqObj.find(' .ld-saleskitview-block-stuff-close').unbind('click').bind('click',function(event){
            that.removeSalesKitStuff(this);
        })*/
        //选中简报事件
        /*PopupJqObj.find(' .ld_saleskitview_stuff .ld_saleskitstuff').unbind('click').bind('click',function (){
            that.SelectSalesKit_Setting(this);
        });*/
    }
    //设置选中简报之后的事件---统计信息改变的事件
    this.setSelectedSalesKitComputeInfoEvent = function(stufflabel,rowindex){
        var stuffdetailInfo = popupobj.selected_saleskit_list[stufflabel];
        var lineComputeinfo = stuffdetailInfo['computeinfo'][rowindex];
        //点击其他条件的事件
        PopupJqObj.find(' #saleskit_otherconditions_'+rowindex).unbind('click').bind('click',function (){
            //edit: xll 2023/09/04 首页组件中设置其他查询条件的方法改成类，以以便所有需要的地方同意调用
            getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
                var SetOtherConditionsObj = new SetOtherConditions();
                SetOtherConditionsObj.SetDirDataObjByRowIndex(stuffdetailInfo,rowindex);
                SetOtherConditionsObj.fun_other_conditions();
            });
            //that.fun_other_conditions(stufflabel,rowindex);
        });
        //统计模块
        PopupJqObj.find(' #mainmodule_'+rowindex).unbind('change').bind('change',function(){
            that.getFieldsByModule(stufflabel,stuffdetailInfo,lineComputeinfo,rowindex);
        });

        //计算方法
        PopupJqObj.find(' #computetype_'+rowindex).unbind('change').bind('change',function(){
            that.getFieldsByModule(stufflabel,stuffdetailInfo,lineComputeinfo,rowindex,'computetype_change');
        });
        //统计字段
        PopupJqObj.find(' #computecolumns_'+rowindex).unbind('change').bind('change',function(){
            //统计模块改变 对应的简报数据改变--zxm 20240716
            var html  = that.getSalesKitStuffhtml(stuffdetailInfo);
            PopupJqObj.find('#saleskitstuff_'+stufflabel).parent().before(html).remove();
            PopupJqObj.find('#saleskitstuff_'+stufflabel).parent().css('border','1px dashed #3B7CFF');
            //删除选中简报事件
            PopupJqObj.find('#saleskitstuff_'+stufflabel+' .ld-saleskitview-block-stuff-close').unbind('click').bind('click',function(event){
                that.removeSalesKitStuff(this);
            });
            PopupJqObj.find(' .ld_saleskitview_stuff #saleskitstuff_'+stufflabel).unbind('click').bind('click',function (){
                that.SelectSalesKit_Setting(this);
            });
        });

        //统计模块改变 对应的简报数据改变--zxm 20240716
        var html  = that.getSalesKitStuffhtml(stuffdetailInfo);
        PopupJqObj.find('#saleskitstuff_'+stufflabel).parent().before(html).remove();
        PopupJqObj.find('#saleskitstuff_'+stufflabel).parent().css('border','1px dashed #3B7CFF');
        //删除选中简报事件
        PopupJqObj.find('#saleskitstuff_'+stufflabel+' .ld-saleskitview-block-stuff-close').unbind('click').bind('click',function(event){
            that.removeSalesKitStuff(this);
        });
        PopupJqObj.find(' .ld_saleskitview_stuff #saleskitstuff_'+stufflabel).unbind('click').bind('click',function (){
            that.SelectSalesKit_Setting(this);
        });

    }
    //重设排序
    this.resetSequence = function(){
        var stuffdetailObj = PopupJqObj.find('.ld_saleskitstuff');
        stuffdetailObj.each(function(stuffindex,lineinfoobj){
            var curstufflabel = ld(lineinfoobj).data('stufflabel');
            popupobj.selected_saleskit_list[curstufflabel].sequence = parseInt(stuffindex)+1;
        });
    }
    //移除简报
    this.removeSalesKitStuff=function(obj){
        var remove_stufflabel = ld(obj).data('stufflabel');
        PopupJqObj.find(' #saleskitstuff_'+remove_stufflabel).parent().remove();

        PopupJqObj.find(' .ld_saleskitlist_stuff[data-stufflabel='+remove_stufflabel+']').find('.tag').css('display','none');
        PopupJqObj.find(' .ld_saleskitlist_stuff[data-stufflabel='+remove_stufflabel+']').removeClass('ld_listchosestuff').addClass('drag-handle');

        var saleskitInfo = popupobj.selected_saleskit_list[remove_stufflabel];
        if(saleskitInfo.is_default !== 'yes'){
            PopupJqObj.find(' [name=saleskit_delete][data-stufflabel='+remove_stufflabel+']').addClass('ld-saleskitview-block-stuff-delete');
        }
        //删掉数组中的简报信息
        if(!empty(saleskitInfo)){
            saleskitInfo.used = 'no';
        }
        //wyt 230616 BUG0067957 销售简报：排列的模块选中删掉后，右侧设置里的字段不会自动刷新
        PopupJqObj.find(' #saleskitset_stuff').hide();
        PopupJqObj.find(' .ld_saleskit_settingdetail[tag=0]').addClass('CurSetType');
        PopupJqObj.find(' .ld_saleskit_settingdetail[tag=1]').removeClass('CurSetType');
        PopupJqObj.find(' #saleskitset_layout').show();
        event.stopPropagation();
    }
    //选中简报之后生成右侧的html
    this.getStuffDetailSetDetail = function(stufflabel){
        var stuffdetailInfo = popupobj.selected_saleskit_list[stufflabel];
        PopupJqObj.find('#saleskitset_stuff').empty();
        //中英文名称 设置图标
        var html = '<div class="FieldBlock">'+
            '<div class="marT10 FieldLabel Mandatory justifynormal">' +
            '    <font color="red">*</font>' +
            '    <span>'+popupobj.JspopLabelarr.SALESKITZHNAME+'</span>' +
            '</div>' +
            '<div class="marT5 marB15 FieldCon">' +
            '    <input type="text" id="saleskit_zh" class="detailedViewTextBox Bornone FieldConText" style="width: 100%; background:#F5F8FC; ">' +
            '</div>' +
            '</div>' +
            '' +
            '<div class="FieldBlock">'+
            '<div class="FieldLabel Mandatory justifynormal">' +
            '    <font color="red">*</font>' +
            '    <span>'+popupobj.JspopLabelarr.SALESKITENNAME+'</span>' +
            '</div>' +
            '<div class="marT5 marB15 FieldCon">' +
            '    <input type="text" id="saleskit_en" class="detailedViewTextBox Bornone FieldConText" style="width: 100%;background:#F5F8FC;">' +
            '</div>' +
            '</div>' +
            '' +
            '<div>' +
            '    <span>'+popupobj.JspopLabelarr.SelectIcon+'</span>' +
            '</div>' +
            '<div class="marT5 marB15">' +
            '        <a id="sel_icon_pop" class="cursorPointer blueFont settingpop">'+popupobj.JspopLabelarr.SETTINGS+'</a>' +
            '</div>';
        PopupJqObj.find('#saleskitset_stuff').append(html);
        //中英文 双向绑定
        var databindArr = {
            'saleskit_zh':'zh',
            'saleskit_en':'en'
        }
        ld.each(databindArr,function(idname,keyname){
            PopupJqObj.find('#'+idname).val(stuffdetailInfo[keyname]);
            var DataHtmlBindobj =new DataHtmlBind();
            DataHtmlBindobj.setJqueryObj(PopupJqObj.find(' #'+idname));
            DataHtmlBindobj.setDataBindByJqueryObj( popupobj.selected_saleskit_list[stufflabel] ,keyname);
        });
        that.setSelectedSalesKitEvent(stufflabel);//中英文等事件
        //选择统计模块 选择统计类型 选择统计字段等
        var computeinfo = stuffdetailInfo.computeinfo;

        ld.each(computeinfo,function(rowindex,lineComputeinfo){

            var moduleoptionHtml = '';
            ld.each(popupobj.ModuleArr,function(moduleindex,module){
                var selectdcss = lineComputeinfo.computemodule==module.modulename?'selected':'';
                moduleoptionHtml += '<option '+selectdcss+' value="'+module.modulename+'">'+module.name+'</option>';
            });
            var is_default=stuffdetailInfo.is_default;//判断是否是默认组件
            //var inputcss = is_default=='yes'?'background:#d5d5d5;cursor:not-allowed':'background：#F0F3F7;cursor:pointer;';
            //var disabledcss = is_default=='yes'?'disabled':'';
            var inputcss = 'background：#F0F3F7;cursor:pointer;';//直接把默认的组件设置也放开
            var disabledcss = '';
            var computeHtml = '<div class="filtersetcard filtersetcarddash">'+
                '<div class="FieldBlock">'+
                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                '    <span>'+popupobj.JspopLabelarr.StatisticsModule+'</span>' +
                '</div>' +
                '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
                '    <select '+disabledcss+' fieldtype="selecttype" name="mainmodule_'+rowindex+'" id="mainmodule_'+rowindex+'" class="detailedViewTextBox input-width-70 custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 80%;'+inputcss+'">' +
                moduleoptionHtml +
                '    </select>' +
                '</div>' +
                '</div>' +
                '' +
                '<div class="FieldBlock">'+
                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                '    <span>'+popupobj.JspopLabelarr.COMPUTINGMETHOD+'</span>' +
                '</div>' +
                '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
                '    <select '+disabledcss+' fieldtype="selecttype" name="computetype_'+rowindex+'" id="computetype_'+rowindex+'" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+'">' +
                '        <option value="count">'+popupobj.JspopLabelarr.COUNT+'</option>' +
                '        <option value="ucount">'+popupobj.JspopLabelarr.UCOUNT+'</option>' +
                '        <option value="sum">'+popupobj.JspopLabelarr.Summation+'</option>' +
                '        <option value="avg">'+popupobj.JspopLabelarr.AVGVALUE+'</option>' +
                '        <option value="max">'+popupobj.JspopLabelarr.MAXVALUE+'</option>' +
                '        <option value="min">'+popupobj.JspopLabelarr.MINVALUE+'</option>' +
                '    </select>' +
                '</div>' +
                '</div>' +
                '<div class="FieldBlock">'+
                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                '    <span>'+popupobj.JspopLabelarr.STATISTICALFIELD+'</span>' +
                '</div>' +
                '<div class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
                '    <select '+disabledcss+' fieldtype="selecttype" name="computecolumns_'+rowindex+'" id="computecolumns_'+rowindex+'" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+'"></select>' +
                '</div>' +
                '</div>' +
                '' +
                '<div class="FieldBlock">'+
                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                '   <input type="checkbox" name="viewrange_isrelated_'+rowindex+'" id="viewrange_isrelated_'+rowindex+'" class="second_switch marR5">' +
                '    <span>'+popupobj.JspopLabelarr.FILTERSVIEWSCOPEMAPPINGFIELDS+'</span>' +
                '</div>' +
                '<div data-control="viewrange_isrelated_'+rowindex+'" class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
                '   <select '+disabledcss+' name="viewrange_'+rowindex+'" id="viewrange_'+rowindex+'" class="detailedViewTextBox" style="height: 25px;width: 100%;'+inputcss+';"></select>' +
                '</div>' +
                '</div>' +
                '' +
                '<div class="FieldBlock">'+
                '<div  class="marT20 FieldLabel Mandatory justifynormal">' +
                '   <input type="checkbox" name="daterange_isrelated_'+rowindex+'" id="daterange_isrelated_'+rowindex+'" class="second_switch marR5">' +
                '    <span>'+popupobj.JspopLabelarr.FILTERTIMERANGEMAPPINGFIELD+'</span>' +
                '</div>' +
                '<div data-control="daterange_isrelated_'+rowindex+'" class="FieldCon changesearch" style="height: 25px;margin: 10px 0;">' +
                '   <select '+disabledcss+' name="daterange_'+rowindex+'" id="daterange_'+rowindex+'" class="detailedViewTextBox Bornone bgF5F8FC" style="height: 25px;width: 100%;'+inputcss+';"></select>' +
                '</div>' +
                '</div>' +
                '' +
                '<div id="saleskit_otherconditions_'+rowindex+'" class="ld_saleskitset_detail marB10">' +
                '    <span class="cursorPointer blueFont">'+popupobj.JspopLabelarr.SETSEARCHCONDITIONS+'</span>' +
                '</div>' +
                '</div>';
            PopupJqObj.find('#saleskitset_stuff').append(computeHtml);
            //首页看板或简报、龙虎榜设置界面，关闭“查看范围或时间筛选器”后，建议不要再显示筛选器的查询字段下拉框了  BUG20240808-14
            var bindswitcharr = ['viewrange_isrelated','daterange_isrelated']
            ld.each(bindswitcharr,function(i,keyName){
                var controlid = keyName+ '_' + rowindex;
                if(lineComputeinfo[keyName]==true){
                    PopupJqObj.find('[data-control='+controlid+']').show();
                }else{
                    PopupJqObj.find('[data-control='+controlid+']').hide();
                }
                PopupJqObj.find('#'+keyName+ '_' + rowindex).unbind('change').bind('change',function(){
                    //var checkedvalue = ld(this).prop('checked');
                    PopupJqObj.find('[data-control='+controlid+']').toggle();
                })
            });

            PopupJqObj.find('#mainmodule_'+rowindex).val(lineComputeinfo.computemodule);
            var DataHtmlBindobj =new DataHtmlBind();
            DataHtmlBindobj.setJqueryObj(PopupJqObj.find('#mainmodule_'+rowindex));
            DataHtmlBindobj.setDataBindByJqueryObj( popupobj.selected_saleskit_list[stufflabel]['computeinfo'][rowindex] ,'computemodule');

            var tmpobj = PopupJqObj.find('#mainmodule_'+rowindex);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,'235');

            that.getFieldsByModule(stufflabel,stuffdetailInfo,lineComputeinfo,rowindex);

            PopupJqObj.find('.filtersetcard').unbind('click').bind('click',function (){
                PopupJqObj.find('.filtersetcard').addClass('filtersetcarddash');
                ld(this).removeClass('filtersetcarddash');
            })
        });
    }
    //绑定拖动事件，左侧li标签的拖动
    this.dragEvent_list=function(obj){
        Sortable.create(obj, {
            group: {name: 'stuff',pull:'clone',put:false},
            animation: 0,
            sort:false,
            draggable:".drag-handle",
            onMove: function (evt) {
                if(ld(evt.to).find('[name=blankstuff_new]').length > 0){
                    ld(evt.to).find('[name=blankstuff_new]').html('');
                }
            },
            onEnd: function (evt){
                that.DragListOnEnd(evt);

            }
        });
    }
    //Li标签OnEnd事件
    this.DragListOnEnd = function(SortableEvent){
        if(ld('[name=blankstuff_new]').text() == ''){
            ld('[name=blankstuff_new]').html('+'+arrJsPopLabel['dragmodule']);
        }
        var liobj = ld(SortableEvent.item);
        var toObj = SortableEvent.to;
        var stufflabel = liobj.data('stufflabel');//简报的stufflabel
        var newsaleskit = stufflabel.search('NEW_');
        //zxm 20230628   选中简报 左侧的删除不要
        PopupJqObj.find(' [name=saleskit_delete][data-stufflabel='+stufflabel+']').removeClass('ld-saleskitview-block-stuff-delete');
        if(toObj.tagName !== 'UL') {
            SortableEvent.clone.className = 'ld_saleskitlist_stuff ld_listchosestuff';
            ld(SortableEvent.clone).find('.tag').css('display','block');
            if(newsaleskit<0){//非新建自定义简报
                //将这个拖动的那个简报信息给选中的数组
                popupobj.selected_saleskit_list[stufflabel] = popupobj.detault_saleskit_list[stufflabel];
            }else if(newsaleskit>=0){
                //新建简报
                var cur_stufflabelid=parseInt(stufflabel.slice(4));
                var newstufflabelid=cur_stufflabelid+1;
                PopupJqObj.find(' .ld_saleskitnew').data('stufflabel','NEW_'+newstufflabelid);
                var label = liobj.find('.tip-items-list').data('tip');
                var NewStuffInfoArr = that.getNewStuffInfoArr();
                NewStuffInfoArr.stufflabel = stufflabel;
                NewStuffInfoArr.label = label;
                NewStuffInfoArr.zh = label;
                NewStuffInfoArr.en = label;
                NewStuffInfoArr.css = '';
                popupobj.selected_saleskit_list[stufflabel] = NewStuffInfoArr;
            }
            popupobj.selected_saleskit_list[stufflabel].used = 'yes';
            var SalesKitStuff_html = that.getSalesKitStuffhtml(popupobj.selected_saleskit_list[stufflabel]);
            //var colcount=that.saleskit_layout.colcount;//每行多少个简报
            //var curheight=that.saleskit_layout.height;//每行简报高度

            toObj = ld(toObj);
            //toObj.before('<div class="ld_saleskitview_stuff ld_saleskitview_block_stuff" style="width:calc(100% / '+colcount+' - 10px);height:'+curheight+'px;margin:5px;overflow: hidden;">'+SalesKitStuff_html+'</div>');
            toObj.before(SalesKitStuff_html);//返回的html中有上一行的div
            that.dragEvent_layout(toObj.prev().get(0));
            toObj.find('li').remove();
            toObj.prev().get(0).scrollIntoView({ behavior: "smooth" , block : "center"});
            tooltip('#'+popupobj.divid+' #saleskitlist_all [data-stufflabel="'+stufflabel+'"] .sort-tip-items', {transition: true, time: 200});
            tooltip('#'+popupobj.divid+' #saleskitstuff_'+stufflabel, {transition: true, time: 200});
            that.SelectSalesKit_Setting(PopupJqObj.find(' .ld_saleskitview_stuff #saleskitstuff_'+stufflabel));
        }
    };
    this.getNewStuffInfoArr = function () {
        return {
            'stufflabel' : '',
            'zh' : '',
            'en' : '',
            'sequence' : 0,
            'label' : '',
            'computeinfo' : [
                {
                    'homestuffdetailid' : 0,
                    'computemodule' : 'Accounts',
                    'computetype' : 'count',
                    'computecolumns' : 'ld_account.account_no',
                    'viewrange' : '',
                    'daterange' : '',
                    'advance_demand' : '[]',
                    'advance_demand_groups' : '[]',
                }
            ],
            'icon' : '',
            'css' : '',
            'is_default' : 'no',
            'used' : 'yes',//是否被选中
        }
    }
    //右侧简报区块的拖动
    this.dragEvent_layout=function(obj){
        Sortable.create(obj, {
            group: 'stuff',
            animation: 150,
            sort:true,
            //edit: xll 2023/11/09 BUG0074785 kfbcrm-数据简报设置-将空白简报拖到设置好的区块上，显示错误
            filter: '.ld_saleskitview_stuff_new',
            onMove: function (evt){
                //wyt 230613 BUG0068118 销售简报设置：可以通过拖拽将板块卡在已设好的板块当中
                ld(evt.dragged).css('display','none');
                //BUG0076943 空态和已选简报之间不可交换位置
                if(ld(evt.to).hasClass('ld_saleskitview_stuff_new')){
                    return false;// return false; — for cancel
                }
            },
            onEnd: function (evt){
                var drag_stuffid=evt.item.id;
                var move_stuff=ld(evt.to).children("div:not([id='"+drag_stuffid+"'])");
                //BUG0076943 空态和已选简报之间不可交换位置
                if(ld(evt.to).hasClass('ld_saleskitview_stuff_new')){
                    return false;// return false; — for cancel
                }
                if(evt.from!=evt.to){
                    ld(evt.from).html(move_stuff);
                }
                ld(evt.item).css('display','block');
            }
        })
    }

    //选择简报
    this.SelectSalesKit_Setting=function(obj){
        //选中样式
        PopupJqObj.find(' .ld_saleskitstuff').attr('cur_selected','').css('border','1px solid #F7F8FA');
        PopupJqObj.find(' .ld_saleskitstuff').parent().css('border','1px dashed #DCDEE0');
        ld(obj).attr('cur_selected','yes');

        ld(obj).parent().css('border','1px dashed #3B7CFF');

        var stufflabel=ld(obj).data('stufflabel');
        //切换布局设置和全局设置事件
        PopupJqObj.find(' .ld_saleskit_settingdetail').show();
        PopupJqObj.find(' .ld_saleskit_settingdetail[tag=0]').css('width','35%');//tag=0布局设置 tag==1全局设置
        PopupJqObj.find(' .ld_saleskit_settingdetail[tag=1]').css('width','35%');

        ld(obj).addClass('ld_saleskitlist_stuff_active');
        PopupJqObj.find(' #saleskitset_layout').hide();
        PopupJqObj.find(' #saleskitset_stuff').show();
        //切换布局设置全局设置
        PopupJqObj.find(' #saleskitset .ld_saleskit_settingdetail[tag=0]').removeClass('CurSetType');
        PopupJqObj.find(' #saleskitset .ld_saleskit_settingdetail[tag=1]').addClass('CurSetType');

        that.getStuffDetailSetDetail(stufflabel);
    }

    this.SaveSalesKitSetReport=function(){
        that.resetSequence();//重设排序值
        //判断必填项
        var ret = 'yes';
        ld.each(popupobj.selected_saleskit_list,function (stufflabel,stuffdetailinfo){
            if(empty(stuffdetailinfo.zh) ||stuffdetailinfo.zh==''){
                var confirm_str = stuffdetailinfo.label+arrJsPopLabel['ChineseName']+arrJsPopLabel['Empty'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                ret = 'no';
                return false;
            }
            if(empty(stuffdetailinfo.en) ||stuffdetailinfo.en==''){
                var confirm_str = stuffdetailinfo.label+arrJsPopLabel['EnglishName']+arrJsPopLabel['Empty'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                ret = 'no';
                return false;
            }
        });
        if(ret=='no'){
            return false;
        }
        var boardid=popupobj.boardid;
        var layoutinfo = that.saleskit_layout;
        if(layoutinfo.height<120 || layoutinfo.height>230){//wyt 230619 BUG0068480 kfbcrm-销售简报-直接输入组件行高，低于120或高于230也可以保存生效
            var confirm_str = arrJsPopLabel['BEYONDHEIGHT'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        that.selected_saleskit_list = popupobj.selected_saleskit_list;
        if(boardid<=0){
            var createboard_popupobj = CrmPopup.getPopupObj("lastprev");
            createboard_popupobj.saleskitObj = that;
            //看板简报数据预览
            var saleskitHtml = that.getSalesKitListStuffhtml();
            ld('#'+createboard_popupobj.divid).find('#preview_stuffcont_35').html(saleskitHtml);
            popupobj.canceledit();
            DelProgressObjs();
        }else{
            that.saveSalesKitAjaxFun(boardid);
        }

    }
    that.saveSalesKitAjaxFun = function(boardid){
        var selected_saleskit_list=that.selected_saleskit_list;
        selected_saleskit_list=JSON.stringify(selected_saleskit_list);
        var saleskit_layout=JSON.stringify(that.saleskit_layout);
        var params='&boardid='+boardid;
        var formData=new FormData();
        formData.append('SalesKitInfo',selected_saleskit_list);
        formData.append('saleskit_layout',saleskit_layout);
        var module = getUrlParam("pageto_module");
        var url='index.php?module='+module+'&action='+module+'Ajax&file=SalesKitSet&mode=NewsaleskitSave'+params;
        ldAjax_File(url,formData,function(data){
            if(data.code == 1){
                popupobj.canceledit();
                ld('#stuffcont_').css('min-height',data.result.allheight+'px');
                DelProgressObjs();
            }
            //zxm 20230830 销售简报编辑保存之后 只刷新简报数据  不全局刷新
            var createboard_popupobj = CrmPopup.getPopupObj("last");
            if(!empty(createboard_popupobj)&&createboard_popupobj.homeboardobj){
                //看板编辑界面  简报的修改也要刷新
                createboard_popupobj.homeboardobj.loadStuff(35,'saleskit');
            }else{
                loadStuff(35,'saleskit');
            }

            /**
             var surl = 'index.php?module='+module+'&file=Homeboard_index&action='+module+'Ajax';
             if(boardid > 0){
                surl += '&boardid='+boardid;
            }
             var listcontentobj=ld("#pagecontent .wrapper-panel-inner");
             ldAjaxHtml(surl,'',function(data){
                if(module == 'VisualAnalysis'){
                    ViewBoardShow(data);
                }
                else{
                    listcontentobj.html(data);
                }
                DelProgressObjs();
            })*/
        });
    }
    //传入模块 查询该模块字段
    this.getFieldsByModule = function(stufflabel,stuffdetailInfo,computeInfo,rowindex,changetype=''){
        var params='&selectmodule='+computeInfo.computemodule;
        var url = 'index.php?module=Home&action=HomeAjax&file=SalesKitSet&mode=getModuleFields';
        //生成下拉框
        ldAjax(url,params,function (data){
            if(data.code==1){
                that.mainfield_arr = data.result.main_field_arr;
                that.detailfield_arr = data.result.detail_field_arr;

                //wyt 230619 BUG0068126 销售简报设置：在自定义简报中，当计算方式选[求和]时，自动筛选出统计字段中的数字数量字段，不相干的文本字段不予显示
                var computetype=computeInfo.computetype;

                if(computetype=='count'||computetype=='ucount'){
                    computetype = 'count';
                }

                if(computetype=='sum'||computetype=='max'||computetype=='min'||computetype=='avg'){
                    computetype = 'sum';
                }

                //统计字段
                var computecol_html=data.result.SalesKitfieldsArr[computetype+'FieldOption'];//计算字段下拉框
                PopupJqObj.find(' #computecolumns_'+rowindex).html(computecol_html);


                if(changetype!='computetype_change') {
                    //筛选器查看范围
                    var viewrange_html = data.result.SalesKitfieldsArr['smowneridFieldOption'];//查看范围下拉框
                    PopupJqObj.find(' #viewrange_' + rowindex).html(viewrange_html);
                    //PopupJqObj.find(' #viewrange_'+rowindex).val(computeInfo.viewrange);

                    //时间范围筛选器
                    var daterange_html = data.result.SalesKitfieldsArr['timeFieldOption'];//查看范围下拉框
                    PopupJqObj.find(' #daterange_' + rowindex).html(daterange_html);
                }
                //PopupJqObj.find(' #daterange_'+rowindex).val(computeInfo.daterange);
                var compute_databindArr = {
                    //'mainmodule':'computemodule',
                    //'computetype':'computetype',
                    'computecolumns':'computecolumns',
                    // 'viewrange':'viewrange',
                    // 'viewrange_isrelated':'viewrange_isrelated',
                    // 'daterange':'daterange',
                    // 'daterange_isrelated':'daterange_isrelated',
                }
                //edit: xll 2024/02/22 BUG20240218-30 统计字段选择报价单分录明细的“产品名称”保存后没有生效, 缺少为空的判断
                if(empty(computeInfo.computecolumns) && (computeInfo.computetype==='count' || computeInfo.computetype==='ucount')){
                    var firstmodulename='';
                    ld.each(  that.mainfield_arr,function(tmpmodulename,tmpinfo){
                        firstmodulename=tmpmodulename;
                        return false;
                    })
                    ld.each(  that.mainfield_arr[firstmodulename] ,function(tmpindex,tmpfieldinfo){
                        //edit:can  BUG20240116-21 kfbcrm-首页-销售简报-新建跟进记录数量，显示数据为0，点击简报设置，统计字段为空，应控制统计字段不能为空，默认为模块超链接字段 ;
                        if(tmpfieldinfo.ishreflink=='yes')
                        {
                            computeInfo.computecolumns=tmpfieldinfo.compute_column
                            return false;
                        }
                    })
                }
                if(changetype!='computetype_change'){
                    compute_databindArr['computetype'] = 'computetype';
                    compute_databindArr['viewrange'] = 'viewrange';
                    compute_databindArr['viewrange_isrelated'] = 'viewrange_isrelated';
                    compute_databindArr['daterange'] = 'daterange';
                    compute_databindArr['daterange_isrelated'] = 'daterange_isrelated';
                }
                ld.each(compute_databindArr,function(idname,keyname){

                    var tmpJqObj = PopupJqObj.find('#'+idname+'_'+rowindex);
                    var DataHtmlBindobj =new DataHtmlBind();
                    DataHtmlBindobj.setDataBindByJqObj(tmpJqObj, computeInfo, keyname);
                    if(idname!='viewrange_isrelated'&&idname!='daterange_isrelated'){
                        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpJqObj.attr("name"));
                        cls_resetComboxHtmlobj.setPopupObj(popupobj);
                        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpJqObj,235);
                    }
                });
                that.setSelectedSalesKitComputeInfoEvent(stufflabel,rowindex);
                DelProgressObjs();
            }
        });
    }
    //生成组件html方法--新的 20240716 zxm 从后台请求真实数据
    this.getSalesKitStuffhtml = function(stuffdetailInfo){
        var stufflabel = stuffdetailInfo.stufflabel;
        var tmphtml='';
        //获取简报数据--单个简报数据 根据stufflabel--不要控制参数boardid 主要是为了简报编辑界面 实时获取简报数据
        var url = 'index.php?module=Home&action=HomeAjax&file=SalesKitSet&mode=getSalesKitByStuffLabel';
        var isshowprevious = that.saleskit_layout.isshowprevious===true?'yes':'no';
        var ShowPercent = that.saleskit_layout.ShowPercent===true?'yes':'no';
        var saleskitCount = parseInt(that.saleskit_layout['count']) + 1;
        that.saleskit_layout['count'] = saleskitCount;
        //时间人员审批参数
        var params = getHomeAllParams();
        params += '&saleskitCount='+saleskitCount+'&stufflabel='+stufflabel+'&stuffid=35&boardid='+popupobj.boardid+'&isshowprevious='+isshowprevious+'&ShowPercent='+ShowPercent+'&stuffdetailInfo='+JSON.stringify(stuffdetailInfo);
        //{saleskitCount:saleskitCount,stufflabel:stufflabel,stuffid:35,boardid:popupobj.boardid,isshowprevious:isshowprevious,ShowPercent:ShowPercent,stuffdetailInfo:JSON.stringify(stuffdetailInfo)}
        //生成下拉框--同步
        ldAjaxsync(url,params,function (data){
            tmphtml = data.result.content;
        });
        ld('#rptContentLoading').hide();
        return tmphtml;
    }
    //生成组件html方法 新建看板的时候 从前台传参过去获取简报数据
    this.getSalesKitListStuffhtml = function(){
        var tmphtml='';
        //获取简报数据--单个简报数据 根据stufflabel--不要控制参数boardid 主要是为了简报编辑界面 实时获取简报数据
        var url = 'index.php?module=Home&action=HomeAjax&file=SalesKitSet&mode=getSalesKitListByStuffLabel';
        var selected_saleskit_list=that.selected_saleskit_list;
        selected_saleskit_list=JSON.stringify(selected_saleskit_list);
        var saleskit_layout=JSON.stringify(that.saleskit_layout);
        //时间人员审批参数
        var params = getHomeAllParams();
        params += '&stuffid=35&selected_saleskit_list='+selected_saleskit_list+'&saleskit_layout='+saleskit_layout;
        //生成下拉框--同步
        ldAjaxsync(url,params,function (data){
            tmphtml = data.result.content;
        });
        ld('#rptContentLoading').hide();
        return tmphtml;
    }
}
SalesKitSetReport.funname = 'SalesKitSetReport';







